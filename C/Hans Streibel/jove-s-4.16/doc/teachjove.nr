.TH TEACHJOVE 1 "24 June 1993"
.ad
.SH NAME
teachjove \- learn how to use the JOVE editor
.SH SYNOPSIS
.B teachjove
[
.BI \-s \ sharedir
]
.SH DESCRIPTION
.hy 0
TEACHJOVE is a simple program that calls up the JOVE editor on a special
file that is an interactive tutorial for the JOVE editor.  Once in JOVE
all you do is follow the instructions and by doing so you will learn all
about JOVE!  NOTE: TEACHJOVE actually makes a copy of the tutorial in
your home directory; if you ever want to start over (if you trash the
file by accident) all you need to do is remove the file
.I ~/teach-jove
and run teachjove again.
.LP
TEACHJOVE recognizes the following switch:
.TP
.BI \-s \ sharedir
Allows the user to specify the directory in which the special
teach-jove file can be found (default <SHAREDIR>).
.SH FILES
.I <SHAREDIR>/teach-jove
\(em THE special file.
.SH SEE ALSO
.I jove(1)
\(em to learn about JOVE in general.
.SH AUTHOR
Jonathan Payne
