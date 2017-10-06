

                              README file for


               Bywater BASIC Interpreter/Shell, version 2.21
               ---------------------------------------------

                    Copyright (c) 1993, Ted A. Campbell
                  for bwBASIC version 2.10, 11 October 1993

               Version 2.20 modifications by Jon B. Volkoff,
                             25 November 1995

               Version 2.21 modifications by Matthias Jaap,
                             28 August 2001


DESCRIPTION:

   The Bywater BASIC Interpreter (bwBASIC) implements a large
   superset of the ANSI Standard for Minimal BASIC (X3.60-1978)
   and a significant subset of the ANSI Standard for Full BASIC
   (X3.113-1987) in C. It also offers shell programming facilities
   as an extension of BASIC. bwBASIC seeks to be as portable
   as possible.

   This version of Bywater BASIC is released under the terms of the 
   GNU General Public License (GPL), which is distributed with this 
   software in the file "COPYING".  The GPL specifies the terms 
   under which users may copy and use the software in this distribution.

   A separate license is available for commercial distribution,
   for information on which you should contact the author.

IMPROVEMENTS OVER PREVIOUS VERSION (2.21):

   * added commandos ASIN (arcus sinus) and ACOS (arcus cosinus)

   * severall changes were made to make the program Atari compatible. Even
     the rmdir/mkdir command works


IMPROVEMENTS OVER PREVIOUS VERSION (2.10):

   * Plugged numerous memory leaks, resolved memory overruns and allocation
     difficulties.

   * General cleanup and bug fixes, too many to list in detail here.
     The major problem areas addressed were:

      - RUN command with file name argument
      - nested and cascaded FOR-NEXT loops
      - PRINT USING
      - EOF, LOF functions
      - string concatenation
      - operator hierarchy
      - multi-level expression evaluation
      - hex constant interpretation
      - hex and octal constants in INPUT and DATA statements

   * Added a CLOSE all files feature (when no argument supplied).

   * Added a unary minus sign operator.

   * Added a MID$ command to complement the MID$ function.

   * Added a RENUM facility in a standalone program.

   * Added checking in configure for unistd.h (important on Sun systems).


OBTAINING THE SOURCE CODE:

   The source code for bwBASIC 2.20 is available immediately by
   anonymous ftp. To obtain the source code, ftp to site ftp.netcom.com,
   cd to pub/rh/rhn and get the file bwbasic-2.20.uu. Or you may receive
   a copy by e-mail by writing to Jon Volkoff at eidetics@cerf.net.


COMMUNICATIONS:

   email:  tcamp@delphi.com  (for Ted Campbell)
           eidetics@cerf.net (for Jon Volkoff)


A LIST OF BASIC COMMANDS AND FUNCTIONS IMPLEMENTED in bwBASIC 2.20:

   Be aware that many of these commands and functions will not be
   available unless you have set certain flags in the header files.

   ABS( number )
   ASC( string$ )
   ATN( number )
   CALL subroutine-name
   CASE constant | IF partial-expression | ELSE
   CHAIN file-name
   CHDIR pathname
   CHR$( number )
   CINT( number )
   CLEAR
   CLOSE [[#]file-number]...
   CLS
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
   DO NUM|UNNUM
   DO [WHILE expression]
   EDIT		(* depends on variable BWB.EDITOR$)
   ELSE
   ELSEIF
   END FUNCTION | IF | SELECT | SUB
   ENVIRON variable-string$ = string$
   ENVIRON$( variable-string )
   EOF( device-number )
   ERASE variable[, variable]...
   ERL
   ERR
   ERROR number
   EXIT FOR|DO
   EXP( number )
   FIELD [#] device-number, number AS string-variable [, number AS string-variable...]
   FILES filespec$	(* depends on variable BWB.FILES$)
   FOR counter = start TO finish [STEP increment]
   FUNCTION function-definition
   GET [#] device-number [, record-number]
   GOSUB line | label
   GOTO line | label
   HEX$( number )
   IF expression THEN [statement [ELSE statement]]
   INKEY$
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
   LOCATE
   LOF( device-number )
   LOG( number )
   LOOP [UNTIL expression]
   LSET string-variable$ = expression
   MERGE file-name
   MID$( string$, start-position-in-string[, number-of-spaces ] )
   MKD$( number )
   MKDIR pathname
   MKI$( number )
   MKS$( number )
   NAME old-file-name AS new-file-name
   NEW
   NEXT counter
   OCT$( number )
   ON variable GOTO|GOSUB line[,line,line,...]
   ON ERROR GOSUB line | label
   OPEN O|I|R, [#]device-number, file-name [,record length]
        file-name FOR INPUT|OUTPUT|APPEND AS [#]device-number [LEN = record-length]
   OPTION BASE number
   POS
   PRINT [# device-number,][USING format-string$;] expressions...
   PUT [#] device-number [, record-number]
   RANDOMIZE number
   READ variable[, variable]...
   REM string
   RENUM
   RESTORE line
   RETURN
   RIGHT$( string$, number-of-spaces )
   RMDIR pathname
   RND( number )
   RSET string-variable$ = expression
   RUN [line]|[file-name]
   SAVE file-name
   SELECT CASE expression
   SGN( number )
   SIN( number )
   SPACE$( number )
   SPC( number )
   SQR( number )
   STOP
   STR$( number )
   STRING$( number, ascii-value|string$ )
   SUB subroutine-name
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
