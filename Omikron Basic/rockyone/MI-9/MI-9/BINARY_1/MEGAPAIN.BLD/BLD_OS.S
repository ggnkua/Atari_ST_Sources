;rockyone			pour MI-3 & Mi-9		11/03/2017
;
;				
;				Mega_Paint BLD
;
;			open pic <= 640 *  <= 400
;			save pic    640 *     400
;
;
;Op% 	0 open
;	1 save compress‚
;	2 save
;		
;		call	bld_os( L source, L destination, W Op%)
;
;-------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		move.w	68(sp),d1
		cmpi.b	#1,d1			; open or save ?
		beq	pack_bld
		bhi	save_bld

;...............................................OPEN.....................

		move.w	(a0),d7			; n‚gatif = compress‚  
		bpl.s	positif			
		neg.w	(a0)

positif:	moveq.l	#-4,d0			;R. bad size
		cmpi.w	#640,(a0)		; > 639 ?
		bpl	end_prg
		move.w	(a0)+,d1		; largeur image

		cmpi.w	#400,(a0)		;>399 ?
		bpl	end_prg			; hauteur image
		move.w	(a0)+,d2

		moveq.l	#0,d0			;R. not error	

		move.w	#2,(a1)+		; write r‚solution
		move.l	#$FFF0000,(a1)+		; write two couleurs
		lea.l	28(a1),a1
		
		move.w	d1,d4
		subi.w	#639,d4
		neg.w	d4
		moveq.l	#0,d5
		move.w	d2,d5
		subi.w	#399,d5
		neg.w	d5
		mulu.w	#640,d5
		subq.l	#1,d5
		moveq.l	#0,d6

		move.w	d1,d3
		move.w	d4,d6

		tst.w	d7
		bmi.s	depack
;...............................................open non compress‚......		


copy_line:	move.b	(a0)+,(a1)+
		subq.w	#8,d3
		bhi.s	copy_line	; end data line ?
		bsr.s	finish_line	; complte the line if needed

		tst.w	d2		; eof file ?
		bpl.s	copy_line

end_file:	move.l	d5,d6
		bsr.s	finish_line	; complete the lines if necessary
		bra.s	end_prg

;.............................................. complete the lign.......

finish_line:	tst.l	d6			
		ble.s	end_line

loop:		move.b	#0,(a1)+
		subq.l	#8,d6
		bhi.s	loop

end_line:	move.w	d1,d3
		move.w	d4,d6
		subq.w	#1,d2
		rts
;...............................................open compress‚..........

depack:		moveq.l	#0,d0
read_code:	tst.w	d2		; eof file ?
		bmi.s	end_file	

		move.b	(a0)+,d7
		beq.s	repeat
		cmpi.b	#$ff,d7
		beq.s	repeat

		move.b	d7,(a1)+
		subq.w	#8,d3
		bhi.s	read_code	; end data line ?
		bsr.s	finish_line	; complete the ligne if needed 
		bra.s	read_code

repeat:		move.b	(a0)+,d0	; number of repetition
recopy:		move.b	d7,(a1)+
		subq.w	#8,d3
		bhi.s	continu		; end data line ?
		bsr.s	finish_line     ; complete the line if needed
continu:	dbra.w	d0,recopy
		bra.s	depack
;--------------------------------------------END--------------------------
end_pack	move.l	a1,d0
		sub.l	a6,d0		
*		cmpi.l	#32001,d0
*		bpl.s	save_bld
		addi.l	#4,d0
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts
;-------------------------------------------------------------------------

init_memory:	
*		move.l	64(sp),a1		; but, (sp+4 because BSR)
*		move.l	68(sp),a0		; source
		exg.l	a0,a1
		lea.l	34(a0),a0
		move.w	#639,(a1)+
		move.w	#399,(a1)+	
		rts
;..............................................Save uncompressed........

save_bld:	bsr.s	init_memory
		move.w	#7999,d7
copy_lw:	move.l	(a0)+,(a1)+
		dbra.w	d7,copy_lw
		move.w	#32004,d0		;R. file size uncompressed
		bra.s	end_prg

;...............................................Save compressed.........

;source	a0 a2 a3
;but	a1 a6
;d2	byte read
;d6	counter repeat

pack_bld:	bsr.s	init_memory
		lea.l	32000(a0),a3		; end source
		movea.l	a1,a6			; for calulate file size
		neg.w	-4(a1)
		
next_line:	
		move.w	#80,d6			; 80 bytes per line

s_read:		cmpa.l	a3,a0			; eof source ?
		bpl.s	end_pack

		move.b	(a0)+,d2	
		move.b	d2,(a1)+
		beq.s	s_repeat
		cmpi.b	#$ff,d2
		beq.s	s_repeat

		subq.b	#1,d6
		beq.s	next_line		; end_line ?
		bra.s	s_read

s_repeat:	movea.l	a0,a2
		moveq.l	#0,d5			; reset counter

s_cmp:		subq.w	#1,d6
		beq.s	write_counter		; end_line ?

		cmp.b	(a2)+,d2
		bne.s	write_counter	

		addq.l	#1,d5			; count byte to repeat

		cmpa.l	a3,a2			; eof source ?
		bpl.s	write_counter

		bra.s	s_cmp

write_counter:	move.b	d5,(a1)+
		adda.w	d5,a0
		tst.b	d6			; end_line
		beq.s	next_line
		bra.s	s_read	

;-------------------------------------------------------------------------

		end

;-------------------------------------------------------------------------



