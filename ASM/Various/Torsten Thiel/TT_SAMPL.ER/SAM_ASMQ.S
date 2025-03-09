        ;*****************************************************
        ; SAM_ASM.PRG            geschrieben von Torsten Thiel
        ; wird von MINI_SAM.PRG benîtigt und erlaubt auf einem
        ; ST bis zu 2*50000 Messungen je Sekunde
        ;*****************************************************
.TEXT
        ;
        movem.l d0-d7/a1-a6,-(sp)
        ;
        ;
        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1              ; in den Supervisormodus
        addq.l  #6,sp           ; schalten
        lea.l   oldsp(pc),a0
        move.l  d0,(a0)         ; alten Stack merken
        ;
        move.w  #$2700,sr       ; ab jetzt kein IRQ mehr
        ;
        ;
        ;** alle fÅr das Sampeln notwendigen Adress- und Datenregister setzen
        ;
        movea.l startadr(pc),a1 ; Startadresse
        movea.l a1,a2
        adda.l  anzahl(pc),a2   ; Endadresse
        movea.l #$ffff8800,a5   ; SID-Basis
        movea.l #$ffff8802,a4   ; SID-Basis+2
        movea.l #$fffffa00,a6   ; MFP-Basis
        movea.l #$fffffa0d,a3   ; MFP-Basis+13
        ;
        moveq.l #15,d1          ; SID-Register fÅr Druckerport
        moveq.l #4,d2           ; fÅr Bit 4 testen
        move.l  #$0e002f00,d3   ; Long fÅr STROBE Hi
        move.l  #$0e000f00,d4   ; Long FÅr STROBE Lo
        ;
        ;** Timer D fÅr das Sampeln vorbereiten
        ;
        move.b  zaehler(pc),d0  ; ZÑhlerstartwert holen
        move.b  d0,$25(a6)      ; und setzen
        move.b  $1d(a6),d0      ; Vorteiler des Timer's C/D holen
        andi.b  #$f0,d0         ; und Timer D neu setzen
        move.b  vorteil(pc),d7
        or.b    d7,d0
        move.b  d0,$1d(a6)
        bset    #4,9(a6)        ; Timer D muû IRQ geben kînnen
        ;
        ;
        move.b  #7,(a5)         ; Port B auf Eingabe
        move.b  (a5),d0         ; schalten
        andi.b  #$7f,d0
        move.b  d0,2(a5)
        ;
        ;** Sampler in Ausgangszustand bringen
        ;
        move.l  d3,(a5)         ; STROBE Hi senden
        move.b  d1,(a5)         ; Port B selektieren
        move.b  (a5),d0         ; Port B testen
        beq.s   Takt1           ; wenn 'Ja' war Sampler in Ausgangszustand
        ;                       ; und TAKT1 folgt
        move.l  d4,(a5)         ; wenn 'Nein' STROBE Lo und
        move.l  d3,(a5)         ; STROBE Hi senden
Takt1:  
        move.l  d4,(a5)         ; STROBE Lo senden
        ;                       ; fallende Flanke von TAKT1
        ;
        ;
        bclr    d2,(a3)
        move.b  (a3),d5         ; move ist schneller als bclr
        ;
inplr:  
        btst    d2,(a3)         ; warten bis Timerzeit
        beq.s   inplr           ; abgelaufen
        move.b  d5,(a3)         ; Timer zurÅcksetzen
        ;
        move.b  d1,(a5)         ; Port B selektieren
        move.b  (a5),(a1)+      ; Port B lesen
        ;
        move.l  d3,(a5)         ; STROBE Hi senden
        ;
        move.b  d1,(a5)         ; Port B selektieren
        move.b  (a5),(a1)+      ; Port B lesen
        ;
        move.l  d4,(a5)         ; STROBE Lo senden
        move.w  d3,(a4)         ; STROBE Hi senden\ mit word-adressierung
        move.w  d4,(a4)         ; STROBE Lo senden/ geht es schneller
        ;
        cmpa.l  a1,a2           ; ist Endadressen schon erreicht?
        bne.s   inplr           ; wenn 'Nein' noch ein Durchlauf
        ;
        ;
        ;
        move.b  $1d(a6),d0
        andi.b  #$f0,d0         ; Timer D stoppen
        move.b  d0,$1d(a6)
        bclr    #4,9(a6)
        ;
        move.l  d3,(a5)         ; STROBE Hi senden
        move.l  d4,(a5)         ; STROBE Lo senden
        ;                       ; Sampler in Ausgangsstellung
        ;
        move.w  #$2300,sr       ; IRQ's wieder erlauben
        ;
        move.l  oldsp(pc),-(sp)
        move.w  #$20,-(sp)
        trap    #1              ; in User-Modus zurÅck
        addq.l  #6,sp
        ;
        ;
        ;
        ;
        ;** Daten fÅr Soundausgabe Mundgerecht machen
        ;
        move.l  #%01111111011111110111111101111111,d0
        movea.l startadr(pc),a1 ; Startadresse
        ;                       ; Endadresse steht noch in a2
        move.l  a2,d7
        andi.l  #%11111111111111111111111111100000,d7
neglr32:        
        eor.l   d0,(a1)+        ; aus GeschwindigkeitsgrÅnden
        eor.l   d0,(a1)+        ; gleich 32 Byte
        eor.l   d0,(a1)+
        eor.l   d0,(a1)+
        eor.l   d0,(a1)+
        eor.l   d0,(a1)+
        eor.l   d0,(a1)+
        eor.l   d0,(a1)+
        ;
        cmp.l   a1,d7           ; ist Endadressen schon erreicht?
        bne.s   neglr32         ; wenn 'Nein' noch ein Durchlauf
        ;
        move.l  a2,d7
        andi.l  #%00000000000000000000000000011111,d7
        beq.s   ende
neglr1: 
        eor.b   d0,(a1)+        ; die restlichen Bytes byteweise
        dbf     d7,neglr1
        ;
        ;
        ;
ende:   
        movem.l (sp)+,d0-d7/a1-a6
        ;
        ;
        rts     
        ;
        ;
        ;
        ;
        ;
        ;
.DATA 
startadr:       
        .DC.l 0
anzahl: 
        .DC.l 0
zaehler:        
        .DC.b 20
vorteil:        
        .DC.b 1
oldsp:  
        .DC.l 0
.END
