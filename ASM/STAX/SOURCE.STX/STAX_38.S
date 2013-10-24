
*** STAX CD #38 INTRO PROGRAM *** RELEASED ON 22.01.1993

; 12th CD Intro coded by Matt of STAX
; (c) for now and forever, started on 13.1.1993, finished on 18.1.1993
; Members of STAX are: Matt (Coder), Mike (Coder), Sodan (Artist)
;				Tyan (Musician,Swapper), Dux (Incarnation of Lazyness)
; ---------------------------------------------------------------------------

; If you use something of this crappy code then feel more than free to
; credit us for everything you 'borrow' from here !!!
; (Source 100% compatible for Turbo ASS 1.6 and newer !!!)
; Note: There is still a lot of the CPU Time free but this is just a Menu-
; Program for which I don't wanna spend too much time at all, so don't care
; about it without remembering this !!!

; All Coding and Design done by :	Matt of STAX
; Blue 'Chrystallo' Characters  :	Mike of STAX
; Small Characterset		:	Cape-City of Mega-Wanx
; STAX-Logo Design		 :	Dominator of The Techno Gangsters (TTG)
; Marvellous Chip Muzak		:	SNK of Pure Energy


anz_keys		equ 1		; 1-anz_keys can be pressed for selector

		text


init:		movea.l 4(sp),a5		; give unused memory back to TOS
		move.l	12(a5),d0
		add.l	20(a5),d0
		add.l	28(a5),d0
		addi.l	#$1100,d0
		move.l	d0,d1
		add.l	a5,d1
		andi.l	#-2,d1
		movea.l d1,sp

		move.l	d0,-(sp)
		move.l	a5,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)	; mshrink
		trap	#1
		lea	12(sp),sp

		pea	main(pc)	; call supervisor intro routine
		move.w	#38,-(sp)
		trap	#14
		addq.l	#6,sp

		cmpi.w	#0,magic_number
		beq.s	quit		; means 'Escape' was pressed !!!
		bra	go_and_load_something

quit:		clr.w	-(sp)
		trap	#1


files:		dc.l 0,file1,file2,file3,file4,file5,file6
		dc.l file7,file8,file9,file10

magic_number:	dc.w 0

par:		dc.b 0
env:		dc.b 0

file1:		dc.b 'SPACKER3.PRG',0
		even
file2:		dc.b 'ADVERT.PRG',0
		even
file3:		dc.b 'D_TOWER.PRG',0
		even

file4:		dc.b 'PROGRAM.PRG',0
		even
file5:		dc.b 'PROGRAM.PRG',0
		even
file6:		dc.b 'PROGRAM.PRG',0
		even
file7:		dc.b 'PROGRAM.PRG',0
		even
file8:		dc.b 'PROGRAM.PRG',0
		even
file9:		dc.b 'PROGRAM.PRG',0
		even
file10:		dc.b 'PROGRAM.PRG',0
		even


go_and_load_something
		lea	files(pc),a6
		move.w	magic_number(pc),d0
		lsl.w	#2,d0
		movea.l 0(a6,d0.w),a6

		pea	env(pc)
		pea	par(pc)
		pea	(a6)
		clr.w	-(sp)
		move.w	#$4b,-(sp)	; pexec reloading system
		trap	#1
		lea	16(sp),sp
		tst.w	d0
		bmi	quit		; quit if error occured
		clr.w	-(sp)		; if other program should come back
		trap	#1		; then quit as well !!!

;-----------------------------------------------------------------------------

