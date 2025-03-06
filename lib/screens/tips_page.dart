import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('نصائح لتحسين النوم'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCategory(
            context,
            'نصائح قبل النوم',
            Icons.nightlight_round,
            [
              'تجنب استخدام الأجهزة الإلكترونية قبل النوم بساعة',
              'حافظ على درجة حرارة الغرفة معتدلة (18-21 درجة مئوية)',
              'تناول عشاء خفيف قبل النوم بساعتين على الأقل',
              'قم بممارسة تمارين الاسترخاء أو التأمل',
              'تجنب المشروبات المحتوية على الكافيين بعد العصر',
              'اجعل غرفة نومك هادئة ومظلمة',
              'استخدم سرير مريح ووسائد مناسبة',
              'البس ملابس مريحة للنوم',
              'استخدم الستائر المعتمة لمنع دخول الضوء',
              'تجنب النقاشات المثيرة للتوتر قبل النوم',
              'اقرأ كتاباً هادئاً أو استمع لموسيقى هادئة',
              'خذ حماماً دافئاً قبل النوم',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'تحضير بيئة النوم',
            Icons.bedroom_parent_outlined,
            [
              'استخدم مرتبة وفراش مناسب لطبيعة جسمك',
              'اختر وسادة تدعم رقبتك بشكل صحيح',
              'استخدم أغطية من القطن الطبيعي',
              'تأكد من تهوية الغرفة بشكل جيد',
              'ضع نباتات لطيفة في غرفة النوم',
              'استخدم معطر هواء طبيعي مهدئ',
              'نظم الأثاث بطريقة تبعث على الراحة',
              'تجنب وضع التلفاز في غرفة النوم',
              'احتفظ بمنبه بعيداً عن السرير',
              'استخدم إضاءة خافتة في المساء',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'روتين صحي للنوم',
            Icons.schedule,
            [
              'حافظ على موعد نوم واستيقاظ ثابت',
              'اجعل لنفسك روتين مسائي ثابت',
              'تجنب القيلولة الطويلة خلال النهار',
              'مارس الرياضة بانتظام لكن ليس قبل النوم مباشرة',
              'اتبع نظام غذائي صحي ومتوازن',
              'تعرض للضوء الطبيعي خلال النهار',
              'تجنب الوجبات الثقيلة قبل النوم',
              'اشرب الماء بكمية كافية خلال النهار',
              'قلل من السوائل قبل النوم بساعتين',
              'خصص وقتاً للاسترخاء قبل النوم',
              'اكتب مهام الغد قبل النوم',
              'تأمل لمدة 10 دقائق قبل النوم',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'نصائح للاستيقاظ',
            Icons.wb_sunny_outlined,
            [
              'استيقظ في نفس الوقت يومياً حتى في العطلات',
              'تعرض للضوء الطبيعي مباشرة بعد الاستيقاظ',
              'تناول فطور صحي في وقت مبكر',
              'قم بتمارين خفيفة للتنشيط',
              'اشرب كمية كافية من الماء',
              'خطط ليومك في الصباح الباكر',
              'تجنب النظر للهاتف فور الاستيقاظ',
              'افتح النوافذ للتهوية الصباحية',
              'رتب سريرك فور الاستيقاظ',
              'اغسل وجهك بماء بارد للتنشيط',
              'استمع لموسيقى حيوية في الصباح',
              'قم بتمارين التمدد الصباحية',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'تحسين جودة النوم',
            Icons.star_outline,
            [
              'تجنب النظر إلى الساعة إذا استيقظت ليلاً',
              'استخدم تقنيات التنفس العميق للاسترخاء',
              'تجنب التفكير في مشاكل العمل قبل النوم',
              'اكتب ما يقلقك في دفتر قبل النوم',
              'استخدم أصوات طبيعية هادئة للمساعدة على النوم',
              'تجنب الضوء الأزرق في المساء',
              'استخدم زيوت عطرية مهدئة مثل اللافندر',
              'حافظ على رطوبة مناسبة في غرفة النوم',
              'استخدم قناع للعين إذا كان هناك ضوء',
              'جرب تقنية الاسترخاء التدريجي للعضلات',
              'تناول أطعمة غنية بالمغنيسيوم',
              'تجنب التدخين قبل النوم',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'نصائح غذائية للنوم الجيد',
            Icons.restaurant_menu,
            [
              'تناول الموز قبل النوم لمحتواه من التريبتوفان',
              'اشرب شاي البابونج المهدئ',
              'تجنب الأطعمة الحارة في المساء',
              'تناول المكسرات كوجبة خفيفة',
              'اختر الكرز الحامض كمصدر طبيعي للميلاتونين',
              'تجنب السكريات المكررة قبل النوم',
              'تناول الأسماك الغنية بأوميغا 3',
              'اختر الحليب الدافئ قبل النوم',
              'تجنب الشوكولاتة الداكنة مساءً',
              'تناول الزبادي قليل الدسم',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'نصائح للتعامل مع الأرق',
            Icons.warning_amber_outlined,
            [
              'انهض من السرير إذا لم تستطع النوم خلال 20 دقيقة',
              'قم بنشاط هادئ حتى تشعر بالنعاس',
              'تجنب مشاهدة التلفاز في غرفة النوم',
              'تجنب القلق بشأن عدم النوم',
              'مارس تمارين الاسترخاء التدريجي للعضلات',
              'اقرأ كتاباً ورقياً بإضاءة خافتة',
              'استمع لموسيقى هادئة أو صوت المطر',
              'جرب تمارين التنفس 4-7-8',
              'غير مكان نومك مؤقتاً',
              'اكتب أفكارك في دفتر يوميات',
              'تحدث مع طبيب إذا استمر الأرق',
              'جرب العلاج السلوكي المعرفي',
            ],
          ),
          const SizedBox(height: 16),
          _buildTipCategory(
            context,
            'نصائح للمسافرين',
            Icons.flight,
            [
              'اضبط ساعتك على توقيت الوجهة مبكراً',
              'تجنب القيلولة عند الوصول نهاراً',
              'تعرض للضوء الطبيعي في الوجهة الجديدة',
              'حافظ على الترطيب أثناء السفر',
              'استخدم قناع العين وسدادات الأذن',
              'تجنب الكافيين أثناء الرحلات الطويلة',
              'تحرك وتمدد كل ساعتين أثناء السفر',
              'تناول وجبات خفيفة في أوقات الوجهة',
              'اختر مقعداً مريحاً في الطائرة',
              'خذ حماماً دافئاً عند الوصول للفندق',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCategory(
    BuildContext context,
    String title,
    IconData icon,
    List<String> tips,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
