#!/bin/sh

echo 'Go to http://localhost:6901/?password=magic'
docker run -d -p 5901:5901 -p 6901:6901 bolunthompson/magic-vlsi
