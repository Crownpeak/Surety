"use strict";

let LRU = require("lru-cache")
  , options = { max: 100
              , length: function (n, key) { return 1 }
              , dispose: function (key, n) { ; }
              , maxAge: 1000 * 60 * 60 }
  , resultCache = new LRU(options);

exports.handler = async (event, context) => {

  //console.log("Event: " + JSON.stringify(event));
  //console.log("Context: " + JSON.stringify(context));

  const AWS = require('aws-sdk');
  AWS.config.region = "us-east-1";
  const request = require('request').defaults({ encoding: null });

  if (!event.body) {
    return { statusCode: 404 };
  }
  const body = JSON.parse(event.body);
  if (!body.url) {
    return { statusCode: 404 };
  }
  
  var maxLabels = parseInt(body.maxLabels || "10");
  var minConfidence = parseFloat(body.minConfidence || "77.0");

    // Define a key to represent this request
    let key = body.url + "," + maxLabels + "," + minConfidence;
    // If this key is already in the cache, we can shortcut the whole thing
    let result = resultCache.get(key);
    if (result) {
      //console.log("Got result from cache");
      return { 
        statusCode: 200, 
        headers: {
          "Access-Control-Allow-Origin": "*"
        },
        body: result };
    }
  
  const promise = new Promise(function(resolve, reject) {
    request.get(body.url, (error, response, body) => {
      if (error) {
        console.log(error, error.stack);
        reject({ statusCode: 500, body: "" });
      } else {
        new AWS.Rekognition({apiVersion: '2016-06-27'})
          .detectLabels({
            MaxLabels: maxLabels, 
            MinConfidence: minConfidence,
            Image: { Bytes: body }
          }, (err, data) => {
              if (err) {
                console.log(err, err.stack);
                reject({ statusCode: 500, body: "" });
              } else {
                result = JSON.stringify(data);
                resultCache.set(key, result);
                  //console.log("Set response to " + JSON.stringify(data));
                resolve({ 
                  statusCode: 200, 
                  headers: {
                    "Access-Control-Allow-Origin": "*"
                  },
                  body: result });
              } 
            });
       }
    });
  });
  return promise;
};
