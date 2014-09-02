*
*	SOUND.S   Interrupt-Driven ST Three-Voice Sound Handler
*
*	Started 2/26/86 .. R.Zdybel
*	Copyright 1986 ATARI Corp.
*

	.text

	.globl	initsound
	.globl	silence
	.globl	startsad
	.globl	startsound
	.globl	stopsound
	.globl	unsound

	.globl	redalsnd
	.globl	damagsnd
	.globl	nukesnd
	.globl	shotsnd
	.globl	togglsnd
	.globl	refitsnd
	.globl	cmponsnd
	.globl	cmpofsnd
	.globl	shonsnd
	.globl	shoffsnd
	.globl	pausnd
	.globl	scansnd
	.globl	surrsnd
	.globl	deadsnd
	.globl	explsnd0
	.globl	explsnd1
	.globl	explsnd2
	.globl	explsnd3
	.globl	explsnd4
	.globl	upengsnd
	.globl	dnengsnd
	.globl	uphpsnd0
	.globl	uphpsnd1
	.globl	uphpsnd2
	.globl	inhypsnd
	.globl	outhpsd0
	.globl	outhpsd1

	.globl	avoice
	.globl	bvoice
	.globl	cvoice


*
*	GLOBAL CONSTANTS
*
avoice	.equ	8		* Voice A ID
bvoice	.equ	4		* Voice B ID
cvoice	.equ	0		* Voice C ID

vostop	.equ	0		* Stop Voice
setwait	.equ	$2000		* Set Wait
ramp	.equ	$3000		* Ramp Register
vowait	.equ	$8000		* Wait Here

setfreq	.equ	$1000		* Set Frequency Register
setvol	.equ	$1008		* Set Volume Register
setmode	.equ	$1007		* Set Mode Control Register
setnoise .equ	$1006		* Set Noise Frequency Register
setenvfr .equ	$100b		* Set Envelope Frequency Register
setenvmo .equ	$100d		* Set Envelope Mode Register

freq	.equ	0		* Frequency Register
vol	.equ	8		* Volume Register
mode	.equ	7		* Mode Control Register
noise	.equ	6		* Noise Frequency Register
envfreq	.equ	11		* Envelope Frequency Register
envmode	.equ	13		* Envelope Mode Register


*
*	HARDWARE CONSTANTS
*
giselect .equ	$ffff8800
giread	.equ	$ffff8800
giwrite	.equ	$ffff8802


*
*	INITSOUND   Initialize Sound Driver Variables, Stop Sound
*
*	Given:
*		Control
*
*	Returns:
*		Sound Interrupts Enabled
*		Sound Channels and Sound RAM Cleared
*
*	Register Usage:
*		a0-a3,d0-d3
*
*	Externals:
*		silence
*
initsound:
	clr	sndlock			* Clear Interrupt Lock-Out
	movea.l	#aframp,a0
	move	#7,d0
inramplp:				* FOR (All Ramps) DO
	clr	(a0)+			* .. Ramping Off
	addq.l	#8,a0
	dbra	d0,inramplp
	jsr	silence			* Init. All Voices Off

	move.l	#-1,-(sp)
	move	#$100,-(sp)
	move	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	move.l	d0,hertz50		* Save Old 50 Hertz Server Vector
	move.l	#sounder,-(sp)
	move	#$100,-(sp)
	move	#5,-(sp)
	trap	#13
	addq.l	#8,sp			* Install New Sound Handler
	rts


*
*	UNSOUND   Return 50 Hz Timer Control to TOS
*
*	Given:
*		Control
*
*	Returns:
*		Vector Restored to pre-InitSound State
*
*	Register Usage:
*		a0-a3 and d0-d3
*
*	Externals:
*		none
*
unsound:
	move	#1,sndlock		* Lock-Out Our Sound Handler
	move	sr,-(sp)
	or	#$700,sr		* Halt any Interruptions
	move.b	#8,giselect
	move.b	#0,giwrite
	move.b	#9,giselect
	move.b	#0,giwrite
	move.b	#10,giselect
	move.b	#0,giwrite		* Directly Kill Volume Registers
	move	(sp)+,sr
	move.l	hertz50,-(sp)
	move	#$100,-(sp)
	move	#5,-(sp)
	trap	#13
	addq.l	#8,sp			* Restore Old Sound Handler
	rts

