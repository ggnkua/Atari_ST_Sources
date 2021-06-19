;     Line-F-Emulator fr die Benutzung eines 68881 in einem
;     Atari-ST ohne 68020. Wenn ein 68882 benutzt wird, so mssen
;     einige kleine nderungen vorgenommen werden, da dieser an
;     einigen Stellen die šbertragung des PCs erwartet.
;     Entwickelt mit dem Assembler von Aztec, aus dem Aztec
;     Entwicklungspaket,  von Roger Butenuth
;
        far     data    ; Sonst wrde a4 fr die Adressierung
                        ; der Daten benutzt!
        ;
response  equ   $fffa40 ; In a6 (Coprozessor-Basisregister)
control   equ   $02     ; Alle weiteren Register relativ
save      equ   $04     ;   zu "response"
restore   equ   $06
command   equ   $0a     ; in a5
condition equ   $0e
operand   equ   $10     ; in a4
reg_selec equ   $14
ins_add   equ   $18
        ;
        cseg
        ;
start   move.l  #setvec,-(sp) ; Im Supervisormodus Vektor setzen
        move.w  #38,-(sp)     ; Supexec()
        trap    #14           ; XBIOS
        addq.l  #6,sp         ; Stack aufr„umen
        ;
        move.l  4(sp),a0      ; Basepageadresse holen
        move.l  #$100,d1      ; Basepagel„nge
        add.l   $0c(a0),d1    ; +Textl„nge
        add.l   $14(a0),d1    ; +Datenl„nge
        add.l   $1c(a0),d1    ; +BSS-l„nge
        move.l  d1,-(sp)      ; L„nge des belegten Speichers
        move.w  #$31,-(sp)    ;   an GEMDOS melden
        trap    #1
        ;
setvec  move.l  $2c,oldtrap   ; Alten Line-F-Vektor retten
        move.l  #newtrap,$2c  ; Neuen Line-F-Vektor setzen
        rts
        ;
newtrap move.l  d1,rd1        ; D1 retten (nur fr eigenen Trap)
        move.l  2(sp),d1      ; PC nach D1
        cmp.l   #$fc0000,d1   ; PC-ROM-Anfang
        blt.s   my_trap       ; PC<ROM-Anfang -> kam aus dem RAM
        move.l  oldtrap,a0    ; Adresse der alten Trap-Routine
        jmp     (a0)          ; Alte Routine anspringen
        ;
my_trap move.l  rd1,d1        ; D1 zurckholen
        movem.l d0-a6,dregs   ; Register retten
        move.l  usp,a0        ; USP retten
        move.l  a0,rusp       ; (geht nur ber Umweg)
        lea     response,a6    ; #response nach A6
        lea     command(a6),a5 ; #command  nach A5
        lea     operand(a6),a4 ; #operand  nach A4
        lea     dregs,a3       ; #dregs    nach A3
        move.l  2(sp),a0      ; PC nach A0
        move.w  (a0),d1       ; Kommando nach D1
