; PRTKL881 - Protokoll fÅr M68881 - Version 1.0
; programmiert von Volker Hemsen, August 1993, Public Domain

; Dieses Programm ist Public Domain! Es ist unverkÑuflich und darf von jeder-
; man benutzt und kopiert werden. Es ist unverkÑuflich!
; Hiermit wird ausdrÅcklich erlaubt, den Quellcode zu verÑndern und zu
; erweitern!
; Folgende Befehle werden nicht bearbeitet:
; fscc, fdbcc, ftrapcc, fbcc.l, fsave, frestore, fmovem
; verwendete Literatur: Atari Profibuch ST-STE-TT, Sybex Verlag


fpstat            EQU $FFFFFA40           ; status register.w (R)
fpctl             EQU $FFFFFA42           ; control register.w (W)
fpsave            EQU $FFFFFA44           ; save register.w (R)
fprestor          EQU $FFFFFA46           ; restore register.w (R/W)
;fpopw           EQU $FFFFFA48   ; operation word register (?).w
fpcmd             EQU $FFFFFA4A           ; command register.w (W)
;fpres           EQU $FFFFFA4C   ; reserved.w
fpccr             EQU $FFFFFA4E           ; condition code register.w (W)
fpop              EQU $FFFFFA50           ; operand register.l (R/W)
fpselct           EQU $FFFFFA54           ; register select.w (R)
fpiadr            EQU $FFFFFA58           ; instruction address.l (W)


                  TEXT

                  movea.l 4(SP),A0        ;Adresse der Basepage
                  move.l  #$0100,D0       ;LÑnge der Basepage
                  add.l   $0C(A0),D0      ;LÑnge des Textsegmentes
                  add.l   $14(A0),D0      ;LÑnge des Datasegmentes
                  add.l   $1C(A0),D0      ;LÑnge der BSS
                  clr.w   -(SP)           ;Returnparameter
                  move.l  D0,-(SP)        ;LÑnge Åbergeben
                  move.w  #$31,-(SP)      ;Ptermres()

                  pea     hallo(PC)
                  move.w  #9,-(SP)
                  trap    #1
                  addq.l  #6,SP

                  pea     linef_patch(PC)
                  move.w  #$26,-(SP)
                  trap    #14
                  addq.l  #6,SP

                  trap    #1


linef_patch:      move.l  $2C.w,old_linef
                  move.l  #my_linef,$2C.w
                  rts

                  DC.L 'XBRA'
                  DC.L 'P881'
old_linef:        DC.L 0
my_linef:         movem.l D0-A6,register
                  movea.l SP,A0           ;SP korrigieren
                  subq.l  #6,A0
                  move.l  A0,adressreg_sp
                  movea.l 2(SP),A6        ;a6=Returnadresse
                  move.l  A6,op_pc
                  move.w  (A6)+,D7        ;d7=opcode
                  move.w  D7,fpctl.w
                  move.w  D7,D0
                  andi.w  #$01C0,D0
                  tst.w   D0
                  beq.s   gruppe000
                  cmpi.w  #$40,D0
                  beq.s   gruppe001
                  cmpi.w  #$80,D0
                  beq.s   gruppe010
                  bra.s   gruppe_ende
gruppe001:        swap    D7
                  move.w  (A6)+,D7
                  move.w  D7,fpccr.w
                  bra.s   gruppe_ende
gruppe010:        move.w  D7,D0
                  andi.w  #$3F,D0
                  move.w  D0,fpccr.w
                  bra.s   gruppe_ende
gruppe000:        swap    D7
                  move.w  (A6)+,D7
                  move.w  D7,fpcmd.w      ;LowWord
gruppe_ende:      bsr.s   response
                  move.l  A6,2(SP)
                  movem.l register(PC),D0-A6
                  rte

response:         move.w  fpstat.w,D6     ;status
                  move.w  D6,D0
                  and.w   #$36FC,D0       ;eigentlich $3EFC
                  tst.w   D0
                  beq.s   resp_null
                  move.w  D6,D0
                  and.w   #$1800,D0
                  cmp.w   #$1000,D0
                  beq.s   resp_transdata
                  move.w  D6,D0
                  and.w   #$1FF0,D0
                  cmp.w   #$0C00,D0
                  beq.s   resp_transcpureg
                  move.w  D6,D0
                  and.w   #$1F00,D0
                  cmp.w   #$0100,D0
                  beq     resp_transfpureg
resp_ende:        btst    #15,D6          ;Come again-Bit auf 0 prÅfen
                  bne.s   response
                  btst    #1,D6           ;Process-Finished-Bit auf 1 testen
                  beq.s   response
                  rts

resp_null:        btst    #0,D6           ;True/False-Bit
                  bne.s   resp_null_sprung
                  bra.s   resp_ende
resp_null_sprung: adda.w  (A6),A6         ;nur .w-SprÅnge
                  bra.s   resp_ende

resp_transdata:   moveq   #0,D5           ;d5=LÑnge
                  move.b  D6,D5
                  bsr.s   getea
                  btst    #13,D6          ;Datenrichtung
                  beq.s   resp_tdwrite
                  cmp.b   #1,D5
                  beq.s   resp_tdreadb
                  cmp.b   #2,D5
                  beq.s   resp_tdreadw
resp_tdreadl:     move.l  fpop.w,(A0)+
                  subq.b  #4,D5
                  bgt.s   resp_tdreadl
                  bra.s   resp_ende
resp_tdreadb:     move.b  fpop.w,(A0)
                  bra.s   resp_ende
resp_tdreadw:     move.w  fpop.w,(A0)
                  bra.s   resp_ende
resp_tdwrite:     cmp.b   #1,D5
                  beq.s   resp_tdwriteb
                  cmp.b   #2,D5
                  beq.s   resp_tdwritew
