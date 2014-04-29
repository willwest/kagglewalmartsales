all:
	-@pdflatex report.tex
	-@bibtex report
	-@pdflatex report.tex
	-@pdflatex report.tex

clean:
	-@rm *~
	-@rm report.pdf
	-@rm Rplots.pdf
	-@rm report.log