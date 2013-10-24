; #########################################################################

; 4-PLANES-FöLLROUTINE (AUSMASKIERT).

; HLine 18.1.1993, HLine-Creator 19.1.1993
; Umarbeitung zu Includefile:    29.1.
; Letzte Korrektur:               5.3.1994
; Umbau auf PMOD:                23.12.1994
; Update:                        27.12.1994 (Fehlerkorrektur x2>x1)
; Update:                        18.3.1995 (Optimierung)

; Coded by BDC/AURA, alias Jochen der Knaus.
; Coderight (C) AURA-Productions.

; Initialisierung:
;               "calc_r_16"     - Berechnen der Randoffsets.+
; Paramerter:   a0      - Arrayadresse linke Offsets/RÑnder
;               a1      -       "      rechte       "
;               a2      - Scanlineoffsettabelle
; Arraygrîûe:   x_aufl_max * 4.

;               "build_16"      - Aufbau der HLineroutinen.
;               a0      - Buffer fÅr Routinencode (Grîûe: ca. 16*256)
;               a1      - Routinenadressen und Farbewerte (Grîûe: 16*16)

;    VERSION:           1.03
;    UPDATE:            29.1.1993
;    OPTIMIERUNG:       18.3.1995 (4 Tz / HLine)
;    WICHTIG:           Datencache wird in der HLineroutine AUSgeschalten !
; #########################################################################

FEHLERKOR       EQU     0               ; Fehlerkorrektur (0=an) (ein "bne.s")

x_aufl_max      EQU     320             ; max. horizontale Auflîsung
y_aufl_max      EQU     280             ; max. vertikale Auflîsung.
x_aufl          EQU     320             ; tatsÑchliche horiz. Auflîsung.
mul_4           EQU     1               ; Koords. *4 angeliefert (0=ja)

len_h16         EQU     260             ; LÑnge 16 Farb-HLinerout.
hl_cache        EQU     $0019           ; Cacheinitialisierungswert.

PMOD            EQU     0               ; 0 : PMOD-File / 1: Includefile.

; #########################################################################
; Aufruf HLine-FÅllroutine.

; d3 - Planedaten: Plane 4+3
; d4 - Planedaten: Plane 2+1
; d7 - Anzahl HLines.

; a0 - Screenbase
; a3 - Offset und Randbitmaptabelle fÅr linke Koordinaten.
; a4 -               "                  rechte      "    .
; a5 - Linkes Koordinatenarray.
; a6 - Rechtes Koordinatenarray.
; #########################################################################

; ///////////////////////////////////////////////////////////////////
; Baut 16 HLine-Routinen auf, welche auf 4 Bitplanes arbeiten (Farben
; 0-15). Voll deckend und Cachegerecht < 256 Bytes lang.

; Parameter:    a0      - Bufferadresse, an die Routinen sollen.
;               a1      - Adressenliste und Farbliste fÅr Routinen.
;                         wird vom Proggy folgendermaûen besetzt:
;                         0.l - move_daten Wort 1 und Wort 2
;                         4.l -      "        " 3     "    4
;                         8.l - Adresse der HLineroutine.
;                        12.l - nicht belegt.

; Aufruf der HLineroutinen:
; d3 - Planedaten: Plane 4+3    Farbliste long 0
; d4 - Planedaten: Plane 2+1        "     long 1
; d7 - Anzahl HLines minus 1

; a0 - Screenbase
; a3 - Offset und Randbitmaptabelle fÅr linke Koordinaten.
; a4 -               "                  rechte      "    .
; a5 - Linkes Koordinatenarray.
; a6 - Rechtes Koordinatenarray.

; ALLE Adressregister sowie d0,d1,d2 werden ungesichert benutzt !!!

; Generierungsroutine etwas unelegant und unflexibel, aber who care's ?
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

        IFEQ    PMOD                            ; BinÑrfile ?
                ORG     0

                MODUL   "f:\lib\hline_4.inc"
                MC68030

                bra.w   build_16                ; Routinenaufbau.
                bra.w   calc_r_16               ; Offsettabellen.

                DC.B    'PMOD'                  ; PMOD-Header
                DC.B    'H-Lines 4 Plans',0
                DC.B    'BDCannibal/AURA',0
                DC.B    '01930395'
                DC.B    '010320--'
                DC.B    '--------'
        ENDIF

