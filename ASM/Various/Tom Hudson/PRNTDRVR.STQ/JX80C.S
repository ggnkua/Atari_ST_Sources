***********************************
* Epson JX-80 color screen dumper *
*      Written by Tom Hudson      *
* Copyright 1986, not to be sold  *
***********************************

X .equ 66		;screen X coordinate
Y .equ 68		;screen Y coordinate
REZ .equ 70		;resolution indicator
PRTX .equ 72		;printer X coordinate
PRTY .equ 74		;printer Y coordinate
YTIME .equ 76		;Y coord repeat count
XTIME .equ 78		;X coord repeat count
COLOR .equ 80		;color bit mask (yellow, magenta, cyan)
SAVE .equ 82		;temporary storage
PHASE .equ 84		;printer bit phase
XMAX .equ 86		;screen X limit
MASK .equ 88		;printer pin mask
YCOUNT .equ 90		;Y counter

BLACK .equ 200		;gray-scale table offset
WHITE .equ 300		;white-scale table offset

.globl _dumper		;convenient label for dump routine

.text

_dumper:

move.l a0,d0		;save A0
move.l 16(a7),a0	;point A0 at the work area start
movem.l d0-a7,(a0)	;save all registers
move.l 8(a7),a1		;point A1 to screen base
move.l 12(a7),a2	;point A2 to palette start address
tst.w 4(a7)		;initialize command (0)?
bne process		;no, dump it!

* reset & initialize printer *

init:

* BUILD BLACK PIXEL TABLE *

move.w #%1111111111111111,200(a0)	;Black...
move.w #%1111011011110110,202(a0)
move.w #%1011011010110110,204(a0)
move.w #%1001011010010110,206(a0)
move.w #%1000011010000110,208(a0)
move.w #%1000001010000010,210(a0)
move.w #%1000000010000000,212(a0)
move.w #%0000000000000000,214(a0)	;...to white

* BUILD WHITE PIXEL TABLE *

move.w #%1000000000000000,300(a0)	;low white...
move.w #%1000000010000000,302(a0)
move.w #%1000001010000000,304(a0)
move.w #%1000001010000010,306(a0)
move.w #%1000011010000010,308(a0)
move.w #%1000011010000110,310(a0)
move.w #%1001011010000110,312(a0)
move.w #%1001011010010110,314(a0)
move.w #%1011011010010110,316(a0)
move.w #%1011011010110110,318(a0)
move.w #%1111011010110110,320(a0)
move.w #%1111011011110110,322(a0)
move.w #%1111111011110110,324(a0)
move.w #%1111111011110111,326(a0)	;...to high white

* set init string *

fininit:
bsr preset			;reset printer
tst.w d0			;reset successful?
bmi error			;no!
move.l #$1b410800,150(a0)	;reset, set linefeed to 8 dots
move.l #3,d2			;3 bytes in init string
lea 150(a0),a3			;point to init string
bsr printit			;and print it!
clr.l 150(a0)			;clear that portion of work area
tst.w d0			;was print OK?
bpl exit			;yes!

* exit w/error condition (0) *

error:
movem.l (a0),d0-a7		;restore registers
move.l d0,a0			;restore old A0
clr.w d0			;set error condition
rts

* exit the subroutine (no error) *

exit:
movem.l (a0),d0-a7		;restore registers
move.l d0,a0			;restore old A0
move.w #1,d0			;set OK condition
rts

* exit w/abort condition (2) *

abort:
movem.l (a0),d0-a7		;restore registers
move.l d0,a0			;restore old A0
move.w #2,d0			;set abort condition
rts

* process the pixels and send to printer *

process:
move.w 6(a7),REZ(a0)		;save resolution
tst.w 6(a7)			;was it 0 (low)?
beq lowvert			;yes!

cmp.w #1,6(a7)			;was it 1 (medium)?
beq medvert			;yes!

bra abort			;can't dump hires with this dumper!

* MEDIUM-REZ PROCESSOR *

medvert:
move.w #640,XMAX(a0)		;set X maximum
bra ALLDUMP			;and dump it!

* LOW-REZ PROCESSOR *

lowvert:
move.w #320,XMAX(a0)		;set X maximum

ALLDUMP:
clr.w Y(a0)			;start at Y=0
clr.w PRTY(a0)			;and printer Y=0
move.l #$80,MASK(a0)		;init pin mask

