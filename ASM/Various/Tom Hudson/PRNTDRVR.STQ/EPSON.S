***********************************
* Epson 2-way B&W graphics dumper *
*      Written by Tom Hudson      *
* Copyright 1986, not to be sold  *
***********************************

PHASE	.equ 64
KBSHIFT	.equ 65
X	.equ 66
Y	.equ 68
REZ	.equ 70

.globl _dumper		;convenient labelfor dump routine

.text

_dumper:

move.l a0,d0		;save A0
move.l 16(a7),a0	;get work area address
movem.l d0-a7,(a0)	;shove registers in work area
move.l 8(a7),a1		;screen address--->A1
move.l 12(a7),a2	;palette address--->A2
tst.w 4(a7)		;init?
bne process		;no, go dump!

* reset & initialize printer *

init:
link a6,#-4
move.w #$FFFF,(sp)	;get...
move.w #11,-(sp)	;kbshift status
trap #13
unlk a6
move.l 16(a7),a0	;get work area pointer again
move.b d0,KBSHIFT(a0)	;save kbshift status
move.w 6(a7),REZ(a0)	;save rez

* BUILD PIXEL TABLE *

move.l #$ffffffff,1200(a0)	;black...
move.l #$55ff55ff,1204(a0)
move.l #$55bb55ee,1208(a0)
move.l #$aa55aa55,1212(a0)
move.l #$aa44aa11,1216(a0)
move.l #$aa00aa00,1220(a0)
move.l #$88002200,1224(a0)
move.l #$00000000,1228(a0)	;to white

move.b KBSHIFT(a0),d0	;get kbshift
and.b #8,d0		;ALT?
beq sethoriz		;no, do horizontal

cmp.w #2,REZ(a0)	;hi rez?
beq hivinit		;yes!

* reset phase counter *

move.b #192,PHASE(a0)	;2 pixels per scan line
bra fininit

hivinit:
move.b #128,PHASE(a0)	;1 pixel per scan line
bra fininit

sethoriz:
tst.w REZ(a0)		;hi rez?
beq lowhinit		;yup!

* reset phase counter *

move.b #128,PHASE(a0)	;1 pixel per scan line
bra fininit

lowhinit:
move.b #192,PHASE(a0)	;2 pixels per scan line

* set init string *

fininit:
move.l #$1b401b41,100(a0)	;finish init by resetting printer &
move.w #$080d,104(a0)		;setting linefeed, etc.

move.l #6,d2			;6 bytes in init buffer
lea 100(a0),a3			;point to bytes
bsr printit			;print the init stuff

lea 100(a0),a3			;point to print buffer
move.w #242,d1			;clear 242 * 4 bytes
clpln:
clr.l (a3)+
subq #1,d1
bne clpln
tst.w d0
bpl exit

* exit w/error condition (0) *

error:
movem.l (a0),d0-a7
move.l d0,a0
clr.w d0		;0 indicates error
rts

* exit the subroutine (no error) *

exit:
movem.l (a0),d0-a7
move.l d0,a0
move.w #1,d0		;1 indicates success
rts

* exit w/abort condition (2) *

abort:
movem.l (a0),d0-a7
move.l d0,a0
move.w #2,d0		;2 indicates abort
rts

* process the pixels and send to printer *

process:
move.b KBSHIFT(a0),d0	;get keyboard info
and.b #8,d0		;ALT?
beq hformat		;no!

tst.w REZ(a0)		;low rez?
beq lowvert		;yes!

cmp.w #1,REZ(a0)	;med rez?
beq medvert		;yes!

bra hivert		;only one left...

***********************************
* horizontal format dump routines *
***********************************

hformat:
tst.w REZ(a0)		;low rez?
beq lowproc		;yes!

cmp.w #1,REZ(a0)	;med rez?
beq medproc		;yes!

* HI-REZ PROCESSOR *

clr.w X(a0)		;start at X=0
nx2:
lea 104(a0),a4		;point A4 to print buffer
move.w #399,Y(a0)	;start at Y=399

* GET PIXEL *

nx2b:
bsr get2		;get a pixel
move.b d0,d1		;value in d1 (0 or 1)
andi.l #$000000ff,d1
lsl.l #1,d1		;mult by 2 for palette index
add.l a2,d1		;add palette start address
movea.l d1,a5		;shove in A5
btst.b #0,1(a5)		;low bit on?
bne white		;yes, it's white!

