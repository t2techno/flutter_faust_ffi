/* ------------------------------------------------------------
name: "FaustFlutterC"
Code generated with Faust 2.58.13 (https://faust.grame.fr)
Compilation options: -lang c -ct 1 -es 1 -mcd 16 -single -ftz 0
------------------------------------------------------------ */

#include "./FaustFlutterC.h"
static float mydsp_faustpower2_f(float value) {
	return value * value;
}

mydsp* newmydsp() { 
	mydsp* dsp = (mydsp*)calloc(1, sizeof(mydsp));
	return dsp;
}

void deletemydsp(mydsp* dsp) { 
	free(dsp);
}

void metadatamydsp(MetaGlue* m) { 
	m->declare(m->metaInterface, "compile_options", "-lang c -ct 1 -es 1 -mcd 16 -single -ftz 0");
	m->declare(m->metaInterface, "filename", "FaustFlutterC.dsp");
	m->declare(m->metaInterface, "maths.lib/author", "GRAME");
	m->declare(m->metaInterface, "maths.lib/copyright", "GRAME");
	m->declare(m->metaInterface, "maths.lib/license", "LGPL with exception");
	m->declare(m->metaInterface, "maths.lib/name", "Faust Math Library");
	m->declare(m->metaInterface, "maths.lib/version", "2.5");
	m->declare(m->metaInterface, "name", "FaustFlutterC");
	m->declare(m->metaInterface, "oscillators.lib/lf_sawpos:author", "Bart Brouns, revised by Stéphane Letz");
	m->declare(m->metaInterface, "oscillators.lib/lf_sawpos:licence", "STK-4.3");
	m->declare(m->metaInterface, "oscillators.lib/name", "Faust Oscillator Library");
	m->declare(m->metaInterface, "oscillators.lib/saw2ptr:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "oscillators.lib/saw2ptr:license", "STK-4.3");
	m->declare(m->metaInterface, "oscillators.lib/sawN:author", "Julius O. Smith III");
	m->declare(m->metaInterface, "oscillators.lib/sawN:license", "STK-4.3");
	m->declare(m->metaInterface, "oscillators.lib/version", "0.4");
	m->declare(m->metaInterface, "platform.lib/name", "Generic Platform Library");
	m->declare(m->metaInterface, "platform.lib/version", "0.3");
}

int getSampleRatemydsp(mydsp* RESTRICT dsp) {
	return dsp->fSampleRate;
}

int getNumInputsmydsp(mydsp* RESTRICT dsp) {
	return 0;
}
int getNumOutputsmydsp(mydsp* RESTRICT dsp) {
	return 2;
}

void classInitmydsp(int sample_rate) {
}

void instanceResetUserInterfacemydsp(mydsp* dsp) {
}

void instanceClearmydsp(mydsp* dsp) {
	/* C99 loop */
	{
		int l0;
		for (l0 = 0; l0 < 2; l0 = l0 + 1) {
			dsp->iVec0[l0] = 0;
		}
	}
	/* C99 loop */
	{
		int l1;
		for (l1 = 0; l1 < 2; l1 = l1 + 1) {
			dsp->fRec0[l1] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l2;
		for (l2 = 0; l2 < 2; l2 = l2 + 1) {
			dsp->fVec1[l2] = 0.0f;
		}
	}
	dsp->IOTA0 = 0;
	/* C99 loop */
	{
		int l3;
		for (l3 = 0; l3 < 512; l3 = l3 + 1) {
			dsp->fVec2[l3] = 0.0f;
		}
	}
	/* C99 loop */
	{
		int l4;
		for (l4 = 0; l4 < 2; l4 = l4 + 1) {
			dsp->fRec1[l4] = 0.0f;
		}
	}
}

void instanceConstantsmydsp(mydsp* dsp, int sample_rate) {
	dsp->fSampleRate = sample_rate;
	float fConst0 = fminf(1.92e+05f, fmaxf(1.0f, (float)(dsp->fSampleRate)));
	dsp->fConst1 = 2.2e+02f / fConst0;
	float fConst2 = 0.0022727272f * fConst0;
	float fConst3 = fmaxf(0.0f, fminf(2047.0f, fConst2));
	dsp->iConst4 = (int)(fConst3);
	dsp->iConst5 = dsp->iConst4 + 1;
	float fConst6 = floorf(fConst3);
	dsp->fConst7 = fConst3 - fConst6;
	dsp->fConst8 = fConst6 + (1.0f - fConst3);
	dsp->fConst9 = 0.00085227273f * fConst0;
	dsp->fConst10 = 4.4e+02f / fConst0;
	dsp->fConst11 = 1.0f - fConst2;
}

void instanceInitmydsp(mydsp* dsp, int sample_rate) {
	instanceConstantsmydsp(dsp, sample_rate);
	instanceResetUserInterfacemydsp(dsp);
	instanceClearmydsp(dsp);
}

void initmydsp(mydsp* dsp, int sample_rate) {
	classInitmydsp(sample_rate);
	instanceInitmydsp(dsp, sample_rate);
}

void buildUserInterfacemydsp(mydsp* dsp, UIGlue* ui_interface) {
	ui_interface->openVerticalBox(ui_interface->uiInterface, "FaustFlutterC");
	ui_interface->closeBox(ui_interface->uiInterface);
}

void computemydsp(mydsp* dsp, int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
	FAUSTFLOAT* output0 = outputs[0];
	FAUSTFLOAT* output1 = outputs[1];
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; i0 < count; i0 = i0 + 1) {
			dsp->iVec0[0] = 1;
			float fTemp0 = ((1 - dsp->iVec0[1]) ? 0.0f : dsp->fConst1 + dsp->fRec0[1]);
			dsp->fRec0[0] = fTemp0 - floorf(fTemp0);
			float fTemp1 = mydsp_faustpower2_f(2.0f * dsp->fRec0[0] + -1.0f);
			dsp->fVec1[0] = fTemp1;
			float fTemp2 = (float)(dsp->iVec0[1]) * (fTemp1 - dsp->fVec1[1]);
			dsp->fVec2[dsp->IOTA0 & 511] = fTemp2;
			float fTemp3 = dsp->fConst10 + dsp->fRec1[1] + -1.0f;
			int iTemp4 = fTemp3 < 0.0f;
			float fTemp5 = dsp->fConst10 + dsp->fRec1[1];
			dsp->fRec1[0] = ((iTemp4) ? fTemp5 : fTemp3);
			float fRec2 = ((iTemp4) ? fTemp5 : dsp->fConst10 + dsp->fRec1[1] + dsp->fConst11 * fTemp3);
			float fTemp6 = 0.5f * (0.25f * (2.0f * fRec2 + -1.0f) + dsp->fConst9 * (fTemp2 - dsp->fConst8 * dsp->fVec2[(dsp->IOTA0 - dsp->iConst4) & 511] - dsp->fConst7 * dsp->fVec2[(dsp->IOTA0 - dsp->iConst5) & 511]));
			output0[i0] = (FAUSTFLOAT)(fTemp6);
			output1[i0] = (FAUSTFLOAT)(fTemp6);
			dsp->iVec0[1] = dsp->iVec0[0];
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fVec1[1] = dsp->fVec1[0];
			dsp->IOTA0 = dsp->IOTA0 + 1;
			dsp->fRec1[1] = dsp->fRec1[0];
		}
	}
}