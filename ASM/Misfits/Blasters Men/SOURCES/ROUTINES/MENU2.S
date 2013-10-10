
menu_ctrl	loadpal decors+2
	lea t_intro,a0
	moveq #0,d0
	moveq #0,d1
	jsr aff_texte
m_main	jsr swap_screen
	jsr aff_curseur
	moveq #0,d0
m_mains1	move.b pt_key,d0
	cmp.w old_key,d0
	beq.s m_mains1
	move.w d0,old_key
	cmp.w #$39,d0
	beq.s m_exit
	cmp.w #$48,d0		key up
	beq.s m_ku
	cmp.w #$50,d0		key down
	beq.s m_kd
	cmp.w #$4b,d0		key left
	beq m_kl
	cmp.w #$4d,d0		key right
	beq m_kr
	bra.s m_main
m_exit	tst.b pt_key
	bne.s m_exit
	rts

m_ku	jsr eff_curseur
	move.w m_pt_lgn,d0
	subq.w #1,d0
	cmp.w #6,d0
	bge.s m_kus1
	move.w #9,d0
m_kus1	move.w d0,m_pt_lgn
	bra m_main

m_kd	jsr eff_curseur
	move.w m_pt_lgn,d0
	addq.w #1,d0
	cmp.w #9,d0
	ble.s m_kds1
	move.w #6,d0
m_kds1	move.w d0,m_pt_lgn
	bra m_main

m_kl	lea c_type,a0
	moveq #0,d1
	move.w m_pt_lgn,d0
	subq.w #6,d0
	move.b (a0,d0.w),d1
	subq.w #1,d1
	bpl.s m_kls1
	move.w #5,d1
m_kls1	move.b d1,(a0,d0.w)
	mulu #11,d1
	lea t_type,a0
	add.w d1,a0
	move.w m_pt_lgn,d1
	lsl.w #3,d1
	move.w #11*8,d0
	jsr aff_texte
	bra m_main

m_kr	lea c_type,a0
	moveq #0,d1
	move.w m_pt_lgn,d0
	subq.w #6,d0
	move.b (a0,d0.w),d1
	addq.w #1,d1
	cmp.w #5,d1
	ble.s m_kls1
	moveq #0,d1
	bra.s m_kls1

eff_curseur	lea t_eff,a0
	bra.s aff_curs1

aff_curseur	lea t_curseur,a0
aff_curs1	move.w m_pt_lgn,d1
	lsl.w #3,d1
	move.w #10*8,d0
	movem.l d1/a0,-(sp)
	jsr aff_texte
	movem.l (sp)+,d1/a0
	move.w #21*8,d0
	jmp aff_texte

	data

	*     0000000000111111111122222222223333333333
	*     0123456789012345678901234567890123456789
t_intro	dc.b "+-------------------------------------+",$0d,$0a
	dc.b "!      B L A S T E R S  -  M E N      !",$0d,$0a
	dc.b "!      -------------------------      !",$0d,$0a
	dc.b "!      (C) 1993 TMS DEVELOPMENTS      !",$0d,$0a
	dc.b "+-------------------------------------+",$0d,$0a
	dc.b $0d,$0a
	dc.b "PLAYER 1 ; JOYSTICK 0",$0a,$0d
	dc.b "PLAYER 2 ; JOYSTICK 1",$0a,$0d
	dc.b "PLAYER 3 ; CLAVIER 1",$0a,$0d
	dc.b "PLAYER 4 ; CLAVIER 2",$0a,$0d
	dc.b $0a,$0d
	dc.b "+--------+-----+-----+-----+-----+-----+",$0a,$0d
	dc.b "!CLAVIER ! UP  ! DWN ! LFT ! RGT ! FEU !",$0a,$0d
	dc.b "+--------+-----+-----+-----+-----+-----+",$0a,$0d
	dc.b "! NUM. 1 !  T  !  G  !  F  !  H  ! CTL !",$0a,$0d
	dc.b "+--------+-----+-----+-----+-----+-----+",$0a,$0d
	dc.b "! NUM. 2 !  8  !  5  !  4  !  6  ! RTN !",$0a,$0d
	dc.b "+--------+-----+-----+-----+-----+-----+",$0a,$0d
	dc.b "! NUM. 3 !  - TOUCHES CURSEUR -  ! SPC !",$0a,$0d
	dc.b "+--------+-----+-----+-----+-----+-----+",$0a,$0d
	dc.b $0a,$0d
	dc.b "      ESPACE POUR COMMENCER LE JEU",$0a,$0d
	dc.b 0
t_type	dc.b "JOYSTICK 0",0
	dc.b "JOYSTICK 1",0
	dc.b "CLAVIER 1 ",0
	dc.b "CLAVIER 2 ",0
	dc.b "CLAVIER 3 ",0
	dc.b "OFF       ",0
t_curseur	dc.b "-",0
t_eff	dc.b " ",0
	even

old_key	dc.w 0

m_pt_lgn	dc.w 6
c_type	dc.b 0,1,2,3
