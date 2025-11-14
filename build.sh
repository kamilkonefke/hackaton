#!/usr/bin/env bash

if [[ $1 == '-exe' ]]; then
    odin build src/ -out=game -debug
else
    odin run src/ -out=game -debug
fi
