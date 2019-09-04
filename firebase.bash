#!/bin/bash

# run the original firebase
if [ $FIREBASE_TOKEN ]; then
  firebase deploy --only hosting --token $FIREBASE_TOKEN
else
	echo "Hello, world! The time is $(date)."
  firebase deploy --only hosting
fi
