***************************************
*                                     *
* Fingerbobs New Year Demo Loader     *
*                                     *
* By Oberje'                          *
*                                     *
* Plays Sample and displays pictures  *
* whilst loading and relocating the   *
* demo!                               *
*                                     *
***************************************

ln equ	 99087

go	move.l	a7,a5		;Need this!
	move.l	#mystack,a7	
	move.l	4(a5),a5	
	move.l	$c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move	d0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	add.l	#$c,sp

	dc.w	$a00a		;Mouse off
		
	clr	-(a7)		;Low Res
	pea	$78000
	pea	$78000
	move.w	#5,-(a7)
	trap	#14
	add.l	#12,a7
	
	clr.l	-(a7)		;Super mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldstack
	
	move.l	#0,$ff8240	;Blank Palette
	move.l	#0,$ff8244
	move.l	#0,$ff8248
	move.l	#0,$ff824c
	move.l	#0,$ff8250
	move.l	#0,$ff8254
	move.l	#0,$ff8258
	move.l	#0,$ff825c
	
	lea	bs,a0		;Copy sample to top of memory
	lea	$5f960,a1
	move.l	#(100000/4)-1,d0
smploop
	move.l	(a0)+,(a1)+
	dbf	d0,smploop
	
	lea	pic2,a0		;Copy first picture to screen
	lea	$78000,a1
	move.l	#(32000/4)-1,d0
picloop
	move.l	(a0)+,(a1)+
	dbf	d0,picloop
	
	movem.l	cols2,d0-d7	;Picture palette
	movem.l	d0-d7,$ff8240

	move.l	oldstack,-(a7)	;Back to user mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	lea	vars,a6		;Start playing sample
	move.l	#$5f960,start(a6)
	move.l	#ln,len(a6)
	move.w	#$ffff,loop(a6)
	move.w	#2,speed(a6)
	
	jsr	play		;Start sample
	
	move.w	#8,-(a7)	;Wait Key
	trap	#1
	addq.l	#2,a7
	
	clr.l	-(a7)		;Super mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldstack
	
	move.l	#0,$ff8240	;Blank Palette
	move.l	#0,$ff8244
	move.l	#0,$ff8248
	move.l	#0,$ff824c
	move.l	#0,$ff8250
	move.l	#0,$ff8254
	move.l	#0,$ff8258
	move.l	#0,$ff825c
	
	lea	picture,a0		;Copy second picture to screen
	lea	$78000,a1
	move.l	#(32000/4)-1,d0
picloop2
	move.l	(a0)+,(a1)+
	dbf	d0,picloop2
	
	movem.l	cols,d0-d7	;Picture palette
	movem.l	d0-d7,$ff8240

	move.l	oldstack,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	pea	env		;Load demo
	pea	env		;But do not execute
	pea	name
	move.w	#3,-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	add.l	#16,a7
	move.l	d0,progstart
	
	jsr	halt		;Stop sample

run	clr.l	d0		;Best start with
	clr.l	d1		;a clean slate!
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	movea.l	#0,a0
	movea.l	#0,a1
	movea.l	#0,a2
	movea.l	#0,a3
	movea.l	#0,a4
	movea.l	#0,a5
	movea.l	#0,a6
	move.l	progstart,a0	;Execute demo! ( No Return! )
	move.l	a0,4(a7)	;Must give Base Page
	move.l	#run,(a7)  	;And a Return Address!
	add.l	#256,a0
	jmp	(a0)
	
	even
	
oldstack ds.l	1

vars	dc.w	0		;Speed of Sample
speed	rs.w	1		;4=20KHz,3=15KHz,2=10KHz,1=7.5KHz,0=5KHz
	dc.w	0		;Looping ?   0=Looping off
loop	rs.w	1
	dc.l	0		;Start of Sample
start	rs.l	1
	dc.l	0		;Length of sample
len	rs.l	1
	dc.l	0		;Low position in sample
begin	rs.l	1
	dc.l	0		;High position in sample
