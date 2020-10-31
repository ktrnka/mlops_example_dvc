# Grab the latest alpine image
FROM python:3.7-slim

# Install dependencies
ADD ./requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -q -r /tmp/requirements.txt

# Add our code
ADD ./ /opt/webapp/
WORKDIR /opt/webapp

# Run the image as a non-root user
RUN adduser --disabled-password web_user
USER web_user

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku
ENV PYTHONPATH "${PYTHONPATH}:src"
CMD gunicorn --bind 0.0.0.0:$PORT main:app
