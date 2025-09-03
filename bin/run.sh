#!/bin/sh
# Wait for db with nc
while ! nc -z db 5432; do
  sleep 1
done