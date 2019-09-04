FROM node:10-alpine
RUN npm install -g @11ty/eleventy

RUN npm i -g firebase-tools

WORKDIR /usr/src/toaster-site

COPY ./pages /usr/src/toaster-site
COPY ./firebase.json /usr/src/toaster-site
COPY ./.firebaserc /usr/src/toaster-site

RUN eleventy

RUN firebase deploy

