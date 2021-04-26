# pull official base image
FROM python:3.8.5-slim-buster

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apt-get update \
  && apt-get -y install gcc postgresql libasound-dev portaudio19-dev libportaudio2 libportaudiocpp0 \
  && apt-get clean

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# copy project
COPY . .

# collect static files
RUN python manage.py collectstatic --no-input

# Apply database migrations
RUN python manage.py migrate

RUN mkdir -p /usr/src/static_cdn
RUN cd /usr/src/static_cdn && ln -s /usr/src/app/static_cdn/media_root
