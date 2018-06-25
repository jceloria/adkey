FROM python:3-alpine

ENV SUBJ "/C=US/ST=TX/L=City/O=Company/OU=Org/CN=example.com"

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN apk --no-cache add git gcc libc-dev openssl && \
    pip install --no-cache-dir -r requirements.txt && mkdir ssl && \
    openssl req -x509 -nodes -subj ${SUBJ} -newkey rsa:4096 -keyout ssl/server.key -out ssl/server.crt -days 365 && \
    apk --no-cache del gcc libc-dev openssl

ADD http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css ./static/
ADD http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js ./static/
ADD http://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js ./static/

COPY . .

EXPOSE 8443/tcp
CMD [ "gunicorn", "--certfile=ssl/server.crt", "--keyfile=ssl/server.key", "--bind=0.0.0.0:8443", "adkey:application" ]
