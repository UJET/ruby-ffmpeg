module FFMPEG
  class CodecOptions
    attr_reader :aac, :mp3, :default_audio, :default_video
    def initialize
        @aac = "aac"
        @mp3 = "mp3"
        @h264 = "libx264"
        @default_audio = "aac"
        @default_video = "h264"
    end

    def default_audio= value
        @default_audio = value
    end

    def default_video= value
        @default_video = value
    end

    def mp3= value
        case value
        when "native"
           @mp3 = "mp3"
        when "lame"
           @mp3 = "libmp3lame"
        else
           raise ArgumentError, "Invalid codec setting. Only one of native, faac and fdk allowed."
        end
    end

    def aac= value
        case value
        when "native"
           @aac = "aac"
        when "faac" 
           @aac = "libfaac"
        when "fdk"
           @aac = "libfdk_aac"
        else
           raise ArgumentError, "Invalid codec setting. Only one of native, faac and fdk allowed."
        end
    end
  end
end
    
        
        
        
