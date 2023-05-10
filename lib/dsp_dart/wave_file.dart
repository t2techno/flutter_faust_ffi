import 'dart:typed_data';
import 'dart:convert';

// http://soundfile.sapp.org/doc/WaveFormat/

class WaveFileHeader{

    // Can open this up for my customization later
    WaveFileHeader();


    static BytesBuilder header = BytesBuilder();
    static final utf8Encoder = utf8.encoder;

    // ToDo: Find best way to use global variables like samplerate/buffersize
    static late final int _bufferSize;

    // 44 for PCM
    static const _wavHeaderSize = 46;

    // 0x52494646 big-endian form
    static const _strRiff = 'RIFF';

    // Total file size in bytes (minues the 8 bytes of this and the previous field)
    static late final int _chunkSize;

    // Size of the fmt section. Doing 32-bit float, 
    // have to populate an extra 2 bytes for cbSize field extension
    static const _subChunk1Size = 18;

    // 0x57415645 big-endian form
    static const _strWave = 'WAVE';

    // 0x666d7420 big-endian form
    static const _strFmt = 'fmt ';

    //0x0003	WAVE_FORMAT_IEEE_FLOAT	IEEE float
    static const _format = 3;
    static const _numChannels = 2;
    static late final int _sampleRate;

    //byteRate = SampleRate * NumChannels * BitsPerSample/8
    static late final int _byteRate;

    //blockAlign = NumChannels * BitsPerSample/8
    static const _blockAlign = (_numChannels * _bitsPerSample)~/8;
    static const _bitsPerSample = 32;

    // ExtraParamSize doesn't exist if PCM audio 
    // have to include for non-PCM, even if it's 0 
    static const _cbSize = 0;
    
    static const _strData = 'data';

    // _subchunk2Size =  NumSamples * NumChannels * BitsPerSample/8
    static late final int _subchunk2Size;

    void buildHeader([int sr = 44100, int bfr = 512]){
        _sampleRate = sr;
        _bufferSize = bfr;
        _byteRate = (_sampleRate*_numChannels*_bitsPerSample)~/8;
        _chunkSize = _wavHeaderSize + _bufferSize - 8;
        _subchunk2Size = (_bufferSize * _numChannels * _bitsPerSample)~/8;
        buildRiffHeader();
        buildFmtChunk();
        buildDataChunk();
    }

    Uint8List getHeader(){
        if(header.isNotEmpty){
            return header.toBytes();
        }
        buildHeader();
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
        bytePerLetter(_strWave);
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
              ..add(twoBytes(_byteRate))
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

    // 1 byte per letter
    //...might need to do something to ensure proper endian
    void str2bytes(String s) => header.add(utf8Encoder.convert(s));

    Uint8List twoBytes(int  v) => Uint8List(2)..buffer.asInt16List()[0] = v;
    
    Uint8List fourBytes(int v) => Uint8List(4)..buffer.asInt32List()[0] = v;
}