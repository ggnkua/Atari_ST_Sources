
***************************************************************************
* THE LOWER LEVEL : 3 CHANNEL PLAYER, FOR RIPPED MUSIC                    *
* Written by ZCT                                                          *
***************************************************************************
* DEVPAC: SET TABS TO 11, TEXT BUFFER TO 20KB, ASSEMBLE TO 40KB of MEMORY.*
***************************************************************************
* A music file has two main routines, init and play.  INIT has to be      *
* executed at the start.  A parameter is passed in D0 to tell the routine *
* which piece of music to play.  Some files have only one piece of music, *
* but others may have five or more.  By changing the value in D0 and      *
* executing INIT you can select a new tune.                               *
* The PLAY routine actually does the work, it is executed every VBL and   *
* will play a sequence of three notes through each of the three sound     *
* ports.                                                                  *
***************************************************************************
* If you have any questions surrounding this source please contact us :   *
* 34 OVERBROOK DRIVE, CHELTENHAM, GLOUCESTERSHIRE, GL52 3HR, ENGLAND.     *
* (ENCLOSE AN SAE if you want a reply)                                    *
***************************************************************************

START	PEA	$70000		;new stack position
	MOVE.W	#$20,-(SP)
	TRAP	#1		;supervisor mode
	CLR.W	-(SP)		;LOW REZ
	PEA	$70000		;NEW SCREEN ADDRESS
	PEA	$70000
	MOVE.W	#5,-(SP)
	TRAP	#14		;set
	LEA	12(SP),SP
	
	DC.W	$A00A		;no mouse
	
	MOVEM.L	D0-D7,-(SP)	;PUSH
	LEA	oldpal,A0
	MOVEM.L	$FFFF8240.W,D0-D7
	MOVEM.L	D0-D7,(A0)		;store old colour palette
	MOVEM.L	(SP)+,D0-D7	;POP

	MOVE.W	#$777,$FFFF825E.W	;make text white
	MOVE.L	#$004,$FFFF8240.W	;background black VU blue
	MOVE.L	#tcol,colpos	;initalize flasher
	MOVE.B	#2,$FFFF820A.W	;50Hz
	
	MOVE.L	#Bus,$08.W		;NO Bus ERROR
	MOVE.L	#addRess,$0C.W	;NO addRess ERROR
	MOVE.L	#illeGal,$10.W	;THAT ONE IS HISTORY TOO !!!
	
	MOVE.W	#8000-1,D7
	LEA	$70000,A6
lp	CLR.L	(A6)+		;clear screen
	DBF	D7,lp
	
	PEA	text
	MOVE.W	#9,-(SP)
	TRAP	#1		;output message
	ADDQ	#6,SP
	
	BSR	on		;set music going
	
wait	MOVE	#7,-(SP)
	TRAP	#1		;wait for a keypress
	ADDQ	#2,SP
	
	SWAP	D0		;get scancode
	CMPI.B	#$39,D0		;if spacebar
	BEQ	end		;QUIT
	
	CMPI.B	#$3B,D0		;test for F1
	BEQ.S	channel
	CMPI.B	#$3C,D0		;test for F2
	BEQ.S	channel
	CMPI.B	#$3D,D0		;test for F3
	BEQ.S	channel
	
	CMPI.B	#$B,D0		;test for zero
	BEQ.S	zero
	
	SUB.B	#1,D0
	CMPI.B	#9,D0		;see if a number was pressed
	BGT.S	wait	;if illegal key was pressed continue loop
	
mchange	MOVE.L	mstart,A0
	ADDQ	#2,A0
	MOVE.L	D0,-(SP)	;sometimes the INIT routine corrupts D0
	JSR	(A0)		;RE-INITIALISE MUSIC
	MOVE.L	(SP)+,D0		;POP !
	BSR	status_d0		;update status bar
	BRA.S	wait		;continue looping
	
zero	MOVEQ	#0,D0
	BRA.S	mchange
	
channel	SUB.L	#$38,D0		;convert scancode to 3,4 or 5
	MOVE.W	D0,btst+2	;directly alter BTST instruction
	BSR	status_c		;update status bar
	BRA.S	wait		;continue looping
	
status_c	ADDI.W	#$31-3,D0		;make D0 a valid ascii code
	MOVE.B	D0,fx		;change status message
	BRA.S	show_stat		;re-draw status bar
	
