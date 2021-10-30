# Magnus Carlsen Games Analysis

## Overview

This is a preliminary analysis of set of games by world chess champion Magnus Carlsen pulled from the Lichess.org server. 

The first part of the analysis is carried out only a subset of games (a random sample of 500 games pulled from [this][arxiv] Kaggle archive of all his Lichess games). This small subset is meant for demonstration purposes as the source data is too large to include directly on Github. If you would like to generate a report for the full data, you will need to create an account on Kaggle and download the data, then place the file `carlsen_games_moves.csv` in the `/source_data` folder. 

## Docker

This app relies on a Docker container to launch. The included Dockerfile will install all the required dependencies. To build the Docker image (and name it in a way that is compatible with the included launch_container.sh script), navigate to the repository and run the following code:
``` console
docker build . -t bios611project 
```
This will build a Docker image and allow you to generate the report.

## Generating the Report

Included in this repository is a bash script, launch_container.sh that will automatically run the docker image and create a bash shell. Once you have built the Docker image as outlined previously, just navigate to the repository and run:

``` console
bash launch_container.sh
```

This will generate a random password for the container and output it before running the bash shell. 

Alternatively, if you would like to run the container yourself and choose your own password, navigate to the repository and run: 

``` console
docker run\
 -e PASSWORD="pwd"\
 -v $(pwd):/home/rstudio/project\
 --rm -w "/home/rstudio/project"\
 -it bios611project sudo -H -u rstudio /bin/bash 
``` 

Once the container is running, you can create the report using make:

``` console
make report.pdf
```

Once the make process is finished, the `report.pdf` file should now be in the repository. If you would like to clearn the repository and run the make process from scratch just run:

``` console
make clean
```
Once you are done, you may quit the container process by pressing `ctrl + d`. 
* * * 

[arxiv]:https://www.kaggle.com/zq1200/magnus-carlsen-lichess-games-dataset