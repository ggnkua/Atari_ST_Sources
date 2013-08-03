REM this file invokes the loader, LO68 and allows specification
REM of multiple object files to be linked by LO68 into a
REM single executable program.
\tools\lo68 -s -r -o %1.rel s.o %1.o %2.o %3.o %4.o %5.o %6.o %7.o %8.o %9.o clib
\tools\relmod %1.rel %1.prg
del %1.rel
