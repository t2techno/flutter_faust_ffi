import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:typed_data';


import './synth.dart';

class StereoPlayer {
    static const _bufferSize = 512;
    static const _sampleRate = 44100;
    static const signedInt32Max = (1 << 31)-1;
    bool isReady = false;
    Synth synth = Synth(_bufferSize, _sampleRate);

    final SynthAudioStream lChannel = SynthAudioStream(List.filled(0,_bufferSize));
    final SynthAudioStream rChannel = SynthAudioStream(List.filled(0,_bufferSize));
    final AudioPlayer lPlayer = AudioPlayer();
    final AudioPlayer rPlayer = AudioPlayer();


    bool isPlaying = false;

    StereoPlayer();

    Future<bool> init() async {
        synth.initSynth();
        startSynth();
        isReady = await connectAudioSource(lPlayer, lChannel) &&
                await connectAudioSource(rPlayer, rChannel); 
        print('player readyness: $isReady');
        return isReady;
    }

    Future<bool> connectAudioSource(AudioPlayer player, StreamAudioSource stream) async {
        // Catching errors at load time
        try {
            print("connecting shit");
            await player.setAudioSource(stream);
            print("shit connected");
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
        print("shit not connected :(");
        return false;
    }
    
    void play(){
        lPlayer.play();
        rPlayer.play();

        listenTo(lPlayer);
        listenTo(rPlayer);
    }

    void startSynth() async {
        synth.play().listen((List<Float32List> data) {
            //lChannel.bytes = data[0].map((f) => (f*signedInt32Max).toInt()).toList();
            //rChannel.bytes = data[1].map((f) => (f*signedInt32Max).toInt()).toList();
        }, onError: (Object e, StackTrace st) {
            print('An error occurred: $e');
            print('stacktrace: $st');
        });
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

    void dispose(){
        lPlayer.stop();
        rPlayer.stop();
        synth.dispose();
    }
}

class SynthAudioStream extends StreamAudioSource {
    final List<int> bytes;

    SynthAudioStream(this.bytes);

    @override
    Future<StreamAudioResponse> request([int? start, int? end]) async {
        start ??= 0;
        end ??= bytes.length;
        return StreamAudioResponse(
            sourceLength: bytes.length,
            contentLength: end - start,
            offset: start,
            stream: Stream.value(bytes.sublist(start, end)),
            contentType: 'audio/wave',
        );
    }
}