*
*	STARTSAD   Initialize Channel A and Clear Channel B
*
*	Given:
*		d1 = Command String ptr (Long)
*
*	Returns:
*		w/ Voice Command ptr and Stack Initialized
*
*	Register Usage:
*		a0 destroyed
*
*	Externals:
*		startsound,stopsound
*
startsad:
	move	#avoice,d0
	jsr	startsound	* Start Channel A
	move	#bvoice,d0
	jsr	stopsound	* Stop Channel B
	rts


*
*	SILENCE   Stop Sound in ALL Voices
*
*	Given:
*		Control
*
*	Returns:
*		w/ Voices Off
*
*	Register Usage:
*		a0 and d0-d1
*
*	Externals:
*		stopsound
*
silence:
	move	#avoice,d0
	jsr	stopsound
	move	#bvoice,d0
	jsr	stopsound
	move	#cvoice,d0	* NOTE: Fall Thru to Final StopSound

*
*	STOPSOUND   Stop a Voice Channel
*
*	Given:
*		d0 = Voice No. (8,4 or 0)
*
*	Returns:
*		w/ Voice Command ptr and Stack Initialized
*
*	Register Usage:
*		a0 and d1
*
*	Externals:
*		startsound
*
stopsound:
	move.l	#nonsound,d1	* NOTE: Fall Thru to Start Sound


*
*	STARTSOUND   Initialize a Voice Command ptr
*
*	Given:
*		d0 = Voice No. (8,4 or 0)
*		d1 = Command String ptr (Long)
*
*	Returns:
*		w/ Voice Command ptr and Stack Initialized
*
*	Register Usage:
*		a0 destroyed
*
*	Externals:
*		none
*
startsound:
	addq	#1,sndlock	* Lock-Out Interrupt Server
	movea.l	#voiceptr,a0
	move.l	d1,(a0,d0)
	movea.l	#voicestk,a0
	move.l	stastatbl(pc,d0),(a0,d0)
	move.l	stafrrtbl(pc,d0),a0
	clr	(a0)
	move.l	stavortbl(pc,d0),a0
	clr	(a0)
	cmp	#avoice,d0
	bne	stardone	* Clear Ramps
	clr	nsramp
	clr	evramp		* Voice-A Controls Envelope and Noise
stardone:
	subq	#1,sndlock	* UnLock
	rts
stastatbl:			* Start-Sound Stack Init. Table
	.dc.l	cvstack-2,bvstack-2,avstack-2
stafrrtbl:
	.dc.l	cframp,bframp,aframp
stavortbl:
	.dc.l	cvramp,bvramp,avramp


*
*	SOUNDER   Interrupt-Driven Driver
*
*	Given:
*		Control
*
*	Returns:
*		Sound Channels Maintained and Updated
*
*	Register Usage:
*		none
*
*	Externals:
*		none
*
sounder:
	movem.l	d0-d3/a0-a3,-(sp)
	move	sr,-(sp)
	or	#$700,sr	* Disable Interrupts
	tst	sndlock
	bne	nosound		* IF (Sound Data Area Available) THEN
	movea.l	#voiceptr,a0
	movea.l	#voicestk,a2
	move	#2,d3
voicelp:			* FOR (All Three Voices) DO
	move.l	(a0),a1		* a1 = Command Ptr
	move.l	a1,d0
	beq	voicedone	* IF (Voice Currently Active) THEN
wirthlp:			* ... Loop to Interpret Command Stream
	move	(a1)+,d0
	bne	vcomm1		* IF (Command = StopVoice)
	clr.l	a1		* THEN Zap the Command Ptr
	move	#8,d0
	add	d3,d0		* d0 = Volume Register to Silence
	move.b	d0,giselect
	move.b	#0,giwrite
	bra	voicedone
vcomm1:	bpl	vcomm2		* ELSE IF (Command = Wait)
	move.l	(a2),a3		* THEN a3 = Wait-Stack-Ptr
	move	(a3),d1		* d1 = Wait Duration (Repeat Count)
	bne	vbrnch		* IF (Wait-Time Up)
	subq.l	#2,(a2)		* THEN Pop the Wait-Stack
	bra	wirthlp		* .. and Continue to Interpret Commands
vbrnch:	bmi	vinfin		* ELSE Still Waiting
	subq	#1,(a3)		* Count-Down the Wait Timer
vinfin:	subq.l	#2,a1		* Rerun the Wait Command
	asl	#1,d0
	beq	voicedone	* Special Case: Wait-Here
	adda	d0,a1		* Branch Command Ptr
	bra	wirthlp		* .. and Continue to Interpret Commands
