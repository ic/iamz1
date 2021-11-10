
INRES="640x480" # input resolution
OUTRES="640x480" # output resolution
FPS="15" # target FPS
GOP="30" # i-frame interval, should be double of FPS,
GOPMIN="15" # min i-frame interval, should be equal to fps,
THREADS="2" # max 6
CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
QUALITY="ultrafast"  # one of the many FFMPEG preset
AUDIO_RATE="44100"

#STREAM_KEY="$1" # use the terminal command Streaming streamkeyhere to stream your video to twitch or justin
SERVER="live-sjc" # twitch server in California, see http://bashtech.net/twitch/ingest.php to change
 
ffmpeg -f flv -r "$FPS" -i /dev/video0 -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE \
-vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR \
-preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal \
-bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"