build_16:       movem.l d0-a6,-(sp)

                movec   cacr,a2
                pea     (a2)
                moveq   #0,d0
                movec   d0,cacr

                lea     hl_r_tab16(PC),a2       ; HLine-aufbau Tabelle.

                moveq   #15,d7          ; 16 Routs
rout_loop:      move.w  d7,d0           ; ZÑhler holen. Wandlung spiegelverk.
                eor.w   #15,d0          ; 16-x = Farbe.
                lea     (a2,d0.w*8),a6  ; VerknÅpfungstabelle dieser Farbe.
                
                moveq   #3,d6           ; konstante Planedaten dieser Farbe.
get_pl_da:      ror.w   #1,d0           ; Bit ins C-Bit schieben.
                bcc.s   clr_pla         ; War Bit gesetzt ?

                move.w  #$ffff,(a1)+    ; diese Plane war gesetzt.
                bra.s   pla_set

clr_pla:        clr.w   (a1)+           ; Plane lîschen.
pla_set:        dbra    d6,get_pl_da    ; nÑchste Plane checken.

                move.l  a0,(a1)+        ; Routinenadresse sichern.
                addq.l  #4,a1           ; auf 16 Byte Grenze bringen !

                moveq   #0,d3           ; Offset-Berechnungsfaktor.

                move.w  (a6)+,d0        ; LÑnge VerknÅpfungsrout. in Bytes.

                move.l  lea_pc+0(pc),(a0)+
                move.l  lea_pc+4(pc),(a0)+
                move.w  lea_pc+8(PC),(a0)+ ; "move"-Routinenende.
                lea     -2(a0),a5       ; spÑter kommt noch Offset rein !

                move.w  #$203c,(a0)+    ; "move.l #x,d0", Cache install.
                move.l  #hl_cache,(a0)+
                move.l  s_cache(PC),(a0)+ ; Cache lîschen und anschalten.

                lea     hline_16(PC),a4 ; allgemeine Startroutine.
                moveq   #9-1,d6         ; Grîûe Startrout in Wîrtern (-1)
move_start:     move.w  (a4)+,(a0)+
                dbra    d6,move_start

                moveq   #9*2,d3         ; Startroutine.

                move.b  (a4),(a0)+      ; Erste HÑlfte des "bgt.s"-Befehls.
                move.b  d0,(a0)         ; LÑnge der VerknÅpfungsroutine.

        IFEQ    FEHLERKOR
                addi.b  #14,(a0)+       ; "lea","dbra","rts" und "bne.s"

                addq.l  #2,a4           ; "bne.s" anfÅgen, um abzubrechen,
                move.b  (a4),(a0)+      ; falls x2_off > x1_off ! 
                move.b  d0,(a0)
                addq.b  #4,(a0)+
                addq.w  #4,d3
        ELSE
                addi.b  #12,(a0)+       ; "lea","dbra" und "rts"
                addq.w  #2,d3           ; 2 Bytes Rout.
        ENDIF

                move.w  andl_d0d1(PC),(a0)+ ; Shortlinebefs: Beide Randwerte
                move.w  swap_d0(PC),(a0)+   ; miteinander verknÅpfen.
                addq.w  #4,d3           ; nicht den öberblick verlieren.
        
                bsr.s   verkn_d0        ; VeknÅpfungscode fÅr d0 einfÅgen.
                add.w   d0,d3           ; LÑnge VerknÅpfungsrout.

                lea     co_e_s(PC),a3   ; "next line"-Code
                move.w  (a3)+,(a0)+     ; "lea $x(a0),a0"
                addq.w  #4,d3           ; nÑchsten Befehl inkl. ! (Offset !)

                move.w  d3,2(a3)
                neg.w   2(a3)           ; negativer Offset !

                move.l  (a3)+,(a0)+     ; "dbra"
                addq.w  #2,d3           ; Befehl vorher, jetzt noch Off-wort.
                move.w  (a3),(a0)+      ; "rts"
                addq.w  #2,d3

                move.w  swap_d0(PC),(a0)+  ; BIG LINE: linker Randwert.
                addq.w  #2,d3

                bsr.s   verkn_d0        ; Randwert verknÅpfen.
                add.w   d0,d3

                move.l  s_jmp(PC),(a0)+ ; Startcode fÅr aufg. Schleife.
                move.w  s_jmp+4(PC),(a0)+
                addq.w  #6,d3

                move.l  movem(pc),d1    ; move-Code holen
                moveq   #38-1,d2        ; 38 mal diese Sequenz.
