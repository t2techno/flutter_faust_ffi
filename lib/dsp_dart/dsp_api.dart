import 'dart:ffi';
import 'dart:io' show Directory, Platform;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import './api_types.dart';

class DspApi {
    static final libraryPath = path.join(
        Directory.current.path, 'faust_c.dll');

    static late final DynamicLibrary dylib;
    static late final NewMyDsp newmydsp;
    static late final InitMyDsp initmydsp;
    static late final BuildUserInterfaceMyDsp buildUserInterfacemydsp;
    static late final ComputeMyDsp computemydsp;
    static late final DeleteMyDsp deletemydsp;
    static late final Pointer<MyDsp> mydsp;
    static final int sample_rate = 44100;

    static bool init(){
        if(loadDll()){
            return initializeDsp();
        }
        return false;
    }

    static bool loadDll(){
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

    static bool initializeDsp(){
        mydsp = newmydsp();
        initmydsp(mydsp, sample_rate);
        //buildUserInterfacemydsp();
        return true;
    }

}