* GET PIXEL *

newpass:
move.b #%100100,COLOR(a0)	;start with yellow pass

nx0strt:
bsr linestrt			;start off the print operation

clr.w X(a0)			;set screen X coord to 0
clr.w PRTX(a0)			;set printer X coord to 0

nx0yel:
tst.w REZ(a0)			;low-res?
beq threex			;yes, that's three printer dots!
move.w X(a0),d1			;grab screen X
and.w #1,d1			;is is even?
beq onex			;yes, that gets only 1 printer dot
move.w #2,XTIME(a0)		;it's odd, make it 2 printer dots.
bra doppix			;do convert on pixel

onex:
move.w #1,XTIME(a0)		;set up 1 printer dot
bra doppix

threex:
move.w #3,XTIME(a0)		;set up 3 printer dots

doppix:
bsr procit			;process the pixel
bmi error			;if error, return.

addq.w #1,X(a0)			;increment screen X coord
move.w X(a0),d1			;get the X coord
cmp.w XMAX(a0),d1		;end of screen scan line?
bne nx0yel			;nope, loop for more!

move.b #$0D,150(a0)		;new color, send CR
move.l #1,d2			;1 byte to print
lea 150(a0),a3			;point to the CR
bsr printit			;and print it!
clr.l 150(a0)			;clear that part of the work area
bsr pabchk			;check for abort (UNDO)
tst.w d0			;abort?
beq NOabort			;no!
bsr preset			;they bailed out, reset printer
bra abort			;and exit w/abort condition

NOabort:
move.b COLOR(a0),d1		;get color mask
lsr.b #1,d1			;shift right one bit
move.b d1,COLOR(a0)		;and put back in the mask
and.b #%111000,d1		;done with all 3 colors?
bne nx0strt			;no, loop for next color

move.b #$0a,150(a0)		;new line, send LF
move.l #1,d2			;a LF is just 1 byte,
lea 150(a0),a3			;point to LF
bsr printit			;and print it!
clr.l 150(a0)			;clear that area
addq.w #4,Y(a0)			;increment screen Y by 4 (4 lines per pass)
add.w #8,PRTY(a0)		;add 8 to printer's Y (8 pins per pass)
cmpi.w #200,Y(a0)		;end of screen?
bmi newpass			;no!
bsr preset			;all done, reset printer
bra exit			;and exit!

preset:
move.w #$1b40,150(a0)		;set up printer reset codes
move.l #2,d2			;it's 2 bytes
lea 150(a0),a3			;point to string
bsr printit			;reset printer!
clr.l 150(a0)			;clean up print buffer
rts				;and exit!

linestrt:
move.l #$1B72001B,150(a0)	;set up start of color set string
cmpi.b #%100100,COLOR(a0)	;yellow pass?
bne notyel			;no, try magenta
move.b #$34,152(a0)		;it's yellow, set ribbon color
bra setcolor			;and do it.

notyel:
cmpi.b #%010010,COLOR(a0)	;magenta?
bne notmag			;no, it's cyan!
move.b #$31,152(a0)		;set ribbon color to magenta
bra setcolor			;and do it.

notmag:
move.b #$32,152(a0)		;set ribbon color to cyan!

setcolor:
move.l #$4CC00300,154(a0)	;set up end of string (dots per line = 960)
move.l #7,d2			;7 bytes to print
lea 150(a0),a3			;point to string
bsr printit			;and print them!
clr.l 150(a0)			;clear print area
clr.l 154(a0)
rts

procit:
move.w #4,YCOUNT(a0)		;do 4 screen pixels per head pass

proc2:
bsr getpixel			;get a pixel!
move.w #2,YTIME(a0)		;each pixel repeated 2X (8 pins/4 pixels)
bsr ppix			;convert pixel & send to printer
bmi procx			;exit if error
addq.w #1,Y(a0)			;next screen Y coord
subq.w #1,YCOUNT(a0)		;1 less pixel to do
bne proc2			;loop if more
addq.w #1,PRTX(a0)		;increment printer X count
subq.w #4,Y(a0)			;reverse Y coord to top of print head
sub.w #8,PRTY(a0)		;and printer Y as well
subq.w #1,XTIME(a0)		;decrement X repeat counter
bne procit			;loop if more
clr.w d0			;clear error flag
procx:
rts				;and return

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