end	rs.l	1
	dc.l	0		;SP store		
save_sp	rs.l	1
	dc.w	0		;SR store
save_sr	rs.w	1
	dc.b	0		;Sample  $ff=on  $00=off
s_on	rs.b	1		;>>Routines only RESET this, set yourself
	dc.b	0		;HEAR    $ff=off $00=on
s_hear	rs.b	1		;>>When on cause WAIT to exit instantly
	dc.b	0		;  Useful for when sample has finished!
	dc.b	0


	**********************************************
	* Dummy Routine for non-implemented routines *
	**********************************************
	
dud	rts

	**************************
	* Wait for Sample to End *
	**************************
	
wait	movem.l	d0/a0,-(a7)	
	lea	vars(pc),a0
	tst.b	s_hear(a0)	;Test for Hear option
	beq.s	endwait		;0=Hear ON
	st	s_on(a0)	;Siganl Sample ON
check	tst.b	s_on(a0)	;Is it still playing ?
	bne.s	check		;Yes, check again
endwait	movem.l	(a7)+,d0/a0
	rts

	
	***************
	* Halt Sample *
	***************

halt	movem.l	d0-d7/a0-a6,-(a7)	;Save Regs
	clr.l	-(a7)		;
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;Enter Super mode
	lea	vars(pc),a0	;Base of variables
	move.l	d0,save_sp(a0)	;Save SP
	move	SR,d0		;Save SR
	ori.w	#$700,SR	;Raise IPL to 7 (Stop all interrupts )
	bclr	#5,$FFFFFa07.w	;Turn Interrupts off (IERA)
	bclr	#5,$FFFFFa0B.w	;(IPRA)
	bclr	#5,$FFFFFa0F.w	;(ISRA)	Bit 5 = Timer A
	bclr	#5,$FFFFFa13.w	;(IMRA)
	move.w	d0,SR		;Restore SR
	sf	s_hear(a0)	;Hear ON
	sf	s_on(a0)	;Siganl Sample OFF
	move.l	save_sp(a0),-(a7)	
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;Back to user mode and exit
	movem.l	(a7)+,d0-d7/a0-a6
	rts			;
	
	
	
	***************
	* Play Sample *
	***************

play	movem.l	d0-d7/a0-a6,-(a7)	;Save Regs
	lea	vars(pc),a0	;Base of variables
	move.l	start(a0),d7	;Get Sample Start
	move.l	d7,begin(a0)	;Put in Begin address
	add.l	len(a0),d7	;Add on length
	move.l	d7,end(a0)	;Put in End address
	clr.l	-(a7)		;
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;Enter super mode
	lea	vars(pc),a0	;
	move.l	d0,save_sp(a0)	;Save SP
	move	SR,save_sr(a0)	;Save SR
	clr.b	$484		;*** Keyclick OFF! ***
	ori.w	#$700,SR	;IPL=7 : Stop all interrupts
	bsr	setsnd		;Set up sound channels
	lea	freq(pc),a1	;Base of Speed table
	move.w	speed(a0),d0	;Get Speed
	andi.w	#7,d0		;Mask off Rubbish
	lsl.w	#2,d0		;Multiply since is Longword Table
	move.l	(a1,d0.w),d0	;Get Timer Presets from table
	pea	I_play(pc)	;Timer A (Sample) Interrupt Routine
	move.w	d0,-(a7)	;Timer A - Data
	swap	d0		;
	move.w	d0,-(a7)	;Timer A - Control
	move.w	#0,-(a7)	;Select Timer A
	move.w	#$1F,-(a7)	;
	trap	#14		;XBTIMER
	adda.l	#$C,a7		;
	lea	vars(pc),a0	;Base of variables
	st	s_hear(a0)	;Hear OFF
	sf	s_on(a0)	;Sample OFF - Only used by WAIT
	move.w	save_sr(a0),SR	;
	move.l	save_sp(a0),-(a7)
	move.w	#$20,-(a7)	;
	trap	#1		;Return to User mode and Exit!
	addq.l	#6,a7		;
	movem.l	(a7)+,d0-d7/a0-a6
	rts			;

	

	*************************
	* Set up Sound Channels *
	*************************

