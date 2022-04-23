import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/band.dart';
import '../services/sockets_service.dart';
import '../providers/bands_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SocketsService socket;
  
  @override
  void initState() {
    super.initState();

    socket = Provider.of<SocketsService>(context, listen: false);
    final bands = Provider.of<BandsProvider>(context, listen: false);

    /// Alcanca a redibujarse el widget antes de que se conecte al socket, si fuera muy rapido se deberia
    /// usar en el postFrame
    socket.on('get-bands', (payload) {
      final data = List<Band>.from(payload.map((band) => Band.fromSocket(band)));
      bands.update(data);
    });
  }

  @override
  void dispose() {
    socket.off('get-bands');
    super.dispose();
  }

  void _addBand() async {
    final bandName = await showDialog<String?>(context: context, builder: (_) => const _Dialog());

    if(bandName != null && bandName.length > 1){
      socket.emit('add-band', bandName);
    }
  }

  void _addVote(String id){
    socket.emit('vote-band', id);
  }

  void _deleteBand(String id){
    socket.emit('delete-band', id);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text('Band Name',style: TextStyle(color: Colors.black),),
        actions: [
          StreamBuilder<ServerStatus>(
            initialData: ServerStatus.connecting,
            stream: socket.servertStatusStream,
            builder: (_, status) {
              final Icon icon = status.data! != ServerStatus.online 
              ? Icon(Icons.offline_bolt, color: Colors.red[300])
              : Icon(Icons.check_circle, color: Colors.blue[300]);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: icon,
              );
            },
          )
        ],
      ),

      backgroundColor: Colors.white,

      body: Consumer<BandsProvider>(
        builder: (_, bandsProvider, __) {
          if(bandsProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final bands = bandsProvider.bands;

          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: size.height * 0.2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: _BandGraph(bands: bandsProvider.bandsMap,),
                )
              ),
              Expanded(
                child: ListView.builder( 
                  itemCount: bands.length,
                  itemBuilder: (_, index) {
                    final band = bands[index];

                    return Dismissible(
                      onDismissed: (_) => _deleteBand(band.id),
                      key: ValueKey(band.id),
                      background: Container(color: Colors.redAccent),
                      child: _BandTile(band: band, onTap: _addVote)
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addBand,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BandGraph extends StatelessWidget {
  final Map<String, double> bands;

  const _BandGraph({Key? key, required this.bands}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: bands,
      chartType: ChartType.ring,
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        // decimalPlaces: 0
      ),
    );
  }
}

class _BandTile extends StatelessWidget {
  final Band band;
  final Function(String) onTap;

  const _BandTile({Key? key, required this.band, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(band.id),
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
    /// Como el input se actualiza solo no necesitamos ningun setState
    String text = '';

    return AlertDialog(
      title: const Text('Add new band'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Band Name: '),
          /// Se puede agregar valiadcion para que no sea vacio
          TextField(
            autofocus: true,
            onChanged: (value) => text = value
          ),
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