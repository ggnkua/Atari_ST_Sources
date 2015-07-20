;
; Floppy Drive Boot Selector v1.0
; -------------------------------
;
; Coded by: Mike Mee
;
; v1.0 - 21/02/1991 - Drives A:\ & B:\
;

	opt	p+,o+,d-,s-

buffcode
	bra.s	start
	dc.b	"Coded by: Mike Mee - 10/10/1991",0

start	lea	oldpal(pc),a1
	move.w	$ff8240,(a1)+	; store palette
	move.w	$ff825e,(a1)+
	move.w	#$007,$ff8240
	move.w	#$777,$ff825e

print	pea	mess(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp	; correct stack

keytest	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp	; correct stack
	swap	d0
	
work_out	cmpi.b	#$1e,d0	; 'a' key
	bne.s	checkb
	move.w	#0,$446.w
	bra.s	doboot

checkb	cmpi.b	#$30,d0	; 'b' key
	bne.s	exit
	move.w	#1,$446.w

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

;
; Data stuff follows
;      
mess	dc.b	27,69
	dc.b	"    Floppy Boot Drive Selector v1.0",13,10
	dc.b	"    -------------------------------",13,10,10,10
	dc.b	"               Press:-",13,10,10,10,10
	dc.b	"          A = Boot Drive A:\",13,10,10,10
	dc.b	"          B = Boot Drive B:\",13,10,10,10
	dc.b	"  Any Other = Neither option"
	dc.b	27,89,55,40
	dc.b	"Installed with PVK",$bf," v2.1",0
	even

oldpal	ds.w	2
blanks	ds.w	56