font2:		dc.b %0		; LEERSTELLE
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %1111110	; !
		dc.b %111100
		dc.b %11000
		dc.b %11000
		dc.b %0
		dc.b %11000
		dc.b %11000
		dc.b %0

		dc.b %110110	; "
		dc.b %110110
		dc.b %10010
		dc.b %100100
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %111100	; #
		dc.b %1000010
		dc.b %10011001
		dc.b %10100001
		dc.b %10100001
		dc.b %10011001
		dc.b %1000010
		dc.b %111100

		dc.b %0		; $
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %0		; %
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %0		; &
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %110	; '
		dc.b %1100
		dc.b %11000
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %1100	; (
		dc.b %11000
		dc.b %110000
		dc.b %110000
		dc.b %110000
		dc.b %110000
		dc.b %11000
		dc.b %1100

		dc.b %110000	; )
		dc.b %11000
		dc.b %1100
		dc.b %1100
		dc.b %1100
		dc.b %1100
		dc.b %11000
		dc.b %110000

		dc.b %0		; *
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %0		; +
		dc.b %11000
		dc.b %11000
		dc.b %1111110
		dc.b %1111110
		dc.b %11000
		dc.b %11000
		dc.b %0

		dc.b %0		; ,
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %11000
		dc.b %11000
		dc.b %110000

		dc.b %0		; -
		dc.b %0
		dc.b %0
		dc.b %1111110
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %0		; .
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %11100
		dc.b %11100
		dc.b %11100

		dc.b %0		; /
		dc.b %11
		dc.b %110
		dc.b %1100
		dc.b %11000
		dc.b %110000
		dc.b %1100000
		dc.b %0

		dc.b %1111100	; 0
		dc.b %11001110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11100110
		dc.b %1111100

		dc.b %11000	; 1
		dc.b %111000
		dc.b %1111000
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %111100
		dc.b %111110


		dc.b %111100	; 2
		dc.b %1101110
		dc.b %11000110
		dc.b %1100
		dc.b %11000
		dc.b %110000
		dc.b %1100110
		dc.b %11111110

		dc.b %111000	; 3
		dc.b %1101110
		dc.b %11000110
		dc.b %11100
		dc.b %11100
		dc.b %11000110
		dc.b %1101110
		dc.b %111100

		dc.b %11100	; 4
		dc.b %111000
		dc.b %1100000
		dc.b %11000000
		dc.b %11001100
		dc.b %11111110
		dc.b %11100
		dc.b %1100

		dc.b %11111110	; 5
		dc.b %11001110
		dc.b %11000000
		dc.b %11111100
		dc.b %11110
		dc.b %110
		dc.b %11000110
		dc.b %1111100

		dc.b %1111100	; 6
		dc.b %11101110
		dc.b %11000000
		dc.b %11111100
		dc.b %11001110
		dc.b %11000110
		dc.b %11101110
		dc.b %1111100

		dc.b %11111110	; 7
		dc.b %11100110
		dc.b %11000110
		dc.b %1100
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %11000

		dc.b %1111100	; 8
		dc.b %11001110
		dc.b %11000110
		dc.b %1111100
		dc.b %1111100
		dc.b %11000110
		dc.b %11100110
		dc.b %1111100

		dc.b %1111100	; 9
		dc.b %11101110
		dc.b %11000110
		dc.b %11100110
		dc.b %1111110
		dc.b %110
		dc.b %11101110
		dc.b %1111100

		dc.b %0		; :
		dc.b %11000
		dc.b %11000
		dc.b %0
		dc.b %0
		dc.b %11000
		dc.b %11000
		dc.b %0

		dc.b %0		; ;
		dc.b %0
		dc.b %11000
		dc.b %0
		dc.b %0
		dc.b %11000
		dc.b %11000
		dc.b %110000

		dc.b %0		; <
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %0		; =
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %0		; >
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %111100	; ?
		dc.b %1111110
		dc.b %1110
		dc.b %11100
		dc.b %111000
		dc.b %0
		dc.b %111000
		dc.b %111000

		dc.b %0		; @
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0
		dc.b %0

		dc.b %110000	; A
		dc.b %111000
		dc.b %1101100
		dc.b %1100110
		dc.b %11111110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110

		dc.b %11111000	; B
		dc.b %11001110
		dc.b %11000110
		dc.b %11111100
		dc.b %11111100
		dc.b %11000110
		dc.b %11001110
		dc.b %11111000

		dc.b %111100	; C
		dc.b %1101110
		dc.b %11000110
		dc.b %11000000
		dc.b %11000000
		dc.b %11000110
		dc.b %11101110
		dc.b %1111100

		dc.b %11110000	; D
		dc.b %11111100
		dc.b %11001100
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11001110
		dc.b %11111100

		dc.b %11111100	; E
		dc.b %11001110
		dc.b %11000110
		dc.b %11110000
		dc.b %11110000
		dc.b %11000110
		dc.b %11001110
		dc.b %11111100

		dc.b %11111100	; F
		dc.b %11001110
		dc.b %11000110
		dc.b %11110000
		dc.b %11110000
		dc.b %11000000
		dc.b %11000000
		dc.b %11000000

		dc.b %111100	; G
		dc.b %1101110
		dc.b %11000110
		dc.b %11000000
		dc.b %11001110
		dc.b %11000110
		dc.b %11100110
		dc.b %111110

		dc.b %11101110	; H
		dc.b %11101110
		dc.b %11000110
		dc.b %11111110
		dc.b %11111110
		dc.b %11000110
		dc.b %11101110
		dc.b %11101110

		dc.b %1111110	; I
		dc.b %111100
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %111100
		dc.b %1111110

		dc.b %1111110	; J
		dc.b %11111100
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %11011000
		dc.b %11011000
		dc.b %1110000

		dc.b %11001110	; K
		dc.b %11001110
		dc.b %11011100
		dc.b %11110000
		dc.b %11110000
		dc.b %11011100
		dc.b %11001110
		dc.b %11001110

		dc.b %11000000	; L
		dc.b %11000000
		dc.b %11000000
		dc.b %11000000
		dc.b %11000000
		dc.b %11000110
		dc.b %11111110
		dc.b %11111100

		dc.b %11000110	; M
		dc.b %11101110
		dc.b %11111110
		dc.b %11111110
		dc.b %11010110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110

		dc.b %1111100	; N
		dc.b %11111110
		dc.b %11100110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110

		dc.b %1111100	; O
		dc.b %11111110
		dc.b %11100110
		dc.b %11000110
		dc.b %11000110
		dc.b %11001110
		dc.b %11111110
		dc.b %1111110

		dc.b %1111100	; P
		dc.b %11111110
		dc.b %11000110
		dc.b %11001110
		dc.b %11111100
		dc.b %11000000
		dc.b %11000000
		dc.b %11000000

		dc.b %111100	; Q
		dc.b %1111110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11011100
		dc.b %1111000
		dc.b %1110

		dc.b %111000	; R
		dc.b %1111100
		dc.b %11000110
		dc.b %11001110
		dc.b %11111100
		dc.b %11011000
		dc.b %11001100
		dc.b %11001110

		dc.b %111000	; S
		dc.b %1111100
		dc.b %11000110
		dc.b %11000000
		dc.b %1111100
		dc.b %110
		dc.b %11000110
		dc.b %1111100

		dc.b %1111110	; T
		dc.b %1111110
		dc.b %111100
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %11000
		dc.b %11000

		dc.b %11101110	; U
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11101110
		dc.b %1111100

		dc.b %11101110	; V
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %1101100
		dc.b %1101100
		dc.b %111000

		dc.b %11101110	; W
		dc.b %11000110
		dc.b %11000110
		dc.b %11000110
		dc.b %11010110
		dc.b %11111110
		dc.b %11101110
		dc.b %11000110

		dc.b %11000110	; X
		dc.b %11101110
		dc.b %11111110
		dc.b %111000
		dc.b %111000
		dc.b %11111110
		dc.b %11101110
		dc.b %11000110

		dc.b %11000110	; Y
		dc.b %11000110
		dc.b %11000110
		dc.b %1100110
		dc.b %111100
		dc.b %11000
		dc.b %11000
		dc.b %110000

		dc.b %11111110	; Z
		dc.b %11100110
		dc.b %11001100
		dc.b %11000
		dc.b %110000
		dc.b %1100110
		dc.b %11001110
		dc.b %11111110
		even

main:		bsr	set_video
		bsr	preshift_a_little
		bsr	set_irqs

		jsr	sound
		bsr	vsync
		bsr	vsync
		movem.l font_pal,d0-d7
		movem.l d0-d7,$ffff8240.w

z:		bsr	vsync		; endless loop !!!
		jsr	sound+8
		bsr	vbl
;;;		bra.s	z

* forget the Loader, most programs of #38 don't run with this loader, so
* you can't exit from this intro !!!

		move.b	$fffffc02.w,d0
		cmpi.b	#$01+anz_keys,d0
		bhi.s	z
		cmpi.b	#0,d0
		beq.s	z
		cmpi.b	#1,d0
		beq.s	z
		ext.w	d0
		subq.w	#1,d0
		move.w	d0,magic_number

		bsr	vsync

		moveq	#0,d0
		moveq	#7,d1
		lea	$ffff8240.w,a0
cls_pal_nochmal:move.l	d0,(a0)+
		dbra	d1,cls_pal_nochmal

		move.b	#8,$ffff8800.w
		clr.b	$ffff8802.w
		move.b	#9,$ffff8800.w
		clr.b	$ffff8802.w
		move.b	#10,$ffff8800.w
		clr.b	$ffff8802.w

		bsr	restore_irqs
		bsr	restore_video
		rts

preshift_a_little:
		move	#$2700,sr
		move.w	#43*112-1,d0
		lea	logo0,a1
		lea	logo,a0
nordpol:	move.b	(a0)+,(a1)+
		dbra	d0,nordpol

		move.w	#14,d0
sÅdpol:		bsr.s	shift_logo
		movea.l logo_tab,a0
		move.l	(a0)+,(a1)
		move.l	a0,logo_tab
		lea	logo,a0
		move.w	#43*112-1,d1
westpol:	move.b	(a0)+,(a1)+
		dbra	d1,westpol
		dbra	d0,sÅdpol
		move	#$2300,sr
		rts

