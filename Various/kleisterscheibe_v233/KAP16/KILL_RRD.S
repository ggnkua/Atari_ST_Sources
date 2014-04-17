*********************************************************************
**************************** KILL RRD *******************************
*     Dieses Programm entfernt das LUFTSCHLOSS (die RRD) wieder     *
*                       Written & Ω 1988 by                         *
*             Lutz Preûler (Ahornweg 11, 2904 Hatten)               *
*********************************************************************

                >PART 'Geschichte'
* V1.2 (30.9.1988)                                                  *
* V1.2a  (1/1989) : Kennung in WINZ geÑndert                        *
* V1.3 (12.2.1989): alloc_mem geÑndert                              *
* V1.4 (8/90, CB+BR): alloc_mem a la Bernd Rosenlecher, Korrektur   *
*                   des bootdev-Fehlers                             *
* V1.5 (7/91, CB+BR): Nochmal neue MPB-Suche, AUTO-Ordner-Test      *
* V1.6 (1/92, CB): alloc_mem arbeitet mit Tabelle                   *
* V1.7 (5/92, CB): Anpassung TOS 2.05/CH                            *

                ENDPART

                OPT F+          ; Schnelladebit an

                >PART 'Konstanten'
kennung         EQU "RSt-"      ; ID-Kennungen der RAM-Disk
kennung2        EQU "WINZ"      ; zweite Kennung (u.a. fÅr XBRA)

FRG             EQU 1
UK              EQU 3
CH              EQU 8

*************************
* Systemvariablen
*************************
hdv_bpb         EQU $0472       ; BPB-Vektor
hdv_rw          EQU $0476       ; RWABS-Vektor
hdv_mediach     EQU $047E       ; MEDIACH-Vektor
drvbits         EQU $04C2       ; drvbits (angemeldete Laufwerke)
bootdev         EQU $0446       ; Bootlaufwerk
etv_timer       EQU $0400       ; Timer-Vektor
phystop         EQU $042E       ; physikalisches Speicherende
membot          EQU $0432       ; Unteres Speicherende
memtop          EQU $0436       ; Oberes Speicherende
nvbls           EQU $0454       ; LÑnge der VBL-Liste
vblqueue        EQU $0456       ; Start der VBL-Liste
themd           EQU $048E       ; Ur-MD
sysbase         EQU $04F2       ; ->TOS-Header
exec_os         EQU $04FE       ; ->AES-Start

                ENDPART

                TEXT

                >PART 'Init'
*************************
* prgstart: nun aber los!
*************************
prgstart:
                movea.l 4(SP),A5        ; Basepageadr. in a5
                movea.l 12(A5),A0       ; TEXT-LÑnge
                adda.l  20(A5),A0       ; + DATA-LÑnge
                adda.l  28(A5),A0       ; + BSS-LÑnge
                adda.w  #$0500,A0       ; + Basepage u.a
                move.l  A0,D1
                add.l   A5,D1           ; + BP-Adresse
                andi.b  #-2,D1          ; gerade machen
                movea.l D1,SP           ; Stackpointer neu setzen
                move.l  A0,-(SP)        ; genÅgend Speicher
                move.l  A5,-(SP)        ; ab Basepage
                clr.w   -(SP)           ; per
                move.w  #$4A,-(SP)      ; GEMDOS-MShrink
                trap    #1              ; reservieren
                lea     12(SP),SP

                lea     contrl(PC),A6   ; Zeiger setzen
                move.w  #10,(A6)+       ; appl_init, Anwendung anmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                moveq   #0,D0
                move.l  D0,(A6)
                lea     global(PC),A6
                move.l  D0,(A6)
                bsr.s   aes

                move.w  global+2(PC),autoflag ; sind wir im AUTO-Ordner?
                beq.s   keinauto

                lea     contrl(PC),A6
                move.w  #19,(A6)+       ; appl_exit, Anwendung abmelden
                move.l  #1,(A6)+        ; 1 Ausgabeparameter
                clr.l   (A6)
                bsr.s   aes

