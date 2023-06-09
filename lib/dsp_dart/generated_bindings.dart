// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Basic Faust oscillator
class Faust {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  Faust(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  Faust.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  double mydsp_faustpower2_f(
    double value,
  ) {
    return _mydsp_faustpower2_f(
      value,
    );
  }

  late final _mydsp_faustpower2_fPtr =
      _lookup<ffi.NativeFunction<ffi.Float Function(ffi.Float)>>(
          'mydsp_faustpower2_f');
  late final _mydsp_faustpower2_f =
      _mydsp_faustpower2_fPtr.asFunction<double Function(double)>();

  ffi.Pointer<mydsp> newmydsp() {
    return _newmydsp();
  }

  late final _newmydspPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<mydsp> Function()>>('newmydsp');
  late final _newmydsp =
      _newmydspPtr.asFunction<ffi.Pointer<mydsp> Function()>();

  void deletemydsp(
    ffi.Pointer<mydsp> dsp,
  ) {
    return _deletemydsp(
      dsp,
    );
  }

  late final _deletemydspPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<mydsp>)>>(
          'deletemydsp');
  late final _deletemydsp =
      _deletemydspPtr.asFunction<void Function(ffi.Pointer<mydsp>)>();

  void metadatamydsp(
    ffi.Pointer<MetaGlue> m,
  ) {
    return _metadatamydsp(
      m,
    );
  }

  late final _metadatamydspPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<MetaGlue>)>>(
          'metadatamydsp');
  late final _metadatamydsp =
      _metadatamydspPtr.asFunction<void Function(ffi.Pointer<MetaGlue>)>();

  int getSampleRatemydsp(
    ffi.Pointer<mydsp> dsp,
  ) {
    return _getSampleRatemydsp(
      dsp,
    );
  }

  late final _getSampleRatemydspPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<mydsp>)>>(
          'getSampleRatemydsp');
  late final _getSampleRatemydsp =
      _getSampleRatemydspPtr.asFunction<int Function(ffi.Pointer<mydsp>)>();

  int getNumInputsmydsp(
    ffi.Pointer<mydsp> dsp,
  ) {
    return _getNumInputsmydsp(
      dsp,
    );
  }

  late final _getNumInputsmydspPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<mydsp>)>>(
          'getNumInputsmydsp');
  late final _getNumInputsmydsp =
      _getNumInputsmydspPtr.asFunction<int Function(ffi.Pointer<mydsp>)>();

  int getNumOutputsmydsp(
    ffi.Pointer<mydsp> dsp,
  ) {
    return _getNumOutputsmydsp(
      dsp,
    );
  }

  late final _getNumOutputsmydspPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<mydsp>)>>(
          'getNumOutputsmydsp');
  late final _getNumOutputsmydsp =
      _getNumOutputsmydspPtr.asFunction<int Function(ffi.Pointer<mydsp>)>();

  void classInitmydsp(
    int sample_rate,
  ) {
    return _classInitmydsp(
      sample_rate,
    );
  }

  late final _classInitmydspPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>('classInitmydsp');
  late final _classInitmydsp =
      _classInitmydspPtr.asFunction<void Function(int)>();

  void instanceResetUserInterfacemydsp(
    ffi.Pointer<mydsp> dsp,
  ) {
    return _instanceResetUserInterfacemydsp(
      dsp,
    );
  }

  late final _instanceResetUserInterfacemydspPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<mydsp>)>>(
          'instanceResetUserInterfacemydsp');
  late final _instanceResetUserInterfacemydsp =
      _instanceResetUserInterfacemydspPtr
          .asFunction<void Function(ffi.Pointer<mydsp>)>();

  void instanceClearmydsp(
    ffi.Pointer<mydsp> dsp,
  ) {
    return _instanceClearmydsp(
      dsp,
    );
  }

  late final _instanceClearmydspPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<mydsp>)>>(
          'instanceClearmydsp');
  late final _instanceClearmydsp =
      _instanceClearmydspPtr.asFunction<void Function(ffi.Pointer<mydsp>)>();

  void instanceConstantsmydsp(
    ffi.Pointer<mydsp> dsp,
    int sample_rate,
  ) {
    return _instanceConstantsmydsp(
      dsp,
      sample_rate,
    );
  }

  late final _instanceConstantsmydspPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<mydsp>, ffi.Int)>>(
      'instanceConstantsmydsp');
  late final _instanceConstantsmydsp = _instanceConstantsmydspPtr
      .asFunction<void Function(ffi.Pointer<mydsp>, int)>();

  void instanceInitmydsp(
    ffi.Pointer<mydsp> dsp,
    int sample_rate,
  ) {
    return _instanceInitmydsp(
      dsp,
      sample_rate,
    );
  }

  late final _instanceInitmydspPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<mydsp>, ffi.Int)>>(
      'instanceInitmydsp');
  late final _instanceInitmydsp = _instanceInitmydspPtr
      .asFunction<void Function(ffi.Pointer<mydsp>, int)>();

  void initmydsp(
    ffi.Pointer<mydsp> dsp,
    int sample_rate,
  ) {
    return _initmydsp(
      dsp,
      sample_rate,
    );
  }

  late final _initmydspPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<mydsp>, ffi.Int)>>(
      'initmydsp');
  late final _initmydsp =
      _initmydspPtr.asFunction<void Function(ffi.Pointer<mydsp>, int)>();

  void buildUserInterfacemydsp(
    ffi.Pointer<mydsp> dsp,
    ffi.Pointer<UIGlue> ui_interface,
  ) {
    return _buildUserInterfacemydsp(
      dsp,
      ui_interface,
    );
  }

  late final _buildUserInterfacemydspPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<mydsp>,
              ffi.Pointer<UIGlue>)>>('buildUserInterfacemydsp');
  late final _buildUserInterfacemydsp = _buildUserInterfacemydspPtr
      .asFunction<void Function(ffi.Pointer<mydsp>, ffi.Pointer<UIGlue>)>();

  void computemydsp(
    ffi.Pointer<mydsp> dsp,
    int count,
    ffi.Pointer<ffi.Pointer<ffi.Float>> inputs,
    ffi.Pointer<ffi.Pointer<ffi.Float>> outputs,
  ) {
    return _computemydsp(
      dsp,
      count,
      inputs,
      outputs,
    );
  }

  late final _computemydspPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<mydsp>,
              ffi.Int,
              ffi.Pointer<ffi.Pointer<ffi.Float>>,
              ffi.Pointer<ffi.Pointer<ffi.Float>>)>>('computemydsp');
  late final _computemydsp = _computemydspPtr.asFunction<
      void Function(
          ffi.Pointer<mydsp>,
          int,
          ffi.Pointer<ffi.Pointer<ffi.Float>>,
          ffi.Pointer<ffi.Pointer<ffi.Float>>)>();
}

