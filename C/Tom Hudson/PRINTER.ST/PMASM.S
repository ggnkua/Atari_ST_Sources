*******************************************
*  Generic 2-way graphics dumper skeleton *
*         Written by Tom Hudson		  *
*	    For START Magazine		  *
* Copyright 1986 by Antic Publishing, Inc.*
*******************************************

.globl	_HEADPINS	;# of pins
.globl	_HEADSIZE	;byte count for head data
.globl	_VSOFF		;vert. start string offset
.globl	_VSSIZE		;vert. start string size
.globl	_HVXO		;high-res vertical X odd repeat
.globl	_HVXE		;high-res vertical X even repeat
.globl	_HVYO		;high-res vertical Y odd repeat
.globl	_HVYE		;high-res vertical Y even repeat
.globl	_MVYO		;med-res vertical Y odd repeat
.globl	_MVYE		;med-res vertical Y even repeat
.globl	_LVXO		;low-res vertical X odd repeat
.globl	_LVXE		;low-res vertical X even repeat
.globl	_HSOFF		;horiz. start string offset
.globl	_HSSIZE		;horiz. start string size
.globl	_HHXO		;high-res horiz. X odd repeat
.globl	_HHXE		;high-res horiz. X even repeat
.globl	_HHYO		;high-res horiz. Y odd repeat
.globl	_HHYE		;high-res horiz. Y even repeat
.globl	_MHXO		;med-res horiz. X odd repeat
.globl	_MHXE		;med-res horiz. X even repeat
.globl	_LHYO		;low-res horiz. Y odd repeat
.globl	_LHYE		;low-res horiz. Y even repeat
.globl	_INITOFF	;init string offset
.globl	_INITSIZ	;init string size
.globl	_SCALE1		;X pattern scale factor
.globl	_SCALE2		;Y pattern scale factor
.globl	_HMINIT		;head mask init value
.globl	_SHIFT		;bit shift direction instruction
.globl	_ENDOFF		;end-of-line offset
.globl	_ENDSIZ		;end-of-line end
.globl	_CLEANOFF	;cleanup string offset
.globl	_CLEANSIZ	;cleanup string size
.globl	_STRINGS	;string area start

.globl	_dumper		;convenient label for dump routine
.globl	_lshift		;left-shift instruction
.globl	_rshift		;right-shift instruction
.globl	_movem		;general-purpose memory mover

*******************
* Work area usage *
*******************

HEADMASK	.equ	64	;print head bit mask
X		.equ	68	;pixel X coord
Y		.equ	70	;pixel Y coord
REZ		.equ	72	;resolution (0,1,2)
PRTX		.equ	74	;printer X coord
PRTY		.equ	76	;printer Y coord
PINS		.equ	82	;pins in print head
XR		.equ	84	;X repeat value
YR		.equ	86	;Y repeat value
NEWY		.equ	88	;start Y for next head pass
NEWSPECIAL	.equ	90	;start YR for next head pass
YSTART		.equ	92	;start Y for this head pass
YSPECIAL	.equ	94	;start YR for this head pass
ENDFLAG		.equ	96	;end-of-dump flag
HEADCT		.equ	98	;head pin count
BUFFER		.equ	100	;buffer for dump
VERT		.equ	104	;vertical dump flag
GETX		.equ	106	;pixel get X
GETY		.equ	108	;pixel get Y
PYSTART		.equ	110	;printer start Y for this pass
SOFF		.equ	112	;line start string offset
SSIZ		.equ	114	;line start strinf size
XODD		.equ	116	;X odd repeat count
XEVEN		.equ	118	;X even repeat count
YODD		.equ	120	;Y odd repeat count
YEVEN		.equ	122	;Y even repeat count
XLIMIT		.equ	124	;screen X limit value
YLIMIT		.equ	126	;screen Y limit value

.text

********************************
* Start of printer driver code *
********************************

_dumper:
move.l a0,d0		;save A0
move.l 16(a7),a0	;get work area address
movem.l d0-a7,(a0)	;shove registers in work area
move.l 8(a7),a1		;screen address--->A1
move.l 12(a7),a2	;palette address--->A2
tst.w 4(a7)		;init?
bne process		;no, go dump!

******************************
* reset & initialize printer *
******************************

