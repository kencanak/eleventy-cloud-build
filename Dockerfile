FROM node:10-alpine

# RUN apk --no-cache add curl

# get docker build-arg
ARG FIREBASE_TOKEN

# set it to environment variable,
# so that we can grab the value from shell script
ENV FIREBASE_TOKEN=$FIREBASE_TOKEN

# install firebase cli
RUN npm i -g firebase-tools

# set docker working directory
WORKDIR /usr/src/toaster-site

# copy all front-end code template
COPY . /usr/src/toaster-site

# run npm install locally
RUN npm install

# copy firebase-deploy.sh to /usr/bin
ADD firebase-deploy.sh /usr/bin

# chmod the shell script, so that it is executable
RUN chmod +x /usr/bin/firebase-deploy.sh

# just to confirm chmod is working ok
RUN ls -l /usr/bin/firebase-deploy.sh

# set docker run entry point
ENTRYPOINT [ "/usr/bin/firebase-deploy.sh" ]
