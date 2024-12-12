; -----------------------------
; Affichage du logo 'MINI-DIST'
;  SCREEN2 (C) FANTOMAS 1990
; -----------------------------

 move.l 4(sp),d6              ; d6=y
 move.l 8(sp),a3              ; a3=ecran d'affichage
 lea sprt(pc),a0              ; a0=adresse des donnees du sprite
 lea coor(pc),a2              ; a2=adresse des abscisses

 mulu #160,d6                 ; y=y*160
 moveq.l #19,d5               ; d5=nbre de lignes-1

loop:

 lea (a3),a1                  ; Sauve adresse
 moveq.l #0,d0
 move.w (a2)+,d0              ; d0=x
 move d0,d4                   ; sauve x
 and.l #15,d4                 ; calcule le decalage (modulo 16)
 lsr #1,d0                    ; Calcule, a partir de x, la position
 andi #$f8,d0                 ; dans la ligne video...
 add d6,d0                    ; x=(x/2) and -8
 adda.l d0,a1                 ; a1=adresse ou sera affiche le sprite

;--- 1 ---
 movem.l (a0)+,d0-d3          ; Chargement des 3 plans+masque
 ror.l d4,d0                  ; Rotation plan 1
 ror.l d4,d1                  ;          plan 2
 ror.l d4,d2                  ;          plan 3
 ror.l d4,d3                  ;          masque
 and d3,(a1)                  ; Affichage du masque
 or d0,(a1)+                  ; Affichage du sprite
 and d3,(a1)                  ; Idem plan 2
 or d1,(a1)+
 and d3,(a1)                  ; Idem plan 3
 or d2,(a1)+
 and d3,(a1)+
 swap d0                      ; Met ce qui a ete decale dans
 swap d1                      ; le mot de poids faible
 swap d2
 swap d3
 and d3,(a1)                  ; Affichage des donnees qui sont
 or d0,(a1)+                  ; sorties lors du decalage
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1                 ; Ajuste a1
;--- 2 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 3 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 4 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 5 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 6 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 7 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 8 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 9 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 subq.l #8,a1
;--- 10 ---
 movem.l (a0)+,d0-d3         
 ror.l d4,d0
 ror.l d4,d1
 ror.l d4,d2
 ror.l d4,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)
 add.l #160,d6
 dbra d5,loop

 lea coor(pc),a0
 lea 2(a0),a1
 movem.l (a0),d0-d7/a2-a3
 movem.l d0-d7/a2-a3,(a1)
 rts


sprt:
;--- 0 ---
 dc.l $C000,$0,$3FFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $0,$0,$FFFF,$FFFF0000
 dc.l $1,$1,$FFFE,$FFFF0000
;--- 1 --- dc.l $8000,$7FFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $1,$FFFF,$0,$FFFF0000
;--- 2 --- dc.l $C03,$703C,$83C0,$FFFF0000
 dc.l $300,$C00,$F0FF,$FFFF0000
 dc.l $C0,$303,$FC3C,$FFFF0000
 dc.l $3030,$C0C0,$F0F,$FFFF0000
 dc.l $0,$3F,$FFC0,$FFFF0000
 dc.l $180,$FE00,$7F,$FFFF0000
 dc.l $60,$780,$F81F,$FFFF0000
 dc.l $18,$60,$FF87,$FFFF0000
 dc.l $6,$18,$FFE1,$FFFF0000
 dc.l $1,$7,$FFF8,$FFFF0000
;--- 3 --- dc.l $FC3,$707C,$8781,$FFFF0000
 dc.l $F3FF,$1C00,$E1FF,$FFFF0000
 dc.l $FCFC,$707,$F878,$FFFF0000
 dc.l $3F3F,$C1C0,$1E1F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $1FF,$FE00,$FF,$FFFF0000
 dc.l $FC7F,$780,$F83F,$FFFF0000
 dc.l $FF9F,$E0,$FF0F,$FFFF0000
 dc.l $FFE7,$38,$FFC3,$FFFF0000
 dc.l $FFF9,$F,$FFF0,$FFFF0000
