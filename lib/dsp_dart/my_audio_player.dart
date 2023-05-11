import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:typed_data';


import './synth.dart';

class MyAudioPlayer {
    // 384 batches/second
    static const _bufferSize = 125;
    static const _sampleRate = 48000;
    bool _isReady = false;
    Synth _synth = Synth(_sampleRate, _bufferSize);

    final SynthAudioStream _audioSource = SynthAudioStream(List.filled(0,_bufferSize));
    final AudioPlayer _player = AudioPlayer();


    bool _isPlaying = false;

    MyAudioPlayer();

    bool get isReady => _isReady;
    BytesBuilder _recording = BytesBuilder(); 

    Future<bool> init() async {
        _synth.initSynth();
        startSynth();
        //_isReady = await connectAudioSource(_player, _audioSource); 
        print('player readyness: $_isReady');
        return _isReady;
    }

    Future<bool> connectAudioSource(AudioPlayer player, StreamAudioSource stream) async {
        // Catching errors at load time
        try {
            print("connecting audio source to player");
            await player.setAudioSource(stream, initialPosition: Duration.zero, preload: false);
            print("audio source connected");
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
        print("audio source not connected.");
        return false;
    }
    
    void play(){
        //_player.play();
        //listenToErrors(_player);
    }

    void startSynth() async {
        _synth.play().listen((Uint8List data) {
            //_audioSource.bytes = data;
        }, onError: (Object e, StackTrace st) {
            print('An error occurred: $e');
            print('stacktrace: $st');
        });
    }

    void listenToErrors(AudioPlayer ap){
        ap.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
            if (e is PlayerException) { 
                print('Error code: ${e.code}');
                print('Error message: ${e.message}');
            } else {
                print('An error occurred: $e');
            }
        });
    }

    void pause() async {
        _player.pause();
        _synth.stopPlaying();
        _synth.writeSynthAudio();
    }

    void dispose(){
        _player.stop();
        _synth.dispose();
    }
}

class SynthAudioStream extends StreamAudioSource {
    List<int> bytes;

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