keinauto:
                clr.l   -(SP)           ; Supervisormodus einschalten
                move.w  #32,-(SP)       ; SUPER
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                move.l  D0,-(SP)        ; alten SP auf Stack retten

                bsr.s   main            ; Hauptroutine ausfÅhren

                move.w  #32,-(SP)       ; SP liegt schon auf Stack
                trap    #1              ; zurÅck in den Usermodus
                addq.l  #6,SP
                clr.w   -(SP)           ; Pterm0
                trap    #1              ; fini!

aes:
                move.l  #aespb,D1
                move.w  #$C8,D0
                trap    #2
nurweg:
                rts

                ENDPART

                >PART 'Hauptroutine'
*************************
* main: die ganze Arbeit
*************************
main:
                bsr     checkrdsk       ; RAM-Disk installiert?
                lea     keinerd(PC),A6  ; Fehlermeldung
                tst.b   D2              ; Flag testen
                beq     error           ; keine RAM-Disk vorhanden
; sonst:
                movea.l A0,A5           ; Startadr. der "PÑckchen"-Routine

                lea     fehler(PC),A6   ; Fehlermeldung

; hdv-Vektoren untersuchen
                lea     hdv_bpb.w,A2
                lea     bpb_s(PC),A3
                bsr     search_hdv
                lea     hdv_rw.w,A2
                lea     rw_s(PC),A3
                bsr     search_hdv
                lea     hdv_mediach.w,A2
                lea     mediach_s(PC),A3
                bsr     search_hdv

                movea.l hdv_bpb.w,A2    ; hdv-Vektoren retten
                movea.l hdv_rw.w,A3
                movea.l hdv_mediach.w,A4

                move.w  22(A5),D2       ; Laufwerkskennung der RAM-Disk

* Laufwerk beim GEMDOS abmelden
* Trick, s. Serie 'An der Schwelle zum Licht'
* von Alex Esser , ST-Computer

                move.l  #free_bpb,hdv_bpb.w
                move.l  #free_rw,hdv_rw.w
                move.l  #free_mediach,hdv_mediach.w
                move.w  D2,-(SP)
                addq.w  #1,(SP)
                pea     freedum(PC)
                move.w  #$36,-(SP)
                trap    #1
                addq.l  #8,SP

; eigene Routinen entfernen (und Vektoren zurÅck)
                tst.l   bpb_ps
                bne.s   entf_bpb
                move.l  bpb_s(PC),hdv_bpb.w
                bra.s   rw_x
entf_bpb:       movea.l bpb_ps(PC),A0
                move.l  bpb_s(PC),-4(A0)
                move.l  A2,hdv_bpb.w
rw_x:           tst.l   rw_ps
                bne.s   entf_rw
                move.l  rw_s(PC),hdv_rw.w
                bra.s   med_x
entf_rw:        movea.l rw_ps(PC),A0
                move.l  rw_s(PC),-4(A0)
                move.l  A3,hdv_rw.w
med_x:          tst.l   mediach_ps
                bne.s   entf_med
                move.l  mediach_s(PC),hdv_mediach.w
                bra.s   rout_x
entf_med:       movea.l mediach_ps(PC),A0
                move.l  mediach_s(PC),-4(A0)
                move.l  A4,hdv_mediach.w
rout_x:

; Laufwerk abmelden (drvbits)
                move.l  drvbits.w,D1
                bclr    D2,D1
                move.l  D1,drvbits.w
                addi.b  #65,D2          ; Kennung in String
                move.b  D2,infolw

                move.w  24(A5),bootdev.w

                clr.l   (A5)            ; "PÑckchen"-Routine 'abschieûen'

                movea.l $0436.w,A0
                cmpa.l  26(A5),A0
                bne.s   merror
                clr.l   D1              ; Speicher unter memtop freigeben
                sub.l   18(A5),D1
                bsr     alloc_mem

merror:         lea     info(PC),A6     ; Infotext
error:

*******************
* message: Gibt Texte aus
* IN:  a6 Stringadresse
*******************
message:
                move.l  A6,-(SP)        ; Stringadresse
                move.w  #9,-(SP)        ; Cconws
                trap    #1              ; GEMDOS
                addq.l  #6,SP
                rts

                ENDPART

                >PART 'Nach Luftschloss suchen'
