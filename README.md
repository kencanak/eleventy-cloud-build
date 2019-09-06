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

2. Debugging Cloud Build settings locally
	- before building Cloud Build settings locally, make sure that `cloud-build-local` is installed in gcloud sdk
	- run `gcloud components install cloud-build-local`
	- run `cloud-build-local --config=cloudbuild.yaml --dryrun=false .` in terminal
	- the command above will read `cloudbuild.yaml` and run all the build steps
	- before running docker image locally, make sure that Docker is configured with container registry credentials
	- run `gcloud auth configure-docker`
	- to run docker image `docker run gcr.io/[Project ID]/[Docker image name]`
	- when running `cloud-build-local`, you will be able to debug and makesure that your Dockerfile is running as expected
	- when running docker image, you will be able to verify that it's running the shell script configured in Dockerfile, and doing the task listed in shell script

3. CI/CD flow
	- When there is code update in the repo, this includes code changes in front-end, Dockerfile, etc. to a specific branch, depending on the Cloud Build trigger setting
	- Respective Cloud Build's trigger will run and do the following:

		- Build the latest Dockerfile
		- Push the image into Image Registry
		- Run the latest docker image, which in case it will run `npm run build` and do a firebase deployment

	- The `cloudbuild.yaml` file should be looking like the following example:

			steps:
			# build docker image on trigger
			- name: gcr.io/cloud-builders/docker
				args: ['build', '--build-arg', FIREBASE_TOKEN, '-t', 'gcr.io/$PROJECT_ID/eleventy-cloud-build', '.']
				secretEnv: ['FIREBASE_TOKEN']

			# push to image registry, so that we can run the latest docker image
			# when creating build
			- name: 'gcr.io/cloud-builders/docker'
				args: ['push', 'gcr.io/$PROJECT_ID/eleventy-cloud-build']

			# we assume that on code change we want to rebuild the static page
			- name: 'gcr.io/$PROJECT_ID/eleventy-cloud-build'
				args: []

			secrets:
			- kmsKeyName: projects/toaster-website-beta/locations/global/keyRings/test-cloud-build/cryptoKeys/firebase-eleventy-cloud-build
				secretEnv:
					FIREBASE_TOKEN: CiQA+KnhzlNHI5LTH2Vl4MGDs10fCakPvsDFPbLZea+oE7Gk4wYSVgBPFOSMM/oMyjaUt5Mp3iiYC821T88EmecEgf6Nxu9uFkGJS5vutBf3qhYYb9WLUxP55wuWE4bb3uvmzLu6J1osTF1qJ27NWqiZXsWKgYkUSFvdnuM/


## Why this approach?
Background:

		1. We have existing CMS that is running on different instance
		2. The Front-end page is slow, hence we need to improve it by moving it to static build instead of dynamically
			 read, consume, and render the page via AJAX call

Build flow approach:

		We are trying to automate the static page builder (in this case eleventy) whenever there is a new content
		published from a CMS that is running from a different environment.

		When user do a PUBLISH/DELETE/etc. in the CMS it will send out a Pub/Sub topic message.

		We then have a separate Cloud Function running, that is subscribing
		to the respective Pub/Sub topic.

		Upon receiving a message from the Pub/Sub topic, the cloud function will run and create a new Cloud Build task.

		Cloud Build will then running all the processed needed, such as grabbing the latest PUBLISHED data from the
		CMS, by calling the CMS API and then build the static pages.

		Once static pages are build, we will then deploy those to firebase hosting

Implementation:

		In Google Cloud Build, we can create a build trigger by listening to a code repo branch. When there is a code
		push, what happen is that it will run all the steps specified in `cloudbuild.yaml` (if it's a custom build)
		or run a build on the Dockerfile provided.

		Since our Dockerfile involves a bunch of packages install process, it would be time consuming if we are doing:
				1. Every time there is a content update, we will run the trigger
				2. When we are running the trigger, it will start over all the packages installation process and
				the rest of mumbo jumbo

		So, instead of running a trigger each time there is a content update, we do:
				1. create a custom build settings, which telling cloud build to:
						- rebuild the docker image when ONLY there is a code base change.
						- Then push the image into the registry (to be re-used)
						- Run the latest docker image from registry (which will then rebuild all the static
						pages and deploy)

				2. In our Cloud Function that is subscribing to a Pub/Sub topic, we will do the following when
				there is a new
				   topic:
					 	- create new Cloud Build projects Build with the following steps:
							- run the latest Dockerimage, and set the working directory to be the same
							as per what we set in our Dockerfile

				3. This approach will make the static pages build and deployment process a lot faster,
				as there is no need for us to run every single packages installation anymore

## References
1. https://cloud.google.com/cloud-build/docs/build-debug-locally
2. https://cloud.google.com/cloud-build/docs/securing-builds/use-encrypted-secrets-credentials
3. https://docs.docker.com/docker-for-mac/install/
4. should we need to access github private repo: https://cloud.google.com/cloud-build/docs/access-private-github-repos
5. https://towardsdatascience.com/slimming-down-your-docker-images-275f0ca9337e
