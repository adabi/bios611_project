.PHONY: clean fullclean
SHELL: /bin/bash

report.pdf:\
	report.Rmd\
	figures/first_moves_white.png figures/first_moves_black.png figures/roc_plot.png\
	figures/openings.png figures/accuracy.png
		Rscript -e "rmarkdown::render('report.Rmd')"

clean:
	rm -f figures/*
	rm -f report.pdf
	rm -f Rplots.pdf
	
fullclean:
	make clean
	rm -f source_data/accuracy.csv

figures/first_moves_white.png figures/first_moves_black.png figures/roc_plot.png\
figures/openings.png figures/accuracy.png:\
	source_data/carlsen_games_moves.csv\
	source_data/carlsen_games.csv\
	create_figures.R accuracy.R\
	source_data/accuracy.csv
		mkdir -p figures/
		Rscript create_figures.R
		rm -f Rplots.pdf
		
source_data/accuracy.csv:
	mkdir -p source_data/
	Rscript accuracy.R
