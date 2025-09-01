// main.dart — Atom Scanner — النسخة المصححة للعمل على DartPad (Flutter)
import 'package:flutter/material.dart';

void main() {
  runApp(const AtomScannerApp());
}


class AtomScannerApp extends StatelessWidget {
  const AtomScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATOM Scanner - دليل الصيانة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true),
      ),
      home: const HomeScreen(),
    );
  }
}

/* 
=========================
   Data Models (Board / Tests)
   =========================
*/

class Board {
  final String code;
  final String name;
  final String description;
  final Color color;
  final List<String> tags;
  final List<TestPoint> testPoints;
  final List<ICSpec> ics;
  final List<String> notes; // static notes / suggestions
  final String imageUrl; // placeholder for later

  const Board({
    required this.code,
    required this.name,
    required this.description,
    required this.color,
    this.tags = const [],
    this.testPoints = const [],
    this.ics = const [],
    this.notes = const [],
    this.imageUrl = '',
  });
}

class TestPoint {
  final String id; // TP1, +5V, ...
  final String location; // e.g., "TP2 - next to bulk cap"
  final String expected; // e.g., "+5.00V ±5%"
  final String details;
  final Offset? pos; // optional for schematic overlay

  const TestPoint({required this.id, required this.location, required this.expected, required this.details, this.pos});
}

class ICPin {
  final String pin;
  final String name;
  final String expected;

  const ICPin({required this.pin, required this.name, required this.expected});
}

class ICSpec {
  final String ref;
  final String part;
  final String role;
  final List<ICPin> pins;
  final List<String> checks;

  const ICSpec({required this.ref, required this.part, required this.role, this.pins = const [], this.checks = const []});
}

/* =========================
   Static Database (Boards)
   ========================= */

