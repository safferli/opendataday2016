var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var columns = ["streets"];
require("csv-to-array")({
	   file: "ffm-streetnames.csv",
	   columns: columns
}, function (err, array) {
	  console.log(err || array);
          var csvarray = array;

//var csvarray = [{ streets: 'Zum Gottschalkhof' }, { streets: 'Zum Heidebuckel' },{ streets: 'Zum Laurenburger Hof' },{ streets: 'Zum Pfarrturm' },{ streets: 'Zum Schäferköppel' }]

app.get('/', function(req, res){
	  res.sendFile(__dirname + '/index.html');
});

function generateGoogleLink(location) {
	return "https://maps.googleapis.com/maps/api/streetview?size=1200x1200&location=" + location + "&fov=90&pitch=5&key=AIzaSyCip6t4-QiECAb8KT0c5B-H7FoYopF_dAc" 
}

io.on('connection', function(socket) {
	console.log('a user connected');
	address = csvarray[Math.floor(Math.random() * 200)]["streets"] + ",FrankfurtamMain";
	io.emit("newpic", generateGoogleLink(address));
	socket.on("kp", function(keyCode) {
		address = csvarray[Math.floor(Math.random() * 2000)]["streets"] + ",FrankfurtamMain";
	  	console.log(address);
		console.log(keyCode);
	  	io.emit("newpic", generateGoogleLink(address));
	  });
});

http.listen(3000, function(){
	  console.log('listening on *:3000');
});

});
