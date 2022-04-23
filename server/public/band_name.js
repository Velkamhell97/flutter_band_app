const socket = io();

/// Cuando el cliente se conecta al servdior emite el evento connect
socket.on('connect', () => {
  console.log('Server Connected (From Client)');
})

/// Los emits de los clientes si van unicamente al servidor y no a otros clientes (por defecto)
/// probablemente no se dispare aqui por que el socket no se ha conectado, lo ideal seria disprarlo
/// dentro del on connect
socket.emit('message', {client: 'Daniel'});

/// Este mensaje se escucha unicamente si se utiliza el metodo correcto en el server
/// client.emit: escucha unicamente el cliente conectado en ese momento no los demas
/// client.broadcast.emit: escuchan todos los clientes menos el conectado
/// server.emit: escucha todos los clientes y el conectado
/// cuando se habla del conectado es actual que se conecta o envia un emit
socket.on('message', (payload) => {
  console.log('Message From Server %O', payload);
})

/// Imprime los resultados de la tabla
socket.on('get-bands', (payload) => {
  console.clear();
  console.table(payload);
})

/// Cuando se cae el servidor, se emite el evento al cliente
socket.on('disconnect', () => {
  console.log('Server Disconnect (From Client)');
})
