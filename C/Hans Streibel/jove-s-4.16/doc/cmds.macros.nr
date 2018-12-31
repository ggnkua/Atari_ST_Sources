.\" Macros for formatting cmds.nr to produce cmds.doc
.
.\" define strings for left and right double-quotes (same as -ms)
.if n .ds Q ""
.if n .ds U ""
.if t .ds Q ``
.if t .ds U ''
.
.de IQ	\" italics (in manual) or quote (here, in describe-command)
"\\$1"\\$2
..
.de BQ	\" bold (in manual) or quote (here, in describe-command)
"\\$1"\\$2
..
.de dc
.sp 1
:entry "\\$1"
.if '\\$2'(variable)' "Variable"
.if !'\\$2'(variable)' "Command"
.br
..
.de ID
.sp 1
.in +5
..
.de DE
.fi
.sp 1
.in -5
..
.de DS
.nf
.sp 1
.in +5
..
.de UX
UNIX\\$1
..
.ll 7i
.na	\" No Adjust: ragged right looks best on fixed-pitch screen
.nh	\" No Hyphenation: best with ragged
.pl 1	\" page length 1 line: avoid filling last page with blank lines
