;rockyone			pour MI-3 & Mi-9		14/02/2017
;
;
;Funny-Paint is buggy, 
; 
; It does not load and does not porperly save the palette
;
;			open|save Funy Paint v1.2 FUN
;
;			   
;	open	call fun_os( L source, L destination, W Op%)
;	save	call fun_os( L destination, L source, W Op%)
;
;	
;Op%: 0 open, 1 save
;-------------------------------------------------------------------------
;		 ********************************************
;   	         
;		 FUN :  IMAGE DATA AND PALETTE ON ODD ADRESS
;
; +196 nombre de couleur -1
;
;	         *********************************************
;-------------------------------------------------------------------------
;d7	 resol image
;...................
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		lea.l	header(pc),a3	

		moveq.l	#3,d3		; for test and write header
		moveq.l	#0,d6 		; reading Index in a3

		move.w	68(sp),d0
		beq	open_fun

;---------------------------------------- SAVE FUN --------------------
		exg.l	a0,a1

		movea.l	a1,a6		; for coalulate file size
		addq.l	#1,a0
		move.b	(a0)+,d1	; resol source
		move.w	d1,d7		

		movea.l	a0,a2		; address palettesource
		lea.l	32(a0),a0	; jump palette
		subq.l	#2,d1
		neg.w	d1
		mulu.w	#12,d1

		lea.l	2(a3,d1.w),a3
		move.l	#$acfe2,(a1)+	; id FUN

write_header: 	move.w	(a3)+,(a1)+
		dbra.w	d3,write_header	

		addq.l	#1,a1

		bsr.s	copy_image

		move.w	(a3),d2		;+196  nombre de couleur -1
		move.b	d2,3(a1)

		adda.l	#12+6,a1	; jump animation 12 bytes
*					; +6 bytes to write RVB from 
*					; right to left
*					;****************************
		bsr.s	color_table	

read_color:	moveq.l	#2,d1
		move.b	(a3)+,d6	; read index vdi color
		move.w	0(a2,d6.w),d3	; read hard couleur

save_bvr:	moveq.l	#0,d5
		move.b	d3,d5		; B, then V, then R

		andi.b	#$f,d5
		mulu.w	#1000,d5
		divu.w	#15,d5

		move.b	d5,d0
		mulu.w	#2,d5
		cmpi.w 	#1000,d5
		blt.s	c8_vbr
		subi.w	#1000,d5
c8_vbr:		andi.b	#3,d0
		beq.s	ok_vbr
		addq.b	#1,d5

ok_vbr:		move.b	d5,-(a1)	; Write word B then V then R
		lsr.w	#8,d5		; on odd address
		move.b	d5,-(a1)	;
		lsr.w	#4,d3 		
		dbra.w	d1,save_bvr

		adda.l	#12,a1		; point to next Bleue + 1
		dbra.w	d2,read_color

		subq.l	#6,a1
		suba.l	a6,a1		
		move.l	a1,d0		;R. file size
		bra	end_prg


;..................................................................
color_table:	move.w	(a3),d2		; number of colors to convert

		lea.l	vdi_0(pc),a3	; conversion table resol 0
		tst.b	d7		 
		beq.s	ok_table	
		adda.w	#16,a3		; conversion table resol 1
		cmpi.b	#1,d7		 
		beq.s	ok_table	
		addq.l	#4,a3		; conversion table resol 2
ok_table:	rts

copy_image:	move.l	#31999,d5
copy_byte:	move.b	(a0)+,(a1)+	
		dbra.w	d5,copy_byte
		rts

;---------------------------------------OPEN FUN-------------------------

open_fun:	move.w	8(a0),d1	; read number plane 4 2 1
		lsr.b	#1,d1		;		    2 1 0
		mulu.w	#12,d1
		adda.w	d1,a3

		move.w	(a3)+,d7
*		move.w	d1,d7		; resol

		moveq.l	#-2,d0		;R. bad format
		cmp.l	#$acfe2,(a0)+
		bne	end_prg

test_header	cmpm.w	(a3)+,(a0)+	
		bne.s	end_prg
		dbra.w	d3,test_header
		
*		moveq.l	#0,d0		; not eror 

		addq.l	#1,a0
		move.l	a0,a2

		move.w	d7,(a1)+	; write resol
		movea.l	a1,a2		; for write color palette
		lea.l	32(a1),a1	
			
		bsr.s 	copy_image

		lea.l	12(a0),a0	; jumps animation bytes

;........................................palette de couleur RVB | HARD
	
		bsr.s	color_table

open_color:	moveq.l	#2,d1		; 3 values to read
		moveq.l	#0,d5

rvb:		moveq.l	#0,d3		
		move.b	(a0)+,d3	; Read Word R then V then B
		lsl.w	#8,d3		; on odd address	
		move.b	(a0)+,d3	;

		andi.w	#$fff,d3
		lsl.w	#4,d3
		divu.w	#1000,d3
	
		move.b	d3,d0
		lsr.w	#1,d3
		cmpi.b	#8,d3
		bne.s	c8_rvb
		addq.b	#7,d3
c8_rvb:		andi.b	#1,d0
		beq.s	ok_rvb
		addq.b	#8,d3

ok_rvb:		lsl.w	#4,d5
		add.b	d3,d5		; add r,v,b
		dbra.w	d1,rvb	

		move.b	(a3)+,d6	; index couleur VDI HARD
		move.w	d5,0(a2,d6.w)	; Save color

		dbra.w	d2,open_color

		moveq.l	#0,d0
		
;........................................................................

end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts

;......................................................................
	even
header:	dc.w	2,640,400,1,1,1
	dc.w	1,640,200,2,1,3
	dc.w 	0,320,200,4,1,15
	
Vdi_0:	dc.b 	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26
	dc.b 	0,6,2,4
	dc.b 	0,2
	even
		end
;-------------------------------------------------------------------------



