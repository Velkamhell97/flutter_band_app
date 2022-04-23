const { Socket, Server } = require('socket.io');
const Band = require('../models/band');

const Bands = require('../models/bands');

/// La bandas se crearan siempre que se modifiquen archivos del backend, que idealmente esto no ocurre
/// por eso se podria decir que esto es una medio persistencia, tambien se podria trabajar con un archivo json
const bands = new Bands();

/// Cuando un cliente (puede ser una pagina o un telefono) se conecta al server se pasa por este metodo
const socketController = async (client = new Socket(), server = new Server()) => {
  console.log('Client Connected (From Server)');

  /// Una vez se conecta el usuario emite la lista de bandas disponible perso unicamente al cliente que se conecta
  /// los otros clientes no necesitan esto ya que es para el loading de cada cliente
  client.emit('get-bands', bands.getBands())

  client.on('add-band', (name) => {
    bands.addBand(new Band(name));
    server.emit('get-bands', bands.getBands())
  })

  client.on('vote-band', (id) => {
    bands.voteBand(id);
    server.emit('get-bands', bands.getBands())
  })

  client.on('delete-band', (id) => {
    bands.deleteBand(id);
    server.emit('get-bands', bands.getBands())
  })

  /// Cuando un cliente se desconecta, ya sea reiniciando el navegador o saliendo de la pagina se dispara este evento
  client.on('disconnect', () => {
    console.log('Client Disconnected (From Server)');
  })

  client.on('message', (payload) => {
    /// Para ver formateado el objeto utilizamos el %O
    console.log(`Message From Client %O`, payload);

    /// Envia solo al emisor pero no a los demas (automensaje)
    // client.emit('message', payload);

    /// Envia a los demas excepto al emisor
    // client.broadcast.emit('message', payload);

    /// Envia a todos y al emisor
    server.emit('message', payload);
  })
}

module.exports = {
  socketController
}