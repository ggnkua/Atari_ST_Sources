; **************************************
; *                                    *
; * Cursorscrolling durch Mausanschlag *
; * 28.6.1990 Peter Holzwarth          *
; * (c) MAXON Computer 1990            *
; **************************************

             .INCLUDE 'MSCRMAC.IS'

GCURX        = -602    ; Offset der Maus-X-Position in den Line-A-Variablen
GCURY        = -600    ; Offset der Maus-Y-Position      - " -
sc_up        = $48     ; Scan-Code fÅr Cursor hoch
sc_do        = $50     ; Scan-Code fÅr Cursor runter

MitteLinks   = 12      ; Bereich in der Mitte des Bildes, in dem die Maus
MitteRechts  = 512     ; kein AufwÑrtsscrolling auslîsen soll

             .ABS 0
buffer:      .DS.l 1   ; Anfang der Struktur des Parameterblocks
Size:        .DS.w 1   ; fÅr den Tastaturpuffer
Head:        .DS.w 1
Tail:        .DS.w 1

             .TEXT 
; **************************************
; Initialisierung

start:       lea       StackEnd,sp      ; eigenen Stack einrichten

.appl_init:  moveq.l   #10,d0           ; wg. Accessory
             moveq.l   #0,d1
             moveq.l   #1,d2
             moveq.l   #0,d3
             bsr       aes

.LineA:      .DC.w $a000                ; Basisadresse der Line-A-Variablen
             move.l    a0,LineAvars

.kbdvect:    Iorec     #1               ; Tastaturpuffer-Parameterblock holen
             move.l    d0,KeyPar

.resolution: Getrez    ;                ; Auflîsung holen
             move.w    #199,d1          ; 200 Y-Punkte in Lo- und MidRes
             subq.w    #2,d0
             bmi       .resok
             move.w    #399,d1          ; 400 Y-Punkte in HiRes
.resok:      move.w    d1,ymax

.vbl:        Supexec   #vblinit         ; s.u.

.evnt_timer: move.l    #-1,intin        ; Zeit = -1 (nie)
             moveq.l   #24,d0
             moveq.l   #2,d1
             moveq.l   #0,d2
             moveq.l   #0,d3
             bsr       aes              ; Warten auf das Ende
             bra       .evnt_timer

vblinit:     movea.l   _vblqueue,a1     ; VBL-Interrupt-Routine instalieren
.l:          tst.l     (a1)+            ; freien Platz suchen
             bne       .l
             move.l    #test,-(a1)      ; und Routine eintragen
.e:          rts       

aes:         moveq.l   #0,d4            ; GEM-AES aufrufen
             movem.w   d0-d4,contrl
             move.l    #AESpar,d1
             move.w    #200,d0
             trap      #2
             rts       

; **************************************
; im VBL-Interrupt testen, ob Maus oben oder unten ist

test:        movea.l   LineAvars,a0
             move.w    GCURY(a0),d0
             beq       .oben
             cmp.w     ymax,d0
             beq       .unten

.innen:      tst.b     scrolling        ; Maus im Inneren des Bildschirms
             beq       .testend         ; hat zuvor Scrolling stattgefunden ?
             movea.l   KeyPar,a0
             clr.l     Head(a0)         ; dann Tastaturpuffer lîschen
             sf        scrolling        ; um Nachlaufen zu verhindern
             bra       .testend

.oben:       move.w    GCURX(a0),d0     ; Maus oben
             cmpi.w    #MitteLinks,d0   ; ist Maus im mittleren Teil des
             bcs       .obenOK          ; Bildes ?
             cmpi.w    #MitteRechts,d0
             bcs       .innen           ; dann nicht scrollen
.obenOK:     st        scrolling
             moveq     #sc_up,d0
             bsr       send
             bra       .testend

.unten:      st        scrolling        ; Maus unten
             moveq     #sc_do,d0
             bsr       send

.testend:    rts       

send:        swap.w    d0               ; Taste in Tastaturpuffer eintragen
             movea.l   KeyPar,a0        ; ($0048 0000 oder $0050 0000)
             movea.l   (a0),a1
             move.w    Tail(a0),d1
             addq.w    #4,d1
             cmp.w     Size(a0),d1      ; wrapping notwendig ?
             bcs       .1
             clr.w     d1
.1:          cmp.w     Head(a0),d1      ; Puffer voll ?
             beq       .e
             move.w    d1,Tail(a0)      ; noch nicht, Schreibzeiger erhîhen
             move.l    d0,0(a1,d1.w)    ; und Taste eintragen
.e:          rts       

             .DATA 
AESpar:      .DC.l contrl,globl,intin,intout,addrin,addrout ; AES-Parameterblock

             .BSS 
contrl:      .DS.w 12  ; AES-Datenfelder
globl:       .DS.w 15
intin:       .DS.w 2
intout:      .DS.w 1
addrin:      .DS.l 1
addrout:     .DS.l 1
             .DS.b 4096                 ; neuer Stack-Bereich
StackEnd:    
LineAvars:   .DS.l 1   ; Basisadresse der Line-A-Variablen (neg. Offsets)
KeyPar:      .DS.l 1   ; Tastaturpuffer-Parameterblock
ymax:        .DS.w 1   ; max. Y-Koordinate der Maus
scrolling:   .DS.b 2   ; -1: Scrolling wird gerade durch Maus ausgelîst
             .END 



