# CHART

This project provides a library of simple chart drawing functions for 
Atari C programmers.  The code is written to be embedded into an 
existing project.  The code was written for 
[AHCC](http://members.chello.nl/h.robbers/), 
but may work with other C compilers with minor modifications.

## Use

Include the files chart.h and chart.c in your own project.

Read chart.h for a description of the available functions.

The file example.c illustrates all functions in the library.

When compiling on a Firebee, include the compiler flag PMARKS, to use 
the library's built in pmarker code. 

## Functionality

Three types of chart are supported:

1. Bar Charts: A set of positive values is converted into a series of vertical
   bars.  The title, x/y labels, colours and fill patterns of bars may be
   altered.

2. Line Charts: A set of lines added to a line chart.  The title, x/y labels,
   and colour, line style and point style may all be altered.

3. Pie Charts: A set of positive values is converted into slices of a pie
   chart.  The title, slice labels, colours and fill patterns may be altered.

## License

Chart is copyright (c) 2016, Peter Lane.

This is version 0.9.4 of the [Open Works License](http://owl.apotheon.org/)

Permission is hereby granted by the holder(s) of copyright or other legal
privileges, author(s) or assembler(s), and contributor(s) of this work, to any
person who obtains a copy of this work in any form, to reproduce, modify,
distribute, publish, sell, sublicense, use, and/or otherwise deal in the
licensed material without restriction, provided the following conditions are
met:

Redistributions, modified or unmodified, in whole or in part, must retain
applicable copyright and other legal privilege notices, the above license
notice, these conditions, and the following disclaimer.

NO WARRANTY OF ANY KIND IS IMPLIED BY, OR SHOULD BE INFERRED FROM, THIS LICENSE
OR THE ACT OF DISTRIBUTION UNDER THE TERMS OF THIS LICENSE, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS, ASSEMBLERS, OR HOLDERS OF
COPYRIGHT OR OTHER LEGAL PRIVILEGE BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
LIABILITY, WHETHER IN ACTION OF CONTRACT, TORT, OR OTHERWISE ARISING FROM, OUT
OF, OR IN CONNECTION WITH THE WORK OR THE USE OF OR OTHER DEALINGS IN THE WORK.
