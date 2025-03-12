;
; No-Click Bootsector by MUG U.K - 18/12/2005
; -------------------------------------------
;


	opt p+,o+,d-,s-

color	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

print	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	#$50000,d1	; slight pause
pause	subq.l	#1,d1 
	bne.s	pause

load	move.w	#$777,$ff8240	; reset palette
	move.w	#$000,$ff825e
	

	bclr	#0,$484.w
exit	rts


text	dc.b "MUG U.K(tm)'s No-Click Bootsector",$d,$a
	dc.b "----------------------------------",$d,$a
	dc.b "Done: 18th Dec. 2005",$d,$a,$d,$a
	dc.b $d,$a
	dc.b "Greetings to:",$d,$a,$d,$a
	dc.b "Everyone on www.atari-forum.com",$d,$a
	dc.b $d,$a
	dc.b $d,$a
	dc.b "Key-click disabled!",$d,$a

	dc.b 0

; this is to pad out the bootsector.  If I assemble the
; bootsector without my installer, it needs to be 480 bytes
; exactly.

blanks	ds.b	245
