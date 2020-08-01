This is a port of SBProlog 3.1 to the Atari-ST; the port
is faithful to the original, except for some networking
fetures of Unix not present on the ST. This archive
contains sources, binaries and documentation in troff
format. The binary was compiled by gcc-2.1 on a SparcStation II.

The program needs to run under a shell and uses full UNIXMODE
support; there's no chance to restrict it under 8.3 character 
filenames, sorry. Consult UNIXMODE.arc at atari.archive
for more details.

The program uses by default 500000 longwords of program
and 300000 longwords of stack, perhaps too much for an ST.

To use it

setenv SBP <where sbp lives>
setenv SIMPATH $SBP/modlib:$SBP/lib:$SBP/cmplib:.
sbprolog -m 80000 -p 150000 $SBP/modlib/\$readloop

The first lines set up the simulator search path
(as described in docs, the program features a dynamic
loader of predicates). The option -m defines how much
stack the program will reserve, and -p how much storage
will be devoted to program area. With those defaults
the total memory used is 1200Kb, so I think the
whole system should run in 1Mb (but you may fail to run
the prolog compiler).

To use a runtime system only, you can delete the sources.

cd $SBP
cp sim/sbprolog.ttp .
rm -rf sim lib/src modlib/src cmplib/src bench

The compiled prolog performs about 5100 LIPS, against
a double value obtained by prolog68 (which is tailored
to the ST).

I had not used this system extensively, but it seems working
quite well. In case of problems, email to

Matteo.Frigo@dei.unipd.it

Matteo Frigo.

