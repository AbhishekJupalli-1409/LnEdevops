var express = require('express'),
    async = require('async'),
    mysql = require('mysql2'),
    path = require('path'),
    cookieParser = require('cookie-parser'),
    app = express(),
    server = require('http').Server(app),
    io = require('socket.io')(server);

var port = process.env.PORT || 80;

io.on('connection', function (socket) {
  socket.emit('message', { text : 'Welcome!' });

  socket.on('subscribe', function (data) {
    socket.join(data.channel);
  });
});

var pool = mysql.createPool({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE || 'voting',
  ssl: { rejectUnauthorized: true },
  waitForConnections: true,
  connectionLimit: 4
});

async.retry(
  {times: 1000, interval: 1000},
  function(callback) {
    pool.getConnection(function(err, client) {
      if (err) {
        console.error("Waiting for db");
      }
      callback(err, client);
    });
  },
  function(err, client) {
    if (err) {
      return console.error("Giving up");
    }
    console.log("Connected to db");
    getVotes(client);
  }
);

function getVotes(client) {
  client.query('SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote', [], function(err, rows) {
    if (err) {
      console.error("Error performing query: " + err);
    } else {
      var votes = collectVotesFromResult(rows);
      io.sockets.emit("scores", JSON.stringify(votes));
    }

    setTimeout(function() { getVotes(client); }, 1000);
  });
}

function collectVotesFromResult(rows) {
  var votes = {a: 0, b: 0};

  rows.forEach(function (row) {
    votes[row.vote] = parseInt(row.count);
  });

  return votes;
}

app.use(cookieParser());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(__dirname + '/views'));

app.get('/', function (req, res) {
  res.sendFile(path.resolve(__dirname + '/views/index.html'));
});

server.listen(port, function () {
  var listenPort = server.address().port;
  console.log('App running on port ' + listenPort);
});
