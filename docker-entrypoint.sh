#!/usr/bin/env bash

set -ex
set -o allexport

while ! python3 manage.py migrate 2>&1; do
  echo 'Performing database migration'
  sleep 3
done

echo 'Starting application'
python3 ./manage.py runserver 0.0.0.0:8080