vcomm2:	cmp	#$2000,d0
	blt	vcomm3		* CASE (Command Word)
	bgt	vcomm4
	addq.l	#2,(a2)		* Command = SetWait
	move.l	(a2),a3
	move	(a1)+,(a3)	* Push Wait Duration to Wait-Stack
	bra	wirthlp
vregister:			* Register to Handling Routine Mapping
	.dc.l	vcreg0,vcillr,vcillr,vcillr,vcillr,vcillr,vcset1,vcreg7
	.dc.l	vcreg8,vcillr,vcillr,vcset2,vcillr,vcset1,vcillr,vcillr
vcomm3:	and	#$0f,d0		* Command = SetRegister
	move	d0,d1
	add	d1,d1
	add	d1,d1
	move.l	vregister(pc,d1),a3
	jmp	(a3)		* CASE (Register No.)
vcillr:
	illegal			* WHAT? Illegal Register!!
vcreg0:
	move	d3,d0		* Register0
	add	d0,d0		* d0 = Freq. Register
	bra	vcset2
vcreg7:
	move	#$fff6,d2	* Register7
	move	(a1)+,d0
	move	d0,d1
	and	#$0f,d1
	asl	d3,d1
	rol	d3,d2
	move.b	#7,giselect
	and.b	giread,d2
	or	d2,d1
	move.b	d1,giwrite	* Write Noise/Tone Bits
	move	#8,d1
	add	d3,d1		* d1 = Volume Register
	and	#$10,d0
	move.b	d1,giselect
	move.b	giread,d1
	and	#$0f,d1
	or	d1,d0
	move.b	d0,giwrite	* Write Envelope Mode Bit
	bra	wirthlp
vcreg8:
	add	d3,d0		* Register8
	move	(a1)+,d1
	and	#$0f,d1		* d1 = Volume Bits
	move.b	d0,giselect	* Select Proper Volume Register
	move.b	giread,d0
	and	#$10,d0		* Retain Mode Bit
	or	d1,d0
	move.b	d0,giwrite	* And Set Volume
	bra	wirthlp
vcset1:				* Read and Set a Byte
	move	(a1)+,d1
	move.b	d0,giselect
	move.b	d1,giwrite	* Set Byte
	bra	wirthlp
vcset2:				* Read and Set a Word
	move.b	(a1)+,d2
	move.b	(a1)+,d1
	move.b	d0,giselect
	move.b	d1,giwrite	* Set Low Word
	addq	#1,d0
	move.b	d0,giselect
	move.b	d2,giwrite	* Set High Word
	bra	wirthlp
ramptbl:			* Ramping RAM Base Ptrs
	.dc.l	aframp,bframp,cframp,dmramp,dmramp,dmramp
	.dc.l	nsramp,dmramp,avramp,bvramp,cvramp,evramp
vcomm4:	and	#$0f,d0		* Command = RampRegister
	beq	vcrmp1
	cmp	#8,d0
	bne	vcrmp2
vcrmp1:	add	d3,d0		* d0 = Ramp/Register No.
vcrmp2:	add	d0,d0
	add	d0,d0
	move.l	ramptbl(pc,d0),a3
	move	(a1)+,(a3)+	* Duration
	clr	(a3)+		* Initial Delay
	move	(a1)+,(a3)+	* Delay Reset
	move	(a1)+,(a3)+	* Increment
	move	(a1)+,(a3)+	* Initial Value
	bra	wirthlp
voicedone:
	move.l	a1,(a0)+	* Save New Command Ptr
	addq.l	#4,a2
	dbra	d3,voicelp

	movea.l	#aframp,a0	* a0 = Ramp Data ptr
	move	#7,d3
regloop:			* FOR (All Ramping Registers) DO
	tst	(a0)
	beq	rejoin		* IF (Actively Ramping) THEN
	subq	#1,2(a0)	* Count-Down Delay
	bpl	rejoin		* IF (Delay Expired) THEN
	move	4(a0),2(a0)	* Reload Delay Counter
	tst	(a0)
	bmi	reginf		* IF (Finite Duration) THEN Count Duration
	subq	#1,(a0)
reginf:	move.b	regindex(pc,d3),d0
	move	d3,d2
	add	d2,d2
	add	d2,d2
	move.l	regcomm(pc,d2),a1
	jmp	(a1)		* Case (Register No.)
regindex:			* Loop-Index to Register No. Table
	.dc.b	11,6,10,9,8,4,2,0
regcomm:			* Loop-Index to Register Handler Table
	.dc.l	rgset2,rgset1,rgsvol,rgsvol,rgsvol,rgset2,rgset2,rgset2
