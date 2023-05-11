# flutter_faust_ffi

A basic flutter app to prove as a proof of concept utilizing Faust's C api export with Dart's ffi methods to create cross-platform plug-ins.</br></br>
While I thought the big challenge would be binding the C code, it turns out my bigger challenge has been creating a realtime playable stream of raw audio data out of the data that my C code generates.

The first step was preparing the Faust exported C file to be further exported as a dll.
In /dsp_c:
<ol>
  <li>cmake .</li>
  <li>cmake --build .</li>
  <li>You'll find the generated dll file in dsp_c/Debug/</li>
</ol>

The next step was creating the C-Native and Dart typedefs for dsp, gui, and metadata class objects and methods being used from the c code, found in lib/dsp_dart/api_types.dart.</br>
  * I ended up using ffigen output for the final interface between Faust and Dart

<ol>
  <li>Main.dart: simply contains a basic play/pause button with textual feedback letting you know if it's supposed to be playing</li>
  <li>dsp_dart<ul>
    <li>api_types.dart: my hand written typedefs for interfacing with Faust code, leaving for now as it's easy to read.</li>
    <li>generated_bindings.dart: The ffigen output file from running against /dsp_c/FaustFlutterC.h</li>
    <li>my_audio_player.dart:<ul> 
      <li>Contains an AudioStreamSource, an AudioPlayer, and the synth object</li>
      <li>Defines and passes most constants like sample rate and buffer size</li>
      <ul>
        <li>Sampling Rate = 48000</li>
        <li>Buffer Size   = 125</li>
      </ul>
      <li>main.dart interacts with this object</li>
    </ul></li>
    <li>synth.dart: Class that holds all actual dsp related code<ul>
      <li>Constructor takes bufferSize and Sample rate</li>
      <li>synth.play()<ul>
        <li>Sets isPlaying to true and runs while loop _sampleRate/bufferRate times per second</li>
        <li>runs compute to fill output buffers with audio data</li>
        <li>yields a List<Float32List> of size two for the left and right channels</li>
        <li>isPlaying is toggled back to false from the play/pause state change in audio_player</li>
        <li>In order to use a custom audio source, just_audio creates a local http media server</li>
        <li>Have methods to stream audio data as float32 bit or 16bit PCM Wave</li>
        <li>Currently saves the played audio data as a wav file that doesn't work yet</li>
        <ul><li>File not playing is probably related to why the audio data won't stream...</li></ul>
      </ul></li>
    </ul></li>
    <li>wave_file.dart:<ul>
      <li>Generates a Wav header for either 32bit float or 16bit PCM</li>
      <li>Can pass in audio data and create a wave file in audioOut/ directory</li>
      <li>In the header, the string constants are BigEndian while the numeric constants are LittleEndian</li>
      <li>The whole data chunk uses the System's default endian-ness, BigEndian on my Windows</li>
    </ul></li>
  </ul></li>
</ol>