setsnd	pea	snddata(pc)	;Sound commands
	move.w	#$20,-(a7)	;Call DOSOUND
	trap	#14		;
	addq.l	#6,a7		;
	lea	vars(pc),a0	;Restore a0
	rts			;


	********************
	* INTERRUPT : Play *
	********************
	
I_play	movem.l	d6-d7/a5-a6,-(a7)	;Save regs
	lea	vars(pc),a5	;Base of variables
	movea.l	begin(a5),a6	;Get Begin
	clr.w	d7		;Ensure d7 is clean
	move.b	(a6)+,d7	;Get Byte to play
	andi.l	#$ff,d7
	addi.b	#$80,d7
	cmpa.l	end(a5),a6	;Are we at End ?
	bgt.s	Looptst		;Yes, Branch and test for looping
	move.l	a6,begin(a5)	;Update Begin Address
	bra	I_out		;Jump to output section

	;Sample is finished and doesn't loop
	
I_End	move	SR,d7		;Save SR
	ori.w	#$700,SR	;IPL 7
	bclr	#5,$FFFFFa07.w	;
	bclr	#5,$FFFFFa0B.w	;Timer A, tidy
	bclr	#5,$FFFFFa0F.w	;up registers
	bclr	#5,$FFFFFa13.w	;
	sf	s_hear(a5)	;Hear ON
	sf	s_on(a5)	;Signal Sample OFF
	move.w	d7,SR		;Restore SR
	movem.l	(a7)+,d6-d7/a5-a6	;Restore Regs
	rte			;End of Interrupt

	;Sample is finished, check for looping
	
Looptst	sf	s_on(a5)	;Signal Sample OFF
	tst.w	loop(a5)	;Test for looping
	beq.s	I_End		;No, Jump and finish off
	move.l	start(a5),d7	;Get Sample start
	move.l	d7,begin(a5)	;Place in Begin
	add.l	len(a5),d7	;Add on Length
	move.l	d7,end(a5)	;Place in End
	movem.l	(a7)+,d6-d7/a5-a6	;Restore Regs
	bclr	#5,$FFFFFa0F.w	;End Interrupt
	rte


I_out	add.w	d7,d7		;Get 2 * .L
	add.w	d7,d7		;offset
	add.w	d7,d7		;offset
	move.l	sndtab(pc,d7.W),d6	
	move.w	sndtab+4(pc,d7.W),d7	
	movea.l	#$FFFF8800,a6	;
	movep.l	D6,(a6)		;	
	movep.w	d7,(a6)		;Output Sound
	movem.l	(a7)+,d6-d7/a5-a6	;Restore Regs
	bclr	#5,$FFFFFa0F.w	;End Interrupt
	rte			;


	***********************
	* SOUND LOOKUP TABLES *
	***********************
	*
	* 3 words for each of 255 possible volumes
	* ( Runs Loud -> Quiet )
	*
	* 3 channels gives 16+15+15 volumes ???
	*
	
