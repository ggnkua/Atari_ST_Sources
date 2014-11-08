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

old_trap:
	bra demarrage
	
gestionnaire:
	swap d0
	cmp #'10',d0
	bne.s .not_trap_10
	clr d0
	swap d0
	lsl.l #8,d0		; sub fn Highword
	lsr.w #6,d0		; fn*4
	tst.l table(pc,d0.w)
	beq.s .empty_fn
	move.l a1,-(sp)
	move.l table(pc,d0.w),a1
	swap d0			; sub fn
	jsr (a1)
	move.l (sp)+,a1
	rte
.empty_fn:
	move.l #'NULL',d0
	rte	
.not_trap_10:
	swap d0
	move.l old_trap(pc),-(sp)
	rts

table: 
	dc.l gest		; fonctions 0 reserv‚es
	dcb.l 255,0		; autres libres!
	
	; Fonction 0: gestionnaire
	
gest:
	lea table(pc),a1
	tst d0
	bne.s .lb1
						; sous fonction 00=demander infos sur Trap 10
	move.l #'1.00',(a0)+		; version de Trap #10
	move.l a1,(a0)+			; adresse de la table
	moveq #10,d0
	rts
.lb1:
	cmp #1,d0
	bne.s .lb2
						; sous fonction 01=installer une fonction
	move (a0)+,d0	; numero de fonction
	lsl #2,d0		; *4
	add d0,a1
	tst.l (a1)
	bne.s .not_free
	move.l (a0),(a1)	; installe
	moveq #10,d0	; Ok
	rts
.not_free:
	moveq #-1,d0	; pas libre
	rts
.lb2:
	cmp #2,d0
	bne.s .lb3
						; sous fonction 02=liberer une fonction
	move (a0)+,d0	; num‚ro de fonction
	lsl #2,d0		; *4
	add d0,a1
	tst.l (a1)
	beq.s .deja_libre
	clr.l (a1)
	moveq #10,d0
	rts
.deja_libre:
	moveq #-2,d0	; deja libre!
	rts
.lb3:
	move.l #'UNKN',d0
	rts		
		
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
	
	pea installe(pc)
	XBIOS 38,6
	
	pea texte(pc)
	GEMDOS 9,6
	
	clr -(sp)
	lea old_trap(pc),a0
	lea demarrage+256(pc),a1
	sub.l a0,a1
	move.l a1,-(sp)
	move #49,-(sp)
	trap #1
	
	
installe:
	move.l $a8.w,old_trap
	move.l #gestionnaire,$a8.w
	rts

	data
	
texte:
	dc.b 13,10,"Gestionnaire routines TRAP #10"
	dc.b 13,10,"         install‚!"
	dc.b 13,10,"(c) 1998 gtello@wanadoo.fr"
	dc.b 13,10,0			

	end