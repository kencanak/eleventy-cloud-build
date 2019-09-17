const functions = require('firebase-functions');
const crypto = require('crypto');

const isValidRequest = (request) => {
	const event_type = request.headers['x-github-event'];
	const request_signature = request.headers['x-hub-signature'];

	const digest = crypto
			.createHmac('sha1', functions.config().githubwebhook.secret)
			.update(request.rawBody)
			.digest('hex');

	return event_type === 'pull_request' && request_signature === `sha1=${digest}`;
};

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
	console.log(request.body);
	const event_type = request.headers['x-github-event'];
	const payload = JSON.parse(request.body.payload);

	console.log('HEADERS');
	console.log(request.headers);

	if (isValidRequest(request)) {
		console.log(`EVENT TYPE: ${event_type}`);
		console.log(payload);

		console.log('RAW BODY:');
		console.log(request.rawBody);
		response.send("Hello from Firebase!");
	} else {
		response.status(403).send('forbidden request');
	}
});
