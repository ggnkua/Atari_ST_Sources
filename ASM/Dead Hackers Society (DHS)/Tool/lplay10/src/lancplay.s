; 50 kHz modplayer using Lance/Impulse replayer
; Replayer optimized by Paulo Simoes (Hacking Lance)
; Replayer cleaned up and modernised by Insane/.tSCc.
;
; Builds with vasm
; vasm -m68000 -Ftos -noesc -nosym -no-opt -unnamed-sections lancplay.s -o 50066hz.ttp
;
; v1.0: May 10, 2025
; ae@dhs.nu

replayspeed:	equ	3				;1=12517 Hz, 2=25033 Hz, 3=50066 Hz

		section	text

		move.l	4(sp),a5			;Address to basepage
		move.l	a5,d0				;Basepage address
		add.l	#129,d0				;Offset to commandline
		move.l	d0,fn
		move.l	$0c(a5),d0			;Length of text segment
		add.l	$14(a5),d0			;Length of data segment
		add.l	$1c(a5),d0			;Length of bss segment
		add.l	#$100,d0			;Length of basepage
		add.l	#$1000,d0			;Length of stackpointer
		move.l	a5,d1				;Address to basepage
		add.l	d0,d1				;End of program
		and.l	#-2,d1				;Make address even
		move.l	d1,sp				;New stackspace

		move.l	d0,-(sp)			;mshrink()
		move.l	a5,-(sp)
		move.w	d0,-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp

; ------------- Check machine type via Cookiejar, exit if not STe or MSTe
		pea	detect_machine(pc)		;supexec()
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp

		move.l	machine(pc),d0
		cmp.l	#"STe ",d0
		beq.s	.go
		cmp.l	#"MSTe",d0
		beq.s	.go

		lea	error_machine(pc),a0
		bra	exit_error

; ------------- Reserve memory and load module
.go:
		clr.w	-(sp)				;fopen()
		move.l	fn(pc),-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		lea	error_fopen(pc),a0
		tst.l	d0
		bmi	exit_error
		move.w	d0,fhandle

		move.w	#2,-(sp)			;fseek()
		move.w	fhandle(pc),-(sp)
		clr.l	-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp
		lea	error_fseek(pc),a0
		tst.l	d0
		bmi	exit_error
		move.l	d0,fsize

		clr.w	-(sp)				;fseek()
		move.w	fhandle(pc),-(sp)
		clr.l	-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp
		lea	error_fseek(pc),a0
		tst.l	d0
		bmi	exit_error

		move.l	fsize(pc),d0			;malloc()
		add.l	#31*665*2,d0
		move.l	d0,-(sp)
		move.w	#72,-(sp)
		trap	#1
		addq.l	#6,sp
		lea	error_malloc(pc),a0
		tst.l	d0
		beq.s	exit_error
		move.l	d0,faddr

		move.l	faddr(pc),-(sp)			;fread()
		move.l	fsize(pc),-(sp)
		move.w	fhandle(pc),-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		lea	error_fread(pc),a0
		tst.l	d0
		bmi.s	exit_error

		move.w	fhandle(pc),-(sp)		;fclose()
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		lea	error_fclose(pc),a0
		tst.l	d0
		bne.s	exit_error


; ------------- Make sure it's a Protracker file and print some info
		bsr	check_module
		bsr	copy_samplenames
		bsr	print_infos


; ------------- Fire up the player, wait for space and close
		pea	start_module(pc)		;supexec()
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp

.nospace:
		move.w	#7,-(sp)			;crawcin()
		trap	#1
		addq.l	#2,sp
		cmp.b	#" ",d0
		bne.s	.nospace

		pea	stop_module(pc)			;supexec()
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp


		clr.w	-(sp)
		trap	#1

exit_error:
		bsr	cconws

		clr.w	-(sp)
		trap	#1


; ------------- Inititalise the Paula emulator and Protracker replay
start_module:
		moveq	#replayspeed,d0
		jsr	paula_init
		move.l	faddr,a0
		jsr	mt_init
		st	mt_Enable

		move.w	sr,d0
		move.w	#$2700,sr
		move.l	$114.w,save_tc
		move.l	#timer_c,$114.w
		move.w	d0,sr
		rts

; ------------- Stop the Paula emulator
stop_module:	
		move.w	sr,d0
		move.w	#$2700,sr
		move.l	save_tc,$114.w
		move.w	d0,sr
		jsr	mt_end
		jsr	paula_done
		rts

; ------------- 50 Hz Paula and Protracker calls
timer_c:	subq.w	#1,.delay
		bne.s	.noplay
		addq.w	#4,.delay
		movem.l	d0-a6,-(sp)
		bsr	paula_calc
		bsr	mt_music
		movem.l	(sp)+,d0-a6
.noplay:	move.l	save_tc(pc),-(sp)
		rts
.delay:		dc.w	1



; ------------- Show some infos about the player and loaded module
print_infos:
		lea	title(pc),a0
		bsr	cconws

		move.l	faddr,a0
		bsr	cconws

		lea	crlf(pc),a0
		bsr	cconws
		lea	crlf(pc),a0
		bsr	cconws

		lea	samples_header(pc),a0
		bsr	cconws

		lea	samples(pc),a0
		bsr	cconws
		rts

