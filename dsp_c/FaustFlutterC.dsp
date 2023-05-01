declare filename "FaustFlutterC.dsp";
declare name "FaustFlutterC";
import("stdfaust.lib");
process = os.sawtooth(440)*.25 + os.square(220)*0.75 : _*0.5 <: _,_;