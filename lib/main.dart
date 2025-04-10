// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure VPN By Afaq Ahmad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.deepPurple),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/servers': (context) => ServerListScreen(),
        '/settings': (context) => SettingsScreen(),
        '/custom-server': (context) => CustomServerScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 100, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text('Secure VPN By Afaq Ahmad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  String selectedServer = 'Auto (Fastest)';
  double uploadSpeed = 0.0;
  double downloadSpeed = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secure VPN'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isConnected 
                          ? [Colors.greenAccent, Colors.green]
                          : [Colors.redAccent, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isConnected ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isConnected ? Icons.lock : Icons.lock_open,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 500.ms),
                SizedBox(height: 30),
                Text(
                  isConnected ? 'SECURE CONNECTION' : 'NOT CONNECTED',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  selectedServer,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpeedWidget(icon: Icons.arrow_upward, speed: uploadSpeed),
                    SizedBox(width: 30),
                    SpeedWidget(icon: Icons.arrow_downward, speed: downloadSpeed),
                  ],
                ),
              ],
            ),
          ),
          ConnectButton(
            isConnected: isConnected,
            onPressed: () {
              setState(() {
                isConnected = !isConnected;
                if (isConnected) {
                  _startSpeedTest();
                } else {
                  _stopSpeedTest();
                }
              });
            },
          ),
          SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/servers'),
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.public),
      ),
    );
  }

  void _startSpeedTest() {
    uploadSpeed = 0.0;
    downloadSpeed = 0.0;
    const duration = Duration(milliseconds: 100);
    const maxSpeed = 50.0;
    
    Future.doWhile(() async {
      if (!isConnected) return false;
      await Future.delayed(duration);
      setState(() {
        uploadSpeed = (uploadSpeed + 0.5) % maxSpeed;
        downloadSpeed = (downloadSpeed + 0.7) % maxSpeed;
      });
      return isConnected;
    });
  }

  void _stopSpeedTest() {
    setState(() {
      uploadSpeed = 0.0;
      downloadSpeed = 0.0;
    });
  }
}

class SpeedWidget extends StatelessWidget {
  final IconData icon;
  final double speed;

  const SpeedWidget({super.key, required this.icon, required this.speed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.deepPurple),
        SizedBox(height: 5),
        Text('${speed.toStringAsFixed(1)} Mbps', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class ConnectButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onPressed;

  const ConnectButton({super.key, required this.isConnected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: isConnected 
                ? [Colors.redAccent, Colors.red]
                : [Colors.greenAccent, Colors.green],
          ),
          boxShadow: [
            BoxShadow(
              color: isConnected ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Center(
          child: Text(
            isConnected ? 'DISCONNECT' : 'CONNECT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class ServerListScreen extends StatefulWidget {
  const ServerListScreen({super.key});

  @override
  _ServerListScreenState createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen> {
  final List<Server> servers = [
    Server(name: 'Auto (Fastest)', country: 'Auto', flag: '🌐'),
    Server(name: 'United States', country: 'US', flag: '🇺🇸', ping: 45),
    Server(name: 'United Kingdom', country: 'UK', flag: '🇬🇧', ping: 62),
    Server(name: 'Germany', country: 'DE', flag: '🇩🇪', ping: 58),
    Server(name: 'Japan', country: 'JP', flag: '🇯🇵', ping: 112),
    Server(name: 'Singapore', country: 'SG', flag: '🇸🇬', ping: 89),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Server'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: servers.length,
        itemBuilder: (context, index) {
          final server = servers[index];
          return ListTile(
            leading: Text(server.flag, style: TextStyle(fontSize: 24)),
            title: Text(server.name),
            subtitle: server.ping != null ? Text('Ping: ${server.ping}ms') : null,
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context, server);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/custom-server'),
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Server {
  final String name;
  final String country;
  final String flag;
  final int? ping;

  Server({required this.name, required this.country, required this.flag, this.ping});
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool killSwitchEnabled = true;
  bool autoConnectEnabled = false;
  String selectedProtocol = 'WireGuard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('VPN Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(),
          SwitchListTile(
            title: Text('Kill Switch'),
            subtitle: Text('Block internet if VPN disconnects'),
            value: killSwitchEnabled,
            onChanged: (value) => setState(() => killSwitchEnabled = value),
          ),
          SwitchListTile(
            title: Text('Auto Connect'),
            subtitle: Text('Connect automatically on startup'),
            value: autoConnectEnabled,
            onChanged: (value) => setState(() => autoConnectEnabled = value),
          ),
          ListTile(
            title: Text('Protocol'),
            subtitle: Text(selectedProtocol),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Select Protocol'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        title: Text('WireGuard'),
                        value: 'WireGuard',
                        groupValue: selectedProtocol,
                        onChanged: (value) {
                          setState(() => selectedProtocol = value.toString());
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile(
                        title: Text('L2TP-PSK'),
                        value: 'L2TP-PSK',
                        groupValue: selectedProtocol,
                        onChanged: (value) {
                          setState(() => selectedProtocol = value.toString());
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(),
          ListTile(
            title: Text('Theme'),
            subtitle: Text('System default'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class CustomServerScreen extends StatefulWidget {
  const CustomServerScreen({super.key});

  @override
  _CustomServerScreenState createState() => _CustomServerScreenState();
}

class _CustomServerScreenState extends State<CustomServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pskController = TextEditingController();
  String _selectedProtocol = 'WireGuard';

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Custom Server'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _selectedProtocol,
                items: ['WireGuard', 'L2TP-PSK'].map((protocol) {
                  return DropdownMenuItem(
                    value: protocol,
                    child: Text(protocol),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProtocol = value.toString());
                },
                decoration: InputDecoration(
                  labelText: 'Protocol',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _serverController,
                decoration: InputDecoration(
                  labelText: 'Server Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter server address';
                  }
                  return null;
                },
              ),
              if (_selectedProtocol == 'L2TP-PSK') ...[
                SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              SizedBox(height: 16),
              TextFormField(
                controller: _pskController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _selectedProtocol == 'WireGuard' ? 'Private Key' : 'Pre-Shared Key',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newServer = Server(
                      name: 'Custom Server',
                      country: 'Custom',
                      flag: '⚙️',
                    );
                    Navigator.pop(context, newServer);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Save Server'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}