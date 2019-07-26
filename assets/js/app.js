// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

var channel = socket.channel('room:lobby', {}); // connect to "room"

// listen to the 'shout' event
channel.on('shout', function (payload) {
  var li = document.createElement("li");
  var name = payload.name || 'Anonymous';
  var message = payload.message || ' retweeted';
  if(payload.isRe){
    li.setAttribute('data-name', payload.reName);
    li.setAttribute('data-message', payload.reMessage);
    li.innerHTML = '<b>' + name + '</b>: ' + message +
                   "<div><div class='quote'> (Quote)" +
                   '<b>' + payload.reName + '</b>: ' + payload.reMessage +
                   "</div></div>";
  }
  else {
    li.setAttribute('data-name', name);
    li.setAttribute('data-message', message);
    li.innerHTML = '<b>' + name + '</b>: ' + message;
  }
  li.addEventListener('click', function (event) {
    if(forcusLi != this) {
     forcusLi = this;
     $("ul li.actived").removeClass("actived");
     $(forcusLi).addClass("actived");
   }
   else {
     $("ul li.actived").removeClass("actived");
     forcusLi = undefined;
   }
  });
  if($(ul).children().length == 10) {
    $(ul).children().last().remove();
  }
  ul.prepend(li);
  console.log($(ul));
});

channel.join(); // join the channel.

var forcusLi = undefined;
var ul = document.getElementById('msg-list');
var name = document.getElementById('name');
var msg = document.getElementById('msg');

// "listen" for the [Enter] keypress event to send a message:
msg.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && msg.value.length < 140) {
    if(forcusLi == undefined && msg.value.length > 0) {
      channel.push('shout', {
        name: name.value,
        message: msg.value,
        isRe: false
      });
    }
    else {
      channel.push('shout', {
        name: name.value,
        message: msg.value,
        isRe: true,
        reMessage: forcusLi.getAttribute('data-message'),
        reName: forcusLi.getAttribute('data-name')
      });
    }
    console.log(forcusLi);
    msg.value = '';
  }
});

$(".remove-retweet button").on('click', function (event) {
  console.log(event);
  $("ul li.actived").removeClass("actived");
  forcusLi = undefined;
});
