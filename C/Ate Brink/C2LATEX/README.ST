C2LATEX.TTP

I compiled this version of c2latex for the Atari ST with GNU C 1.40.
I had to make one small modification at line 1687 in the file
c2latex.c. GNU C couldn't find the header file malloc.h, so for the
Atari version I didn't include this file.

To create the c2latex.c file I have used flex on the HP9000/400 computer
at our department. I'll include the complete sources.

I have also included a plain ascii version of the manual pages (c2latex.txt).
Please note: The original maual pages describe a c++2latex version of the
             program, but I made ansi-C input files as the default option.
             So c2latex.txt describes my version of the program.


Ate Brink
Department of computer science, Utrecht University, The Netherlands
Email: ate@cs.ruu.nl
14-02-1992