sndtab	dc.w	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	dc.w	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	dc.w	$80D,$909,$A05,0,$80C,$90B,$A08,0
	dc.w	$80D,$909,$A02,0,$80D,$908,$A06,0
	dc.w	$80C,$90B,$A07,0,$80D,$907,$A07,0
	dc.w	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	dc.w	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	dc.w	$80C,$90B,$A00,0,$80C,$90A,$A08,0

	dc.w	$80D,$906,$A04,0,$80D,$905,$A05,0
	dc.w	$80D,$905,$A04,0,$80C,$909,$A09,0
	dc.w	$80D,$904,$A03,0,$80B,$90B,$A09,0
	dc.w	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	dc.w	$80C,$909,$A08,0,$80B,$90B,$A08,0
	dc.w	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	dc.w	$80C,$909,$A07,0,$80B,$90B,$A07,0
	dc.w	$80C,$909,$A06,0,$80B,$90B,$A06,0

	dc.w	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	dc.w	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	dc.w	$80B,$90A,$A08,0,$80C,$907,$A07,0
	dc.w	$80C,$908,$A04,0,$80C,$907,$A06,0
	dc.w	$80B,$909,$A09,0,$80C,$906,$A06,0
	dc.w	$80A,$90A,$A09,0,$80C,$907,$A03,0
	dc.w	$80B,$90A,$A05,0,$80B,$909,$A08,0
	dc.w	$80B,$90A,$A03,0,$80A,$90A,$A08,0

	dc.w	$80B,$90A,$A00,0,$80B,$909,$A07,0
	dc.w	$80B,$908,$A08,0,$80A,$90A,$A07,0
	dc.w	$80A,$909,$A09,0,$80C,$901,$A01,0
	dc.w	$80A,$90A,$A06,0,$80B,$908,$A07,0
	dc.w	$80A,$90A,$A05,0,$80A,$909,$A08,0
	dc.w	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	dc.w	$80A,$90A,$A00,0,$809,$909,$A09,0
	dc.w	$80A,$908,$A08,0,$80B,$908,$A01,0

	dc.w	$80A,$909,$A06,0,$80B,$907,$A04,0
	dc.w	$80A,$909,$A05,0,$809,$909,$A08,0
	dc.w	$80A,$909,$A03,0,$80A,$908,$A06,0
	dc.w	$80A,$909,$A00,0,$809,$909,$A07,0
	dc.w	$809,$908,$A08,0,$80A,$908,$A04,0
	dc.w	$809,$909,$A06,0,$80A,$908,$A01,0
	dc.w	$809,$909,$A05,0,$809,$908,$A07,0
	dc.w	$808,$908,$A08,0,$809,$909,$A02,0

	dc.w	$809,$908,$A06,0,$809,$909,$A00,0
	dc.w	$809,$907,$A07,0,$808,$908,$A07,0
	dc.w	$809,$907,$A06,0,$809,$908,$A02,0
	dc.w	$808,$908,$A06,0,$809,$906,$A06,0
	dc.w	$808,$907,$A07,0,$808,$908,$A04,0
	dc.w	$808,$907,$A06,0,$808,$908,$A02,0
	dc.w	$807,$907,$A07,0,$808,$906,$A06,0
	dc.w	$808,$907,$A04,0,$807,$907,$A06,0

	dc.w	$808,$906,$A05,0,$808,$906,$A04,0
	dc.w	$807,$906,$A06,0,$807,$907,$A04,0
	dc.w	$808,$905,$A04,0,$806,$906,$A06,0
	dc.w	$807,$906,$A04,0,$807,$905,$A05,0
	dc.w	$806,$906,$A05,0,$806,$906,$A04,0
	dc.w	$806,$905,$A05,0,$806,$906,$A02,0
	dc.w	$806,$905,$A04,0,$805,$905,$A05,0
	dc.w	$806,$905,$A02,0,$805,$905,$A04,0

	dc.w	$805,$904,$A04,0,$805,$905,$A02,0
	dc.w	$804,$904,$A04,0,$804,$904,$A03,0
	dc.w	$804,$904,$A02,0,$804,$903,$A03,0
	dc.w	$803,$903,$A03,0,$803,$903,$A02,0
	dc.w	$803,$902,$A02,0,$802,$902,$A02,0
	dc.w	$802,$902,$A01,0,$801,$901,$A01,0
	dc.w	$802,$901,$A00,0,$801,$901,$A00,0
	dc.w	$801,$900,$A00,0,$800,$900,$A00,0

	dc.w	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	dc.w	$80F,$903,$A00,0,$80F,$903,$A00,0
	dc.w	$80F,$903,$A00,0,$80F,$903,$A00,0
	dc.w	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	dc.w	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	dc.w	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	dc.w	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	dc.w	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0

	dc.w	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	dc.w	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	dc.w	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	dc.w	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	dc.w	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	dc.w	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	dc.w	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	dc.w	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0

	dc.w	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	dc.w	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	dc.w	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	dc.w	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	dc.w	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	dc.w	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	dc.w	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	dc.w	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0

	dc.w	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	dc.w	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	dc.w	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	dc.w	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	dc.w	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	dc.w	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	dc.w	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	dc.w	$80E,$90B,$A00,0,$80D,$90D,$A09,0

	dc.w	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	dc.w	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	dc.w	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	dc.w	$80E,$90A,$A04,0,$80E,$909,$A09,0
	dc.w	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	dc.w	$80E,$909,$A08,0,$80E,$909,$A08,0
	dc.w	$80E,$909,$A07,0,$80E,$908,$A08,0
	dc.w	$80E,$909,$A01,0,$80C,$90C,$A0C,0

	dc.w	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	dc.w	$80E,$907,$A07,0,$80E,$908,$A00,0
	dc.w	$80E,$907,$A05,0,$80E,$906,$A06,0
	dc.w	$80D,$90C,$A09,0,$80E,$905,$A05,0
	dc.w	$80E,$904,$A04,0,$80D,$90C,$A08,0
	dc.w	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	dc.w	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	dc.w	$80D,$90C,$A02,0,$80C,$90C,$A0B,0

	dc.w	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	dc.w	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	dc.w	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	dc.w	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	dc.w	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	dc.w	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	dc.w	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	dc.w	$80C,$90C,$A09,0,$80C,$90C,$A09,0

	dc.w	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	dc.w	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	dc.w	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	dc.w	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	dc.w	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	dc.w	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	dc.w	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	dc.w	$80D,$909,$A08,0,$80D,$909,$A08,0


	
	*************************
	* Speed/Frequency Table *
	*************************

	;First word = control - Event count mode divider
	;second     = data    - Events to wait before generating interrupt
		
