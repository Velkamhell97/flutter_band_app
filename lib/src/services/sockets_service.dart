// ignore_for_file: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

import '../models/environment.dart';

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketsService {
  late final IO.Socket socket;
  final socketUrl = Environment.socketUrl;

  /// Pasa las funciones.
  Function get emit => socket.emit;
  Function get on => socket.on;
  Function get off => socket.off;

  /// Por si se necesita el valor de la variable en un momento, con esto evitamos sacarla del Stream
  ServerStatus serverStatus = ServerStatus.connecting;

  SocketsService() {
    _sockets();
  }

  final _serverStatusStreamController = StreamController<ServerStatus>();
  Stream<ServerStatus> get servertStatusStream => _serverStatusStreamController.stream;

  void _sockets(){
    /// No funciona si se coloca el localhost, se debe usar el ip del pc o el localhost del emulador
    // socket = IO.io('https://flutter-bands-app.herokuapp.com/', 
    socket = IO.io(socketUrl,
      IO.OptionBuilder()
      .setTransports(['websocket']) 
      // .disableAutoConnect() /// El autoconnect esta en true por defecto
      .build()
    );

    /// socket.connect(); --> Si se usa el autoConnect en false

    socket.onConnect((data) {
      print('Server Connected (From Mobile)');
      serverStatus = ServerStatus.online;
      _serverStatusStreamController.add(ServerStatus.online);
    });

    socket.onDisconnect((data) {
      print('Server Disconnected (From Mobile)');
      serverStatus = ServerStatus.offline;
      _serverStatusStreamController.add(ServerStatus.offline);
    });

    /// Este mensaje se escucha unicamente si se utiliza el metodo correcto en el server
    /// client.emit: escucha unicamente el cliente conectado en ese momento no los demas
    /// client.broadcast.emit: escuchan todos los clientes menos el conectado
    /// server.emit: escucha todos los clientes y el conectado
    /// cuando se habla del conectado es actual que se conecta o envia un emit
    socket.on('message', (payload) {
      /// Si el payload no tiene una propiedad viene null ej: ${payload['message']}
      print('Message From Server Emtted By Client: $payload');
    });

    /// Para dejar de escuchar un evento en especifico
    // socket.off('mobile-message');
  }
}