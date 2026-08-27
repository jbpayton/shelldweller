#!/bin/bash
# Entry point for battery task 01_list_etc.
# Prints the /etc filename listing to stdout and saves it as the output artifact.
cd "$(dirname "$0")"
./list_etc.sh > output.txt
cat output.txt
