* Hexadecimal dump program by Silas Warner, MicroProse Software
**********************************************
*** Watch for SILENT SERVICE, coming soon! ***
**********************************************
*Appreciation to Jez San, who set me on the right track.
*To assemble the program:
*     AS68 DUMP
*     LINK68 DUMP.O
*     RELMOD DUMP.68K DUMP.TOS
*Then remove DUMP.O and DUMP.68K
*
*APSTART chunk to set stack and memory
start  move.l sp,a5
  move.l #ustk,sp 
  move.l 4(a5),a5
  move.l $c(a5),d0
  add.l $14(a5),d0
  add.l $1c(a5),d0
  add.l #$100,d0
  move.l d0,-(sp) *set up m-f call
  move.l a5,-(sp)
  move.w #0,-(sp)
  move.w #$4a,-(sp)
  trap #1    *do m-f call
  addq.l #4,sp
  move.l (sp)+,a5    *recover basepage
  addq.l #4,sp
  lea.l $80(a5),a1  *command string
  move.l $2c(a5),a2  *env string
*NOW THE PROGRAM STARTS
  lea.l start(pc),a5  *set PBR
   lea.l ustk(a5),sp  *use our own stack
  bra.s startup    *go do the program
*File comment header
  dc.b 13,10,10
  dc.b "Hexadecimal File Dump"
  dc.b 13,10
  dc.b "by Silas Warner."
  dc.b 13,10,10
  dc.b 0
  even
*Okay, do init stuff
startup  lea commstr(a5),a0  *to command string buffer
  clr.w d1
xfercom  move.b (a1)+,d0    *move command string
  move.b d0,(a0)+
  beq xferof
  addq.l #1,d1    *count characters
  cmp.b #78,d1    *up to 78
  bcs xfercom
xferof  move.b #0,(a0)    *zg
  tst.w commstr(a5)  *is command string zero?
  bne commgo    *no, use it
  lea.l commes(a5),a0  *ask for command string
  bsr wstring
commgo  lea.l commstr(a5),a6  *start command parsing
  move.l a6,wrdstor(a5)
parse  move.l wrdstor(a5),a6  *parse next word
  lea.l word(a5),a0
skspc  move.b (a6)+,d0    *skip over multiple blanks
  beq eline    *if zero byte, end parsing
  cmp.b #" ",d0    *is byte a space?
  beq skspc
  bra fstchr    *no, it's 1st byte of command
nxtchr  move.b (a6)+,d0    *get next byte from line
fstchr  move.b d0,(a0)+    *and put it in command word
  beq elparse    *if zero byte, EOL
  cmp.b #" ",d0    *is it a space?
  beq eparse    *Yes, end command
  bra nxtchr    *no, get next byte
elparse  subq.l #1,a6    *parser hit end of line
eparse  move.l a6,wrdstor(a5)  *store pars pointer back
  clr.b -(a0)    *clear off added space
  tst.b word+1(a5)  *next word now stored in word
  bne mbefile    *1-byte files not allowed
  move.b word(a5),d1  *check 1st char
  and.l #$1f,d1
  cmp.b #$13,d1    *is it an S?
  beq toscren
  cmp.b #$10,d1    *is it a P?
  beq toprter
  cmp.b #$17,d1    *is it a W?
  beq kwait
  bra parse    *No, ignore it

*end of command line
eline  tst.b printfg(a5)  *are we printing?
  bne exitprog    *yes, don't wait
  bsr wait
exitprog
  move.w #0,-(sp)  *call GEMDOS
  clr.l d0
  trap #1    *that's it! we gone!

*wait by order of command line
kwait  bsr wait
  bra parse

*set dump to screen
toscren  clr.w printfg(a5)
  lea.l scnmes(a5),a0  *tell the world
  bsr wstring  *printing to screen
  bra parse

*set dump to printer
toprter  move.w #$11,-(sp)
  trap #1    *is printer ready?
  addq.l #2,sp
  tst.b d0
  bne prtcan
  clr.w printfg(a5)  *printer not ready!
  lea.l pnrmes(a5),a0  *tell them so
  bsr wstring
  bra parse
