FROM node:10-alpine
RUN npm install -g @11ty/eleventy

RUN npm i -g firebase-tools

WORKDIR /usr/src/toaster-site

ADD firebase.bash /usr/src/toaster-site
RUN chmod +x /usr/src/toaster-site/firebase.bash

COPY ./pages /usr/src/toaster-site
COPY ./firebase.json /usr/src/toaster-site
COPY ./.firebaserc /usr/src/toaster-site

RUN eleventy

RUN ls /usr/src/toaster-site

RUN pwd

RUN firebase.bash