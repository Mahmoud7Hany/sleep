import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, 
                    color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'كيفية استخدام الحاسبة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildHelpSection(
                'حساب وقت النوم:',
                'اختر وقت الاستيقاظ المطلوب، وسيتم عرض أفضل الأوقات للنوم بناءً على دورات النوم (90 دقيقة لكل دورة).',
                Icons.bedtime,
              ),
              _buildHelpSection(
                'حساب وقت الاستيقاظ:',
                'اختر وقت النوم، وسيتم عرض أفضل الأوقات للاستيقاظ لضمان الشعور بالنشاط.',
                Icons.wb_sunny,
              ),
              _buildHelpSection(
                'دورات النوم:',
                'كل دورة نوم تستغرق 90 دقيقة. للحصول على أفضل راحة، يُفضل الاستيقاظ في نهاية دورة كاملة.',
                Icons.repeat,
              ),
              _buildHelpSection(
                'جودة النوم:',
                'الألوان تشير إلى جودة النوم المتوقعة:\n'
                '🟢 أخضر: مثالي (5-6 دورات)\n'
                '🟡 أصفر: جيد (4-5 دورات)\n'
                '🔴 أحمر: قصير (أقل من 4 دورات)',
                Icons.star,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('فهمت'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 28, top: 4),
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
