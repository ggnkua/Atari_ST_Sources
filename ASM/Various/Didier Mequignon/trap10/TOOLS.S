; d‚marrage TOS

XBIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO   ; fn,pile
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,pile
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM
   
; chaque routine est appelee avec 
; D0=(HighWORD='10',LowWORD=(highBYTE=sub fn,lowBYTE=fn))
; A0=adresse suppl‚mentaire pour paramŠtres

; retour:
; D0='NULL' fonction inexistante
; D0='UNKN' sous fonction inexistante
; D0=long 10 Ok, tout baigne

debut:
	bra demarrage
	
restes:
	rept 5
	dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
	dc.b 25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45
	dc.b 46,47,48,49,50
	endr
	dc.b 0

quot_rouge:
	dcb.b 51,0
	dcb.b 51,1
	dcb.b 51,2
	dcb.b 51,3
	dcb.b 51,4
	dc.b 5

quot_vert6:
	dcb.b 51,0
	dcb.b 51,6
	dcb.b 51,12
	dcb.b 51,18
	dcb.b 51,24
	dc.b 30

quot_bleu36:
	dcb.b 51,0
	dcb.b 51,36
	dcb.b 51,72
	dcb.b 51,108
	dcb.b 51,144
	dc.b 180

matrice16_16:
	dc.b 34,5,21,44,32,3,20,42,33,4,21,43,35,6,22,44
	dc.b 15,50,28,12,13,48,26,10,14,49,27,11,15,51,28,12
	dc.b 31,8,18,47,29,7,16,45,30,8,17,46,32,9,19,48
	dc.b 25,41,37,2,23,39,36,0,24,40,37,1,25,41,38,3
	dc.b 33,4,20,43,35,6,22,45,34,5,21,43,33,4,20,42
	dc.b 14,49,27,10,16,51,29,13,14,50,27,11,13,49,26,10
	dc.b 30,7,17,46,32,9,19,48,31,8,18,47,30,7,17,46
	dc.b 23,39,36,1,26,42,38,3,24,40,37,2,23,39,36,1
	dc.b 34,5,21,44,33,4,20,42,33,4,20,43,35,6,22,45
	dc.b 15,50,28,11,13,49,26,10,14,49,27,11,16,51,29,12
	dc.b 31,8,18,47,29,7,16,45,30,7,17,46,32,9,19,48
	dc.b 24,40,37,2,23,39,36,0,24,40,36,1,25,41,38,3
	dc.b 34,5,21,43,35,6,22,44,34,5,22,44,32,3,19,42
	dc.b 14,50,27,11,15,51,28,12,15,50,28,12,13,48,26,10
	dc.b 30,8,18,46,31,9,19,47,31,9,18,47,29,6,16,45
	dc.b 24,40,37,1,25,41,38,2,25,41,38,2,23,39,35,0

dither_216:

	movem.l d2-d7/a2-a5,-(sp)
	move.l (a0)+,a1
	move.l (a0)+,a3
	move (a0)+,d4
	subq #1,d4
	move (a0)+,d6
	subq #1,d6
	move.l (a0),a5	; adresse palette (768 octets)
	lea restes,a0
	lea matrice16_16,a2
	cmp #0,d0
	bne sous1
	moveq #0,d0
.ligne:
	move d4,d7
	lea 16(a2),a4
