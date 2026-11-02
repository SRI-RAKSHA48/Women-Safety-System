import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

const backend = 'http://10.0.2.2:8080';

void main() {
  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Safety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff8f7fb),
      ),
      home: const LoginPage(),
    );
  }
}

class Api {
  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$backend$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) return jsonDecode(r.body);
    throw Exception('Backend error ${r.statusCode}: ${r.body}');
  }
}

Future<Position?> getPosition() async {
  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) return null;
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) return null;
  return Geolocator.getCurrentPosition();
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email/mobile and password')));
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setBool('loggedIn', true);
    await p.setString('userName', email.text.split('@').first);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.shield, size: 72),
                const SizedBox(height: 12),
                const Text('WOMEN SAFETY', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email / Mobile', border: OutlineInputBorder())),
                const SizedBox(height: 14),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: login, child: const Text('LOGIN'))),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                  child: const Text("Don't have an account? REGISTER"),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('OTP Verification'),
              content: const Text('Prototype OTP step. Connect Firebase Auth/OTP for production.'),
              actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('VERIFY'))],
            )),
            child: const Text('SEND OTP'),
          )
        ],
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Forgot Password')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const TextField(decoration: InputDecoration(labelText: 'Email / Mobile', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Reset Password'),
            content: const Text('OTP/password reset flow is ready to connect to Firebase Auth.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          )),
          child: const Text('SEND OTP'),
        )
      ]),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String risk = 'SAFE';
  int score = 0;
  bool sosActive = false;
  String? incidentId;
  Position? position;
  String transport = 'WALKING';
  Timer? riskTimer;

  @override
  void initState() {
    super.initState();
    refreshRisk();
    riskTimer = Timer.periodic(const Duration(seconds: 30), (_) => refreshRisk());
  }

  @override
  void dispose() {
    riskTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshRisk() async {
    position ??= await getPosition();
    final now = DateTime.now();
    final p = position;
    try {
      final result = await Api.post('/api/risk/predict', {
        'latitude': p?.latitude ?? 0,
        'longitude': p?.longitude ?? 0,
        'transportMode': transport,
        'hour': now.hour,
        'trafficLevel': 'MEDIUM',
        'crowdDensity': 'MEDIUM',
        'streetLighting': now.hour >= 22 || now.hour < 5 ? 'POOR' : 'GOOD',
        'historicalIncidentRate': 0.30,
        'routeIsolated': false,
        'routeDeviation': false,
        'rain': false,
        'unusualMovement': false
      });
      if (mounted) setState(() { risk = result['level']; score = result['score']; });
    } catch (_) {}
  }

  Future<void> activateSos() async {
    position ??= await getPosition();
    try {
      final result = await Api.post('/api/sos/activate', {
        'latitude': position?.latitude ?? 0,
        'longitude': position?.longitude ?? 0,
        'transportMode': transport,
        'activationMethod': 'ONE_TAP'
      });
      if (mounted) setState(() { sosActive = true; incidentId = result['incidentId']; });
      if (mounted) Navigator.push(context, MaterialPageRoute(
        builder: (_) => SosActivePage(incidentId: incidentId!, onStopped: () => setState(() => sosActive = false))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS backend unavailable: $e')));
    }
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Women Safety'),
      actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout), tooltip: 'Logout')],
    ),
    body: RefreshIndicator(
      onRefresh: refreshRisk,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hello 👋', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                const Text('CURRENT SAFETY'),
                Text('$risk  •  $score%', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(position == null ? 'Location unavailable' : 'GPS: ${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}'),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: transport,
            decoration: const InputDecoration(labelText: 'How are you travelling?', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'WALKING', child: Text('🚶 Walking')),
              DropdownMenuItem(value: 'CAB', child: Text('🚕 Cab / Taxi')),
              DropdownMenuItem(value: 'PUBLIC_TRANSPORT', child: Text('🚌 Public Transport')),
              DropdownMenuItem(value: 'OWN_VEHICLE', child: Text('🚗 Own Vehicle')),
            ],
            onChanged: (v) { if (v != null) { setState(() => transport = v); refreshRisk(); } },
          ),
          const SizedBox(height: 14),
          SizedBox(height: 150, child: FilledButton(
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            onPressed: activateSos,
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.sos, size: 48), Text('SOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            ]),
          )),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
            children: [
              FeatureButton(icon: Icons.contacts, label: 'Emergency Contacts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsPage()))),
              FeatureButton(icon: Icons.phone_in_talk, label: 'Fake Call', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FakeCallPage()))),
              FeatureButton(icon: Icons.location_on, label: 'Live Location', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPage(position: position)))),
              FeatureButton(icon: Icons.route, label: 'Safe Route', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JourneyPage(transport: transport)))),
              FeatureButton(icon: Icons.smart_toy, label: 'AI Assistant', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssistantPage()))),
              FeatureButton(icon: Icons.local_hospital, label: 'Emergency Services', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyServicesPage()))),
              FeatureButton(icon: Icons.history, label: 'Incident Timeline', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelinePage()))),
              FeatureButton(icon: Icons.person, label: 'Profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(onLogout: logout)))),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Smart Safety Check-In'),
              subtitle: const Text('Start a journey with periodic safety check-ins and escalation.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JourneyPage(transport: transport))),
            ),
          )
        ],
      ),
    ),
  );
}

class FeatureButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const FeatureButton({super.key, required this.icon, required this.label, required this.onTap});
  @override Widget build(BuildContext context) => Card(
    child: InkWell(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 30), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center)
    ])),
  );
}

class SosActivePage extends StatefulWidget {
  final String incidentId; final VoidCallback onStopped;
  const SosActivePage({super.key, required this.incidentId, required this.onStopped});
  @override State<SosActivePage> createState() => _SosActivePageState();
}
class _SosActivePageState extends State<SosActivePage> {
  bool stopping = false;
  Future<void> stop() async {
    setState(() => stopping = true);
    await Api.post('/api/sos/${widget.incidentId}/stop', {});
    widget.onStopped();
    if (mounted) Navigator.pop(context);
  }
  @override Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.warning_amber, size: 90, color: Colors.red),
          const Text('SOS ACTIVE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Emergency assistance is active.\nLocation tracking and incident logging are active.', textAlign: TextAlign.center),
          const SizedBox(height: 28),
          FilledButton(onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Are you safe?'),
              content: const Text('Stopping SOS will end the active emergency incident.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                FilledButton(onPressed: () { Navigator.pop(context); stop(); }, child: const Text('YES, STOP SOS'))
              ],
            ),
          ), child: Text(stopping ? 'Stopping...' : 'STOP SOS')),
          const SizedBox(height: 12),
          EmergencyCallButton(label: 'CALL EMERGENCY', number: '112'),
        ]),
      ))),
    ),
  );
}

class EmergencyCallButton extends StatelessWidget {
  final String label; final String number;
  const EmergencyCallButton({super.key, required this.label, required this.number});
  Future<void> call() async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
  @override Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: call, icon: const Icon(Icons.call), label: Text(label));
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});
  @override State<ContactsPage> createState() => _ContactsPageState();
}
class _ContactsPageState extends State<ContactsPage> {
  final contacts = <Map<String,String>>[
    {'name': 'Mother', 'phone': ''},
    {'name': 'Father', 'phone': ''},
  ];
  void add() {
    final n = TextEditingController(); final p = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Add Emergency Contact'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
        TextField(controller: p, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        FilledButton(onPressed: () { setState(() => contacts.add({'name': n.text, 'phone': p.text})); Navigator.pop(context); }, child: const Text('ADD'))],
    ));
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Emergency Contacts'), actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))]),
    body: ListView(children: contacts.map((c) => ListTile(
      leading: const Icon(Icons.person),
      title: Text(c['name']!),
      subtitle: Text(c['phone']!.isEmpty ? 'Phone not set' : c['phone']!),
      trailing: c['phone']!.isEmpty ? null : IconButton(icon: const Icon(Icons.call), onPressed: () async { await launchUrl(Uri.parse('tel:${c['phone']}')); }),
    )).toList()),
    floatingActionButton: FloatingActionButton.extended(onPressed: add, icon: const Icon(Icons.add), label: const Text('Add Contact')),
  );
}

class FakeCallPage extends StatelessWidget {
  const FakeCallPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fake Call')),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
      const SizedBox(height: 12),
      const Text('Dad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const Text('Incoming call'),
      const SizedBox(height: 12),
      const Text('Message: "Where are you? I am waiting outside."', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Fake Call'), content: Text('Simulated incoming call generated.'))), icon: const Icon(Icons.phone), label: const Text('GENERATE FAKE CALL')),
    ]))),
  );
}

class LocationPage extends StatelessWidget {
  final Position? position;
  const LocationPage({super.key, this.position});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Live Location')),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.location_on, size: 80),
      Text(position == null ? 'Location unavailable' : 'Latitude: ${position!.latitude}\nLongitude: ${position!.longitude}', textAlign: TextAlign.center),
      const SizedBox(height: 12),
      const Text('Google Maps integration is configured through the Android API key.'),
    ])),
  );
}

