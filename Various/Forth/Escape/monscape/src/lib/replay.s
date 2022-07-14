.extern mt_init mt_physic_buf mt_logic_buf
.extern mt_physic mt_patternpos mt_songpos

DENTRIES startmod stopmod samplebuf patternpos songpos

CODE_XT startmod
	movem.l d0-a6,-(sp)
	bsr     mt_init
	bsr     init_inter
	movem.l (sp)+,d0-a6
	NEXT

CODE_XT stopmod
	movem.l d0-a6,-(sp)
	bsr     stop_inter
	bsr     mt_stop_Paula
	movem.l (sp)+,d0-a6
	NEXT

CODE_XT samplebuf
	lea    mt_physic_buf,a0
	PUSHD  (a0)
	NEXT

CODE_XT patternpos
	lea    mt_patternpos,a0
	moveq  #0,d0
	move.w (a0),d0
	lsr.w  #4,d0
	PUSHD  d0
	NEXT

CODE_XT songpos
	lea    mt_songpos,a0
	moveq  #0,d0
	move.b (a0),d0
	PUSHD  d0
	NEXT