* black pixel *

move.b (a4),d1		;get print buffer byte
or.b PHASE(a0),d1	;turn on bits using PHASE
move.b d1,(a4)+		;put it back in print line
move.b d1,(a4)+		;(twice)
bra np2			;next pixel!

* white pixel *

white:
addq.l #2,a4		;bypass next 2 printer bytes

np2:
subq.w #1,Y(a0)		;next Y position
bpl nx2b		;branch if more

move.b PHASE(a0),d1	;get PHASE
lsr.b #1,d1		;shift right 1 bit
move.b d1,PHASE(a0)	;put back in PHASE
tst.b d1		;any bits left?
bne xl2			;yes, loop back.

move.b #128,PHASE(a0)	;reset PHASE
bsr doprnt		;print the line!
tst.w d0		;OK?
bmi error		;no!

xl2:
bsr pabchk		;check for UNDO
tst.w d0		;UNDO?
bne abort		;yes -- abort!
addq.w #1,X(a0)		;next X position
cmp.w #640,X(a0)	;end of line?
bne nx2			;no!
bsr cleanup		;all done, cleanup printer...
bra exit		;and exit

* MEDIUM-REZ PROCESSOR *

medproc:
clr.w X(a0)		;start at X=0
nx1:
lea 104(a0),a4		;point to printer buffer
move.w #199,Y(a0)	;start at Y=199

* GET PIXEL *

nx1b:
bsr get1		;get a pixel
bsr ppix		;put in print line

subq.w #1,Y(a0)		;next Y
bpl nx1b		;loop if more

move.b PHASE(a0),d1	;get PHASE
lsr.b #1,d1		;shift it right 1 bit
move.b d1,PHASE(a0)	;put back
tst.b d1		;end of phase run?
bne xl1			;no!

move.b #128,PHASE(a0)	;reset PHASE
bsr doprnt		;print the line
tst.w d0		;print error?
bmi error		;yes!

xl1:
bsr pabchk		;check for UNDO abort
tst.w d0		;UNDO?
bne abort		;yes!
addq.w #1,X(a0)		;next X
cmp.w #640,X(a0)	;X done?
bne nx1			;no!
bsr cleanup		;cleanup printer...
bra exit		;and exit!

* LOW-REZ PROCESSOR *

lowproc:
clr.w X(a0)		;start X at 0
nx0:
lea 104(a0),a4		;point to printer buffer
move.w #199,Y(a0)	;start Y at 199

* GET PIXEL *

nx0b:
bsr get0		;get a pixel
bsr ppix		;put in print line

subq.w #1,Y(a0)		;next Y
bpl nx0b		;loop if more Y

move.b PHASE(a0),d1	;get phase
lsr.b #2,d1		;shift right 2 bits
move.b d1,PHASE(a0)	;put back in phase byte
tst.b d1		;end of phase run?
bne xl0			;no!

move.b #192,PHASE(a0)	;reset phase
bsr doprnt		;print the line
tst.w d0		;error?
bmi error		;yes!

xl0:
bsr pabchk		;check for UNDO abort
tst.w d0		;UNDO?
bne abort		;yes!
addq.w #1,X(a0)		;next X
cmp.w #320,X(a0)	;done?
bne nx0			;no, loop back.
bsr cleanup		;all done, cleanup printer...
bra exit		;and exit!

* Vertical-format dump routines *
* HI-REZ PROCESSOR *

hivert:
clr.w Y(a0)		;start Y ay 0
vnx2:
lea 104(a0),a4		;point to print buffer
clr.w X(a0)		;start X at 0

* GET PIXEL *

vnx2b:
bsr get2		;get a pixel
move.b d0,d1		;put it in D1
andi.l #$000000ff,d1
lsl.l #1,d1		;multiply by 2 for index
add.l a2,d1		;add start of color palette
movea.l d1,a5		;stick in A5
btst.b #0,1(a5)		;low bit on?
bne vwhite		;yes, it's white!

* black pixel *

move.b (a4),d1		;turn on printer bits
or.b PHASE(a0),d1	
move.b d1,(a4)+
move.w X(a0),d2		;get X
and.w #1,d2		;even pixel?
bne vnp2		;no!
move.b d1,(a4)+		;it's even, do it twice.
bra vnp2		

* white pixel *

