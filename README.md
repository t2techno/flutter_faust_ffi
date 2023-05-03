# flutter_faust_ffi

A basic flutter app to prove as a proof of concept utilizing Faust's C api export with Dart's ffi methods to create cross-platform plug-ins.

The first step was preparing the Faust exported C file to be further exported as a dll.
In /dsp_c:
<ol>
  <li>cmake .</li>
  <li>cmake --build .</li>
  <li>You'll find the generated dll file in dsp_c/Debug/</li>
</ol>

The next step was creating the C-Native and Dart typedefs for dsp, gui, and metadata class objects and methods being used from the c code, found in lib/dsp_dart/api_types.dart

TODO: My next step is going to be utilizing those types to create a class object that will allow me to instantiate and run my faust dsp object.
