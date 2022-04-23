const express = require('express');
const cors = require('cors');

const { socketController } = require('../sockets/controller');

class Server {

  constructor () {
    this.app = express();
    this.port = process.env.PORT;

    this.server = require('http').createServer(this.app);
    this.io = require('socket.io')(this.server);

    this.middlewares();

    this.sockets();
  }

  middlewares() {
    /// Para los middlewares seguimos usando el app
    this.app.use(cors());

    this.app.use(express.json());

    this.app.use(express.static('public'))
  }

  sockets() {
    /// Controllador para cuando los clientes se conecten al servidor
    this.io.on('connection', (stream) => socketController(stream, this.io))
  }

  listen() {
    /// Para el listen usamos el server
    this.server.listen(this.port, () => {
      console.log(`Server app listening at ${this.port}`);
    })
  }
}

module.exports = Server;