vwhite:
addq.l #1,a4		;skip printer byte
move.w X(a0),d2		;get X
and.w #1,d2		;is it even?
bne vnp2		;no!
addq.l #1,a4		;do it twice

vnp2:
addq.w #1,X(a0)		;next X
cmpi.w #640,X(a0)	;X done?
bne vnx2b		;no, loop!

move.b PHASE(a0),d1	;get phase
lsr.b #1,d1		;shift right 1 bit
move.b d1,PHASE(a0)	;put it back
tst.b d1		;end of phase run?
bne vxl2		;no!

move.b #128,PHASE(a0)	;reset phase
bsr dovprnt		;print it!
tst.w d0		;print OK?
bmi error		;no!

vxl2:
bsr pabchk		;check for UNDO
tst.w d0		;UNDO?
bne abort		;yes!
addq.w #1,Y(a0)		;next Y position
cmp.w #400,Y(a0)	;end of Y?
bne vnx2		;no, loop back.
bsr cleanup		;all done, cleanup printer...
bra exit		;and exit.

* MEDIUM-REZ PROCESSOR *

medvert:
clr.w Y(a0)		;start Y at 0
vnx1:
lea 104(a0),a4		;point to print line
clr.w X(a0)		;start X at 0
clr.w d7		;clear counter

* GET PIXEL *

vnx1b:
bsr get1		;get a pixel
bsr ppix		;put in print line

addq.w #1,X(a0)		;next X
cmpi.w #640,X(a0)	;end of X?
bne vnx1b		;no!

move.b PHASE(a0),d1	;shift phase
lsr.b #2,d1
move.b d1,PHASE(a0)
tst.b d1		;end of phase run?
bne vxl1		;no!

move.b #192,PHASE(a0)	;reset phase
bsr dovprnt		;print it!
tst.w d0		;print OK?
bmi error		;no!

vxl1:
bsr pabchk		;UNDO check
tst.w d0		;UNDO?
bne abort		;yes, abort!
addq.w #1,Y(a0)		;next Y
cmp.w #200,Y(a0)	;Y done?
bne vnx1		;no!
bsr cleanup		;cleanup printer...
bra exit		;and exit!

* LOW-REZ PROCESSOR *

lowvert:
clr.w Y(a0)		;start Y at 0
vnx0:
lea 104(a0),a4		;point to printer buffer
clr.w X(a0)		;start X at 0

* GET PIXEL *

vnx0b:
bsr get0		;get pixel
bsr ppix		;put in print line

addq.w #1,X(a0)		;next X
cmpi.w #320,X(a0)	;X done?
bne vnx0b		;no!

move.b PHASE(a0),d1	;shift phase bits
lsr.b #2,d1
move.b d1,PHASE(a0)
tst.b d1		;end of phase run?
bne vxl0		;no!

move.b #192,PHASE(a0)	;reset phase
bsr dovprnt		;print it!
tst.w d0		;print OK?
bmi error		;no!

vxl0:
bsr pabchk		;UNDO check
tst.w d0		;UNDO?
bne abort		;yes!
addq.w #1,Y(a0)		;next Y
cmp.w #200,Y(a0)	;Y done?
bne vnx0		;no!
bsr cleanup		;cleanup printer...
bra exit		;and exit!

****************************
* print string to printer  *
*--------------------------*
* input:                   *
* d2.L # of bytes to print *
* a3: address of 1st byte  *
* returns:                 *
* d0 = -1: error!          *
* d0 =  0: OK!             *
****************************

printit:
move.l #270000,d1	;timeout count (works out to +/- 30 secs.)

statloop:
link a5,#-20		;save registers on stack
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)
link a6,#-4		;Request printer
clr.w (sp)		;output status
move.w #8,-(sp)
trap #13
unlk a6
move.l (sp)+,d2		;restore registers
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
tst.l d0		;printer ready?
bmi prtrdy		;yes!
subq.l #1,d1		;decrement timeout counter
bpl statloop		;and try again
move.w #-1,d0		;printer error!
rts

prtrdy:
link a5,#-20		;save registers
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)
link a6,#-6
move.b (a3),d0		;get byte to print
andi.w #$00FF,d0	;mask off to be safe
move.w d0,(sp)		;put on stack
clr.w -(sp)		;device #0 (printer)
move.w #3,-(sp)		;conout
trap #13		;send to printer!
unlk a6
move.l (sp)+,d2		;restore registers
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
addq.l #1,a3		;point to next byte
subq.w #1,d2		;decrement counter
bne printit		;loop if more bytes
clr.w d0		;OK!
rts

