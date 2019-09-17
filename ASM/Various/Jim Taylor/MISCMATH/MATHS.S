* From: Jim Taylor, Sunderland.

* In reponse to Tony Harris's request for sine wave generation in
* assembler here are a few miscellaneous maths routines I have
* gleaned/written/poached/hacked over the years.
* The trig. routines are towards the end.


*===============================================================




* dascth		Convert a signed, null terminated ascii
*	"		string to a 32 bit hex value.
*			dascth [#]str_addr,result.l

dascth macro [#]addr_in,result.l
	move.l	\1,-44(sp)
	jsr	dascth
	move.l	-44(sp),\2
	endm
		
* Enter here with a0 point_ing to 1st byte.
* Exit with hex answer in d0.l
dascth	movem.l	d0-d4/a0-a3,-(sp)
	move.l	-4(sp),a0	* Address of ascii string
	clr.l	d0		* Clear answer reg.
	clr.l	d1		* Init. counter
	move.l	#adder,a1	* Init adder address
.get_null
	tst.b	(a0)		* Null?
	beq.s	.convert	* Yes
	adda.l	#1,a0		* Adv to next char
	addq	#1,d1		* Inc counter
	bra.s	.get_null
.convert
	dbra	d1,.get_byte
	bra	.done
.get_byte
	clr.l	d3		* Init scratchreg
	move.b	-(a0),d3	* Get an ascii char
	cmpi.b	#'-',d3		* Negative?
	beq.s	.neg
	subi	#'0',d3		* Convert to dec
	move.l	(a1)+,d2	* Get adder
	clr.l	d4		* Init	sub result
* Multiply adder by digit
.nxt	dbra	d3,.add
	bra	.updat
.add	add.l	d2,d4
	bra	.nxt
* Add on product
.updat	add.l	d4,d0		* Update answer
	bra.s	.convert
.neg	neg.l	d0
.done	move.l	d0,-4(sp)
	movem.l	(sp)+,d0-d4/a0-a3
	rts
adder	dc.l	1
	dc.l	10
	dc.l	100
	dc.l	1000
	dc.l	10000
	dc.l	100000
	dc.l	1000000
	dc.l	10000000
	dc.l	100000000
	dc.l	1000000000
	dc.l	10000000000



*===============================================================


* hex_to_ascii		Convert a hex value to a null terminated
*	"		ascii string. [OBSOLETE]
*			eg. hex_to_ascii d1,ascnum

hex_to_ascii macro source_of_data.l,destination_address
	move.l	\1,d0
	lea	\2,a0
	jsr	hex_to_ascii
	endm

hex_to_ascii
* Enter with hex number in d0.l. Exit with dec number in d0.l
	jsr	hex_to_dec
* Enter with dec number in d0.l and destination address of ascii
* characters in a0
	jsr	dec_to_ascii
	rts

*===============================================================


* hexasc		Convert a hex value in d0 to an ascii
*	"		string in ASCNUM.

* Enter with hex number in d0. Exit with 1st ascii char in ASCNUM and
* number of characters in d0. Uses d1,d2,d3 & a0
hexasc	jsr	hex_to_dec
	jsr	decasc
	rts

*===============================================================


* hex_to_dec		Convert a hex value to decimal

* Enter with hex number in d0.l. Return with dec number in d0. Uses d1
* & d2
hex_to_dec
	movem.l	d1-d2,-(sp)
	clr.l	d1		* Clear the answer register
	move.l	#1000,d2	* Init multiplier
.hex3	cmp.l	d0,d2		* Is multiplier not too big
	ble	.hex1		* Apparently
	cmpi	#1,d2		* Multiplier = 1? (ie. finished)
	beq	.hex2		* Yes
	asl.l	#4,d1
	divu	#10,d2
	bra	.hex3
.hex1	sub.l	d2,d0
	cmpi.b	#9,d1
	bne	.hex4
	addq.b	#6,d1		* 9+6=$f:  $f+1=$10
.hex4	addq.b	#1,d1
	bra	.hex3
.hex2	move.l	d1,d0
	movem.l	(sp)+,d1-d2
	rts

*===============================================================


* hex_to_asc		Convert 16bit value to 4 ascii hex digits
*			From page 11-6 of:
*			  '68000 Assembly Language Programming'

hex_to_asc
	move.l	#ascnum,-(sp)
	move	d0,-(sp)
	jsr	binhex
	rts

binhex	movem.l	d0-d2/a0,-(sp)
	moveq	#3,d1		* Loop ctr 4-1
	move	16+4(sp),d2	* Get value
	move.l	16+6(sp),a0	* Get string addr
	adda.l	#4,a0		* Adjust pointer past end of string
.loop	move.b	d2,d0
	andi.b	#$f,d0
	jsr	hexdigit
	move.b	d0,-(a0)	* Save ascii digit
	lsr.w	#4,d2		* Shift d2 to get next nibble
	dbra	d1,.loop
	movem.l	(sp)+,d0-d2/a0
	move.l	(sp),6(sp)	* Move return addr down
	adda.l	#6,sp		* Adjust stack pointer to ret addr
	rts

hexdigit
	cmp.b	#$a,d0		* Decimal digit or hex letter?
	blt.s	.addz
	add.b	#'A'-'0'-$a,d0	* Offset for letters
.addz	add.b	#'0',d0		* Convert to ascii
	rts


*===============================================================


* decasc		Convert a decimal value to an ascii string.

* Enter with dec value in d0.
* Exit with 1st ascii char in ASCNUM(0)
* and number of characters in d0. Uses d1,d2,d3 & a0
decasc	movem.l	d1-d3/d7/a0,-(sp)
	move.l	#ascnum,a0	* Get buffer address
	move.l	#7,d2		* Set digit counter
	move.l	#1,d3		* Init ascii char counter
	move.l	#$30,d1
.dec1	rol.l	#4,d0
	move.l	d0,d7		* Save value
	andi.l	#$f,d0		* Isolate digit
	cmpi.b	#0,d0
	bne	.dec2
	move.l	d7,d0		* Retrieve value
	dbra	d2,.dec1		* Skip leading zero's
	move.b	d1,(a0)+	* Store ascii zero
	bra	.dec4		* Return
.dec3	rol.l	#4,d0		* Get next digit
	move.l	d0,d7		* Save value
	andi.l	#$f,d0		* Isolate digit
	addq.l	#1,d3		* Inc. ascii character counter
	move.l	#$30,d1
.dec2	add.b	d0,d1		* Conv. to ascii in d1
	move.b	d1,(a0)+	* Store ascii character
	move.l	d7,d0		* Retrieve value
	dbra	d2,.dec3
.dec4	move.l	d3,d0		* Get ascii count
	movem.l	(sp)+,a0/d7/d1-d3
	rts

*===============================================================


* dec_to_ascii		Convert a decimal value to an ascii string.

* Enter with decimal value in d0.l
* Exit with ascii characters in ASCNUM
dec_to_ascii
	movem.l	d0-d2/a0,-(sp)
	move	#7,d1		* Counter
	clr	d2
.nulls	rol.l	#4,d0		* Move to next dec character
	move	d0,d2		* Get a character
	andi	#%1111,d2	* Isolate it
	tst.b	d2		* Null?
	bne	.chars		* No
	dbra	d1,.nulls
	clr	d1		* Answer is zero, so process it
.chars	clr	d2
	move.b	d0,d2		* Get a character
	andi	#%1111,d2	* Isolate it
	addi	#$30,d2		* Convert to ascii
	move.b	d2,(a0)+	* Store in memory
	rol.l	#4,d0		* Advance next character
	dbra	d1,.chars
	clr.b	(a0)		* Null terminator
	movem.l	(sp)+,d0-d2/a0
	rts

*===============================================================


* aschex		Convert dec. str to hex. value.

* Enter here with a0 point_ing 1 byte past last ascii byte.
* Exit with hex answer in d0
asch8	movem.l	d1-d3,-(sp)
	bra.s	asch5
* Enter here with a0 point_ing to ascii byte length in buffer.
* Exit with hex answer in d0
aschex	movem.l	d1-d3,-(sp)
	clr.l	d3
	move.b	(a0),d3		* String length in d3
	addi	#1,d3		* Inc string length
	add	d3,a0		* Go to lsb
	subq	#2,d3		* Adjust counter for dbra

asch5	clr.l	d0		* Clear answer register
.asch4	move.l	#1,d1		* Initialise counter
.asch3	move.b	-(a0),d2	* Get a digit
	cmpi.b	#'-',d2		* Is it a minus sign
	bne	.asch7
	neg	d0		convert to negative

.asch7	cmpi.b	#',',d2		= ','
	bne	.asch2
	swap	d0		put number into hi-bytes
	bra	.asch4
.asch2	cmpi.b	#$39,d2		d2>'9' (ie. all numbers done)
	bgt	.asch6
	cmpi.b	#$30,d2		d2<'0' (ie. all numbers done)
	blt	.asch6

	cmpi.b	#$31,d2		less than 1 ?
	blt	.asch1		down to zero ?
	add	d1,d0		no. inc answer
	sub	#1,d2		dec digit
	bra	.asch2
.asch1	mulu	#10,d1		inc counter
	dbra	d3,.asch3

.asch6	movem.l	(sp)+,d1-d3
	rts

ascdec	clr.l	d1
	clr.l	d0
	move.l	#wrtbuff,a1
.ascd2	move.b	(a1)+,d1
	cmpi.b	#'.',d1
	beq	.ascd3
	subi.b	#48,d1
.ascd1	asl	#4,d0
	add.l	d1,d0
	bra	.ascd2
.ascd3	rts

*===============================================================


* sqrt32		Calculates the square root of a
*	"		32 bit integer in d0.

* This routine calculates the square root of a 32 bit integer in d0
* max value 65536*200=13107200.
* Returns the square root as a 16 bit integer in the low word of d1.
* The original number in d0 is not affected.
sqrt32	movem.l	d2-d3,-(sp)	save scratch registers
	move.l	d0,d2		copy data value to d2
	divu	#200,d2		divide by 200
	addq	#2,d2		then add 2
.nxtapp	move.l	d0,d1		load data value value into d1
	divu	d2,d1		divide it by last approx.
	move	d1,d3		and put new approx in d3
	sub	d2,d3		last two approx's identical ?
	beq.s	.done		yes. exit
	cmpi	#1,d3		no. check for done.
	beq.s	.done
	cmpi	#-1,d3
	beq.s	.done
	add 	d1,d2		add last two approx's
	lsr	#1,d2		and divide sum by two
	bra.s	.nxtapp
.done	movem.l	(sp)+,d2-d3
	rts

*===============================================================


* sincosa		Sine & cosine function
*			sincosa angle*10,sine*16384,cos*16384

sincosa	macro	angle*10,sin,cos
	move	\1,-32(sp)
	jsr	sincosa
	move	-32(sp),\2
	move	-34(sp),\3
	endm

* sine and cosine Function, angle is passed in d0 and
* the sine and cosine are returned in d1 and d2
sincosa	movem.l	d0-d4/a0,-(sp)
	move	-4(sp),d0	* Retrieve angle from stack
	tst	d0		* Angle negative, add 360 degrees
	bpl	.noaddi
	add	#3600,d0
.noaddi	lea	sintab,a0	* Beginning address of sine table
	andi.l	#$ffff,d0
	divu	#10,d0		* Convert to angle
	swap	d0
	move	d0,d3		* Get remainder
	swap	d0
	lsl	#1,d0		* Angle times two as index for access
	move	0(a0,d0),d1	* sine to d1

	move	2(a0,d0),d4	* Next sine to d4
	sub	d1,d4		* Interpolate dec amount
	muls	d3,d4		* base+(next-base)*(rem/10)
	divs	#10,d4
	add	d4,d1

	cmp	#270*2,d0	* Calculate cosine through
	blt	.plus9		* displacement of sine values
	sub	#270*2,d0	* by 90 degrees
	bra	.sendsin
.plus9	add	#90*2,d0
.sendsin move	0(a0,d0),d2	* cosine to d2

	move	2(a0,d0),d4	* Next cosine to d4
	sub	d2,d4		* Interpolate dec amount
	muls	d3,d4		* base+(next-base)*(rem/10)
	divs	#10,d4
	add	d4,d2

	move	d1,-4(sp)
	move	d2,-6(sp)
	movem.l	(sp)+,d0-d4/a0
	rts

*===============================================================


* sincos		Sine & cosine function
*				sincos angle,sine,cos

sincos	macro	angle,sin,cos
	move	\1,-22(sp)
	jsr	sincos
	move	-22(sp),\2
	move	-24(sp),\3
	endm

* sine and cosine Function, angle is passed in d0 and
* the sine and cosine are returned in d1 and d2
sincos	movem.l	d0-d2/a0,-(sp)
	move	-2(sp),d0	* Retrieve angle from stack
	tst	d0		* Angle negative, add 360 degrees
	bpl	noaddi
	add	#360,d0
noaddi	lea	sintab,a0	* Beginning address of sine table
	move.l	d0,d2		* Angle in d0 and d2
	lsl	#1,d0		* Angle times two as index for access
	move	0(a0,d0),d1	* sine to d1
	cmp	#270,d2		* Calculate cosine through
	blt	plus9		* displacement of sine values
	sub	#270,d2		* by 90 degrees
	bra	sendsin
plus9	add	#90,d2
sendsin lsl	#1,d2
	move	0(a0,d2),d2	* cosine to d2
	move	d1,-2(sp)
	move	d2,-4(sp)
	movem.l	(sp)+,d0-d2/a0
	rts

*===============================================================


* sin			Sine function (d0=angle)
*				jsr	sin

* sine function
* Angle is passed in d0 and the sine returned in d1
sin	lea	sintab,a1
	tst	d0
	bpl	 sin1
	add	#360,d0
sin1	lsl	#1,d0
	move	0(a1,d0),d1
	rts

* sintab		Sine table for above sincos & sin

	section data
sintab
_0deg	dc.w	00000,00286,00572,00857,01143,01428,01713,01997,02280
	dc.w	02563
_10deg	dc.w	02845,03126,03406,03686,03964,04240,04516,04790,05063
	dc.w	05334
_20deg	dc.w	05604,05872,06138,06402,06664,06924,07182,07438,07692
	dc.w	07943
_30deg	dc.w	08192,08438,08682,08923,09162,09397,09630,09860,10087
	dc.w	10311
_40deg	dc.w	10531,10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365
_50deg	dc.w	12551,12733,12911,13085,13255,13421,13583,13741,13894
	dc.w	14044
	dc.w	14189,14330,14466,14598,14726,14849,14962,15082,15191
	dc.w	15296
	dc.w	15396,15491,15582,15668,15749,15826,15897,15964,16026
	dc.w	16083
	dc.w	16135,16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382

_90deg	dc.w	16384,16382,16374,16362,16344,16322,16294,16262,16225,16182
	dc.w	16135,16083,16026,15964,15897,15826,15749,15668,15582,15491
	dc.w	15396,15296,15191,15082,14962,14849,14726,14598,14466,14330
	dc.w	14189,14044,13894,13741,13583,13421,13255,13085,12911,12733
	dc.w	12551,12365,12176,11982,11786,11585,11381,11174,10963,10749
	dc.w	10531,10311,10087,09860,09630,09397,09162,08923,08682,08438
	dc.w	08192,07943,07692,07438,07182,06924,06664,06402,06138,05872
	dc.w	05604,05334,05063,04790,04516,04240,03964,03686,03406,03126
	dc.w	02845,02563,02280,01997,01713,01428,01143,00857,00572,00286

_180deg	dc.w	00000,-0286,-0572,-0857,-1143,-1428,-1713,-1997,-2280,-2563
	dc.w	-2845,-3126,-3406,-3686,-3964,-4240,-4516,-4790,-5063,-5334
	dc.w	-5604,-5872,-6138,-6402,-6664,-6924,-7182,-7438,-7692,-7943
	dc.w	-08192,-08438,-08682,-08923,-09162,-09397,-09630,-09860,-10087,-10311
	dc.w	-10531,-10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176,-12365
	dc.w	-12551,-12733,-12911,-13085,-13255,-13421,-13583,-13741,-13894,-14044
	dc.w	-14189,-14330,-14466,-14598,-14726,-14849,-14962,-15082,-15191,-15296
	dc.w	-15396,-15491,-15582,-15668,-15749,-15826,-15897,-15964,-16026,-16083
	dc.w	-16135,-16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374,-16382

_270deg	dc.w	-16384,-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	dc.w	-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668,-15582,-15491
	dc.w	-15396,-15296,-15191,-15082,-14962,-14849,-14726,-14598,-14466,-14330
	dc.w	-14189,-14044,-13894,-13741,-13583,-13421,-13255,-13085,-12911,-12733
	dc.w	-12551,-12365,-12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w	-10531,-10311,-10087,-09860,-09630,-09397,-09162,-08923,-08682,-08438
	dc.w	-8192,-7943,-7692,-7438,-7182,-6924,-6664,-6402,-6138,-5872
	dc.w	-5604,-5334,-5063,-4790,-4516,-4240,-3964,-3686,-3406,-3126
	dc.w	-2845,-2563,-2280,-1997,-1713,-1428,-1143,-0857,-0572,-0286
	dc.w	0,286
	section text

*===============================================================


* angle			Return angle from X & Y (d0.w=X d1.w=Y)
*			jsr	angle

* Return the angle generated by X & Y coords
*  In: d0.w - X coord   d1.w - Y coord
* Out: angle.w - _angle
angle	movem.l	d0-d6/a0-a2,-(sp)
	move	d0,d2		* Copy Y
	bpl	ang1
	neg	d2
ang1	move	d1,d3		* Copy X
	bpl	ang2
	neg	d3

ang2	cmp	d3,d2		* Y:X
	bge	ang3
	exg	d2,d3		* X<->Y
	jsr	det_ang
	neg	d4
	addi	#90,d4
	bra	ang4
ang3	jsr	det_ang
* Convert to full circle
ang4	tst	d0		* tst X
	bmi	ang5
	tst	d1		* tst Y
	bpl	ang7
	neg	d4
	addi	#360,d4
	bra	ang7
ang5	tst	d1
	bmi	ang6
	neg	d4
ang6	addi	#180,d4
ang7	cmp	#360,d4
	bne	ang8
	clr	d4
ang8	move	d4,_angle
	movem.l	(sp)+,d0-d6/a0-a2
	rts

* Determine angle
det_ang	mulu	#32768,d3
	tst	d2
	bne	da2
	clr	d4
	bra	da3
da2	divu	d2,d3		* 65535*Y/X
	lea	tantab,a0
da1	cmp	(a0)+,d3
	bhi	da1
	move.l	a0,d4
	sub.l	#tantab,d4
	asr	d4		* Angle
	subq	#1,d4
da3	rts


* tantab		Tangent table for above angle

	section data
tantab	dc.w	00286,00858,01431,02004,02579,03155,03733,04314,04897
	dc.w	05484
	dc.w	06073,06667,07265,07867,08474,09087,09706,10332,10964
	dc.w	11604
	dc.w	12252,12908,13753,14248,14933,15630,16338,17058,17792
	dc.w	18539
	dc.w	19302,12908,20876,21689,22521,23373,24247,25144,26065
	dc.w	27012
	dc.w	27987,28991,30026,31096,32201,33345
	section text

*===============================================================


* sine			Computed sine function
*			In:d0=angle Out:d1=2048*sine
*			sine	angle,sine

sine	macro	angle,sine
	move.l	\1,d0
	jsr	sine
	move.l	d1,\2
	endm

sine_b4	equ	$6c68
sine_b2	equ	-$767d61b6
sine_b1	equ	$23be8d44
sine_rnd equ	$8000
* Computed sine function. See ST World p78 issue 31
sine	movem.l	d2-d3,-(sp)
	move.l	#16,d3		* Shift count
	move.l	d0,d1		* Copy angle (x)
	muls	d1,d1		* x^2
	move.l	d1,d2		* Copy it
	muls	#sine_b4,d2	* (2^51)*b4*(x^2)
	addi.l	#sine_b2,d2	* (2^51)*[b2+b4*(x^2)]
	addi.l	#sine_rnd,d2	* Round off (try removing this)
	asr.l	d3,d2		* (2^35)*[b2+b4*(x^2)]
	muls	d2,d1		* (2^35)*(x^2)*[b2+b4*(x^2)]
	addi.l	#sine_b1,d1	* (2^35)*{b1+(x^2)*[b2+b4*(x^2)]}
	addi.l	#sine_rnd,d1	* Round off (try removing this)
	asr.l	d3,d1		* (2^19)*{b1+(x^2)*[b2+b4*(x^2)]}
	muls	d0,d1		* (2^19)*sin(x)
	asr.l	#8,d1		* 2048*sin(x)
	movem.l	(sp)+,d2-d3
	rts

*===============================================================


* cosine		Computed cosine function
*			In:d0=angle Out:d1=2048*cosine
*			cosine	angle,cosine

cosine	macro	angle,cosine
	move.l	\1,d0
	jsr	cosine
	move.l	d1,\2
	endm

cos_b4	equ	$7620
cos_b2	equ	-$4f539bb8
cos_b1	equ	$8000000
cos_rnd equ	$8000
* Computed cosine function. See ST World p79 issue 31
cosine	movem.l	d2-d3,-(sp)
	move.l	#16,d3
	move.l	d0,d1		* Copy angle (x)
	muls	d1,d1		* x^2
	move.l	d1,d2		* Copy it
	muls	#cos_b4,d2	* (2^43)*b4*(x^2)
	addi.l	#cos_b2,d2	* (2^43)*[b2+b4*(x^2)]
	addi.l	#cos_rnd,d2	* Round off (try removing this)
	asr.l	d3,d2		* (2^27)*[b2+b4*(x^2)]
	muls	d2,d1		* (2^27)*(x^2)*[b2+b4*(x^2)]
	addi.l	#cos_b1,d1	* (2^27)*{1+(x^2)*[b2+b4*(x^2)]}
	asr.l	d3,d1		* (2^11)*cosine(x)
	movem.l	(sp)+,d2-d3
	rts

*========================= End of File ================================


