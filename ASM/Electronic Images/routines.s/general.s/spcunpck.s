
handle_spc:
	lea	spc(pc),a0
	move.l	a0,a1
	adda.l	#52000,a1
	move.l	a1,a2
	bsr	unpackspc

	move.l	a2,a0
	moveq	#4-1,d1
	moveq	#0,d2
dospc:	lea	spc(pc),a1
	lea	160(a1),a1
	adda.w	d2,a1
	move.w	#199-1,d0	; Number of lines -1.
	bsr	copy1plane
	addq.w	#2,d2
	dbra	d1,dospc
	lea	-6(a1),a1
	move.w	#1194-1,d0
copypln:move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,copypln
dont_moveit:
	rts


;
; SPC unpacker.
;
unpackspc:
	movem.l	(a0)+,d0-d2
	movem.l	d0-d2,spc_flag

itsspc:	move.l	a0,spc_addr

	move.w	#31840,d0

spc_next:
	moveq	#0,d1
	move.b	(a0)+,d1
	bpl.s	spc_norep

	ext.w	d1
	neg.w	d1
	addq.w	#1,d1	; (usually 2) -1 for DBRA
	move.w	d1,d2
	addq.w	#1,d2
	move.b	(a0)+,d3
spc_rep:move.b	d3,(a1)+
	dbra	d1,spc_rep
	sub.w	d2,d0
	ble.s	do_palette
	bra.s	spc_next

spc_norep:
	move.w	d1,d2
norep:	move.b	(a0)+,(a1)+
	dbra	d1,norep
	addq.w	#1,d2
	sub.w	d2,d0
	bgt.s	spc_next


do_palette:

	move.l	spc_addr(pc),a0
	add.l	spc_datalen(pc),a0

      MOVE.W  #$254,D7
      CLR.W   D0
L0043:MOVE.W  #$D,D6
      MOVE.W  (A0)+,D1
      LSR.W   #1,D1 
      MOVE.W  D0,(A1)+
L0044:LSR.W   #1,D1 
      BCC.S   L0045 
      MOVE.W  (A0)+,(A1)+ 
      DBF     D6,L0044
      BRA.S   L0046 
L0045:MOVE.W  D0,(A1)+
      DBF     D6,L0044
L0046:MOVE.W  D0,(A1)+
      DBF     D7,L0043
enduspc:
	rts	


spc_addr:
	ds.l	1
spc_flag:
	ds.w	1
spc_reserved:
	ds.w	1
spc_datalen:
	ds.l	1	
spc_collen:
	ds.l	1

	
copy1plane:
scoff	set	0
	rept	20
	move.w	(a0)+,scoff(a1)
scoff	set	scoff+8
	endr
	lea	160(a1),a1
	dbra	d0,copy1plane
	rts

	section bss

spc:	ds.b	52000
boo:	ds.b	54000
