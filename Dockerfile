FROM node:10-alpine
RUN npm install -g @11ty/eleventy

RUN npm i -g firebase-tools

ADD firebase.bash /usr/bin
RUN chmod +x /usr/bin/firebase.bash

WORKDIR /usr/src/toaster-site

COPY ./pages /usr/src/toaster-site
COPY ./firebase.json /usr/src/toaster-site
COPY ./.firebaserc /usr/src/toaster-site

RUN eleventy

RUN /usr/bin/firebase.bash deploy --only hosting