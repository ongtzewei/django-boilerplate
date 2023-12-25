FROM python:3.12.1-slim-bullseye

#RUN apt-get update && apt-get install -y \
#  binutils \
#  libproj-dev \
#  gdal-bin \
#  && rm -rf /var/lib/apt/lists/*

WORKDIR /django/boilerplate-app
COPY requirements.txt /django/boilerplate-app/

RUN python3.12 -m pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel
RUN pip install -r requirements.txt

COPY . /django/boilerplate-app/
RUN chmod +x /django/boilerplate-app/docker-entrypoint.sh

ENV PYTHONUNBUFFERED=1
EXPOSE 8080
ENTRYPOINT [ "/django/boilerplate-app/docker-entrypoint.sh" ]
