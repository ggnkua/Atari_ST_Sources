*************************************************************
*                         X-SOUND DMA                       *
*    Digi-Sound per Betriebsystem auf jedem ST/E und TT     *
*        Dies ist die Version fÅr den STE-DMA-Sound         *
*             Geschrieben von Thomas Huth, 1995/96          *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*             Jetzt mit McSn-Cookie UnterstÅtzung           *
*                      dank ChrisP, 1999                    *
*************************************************************

_sysbase        EQU $04F2
_longframe      EQU $059E
_p_cookies      EQU $05A0
frmbase         EQU $FFFF8903   ; Frame-Basis-Address
frmend          EQU $FFFF890F   ; Frame-End-Address
frmcnt          EQU $FFFF8909   ; Frame-Address-Counter
sdmacntr        EQU $FFFF8901   ; Sound DMA Control - Register
smodcntr        EQU $FFFF8921   ; Sound Mode Control - Register
mwmask          EQU $FFFF8924   ; Microwire Mask-Register
mwdata          EQU $FFFF8922   ; Microwire Data-Register
resvalid        EQU $0426       ; Reset-Vektor Magic
resvector       EQU $042A       ; der Reset-Vektor

newjarslots     EQU 32          ; Anzahl der EintrÑge in einem neuen Cookiejar


                TEXT
start:
                bra     init            ; Routine initialisieren

;### etv_term: ZurÅcksetzen von locksnd ##
                DC.B "XBRAXSND" ; XBRA-Kennung
oldetvterm:     DS.L 1
myetvterm:      movea.l act_pd(PC),A0   ; actpd-Variable holen
                move.l  (A0),D0         ; Aktuelle Basepage => D0
                cmp.l   lock_pd(PC),D0  ; Basepage des Reservierers?
                bne.s   etvtermret      ; Nein: zurÅck
                clr.l   lock_pd         ; Sperre Freigeben
etvtermret:     lea     oldetvterm(PC),A0 ; Alten Wert laden
                jmp     (A0)            ; und springen

;### Hauptverteiler ###
                DC.B "XBRAXSND" ; XBRA-Kennung
oldtrap14:      DS.L 1          ; Alter Vektor
mytrap14:       move    USP,A0          ; A0 auf Parameter zeigen lassen
                btst    #5,(SP)         ; War schon Supervisor an?
                beq.s   go              ; Ja: Keine Zusatzparameter
                lea     6(SP),A0        ; A0 auf Parameter
                tst.w   _longframe.w    ; Ist Prozessor > 68000?
                beq.s   go              ; Nein: A0 ist OK
                addq.l  #2,A0           ; 2 Zusatzparameter mehr
go:             move.w  (A0)+,D0        ; Funktionsnummer holen, A0 auf Daten
                sub.w   #128,D0         ; Locksnd hat Nr.128
                bmi.s   nrmlxbios       ; Funktionsnummer < 128 => Altes Xbios
                cmp.b   #14,D0
                bge.s   nrmlxbios       ; Nur 13 Routinen vorhanden
                lea     jumptabl(PC),A1 ; Tabelle holen
                add.w   D0,D0           ; D0 * 2 wegen WortlÑnge
                lea     r(PC),A2        ; Start der Routinen
                adda.w  0(A1,D0.w),A2   ; Adresse der Routine in A2
                jmp     (A2)            ; Routine anspringen
nrmlxbios:      movea.l oldtrap14(PC),A0 ; Alten Vektor laden
                jmp     (A0)            ; und springen

jumptabl:       DC.W locksnd-r,unlocksnd-r,soundcmd-r,setbuffer-r
                DC.W setsndmode-r,unknown-r,unknown-r,setinterrupt-r
                DC.W buffoper-r,unknown-r,unknown-r,devconnect-r
                DC.W sndstatus-r,buffptr-r

;** Alles Okay (0L) und zurÅck **
xsndok:         moveq   #0,D0
                rte

;** Fehler melden (-1L) und zurÅck: **
xsnderr:        move.l  #-1,D0          ; Fehler melden
                rte

r:                                      ; Die Routinen

