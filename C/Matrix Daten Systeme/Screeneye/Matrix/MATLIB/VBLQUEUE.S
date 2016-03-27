		.include	"gemdos.i"

TRUE	=	1
FALSE	=	0


*--------------------------------------------- inst_vbl_rout ----------

; PROC *inst_vbl_rout ( void vbl_rout() ) ;
;								a0
				.xref	inst_vbl_rout
				
inst_vbl_rout:	movem.l	d1/a1,-(sp)

		        move.w  nvbls,d1
		        move.l  _vblqueue,a1

		        addq.l  #4,a1				; skip slot # 0
		        subq    #2,d1

	vbl_loop:   tst.l	(a1)+				; Look for free slot
		        beq     slot_found
        		dbra    d1,vbl_loop

				sub.l	a0,a0				; not found, a0 := NULL ;
				bra		ivbl_exit

slot_found:		move.l	a0,-(a1)			; put vblrout into empty slot
				move.l	a1,a0				; a0 := slot address ;

ivbl_exit:		movem.l	(sp)+,d1/a1
      			rts


XBRA            EQU     "XBRA"
POS_XBRA        EQU     -12
POS_MAGIC       EQU     -8
POS_OLD_VEC     EQU     -4


*--------------------------------------------- vbl_xbra ----------

; void *vbl_xbra ( ulong magic ) ;
; return pointer to XBRA - routine with 'magic', if not found : NULL

			.export	vbl_xbra
			
vbl_xbra:	move.l  _vblqueue,a1
			move    nvbls,d1
			bra		while_loop

test_vbl:	movea.l (a1)+,a0                ; Fetch vector
			cmpa.l  #0,a0
			beq     while_loop              ; Empty slot
			cmp.l   #XBRA,POS_XBRA(a0)      ; Check XBRA magic
			bne     while_loop

			cmp.l   POS_MAGIC(a0),d0
			beq     found					; return -> XBRA isr

while_loop:	dbra    d1,test_vbl

			sub.l	a0,a0					; return NULL

found:		rts

