;
; Floppy Drive Boot Selector v1.1
; -------------------------------
;
; Coded by: Mike Mee
;
; v1.0 - 21/02/1991 - Drives A:\ & B:\
; v1.1 - 14/10/1991 - Drives A:\, B:\ & C:\ + code optimised !!
; Fixed - 05/12/1991 - Try and find some bugs now, Steve !!

	opt	p+

buffcode
	bra.s	start
	dc.b	"Coded by: Mike Mee - 14/10/1991",0

start	lea	oldpal(pc),a1
	move.w	$ff8240,(a1)+	; store palette
	move.w	$ff825e,(a1)+
	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

print	pea	mess(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp	; correct stack

keytest	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp	; correct stack
	swap	d0
	
work_out	cmpi.b	#$1e,d0	; 'a' key
	bne.s	checkb
	move.w	#0,$446
	bra.s	doboot

checkb	cmpi.b	#$30,d0	; 'b' key
	bne.s	checkc
	move.w	#1,$446
	bra.s	doboot

checkc	cmpi.b	#$2e,d0	; 'c' key
	bne.s	exit
	move.w	#2,$446

;	bne.s	exit	; Anything else

;bootc	move.w	#2,$446
;	bra.s	doboot
	
;bootb	move.w	#1,$446
;	bra.s	doboot
	
;boota	move.w	#0,$446
	
;
; Set Drive & Hard-Reset
;
;doboot	move.l	#$752019f3,$420.w
doboot	move.l	$4.w,a0
	jmp	(a0)
;
; Exit bootsector
;	
exit	lea	oldpal(pc),a1
	move.w	(a1)+,$ff8240	; restore palette
	move.w	(a1)+,$ff825e
	rts
	even
;
; Data stuff follows
;      
mess	dc.b	27,69
	dc.b	27,89,32,40,"Boot Drive Selector v1.1"
	dc.b	27,89,33,40,"------------------------"
	dc.b	27,89,36,49,"Press:-"
	dc.b	27,89,40,44,"A = Boot Drive A:\"
	dc.b	27,89,42,44,"B = Boot Drive B:\"
	dc.b	27,89,44,44,"C = Boot Drive C:\"
	dc.b	27,89,46,36,"Any Other = Normal Boot"
	dc.b	27,89,55,40
	dc.b	"Installed with PVK",$bf," v2.1",0

	even

oldpal	ds.w	2
blanks	ds.w	63