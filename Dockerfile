FROM node:10-alpine
# RUN npm install -g @11ty/eleventy

# RUN npm i -g firebase-tools

# WORKDIR /usr/src/toaster-site

ADD firebase.sh /usr/bin
RUN chmod +x /usr/bin/firebase.sh

# COPY ./pages /usr/src/toaster-site
# COPY ./firebase.json /usr/src/toaster-site
# COPY ./.firebaserc /usr/src/toaster-site

# RUN eleventy

# RUN ls /usr/src/toaster-site

# RUN pwd

ENTRYPOINT [ "/usr/bin/firebase.sh" ]