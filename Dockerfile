FROM node:10-alpine

ARG FIREBASE_TOKEN

RUN npm i -g firebase-tools

WORKDIR /usr/src/toaster-site

COPY . /usr/src/toaster-site

RUN npm install

RUN npm run build

RUN chmod +x /usr/src/toaster-site/firebase-deploy.sh

ENTRYPOINT [ "/usr/src/toaster-site/firebase-deploy.sh" ]

# CMD firebase deploy --only hosting --token=${FIREBASE_TOKEN}

