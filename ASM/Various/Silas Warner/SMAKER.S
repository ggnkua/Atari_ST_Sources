
*******************************************************
*** SMAKER.TOS by Silas Warner, MicroProse Software ***
*******************************************************
*    This file converts binary image files  
*    such as ASCII text, icons and screen 
*    dumps to assembler source files.  The
*    data appears as DC.L bytes, with
*    a single label.
*

*To assemble this program, type
*AS68 -l SMAKER.S
*LINK68 SMAKER
*RELMOD SMAKER.68K SMAKER.TOS
*then remove SMAKER.O and SMAKER.68K.

start  bra start1  *around title

*File comment header
title  dc.b 13,10,"+-------------------------+"
  dc.b 13,10,"!    SOURCE FILE MAKER    !"
  dc.b 13,10,"!    by Silas Warner.     !"
  dc.b 13,10,"!Copyright 1985,MicroProse!"
  dc.b 13,10,"+-------------------------+"
  dc.b 13,10,0
  even

*
*APSTART chunk to set stack and memory
start1  move.l sp,a5
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
   lea.l ustk,sp  *use our own stack
*Okay, do init stuff
startup  lea commstr,a0  *to command string buffer
  move.b (a1)+,d1  *get length
xfercom  move.b (a1)+,(a0)+  *move command string
  dbeq d1,xfercom
xferof  move.b #0,(a0)    *zero end of command string
  lea.l title,a0  *now print title?
  bsr wstring
  tst.w commstr  *is command string zero?
  bne commgo    *no, use it
  lea.l commes,a0  *ask for command string
  bsr wstring
  lea.l ibuff,a0  *and get it (IBUFF=COMMSTR-2)
  move.w #65,d0
  bsr rstring
commgo  lea.l commstr,a6  *start command parsing
  move.l a6,wrdstor
parse  move.l wrdstor,a6  *parse next word
  lea.l word,a0
skspc  move.b (a6)+,d0    *skip over multiple blanks
  bne neline    *if zero byte
  move.w #$00,-(sp)  *set good ending
  move.w #$4c,-(sp)  *and kill program!
  trap #1
neline  cmp.b #" ",d0    *is byte a space?
  beq skspc
  bra fstchr    *no, it's 1st byte of command
nxtchr  move.b (a6)+,d0    *get next byte from line
fstchr  move.b d0,(a0)+    *and put it in command word
  beq elparse    *if zero byte, EOL
  cmp.b #" ",d0    *is it a space?
  beq eparse    *Yes, end command
  bra nxtchr    *no, get next byte
elparse  subq.l #1,a6    *parser hit end of line
eparse  move.l a6,wrdstor  *store pars pointer back
  clr.b -(a0)    *clear off added space
*One command is now stored in "word"
*separate it into file name, suffix and label
  lea.l word,a0    *set to start of word
  clr.b suffix    *set original suffix to 0
  clr.b label    *same with label
  clr.b pname     *and file name
  lea.l pname,a1    *pname is first destination!
nxtfn  move.b (a0)+,d0    *get a char
  beq efname    *end of command?
  cmp.b #".",d0    *No, start of suffix?
  beq ssuffix    *Yes, go to suffix mover
  cmp.b #"(",d0    *No,start of label?
  beq slabel    *yes, go to label mover
  move.b d0,(a1)+    *No, put it in pname
  clr.b (a1)    *set zero on end
  bra nxtfn    *and go get another
ssuffix  lea.l suffix,a1    *now transferring to suffix!
  clr.l d1    *suffix byte count
nxsuf  move.b (a0)+,d0    *get a suffix byte (skip period)
  beq efname    *end of command?
  cmp.b #"(",d0    *No, start of label?
  beq slabel    *Yes, go to label mover
  cmp.l #3,d1    *got 3 chars?
  bcc nxsuf    *Yes, don't add it
  addq.l #1,d1    *No, count chars
  move.b d0,(a1)+    *Put char in suffix
  clr.b (a1)    *end it with zero
  bra nxsuf    *and go get another
slabel  lea.l label,a1    *start xferring to label
  clr.l d1    *label char count
nxlabel  clr.b -1(a0)    *replace paren with zero byte
  move.b (a0)+,d0    *get a label byte (skip paren)
  beq efname    *end of label?
  cmp.b #")",d0    *Paren also means end label?
  beq efname    *Yes, go examine the catch
  cmp.l #8,d1    *got 8 chars?
  bcc nxlabel    *Yes, don't add more
  addq.l #1,d1    *No, count chars
  move.b d0,(a1)+    *Put char in label
  clr.b (a1)    *end it with zero
  bra nxlabel    *and get another
*Now we have the command separated into elements
*but some of them can be blank!
efname  lea.l pname,a0    *set for filename
  tst.b (a0)    *is filename blank?
  beq parse    *Yes, forget it all!
