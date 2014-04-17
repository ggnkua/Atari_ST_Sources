
	move.l	sp,oldsp

	pea	Prog(pc)
	move.w	#$26,-(sp)	Call SUPERVISOR routine.
	trap	#14
	addq.l	#6,sp
term
	move.l	oldsp,sp
	move.w	#0,-(sp)	any value
	move.w	#$4c,-(sp)	P_Term/Quit.
	trap	#1

oldsp:	dc.l	0

Prog
	bsr	InitSystem		start up exceptions etc

	bsr	startsong		Initialise song


WaitKey

;THIS IS WHERE YOU DO WHAT YOU LIKE (SCREEN ANIMATION ETC...)
	cmp.b	#$01,$fffffc02.w
	bne.s	WaitKey

	bsr.w	RestoreSystem

	rts	return from Super call to Prog



;Constant Offsets from start of DRIVER.BIN
_Install equ	$0000		sets up timer A  vector & installs
_DeInstall equ	$0004		restores old vectors etc
_Start	equ	$0008		start playing tune (_SongAddr,_VoiceAddr)
_Stop	equ	$000C		stop playing current tune
_Restart equ	$0010		restart playing current tune
_SongAddr equ	$002C	.l	holds address of song
_VoiceAddr equ	$0030	.l	holds address of 20-voice kit
_IRQmask equ	$0038	.w	holds normal IRQ mask to write to MFP


installq			;grab vectors, init soundchip, etc
	lea	sing_s(pc),a6		get sing-routine start address

	lea	song1_s,a5
	lea	sing_s(pc),a6
	move.l	a5,_SongAddr(a6)	inform system of where song is

	move.w	#$0040,_IRQmask(a6)	ie just keyboard.
	jmp	_Install(a6)

deinstallq			;restore vectors, deinit soundchip, etc
	lea	sing_s(pc),a6
	jmp	_DeInstall(a6)

startsong			;start singing song1
	lea	song1_s,a5
singsong
	lea	sing_s(pc),a6
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s,a5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	jmp	_Start(a6)		let's go!

stopsong
	lea	sing_s(pc),a6
	jmp	_Stop(a6)		stop!

restartsong
	;should have started (& stopped) a song before calling this!
	;but the program double-checks anyway
	lea	sing_s(pc),a6
	jmp	_Restart(a6)		restart!



;System startup & shutdown code

vec	MACRO
	lea	\2.w,a1
	lea	\1(pc),a2
	move.w	a1,(a0)+
	move.l	(a1),(a0)+
	move.l	a2,(a1)
	ENDM

unvec	MACRO
	move.w	(a0)+,a1
	move.l	(a0)+,(a1)
	ENDM


InitSystem
	move.w	#$2700,SR
	lea	savearea(pc),a0
	vec	vblankint,$070
	vec	timerAint,$134
	move.w	#-1,(a0)
	bclr	#3,$fffffa17.w		set AEI mode
	bsr	savemfp			remember settings of mfp

	bsr.w	installq		install quartet driver

	;now disable midi ACIA interrupts so that keyboard is sole source	
	move.b	#$00,$fffffc04.w	midi acia control reg (no irqs)
	move.b	$fffffc04.w,d0		clear any passing midi irq
	move.b	$fffffc06.w,d0		and anything in receive buffer

	move.w	#$2300,SR		Don't leave the old vbl in unless you want
*					Crashes left right and centre
	rts


RestoreSystem
	move.w	#$2700,SR

	bsr.w	deinstallq		deinstall quartet driver

	bsr	loadmfp			get default bits
	lea	savearea(pc),a0
	sub.l	a1,a1
unstacklp
	unvec
	tst.w	(a0)
	bpl.s	unstacklp
	bset	#3,$fffffa17.w		set SEI mode

	move.w	#$2300,SR
	rts


vblankint
	rte

timerAint
	rte


IERA	equ	$07
IERB	equ	$09
IPRA	equ	$0B
IPRB	equ	$0D
ISRA	equ	$0F
ISRB	equ	$11
IMRA	equ	$13
IMRB	equ	$15
VECTR	equ	$17
TACR	equ	$19
TADR	equ	$1F
TCDCR	equ	$1d
TDDR	equ	$25

ISRVEC	equ	$134

savemfp	lea	mfpdata(pc),a1
	move.b	IERA+$fffffa00.w,(a1)
	move.b	IERB+$fffffa00.w,1(a1)
	move.b	IMRA+$fffffa00.w,2(a1)
	move.b	IMRB+$fffffa00.w,3(a1)
	move.b	TADR+$fffffa00.w,4(a1)
	move.b	TACR+$fffffa00.w,5(a1)
	move.b	VECTR+$fffffa00.w,6(a1)
	rts

loadmfp	move.b	mfpdata+6(pc),VECTR+$fffffa00.w
	move.b	mfpdata+5(pc),TACR+$fffffa00.w
	move.b	mfpdata+4(pc),TADR+$fffffa00.w
	move.b	mfpdata+3(pc),IMRB+$fffffa00.w
	move.b	mfpdata+2(pc),IMRA+$fffffa00.w
	move.b	mfpdata+1(pc),IERB+$fffffa00.w
	move.b	mfpdata+0(pc),IERA+$fffffa00.w
	rts


mfpdata	dcb.b	16,0

savearea ds.w	$100		ST's vectors go here


	ds.b	8000
sing_s
*	incbin	track.bin
	include	volpro1s.s
	even

song1_s	incbin	rsi.mod
	even
voice_s	
	ds.w	32*1600
	end
