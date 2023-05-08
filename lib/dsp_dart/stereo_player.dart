import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:typed_data';


import './synth.dart';

class StereoPlayer {
    static const _bufferSize = 512;
    static const _sampleRate = 44100;
    static final Synth synth = Synth(_bufferSize, _sampleRate);

    static final SynthAudioStream lChannel = SynthAudioStream(synth, _bufferSize, true);
    static final SynthAudioStream rChannel = SynthAudioStream(synth, _bufferSize, false);
    static final AudioPlayer lPlayer = AudioPlayer();
    static final AudioPlayer rPlayer = AudioPlayer();


    static bool isPlaying = false;

    StereoPlayer();

    Future<bool> init() async {
        return  await connectAudioSource(lPlayer, lChannel) &&
                await connectAudioSource(rPlayer, rChannel);
    }

    Future<bool> connectAudioSource(AudioPlayer player, StreamAudioSource stream) async {
        // Catching errors at load time
        try {
            await player.setAudioSource(stream);
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
    
    void play(){
        lPlayer.play();
        rPlayer.play();

        listenTo(lPlayer);
        listenTo(rPlayer);
    }

    void listenTo(AudioPlayer ap){
        ap.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
            if (e is PlayerException) {
                print('Error code: ${e.code}');
                print('Error message: ${e.message}');
            } else {
                print('An error occurred: $e');
            }
        });
    }

    void stop() async {
        await lPlayer.stop();
        await rPlayer.stop();
        synth.stopPlaying();
    }
}

class SynthAudioStream extends StreamAudioSource {
    static const signedInt32Max = 1 << 31;
    late int _bufferSize;
    late bool _isLeft;
    late Synth _synth;

    SynthAudioStream(Synth synth, int bufferSize, bool isLeft){
        // 32-bit floats
        _bufferSize = bufferSize;
        _isLeft = isLeft;
        _synth = synth;
    }

    @override
    Future<StreamAudioResponse> request([int? start, int? end]) async {
        return StreamAudioResponse(
            sourceLength:  _bufferSize,
            contentLength: _bufferSize,
            offset: 0,
            stream: play(),
            contentType: 'audio/mp3',
        );
    }

    Stream<List<int>> play() async* {
        await for(final List<Float32List> value in _synth.play()){
            if(_isLeft){
                yield value[0].map((f) => (f*signedInt32Max).toInt()).toList();
                continue;
            }
            yield value[1].map((f) => (f*signedInt32Max).toInt()).toList();
        }
    }
}