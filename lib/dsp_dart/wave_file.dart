import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

// http://soundfile.sapp.org/doc/WaveFormat/

class WaveFile{

    // Can open this up for my customization later
    WaveFile();

    BytesBuilder header = BytesBuilder();
    final utf8Encoder = utf8.encoder;

    // ToDo: Find best way to use global variables like samplerate/buffersize
    late int _dataSize;

    // 44 for PCM
    late int _wavHeaderSize;

    // 0x52494646 big-endian form
    static const _strRiff = 'RIFF';

    // Total file size in bytes (minues the 8 bytes of this and the previous field)
    late int _chunkSize;

    // Size of the fmt section. Doing 32-bit float, 
    // have to populate an extra 2 bytes for cbSize field extension
    late int _subChunk1Size;

    // 0x57415645 big-endian form
    static const _strWave = 'WAVE';

    // 0x666d7420 big-endian form
    static const _strFmt = 'fmt ';

    //0x0001    PCM
    //0x0003	WAVE_FORMAT_IEEE_FLOAT	IEEE float
    late int _format;
    late int _sampleRate;

    //byteRate = SampleRate * NumChannels * BitsPerSample/8
    late int _byteRate;

    late int _numChannels;
    late int _bitsPerSample;

    //blockAlign = NumChannels * BitsPerSample/8
    late int _blockAlign;

    // ExtraParamSize doesn't exist if PCM audio 
    // have to include for non-PCM, even if it's 0 
    final _cbSize = 0;
    
    static const _strData = 'data';

    // _subchunk2Size =  NumSamples * NumChannels * BitsPerSample/8
    // Note, I'm just passing the raw bytes, so no calc needed
    late int _subchunk2Size;

    void buildHeader(int sampleRate, int numAudioBytes, 
                     int bitsPerSample, int numChannels, bool isPcm){
        header.clear();
        if(isPcm){
            _format        = 1;
            _subChunk1Size = 16;
            _wavHeaderSize = 44;
        } else {
            _format        = 3;
            _subChunk1Size = 18;
            _wavHeaderSize = 46;
        }
        _bitsPerSample = bitsPerSample;
        _numChannels   = numChannels;
        _sampleRate    = sampleRate;
        _byteRate      = (_sampleRate*_numChannels*_bitsPerSample)~/8;
        _blockAlign = (_numChannels * _bitsPerSample)~/8;
        _subchunk2Size = numAudioBytes;
        _chunkSize     = 36 + _subchunk2Size;
        buildRiffHeader();
        buildFmtChunk();
        buildDataChunk();
    }

    Uint8List getHeader(){
        if(header.isNotEmpty){
            return header.toBytes();
        }
        print('building uninitialized header');
        print('using default values: 41000, 512, 16, 2, true');
        buildHeader(41000, 512, 16, 2, true);
        return header.toBytes();
    }

    // RIFF Header
    ///////////////////////
    //offset    size  Name
    //0         4   ChunkID
    //4         4   ChunkSize
    //8         4   Format
    void buildRiffHeader(){
        str2bytes(_strRiff);
        header.add(fourBytes(_chunkSize));
        str2bytes(_strWave);
    }

    // fmt subchunk
    ///////////////////////
    //offset    size  Name
    //12        4   Subchunk1ID
    //16        4   Subchunk1Size
    //20        2   AudioFormat
    //22        2   NumChannels
    //24        4   SampleRate
    //28        4   ByteRate 
    //32        2   BlockAlign
    //34        2   BitsPerSample
    //(36)      2   ExtraParamSize
    void buildFmtChunk(){
        str2bytes(_strFmt);
        header..add(fourBytes(_subChunk1Size))
              ..add(twoBytes(_format))
              ..add(twoBytes(_numChannels))
              ..add(fourBytes(_sampleRate))
              ..add(fourBytes(_byteRate))
              ..add(twoBytes(_blockAlign))
              ..add(twoBytes(_bitsPerSample));
        // not pcm
        if(_format != 1){
            header.add(twoBytes(_cbSize));
        }
    }

    // data subchunk
    ///////////////////////
    //offset    size  Name
    //36(38)    4   Subchunk2ID
    //40(42)    4   Subchunk2Size
    //44(46)    *   Data
    void buildDataChunk(){
        str2bytes(_strData);
        header.add(fourBytes(_subchunk2Size));
    }

    void logItAll(){
        print('__RIFF__');
        print('chunckSize: $_chunkSize - ${fourBytes(_chunkSize)}');
        print('__WAVE__');
        print('__fmt __');
        print('_subChunk1Size: $_subChunk1Size - ${fourBytes(_subChunk1Size)}');
        print('_format: $_format - ${twoBytes(_format)}');
        print('_numChannels: $_numChannels - ${twoBytes(_numChannels)}');
        print('_sampleRate: $_sampleRate - ${fourBytes(_sampleRate)}');
        print('_byteRate: $_byteRate - ${fourBytes(_byteRate)}');
        print('_blockAlign: $_blockAlign - ${twoBytes(_blockAlign)}');
        print('_bitsPerSample: $_bitsPerSample - ${twoBytes(_bitsPerSample)}');
        print('__DATA__');
        print('_subchunk2Size: $_subchunk2Size - ${fourBytes(_subchunk2Size)}');
    }
    // 1 byte per letter
    void str2bytes(String s) => header.add(utf8Encoder.convert(s));

    Uint8List twoBytes(int  v) => Uint8List(2)..buffer.asByteData().setInt16(0,v,Endian.little);
    
    Uint8List fourBytes(int v) => Uint8List(4)..buffer.asByteData().setInt32(0,v,Endian.little);

    // Called externally to create a Wave file out of the passed in data
    Future<int> createWaveFile(String name, Uint8List audioData, int sampleRate, 
                               int bitsPerSample, int numChannels, bool isPcm) async {
        // Wave files require an even number of bytes
        if(audioData.lengthInBytes%2 == 1){audioData.add(0);}
        
        buildHeader(sampleRate, audioData.length, bitsPerSample, numChannels, isPcm);
        logItAll();
        header.add(audioData);
        File audioFile = await writeFile(name, header.toBytes());
        return audioFile.length();
    }

    Future<File> writeFile(String name, Uint8List data) async {
        final file = File('${Directory.current.path}/audioOut/$name');
        print('writing ${Directory.current.path}/audioOut/$name');

        // Write the file
        return file.writeAsBytes(data);
    }

}