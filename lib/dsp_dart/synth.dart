import 'dart:ffi';
import 'dart:io' show Directory;

import 'package:path/path.dart' as path;

import './api_types.dart';

class Synth {
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
    static const _sampleRate;
    static const _bufferSize;
    static final List<List<double>> _buffer;

    Synth(int sampleRate, int bufferSize){
        _sampleRate = sampleRate;
        _bufferSize = bufferSize;
        _buffer = List.filled(2,List.filled(_bufferSize, 0.0));
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

        initmydsp(mydsp, sampleRate);

        print("mydsp after:");
        print(mydsp);
        
        //buildUserInterfacemydsp();
        return true;
    }

    void compute(){
        computemydsp(mydsp,_bufferSize,Array<Array<double>>(),_buffer);
    }

    get Array<double> leftChannel {
        return _buffer[0];
    }

    get Array<double> rightChannel {
        return _buffer[1];
    }
}