shift_logo:	moveq	#0,d2
stierkampf:	lea	logo,a0
		lea	0(a0,d2.w),a0
		move.w	#43-1,d3
tonne:		move	#0,ccr
		roxr.w	(a0)
		roxr.w	1*8(a0)
		roxr.w	2*8(a0)
		roxr.w	3*8(a0)
		roxr.w	4*8(a0)
		roxr.w	5*8(a0)
		roxr.w	6*8(a0)
		roxr.w	7*8(a0)
		roxr.w	8*8(a0)
		roxr.w	9*8(a0)
		roxr.w	10*8(a0)
		roxr.w	11*8(a0)
		roxr.w	12*8(a0)
		roxr.w	13*8(a0)
		lea	112(a0),a0
		dbra	d3,tonne
		addq.w	#2,d2
		cmpi.w	#8,d2		; alle Planes
		bne.s	stierkampf
		rts

;-----------------------------------------------------------------------------

set_video:	move.b	$ffff820a.w,old_sync
		move.b	$ffff8260.w,old_res
		movem.l $ffff8240.w,d0-d7
		movem.l d0-d7,old_pal
		lea	$ffff8201.w,a0
		movep.w 0(a0),d0
		move.w	d0,old_scr

		move.l	#screen_ram,d0
		clr.b	d0
		move.l	d0,physical
		lsr.l	#8,d0
		lea	$ffff8201.w,a0
		movep.w d0,0(a0)
		move.l	physical,d0
		add.l	#160+230*300,d0
		clr.b	d0
		move.l	d0,logical

		movea.l physical,a0
		movea.l logical,a1
		move.w	#230*199/2+80,d1
copy:		move.b	#0,(a0)+
		move.b	#0,(a1)+
		move.b	#0,(a1)+
		move.b	#0,(a1)+
		dbra	d1,copy

		movea.l logical,a0
		lea	160+230*57(a0),a0
		movea.l physical,a1
		lea	160+230*57(a1),a1

		move.l	a0,output_base1
		move.l	a0,output_address1
		move.l	a1,output_base2
		move.l	a1,output_address2

		move	#$2700,sr
		move.l	$70.w,old70
		move.l	#init_vbl,$70.w
		move	#$2300,sr
		bsr	vsync
		bsr	vsync

		moveq	#0,d0
		move.w	#7,d1
		lea	$ffff8240.w,a0
cls_pal:	move.l	d0,(a0)+
		dbra	d1,cls_pal

		moveq	#$12,d0
		bsr.s	ikbd
		bsr	vsync
		move.b	#2,$ffff820a.w
		bsr.s	vsync
		clr.b	$ffff8260.w
		rts

restore_video:	move.l	#init_vbl,$70.w
		bsr.s	vsync
		bsr.s	vsync

		movem.l old_pal,d0-d7
		movem.l d0-d7,$ffff8240.w

		bsr.s	vsync
		move.b	#2,$ffff820a.w
		bsr.s	vsync
		move.b	#0,$ffff820a.w
		bsr.s	vsync

		bsr.s	vsync
		move.b	old_sync,$ffff820a.w
		move.b	old_res,$ffff8260.w

		bsr.s	vsync
		move.w	old_scr,d0
		lea	$ffff8201.w,a0
		movep.w d0,0(a0)

		move	#$2700,sr
		move.l	old70,$70.w
		move	#$2300,sr

		moveq	#$08,d0
		bsr.s	ikbd
		rts

ikbd:		lea	$fffffc00.w,a0
kaeptain_iglo:	btst	#1,(a0)		; bereit ?
		beq.s	kaeptain_iglo
		move.b	d0,2(a0)
		rts

vsync:		sf	vblflag
john_wayne:	tst.b	vblflag
		beq.s	john_wayne
		rts

set_irqs:	move	sr,d7
		move	#$2700,sr
		lea	$fffffa00.w,a0
		move.b	$07(a0),oldmfp07
		move.b	$09(a0),oldmfp09
		move.b	$11(a0),oldmfp11
		move.b	$13(a0),oldmfp13
		move.b	$15(a0),oldmfp15
		move.b	$17(a0),oldmfp17
		move.b	$1b(a0),oldmfp1b
		move.b	$21(a0),oldmfp21
		clr.b	$07(a0)
		clr.b	$09(a0)
		clr.b	$13(a0)
		clr.b	$15(a0)
		move.l	$0120.w,old120

		move.l	#init_vbl,$70.w
		move	#$2300,sr
		move	d7,sr
		rts

restore_irqs:	move	sr,d7
		move	#$2700,sr
		move.l	old120,$0120.w
		lea	$fffffa00.w,a0
		move.b	oldmfp07,$07(a0)
		move.b	oldmfp09,$09(a0)
		move.b	oldmfp11,$11(a0)
		move.b	oldmfp13,$13(a0)
		move.b	oldmfp15,$15(a0)
		move.b	oldmfp17,$17(a0)
		move.b	oldmfp1b,$1b(a0)
		move.b	oldmfp21,$21(a0)
		move	#$2300,sr
		move	d7,sr
		rts

;------------------------------------------------------------------------------

init_vbl:	st	vblflag
		rte

vbl:		move	#$2700,sr
		st	vblflag
		move.b	#2,$ffff820a.w	; [16]	50 Hz
		move.w	hertz_color,$ffff8240.w

		movem.l d0-a6,-(sp)

		jsr	flip_screens
		jsr	choose
		jsr	do_stars

		movea.l logical,a0
		lea	160+230*57(a0),a0
		move.l	a0,output_base1

		movea.l physical,a0
		lea	160+230*57(a0),a0
		move.l	a0,output_base2

		jsr	txt_routine

		lea	logo_pal+2,a0
		lea	$ffff8242.w,a1
		move.w	#14,d0
do_logo_pal:	move.w	(a0)+,(a1)+
		dbra	d0,do_logo_pal


		movea.l x_pos_pntr,a0
		move.w	(a0)+,d0
		cmpi.w	#-1,(a0)
		bne.s	so_was
		lea	x_pos_tab,a0
so_was:		move.l	a0,x_pos_pntr

		move.w	d0,d1
		and.w	#$fff0,d0
		lsr.w	#1,d0
		movea.l physical,a3
		lea	160+460(a3),a3
		adda.l	d0,a3

		and.w	#$0f,d1
		ext.l	d1
		add.l	d1,d1
		add.l	d1,d1
		lea	logos,a2
		movea.l 0(a2,d1.l),a2

		lea	$ffff820a.w,a0	; Sync-Register
		lea	$ffff8260.w,a1	; Auflîsungsregister

		moveq	#0,d0
