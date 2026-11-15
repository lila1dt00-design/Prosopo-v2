# Player Cutout Native integration status

## Integrated
- Added `PlayerCutoutActivity` as a native Android Activity. It uses Android `Bitmap`, `Canvas`, `ImageView`, `SeekBar`, document picker, and MediaStore PNG export; it does not use WebView/HTML/JavaScript for image processing.
- Added an entry point to the existing Prosopo home screen through the existing WebView-to-Android bridge. Existing converter screens and Python bridge were retained.
- Added ONNX Runtime Android dependency (`com.microsoft.onnxruntime:onnxruntime-android:1.20.1`) in preparation for local inference.
- Native editing state includes original bitmap, optional cutout/enhanced bitmap slots, crop parameters, linear/circular fade parameters, filter parameters, and undo/redo snapshots.
- Implemented local crop rectangle controls, aspect ratios, fade math, filter presets/manual color controls, transparent PNG export, and output sizing choices.

## Not complete / must not be represented as complete
- The uploaded project did not contain either ONNX model. Network access from the build container was unavailable, so `birefnet_lite_512_fp16.onnx` and `realesr-general-x4v3.onnx` could not be bundled. The native UI deliberately reports this rather than fabricating a successful result.
- BiRefNet inference, alpha matte creation/edge refinement, automatic player bounds, and Real-ESRGAN inference/tiled progress/cancel are not implemented yet.
- Native crop currently uses numeric geometry sliders and aspect presets rather than the original draggable corner handles.
- The user mentioned a UI screenshot, but no screenshot was present among the two mounted uploads.
- Undo/redo currently snapshots editing parameters, not expensive model outputs or every pixel operation.
- The source archive lacks `gradle-wrapper.jar`; no Gradle executable or Android SDK is installed in this environment, so an APK build/device test could not be performed.

## Model requirements
- BiRefNet Lite model card: `shozebDev/birefnet-lite-512-onnx`, MIT, fixed input `[1,3,512,512]`, ImageNet normalization, output logits requiring sigmoid.
- Real-ESRGAN general-x4v3 model: BSD-3-Clause, dynamic RGB NCHW float input and 4x output. Confirm exact tensor names/shapes against the selected ONNX artifact before shipping.

The app remains build-configured for Android `minSdk 21`; ONNX Runtime documentation says Android API 21+ may be compatible, but it is not tested across every device combination. Verify the exact AAR and ABIs in a real build. Do not claim offline AI processing until both model binaries are added to `app/src/main/assets/models/` and device inference is validated.

## Update (this session)
- Real-ESRGAN x4v3 bundled (assets/models, .onnx + .data) and `EsrganEngine.java` added: 128px tiles, 16px overlap, background thread, progress, cancel, alpha preserved. Tile algorithm verified in Python with the real model (no seams). The Java port itself is NOT compiled or run: no javac/Android SDK/network here.
- Enhance tab wired to it. Input capped at 800px per side (output up to 3200px) to avoid OOM.
- BiRefNet: the model file was NOT in the uploads (Real-ESRGAN was uploaded twice, identical). Background removal remains unimplemented.

## Update 2 — BiRefNet
- `model_fp16_1.onnx` received; verified with onnxruntime (Python): input_image [1,3,512,512] float32, output_image [1,1,512,512] logits (-28..24), needs sigmoid. Foreground detected correctly on a synthetic test image. Bundled as assets/models/birefnet_lite_512_fp16.onnx (~98 MB).
- `BiRefNetEngine.java` added: resize/normalise, inference, sigmoid, upsample, edge refinement, alpha + player bounds. Wired to the Background tab and the "auto-crop around player" button.
- NOT verified: Java compile, Android run, real photos, Android speed/memory (Python CPU took ~7.7 s on this server). The FP16 model may hit unsupported FP16 kernels on some Android CPUs; test on a device.
