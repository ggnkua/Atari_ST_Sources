;
;Short "load 'n patch" program to make the DBAMAG10 run from da harddisks
; ½ by SCY of TSCC 18.09.94   assembler used: TurboAss 1.7
;   Contact TSCC:
;               The Sirius Lab/TSCC WHQ
;               Ruelzheimer Str. 30a
;               76756 Bellheim/Germany
;
                OPT F+,P+,O+,W+
                OUTPUT 'DBALOAD.PRG'
                TEXT
                >PART 'main'
                movea.l 4(SP),A3
                clr.l   -(SP)           ;Supermode
                move.w  #32,-(SP)
                trap    #1
                move.l  D0,2(SP)

                movea.l $0C(A3),A0      ;Mshrink()
                adda.l  $14(A3),A0
                adda.l  $1C(A3),A0
                pea     256(A0)
                pea     (A3)
                move.l  #$4A0000,-(SP)
                trap    #1
                lea     12(SP),SP

                lea     oldtrap1(PC),A3
                st      intern-oldtrap1(A3)
                move.l  $84.w,(A3)+
                move.l  A3,$84.w

                lea     oldtrap14(PC),A3
                move.l  $B8.w,(A3)+
                move.l  A3,$B8.w

                sf      intern-trap14(A3)
                pea     0.w             ;Pexec()
                pea     cmdline(PC)
                pea     filename(PC)
                move.l  #$4B0000,-(SP)
                trap    #1
                lea     16(SP),SP

                move.l  oldtrap1(PC),$84.w
                move.l  oldtrap14(PC),$B8.w
                trap    #1              ;Usermode
                addq.l  #6,SP

                clr.w   -(SP)           ;Pterm0
                trap    #1
;-----
cmdline:        DC.W 0
filename:       DC.B 'DBAMAG10.PRG',0
                EVEN
                ENDPART
                >PART 'trap1'
                DC.L 'XBRA'
                DC.L 'LOAD'
oldtrap1:       DC.L 0
trap1:          move.w  intern(PC),D0
                bne.s   trap1_cont

                lea     6(SP),A0
                tst.w   $059E.w
                beq.s   normal
                addq.l  #2,A0
normal:         btst    #5,(SP)
                bne.s   supermode
                move    USP,A0
supermode:      move.w  (A0)+,D0
                cmp.w   #61,D0
                beq.s   fopen
                cmp.w   #78,D0
                beq.s   fopen
                cmp.w   #75,D0
                beq.s   pexec
trap1_cont:     movea.l oldtrap1(PC),A0
                jmp     (A0)
;-----
fopen:          movea.l (A0),A1
                moveq   #0,D0
                move.b  (A1)+,D0
                lsl.w   #8,D0
                move.b  (A1)+,D0
                lsl.l   #8,D0
                move.b  (A1)+,D0
                cmp.l   #'A:\',D0
                beq.s   found
                cmp.l   #'a:\',D0
                beq.s   found
                lsr.l   #8,D0
                subq.l  #1,A0
                cmp.w   #'A:',D0
                beq.s   found
                cmp.w   #'a:',D0
                bne.s   trap1_cont
found:          move.l  A1,(A0)
                bra.s   trap1_cont
;-----
pexec:          move.w  (A0)+,D0
                beq.s   fopen
                subq.w  #3,D0
                beq.s   fopen
                bra.s   trap1_cont
                ENDPART
                >PART 'trap14'
intern:         DC.W 0
                DC.L 'XBRA'
                DC.L 'LOAD'
oldtrap14:      DC.L 0
trap14:         move.w  intern(PC),D0
                bne.s   trap14_cont
                move.l  #$0BFFFF,-(SP)
                trap    #13
                addq.l  #4,SP
                and.w   #$03,D0
                beq.s   noshift
                lea     intern(PC),A0
                st      (A0)
                move.w  #%101010,-(SP)
                move.w  #88,-(SP)
                trap    #14
                addq.l  #4,SP
                lea     intern(PC),A0
                sf      (A0)
noshift:        lea     6(SP),A0
                tst.w   $059E.w
                beq.s   normal2
                addq.l  #2,A0
normal2:        btst    #5,(SP)
                bne.s   supermode2
                move    USP,A0
supermode2:     move.w  (A0)+,D0
                cmp.w   #89,D0
                beq.s   getvtype
trap14_cont:    movea.l oldtrap14(PC),A0
                jmp     (A0)
;-----
getvtype:       moveq   #1,D0           ;'simulate' VGA
                rte
                ENDPART
                END
