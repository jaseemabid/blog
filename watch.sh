#!/bin/bash

# only watches first parameter for modification
while inotifywait -e modify css/style.less; do
        echo
        make lessc
        echo +++ Last run: `date`  +++
done