resp_tdwritel:    move.l  (A0)+,fpop.w
                  subq.b  #4,D5
                  bgt.s   resp_tdwritel
                  bra.s   resp_ende
resp_tdwriteb:    move.b  (A0),fpop.w
                  bra.s   resp_ende
resp_tdwritew:    move.w  (A0),fpop.w
                  bra.s   resp_ende

resp_transcpureg: lea     register(PC),A0
                  move.w  D6,D0
                  lsl.w   #2,D0
                  ext.l   D0
                  adda.l  D0,A0
                  btst    #13,D6          ;Datenrichtung
                  beq.s   resp_tcrwrite
                  move.l  fpop.w,(A0)
                  bra     resp_ende
resp_tcrwrite:    move.l  (A0),fpop.w
                  bra     resp_ende

resp_transfpureg:
                  bra     resp_ende

getea:            move.l  D7,D0           ;opcode
                  move.w  D7,D2
                  lsr.w   #8,D2
                  lsr.w   #2,D2
                  and.w   #%111,D2        ;d2 = g : LÑngencodierung
                  swap    D0
                  move.w  D0,D1
                  and.w   #%111,D1        ;d1 = R : Register
                  lsr.w   #3,D0
                  and.w   #%111,D0        ;d0 = M : Modus
                  lsl.w   #2,D0
                  lea     getea_adr(PC),A0 ;weitere Routine nach
                  movea.l 0(A0,D0.w),A0   ;Modus auswÑhlen
                  jmp     (A0)

getea_d:          lea     datenreg(PC),A0 ;Datenregister direkt
                  lsl.w   #2,D1
                  cmpi.w  #%110,D2        ;byte?
                  bne.s   getea_dnob
                  addq.l  #3,A0
getea_dnob:       cmpi.w  #%100,D2
                  bne.s   getea_dnow
                  addq.l  #2,A0
getea_dnow:                               ;ext.l   D1
                  adda.w  D1,A0
                  rts

getea_a:          bset    #3,D1           ;Adressregister direkt
                  bra.s   getea_d

getea_ai:         lea     adressreg(PC),A1 ;Adressregister indirekt
                  lsl.w   #2,D1
                  movea.l 0(A1,D1.w),A0
                  rts
getea_aip:        bsr.s   getea_ai        ;Adressregister indirekt (a)+
                  add.l   D5,0(A1,D1.w)
                  rts
getea_aim:        bsr.s   getea_ai        ;Adressregister indirekt -(a)
                  sub.l   D5,0(A1,D1.w)
                  suba.l  D5,A0
                  rts
getea_aid:        bsr.s   getea_ai        ;Adressregister indirekt d(a)
                  adda.w  (A6)+,A0
                  rts
getea_aidr:       bsr.s   getea_ai        ;Adressregister indirekt d(a,r.?)
;folgendes gilt auch fÅr d(pc,r.?)
getea_eidr:       move.w  (A6)+,D1        ;Zusatzwort holen
                  move.w  D1,D0           ;offset addieren
                  ext.w   D0
                  adda.w  D0,A0
                  move.w  D1,D0
                  rol.w   #6,D0           ;Registernummer extrahieren und *4
                  and.w   #%111100,D0
                  lea     register(PC),A1
                  adda.w  D0,A1
                  btst    #11,D1
                  bne.s   getea_aidrl
                  adda.w  2(A1),A0
                  rts
getea_aidrl:      adda.l  (A1),A0
                  rts

getea_erweitert:  lea     getea_adrerw(PC),A0
                  lsl.w   #2,D1
                  movea.l 0(A0,D1.w),A0   ;weitere Routine nach
                  jmp     (A0)            ;Register auswÑhlen

getea_wadr:       suba.l  A0,A0           ;Speicher direkt, kurz
                  movea.w (A6)+,A0
                  rts
getea_ladr:       movea.l (A6)+,A0        ;Speicher direkt, lang
                  rts
getea_pcd:        movea.l A6,A0           ;a6 ist neuer PC!
                  adda.w  (A6)+,A0
                  rts
getea_pcdr:       movea.l A6,A0
                  bra.s   getea_eidr

getea_konst:      movea.l A6,A0           ;Adresse holen
                  adda.l  D5,A6           ;A6 weiterschalten
                  cmpi.w  #1,D5           ;auf BytelÑnge testen
                  bne.s   getea_konstrts
                  addq.l  #1,A0
                  addq.l  #1,A6
getea_konstrts:   rts


                  DATA
getea_adr:        DC.L getea_d            ;0
                  DC.L getea_a            ;1
                  DC.L getea_ai           ;2
                  DC.L getea_aip          ;3
                  DC.L getea_aim          ;4
                  DC.L getea_aid          ;5
                  DC.L getea_aidr         ;6
                  DC.L getea_erweitert    ;7
getea_adrerw:     DC.L getea_wadr         ;7,0
                  DC.L getea_ladr         ;7,1
                  DC.L getea_pcd          ;7,2
                  DC.L getea_pcdr         ;7,3
                  DC.L getea_konst        ;7,4


hallo:            DC.B '
p PRTKL881 - Softwareprotokoll fÅr M68881 - Version 1.0'
                  DC.B 'q
entwickelt von Volker Hemsen, August 1993, Public Domain'
                  DC.B '
',0

                  BSS
register:
datenreg:         DS.L 8                  ;Platz fÅr 8 Datenregister
adressreg:        DS.L 7                  ;Platz fÅr 7 Adreûregister
adressreg_sp:     DS.L 1                  ;Platz fÅr korrigierten Stackpointer
op_pc:            DS.L 1                  ;Programmcounter bei Exeption


                  END
