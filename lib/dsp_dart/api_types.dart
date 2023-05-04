import 'dart:ffi';

import 'package:ffi/ffi.dart';

// ignore_for_file: non_constant_identifier_names

/* DSP Stuff

typedef struct {
	int iVec0[2];
	int fSampleRate;
	float fConst1;
	float fRec0[2];
	float fVec1[2];
	int IOTA0;
	float fVec2[512];
	int iConst4;
	int iConst5;
	float fConst7;
	float fConst8;
	float fConst9;
	float fConst10;
	float fRec1[2];
	float fConst11;
} mydsp;
*/
class MyDsp extends Struct {
  external Array<Int32> iVec0(2); //int iVec0[2];

  @Int32()
  external int fSampleRate; //int fSampleRate;

  @Float()
  external double fConst1; //float fConst1;

  external Pointer<Float> fRec0; //float fRec0[2];

  external Pointer<Float> fVec1; //float fVec1[2];

  @Int32()
  external int IOTA0; //int IOTA0;
  
  external Pointer<Float>fVec2; //float fVec2[512];
  
  @Int32()
  external int iConst4;// int iConst4;

  @Int32()
  external int iConst5;	// int iConst5;

  @Float()
  external double fConst7; // float fConst7;

  @Float()
  external double fConst8;  // float fConst8;

  @Float()
  external double fConst9; // float fConst9;

  @Float()
  external double fConst10; // float fConst10;

  external Pointer<Float> fRec1fRec1; // float fRec1[2];

  @Float()
  external double fConst11;// float fConst11;
}

// mydsp* newmydsp()
typedef NewMyDsp = Pointer<MyDsp> Function();

// 	void initmydsp(mydsp* dsp, int sample_rate)
typedef InitMyDspNative = Pointer<Void> Function(Pointer<MyDsp> dsp, Int32 sample_rate);
typedef InitMyDsp = Pointer<Void> Function(Pointer<MyDsp> dsp, int sample_rate);

// void buildUserInterfacemydsp(mydsp* dsp, UIGlue* ui_interface)
typedef BuildUserInterfaceMyDsp = Pointer<Void> Function(Pointer<MyDsp> dsp, Pointer<UiGlue> ui_interface);

// 	void computemydsp(mydsp* dsp, int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs);
typedef AudioIOArrayNative = Pointer<Pointer<Float>>;
typedef AudioIOArray = Pointer<Pointer<Float>>;
typedef ComputeMyDspNative = Pointer<Void> Function(Pointer<MyDsp> dsp, Int32 count, AudioIOArrayNative inputs, AudioIOArrayNative outputs);
typedef ComputeMyDsp = Pointer<Void> Function(Pointer<MyDsp> dsp, int count, AudioIOArray inputs, AudioIOArray outputs);

// 	void deletemydsp(mydsp* dsp)
typedef DeleteMyDsp = Pointer<Void> Function(Pointer<MyDsp> dsp);


/* UI and Meta data stuff */

//typedef void (* openVerticalBoxFun) (void* ui_interface, const char* label);
typedef OpenVerticalBoxFun = Pointer<void> Function(Pointer<void> ui_interface, Pointer<Utf8> label);

//typedef void (* closeBoxFun) (void* ui_interface);
typedef CloseBoxFun = Pointer<void> Function(Pointer<void> ui_interface);

class UiGlue extends Struct {
    external static Pointer<UiGlue> uiInterface;
}

//typedef void (* metaDeclareFun) (void* ui_interface, const char* key, const char* value);
typedef MetaDeclareFun = Pointer<void> Function(Pointer<void> ui_interface, Pointer<Utf8> key, Pointer<Utf8> value);
class MetaGlue extends Struct {
    external static Pointer<MetaGlue> metaInterface;
}