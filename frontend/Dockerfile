FROM node:16.19.1

LABEL maintainer="realraec.xyz"

WORKDIR /usr/app

RUN git clone https://github.com/realraec/quizgame-frontend.git .
RUN npm install

ENTRYPOINT npm start