final List<Board> kBoards = [
  Board(
    code: 'PSU',
    name: 'Power Supply (PSU)',
    description:
        'مزود الطاقة الرئيسي: تحويل وتقويم وتنعيم وتوليد +5V و ±12V. احتياطات: فحص المكثفات، الديودات، المحول الصغير، وقياس التموج.',
    color: Colors.green,
    tags: ['PSU', 'Power', '5V', '12V'],
    testPoints: const [
      TestPoint(id: 'TP1', location: 'بعد جسر التقويم', expected: '≈ 300–325 VDC', details: 'على 220VAC دخول.', pos: Offset(0.12, 0.12)),
      TestPoint(id: 'TP2', location: '+5V rail', expected: '+5.0 V ±5%', details: 'Ripple < 50mV RMS.', pos: Offset(0.55, 0.20)),
      TestPoint(id: 'TP3', location: '+12V rail', expected: '+12 V ±10%', details: 'التحقق تحت حمل.', pos: Offset(0.78, 0.25)),
      TestPoint(id: 'TP4', location: '-12V rail', expected: '-12 V ±10%', details: 'إن وُجد.', pos: Offset(0.80, 0.70)),
      TestPoint(id: 'TP5', location: 'Power Good (PG)', expected: 'High > 4.5V', details: 'عند استقرار الخرج.', pos: Offset(0.65, 0.6)),
    ],
    ics: const [
      ICSpec(
        ref: 'U1',
        part: 'UC3842 / PWM Controller (مثال)',
        role: 'متحكم PWM لدوائر SMPS',
        pins: [
          ICPin(pin: 'VCC', name: 'تغذية', expected: '14–18V (start)'),
          ICPin(pin: 'OUT', name: 'خروج PWM', expected: 'ملبّد 0–12V pp'),
          ICPin(pin: 'CS', name: 'Current Sense', expected: 'نبضات 0–1V'),
        ],
        checks: ['قِس VCC و OUT عند التشغيل', 'تحقق من وجود نبض PWM عند Gate/MOSFET'],
      ),
      ICSpec(
        ref: 'U2',
        part: 'TL431 (Voltage Ref)',
        role: 'مرجع دقيق لضبط العائد (feedback)',
        pins: [
          ICPin(pin: 'REF', name: 'مرجع', expected: '2.5V'),
        ],
        checks: ['افحص شدّة الجهد على REF ومقارنة الاستجابة بالتغذية'],
      ),
    ],
    notes: [
      'تأكد من فصل الطاقة قبل العمل على المكونات الأولية.',
      'اختبر المكثفات ESR باستخدام جهاز مخصص إن أمكن.',
      'ملاحظة: بعض الإصدارات تستخدم منظمات خطية للـ5V بدلاً من SMPS.',
    ],
    imageUrl: '',
  ),

  Board(
    code: 'CPU',
    name: 'CPU Card',
    description:
        'لوحة المعالج: تحتوي على الميكرو/الميكروبروسسر، الذاكرة، دائرة المذبذب، وبطارية الحفظ. مسؤولة عن إدارة النظام والتواصل مع البطاقات الأخرى.',
    color: Colors.blue,
    tags: ['CPU', 'MCU', 'Main'],
    testPoints: const [
      TestPoint(id: 'TP5V', location: 'VCC pin (CPU)', expected: '+5.0V ±5%', details: 'قياس بين VCC وGND', pos: Offset(0.15, 0.20)),
      TestPoint(id: 'TPCLK', location: 'Crystal pins (XTAL)', expected: '8–16 MHz', details: 'وجود موجة مربعة indicates oscillator ok', pos: Offset(0.55, 0.18)),
      TestPoint(id: 'TPRST', location: 'RESET line', expected: 'High after reset', details: 'Low briefly on power-up', pos: Offset(0.65, 0.28)),
      TestPoint(id: 'TPBAT', location: 'Battery contact', expected: '≈ 3.0–3.6V', details: 'حالة البطارية لحفظ الإعدادات'),
    ],
    ics: const [
      ICSpec(
        ref: 'U1',
        part: 'µPD70320 / 80Cxx (example)',
        role: 'المتحكم الرئيسي',
        pins: [
          ICPin(pin: 'VCC', name: 'تغذية', expected: '5V'),
          ICPin(pin: 'GND', name: 'أرضي', expected: '0V'),
          ICPin(pin: 'XTAL', name: 'مذبذب', expected: '8–16MHz'),
          ICPin(pin: 'RESET', name: 'خط إرجاع', expected: 'High بعد الإقلاع'),
        ],
        checks: ['قِس VCC وGND، تأكد من موجة الكلوك عند XTAL', 'افحص RESET'],
      ),
      ICSpec(
        ref: 'BT1',
        part: 'Battery 3.6V (RTC/backup)',
        role: 'حفظ الإعدادات',
        pins: [
          ICPin(pin: '+', name: 'موجب البطارية', expected: '3.0–3.6V'),
        ],
        checks: ['استبدال البطارية إذا أقل من 2.8V'],
      ),
    ],
    notes: [
      'لا تشحن البطارية على اللوحة—استبدال فقط.',
      'بعد استبدال البطارية قد تحتاج إعادة ضبط الإعدادات.',
    ],
    imageUrl: '',
  ),

  Board(
    code: 'I/F',
    name: 'Interface (I/F) Card',
    description:
        'واجهة الإشارات: buffers، transceivers (74HCxx)، وعوازل ضوئية إن وُجدت. تربط CPU مع بقية البطاقات.',
    color: Colors.orange,
    tags: ['I/F', 'Interface', '74HC'],
    testPoints: const [
      TestPoint(id: 'TPIF5', location: 'VCC (IF Board)', expected: '+5.0V', details: 'تغذية منطقية للكواشف والبوفرات', pos: Offset(0.15, 0.20)),
      TestPoint(id: 'TPBUS', location: 'Bus lines D0..D7', expected: 'Logic transitions', details: 'نشاط عند القراءة/الكتابة', pos: Offset(0.55, 0.40)),
      TestPoint(id: 'TPEN', location: 'OE / EN lines', expected: 'Low = enabled', details: 'تحكم البوفرات'),
    ],
    ics: const [
      ICSpec(
        ref: 'U5',
        part: '74HC244',
        role: 'Octal buffer',
        pins: [
          ICPin(pin: '20', name: 'VCC', expected: '5V'),
          ICPin(pin: '10', name: 'GND', expected: '0V'),
        ],
        checks: ['تحقق من OE low لتفعيل', 'غياب الخرج بالرغم من الدخل قد يُشير إلى تلف IC'],
      ),
      ICSpec(
        ref: 'U6',
        part: '74HC245',
        role: 'Transceiver',
        pins: [
          ICPin(pin: '20', name: 'VCC', expected: '5V'),
          ICPin(pin: '10', name: 'GND', expected: '0V'),
        ],
        checks: ['قِس اتجاه DIR أثناء العمليات', 'تحقق من OE'],
      ),
    ],
    notes: ['نظف الفلوكس حول الأرجل وراجع لحامات الكونكتورات.'],
    imageUrl: '',
  ),

  Board(
    code: 'A/D',
    name: 'A/D Card',
    description:
        'محول التناظري إلى رقمي: مسؤول عن قراءة الإشارات التناظرية من RTD/TC وتحويلها للمعالج عبر BUS.',
    color: Colors.purple,
    tags: ['A/D', 'ADC'],
    testPoints: const [
      TestPoint(id: 'TPVREF', location: 'VREF', expected: '2.5V or 5.0V', details: 'دقة المرجع مهمة'),
      TestPoint(id: 'TPCLK', location: 'ADC Clock', expected: '100–640kHz', details: 'ساعة التحويل (قد تختلف)'),
    ],
    ics: const [
      ICSpec(
        ref: 'U8',
        part: 'ADC080x or equivalent',
        role: 'ADC',
        pins: [
          ICPin(pin: 'VCC', name: 'VCC', expected: '5V'),
          ICPin(pin: 'GND', name: 'GND', expected: '0V'),
        ],
        checks: ['تحقق من VREF وثباتها', 'قارن دخل قناة مع الخرج الرقمي'],
      ),
    ],
    notes: ['التحقق من مسارات التأريض والتخلّص من الضجيج قبل A/D.'],
    imageUrl: '',
  ),

  Board(
    code: 'T/C',
    name: 'Thermocouple (T/C) Card',
    description:
        'معالجة إشارات TC: مضخمات حساسّة، CJC (cold-junction compensation)، وفلترة.',
    color: Colors.teal,
    tags: ['T/C', 'Thermocouple'],
    testPoints: const [
      TestPoint(id: 'TPCJC', location: 'CJC output', expected: '0.5–2.5V', details: 'يتغيّر مع حرارة اللوحة'),
      TestPoint(id: 'TPAMP', location: 'Amplifier output', expected: '0.2–4.0V', details: 'حسب الإدخال'),
    ],
    ics: const [
      ICSpec(
        ref: 'U2',
        part: 'Instrumentation Op-Amp',
        role: 'Amplifier for µV signals',
        pins: [
          ICPin(pin: '+V', name: 'V+', expected: '+12V'),
          ICPin(pin: '-V', name: 'V-', expected: '-12V'),
        ],
        checks: ['تأكد من ±12V وجودها قبل القياس', 'لا تلمس المدخلات بيد عارية'],
      ),
    ],
    notes: ['ثبّت الأسلاك في الكونكتورات الخضراء، واحرص على التأريض الجيد.'],
    imageUrl: '',
  ),

  Board(
    code: 'RTD',
    name: 'RTD Board',
    description:
        'مدخلات RTD (PT100/1000): دائرة تيار إثارة، تضخيم تفاضلي، وفلترة anti-alias قبل A/D.',
    color: Colors.lightGreen,
    tags: ['RTD', 'Temperature'],
    testPoints: const [
      TestPoint(id: 'TPREF', location: 'Reference (Vref)', expected: '2.5V', details: 'قد يختلف حسب التصميم'),
      TestPoint(id: 'TPOUT', location: 'Amplifier OUT', expected: '0.1–3.0V', details: 'حسب المقاومة'),
    ],
    ics: const [
      ICSpec(
        ref: 'U3',
        part: 'HEF4051BP (MUX)',
        role: 'Channel multiplexer',
        pins: [
          ICPin(pin: 'VDD', name: 'VDD', expected: '5V'),
          ICPin(pin: 'VSS', name: 'VSS', expected: '0V'),
        ],
        checks: ['تبديل القنوات عبر S0..S2', 'افحص القناة الواحدة إن لم تستجب'],
      ),
    ],
    notes: ['افحص مقاومات المرجع وRsense التي تحدد تيار الإثارة.'],
    imageUrl: '',
  ),

  Board(
    code: 'DISPLAY',
    name: 'Display / Driver',
    description: 'وحدة التعامل مع الشاشة: فيديو/Segments أو موصل LCD.',
    color: Colors.red,
    tags: ['Display', 'Driver'],
    testPoints: const [
      TestPoint(id: 'TPDISV', location: 'Display Vcc', expected: '5V', details: 'تحقق من ترددات التحديث'),
    ],
    ics: const [
      ICSpec(
        ref: 'U9',
        part: 'Display Driver',
        role: 'تحويل البيانات لبنود العرض',
        pins: [
          ICPin(pin: 'Vcc', name: 'Vcc', expected: '5V'),
        ],
        checks: ['تحقق من وجود بيانات وساعات العرض'],
      ),
    ],
    notes: ['راجع وصلات الكابل والشاشة قبل البدء بفحص اللوحة.'],
    imageUrl: '',
  ),
];

