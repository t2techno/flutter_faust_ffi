import 'package:just_audio/just_audio.dart';

import './synth.dart';

class MyAudioPlayer {
    static final AudioPlayer audioPlayer = AudioPlayer();
    static final Synth synth = Synth();

    MyAudioPlayer();

    Future<bool> init() async {
        if(synth.initSynth()){
            return await setAudioSource();
        }
        return false;
    }

    Future<bool> setAudioSource() async {
        // Catching errors at load time
        try {
            await audioPlayer.setAudioSource(synth);
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
        audioPlayer.play();
    }
}