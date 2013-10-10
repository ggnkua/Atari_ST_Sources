 dc.w $a00a
 lea $78000,a0
 move #$1f40,d0
jompa:
 clr.l (a0)+
 dbra d0,jompa 
main:
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,pointeursuperviseur
 move.b $ff8201,d0
 lsl.w #8,d0
 move.b $ff8203,d0
 lsl.l #8,d0
 movea.l d0,a0
 move.b -$5f9,d5
 move.b -$5f7,d7
 clr.b -$5f9
 clr.b -$5f7
 move.b #2,$ff820a
 move.l $68,a0
 move.l $70,a6
 lea hbl(pc),a1
 move.l a1,$68
 lea vbl(pc),a1
 move.l a1,$70
 and.w #$f8ff,sr
 moveq.b #-1,d0          ; Sens de d‚placement de la barre
 moveq.b #0,d1            ; Positionnement de la barre
 suba.l a1,a1
finprovisoire:
 cmpi.b #$b9,$fffc02
 beq sortie
 cmpi.b #$39,$fffc02
 beq sortie
 jmp finprovisoire(pc)
hbl:                    ; Ne pas modifier les registres d5,d7,a0,a6
 dc.l $4e714e71
 addq #1,d2
 tst d3
 bne okay
 cmp d2,d1
 bne tanpi
 moveq #$d,d3
 lea barre,a1
okay:
 rept 85
 dc.w $4e71
 endr
 move (a1)+,$ff8240
 subq #1,d3
tanpi:
 rte
vbl:
 moveq #0,d2
 tst d0
 bne.s descend
monte:
 subq #1,d1
 cmp #25,d1
 bne.s hop 
 moveq #-1,d0
hop:
 rte
descend:
 addq #1,d1
 cmp #280,d1
 bne.s hop
 moveq #0,d0
 rte
sortie:
 or.w #$300,sr
 move.b d7,-$5f7
 move.b d5,-$5f9
 move.l a0,$68
 move.l a6,$70
 and.w #$f8ff,sr          ; La couleur doit etre remise en ‚tat
 move #$777,$ff8240
 move.l pointeursuperviseur(pc),-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 dc.w $a009
 clr.l -(a7)
 trap #1
pointeursuperviseur:
 dc.l 0
barre:
 dc.w 1,2,3,4,5,6,7,6,5,4,3,2,1
end
