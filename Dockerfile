FROM alpine:3.18

RUN apk update && apk add bcc-tools bcc-doc
