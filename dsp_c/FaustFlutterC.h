/* ------------------------------------------------------------
name: "FaustFlutterC"
Code generated with Faust 2.58.13 (https://faust.grame.fr)
Compilation options: -lang c -ct 1 -es 1 -mcd 16 -single -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif 


#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define RESTRICT __restrict
#else
#define RESTRICT __restrict__
#endif

#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#include "./faust/CInterface.h"

static float mydsp_faustpower2_f(float value);

#ifndef FAUSTCLASS 
#define FAUSTCLASS mydsp
#endif

#ifdef __APPLE__ 
#define exp10f __exp10f
#define exp10 __exp10
#endif

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

mydsp* newmydsp();

void deletemydsp(mydsp* dsp);

void metadatamydsp(MetaGlue* m);

int getSampleRatemydsp(mydsp* RESTRICT dsp);

int getNumInputsmydsp(mydsp* RESTRICT dsp);
int getNumOutputsmydsp(mydsp* RESTRICT dsp);

void classInitmydsp(int sample_rate);

void instanceResetUserInterfacemydsp(mydsp* dsp);

void instanceClearmydsp(mydsp* dsp);

void instanceConstantsmydsp(mydsp* dsp, int sample_rate);

void instanceInitmydsp(mydsp* dsp, int sample_rate);

void initmydsp(mydsp* dsp, int sample_rate);

void buildUserInterfacemydsp(mydsp* dsp, UIGlue* ui_interface);

void computemydsp(mydsp* dsp, int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs);

#ifdef __cplusplus
}
#endif

#endif
