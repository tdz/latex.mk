
#
# User Variables
#

# LaTex input file
PDF_SOURCE ?=

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

# LaTex toolchain
LATEX_FILE_SUFFIX := .aux \
                     .bbl \
                     .blg \
                     .log \
                     .nav \
                     .snm \
                     .toc \
                     .out \
                     .vrb
PDFLATEX ?= pdflatex
PDFLATEX_FLAGS += -halt-on-error

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

$(PDF_OUTPUT) : $(PDF_SOURCE) $(IMAGES)
	$(RM) $(addprefix $(basename $(PDF_SOURCE)), $(LATEX_FILE_SUFFIX))
	$(PDFLATEX) $(PDFLATEX_FLAGS) $<
	$(PDFLATEX) $(PDFLATEX_FLAGS) $<
	$(PDFLATEX) $(PDFLATEX_FLAGS) $<

%.jpg : %.png
	$(CONVERT) $(CONVERT_FLAGS) $< $@

%-dot.png : %.dot
	$(DOT) $(DOT_FLAGS) -Tpng -o$@ $<