prtcan  st.b printfg(a5)  *printer on!
  clr.w stopfg(a5)  *normally no STOP during print!
  lea.l prtmes(a5),a0  *tell the world
  bsr wstring  *dumping to printer
  bra parse

*load and dump a file
mbefile  clr.w killfg(a5)  *set up for CTRL-C
  lea.l filmes(a5),a0  *print file name
  bsr ostring
  lea.l word(a5),a0
  bsr ostring
  lea.l word(a5),a0
  bsr openrd    *try to open the file
  bpl opengod    *did it work?
  lea.l nfdmes(a5),a0  *no, tell us so
  bsr ostring
  bra parse
opengod  move.w d0,handle(a5)  *Yes, prepare to read file
  bsr newlinp
  clr.l d5    *d5 is dump count
rdachk  lea.l start(pc),a5  *make sure PBR is set
  move.w handle(a5),d1
  move.l #16,d0    *read 16 bytes
  lea.l chacter(a5),a0  *to chacter array
  bsr infile    *do it!
  bmi eofile    *if file error
  move.l d0,d6    *d6 is bytes read
  clr.l d4    *d4 is bytes dumped
  move.l d5,d1    *byte count
  swap d1      *print long address
  bsr hxpword
  swap d1
  bsr hxpword
  bsr dpspace
  bsr dpspace    *2 spaces (column 10)
  move.l #10,d3    *d3 is column count
  lea.l chacter(a5),a4
nxtbhx  move.w 0(a4,d4.w),d1  *get a word
  bsr hxpword    *and print it
  bsr dpspace
  addq.l #2,d4    *inc word count
  addq.l #5,d3    *and column count
  cmp.b d4,d6    *are we past dump ct?
  bhi nxtbhx
colit  bsr dpspace    *space over to colunmn 58
  addq.l #1,d3
  cmp.b #58,d3
  bcs colit
  clr.l d4    *set print ct back to 0
nxtdmp  move.b 0(a4,d4.w),d1  *now get a byte
  cmp.b #$20,d1    *is it a ctl byte?
  bcc palain
  move.b #".",d1
palain  bsr ochar    *and print it
  addq.l #1,d4    *try next byte
  cmp.b d4,d6    *are we past dump ct?
  bhi nxtdmp
  add.l d6,d5
  bsr newlinp
  tst.b killfg(a5)  *was CTRL-C hit?
  bne eofile    *Yes, end file
  cmp.b #16,d6    *was there a short read?
  beq rdachk    *no, next line

eofile  lea.l start(pc),a5
  move.w handle(a5),d1  *end of the dump file
  bsr closfil    *so close it
  lea.l dbline(a5),a0  *print an end line
  bsr ostring
  bra parse    *and look at command line again

ostring  tst.b printfg(a5)  *print a string
  bne pstring    *to printer?
  bra wstring    *no, to screen
pstring  clr.l d0    *print 1 char
  move.b(a0)+,d0    *at a time
  tst.b d0    *is it zero?
  bne pstrin1    *if not, print it
  rts
pstrin1  movem.l a0-a6/d1-d7,-(sp)
  move.w d0,-(sp)
  move.w #5,-(sp)    *GEMDOS for print char
  trap #1
  addq.l #4,sp
  movem.l (sp)+,a0-a6/d1-d7
  bra pstring

*print a hex word to screen or printer
hxpword  move.w d1,-(sp)  *thanks to Jez San
  lsr.w #8,d1
  lsr.w #4,d1
  bsr.s hxpnibbl  *1st nybble
  move.w (sp),d1
  lsr.w #8,d1
  bsr.s hxpnibbl  *2nd nybble
  move.w (sp),d1
  lsr.w #4,d1
  bsr.s hxpnibbl  *3rd nybble
  move.w (sp)+,d1
hxpnibbl
  and.w #15,d1  *finally print out ONE hex digit!
  cmp.b #9,d1
  bls.s hxpnib2
  add.b #7,d1
hxpnib2  add.b #"0",d1
*fall thru to
*print a char to screen or printer
ochar  tst.b printfg(a5)  *sending to printer?
  bne pchar
  bra wrchar    *no, go to screen