;--- 4 --- dc.l $7C3,$7018,$8FE7,$FFFF0000
 dc.l $F1FF,$1C00,$E3FF,$FFFF0000
 dc.l $FC7C,$707,$F8F8,$FFFF0000
 dc.l $1F1F,$C1C0,$3E3F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FE3F,$380,$FC7F,$FFFF0000
 dc.l $FF8F,$E0,$FF1F,$FFFF0000
 dc.l $FFE3,$38,$FFC7,$FFFF0000
 dc.l $FFF9,$F,$FFF0,$FFFF0000
;--- 5 --- dc.l $7E7,$7000,$8FFF,$FFFF0000
 dc.l $F1FF,$1C00,$E3FF,$FFFF0000
 dc.l $FC7C,$701,$F8FE,$FFFF0000
 dc.l $1F1F,$C1C0,$3E3F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FE3F,$380,$FC7F,$FFFF0000
 dc.l $FF8F,$E0,$FF1F,$FFFF0000
 dc.l $FFE3,$38,$FFC7,$FFFF0000
 dc.l $FFF9,$F,$FFF0,$FFFF0000
;--- 6 --- dc.l $7FF,$7000,$8FFF,$FFFF0000
 dc.l $F1FF,$1C00,$E3FF,$FFFF0000
 dc.l $FC7E,$700,$F8FF,$FFFF0000
 dc.l $1F1F,$C1C0,$3E3F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FE3F,$380,$FC7F,$FFFF0000
 dc.l $FF8F,$E0,$FF1F,$FFFF0000
 dc.l $FFE3,$38,$FFC7,$FFFF0000
 dc.l $FFF9,$F,$FFF0,$FFFF0000
;--- 7 --- dc.l $7FF,$7000,$8FFF,$FFFF0000
 dc.l $F1FF,$1DF0,$E20F,$FFFF0000
 dc.l $FC7F,$FF00,$FF,$FFFF0000
 dc.l $1F1E,$41DE,$BE21,$FFFF0000
 dc.l $FFC0,$FFF,$F000,$FFFF0000
 dc.l $FC,$FE00,$1F3,$FFFF0000
 dc.l $3E3F,$3BE,$FC41,$FFFF0000
 dc.l $FF8F,$1FE0,$E01F,$FFFF0000
 dc.l $FFE3,$FFFB,$4,$FFFF0000
 dc.l $FFF9,$E1FF,$1E00,$FFFF0000
