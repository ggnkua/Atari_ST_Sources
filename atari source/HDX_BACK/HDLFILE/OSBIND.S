;
;	ostraps.s	trap calls for GEMDOS,BIOS & XBIOS
;
	.text
	.globl	_gemdos
	.globl	_bios
	.globl	_xbios


;
;	trap14	Taken straight from the hitchhikers guide
;
_xbios:
	move.l	(sp)+,saveret	;pop return address
	trap	#14
	move.l	saveret,-(sp)	;restore return address
	rts

;
;	trap13	Virtually identical to trap14
;
_bios:
	move.l	(sp)+,saveret	;pop return address
	trap	#13
	move.l	saveret,-(sp)	;restore return address
	rts

;
;	trap1	Virtually identical to trap13
;
_gemdos:
	move.l	(sp)+,saveret	;pop return address
	trap	#1
	move.l	saveret,-(sp)	;restore return address
	rts

	.bss
saveret:
	.ds.l	1		;storage for return address

	.end
