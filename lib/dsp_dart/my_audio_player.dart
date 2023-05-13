import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';
import 'dart:typed_data';


import './synth.dart';

class MyAudioPlayer {
    // 384 batches/second
    static const _bufferSize = 125;
    static const _sampleRate = 48000;
    static const _bitRate = 16;
    static const _numChannels = 2;
    static const _tick = Duration(microseconds:(1000000*_bufferSize)~/_sampleRate);
    bool _isReady = false;

    // extends StreamAudioSource
    Synth _synth = Synth(_sampleRate, _bufferSize, _bitRate, _numChannels, true);
    final AudioPlayer _player = AudioPlayer();
    late final audioSession;
    
    //don't need this right now
    //BytesBuilder _recording = BytesBuilder(); 

    MyAudioPlayer();

    bool get isReady => _isReady;

    Future<bool> init() async {
        _synth.initSynth();
        audioSession = await AudioSession.instance;
        await audioSession.configure(AudioSessionConfiguration.music());
        _isReady = await connectAudioSource();
        print('player readyness: $_isReady');
        return _isReady;
    }

    Future<bool> connectAudioSource() async {
        // Catching errors at load time
        try {
            print("connecting audio source to player");
            await _player.setAudioSource(_synth, initialPosition: Duration.zero, preload: false);
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
    
    Future<void> play() async {
        listenToErrors();
        listenToStreamState();
        while(true){
            _player.play();
            Future.delayed(_tick);
        }
    }

    void listenToErrors(){
        _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
            if (e is PlayerException) { 
                print('Error code: ${e.code}');
                print('Error message: ${e.message}');
            } else {
                print('An error occurred: $e');
            }
        });
    }

    void listenToStreamState(){
        _player.playerStateStream.listen((state) {
            if (state.playing) {
                print('idle');
            } else {
                switch (state.processingState) {
                    case ProcessingState.idle:
                        print('idle');
                        break;
                    case ProcessingState.loading:
                        print('loading');
                        break;
                    case ProcessingState.buffering:
                        print('buffering');
                        break;
                    case ProcessingState.ready:
                        print('ready');
                        break;
                    case ProcessingState.completed:
                        print('completed');
                        break;
                    default:
                        print('new state: ${state.processingState}');
                        break;
                }
            }
        });
    }

    void pause() async {
        _player.pause();
    }

    void dispose(){
        _player.stop();
        _synth.dispose();
    }
}