;** Unbekannte bzw. nicht unterstÅtzte Funktion: -32L melden **
unknown:        move.l  #-32,D0
                rte

;*** Locksnd ***
locksnd:        tst.l   lock_pd         ; Schon gesperrt?
                beq.s   lockit          ; Nein: Sperren gehen
                move.l  #-129,D0        ; Ja: Als gesperrt melden
                rte
lockit:         movea.l act_pd(PC),A0   ; act_pd-Variable laden
                move.l  (A0),lock_pd    ; Basepage merken
                moveq   #1,D0
                rte

;*** Unlocksnd ***
unlocksnd:      tst.l   lock_pd         ; Schon freigegeben?
                bne.s   unlockit        ; Nein: Freigeben
                moveq   #-128,D0        ; Ja: Fehler-Code
                rte
unlockit:       clr.l   lock_pd         ; Freigabe
                bra.s   xsndok

;*** Soundcmd ***
soundcmd:       moveq   #0,D0
                cmpi.w  #-1,2(A0)
                beq.s   scmdreqest      ; Nachfrage?
                move.w  #$07FF,mwmask.w
                lea     mwdata.w,A1     ; MWDATA mit A1 ansprechen
                move.b  3(A0),D0        ; Data in D0
                cmpi.w  #5,(A0)
                beq.s   setmix
                andi.b  #$F0,D0         ; FÅr LTATTEN + RTATTEN
                cmpi.w  #1,(A0)
                beq.s   setrightvol
                tst.w   (A0)
                bne     xsndok

                move.w  #%1101010100,D1 ; LautstÑrke setzen
                move.b  D0,leftvol
                bra.s   setvol
setrightvol:    move.w  #%1100010100,D1
                move.b  D0,rightvol
setvol:         move.b  D0,D2
                divu    #12,D2
                sub.w   D2,D1           ; AbschwÑchung in LautstÑrke wandeln
                move.w  D1,(A1)         ; Und losschicken
                rte
setmix:
                move.b  D0,mixstat
                tst.b   D0              ; Adcinput bearbeiten
                beq.s   no_psg          ; PSG zumischen?
                move.w  #%1000000001,(A1) ; PSG zumischen!
                rte
no_psg:         move.w  #%1000000010,(A1) ; PSG nicht zumischen
                rte
scmdreqest:
                tst.w   (A0)
                beq.s   getlvol
                cmpi.w  #1,(A0)
                beq.s   getrvol
                cmpi.w  #5,(A0)
                bne.s   scmdret
                move.b  mixstat(PC),D0  ; Mix-Status zurÅckgeben
scmdret:        rte
getlvol:        move.b  leftvol(PC),D0
                rte
getrvol:        move.b  rightvol(PC),D0
                rte

;*** Setbuffer ***
setbuffer:      tst.w   (A0)            ; Setzen des Abspielbuffers?
                bne.s   setrecbuf       ; Nein: Aufnahmebuffer merken
                lea     frmbase.w,A1
                addq.l  #3,A0
                move.b  (A0)+,(A1)      ; Base-Adr. setzen
                move.b  (A0)+,2(A1)
                move.b  (A0),4(A1)
                lea     frmend.w,A1
                addq.l  #2,A0
                move.b  (A0)+,(A1)
                move.b  (A0)+,2(A1)
                move.b  (A0),4(A1)
                bra     xsndok
setrecbuf:
                move.l  2(A0),recbuf    ; Aufnahmebuffer merken (fÅr Buffptr)
                bra     xsnderr

;*** Setsndmode ***
setsndmode:     cmpi.w  #2,(A0)
                beq.s   set8mono        ; 8-Bit Mono setzen
                tst.w   (A0)
                bne     xsnderr         ; Bei 16-Bit: Fehler melden + zurÅck
                bclr    #7,smodcntr.w   ; 8-Bit Stereo einschalten
                bra     xsndok
set8mono:       bset    #7,smodcntr.w   ; 8-Bit Mono einschalten
                bra     xsndok


;*** Setinterrupt ***
setinterrupt:   cmpi.w  #2,(A0)
                bhs     xsnderr         ; Falscher Wert?
                cmpi.w  #1,2(A0)        ; Wiedergabe?
                bne     xsnderr         ; Nein -> Fehler
                bra     xsndok

