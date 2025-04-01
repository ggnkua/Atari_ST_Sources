*************************************************
* LOGITECH-Pilot-Maustreiber fr ATARI
* von Ralf Schernewski
* Version 1.02 vom 18.03.93
* GST-Macro-Assembler
* (c) MAXON Computer 1993
*************************************************
        OPT     ABS
*************************************************
XBRAKEN equ     'CSNM'        ; XBRA-Kennung
vtab    equ     0             ; Vektor-Tabelle
condit  equ     4             ; Zustand
n_xval  equ     5             ; neg. x-Wert
n_yval  equ     6             ; neg. y-Wert
okMT    equ     7             ; ok fr MT
b1      equ     8             ; 1. Datenbyte
b2      equ     9             ; 2. Datenbyte
b3      equ     10            ; 3. Datenbyte
mt_cond equ     11            ; Zustand mittl.
                              ; Maustaste
RCVBFL  equ     $130          ; Vektor - RS232
                              ; Empfangspuf. voll
UDR     equ     $fffffa2f     ; Datenregister MFP
ISRA    equ     $fffffa0f     ; Interrupt
                              ; In-Service Reg.A
*************************************************
        SECTION CODE
*************************************************
XBRABEG bra     main          ; Sprung zum HptPrg
*************************************************
        dc.b    'XBRA'        ; XBRA-Anfang
        dc.l    XBRAKEN       ; Kennung
oldvek1 dc.l    0             ; alter Vektor

*************************************************
newvek1                       ; Byte ber RS232
                              ; angekommen
        movem.l d0-d7/a0-a6,-(sp)
                              ; Register retten
        move.b  udr,d4        ; Datenbyte holen
        btst.l  #7,d4         ; Bit 7 gesetzt?
        bne     auxfehl       ; ja, dann Fehler

        lea     global,a4     ; globale Variablen
        lea     condtab,a3    ; Routinen-Adresse

        clr.w   d3            ; d3 l”schen
        move.b  condit(a4),d3 ; Zustand holen
        lsl.w   #2,d3         ; * 4

        move.l  $0(a3,d3.w),a2; Routine holen
        jmp     (a2)          ; reinspringen

aCond0  btst.l  #6,d4         ; Header-Bit da?
        beq.s   a_mt          ; nein, m.Taste

        move.b  d4,d3         ; Wert kopieren
        andi.b  #%00110000,d3 ; Tastenbits mask.
        lsr.b   #4,d3         ; / 16
        move.b  d3,b1(a4)     ; Tasten absp.
        ori.b   #$f8,b1(a4)   ; Header
        move.b  d4,d3         ; Wert kopieren
        andi.b  #%1100,d3     ; neg. y-Bits mask.
        lsl.b   #4,d3         ; * 16
        move.b  d3,n_yval(a4) ; abspeichern
        move.b  d4,d3         ; Wert kopieren
        andi.b  #%11,d3       ; neg. x-Bits mask.
        lsl.b   #6,d3         ; * 64
        move.b  d3,n_xval(a4) ; abspeichern
        move.b  #1,condit(a4) ; neuer Zustand: 1
        bra.s   auxend        ; Ende

a_mt    tst.b   okMT(a4)      ; Teste, ob MT ok
        bmi.s   auxend        ; nein, dann Ende

        cmp.b   #32,d4        ; m.Taste gedrckt?
        bne.s   a_mt_0        ; nein, vielleicht
                              ; losgelassen

        btst.b  #0,mt_cond(a4); schon gedrckt?
        bne.s   auxend        ; dann Ende

        bset.b  #0,mt_cond(a4); m. Taste gedrckt
                              ; setzen
        bsr.s   mtfkt         ; MT-Funktion
        bra.s   auxend        ; Ende

a_mt_0  cmp.b   #0,d4         ; mittl. Taste
                              ; losgelassen?
        bne.s   auxfehl       ; nein, dann Fehler

        bclr.b  #0,mt_cond(a4); mittl. Taste
                              ; losgelassen!
        bra.s   auxend        ; Ende

a_setc0 move.b  #0,condit(a4) ; Fehler: Zustand 0
        bra.s   auxfehl       ; -> Fehler

aCond1  cmp.b   #63,d4        ; Wert ber 63
        bhi.s   a_setc0       ; ja, -> Zustand 0

        or.b    n_xval(a4),d4 ; neg. x-Wert-Bits
                              ; hinzuaddieren
        move.b  d4,b2(a4)     ; Wert in Buffer
        move.b  #2,condit(a4) ; neuer Zustand: 2
        bra.s   auxend        ; -> Ende

aCond2  cmp.b   #63,d4        ; Wert ber 63
        bhi.s   a_setc0       ; ja, -> Zustand 0
        or.b    n_yval(a4),d4 ; neg. y-Wert-Bits
                              ; hinzuaddieren
        move.b  d4,b3(a4)     ; Wert in Buffer
        move.b  #0,condit(a4) ; neuer Zustand: 0

        lea     b1(a4),a0     ; Bufferadresse
        move.l  vtab(a4),a3   ; mit Vektortabelle
        move.l  $10(a3),a2    ; Mouseroutinen-
                              ; vektor holen
        jsr     (a2)          ; zur Mausroutine

        move.b  #0,okMT(a4)   ; kein Fehler
                              ; MT enablen
        bra.s   auxend        ; Sprung zum Ende

auxfehl move.b  #-1,okMT(a4)  ; Fehler
                              ; MT disablen
auxend  bclr    #4,isra       ; ISR-Bit l”schen
        movem.l (sp)+,d0-d7/a0-a6
                              ; Register rest.
        rte                   ; Interrupt Rck-
                              ; sprung - Stack
                              ; holen und zurck

condtab dc.l    aCond0,aCond1,aCond2
                              ; Vektortabelle