init:
link a6,#-4
move.w #$FFFF,(sp)	;get...
move.w #11,-(sp)	;kbshift status
trap #13
unlk a6
move.l 16(a7),a0	;get work area pointer again
and.w #8,d0		;mask just Alt key
move.w d0,VERT(a0)	;save in VERT dump flag
move.w 6(a7),REZ(a0)	;save rez

********************************
* build gray-scale pixel table *
********************************

move.w #%1111111111111111,1200(a0)	;black (luminance 0)
move.w #%1111010111110101,1202(a0)
move.w #%1110010110110101,1204(a0)
move.w #%1010010110100101,1206(a0)
move.w #%1010010010100001,1208(a0)
move.w #%1010000010100000,1210(a0)
move.w #%1000000000100000,1212(a0)
move.w #%0000000000000000,1214(a0)	;white (luminance 7)

_HEADPINS:
move.w #$1111,PINS(a0)	;set number of pins

tst.w VERT(a0)		;vertical-format dump?
beq hinit		;no!

*********************************
* Vertical-format setup routine *
*********************************

_VSOFF:
move.w #$1111,SOFF(A0)	;set vert start string offset
_VSSIZE:
move.w #$1111,SSIZ(A0)	;set vert start string size

_HVXO:
move.w #$1111,XODD(A0)	;set hi-res X odd repeat
_HVXE:
move.w #$1111,XEVEN(A0)	;set hi-res X even repeat
_HVYO:
move.w #$1111,YODD(A0)	;set hi-res Y odd repeat
_HVYE:
move.w #$1111,YEVEN(A0)	;set hi-res Y even repeat

move.w #640,XLIMIT(A0)	;set X limit value
move.w #400,YLIMIT(A0)	;set Y limit value
cmp.w #2,REZ(a0)	;is it REALLY hi-res?
beq fininit		;yup, setup complete!

_MVYO:
move.w #$1111,YODD(A0)	;set up med-res Y odd repeat
_MVYE:
move.w #$1111,YEVEN(A0)	;set up med-res Y even repeat

move.w #200,YLIMIT(A0)	;set Y limit value
tst.w REZ(a0)		;is it REALLY med-res?
bne fininit		;yup, setup's done!

_LVXO:
move.w #$1111,XODD(A0)	;set up low-res X odd repeat
_LVXE:
move.w #$1111,XEVEN(A0)	;set up low-res X even repeat

move.w #320,XLIMIT(A0)	;set X limit value
bra fininit		;and go wrap up the initialization!

***********************************
* Horizontal-format setup routine *
***********************************

hinit:

_HSOFF:
move.w #$1111,SOFF(A0)	;set up horizontal start string offset
_HSSIZE:
move.w #$1111,SSIZ(A0)	;set up horizontal start string length

_HHXO:
move.w #$1111,XODD(A0)	;set up hi-res X odd repeat
_HHXE:
move.w #$1111,XEVEN(A0)	;set up hi-res X even repeat
_HHYO:
move.w #$1111,YODD(A0)	;set up hi-res Y odd repeat
_HHYE:
move.w #$1111,YEVEN(A0)	;set up hi-res Y even repeat

move.w #400,XLIMIT(A0)	;set backwards X limit value...
move.w #640,YLIMIT(A0)	;and backwards Y limit value (sideways!)
cmp.w #2,REZ(a0)	;we in hi-res?
beq fininit		;yup, go finish init!

_MHXO:
move.w #$1111,XODD(A0)	;set up med-res X odd repeat
_MHXE:
move.w #$1111,XEVEN(A0)	;set up med-res Y odd repeat

move.w #200,XLIMIT(A0)	;set backwards X limit value
tst.w REZ(a0)		;is it REALLY med-res?
bne fininit		;yes!

_LHYO:
move.w #$1111,YODD(A0)	;set up low-res Y odd repeat
_LHYE:
move.w #$1111,YEVEN(A0)	;set up low-res Y even repeat

move.w #320,YLIMIT(A0)	;set backwards Y limit value

***************************************
* set init string and send to printer *
***************************************

fininit:
bsr gettab		;point to string table
_INITOFF:
adda.w #$1111,a3	;add init string offset to base address
_INITSIZ:
move.w #$1111,d2	;get init length
ext.l d2		;make it a LONG value
bsr printit		;print the init stuff
bpl exit		;and exit if OK!

