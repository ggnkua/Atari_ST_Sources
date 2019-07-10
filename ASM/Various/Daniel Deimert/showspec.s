; showspec.s (1989-09-18)
;
; WRITTEN BY
;	Daniel Deimert (daniel@hexagon.pkmab.se)
;	Mail: Fridstavaegen 4, S-715 94 Odensbacken, Sweden
;	Phone: +46 19 52037
;
; DESCRIPTION
;	Displays Spectrum 512 pictures in 50 or 60 Hz
;	Source is for DEVPAC 2, but can probably be used with any
;	other assembler as well without to many changes.
;
; DISCLAIMER
;	This is not written in clean code. 
;
; PLEASE
;	do give me some credits if you use this source in your
;	own programs.

program_start:
	pea	0
	move.w	#$20,-(sp)	; supervisor mode
	trap	#1
	addq.l	#6,sp

	move.w	#-1,-(sp)
	pea	$78000		; watch out!
	pea	$78000
	move.w	#5,-(sp)	; setscreen
	trap	#14
	add.l	#12,sp
	
	move.b	#$12,$fffffc02.w

	bsr start		; display
l:
	cmp.b	#$39+$80,$fffffc02.w	; space? (bit 7 == released)
	bne.s	l

	bsr stop
	illegal			; die fast
		
start:				; quick setup
	move.b #$fc,$ffff8260.w
	move.b #7,$ffff8201.w
	lea picture,a0
	lea $78000,a1
	move.w #8000,d0
loop1:
	move.l (a0)+,(a1)+
	subq.w #1,d0
	bne loop1
	move.l #vbl,$4d2	; install vbl-routine (be aware!)
	rts

stop:				; we have had our fun
	move.l #0,$4d2
	move.w #$777,$ffff8240.w
	move.b #$f,$ffff8201.w
	move.b #$fd,$ffff8260.w
	rts


vbl:				; this is where the hard work is done
	movem.l a0-a6/d0-d7,-(sp)
	move.w #$2700,sr	; don't be friendly to others :-)
	lea $ffff8240.w,a5
	lea picture+32000,a4	; a4 -> palettes
	move.w #198,d7
	lea $ffff8209.w,a3
test:				; sync
	tst.b (a3)
	beq test
	moveq #0,d0
	move.b (a3),d0
	lea jump,a3
	add.l d0,a3
	jmp (a3)
jump:				; 77 nops
	rept 77
	dc.w $4e71
	endr
loop:
;	nop			; add this little nop for 50 hz
	lea 2(a5),a0
	lea (a5),a1
	lea (a5),a2
	lea 2(a4),a4
	move.w (a4)+,(a0)+	; this is just a lot of moves
	rept 7
	dc.w $20dc
	endr
	rept 8
	dc.w $22dc
	endr
	rept 8
	dc.w $24dc
	endr

	dbra d7,loop
	movem.l (sp)+,a0-a6/d0-d7
	move.w #$2300,sr
	rts

picture:
;
; just include your favourite spectrum picture file here at this label,
; or read it in with rb (?) if you're using K-SEKA.
;
; NOTE
;   The picture has to be saved in UNCOMPRESSED ("raw") format.
;   These files usually has a .SPU extension.
;
	incbin "\bilder\profile.spu"
