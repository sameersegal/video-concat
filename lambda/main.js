'use strict'

exports.handler = function(event, context, callback) {
    console.log('Received event:');
    console.log(JSON.stringify(event, null, '  '));

    var response = {
        statusCode: 200,
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
        },
        body: JSON.stringify(event, null, '  '),
      }
    callback(null, response)
};