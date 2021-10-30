#!/bin/bash
password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
echo You password is $password
docker run -e PASSWORD=$password -v $(pwd):/home/rstudio/project --rm -w "/home/rstudio/project" -it bios611project sudo -H -u rstudio /bin/bash 