gerd_mueller:	move.b	$ffff8209.w,d0	; screen low byte
		beq.s	gerd_mueller
		not.w	d0
		lsr.w	d0,d0		; do the 'magic' shit command

		dcb.w 69,$4e71	; magic moment
		clr.w	$ffff8240.w	; normaler Bildschirm hier bitte schwarz


		rept 23
		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		movem.l (a2),d1-d7/a4-a6 ; [92]
		movem.l d1-d7/a4-a6,(a3) ; [88]
		movem.l 40(a2),d1-d7/a4 ; [80]
		movem.l d1-d7/a4,40(a3) ; [76]

		dcb.w 5,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		movem.l 72(a2),d1-d4	; [48]

		dcb.w 13-12,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		movem.l d1-d4,72(a3)	; [44]

;--------------

		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		movem.l 88(a2),d1-d6	; [72]
		movem.l d1-d6,88(a3)	; [68]


		lea	112(a2),a2	; [8]
		lea	230(a3),a3	; [8]

		dcb.w 54,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 11,$4e71
		endr

***************************

		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		move.w	#$0777,$ff8240+2*1 ; [20]
		move.w	#$0440,$ff8240+2*2 ; "
		move.w	#$0444,$ff8240+2*3 ; "

		move.w	#$70,$ff8240+2*4 ; "
		move.w	#$70,$ff8240+2*5 ; "
		move.w	#$70,$ff8240+2*6 ; "
		move.w	#$70,$ff8240+2*7 ; "


		dcb.w 74-20,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		lea	$ffff8240.w,a6	; [8]
		lea	med_pal,a5	; [12]

		dcb.w 6,$4e71


		rept 10
		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		move.w	(a5)+,(a6)	; [12]

		dcb.w 86,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		clr.w	$ffff8240.w	; [16]

		dcb.w 7,$4e71
		endr

***************************

		rept 20
		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		movem.l (a2),d1-d7/a4-a6 ; [92]
		movem.l d1-d7/a4-a6,(a3) ; [88]
		movem.l 40(a2),d1-d7/a4 ; [80]
		movem.l d1-d7/a4,40(a3) ; [76]

		dcb.w 5,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		movem.l 72(a2),d1-d4	; [48]

		dcb.w 13-12,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		movem.l d1-d4,72(a3)	; [44]

;--------------

		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		movem.l 88(a2),d1-d6	; [72]
		movem.l d1-d6,88(a3)	; [68]

		lea	112(a2),a2	; [8]
		lea	230(a3),a3	; [8]

		dcb.w 54,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 11,$4e71
		endr

*******************************

		rept 3
		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 89,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 11,$4e71
		endr



		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		move.w	#0,$ffff8240.w	; [16]

		dcb.w 85,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 11,$4e71



		rept 72
		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 89,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 11,$4e71
		endr



		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		lea	$ffff8240.w,a3	; [8]
		lea	font_pal,a2	; [12]

		rept 8
		move.l	(a2)+,(a3)+	; [20]
		endr

		dcb.w 84-8*5,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		lea	$ffff8240.w,a3	; [8]
		lea	raster_pal,a2	; [12]

		dcb.w 6,$4e71



		rept 25
		nop
		move.w	a1,(a1)		; [8]	Linker Rand
		nop			; [4]
		move.b	d0,(a1)		; [8]

		move.w	(a2)+,(a3)	; [12]

		dcb.w 86,$4e71

		move.b	d0,(a0)		; [8]	Rechter Rand
		move.w	a0,(a0)		; [8]

		dcb.w 13,$4e71

		move.w	a1,(a1)		; [8]	Stabilisator
		nop			; [4]
		move.b	d0,(a1)		; [8]

		dcb.w 11,$4e71
		endr


		move.w	hertz_color(pc),$ffff8240.w
		jsr	shift_left(pc)
		movem.l (sp)+,d0-a6
		move	#$2300,sr
		rts


;------------------------------------------------------------------------------

do_stars:	move.l	#160+230*56,d0
		movea.l logical,a6
		movea.l physical,a5
		adda.l	d0,a5
		adda.l	d0,a6

get_star:	move.w	#$0f,d7
		movea.l star_pntr(pc),a0
		move.w	(a0)+,d0	;x_pos
		move.w	(a0)+,d2	;speed
		move.w	(a0)+,d3	;altes screenbit
		move.w	(a0)+,d4	;alter screen
		move.w	(a0)+,d5	;Farbe (0-3)
		move.w	(a0),star_weg_flag

		move.l	a0,star_pntr	;nÑchste Sternwerte

		sub.w	d2,d0		;abziehen
		cmpi.w	#-1,d0		;schon am linken bildrand ?
		bgt.s	okey		;"
		add.w	#460,d0		;dann wieder 320 Pixel dazu
okey:		move.w	d0,-10(a0)	;neue x_pos sichern
		ext.l	d5
		movea.l a5,a1
		adda.w	d4,a1		;alte screenposition

		move.w	(a1),d4		;punkt wieder lîschen
		bclr	d3,d4
		move.w	d4,(a1)
		move.w	2(a1),d4
		bclr	d3,d4
		move.w	d4,2(a1)


		move.w	d0,d1		;retten
		and.w	#$fff0,d0	;Vielf.von 16
		lsr.w	#1,d0		;"

		move.w	d0,-4(a0)	;screenadr. speichern

		movea.l a6,a1		;screen -
		adda.w	d0,a1		;abschnitt

		and.w	#$0f,d1		;Wert von 0-15
		sub.w	d1,d7		;abziehen von 15

		move.w	d7,-6(a0)	;Bit speichern

		move.w	(a1),d0		; Punkt plotten
		btst	#0,d5
		bne.s	st1
		bclr	d7,d0
		bra.s	no_st1
st1:		bset	d7,d0
no_st1:		move.w	d0,(a1)

		move.w	2(a1),d0
		btst	#1,d5
		bne.s	st2
		bclr	d7,d0
		bra.s	no_st2
st2:		bset	d7,d0
no_st2:		move.w	d0,2(a1)


		lea	230*3(a6),a6	;nÑchsten Stern
		lea	230*3(a5),a5
		cmpi.w	#-1,star_weg_flag ;"
		beq.s	schluss		;"
		bra	get_star	;"
schluss:
		move.l	#star_data,star_pntr
		rts

