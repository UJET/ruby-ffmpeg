module FFMPEG

  class EncodingOptions < Hash

    def initialize(options = {})
      merge!(options)
      @acodec = FFMPEG.codec_options.default_audio
      @vcodec = FFMPEG.codec_options.default_video
    end

    def to_s
      params = collect do |key, value|
        send("convert_#{key}", value) if value && supports_option?(key)
      end

      # codecs should go before the presets so that the files will be matched successfully
      # all other parameters go after so that we can override whatever is in the preset
      codecs        = params.select { |p| p =~ /codec/ }
      presets       = params.select { |p| p =~ /\-.pre/ }
      video_filters = params.select { |p| (p=~/-vf /) }
      audio_filters = params.select { |p| (p=~/-af /) }
      acodec        = params.select { |p| (p =~ /acodec/ or p == "-an") }
      vcodec        = params.select { |p| (p =~ /vcodec/ or p == "-vn") }      
      audio_params  = params.select { |p| (p=~/:a/ or p=~/-ac / or p=~/-ar/ ) } 
      video_params  = params.select { |p| (p=~/:v/ or p=~/-g/ or p=~/-keyint_min/) } 
      other         = params - acodec - vcodec - audio_params - video_params - presets - audio_filters - video_filters
      params        = other
      params        = params + acodec
      audio_filter_string  = audio_filters.empty? ? [] : ["-af #{( audio_filters.collect{ |af| af.split(' ').last }).join(',')}"] 
      params        = params + audio_filter_string + audio_params if @acodec != "none"
      video_filters_string = video_filters.empty? ? [] : ["-vf #{( video_filters.collect do |vf| vf.split(' ').last  end).join(',')}"]
      params        = params + vcodec
      params        = params + presets + video_filters_string + video_params if @vcodec != "none"
      params_string = params.join(" ")
      params_string << " #{convert_aspect(calculate_aspect)}" if calculate_aspect?
      params_string
    end

    def width
      self[:resolution].split("x").first.to_i rescue nil
    end

    def height
      self[:resolution].split("x").last.to_i rescue nil
    end

    private
    def supports_option?(option)
      option = RUBY_VERSION < "1.9" ? "convert_#{option}" : "convert_#{option}".to_sym
      private_methods.include?(option)
    end

    def convert_aspect(value)
      "-aspect #{value}"
    end

    def calculate_aspect
      width, height = self[:resolution].split("x")
      width.to_f / height.to_f
    end

    def calculate_aspect?
      self[:aspect].nil? && self[:resolution]
    end

    def convert_video_codec(value)
      @vcodec = value
      if @vcodec == "none"
          "-vn"
      else
          "-vcodec #{value}"
      end
    end

    def convert_frame_rate(value)
      "-r #{value}"
    end

    def convert_resolution(value)
      "-s #{value}"
    end

    def convert_video_bitrate(value)
      "-b:v #{k_format(value)}"
    end

    def convert_audio_codec(value)
       @acodec = value
       if @acodec == "none"
            "-an"
       else
            # Now here we choose amongst the aac options
            value = FFMPEG.codec_options.aac if value == "aac"
            value = FFMPEG.codec_options.mp3 if value == "mp3"
            "-acodec #{value}"
       end
    end

    def convert_audio_bitrate(value)
      "-b:a #{k_format(value)}"
    end

    def convert_audio_sample_rate(value)
      "-ar #{value}"
    end

    def convert_audio_channels(value)
      "-ac #{value}"
    end

    def convert_video_max_bitrate(value)
      "-maxrate #{k_format(value)}"
    end

    def convert_video_min_bitrate(value)
      "-minrate #{k_format(value)}"
    end

    def convert_buffer_size(value)
      "-bufsize #{k_format(value)}"
    end

    def convert_video_bitrate_tolerance(value)
      "-bt #{k_format(value)}"
    end

    def convert_threads(value)
      "-threads #{value}"
    end

    def convert_duration(value)
      "-t #{value}"
    end

    def convert_video_preset(value)
      "-vpre #{value}"
    end

    def convert_audio_preset(value)
      "-apre #{value}"
    end

    def convert_file_preset(value)
      "-fpre #{value}"
    end

    def convert_keyframe_interval(value)
      "-g #{value}"
    end

    def convert_seek_time(value)
      "-ss #{value}"
    end

    def convert_screenshot(value)
      value ? "-vframes 1" : ""
    end

    def convert_custom(value)
      value
    end

    def k_format(value)
      value.to_s.include?("k") ? value : "#{value}k"
    end

    ########## x264 specific values ###########
    def convert_aq_mode value
        "-aq-mode:v #{value}"
    end

    def convert_aq_strength value
        "-aq-strength:v #{value}"
    end

    ######### Simple filter support Can add more filters to this
    def convert_audio_filter_gain value
        "-af volume=#{value}"
    end

    def convert_video_filter_denoise value
        "-vf hqdn3d" + ( value ? "=#{value}" : "" )
    end
    def convert_video_filter_select value
        "-vf select=#{value}"
    end

    def convert_video_filter_deinterlace value
        "-vf yadif" + ( value ? "=#{value}" : "" )
    end

    def convert_video_filter_crop value
        "-vf crop=#{value}"
    end

    def convert_video_filter_drawtext value
        "-vf drawtext=#{value}"
    end

    def convert_video_filter_pad value
        "-vf pad=#{value}"
    end

    def convert_video_filter_scale value
        "-vf scale=#{value}"
    end

    def convert_video_filter_tile value
        "-vf tile=#{value}"
    end
  end
end
