; ---------------
; AFSPR16 (V 2.0)
; ---------------
; Routine d'affichage de sprites de 16x16
;  (Codage du sprite sur 3 plans)
;
 move.l 4(sp),d0              ; d0=x
 move.l 8(sp),d1              ; d1=y*160
 move.l 12(sp),a1             ; a1=adresse ecran d'affichage
 move d0,d4                   ; sauve d0
 lea disc(pc),a0              ; a0=adresse des donnees du sprite
 and.l #15,d4                 ; Calcule le decalage (modulo 16)
 lsl.l #8,d4                  ; Decalage*256
 add.l d4,a0                  ; adresse=adresse+decalage*256
 lsr #1,d0                    ; Calcule, a partir de x, la
 andi #$f8,d0                 ; position dans la ligne video
 add d0,d1                    ; x=(x/2) and -8
 adda.l d1,a1                 ; a1=adresse ou sera affiche le sprite
;--- 1 ---
 movem.l (a0)+,d0-d3          ; Chargement des 3 plans + masque
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
 add.l #144,a1                ; Ajuste a1
;--- 2 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 3 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 4 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 5 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 6 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 7 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 8 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 9 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 10 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 11 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 12 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 13 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 14 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 15 ---
 movem.l (a0)+,d0-d3
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
 add.l #144,a1
;--- 16 ---
 movem.l (a0)+,d0-d3
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
 rts
; --------------------------------
; Sprite code sur 3 plans + masque
; --------------------------------
 data
disc:
;---- 0 ----
 dc.l $f00f,$2004,$ffff,$ffff0000
 dc.l $f00f,$2004,$ffff,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$f00f,$ffff0000
 dc.l $ffff,$2004,$ffff,$ffff0000
 dc.l $ffff,$3ffc,$ffff,$ffff0000
 dc.l $ffff,$0000,$ffff,$ffff0000
 dc.l $ffff,$0ffc,$ffff,$ffff0000
 dc.l $ffff,$0ff4,$f80f,$ffff0000
 dc.l $ffff,$0cf4,$fb0f,$ffff0000
 dc.l $ffff,$0cf4,$fb0f,$ffff0000
 dc.l $ffff,$0cf4,$fb0f,$ffff0000
 dc.l $ffff,$0ff4,$f80f,$ffff0000
