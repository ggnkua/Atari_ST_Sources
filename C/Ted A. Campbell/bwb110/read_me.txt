

                        Bywater Software Announces
                        the First Public Release of


               Bywater BASIC Interpreter/Shell, version 1.10
               ---------------------------------------------

                    Copyright (c) 1992, Ted A. Campbell
                 for bwBASIC version 1.10, 1 November 1992



DESCRIPTION:

   The Bywater BASIC Interpreter (bwBASIC) implements a large
   superset of the ANSI Standard for Minimal BASIC (X3.60-1978)
   implemented in ANSI C, and offers a simple interactive environ-
   ment including some shell program facilities as an extension of
   BASIC. The interpreter has been compiled successfully on a range
   of ANSI C compilers on varying platforms with no alterations
   to source code necessary. 


OBTAINING THE SOURCE CODE:

   The source code for bwBASIC 1.10 will be posted to network news
   groups and is available immediately by anonymous ftp. To obtain
   the source code, ftp to site duke.cs.duke.edu, cd to /pub/bywater
   and get the appropriate files.  These are as follows:

   bwb110.zip	Source code in ZIP compressed format, with text lines
   		concluded with CR-LF. This is the appropriate version
   		for DOS-based computers.

   bwb110.tar.Z	Tar'd and compressed source code with text lines con-
   		cluded with LF only.  This is the appropriate version
   		for Unix-based computers.


COMMUNICATIONS:

   Ted A. Campbell
   Bywater Software
   P.O. Box 4023
   Duke Station
   Durham, NC  27706
   USA

   email:  tcamp@acpub.duke.edu


A LIST OF BASIC COMMANDS AND FUNCTIONS IMPLEMENTED in bwBASIC 1.10:

   ABS( number )
   ASC( string$ )
   ATN( number )
   ASIN( number )
   ACOS( number )
   CHAIN [MERGE] file-name [, line-number] [, ALL]
   CHR$( number )
   CINT( number )
   CLEAR
   CLOSE [[#]file-number]...
   COMMON variable [, variable...]
   COS( number )
   CSNG( number )
   CVD( string$ )
   CVI( string$ )
   CVS( string$ )
   DATA constant[,constant]...
   DATE$
   DEF FNname(arg...)] = expression
   DEFDBL letter[-letter](, letter[-letter])...
   DEFINT letter[-letter](, letter[-letter])...
   DEFSNG letter[-letter](, letter[-letter])...
   DEFSTR letter[-letter](, letter[-letter])...
   DELETE line[-line]
   DIM variable(elements...)[variable(elements...)]...
   END
   ENVIRON variable-string = string
   ENVIRON$( variable-string )
   EOF( device-number )
   ERASE variable[, variable]...
   ERL
   ERR
   ERROR number
   EXP( number )
   FIELD [#] device-number, number AS string-variable [, number AS string-variable...]
   FOR counter = start TO finish [STEP increment]
   GET [#] device-number [, record-number]
   GOSUB line
   GOTO line
   HEX$( number )
   IF expression THEN statement [ELSE statement]
   INPUT [# device-number]|[;]["prompt string";]list of variables
   INSTR( [start-position,] string-searched$, string-pattern$ )
   INT( number )
   KILL file-name
   LEFT$( string$, number-of-spaces )
   LEN( string$ )
   LET variable = expression
   LINE INPUT [[#] device-number,]["prompt string";] string-variable$
   LIST line[-line]
   LOAD file-name
   LOC( device-number )
   LOF( device-number )
   LOG( number )
   LSET string-variable$ = expression
   MERGE file-name
   MID$( string$, start-position-in-string[, number-of-spaces ] )
   MKD$( double-value# )
   MKI$( integer-value% )
   MKS$( single-value! )
   NAME old-file-name AS new-file-name
   NEW
   NEXT counter
   OCT$( number )
   ON variable GOTO|GOSUB line[,line,line,...]
   ON ERROR GOSUB line
   OPEN O|I|R, [#]device-number, file-name [,record length]
        file-name FOR INPUT|OUTPUT|APPEND AS [#]device-number [LEN = record-length]
   OPTION BASE number
   POS
   PRINT [# device-number,][USING format-string$;] expressions...
   PUT [#] device-number [, record-number]
   RANDOMIZE number
   READ variable[, variable]...
   REM string
   RESTORE line
   RETURN
   RIGHT$( string$, number-of-spaces )
   RND( number )
   RSET string-variable$ = expression
   RUN [line][file-name]
   SAVE file-name
   SGN( number )
   SIN( number )
   SPACE$( number )
   SPC( number )
   SQR( number )
   STOP
   STR$( number )
   STRING$( number, ascii-value|string$ )
   SWAP variable, variable
   SYSTEM
   TAB( number )
   TAN( number )
   TIME$
   TIMER
   TROFF
   TRON
   VAL( string$ )
   WEND
   WHILE expression
   WIDTH [# device-number,] number
   WRITE [# device-number,] element [, element ].... 

   If DIRECTORY_CMDS is set to TRUE when the program is compiled,
   then the following commands will be available:

   CHDIR pathname
   MKDIR pathname
   RMDIR pathname


