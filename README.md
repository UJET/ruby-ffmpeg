RUBY-FFMPEG
===========

Original repo from [streamio-ffmpeg](https://github.com/streamio/streamio-ffmpeg). Thanks to the Streamio guys!

It is heavily modified with support for new use cases not covered in the original gem. This is a work in progress. If you need something
urgently, file a request. I should be able to add it off fast.


Major changes
1. Input options. Seek and loop support added. - More coming soon
2. FFMPEG Simple Filters Support. Basic crop, scale, pad, select, denoise, deinterlace added. - More coming soon
3. Multiple Output support - Added
4. Support for setting default audio/video codec
5. Support for various external libraries. AAC and MP3 now configurable.


Installation
------------
    git clone http://github.com/omkiran/ruby-ffmpeg
    cd ruby-ffmpeg
    gem build ruby-ffmpeg.gemspec
    (sudo) gem install ruby-ffmpeg.0.1.0.gem 
    Not available on rubygems.org yet. Will add it soon.

Compatibility
-------------

### Ruby

Only guaranteed to work with MRI Ruby 1.9.3 or later. 

### ffmpeg

Tested against latest head on ffmpeg currently. Will resort to better versioning soon.

Usage
-----
 If you have used streamio-ffmpeg it is similar, but there are changes. Read below.


### Require the gem

``` ruby
require 'ruby-ffmpeg'
```

### Default parameters

Set the following if you want them changed.
FFMPEG.codec_options.default_audio # "aac"
FFMPEG.codec_options.default_video # "mp3"
FFMPEG.codec_options.aac = "native" # Inbuilt AAC encoder 
Other options for aac are faac and fdk
FFMPEG.codec_options.mp3 = "native" # Inbuilt mp3 encoder
Other option is lame



### Reading Metadata

``` ruby
movie = FFMPEG::Movie.new("path/to/movie.mov")

movie.duration # 7.5 (duration of the movie in seconds)
movie.bitrate # 481 (bitrate in kb/s)
movie.size # 455546 (filesize in bytes)

movie.video_stream # "h264, yuv420p, 640x480 [PAR 1:1 DAR 4:3], 371 kb/s, 16.75 fps, 15 tbr, 600 tbn, 1200 tbc" (raw video stream info)
movie.video_codec # "h264"
movie.colorspace # "yuv420p"
movie.resolution # "640x480"
movie.width # 640 (width of the movie in pixels)
movie.height # 480 (height of the movie in pixels)
movie.frame_rate # 16.72 (frames per second)

movie.audio_stream # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)
movie.audio_codec # "aac"
movie.audio_sample_rate # 44100
movie.audio_channels # 2

movie.valid? # true (would be false if ffmpeg fails to read the movie)
```

### Transcoding

First argument is the output file path.

``` ruby
movie.transcode("tmp/movie.mp4") # Default ffmpeg settings for mp4 format
```

Keep track of progress with an optional block.

``` ruby
movie.transcode("movie.mp4") { |progress| puts progress } # 0.2 ... 0.5 ... 1.0
```

Use the EncodingOptions parser for humanly readable transcoding options. Below you'll find most of the supported options. Note that the :custom key will be used as is without modification so use it for any tricky business you might need.

``` ruby
encoding_options = {video_codec: "libx264", frame_rate: 10, resolution: "320x240", video_bitrate: 300, video_bitrate_tolerance: 100,
           aspect: 1.333333, keyframe_interval: 90,
           audio_codec: "libfaac", audio_bitrate: 32, audio_sample_rate: 22050, audio_channels: 1,
           threads: 2,
           custom: "-vf crop=60:60:10:10"}
movie.transcode("movie.mp4", encoding_options)
```

This is where we have the first difference with streamio. Support for input options. 
1. loop
2. Seek

Loop of 0 gives an infinite loop, you probably don't want that.
Seek is in milliseconds and allows you to seek to the point before starting the video processing.

Multiple outputs (Explain here)

The transcode function returns a Movie object for the encoded file.

``` ruby
transcoded_movie = movie.transcode("tmp/movie.flv")

transcoded_movie.video_codec # "flv"
transcoded_movie.audio_codec # "mp3"
```

Aspect ratio is added to encoding options automatically if none is specified.

``` ruby
options = { resolution: "320x180" } # Will add -aspect 1.77777777777778 to ffmpeg
```

Preserve aspect ratio on width or height by using the preserve_aspect_ratio transcoder option.

``` ruby
widescreen_movie = FFMPEG::Movie.new("path/to/widescreen_movie.mov")

options = { resolution: "320x240" }

transcoder_options = { preserve_aspect_ratio: :width }
widescreen_movie.transcode("movie.mp4", options, transcoder_options) # Output resolution will be 320x180

transcoder_options = { preserve_aspect_ratio: :height }
widescreen_movie.transcode("movie.mp4", options, transcoder_options) # Output resolution will be 426x240
```

For constant bitrate encoding use video_min_bitrate and video_max_bitrate with buffer_size.

``` ruby
options = {video_min_bitrate: 600, video_max_bitrate: 600, buffer_size: 2000}
movie.transcode("movie.flv", options)
```

### Taking Screenshots

You can use the screenshot method to make taking screenshots a bit simpler.

``` ruby
movie.screenshot("screenshot.jpg")
```

The screenshot method has the very same API as transcode so the same options will work.

``` ruby
movie.screenshot("screenshot.bmp", seek_time: 5, resolution: '320x240')
```

You can preserve aspect ratio the same way as when using transcode.

``` ruby
movie.screenshot("screenshot.png", { seek_time: 2, resolution: '200x120' }, preserve_aspect_ratio: :width)
```

Specify the path to ffmpeg
--------------------------

By default, gem assumes that the ffmpeg binary is available in the execution path and named ffmpeg and so will run commands that look something like "ffmpeg -i /path/to/input.file ...". Use the FFMPEG.ffmpeg_binary setter to specify the full path to the binary if necessary:

``` ruby
FFMPEG.ffmpeg_binary = '/usr/local/bin/ffmpeg'
```

This will cause the same command to run as "/usr/local/bin/ffmpeg -i /path/to/input.file ..." instead.


Automatically kill hung processes
---------------------------------

By default, gem will wait for 30 seconds between IO feedback from the FFMPEG process. After which an error is logged and the process killed.
It is possible to modify this behaviour by setting a new default:

``` ruby
# Change the timeout
Transcoder.timeout = 10

# Disable the timeout altogether
Transcoder.timeout = false
```


Copyright
---------
Original license from Streamio. See LICENSE for details.

Thank You
---------
Streamio for the original gem.
