;rockyone			POUR MI-3 MI-9			28/06/2016
;
;reduction du code						23/02/2017
;
;	save 	PRISM-PAINT v1.1	PNT compress‚ ou non compress‚
;	save 	TRUE-PAINT  v1.03	TPI n'est jamais compress‚
;			------------------------
;
; Source	Buffer Contenant  le fichier image format PI1-3
; Destination  	Bufer 32480 octet
; Op%		0 pas compresser, 1 compresser
;
;
; Utilisez avant :      pc_save( L Source,L Destination,Op%) 
;			
; Return dans	low d0  La taille des data image 
;			taille = lpeek(reserved(0))-66 
;
;
;		CALL Pnt_Tpi_Save( L Destination, taille )
;		---------------------------------
; Retour dans d0  la taille du fichier a sauvegarder
;
;
;-------------------------------------------------------------------------	
;a0 source

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0
		moveq.l	#0,d4
		move.w	64(sp),d4		; taille du fichier source

		movea.l	a0,a5			; but = source

;recopier data image source apres entete et palette PNT 

		lea.l	0(a0,d4.w),a1		; fin du source
	
		lea.l	94(a1),a4		; copier data image sur a4
;						; -34 palette Degas
;						; +128 entete PNT

		subi.w	#35,d4			; nombre de data a recopier
;                                               ; a incrire dans l'entete
;						; - 1 byte compresion
;						; - 1 byte resolution
;						; -32 byte palette
;						; -1 pour dbra
		
;taille de la palette ?
		move.b	1(a0),d1		;  0   1  2 resol source
		subq.l	#2,d1			; -2, -1, 0
		neg.w	d1			;  2,  1, 0
		mulu.w	#10,d1			;  20, 10,0

		lea.l	table(pc),a2
		adda.w	d1,a2			;  table PNT / resol	

		adda.w	(a2)+,a4		; +taille  palette PNT

		move.l	a4,d0			;R. size file PNT
		sub.l	a0,d0			;----------------
		
		move.w	d4,d1				
copy_pic:	move.b	-(a1),-(a4)
		dbra.w	d1,copy_pic	
	
		lea.l	134(a0),a4
*		suba.w	(a2)+,a4		; start palette PNT
		addq.l	#2,a0			; star palette source

		move.b	1(a5),d7		; resol source
*		bsr.s	table

;........................................
		lea.l	vdi_0(pc),a3		; table conversion resol 0
		tst.b	d7			 
		beq.s	ok_table	
		lea.l	16(a3),a3		; table conversion resol 1
		cmp.b	#1,d7		
		beq.s  ok_table
		addq.l	#4,a3			;table conversion resol  2
ok_table:
	
;.......................................	
	
palette:	move.w	(a2),d2		; nombre de couleurs 
		subq.l	#1,d2		; -1 pour dbra	
		moveq.l	#0,d6

read_color:	moveq.l	#2,d1		; trois valeur a transformer
		move.b	(a3)+,d6	; read index vdi color
		move.w	0(a0,d6.w),d3	; read color source

code_bvr:	moveq.l	#0,d5
		move.b	d3,d5		;B, then V, then R

		andi.b	#$f,d5		
		mulu.w	#1000,d5
		divu.w	#15,d5			

		move.b	d5,d7
		mulu.w	#2,d5
		cmpi.w	#1000,d5
		blt.s	c8_bvr
		subi.w	#1000,d5
c8_bvr:		andi.b	#3,d7
		beq.s	ok_bvr
		addq.b	#1,d5

ok_bvr:		move.w	d5,-(a4)	;write B, then V, then R
		lsr.w	#4,d3
		dbra.w	d1,code_bvr

		lea.l	12(a4),a4
		dbra.w	d2,read_color
	
;.......................................HEADER........................		
		moveq.l	#0,d1
		tst.b	(a5)			; byte compression
		beq.s	not_packed
		moveq.l	#1,d1	

not_packed: 	move.l	#$504e5400,(a5)+	; 'PNT '
		move.w	#$100,(a5)+		; version PNT 1.00 
	
		moveq.l	#3,d2
copy_header:	move.w	(a2)+,(a5)+
		dbra.w	d2,copy_header

		move.w	d1,(a5)+		;+14  flag compression 1
		addq.l	#1,d4
		move.l	d4,(a5)+		;+16  taille des data

		moveq.l	#26,d1
clean:		move.l	#0,(a5)+
		dbra.w	d1,clean

;........................................end_prg...............
end_prg:	movem.l	(a7)+,d1-d7/a0-a6
		rts

;.......................................
	even
;	lg_palette,color, largeur, hauteur, nb_plan
table:	dc.w	12,2,640,400,1
	dc.w	24,4,640,200,2
	dc.w	96,16,320,200,4	

Vdi_0:	dc.b 	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26
	dc.b 	0,6,2,4
	dc.b 	0,2

	end
;-------------------------------------------------------------------------