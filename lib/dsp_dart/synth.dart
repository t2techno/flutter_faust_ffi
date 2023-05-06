import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

import './api_types.dart';

class Synth {
    static final libraryPath = path.join(
        Directory.current.path, 'assets', 'faust_c.dll');

    // imported Faust code
    static late final DynamicLibrary dylib;

    // Methods from Faust Code
    static late final NewMyDsp newmydsp;
    static late final InitMyDsp initmydsp;
    static late final BuildUserInterfaceMyDsp buildUserInterfacemydsp;
    static late final ComputeMyDsp computemydsp;
    static late final DeleteMyDsp deletemydsp;

    // Objects from Faust Code
    static late final Pointer<MyDsp> mydsp;
    static late final Pointer<UiGlue> uiInterface;

    // Constants
    static late final int _bufferSize;
    static late final int _sampleRate;

    // only need the first two channels
    //static late final List<Float32List> _inputBuffer;
    //static late final List<Float32List> _buffer;
    static late final Pointer<Pointer<Float>> _inputBuffer;
    static late final Pointer<Pointer<Float>> _buffer;

    Synth(int bufferSize, int sampleRate){
        _sampleRate  = sampleRate;
        _bufferSize  = bufferSize;

        _inputBuffer = calloc<Pointer<Float>>(2);
        _buffer      = calloc<Pointer<Float>>(2);
    }

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

        initmydsp(mydsp, _sampleRate);

        print("mydsp after:");
        print(mydsp);
        
        //buildUserInterfacemydsp();
        return true;
    }

    // https://dart.dev/articles/libraries/creating-streams
    void compute(){
        computemydsp(mydsp,_bufferSize,_inputBuffer,_buffer);
    }

    Float32List get leftChannel {
        return Float32List(_buffer.elementAt(0));
    }

    Float32List get rightChannel {
        return Float32List(_buffer.elementAt(1));
    }
}