;*** Buffoper ***
buffoper:       move.w  (A0),D0
                cmp.w   #-1,D0
                beq.s   retbufopstat    ; Bei -1 Status zurÅckgeben
                and.w   #%1100,D0       ; Soll Aufnahme gestartet werden?
                bne     xsnderr         ; Ja: Fehler melden+zurÅck
                move.w  (A0),D0
                andi.b  #3,D0           ; Nur die beiden untersten Bits
                move.b  D0,sdmacntr     ; DMA-Wiedergabe starten/beenden
                bra     xsndok
retbufopstat:                           ; Status zurÅckgeben
                move.b  sdmacntr.w,D0
                and.l   #3,D0
                rte

;*** Devconnect ***
devconnect:     tst.w   (A0)            ; Ist DMA-Ausgabe gemeint?
                bne     xsnderr         ; Nein: Fehler melden + zurÅck
                cmpi.w  #8,2(A0)        ; Ist auch D/A-Wandler gemeint?
                bne     xsnderr         ; Nein: TschÅû dann...
                tst.w   4(A0)           ; Richtige Taktart?
                bne     xsnderr         ; Nein: zurÅck
                move.w  6(A0),D1        ; GewÅnschte Taktrate in D1
                move.b  D1,devconstat   ; Taktrate merken (fÅr Sndstatus)
                cmp.w   #1,D1           ; DMA Sample-Taktrate einstellen
                bne.s   devc_l1
                ori.b   #3,smodcntr.w   ; => 50 kHz
                bra     xsndok
devc_l1:        andi.b  #$FC,smodcntr.w
                cmp.w   #4,D1           ; 32KHz bis 20KHz:
                bhi.s   devc_l2
                ori.b   #2,smodcntr.w   ; => 25 kHz
                bra     xsndok
devc_l2:        cmp.w   #9,D1           ; 16KHz bis 10KHz:
                bhi.s   devc_l3
                ori.b   #1,smodcntr.w   ; => 12 kHz
                bra     xsndok
devc_l3:        cmp.w   #15,D1          ; Von 9 bis 6KHz: automatisch => 6KHz
                bhi     xsnderr         ; UngÅltige Werte: springen
                bra     xsndok

;*** Sndstatus ***
sndstatus:      move.b  devconstat(PC),D0
                cmp.b   #1,D0
                beq     xsndok          ; 50KHz sind ok
                cmp.b   #3,D0
                beq     xsndok          ; 25KHz = ok
                cmp.b   #7,D0
                beq     xsndok          ; 12KHz = ok
                cmp.b   #15,D0
                beq     xsndok          ; 6KHz = ok
                moveq   #3,D0           ; UngÅltigen Takt melden
                rte

;*** Buffptr ***
buffptr:        movea.l (A0),A0         ; Zeiger auf Struktur holen
                lea     frmcnt.w,A1     ; Frame Counter
                movep.l -2(A1),D0       ; Aktuelle Adresse in D0
                and.l   #$FFFFFF,D0     ; Nur 24-Bit Adresse
                move.l  D0,(A0)         ; Eintragen
                move.l  recbuf(PC),4(A0) ; Aufnahmebuffer eintragen (sicherer)
                bra     xsndok



;reset-feste Routine zum Entfernen des Cookie Jars
old_resvalid:   DS.L 1          ;altes Reset-Valid
                DC.L 'XBRA'     ;XBRA-Protokoll
                DC.L 'XSND'
old_resvector:  DS.L 1          ;alter Reset-Vektor
cookie_reset:   clr.l   _p_cookies.w    ;Cookie Jar entfernen
                move.l  old_resvector(PC),resvector.w ;Reset-Vektor zurÅck
                move.l  old_resvalid(PC),resvalid.w
                jmp     (A6)            ;weiter mit dem RESET


                EVEN

; Die Variablen:
recbuf:         DS.L 1          ; Aufnahmebuffer (fÅr Buffptr)