status_d0	TST.W	D0   ;check if D0 is 0 'cos the ascii code will not
	BEQ.S	opz  ;be directly proportional to the scancode.
	ADDI.W	#$30,D0	;numeric scancode now = ascii code
	MOVE.B	D0,ps_d0		;modify the status bar text
	BRA.S	show_stat		;re-draw status bar
opz	MOVE.B	#$30,ps_d0		;ascii code for 0
show_stat	PEA	status_bar
	MOVE.W	#9,-(SP)
	TRAP	#1		;OUTPUT status bar to screen
	ADDQ	#6,SP
	RTS			;go home
	
end	MOVE.L	#oldpal,$45A.W	;RESET COLOURS
quit	BSR	off		;kill interupts
	DC.W	$A009	;come back mouse all is forgiven !!!
	CLR.W	-(SP)
	TRAP	#1		;kill program (OUCH !!!)

Bus	MOVE.L	#$00770000,$FFFF8240.W
	BRA.S	no_bomb
addRess	MOVE.L	#$07000000,$FFFF8240.W
	BRA.S	no_bomb
illeGal	MOVE.L	#$00700000,$FFFF8240.W

no_bomb	MOVE.W	#$2300,SR		;bring IPL back down
	LEA	$70000,SP		;correct stack
	CLR.L	$4D2.W		;switch off VBL IRQ
	MOVE.W	#1,$452.W		;allow VBL IRQ next time
	MOVE.B	#2,$FFFF820A.W	;ensure 50Hz
	BRA.S	quit		;we can quit now

*********************************************************************
* SCROLL : A very advanced subroutine !!!  (Executed from the VBI ) *
*********************************************************************

scroll	LEA	$70000,A0
	ADDA.L	#160*90,A0
	MOVE.W	#110-1,D0
shift	MOVEQ	#0,D1
	ROXR.W	D1		;clear carry
	ROXL.W	152(A0)		;scroll one line
	ROXL.W  	144(A0)
           ROXL.W	136(A0)
           ROXL.W 	128(A0)
           ROXL.W  	120(A0)
           ROXL.W  	112(A0)
           ROXL.W  	104(A0)
           ROXL.W  	 96(A0)
           ROXL.W  	 88(A0)
           ROXL.W  	 80(A0)
           ROXL.W  	 72(A0)
           ROXL.W      64(A0)
           ROXL.W  	 56(A0)
           ROXL.W  	 48(A0)
           ROXL.W  	 40(A0)
           ROXL.W  	 32(A0)
           ROXL.W  	 24(A0)
           ROXL.W  	 16(A0)	
           ROXL.W  	  8(A0)
	ROXL.W  	   (A0)
	MOVEQ	#0,D1
	ROXR.W	D1
	ADDA.L	#160,A0		;next line
	DBF	D0,shift
	RTS			;back to VBL IRQ
	
***************************************************************************
on	LEA	music,A6		;location of music
	MOVE.L	mstart,A5		;relocate to here
	MOVE.L	#6000-1,D7		;music can be up to 24000 bytes
relocate	MOVE.L	(A6)+,(A5)+
	DBF	D7,relocate
	MOVE.L	mstart,A0		;INIT music and start VBL-IRQ
	BCLR	#0,$484.W		;turn off that bloody click
	JSR	(A0)		;HIT IT
	RTS
	
off	CLR.L	$4D2.W		;DISABLE IRQ
	MOVE.L	#$8080000,$FFFF8800.W	;SILENCE SOUND-CHIP
	MOVE.L	#$9090000,$FFFF8800.W
	MOVE.L	#$A0A0000,$FFFF8800.W
	BSET	#0,$484.W		;K/B CLICK ON
	RTS
	
*************************************************************************
* The only bit of code you really need here is JSR VBL.  The rest of it *
* is for the VU meter and the disk drive FX.  If you wish to use this   *
* source in your own program delete all the other code and remove the * *
* from the first RTS.  I have also preserved the registers in case you  *
* wish to call IRQ from your own interupt routine.  On a normal VBL-IRQ *
* this is unneccessary since the system does it for you.                *
*************************************************************************

IRQ	JSR	VBL		;PLAY MUSIC
*	RTS		
	MOVEM.L	A0/D0,-(SP)	;you don't really need this
pulse	MOVE.L	colpos,A0
	MOVE.W	(A0)+,D0
	TST.W	D0
	BMI.S	color_wrap
	MOVE.W	D0,$FFFF825E.W
	MOVE.L	A0,colpos
	BRA.S	flash		;oo-er !
