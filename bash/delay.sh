#!/bin/bash

echo "$@" | at now + $(shuf -i1-32 -n1) minutes

