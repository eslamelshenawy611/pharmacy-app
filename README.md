# دفتر عملاء الصيدلية (نسخة Supabase)

- مشروع Supabase: vet-pharmacy-customers (ref: xbzldysgngiwlblvayxi، فرانكفورت، الخطة المجانية).
- `index.html`: الأبلكيشن كله (عربي، RTL، بيتثبت على الموبايل). متوصل بالمشروع خلاص.
- `schema.sql`: الجداول الأساسية. وفيه كمان على Supabase migration اسمها members_only_access: محدش يشوف البيانات غير اللي team.active = true عنده.
- رسايل واتساب جاهزة: من الإعدادات، بتتحفظ في settings.data.msgs، وبتظهر زراير في صفحة العميل (wa.me). المتغيرات: {الاسم} {الاسم كامل} {الصيدلية} {المنطقة} {الباقي}.
- `supabase.js`: مكتبة supabase-js 2.45.4 محفوظة جنب الصفحة.
- `sw.js` + `manifest.webmanifest` + الأيقونات: عشان التثبيت على الموبايل. غيّر رقم CACHE في sw.js مع كل تعديل.

إضافة موظف: Authentication ← Add user (Auto confirm)، وبعدين في جدول team خلي active = true للموظف ده.
الرفع: أي استضافة static (مثلًا Netlify Drop: اسحب الفولدر كله أو ملف الـ zip).
