; ***********************************************
; *                                             *
; *                S P O O L x x x              *
; *          relozierbar assemblieren!          *
; *           (c) 1992 MAXON Computer           *
; *                                             *
; ***********************************************

 include      d:\tos.q

mfp     equ $fffffa00
gi      equ $ffff8800
hz200   equ $4ba
timeout equ 2000       ; Timeout: 10 Sek.

top     bra     install

fname2  dc.b '\AUTO\'
fname   dc.b 'SPOOL*.PRG',0

buflen  dc.l    $8000  ; Puffergrîûe
                       ; (Default: 32 KB)
last    dc.l    0      ; Zeitpunkt des letzten
                       ; Non-Busy-Irq bzw. wann
                       ; bei einem Druckvorgang
                       ; das 1. Zeichen ausgege-
                       ; ben wird.
lobuf   ds.l    1      ; Anf.adresse buffer
hibuf   ds.l    1      ; Adresse hinter buffer
outmark ds.l    1      ; Adresse mit nÑchstem
                       ; auszugebendem Zeichen
inmark  ds.l    1      ; nÑchste freie Adresse
                       ; im buffer
                       ; inmark = outmark :
                       ;        buffer leer
                       ; inmark + 1 = outmark :
                       ;        buffer voll

Irq     movem.l d0/d1/a0,-(sp)
        move.l  last(pc),d1    ; letzter NonBusy-
        move.l  hz200,d0       ; Irq Ñlter als
        move.l  d0,last        ; (aktuelle Zeit
        sub.l   d1,d0          ;     nach last
                               ;     bringen)
        cmp.l   #timeout,d0    ; timeout-Wert ?
        bcs.s   Irq0           ; Nein: Irq0
        move.l  inmark(pc),outmark
                               ; Puffer lîschen
Irq0    move.l  outmark(pc),a0 ; Puffer leer ?
        cmp.l   inmark(pc),a0  ;
        beq.s   Irq2           ; Ja: Irq2
        move.b  (a0)+,d0       ; NÑchstes Zeichen
        cmp.l   hibuf(pc),a0   ;
        bne.s   Irq1           ;
        move.l  lobuf(pc),a0   ;
Irq1    move.l  a0,outmark     ; nach d0
        bsr.s   Ausgabe
Irq2    bclr    #0,mfp+$11     ; Busy-Interrupt 
                               ; wieder freigeben
                               ; (I/O-Port 0 des
                               ; Interrupt-In-
                               ; Service-Register
                               ; B des MFP 68901)
        movem.l  (sp)+,d0/d1/a0
        rte

Ausgabe lea     gi,a0          ; Reg. 7 des
        move.b  #7,(a0)        ; Soundchip wÑhlen
        move.b  (a0),d1        ; Reg. 7 nach d1
        bset    #7, d1         ; Port B des
                               ; Soundchip (Druk-
                               ; kerdaten) auf
        move.b  d1,2(a0)       ; Ausgabe stellen
        move.b  #15,(a0)       ; Reg. 15 (Port B)
                               ; auswÑhlen
        move.b  d0,2(a0)       ; d0 auf Port B
                               ; ausgeben
        move.b  #14,(a0)       ; Reg. 14 (Port A)
                               ; auswÑhlen
        move.b  (a0),d1        ; Bit 5 des Port A
        bclr    #5,d1          ; (Strobe)
        move.b  d1,2(a0)       ; Low setzen
        bset    #5,d1          ; Strobe High
        move.b  d1,2(a0)       ; setzen
                               ; Strobe Low- und
                               ; High-Setzen er-
                               ; gibt einen
                               ; Strobe-Impuls
        rts

        dc.b    'XBRA'         ; XBRA-
        dc.b    'SPLX'         ; Kennung
OldBconOut:                    ; alter
        dc.l    1              ; BConOut-Vektor
BconOut:
        move.l  last(pc),d1    ; letzter NonBusy-
        move.l  hz200,d0       ; Irq Ñlter als
        sub.l   d1,d0          ;
        cmp.l   #timeout,d0    ; timeout-Wert ?
        bcs.s   BconOut1       ; Nein: BconOut1
        move.l  inmark(pc),a0  ; Puffer leer ?
        cmp.l   outmark(pc),a0 ;
        bne.s   BconOut0       ; Nein: BconOut0
        move.l  $55e,a0        ; Bcostat
        jsr     (a0)           ; fÅr PRT
        tst.l   d0             ; Drucker nicht
                               ;         bereit ?
        beq.s   BconOut0       ; Ja: BconOut0
        move.l  hz200,last     ; last mit aktuel-
        bra.s   BconOut2a      ; ler Zeit versor-
                               ; gen
