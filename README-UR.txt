GM Network Admin Upgrade — اردو گائیڈ

اس ورژن میں:
- اسی ایپ میں Admin مینو رکھا گیا ہے، جو صرف Supabase کے admin_users ٹیبل میں موجود لاگ اِن اکاؤنٹ کو دکھے گا۔
- ای میل/پاس ورڈ لاگ اِن Supabase Auth کے ذریعے ہے۔
- ایڈمن ڈیش بورڈ پروڈکٹس شامل کرنے اور ابتدائی ممبر/آرڈر/کمیشن ریکارڈ دیکھنے کی کوشش کرتا ہے۔
- config.js میں اپنی Supabase URL اور anon/public key ڈالنی ہوگی۔

اہم: ابھی یہ مکمل production app نہیں ہے۔ ممبر پروفائل بنانے کا مکمل محفوظ signup/referral flow اور کمیشن کی server-side calculation شامل نہیں۔ حقیقی ادائیگیاں شروع نہ کریں۔

موبائل سے اگلے مراحل:
1) Chrome میں supabase.com کھول کر نیا project بنائیں۔
2) Supabase > SQL Editor میں supabase-schema.sql کا متن چلائیں۔ اگر policy پہلے سے موجود ہونے کا error ہو تو رک کر error محفوظ کریں؛ اندھا دھند دوبارہ نہ چلائیں۔
3) Supabase > Project Settings > API سے Project URL اور anon/public key لیں۔ service_role/secret key ہرگز نہ لیں۔
4) config.js فائل میں صرف URL اور anon/public key رکھیں۔
5) فائلیں HTTPS static hosting پر deploy کریں؛ مثال کے طور پر GitHub Pages یا کوئی دوسرا static host، موجودہ مفت limits اور شرائط چیک کریں۔
6) اپنی ویب سائٹ پر Account ٹیب سے اپنا owner account بنائیں۔ پھر Supabase > Authentication > Users میں اپنے صارف کا UUID کاپی کریں۔
7) SQL Editor میں الگ سے یہ چلائیں، UUID کو اپنے اصل UUID سے بدلیں:
   insert into public.admin_users(user_id) values ('YOUR_AUTH_USER_UUID');
   اسے کسی دوسرے صارف کے UUID سے نہ چلائیں۔ اب دوبارہ ویب ایپ میں sign in کریں؛ Admin مینو نظر آنا چاہیے۔
8) پہلے test account اور test product کے ساتھ چیک کریں۔ مسئلہ آئے تو error کا screenshot بھیجیں۔

سکیورٹی:
- service_role/secret key کو config.js یا public files میں کبھی نہ ڈالیں۔
- admin_users میں admin صرف آپ خود بنائیں؛ کسی عام ممبر کو admin نہ بنائیں۔
- فرنٹ اینڈ میں Admin مینو چھپانا کافی سکیورٹی نہیں؛ اصل اجازت database RLS سے نافذ ہوتی ہے۔
- کمیشن کی رقم browser سے قابلِ اعتماد نہ سمجھیں؛ server-side validation/commission trigger بننے تک حقیقی ادائیگی نہ کریں۔
- حقیقی launch سے پہلے privacy policy, terms, backups, audit logs, rate limiting اور قانونی/ٹیکس جائزہ ضروری ہے۔
- صرف حقیقی مصنوعات/خدمات کی فروخت سے منسلک شفاف کمیشن رکھیں۔


کنفیگریشن اپڈیٹ: config.js میں Supabase Project URL اور Publishable key درج کر دی گئی ہے۔
اہم: یہ ZIP ابھی HTTPS ہوسٹنگ پر اپ لوڈ کرنا باقی ہے؛ صرف مقامی index.html کھولنے سے لاگ اِن کام نہیں کرے گا۔