class JourneyPage extends StatefulWidget {
  final String transport;
  const JourneyPage({super.key, required this.transport});
  @override State<JourneyPage> createState() => _JourneyPageState();
}
class _JourneyPageState extends State<JourneyPage> {
  final destination = TextEditingController();
  int minutes = 30;
  String transport = 'WALKING';
  @override void initState() { super.initState(); transport = widget.transport; }
  Future<void> start() async {
    final p = await getPosition();
    try {
      final result = await Api.post('/api/journey/start', {
        'latitude': p?.latitude ?? 0, 'longitude': p?.longitude ?? 0,
        'destination': destination.text, 'transportMode': transport, 'expectedMinutes': minutes
      });
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Journey Started'),
        content: Text('Journey: ${result['journeyId']}\nSafety check-in: every 15 minutes'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Start Safe Journey')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      TextField(controller: destination, decoration: const InputDecoration(labelText: 'Destination', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(value: transport, decoration: const InputDecoration(labelText: 'Transport Mode', border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: 'WALKING', child: Text('Walking')),
          DropdownMenuItem(value: 'CAB', child: Text('Cab / Taxi')),
          DropdownMenuItem(value: 'PUBLIC_TRANSPORT', child: Text('Public Transport')),
          DropdownMenuItem(value: 'OWN_VEHICLE', child: Text('Own Vehicle')),
        ], onChanged: (v) => setState(() => transport = v!)),
      const SizedBox(height: 14),
      Text('Expected duration: $minutes minutes'),
      Slider(min: 10, max: 180, divisions: 17, value: minutes.toDouble(), label: '$minutes', onChanged: (v) => setState(() => minutes = v.round())),
      FilledButton(onPressed: start, child: const Text('START JOURNEY')),
    ]),
  );
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override State<AssistantPage> createState() => _AssistantPageState();
}
class _AssistantPageState extends State<AssistantPage> {
  final q = TextEditingController();
  final messages = <Map<String,String>>[
    {'from':'AI','text':'Hello. Ask me about SOS, emergency contacts, safe travel, stalking, harassment, route deviation, or emergency services.'}
  ];
  String answer(String text) {
    final s = text.toLowerCase();
    if (s.contains('sos')) return 'Press the SOS button on the home screen. Once active, the app creates an incident and can keep the emergency state active until you confirm STOP SOS.';
    if (s.contains('following') || s.contains('stalking')) return 'Move toward a crowded, well-lit public location, avoid confrontation, contact someone you trust, and use SOS/emergency services if you are in immediate danger.';
    if (s.contains('cab') || s.contains('taxi')) return 'For a cab journey, watch route deviation and unexpected stops. Start a Safe Journey and keep your live location available to trusted contacts.';
    if (s.contains('contact')) return 'Open Emergency Contacts from Home and use Add Contact to add family or trusted people.';
    if (s.contains('police') || s.contains('emergency')) return 'Use the Emergency Services page for one-tap calling. In India, 112 is the national emergency number; verify current official numbers before deployment.';
    if (s.contains('harass')) return 'Move to a safe public place, preserve evidence where safe and lawful, notify a trusted contact, and contact emergency/police services if immediate danger exists.';
    if (s.contains('route')) return 'The risk engine considers current GPS, transport mode, time and supplied environmental/route features. A production version should connect verified live datasets for traffic, lighting, incidents and weather.';
    return 'I can help with SOS activation, emergency contacts, safe journeys, route safety, emergency services, harassment/stalking guidance, and app navigation. Please ask a specific safety question.';
  }
  void send() {
    if (q.text.trim().isEmpty) return;
    final text = q.text.trim();
    setState(() { messages.add({'from':'You','text':text}); messages.add({'from':'AI','text':answer(text)}); q.clear(); });
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI Safety Assistant')),
    body: Column(children: [
      Expanded(child: ListView.builder(itemCount: messages.length, itemBuilder: (_, i) {
        final m = messages[i];
        return Align(alignment: m['from']=='You' ? Alignment.centerRight : Alignment.centerLeft,
          child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(m['text']!))));
      })),
      Padding(padding: const EdgeInsets.all(10), child: Row(children: [
        Expanded(child: TextField(controller: q, decoration: const InputDecoration(hintText: 'Ask a safety question...'))),
        IconButton(onPressed: send, icon: const Icon(Icons.send))
      ]))
    ]),
  );
}

class EmergencyServicesPage extends StatelessWidget {
  const EmergencyServicesPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Emergency Services')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Verify official numbers before production deployment.'),
      const SizedBox(height: 12),
      EmergencyCallButton(label: 'National Emergency • 112', number: '112'),
      EmergencyCallButton(label: 'Women Helpline • 181', number: '181'),
      EmergencyCallButton(label: 'Police • 100', number: '100'),
      EmergencyCallButton(label: 'Ambulance • 108', number: '108'),
    ]),
  );
}

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Incident Timeline')),
    body: ListView(children: const [
      ListTile(leading: Icon(Icons.play_arrow), title: Text('SOS activation'), subtitle: Text('Recorded when an SOS incident begins')),
      ListTile(leading: Icon(Icons.location_on), title: Text('GPS history'), subtitle: Text('Location events are associated with the incident')),
      ListTile(leading: Icon(Icons.notifications), title: Text('Notifications'), subtitle: Text('Emergency contact notification events')),
      ListTile(leading: Icon(Icons.stop), title: Text('SOS stopped'), subtitle: Text('Requires explicit safety confirmation')),
    ]),
  );
}

class ProfilePage extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfilePage({super.key, required this.onLogout});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder())),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout), label: const Text('LOGOUT')),
    ]),
  );
}
