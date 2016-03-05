var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
	  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
	  console.log('a user connected');
	  io.emit("newpic", "https://maps.googleapis.com/maps/api/streetview?size=1200x1200&location=40.720032,-73.988354&fov=90&heading=235&pitch=10&key=AIzaSyCip6t4-QiECAb8KT0c5B-H7FoYopF_dAc")
});

http.listen(3000, function(){
	  console.log('listening on *:3000');
});
