import 'dart:ffi';
import 'dart:io' show Directory, Platform;

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

import '/api_types.dart';

class DspApi {
    static const libraryPath = path.join(
        Directory.current.path, 'faust_c.dll');

    
    /*
    final dylib = DynamicLibrary.open(libraryPath);

    final newmydsp = 
        dylib.lookupFunction<NewMyDsp,NewMyDsp>('newmydsp');

    final initmydsp = 
        dylib.lookupFunction<InitMyDspNative,InitMyDsp>('initmydsp');

    final buildUserInterfaceMyDsp = 
        dylib.lookupFunction<BuildUserInterfaceMyDsp,BuildUserInterfaceMyDsp>('buildUserInterfacemydsp');

    final computemydsp = 
        dylib.lookupFunction<ComputeMyDspNative,ComputeMyDsp>('computemydsp');

    final deletemydsp = 
        dylib.lookupFunction<DeleteMyDsp,DeleteMyDsp>('deletemydsp')
     */
}