module FFMPEG
  class InputOptions < Hash
    def initialize(options = {})
        merge!(options)
    end
    def to_s
        params = collect do |key, value|
          send("convert_#{key}", value) if value && supports_option?(key)
        end
        params_string = params.join(" ")
    end
    def convert_analyzeduration value
       "-analyzeduration #{value}" 
    end 
    def convert_analyzesize value
        "-probesize #{value}"
    end
    def convert_loop(value)
        "-loop #{value}"
    end
    def convert_seek_time(value)
        "-ss #{value}"
    end
    # Use only for raw input formats
    def convert_frame_rate(value)
        "-r #{value}"
    end
    def convert_format value
        "-f #{value}"
    end
  end
end