star_data:
;erklÑrung: 1 Stern braucht 5 words
;----------
;		1.Word) Start X-Pos.
;		2.Word) Speed (nicht 0!, 1-8)
;	3.+4.Word) Save
;		5.Word) Color


		dc.w 100,4,0,0,3
		dc.w 21,2,0,0,2
		dc.w 221,6,0,0,1
		dc.w 71,5,0,0,3
		dc.w 271,1,0,0,3
		dc.w 331,4,0,0,1
		dc.w 31,1,0,0,2

		dc.w 221,1,0,0,3
		dc.w 311,3,0,0,2
		dc.w 301,6,0,0,1
		dc.w 193,4,0,0,3
		dc.w 20,2,0,0,3
		dc.w 222,3,0,0,3
		dc.w 301,1,0,0,2
		dc.w 40,4,0,0,2
		dc.w 50,3,0,0,1
		dc.w 70,1,0,0,1

		dc.w 40,4,0,0,2
		dc.w 50,3,0,0,1

		dc.w 51,5,0,0,3
		dc.w 119,2,0,0,2
		dc.w 91,1,0,0,1
		dc.w 101,4,0,0,1
		dc.w 108,2,0,0,3
		dc.w 105,3,0,0,2
		dc.w 102,5,0,0,2
		dc.w 221,1,0,0,3
		dc.w 311,3,0,0,2
		dc.w 301,6,0,0,1
		dc.w 193,4,0,0,3
		dc.w 20,2,0,0,3
		dc.w 222,3,0,0,3
		dc.w 301,1,0,0,2
		dc.w 40,4,0,0,2
		dc.w 119,2,0,0,2
		dc.w 91,1,0,0,1
		dc.w 101,4,0,0,1
		dc.w 50,3,0,0,1
		dc.w 70,1,0,0,1

		dc.w -1

flip_screens:	move.l	logical,d0
		move.l	physical,logical
		move.l	d0,physical
		move.b	physical+1,$ffff8201.w ; high byte
		move.b	physical+2,$ffff8203.w ; mid byte
		rts

shift_left:	move.w	#24,d0		;um 16 Pixel nach links verschieben
		movea.l logical,a0
		lea	160+230*100(a0),a0
		lea	230*74(a0),a0
sl_1:		movem.l 8(a0),d1-d7/a2-a6
		movem.l d1-d7/a2-a6,(a0)
		movem.l 56(a0),d1-d7/a2-a6
		movem.l d1-d7/a2-a6,48(a0)
		movem.l 104(a0),d1-d7/a2-a6
		movem.l d1-d7/a2-a6,96(a0)
		movem.l 152(a0),d1-d7/a2-a6
		movem.l d1-d7/a2-a6,144(a0)
		movem.l 200(a0),d1-d4
		movem.l d1-d4,192(a0)
		lea	230(a0),a0
		dbra	d0,sl_1
		rts

choose:		movea.l phases_pointer(pc),a0
		movea.l (a0)+,a1
		move.l	a0,phases_pointer
		jmp	(a1)

get_char:	movea.l txt_pointer(pc),a0
		move.b	(a0)+,d0	; neuen Buchstaben holen
		cmpi.b	#-1,(a0)
		bne.s	txt_okey
		lea	txt(pc),a0
txt_okey:	move.l	a0,txt_pointer
		cmpi.b	#32,d0
		bne.s	not_blank
		move.b	#64,d0
		bra.s	fin
not_blank:	cmpi.b	#'!',d0
		bne.s	not_sign
		move.b	#'Z'+1,d0
		bra.s	fin
not_sign:	cmpi.b	#'.',d0
		bne.s	not_dot
		move.b	#'Z'+2,d0
		bra.s	fin
not_dot:	cmpi.b	#'(',d0
		bne.s	not_open
		move.b	#'Z'+3,d0
		bra.s	fin
not_open:	cmpi.b	#')',d0
		bne.s	not_close
		move.b	#'Z'+4,d0
		bra.s	fin
not_close:	cmpi.b	#'?',d0
		bne.s	fin
		move.b	#'Z'+5,d0
fin:		sub.b	#64,d0
		ext.w	d0
		add.w	d0,d0
		add.w	d0,d0
		lea	font_tab(pc),a0
		movea.l 0(a0,d0.w),a0
copy_puffer:	move.w	#24,d0		; Buchstaben in Puffer kopieren
		lea	puffer,a1
cp_1:		movem.l (a0),d1-d4
		movem.l d1-d4,(a1)
		lea	160(a0),a0
		lea	16(a1),a1
		dbra	d0,cp_1
		rts

phase1:		move.w	#24,d0
		movea.l logical,a1
		lea	160+208(a1),a1
		lea	230*100(a1),a1
		lea	230*74(a1),a1
		lea	puffer,a0
ph_1:		movem.l (a0),d1-d2
		movem.l d1-d2,(a1)
		lea	230(a1),a1
		lea	16(a0),a0
		dbra	d0,ph_1
		rts

phase2:		move.w	#24,d0
		movea.l logical,a1
		lea	160+208(a1),a1
		lea	230*100(a1),a1
		lea	230*74(a1),a1
		lea	puffer,a0
ph_2:		move.b	1(a0),(a1)
		move.b	3(a0),2(a1)
		move.b	5(a0),4(a1)
		move.b	7(a0),6(a1)
		move.b	8(a0),1(a1)
		move.b	10(a0),3(a1)
		move.b	12(a0),5(a1)
		move.b	14(a0),7(a1)
		lea	230(a1),a1
		lea	16(a0),a0
		dbra	d0,ph_2
		rts


phase3:		move.w	#24,d0
		movea.l logical,a1
		lea	160+208(a1),a1
		lea	230*100(a1),a1
		lea	230*74(a1),a1
		lea	puffer,a0
ph_3:		movem.l 8(a0),d1-d2
		movem.l d1-d2,(a1)
		lea	230(a1),a1
		lea	16(a0),a0
		dbra	d0,ph_3
		rts

phase4:		move.w	#24,d0
		movea.l logical,a1
		lea	160+208(a1),a1
		lea	230*100(a1),a1
		lea	230*74(a1),a1

		movea.l a1,a2
		lea	puffer,a0
ph_4:		move.b	9(a0),(a1)
		move.b	11(a0),2(a1)
		move.b	13(a0),4(a1)
		move.b	15(a0),6(a1)
		lea	230(a1),a1
		lea	16(a0),a0
		dbra	d0,ph_4

		bsr	get_char	; neuen Char holen & Puffer vorbereiten
		lea	puffer,a0
		move.w	#24,d0
ph_4l2:		move.b	(a0),1(a2)	; linkes Byte des neuen Buchstaben ins
		move.b	2(a0),3(a2)	; letzte rechte Screenbyte kopieren
		move.b	4(a0),5(a2)
		move.b	6(a0),7(a2)
		lea	230(a2),a2
		lea	16(a0),a0
		dbra	d0,ph_4l2
		move.l	#phases,phases_pointer ; von vorne scrollen
		rts

txt_routine:	subq.w	#1,pause
		cmpi.w	#-1,pause
		bne	kein_buchstabe
		clr.w	pause

		addq.w	#1,verzîgerer
		cmpi.w	#1,verzîgerer
		bne	kein_buchstabe
		clr.w	verzîgerer
get_one_char:	movea.l output_pntr(pc),a0
		move.b	(a0)+,d0
		bne.s	still_coming
		movea.l output_base1(pc),a0
		move.l	a0,output_address1
		movea.l output_base2(pc),a0
		move.l	a0,output_address2
		move.l	#output_text,output_pntr
		clr.w	x
		bra	kein_buchstabe
