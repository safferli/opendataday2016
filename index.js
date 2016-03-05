var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
	  res.sendFile(__dirname + '/index.html');
});

function generateGoogleLink(long, lat) {
	return "https://maps.googleapis.com/maps/api/streetview?size=1200x1200&location=" + long + "," + lat + "&fov=90&heading=235&pitch=10&key=AIzaSyCip6t4-QiECAb8KT0c5B-H7FoYopF_dAc" 
}

io.on('connection', function(socket){
	  console.log('a user connected');
	  io.emit("newpic", generateGoogleLink(40.720032,-73.988354))
});

http.listen(3000, function(){
	  console.log('listening on *:3000');
});
