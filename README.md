# دفتر عملاء الصيدلية (نسخة Supabase)

- مشروع Supabase: vet-pharmacy-customers (ref: xbzldysgngiwlblvayxi، فرانكفورت، الخطة المجانية).
- `index.html`: الأبلكيشن كله (عربي، RTL، بيتثبت على الموبايل). متوصل بالمشروع خلاص.
- `schema.sql`: الجداول الأساسية. وفيه كمان على Supabase migration اسمها members_only_access: محدش يشوف البيانات غير اللي team.active = true عنده.
- رسايل واتساب جاهزة: من الإعدادات، بتتحفظ في settings.data.msgs، وبتظهر زراير في صفحة العميل (wa.me). المتغيرات: {الاسم} {الاسم كامل} {الصيدلية} {المنطقة} {الباقي}.
- `supabase.js`: مكتبة supabase-js 2.45.4 محفوظة جنب الصفحة.
- `sw.js` + `manifest.webmanifest` + الأيقونات: عشان التثبيت على الموبايل. غيّر رقم CACHE في sw.js مع كل تعديل.

إضافة موظف: Authentication ← Add user (Auto confirm)، وبعدين في جدول team خلي active = true للموظف ده.
الرفع: أي استضافة static (مثلًا Netlify Drop: اسحب الفولدر كله أو ملف الـ zip).

## تحديث: الحملات والمراحل والاستيراد
- المراحل: lead / follow / promised (وعد يحجز) / booked (حجز) / buyer / lost (مستبعد). المرحلة الكاملة في customers.pipeline، وcustomers.stage فيها الأربعة القدام بس عشان الـ check constraint.
- customers: exclude_reason, follow_note, campaign_id. جدول campaigns (spend, messages, extras jsonb). cycles: sell_day, sold_on (وكمان logs مش مستخدم).
- استيراد تقرير فيسبوك CSV من تبويب الحملات، واستيراد أرقام (لصق / VCF / CSV) من تبويب العملاء.
