*
*
*
*                --- *  WORDSORT.ASM V1.1 dd 28/5/1988  * ---
*
*
* This program was written by:
*
*                             E. van Herk
*                             Wakkerstraat 18/1
*                             1097 CE Amsterdam
*                             Netherlands
*
* Purpose: to output an alphabetically sorted list of all words appearing
* in a given input text.
*
* Machine: Atari ST with at least 330 K of free memory.
*
* Designed and tested on an 1040 STF, it should work on all Atari ST
* computers
*
* It is hereby placed in the public domain, with the restriction that
* it shall not be sold for profit, or copied without this header.
*
* This is a program written in assembler, after a C program written by
* E. van Herk, after a Pascal program written by Dick Pountain, in BYTE,
* July 1987 p. 275. The C program was disassembled and the code then 
* extensively rewritten to improve the speed of operation by a factor of
* 3 or 4 and the code size by a factor of 4.
*
* Parts of the program produced by the megamax C compiler may still be
* recognized by being in UPPERCASE.
*
* This sourcecode will assemble without changes on the Hisoft Devpac 
* assembler package, version 1.
*
* Goodie: the program recognizes the Atari characters for Ñç† etc.,
* so that words are not cut in two if a special character turns up.
*
* Restrictions: first letters of words must be in A-Z or a-z, and 
* special characters are sorted on their ascii values.(So that azimuth
* will come before aziâ)
*
* Numbers 0-9 are also allowed. All words are converted to lowercase.
* The program has been tested on Firstword+ files, and probably works 
* on most wordprocessor files.
* Hyphe-nated words are split into two by the program.
* Apostrophes (as in it's) are also regarded as being part of a word.
* 
* The program is quite fast, a 200 K textfile was completely sorted in
* 72 seconds (running from a ramdisk, running the program from floppy disk 
* will be rather slower ), yielding a list of 4700 words,
* and a 30 K file was sorted in just over 5 seconds.
*
* Algorithm: an array of 26 linked lists is kept, one list for each
* starting letter, and every word is read in and linked into its proper
* position. If it is already in the list it is discarded.
*
* The complete list is kept in memory and the space allotted is 300.000
* bytes which should be enough for the largest textfiles. ( something
* like 20,000 different words may be accommodated.) If this should prove 
* restrictive a larger amount may be allotted by changing the value
* in the malloc call.
*
* The author welcomes constructive criticism, bug reports, complaints
* and suggestions for improvement. Send a letter to the above address
* or leave a message to Bart van Herk on BBS Microlines 020-736008
*
* Enjoy the program!
*
* Changes in version 1.1 : 
*
* - 60 bytes of superfluous code have been removed.
* - The program has been speeded up 2 or 3 % by changing the order of the
*   letter validity tests. 
* - A bug which caused every last letter in the output buffer to be 
*   dropped has been corrected.
* - A bug which caused the program to crash if eof occurred right after a
*   valid letter has been corrected
* - A bug which caused the program to write a large output file of garbage
*   if presented with an input file that was empty or contained only 
*   non-letters has been corrected.
* - The disk buffers have been enlarged to 10 K to speed up operation from
*   floppy disk by 10 to 20 % 
*
* ------------------------------------------------------------------------

