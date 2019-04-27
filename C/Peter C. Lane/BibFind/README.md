# BibFind

This program lets you search for entries in a bibliography 
written in BibTeX .bib format, and either copy them to a word processor 
or text editor using the system clipboard, or mark them to save as 
a complete reference list.

Compiling
---------

The program can be compiled on an Atari using the AHCC C Compiler.  

* bibfind.prj is the project file to build a standalone program.  Read 
the comments in bibfind.prj about the RSC file. 
* bibacc.prj is the project file to build as an accessory.  Read the 
comments in bibacc.prj about the RSC file.
* bibtest.prj builds a test program to ensure the biblio parsing is correct.

(On version 5.3 of AHCC, you need to copy the definitions of FL3D... 
from SINCLUDE\AES.H to INCLUDE\AES.H when compiling the .ACC.)

License
-------

BibFind is copyright (c) 2015-16, Peter Lane.

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


