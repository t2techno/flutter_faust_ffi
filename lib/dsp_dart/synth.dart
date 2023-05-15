import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:just_audio/just_audio.dart';
import 'dart:io';

import './api_types.dart';
import './generated_bindings.dart';
import './wave_file.dart';

class Synth extends StreamAudioSource{
    // Object from Faust Code
    static late final Pointer<MyDsp> _mydsp;

    // generated binding object interfacing c code
    static late final _impl;

    //code to import
    static const faustFile = 'faust_c';

    // convert 32bit float/int to signed 16 for PCM
    static const signedInt16Max = (1 << 15)-1;

    // Constants
    late int _bufferSize;
    late int _sampleRate;
    late int _batchPerSec;
    late int _bitRate;
    late int _numChannels;
    late int _headerSize;
    late bool _isPcm;
    late int _batchByteSize;
    int _currentBatchSize = -1;
    
    // sampleRate/bufferSize times per second
    late Duration _tick;

    late final Pointer<Float> _inL;
    late final Pointer<Float> _inR;
    late final Pointer<Pointer<Float>> _inputBuffer;

    late final Pointer<Float> _outL;
    late final Pointer<Float> _outR;
    late final Pointer<Pointer<Float>> _buffer;

    // for interleaving
    final _bb = BytesBuilder();

    // Wave file header and file writing
    final _waveFile = WaveFile();
    final _recorder = BytesBuilder();
    late final Stream<Uint8List> _synthStream;
    late final StreamSubscription<Uint8List> _streamSub;

    Synth(int sampleRate, int bufferSize, int bitRate, int numChannels, bool isPcm) {
        _sampleRate = sampleRate;
        _bufferSize = bufferSize;
        _bitRate = bitRate;
        _numChannels = numChannels;
        _isPcm = isPcm;
        _batchPerSec = sampleRate~/bufferSize;
        _tick = Duration(microseconds:(1000000*bufferSize)~/_sampleRate);
        _headerSize = isPcm ? 44 : 46;
        
        final dataByteSize = (_bufferSize*_numChannels*(_bitRate~/8));
        _batchByteSize = _headerSize + dataByteSize;
        print('building header...');
        _waveFile.buildHeader(sampleRate, dataByteSize, bitRate, numChannels, true);
        print('header built');
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
        initializeStream();
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

    void initializeStream(){
        _synthStream = Stream<Uint8List>.periodic(_tick, 
            (count) => _waveFile.headerWithData(compute())
        ).asBroadcastStream();

        // pause the stream until we need it
        _streamSub = _synthStream.listen((data)=>{data})..pause();
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

    Uint8List compute() {
        _impl.computemydsp(_mydsp, _bufferSize, _inputBuffer, _buffer);
        return _isPcm ? interleavedIntBytes : interleavedFloatBytes;
    }

    void pause(){
        _streamSub.pause();
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

    void dispose(){
        _streamSub.cancel();

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

    // test methods while getting the file structure correct
    Future<void> writeSynthAudio(String fileName) async {
        print('writing file....${_recorder.length}');
        var fileSize = await _waveFile.createWaveFile(fileName, _recorder.takeBytes(), 
                                                      _sampleRate, _bitRate, _numChannels,  true);
        print('file writing complete! Wrote ${fileSize/1000} KB');
    }

    void recordNSeconds(int n) async {
        print('recording $n seconds');
        for(int i=0;i<n; i++){
            for(int j=0; j< _batchPerSec; j++){
                compute();
                _recorder.add(interleavedIntBytes);
            }
            print('${i+1}.');
        }
        await writeSynthAudio("test_wave.wav");
    }

    ////////////////////
    // StreamAudioSource
    ////////////////////

    @override
    Future<StreamAudioResponse> request([int? start, int? end]) async {
        print('request');
        _streamSub.resume();

        start ??= 0;
        end ??= _batchByteSize;
        print('end: $end');
        return StreamAudioResponse(
            sourceLength: 10000000,
            contentLength: end - start,
            offset: start,
            stream: _synthStream,
            contentType: 'audio/wave',
        );
    }
}