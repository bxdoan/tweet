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

channel.on('shout', function (payload) { // listen to the 'shout' event
  var li = document.createElement("li"); // create new list item DOM element
  var name = payload.name || 'Anonymous';    // get name from payload or set default
  if(payload.isRe){
    li.innerHTML = '<b>' + name + '</b>: ' +
                   "<div><div class='quote'>" +
                   payload.reMessage +
                   "</div><div>" +
                   payload.message
                   + "</div></div>";
  }
  else {
    li.innerHTML = '<b>' + name + '</b>: ' + payload.message;
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
  ul.prepend(li);                 // append to list
  console.log($(ul));
});

channel.join(); // join the channel.

var forcusLi = undefined;
var ul = document.getElementById('msg-list');        // list of messages.
var name = document.getElementById('name');          // name of message sender
var msg = document.getElementById('msg');            // message input field

// "listen" for the [Enter] keypress event to send a message:
msg.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && msg.value.length > 0 && msg.value.length < 140) { // don't sent empty msg and less than 140 characters
    if(forcusLi == undefined) {
      channel.push('shout', { // send the message to the server
        name: name.value,     // get value of "name" of person sending the message
        message: msg.value,    // get message text (value) from msg input field.
        isRe: false
      });
    }
    else {
      channel.push('shout', { // send the message to the server
        name: name.value,     // get value of "name" of person sending the message
        message: msg.value,    // get message text (value) from msg input field.
        isRe: true,
        reMessage: forcusLi.innerHTML
      });
    }
    msg.value = '';         // reset the message input field for next message.
  }
});

$(".remove-retweet button").on('click', function (event) {
  console.log(event);
  $("ul li.actived").removeClass("actived");
  forcusLi = undefined;
});
