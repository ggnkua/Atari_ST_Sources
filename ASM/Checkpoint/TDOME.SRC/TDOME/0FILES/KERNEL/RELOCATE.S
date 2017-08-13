; A0...prg
relocate:       >PART

                movem.l D0-D3/A0-A1,-(SP)

                lea     2(A0),A1
                lea     $001C(A0),A0
                move.l  A0,D0

                adda.l  (A1)+,A0        ; text
                adda.l  (A1)+,A0        ; data
                lea     (A0),A3         ; BSS Start
                move.l  (A1)+,D3        ; bss
                adda.l  (A1)+,A0        ; rest  (symboltable)

                move.l  (A0)+,D1        ;relocation info ??
                beq.s   end_relocation  ;nope...
                movea.l D0,A1           ; text start
                adda.l  D1,A1           ;1st adress - long offset
                moveq   #0,D1
                moveq   #1,D2
relo_do:
                add.l   D0,(A1)         ;relocate!
RELO2:
                move.b  (A0)+,D1
                beq.s   end_relocation
                cmp.b   D2,D1
                bne.s   normal_distance
                lea     254(A1),A1
                bra.s   RELO2
normal_distance:
                adda.l  D1,A1
                bra.s   relo_do
end_relocation:
                movem.l (SP)+,D0-D3/A0-A1
                rts
                ENDPART