again           ;------- Einsprung fr weitere FPU-Befehle
        and.w   #%0000000111000000,d1 ; Spezialteil ausmaskieren
        bne     spezial       ; Ein Bit gesetzt -> Spezialbefehl
        move.w  2(a0),d1      ; Zweiten Befehlsteil in D1 merken
        move.w  d1,(a5)       ; Befehl in FPU schr. (A5==#command)
do_ca           ;------- Einsprung fr weitere Nachfragen an FPU
        move.w  (a6),d0       ; Response lesen
        btst    #12,d0        ; Erstes Modusbit testen
        bne     rw_1x         ; ==1 -> springen
        btst    #11,d0        ; Zweites Modusbit testen
        beq.s   rw_00         ; ==0 -> springen
        ;----- %xxx01, Null-Primitive/Transfer Single CPU-Register
        btst    #10,d0        ; Register bertragen?
        bne.s   rw_sngl       ; Ja -> Transfer Single CPU-Register
        btst    #15,d0        ; CA (Come Again) gesetzt?
        bne.s   do_ca         ; Ja -> weiter fragen, sonst fertig
        addq.l  #4,a0         ; A0 um reine Befehlsl„nge weiter
                       ; (Alles andere wurde in calc_add erledigt)
        move.w  (a0),d1       ; Erstes Befehlswort holen
        move.w  d1,d0         ;   und nach d0
        and.w   #$f000,d0     ; Wieder COP-Befehl?
        eor.w   #$f000,d0     ;
        beq.s   again         ; Ja -> direkt weitermachen
        move.l  a0,2(sp)      ; Neuen PC eintragen
        move.l  rusp,a0       ; USP wiederherstellen
        move.l  a0,usp        ;   (Geht nur ber Umweg)
        movem.l (a3),d0-a6    ; Register wiederherstellen
        rte                   ; Trap beenden
        ;
rw_sngl and.w   #%1110000,d1 ;Registernummer ausmaskieren (nur Dn)
        lsr.w   #2,d1         ; D1=Nummer*4
        move.l  (a3,d1.w),(a4) ; Register bertragen 
                               ; (a4==#operand, a3==#dregs)
        bra.s   do_ca         ; Danach kommt immer noch etwas
        ;
rw_00   ;----- %xxx00, Transfer multiple coprozessor Reg.
        bsr     calc_add      ; Operandenadresse nach A1 holen
        move.w  reg_selec(a6),d4 ; Registerliste nach D4 holen
        btst    #13,d0        ; Dr-Bit testen
        beq.s   w_00          ; ==0 -> Daten in FPU schreiben
        ;
        btst    #12,d0        ; Predekrementmodus?
        beq.s   r_pred        ; ==0 -> ja, springen
        ;
        moveq   #7,d0         ; Schleifenz„hler fr 8 Bits
        ;
1$      lsl.w   #1,d4         ; Ein Bit ins Carry
        bcc.s   2$            ; Nur bei Bit==1 etwas machen
        move.l  (a4),(a1)+    ; 1  (A4==#operand)
        move.l  (a4),(a1)+    ; 2
        move.l  (a4),(a1)+    ; 3 Langworte fr jedes Register
2$      dbra    d0,1$         ; Fr alle 8 Bits
        ;
        bra     do_ca         ; Nochmal FPU befragen
        ;
r_pred  moveq   #7,d0         ; Schleifenz„hler fr 8 Bits
        ;
1$      lsl.w   #1,d4         ; Ein Bit ins Carry
        bcc.s   2$            ; Nur bei Bit==1 etwas machen
        move.l  (a4),(a1)+    ; 1  (A4==#operand)
        move.l  (a4),(a1)+    ; 2
        move.l  (a4),(a1)+    ; 3 Langworte fr jedes Register
        suba.w  #24,a1        ; Dekrement durchfhren
2$      dbra    d0,1$         ; Fr alle 8 Bits
        ;
        adda.w  #12,a1        ; A1 wieder auf letztes Register
        move.l  a1,(a2)       ; A1 als Registerinhalt abspeichern
        bra     do_ca         ; Nochmal FPU befragen
        ;
w_00    move.w  (a0),d0       ; Erstes Befehlswort holen
        and.b   %111000,d0    ; Adressierungsart maskieren
        cmp.b   %011000,d0    ; Gleich (An)+ ?
        beq.s   w_post        ; Ja -> Postinkrementmodus
        ;
        moveq   #7,d0         ; Schleifenz„hler fr 8 Bits
        ;
1$      lsl.w   #1,d4         ; Ein Bit ins Carry
        bcc.s   2$            ; Nur bei Bit==1 etwas machen
        move.l  (a1)+,(a4)    ; 1  (A4==#operand)
        move.l  (a1)+,(a4)    ; 2
        move.l  (a1)+,(a4)    ; 3 Langworte fr jedes Register
2$      dbra    d0,1$         ; Fr alle 8 Bits
        ; 
        bra     do_ca         ; Nochmal FPU befragen
        ;
w_post  suba.w  #12,a1        ; Inkrement von calc_add aufheben
        moveq   #7,d0         ; Schleifenz„hler fr 8 Bits
        ;
1$      lsl.w   #1,d4         ; Ein Bit ins Carry
        bcc.s   2$            ; Nur bei Bit==1 etwas machen
        move.l  (a1)+,(a4)    ; 1  (A4==#operand)
        move.l  (a1)+,(a4)    ; 2
        move.l  (a1)+,(a4)    ; 3 Langworte fr jedes Register
2$      dbra    d0,1$         ; Fr alle 8 Bits
        ;
        move.l  a1,(a2)       ; A1 als Registerinhalt abspeichern
        bra     do_ca         ; Nochmal FPU befragen
        ;
rw_1x   btst    #11,d0        ; Zweites Modusbit testen
        bne.s   rw_11         ; ==1 -> springen (TRAP, Error)
        btst    #13,d0        ; DR-Bit testen
        beq.s   w_10          ; ==0 -> Daten an FPU schreiben
        ;----- %xx110, evaluate effective adress and transfer data
        bsr     calc_add      ; Operandenadresse berechnen
                        ; A1=Operandenadresse, d1.l=Operandenl„nge
        cmp.w   #2,d1         ; L„nge-2
        ble.s   r_bw          ; <=2 -> Wort- oder Byteoperand
        ;
r_ll    move.l  (a4),(a1)+    ; Ein Langwort lesen (a4==#operand)
        subq.l  #4,d1         ;   und runterz„hlen
        bgt.s   r_ll          ; >0 -> weiter bertragen
        bra     do_ca         ; Nochmal FPU befragen
        ;
r_bw    btst    #0,d1         ; Byte?
        bne.s   r_byte        ; Ja!
        move.w  (a4),(a1)     ; Word-Operand lesen (A4==#operand)
        bra     do_ca         ; Nochmal FPU befragen
        ;
r_byte  move.b  (a4),(a1)     ; Byte-Operand lesen (A4==#operand)
        bra     do_ca         ; Nochmal FPU befragen
        ;
w_10    ;----- %xx010, evaluate effective adress and transfer data
        bsr     calc_add      ; Operandenadresse berechnen
                        ; A1=Operandenadresse, D1.l=Operandenl„nge
        cmp.w   #2,d1         ; L„nge-2
        ble.s   w_bw          ; <=2 -> Wort- oder Byteoperand
w_ll    move.l  (a1)+,(a4)    ; Langwort schreiben (A4==#operand)
        subq.l  #4,d1         ;   und runterz„hlen
        bgt.s   w_ll          ; >0 -> weiter bertragen
        bra     do_ca         ; Nochmal FPU befragen
        ;
w_bw    btst    #0,d1         ; Byte?
        bne.s   w_byte        ; Ja!
        move.w  (a1),(a4)     ; Wort schreiben (A4==#operand)
        bra     do_ca         ; Nochmal FPU befragen
        ;
w_byte  move.b  (a1),(a4)     ; Byte schreiben (A4==#operand)
        bra     do_ca         ; Nochmal FPU befragen
        ;
rw_11   ;----- %xxx11, take pre-instruction exception
        bra     cop_error     ; Error-Handler anspringen
        ; (Hier k”nnte man eine genauere Fehleranalyse machen.)
        ;
spezial                 ; Sprungbefehle etc.
        cmp.w   #%001000000,d1 ; FScc, FDBcc oder FTRAPcc
        beq.s   s_trap
        cmp.w   #%010000000,d1 ; Branch mit 16-Bit-Offset
        beq     s_br16
        eor.w   #%011000000,d1 ; Branch mit 32-Bit-Offset
        beq     s_br32
        bra     cop_error     ; FSAVE / FRESTORE nicht untersttzt
        ;
s_trap  move.w  (a0),d0       ; Erstes Befehlswort nach D0
        move.w  d0,d1         ;   und nach D1 retten
        and.w   #%111000,d0   ; Wichtige Bits ausmaskieren
        cmp.w   #%001000,d0   ; FDBcc?
        beq.s   s_fdbcc       ; Ja -> springen
        cmp.w   #%111000,d0   ; FTRAP?
        beq     cop_error     ; Ja -> Fehler (nicht untersttzt)
                              ; Sonst FScc
        move.w  2(a0),condition(a6) ; Bedingung an FPU schicken
        moveq   #1,d0         ; Operandenl„nge=1 (fr calc_add)
        bsr     calc_add      ; Operandenadresse berechnen
        ;
1$      move.w  (a6),d0       ; Response lesen
        btst    #8,d0         ; IA-Bit testen
        beq.s   2$            ; ==0 -> fertig
        and.w   #%1100000000000,d0 ; Bits 11 und 12 ausmaskieren
        eor.w   #%1100000000000,d0 ; Beide gesetzt?
        bne.s   1$            ; Nicht beide ==1 -> warten
        bra     cop_error     ; Sonst ist Exception aufgetreten
        ;
2$      btst    #0,d0         ; Antwortbit testen
        sne     (a1)          ; Je nach Bit setzen/l”schen
        bra     do_ca         ; Nochmal FPU befragen
        ;
s_fdbcc move.w  2(a0),condition(a6) ; Bedingung an FPU schicken
        and.w   #%111,d1      ; Registernummer maskieren (D1=(A0))
        lsl.w   #2,d1         ; D1=Nummer*4
        lea     (a3,d1.w),a1  ; A1 enth„lt Adresse des Datenreg.
        move.l  (a1),d1       ; Dn holen
        subq.w  #1,d1         ; Dn=Dn-1
        move.l  d1,(a1)       ; Dn zurckschreiben
        move.l  a0,a2         ; alten PC nach A2 holen
        addq.l  #2,a0         ; PC 2 weiter (fr "nicht springen")
        ;
1$      move.w  (a6),d0       ; Response lesen
        btst    #8,d0         ; IA-Bit testen
        beq.s   2$            ; ==0 -> fertig
        and.w   #%1100000000000,d0 ; Bits 11 und 12 ausmaskieren
        eor.w   #%1100000000000,d0 ; Beide gesetzt?
        bne.s   1$            ; Nicht beide ==1 -> warten
        ;
        bra     cop_error     ; Sonst ist Exception aufgetreten
        ;
2$      btst    #0,d0         ; Antwortbit testen
        bne     do_ca         ; True -> das war's schon
        adda.w  4(a2),a2      ; 16-Bit Sprungdist. add. (A2=PC)
        addq.w  #1,d1         ; Dn==-1 ?
        beq     do_ca         ; Ja -> kein Sprung (Schleifenende)
        move.l  a2,a0         ; Sonst "Sprung" (neuen pc laden)
        bra     do_ca         ; Nochmal FPU befragen
        ;
s_br16  move.w  (a0),condition(a6) ; Bedingung an FPU schicken
        ;
1$      move.w  (a6),d0       ; Response lesen
        btst    #8,d0         ; IA-Bit testen
        beq.s   2$            ; ==0 -> fertig
        and.w   #%1100000000000,d0 ; Bits 11 und 12 ausmaskieren
        eor.w   #%1100000000000,d0 ; Beide gesetzt?
        bne.s   1$            ; Nicht beide ==1 -> warten
        bra     cop_error     ; Sonst ist Exception aufgetreten
        ;
2$      btst    #0,d0         ; Antwortbit testen
        beq     do_ca         ; False -> das war's schon
        adda.w  2(a0),a0      ; 16-Bit Sprungdistanz addieren
        subq.l  #2,a0         ; Ein Wort zurck (weil sp„ter noch
                ; 4 addiert wird und nur 2 addiert werden mte)
        bra     do_ca         ; Nochmal FPU befragen
        ;
s_br32  move.w  (a0),condition(a6) ; Bedingung an FPU schicken
        ;
1$      move.w  (a6),d0       ; Response lesen
        btst    #8,d0         ; IA-Bit testen
        beq.s   2$            ; ==0 -> fertig
        and.w   #%1100000000000,d0 ; Bits 11 und 12 ausmaskieren
        eor.w   #%1100000000000,d0 ; Beide gesetzt?
        bne.s   1$            ; Nicht beide ==1 -> warten
        bra     cop_error     ; Sonst ist Exception aufgetreten
        addq.l  #2,a0         ; Befehl ist 3 Worte lang 
                              ; [jetzt:(A0)=Distanz]
2$      btst    #0,d0         ; Antwortbit testen
        beq     do_ca         ; False -> das war's schon
        adda.l  (a0),a0       ; 32-Bit Sprungdistanz addieren
        subq.l  #4,a0    ; Zwei Worte zurck (weil sp„ter noch 4 
                         ; addiert wird, 2 wurden schon addiert)
        bra     do_ca         ; Nochmal FPU befragen
        ;
cop_error ; Error-Handler fr einen Trap der FPU. Es wird ein
          ; Reset der FPU durchgefhrt und das aktuelle Programm
          ; verlassen. Return-Code ist 881.
        move.w  #0,control(a6) ; FPU-Reset (kein clr.w verwenden!)
        move.w  #881,-(sp)    ; Return-Code
        move.w  #$4c,-(sp)    ; Funktion Pterm(881)
        trap    #1            ;   des GEMDOS aufrufen
        ;
calc_add  
    ; Operandenadresse berechnen. A0 mu die Adresse des Line-F-
    ; Befehls enthalten, D0 im unteren Byte die Operandenl„nge.
    ; Die zu berechnende Adresse wird in A1 abgelegt. A0 wird 
    ; um die L„nge der zus„tzlichen Daten erh”ht.
    ; Zus„tzlich wird in D1 die L„nge des Operanden zurckge-
    ; geben (in Bytes, als Langwort). D2, D3, A2 werden zerst”rt.
    ; Bei den Adressierungsarten -(An), (An)+ steht in A2 ein
    ; Zeiger auf die Stelle, in der der Inhalt des Adressre-
    ; gisters An steht (wird fr fmovem gebraucht).
    ;
        clr.l   d1            ; L„nge als Langword l”schen
        move.b  d0,d1         ;   und Byte einkopieren
        move.w  (a0),d2       ; Erstes Befehlswort nach D2
        move.w  d2,d3         ;   und D3 retten
        and.w   #%111000,d3   ; Adressierungsart ausmaskieren
        lsr.w   #1,d3         ; D3=Adressierungsart*4 (Langworte!)
        lea     cs_tab,a1     ; Sprungtabellenadresse nach A1
        move.l  (a1,d3.w),a1  ; Adresse der Routine nach A1
        jmp     (a1)          ;   und Routine anspringen
        ;
c_drd   ; %000  Data Register Direct:                         Dn
c_ard   ; %001  Address Register Direct:                      An
        lea     (a3),a1       ; A1 auf Registerfeld
        and.w   #%1111,d2     ; Registernummer ausmaskieren (und
        ; ein Bit vom Modus, 0 fr Daten-, 1 fr Adressregister)
        lsl.w   #2,d2         ; D2="Registernummer"*4 (+Modusbit!)
        addq.w  #4,d2         ; +4 (fr Operandenl„nge)
        sub.w   d1,d2         ; Wahre L„nge abziehen
        adda.w  d2,a1         ; Offset auf Registerfeldanfang add.
        rts
        ;
c_ari   ; %010  Address Register Indirect                     (An)
        and.w   #%111,d2      ; Registernummer ausmaskieren
        lsl.w   #2,d2         ; D2=Registernummer*4
        move.l  32(a3,d2.w),a1 ; Adresse nach A1
        rts
        ;
c_arpo  ; %011  Address Register Indirect with Postincrement:(An)+
        and.w   #%111,d2      ; Registernummer ausmaskieren
        lsl.w   #2,d2         ; D2=Registernummer*4
        lea     32(a3,d2.w),a2 ; Adresse Adressregister nach A2
        move.l  (a2),a1       ; Adresse (Inhalt A.-Reg.) nach A1
        btst    #0,d1         ; D1 ungerade? (Byteoperand)
        bne.s   2$            ; Ja -> Spezialbehandlung
        ;
1$      add.l   d1,(a2)       ; Inkrement durchfhren
        rts
        ;
2$      cmp.w   #4*7,d2       ; Ist A7 gemeint?
        bne.s   1$            ; Nein -> normal vorgehen
        addq.l  #2,(a2)       ; Sonst (bei Byte) 2 addieren,
        rts                   ;   damit Stack gerade bleibt!
        ;
c_arpr  ; %100  Address Register Indirect with Predecrement: -(An)
        and.w   #%111,d2      ; Registernummer ausmaskieren
        lsl.w   #2,d2         ; D2=Registernummer*4
        lea     32(a3,d2.w),a2 ; Adresse des Adressreg. nach A2
        btst    #0,d1         ; D1 ungerade? (Byteoperand)
        bne.s   2$            ; Ja -> Spezialbehandlung
        ;
1$      sub.l   d1,(a2)       ; Dekrement durchfhren
        move.l  (a2),a1     ; Adresse (Inhalt des A.-Reg.) nach A1
        rts
        ;
2$      cmp.w   #4*7,d2       ; Ist A7 gemeint?
        bne.s   1$            ; Nein -> normal vorgehen
        subq.l  #2,(a2)       ; Sonst (bei Byte) 2 addieren,
                              ;   damit Stack gerade bleibt!
        move.l  (a2),a1     ; Adresse (Inhalt des A.-Reg.) nach a1
        rts
        ;
c_ar16  ; %101 Address Register Indirect with Displacement:d16(An)
        and.w   #%111,d2      ; Registernummer ausmaskieren
        lsl.w   #2,d2         ; D2=Registernummer*4
        move.l  32(a3,d2.w),a1 ; Adresse nach A1
        move.w  4(a0),d2      ; 3. Befehlswort nach D2 (Offset)
        adda.w  d2,a1         ; Offset auf Adresse addieren
        addq.l  #2,a0         ; A0 ein Wort (d16) weiter
        rts
        ;
c_ar08  ; %110  Address Register Indirect with Index:    d8(An,Xn)
        and.w   #%111,d2      ; Registernummer (An) ausmaskieren
        lsl.w   #2,d2         ; D2=Registernummer*4
        move.l  32(a3,d2.w),a1 ; Adresse nach A1
        move.w  4(a0),d2    ; drittes Befehlswort nach D2 (Offset)
        move.w  d2,d3         ; und nach D3
        and.w   #$ff,d3       ; Byte ausmaskieren (Byte-Offset)
        adda.w  d3,a1         ; Offset auf Adresse addieren
        btst    #11,d2        ; 1=long, 0=word
        bne.s   c_ar8l
        and.w   #%1111000000000000,d2 ; Nummer von Dn und Modusbit
        lsr.w   #5,d2                 ; maskieren
        lsr.w   #5,d2         ; D2=Registernummer*4 (und Modusbit)
        adda.w  2(a3,d2.w),a1 ; 16-Bit-Index auf A1 addieren
        addq.l  #2,a0         ; A0 ein Wort (Kram & d8) weiter
        rts
        ;
c_ar8l  and.w   #%1111000000000000,d2 ; Nummer von Dn und Modusbit
        lsr.w   #5,d2                 ;   maskieren
        lsr.w   #5,d2         ; D2=Registernummer*4 (und Modusbit)
        adda.l  (a3,d2.w),a1  ; 32-Bit-Index auf A1 addieren
        addq.l  #2,a0         ; A0 ein Wort (Kram & d8) weiter
        rts
        ;
c_pc    ; %111  absolut short/long, PC-relativ (ohne/mit Index) 
        btst    #2,d2         ; Immidiate?           \ oder direkt
        bne.s   immi          ; !=0 -> ja
        btst    #1,d2         ; PC-relativ?
        bne.s   pc_rel        ; !=0 -> ja
        btst    #0,d2         ; Long?
        bne.s   c_long        ; !=0 -> ja
                              ; Sonst Short
        move.w  4(a0),d2      ; Wortadresse holen,
        ext.l   d2            ; Auf Langwort erweitern
        move.l  d2,a1         ;   und als Operandenadresse merken
        addq.l  #2,a0         ; A0 ein Wort (Short-Adr.) weiter
        rts
        ;
c_long  move.l  4(a0),a1      ; Langwortadresse holen
        addq.l  #4,a0         ; A0 zwei Worte (Long-Adr.) weiter
        rts
        ;
immi    move.l  a0,a1         ; Befehlsadresse nach A1
        addq.l  #4,a1         ; Beide Befehlsworte berspringen
        add.l   d1,a0         ; A0 ber Operand hinwegsetzen
        rts
        ;
pc_rel  btst    #0,d2         ; Mit Index?
        bne.s   pc_idx        ; !=0 -> ja
        move.l  a0,a1         ; PC nach A1
        adda.w  4(a0),a1      ; Offset addieren
        addq.l  #4,a1         ; +4 fr L„nge des FPU-Befehls
        addq.l  #2,a0         ; A0 zwei (16-Bit-Offset) weiter
        rts
        ;
pc_idx  move.l  a0,a1         ; PC nach A1
        clr.w   d2            ; Oberes Byte l”schen
        move.b  5(a0),d2      ; Offset nach D2
        adda.w  d2,a1         ;   und addieren
        addq.l  #4,a1         ; +4 fr L„nge des FPU-Befehls
        move.b  4(a0),d2      ; D2=Registernummer*16 und Modusbit
                              ;   (high-Byte ist noch 0)
        btst    #3,d2         ; Long-Bit testen
        bne.s   pc_i_l        ; !=0 -> Long-Index
        and.b   #%111110000,d2 ; Restinformation ausblenden
        lsr.w   #2,d2         ; D2=Registernummer*4 (und Modusbit)
        adda.w  2(a3,d2.w),a1 ; Word-Index addieren
        addq.l  #2,a0         ; A0 zwei (16-Bit-Offset) weiter
        rts
        ;
pc_i_l  and.b   #%111110000,d2 ; Restinformation ausblenden
        lsr.w   #2,d2         ; D2=Registernummer*4 (und Modusbit)
        adda.l  (a3,d2.w),a1  ; Word-Index addieren
        addq.l  #2,a0         ; A0 zwei (16-Bit-Offset) weiter
        rts     ; Ende von Calc_add
        ;
        dseg
        ;
cs_tab  dc.l    c_drd,c_ard,c_ari,c_arpo    ; Sprungtabelle fr
        dc.l    c_arpr,c_ar16,c_ar08,c_pc   ; Adressierungsarten
        ;
        bss     oldtrap,4     ; Alter Line-F-Vektor
        bss     dregs,(8+7)*4 ; Platz fr Register  (D0-D7/A0-A6)
        bss     rusp,4        ; Platz fr USP       (         A7)
        bss     rd1,4         ; Platz fr D1
        ;
        end