fefnam  cmp.b #0,(a0)+    *Is this the end?
  bne fefnam    *No, go on
  subq.l #1,a0    *Back up to zero
  move.b #".",(a0)+  *Construct suffix
  move.b #"S",(a0)+  *of ".S"
  move.b #0,(a0)+    *on pname
  lea.l pname,a0    *put a0 back to start
  lea.l label,a1
  tst.b (a1)    *is label blank?
  bne triopn    *No, go try to open file
  move.b 1(a0),d0    *check for colon
  cmp.b #":",d0    *which means drive spec
  bne duplbl    *Is there a colon?
  addq.l #2,a0    *Yes, don't put it in label!
duplbl  move.b (a0)+,d0    *get a name char
  cmp.b #".",d0    *are we at suffix header?
  beq dedlbl    *Yes, branch out
  move.b d0,(a1)+    *No, put it in
  bne duplbl    *and get next char (unless zero!)
dedlbl  clr.b (a1)    *stick zero on end
*NOW, word contains old file name (with zero in place of label spec)
*pname contains new file name spec
*label contains proper label name
*Now, open the input file!
triopn  lea.l word,a0
  bsr openrd  *Try opening original file
  bpl troopen  *Did we do it?
  bsr newline  *No, print error
  lea.l word,a0  *File name
  bsr wstring
  lea.l notfnd,a0  *Error message
  bsr wstring
  bsr newline
  jmp parse  *and try again
troopen  move.w d0,ihandle
  lea.l pname,a0  *Try to open output file
  bsr opensav
  bpl iniline  *Did we do it?
  move.w ihandle,d1 *No, close input file
  jsr closfil
  bsr newline  *print output name
  lea.l pname,a0
  bsr wstring
  lea.l wrerm,a0  *and error messae
  bsr wstring
  bsr newline
  jmp parse
iniline  move.w d0,ohandle
  bsr newlfil
  bsr newlfil
  lea.l label,a1  *set up to xfer label
  lea.l kline,a0
  clr.l d2
setlbl  move.b 0(a1,d2.w),0(a0,d2.w) *xfer label char
  beq lineovr  *If zero, end of label
  addq.l #1,d2  *inc line pos
  cmp.b #7,d2  *Is it 7?
  bne setlbl  *No, back for more label
lineovr  lea.l kline,a0  *entry for new line
  bsr spasto8
  move.l #16,d0  *Now get 4 longwords
  lea.l kowde,a0  *Into kowde
  move.w ihandle,d1 *from input file
  bsr infile
  beq kodend  *If nothing gotten,end
  bmi kodend  *If we failed, force end
  move.l d0,length *Save length
  move.l d0,d7  *and bytes left
  lea.l kline,a0  *Start in on line
  move.l #"dc.l",d0 *put command
  bsr storlw  *as longword
  bsr spastor  *then space
akowde  move.b #"$",d0  *lword begins with $ sign
  bsr storlin
  move.l kowde,d1  *now hex longword
  bsr hexlong  *store longword
  bsr kowd4lf  *get next codeword
  subq.l #4,d7  *dec bytes left by 4
  cmp.l #4,d7  *Are there less than 4?
  bcs ekowde  *Yes, end line
  move.b #",",d0  *comma between lwords
  bsr storlin
  bra akowde
ekowde  bsr linfile  *print the line!
  clr.l d2  *start new line
  tst.l d7  *Even end?
  bne kodtail  *No, print tail as dc.b's
  bra lineovr
kodtail  lea.l kline,a0  *reload
  bsr spasto8  *space over to column 8
  move.l #"dc.b",d0 *print command dc.b
  bsr storlw  *from longword
  bsr spastor  *then space
skowde  move.b #"$",d0  *byte begins with $ sign
  bsr storlin
  move.b kowde,d1  *now hex longword
  bsr hexbyte  *store longword
  bsr kowd1lf  *get next codeword
  subq.l #1,d7  *dec bytes left
  beq ekowde  *Yes, end line
  move.b #",",d0  *comma between lwords
  bsr storlin
  bra skowde
kodend  lea.l kline,a0  *reload proper buffer
  move.l #"even",d0 *store "even"
  bsr storlw  *as longword
  bsr linfile  *store the line
  lea.l kline,a0  *reload proper buffer
  clr.l d2  *start over again
  bsr spasto8  *go to column 8
  move.l #"end ",d0 *store "end"
  bsr storlw  *as longword
  bsr linfile
  move.w #$1a00,kline *store EOF marker
  moveq.l #1,d0
  lea.l kline,a0  *from kline
  move.w ohandle,d1 *to output file
  bsr outfile  *write EOF marker
  move.w ihandle,d1 *close input file
  bsr closfil  
  move.w ohandle,d1 *and output file
  bsr closfil
  jmp parse

*print a hex longword, word or byte to output line
hexlong  move.l d1,-(sp)
  swap d1
  bsr hexword
  move.l (sp)+,d1