******************************
* exit w/error condition (0) *
******************************

error:
movem.l (a0),d0-a7
move.l d0,a0
clr.w d0		;0 indicates error
rts

**********************************
* exit the subroutine (no error) *
**********************************

exit:
movem.l (a0),d0-a7
move.l d0,a0
move.w #1,d0		;1 indicates success
rts

******************************
* exit w/abort condition (2) *
******************************

abort:
movem.l (a0),d0-a7
move.l d0,a0
move.w #2,d0		;2 indicates abort
rts

******************************************
* process the pixels and send to printer *
******************************************

process:
clr.w ENDFLAG(a0)		;clear end-of-dump flag
clr.w YSPECIAL(a0)		;reset Y repeat count
clr.w Y(a0)			;reset screen pixel Y coord
clr.w PRTY(a0)			;reset printer pixel Y coord

loop10:
move.w Y(a0),YSTART(a0)		;set up YSTART variable = screen Y
move.w PRTY(a0),PYSTART(a0)	;set up PYSTART variable = printer Y
clr.w X(a0)			;start at screen X = 0
clr.w PRTX(a0)			;and printer X = 0

bsr gettab			;get string table start
adda.w SOFF(a0),a3		;add line start string offset
move.w SSIZ(a0),d2		;get line start string length
ext.l d2			;make length a LONG
bsr printit			;print the start string stuff
bmi error			;and branch if error!

loop20:
move.w X(a0),d0			;get screen X
andi.w #1,d0			;is it odd or even?
bne xodd			;it's odd!

move.w XEVEN(a0),XR(a0)		;set X repeat to XEVEN
bra loop30			;and branch

xodd:
move.w XODD(a0),XR(a0)		;set X repeat to XODD

loop30:
move.w PINS(a0),HEADCT(a0)	;init the number of pins in the print head

_HMINIT:
move.l #$11111111,HEADMASK(a0)	;init the head mask
clr.l BUFFER(a0)		;clear the print buffer
move.w Y(a0),d0			;get the screen Y coord
cmp.w YSTART(a0),d0		;is it = YSTART?
bne loop40			;no, process normally

tst.w YSPECIAL(a0)		;any Y repeat left over?
beq loop40			;no, handle it normally

move.w YSPECIAL(a0),YR(a0)	;get special Y repeat
bra loop50			;and continue processing

loop40:
move.w Y(a0),d0			;get screen Y coord
andi.w #1,d0			;is it odd or even?
bne yodd			;it's ODD!

move.w YEVEN(a0),YR(a0)		;set Y repeat to YEVEN
bra loop50			;and continue

yodd:
move.w YODD(a0),YR(a0)		;set Y repeat to YODD

loop50:
tst.w VERT(a0)			;is it a vertical dump?
beq swapxy			;no!
move.w X(a0),GETX(a0)		;set up the X...
move.w Y(a0),GETY(a0)		;and Y coords normally
bra getit			;and go get the pixel!

swapxy:
move.w XLIMIT(A0),d0		;set up the X...
subq.w #1,d0			;and Y coordinates...
sub.w X(a0),d0			;backwards...
move.w d0,GETY(a0)		;for a sideways...
move.w Y(a0),GETX(a0)		;screen dump!

getit:
bsr getpixel			;get the pixel
subq.w #1,YR(a0)		;decrement Y repeat value

lea 1200(a0),a3			;point to black masks
lsl.w d0			;get offset for grayscale

move.w PRTX(a0),d1		;get printer X coord
and.l #$0000ffff,d1		;mask it
_SCALE1:
divu.w #$1111,d1		;divide by pattern scale factor
andi.w #3,d1			;mask it for a 4X4 pattern

move.w PRTY(a0),d2		;get printer Y coord
and.l #$0000ffff,d2		;mask it
_SCALE2:
divu.w #$1111,d2		;divide by pattern scale factor
andi.w #3,d2			;mask it for a 4X4 pattern
lsl.w #2,d2			;multiply by 4...
add.w d2,d1			;and add X pattern index
move.w #$8000,d2		;set up mask
lsr.w d1,d2			;shift bit into position
and.w 0(a3,d0.w),d2		;check black mask bit
beq dont_or			;it's off!