copy_samplenames:

		move.l	faddr(pc),a0
		lea	20(a0),a0
		lea	30*16(a0),a1
		lea	samples+3(pc),a2

		moveq	#16-1,d7
.yloop1:	moveq	#22-1,d6
.charloop1:	move.b	(a0)+,d0
		beq.s	.next1
		move.b	d0,(a2)
.next1:		addq.l	#1,a2
		dbra	d6,.charloop1
		lea	8(a0),a0
		lea	53-22(a2),a2
		dbra	d7,.yloop1

		lea	samples+29(pc),a2
		moveq	#15-1,d7
.yloop2:	moveq	#22-1,d6
.charloop2:	move.b	(a1)+,d0
		beq.s	.next2
		move.b	d0,(a2)
.next2:		addq.l	#1,a2
		dbra	d6,.charloop2
		lea	8(a1),a1
		lea	53-22(a2),a2
		dbra	d7,.yloop2

		rts


; ------------- Check some module headers, exit if not found
check_module:
		move.l	faddr,a0
		move.l	1080(a0),d0

		cmp.l	#"M.K.",d0			;Noisetracker / Protracker
		beq.s	.ok

		cmp.l	#"M!K!",d0			;Noisetracker
		beq.s	.ok

		cmp.l	#"M&K&",d0			;Noisetracker
		beq.s	.ok

		cmp.l	#"FLT4",d0			;Startrekker
		beq.s	.ok

		cmp.l	#"RASP",d0			;Startrekker
		beq.s	.ok

		cmp.l	#"FA04",d0			;Old Digital Tracker
		beq.s	.ok

		lea	error_mod,a0
		bra	exit_error

.ok:		move.l	#"M.K.",1080(a0)
		rts


; ------------- Detect computer via Cookiejar
detect_machine:
		lea	machine,a6

		move.l	$5a0.w,d0
		beq.s	.st				;Null pointer = ST
		move.l	d0,a0

		moveq	#128-1,d7
.search_mch:	tst.l	(a0)
		beq.s	.st				;Null termination of cookiejar, no _MCH found = ST

		cmp.l	#"_MCH",(a0)
		beq.s	.mch_found
		addq.l	#8,a0
		dbra	d7,.search_mch
		bra.s	.st				;No _MCH cookie found, default to ST

.mch_found:	move.l	4(a0),d0
		cmp.l	#$00010000,d0			;STe
		beq.s	.ste
		cmp.l	#$00010008,d0			;STe + IDE
		beq.s	.ste
		cmp.l	#$00010010,d0			;Mega STe
		beq.s	.megaste
		cmp.l	#$00020000,d0			;TT
		beq.s	.tt
		cmp.l	#$00030000,d0			;Falcon
		beq.s	.falcon

.st:		move.l	#"ST  ",(a6)
		rts

.ste:		move.l	#"STe ",(a6)
		rts

.megaste:	move.l	#"MSTe",(a6)
		rts

.tt:		move.l	#"TT  ",(a6)
		rts

.falcon:	move.l	#"FALC",(a6)
		rts


;============== cconws() - print text string ===========
;in: a0.l address to null terminated string
cconws:		move.l	a0,-(sp)
		move.w	#$9,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

fn:		dc.l	0
save_tc:	dc.l	0
save_vbl:	dc.l	0
faddr:		dc.l	0
fhandle:	dc.w	0
fsize:		dc.l	0
machine:	dc.l	0

error_fopen:	dc.b	"fopen() failed.",13,10,0
error_fseek:	dc.b	"fseek() failed.",13,10,0
error_fread:	dc.b	"fread() failed.",13,10,0
error_fclose:	dc.b	"fclose() failed.",13,10,0
error_malloc:	dc.b	"malloc() failed.",13,10,0
error_machine:	dc.b	"STe machine needed.",13,10,0
error_mod:	dc.b	"Unknown module format.",13,10,0

			;0123456789012345678901234567890123456789
title:		dc.b	"Hacking Lance Protracker player v1.0",13,10
		if	replayspeed=1
		dc.b	"12517 Hz stereo version",13,10
		endc
		if	replayspeed=2
		dc.b	"25033 Hz stereo version",13,10
		endc
		if	replayspeed=3
		dc.b	"50066 Hz stereo version",13,10
		endc
		dc.b	"Song title: ",0


crlf:		dc.b	13,10,0

samples_header:	dc.b	"Sample names:",13,10,0
samples:	dc.b	"01                        17                       ",13,10
		dc.b	"02                        18                       ",13,10
		dc.b	"03                        19                       ",13,10
		dc.b	"04                        20                       ",13,10
		dc.b	"05                        21                       ",13,10
		dc.b	"06                        22                       ",13,10
		dc.b	"07                        23                       ",13,10
		dc.b	"08                        24                       ",13,10
		dc.b	"09                        25                       ",13,10
		dc.b	"10                        26                       ",13,10
		dc.b	"11                        27                       ",13,10
		dc.b	"12                        28                       ",13,10
		dc.b	"13                        29                       ",13,10
		dc.b	"14                        30                       ",13,10
		dc.b	"15                        31                       ",13,10
		dc.b	"16                                                 ",13,10,0

		even


		include	'lancepaula.asm'
		even

		include	'lancetracker.asm'
		even

