# Eleventy Cloud Builder Setup

## Development Pre-requisites
1. Development tools:

	- Node >= 8
	- Firebase CLI (ref: [firebase-cli](https://firebase.google.com/docs/cli))
	- Install docker (ref: [docker-for-mac](https://docs.docker.com/docker-for-mac/install/))
	- To use cloud build locally, follow the instructions [here](https://cloud.google.com/cloud-build/docs/build-debug-locally)

2. GCP environment setup

	- Enable Cloud Build API
	- Enable KMS API
	- Enable Firebase API
	- Grant KMS encrypt/decrypt access to both service account and developer account (usefull for debugging locally)
	- In cloud console (ref: [Securing Builds](https://cloud.google.com/cloud-build/docs/securing-builds/set-service-account-permissions)):

		- Go to Cloud Build > Settings
		- Enable `Cloud KMS`

## Development
This guide is focusing on both your `Dockerfile` and custom cloud build setup `cloudbuild.yaml`.
We won't touch anything on Front-end build steps. All we care is that `npm run build` should run all
the necessary static page build steps.

NOTE: Please make sure that you are login in to the correct gcloud project before proceeding

1. In order to deploy the static pages to firebase hosting, we will need to generate firebase CI token and store the
	 token in `KMS`. The steps will be:

	 - create KMS keyring

			gcloud kms keyrings create [KEYRING-NAME] --location=global

	 - create KMS keys

	 		gcloud kms keys create [KEY_NAME] \
				--location=global \
				--keyring=[KEYRING_NAME] \
				--purpose=encryption \
				--project=[PROJECT_ID]

	 - run `firebase login:ci` in terminal
	 - grant access using your account and copy the generated token
	 - run `export FIREBASE_TOKEN=[the token you copied]`
	 - create KMS key ring by:

			echo -n $FIREBASE_TOKEN | gcloud kms encrypt \
					--plaintext-file=- \
					--ciphertext-file=- \
					--location=global \
					--project=[PROJECT_ID] \
					--keyring=[KEYRING_NAME] \
					--key=[KEY_NAME] | base64

	 - copy the Base64 Encrypted keys
	 - update `cloudbuild.yaml`

			secrets:
			- kmsKeyName: projects/[PROJECT_ID]/locations/global/keyRings/[KEY_RING]/cryptoKeys/[KEY_NAME]
				secretEnv:
					FIREBASE_TOKEN: [the base64 encrypted keys you copied]

## References
1. https://cloud.google.com/cloud-build/docs/build-debug-locally
2. https://cloud.google.com/cloud-build/docs/securing-builds/use-encrypted-secrets-credentials
3. https://docs.docker.com/docker-for-mac/install/
