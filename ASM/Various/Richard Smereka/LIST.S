*****************************************************************************
*                              FILE LISTER                                  * 
*                           By Richard Smereka                              *
*                      COMPUTE!'s ST Disk and Magazine                      *
*                       February 1987- Vol. 2, No. 1                        *
*                      ½ 1987 COMPUTE! Publications/ABC                     *
*                                                                           *
* Program to list a text/source file to the screen/printer with optional    *
* line numbers, printer format, screen pause, and a choice of numeric       *
* padding characters.                                                       *
*                                                                           *
* The available options are:                                                *
*                                                                           *
*          -n number lines with listing (default=line numbers off)          *
*          -p output also to the printer (default=printer output off)       *
*          -s output to the screen (default=screen on)                      *
*          -w screen wait for a key (default=wait on)                       *
*          -f full printer format (default=format on)                       *
*          -z pad line numbers with zeros (default=zeros on)                *
*          -t used with TTP application to pause before returning to        *
*             desktop (default=TTP off)                                     *
*                                                                           *
* The alternative to printing the line numbers padded with zeros is to pad  *
* them with spaces (which is what occurs if the '-z' option is given.       *
*                                                                           *
* Full printer format means 55 lines per page, and a heading appearing at   *
* the top of each line stating the file name and the page number.           *
*                                                                           *
* Note that this program can be executed from ST Shell, or installed as a TTP    *
* application and executed from the desktop.                                *
*                                                                           *
* The syntax from ST Shell is:                                                   *
*                                                                           *
*           list [-n -p -s -w -f -z -t][x:][\path\]filename                 *
*                                                                           *
* Where 'x:' is the optional drive specification, and '\path\' is the       *
* optional path name.                                                       *
*                                                                           *
* The syntax from the program as a TTP application is:                      *
*                                                                           *
*                [-n -p -s -w -f -z -t][x:][\path\]filename                 *
*                                                                           *
* Where the names are the same as described for execution with ST Shell.        *
*****************************************************************************

*****************************************************************************
*                              Program Equates                              *
*****************************************************************************
 
gemdos          equ     1
conin           equ     1
getdta          equ     $2f
setdta          equ     $1a
sfirst          equ     $4e
malloc          equ     $48
open            equ     $3d
read            equ     $3f
mfree           equ     $49
close           equ     $3e
mshrink         equ     $4a
prtline         equ     9
conout          equ     2
prnout          equ     5
term            equ     0
maxscr          equ     18
maxprn          equ     55

****************************************************************************
*                              Main Body                                   *
****************************************************************************

*******************************
* Shrink Size of Program Area *
*******************************

start           move.l  a7,a5           save user SP
                move.l  #unstk,a7
                move.l  4(a5),a5        get base page address
                move.l  $c(a5),d0
                add.l   $14(a5),d0
                add.l   $1c(a5),d0
                add.l   #$100,d0        allocate 1K of user stack space
                move.l  d0,-(sp)
                move.l  a5,-(sp)
                move    d0,-(sp)        
                move    #mshrink,-(sp)  function MSHRINK
                trap    #gemdos
                add.l   #12,sp
                lea.l   129(a5),a0      pointer to command string

*******************************
* Check for Null Command Line *
*******************************

                cmpi.b  #31,(a0)        nothing in command line?
                bhi     okparm          no, continue
                addq.b  #1,optflag      force usage string to print
                bra     exit            exit program

**********************
* Parse Command Line *
**********************

okparm          bsr     ispace          remove leading spaces (1st para.)
                bsr     optpar          parse 1st parameter
                cmpi.b  #0,optflag      error in parameter?
                bne     exit            yes, exit program
                cmpi.b  #0,nopt         any more options?
                beq     okparm          yes, go again

******************************
* Check for Output Indicated *
******************************

                cmpi.b  #0,optprt       printer output desired?
                bne     exfile          yes, continue
                cmpi.b  #0,optscr       screen output desired?
                bne     exfile          yes, continue
                movea.l #outerr,a2      address of output error message
                bsr     pline
                addq.b  #1,optflag      indicate usage error
                bsr     newline
                bra     exit

********************
* Extract Filename *
********************

exfile          bsr     ispace          remove leading spaces
                movea.l #fname,a1       initialize pointer to filename buffer
                bsr     blockm          do block memory move

************************
* Search for Disk File *
************************

noprt           bsr     ffile           do search
                cmpi.b  #0,optflag      error in search?
                bne     exit            yes, exit program

********************************
* Allocate Memory to Read File *
********************************

                bsr     alloc           do memory allocate
                cmpi.b  #0,endflag      error in allocation?
                bne     exit            yes, exit program

**********************
* Open File for Read *
**********************

                bsr     fileopen        do open file
                cmpi.b  #0,endflag      error in opening file
                bne     exit2           de-allocate memory and exit program

*****************
* Read the File *
*****************

                bsr     fileread

************************
* Print Intro. Message *
************************

                movea.l #intro,a2
                bsr     pline
                bsr     newline
                bsr     newline

                cmpi.b  #0,optprt       print option on?
                beq     standb          no, continue
                movea.l #intro,a6
                bsr     prnstring
                movea.l #crlf,a6
                bsr     prnstring
                movea.l #crlf,a6
                bsr     prnstring

**************************************************
* Print Stand by Message if Screen Option is Off *
**************************************************

standb          cmpi.b  #0,optscr       screen output option off?
                bne     dofile          no, continue
                movea.l #nosmg1,a2
                bsr     pline
                movea.l #fname,a2
                bsr     pline
                movea.l #nosmg2,a2
                bsr     pline
                bsr     newline

************************
* Output File Contents *
************************

dofile          bsr     outfile

********************
* Close Input File *
********************

                move.w  fhandle,-(sp)   file handle on stack
                move.w  #close,-(sp)    function CLOSE
                trap    #gemdos
                addq.l  #4,sp

**********************
* De-allocate Memory *
**********************

exit2           move.l  memptr,d0
                move.l  d0,-(sp)        buffer address on stack
                move.w  #mfree,-(sp)    function MFREE
                trap    #gemdos
                addq.l  #6,sp
                
*****************************************************************************
*                              Exit Program                                 *
*****************************************************************************

*****************************************
* If Usage Error, Display Program Usage *
*****************************************

exit            cmpi.b  #0,optflag      usage error?
                beq     final           no, exit program
                movea.l #usage,a2       address of usage string
                bsr     pline           print it
                bsr     newline         do CR/LF
                bra     exitmsg
final           cmpi.b  #0,opttp        TTP option set?
                beq     terminate       no, exit program
                bsr     newline
exitmsg         movea.l #ttpmsg,a2      address of TTP exit message
                bsr     pline           print it
                move.w  #conin,-(sp)    wait for a key before exit
                trap    #gemdos
                addq.l  #2,sp

terminate       move.w  #term,-(sp)     function PTERM0
                trap    #gemdos
                .page
*****************************************************************************
*                            Program Subroutines                            *
*****************************************************************************

*****************************************************************************
*               Subroutine to Ignore Spaces in the Command Line             *
*****************************************************************************

ispace          cmpi.b  #32,(a0)        current byte=space?
                bne     idone           no, exit routine
                adda    #1,a0           point to next byte
                bra     ispace          do comparison again
idone           rts

****************************************************************************
*               Subroutine to Parse Command Line for Options               *
****************************************************************************

optpar          cmpi.b  #'-',(a0)       char=hyphen?
                beq     okopt           yes, continue
                addq.b  #1,nopt         indicate no more options
                bra     efin

*************************************
* Convert to Uppercase if Necessary *
*************************************

okopt           cmpi.b  #'a',(a0)       < 'a'?
                bcs     noconv          yes, bypass
                cmpi.b  #'z',(a0)       > 'z'?
                bhi     noconv
                addi.b  #32,(a0)        make to upper case

********************
* Test for Options *
********************

noconv          adda    #1,a0           point to next byte
                cmpi.b  #'N',(a0)       char='N'?
                bne     ptest           no, test for 'P'
                addq.b  #1,optnum       set line number flag high
                bra     edone           
ptest           cmpi.b  #'P',(a0)       char='P'?
                bne     stest           no, test for 'S'
                addq.b  #1,optprt       set printer option high
                bra     edone
stest           cmpi.b  #'S',(a0)       char='S'?
                bne     wtest           no, test for 'W'
                move.b  #0,optscr       set option no screen
                bra     edone
wtest           cmpi.b  #'W',(a0)       char='W'?
                bne     ftest           no, test for 'F'
                move.b  #0,optwait      set screen wait off
                bra     edone
ftest           cmpi.b  #'F',(a0)       char='F'?
                bne     ztest           no, test for 'Z'
                move.b  #0,optform      set printer format off
                bra     edone
ztest           cmpi.b  #'Z',(a0)       char='Z'?
                bne     ttest           no, test for 'T'
                move.b  #0,optzero      set zero pad off
                bra     edone
ttest           cmpi.b  #'T',(a0)       char='T'?
                beq     okttp           yes
                movea.l #opterr,a2      address of option error
                addq.b  #1,optflag      set error flag high
                bsr     pline           print error message
                bra     newline         do CR/LF
okttp           addq.b  #1,opttp        set TTP pause on
edone           adda    #1,a0           pointer to next byte
efin            rts

****************************************************************************
*                 Subroutine to Perform a Block Memory Move                *
****************************************************************************

blockm          cmpi.b  #32,(a0)        byte=space?
                bne     chend           no, move byte
                adda    #1,a0           ignore space, point to next byte
                bra     blockm          do next byte
chend           cmpi.b  #13,(a0)        byte > CR?
                bhi     okmove          yes, move byte
                move.b  #0,(a1)+        indicate end of filename
                bra     eblock          exit routine
okmove          move.b  (a0)+,(a1)+     transfer byte
                bra     blockm          not zero, move next byte
eblock          rts

**************************************************************************
*                     Subroutine to Find a Disk File                     *
**************************************************************************

*******************
* Get Current DTA *
*******************

ffile           move.w  #getdta,-(sp)   function GETDTA
                trap    #gemdos
                addq.l  #2,sp
                move.l  d0,tempdta      save dta

***************     
* Set New DTA *
***************

                move.l  #dta,-(sp)      address of new dta buffer
                move.w  #setdta,-(sp)   function SETDTA
                trap    #gemdos
                addq.l  #6,sp

*******************
* Search for File *
*******************

                move.w  #0,-(sp)        zero=normal file search
                move.l  #fname,-(sp)    filename
                move.w  #sfirst,-(sp)   function SFIRST
                trap    #gemdos
                addq.l  #8,sp
                move.w  d0,errcode      save SFIRST return code

*******************
* Restore Old DTA *
*******************

                move.l  tempdta,-(sp)   old dta address
                move.w  #setdta,-(sp)   function SETDTA
                trap    #gemdos
                addq.l  #6,sp

*********************
* Check Return Code *
*********************

                cmpi.w  #0,errcode      return code=zero?
                beq     okfile          yes, file found
                movea.l #filerr,a2      address of file error message
                bsr     pline           print it
                movea.l #fname,a2       address of file name
                bsr     pline
                addq.b  #1,optflag      set error flag high
                bra     newline         do CR/LF
okfile          rts

***************************************************************************
*                Subroutine to Allocate Memory for File Buffer            *
***************************************************************************

alloc           move.l  dtasize,d0
                move.l  d0,-(sp)        size of file (in bytes)
                move.w  #malloc,-(sp)   function MALLOC
                trap    #gemdos
                addq.l  #6,sp

*************************
* Was Buffer Allocated? *
*************************

                move.l  d0,memptr       save pointer to buffer
                cmpi.l  #0,d0           pointer=zero?
                bne     okmem           no, memory was allocated
                movea.l #memerr,a2      address of memory error string
                bsr     pline
                addq.b  #1,endflag      indicate end of program
                bra     newline
okmem           rts

***************************************************************************
*                    Subroutine to Open the Disk File                     *
***************************************************************************

fileopen        move.w  #0,-(sp)        read access only
                move.l  #fname,-(sp)    address of file name buffer
                move.w  #open,-(sp)     function OPEN
                trap    #gemdos
                addq.l  #8,sp

********************************
* Check for Read Error on Open *
********************************

                move.w  d0,fhandle      save file handle
                cmpi.w  #0,d0   
                bpl     okopen          ok if positive handle
                movea.l #openerr,a2     address of open error string
                bsr     pline
                movea.l #fname,a2       address of file name
                bsr     pline
                addq.b  #1,endflag      indicate end of program
                bra     newline
okopen          rts

*****************************************************************************
*               Subroutine to Read the Disk File Into the Buffer            *
*****************************************************************************

fileread        move.l  memptr,d0
                move.l  d0,-(sp)        pointer returned by MALLOC
                move.l  dtasize,d0
                move.l  d0,-(sp)        file size (in bytes)
                move.w  fhandle,-(sp)   file handle returned by OPEN
                move.w  #read,-(sp)     function READ
                trap    #gemdos
                add.l   #12,sp

****************************
* Calculate Ending Pointer *
****************************

                move.l  memptr,endptr   start of buffer
                move.l  dtasize,d6      file size in d6
                add.l   d6,endptr       add size of disk file
                move.l  memptr,startptr preserve start of buffer
                rts

***************************************************************************
*         Subroutine to Output Contents of Buffer to Screen/Printer       *
***************************************************************************

**************
* Initialize *
**************

outfile         move.w  #1,d1           starting line number
                movea.l  startptr,a3    a3 is buffer pointer

************************************
* Do Initial Headings (if desired) *
************************************

                cmpi.b  #0,optprt       printer output?
                beq     numout          no
                cmpi.b  #0,optform      printer format?
                beq     numout          no
                bsr     incpline        do headings

*************************************
* Output Line Number (if requested) *
*************************************

numout          cmpi.b  #0,optnum       line numbers requested?
                beq     passnum         no, bypass
                move.w  d1,d2
                bsr     outnum          print line number
                cmpi.b  #0,endflag      error during line number?
                bne     filend          yes, exit routine

***********************
* Output Character(s) *
***********************

passnum         move.b  (a3)+,d2        current byte in d2
                cmpi.b  #13,d2          byte=CR?
                beq     linend          end of line
                cmpi.b  #10,d2          byte=LF?
                beq     linend          end of line
                bsr     charscreen      print char.
                cmpi.b  #0,endflag      error during output?
                bne     filend          yes, exit routine
                cmpa.l  endptr,a3       reached end of buffer?
                bcc     filend          yes, exit routine
                bra     passnum         do next char.
linend          bsr     finline         output end of line chars.
                cmpi.b  #0,endflag      error or end?
                bne     filend          yes, exit routine
                bra     numout          do next line
filend          rts

***************************************************************************
*     Line Termination and Check for Screen Wait and Printer Paging       *
***************************************************************************

*************************
* Terminate Output Line *
*************************

finline         move.b  #13,d2          dec 13=CR
                bsr     charscreen      print it
                move.b  #10,d2          dec 10=LF
                bsr     charscreen
                cmpi.b  #0,endflag      error during print?
                bne     pass1           yes, exit routine
                addq.w  #1,d1           increment line counter

**************************
* Screen Wait Management *
**************************

                cmpi.b  #0,optscr       screen output active?
                beq     incpline        no, check printer
                cmpi.b  #0,optwait      screen wait active?
                beq     incpline        no, check printer
                addq.b  #1,slcount      increment screen lines
                cmpi.b  #maxscr,slcount reached max. screen lines?
                bne     incpline        no, do printer

                bsr     newline
                movea.l #waitmsg,a2     address of wait message
                bsr     pline
                move.w  #conin,-(sp)    function CONIN
                trap    #gemdos
                addq.l  #2,sp
                move.b  d0,d5
                bsr     newline
                bsr     newline
                cmpi.b  #'A',d5         'A' entered?
                beq     chabort
                cmpi.b  #'a',d5
                bne     noabort
chabort         addq.b  #1,endflag      indicate end of program
                bra     pass1           and exit routine
noabort         cmpi.b  #'N',d5         'N' entered?
                beq     chwait
                cmpi.b  #'n',d5
                bne     waiton
chwait          move.b  #0,optwait      turn wait off
waiton          move.b  #0,slcount      reset screen line counter

*****************************
* Printer Format Management *
*****************************

incpline        cmpi.b  #0,optprt       printer output active?
                beq     comptr          no
                cmpi.b  #0,optform      format option active?
                beq     comptr          no
                addq.b  #1,plcount      increment printer line count
                cmpi.b  #maxprn,plcount reached max. lines per page?
                bne     comptr          no
                addq.w  #1,pagcount     increment page count
                move.b  #0,plcount      reset line count
                cmpi.w  #1,pagcount     first page?
                beq     passpage        yes, skip form feed
                move.w  #$c,d2          $c=form feed
                bsr     charprt         print it
                cmpi.b  #0,endflag      error during print?
                bne     pass1           yes, exit routine
passpage        movea.l #head1,a6       address of 1st part of page heading
                bsr     prnstring       print it
                cmpi.b  #0,endflag      error during print?
                bne     pass1           yes, exit routine
                movea.l #fname,a6       address of filename
                bsr     prnstring
                cmpi.b  #0,endflag
                bne     pass1
                move.w  #13,d2          move print head to start of line
                bsr     charprt
                movea.l #spacepad,a6    address of space filled string
                bsr     prnstring
                cmpi.b  #0,endflag
                bne     pass1
                movea.l #head2,a6       address of 2nd part of page heading
                bsr     prnstring
                cmpi.b  #0,endflag
                bne     pass1
                move.b  optscr,d3       save screen output flag
                move.b  #0,optscr       force no screen output
                move.w  pagcount,d2     print page number
                bsr     outnum
                cmpi.b  #0,endflag
                bne     pass1
                move.b  d3,optscr       restore screen output flag
                movea.l #crlf,a6        address of CR/LF string
                bsr     prnstring
                cmpi.b  #0,endflag
                bne     pass1
                movea.l #crlf,a6
                bsr     prnstring
                cmpi.b  #0,endflag
                bne     pass1

***********************
* Check for Line Feed *
***********************

comptr          cmpa.l  endptr,a3       reached end of buffer?
                bcs     noend           no, continue
                addq.b  #1,endflag      raise end flag
                bra     pass1           exit routine
noend           cmpi.b  #10,(a3)
                bhi     pass1           no control char, exit routine
                adda    #1,a3           skip char.
                bra     comptr          check next char.
pass1           rts

****************************************************************************
*                Subroutine to Output Numbers as ASCII Digits              *
****************************************************************************

******************
* Initialization *
******************

outnum          move.w  d2,d7           current line number in d7
                andi.l  #$ffff,d7       mask out MSW
                movea.l #buf,a5         address of ASCII buffer

**************************
* Calculate ASCII Number *
**************************

dodec           move.l  d7,d6           save line number in d6
                divu.w  #10,d6          divide by 10
                move.w  d6,d7           quotent in d7
                swap    d6              remainder in d6
                addi.w  #$30,d6         make into ASCII
                move.b  d6,(a5)+        put digit into buffer
                cmpi.w  #0,d7           quotent=zero?
                bne     dodec           no, do next digit

*******************
* Pad Line Number *
*******************

                move.l  #4,d7           four digits
                move.l  a5,d6           address of last digit+2
                sub.l   #buf,d6         subtract start buffer address
                sub.l   #2,d6       
                sub.l   d6,d7           d7=number of char to Pad
                sub.l   #3,d7
                bmi     nextdigit       if <0 don't pad

nextnum         cmpi.b  #1,optzero      zero pad flag high?
                beq     zeron           yes
                move.b  #32,d2          pad with spaces
                bra     gopad
zeron           move.b  #'0',d2         padding character       
gopad           bsr     charscreen      print padding char.
                cmpi.b  #0,endflag      error during print?
                bne     endout          yes, exit routine
                dbf     d7,gopad        do next pad

***********************
* Output ASCII Number *
***********************

nextdigit       cmpa.l  #buf,a5         pointer=start of buffer?
                beq     numdone         yes, finished numbers
                move.b  -(a5),d2        current digit in d2
                bsr     charscreen      print it
                cmpi.b  #0,endflag      error?
                bne     endout          yes, exit
                bra     nextdigit

numdone         move.b  #32,d2          output one space after number
                bsr     charscreen
endout          rts

****************************************************************************
*             Subroutine to Output a Character to Screen/Printer           *
****************************************************************************

charscreen      andi.w  #$ff,d2         mask out MSB
                cmpi.b  #0,optscr       screen output?
                beq     noscreen        no, continue
                move.w  d2,-(sp)
                move.w  #conout,-(sp)   function CONOUT
                trap    #gemdos
                addq.l  #4,sp
noscreen        cmpi.b  #0,optprt       output to printer?
                beq     exitchar        no, exit routine
                bsr     charprt         printer output
exitchar        rts

****************************************************************************
*               Subroutine to Output a Character to the Printer            *
****************************************************************************

charprt         move.w  d2,-(sp)        char. on stack
                move.w  #prnout,-(sp)   function PRNOUT
                trap    #gemdos
                addq.l  #4,sp

****************************
* Test for Printer Timeout *
****************************

                tst.w   d0              d0=zero?
                bne     okprn           no, exit routine
                addq.b  #1,endflag      indicate problem
                bsr     newline
                movea.l #prnerr,a2      address of printer error string
                bsr     pline           print it
                bra     newline
okprn           rts

***************************************************************************
*               Subroutine to Output String to the Printer                *
***************************************************************************

prnstring       move.b  (a6)+,d2        one char in d2
                beq     finstring       if zero byte, string finished
                ext.w   d2              extend to word
                bsr     charprt         print it
                cmpi.b  #0,endflag      error during print
                beq     prnstring       no, continue
finstring       rts
    
*******************************************
* Earily Entrance to Pline to Print CR/LF *
*******************************************

newline         movea.l #crlf,a2

***************************************************************************
*              Subroutine to Print a String of Text on Screen             *
***************************************************************************

pline           move.l  a2,-(sp)        address of string on stack
                move.w  #prtline,-(sp)  function print line
                trap    #gemdos
                addq.l  #6,sp
                rts
                .page
*****************************************************************************
*                               Program Data                                *
*****************************************************************************

buf             .ds.b   6               binary to ASCII buffer
fname           .ds.b   50              file name buffer
optnum          .dc.b   0               line number option flag
optprt          .dc.b   0               printer option flag
nopt            .dc.b   0               no more option flag
optzero         .dc.b   1               zero pad flag
optwait         .dc.b   1               screen wait flag
optform         .dc.b   1               printer format option
optscr          .dc.b   1               screen output flag
opttp           .dc.b   0               TTP pause option
pagcount        .dc.w   0               printer page counter
slcount         .dc.b   0               screen line count
plcount         .dc.b   54              printer line count
optflag         .dc.b   0               error flag
endflag         .dc.b   0               end of program flag
intro           .dc.b   "File Lister",0
head1           .dc.b   "File: ",0
head2           .dc.b   "Page ",0
spacepad        .dc.b   "                                        "
                .dc.b   "                      ",0
waitmsg         .dc.b   "A=Abort, N=No Wait, Any Other Key to Continue",0
opterr          .dc.b   "Unidentified Option Used",0    option error message
filerr          .dc.b   "Can't Open ",0 file error message
memerr          .dc.b   "File Too Large, Can't Allocate Memory",0
openerr         .dc.b   "Read Error Opening ",0
prnerr          .dc.b   "Trouble Communicating With Printer",0
outerr          .dc.b   "Error, No Output Requested",0
usage           .dc.b   "Usage is: list [-p -n -s -w -f -z -t][x:][\path\]"
                .dc.b   "filename",0
ttpmsg          .dc.b   "Press Any Key to Exit List Utility",0
nosmg1          .dc.b   "Stand By...Listing of ",0
nosmg2          .dc.b   " is in Progress",0     
crlf            .dc.b   13,10,0         CR/LF
errcode         .ds.w   1               SFIRST return code
dta             .ds.b   26              dta buffer
dtasize         .ds.l   1               file size (in bytes)
dtaname         .ds.b   14              file name
tempdta         .ds.l   1               holding area for previous DTA pointer
memptr          .ds.l   1               pointer to file buffer
fhandle         .ds.w   1               file handle
endptr          .ds.l   1               temporary pointers
startptr        .ds.l   1
                .bss
                .even
                .ds.l   256
unstk           .ds.l   1
                .end
