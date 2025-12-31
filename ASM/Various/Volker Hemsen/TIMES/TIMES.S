********************************************************************************
**                                                                            **
**                     U L T I   T I M E S +   V 1 . 0                        **
**                                                                            **
**          DAS (ULTIMATIVE) AUTOSTARTER PROGRAMM - PUBLIC DOMAIN             **
**                                                                            **
********************************************************************************
**                                                                            **
**       erstellt mit TurboAss V1.53  im Sept 1991  von Volker Hemsen         **
**                                                                            **
**    Funktion:  if TIME<00:05:00 : gemdos-time abfragen                      **
**               else xbios-time abfragen und gemdos-time stellen             **
**                                                                            **
**               if XBRA RSHC=false and XBRA RSBT=false:                      **
**                            Warmstart auf Alt+LShift+Help                   **
**                  if you will das: Doodle-Save auf Alt+Help                 **
**               else if XBRA RSHC=false and you will das:                    **
**                                   Doodle-Save auf Alt+Help                 **
**                                                                            **
********************************************************************************

                OPT F+

                TEXT
res_start:      linea   #10 [ Hidem ]
                bra     nonres_start

                >PART 'HARDCOPY'
                DC.L 'XBRA'
                DC.L 'RSBT'
hc_old_vec:     DS.L 1
boot_start:     move.w  #-1,-(SP)
                move.w  #11,-(SP)       ;kbshift
                trap    #13
                addq.l  #4,SP
                btst    #1,D0           ;Shift left?
                beq.s   weiter2
                movea.l $04F2.w,A0      ;Warmboot
                jmp     (A0)
weiter2:        movea.l hc_old_vec(PC),A0
                jmp     (A0)

                DC.L 'XBRA'
                DC.L 'RSHC'
hc_old_vec2:    DS.L 1
hc_start:       linea   #0 [ Init ]     ;Bildschirmgrîûe
                moveq   #0,D6
                move.w  2(A0),D6
                mulu    -4(A0),D6

                clr.w   -(SP)           ;dfree()
                pea     dfree(PC)
                move.w  #54,-(SP)
                trap    #1
                addq.l  #8,SP
                tst.w   D0
                blt.s   hc_ende
                lea     dfree(PC),A0
                move.l  (A0),D0         ;Anz. freier Cluster
                mulu    14(A0),D0       ;* Sekt/Cluster
                mulu    10(A0),D0       ;* Bytes/Sekt
                cmp.l   D6,D0           ;genug Platz?
                blt.s   hc_ende

                linea   #10 [ Hidem ]   ;string mit nummer setzen
                lea     dat_name(PC),A0
                addq.b  #1,6(A0)

                clr.w   -(SP)           ;fcreate()
                move.l  A0,-(SP)
                move.w  #60,-(SP)
                trap    #1
                addq.l  #8,SP
                move.w  D0,D7
                tst.w   D0
                blt.s   hc_ende

                move.w  #3,-(SP)        ;logbase()
                trap    #14
                move.l  D0,-(SP)        ;fwrite()
                move.l  D6,-(SP)
                move.w  D7,-(SP)
                move.w  #64,-(SP)
                trap    #1
                move.w  D7,-(SP)        ;fclose()
                move.w  #62,-(SP)
                trap    #1
                lea     18(SP),SP       ;2+12+4

hc_ende:        linea   #9 [ Showm ]
                rts

dat_name:       DC.B 'SCREEN@.DOO',0
dfree:          DS.L 4          ;4*4 Bytes
                ENDPART

nonres_start:
                >PART 'TIME_INSTALL'
                move.w  #23,-(SP)       ;bgettime()
                trap    #14
                addq.l  #2,SP
                move.l  D0,D7
                bclr    #15,D0
                cmpi.w  #160,D0         ;Zeit unter 5 Minuten?
                bmi.s   setzen
                lea     text5(PC),A0    ;Text ausgeben
                bsr     cconws
                move.w  D7,-(SP)
                move.w  #45,-(SP)       ;tsettime()
                trap    #1
                addq.l  #4,SP
                move.l  D7,-(SP)
                move.w  #43,-(SP)       ;tsetdate()
                trap    #1
                addq.l  #6,SP
                bra.s   weiter1

