require 'open3'
require 'shellwords'

module FFMPEG
  class Transcoder
    @@timeout = 30

    def self.timeout=(time)
      @@timeout = time
    end

    def self.timeout
      @@timeout
    end

    def initialize(movie, output_file, options = EncodingOptions.new, input_options={})
      @movie            = movie
      @output_file      = output_file
      @encoding_options = get_options(EncodingOptions, options)
      @input_options    = get_options(InputOptions,    input_options)
      @errors = []
    end

    def get_options(options_class, options)
      if options.is_a?(String) || options.is_a?(options_class)
        ret_options = options
      elsif options.is_a?(Hash)
        ret_options = options_class.new(options)
      else
        raise ArgumentError, "Unknown options format '#{options.class}', should be either EncodingOptions, Hash or String."
      end
      ret_options
    end
    # frame= 4855 fps= 46 q=31.0 size=   45306kB time=00:02:42.28 bitrate=2287.0kbits/

    def run
      command = "#{FFMPEG.ffmpeg_binary} -y #{@input_options} -i #{Shellwords.escape(@movie.path)} #{@encoding_options} #{Shellwords.escape(@output_file)}"
      FFMPEG.logger.info("Running transcoding...\n#{command}\n")
      output = ""
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        begin
          yield(0.0) if block_given?
          next_line = Proc.new do |line|
            fix_encoding(line)
            output << line
            if line.include?("time=")
              if line =~ /time=(\d+):(\d+):(\d+.\d+)/ # ffmpeg 0.8 and above style
                time = ($1.to_i * 3600) + ($2.to_i * 60) + $3.to_f
              else # better make sure it wont blow up in case of unexpected output
                time = 0.0
              end
              progress = time / @movie.duration
              yield(progress) if block_given?
            end
          end

          if @@timeout
            stderr.each_with_timeout(wait_thr.pid, @@timeout, 'size=', &next_line)
          else
            stderr.each('size=', &next_line)
          end

        rescue Timeout::Error => e
          FFMPEG.logger.error "Process hung...\nCommand\n#{command}\nOutput\n#{output}\n"
          raise Error, "Process hung. Full output: #{output}"
        end
      end

      if encoding_succeeded?
        yield(1.0) if block_given?
        FFMPEG.logger.info "Transcoding of #{@movie.path} to #{@output_file} succeeded\n"
      else
        errors = "Errors: #{@errors.join(", ")}. "
        FFMPEG.logger.error "Failed encoding...\n#{command}\n\n#{output}\n#{errors}\n"
        raise Error, "Failed encoding.#{errors}Full output: #{output}"
      end
      encoded
    end

    def encoding_succeeded?
      @errors << "no output file created" and return false unless File.exists?(@output_file)
      @errors << "encoded file is invalid" and return false unless encoded.valid?
      true
    end

    def encoded
      @encoded ||= Movie.new(@output_file)
    end

    private
    def fix_encoding(output)
      output[/test/]
    rescue ArgumentError
      output.force_encoding("ISO-8859-1")
    end
  end
end