move.l BUFFER(a0),d2		;get printer buffer data
or.l HEADMASK(a0),d2		;and turn on appropriate bits
move.l d2,BUFFER(a0)		;when done, return to buffer storage area

dont_or:
move.l HEADMASK(a0),d0		;get head mask back again

_SHIFT:
lsr.l d0			;either lsl or lsr (see C program)

move.l d0,HEADMASK(a0)		;put back in head mask
addq.w #1,PRTY(a0)		;increment printer X coord
subq.w #1,HEADCT(a0)		;and decrement head counter
bne notfull			;branch if more to do

******************************
* Head's full, check for end *
******************************

move.w Y(a0),d0			;get Y coordinate
cmp.w YLIMIT(a0),d0		;at Y limit?
bmi notend			;nope!
move.w #1,ENDFLAG(a0)		;yes!  Set end flag!

notend:
move.w YR(a0),NEWSPECIAL(a0)	;save Y repeat for start of next head pass
move.w Y(a0),NEWY(a0)		;and save Y coordinate for next pass
tst.w YR(a0)			;is Y repeat = 0?
bne dumpit			;no, go dump buffer!
addq.w #1,NEWY(a0)		;no Y repeat, increment NEWY
move.w NEWY(a0),d0		;get new Y coordinate
cmp.w YLIMIT(a0),d0		;at Y limit?
bmi dumpit			;nope!  Continue normally
move.w #1,ENDFLAG(a0)		;yes!  Set end flag!
bra dumpit			;and go do the buffer dump!

***************************
* Print head not full yet *
***************************

notfull:
tst.w YR(a0)			;is Y repeat = 0?
bne loop50			;no!
addq.w #1,Y(a0)			;repeat done, increment screen Y

move.w Y(a0),d0			;get screen Y...
cmp.w YLIMIT(a0),d0		;is it at the limit?
bmi loop40			;nope!
move.w #1,ENDFLAG(a0)		;at limit!  Set end flag!

dumpit:
addq.w #1,PRTX(a0)		;increment printer X coordinate
lea BUFFER(a0),a3		;point to data buffer

_HEADSIZE:
move.w #$1111,d2		;get head size (1,2, or 3 bytes)
ext.l d2			;make it a LONG value
bsr printit			;send to printer
bmi error			;and branch if error!

move.w YSTART(a0),Y(a0)		;get Y start for this head pass
move.w PYSTART(a0),PRTY(a0)	;get printer Y start for this pass
subq.w #1,XR(a0)		;decrement X repeat for this pixel,
bne loop30			;branch if more repeats necessary!

addq.w #1,X(a0)			;increment screen X

move.w X(a0),d0			;get screen X coord
cmp.w XLIMIT(a0),d0		;at limit?
bmi loop20			;no, continue processing!

******************
* Terminate line *
******************

bsr gettab			;get string table base address
_ENDOFF:
adda.w #$1111,a3		;add end-of-line string offset
_ENDSIZ:
move.w #$1111,d2		;get end-of-line string length
ext.l d2			;make length a LONG value
bsr printit			;print it!
bmi error			;branch if error

bsr pabchk			;check for UNDO
tst.w d0			;UNDO?
bne wrapup			;yes -- abort!

tst.w ENDFLAG(a0)		;end of dump?
bne wrapup			;yes, wrap it up!

move.w NEWSPECIAL(a0),YSPECIAL(a0) ;get new line special repeat
move.w NEWY(a0),Y(a0)		;get new line Y start
move.w PYSTART(a0),d0		;get old printer Y start
add.w PINS(a0),d0		;increment by the number of pins printed
move.w d0,PRTY(a0)		;and put in printer Y coord
bra loop10			;loop to continue!

*******************************************************
* Dump is done, send cleanup string (if any) and exit *
*******************************************************

wrapup:
bsr gettab			;get string table base address 
_CLEANOFF:
adda.w #$1111,a3		;point to cleanup string
_CLEANSIZ:
move.w #$1111,d2		;get cleanup string length
ext.l d2			;make it a LONG value
beq noclean			;if length = 0, don't print anything
bsr printit			;print cleanup string
bmi error			;branch if error!

