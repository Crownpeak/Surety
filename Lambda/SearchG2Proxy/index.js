"use strict";

const allowedEndPoints = ["searchg2.crownpeak.net", "searchg2-restricted.crownpeak.net"];
const request = require('request').defaults({ encoding: "utf-8" });
const AWS = require('aws-sdk');
AWS.config.region = "us-west-2";

let LRU = require("lru-cache")
  , options = { max: 100
              , length: function (n, key) { return 1 }
              , dispose: function (key, n) { ; }
              , maxAge: 1000 * 60 * 60 }
  , certificateCache = new LRU(options);

exports.handler = async (event, context) => {

  //console.log("Event: " + JSON.stringify(event));
  //console.log("Context: " + JSON.stringify(context));

  const AWS = require('aws-sdk');
  AWS.config.region = "us-west-2";

  // See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-requirements-limits.html
  if (!event || !event.queryStringParameters || !event.queryStringParameters["q"] || !event.httpMethod) {
    return { statusCode: 404 };
  }

  if (!event.headers || !event.headers.Referer) {
    return { statusCode: 401 };
  }

  let proxyRequest = event.queryStringParameters["q"];
  const proxyRequestDomain = getDomainNameFromUrl(proxyRequest);
  if (allowedEndPoints.indexOf(proxyRequestDomain) < 0) {
    return { statusCode: 401 };
  }

  let options = { url: proxyRequest,
    headers: {
      "User-Agent": "Crownpeak Search Proxy"
    }
  };

  let fn = request.get;
  if (event.httpMethod === "POST") {
    options.form = event.body;
    fn = request.post;
  }

  const secure = proxyRequest.indexOf("https://") == 0;

  if (secure) {
    let collection = getCollectionNameFromUrl(proxyRequest);
    if (collection) {
      let cert = await getCertificate(collection);
      if (cert && cert.certificate) {

        if (cert.domains && cert.domains.length > 0) {
          const refererDomain = getDomainNameFromUrl(event.headers.Referer);
          if (cert.domains.indexOf(refererDomain) < 0) {
            return { statusCode: 401 };
          }
        }

        options.agentOptions = {
          pfx: cert.certificate
        };
      }
    }
  }

  return new Promise(function(resolve, reject) {
    fn(options, (error, response, body) => {
      if (error) {
        console.log(error, error.stack);
        reject({ statusCode: error.statusCode, body: body });
      } else {
        let responseType = "text/xml";
        const firstChar = body.substr(0, 1);
        if (firstChar === "{") responseType = "application/json";
        else if (firstChar !== "<") responseType = "application/javascript";

        resolve({ 
          statusCode: 200, 
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": responseType,
          },
          body: body});
      }
    });
  });

};

function getCollectionNameFromUrl(url) {
  if (url == null) return "";
  var urlArray = url.split("/");
  return urlArray.length > 4 ? urlArray[3] : "";
}

function getDomainNameFromUrl(url)
{
	if (url == null) return "";
	if (url.indexOf("://") >= 0) url = url.split("://")[1];
	return url.split("/")[0];
}

async function getCertificate(collection) {
  let cert = certificateCache.get(collection);
  if (cert) {
    console.log("Cache hit for " + collection);
  } else {
    console.log("Cache miss for " + collection);
    cert = await getSecret(collection);
    if (cert) {
      cert = JSON.parse(cert);
      if (cert && cert.certificate) {
        cert.certificate = Buffer.from(cert.certificate, "base64");
        certificateCache.set(collection, cert);
      }
    }
  }
  return cert;
}

function getSecret(collection) {
  return new Promise(function(resolve, reject) {
    new AWS.SecretsManager().getSecretValue({SecretId: "SearchG2/prod/certificate/" + collection}, (err, data) => {
      if (err) {
        /* console.log(err);
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
            throw err; */
        console.log("No certificate found for " + collection);
        resolve("");
      }
      else {
        resolve(data.SecretString);
      }
    });
  });
}