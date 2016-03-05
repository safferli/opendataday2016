var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var pg = require('pg');

var conn = process.env.DATABASE_URL || 'ubuntu://localhost:5432/frankfurt?ssl=true';

var client = new pg.Client(conn);
client.connect();

var columns = ["streets"];
require("csv-to-array")({
	   file: "ffm-streetnames.csv",
	   columns: columns
}, function (err, array) {
	  console.log(err || array);
          var csvarray = array;
	  var len = csvarray.length;

//var csvarray = [{ streets: 'Zum Gottschalkhof' }, { streets: 'Zum Heidebuckel' },{ streets: 'Zum Laurenburger Hof' },{ streets: 'Zum Pfarrturm' },{ streets: 'Zum Schäferköppel' }]

app.get('/', function(req, res){
	  res.sendFile(__dirname + '/index.html');
});

function generateGoogleLink(location) {
	return "https://maps.googleapis.com/maps/api/streetview?size=1200x1200&location=" + location + "&fov=90&pitch=5&key=AIzaSyCip6t4-QiECAb8KT0c5B-H7FoYopF_dAc" 
}

function generateHexString(length) {
	  var ret = "";
	    while (ret.length < length) {
		        ret += Math.random().toString(16).substring(2);
			  }
	      return ret.substring(0,length);
}

function createquery(id, text, swipe) {
	s = swipe == 83;
	return "insert into swipes values('" + id + "','" + text + "'," + s + ")";
}

io.on('connection', function(socket) {
	console.log('a user connected');
        socket.id = generateHexString(24);
	console.log(socket.id)
	address = csvarray[Math.floor(Math.random() * len)]["streets"] + ",FrankfurtamMain";
	socket.emit("newpic", generateGoogleLink(address));
	socket.on("kp", function(keyCode) {
		if(keyCode == 65 | keyCode == 83) { 
		  address = csvarray[Math.floor(Math.random() * len)]["streets"] + ",FrankfurtamMain";
	  	  console.log(address, keyCode, socket.id);
		  var query = client.query(createquery(socket.id, address, keyCode));
	  	  socket.emit("newpic", generateGoogleLink(address));
		};
	  });
});

http.listen(3000, function(){
	  console.log('listening on *:3000');
});

});
