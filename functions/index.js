const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
	console.log(request.body);
	const event_type = request.headers['x-github-event'];
	const payload = JSON.parse(request.body.payload);

	console.log('HEADERS');
	console.log(request.headers);

	if (event_type === 'pull_request') {
		console.log(`EVENT TYPE: ${event_type}`);
		console.log(payload);

		console.log('RAW BODY:');
		console.log(request.rawBody);
		response.send("Hello from Firebase!");
	} else {
		response.status(403).send('forbidden request');
	}
});
