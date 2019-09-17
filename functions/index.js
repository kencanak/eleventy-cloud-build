const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
	console.log(request.body);
	const event_type = request.headers["X-GitHub-Event"];
	const payload = JSON.parse(request.body.payload);

	console.log(`EVENT TYPE: ${event_type}`);
	console.log(payload);
 	response.send("Hello from Firebase!");
});
