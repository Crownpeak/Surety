"use strict";

let LRU = require("lru-cache")
  , options = { max: 100
              , length: function (n, key) { return 1 }
              , dispose: function (key, n) { ; }
              , maxAge: 1000 * 60 * 60 }
  , credentialCache = new LRU(options)
  , resultCache = new LRU(options);

exports.handler = async (event, context) => {

  //console.log("Event: " + JSON.stringify(event));
  //console.log("Context: " + JSON.stringify(context));

  const AWS = require('aws-sdk');
  AWS.config.region = "us-west-2";
  const crownpeak = require('crownpeaknodeapi');

  if (!event.requestContext || !event.requestContext.authorizer || !event.requestContext.authorizer.instance) {
    return { statusCode: 401 };
  }
  const instance = event.requestContext.authorizer.instance;

  if (!event.body) {
    return { statusCode: 404 };
  }
  const body = JSON.parse(event.body);
  if (!body.id) {
    return { statusCode: 404 };
  }
  
  var maxLabels = parseInt(body.maxLabels || "10");
  var minConfidence = parseFloat(body.minConfidence || "77.0");

  // Define a key to represent this request
  let key = instance + "," + body.id + "," + maxLabels + "," + minConfidence;
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

  var cmsData = credentialCache.get(instance);
  if (!cmsData) {
    let thisCmsData = await getSecret(AWS, instance);
    cmsData = JSON.parse(thisCmsData);
    credentialCache.set(instance, cmsData);
    //console.log("Read CMS data from Secrets Manager: " + JSON.stringify(cmsData));
  }

  const promise = new Promise(function(resolve, reject) {
    var cp = new crownpeak.Api();
    cp.login(cmsData.username, cmsData.password, cmsData.server, cmsData.instance, cmsData.developerKey).then((_response) => {
      if (cp.error !== undefined) {
        console.log(cp.error);
        reject({ statusCode: 500, body: "" });
      } else {
        var assetAccess = new crownpeak.AccessAsset.AccessAsset(cp);
        assetAccess.DownloadAssetsPrepareBuffer(new crownpeak.AccessAsset.DownloadAssetsPrepareRequest(body.id)).then((response) => {
          new AWS.Rekognition({apiVersion: '2016-06-27'}).detectLabels({MaxLabels: maxLabels, MinConfidence: minConfidence, Image: { Bytes: response.fileBuffer } }, (err, data) => {
            if (err) {
              console.log(err, err.stack);
              reject({ statusCode: 500, body: "" });
            } else {
              result = JSON.stringify(data);
              resultCache.set(key, result);
              //console.log("Set response to " + result);
              resolve({ 
                statusCode: 200, 
                headers: {
                  "Access-Control-Allow-Origin": "*"
                },
                body: result });
            } 
          });
        });
      }
    })
  });
  return promise;
}

function getSecret(AWS, cms) {
  return new Promise(function(resolve, reject) {
    new AWS.SecretsManager().getSecretValue({SecretId: "Surety/prod/cms/" + cms}, (err, data) => {
      if (err) {
        console.log(err);
        if (err.code === 'DecryptionFailureException')
            // Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            // Deal with the exception here, and/or rethrow at your discretion.
            throw err;
        else if (err.code === 'InternalServiceErrorException')
            // An error occurred on the server side.
            // Deal with the exception here, and/or rethrow at your discretion.
            throw err;
        else if (err.code === 'InvalidParameterException')
            // You provided an invalid value for a parameter.
            // Deal with the exception here, and/or rethrow at your discretion.
            throw err;
        else if (err.code === 'InvalidRequestException')
            // You provided a parameter value that is not valid for the current state of the resource.
            // Deal with the exception here, and/or rethrow at your discretion.
            throw err;
        else if (err.code === 'ResourceNotFoundException')
            // We can't find the resource that you asked for.
            // Deal with the exception here, and/or rethrow at your discretion.
            throw err;
      }
      else {
        resolve(data.SecretString);
      }
    });
  });
}