*************************
* search_hdv: hdv-Vektor untersuchen
*************************
search_hdv:
                suba.l  A1,A1
                movea.l (A2),A0
ch_l:           cmpi.l  #"XBRA",-12(A0)
                bne.s   serror
                cmpi.l  #kennung2,-8(A0)
                beq.s   ch_e
                movea.l A0,A1
                movea.l -4(A0),A0
                bra.s   ch_l
ch_e:           move.l  -4(A0),(A3)
                move.l  A1,4(A3)
                rts
serror:         addq.l  #4,SP
                bra.s   error


*************************
* checkrdsk: RAM-Disk schon installiert?
* OUT: d2.b <> 0: RAM-Disk schon da
*      a0.l : Startadr. der "PÑckchen"-Routine
*************************
checkrdsk:
                clr.b   D2              ; Reg. lîschen
                movea.l $042E.w,A0      ; von phystop abwÑrts untersuchen
chloop:         suba.l  #$0200,A0
                cmpa.l  #$0400,A0       ; schon Systemvar. erreicht?
                beq.s   chexit
                cmpi.l  #$12123456,(A0) ; magic?
                bne.s   chloop
                cmpa.l  4(A0),A0        ; eigene Adresse?
                bne.s   chloop
                cmpi.l  #kennung,10(A0) ; Kennung richtig?
                bne.s   chloop
                cmpi.l  #kennung2,14(A0) ; Kennung richtig?
                bne.s   chloop
                clr.w   D0
                movea.l A0,A1
                move.w  #255,D1         ; öber 256-1 Worte
chaloop:        add.w   (A1)+,D0        ; PrÅfsumme bilden
                dbra    D1,chaloop
                cmpi.w  #$5678,D0       ; Magic?
                bne.s   chloop          ; nein: weitermachen
                st      D2              ; wir haben's; Flag setzen
chexit:         rts


                ENDPART

                >PART 'Hilfsroutinen f. Medienwechsel'
*************************
* Hilfsroutinen fÅr GEMDOS-Laufwerkfreigabe
*************************
free_bpb:       moveq   #0,D0
                rts
free_rw:        moveq   #-14,D0
                rts
free_mediach:   moveq   #2,D0
                rts
                ENDPART

                >PART 'alloc_mem'
********************
* alloc_mem: GEMDOS-Speicherverwaltung manipulieren
*           (Dank an Alex Esser, siehe auch ST-Computer-Sonderheft Nr.2)
* IN:  d1.l Grîûe des zu reservierenden Speicherblocks
*           Die Routine rundet die Startadresse auf die nÑchstgelegene
*           512-Byte-Grenze unterhalb der eigentlich erforderlichen Grenze
*      d1.l = 0: Nur Grîûe des obersten SpeicherhÑppchens holen
* OUT: d0.l Startadresse/neues memtop
*           oder: Grîûe des obersten SpeicherstÅcks (wenn d1.l=0)
*           oder: 0L (Fehler)
* USES: D0, D1, D2, A0, A1
********************
alloc_mem:
                movea.l $04F2.w,A0      ; sysbase
                tst.w   autoflag        ; sind wir im AUTO-Ordner?
                bne.s   getcountry      ; nein, weiter
                movea.l 8(A0),A0        ; TOS-Startadresse ermitteln
getcountry:
                move.w  $1C(A0),D2      ; LÑnderkennung holen
                asr.w   #1,D2           ; PAL-Flag raus

                lea     tostab(PC),A1   ; Zeiger auf TOS-Tabelle
checkentry:
                move.w  (A1),D0         ; TOS-Versionsnummer
                beq     selbersuchen    ; Tabelle zu Ende, selbst suchen
                cmp.w   2(A0),D0        ; richtige Version?
                bne.s   nextentry       ; nein, weiter
                cmp.w   2(A1),D2        ; richtiges Land?
                bne.s   nextentry       ; nein, weiter
                move.l  4(A1),D0        ; TOS-Datum
                bmi.s   getentry        ; negativ, dann holen
                cmp.l   24(A0),D0       ; richtiges Datum?
                beq.s   getentry        ; ja, dann holen
