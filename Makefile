.PHONY: clean
SHELL: /bin/bash

report.pdf:\
	report.Rmd\
	figures/first_move_black.png figures/first_move_white.png figures/roc_plot.png
		Rscript -e "rmarkdown::render('report.Rmd')"

clean:
	rm -f figures/*
	rm -f report.pdf
	rm -f Rplots.pdf

figures/first_move_black.png figures/first_move_white.png figures/roc_plot.png:\
	source_data/carlsen_games.csv source_data/carlsen_games_moves.csv\
	create_figures.R
		mkdir -p figures/
		Rscript create_figures.R
		rm -f Rplots.pdf