BconOut0:
        move.l  inmark(pc),outmark
                               ; Puffer lîschen
        moveq   #0,d0          ; Fehler zurÅck-
        rts                    ;  melden
BconOut1:
        move.l  inmark(pc),d0  ; liegt inmark
        addq.l  #1,d0          ; nur 1 Stelle
        cmp.l   hibuf(pc),d0   ; hinter outmark,
        bne.s   BconOut2       ; d.h. ist der
        move.l  lobuf(pc),d0   ; Puffer
BconOut2:
        sub.l   outmark(pc),d0 ; voll ?
        beq.s   BconOut0       ; Ja: BconOut0
BconOut2a:
        move.w  6(sp),d0       ; auszugebendes
                               ; Zeichen
        move.w  sr,d2          ; Statusregister
                               ; nach d2 retten
        or.w    #$700,sr       ; Interrupts
                               ; ausmaskieren
        move.l  inmark(pc),a1  ; Puffer leer ?
        cmp.l   outmark(pc),a1 ;
        bne.s   BconOut3       ; Nein: BconOut3
        lea     mfp,a0
        btst    #0,1(a0)       ; Drucker busy ?
        bne.s   BconOut3       ; Ja: BconOut3
        btst    #0,$d(a0)      ; Ist ein
                               ; Busy-Interrupt
                               ; pending ?
        bne.s   BconOut3       ; Ja: BconOut3
        bsr     Ausgabe
        bra.s   BconOut5
BconOut3:
         move.b  d0,(a1)+      ; Zeichen in den
        cmp.l   hibuf(pc),a1   ;
        bne.s   BconOut4       ;
        move.l  lobuf(pc),a1   ;
BconOut4:
        move.l  a1,inmark      ; Puffer schreiben
BconOut5:
        move.w  d2,sr          ; Statusregister
                               ; restaurieren,
                               ; insbes. Inter-
                               ; rupts wieder
                               ; zulassen
        moveq   #-1,d0         ; OK zurÅckgeben
        rts

        dc.b    'XBRA'         ; XBRA-
        dc.b    'SPLX'         ; Kennung
OldGemDos:                     ; alter
        dc.l    1              ; GemDos-Vektor
NewGemDos:
        move.l  usp,a0
        move.w  (sp),d0        ; Trap-Aufruf im
        btst    #13,d0         ; Supervisor-Mode?
        beq.s   NewGemDos1     ; Nein: NewGemDos1
        lea     6(sp),a0
NewGemDos1:
        cmpi.w  #5,(a0)+       ; Funktions-Nr. 5
                               ; (Cprnout) ?
        bne.s   ExitNewGemDos  ; Nein: 
                               ; ExitNewGemDos
        move.w  (a0),-(sp)     ; Zeichen auf
                               ; Stack legen
        clr.w   -(sp)          ; GerÑt 0 fÅr
                               ; BIOS-Bconout
        move.l  $57e,a0        ; Aufruf
        jsr     (a0)           ; bconout fÅr PRN
        addq.l  #4,sp          ; Stack-Korrektur
        rte
ExitNewGemDos:
        jmp     $11111111

