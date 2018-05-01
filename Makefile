# This is the Makefile
#
# 4/2/18, PH

# project name
PROJ = org-mode-poster

#####################################
# Usually no edits below this line
#####################################
# Output directory


BUILDID=$(shell date +%Y%m%d-%H:%M:%S)

# Source directory
SRC = src

# External
EXT = ext

# directory for additional pdf files
LIB = lib

POSTER = $(SRC)/$(PROJ)_poster.pdf

README = README.md

# executables
RM = rm -Rf
TEX = xelatex -interaction nonstopmode -shell-escape 
BIBTEX = bibtex
EMACSINIT = $(EXT)/$(PROJ)_dotemacs 
EMACS = emacs -l ../$(EMACSINIT)
EMACSMSARGS = --batch -f org-latex-export-to-latex --kill
EMACSPARGS =  --batch -f org-beamer-export-to-latex --kill
EMACSRARGS = --batch -f org-md-export-to-markdown --kill
VIEWBIN = pdfview
PDFMERGEBIN = ext/pdfmerge
CPBIN = cp
MKDIRBIN = mkdir

# list org files
ORGFILES = $(SRC)/$(PROJ)_poster.org

# list tex files
TEXFILES = $(ORGFILES:$(SRC)/$(PROJ)_poster.org=$(SRC)/$(PROJ)_poster.tex)


# list additional library files
PDFLIB = $(wildcard $(LIB)/$(PROJ)*.*)

# indicator files to show tex has run
TEXOUTFILES = $(TEXFILES:$(SRC)/%.tex=$(SRC)/%.aux)

# replace tex with pdf to get pdf tex files
PDFTEXFILES = $(TEXOUTFILES:$(SRC)/%.aux=$(SRC)/%.pdf)

# Rule for $(TEXFILES)
# Convert every org file to LaTeX this is done from within the subfolder
# so be careful with relative paths
$(SRC)/%.tex: $(SRC)/%.org $(PDFLIB) $(SRC)/beamerthemeph.sty $(EMACSINIT)
	@if [ "$(notdir $<)" = "$(PROJ)_poster.org" ]; then \
		echo "Exporting poster from org to LaTeX" \
		&& cd $(SRC) && $(EMACS) $(PROJ)_poster.org $(EMACSPARGS); \
	fi

# Rule for $(TEXOUTFILES)
# Run every tex file this is done from within the subfolder so be
# careful with relative paths
$(SRC)/%.aux: $(SRC)/%.tex $(PDFLIB)
	cd $(SRC) && $(TEX) $(notdir $<)
	cd $(SRC) && $(TEX) $(notdir $<) 

# Default entry
all: poster readme

$(README): README.org $(EMACSINIT)
	emacs -l $(EMACSINIT) README.org $(EMACSRARGS);

git: all
	convert $(POSTER) $(SRC)/org-mode-poster_poster.png
	git add src/org-mode-poster_poster.org
	git add src/org-mode-poster_poster.tex
	git add src/org-mode-poster_poster.pdf
	git add src/org-mode-poster_poster.png
	git add src/*.sty
	git add README.org
	git add README.md
	git add ext/*
	git add Makefile
	git commit -m "Automatic commit of successful build $(BUILDID)"
	git push origin master

# make poster
poster: tex 

# run tex files
tex: $(TEXOUTFILES) $(TEXFILES)

# convert the readme file
readme: $(README)

viewposter: poster
	pdfview $(POSTER)

.PHONY: clean texclean Rclean

clean: texclean 

texclean: 
	$(RM) $(TEXOUT)/$(PROJ)*.tex
	$(RM) $(TEXOUT)/$(PROJ)*.aux

test:
	@echo $(POSTER) $(README)
