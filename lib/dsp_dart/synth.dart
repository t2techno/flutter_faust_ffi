import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';
import 'dart:io' show Directory;
import 'dart:async';

import 'package:path/path.dart' as path;

import './api_types.dart';
import './generated_bindings.dart';

class Synth {
    static var isPlaying = false;

    // Objects from Faust Code
    static late final Pointer<MyDsp> mydsp;

    // Constants
    static late final int _bufferSize;
    static late final int _sampleRate;
    static late final Duration tick;

    // only need the first two channels
    static late final Pointer<Pointer<Float>> _inputBuffer;
    static late final Pointer<Pointer<Float>> _buffer;

    // generated binding object interfacing c code
    static late final _impl;
    static final libraryPath = path.join(
        Directory.current.path, 'assets', 'faust_c.dll');

    Synth(int bufferSize, int sampleRate){
        _sampleRate  = sampleRate;
        _bufferSize  = bufferSize;
        tick = Duration(microseconds:1000000~/_sampleRate);
        
        allocateBuffers();

        _impl = Faust(DynamicLibrary.open(libraryPath));
        initializeDsp();
    }

    void allocateBuffers(){
        var inL  = calloc<Float>(_bufferSize);
        var inR  = calloc<Float>(_bufferSize);
        var outL = calloc<Float>(_bufferSize);
        var outR = calloc<Float>(_bufferSize);

        _inputBuffer = calloc<Pointer<Float>>(2);
        _inputBuffer.value = Pointer.fromAddress(inL.address);
        _inputBuffer.elementAt(1).value = Pointer.fromAddress(inR.address);

        _buffer = calloc<Pointer<Float>>(2);
        _buffer.value = Pointer.fromAddress(outL.address);
        _buffer.elementAt(1).value = Pointer.fromAddress(outR.address);
    }

    void initializeDsp(){
        mydsp = _impl.newmydsp();
        if(mydsp != nullptr){
            print('dsp created');
            _impl.initmydsp(mydsp, _sampleRate);
        }
        // currently not using an interface with faust
        //_impl.buildUserInterfacemydsp();
    }

    void compute(){
        _impl.computemydsp(mydsp, _bufferSize, _inputBuffer, _buffer);
    }

    Float32List get leftChannel  => _buffer[0].asTypedList(_bufferSize);
    Float32List get rightChannel => _buffer[1].asTypedList(_bufferSize);

    // ToDo: Is it more efficient to yield pointers and defer
    //       casting/splitting channel to listener?
    Stream<List<Float32List>> play() async* {
        isPlaying=true;
        while(isPlaying){
            compute();
            yield [leftChannel, rightChannel];
            await Future.delayed(tick);
        }
    }

    void stopPlaying(){
        isPlaying = false;
    }
}