
***************************************************************
*	Partie du programme BASIC.PRG
*	Suit la table des adresses en fonction des roms
*	Puis le petit programme qui regarde le numero de
*	la rom en $FC0002 (ou $E00002)
***************************************************************

;-----------------------------> Adaptation aux differentes ROMS
; 1- MEGA ST
adapt:    dc.w $0102
          dc.l $2740
          dc.l $e4f
          dc.l $c76
          dc.l $26e6
          dc.l $27a8
          dc.l $e22
          dc.l $e8a
; 2- 520/1040 V 1.0
          dc.w $0100
          dc.l $26e0            ;adresses souris
          dc.l $e09             ;adresse joystick
          dc.l $db0             ;buffer clavier
          dc.l $2686            ;table VDI 1
          dc.l $2748            ;table VDI 2
          dc.l $ddc             ;vecteur inter souris
          dc.l $e44             ;depart d'un son
; 3- 520/1040 V 1.1
          dc.w $0101
          dc.l $26e0            ;adresses souris
          dc.l $e09             ;adresse joystick
          dc.l $db0             ;buffer clavier
          dc.l $2686            ;table VDI 1
          dc.l $2748            ;table VDI 2
          dc.l $ddc             ;vecteur inter souris
          dc.l $e44             ;depart d'un son
; 4- ROMS 1.4
	dc.w $0104
          dc.l $2882            ;adresses souris
          dc.l $e6b             ;adresse joystick
          dc.l $c92             ;buffer clavier
          dc.l $2828            ;table VDI 1
          dc.l $28ea            ;table VDI 2
          dc.l $e3e             ;vecteur inter souris
          dc.l $ea6             ;depart d'un son
; 5- ROMS 1.6
	dc.w $0106
          dc.l $28c2            ;adresses souris
          dc.l $eab             ;adresse joystick
          dc.l $cd2             ;buffer clavier
          dc.l $2868            ;table VDI 1
          dc.l $292a            ;table VDI 2
          dc.l $e7e             ;vecteur inter souris
          dc.l $ee6             ;depart d'un son
; 6- Vide
          dc.w $ffff
          dc.l 0,0,0,0,0,0,0
; 7- Vide
	dc.w $ffff
	dc.l 0,0,0,0,0,0,0
NbAdapt:	equ 7

; -superviseur- SAUVE LA PALETTE et ADAPTE A L'ORDINATEUR
; Installe aussi la fausse trappe FLOAT!
getpal:   lea $ff8240,a0
          lea datas(pc),a1
          moveq #15,d0
gp1:      move.w (a0)+,(a1)+
          dbra d0,gp1
; Adapte ST/STE
	move.l $8,d1
	move.l #Ste,$8
	move.l sp,d2
	move.w $FC0002,d0
FinSte:	move.l d2,sp
	move.l d1,$8
          lea adapt(pc),a0
          moveq #NbAdapt-1,d1
adapt1:   cmp.w (a0)+,d0
          beq.s adapt2
          add.w #28,a0
          dbra d1,adapt1
          lea adapt+2(pc),a0        ;par defaut: ROM du mega ST
adapt2:   lea adapt+2(pc),a2
          moveq #6,d0
adapt3:   move.l (a0)+,(a2)+    ;recopie en ADAPT+2
          dbra d0,adapt3
; Fausse trappe FLOAT en trappe 6
          move.l #FauxFloat,d0
          move.l d0,$98
          rts
; Erreur de bus si sur STE
Ste:	move.w $E00002,d0
	bra.s FinSte
; FAUSSE TRAPPE FLOAT!
FauxFloat:
          cmp.b #$0c,d0         ;Ramene toujours 0
          beq.s FxFl1
          moveq #0,d0
          moveq #0,d1
          rte
FxFl1:    move.b #"0",(a0)      ;Ramene toujours la chaine nulle
          move.b #".",1(a0)
          move.b #"0",2(a0)
          clr.b 3(a0)
          rte
