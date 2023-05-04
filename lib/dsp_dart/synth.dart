import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

import 'package:just_audio/just_audio.dart';

import './api_types.dart';

class Synth extends StreamAudioSource {
    static final libraryPath = path.join(
        Directory.current.path, 'assets', 'faust_c.dll');

    static late final DynamicLibrary dylib;
    static late final NewMyDsp newmydsp;
    static late final InitMyDsp initmydsp;
    static late final BuildUserInterfaceMyDsp buildUserInterfacemydsp;
    static late final ComputeMyDsp computemydsp;
    static late final DeleteMyDsp deletemydsp;
    static late final Pointer<MyDsp> mydsp;
    static late final Pointer<UiGlue> uiInterface;
    static const sampleRate = 44100;
    static const bufferSize = 512;
    static final List<List<double>> _buffer = List.filled(2,List.filled(bufferSize, 0.0));

    Synth();

    bool initSynth(){
        if(loadDll()){
            return initializeDsp();
        }
        return false;
    }

    bool loadDll(){
        // open library
        try {
            dylib = DynamicLibrary.open(libraryPath);
        } catch(e) {
            print('There was an error loading the dll: $e');
            return false;
        }

        // get references to c functions
        try {
            newmydsp = 
                dylib.lookupFunction<NewMyDsp,NewMyDsp>('newmydsp');
            initmydsp = 
                dylib.lookupFunction<InitMyDspNative,InitMyDsp>('initmydsp');
            buildUserInterfacemydsp = 
                dylib.lookupFunction<BuildUserInterfaceMyDsp,BuildUserInterfaceMyDsp>('buildUserInterfacemydsp');
            computemydsp = 
                dylib.lookupFunction<ComputeMyDspNative,ComputeMyDsp>('computemydsp');
            deletemydsp = 
                dylib.lookupFunction<DeleteMyDsp,DeleteMyDsp>('deletemydsp');
        } catch(e){
            print('There was an error looking up a C function: $e');
            return false;
        }
        return true;
    }

    bool initializeDsp(){
        mydsp = newmydsp();
        print("mydsp before:");
        print(mydsp);

        initmydsp(mydsp, sampleRate);

        print("mydsp after:");
        print(mydsp);
        
        //buildUserInterfacemydsp();
        return true;
    }

    @override
    Future<StreamAudioResponse> request([int? start, int? end]) async {
        computemydsp(mydsp,bufferSize,[[]],_buffer);
        return StreamAudioResponse(
            sourceLength: bufferSize,
            contentLength: bufferSize,
            offset: 0,
            stream: Stream.value(_buffer.sublist(0, bufferSize)),
            contentType: 'audio/wav',
        );
    }
}