fill_move:      move.l  d1,(a0)+
                dbra    d2,fill_move

                addi.w  #38*4,d3

                move.w  d3,(a5)         ; Offset fÅr ersten "lea-Befehl"
                addi.w  #12,(a5)        ; "movec"+"movel"  wurden Åbergangen.

                move.w  swap_d1(PC),(a0)+ ; rechter Randwert
                addq.w  #2,d3
                bsr.s   verkn_d1        ; ebenfalls verknÅpfen.
                add.w   d0,d3

                lea     co_e_s(PC),a3   ; "next line" s.o.
                move.w  (a3)+,(a0)+
                addq.w  #4,d3
                move.w  d3,2(a3)
                neg.w   2(a3)
                move.l  (a3)+,(a0)+
                move.w  (a3)+,(a0)+

                dbra    d7,rout_loop

                move.l  (sp)+,d0
                movec   d0,cacr

                movem.l (sp)+,d0-a6
                rts

; VerknÅpfungscode fÅr d0/d1 nach Tabelle erzeugen und in Code schreiben.
; Tab. in a6.
verkn_d0:       movem.l d0/d7/a5/a6,-(sp)
                lea     befs_16(PC),a5  ; mit d0 verknÅpfen, Tab. normal.
                bra.s   s_verk

verkn_d1:       movem.l d0/d7/a5/a6,-(sp)
                lea     befs_16+2(PC),a5        ; mit d1: 1 Befehl Offset !

s_verk:         moveq   #6-1,d7         ; max. 6 Befehle.
get_bef:        move.b  (a6)+,d0        ; Befehlbyte holen.
                bmi.s   vor_end         ; $ff signalisiert vorzeitiges Ende.

                ext.w   d0
                move.w  (a5,d0.w*2),(a0)+ ; Befehl holen und in Code eintr.
                dbra    d7,get_bef

vor_end:        movem.l (sp)+,d0/d7/a5/a6
                rts

swap_d0:        swap    d0
swap_d1:        swap    d1
andl_d0d1:      and.l   d1,d0           ; fÅr Shortlines.

movem:          move.l  d3,(a1)+        ; fÅr groûe Verschiebedinge
                move.l  d4,(a1)+

s_cache:        movec   d0,CACR         ; Zum Cache lîschen und starten.

; Allgemeine Startroutine bei allen Routs.
hline_16:       move.w  (a5)+,d0        ; linke Koordinate.             [2 By]
                move.w  (a6)+,d1        ; rechte    "                      [2]

        IFNE    mul_4                   ; werden Koordinaten * 4 angeliefert ?
                move.l  (a3,d0.w*4),d0  ; nein: Randbitmap + Offset links  [4]
                move.l  (a4,d1.w*4),d1  ;                 "         rechts [4]
        ELSE
                move.l  (a3,d0.w),d0    ; sie werden schon * 4 angeliefert.
                move.l  (a4,d1.w),d1
        ENDIF

                lea     (a0,d0.w*2),a1  ; auf Screenadresse gehen.      [4]

                sub.w   d0,d1           ; LÑnge HLine in 16 Pixeln.     [2]
                bgt.s   hline_16        ; Linie lÑnger als 16 Pixel !   [2]
                bne.s   hline_16        ; Gegen Fehler !!!

; Code am Ende einer Shortline ( 8 Bytes. )
co_e_s:         adda.l  d5,a0
dbra:           dbra    d7,dbra         ;                               [4]
                rts                     ;                               [2]

; Um "move"-Routinenende in Register zu haben. Kann nicht Åber JMP(PC,d0.w)
; angesprungen werden, da bei 640 Pixlen Breite die Sache > 128 Bytes ist.
lea_pc:         move.l  #(x_aufl/2),d5
                lea     0(PC),a2        ;                               [4]