getpixel:
cmpi #200,Y(a0)		;Y beyond end of screen?
bmi getit		;no, get the pixel
move.b #-1,d0		;return -1 for color
rts			;and exit

getit:
tst.w REZ(a0)		;low rez?
beq get0		;yes, get low-rez pixel!

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

* CHANGE COLOR TO PRINTER FORMAT *
* AND PUT IN PRINT LINE          *

ppix:
move.w PRTX(a0),d1	;get printer X coordinate
move.w PRTY(a0),d2	;get printer Y coordinate
and.w #3,d1		;mask X to 0-3
and.w #3,d2		;mask Y to 0-3
lsl.w #2,d2		;multiply Y by 4
add.w d2,d1		;add them for index of 0-15 for printer pixel table
move.w d1,PHASE(a0)	;got printer black/white phase index, put in PHASE

move.b d0,SAVE(a0)	;save the color for repeat use
tst.b d0		;is color >= 0?
bpl d0OK		;yes!
clr.w d0		;no, change it to 0

d0OK:
move.b d0,d1		;duplicate color in D1
andi.l #$000000ff,d1	;mask it
lsl.l #1,d1		;multiply by 2 for index into palette
add.l a2,d1		;add to palette base address
movea.l d1,a5		and put in an address register
move.w (a5),d0		;got color 000-777
move.w d0,d2		;duplicate it...
and.w #7,d2		;get blue index
move.w d0,d1		;duplicate again...
and.w #$0070,d1		;get green index
lsr.w #1,d1		;shift the green index right 1 bit
add.w d1,d2		;and add to total
move.w d0,d1		;duplicate again!!
and.w #$0700,d1		;get red index
lsr.w #2,d1		;shift right 2 bits
add.w d1,d2		;now we have a color # of 0-511

bsr getcvals		;get color bit table addr in a5
move.w d0,d3		;not AGAIN?? (gotta save it for next operation)
move.b 0(a5,d2.w),d0	;load color bits

* calc color brightness total *

move.w d3,d1		;put color in D1
and.w #7,d1		;mask blue brite
move.w d3,d2		;put color in D2
lsr.w #4,d2		;divide by 4 and...
and.w #7,d2		;mask green brite
add.w d2,d1		;add to total brite
lsr.w #8,d3		;now shift color 8 bits right...
and.w #7,d3		;mask red brite
add.w d3,d1		;add to total brite

tst.b d0		;table color bits = %000000 (gray scale)?
beq grayit		;yes!

cmp.w #7,d1		;total brite < 7?
bmi blakck		;yes, add some black!

beq normal		;brightness = 7, it's a solid color!

whitck:
move.w PHASE(a0),d2	;get printer pixel phase (0-15)
sub.w #8,d1		;decrement pixel brightness by 8
lsl.w d1		;and multiply by 2 for index
lea 0(a0,d1.w),a5	;generate a table offset using brightness
adda.l #WHITE,a5	;index into WHITE table
move.w (a5),d3		;get white addition word
btst.l d2,d3		;and check bit indicated by PHASE
bne nobitson		;if bit is on, make it white!
bra normal		;otherwise, make it normal color

grayit:
and.l #$000000FF,d1	;mask in preparation for divide
divu #3,d1		;divide brightness by 3
move.w PHASE(a0),d2	;get printer phase
lsl.w d1		;multiply brightness by 2 for index
lea 0(a0,d1.w),a5	;generate a table offset using brightness / 3
adda.l #BLACK,a5	;index into BLACK table
move.w (a5),d3		;get black addition word
btst.l d2,d3		;check bit indicated by PHASE
bne turnbitson		;if it's on, add black!
bra nobitson		;otherwise, it's white!

blakck:
move.w PHASE(a0),d2	;get printer pixel phase
lsl.w d1		;multiply brightness by 2 for index
lea 0(a0,d1.w),a5	;generate an offset using brightness
adda.l #BLACK,a5	;index into BLACK table
move.w (a5),d3		;grab black addition word
btst.l d2,d3		;if it's on, add black
bne turnbitson		;otherwise, it's normal color

normal:
and.b COLOR(a0),d0	;mask the table color with color pass bits (y, m or c)
move.w PRTX(a0),d1	;get printer X coord
add.w PRTY(a0),d1	;add printer Y coord
and.w #1,d1		;is it an even pixel?
beq evenpix		;yes!

