import 'package:just_audio/just_audio.dart';

import './synth.dart';

class StereoPlayer {
    static const BUFFER_SIZE = 512;
    static const SAMPLE_RATE = 44100;
    static tick = Duration(milliseconds:((1/SAMPLE_RATE)*1000));
    static final SynthAudioStreamer rChannel = SynthAudioStreamer(BUFFER_SIZE);
    static final SynthAudioStreamer lChannel = SynthAudioStreamer(BUFFER_SIZE);
    static final Synth synth = Synth();

    static bool isPlaying = false;

    StereoPlayer();

    Future<bool> init() async {
        if(synth.initSynth()){
            return await setAudioSource();
        }
        return false;
    }

    void play(){
        synthLoop();
        rChannel.play();
        lChannel.play();
    }

    void synthLoop() async {
        print('beginning to play');
        await Timer.periodic(tick, (Timer t) => {
            if(isPlaying){
                //synth.compute
                //rChannel.buffer
                //lChannel.buffer
            } else {
                print('finished playing');
            }
        });
    }
}

class SynthAudioStream extends StreamAudioSource {
    ByteData _buffer;

    SynthAudioStream(int buffer_size){
        _buffer = ByteData(buffer_size);
        super();
    }

    set buffer(List<double> data){
        _buffer.setFloat64(data);
    }

    @override
    Future<StreamAudioResponse> request([int? start, int? end]) async {
        return StreamAudioResponse(
            sourceLength: bufferSize,
            contentLength: bufferSize,
            offset: 0,
            stream: Stream.value(_buffer.asFloat32List()),
            contentType: 'audio/wav',
        );
    }
}

SynthAudioStreamer extends AudioPlayer {
    final SynthAudioStream audioStream;
    SynthAudioStreamer(int buffer_size){
        audioStream = SynthAudioStream(buffer_size);
        super();
    }

    Future<bool> connectAudioSource() async {
        // Catching errors at load time
        try {
            await this.setAudioSource(audioStream);
            return true;
        } on PlayerException catch (e) {
            // iOS/macOS: maps to NSError.code
            // Android: maps to ExoPlayerException.type
            // Web: maps to MediaError.code
            // Linux/Windows: maps to PlayerErrorCode.index
            print("Error code: ${e.code}");
            // iOS/macOS: maps to NSError.localizedDescription
            // Android: maps to ExoPlaybackException.getMessage()
            // Web/Linux: a generic message
            // Windows: MediaPlayerError.message
            print("Error message: ${e.message}");
        } on PlayerInterruptedException catch (e) {
            // This call was interrupted since another audio source was loaded or the
            // player was stopped or disposed before this audio source could complete
            // loading.
            print("Connection aborted: ${e.message}");
        } catch (e) {
            // Fallback for all other errors
            print('An error occured: $e');
        }
        return false;
    }

    set buffer(List<double> data){
        audioStream.buffer = data;
    }
}