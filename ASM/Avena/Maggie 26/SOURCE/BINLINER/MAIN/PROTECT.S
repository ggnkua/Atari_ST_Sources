; HOST PORT PROTECTOR
;  Stolen from the Xperience Demo by Abstract (Fatal Design)
;  It's a fair cup guv

Save_Host_Internals:
._1	btst	#1,$ffffa202.w
	beq.s	._1
	move.l	#"030",$ffffa204.w

					; 2. Receive data until
					; "DSP" reached
	lea	Saved_Host_Data(pc),a0
._2	btst	#0,$ffffa202.w
	beq.s	._2
	move.l	$ffffa204.w,d7
	move.l	d7,(a0)+
	cmp.l	#"DSP",d7
	bne.s	._2

					; 3. Then transmit to the DSP
					; what was actually in there,
					; including "DSP"
	lea	Saved_Host_Data(pc),a0
._3	move.l	(a0)+,d7
._4	btst	#1,$ffffa202.w
	beq.s	._4
	move.l	d7,$ffffa204.w
	cmp.l	#"DSP",d7
	bne.s	._3

					; Receive data originally sent
					; including "030"
	lea	Saved_Host_Data(pc),a0
._5	btst	#0,$ffffa202.w
	beq.s	._5
	move.l	$ffffa204.w,d7
	move.l	d7,(a0)+
	cmp.l	#"030",d7
	bne.s	._5
	rts



Restore_Host_Internals:
	lea	$ffffa202.w,a6
	lea	Saved_Host_Data(pc),a0
._1	move.l	(a0)+,d7
	cmp.l	#"030",d7
	beq.s	._3
._2	btst	#1,$ffffa202.w
	beq.s	._2
	move.l	d7,$ffffa204.w
	bra.s	._1
._3	rts

Saved_Host_Data:
	DS.L	10



