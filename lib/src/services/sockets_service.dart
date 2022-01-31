import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketsService extends ChangeNotifier {
  late final IO.Socket socket;

  //-Si se deseara pasar la funcion sin poner el socket.
  // Function get emit => socket.emit;

  ServerStatus _serverStatus = ServerStatus.connecting;

  ServerStatus get serverStatus => _serverStatus;

  set serverStatus(ServerStatus serverStatus) {
    _serverStatus = serverStatus;
    notifyListeners();
  }

  SocketsService() {
    _sockets();
  }

  final _statusStreamController = StreamController<ServerStatus>();

  Stream<ServerStatus> get statusStream => _statusStreamController.stream;

  void _sockets(){
    //-No funciona si se coloca el localhost, se debe usar el ip del pc o el localhost del emulador
    socket = IO.io('http://10.0.2.2:8080', 
      IO.OptionBuilder()
      .setTransports(['websocket']) 
      // .disableAutoConnect() //El autoconnect esta en true por defecto
      .build()
      // {
      //   'transports' : ['websocket'],
      //   'autoConnect': true
      // }
    );

    // socket.connect(); --> Si se usa el autoConnect en false

    socket.onConnect((data) {
      print('Server Connected (From Mobile)');

      //-NotifyListener, se redibuja las instancias que escuchen este notifier, se puede optimizar con el selector
      //-se tiene actualizada una referencia del estado en una variable y se utiliza mas facil en los widgets (sin streamBuilder)
      serverStatus = ServerStatus.online;

      //-Metodos con streams, se redibuja solo el streamBuilder, ademas de las ventajas de usar stream (metodos)
      //-no se necesita tener una referencia de la variable, pero se utiliza en muchos lados el streamBuilder
      _statusStreamController.add(ServerStatus.online);
    });

    socket.onDisconnect((data) {
      print('Server Disconnected (From Mobile)');

      serverStatus = ServerStatus.offline;

      _statusStreamController.add(ServerStatus.offline);
    });

     socket.on('message', (payload) {
      //-Si el payload no tiene una propiedad viene null
      // print('Message From Server: ${payload['message']} ');

      print('Message From Server Emtted By Client: $payload');
    });

    //-Si en el server emito este mensaje con el client.broadcast, no se ejecutara este codigo, 
    //-si el mismo cliente (osea este dispositivo) fue el que emitio un evento llamado igual
    socket.on('mobile-message', (payload) {
      //-Si el payload no tiene una propiedad viene null
      // print('Message From Server: ${payload['message']} ');

      print('Message From Server: $payload');
    });

    //-Para dejar de escuchar un evento en especifico
    // socket.off('mobile-message');
  }

}