color_wrap	MOVE.L	#tcol,colpos
	
flash	MOVE.B	#7,$FFFF8800.W	;LISTEN TO REG 7
btst	BTST	#3,$FFFF8800.W	;CHECK BITS 3,4 OR 5
	BNE.S	low
	MOVE.B	#14,$FFFF8800.W	;LIGHT/FX
	MOVE.B	#$40,$FFFF8802.W	;ON
	MOVE.W	#$700,$FFFF8242.W
	BRA.S	cont
low	MOVE.B	#14,$FFFF8800.W	;LIGHT/FX
	MOVE.B	#2,$FFFF8802.W	;OFF
	MOVE.W	#$007,$FFFF8242.W		

cont	MOVE.L	#$70000+160*120,A0
	CLR.L	D0
	MOVE.B	#8,$FFFF8800.W	;SOUNDCHIP REG 8
	MOVE.B	$FFFF8800.W,D0
	TST.B	D0
	BMI.S	silence2
	ANDI.B	#15,D0		;ignore if volume is > 15
draw1	OR.W	#1,152(A0)		;this can happen with wierd
	OR.W	#1,312(A0)		;music waveforms
	SUBA.L	#320,A0
	DBF	D0,draw1
	
silence2	MOVE.L	#$70000+160*155,A0	;physic
	CLR.L	D0
	MOVE.B	#9,$FFFF8800.W	;SOUNDCHIP REG 9
	MOVE.B	$FFFF8800.W,D0
	TST.B	D0
	BMI.S	silence3
	ANDI.B	#15,D0
draw2	OR.W	#1,152(A0)	;try changing this to OR.W #3,152(A0)
	OR.W	#1,312(A0)	;and this to OR.W #3,312(A0)
	SUBA.L	#320,A0	;do the same with the other two routines !
	DBF	D0,draw2

silence3	MOVE.L	#$70000+160*190,A0	;physic
	CLR.L	D0
	MOVE.B	#10,$FFFF8800.W	;SOUNDCHIP REG 10
	MOVE.B	$FFFF8800.W,D0	;get volume
	TST.B	D0		;if silent skip this routine
	BMI.S	slide
	ANDI.B	#15,D0
draw3	OR.W	#1,152(A0)
	OR.W	#1,312(A0)
	SUBA.L	#320,A0	;move "graphics cursor" up two lines
	DBF	D0,draw3	;repeat until bar is correct height

slide	BSR	scroll	;scroll screen
	BSR	scroll	;twice
	
	MOVEM.L	(SP)+,A0/D0 	;restore registers
	
	RTS	;END OF VBL IRQ, return to key watch routine.
	
music	MOVEQ	#1,D0		;SELECT TUNE
	JSR	INIT		;INITALISE
	MOVE.L	#IRQ,$4D2		;INSTALL VBL IRQ
	RTS
***************************************************************************
* PARAMETERS *
**************

PLAY	INCBIN	A:\MUSICRIP.ING\CHARTS.MUS ;specify FULL pathname
mstart	DC.L	$7A000	;START (we move the music to here)
INIT	EQU	$7A014	;INIT ROUT (mstart + offset)
VBL	EQU	$7A01C	;VBL MUSIC ROUT (mstart + offset)
***************************************************************************
	EVEN
text	DC.B	"(C) 1990 THE LOWER LEVEL          V3.2",10,10,13
	DC.B	"MUSIC REPLAY ROUTINE, WRITTEN BY -ZCT-",10,10,13
	DC.B	"HIT 0-9 to change D0",10,13
	DC.B	"and F1-F3 to change disk drive FX",10,13,10
	DC.B	"SPACE QUITS",10,10,13
status_bar	DC.B	"CURRENT STATUS : D0="
ps_d0	DC.B	"1"
	DC.B	", FX ON CHANNEL "
fx	DC.B	"1",13,0

*****************************************************************************
* DATA
*****************************************************************************

	EVEN
oldpal	DS.W	16
colpos	DC.L	0
tcol	DC.W	$700,$710,$720,$730,$740,$750,$760,$770	;R->Y
	DC.W	$670,$570,$470,$370,$270,$170,$070	;Y->G
	DC.W	$071,$072,$073,$074,$075,$076,$077	;G->C
	DC.W	$067,$057,$047,$037,$027,$017,$007	;C->B
	DC.W	$107,$207,$307,$407,$507,$607,$707	;B->M
	DC.W	$706,$705,$703,$702,$701,-1		;M->R
******************************************************************************