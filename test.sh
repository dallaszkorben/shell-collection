#!/bin/bash

while read NEWLINE ; do
    echo "$NEWLINE <>";
done <<< "`cat test.txt| tr ' ' ' '`"