rgsvol:
	move	8(a0),d1
	and	#$0f,d1		* d1 = Volume Bits
	move.b	d0,giselect	* Select Proper Volume Register
	move.b	giread,d0
	and	#$10,d0		* Retain Mode Bit
	or	d1,d0
	move.b	d0,giwrite	* And Set Volume
	bra	regset
rgset1:				* Read and Set a Byte
	move	8(a0),d1
	move.b	d0,giselect
	move.b	d1,giwrite	* Set Byte
	bra	regset
rgset2:				* Read and Set a Word
	move.b	8(a0),d2
	move.b	9(a0),d1
	move.b	d0,giselect
	move.b	d1,giwrite	* Set Low Word
	addq	#1,d0
	move.b	d0,giselect
	move.b	d2,giwrite	* Set High Word
*				  NOTE: Fall Thru ..
regset:	move	6(a0),d0
	add	d0,8(a0)	* Current = Current + Increment
rejoin:	adda	#10,a0
	dbra	d3,regloop

nosound:
	move	(sp)+,sr	* Restore Interrupts
	movem.l	(sp)+,d0-d3/a0-a3

*	move.l	hertz50,-(sp)	* DO NOT Daisy-Chain Thru ..
	rts


*
*	Data Storage
*
nonsound:	.dc.w	0	* The Sound of One Hand Clapping ..

*
*	Sounds for Star Raiders
*
redalsnd:
	.dc.w	setmode,8,setvol,$0c,setwait,2
	.dc.w	setfreq,$10c,setwait,25,vowait
	.dc.w	setfreq,$152,setwait,25,vowait,$0fff6,vostop
damagsnd:
	.dc.w	setmode,8,setvol,$0c,setwait,3
	.dc.w	ramp+freq,25,0,-4,$180,setwait,25,vowait,$0fff8,vostop
nukesnd:
	.dc.w	setmode,8,setvol,$0c,setwait,3
	.dc.w	ramp+freq,25,0,-4,$200,setwait,25,vowait,$0fff8,vostop
shotsnd:
	.dc.w	setmode,$18,setfreq,$0c00,setenvmo,10,setnoise,0
	.dc.w	ramp+envfreq,12,0,2,2
	.dc.w	setwait,12,vowait,vostop
togglsnd:
	.dc.w	setenvfr,$100,setenvmo,14,setnoise,0
	.dc.w	setmode,$18,setfreq,$100,setwait,3,vowait
	.dc.w	setfreq,$80,setwait,3,vowait
	.dc.w	setfreq,$180,setwait,3,vowait,vostop
refitsnd:
	.dc.w	setenvfr,$0c0,setenvmo,14,setnoise,0
	.dc.w	setmode,$18,setfreq,$180,setwait,3,vowait
	.dc.w	setfreq,$100,setwait,3,vowait
	.dc.w	setfreq,$80,setwait,3,vowait
	.dc.w	setfreq,$100,setwait,3,vowait,vostop
cmponsnd:
	.dc.w	setmode,8,setvol,$0a
	.dc.w	ramp+freq,2,1,$0ffc0,$180,setwait,2,vowait
	.dc.w	ramp+freq,2,1,$0ffc0,$140,setwait,2,vowait
	.dc.w	setfreq,$0c0,setwait,2,vowait,vostop
cmpofsnd:
	.dc.w	setmode,8,setvol,$0a
	.dc.w	ramp+freq,2,1,$40,$100,setwait,2,vowait
	.dc.w	ramp+freq,2,1,$40,$120,setwait,2,vowait
	.dc.w	setfreq,$0ea,setwait,2,vowait,vostop
shonsnd:
	.dc.w	setmode,$18,setenvfr,$1800,setenvmo,14,setnoise,0
	.dc.w	setfreq,$3f,setwait,$40,vowait,vostop
shoffsnd:
	.dc.w	setmode,$18,setenvfr,$200,setnoise,0
	.dc.w	ramp+freq,$10,0,-4,$100,setenvmo,0,setwait,$10,vowait,vostop
pausnd:
	.dc.w	setmode,$18,setenvfr,$80,setwait,-1,setnoise,0
	.dc.w	setenvmo,0,ramp+freq,4,0,-2,$40,setwait,4,vowait
	.dc.w	setwait,$31,vowait
	.dc.w	setenvmo,1,ramp+freq,4,0,-2,$60,setwait,4,vowait
	.dc.w	setwait,$31,vowait,$0ffe6,vostop
scansnd:
	.dc.w	setmode,$18,setenvfr,$0c0,setenvmo,14,setnoise,0
	.dc.w	ramp+freq,3,3,$80,$80,setwait,12,vowait,vostop