act_pd:         DS.L 1          ; Zeiger auf Zeiger auf akt. Basepage
lock_pd:        DC.L 0          ; Basepage des Locksnd-Aufrufers

leftvol:        DS.B 1          ; LautstÑrken
rightvol:       DS.B 1
mixstat:        DS.B 1          ; FÅr Adcinput

devconstat:     DC.B 7
                EVEN

cookiedat:      DC.W $0100
                DC.W 30
                DC.W 1
                DC.W 1
                DC.W 0
                DC.W 1
                DC.W 1
                DC.L 0
                DC.L 0
                DC.L 0
                DC.L 0
                DC.L 0

cookiejar:      DS.L newjarslots*2 ; Platz falls ein neuer Cookiejar angelegt werden muss.


; Bis hier ist das Prg resident.

;### Routine initialisieren ###
init:
                clr.l   -(SP)
                move.w  #$20,-(SP)      ; In Supervisor umschalten
                trap    #1
                addq.l  #6,SP
                move.l  D0,save_sp      ; Alten Stack merken

                movea.l _sysbase.w,A0
                move.w  2(A0),D0        ; TOS-Version ermitteln
                cmp.w   #$0400,D0       ; Bei TOS ab V4.00 sinnlos
                bhs     error1
                cmp.w   #$0102,D0
                blt.s   tos1_0
                move.l  $28(A0),act_pd  ; Bei TOS 1.02 aufwÑrts einfach holen
                bra.s   actpdok
tos1_0:         move.l  #$602C,act_pd   ; Bei TOS 1.00: Feste Addi eintragen
                move.w  $1C(A0),D1
                and.b   #%11111110,D1   ; Palflag vergessen
                cmp.b   #8,D1           ; Spanisches TOS 1.00?
                bne.s   actpdok
                move.l  #$873C,act_pd   ; Ja: andere Addi
actpdok:
                movea.l $B8.w,A0        ; Alten Xbiosvektor nach A0
xbraloop:       cmpi.l  #'XBRA',-12(A0) ; Nach XBRA-Kette suchen
                bne.s   notyetinstaled
                cmpi.l  #'XSND',-8(A0)
                beq     error3          ; Wenn schon installiert: Fehlermeldung
                movea.l -4(A0),A0
                bra.s   xbraloop
notyetinstaled:
                move.l  #'_SND',D0      ; Nach Cookie suchen
                bsr.s   hunt_cookie
                tst.l   D0              ; D0 zeigt an, ob Cookie gefunden
                bne     error2          ; Kein Cookie = Kein DMA
                btst    #1,D1           ; DMA-Sound mîglich?
                beq     error2          ; Wenn kein DMA-Sound, Fehler melden

                move.l  #'McSn',D0
                move.l  #cookiedat,D1
                bsr     insert_cookie

                move.l  save_sp(PC),-(SP) ; In User-Mode zurÅck
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                pea     mytrap14(PC)
                move.w  #$2E,-(SP)      ; Kennung Xbios
                move.w  #5,-(SP)        ; Routine einklinken
                trap    #13             ; Setexec
                addq.l  #8,SP
                move.l  D0,oldtrap14    ; Alter Wert sichern

                pea     myetvterm(PC)
                move.w  #$0101,-(SP)    ; Kennung fÅr etv_term
                move.w  #5,-(SP)        ; Setexec
                trap    #13
                addq.l  #8,SP
                move.l  D0,oldetvterm   ; Alten Wert merken

                pea     installedtxt(PC)
                move.w  #9,-(SP)        ; Einschaltmeldung ausgeben
                trap    #1
                addq.l  #6,SP
                clr.w   -(SP)
                move.l  #$0100+init-start,-(SP) ; LÑnge residenten Codes
                move.w  #$31,-(SP)
                trap    #1              ; PRG via Ptermres beenden



; Cookie suchen (siehe ST-Magazin 3/90)
hunt_cookie:
                move.l  D0,D2
                move.l  _p_cookies.w,D0
                beq.s   cookie_ex
                movea.l D0,A0
cookie_l:
                move.l  (A0)+,D3
                move.l  (A0)+,D1
                cmp.l   D2,D3
                beq.s   cookie_f
                tst.l   D3
                bne.s   cookie_l