* ODD pixel on printer, use color 2

lsr.b #3,d0		;shift so color #2 is used
bra orit		;and go put in printer byte

evenpix:
and.b #7,d0		;use color #1

orit:
tst.b d0		;any bits on?
beq nobitson		;no!

turnbitson:
tst.b SAVE(a0)		;is original pixel on screen?
bmi nobitson		;no, leave white!
move.l 150(a0),d0	;get printer byte
or.l MASK(a0),d0	;OR on the appropriate bit
move.l d0,150(a0)	;and put byte back

nobitson:
move.l MASK(a0),d2	;get printer pin mask
lsr.l d2		;move to next pin
move.l d2,MASK(a0)	;save mask
tst.l d2		;any more pins left?
bne noprtyet		;yes!

move.l #$80,MASK(a0)	;reset pin mask to top pin
move.l #1,d2		;1 byte to print
lea 153(a0),a3		;point to byte
bsr printit		;and print the byte!
bmi ppixout		;branch if error
clr.l 150(a0)		;clear print work area

noprtyet:
addq.w #1,PRTY(a0)	;increment printer Y coordinate
move.b SAVE(a0),d0	;restore color to D0
subq.w #1,YTIME(a0)	;decrement Y repeat counter
bne ppix		;loop back if more
clr.w d0		;zero D0 to report success

ppixout:
rts

********************************************
* Color table start -- do not add any code *
* between GETCVALS and CVALUES!            *
********************************************

getcvals:
lea 4(pc),a5		;point A5 at our color value table
rts

***************************************************************
* The CVALUES table is a 512-byte table (one byte per color   *
* combination possible on the ST.)  Each byte is made up of   *
* two color indicator bit groups.  Bits 0-2 are termed        *
* color 1, and are used when the printer pixel X and Y        *
* coordinates add to an even value.  Bits 3-5 are termed      *
* color 2, and are used when the printer pixel X and Y        *
* coordinates add to an odd value.  The three bits in each    *
* color represent (from high bit to low bit) yellow, magenta  *
* and cyan.  That is, 100 is yellow, 010 is magenta, 001 is   *
* cyan.  These bits are combined to make: 011=blue, 101=green,*
* 110=red, 111=black, 000=white.  Gray scales are represented *
* by 000, and are automatically shaded by the color routine.  *
***************************************************************

cvalues:

* 000-077 *

.dc.b %000000,%011001,%011001,%011001,%011001,%011001,%011001,%011001
.dc.b %101101,%001001,%011101,%011101,%011001,%011001,%011001,%011001
.dc.b %101101,%101011,%001001,%011101,%011101,%011001,%011001,%011001
.dc.b %101101,%101101,%101001,%001001,%001001,%011001,%011101,%011101
.dc.b %101101,%101101,%101011,%101001,%001001,%001001,%011101,%011101
.dc.b %101101,%101101,%101101,%101011,%101011,%001001,%011001,%011001
.dc.b %101101,%101101,%101011,%101011,%101011,%101011,%001001,%011001
.dc.b %101101,%101101,%101101,%101011,%101011,%101011,%101001,%001001

* 100-177 *

.dc.b %110110,%010010,%011010,%011010,%011001,%011001,%011001,%011001
.dc.b %100100,%000000,%011001,%011001,%011001,%011001,%011001,%011001
.dc.b %101100,%101101,%001001,%011001,%011001,%011001,%011001,%011001
.dc.b %101101,%101011,%101001,%001001,%011001,%011101,%011001,%011001
.dc.b %101101,%101101,%101011,%101001,%001001,%011001,%011101,%011001
.dc.b %101101,%101101,%101101,%101011,%101001,%001001,%011001,%011001
.dc.b %101101,%101101,%101101,%101011,%101011,%101001,%001001,%011001
.dc.b %101101,%101101,%101101,%101101,%101011,%101011,%101001,%001001

* 200-277 *