surrsnd:
	.dc.w	setmode,$18,setenvfr,$2848,setnoise,0
	.dc.w	setenvmo,0,setfreq,$13f,setwait,$20,vowait
	.dc.w	setenvmo,0,setfreq,$11c,setwait,$20,vowait
	.dc.w	setenvmo,0,setfreq,$166,setwait,$30,vowait,vostop
deadsnd:
	.dc.w	setmode,$18,setenvfr,$2848,setnoise,0
	.dc.w	setenvmo,0,setfreq,$2cc,setwait,$20,vowait
	.dc.w	setenvmo,0,setfreq,$1de,setwait,$30,vowait,vostop
explsnd0:
	.dc.w	setmode,$10,setnoise,$1f,setenvfr,$1800,setenvmo,0
	.dc.w	setfreq,$780,setwait,30,vowait,vostop
explsnd1:
	.dc.w	setmode,$18,ramp+freq,30,0,$10,$480,setwait,30,vowait,vostop
explsnd2:
	.dc.w	setmode,$10,setnoise,$1f,setenvfr,$3000,setenvmo,0
	.dc.w	ramp+freq,$30,0,$10,$880,setwait,$30,vowait,vostop
explsnd3:
	.dc.w	setmode,$18,setfreq,$0d4d,setwait,$30,vowait,vostop
explsnd4:
	.dc.w	setmode,$11,setnoise,31,setenvfr,$1800,setenvmo,0
	.dc.w	setwait,30,vowait,vostop
dnengsnd:
	.dc.w	setmode,$18,setenvfr,$1000,setnoise,0
	.dc.w	ramp+freq,$40,0,$10,$0a00,setenvmo,14,setwait,$40,vowait,vostop
upengsnd:
	.dc.w	setmode,$18,setenvfr,$1000,setnoise,0
	.dc.w	ramp+freq,$40,0,-16,$0e00,setenvmo,14,setwait,$40,vowait,vostop
uphpsnd0:
	.dc.w	setmode,$18,setenvfr,$2e,setnoise,0,setenvmo,10,setfreq,$0c00
	.dc.w	setwait,$400,vowait,vostop
uphpsnd1:
	.dc.w	setmode,$18,setfreq,$0c00,setwait,$400,vowait,vostop
uphpsnd2:
	.dc.w	setmode,$18,setvol,10
	.dc.w	ramp+freq,$100,0,-1,$100
	.dc.w	setwait,$100,vowait,vostop
inhypsnd:
	.dc.w	setmode,$18,setfreq,$77,setenvfr,$61b,setwait,-1,setnoise,0
	.dc.w	setenvmo,0,setwait,4,vowait,$0fffb,vostop
outhpsd0:
	.dc.w	setmode,$18,setenvfr,$1800,setenvmo,14,setnoise,0
	.dc.w	ramp+freq,$40,0,8,$1c0
	.dc.w	setwait,$40,vowait,vostop
outhpsd1:
	.dc.w	setmode,$18,ramp+freq,$40,0,8,$200
	.dc.w	setwait,$40,vowait,vostop


*
*	Random Storage
*
	.data

sndlock:			* Sound Data Base Lock-Out
	.ds.w	1

hertz50:			* Old 50 Hertz Vector
	.ds.l	1

voiceptr:			* Command-List Ptrs
	.ds.l	1		* Cvoice
	.ds.l	1		* Bvoice
	.ds.l	1		* Avoice

voicestk:			* Wait-Stack Ptrs
	.ds.l	1		* Cvoice
	.ds.l	1		* Bvoice
	.ds.l	1		* Avoice

avstack:			* Wait Stack RAM for Voice A
	.ds.w	8
bvstack:			* Wait Stack RAM for Voice B
	.ds.w	8
cvstack:			* Wait Stack RAM for Voice C
	.ds.w	8

*
*	Ramping Registers Arrays
*		Duration,Delay-Count,Delay,Increment,Current
*
aframp:				* Avoice Frequency
	.ds.w	5
bframp:				* Bvoice Frequency
	.ds.w	5
cframp:				* Cvoice Frequency
	.ds.w	5
avramp:				* Avoice Volume
	.ds.w	5
bvramp:				* Bvoice Volume
	.ds.w	5
cvramp:				* Cvoice Volume
	.ds.w	5
nsramp:				* Noise Frequency
	.ds.w	5
evramp:				* Envelope Frequency
	.ds.w	5
dmramp:				* Dummy Pointer
	.ds.w	5

	.end