buffer                         ;
Install movea.l 4(sp),a5       ; a5=Basepageadr.
        clr.l   -(sp)
        Super
        move.l  d0,-(sp)       ; alten ssp auf
                               ; Stack retten
        bsr.s   GetBufSize
        pea     logo(pc)
        Cconws
        lea     buffer(pc),a0
        move.l  a0,lobuf
        move.l  a0,inmark
        move.l  a0,outmark
        adda.l  buflen(pc),a0
        move.l  a0,hibuf
        bsr     Setvec
        Super
        pea     Irq            ; Setzt Interrupt-
                               ; vektor fÅr I/O-
        clr.w   -(sp)          ; Port 0 (Drucker-
                               ; Busy des
        Mfpint                 ; MFP 68901
        clr.w   -(sp)
        move.l  #$100+Install-top,d0
        add.l   buflen(pc),d0
        move.l  d0,-(sp)
        Ptermres

GetBufSize:
        clr.w   -(sp)          ; Prg-Datei suchen
        pea     fname(pc)      ; ->'SPOOL*.PRG'
        move.l  36(a5),a5      ; PD-Adresse der 
                               ; Eltern
        move.l  36(a5),a5      ; PD-Adresse der
                               ; Groûeltern
        tst.l   36(a5)         ; Urgroûeltern
                               ; vorhandenn ?
        bne.s   GetBufSize1    ; Ja: GetBufSize1
        move.l  #fname2,(sp)   ; Nein: Programm
                               ; stammt aus \AUTO
GetBufSize1:
       Fsfirst
       tst.w   d0              ; Datei gefunden?
       bne.s   GetBufSize2     ; Nein :
                               ;     GetBufSize2
       Fgetdta
       addi.l  #30+5,d0        ; Zeiger auf Da-
                               ; teiname (nach
       movea.l d0,a0           ; 'SPOOL') in a0
       clr.w   d0              ; Puffergrîûe
       bsr.s   Digit           ; nÑchste Stelle
       bne.s   GetBufSize2     ; fehlerhafte An-
                               ; gabe:GetBufSize2
       bsr.s   Digit           ; nÑchste Stelle
       bne.s   GetBufSize2     ; fehlerhafte An-
                               ; gabe:GetBufSize2
       bsr.s   Digit           ; nÑchste Stelle
       bne.s   GetBufSize2     ; fehlerhafte An-
                               ; gabe:GetBufSize2
       mulu    #1024,d0
       move.l  d0,buflen
       lea     size(pc),a1     ; size im logo
       move.b  -(a0),-(a1)     ;
       move.b  -(a0),-(a1)     ;
       cmpi.b  #'0',-(a0)      ;
       beq.s   GetBufSize2     ; mit Puffergrîûe
       move.b  (a0),-(a1)      ; laden
GetBufSize2:
       rts

Digit  move.b  (a0)+,d1
       cmpi.b  #'0',d1
       bcs.s   Digit1          ; < '0'
       cmpi.b  #'9',d1
       bhi.s   Digit1          ; > '9'
       andi.b  #$0f,d1
       mulu    #10,d0
       add.w   d1,d0
       moveq   #0,d1
       rts
Digit1 moveq   #1,d1
       rts
              
Setvec move.l  $57e,OldBconOut ; BIOS-Bconout
       move.l  #BconOut,$57e   ; umleiten
       pea     NewGemDos(pc)   ; GEMDOS
       move.w  #33,-(sp)       ;
       Setexc                  ; umleiten
       move.l  d0,ExitNewGemDos+2
       move.l  d0,OldGemDos
       lea     mfp,a0
       bclr    #0,3(a0)        ; Interrupt, wenn
                               ; Busy auf 0 geht!
       bclr    #0,5(a0)        ; I/O-Port Busy-
                               ; Eingang auf
                               ; Eingabe !
       rts

logo   dc.b $1b,'E',$1b,'p',' Spooler          '
       dc.b '(C) 26.6.1992  Horst '
       dc.b 'Albrecht, Brahmsstr. 25, 4047 '
       dc.b 'Dormagen 5 ',$1b,'q',$0d,$0a
       dc.b ' - Puffergrîûe:  32'
size   dc.b ' KB',$0d,$0a
       dc.b ' - nutzt die Geschwindigkeit des '
       dc.b 'Druckers optimal',$0d,$0a
       dc.b ' - Ausschalten des Druckers fÅr 10 '
       dc.b 'Sek. beendet jeden Druckvorgang'
       dc.b $0d,$0a
       dc.b ' - am Beginn eines Drucks erscheint'
       dc.b ' bei ausgeschaltetem Drucker nach'
       dc.b $0d,$0a
       dc.b '   spÑtestens 10 Sek. eine Fehler'
       dc.b 'meldung unabhÑngig von der Art der'
       dc.b $0d,$0a
       dc.b '   Programmierung der Anwendung'
       dc.b $0d,$0a
       dc.b ' - muû vor jedem anderen Programm '
       dc.b 'gestartet werden, welches ebenfalls'
       dc.b $0d,$0a
       dc.b '   die BIOS-PRN-bconout-Routine '
       dc.b 'verÑndert',$0d,$0a
       dc.b ' - Durch Umbenennung des Programms '
       dc.b 'in SPOOLxxx.PRG lÑût sich der '
       dc.b 'Spooler',$0d,$0a
       dc.b '   mit frei wÑhlbarer Puffergrîûe '
       dc.b 'verwenden.',$0d,$0a
       dc.b '   xxx ist die Puffergrîûe in KB '
       dc.b 'und muû mit 3 Stellen angegeben '
       dc.b 'werden.',$0d,$0a
       dc.b '   Bei einer fehlerhaften Angabe '
       dc.b 'wird der Puffer mit 32 KB '
       dc.b 'eingerichtet.',0

              END
 