hexword  move.w d1,-(sp)  *thanks to Jez San
  lsr.w #8,d1
  lsr.w #4,d1
  bsr.s hxpnibbl  *1st nybble
  move.w (sp),d1
  lsr.w #8,d1
  bsr.s hxpnibbl  *2nd nybble
  move.w (sp)+,d1
hexbyte  move.w d1,-(sp)
  lsr.w #4,d1
  bsr.s hxpnibbl  *3rd nybble
  move.w (sp)+,d1
hxpnibbl
  and.w #15,d1  *finally print out ONE hex digit!
  cmp.b #9,d1
  bls.s hxpnib2
  add.b #7,d1
hxpnib2  move.b d1,d0
  add.b #"0",d0
  bra storlin

*kowd4lf - slide kowde left one longword
kowd4lf  move.l kowde+4,kowde
  move.l kowde+8,kowde+4
  move.l kowde+12,kowde+8
  clr.l kowde+12
  rts
*kowd1lf - slide kowde left one byte
kowd1lf  clr.l d4
  lea.l kowde,a1
kowdl1  move.b 1(a1,d4.w),0(a1,d4.w)
  addq.l #1,d4
  cmp.l #15,d4
  bcs kowdl1
  move.b #0,15(a1)
  rts

*store a space in the line
spastor  move.b #$20,d0
*store char in d0 in the line
storlin  lea.l kline,a0
  move.b d0,0(a0,d2.w)
  addq.l #1,d2
  move.b #0,0(a0,d2.w)
  rts
*store a longword to line
storlw  moveq.l #3,d3
storlk  rol.l #8,d0
  bsr storlin
  dbf d3,storlk
  rts
*store spaces to column 8
spasto8  bsr spastor
  cmp.b #8,d2
  bcs spasto8
  rts

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

opensav  bsr openwrt
  bpl.s exitsav
  cmp.l #-33,d0  *file not found
  beq newfile
exitsav  rts
newfile  movem.l a1-a6/d1-d7,-(sp)
  move.w #0,-(sp)    *this is a DOS call
  move.l a0,-(sp)
  move.w #$3c,-(sp)
  trap #1
  addq.l #2,sp
  move.l (sp)+,a0
  addq.l #2,sp
  movem.l (sp)+,a1-a6/d1-d7
  tst.l d0
  rts

*openrd  - open a file for loading or reading
*openwrt - open an existing file for writing
*          Entry, a0 =addr of file to open
*          Exit IF SUCCESFUL (N=0)
*                d0 =file handle
*          Exit IF ERROR (N=1)
*                d0 =error #
openrd  movem.l a1-a6/d1-d7,-(sp)
  move.w #0,-(sp)
  bra opencom
openwrt  movem.l a1-a6/d1-d7,-(sp)
  move.w #1,-(sp)
opencom  move.l a0,-(sp)
  move.w #$3d,-(sp)
  trap #1
  addq.l #2,sp
  move.l (sp)+,a0
  addq.l #2,sp
  movem.l (sp)+,a1-a6/d1-d7
  tst.l d0
  rts

*linfile - print kline to file 
*          Entry, d2=line length
linfile  lea.l kline,a0
  clr.l d0
  move.b d2,d0
  move.w ohandle,d1
  bsr outfile
*fall thru to
*newlfil - send newline to output handle
newlfil  lea.l newln,a0
  moveq.l #2,d0
  move.w ohandle,d1
  bra outfile

*infile  - read a buffer from disk
*outfile - write a buffer to disk
*          Entry,a0.l =address of buffer
*                d0.l =buffer length
*                d1.w =file handle
*          Exit IF SUCCESSFUL (N=0)
*               d0.l =# of bytes read
*          Exit IF ERROR (N=1)
*               d0.l =Error #
infile  movem.l a1-a6/d2-d7,-(sp)
  move.w #$3f,d2
  bra iofile
outfile  movem.l a1-a6/d2-d7,-(sp)
  move.w #$40,d2
iofile  move.l a0,-(sp)
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
commes  dc.b 13,10,"Command?",0
notfnd  dc.b " Not Found!",0
rderm  dc.b " Not Read!",0
wrerm  dc.b " Not Written!",0
  even

length  dc.l 0    *data length
left  dc.l 0    *bytes left to write

label  dc.l 0,0  *label name
newln  dc.w $0d0a  *new line
spaces  dc.l $a0a0a0a0  *4 spaces fr quick line

*BSS segment
  .bss
  even
  ds.l 256 *256 stacks
ustk  ds.l 1
ihandle  ds.w 1  *input handle
ohandle  ds.w 1  *output handle
wrdstor  ds.l 1  *parse position
ibuff  ds.b 2  *2 bytes before COMMSTR
commstr  ds.b 80  *command line
word  ds.b 80 *used in parsing
pname  ds.b 16  *file name
suffix  ds.b 4  *original suffix
  even
kline  ds.l 20  *S file line 80 bytes long
kowde  ds.l 8  *8 longwords per line
  even



*********************
  end
