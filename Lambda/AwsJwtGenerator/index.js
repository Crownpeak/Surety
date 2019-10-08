"use strict";

exports.handler = async (event, context) => {

    const key = "{key_ARN}";  // Replace with your AWS KMS ARN.
    const unauthorized = { "statusCode": 403 };
    const allowedReferrers = ["cms.crownpeak.net"];
    
    console.log("Event: " + JSON.stringify(event));
    console.log("Context: " + JSON.stringify(context));

    if (!event || !event.headers || !event.headers.Referer) {
        return unauthorized;
    } else {
        if (!allowedReferrers.some((value) => {
            return event.headers.Referer.indexOf(value) >= 0;
        })) return unauthorized;
    }

    var referrerParts = event.headers.Referer.split("/");
    if (referrerParts.length < 5) return unauthorized;

    const JWTKMS = require("jwt-kms");
    var jwtkms = new JWTKMS({
      aws: {
        region: "us-east-1"
      }
    });

    var instance = referrerParts[3];
    var payload = { crownpeak: true, instance: instance, created: Date.now() };

    try {
        var options = { expires: new Date(Date.now() + 60 * 1000 * 1000)};
        var token = "";
        await jwtkms.sign(payload, options, key).then((newtoken) => {
            token = newtoken;
        });
        return {
            "statusCode": 200,
            "body": JSON.stringify({ token: token })
        };
    }
    catch (e) {
        console.log("Error: " + JSON.stringify(e));
        return unauthorized;
    }
}