nextentry:
                lea     12(A1),A1       ; Zeiger auf nÑchsten Eintrag
                bra.s   checkentry      ; prÅfen

getentry:
                movea.l 8(A1),A0        ; MPB-Adresse holen
alloc_st:
                move.l  (A0),D0         ; Zeiger auf mfl-Beginn
                beq.s   err             ; mfl leer!
                moveq   #0,D2           ; Default fuer letzten freien Block im ST-RAM
src_fr1:
                btst    #0,7(A0)        ; Startadresse ungerade?
                bne.s   nextone

                move.l  A0,D2           ; MD merken
nextone:
                move.l  (A0),D0         ; nÑchster MD
                beq.s   amende
                movea.l D0,A0
                bra.s   src_fr1
amende:
                move.l  D2,D0
                beq.s   err             ; kein freier Block im ST-RAM
                movea.l D2,A0

                move.l  memtop.w,D0

                move.l  4(A0),D2        ; M_START
                sub.l   D2,D0           ; Obergrenze minus M_START = freier Speicher
                cmp.l   8(A0),D0        ; M_LENGTH, sollte gleich sein
                bhi.s   err             ; ungleich, Speicherverwaltung durcheinander
                tst.l   D1              ; reservieren oder nur abfragen?
                beq.s   ok              ; nur abfragen
                cmp.l   D1,D0           ; genug Speicher frei?
                blt.s   err             ; nein, dann Fehler
                move.l  memtop.w,D0     ; memtop, alte Obergrenze

                sub.l   D1,D0           ; minus LÑnge = neues Speicherende

                move.l  D0,D2           ; d0.l merken
                and.l   #$01FF,D2
                beq.s   reservieren     ; war schon auf 512-Byte-Grenze?
                add.l   D2,D1           ; reservierte Grîûe entsprechend erhîhen
                and.l   #$FFFFFE00,D0   ; untere 9 Bits lîschen

reservieren:
                move.l  D0,memtop.w     ; in memtop ablegen

                movea.l D0,A1           ; neues Speicherende ins Adreûregister
                suba.l  4(A0),A1        ; minus M_START = LÑnge des neuen Blocks
                move.l  A1,8(A0)        ; M_LENGTH, neue LÑnge im mfl-Block merken
ok:             rts                     ; alles roger

mpberr:
                lea     mpberror(PC),A6 ; "MPB-Variable nicht gefunden"
                bsr     message

err:            moveq   #0,D0
                rts

* Hoffentlich von der TOS-Version unabhÑngige Routine, die versucht, den
* MPB zu finden. Erdacht von Bernd Rosenlecher:
* --------------------------------------------------------------------------
* VersionsabhÑngigen Teil ersetzt, lÑuft damit auf allen RAM- (ab 20.11.85)
* & ROM-TOS-Versionen - inkl. STE-TOS 1.6 vom 29.7.89 & TT-TOS 3.01 br 2/91
* --------------------------------------------------------------------------
* IN: nothing, OUT: a0 -> MPB, USES: a1, d0, d2, (PRESERVES d1)
* --------------------------------------------------------------------------
selbersuchen:
                lea     mpbmsg(PC),A6
                bsr     message         ; "Unbekannte TOS-Version!"

                lea     themd.w,A1      ; Ausgangspunkt der Suche
                movea.l membot.w,A2     ; Suchende
                move.l  memtop.w,D0
                sub.l   A2,D0           ; freien Speicher berechnen
                cmp.l   8(A1),D0        ; m_length = memtop-membot?
                bne.s   loop_0          ; da fehlt schon etwas

                lea     $4000,A0        ; Suchbeginn
t_loop:         addq.w  #2,A0           ; nur gerade Adressen absuchen
                cmpa.l  A0,A2           ; Endadresse erreicht?
                bls.s   mpberr          ; Fehler, fertig

                cmpa.l  (A0),A1         ; Zeiger auf themd?
                bne.s   t_loop          ; nein, weitersuchen
                bra.s   fini            ; das war's

loop_0:         movea.l A2,A0           ; Suchbeginn = membot
                moveq   #0,D2           ; VersuchszÑhler
