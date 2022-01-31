import 'package:band_name_app/src/models/band.dart';
import 'package:band_name_app/src/services/sockets_service.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //-Bandas agregadas manualmente
  
  // final List <Band> _bands = [...Band.bands];

  // void _addNewBand() async {
  //   final bandName = await showDialog<String?>(
  //     context: context, 
  //     builder: (_) => const _Dialog(),
  //   );

  //   if(bandName != null){
  //     setState(() => _bands.add(Band(id: "${_bands.length}", name: bandName)));
  //   }
  // }

  //-Bandas por Sockets
  List<Band> _bands = [];

  //-Podemos empezar a escuchar eventos desde un init state, no se deben declarar todos en el constructor
  //-del provider
  @override
  void initState() {
    super.initState();

    final socketsServices = Provider.of<SocketsService>(context, listen: false);

    //-Esto ya es como una subscripcion, siempre que se emita el evento get-bands, se va a ejecutar este codigo
    //-reeemplazando la lista por completo
    socketsServices.socket.on('get-bands', (payload) {
      setState(() {
        _bands = List<Band>.from(payload.map((band) => Band.fromSocket(band)));
      });
    });
  }

  @override
  void dispose() {
    final socketsServices = Provider.of<SocketsService>(context, listen: false);
    
    socketsServices.socket.off('get-bands');

    super.dispose();
  }

   void _addBand() async {
    final bandName = await showDialog<String?>(
      context: context, 
      builder: (_) => const _Dialog(),
    );

    if(bandName != null && bandName.length > 1){
      final socketsServices = Provider.of<SocketsService>(context, listen: false);

      socketsServices.socket.emit('add-band', bandName);
    }
  }

  void _addVote(String id){
    final socketsServices = Provider.of<SocketsService>(context, listen: false);

    socketsServices.socket.emit('vote-band', id);
  }

  void _deleteBand(String id){
    final socketsServices = Provider.of<SocketsService>(context, listen: false);

    socketsServices.socket.emit('delete-band', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text('Band Name',style: TextStyle(color: Colors.black),),
        actions: [
          Selector<SocketsService, ServerStatus>(
            selector: (_, model) => model.serverStatus,
            builder: (_, status, __) {
              final Icon icon = status != ServerStatus.online 
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

      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _BandGraph(
              data: <String, double>{for (Band band in _bands) band.name: band.votes.toDouble()},
            ),
          ),
          Expanded(
            child: ListView.builder( 
              itemCount: _bands.length,
              itemBuilder: (_, index) {
                final band = _bands[index];
          
                return Dismissible(
                  // onDismissed: (_) => setState(() => _bands.removeAt(index)),
                  onDismissed: (_) => _deleteBand(band.id),
                  key: ValueKey(band.id),
                  background: Container(color: Colors.redAccent),
                  child: _BandTile(band: band, onTap: _addVote)
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addBand,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BandGraph extends StatelessWidget {
  final Map<String, double> data;

  const _BandGraph({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(data.isEmpty){
      return const Center(child: CircularProgressIndicator());
    }

    return PieChart(
      dataMap: data,
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
    String text = '';

    return AlertDialog(
      title: const Text('Add new band'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Band Name: '),
          //-Se puede agregar valiadcion para que no sea vacio
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