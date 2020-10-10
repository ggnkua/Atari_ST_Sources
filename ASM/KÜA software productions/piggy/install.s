read_boot:
	moveq.w #8,d0
	bsr rw_boot


trans_fuck:
off	equ $1a
	move.l #fuck,a0
	move.w #(fuck_end-fuck)/2,d0
	move.l #boots+off+2,a1
.loop	move.w (a0)+,(a1)+
	dbf d0,.loop
	move.w #$6000+off,boots
	
	
make_exec:
	move.l #$00000001ffffffff,-(sp)
	move.l #-1,-(sp)
	move.l #boots,-(sp)
	move.w #18,-(sp)
	trap #14
	lea.l 14(sp),sp	
	
	move.w d0,checksum	; no I don't know why I
			; have to do this -
			; but it works!


write_boot:
	moveq.w #9,d0
	bsr rw_boot


end:
	clr.w -(sp)
	trap #1
	

rw_boot
	move.w #1,-(sp)
	move.l #0,-(sp)
	move.w #1,-(sp)
	move.w #0,-(sp)
	clr.l -(sp)
	move.l #boots,-(sp)
	move.w d0,-(sp)
	trap #14
	lea.l 20(sp),sp
	rts
	

boots:	ds.b 510
checksum	ds.b 2

	even
; Your bootsector fuck goes here - you have 480 bytes
fuck:		include	'turd.s'
fuck_end:	dc.b 0