/* =========================
   App UI: Home / Search / List
   ========================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterTag = 'الكل';

  List<Board> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty && _filterTag == 'الكل') return kBoards;
    return kBoards.where((b) {
      final tagOk = (_filterTag == 'الكل') || b.tags.contains(_filterTag);
      final hay = (b.code + ' ' + b.name + ' ' + b.description + ' ' + b.tags.join(' ')).toLowerCase();
      final queryOk = q.isEmpty || hay.contains(q);
      return tagOk && queryOk;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final tags = <String>{'الكل'};
        for (var b in kBoards) tags.addAll(b.tags);
        final list = tags.toList();
        return ListView(
          padding: const EdgeInsets.all(12),
          children: list
              .map((t) => ListTile(
                    title: Text(t),
                    trailing: _filterTag == t ? const Icon(Icons.check) : null,
                    onTap: () {
                      setState(() => _filterTag = t);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _boardTile(Board b) {
    return GestureDetector(
      onTap: () {
        // Protect: ensure 'b' is not null (it never will be here because list has non-null items)
        Navigator.push(context, MaterialPageRoute(builder: (_) => BoardDetail(board: b)));
      },
      child: Card(
        color: b.color.withOpacity(0.90),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: Colors.white24, child: Text(b.code, style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 10),
              Expanded(child: Text(b.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Text(b.code, style: const TextStyle(color: Colors.white70)),
            ]),
            const SizedBox(height: 8),
            Text(b.description, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, children: b.tags.map((t) => Chip(label: Text(t), backgroundColor: Colors.white24, labelStyle: const TextStyle(color: Colors.white))).toList())
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATOM Scanner — دليل الصيانة'),
        actions: [IconButton(onPressed: _openFilterSheet, icon: const Icon(Icons.filter_list))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث: CPU, PSU, RTD, T/C...'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => setState(() { _searchCtrl.clear(); _filterTag = 'الكل'; }), child: const Text('إعادة')),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('لا توجد نتائج مطابقة', style: TextStyle(fontSize: 16)))
              : ListView.builder(padding: const EdgeInsets.only(bottom: 20), itemCount: list.length, itemBuilder: (_, i) => _boardTile(list[i])),
        ),
      ]),
    );
  }
}

/* =========================
   Detail Screen (Board)
   ========================= */

