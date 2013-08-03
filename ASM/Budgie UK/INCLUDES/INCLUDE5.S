* include 5 * not always included automatically
* routines may be pulled using  F3-Alt I
* sound routines: R_EPLAY (ST replay)
*------------------------------------

* sound REPLAY system 	[ RACINE 2-bit system ]
* see example in shell.s
* load the tune, pass the parameters, then jsr r_eplay
* there is also a macro  <<<
* see numerous examples in shell.s speculator.s moneyspinner.s etc...
*  Registers used: 
*  IN A5 start address   D5 length of tune   D4 frequency 0-7
*  not used:  
*
	even
mfp	EQU	$FFFA00	the multi-function peripheral 68901
iera	EQU	mfp+7	Interrupt Enable Register A (reg#4)
; initially found as holding 30
; bit 5 is timer A  so poke 32 in this register
; any disabled bit is ignored.
ierb	EQU	mfp+9 	not needed. Poke a 0 in this one (reg#5)
; initially found as 100
ipra	EQU	mfp+11	Interrupt pending register (reg#6)
; not used by this routine
isra	EQU	mfp+15	Interrupt service regs (not used)
imra	EQU	mfp+19	Interrupt Mask regs (reg#8)
; initially found as 30
; in our case set to 32 again (bit 6 set)
imrb	EQU	mfp+21	(reg#9) set to 0
; again found as 100
vector	EQU	mfp+23	bit 3 is cleared when in
; automatic end of Interrupt mode.
; initially found as 72
tacr	EQU	mfp+25	Timer A control reg#13  first
; disabled with 0 then reset with appropriate number
; initially found as 0
tadr	EQU	mfp+31	Timer A data reg#14
; initially found with 255
isrvec	EQU	$134
; SR initially found as 8196  ($2004)  00100000 00000100

*  THE PROGRAMME  *
r_eplay
	add.l	a5,d5
	BSR	savemfp		save natural MFP conditions	
; SR was 8196 ($2004) 00100000 00000100
; iera 30  ierb 100  imra 30  imrb 100  tacr 0  tadr 255  vector 72	
	MOVE.W	#$2700,SR		interrupts off	
	LEA	inull,A0
	move.l	a0,$134		interr routine vector
; $134 is user application  /timer A  initially disabled
; $120 is Timer B (H/B ct)  $ etc  ($100 to $140 MFP int vectors)
	BSR	setfreq		held in D4
; at this point tacr has changed from 0 to 5
; and tadr is still 255
	BSR	enabmfp		set mfp running	
; imra 30 now 32  iera 30 now 32   ierb & imrb 100 now 0
; vector 72 now 3	
	BSR	setsnd		set up sound registers
; basically all set to 0, except channel 7 (mixing) set to $FF	
	lea	$ff8800,a4	sound chip
	lea	snd_out,a3	lookup tables
	LEA	ireplay,a0	set up output code address
	move.l	a0,$134
	ST	inuse		
	MOVE.W	#$2500,SR		enable level 6 interrupts	
; that's % 10010100 00000000
* now wait for thr interrupt to do its business
	
	move.l	#shades,a0
idle	btst	#0,colorwave
	beq	idle1	
	move.w	(a0),$ff8240
	add.w 	#1,(a0)
	cmp.w 	#$700,(a0)
	bmi	idle1
	move.w 	#0,(a0)
idle1	nop
	nop
	nop
idle2	lea	$fffc00,a1		acia k/board address
	move.b	0(a1),d1		get acia status
	btst	#7,d1			interrupt request?
	beq	idle3
	tst.b	$a32			keyboard state
	bne	idle3
	move.b	2(a1),d0		get data from acia
	cmp.b	#$f6,d0			keypress? above, it's not
	bcc	idle3			no. some other package
*	cmp.b	#$39,d0			space?
*	bne	idle3
	move.b	#1,keyhit
	bra	ex_it
idle3	TST.B	inuse			sample finished?
	BNE.S	idle			br if not
	
ex_it	MOVE.W	#$2700,SR		disable interrupts	
	BSR	oldmfp			restore original mfp data	
	BSR	enmouse			enable mouse
	bsr	flushout		stop flood from k/board		
intson	MOVE.W	#$2000,SR		restore ints for o.s.
	RTS
shades		DC.W 	0
colorwave	dc.w 	0
keyhit		DC.b	0,0,0,0
*------------
flushout	btst.b	#0,$fffc00 	kbdcont
		beq.s 	flush9		is it working??
		move.b 	$fffc02,d0	kbddata
		bra.s 	flushout
flush9	rts
*------------
*   THE INTERRUPT SERVICE ROUTINES     *

inull	RTE
* replay from memory
ireplay	
	movem.l	a2-a3,-(sp)	full a0-a6 cut out sound!
	MOVE.B	(A5)+,D7		read from ram		
	CMP.L	D5,A5		exceeded end   stop			
	BGE.S	haltrep		branch if so	
* output routine		a note is played each time we come here.
	AND.W	#$FF,D7		mask rubbish		
	ADD.B	#$80,D7		sign value		
	LSL.W	#3,D7		double L word offset	
	MOVE.L	0(A3,D7.W),D3	get data #1
	MOVE.W	4(A3,D7.W),D2	get data #2
	MOVEP.L	D3,0(A4)		play #1
	MOVEP.W	D2,0(A4)		play #2
	sub.w	#6,d6		the next four lines...
	tst.w	d6		smooth out the scroll lines..	
	bne	ire2		and have varied effects...
*	move.w	#$000,$ff8240	according to d6 setting...
	move.w	#65000,d6		and the sub.w increment
ire2	movem.l	(sp)+,a2-a3
	RTE
	
haltrep	MOVE.W	#$2700,SR
	LEA	inull,a0		remove replay int
	move.l	a0,$134			
	SF	inuse
	MOVE.W	#$2500,SR
	movem.l	(sp)+,a2-a3
	RTE
* here is a sample routine running on MFP interrupt 8 (h/b counter)
int_2	
	move.l	a0,-(sp)	
	move.w	shades,$ff8240
	add.w	#1,shades
	cmp.w	#$770,shades
	bmi	int_29
	move.w	#0,shades
int_29		
	lea.l	$fffa01,a0	K.Garroch uses it..
	bclr	#0,14(a0)		to exit a h/b mfp interrupt
	move.l	(sp)+,a0
	rte

* THE SYSTEM SUB-ROUTINES *
SAVEMFP	MOVE.B	iera,mfpmem	preserve mfp registers ...
	MOVE.B	ierb,mfpmem+1	... in temporary storage
	MOVE.B	imra,mfpmem+2
	MOVE.B	imrb,mfpmem+3
	MOVE.B	tadr,mfpmem+4
	MOVE.B	tacr,mfpmem+5
	MOVE.B	vector,mfpmem+6
	RTS

OLDMFP	MOVE.B	mfpmem+6,vector	restore them
	MOVE.B	mfpmem+5,tacr
	MOVE.B	mfpmem+4,tadr
	MOVE.B	mfpmem+3,imrb
	MOVE.B	mfpmem+2,imra
	MOVE.B	mfpmem+1,ierb
	MOVE.B	mfpmem,iera
	RTS

* IKBD enable/disable
dismous	
	movem.l	d0-d3/a0-a3,-(sp)
	PEA	skbddis		keyboard off string address ($12,1A)
	MOVE.W	#1,-(A7)	length of string -1
	MOVE.W	#25,-(A7) 	(ikbdws) send order
	TRAP	#14
	ADDQ.L	#8,A7
	movem.l	(sp)+,d0-d3/a0-a3
	RTS
enmouse	
	movem.l	d0-d3/a0-a3,-(sp)
	PEA	skbden		keys on again / string address ($8)	
	MOVE.W	#0,-(A7)	length of string -1		
	MOVE.W	#25,-(A7) 	(ikbdws) send order
	TRAP	#14
	ADDQ.L	#8,A7
	movem.l	(sp)+,d0-d3/a0-a3
	RTS

skbddis	DC.B	$12,$1A		maybe it should be $13 (stop reporting)
skbden	DC.B	$8		maybe it should be $11 (resume)...(see yello.s)

; 524
	
* set MFP timer to generate interrupts (D4 freq 0 to 7)
SETFREQ	MOVE.B	#0,tacr		disable timer	 MFP + $19				
	AND.W	#7,D4		ensure 0-7					
	LEA	freqtab,a0 	get freq xref address			
	LSL.W	#1,D4		convert to word table offset				
	MOVE.W	0(a0,D4.W),D4	& get mfp data	
	MOVE.B	D4,tacr		LSB = control reg byte 	MPF + $19				
	LSR.W	#8,D4		shift down next byte				
 	MOVE.B	D4,tadr		next = data reg byte	MFP + $1F				
	RTS

enabmfp	MOVE.B	#32,imra		MFP + $13
	MOVE.B	#0,imrb			MFP + $15
	MOVE.B	#32,iera		MFP + $7
	MOVE.B	#0,ierb			MFP + $9
	BCLR.B	#3,vector		MFP + $17
	RTS
* set up sound registers 0-10

SETSND	MOVE.B	#0,$ff8800		channel A
	MOVE.B	#0,$ff8802	
	MOVE.B	#1,$ff8800		command register
	MOVE.B	#0,$ff8802		data register
	MOVE.B	#0,$ff8802

	MOVE.B	#2,$ff8800		channel B	
	MOVE.B	#0,$ff8802
	MOVE.B	#3,$ff8800
	MOVE.B	#0,$ff8802

	MOVE.B	#4,$ff8800		channel C	
	MOVE.B	#0,$ff8802
	MOVE.B	#5,$ff8800
	MOVE.B	#0,$ff8802

	MOVE.B	#7,$ff8800	set up channel mixing & port 'A' I/O	
	MOVE.B	#$FF,$ff8802

	MOVE.B	#8,$ff8800		set all volumes to zero		
	MOVE.B	#0,$ff8802
	MOVE.B	#9,$ff8800
	MOVE.B	#0,$ff8802
	MOVE.B	#10,$ff8800
	MOVE.B	#0,$ff8802
	RTS
*----------
*    INTERNAL SOUND LOOKUP TABLE.

	EVEN
SND_OUT	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0

	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0

	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0

	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0

	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0

	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0

	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0

	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0

	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0

	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0

	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0

	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0

	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0

	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0

	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0

	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0

* MFP/FREQUENCY TABLE *

	EVEN
FREQTAB	DC.W	$506		
	DC.W	$505		
	DC.W	$405
	DC.W	$2901		
	DC.W	$1F01	
	DC.W	$802		
	DC.W	$405		
	DC.W	$405			
		
* DEFINE PROGRAM STORAGE 
	EVEN

mfpmem	DS.B	8
inuse	DS.B	1
	even
