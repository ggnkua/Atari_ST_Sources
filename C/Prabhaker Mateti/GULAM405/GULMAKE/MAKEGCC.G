## Gulam "Makefile" for GNU CC on the Atari ST
##
## - Jim Hurley
##   'jimh@ultra.com'
##   '...!ames!ultra!jimh'
##
##    09/04/90 - Set up for my directory structure
##
echo 'setting up environment, etc...'
alias cpp d:\gnu\bin\gcc-cpp
setenv cpp d:\gnu\bin\gcc-cpp.ttp
alias cc1 d:\gnu\bin\gcc-cc1
setenv cc1 d:\gnu\bin\gcc-cc1.ttp
alias gas d:\gnu\bin\gcc-as
setenv gas d:\gnu\bin\gcc-as.ttp
alias as d:\gnu\bin\gcc-as
setenv as d:\gnu\bin\gcc-as.ttp
alias link d:\gnu\bin\link
setenv link d:\gnu\bin\link.ttp
alias ar d:\gnu\bin\gcc-ar
setenv ar d:\gnu\bin\gcc-ar.ttp
alias ld d:\gnu\bin\gcc-ld
setenv ld d:\gnu\bin\gcc-ld.ttp
alias gcc d:\gnu\bin\gcc
setenv gcc d:\gnu\bin\gcc.ttp
##
alias cc d:\gnu\bin\gcc
setenv cc d:\gnu\bin\gcc.ttp
##
alias make d:\gnu\bin\make.ttp
setenv make d:\gnu\bin\make.ttp
##
##
alias nm d:\gnu\bin\cnm.ttp
##
##
##
setenv GNUINC 'd:\gnu\include'
setenv GNULIB 'd:\gnu\lib'
setenv GCCEXEC 'd:\gnu\bin\gcc-'
## 711k byte RAMDISK for TEMP on m:
setenv TEMP m:
##
##
##
## make the generators for the insn files
echo 'make -f makegen -------- this will take about 20 minutes...'
date
make -f makegen
## generate the insn files
echo 'makeinsn.g ------------- this will take about 10 minutes...'
date
makeinsn.g
## complete the make
echo 'make -f makelast ------- this will take about 2 hours 30 minutes...'
date
make -f makelast
## cleanup directory ( remove *.o, gen*.ttp, and insn-* files)
echo 'cleaning up...'
date
clean.g
## end of makegcc.g
