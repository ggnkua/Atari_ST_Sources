v118	movem.l d0-d1/a0-a1,-(sp)
	move.w #$2500,sr
	lea $fffffc00.w,a0
	lea $fffffc02.w,a1
	moveq #0,d1
	move.b (a0),d0
	btst #7,d0
	beq v118s4
	move.b (a1),d1
	cmp.b #-2,d1		joystick 1 ?
	beq.s v118s1
	cmp.b #-1,d1		joystick 2 ?
	bne.s v118s5		non ? alors scan_code.
v118s1	move.b (a0),d0	attend le pack de donnees
	btst #7,d0		pour les joysticks.
	beq.s v118s1
v118s2	move.b (a1),d0
	cmp.b #-2,d0
	beq.s v118s2
v118s6	btst #0,d1
	bne.s v118s3
	move.b d0,pt_joy0
	bra v118s4
v118s3	move.b d0,pt_joy1
v118s4	bclr #6,$fffffa11.w
	movem.l (sp)+,d0-d1/a0-a1
irte	rte
v118s5	lea tab_keyboard,a0
	clr.b pt_key
	clr.b pt_key2
	bclr #7,d1
	bne.s v118s7
	move.b d1,pt_key
	move.b scan_ascii(pc,d1.w),pt_key2
v118s7	eor.b #-1,(a0,d1.w)
	bra.s v118s4

scan_ascii	dc.b 0,$1b,"&",0,"""'(",0,0,"!",0,0,")-",8
	dc.b 9,"AZERTYUIOP",0,"$",13
	dc.b 0,"QSDFGHJKLM%",0,0,"#"
	dc.b "WXCVBN,;:=",0,0,0," ",0
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b "-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b "()/*7894561230.",13,0,0,0,0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0

tab_keyboard	ds.b 128
	even

tst_key	lea tab_gkey1,a0
	lea tab_keyboard,a1
	lea pt_joy3,a2
	moveq #0,d1
	bsr.s tst_keys1
	lea tab_gkey2,a0
	lea pt_joy2,a2
	moveq #0,d1
	bsr.s tst_keys1
	lea tab_gkey3,a0
	lea pt_joy4,a2
	moveq #0,d1
tst_keys1	move.l (a0)+,d0
	beq.s tst_keys2
	tst.b (a1,d0.w)
	beq.s tst_keys1
	swap d0
	or.w d0,d1
	bra.s tst_keys1
tst_keys2	move.b d1,(a2)
	rts

tab_gkey1	dc.w 1<<0,$68		up    = key 8
	dc.w 1<<1,$6b		down  = key 5
	dc.w 1<<2,$6a		left  = key 4
	dc.w 1<<3,$6c		right = key 6
	dc.w 1<<7,$1c		fire  = key Return
	dc.l 0

tab_gkey2	dc.w 1<<0,$14		up    = key T
	dc.w 1<<1,$22		down  = key G
	dc.w 1<<2,$21		left  = key F
	dc.w 1<<3,$23		right = key H
	dc.w 1<<7,$1d		fire  = key Control
	dc.l 0

tab_gkey3	dc.w 1<<0,$48		up    = key up
	dc.w 1<<1,$50		down  = key down
	dc.w 1<<2,$4b		left  = key left
	dc.w 1<<3,$4d		right = key right
	dc.w 1<<7,$39		fire  = key space
	dc.l 0

