#!/bin/sh
echo "Running static build"

npm run build

firebase deploy --token $FIREBASE_TOKEN