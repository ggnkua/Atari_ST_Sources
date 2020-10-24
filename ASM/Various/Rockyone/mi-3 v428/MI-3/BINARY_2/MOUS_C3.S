;rockyone		  	MI3 uniquement 			25/09/2018
;
;modifi‚ pour Exang_c3.s (F7)			  		26.07.2019
;
;
;		Uniquement pour basse et moyenne r‚solution
;		'''''''''''''''''''''''''''''''''''''''''''
;
;
; adr1		Adrese du buffer de la pallette Hardware
; adr2   	Adresse du buffer      
;		+0  2 index de couleur de la VDI
;		+4  2 index HARD corespondant
;
;;		+8	2 index vdi  pour F7 ( Exang_C3 )
;		12 	2 index Hard pour F7 ( Exang_C3)
;
; rez% 		Resolution de l'image
; res_st% 	R‚solution du ST au d‚maarrage
; inv_pal%	0 toujours aprŠs le chargement d'une image
;		xor 8 si appelle par F7
;
;		     	    a3	   a4    d0     d1
;	call color_mouse( L Adr1,L Adr2, Res%, Res_st%, inv_pal% )
;	
;Return 2 index color vdi in low d0
;------------------------------------------------------------------------
;used	d0-d7/a0-a4
;
	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	64(sp),a3-a4
	movem.w	72(sp),d0-d1

	moveq.l	#0,d3
	moveq.l	#0,d4

	moveq.l	#3,d2			; 4 color si ST d‚marr‚ en r‚sol 1
	add.b	d0,d1			; Nombre de couleur maxi celon la
	bne.s	find_color		; r‚solution de l'image et de la
	moveq.l	#$F,d2			; r‚solution du ST au d‚marrage

find_color:
	lsl.w	#4,d0				;*16
	lea.l	color_index(pc,d0.w),a1		; Celon la r‚sol de l'image
	movea.l	a1,a2				; ind‚pandement de la resol
;						; de d‚marrage du ST
	move.w	#$fff,d6
	moveq.l	#0,d7
	moveq.l	#0,d0
	moveq.l	#0,d5

loop:	move.b	(a1)+,d0
	lsl.b	#1,d0
	move.w	0(a3,d0.w),d1  			; a3 adresse palette
	andi.w	#$77f,d1

	cmp.w	d1,d7
	bge.s	color_fond
	move.w	d1,d7
	move.b	d5,d3

color_fond:
	cmp.w	d1,d6
	ble.s	next_color
	move.w	d1,d6
	move.b	d5,d4

next_color:
	addq.b	#1,d5	
	dbra.w	d2,loop

;............................

;color_vdi:
	move.w	76(sp),d7
	move.w	d4,0(a4,d7.w)		; Index couleurs vdi pour 
	move.w	d3,2(a4,d7.w)		; info_file et menu diaporama


;			   HARDWARE COLOR
;color_mouse:	
	move.b	0(a2,d3.w),d3		 
	swap	d3
	move.b	0(a2,d4.w),d3

	move.l	d3,4(a4,d7.w)		; Index couleurs pour Exang_C3.bin				
	tst.b	d7			; Appel de cette routine par F7 ?
	bne.s	_end			; <>0 Yes

	dc.w	$a000			; init line A
	move.l	d3,-850(a0)		; mouse couleur du fond
*	move.w	d4,-848(a0)		; mouse couleur premier plan


_end:	movem.l	(a7)+,d0-d7/a0-a6
	rts

color_index:	dc.b	0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
		dc.b	0,3,1,2
		end
;------------------------------------------------------------------