;---- 1 ---- dc.l $80007807,$1002,$80007FFF,$7FFF8000 dc.l $80007807,$1002,$80007FFF,$7FFF8000 dc.l $80007FFF,$1002,$80007807,$7FFF8000 dc.l $80007FFF,$1002,$80007807,$7FFF8000 dc.l $80007FFF,$1002,$80007807,$7FFF8000 dc.l $80007FFF,$1002,$80007807,$7FFF8000 dc.l $80007FFF,$1002,$80007807,$7FFF8000 dc.l $80007FFF,$1002,$80007FFF,$7FFF8000 dc.l $80007FFF,$1FFE,$80007FFF,$7FFF8000 dc.l $80007FFF,$0,$80007FFF,$7FFF8000 dc.l $80007FFF,$7FE,$80007FFF,$7FFF8000 dc.l $80007FFF,$7FA,$80007C07,$7FFF8000 dc.l $80007FFF,$67A,$80007D87,$7FFF8000 dc.l $80007FFF,$67A,$80007D87,$7FFF8000 dc.l $80007FFF,$67A,$80007D87,$7FFF8000 dc.l $80007FFF,$7FA,$80007C07,$7FFF8000;---- 2 ---- dc.l $C0003C03,$801,$C0003FFF,$3FFFC000 dc.l $C0003C03,$801,$C0003FFF,$3FFFC000 dc.l $C0003FFF,$801,$C0003C03,$3FFFC000 dc.l $C0003FFF,$801,$C0003C03,$3FFFC000 dc.l $C0003FFF,$801,$C0003C03,$3FFFC000 dc.l $C0003FFF,$801,$C0003C03,$3FFFC000 dc.l $C0003FFF,$801,$C0003C03,$3FFFC000 dc.l $C0003FFF,$801,$C0003FFF,$3FFFC000 dc.l $C0003FFF,$FFF,$C0003FFF,$3FFFC000 dc.l $C0003FFF,$0,$C0003FFF,$3FFFC000 dc.l $C0003FFF,$3FF,$C0003FFF,$3FFFC000 dc.l $C0003FFF,$3FD,$C0003E03,$3FFFC000 dc.l $C0003FFF,$33D,$C0003EC3,$3FFFC000 dc.l $C0003FFF,$33D,$C0003EC3,$3FFFC000 dc.l $C0003FFF,$33D,$C0003EC3,$3FFFC000 dc.l $C0003FFF,$3FD,$C0003E03,$3FFFC000;---- 3 ---- dc.l $E0001E01,$80000400,$E0001FFF,$1FFFE000 dc.l $E0001E01,$80000400,$E0001FFF,$1FFFE000 dc.l $E0001FFF,$80000400,$E0001E01,$1FFFE000 dc.l $E0001FFF,$80000400,$E0001E01,$1FFFE000 dc.l $E0001FFF,$80000400,$E0001E01,$1FFFE000 dc.l $E0001FFF,$80000400,$E0001E01,$1FFFE000 dc.l $E0001FFF,$80000400,$E0001E01,$1FFFE000 dc.l $E0001FFF,$80000400,$E0001FFF,$1FFFE000 dc.l $E0001FFF,$800007FF,$E0001FFF,$1FFFE000 dc.l $E0001FFF,$0,$E0001FFF,$1FFFE000 dc.l $E0001FFF,$800001FF,$E0001FFF,$1FFFE000 dc.l $E0001FFF,$800001FE,$E0001F01,$1FFFE000 dc.l $E0001FFF,$8000019E,$E0001F61,$1FFFE000 dc.l $E0001FFF,$8000019E,$E0001F61,$1FFFE000 dc.l $E0001FFF,$8000019E,$E0001F61,$1FFFE000 dc.l $E0001FFF,$800001FE,$E0001F01,$1FFFE000;---- 4 ---- dc.l $F0000F00,$40000200,$F0000FFF,$FFFF000 dc.l $F0000F00,$40000200,$F0000FFF,$FFFF000 dc.l $F0000FFF,$40000200,$F0000F00,$FFFF000 dc.l $F0000FFF,$40000200,$F0000F00,$FFFF000 dc.l $F0000FFF,$40000200,$F0000F00,$FFFF000 dc.l $F0000FFF,$40000200,$F0000F00,$FFFF000 dc.l $F0000FFF,$40000200,$F0000F00,$FFFF000 dc.l $F0000FFF,$40000200,$F0000FFF,$FFFF000 dc.l $F0000FFF,$C00003FF,$F0000FFF,$FFFF000 dc.l $F0000FFF,$0,$F0000FFF,$FFFF000 dc.l $F0000FFF,$C00000FF,$F0000FFF,$FFFF000 dc.l $F0000FFF,$400000FF,$F0000F80,$FFFF000 dc.l $F0000FFF,$400000CF,$F0000FB0,$FFFF000 dc.l $F0000FFF,$400000CF,$F0000FB0,$FFFF000 dc.l $F0000FFF,$400000CF,$F0000FB0,$FFFF000 dc.l $F0000FFF,$400000FF,$F0000F80,$FFFF000;---- 5 ---- dc.l $78000780,$20000100,$F80007FF,$7FFF800 dc.l $78000780,$20000100,$F80007FF,$7FFF800 dc.l $F80007FF,$20000100,$78000780,$7FFF800 dc.l $F80007FF,$20000100,$78000780,$7FFF800 dc.l $F80007FF,$20000100,$78000780,$7FFF800 dc.l $F80007FF,$20000100,$78000780,$7FFF800 dc.l $F80007FF,$20000100,$78000780,$7FFF800 dc.l $F80007FF,$20000100,$F80007FF,$7FFF800 dc.l $F80007FF,$E00001FF,$F80007FF,$7FFF800 dc.l $F80007FF,$0,$F80007FF,$7FFF800 dc.l $F80007FF,$E000007F,$F80007FF,$7FFF800 dc.l $F80007FF,$A000007F,$780007C0,$7FFF800 dc.l $F80007FF,$A0000067,$780007D8,$7FFF800 dc.l $F80007FF,$A0000067,$780007D8,$7FFF800 dc.l $F80007FF,$A0000067,$780007D8,$7FFF800 dc.l $F80007FF,$A000007F,$780007C0,$7FFF800;---- 6 ---- dc.l $3C0003C0,$10000080,$FC0003FF,$3FFFC00 dc.l $3C0003C0,$10000080,$FC0003FF,$3FFFC00 dc.l $FC0003FF,$10000080,$3C0003C0,$3FFFC00 dc.l $FC0003FF,$10000080,$3C0003C0,$3FFFC00 dc.l $FC0003FF,$10000080,$3C0003C0,$3FFFC00 dc.l $FC0003FF,$10000080,$3C0003C0,$3FFFC00 dc.l $FC0003FF,$10000080,$3C0003C0,$3FFFC00 dc.l $FC0003FF,$10000080,$FC0003FF,$3FFFC00 dc.l $FC0003FF,$F00000FF,$FC0003FF,$3FFFC00 dc.l $FC0003FF,$0,$FC0003FF,$3FFFC00 dc.l $FC0003FF,$F000003F,$FC0003FF,$3FFFC00 dc.l $FC0003FF,$D000003F,$3C0003E0,$3FFFC00 dc.l $FC0003FF,$D0000033,$3C0003EC,$3FFFC00 dc.l $FC0003FF,$D0000033,$3C0003EC,$3FFFC00 dc.l $FC0003FF,$D0000033,$3C0003EC,$3FFFC00 dc.l $FC0003FF,$D000003F,$3C0003E0,$3FFFC00;---- 7 ---- dc.l $1E0001E0,$8000040,$FE0001FF,$1FFFE00 dc.l $1E0001E0,$8000040,$FE0001FF,$1FFFE00 dc.l $FE0001FF,$8000040,$1E0001E0,$1FFFE00 dc.l $FE0001FF,$8000040,$1E0001E0,$1FFFE00 dc.l $FE0001FF,$8000040,$1E0001E0,$1FFFE00 dc.l $FE0001FF,$8000040,$1E0001E0,$1FFFE00 dc.l $FE0001FF,$8000040,$1E0001E0,$1FFFE00 dc.l $FE0001FF,$8000040,$FE0001FF,$1FFFE00 dc.l $FE0001FF,$F800007F,$FE0001FF,$1FFFE00 dc.l $FE0001FF,$0,$FE0001FF,$1FFFE00 dc.l $FE0001FF,$F800001F,$FE0001FF,$1FFFE00 dc.l $FE0001FF,$E800001F,$1E0001F0,$1FFFE00 dc.l $FE0001FF,$E8000019,$1E0001F6,$1FFFE00 dc.l $FE0001FF,$E8000019,$1E0001F6,$1FFFE00 dc.l $FE0001FF,$E8000019,$1E0001F6,$1FFFE00 dc.l $FE0001FF,$E800001F,$1E0001F0,$1FFFE00;---- 8 ---- dc.l $F0000F0,$4000020,$FF0000FF,$FFFF00 dc.l $F0000F0,$4000020,$FF0000FF,$FFFF00 dc.l $FF0000FF,$4000020,$F0000F0,$FFFF00 dc.l $FF0000FF,$4000020,$F0000F0,$FFFF00 dc.l $FF0000FF,$4000020,$F0000F0,$FFFF00 dc.l $FF0000FF,$4000020,$F0000F0,$FFFF00 dc.l $FF0000FF,$4000020,$F0000F0,$FFFF00 dc.l $FF0000FF,$4000020,$FF0000FF,$FFFF00 dc.l $FF0000FF,$FC00003F,$FF0000FF,$FFFF00 dc.l $FF0000FF,$0,$FF0000FF,$FFFF00 dc.l $FF0000FF,$FC00000F,$FF0000FF,$FFFF00 dc.l $FF0000FF,$F400000F,$F0000F8,$FFFF00 dc.l $FF0000FF,$F400000C,$F0000FB,$FFFF00 dc.l $FF0000FF,$F400000C,$F0000FB,$FFFF00 dc.l $FF0000FF,$F400000C,$F0000FB,$FFFF00 dc.l $FF0000FF,$F400000F,$F0000F8,$FFFF00;---- 9 ---- dc.l $7800078,$2000010,$FF80007F,$7FFF80 dc.l $7800078,$2000010,$FF80007F,$7FFF80 dc.l $FF80007F,$2000010,$7800078,$7FFF80 dc.l $FF80007F,$2000010,$7800078,$7FFF80 dc.l $FF80007F,$2000010,$7800078,$7FFF80 dc.l $FF80007F,$2000010,$7800078,$7FFF80 dc.l $FF80007F,$2000010,$7800078,$7FFF80 dc.l $FF80007F,$2000010,$FF80007F,$7FFF80 dc.l $FF80007F,$FE00001F,$FF80007F,$7FFF80 dc.l $FF80007F,$0,$FF80007F,$7FFF80 dc.l $FF80007F,$FE000007,$FF80007F,$7FFF80 dc.l $FF80007F,$FA000007,$780007C,$7FFF80 dc.l $FF80007F,$7A000006,$8780007D,$7FFF80 dc.l $FF80007F,$7A000006,$8780007D,$7FFF80 dc.l $FF80007F,$7A000006,$8780007D,$7FFF80 dc.l $FF80007F,$FA000007,$780007C,$7FFF80;---- 10 ---- dc.l $3C0003C,$1000008,$FFC0003F,$3FFFC0 dc.l $3C0003C,$1000008,$FFC0003F,$3FFFC0 dc.l $FFC0003F,$1000008,$3C0003C,$3FFFC0 dc.l $FFC0003F,$1000008,$3C0003C,$3FFFC0 dc.l $FFC0003F,$1000008,$3C0003C,$3FFFC0 dc.l $FFC0003F,$1000008,$3C0003C,$3FFFC0 dc.l $FFC0003F,$1000008,$3C0003C,$3FFFC0 dc.l $FFC0003F,$1000008,$FFC0003F,$3FFFC0 dc.l $FFC0003F,$FF00000F,$FFC0003F,$3FFFC0 dc.l $FFC0003F,$0,$FFC0003F,$3FFFC0 dc.l $FFC0003F,$FF000003,$FFC0003F,$3FFFC0 dc.l $FFC0003F,$FD000003,$3C0003E,$3FFFC0 dc.l $FFC0003F,$3D000003,$C3C0003E,$3FFFC0 dc.l $FFC0003F,$3D000003,$C3C0003E,$3FFFC0 dc.l $FFC0003F,$3D000003,$C3C0003E,$3FFFC0 dc.l $FFC0003F,$FD000003,$3C0003E,$3FFFC0;---- 11 ---- dc.l $1E0001E,$800004,$FFE0001F,$1FFFE0 dc.l $1E0001E,$800004,$FFE0001F,$1FFFE0 dc.l $FFE0001F,$800004,$1E0001E,$1FFFE0 dc.l $FFE0001F,$800004,$1E0001E,$1FFFE0 dc.l $FFE0001F,$800004,$1E0001E,$1FFFE0 dc.l $FFE0001F,$800004,$1E0001E,$1FFFE0 dc.l $FFE0001F,$800004,$1E0001E,$1FFFE0 dc.l $FFE0001F,$800004,$FFE0001F,$1FFFE0 dc.l $FFE0001F,$FF800007,$FFE0001F,$1FFFE0 dc.l $FFE0001F,$0,$FFE0001F,$1FFFE0 dc.l $FFE0001F,$FF800001,$FFE0001F,$1FFFE0 dc.l $FFE0001F,$FE800001,$1E0001F,$1FFFE0 dc.l $FFE0001F,$9E800001,$61E0001F,$1FFFE0 dc.l $FFE0001F,$9E800001,$61E0001F,$1FFFE0 dc.l $FFE0001F,$9E800001,$61E0001F,$1FFFE0 dc.l $FFE0001F,$FE800001,$1E0001F,$1FFFE0;---- 12 ---- dc.l $F0000F,$400002,$FFF0000F,$FFFF0 dc.l $F0000F,$400002,$FFF0000F,$FFFF0 dc.l $FFF0000F,$400002,$F0000F,$FFFF0 dc.l $FFF0000F,$400002,$F0000F,$FFFF0 dc.l $FFF0000F,$400002,$F0000F,$FFFF0 dc.l $FFF0000F,$400002,$F0000F,$FFFF0 dc.l $FFF0000F,$400002,$F0000F,$FFFF0 dc.l $FFF0000F,$400002,$FFF0000F,$FFFF0 dc.l $FFF0000F,$FFC00003,$FFF0000F,$FFFF0 dc.l $FFF0000F,$0,$FFF0000F,$FFFF0 dc.l $FFF0000F,$FFC00000,$FFF0000F,$FFFF0 dc.l $FFF0000F,$FF400000,$80F0000F,$FFFF0 dc.l $FFF0000F,$CF400000,$B0F0000F,$FFFF0 dc.l $FFF0000F,$CF400000,$B0F0000F,$FFFF0 dc.l $FFF0000F,$CF400000,$B0F0000F,$FFFF0 dc.l $FFF0000F,$FF400000,$80F0000F,$FFFF0;---- 13 ---- dc.l $80780007,$200001,$FFF80007,$7FFF8 dc.l $80780007,$200001,$FFF80007,$7FFF8 dc.l $FFF80007,$200001,$80780007,$7FFF8 dc.l $FFF80007,$200001,$80780007,$7FFF8 dc.l $FFF80007,$200001,$80780007,$7FFF8 dc.l $FFF80007,$200001,$80780007,$7FFF8 dc.l $FFF80007,$200001,$80780007,$7FFF8 dc.l $FFF80007,$200001,$FFF80007,$7FFF8 dc.l $FFF80007,$FFE00001,$FFF80007,$7FFF8 dc.l $FFF80007,$0,$FFF80007,$7FFF8 dc.l $FFF80007,$7FE00000,$FFF80007,$7FFF8 dc.l $FFF80007,$7FA00000,$C0780007,$7FFF8 dc.l $FFF80007,$67A00000,$D8780007,$7FFF8 dc.l $FFF80007,$67A00000,$D8780007,$7FFF8 dc.l $FFF80007,$67A00000,$D8780007,$7FFF8 dc.l $FFF80007,$7FA00000,$C0780007,$7FFF8;---- 14 ---- dc.l $C03C0003,$80100000,$FFFC0003,$3FFFC dc.l $C03C0003,$80100000,$FFFC0003,$3FFFC dc.l $FFFC0003,$80100000,$C03C0003,$3FFFC dc.l $FFFC0003,$80100000,$C03C0003,$3FFFC dc.l $FFFC0003,$80100000,$C03C0003,$3FFFC dc.l $FFFC0003,$80100000,$C03C0003,$3FFFC dc.l $FFFC0003,$80100000,$C03C0003,$3FFFC dc.l $FFFC0003,$80100000,$FFFC0003,$3FFFC dc.l $FFFC0003,$FFF00000,$FFFC0003,$3FFFC dc.l $FFFC0003,$0,$FFFC0003,$3FFFC dc.l $FFFC0003,$3FF00000,$FFFC0003,$3FFFC dc.l $FFFC0003,$3FD00000,$E03C0003,$3FFFC dc.l $FFFC0003,$33D00000,$EC3C0003,$3FFFC dc.l $FFFC0003,$33D00000,$EC3C0003,$3FFFC dc.l $FFFC0003,$33D00000,$EC3C0003,$3FFFC dc.l $FFFC0003,$3FD00000,$E03C0003,$3FFFC;---- 15 ---- dc.l $E01E0001,$40080000,$FFFE0001,$1FFFE dc.l $E01E0001,$40080000,$FFFE0001,$1FFFE dc.l $FFFE0001,$40080000,$E01E0001,$1FFFE dc.l $FFFE0001,$40080000,$E01E0001,$1FFFE dc.l $FFFE0001,$40080000,$E01E0001,$1FFFE dc.l $FFFE0001,$40080000,$E01E0001,$1FFFE dc.l $FFFE0001,$40080000,$E01E0001,$1FFFE dc.l $FFFE0001,$40080000,$FFFE0001,$1FFFE dc.l $FFFE0001,$7FF80000,$FFFE0001,$1FFFE dc.l $FFFE0001,$0,$FFFE0001,$1FFFE dc.l $FFFE0001,$1FF80000,$FFFE0001,$1FFFE dc.l $FFFE0001,$1FE80000,$F01E0001,$1FFFE dc.l $FFFE0001,$19E80000,$F61E0001,$1FFFE dc.l $FFFE0001,$19E80000,$F61E0001,$1FFFE dc.l $FFFE0001,$19E80000,$F61E0001,$1FFFE dc.l $FFFE0001,$1FE80000,$F01E0001,$1FFFE end


 