;--- 8 --- dc.l $7FD,$7040,$8FBF,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $807F,$FF00,$FF,$FFFF0000
 dc.l $9F00,$1FE,$FE01,$FFFF0000
 dc.l $F80C,$FF0,$F003,$FFFF0000
 dc.l $F8,$607,$F9F0,$FFFF0000
 dc.l $7E01,$C3FC,$3C03,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $8000,$FFFF,$0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 9 --- dc.l $7FD,$7064,$8F9B,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $807F,$FF00,$FF,$FFFF0000
 dc.l $DF00,$1FE,$FE01,$FFFF0000
 dc.l $F80F,$FF0,$F007,$FFFF0000
 dc.l $F8F0,$E07,$F1F8,$FFFF0000
 dc.l $7E01,$C3FC,$3C03,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $FFE0,$3F,$FFC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 10 --- dc.l $7D9,$707C,$8F83,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $807F,$FF00,$FF,$FFFF0000
 dc.l $FF00,$1FE,$FE01,$FFFF0000
 dc.l $F807,$FF0,$F00F,$FFFF0000
 dc.l $F8F0,$E07,$F1F8,$FFFF0000
 dc.l $7E01,$C3FC,$3C03,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $FFE0,$3F,$FFC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 11 --- dc.l $7C1,$707C,$8F83,$FFFF0000
 dc.l $F00F,$1FE0,$E01F,$FFFF0000
 dc.l $807F,$FF04,$FB,$FFFF0000
 dc.l $FF00,$1FE,$FE01,$FFFF0000
 dc.l $F807,$FF7,$F008,$FFFF0000
 dc.l $F8F0,$FE07,$1F8,$FFFF0000
 dc.l $7E01,$C3FC,$3C03,$FFFF0000
 dc.l $F000,$1FFF,$E000,$FFFF0000
 dc.l $7E0,$FC3F,$3C0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 12 --- dc.l $7C1,$707C,$8F83,$FFFF0000
 dc.l $F30F,$1C00,$E0FF,$FFFF0000
 dc.l $807F,$8306,$7CF9,$FFFF0000
 dc.l $FF30,$1C0,$FE0F,$FFFF0000
 dc.l $F800,$83F,$F7C0,$FFFF0000
 dc.l $F7,$FE07,$1F8,$FFFF0000
 dc.l $FE61,$C380,$3C1F,$FFFF0000
 dc.l $FF90,$1FE0,$E00F,$FFFF0000
 dc.l $7E0,$43F,$FBC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 13 --- dc.l $7C1,$707C,$8F83,$FFFF0000
 dc.l $F3FF,$1C00,$E1FF,$FFFF0000
 dc.l $FC7D,$707,$F8F8,$FFFF0000
 dc.l $FF3F,$1C0,$FE1F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FE7F,$380,$FC3F,$FFFF0000
 dc.l $FF9F,$E0,$FF0F,$FFFF0000
 dc.l $FFE0,$3F,$FFC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 14 --- dc.l $7C1,$707C,$8F83,$FFFF0000
 dc.l $F1FF,$1C00,$E3FF,$FFFF0000
 dc.l $FC7C,$707,$F8F8,$FFFF0000
 dc.l $FF1F,$81C0,$7E3F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FE3F,$380,$FC7F,$FFFF0000
 dc.l $FF8F,$E0,$FF1F,$FFFF0000
 dc.l $FFE0,$3F,$FFC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 15 --- dc.l $7C1,$707C,$8F83,$FFFF0000
 dc.l $F1FF,$1C00,$E3FF,$FFFF0000
 dc.l $FC7C,$707,$F8F8,$FFFF0000
 dc.l $7F1F,$C1C0,$3E3F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FE3F,$380,$FC7F,$FFFF0000
 dc.l $FF8F,$E0,$FF1F,$FFFF0000
 dc.l $FFE0,$3F,$FFC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 16 --- dc.l $7C1,$707C,$8F83,$FFFF0000
 dc.l $F1FF,$1C00,$E3FF,$FFFF0000
 dc.l $FC7C,$707,$F8F8,$FFFF0000
 dc.l $3F1F,$E1C0,$1E3F,$FFFF0000
 dc.l $FFC0,$7F,$FF80,$FFFF0000
 dc.l $FF,$FE00,$1FF,$FFFF0000
 dc.l $FC3F,$780,$F87F,$FFFF0000
 dc.l $FF8F,$E0,$FF1F,$FFFF0000
 dc.l $FFE0,$3F,$FFC0,$FFFF0000
 dc.l $1F01,$C1FF,$3E00,$FFFF0000
;--- 17 --- dc.l $7C1,$77FD,$8802,$FFFF0000
 dc.l $F1FF,$FDFF,$200,$FFFF0000
 dc.l $FC7C,$FF7F,$80,$FFFF0000
 dc.l $3F1F,$FFDF,$20,$FFFF0000
 dc.l $FFC0,$FFFF,$0,$FFFF0000
 dc.l $FF,$FEFF,$100,$FFFF0000
 dc.l $F87F,$FFFF,$0,$FFFF0000
 dc.l $FF8F,$FFEF,$10,$FFFF0000
 dc.l $FFE0,$FFFF,$0,$FFFF0000
 dc.l $1F01,$DFFF,$2000,$FFFF0000
;--- 18 --- dc.l $0,$7FFF,$8000,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $0,$FFFF,$0,$FFFF0000
 dc.l $1,$FFFF,$0,$FFFF0000
;--- 19 --- dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
 dc.l $ffff,$ffff,$0,$FFFF0000
coor:
 dc.w 111,111,111,111,111,111,111,111,111,111
 dc.w 111,111,111,111,111,111,111,111,111,111
 dc.w 0
 end
 