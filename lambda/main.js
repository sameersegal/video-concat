'use strict'

var async = require('async');
var aws = require('aws-sdk');
var sqs = new aws.SQS({apiVersion: '2012-11-05'});
var ecs = new aws.ECS({apiVersion: '2014-11-13'});

exports.handler = function(event, context, callback) {
    console.log('Received event:');
    console.log(JSON.stringify(event, null, '  '));

    var inputs = JSON.parse(event.body);
    let QUEUE_URL = process.env.QUEUE_URL
    let CLUSTER_NAME = process.env.CLUSTER_NAME
    let TASK_NAME = process.env.TASK_NAME
    let SUBNET = process.env.SUBNET
    let SECURITY_GROUP = process.env.SECURITY_GROUP


    async.waterfall([
          function (next) {
              var params = {
                  MessageBody: JSON.stringify(inputs),
                  QueueUrl: QUEUE_URL
              };
              sqs.sendMessage(params, function (err, data) {
                  if (err) { console.warn('Error while sending message: ' + err); }
                  else { console.info('Message sent, ID: ' + data.MessageId); }
                  next(err);
              });
          },
          function (next) {
              // Starts an ECS task to work through the feeds.
              var params = {
                  cluster: CLUSTER_NAME,
                  taskDefinition: TASK_NAME,
                  count: 1,
                  launchType: 'FARGATE',
                  platformVersion: '1.4.0',
                  networkConfiguration: {
                    'awsvpcConfiguration': {
                      'subnets': [
                          SUBNET
                      ],
                      'securityGroups': [
                          SECURITY_GROUP
                      ],
                      'assignPublicIp': 'ENABLED'
                  }
                  }
              };
              ecs.runTask(params, function (err, data) {
                  if (err) { console.warn('error: ', "Error while starting task: " + err); }
                  else { console.info('Task ' + TASK_NAME + ' started: ' + JSON.stringify(data.tasks))}
                  next(err);
              });
          }
      ], function (err) {
          if (err) {
            var response = {
              statusCode: 400,
              headers: {
                'Content-Type': 'text/html',
              },
              body: "Sorry, it failed. Check your inputs",
            }
            callback(null, response)
          }
          else {
            var response = {
              statusCode: 200,
              headers: {
                'Content-Type': 'application/json',
              },
              body: "It's been triggered. Please check back in 10-15 mins",
            }
            callback(null, response)
          }
      }
    );    
};