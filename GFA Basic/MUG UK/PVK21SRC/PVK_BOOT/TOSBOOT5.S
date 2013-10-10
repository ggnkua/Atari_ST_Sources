;
; Which TOS ? bootsector
; ----------------------
;
; Coded by:  Mike Mee - 13/10/1991
;
;         v1.0 - 13/10/1991 for PVK v2.1
; Text Changes - 12/11/1991 for PVK v2.1

	opt	p+

buffcode
	bra.s	start
	dc.b	"Coded by: Mike Mee - 13/10/1991",0

start	lea	oldpal(pc),a1
	move.w	$ff8240,(a1)+
	move.w	$ff825e,(a1)+
	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

	lea	mug_mes(pc),a2	Who wrote this masterpiece ??
	bsr.s	print

	move.l	$4f2.w,a0		get system base address
	move.l	$14(a0),a1	sysbase+$14 = pointer to magic no.

* should be 'magic' number #$87654321 in (A1). This should be tested
* to confirm that we have a valid sys_base. Assume ok.

	cmp.l	#$87654321,(a1)		check Magic Number
	bne.s	tos99			No Magic Number found !!

	move.w	2(a0),d0		sysbase +2 = TOS version no.
	cmp.w	#$100,d0		TOS v1.0 (1986)
	beq.s	tos1
	cmp.w	#$102,d0		TOS v1.2 (1987 +/- blitter)
	beq.s	tos2
	cmp.w	#$104,d0		TOS v1.4 (1988)
	beq.s	tos3
	cmp.w	#$106,d0		TOS v1.6 (STE - Rainbow TOS)
	beq.s	tos4
	cmp.w	#$162,d0		TOS v1.62 (STE - Bugfixed !!)
	beq.s	tos5

	bra.s	tos99			Unknown TOS ???

tos1	lea	tos_v1(pc),a2
	bra.s	cont
tos2	lea	tos_v2(pc),a2
	bra.s	cont
tos3	lea	tos_v3(pc),a2
	bra.s	cont
tos4	lea	tos_v4(pc),a2
	bra.s	cont
tos5	lea	tos_v5(pc),a2
	bra.s	cont
tos99	lea	tos_99(pc),a2

cont	bsr.s	print

end_bit	lea	endtext(pc),a2
	bsr.s	print

exit	
	move.l	#$50000,d1	; slight pause
pause	subq.l	#1,d1 
	bne.s	pause

	lea	oldpal(pc),a1
	move.w	(a1)+,$ff8240
	move.w	(a1)+,$ff825e
	rts

print	pea	(a2)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
	
mug_mes	dc.b	27,69,27,89,32,39
	dc.b	"'Which TOS ?' by Mike Mee",27,89,33,39
	dc.b	"-------------------------",27,89,36,41
	dc.b	"TOS Version: ",0

tos_v1	dc.b	"1.0  (1985)",0
tos_v2	dc.b	"1.2  (1987)",0
tos_v3	dc.b	"1.4  (1989)",0
tos_v4	dc.b	"1.6  (STE!)",0
tos_v5	dc.b	"1.62 (STE!)",0

tos_99	dc.b	"Unknown !!",0

endtext	dc.b	27,89,54,33
	dc.b	"Bootsector installed using 'PVK",191," v2.1' ",13,10
	dc.b	0

oldpal	ds.w	2

blanks	ds.w	37