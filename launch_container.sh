#!/bin/bash
password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo You password is $password
docker run -e PASSWORD=$password -p 8787:8787 -v $(pwd):/home/rstudio/project --rm  -t bios611project
