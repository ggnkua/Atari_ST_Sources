#!make -f
# @(#)windom.mk, 
#
# make file for 'WinDOM' an its utility
#

all:
	@echo type gcc, gcc281, soz or total

total:
	@echo
	@echo ============================================
	@echo  compiling WINDOM for sozobon C
	@echo ============================================
	@echo
	@echo clean up working directory...
	rm -f *.o
	make soz
	@echo
	@echo ============================================
	@echo  compiling WINDOM for GNU C 2.81c
	@echo ============================================
	@echo
	@echo clean up working directory...
	rm -f *.o
	make gcc281
	@echo
	@echo ============================================
	@echo  compiling WINDOM with default GCC compiler
	@echo ============================================
	@echo
	@echo clean up working directory...
	rm -f *.o
	make gcc
	@echo
	@echo ============================================
	@echo  building archives
	@echo ============================================
	@echo
	@echo clean up working directory...
	rm -f *.o
	make zip

.PHONY : clean pc pcgemlib soz gcc281 gcc zip

clean:
	rm -f *.o

pc:
	make -f m_pc

pcgemlib:
	make -f m_pcgem

soz:
	make -f m_sox

gcc281:
	make -f m_gcc281

gcc:
	make -f m_gcc

zip:
	cd .. ; make -f src/m_zip

.FORCE:

#eof