* CHECK FOR UNDO KEY ABORT *

pabchk:
link a5,#-20		;Save registers
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)
link a6,#-4		;request keyboard status
move.w #2,(sp)		;(returns with D0 = 0 if no characters)
move.w #1,-(sp)
trap #13
unlk a6
tst.w d0		;any keys?
beq abcexit		;no!
link a6,#-4		;there's a keypress waiting...
move.w #2,(sp)		;don't make it wait!
move.w #2,-(sp)
trap #13		;get key...
unlk a6
cmp.l #$00610000,d0	;UNDO?
bne nobort		;no!
move.w #1,d0		;yes, set abort flag

abcexit:
move.l (sp)+,d2		;restore the saved registers
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
rts

nobort:
clr.w d0		;clear D0 (no abort)
bra abcexit		;and go to exit point

* GET hi-rez pixel (0-1) *

get2:
link a5,#-20		;save the registers on stack
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)

move.w Y(a0),d0		;get Y coordinate
and.l #$0000ffff,d0	;mask it
mulu #80,d0		;mult. by 80
adda.l d0,a1		;add to screen base
move.w X(a0),d1		;get X
move.w d1,d2		
lsr.w #3,d1		;divide X by 8
adda.w d1,a1		;add to screen pointer
move.b (a1),d0		;get screen byte
and.l #7,d2		;get byte mask number
move.b #$80,d1		;set up bit mask
lsr.b d2,d1		;shift mask into position
and.b d1,d0		;mask a bit
bne set2
clr.w d0		
bra getx2		;bit off!

set2:
move.w #1,d0		;bit on!

getx2:
move.l (sp)+,d2		;restore registers
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
rts

* get medium-rez pixel *

get1:
link a5,#-24		;save registers
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)
move.l d3,-(sp)

clr.w d0		;zero result register
move.w Y(a0),d3		;grab Y coordinate
and.l #$0000ffff,d3	;mask it off
mulu #160,d3		;multiply by 160 (# of bytes per scan line)
adda.l d3,a1		;add to screen base address
move.w X(a0),d1		;get X coordinate
move.w d1,d2		;duplicate in D2
lsr.w #2,d1		;divide it by 4
and.w #$00fc,d1		;turn off lower 3 bits
adda.w d1,a1		;add to screen address

move.w (a1),d3		;get the screen word
and.l #15,d2		;mask X to 0-15 (index within group)
move.w #$8000,d1	;set up a bit mask
lsr.w d2,d1		;shift it by the group index
and.w d1,d3		;get low-order color bit
beq bit1b		;it's off, go to next color bit
move.w #1,d0		;set bit in result register

bit1b:
move.w 2(a1),d3		;get second pixel group from screen
and.w d1,d3		;get high-order color bit
beq getx1		;it's off, go exit.
or.w #2,d0		;it's on, turn on appropriate color bit in result

getx1:
move.l (sp)+,d3		;restore the registers
move.l (sp)+,d2
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
rts

* get low-rez pixel *

get0:
link a5,#-24		;save registers
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)
move.l d3,-(sp)

clr.w d0		;zero result register
move.w Y(a0),d3		;get Y coordinate
and.l #$0000ffff,d3	;mask off for multiply
mulu #160,d3		;multiply by 160 (# of bytes per scan line)
adda.l d3,a1		;add to screen base address
move.w X(a0),d1		;get X coordinate
move.w d1,d2		;duplicate it in D2
lsr.w #1,d1		;divide it by 2
and.w #$00f8,d1		;turn off lower 3 bits
adda.w d1,a1		;add to screen address register

move.w (a1),d3		;grab screen word
and.l #15,d2		;mask X to 0-15
move.w #$8000,d1	;set up bit mask
lsr.w d2,d1		;shift bit mask 0-15 bits
and.w d1,d3		;mask off bit 0
beq bit0b		;bit's off, go get next color bit
move.w #1,d0		;turn on bit 0 in result

bit0b:
move.w 2(a1),d3		;get screen word for bit 1 of color
and.w d1,d3		;get bit 1
beq bit0c		;it's off, try bit 2
or.w #2,d0		;turn on bit 1 in result

bit0c:
move.w 4(a1),d3		;get screen word for bit 2
and.w d1,d3		;get bit 2
beq bit0d		;it's off, try bit 3
or.w #4,d0		;turn on bit 2 in result

