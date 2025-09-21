; V_GTEXTA                Volker Hemsen             Oktober 1991
; GEM-Text fÅr GFA-Basic  (schnelles TEXT X,Y,A$(x))

; (siehe auch V_GTEXT.S)

; Aufruf:
;  ~C: adr%( L:{*A$()} , X& , Y& , H& , L:VDI_BLOCK% , L:VON% , L:BIS% )
; (siehe V_GTEXT.LST)


str             EQU 4           ;={*A$()}
x               EQU 8
y               EQU 10
h               EQU 12          ;Texthîhe z.B. 8,16
vdi             EQU 14          ;Adresse auf VDI-Parameterblock
von             EQU 18          ;erstes Feld
bis             EQU 22          ;letztes Feld

contrl          EQU 0
intin           EQU 4
ptsin           EQU 8
intout          EQU 12
ptsout          EQU 16

; a2 : para_block
; a3 : contrl
; a4 : ptsin
; a5 : intin
; a6 : str_des (laufend)

; d3 : Zeilenvariable
; d4 : Hîhe

                lea     reg_save(PC),A0
                movem.l A3-A6,(A0)

                movea.l vdi(SP),A2
                movea.l (A2),A3         ;contrl
                move.l  #$080002,(A3)   ;opcode und anz_ptsin
                movea.l ptsin(A2),A4
                move.l  x(SP),(A4)      ;xy
                movea.l intin(A2),A5
                move.w  h(SP),D4

                movea.l str(SP),A6      ;str_des
                addq.l  #4,A6
                move.l  von(SP),D0
                addq.l  #1,D0
                move.l  D0,D3
                mulu    #6,D0
                adda.l  D0,A6

str_loop:       move.l  (A6)+,D0        ;str_adr
                tst.l   D0
                beq.s   test
                movea.l D0,A1
                move.w  (A6)+,D0        ;str_len
                tst.w   D0
                ble.s   test
                move.w  D0,6(A3)
                subq.w  #1,D0
                movea.l A5,A0           ;intin

loop:           clr.b   (A0)+           ;String konvertieren
                move.b  (A1)+,(A0)+
                dbra    D0,loop

                move.l  A2,D1           ;vdi_para_block
                moveq   #$73,D0
                trap    #2

test:           add.w   D4,2(A4)        ;Hîhe dazu
                addq.l  #1,D3
                cmp.l   bis(SP),D3
                ble.s   str_loop

ende:           movem.l reg_save(PC),A3-A6
                rts

reg_save:       DS.L 4
                END
