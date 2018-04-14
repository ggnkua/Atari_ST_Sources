;rockyone			pour MI-3			10/04/2016
;
;
;			CYCLE COULEURS  : DEGAS
;			-----------------------
;
;
;Anime		buffer 68 bytes 
;	+0  	32 bytes anime format degas 
;	+38 	30 bytes for routine
;	
;Buf_Pal	6*34 octets             Pour stoker les palettes	
;	 +0	4 palette +4 word 	1 palette+1 word Par cycle
;	+136	1 palette +1 word 	Palette transf‚rr‚ dans $ff8240
;     	+160	1 palette +1 word 	Restore en quitant
;	+204 	End buffer			
;
;					   a5       a6
; 			call deg_init( L Anime, L Buf_Pal, Op%, Cycle%)
;			-----------------------------------------------
;
;
; * mouse bouton :  aret en fin de cycle
; * keybord      :  force arret        	
;|----------------------------------------------------------------------|
;|A5+38        			BUFFER ANIME + 38                       |
;|----------------------------------------------------------------------|
;| 1,2,3,4	Corespond aux numeros des cycles                        |
;|                                                                      |
;| Nb           Nombre de cycle actif pour convertion Neo et Tny        |
;|									|
;+0              +4              +8             +12             +20    +22
;38              42  inutilis‚   46              50              58     60
;|---------------|---------------|---------------|---------------|------|
;| First color*2 | Last color*2  |  Ecart color  | -1 cycle ok   |  Nb  |
;|---------------|---------------|---------------|---------------|------|
;| 1 | 2 | 3 | 4 | 1 | 2 | 3 | 4 | 1 | 2 | 3 | 4 | 1 | 2 | 3 | 4 |0 … 4 |
;|---------------|---------------|---------------|---------------|------|
;|		       Bytes                     |        Words         |
;|-----------------------------------------------|----------------------|
;
;+22            +30
;60              68
;|---------------|
;|     time      |
;|---------------|
;| 1 | 2 | 3 | 4 |
;|---------------|
;|    Words      |
;|---------------|
;

	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	64(sp),a5-a6
	move.w	72(sp),d7		; Op%

	tst.b	d7
	beq	init_cycle

;.........................................................................

	move.w	74(sp),d7	; Cycle numero 1,2,3,4 ???????,,
	
	lea.l	38(a5),a4  	; Pointe sur le premier param du cycle...
	adda.w	d7,a4		; ...( first color *2 )

	move.w	d7,d6		; 0 1 2 3
	lsl.b	#1,d6		; 0,2,4,6

	move.b	17(a5,d6.w),d3	; sens rotation


	move.b	(a4),d6		; offset premiŠre couleur
	moveq.l	#0,d5
	move.b	8(a4),d5	; ecart couleur

	move.w	d5,d4		; compteur rotation  couleur
	lsr.b	#1,d4		;
	subq.b	#1,d4		;-1 pour dbra
;...............................

	movea.l	#$fff8240,a5
	adda.w	d6,a5		; + offset color
	movea.l	a5,a3		; pour tansfer dans palette cycle

	lsl.b	#5,d7		; offset adr. palette du cycle
	add.b	d6,d7		; +offset couleur
	lea.l	0(a6,d7.w),a4	; adresse palette du cycle

	move.b	d4,d6		; compteur save couleur
	addq.b	#1,d6	
;.......................................;
	tst.b	d3		; sens rotation ?
	bne.s	sens_d
;.......................................;
sens_g:
	move.w	2(a4),(a5)+
	addq.l	#2,a4
	dbra.w	d4,sens_g

	suba.w	d5,a4
	bra.s	save_pal
;.......................................;
sens_d:
	move.w	(a4)+,2(a5)
	addq.l	#2,a5
	dbra.w	d4,sens_d

	suba.w	d5,a5
;...................................
save_pal:
	move.w	(a4),(a5)		; Rotation de la couleur restante

	adda.w	d7,a6			; Palette du cycle
copy_color:
	move.w	(a3)+,(a6)+
	dbra.w	d6,copy_color
	
	bra	end_prg
;.........................................................................
init_cycle:
	move.l	#0,50(a5)		; Efface ex cycles valide
	move.l	#0,54(a5)		;   "    "    "       "
	move.w	#0,58(a5)		; Efface ex nombre de cycle actif
	
	lea.l	38(a5),a4
	moveq.l	#0,d4
;.........................................................................
	moveq.l	#3,d0
init:	
	cmp.w	#1,16(a5)		; sans actif ?
	beq.s	next			; non

	move.w	(a5),d1			; Copy number of the first color
	andi.b	#$f,d1			; of each cycle.
	lsl.b	#1,d1		
	move.b	d1,(a4)

	move.w	8(a5),d2	        ; Copy number of the last color
	andi.b	#$f,d2			; of each cycle.
	lsl.b	#1,d2			
*	move.b	d2,4(a4)  inutilis‚ ***

	sub.b	d1,d2			; last color > first color ?
	bls.s	next			; non

	move.l	#128,d3			; time
	sub.w	24(a5),d3		; >=0 ?
	bmi.s	next			; non
	cmp.w	#129,d3			; > 128 ?
	bpl.s	next			; oui
	
*	lsr.b	#1,d2
*	subq.b	#1,d2			; -1 pour dbra
	move.b	d2,8(a4)		; Stok nb couleur dans le cycle
	move.w	d3,60(a5)		; Stok time

	move.w	#-1,50(a5)		; Marque cycle actif
	add.w	#1,d4			; Compte cycle actif

next:
	addq.l	#2,a5
	addq.l 	#1,a4
	dbra.w	d0,init

	move.w	d4,50(a5)		; Save nombre cyccle actif

;........................................................................

	movea.l	#$fff8240,a3
	moveq.l	#7,d1
copy_pal:
	move.l	(a3),(a6)+	
	move.l	(a3),28(a6)
	move.l	(a3),60(a6)
	move.l	(a3),92(a6)
	move.l	(a3),124(a6)
	move.l	(a3)+,156(a6)
	dbra.w	d1,copy_pal
	
;
;.....................................
;
end_prg: 
	moveq.l	#0,d0
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	end
;-------------------------------------------------------------------------