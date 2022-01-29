import 'package:band_name_app/src/models/band.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List <Band> _bands = [...Band.bands];

  void _addNewBand() async {
    final bandName = await showDialog<String?>(
      context: context, 
      builder: (_) => const _Dialog(),
    );

    if(bandName != null){
      setState(() => _bands.add(Band(id: "${_bands.length}", name: bandName)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text('Band Name',style: TextStyle(color: Colors.black),),
        actions: [],
      ),

      body: ListView.builder(
        itemCount: _bands.length,
        itemBuilder: (_, index) {
          final band = _bands[index];

          return Dismissible(
            onDismissed: (_) => setState(() => _bands.removeAt(index)),
            key: ValueKey(band.id),
            background: Container(color: Colors.redAccent),
            child: _BandTile(band: band)
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BandTile extends StatelessWidget {
  final Band band;

  const _BandTile({Key? key, required this.band}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(band.name.characters.first.toUpperCase())),
      title: Text(band.name),
      trailing: Text('${band.votes}'),
    );
  }
}

class _Dialog extends StatelessWidget {

  const _Dialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = '';

    return AlertDialog(
      title: const Text('Add new band'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Band Name: '),
          TextField(onChanged: (value) => text = value),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Cancel', style: TextStyle(color: Colors.redAccent))
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(text), 
          child: const Text('Add')
        )
      ],
    );
  }
}