freq	dc.w	$03,$1F	;Divide by 16, Wait 31 -   5 KHz (4166Hz?) 
	dc.w	$01,$52	;Divide by 4 , Wait 82 - 7.5 KHz (6172Hz?)
	dc.w	$01,$3E	;Divide by 4 , Wait 62 -  10 KHz (8196Hz?)
	dc.w	$01,$29	;Divide by 4 , Wait 41 -  15 KHz (12500Hz?)
	dc.w	$01,$1F	;Divide by 4 , Wait 31 -  20 KHz (16666Hz?)
	dc.w	$01,$1F	;Divide by 4 , Wait 31 -    " 
	dc.w	$01,$1F	;Divide by 4 , Wait 31 -    "
	dc.w	$01,$1F	;Divide by 4 , Wait 31 -    "


	**************************
	* Sound Channel Commands *
	**************************
	
snddata	dc.w	$0200	; load reg2,$00		Chan B - Fine Tune
	dc.w	$0300	; load reg3,$00		Chan B - Coarse Tune
	dc.w	$0400	; load reg4,$00		Chan C - Fine Tune
	dc.w	$0500	; load reg5,$00		Chan C - Coarse Tune
	dc.w	$07FF	; load reg7,$ff		Everything off!
	dc.w	$0900	; load reg9,$00		Chan B - Amplitude
	dc.w	$0a00	; load reg10,$00	Chan C - Amplitude
	dc.w	$FF00	; End sound commands	

	even
	
env	dc.l	0

name	dc.b	"\decade.dat",0

	even
	
progstart ds.l	1	

	ds.l	100		Declare storage required
mystack	ds.l	1		for stack 101 .L ( 404 bytes )


	************
	* THE END! *
	************
	
	section	data

smp	incbin	"\lfb_bong.sam"
bs	equ	smp+12

	even
	
pic	incbin	"\nyd.pi1"
picture	equ	pic+34
cols	equ	pic+2

	even
		
zzz	incbin	"\nyd2.pi1"
pic2	equ	zzz+34
cols2	equ	zzz+2





