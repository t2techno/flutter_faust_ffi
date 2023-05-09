import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';
import 'dart:io' show Directory;
import 'dart:async';

import 'package:path/path.dart' as path;
import 'dart:io';

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

    static late final Pointer<Float> _inL;
    static late final Pointer<Float> _inR;
    static late final Pointer<Pointer<Float>> _inputBuffer;

    static late final Pointer<Float> _outL;
    static late final Pointer<Float> _outR;
    static late final Pointer<Pointer<Float>> _buffer;

    // generated binding object interfacing c code
    static late final _impl;
    static const faustFile = 'faust_c';

    Synth(int bufferSize, int sampleRate) {
        _sampleRate  = sampleRate;
        _bufferSize  = bufferSize;
        tick = Duration(microseconds:1000000~/_sampleRate);
    }

    void initSynth() {
        print('allocating buffers');
        allocateBuffers();
        print('opening c library');

        DynamicLibrary _dylib;
        if (Platform.isAndroid || Platform.isLinux) {
            print('opening on Android or Linux');
            _dylib = DynamicLibrary.open('lib$faustFile.so');
        }
        else if (Platform.isWindows) {
            print('opening on Windows');
            _dylib = DynamicLibrary.open(Directory.current.path + '/assets/$faustFile.dll');
        } else {
            print("Sorry, I don't own a Mac :(");
            return;
        }
        _impl = Faust(_dylib);
        initializeDsp();
    }

    void initializeDsp() {
        mydsp = _impl.newmydsp();
        if(mydsp != nullptr){
            print('dsp created');
            _impl.initmydsp(mydsp, _sampleRate);
            print('dsp init-ed');
        }
        // currently not using an interface with faust
        //_impl.buildUserInterfacemydsp();
    }

    void allocateBuffers(){
        print("_inputBuffer");
        _inL  = calloc<Float>(_bufferSize);
        _inR  = calloc<Float>(_bufferSize);

        _inputBuffer = calloc<Pointer<Float>>(2);
        _inputBuffer.value = Pointer.fromAddress(_inL.address);
        _inputBuffer.elementAt(1).value = Pointer.fromAddress(_inL.address);
        print("made");

        print("_outputBuffer");
        _outL = calloc<Float>(_bufferSize);
        _outR = calloc<Float>(_bufferSize);

        _buffer = calloc<Pointer<Float>>(2);
        _buffer.value = Pointer.fromAddress(_outL.address);
        _buffer.elementAt(1).value = Pointer.fromAddress(_outR.address);
        print("made");
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
        //while(isPlaying){
            compute();
            yield [leftChannel, rightChannel];
            await Future.delayed(tick);
        //}
    }

    void stopPlaying(){
        isPlaying = false;
    }

    void dispose(){
        // free pointers allocated in dart
        calloc.free(_inL);
        calloc.free(_inR);
        calloc.free(_inputBuffer);

        calloc.free(_outL);
        calloc.free(_outR);
        calloc.free(_buffer);

        // free c pointer
        _impl.deletemydsp();
    }
}