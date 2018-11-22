; a0 a2 buffer_menu
; a1 a3	ecr1
; d1	num‚ro du menu ligne 1
; d2	-1 si menu d‚j… sur l'‚cran 
; d3  	-1 pour afficher le bloc rvb
;	-2 pour afficher uniquement le bloc rvb
 
		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	64(sp),a0-a1
		movem.w	72(sp),d1-d3

		cmpi.w	#-2,d3
		beq.s	bar_rvb
		
		tst.b	d2
		bne.s	new_menu

all_menu:	move.l	#599,d7			; 2400\4-1  15 lignes
		lea.l	7*160(a0),a2		; bar_titre +4 lignes noir	 
		lea.l	158*160(a1),a3	
loop:		move.l	(a2)+,(a3)+
		dbra.w	d7,loop

new_menu:	bsr.s	bar_l1
		tst.b	d2			; new_menu ?
		bne.s	bar_rvb			; yes

bar_l2		move.l	#639,d7			; 2560\4-1  16 ligne			
		lea.l	33*160(a0),a2		; bar bt_l2
loop2:		move.l	(a2)+,(a3)+	
		dbra.w	d7,loop2	

bar_rvb:	tst.w	d3
		beq.s	end_prg
		lea.l	71*160(a0),a2
		lea.l	126*160(a1),a3
		move.l  #1439,d7		; 5760\4-1 32 ligne+ 4
		bsr.s	loop1
;.........................................................................
end_prg:	movem.l	(sp)+,d0-d7/a0-a6
		rts
;.........................................................................

bar_l1:		lea.l	173*160(a1),a3		; oblig‚ pour new_menu
		move.l	#439,d7			; 1760\4-1  11 lignes

		cmpi.w	#3,d1
		bne.s	barcopy
		lea.l	49*160(a0),a2		; bar_cycle
		bra.s	loop1

barcopy:	cmpi.w	#7,d1
		bne.s	autre
		lea.l	60*160(a0),a2		; bar_copy
		bra.s	loop1

autre:		lea.l	22*160(a0),a2		; les autres menu ligne 1

		
loop1:		move.l	(a2)+,(a3)+
		dbra.w	d7,loop1
		rts
;-------------------------------------------------------------------------
		
