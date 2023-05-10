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
    static const _numChannels = 2;
    late int _sampleRate;

    //byteRate = SampleRate * NumChannels * BitsPerSample/8
    late int _byteRate;

    //blockAlign = NumChannels * BitsPerSample/8
    final _blockAlign = (_numChannels * _bitsPerSample)~/8;
    static const _bitsPerSample = 16;

    // ExtraParamSize doesn't exist if PCM audio 
    // have to include for non-PCM, even if it's 0 
    final _cbSize = 0;
    
    static const _strData = 'data';

    // _subchunk2Size =  NumSamples * NumChannels * BitsPerSample/8
    late int _subchunk2Size;

    void buildHeader({int sampleRate = 44100, int dataSize = 512, isPcm = true}){
        header.clear();
        if(isPcm){
            _format = 1;
            _subChunk1Size = 16;
            _wavHeaderSize = 44;
        } else {
            _format = 3;
            _subChunk1Size = 18;
            _wavHeaderSize = 46;
        }
        _sampleRate = sampleRate;
        _dataSize   = dataSize;
        _byteRate   = (_sampleRate*_numChannels*_bitsPerSample)~/8;
        _subchunk2Size = (_dataSize * _numChannels * _bitsPerSample)~/8;
        _chunkSize     = 36 + _subchunk2Size;
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

    Uint8List twoBytes(int  v) => Uint8List(2)..buffer.asByteData().setInt16(0,v,Endian.little);
    
    Uint8List fourBytes(int v) => Uint8List(4)..buffer.asByteData().setInt32(0,v,Endian.little);

    Future<int> createWaveFile(Uint8List audioData) async {
        buildHeader();
        header.add(audioData);
        File audioFile = await writeFile("test16Bit_PCM.wav", header.toBytes());
        return audioFile.length();
    }

    Future<File> writeFile(String name, Uint8List data) async {
        final file = File('${Directory.current.path}/audioOut/$name');
        print('writing ${Directory.current.path}/audioOut/$name');

        // Write the file
        return file.writeAsBytes(data);
    }

}