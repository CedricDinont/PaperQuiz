#!/bin/bash

SERVERNUM=99
# find free server number by looking at .X*-lock files in /tmp
find_free_servernum() {
    # ldv: FIXME: race condition.
    i=$SERVERNUM
    while [ -f /tmp/.X$i-lock ]; do
        i=$(($i + 1))
    done
    SERVERNUM=$i
}