# Prosopo (Android) — نسخة Chaquopy

بايثون الأصلي يعمل داخل التطبيق (Chaquopy) بدل Pyodide/WebView، فلا يتأثر بقدم WebView في Honor وغيره.
الواجهة (index.html) وكود التحويل (حزمة bundle.bin المشفّرة بنفس مفتاحك) بقيا كما هما.

## البناء
1. ثبّت Android Studio (Koala أو أحدث) وPython 3.8+ على جهازك (يحتاجه Chaquopy وقت البناء).
2. File ▸ Open ▸ مجلد المشروع، وانتظر Gradle Sync (يحتاج إنترنت أول مرة).
3. Build ▸ Build APK(s)  أو  Run على جهاز Honor.

## لو فشل Sync
- رسالة عن إصدار Chaquopy/AGP: غيّر الأرقام معًا في build.gradle (AGP 8.5.2 مع Chaquopy 16.0.0).
- رسالة أن numpy/scipy/pillow غير متوفرة لـ armeabi-v7a أو للإصدار 3.11: احذف 'armeabi-v7a' من abiFilters
  أو جرّب version '3.12' في chaquopy.defaultConfig.

## ما تغيّر
- app/src/main/python/pybridge.py: ينفّذ كود بايثون ويلتقط المخرجات (بديل runPython).
- PyBridge.java: يفك حزمة bundle.bin أول تشغيل ويشغّل بايثون ويقرأ/يكتب الملفات.
- MainActivity.java: WebView + اختيار الملفات + الحفظ في Download/FaceTools (Android 6–9 يطلب إذن التخزين).
- ArchiveHelper.java: فك RAR/7z (بدل libarchive الخاص بـ Pyodide). ZIP وCPK وFPK وFMDL وGLB تعمل بلا اعتماد عليه.
- index.html: استُبدل تحميل Pyodide بجسر أصلي، وحُذفت الحزمة المضمّنة منه. وعُدّل containers.py ليستعمل ArchiveHelper.

## تعديلات إضافية (scipy)
- حُذف scipy من البناء (لا توجد له حزمة لهواتف 32-بت مثل Galaxy A12). أُضيف face_tools/_spfallback.py داخل bundle.bin
  (بدائل numpy لـ cKDTree وndimage.label/sum/binary_dilation)، وقورنت نتائجها مع scipy فتطابقت.
- لذلك يبقى abiFilters كما هو (arm64-v8a وarmeabi-v7a وx86_64) ويعمل APK واحد على الجميع.

## البناء الآلي على GitHub (بدون Android Studio)
1. ارفع هذا المجلد كمستودع على GitHub.
2. تبويب Actions ▸ Build APK ▸ Run workflow.
3. بعد النجاح نزّل Prosopo-debug-apk من قسم Artifacts في صفحة التشغيل.

## تحسين الشعر (v2.4)
- أي خامة اسمها hair/beard/mustache/stubble/goatee/sideburn/brow تُستعمل الآن (كانت الخامات خارج 5 أسماء محددة تُهمَل).
- بطاقات الشعر ذات RGB العشوائي (hair_parts_*) لم تعد تصير لونًا مسطّحًا: يُحفظ تباين الخصل ويُلوَّن بلون الباك.
- اللون يُختار من خريطة لون مطابقة (beard/brow/hair) داخل الباك، وإلا أي خريطة لون، وإلا الافتراضي.
- ملف 模型信息.json صار يحوي hairMaterialReport (كل خامات الشعر وملفاتها المستعملة والمُهمَلة).
- FACE_HAIR_STRAND_SHADE=0 يعيد السلوك القديم (لون مسطّح).

## Player Cutout (Native integration in progress)
- Added `PlayerCutoutActivity` for native Android bitmap editing and PNG export.
- The existing Prosopo converter and its Python bridge/bundle are retained.
- See `PLAYER_CUTOUT_NATIVE_STATUS.md` for the exact implemented scope and outstanding model/device-test requirements.
- Important: offline AI segmentation and Real-ESRGAN are not yet enabled because the two ONNX model binaries were not present in the supplied archive and could not be downloaded in this build environment. Do not ship this as a complete Player Cutout release until those models are bundled and device-tested.
