const functions = require('firebase-functions');
const crypto = require('crypto');

const isValidRequest = (request) => {
	const event_type = request.headers['x-github-event'];
	const request_signature = request.headers['x-hub-signature'];

	const digest = crypto
			.createHmac('sha1', functions.config().githubwebhook.secret)
			.update(request.rawBody)
			.digest('hex');

	return event_type === 'check_suite' && request_signature === `sha1=${digest}`;
};

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
	console.log(request.body);
	const event_type = request.headers['x-github-event'];
	const payload = request.body.payload ? JSON.parse(request.body.payload) : null;

	console.log('HEADERS');
	console.log(request.headers);
	console.log(`EVENT TYPE: ${event_type}`);

	if (isValidRequest(request)) {
		console.log('request is valid');
		console.log(payload);

		console.log('pull request details');
		console.log(request.body.check_suite.pull_requests);


		// github token to post comment and update the pull request
		// regardless whether or not it's a github app or just pure webhook

		response.send("Hello from Firebase!");
	} else {
		response.status(403).send('forbidden request');
	}
});
