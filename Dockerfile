FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

ADD http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css ./static/
ADD http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js ./static/
ADD http://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js ./static/

COPY . .

EXPOSE 8080/tcp
CMD [ "python", "./app.py" ]