noclean:
bra exit			;that's all, folks!!!

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

****************************
* Check for UNDO key abort *
****************************

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

***********************************
* GET a pixel & return brightness *
***********************************

getpixel:
link a5,#-24		;save the registers on stack
move.l a0,(sp)
move.l a1,-(sp)
move.l a2,-(sp)
move.l d1,-(sp)
move.l d2,-(sp)
move.l d3,-(sp)

tst.w REZ(a0)		;low rez?
beq get0		;yup!
cmpi.w #1,REZ(a0)	;medium rez?
beq get1		;yup!

************************
* Get a high-rez pixel *
************************

move.w GETY(a0),d0	;get Y coordinate
and.l #$0000ffff,d0	;mask it
mulu #80,d0		;mult. by 80
adda.l d0,a1		;add to screen base
move.w GETX(a0),d1	;get X
move.w d1,d2		
lsr.w #3,d1		;divide X by 8
adda.w d1,a1		;add to screen pointer
move.b (a1),d0		;get screen byte
and.l #7,d2		;get byte mask number
move.b #$80,d1		;set up bit mask
lsr.b d2,d1		;shift mask into position
and.b d1,d0		;mask a bit
beq set0		;bit's off!

move.w 2(a2),d0		;get color register #1
bra set1

set0:
move.w 0(a2),d0		;get color register #0

set1:
and.w #1,d0		;test low bit of color value (0=black, 1=white)
bne c_777		;it's ON!

c_000:
clr.w d0		;it's OFF, brightness=0!
bra getexit

c_777:
move.w #7,d0		;it's ON, brightness=7!
bra getexit

***********************
* Get a med-rez pixel *
***********************

get1:
clr.w d0		;zero result register
move.w GETY(a0),d3	;grab Y coordinate
and.l #$0000ffff,d3	;mask it off
mulu #160,d3		;multiply by 160 (# of bytes per scan line)
adda.l d3,a1		;add to screen base address
move.w GETX(a0),d1	;get X coordinate
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
beq lookup		;it's off, go exit.
or.w #2,d0		;it's on, turn on appropriate color bit in result
bra lookup

***********************
* Get a low-rez pixel *
***********************

get0:
clr.w d0		;zero result register
move.w GETY(a0),d3	;get Y coordinate
and.l #$0000ffff,d3	;mask off for multiply
mulu #160,d3		;multiply by 160 (# of bytes per scan line)
adda.l d3,a1		;add to screen base address
move.w GETX(a0),d1	;get X coordinate
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
beq lookup		;it's off!
or.w #8,d0		;turn on bit 3 in result

**************************************
* Got the color register number, now *
* look up the corresponding color in *
* the color palette array...         *
**************************************

lookup:
move.w d0,d1		;put pixel index in d1
lsl.w d1		;multiply by 2
move.w 0(a2,d1.w),d0	;get color 000-777
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
move.w d2,d0		;return in D0

getexit:
move.l (sp)+,d3		;restore registers
move.l (sp)+,d2	
move.l (sp)+,d1
move.l (sp)+,a2
move.l (sp)+,a1
move.l (sp)+,a0
unlk a5
rts

************************
* Point to string area *
************************

gettab:
lea 4(pc),a3	;point to _STRINGS label (4 from PC)
rts

************************************************
* This is where we put all our working strings *
************************************************

_STRINGS:

.ds.l 500	;pad to make sure it's at least 2000 bytes

******************************
* That's all for the driver! *
******************************

**********************************************
* Miscellaneous stuff for the maker program. *
* Doesn't wind up in printer driver!	     *
**********************************************

_lshift:
lsl.l d0	;left shift register D0 instruction opcode

_rshift:
lsr.l d0	;right shift register D0 instruction opcode

*****************************************
* Memory-mover routine			*
*					*
* movem(from,to,count)			*
*					*
* from:  LONG address of source data	*
* to:    LONG address of destination	*
* count: LONG byte count to move	*
*****************************************

_movem:
move.l 4(a7),a0		;from
move.l 8(a7),a1		;to
move.l 12(a7),d0	;bytes to move

mvloop:
move.b (a0)+,(a1)+
subq.l #1,d0
bne mvloop
rts
