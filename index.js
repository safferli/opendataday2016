var express = require('express');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var pg = require('pg');
var path = require("path");

app.use(express.static(path.join(__dirname, 'public')));

var conn = process.env.DATABASE_URL || 'ubuntu://localhost:5432/frankfurt?ssl=true';

var client = new pg.Client(conn);
client.connect();

client.query("SELECT * from addresslist", function(err, addressfull) {

var address = addressfull["rows"];

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

function createquery(id, text, swipe, district) {
	s = swipe == 83;
	return "insert into swipes values('" + id + "','" + text + "'," + s + ",'" + district+"')";
}

len = address.length;
//console.log(len);


function getrow(address, len) {
	result =  address[Math.floor(Math.random() * len)];
	console.log(result["district"]);
	return result;
}

function getAddress(singlerow) {
	//console.log(address);
	result = singlerow["address"]  +  ", FrankfurtamMain";
	//console.log(result);
	return result;
}

io.on('connection', function(socket) {
	console.log('a user connected');
	singlerow = getrow(address, len);
        socket.id = generateHexString(24);
	singleaddress = getAddress(singlerow);
	socket.emit("newpic", generateGoogleLink(singleaddress));
	socket.on("kp", function(keyCode) {
		if(keyCode == 65 | keyCode == 83) { 
		  singlerow = getrow(address, len);
		  singleaddress = getAddress(singlerow);
	  	  console.log(singlerow);
		  var query = client.query(createquery(socket.id, singlerow["address"], keyCode, singlerow["district"]));
	  	  socket.emit("newpic", generateGoogleLink(singleaddress));
		};
	  });
});

http.listen(3000, function(){
	  console.log('listening on *:3000');
});

}); 