still_coming:	move.l	a0,output_pntr
		cmpi.b	#13,d0
		bne.s	mach_weiter
		addi.l	#230*9,output_address1
		addi.l	#230*9,output_address2
		clr.w	x
		bra	kein_buchstabe
mach_weiter:	cmpi.b	#10,d0
		bne.s	okey_do_key
		clr.w	x
		movea.l output_base1(pc),a0
		move.l	a0,output_address1
		movea.l output_base2(pc),a0
		move.l	a0,output_address2
		bra	kein_buchstabe
okey_do_key:	cmpi.b	#1,d0
		bne.s	well_done
		move.w	#1000,pause
		bra	kein_buchstabe
well_done:	sub.b	#$20,d0
		ext.l	d0
		add.l	d0,d0
		add.l	d0,d0
		lea	char_tab(pc),a0
		movea.l 0(a0,d0.l),a0
		movea.l output_address1(pc),a1
		movea.l output_address2(pc),a2
		move.w	x(pc),d0
		btst	#0,d0
		beq.s	keep_it
		addq.l	#1,a1
		addq.l	#1,a2
keep_it:	andi.w	#-2,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	0(a1,d0.w),a1
		lea	0(a2,d0.w),a2
		rept 8
		move.b	(a0),4(a2)
		move.b	(a0)+,4(a1)
		lea	230(a1),a1
		lea	230(a2),a2
		endr
		addq.w	#1,x
kein_buchstabe: rts

;-------------------------------------------------------------------------------

		data


font_tab:	dc.l font+16*0
		dc.l font+16*1
		dc.l font+16*2
		dc.l font+16*3
		dc.l font+16*4
		dc.l font+16*5
		dc.l font+16*6
		dc.l font+16*7
		dc.l font+16*8
		dc.l font+16*9
		dc.l font+160*26+16*0
		dc.l font+160*26+16*1
		dc.l font+160*26+16*2
		dc.l font+160*26+16*3
		dc.l font+160*26+16*4
		dc.l font+160*26+16*5
		dc.l font+160*26+16*6
		dc.l font+160*26+16*7
		dc.l font+160*26+16*8
		dc.l font+160*26+16*9
		dc.l font+160*52+16*0
		dc.l font+160*52+16*1
		dc.l font+160*52+16*2
		dc.l font+160*52+16*3
		dc.l font+160*52+16*4
		dc.l font+160*52+16*5
		dc.l font+160*52+16*6
		dc.l font+160*52+16*7
		dc.l font+160*52+16*8
		dc.l font+160*52+16*9
		dc.l font+160*78+16*0
		dc.l font+160*78+16*1
		dc.l font+160*78+16*2

char_tab:	dc.l font2+0*8,font2+1*8,font2+2*8,font2+3*8,font2+4*8,font2+5*8
		dc.l font2+6*8,font2+7*8,font2+8*8,font2+9*8,font2+10*8,font2+11*8
		dc.l font2+12*8,font2+13*8,font2+14*8,font2+15*8,font2+16*8,font2+17*8
		dc.l font2+18*8,font2+19*8,font2+20*8,font2+21*8,font2+22*8,font2+23*8
		dc.l font2+24*8,font2+25*8,font2+26*8,font2+27*8,font2+28*8,font2+29*8
		dc.l font2+30*8,font2+31*8,font2+32*8,font2+33*8,font2+34*8,font2+35*8
		dc.l font2+36*8,font2+37*8,font2+38*8,font2+39*8
		dc.l font2+40*8,font2+41*8,font2+42*8,font2+43*8,font2+44*8,font2+45*8
		dc.l font2+46*8,font2+47*8,font2+48*8,font2+49*8,font2+50*8,font2+51*8
		dc.l font2+52*8,font2+53*8,font2+54*8,font2+55*8,font2+56*8,font2+57*8
		dc.l font2+58*8,font2+59*8

logo_tab:	dc.l logos+4
logos:		dc.l logo0,logo1,logo2,logo3,logo4,logo5,logo6,logo7,logo8
		dc.l logo9,logo10,logo11,logo12,logo13,logo14,logo15

output_base1:	dc.l 0
output_address1:dc.l 0
output_base2:	dc.l 0
output_address2:dc.l 0

output_pntr:	dc.l output_text

txt_pointer:	dc.l txt
star_pntr:	dc.l star_data

phases_pointer: dc.l phases
phases:		dc.l phase1,phase2,phase3,phase4
x_pos_pntr:	dc.l x_pos_tab

x_pos_tab:	dc.w 1,1,1,1,1,2,2,2,2,3,3,3,4,4,5,6,7,8,9,10
		dc.w 12,14,16,18,20,22,24,26,28,30
		dc.w 33,36,39,42,45,48,51
		dc.w 55,59,63,67,71,75,79,83,87,91
		dc.w 96,101,106,111,116
		dc.w 110+10,114+10,118+10,122+10,126+10,130+10,134+10,138+10,142+10,146+10
		dc.w 149+10,152+10,155+10,158+10,161+10,164+10,167+10
		dc.w 169+10,171+10,173+10,175+10,177+10,179+10,181+10,183+10,185+10,187+10
		dc.w 188+10,189+10,190+10,191+10,192+10,193+10
		dc.w 194+10,194+10,195+10,195+10,195+10,196+10,196+10,196+10,196+10,197+10,197+10,197+10,197+10,197+10
		dc.w 196+10,196+10,196+10,196+10,195+10,195+10,195+10,194+10,194+10
		dc.w 203,202,201,200,199,198
		dc.w 197,195,193,191,189,187,185,183,181,179
		dc.w 177,174,171,168,165,162,159
		dc.w 156,152,148,144,140,136,132,128,124,120
		dc.w 116,111,106,101,96
		dc.w 91,87,83,79,75,71,67,63,59,55
		dc.w 51,48,45,42,39,36,33
		dc.w 30,28,26,24,22,20,18,16,14,12,10
		dc.w 9,8,7,6,5,4,4,3,3,3,2,2,2,2
		dc.w -1

star_weg_flag:	dc.w 0
pause:		dc.w 0
verzîgerer:	dc.w 0
hin:		dc.w 1
x:		dc.w 0
x_pos:		dc.w 0

hertz_color:	dc.w $00
med_pal:	dc.w $0110,$0220,$0330,$0440,$0550,$0550,$0440,$0330,$0220,$0110
raster_pal:	dc.w $0100,$0200,$0300,$0400,$0500,$0600,$0700
		dc.w $0701,$0702,$0703,$0704,$0705,$0706,$0707,$0706
		dc.w $0703,$0702,$0701,$0700,$0600,$0500,$0400,$0300,$0200,$0100
font_pal:	dc.w $00,$02,$03,$04,$05,$07,$0237,$0247
		dc.w $0257,$0367,$0577,$0677,$0400,$70,$00,$0777