.dc.b %110110,%110010,%010010,%011010,%011010,%011001,%011001,%011001
.dc.b %110100,%110110,%010010,%011010,%011010,%011001,%011001,%011001
.dc.b %100100,%100100,%000000,%011001,%011001,%011001,%011001,%011001
.dc.b %100100,%100100,%100100,%001001,%011001,%011001,%011001,%011001
.dc.b %101100,%101100,%101101,%101001,%001001,%011001,%011001,%011001
.dc.b %101101,%101101,%101101,%101101,%101001,%001001,%011001,%011001
.dc.b %101101,%101101,%101101,%101101,%101101,%101001,%001001,%011001
.dc.b %101101,%101101,%101101,%101101,%101101,%101101,%101001,%001001

* 300-377 *

.dc.b %110110,%110110,%110010,%010010,%011010,%011001,%011001,%011001
.dc.b %110110,%110010,%110010,%010010,%011010,%011010,%011001,%011001
.dc.b %110100,%110100,%110110,%010010,%011010,%011001,%011001,%011001
.dc.b %100100,%100100,%100100,%000000,%011001,%011001,%011001,%011001
.dc.b %101100,%101100,%101100,%101001,%001001,%011001,%011001,%011001
.dc.b %101101,%101101,%101101,%101101,%101001,%001001,%011001,%011001
.dc.b %101101,%101101,%101101,%101101,%101011,%101001,%001001,%011001
.dc.b %101101,%101101,%101101,%101101,%101101,%101101,%101001,%001001

* 400-477 *

.dc.b %110110,%110110,%110010,%110010,%010010,%011010,%011001,%011001
.dc.b %110110,%110110,%110110,%110010,%010010,%011010,%011001,%011001
.dc.b %110110,%110110,%110110,%110010,%010010,%011010,%011001,%011001
.dc.b %110100,%110100,%110110,%110110,%010010,%011010,%011010,%011001
.dc.b %100100,%100100,%100100,%100100,%000000,%011001,%011001,%011001
.dc.b %101100,%101100,%101100,%101101,%101101,%001001,%011001,%011001
.dc.b %101101,%101101,%101101,%101011,%101011,%101001,%001001,%011001
.dc.b %101101,%101101,%101101,%101101,%101011,%101011,%101001,%001001

* 500-577 *

.dc.b %110110,%110110,%110110,%110110,%110010,%010010,%011010,%011010
.dc.b %110110,%110110,%110110,%110110,%110010,%010010,%011010,%011010
.dc.b %110110,%110110,%110110,%110110,%110010,%010010,%011010,%011010
.dc.b %110100,%110100,%110110,%110110,%110010,%010010,%011010,%011010
.dc.b %110100,%110100,%110100,%110110,%110010,%010010,%011010,%011010
.dc.b %100100,%100100,%100100,%100100,%100100,%000000,%011001,%011001
.dc.b %101100,%101100,%101100,%101100,%101101,%101001,%001001,%011001
.dc.b %101100,%101100,%101100,%101101,%101011,%101001,%101001,%001001

* 600-677 *

.dc.b %110110,%110110,%110110,%110110,%110010,%110010,%010010,%011010
.dc.b %110110,%110110,%110110,%110110,%110010,%110010,%010010,%011010
.dc.b %110100,%110110,%110110,%110110,%110010,%110010,%010010,%011010
.dc.b %110100,%110100,%110100,%110110,%110010,%110010,%010010,%011010
.dc.b %110100,%110100,%110110,%110110,%110110,%110010,%010010,%011010
.dc.b %110100,%110100,%110100,%110100,%110100,%110110,%010010,%011010
.dc.b %100100,%100100,%100100,%100100,%100100,%100100,%000000,%011001
.dc.b %101100,%101100,%101100,%101100,%101100,%101100,%101101,%001001

* 700-777 *

.dc.b %110110,%110110,%110110,%110110,%110010,%110010,%110010,%010010
.dc.b %110110,%110110,%110110,%110110,%110010,%110010,%110010,%010010
.dc.b %110110,%110110,%110110,%110110,%110010,%110010,%110010,%010010
.dc.b %110110,%110110,%110110,%110110,%110010,%110010,%110010,%010010
.dc.b %110100,%110100,%110100,%110100,%110110,%110010,%110010,%010010
.dc.b %110100,%110100,%110100,%110100,%110100,%110110,%110010,%010010
.dc.b %110100,%110100,%110100,%110100,%110100,%110100,%110110,%010010
.dc.b %100100,%100100,%100100,%100100,%100100,%100100,%100100,%000000

filler .ds.l 500	;pad the end of the routine to be sure of 2000 bytes
