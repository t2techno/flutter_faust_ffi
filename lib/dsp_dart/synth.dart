import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:path/path.dart' as path;
import 'dart:io';

import './api_types.dart';
import './generated_bindings.dart';
import './wave_file.dart';

class Synth {
    static var _isPlaying = false;

    // Objects from Faust Code
    static late final Pointer<MyDsp> _mydsp;

    // Constants
    static late final int _bufferSize;
    static late final int _sampleRate;
    static late final Duration _tick;

    static late final Pointer<Float> _inL;
    static late final Pointer<Float> _inR;
    static late final Pointer<Pointer<Float>> _inputBuffer;

    static late final Pointer<Float> _outL;
    static late final Pointer<Float> _outR;
    static late final Pointer<Pointer<Float>> _buffer;
    static final BytesBuilder _bb = BytesBuilder();
    static final WaveFile _waveFile = new WaveFile();
    static final BytesBuilder _recorder = BytesBuilder();

    // generated binding object interfacing c code
    static late final _impl;
    static const faustFile = 'faust_c';
    static const signedInt16Max = (1 << 15)-1;

    Synth(int sampleRate, int bufferSize ) {
        _sampleRate  = sampleRate;
        _bufferSize  = bufferSize;
        _tick = Duration(microseconds:1000000~/_sampleRate);
        _waveFile.buildHeader(sampleRate: sampleRate, dataSize: bufferSize);
    }

    void initSynth() {
        print('allocating buffers');
        allocateBuffers();
        print('opening c library');

        DynamicLibrary dylib;
        if (Platform.isAndroid || Platform.isLinux) {
            print('...Android or Linux');
            dylib = DynamicLibrary.open('lib$faustFile.so');
        }
        else if (Platform.isWindows) {
            print('...on Windows');
            dylib = DynamicLibrary.open('${Directory.current.path}/assets/$faustFile.dll');
        } else {
            print("Sorry, I don't own a Mac :(");
            return;
        }
        _impl = Faust(dylib);
        initializeDsp();
    }

    void initializeDsp() {
        _mydsp = _impl.newmydsp();
        if(_mydsp != nullptr){
            print('dsp created');
            _impl.initmydsp(_mydsp, _sampleRate);
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

    compute() {
        _impl.computemydsp(_mydsp, _bufferSize, _inputBuffer, _buffer);
    }

    // casting buffers as more convenient type
    Float32List get leftFloats  => _buffer[0].asTypedList(_bufferSize);
    Float32List get rightFloats => _buffer[1].asTypedList(_bufferSize);

    // interleaves the left and right stereo channels for wav format 
    Uint8List get interleavedFloatBytes {
        Float32List left = leftFloats;
        Float32List right = rightFloats;
        for(var i=0; i<_bufferSize; i++){
            _bb..add(float2bytes(left[i]))
               ..add(float2bytes(right[i]));
        }
        return _bb.takeBytes();
    }
    
    // Creates a list of 4 bytes, casts it as a Float32List(size one), assigns my double
    // technically double in dart is 64bit, but they are floats coming from a FloatList32...
    Uint8List float2bytes(double v) => Uint8List(4)..buffer.asFloat32List()[0] = v;

    // interleaves the left and right stereo channels for wav format 
    Uint8List get interleavedIntBytes {
        Float32List left  = leftFloats;
        Float32List right = rightFloats;
        for(var i=0; i<_bufferSize; i++){
            _bb..add(int16bytes((left[i]* signedInt16Max).toInt()))
               ..add(int16bytes((right[i]*signedInt16Max).toInt()));
        }
        return _bb.takeBytes();
    }

    Uint8List int16bytes(int v) => Uint8List(2)..buffer.asInt16List()[0] = v;

    // sound making loop
    // runs _samplingRate times per second,
    Stream<Uint8List> play() async* {
        _isPlaying=true;
        while(_isPlaying){
            compute();
            _recorder.add(interleavedIntBytes);
            print('.');
            //_bb.add(_waveHeader.getHeader());
            //yield interleavedIntBytes;
            await Future.delayed(_tick);
        }
    }

    void stopPlaying(){
        _isPlaying = false;
    }

    Future<void> writeSynthAudio() async {
        print('writing file....');
        var fileSize = await _waveFile.createWaveFile(_recorder.takeBytes());
        print('file writing complete! Wrote ${fileSize/1000} KB');
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
        _impl.deletemydsp(_mydsp);
    }
}