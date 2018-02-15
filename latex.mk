# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

# Files to clean up
EXTRA_CLEAN_FILES ?=

# Flags for pdflatex
PDFLATEX_FLAGS ?=

# Flags for convert
CONVERT_FLAGS ?=
CONVERT_QUALITY ?= 50

# Flags for hunspell
HUNSPELL_FLAGS ?=


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

# Includes PDF source file plus \input'ed TeX files
TEX_FILES := $(PDF_SOURCE) $(EXTRA_PDF_SOURCES)

IDX_FILE := $(patsubst %.tex,%.idx,$(PDF_SOURCE))

# LaTeX toolchain
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


#
# Tools
#

# System tools
CP ?= cp
MV ?= mv
RM ?= rm -f

# BibTeX
BIBTEX ?= bibtex
BIBTEX_FLAGS += -terse

PDFLATEX ?= pdflatex
PDFLATEX_FLAGS += -halt-on-error

# makeindex
MAKEINDEX ?= makeindex
MAKEINDEX_FLAGS += -q

# Graphviz
DOT ?= dot
DOT_FLAGS +=

# ImageMagick
CONVERT ?= convert
CONVERT_FLAGS += -quality $(CONVERT_QUALITY)

# Hunspell
HUNSPELL ?= hunspell


#
# Rules
#

.PHONY = all check clean pdf spellcheck

all : pdf

check : spellcheck

clean :
ifneq ($(EXTRA_CLEAN_FILES),)
	$(RM) $(EXTRA_CLEAN_FILES)
endif
	$(RM) $(PDF_OUTPUT) $(JPEG_OUTPUT) $(PNG_OUTPUT)
	$(RM) $(addprefix $(basename $(PDF_SOURCE)), $(LATEX_FILE_SUFFIX))

pdf : $(PDF_OUTPUT)

spellcheck : $(PDF_SOURCE)
	$(HUNSPELL) $(HUNSPELL_FLAGS) $(PDF_SOURCE)

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
