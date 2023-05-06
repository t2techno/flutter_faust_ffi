import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:typed_data';


import './synth.dart';

class StereoPlayer {
    static const _bufferSize = 512;
    static const _sampleRate = 44100;
    static const tick = Duration(microseconds:1000000~/_sampleRate);
    static final SynthAudioStreamer rChannel = SynthAudioStreamer(_bufferSize);
    static final SynthAudioStreamer lChannel = SynthAudioStreamer(_bufferSize);
    static final Synth synth = Synth(_bufferSize,_sampleRate);

    static bool isPlaying = false;

    StereoPlayer();

    Future<bool> init() async {
        if(synth.initSynth()){
            return await lChannel.connectAudioSource() &&
                   await rChannel.connectAudioSource();
        }
        return false;
    }

    void play(){
        synthLoop();
        lChannel.play();
        rChannel.play();
    }

    void synthLoop() async {
        print('beginning to play');
        Timer.periodic(tick, (Timer t) {
            if(isPlaying){
                synth.compute();
                lChannel.buffer  = synth.leftChannel;
                rChannel.buffer  = synth.rightChannel;
            } else {
                print('finished playing');
            }
        });
    }
}

class SynthAudioStreamer extends AudioPlayer {
    late final SynthAudioStream audioStream;
    SynthAudioStreamer(int bufferSize){
        audioStream = SynthAudioStream(bufferSize);
    }

    Future<bool> connectAudioSource() async {
        // Catching errors at load time
        try {
            await setAudioSource(audioStream);
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

    set buffer(Float32List data){
        audioStream.buffer = data;
    }
}


class SynthAudioStream extends StreamAudioSource {
    late ByteData _buffer;

    SynthAudioStream(int bufferSize){
        // 32-bit floats
        _buffer = ByteData(bufferSize*4);
    }

    set buffer(Float32List data){
        _buffer = ByteData.sublistView(data);
    }

    @override
    Future<StreamAudioResponse> request([int? start, int? end]) async {
        return StreamAudioResponse(
            sourceLength:  _buffer.lengthInBytes,
            contentLength: _buffer.lengthInBytes,
            offset: 0,
            stream: Stream.value(_buffer.buffer.asInt32List()),
            contentType: 'audio/wav',
        );
    }
}