cookie_ex:
                moveq   #-1,D0
                rts
cookie_f:
                moveq   #0,D0
                rts



insert_cookie:  movem.l D2-D5/A1,-(SP)
                move.l  _p_cookies.w,D3 ;Zeiger auf das Cookie Jar holen
                beq.s   insert_newjar   ;ist leer => Liste einrichten
                movea.l D3,A1
                moveq   #0,D4           ;Anzahl der Slots
ins_oldjar_l:
                addq.w  #1,D4           ;Slotanzahl erhîhen
                movem.l (A1)+,D2-D3     ;Namen und Wert eines Cookies holen
                tst.l   D2              ;leeren Cookie gefunden?
                bne.s   ins_oldjar_l    ;Nein => weiter suchen
                cmp.l   D3,D4           ;alle Slots belegt?
                beq.s   ins_copynewjar  ;Ja! => neue Liste anlegen
                movem.l D0-D3,-8(A1)    ;neuen Cookie & Listenende einfÅgen
                moveq   #0,D0           ;alles ok!
                bra.s   insert_cookie_x ;und raus

insert_newjar:
                move.l  resvector.w,old_resvector
                move.l  resvalid.w,old_resvalid ;alten Reset-Vektor merken
                move.l  #cookie_reset,resvector.w
                move.l  #$31415926,resvalid.w ;und eigenen einsetzen
                lea     cookiejar(PC),A0
                move.l  A0,_p_cookies.w ;Cookie Jar initialisieren
                moveq   #0,D2           ;Markierung: Ende der Cookie-List
                move.l  #newjarslots,D3 ;Anzahl der Slots nach D3
                movem.l D0-D3,(A0)      ;Namen und Wert des Cookies einsetzen
                moveq   #1,D0           ;Liste resetfest eingerichtet, alles ok
                bra.s   insert_cookie_x ;und raus

insert_cookie_e:
                moveq   #-1,D0          ;Fehler, Cookie nicht eingetragen
                bra.s   insert_cookie_x ;und raus

ins_copynewjar:
                cmp.l   #newjarslots,D4 ;reicht der Platz?
                ble.s   insert_cookie_e ;Nein => Fehler und raus
                movea.l _p_cookies.w,A1 ;Anfang der Liste erneut holen
                lea     cookiejar(PC),A0
                move.l  A0,_p_cookies.w ;neuen Cookie Jar eintragen
                subq.w  #2,D4           ;Ende nicht kopieren (-1 fÅr DBRA)
insert_cookie_m:move.l  (A1)+,(A0)+     ;EintrÑge der Liste kopieren
                move.l  (A1)+,(A0)+
                dbra    D4,insert_cookie_m
                move.l  #newjarslots,D3 ;Anzahl der Slots
                movem.l D0-D3,(A0)      ;eigenes Element eintragen + Listenende
                moveq   #2,D0           ;alles ok, resident bleiben
insert_cookie_x:
                movem.l (SP)+,D2-D5/A1
                rts


; Meldung, daû TOS-Version zu groû ist
error1:
                pea     err1txt(PC)
                bra.s   error
; Meldung, daû keine Soundmîglichkeit vorhanden ist
error2:
                pea     err2txt(PC)
                bra.s   error
; Meldung, daû schon installiert
error3:
                pea     err3txt(PC)
; Fehlermeldung ausgeben
error:
                move.w  #9,-(SP)        ; Cconws
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)        ; Crawcin
                trap    #1
                clr.w   (SP)            ; Programm verlassen
                trap    #1


                DATA

err1txt:        DC.B 13,10,"X-SOUND ist nur unter TOS 4.00 sinnvoll!",13,10,0
err2txt:        DC.B 13,10,"Kein DMA-Sound vorhanden!",13,10,0
err3txt:        DC.B 13,10,"X-SOUND ist schon installiert!",13,10,0
installedtxt:
                DC.B 13,10,13,10,"X-SOUND wurde installiert."
                DC.B 13,10,189," by Thomas Huth, 1996",13,10,0

                BSS
save_sp:        DS.L 1
                END