pchar  movem.l a0-a6/d0-d7,-(sp)
  move.w d1,-(sp)
  move.w #5,-(sp)    *GEMDOS for print
  trap #1
  addq.l #4,sp
  movem.l (sp)+,a0-a6/d0-d7
  rts

*print a space
dpspace  move.b #32,d1
  bra ochar

*print a new line and pause if needed
newlinp  move.b #13,d1
  bsr ochar
  move.b #10,d1
  bsr ochar
*normal pause
pause  tst.b stopfg(a5)  *is STOPFG set?
  bne paused
  bsr getchar    *try to get char - NO pause
paskek  cmp #$20,d0    *is it a space?
  beq setpaus
  cmp #$03,d0    *is it CTRL-C?
  beq setkill
  cmp #$0d,d0    *is it RETURN?
  bne pausrts
clrpaus  clr.w stopfg(a5)  *clear STOPFG
pausrts  rts
setpaus  st.b stopfg(a5)    *set STOPFG
paused  lea.l paumes(a5),a0  *print "--More--"
  bsr wstring
  bsr rdchar    *wait for a key
  cmp #$03,d0    *is it CTRL-C?
  beq setkill
  cmp #$0d,d0    *is it RETURN?
  beq clrpaus
  rts
setkill  st.b killfg(a5)    *set KILLFG
  rts

*wait for key (commanded or at end)
wait  lea.l watmes(a5),a0  *print "Press a Key"
  bsr wstring
  bsr rdchar    *and wait for a key
  rts

*getchar - Get key without echo and without waiting!
*          Exit, d0.b is key, or zero if no key ready
getchar  movem.l a0-a6/d1-d7,-(sp)
  move.w #$0b,-(sp)
  trap #1
  addq.l #2,sp
  tst.l d0  *is there a key?
  bmi.s rdchq
  movem.l (sp)+,a0-a6/d1-d7
  clr.l d0  NO,return zero
  rts

*rdchar  - Wait fpr a key (no echo)
*          Exit, d0.b is key
rdchar  movem.l a0-a6/d1-d7,-(sp)
rdchq  move.w #$07,-(sp)
  trap #1    *call DOS which returns 2 bytes
  addq.l #2,sp  *in lower & upper word of d0
  movem.l (sp)+,a0-a6/d1-d7
  tst.w d0  *is lower word zero?
  bne tsttop  *no, return upper word
lswap  swap d0    *get upper if zero
rdora  or.b #$80,d0  *set high bit
rdout  and.l #$ff,d0  *of lower byte only!
rdrts  rts    *and return
tsttop  swap d0    *lower word nonzero
  cmp.w #$44,d0  *if upper out of range
  bcs bswap  *go to swap lower back
  cmp.w #$54,d0  *same if above range
  bls lswap  *if in range lower word or #$80
bswap  swap d0    *if out of range, lower word!
  bra rdout

*rstring - Get a string from GEMDOS (input line)
*          Entry, a0 =address of buffer (2 bytes +max length)
*                 d0 =max length
*          Exit, a0 =address of first char in buffer
*                d0 =length of input line
rstring  movem.l a1-a6/d1-d7,-(sp)
  move.w d0,d2
zstring  move.b #0,2(a0,d2.w)
  dbf d2,zstring
  move.l a0,-(sp)
  move.b d0,(a0)
  move.w #$0a,-(sp)
  trap #1    *GEMDOS call
  addq.l #2,sp
  move.l (sp)+,a0
  addq.l #1,a0
  move.b (a0)+,d0
  movem.l (sp)+,a1-a6/d1-d7
  rts

*wstring - Print a string to the screen (up to zero byte)
*          Entry, a0 =address of string
wstring  movem.l a1-a6/d0-d7,-(sp)
  move.l a0,-(sp)
  move.w #$09,-(sp)
  trap #1
  addq.l #2,sp
  move.l (sp)+,a0
  movem.l (sp)+,a1-a6/d0-d7
  rts

*nspaces - Print d0+1 spaces
*          Entry, d0 =# of spaces to print
*          Exit, d0 = -1
nspaces  move.l d1,-(sp)
nspace1  bsr dospace
  dbf d0,nspace1
  move.l (sp)+,d1
  rts

*dospace - Print one space
*          Exit, d1 = #32 (SPACE)
dospace  move.w #32,d1  *and fall thru to

