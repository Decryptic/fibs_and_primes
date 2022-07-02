import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const FibsAndPrimes());

class FibsAndPrimes extends StatelessWidget {
  const FibsAndPrimes({Key? key}) : super(key: key);
  
  static const String _title = 'Fibs and Primes';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MainActivity(title: _title),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainActivity extends StatefulWidget {
  const MainActivity({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {

  bool _fibs = true;
  List<BigInt> _sequence = [];
  ScrollController _listViewController = ScrollController();
  Key _listViewKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fibs ? 'Fibs' : 'Primes'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleSetting,
            itemBuilder: (BuildContext ctx) {
              return {'Fibonacci', 'Primes'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _buildList(),
    );
  }
  
  void _handleSetting(String setting) {
    switch (setting) {
      case 'Fibonacci':
        if (!_fibs) {
          _resetList();
          setState(() {
              _fibs = true;
            }
          );
        }
        break;
      case 'Primes':
        if(_fibs) {
          _resetList();
          setState(() {
              _fibs = false;
            }
          );
        }
        break;
    }
  }
  
  void _resetList() {
    if (_listViewController.hasClients)
      _listViewController.jumpTo(_listViewController.position.minScrollExtent);
    _listViewKey = UniqueKey();
    _sequence = [];
  }
  
  Widget _buildList() {
    return ListView.builder(
      itemBuilder: (context, i) {
        if (i >= _sequence.length) {
          _extend();
        }
        return _buildRow(i, _sequence[i], context);
      },
      controller: _listViewController,
      key: _listViewKey,
    );
  }
  
  Widget _buildRow(int i, BigInt e, BuildContext context) {
    return ListTile(
      title: Text(
        '$e',
      ),
      subtitle: Text(
        '${i+1}',
      ),
      onLongPress: () => Clipboard.setData(ClipboardData(text: '$e')).then((_) =>
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'copied to clipboard',
            ),
          )
        )
      )
    );
  }
  
  void _extend() {
    if (_fibs) {
      if (_sequence.isEmpty)
        _sequence = [BigInt.from(0), BigInt.from(1)];
      for (int i = 0; i < 10; i++) {
        int l = _sequence.length;
        _sequence.add(_sequence[l-1] + _sequence[l-2]);
      }
    }
    else {
      if (_sequence.isEmpty)
        _sequence = [BigInt.from(2)];
      for (int i = 0; i < 10; i++) {
        BigInt next = _sequence.last;
        do {
          next += BigInt.from(1);
        } while (!isPrime(next));
        _sequence.add(next);
      }
    }
  }
  
  bool isPrime(BigInt t) {
    //for (var i = BigInt.from(2); i <= t ~/ BigInt.from(2); i += BigInt.from(1)) {
    for (BigInt i in _sequence) {
      if (t % i == BigInt.from(0))
        return false;
    }
    return true;
  }
}