class BoardDetail extends StatelessWidget {
  final Board board;
  const BoardDetail({super.key, required this.board});

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(children: [
        if (icon != null) Icon(icon, size: 18),
        if (icon != null) const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _testPointTile(TestPoint tp, BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pin_drop),
      title: Text('${tp.id} — ${tp.location}'),
      subtitle: Text('المتوقع: ${tp.expected}\n${tp.details}'),
      onTap: () {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('قياس ${tp.id}'),
                  content: Text('اتبع التعليمات: ${tp.details}\nالمتوقع: ${tp.expected}'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('اغلاق'))],
                ));
      },
    );
  }

  Widget _icTile(ICSpec ic, BuildContext ctx) {
    return ExpansionTile(
      leading: const Icon(Icons.memory),
      title: Text('${ic.ref} • ${ic.part}'),
      subtitle: Text(ic.role),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('أرجل مهمة:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            for (final p in ic.pins) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• ${p.pin} — ${p.name} — المتوقع: ${p.expected}')),
            const SizedBox(height: 8),
            const Text('خطوات فحص:', style: TextStyle(fontWeight: FontWeight.w600)),
            ...ic.checks.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• $c'))).toList(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.info),
              label: const Text('إرشادات فحص الـ IC'),
              onPressed: () {
                showDialog(
                    context: ctx,
                    builder: (dctx) => AlertDialog(
                          title: Text('فحص ${ic.part}'),
                          content: SingleChildScrollView(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                            Text('1) افصل الطاقة قبل اللمس.'),
                            Text('2) افحص بصرياً وجود لحام بارد أو أكسدة.'),
                            Text('3) شغّل الطاقة وقِس الفولتية على الأرجل المدرجة.'),
                            Text('4) إن لم تتطابق القيم، افحص المكونات المحيطة (مقاومات/مكثفات).'),
                            Text('5) إذا لزم استبدل IC تجريبياً أو افحصه خارج اللوحة.'),
                          ])),
                          actions: [TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('اغلاق'))],
                        ));
              },
            ),
          ]),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // board is non-null (required)
    return Scaffold(
      appBar: AppBar(
        title: Text(board.name),
        backgroundColor: board.color,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header image area (placeholder)
          Container(
            height: 160,
            color: board.color.withOpacity(0.12),
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 140,
                height: 120,
                decoration: BoxDecoration(color: board.color.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                child: board.imageUrl.isEmpty
                    ? const Center(child: Icon(Icons.image, size: 48, color: Colors.white70))
                    : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(board.imageUrl, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(board.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(board.description),
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: board.tags.map((t) => Chip(label: Text(t))).toList()),
              ])),
            ]),
          ),
          const SizedBox(height: 8),
          _sectionHeader('نظرة عامة', icon: Icons.info_outline),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(board.description)),
          const SizedBox(height: 8),
          _sectionHeader('نقاط الفحص/القياس', icon: Icons.pin_drop),
          Column(children: board.testPoints.map((tp) => _testPointTile(tp, context)).toList()),
          const SizedBox(height: 8),
          _sectionHeader('الدوائر المتكاملة والفحص', icon: Icons.memory),
          Column(children: board.ics.map((ic) => _icTile(ic, context)).toList()),
          const SizedBox(height: 8),
          _sectionHeader('ملاحظات سريعة', icon: Icons.note),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: board.notes.map((n) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('• $n'))).toList()),
          ),
          const SizedBox(height: 12),
          _sectionHeader('مخطط/صورة اللوحة (Placeholder)', icon: Icons.scatter_plot),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(height: 160, decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('أضف الصورة الحقيقية لاحقاً'))),
              const SizedBox(height: 8),
              ElevatedButton.icon(onPressed: () {
                showDialog(context: context, builder: (dctx) => AlertDialog(title: const Text('رفع صورة'), content: const Text('في المشروع المحلي استخدم image_picker أو file_picker لرفع وعرض الصور.'), actions: [TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('اغلاق'))]));
              }, icon: const Icon(Icons.upload_file), label: const Text('رفع/استبدال الصورة (لاحقاً)')),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
