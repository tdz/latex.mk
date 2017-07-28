
#
# User Variables
#

# LaTex input files
PDF_SOURCE ?=
EXTRA_PDF_SOURCES ?=

# BibTex input files
BIB_FILES ?=

# Image input files
JPEG_IMAGES ?=
JPEG_SOURCES ?=
PNG_IMAGES ?=
PNG_SOURCES ?=

# Dot input files
DOT_SOURCES ?=

# Flags for pdflatex
PDFLATEX_FLAGS ?=

# Flags for convert
CONVERT_FLAGS ?=
CONVERT_QUALITY ?= 50


#
# Automatic Variables
#

PDF_OUTPUT := $(patsubst %.tex,%.pdf,$(PDF_SOURCE))

JPEG_OUTPUT := $(patsubst %.png,%.jpg,$(JPEG_SOURCES))

PNG_OUTPUT := $(patsubst %.dot,%-dot.png,$(PNG_SOURCES))

IMAGES := $(JPEG_IMAGES) \
          $(JPEG_OUTPUT) \
          $(PNG_IMAGES) \
          $(PNG_OUTPUT)

# System tools
CP ?= cp
MV ?= mv
RM ?= rm -f

# BibTeX
BIBTEX ?= bibtex
BIBTEX_FLAGS += -terse

# LaTex toolchain
LATEX_FILE_SUFFIX := .aux \
                     .bbl \
                     .blg \
                     .idx \
                     .ind \
                     .log \
                     .nav \
                     .snm \
                     .toc \
                     .out \
                     .vrb
PDFLATEX ?= pdflatex
PDFLATEX_FLAGS += -halt-on-error

# Includes PDF source file plus \input'ed TeX files
TEX_FILES := $(PDF_SOURCE) $(EXTRA_PDF_SOURCES)

# makeindex
MAKEINDEX ?= makeindex
MAKEINDEX_FLAGS += -q

IDX_FILE := $(patsubst %.tex,%.idx,$(PDF_SOURCE))

# Graphviz
DOT ?= dot
DOT_FLAGS +=

# ImageMagick
CONVERT ?= convert
CONVERT_FLAGS += -quality $(CONVERT_QUALITY)


#
# Rules
#

.PHONY = all clean pdf

all : pdf

clean :
	$(RM) $(PDF_OUTPUT) $(JPEG_OUTPUT) $(PNG_OUTPUT)
	$(RM) $(addprefix $(basename $(PDF_SOURCE)), $(LATEX_FILE_SUFFIX))

pdf : $(PDF_OUTPUT)

$(PDF_OUTPUT) : $(TEX_FILES) $(IMAGES) $(BIB_FILES)
	$(RM) $(addprefix $(basename $(PDF_SOURCE)), $(LATEX_FILE_SUFFIX))
	$(PDFLATEX) $(PDFLATEX_FLAGS) -draftmode $<
ifneq ($(BIB_FILES),)
	$(BIBTEX) $(BIBTEX_FLAGS) $(basename $<)
	$(PDFLATEX) $(PDFLATEX_FLAGS) -draftmode $<
endif
ifneq ($(wildcard $(IDX_FILE)),)
	$(MAKEINDEX) $(MAKEINDEX_FLAGS) $(basename $<)
endif
	$(PDFLATEX) $(PDFLATEX_FLAGS) $<

%.jpg : %.png
	$(CONVERT) $(CONVERT_FLAGS) $< $@

%-dot.png : %.dot
	$(DOT) $(DOT_FLAGS) -Tpng -o$@ $<