.pixel:
	move.b (a2)+,d2
	move.b (a1)+,d0
	add d0,a0
	move.b 256(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_rouge
	addq.b #1,d3
.pas_rouge:
	sub d0,a0
	move.b (a1)+,d0
	add d0,a0
	add.b 512(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_vert
	addq.b #6,d3
.pas_vert:
	sub d0,a0
	move.b (a1)+,d0
	add d0,a0
	add.b 768(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_bleu
	add.b #36,d3
.pas_bleu:
	sub d0,a0
	move.b d3,(a3)+
	cmp.l a2,a4
	bne.s .pas_fin
	lea -16(a4),a2
.pas_fin:
	dbf d7,.pixel
	cmp.l #matrice16_16+256,a4
	bne.s .pas_fin_matrice
	lea -256(a4),a4
.pas_fin_matrice:
	move.l a4,a2
	dbf d6,.ligne
palette:
	moveq #51,d5
	moveq #0,d4
.pal_loop1:
	moveq #0,d3
.pal_loop0:
	moveq #0,d2
.pal_loop:
	move.b d2,(a5)+
	move.b d3,(a5)+
	move.b d4,(a5)+
	add.b d5,d2
	bcc.s .pal_loop
	add.b d5,d3
	bcc.s .pal_loop0
	add.b d5,d4
	bcc.s .pal_loop1
	moveq #10,d0
	movem.l (sp)+,d2-d7/a2-a5
	rts
sous1:
	cmp #1,d0
	bne sous2
	moveq #0,d0
.ligne:
	move d4,d7
	lea 16(a2),a4
.pixel:
	move.b (a2)+,d2
	move.w (a1)+,d6
	move.b d6,d0
	add.b d0,d0
	add d0,a0
	move.b 256(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_rouge
	addq.b #1,d3
.pas_rouge:
	sub d0,a0
	rol.w #6,d6
	move.b d6,d0
	add d0,a0
	add.b 512(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_vert
	addq.b #6,d3
.pas_vert:
	sub d0,a0
	rol.w #5,d6
	move.b d6,d0
	add d0,a0
	add.b 768(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_bleu
	add.b #36,d3
.pas_bleu:
	sub d0,a0
	move.b d3,(a3)+
	cmp.l a2,a4
	bne.s .pas_fin
	lea -16(a4),a2
.pas_fin:
	dbf d7,.pixel
	cmp.l #matrice16_16+256,a4
	bne.s .pas_fin_matrice
	lea -256(a4),a4
.pas_fin_matrice:
	move.l a4,a2
	dbf d6,.ligne	
	bra palette
sous2:
	cmp #2,d0
	bne sous3
	moveq #0,d0
.ligne:
	move d4,d7
	lea 16(a2),a4
.pixel:
	move.b (a2)+,d2
	move.w (a1)+,d6
	swap d6
	move.b d6,d0
	add d0,a0
	move.b 256(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_rouge
	addq.b #1,d3
.pas_rouge:
	sub d0,a0
	rol.w #5,d6
	move.b d6,d0
	add d0,a0
	add.b 512(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_vert
	addq.b #6,d3
.pas_vert:
	sub d0,a0
	rol.w #6,d6
	move.b d6,d0
	add d0,a0
	add.b 768(a0),d3
	cmp.b (a0),d2
	bcc.s .pas_bleu
	add.b #36,d3
.pas_bleu:
	sub d0,a0
	move.b d3,(a3)+
	cmp.l a2,a4
	bne.s .pas_fin
	lea -16(a4),a2
.pas_fin:
	dbf d7,.pixel
	cmp.l #matrice16_16+256,a4
	bne.s .pas_fin_matrice
	lea -256(a4),a4
.pas_fin_matrice:
	move.l a4,a2
	dbf d6,.ligne	
	bra palette	
sous3:
	move.l #'UNKN',d0
	rts		
	
; routines TIMER

data_control:
	movem.l d6-d7,-(sp)
	move.l d0,d5
	asr.l #1,d5              ; freq/2 pour les restes
	lea .freq,a1
	moveq #7,d1
	move.l #$7fffffff,d2     ; ‚cart au maximum
.lb0: 
	movem.l d0-d2/d5,-(sp)
	move.l (a1),d3
	move.l d0,d4
	bsr spdiv
	move.l d2,d3
	move.l d1,d4
	movem.l (sp)+,d0-d2/d5
   cmp.l d4,d5
   bpl.s .lb1
   addq.l #1,d3             ; arrondit au dessus si le reste > freq/2
.lb1: move.l (a1)+,d4
   tst.l d3                 ; data nul?
   beq.s .lb4               ; si oui, il faut passer !
   cmp.l #256,d3
   bpl.s .lb4               ; il faut que data tienne dans un octet
	movem.l d0-d3/d5,-(sp)
	exg.l d3,d4
	bsr spdiv
	move.l d2,d4
	movem.l (sp)+,d0-d3/d5
	move.l d4,d6
   sub.l d0,d4              ; ‚cart avec la fr‚quence demand‚e
   bpl.s .lb2
   neg.l d4                 ; ‚cart en valeur absolue
.lb2: cmp.l d4,d2
   bmi.s .lb4               ; l'‚cart pr‚c‚dent ‚tait moindre
   move.l d4,d2             ; change le maxi
   move.l d6,(a0)
   move.b d3,5(a0)          ; data
   move.b d1,7(a0)          ; control
.lb4: subq #1,d1            ; control suivant
   bne.s .lb0
  	movem.l (sp)+,d6-d7
   rts
.freq: dc.l 12288,24576,38400,49152,153600,245760,614400   


timer:
	movem.l d1-d7/a2-a6,-(sp)
	cmp #0,d0				; sous fonction 0 (lancer timer?)
	bne .pas0
	move.l a0,a6
	move.w (a6)+,d6		; numero de timer + 256 si TT MFP
	move.w (a6)+,d7		; auto ou software end of interrupt ou  timer stop
	cmp #2,d7
	beq .stop
	move.l (a6)+,d0		; fr‚quence voulue
	lea 6(a6),a0			; l… ou ranger data et control
	bsr data_control
	move.w (a6)+,d0		; delay (0) ou count (8)
	beq.s .no_count
	bset #3,7(a0)			; ajoute le bit 3 si count
.no_count:
	move sr,-(sp)			; conserve
	or #$700,sr				; plus d'interruptions
	lea $fffa00,a3
	bclr #8,d6				; bit 'TT MFP'
	beq.s .no_tt
	add #$80,a3				; nouvelle base
.no_tt:
	move d6,d0
	muls #12,d0
	lea .table(pc,d0.w),a0	; donn‚es pour chaque timer
	move.w (a0)+,d0		; offset enable/disable
	move.w (a0)+,d1		; num‚ro de bit
	bclr d1,0(a3,d0.w)	; invalide le timer
	bclr d1,12(a3,d0.w)
	lea 8(a6),a1			; data control
	move.w (a0)+,d2		; offset data
	move.b 1(a1),0(a3,d2.w)
	move.w (a0)+,d2		; offset control
	cmp #2,d6
	bmi.s .ab
	move.b 0(a3,d2.w),d3	; ancienne valeur
	move.b 3(a1),d4			; le control … ajouter
	cmp #2,d6
	bne.s .d
	lsl.b #4,d4				; vers bits 4-6
	and.b #$F,d3			; garde bits 0-3
	bra.s .cd
.d:
	and.b #$F0,d3			; garde bits 4-7
.cd:
	or.b d4,d3
	move.b d3,0(a3,d2.w)	; nouveau control C ou D
	bra.s .suite
.ab:
	move.b 3(a1),0(a3,d2.w) ; control A ou B
.suite:
	move.l (a0)+,a1		; l'adresse de la routine
	cmp.l #$FFFA00,a3		; ST MFP?
	beq.s .stmfp
	add.w #$40,a1			; sinon d‚calage de $40 pour les adresses TT
.stmfp:
	move.l (a6)+,(a1)		; adresse de la routine
	tst d7					; sei ou aei
	beq.s .aei
	bset #3,$17(a3)		; soft end of inter
	bra.s .fin
		
.table: dc.w 7,5,$1f,$19
		  dc.l $134
		  dc.w 7,0,$21,$1b
		  dc.l $120
		  dc.w 9,5,$23,$1d
		  dc.l $114
		  dc.w 9,4,$25,$1d
		  dc.l $110
.aei:
	bclr #3,$17(a3)
.fin:
	bset d1,0(a3,d0.w)	; autorise l'interruption
	bset d1,12(a3,d0.w)
	move (sp)+,sr
	moveq #10,d0
	movem.l (sp)+,d1-d7/a2-a6
	rts						; c'est parti mon kiki
	; pour chaque timer: offset enable, nøbit, offset data, offset control
	; et pour finir adresse vecteur (st mfp)
	; 12 octets par timer

		  
.stop:
	move sr,-(sp)
	or #$700,sr
	move d6,d0
	muls #12,d0
	lea .table(pc,d0.w),a0	; donn‚es pour chaque timer
	lea $fffa00,a3
	bclr #8,d6				; bit 'TT MFP'
	beq.s .no_tt2
	add #$80,a3				; nouvelle base
.no_tt2:
	move (a0)+,d0			; offset enable
	move (a0)+,d1			; nøbit
	bclr d1,0(a3,d0.w)	; disabled
	bclr d1,4(a3,d0.w)	; pending
	bclr d1,8(a3,d0.w)	; out service
	bclr d1,12(a3,d0.w)
	move (sp)+,sr
	moveq #10,d0
	movem.l (sp)+,d1-d7/a2-a6
	rts

.pas0:
	cmp #1,d0
	bne.s .unknown
	move.l 4(a0),d0		; frequence voulue
	lea 14(a0),a0			; retour
	bsr data_control
	moveq #10,d0
	movem.l (sp)+,d1-d7/a2-a6
	rts
.unknown:
	move.l #'UNKN',d0
	movem.l (sp)+,d1-d7/a2-a6
	rts

; entree D4 et D3
	
spdiv: moveq.l #1,d7
   move.l d7,d6
   tst.l d4
   bpl.s .lb1
   neg.l d4
   neg.l d7
.lb1:  tst.l d3
   bpl.s .lb2
   neg.l d3
   neg.l d7
   neg.l d6
.lb2: move.l #$80000000,d0
   moveq #0,d1
   moveq #0,d2
.lb3: lsl.l #1,d1
   move.l d0,d5
   and.l d3,d5
   beq.s .lb4
   addq.l #1,d1
.lb4: lsl.l #1,d2
   cmp.l d4,d1
   bmi.s .lb5
   sub.l d4,d1
   addq.l #1,d2
.lb5: lsr.l #1,d0
   bne.s .lb3
   tst.l d7
   bpl.s .lb6
   neg.l d2
.lb6: tst.l d6
   bpl.s .lb7
   neg.l d1
.lb7: rts
		
demarrage:
	move.l 4(sp),a0
	move.l $18(a0),a1
	add.l $1c(a0),a1
	add.l #$200,a1
	move.l a1,sp
	sub.l a0,a1
	move.l a1,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	GEMDOS $4a,12
	
	lea zone(pc),a0
	move.l #$31300100,d0
	trap #10
	
	lea zone2(pc),a0
	move.l #$31300100,d0
	trap #10
	
	pea texte(pc)
	GEMDOS 9,6
	
	clr -(sp)
	lea debut(pc),a0
	lea demarrage+256(pc),a1
	sub.l a0,a1
	move.l a1,-(sp)
	move #49,-(sp)
	trap #1
	
	
	data

zone: dc.w 10
	dc.l dither_216
zone2: dc.w 20
	dc.l timer
		
texte:
	dc.b 13,10,"Dithering 216 couleurs TRAP #10"
	dc.b 13,10,"   Routines Timers TRAP #10"
	dc.b 13,10,"          install‚es!"
	dc.b 13,10,"(c) 1998 gtello@wanadoo.fr"
	dc.b 13,10,0			

	end