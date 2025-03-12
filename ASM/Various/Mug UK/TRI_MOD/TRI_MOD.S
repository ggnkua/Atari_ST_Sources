;
; Tri-Mod Music Driver
;
; Music hacked by: MUG U.K
;
; Released on "Makin' Sweet Music Volume II' - 30/8/1992
;

	opt	o+,d+,s-

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70

	lea	text(pc),a0	
	bsr	print
	move.b	#12,$fffffc02.w

start	moveq	#1,d0	;0 = allows disk access / 1 = no access
	bsr.s	play

wait	move.b	$fffc02,d0
try_sp	cmpi.b	#$39,d0
	bne.s	wait

	bsr.s	stop
	move.b	#8,$fffffc02.w

exit	move.l	old_70,$70.w
	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

play	cmp.l	#2,d0
	bge.s	exitpl
	bclr	#0,$484.w
	jsr	music
	move.l	#new_70,$70.w
exitpl	rts

stop	moveq	#0,d0
	jsr	music+2
;	bset	#0,$484.w
	rts

new_70	movem.l	d0-d7/a0-a6,-(sp)
; 	move.w	#$700,$ffff8240.w
	jsr	music+6
;	move.w	#$777,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

text	dc.b	$1b,"E"
	dc.b	"+----------------------------------+",13,10
	dc.b	"| 'Tri-Mod' Music by TSC & Synergy |",13,10
	dc.b	"| -------------------------------- |",13,10
	dc.b	"|                                  |",13,10
	dc.b	"| The music inside this folder were|",13,10
	dc.b	"| all composed using the ancient   |",13,10
	dc.b	"| Insignia Tri-Sound Sequencer and |",13,10
	dc.b	"| then the program 'Tri-Mod' by    |",13,10
	dc.b	"| Sentry was used to convert the   |",13,10
	dc.b	"| voice-set and pattern data into  |",13,10
	dc.b	"| one single file along with a fast|",13,10
	dc.b	"| play routine.                    |",13,10
	dc.b	"|                                  |",13,10
	dc.b	"+----------------------------------+",13,10,10
	dc.b	"Music ripped by MUG U.K",$bf,13,10,10
	dc.b	"Space to exit.",13,10
	dc.b	0

old_sp	ds.l	1
old_70	ds.l	1

music	incbin "elite_1.mus"
m_end

; "Crusaders" Music Rips by MUG U.K
; ---------------------------------
;

; ELITE_1.MUS \
; ELITE_2.MUS  >- All composed by Synergy Software Developments
; SYNERGY.MUS /

; TSC_60.MUS \
; TSC_65.MUS  \ These tunes were ripped from the various menus done by
; TSC_79.MUS  / The Syndicate.  Thanks to Animal Mine for supplying them !!
; TSC_82.MUS /

; If you use these music rips in your intros, demos, programs or whatever -
; please credit me and not yourself (believe me, I've seen it !!) !!

; MUG U.K - 30/8/1992