; Code zum Einsprung in die FÅllschleife der "inneren"-Wîrter. (6 Bytes).
s_jmp:          neg.w   d1              ; RÅckwÑrts in Schleife einspringen. [2]
                jmp     (4.b,a2,d1.w)   ; +4 wegen rechter RandverknÅpfung.  [4]

; FÅr VerknÅpfungscodeaufbau benîtigten Befehle. Befehlscode fÅr Tabelle:
befs_16:        move.w  d0,d2           ; 0     Zeichnen links: Codes normal,
                move.w  d1,d2           ; 1              rechts: + 1 !!!
                not.w   d0              ; 2
                not.w   d1              ; 3
                not.w   d2              ; 4
                not.w   d2              ; 5     fÅr rechte RandverknÅpfung.
                or.w    d0,(a1)+        ; 6 
                or.w    d1,(a1)+        ; 7
                and.w   d0,(a1)+        ; 8
                and.w   d1,(a1)+        ; 9 
                and.w   d2,(a1)+        ; 10
                and.w   d2,(a1)+        ; 11    fÅr rechts

; VerknÅpfungscodetabelle:      0.w : LÑnge Routine.
;                         2.b - 7.b : Befehle. ($ff=Ende).
hl_r_tab16:     dc.b    0,10            ; Farbe   0: 10 Bytes, nur maskieren.
                dc.b    2,8,8,8,8,$ff
                dc.b    0,10,6,2,8,8,8,$ff      ; 1
                dc.b    0,12,0,4,10,6,10,10     ; 2
                dc.b    0,10,6,6,2,8,8,$ff      ; 3
                dc.b    0,12,0,4,10,10,6,10     ; 4
                dc.b    0,12,0,4,6,10,6,10      ; 5
                dc.b    0,12,0,4,10,6,6,10      ; 6
                dc.b    0,10,6,6,6,2,8,$ff      ; 7
                dc.b    0,12,2,8,8,8,2,6        ; 8   ...,2 (modified !)
                dc.b    0,12,0,4,6,10,10,6      ; 9
                dc.b    0,12,0,4,10,6,10,6      ; 10
                dc.b    0,12,0,4,6,6,10,6       ; 11
                dc.b    0,12,0,4,10,10,6,6      ; 12
                dc.b    0,12,0,4,6,10,6,6       ; 13
                dc.b    0,12,0,4,10,6,6,6       ; 14
                dc.b    0,8,6,6,6,6,$ff,0       ; 15

; #########################################################################
; Berechnung der Randmuster und Offset fÅr jede Koordinate !
; #########################################################################
calc_r_16:      movem.l d0-d1/d7,-(sp)

                moveq   #0,d0
                move.w  #y_aufl_max-1,d7
lilp:           move.l  d0,(a2)+
                addi.l  #x_aufl/2,d0
                dbra    d7,lilp

                move.w  #x_aufl_max-1,d7 ; FÅr jede Koord ein Wert.
                move.w  #$FFFF,d0       ; Startmaske (x=0)
                moveq   #0,d1           ; Offset.
left_loop:      move.w  d0,(a0)+        ; Maske.
                move.w  d1,(a0)+        ; Offset.

                lsr.w   #1,d0           ; nÑchster Status.
                bne.s   no_d_sh1

                move.w  #$FFFF,d0       ; alle 15 DurchgÑnge neu anfangen.
                addq.w  #4,d1           ; nÑchster Offset.

no_d_sh1:       dbra    d7,left_loop


                move.w  #x_aufl_max-1,d7 ; Offset analog links, Maske bit-
                move.l  #$7fff8000,d0   ; spiegelverkehrt zu links.
                moveq   #0,d1
right_loop:     move.w  d0,(a1)+
                move.w  d1,(a1)+

                ror.l   #1,d0           ; nÑchsten Bitstatus.
                bcc.s   no_next_p2      ; durch ?

                addq.w  #4,d1           ; nÑchster Offset.
                move.l  #$7fff8000,d0   ; Bitstatus zurÅck.

no_next_p2:     dbra    d7,right_loop

                movem.l (sp)+,d0-d1/d7
                rts