logo_pal:	dc.w $00,$0111,$0333,$0555,$0777,$0711,$0721,$0631
		dc.w $0641,$0551,$0224,$0324,$0415,$0515,$0706,$0777


;--- Scroller
txt:
;		ERLAUBT: A-Z !?. ()           (MEHR NICHT !!!) bei Ende -1
		dc.b "                     OOHH YEAHH !!!                  "
                dc.b "    HEY GUYS !!!   HERE IS  STAX COMPACT MENU"
		dc.b " NUMBER THIRTY EIGHT  BROUGHT TO YOU BY  MATT  !!!     "
		dc.b " READ THE UPPER TEXT DISPLAY FOR SOME CLSOE INFORMATION"
		dc.b " ABOUT THE STYLE OF THIS MENU.... YOU CANNOT CHOOSE"
		dc.b " YOUR PROGRAMS FROM THIS SELECTOR SO READ ABOVE FOR THE"
		dc.b " REASONS.......                             "
		dc.b " THIS MENU INCLUDES A LITTLE BIT OF EVERYTHING....     "
		dc.b " SO SIMPLY RIGHT FOR YOU... I THINK !!!   THE GFA DEMO"
		dc.b " MUST BE LOADED FROM THE BOOTSEKTOR BECAUSE THE AUTHORS"
		dc.b " (THE GIANTS) DO NOT WANNA SEE IT IN ANOTHER WAY... SO"
		dc.b " WE ARE NICE AND WILL NOT CHANGE ANYTHING !!!    "
		dc.b " THE SPEEDPACKER SHOULD BE THE LATEST VERSION I HOPE..."
		dc.b " ANYWAY I NEVER SAW A FORMER ONE SO I AM NOT QUITE SURE"
		dc.b " IF IT IS NEW OR NOT BUT WHO CARES ABOUT THIS !!!???    "
		dc.b " LOOK FOR YOURSELF WHATS UP WITH THE REST...   IF YOU"
		dc.b " WANNA TRADE LOADSA PD STUFF THEN CONTACT THE  FREE PD"
		dc.b " AND SHAREWARE SOCIETY  WHICH ADDRESSES CAN BE FOUND ON"
		dc.b " THIS DISK WHEN LOADING THE ADVERT PROGRAM...        "
		dc.b " I HOPE YOU ALL HAVE RECOGNICED THAT WE WILL NEVER DO"
		dc.b " AGAIN ANY INTRO COMPIL MENUS OR SOMETHING LIKE THIS..."
		dc.b " BASICALLY WE HAVE NOT EVER REALLY BUT SOME GUYS LIKE"
		dc.b " IT SO MUCH THAT WE WERE NEARLY FORCED TO DO SO BUT"
		dc.b " FINALLY WE KEPT STRONG AND OF COURSE WE KEPT OURSELFES !!!"
		dc.b " ON FURTHER STAX COMPACT DISKS THERE WILL ONLY APPEAR"
		dc.b " WORTHWHILE PD STUFF AND NO SHIT AT ALL !!!    THIS MENU"
		dc.b " SPARES OF COURSE SOME DISKS SO IF YOU ARE NOT A FANATIC"
		dc.b " COLLECTOR OF EVERYTHING IT MAY BE USEFUL FOR YOU...  "
		dc.b " OTHERWISE YOU WILL SURELY HAVE SEEN THE ONE OR OTHER"
		dc.b " PROGRAM OF THIS DISK ALREADY SOMEWHERE BEFORE AND IT IS"
		dc.b " YOUR DECISION TO KEEP THIS DISK OR NOT.........         "
		dc.b " WELL WELL...  WE ARE ACTUALLY WORKING ON OUR SECOND BIG"
		dc.b " DEMO WHICH WILL BE SOMETHING BETWEEN A MEGA DEMO AND A"
		dc.b " DENTRO....  SO MAYBE JUST CALL IT  MEGA DENTRO  !!!    "
		dc.b " I DO NOT KNOW WHEN IT WILL BE RELEASED FINALLY AND I"
		dc.b " CANNOT OVERVIEW THE WHOLE PROJECT VERY GOOD TOO BECAUSE"
		dc.b " I DO NOT SO MUCH WORK FOR IT !!!  MOSTLY IT IS DESIGNED"
		dc.b " BY MIKE BUT I CAN TELL YOU HE IS ALREADY WORKING AS HARD"
		dc.b " AS HE CAN SO IT HOPEFULLY DOES NOT TAKE A SO LONG TIME"
		dc.b " ANYMORE....   BY THE WAY.. WE ARE  S T I L L  LOOKING FOR"
		dc.b " NEW MEMBERS WHO WANNA JOIN US... ESPECIALLY NEW CODERS"
		dc.b "  GRAPHISTS  AND  MUSICIANS !!!   DO NOT HESITADE IF YOU"
		dc.b " WANNA CONTACT US... WE ARE GLAD ABOUT YOUR MEMBERCHIP"
		dc.b " SO DO NOT WAIT ANY LONGER....  WRITE US !!!              "
		dc.b " WELL DONE... YOU NOW WILL LIKELY READ SOME GREETINGS.. SO"
		dc.b " HERE WE GO.......  VERY SPECIAL GREETINGS ARE SEND TO"
		dc.b " FOLLOWING TOP CONTACTS AND FRIENDS............           "
		dc.b " TEE PAU FROM HAMBURG (MOIN MOIN MOIN...)     CARNERA OF"
		dc.b " N.P.G.     JON OF BREAKPOINT SOFTWARE     DARREN OF"
		dc.b " INCOME P.D.     TTK     THE ADMIRABLES (ESP. NIRVANA"
		dc.b " AND STURM)     ACE PD (ESP. THOMAS)     D.B.A."
		dc.b " (ESP. MR.COOL  DIZZY  AND  BONUS !!!  GREAT MAG NUMBER"
		dc.b " SEVEN OVERALL !!!!)     TESLA UNIT (ESP. LEAD BALLOON.."
		dc.b ". HEY GUY... ARE YOU ALIVE ???)     BAD BOYS BELGIUM"
		dc.b " (HI LITTLY GUY !!! BEST GREETS FROM TYAN !!!)"
		dc.b "     MC FLY (I THINK THE NEW  MEGADETH  IS NOT SO GOOD"
		dc.b " EXCEPT FOR ONE TRACK !!!  INCREDIBLE ???   THANX ANYWAY"
		dc.b " FOR THE NEW LOGO EVEN I HAVE NOT SEEN IT YET BUT SODAN"
		dc.b " THINKS IT IS AMAZING.......)     THE FOX (HEY GUY...."
		dc.b " HAVE NOT HEARD ANYTHING FROM YOU SINCE AGES ???  HAVE"
		dc.b " YOU SOLD YOUR ST OR WHAT IS UP TO YOU ???  PLEASE"
		dc.b " CALL ME (MATT) IF YOU READ THIS !!!)    "
		dc.b " THE TECHNO GANGSTERS (HI DOMINATOR !!!  MANY THANX FOR"
		dc.b " THIS NICE LOGO !!!)     CAPE CITY OF MEGA WANX (THANX"
		dc.b " FOR THE SMALL FONT GUY !!!)     SNK OF PURE ENERGY"
		dc.b " (THANX FOR ALL MUSICS MY FRIEND !!!)                 "
		dc.b "                  FURTHER GREETINGS GO TO ALL OTHER"
		dc.b " OF OUR CONTACTS ALL AROUND...  IF YOU WERE NOT MENTIONED"
		dc.b " THEN GO AND SEND US A QUICK NOTE AND YOUR NAME WILL"
		dc.b " SCROLL THROUGH THE GREETS THE NEXT TIME ............   "
		dc.b " IT IS NOW THIRTY MINUTES TO NINE IN THE EVENING AND"
		dc.b " I KNOW I HAVE LOADSA OTHER THINGS TO DO ALSO.... SO LET"
		dc.b " US COME TO AN END SLOWELY !!!     BEST REGARDS FROM MATT"
		dc.b " AND SEE YA LATER............   WRAP!                   "
		dc.b "						              "

		dc.b " "




		dc.b "                                           "
		dc.b -1