loop_1:         subq.w  #2,A0           ; nur gerade Adressen absuchen
                cmpa.l  #$2000,A0       ; schon am Ende?
                bls.s   stuck           ; wir sind festgefahren

                cmpa.l  (A0),A1         ; Zeiger da?
                bne.s   loop_1          ; weiter testen

; Nun folgen PlausibilitÑtstests fÅr MDs, falls mp_mal
; gefunden wurde, kritisch!

                btst    #0,15(A0)       ; m_own gerade?
                bne.s   loop_1          ; nein, weiter
                btst    #0,7(A0)        ; m_start gerade?
                bne.s   loop_1          ; nein, weiter
                btst    #0,11(A0)       ; m_length gerade?
                bne.s   loop_1          ; nein, weiter

                movea.l A0,A1           ; evtl. neuer MD
                tst.l   12(A0)          ; m_own = 0?
                bne.s   loop_0          ; nein, weiter

                subq.w  #4,A0           ; Adresse des MPB
fini:           move.l  A0,D0           ; RÅckgabewert
                bra     alloc_st

stuck:          addq.w  #1,D2           ; Anzahl der Versuche hochzÑhlen
                movea.l A1,A0           ; war kein gÅltiger m_link
                movea.l (A1),A1         ; alten Zeiger nehmen
                cmp.w   #10,D2          ; maximale Anzahl der Versuche
                bne.s   loop_1
                bra     mpberr

                ENDPART

                DATA
                >PART 'Daten'
*************************
* Zum Schluû noch ein paar Daten
*************************
                DC.B "TTAB"
tostab:         DC.W -1,-1
                DC.L -1,-1

                DC.W $0100
                DC.W FRG
                DC.L -1
                DC.L $56EC

                DC.W $0102
                DC.W FRG
                DC.L -1
                DC.L $7E8E

                DC.W $0104
                DC.W FRG
                DC.L $08081988
                DC.L $522E

                DC.W $0104
                DC.W FRG
                DC.L -1
                DC.L $5328

                DC.W $0106
                DC.W FRG
                DC.L -1
                DC.L $5368

                DC.W $0205
                DC.W FRG
                DC.L -1
                DC.L $578E

                DC.W $0205
                DC.W CH
                DC.L -1
                DC.L $578E

                DC.W $0206
                DC.W FRG
                DC.L -1
                DC.L $59DA

                DC.W $0301
                DC.W FRG
                DC.L -1
                DC.L $71E2

                DC.W $0301
                DC.W UK
                DC.L -1
                DC.L $70E8

                DC.W $0305
                DC.W FRG
                DC.L -1
                DC.L $70E8

                DC.W $0306
                DC.W FRG
                DC.L -1
                DC.L $73CA

                DC.W 0

keinerd:        DC.B "Keine entspr. RAM-Disk installiert!",7,13,10,0
fehler:         DC.B "Fehler aufgetreten!",7,13,10,0
info:           DC.B 27,"ERAM-Disk "
infolw:         DC.B "X: aus dem System entfernt.",13,10,0
mpbmsg:
                DC.B 13,10,"Vorsicht: Unbekannte TOS-Version!",7,13,10,0
mpberror:
                DC.B "MPB-Variable nicht gefunden!",7,0

                EVEN
aespb:          DC.L contrl,global,intin,intout
                DC.L addrin,addrout

                BSS
autoflag:       DS.W 1

contrl:
opcode:         DS.W 1
sintin:         DS.W 1
sintout:        DS.W 1
saddrin:        DS.W 1
saddrout:       DS.L 1
                DS.W 5
global:         DS.L 8
intin:          DS.W 10
ptsin:          DS.W 10
intout:         DS.W 10
ptsout:         DS.W 10
addrin:         DS.W 10
addrout:        DS.W 10

; Zwischenspeicher fÅr das Hauptprogramm
freedum:        DS.L 4
; Vektoren
bpb_s:          DS.L 1
bpb_ps:         DS.L 1
rw_s:           DS.L 1
rw_ps:          DS.L 1
mediach_s:      DS.L 1
mediach_ps:     DS.L 1
progende:
                ENDPART

                END
