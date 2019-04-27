Bib Find
========

This program lets you search for entries in a bibliography 
written in BibTeX .bib format, and copy them to a word processor or 
text editor using the system clipboard, or save to file as a reference 
list.

When run, the program displays a single window, containing information 
about a single record.  All options are available in the menu or through 
key commands.  Move back and forth in the list using the N/P keys or 
the left/right arrows.

Find records matching one or more search terms from the Find dialog:
control-F will bring up the Find dialog.  Enter one or more search 
terms separated by spaces and click 'Find'.  The program searches all 
parts of the record, including type and id, for the entered terms, 
ignoring case.  Note this is a full text search, so searching for 'ST' 
will find records with words such as 'mist'.  To return to showing 
the full list, do a search with no search terms.

Entries are copied to the clipboard in one of four ways, using 
the menu or the indicated control key:

1. the bibtex id (useful for latex or asciidoc documents), with ^C; 
2. an (author, year) style in-text citation, with ^R;
3. a Harvard-style reference (for author-year citations), to place 
   in a reference list, with ^H; and 
4. an IEEE-style reference (for numeric citations), also for 
   the reference list, with ^I.

Entries can be marked, using the 'm' key to toggle the marked state.
All marks can be removed using ^K.  Marks are not affected by 'Find'.
Two options are available in the 'File' menu to save the marked records 
as sorted reference lists to a file:

1. in Harvard style
2. in IEEE style 

Some information about the current list of records can be displayed from 
the 'Statistics' menu: a bar chart shows the number of records of 
each type, or each year of publication.

For more information and downloads see: http://peterlane.info/bibfind.html

Installation
------------

The program can be run either as a standalone program or as a desk accessory.
Copy files from the 'Firebee' folder, as appropriate.

1. To run as a standalone program:

The files BIBFIND.PRG and BIBFIND.RSC should be kept together.
Place your BIBLIO.BIB file in the same folder.

2. To run as a desk accessory:

Place the file BIBFIND.ACC in the root folder of your boot drive.
Place your BIBLIO.BIB file in the same folder.

Also included is a sample BIBLIO.BIB file.

Files for the Firebee have been compiled and tested under Mint (they do not 
work under FireTOS).

Source/Issues
-------------

Source code is available: https://github.com/petercrlane/bibfind

Any problems/requests, please raise as github issues.

The code can be compiled with the AHCC C compiler using the provided .PRJ files. 

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