;-------------------------------------------------------------------------------

output_text:
;		ZUSéTZE:13 = NEUE ZEILE ANFANGEN (PRO ZEILE MAX. 52 ZEICHEN)
;			10 = CURSOR AUF AUSGANGSPOSITION,DER REST WIRD GELôSCHT
;			0 = ENDKENNUNG !!! NICHT VERGESSEN !!!!
;			auf einmal nur immer 12 Zeilen !!!
;			------------------------------------

;		dc.b "                                                     ",13
		dc.b "-----------------------------------------------------",13
		dc.b "       ... WELCOME TO STAX COMPACT DISK 38 ...       ",13
		dc.b "        ... RELEASED ON 22.1.1993 BY MATT ...        ",13
		dc.b "-----------------------------------------------------",13,13
		dc.b "        THIS NEW MENU INCLUDES THE FOLLOWING..       ",13,13
		dc.b "            THUNDERBIRDS SPEED PACKER V3.0           ",13
		dc.b "                SOCIETY ADVERTISMENT                 ",13
		dc.b "                    DRAGONS TOWER                    ",13
		dc.b "               LOOK WHO IS CODING TOO                ",1,10

		rept 13
		dc.b "                                                    ",13
		endr
		dc.b " ",10

		dc.b "   TO LOAD ALL THE PROGRAMS YOU HAVE TO LOAD A      ",13
		dc.b "   DESKTOP FROM ANY OTHER DISK....  THIS LOADER     ",13
		dc.b "   DOES NOT LOAD EACH OF THAT THREE PROGRAMS        ",13
		dc.b "   CORRECTLY SO WE HAD NO OTHER CHOICE THEN TO DO   ",13
		dc.b "   IT IN THIS WAY !!!   WE ARE SORRY FOR THIS       ",13
		dc.b "      BUT YOU WILL UNDERSTAND THIS I HOPE !!!       ",13,1,10
		rept 8
		dc.b "                                                    ",13
		endr
		dc.b " ",10



		dc.b "     IF YOU WANNA JOIN US AS A NEW CODER,ARTIST,     ",13
		dc.b "  MUSICIAN OR SWAPPER/PACKER/CD MAKER THEN JUST GET  ",13
		dc.b "    IN CONTACT WITH US AS FAST AS POSSIBLE !!!       ",13,13
		dc.b "   THE ADDRESS FOR THIS AND ANYTHING ELSE IS...      ",13,13
		dc.b "             CHRISTOPHER KROTER / TYAN               ",13
		dc.b "               WALDENBURGERSTRASSE 6                 ",13
		dc.b "                 2406 STOCKELSDORF                   ",13
		dc.b "                      GERMANY                        ",13,13
		dc.b "   DO NOT WRITE TO ANY OTHER ADDRESS TO CONTACT US   ",13
		dc.b "   BECAUSE WE WILL CLOSE ALL OUR BOXES VERY SOON..   ",10,1

		rept 13
		dc.b "                                                    ",13
		endr
		dc.b " ",10

		dc.b "          CREDITS FOR THIS NEW MENU PROGRAM          ",13
		dc.b "-----------------------------------------------------",13
		dc.b "    CODE AND DESIGN ................ MATT OF STAX    ",13
		dc.b "        SCROLL FONT ................ MIKE OF STAX    ",13
		dc.b "-----------------------------------------------------",13
		dc.b "    SPECIAL THANX FOR EXTERNAL CONTRIBUTIONS GO TO   ",13
		dc.b "-----------------------------------------------------",13
		dc.b "           STAXLOGO ................ DOMINATOR OF    ",13
		dc.b "                             THE TECHNO GANGSTERS    ",13
		dc.b "          THIS FONT ...... CAPE-CITY OF MEGA-WANX    ",13
		dc.b "    EXCELLENT MUSIC .......... SNK OF PURE ENERGY    ",13,13
		dc.b "     THANX A LOT TO ALL OF YOU ... KEEP IT ON !!!    ",1,10

		rept 13
		dc.b "                                                    ",13
		endr
		dc.b " ",10

		dc.b 0          ; ENDKENNUNG
		even


;------------------------------------------------------------------------------

font:           incbin 'BLUEFONT.DAT'
                even
sound:          incbin 'MINDBEND.THK'
                even
logo:           incbin 'TTG_LOGO.DAT'
                even


                bss

physical:       ds.l 1
logical:        ds.l 1
old70:          ds.l 1
old120:         ds.l 1
old_pal:        ds.w 16
old_scr:        ds.w 1
scanlines:      ds.w 1
oldmfp07:       ds.b 1
oldmfp09:       ds.b 1
oldmfp11:       ds.b 1
oldmfp13:       ds.b 1
oldmfp15:       ds.b 1
oldmfp17:       ds.b 1
oldmfp1b:       ds.b 1
oldmfp21:       ds.b 1
old_res:        ds.b 1
old_sync:       ds.b 1
vblflag:        ds.b 1
                even

logo0:          ds.b 43*112
logo1:          ds.b 43*112
logo2:          ds.b 43*112
logo3:          ds.b 43*112
logo4:          ds.b 43*112
logo5:          ds.b 43*112
logo6:          ds.b 43*112
logo7:          ds.b 43*112
logo8:          ds.b 43*112
logo9:          ds.b 43*112
logo10:         ds.b 43*112
logo11:         ds.b 43*112
logo12:         ds.b 43*112
logo13:         ds.b 43*112
logo14:         ds.b 43*112
logo15:         ds.b 43*112
                even

puffer:         ds.b 400

                ds.b 256
screen_ram:     ds.b 230*200+160
                ds.b 230*200
                ds.b 230*200+160 ; 2 normale Zeilen sicherheitshalber weg !!!
                end
