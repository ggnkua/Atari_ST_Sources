#
# makefile for primer.dvi
# check comments in primer.tex if you are going to run dvi file
# through dvi2tty
#

TEXFILES= verblist.sty primer.tex firsteps.tex running.tex debug.tex \
	  topics.tex   
EXAMPLES= bcktrace.exm firstdis.exm jumptwo.exm maindis.exm symbols.exm \
	  dump.exm jumpone.exm kdefs.exm reptdis.exm tabs.exm     
CSOURCE = unexpand.c
NAME=primer
ARCH=zoo.ttp

$(NAME).dvi: $(TEXFILES) $(EXAMPLES) $(CSOURCE)
	latex $(NAME).tex

arch: $(TEXFILES) $(EXAMPLES) $(CSOURCE)
	$(ARCH) u $(NAME) $(TEXFILES) $(CSOURCE) makefile
	$(ARCH) u $(NAME) $(EXAMPLES)

clean:
	$(RM) $(NAME).aux $(NAME).log

clobber: clean
	$(RM) $(NAME).dvi