setzen:         moveq   #0,D6
                moveq   #0,D5
                moveq   #0,D0
                bsr     haupt

                pea     curser_aus(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                ENDPART

                >PART 'HC_INSTALL und ENDE'
weiter1:        lea     xbra_test(PC),A0
                bsr.s   supexec
                lea     hc_text(PC),A0  ;Zeichenkette ausgeben
                bsr     cconws
                bsr     cconin          ;Frage
                bclr    #5,D0
                cmpi.b  #74,D0          ;J???
                bne.s   nur_boot
                lea     hc_inst_text(PC),A0
                bsr     cconws
alles_neu:      lea     alles_lpoke(PC),A0 ;alles installieren und Ende
                bsr.s   supexec
                clr.w   -(SP)
                pea     $0100+nonres_start-res_start.w
                bra.s   ptermres

nur_boot:       lea     boot_lpoke(PC),A0 ;nur Boot installieren und Ende
                bsr.s   supexec
                clr.w   -(SP)
                pea     $0100+hc_start-res_start.w
ptermres:       move.w  #49,-(SP)
                bra.s   pterm

alles_da:       lea     alles_da_text(PC),A0
                bsr     cconws
ende:           clr.w   -(SP)
pterm:          linea   #9 [ Showm ]
                trap    #1
                ENDPART

                >PART 'XBRA und SUPER'
supexec:        move.l  A0,-(SP)
                move.w  #38,-(SP)
                trap    #14
                addq.l  #6,SP
                rts

xbra_test:      movea.l $0502.w,A0      ;XBRA-BOOT
                cmpi.l  #'XBRA',-12(A0)
                bne.s   xbra_ende
                cmpi.l  #'RSBT',-8(A0)
                bne.s   xbra_ende
                movea.l -4(A0),A0       ;XBRA-HC
                cmpi.l  #'XBRA',-12(A0)
                bne.s   xbra_ende
                cmpi.l  #'RSHC',-8(A0)
                bne.s   xbra_ende
                lea     alles_da(PC),A0 ;hier weiter
                move.l  A0,(SP)
xbra_ende:      rts

alles_lpoke:    lea     hc_old_vec2(PC),A0
                lea     boot_start(PC),A1
                move.l  $0502.w,(A0)+   ;original retten
                move.l  A1,$0502.w      ;neuen boot_vec setzen
                move.l  A0,-4(A1)       ;neuen hc_vec setzen
                rts
boot_lpoke:     lea     hc_old_vec(PC),A0
                move.l  $0502.w,(A0)+   ;alten Vektor retten
                move.l  A0,$0502.w      ;neuen setzen
                rts
                ENDPART


                >PART 'TIMEDATE'
haupt:          lea     text0(PC),A0    ;Strings ausgeben
                bsr.s   cconws

                lea     date(PC),A3     ;Datum abfragen
                lea     textinp1(PC),A4
                bsr.s   input
                cmpi.b  #27,D4
                beq.s   inp_ende

                lea     text4(PC),A0    ;Uhrzeit abfragen
                bsr.s   cconws
                lea     time(PC),A3
                lea     textinp2(PC),A4
                bsr.s   input
                cmpi.b  #27,D4
                bne.s   settime
inp_ende:       rts

bs:             lea     old_pos(PC),A0  ;Datum/Zeit-Eingabe
                bsr.s   cconws
input:          movea.l A4,A5
                movea.l A3,A6
inploop:        move.b  (A5)+,D5
                bra.s   char_inp
backspace:      move.w  #8,D0           ;Backspace
                bsr.s   cconout
char_inp:       bsr.s   cconin
                move.b  D0,D4           ;retten
                cmpi.b  #27,D0          ;ESC???
                beq.s   esc_inpende
                cmpi.b  #8,D0           ;BS???
                beq.s   bs
                cmp.b   D5,D0           ;mit max_char vergleichen
                bpl.s   char_inp
                subi.b  #48,D0
                move.b  D0,(A6)+        ;merken
                move.b  (A5)+,D0        ;EinfÅgezeichen holen
                cmpi.b  #$FF,D0
                beq.s   inpende
                cmpi.b  #0,D0
                beq.s   inploop
                bsr.s   cconout
                bra.s   inploop
inpende:        rts
esc_inpende:    moveq   #107,D0

cconws:         move.l  A0,-(SP)
                move.w  #9,-(SP)        ;cconws
                trap    #1
                addq.l  #6,SP
                rts
cconin:         move.w  #1,-(SP)
                trap    #1
                addq.l  #2,SP
                rts
cconout:        move.w  D0,-(SP)
                move.w  #2,-(SP)        ;cconout
                trap    #1
                addq.l  #4,SP
                rts

settime:        moveq   #0,D0
                lea     date(PC),A0
                bsr.s   char_byte       ;Tag holen
                move.b  D4,D0
                bsr.s   char_byte       ;Monat holen
                lsl.w   #5,D4
                add.w   D4,D0
                bsr.s   char_byte       ;Jahr holen
                sub.w   #80,D4
                mulu    #512,D4         ;lsl #9,
                add.w   D4,D0
                move.w  D0,-(SP)
                move.w  #43,-(SP)       ;tsetdate
                trap    #1
                addq.l  #4,SP

                moveq   #0,D0
                lea     time(PC),A0
                bsr.s   char_byte       ;Stunden holen
                mulu    #2048,D4
                move.w  D4,D0
                bsr.s   char_byte       ;Minuten holen
                lsl.w   #5,D4
                add.w   D4,D0
                move.w  D0,-(SP)
                move.w  #45,-(SP)       ;tsettime
                trap    #1
                addq.l  #4,SP
                rts

char_byte:      moveq   #0,D4
                move.b  (A0)+,D4
                mulu    #10,D4
                add.b   (A0)+,D4
                rts

                ENDPART


                DATA
text0:          DC.B 27,69,27,101,27,89,34,40,27,112
                DC.B ' Ulti Times+ V1.0 ',27,113
                DC.B 27,89,36,37,"(c) 1991 by RÅby Software"
                DC.B 27,89,39,41
                DC.B 'Date: ',27,106,'__.__.__',27,107,27,106,0
text4:          DC.B 27,89,41,41,'Time: ',27,106,'__:__:00'
old_pos:        DC.B 27,107,27,106,0
text5:          DC.B 27,69,27,89,36,40,'Uhrzeit wird gestellt.',0
curser_aus:     DC.B 27,102,0

textinp1:       DC.B 52,0,58,46,50,0,58,46,58,0,58,$FF
textinp2:       DC.B 51,0,58,58,54,0,58,$FF

hc_text:        DC.B 27,89,44,41
                DC.B 'Reset Åber Alt+Shift+Help'
                DC.B 27,89,46,41
                DC.B 'Doodle-Save Åber Alt+Help',27,89,48,41
                DC.B 'Installieren(J/N)?',0

hc_inst_text:   DC.B 27,89,50,41,'Ok, wird erledigt.',10,13,0
alles_da_text:  DC.B 27,89,50,41,'Ist schon alles installiert.',10,13,0

                BSS
date:           DS.L 2
time:           DS.W 3
                END