class mydsp extends ffi.Struct {
  @ffi.Array.multi([2])
  external ffi.Array<ffi.Int> iVec0;

  @ffi.Int()
  external int fSampleRate;

  @ffi.Float()
  external double fConst1;

  @ffi.Array.multi([2])
  external ffi.Array<ffi.Float> fRec0;

  @ffi.Array.multi([2])
  external ffi.Array<ffi.Float> fVec1;

  @ffi.Int()
  external int IOTA0;

  @ffi.Array.multi([512])
  external ffi.Array<ffi.Float> fVec2;

  @ffi.Int()
  external int iConst4;

  @ffi.Int()
  external int iConst5;

  @ffi.Float()
  external double fConst7;

  @ffi.Float()
  external double fConst8;

  @ffi.Float()
  external double fConst9;

  @ffi.Float()
  external double fConst10;

  @ffi.Array.multi([2])
  external ffi.Array<ffi.Float> fRec1;

  @ffi.Float()
  external double fConst11;
}

class MetaGlue extends ffi.Struct {
  external ffi.Pointer<ffi.Void> metaInterface;

  external metaDeclareFun declare;
}

typedef metaDeclareFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> key, ffi.Pointer<ffi.Char> value)>>;

class UIGlue extends ffi.Struct {
  external ffi.Pointer<ffi.Void> uiInterface;

  external openTabBoxFun openTabBox;

  external openHorizontalBoxFun openHorizontalBox;

  external openVerticalBoxFun openVerticalBox;

  external closeBoxFun closeBox;

  external addButtonFun addButton;

  external addCheckButtonFun addCheckButton;

  external addVerticalSliderFun addVerticalSlider;

  external addHorizontalSliderFun addHorizontalSlider;

  external addNumEntryFun addNumEntry;

  external addHorizontalBargraphFun addHorizontalBargraph;

  external addVerticalBargraphFun addVerticalBargraph;

  external addSoundFileFun addSoundFile;

  external declareFun declare;
}

/// UI and Meta classes for C or LLVM generated code.
typedef openTabBoxFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface, ffi.Pointer<ffi.Char> label)>>;
typedef openHorizontalBoxFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface, ffi.Pointer<ffi.Char> label)>>;
typedef openVerticalBoxFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface, ffi.Pointer<ffi.Char> label)>>;
typedef closeBoxFun = ffi.Pointer<
    ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void> ui_interface)>>;
typedef addButtonFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label, ffi.Pointer<ffi.Float> zone)>>;
typedef addCheckButtonFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label, ffi.Pointer<ffi.Float> zone)>>;
typedef addVerticalSliderFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label,
            ffi.Pointer<ffi.Float> zone,
            ffi.Float init,
            ffi.Float min,
            ffi.Float max,
            ffi.Float step)>>;
typedef addHorizontalSliderFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label,
            ffi.Pointer<ffi.Float> zone,
            ffi.Float init,
            ffi.Float min,
            ffi.Float max,
            ffi.Float step)>>;
typedef addNumEntryFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label,
            ffi.Pointer<ffi.Float> zone,
            ffi.Float init,
            ffi.Float min,
            ffi.Float max,
            ffi.Float step)>>;
typedef addHorizontalBargraphFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label,
            ffi.Pointer<ffi.Float> zone,
            ffi.Float min,
            ffi.Float max)>>;
typedef addVerticalBargraphFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label,
            ffi.Pointer<ffi.Float> zone,
            ffi.Float min,
            ffi.Float max)>>;
typedef addSoundFileFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Char> label,
            ffi.Pointer<ffi.Char> url,
            ffi.Pointer<ffi.Pointer<Soundfile>> sf_zone)>>;

class Soundfile extends ffi.Opaque {}

typedef declareFun = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> ui_interface,
            ffi.Pointer<ffi.Float> zone,
            ffi.Pointer<ffi.Char> key,
            ffi.Pointer<ffi.Char> value)>>;
