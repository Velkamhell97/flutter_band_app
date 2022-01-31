import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_name_app/src/services/sockets_service.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketsService = Provider.of<SocketsService>(context);

    final status = socketsService.serverStatus;
    final socket = socketsService.socket;

    return Scaffold(
      //-Stream Form
      // body: StreamBuilder(
      //   stream: socket.statusStream,
      //   builder: (context, snapshot) {
      //     if(!snapshot.hasData){
      //       return const _StatusRow();
      //     }

      //     return snapshot.data == ServerStatus.online 
      //     ? const _StatusRow(color: Colors.green, text: 'Online')
      //     : const _StatusRow(color: Colors.red, text: 'Offline');
      //   },
      // ),

      //-ProviderForm
      body: Builder(
        builder: (context) {
          if(status == ServerStatus.connecting){
            return const _StatusRow();
          }

          return status == ServerStatus.online 
          ? const _StatusRow(color: Colors.green, text: 'Online')
          : const _StatusRow(color: Colors.red, text: 'Offline');
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          socket.emit('mobile-message', {'name':'Flutter', 'message':'Hello from Mobile'});
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final Color color;
  final String text;

  const _StatusRow({Key? key, this.color = Colors.grey, this.text = 'Connecting...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle
            ),
          ),
          const SizedBox(width: 10),
          Text('Server status: $text', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}