bit0d:
move.w 6(a1),d3		;get word for bit 3
and.w d1,d3		;get bit 3
beq getx0		;it's off!
or.w #8,d0		;turn on bit 3 in result

getx0:
move.l (sp)+,d3		;restore the registers
move.l (sp)+,d2
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
rts

cleanup:
move.b #12,100(a0)	;do a page eject on printer
move.l #1,d2
lea 100(a0),a3
bsr printit
rts			;and exit

* horizontal format print *

doprnt:
move.l #$1b4c2003,100(a0)	;build print line header...
move.w #$0d0a,904(a0)		;and print line tail (CR/LF)
move.l #806,d2			;print 806 bytes
lea 100(a0),a3
bsr printit

lea 100(a0),a3			;clear print line
move.w #210,d1
clpln2:
clr.l (a3)+
subq #1,d1
bne clpln2
rts

* vertical format print *

dovprnt:
move.l #$1b4cc003,100(a0)	;build print header
move.w #$0d0a,1064(a0)		;and tail (CR/LF)
move.l #966,d2			;print 966 bytes
lea 100(a0),a3
bsr printit

lea 100(a0),a3			;clear print line
move.w #242,d1
vclpln2:
clr.l (a3)+
subq #1,d1
bne vclpln2
rts

* CHANGE COLOR TO GRAY-SCALE *
* AND PUT IN PRINT LINE      *

ppix:
move.b d0,d1		;put pixel index in d1
andi.l #$000000ff,d1	;mask it
lsl.l #1,d1		;multiply by 2
add.l a2,d1		;add palette start address
movea.l d1,a5		;put in a5
move.w (a5),d0		;get color ($000-$777)
move.w d0,d2		;duplicate it
and.w #7,d2		;mask BLUE bits
move.w d0,d1		;duplicate again
lsr.w #4,d1		;shift...
and.w #7,d1		;and mask GREEN bits
add.w d1,d2		;add green and blue
move.w d0,d1		;duplicate color AGAIN!
lsr.w #8,d1		;shift...
and.w #7,d1		;and mask RED bits
add.w d1,d2		;add to total (now 0-21)
and.l #$000000ff,d2	;mask for divide
divu #3,d2		;divide by 3 (now 0-7)
lsl.w #2,d2		;mult by 4 for index into gray-scale table
lea 0(a0,d2.w),a5	;get effective address
adda.l #1200,a5		;add table start offset
move.b KBSHIFT(a0),d1	;get keybd bits
and.b #8,d1		;ALT (vert format)?
bne vchange		;yes, do vert!

* handle pixel color *

move.b (a5),d1		;get gray-scale byte
and.b PHASE(a0),d1	;mask with phase
or.b (a4),d1		;or with print byte
move.b d1,(a4)+		;and set print bits
move.b 1(a5),d1		;do three more times (4 dots per pixel)
and.b PHASE(a0),d1
or.b (a4),d1
move.b d1,(a4)+
move.b 2(a5),d1
and.b PHASE(a0),d1
or.b (a4),d1
move.b d1,(a4)+
move.b 3(a5),d1
and.b PHASE(a0),d1
or.b (a4),d1
move.b d1,(a4)+
rts

* handle vertical pixel color *

vchange:
move.b 0(a5,d7.w),d1	;get gray-scale byte
addq.w #1,d7		;increment D7 (printer dot counter)
and.w #3,d7		;force D7 0-3
and.b PHASE(a0),d1	;mask with phase
or.b (a4),d1		;or with print byte
move.b d1,(a4)+		;put in print line
tst.w REZ(a0)		;low rez?
beq dump3		;yes!
move.w X(a0),d1		;med rez:
and.w #1,d1		;is X even?
beq dump2		;yes!
rts			;no, exit

dump3:
move.b 0(a5,d7.w),d1	;dump second & third bytes for low rez
addq.w #1,d7
and.w #3,d7
and.b PHASE(a0),d1
or.b (a4),d1
move.b d1,(a4)+
dump2:
move.b 0(a5,d7.w),d1	;dump second byte for medium rez+even
addq.w #1,d7
and.w #3,d7
and.b PHASE(a0),d1
or.b (a4),d1
move.b d1,(a4)+
rts

filler .ds.l 500	;pad to make sure it's at least 2000 bytes

* That's all! *
