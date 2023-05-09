
// http://soundfile.sapp.org/doc/WaveFormat/

class WaveFile {
    // ToDo: Find best way to use global variables like samplerate/buffersize
    static const sampleRate = 44100;
    static const bufferSize  = 512;

    static const wavHeaderSize = 44;

    // 0x52494646 big-endian form
    static const _strRiff = 'RIFF';

    // Total file size in bytes (minues the 8 bytes of this and the previous field)
    static const _chunkSize = wavHeaderSize + bufferSize - 8;

    // 0x57415645 big-endian form
    static const _strWave = 'WAVE';


    static const _strFmt = 'fmt ';
    static const _formatSize = 16;
    static const _format = 1;
    static const _numChannels = 2;
    static const _factSize = 4;
    static const _fileSizeWithoutData = 36;
    static const _floatFmtExtraSize = 12;
    static const _fPCM = 1;
    static const _float = 3;
    
    
    static const _strData = 'data';
    static const _strFact = 'fact';

    // just_audio requires a stream of ints
    static const _bitsPerSample = 32;

    static ByteData getHeader(){
        ByteData header = ByteData(44);

        // RIFF Header
        ///////////////////////
        //offset    size  Name
        //0         4   ChunkID
        header.setInt32(0,_strRiff);
        
        //4         4   ChunkSize
        header.setInt32(4,_chunkSize);

        //8         4   Format
        header.setInt32(8,_strWave);

        // fmt subchunk
        ///////////////////////
        


        

    }

}