*wrchar  - Print a character to the screen
*          Entry, d1 =character to print
wrchar  movem.l d0-d7/a0-a6,-(sp)
  move.w d1,-(sp)
  move.w #2,-(sp)
  trap #1
  addq.l #4,sp
  movem.l (sp)+,d0-d7/a0-a6
  rts

*newline - Print a CR and LF
*          Exit, d1 = #10 (LF)
newline  move.w #13,d1
  bsr wrchar
  move.w #10,d1
  bra wrchar

*openrd  - open a file for loading or reading
*          Entry, a0 =addr of file to open
*          Exit IF SUCCESFUL (N=0)
*                d0 =file handle
*          Exit IF ERROR (N=1)
*                d0 =error #
openrd  movem.l a1-a6/d1-d7,-(sp)
  move.w #0,-(sp)
  move.l a0,-(sp)
  move.w #$3d,-(sp)
  trap #1
  addq.l #2,sp
  move.l (sp)+,a0
  addq.l #2,sp
  movem.l (sp)+,a1-a6/d1-d7
  tst.l d0
  rts

*infile  - read a buffer fron disk
*          Entry,a0.l =address of buffer
*                d0.l =buffer length
*                d1.w =file handle
*          Exit IF SUCCESSFUL (N=0)
*               d0.l =# of bytes read
*          Exit IF ERROR (N=1)
*               d0.l =Error #
infile  movem.l a1-a6/d2-d7,-(sp)
  move.w #$3f,d2
  move.l a0,-(sp)
  move.l d0,-(sp)
  move.w d1,-(sp)


  move.w d2,-(sp)
  trap #1
  addq.l #2,sp
  move.w (sp)+,d1
  addq.l #4,sp
  move.l (sp)+,a0
  movem.l (sp)+,a1-a6/d2-d7
  tst.l d0
  rts

*closfil - close a disk file
*          Entry, d1 =file handle
*          Exit, d0 =error code or 0
closfil  movem.l a0-a6/d2-d7,-(sp)
  move.w d1,-(sp)
  move.w #$3e,-(sp)
  trap #1
  addq.l #2,sp
  move.w (sp)+,d1
  movem.l (sp)+,a0-a6/d2-d7
  tst.l d0
  rts

*DATA segment
  .data
wrdstor  dc.l 0
printfg  dc.w 0  *0 if default to screen, 255 if to printer
stopfg  dc.w 0  *0 if default to run on, 255=stop on 1st line
killfg  dc.w 0  *must be 0!
handle  dc.w 0
commes  dc.b 13,"Type commands separated by spaces:",13,10
  dc.b 13,"   Filename ",13,10
  dc.b 13,"   S (to screen)",13,10
  dc.b 13,"   P (to printer)",13,10
  dc.b 13,"   W (Wait)",13,10
  dc.b "Dump Command:"
  dc.b 0
scnmes  dc.b 13,10,"Dumping to screen.",13,10,0
prtmes  dc.b 13,10,"Dumping to printer.",13,10,0
pnrmes  dc.b 13,10,"Printer not ready!",13,10,0
paumes  dc.b 13,"--More--",13,0
watmes  dc.b 13,10,"--Press a key--",13,0
filmes  dc.b 13,10,10,"File:",0
nfdmes  dc.b " not found.",13,10,0
dbline  dc.b 13,10,10
  dc.b "-------------------------------------------"
dblret  dc.b 13,10,0
title  dc.b 13,"+----------------------------+",13,10
  dc.b 13,"!  Hexadecimal Dump Program  !",13,10
  dc.b 13,"! Silas Warner -- MicroProse !",13,10
  dc.b 13,"!SPACE=pause    RETURN=resume!",13,10
  dc.b 13,"+----------------------------+",13,10
  dc.b 0
  even

*BSS segment
  .bss
  even
  ds.l 256 *256 stacks
ustk  ds.l 1
ibuff  ds.b 2  *2 bytes before COMMSTR
commstr  ds.b 80  *command line
  even
chacter  ds.b 20 *40 bytes from file
fname  ds.b 80  *file name
  even
word  ds.b 80 *used in parsing
  even

*********************
  end