*************************************************

MTFkt   movem.l d0/a0-a4,-(sp); Register retten

        moveq   #1,d0         ; 2 mal

MTLOOP  lea     MTDat1,a0     ; Bufferadresse
        move.l  vtab(a4),a3   ; mit Vektortabelle
        move.l  $10(a3),a2    ; Mouseroutinen-
                              ; vektor holen
        jsr     (a2)          ; zur Mausroutine

        lea     MTDat2,a0     ; Bufferadresse
        move.l  vtab(a4),a3   ; mit Vektortabelle
        move.l  $10(a3),a2    ; Mouseroutinen-
                              ; vektor holen
        jsr     (a2)          ; zur Mausroutine

        dbf     d0,MTLOOP     ; Schleifenende

        movem.l (sp)+,d0/a0-a4; Register rest.
        rts                   ; Rcksprung

MTDat1  dc.b    $fa,$0,$0,$0  ; linke Taste gedr.
MTDat2  dc.b    $f8,$0,$0,$0  ; linke Taste nicht
                              ; gedrckt

*************************************************
global  dc.l    0,0,0,0       ; globale Variablen
*************************************************

XBRAEND
install move.w  #34,-(sp)     ; Kvdvbase
        trap    #14           ; XBIOS
        addq.l  #2,sp         ; Stack korr.

        lea     global,a4     ; Adresse fr glob.
                              ; Variablen
        move.l  d0,vtab(a4)   ; Vektortabelle
                              ; abspeichern
        move.b  #-1,okMT(a4)  ; MT disablen
        movea.l RCVBFL,a3     ; Vektoradresse
        cmpi.l  #XBRAKEN,-8(a3)
                              ; Kennung vorhanden
        beq.s   exstall       ; ja, -> entfernen

        lea     oldvek1,a3    ; Adresse der Save-
                              ; variablen holen
        move.l  RCVBFL,(a3)   ; alte Routinenadr.
                              ; abspeichern
        lea     newvek1,a3    ; Adresse der neuen
                              ; Routine holen
        move.l  a3,RCVBFL     ; und ablegen
        clr.b   d1            ; Routine install.
        rts                   ; Rcksprung

exstall movea.l RCVBFL,a3     ; Vektoradresse
        move.l  -4(a3),RCVBFL ; alte Routinen-
                              ; adr. restaurieren
        move.b  #-1,d1        ; Routine nicht
                              ; installiert
        rts                   ; Rcksprung

*************************************************

RSInit  move.w  #-1,-(sp)     ; SCR unver„ndert
        move.w  #-1,-(sp)     ; TSR unver„ndert
        move.w  #-1,-(sp)     ; RSR unver„ndert
        move.w  #168,-(sp)    ; UCR (7,1,none)
        move.w  #0,-(sp)      ; kein Handshake
        move.w  #7,-(sp)      ; (1200 Baud)
        move.w  #15,-(sp)     ; rsconf
        trap    #14           ; XBIOS
        add.l   #14,sp        ; Stack korr.

RSILoop move.w  #1,-(sp)      ; Ser. Schnittst.
        move.w  #1,-(sp)      ; Bconstat
        trap    #13           ; BIOS
        addq.l  #4,sp         ; Stack korr.

        tst.w   d0            ; Teste Rckgabe
        beq.s   RSIEnd        ; = 0, dann Ende

        move.w  #1,-(sp)      ; Ser. Schnittst.
        move.w  #2,-(sp)      ; Bconin
        trap    #13           ; BIOS
        addq.l  #4,sp         ; Stack korr.
        bra.s   RSILoop       ; zum Anfang

RSIEnd  rts                   ; Rcksprung

*************************************************

main    move.l  a7,a5         ; Stackpointer
        move.l  $4(a5),a5     ; Basepageadresse
        move.l  $c(a5),d5     ; L„nge Programm
        add.l   $14(a5),d5    ; + init. DB
        add.l   $1c(a5),d5    ; + uninit. DB
        add.l   #$100,d5      ; + Basepage

        move.l  a5,d1         ; Anfangsadresse
        add.l   d5,d1         ; + Programmlaenge
        add.l   #$400,d1      ; + Stack
        and.l   #-2,d1        ; Adresse gerade
        move.l  d1,a7         ; --> neuer Stack

        bsr     RSInit        ; RS232 init.

        pea     install       ; Routinenadresse
                              ; uebergeben
        move.w  #38,-(sp)     ; Supexec
        trap    #14           ; XBIOS
        addq.l  #6,sp         ; Stack korr.

        cmp.b   #0,d1         ; Routine install.?
        beq.s   end_1         ; ja, KEEP PROCESS

        pea     TEXT01        ; Textadresse push.
        move.w  #9,-(sp)      ; Cconws
        trap    #1            ; GEMDOS
        addq.l  #6,sp         ; Stack korr.

        clr.w   -(sp)         ; TERM
        trap    #1            ; GEMDOS

end_1   pea     TEXT00        ; Textadresse push.
        move.w  #9,-(sp)      ; Cconws
        trap    #1            ; GEMDOS
        addq.l  #6,sp         ; Stack korr.

        move.l  #XBRAEND-XBRABEG,d5
                              ; L„nge d. Treibers
        addi.l  #$100,d5      ; + Basepage

        move.l  d5,-(sp)      ; Programml„nge
        move.w  #$31,-(sp)    ; KEEP PROCESS
        trap    #1            ; GEMDOS

*************************************************

TEXT00  dc.b    13,10
        dc.b    'LOGIMOUSE-Treiber installiert'
        dc.b    13,10,0
TEXT01  dc.b    13,10
        dc.b    'LOGIMOUSE-Treiber entfernt'
        dc.b    13,10,0,0

*************************************************
        END

