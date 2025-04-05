; 50/60 hz-Umschaltungsprogramm
; fÅr RGB-Monitore oder Fernseher
; nur fÅr den FALCON 030!
; geschrieben von:
; (c)1993 by MAXON-Computer
; Autor:  Daniel Richter
;         Bergische Str. 54
;         W-5620 Velbert 1
;

                TEXT
; Anfangsmeldung ausgeben:

                lea     anfangstext(pc),a0
                bsr.s   print

; Testen des Monitortyps:
; mon_type gibt in d0.w die Art des Bildschirms
; zurÅck:
;
; d0.w= 0: ST-Monochrommonitor (SM 124)
; d0.w= 1: ST-Farbmonitor = RGB-Monitor
; d0.w= 2: VGA-Monitor
; d0.w= 3: Fernseher

                bsr.s   mon_type

; nur auf RGB-Monitoren oder Fernsehern
; lohnt sich eine Umschaltung der Frequenz:

                cmp.w   #1,d0           ;RGB-Mon
                beq.s   stmonitor
                cmp.w   #3,d0           ;TV
                beq.s   fernseher

; auf VGA-Monitoren braucht nicht umgeschaltet
; zu werden, also Ausgabe eines Abbruchtextes:

                lea     nosensetext(pc),a0
                bsr.s   print

; auf Taste warten:

                bsr.s   getkey
programmende:

;Programm beenden:
                clr.w   -(sp)
                trap    #1
;***********************************************
stmonitor:

; Herausholen des alten Videomodus
; mittels setmode und öbergabeparameter -1.
; setmode liefert in d0.w den alten Videomodus
; zurÅck:

                moveq   #-1,d0
                bsr.s   setmode

; Bit 5 legt fest, welcher Videomodus benutzt
; werden soll:
; Bit 5=0: PAL-Modus  (50 Hz)
; Bit 5=1: NTSC-Modus (60 Hz)
; Umschalten des Modus:
; Aus 0 wird 1 oder umgekehrt.
; Der neue Videomodus wird mittels setmode an
; die Videohardware Åbergeben:

                bchg    #5,d0
                bsr.s   setmode
;und Sprung zum Programmende:
                bra.s   programmende
;***********************************************
fernseher:
; Textausgabe, ob auf dem Fernseher die Frequenz
; umgeschaltet werden soll:

                lea     evtltext(pc),a0
                bsr.s   print

; Warten auf Taste,
; wenn J oder j eingegeben wird, wird in die
; Routine gesprungen, die den Videomodus
; umschaltet.  Ansonsten wird zum Programmende
; gesprungen:

                bsr.s   getkey
                cmp.b   #"J",d0
                beq.s   stmonitor
                cmp.b   #"j",d0
                beq.s   stmonitor

                bra.s   programmende
;***********************************************
print:

; Diese Unterroutine druckt einen Text aus,
; dessen Adresse in a0.l angegeben wird:
                pea     (a0)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
                rts
;***********************************************
getkey:

; Diese Unterroutine liest ein Zeichen von der
; Tastatur ein, und gibt es in d0 zurÅck:

                movem.l d1-d3/a0-a3,-(sp)
                move.w  #8,-(sp)
                trap    #1
                addq.l  #2,sp
                movem.l (sp)+,d1-d3/a0-a3
                rts
;***********************************************
mon_type:

; Diese Unterroutine gibt die Art des ange-
; schlossenen Monitors in d0 zurÅck:

                movem.l d1-d3/a0-a3,-(sp)
                move.w  #89,-(sp)       ;mon_type
                trap    #14
                addq.l  #2,sp

                movem.l (sp)+,d1-d3/a0-a3
                rts
;***********************************************
setmode:

; Diese Unterroutine setzt einen neuen Videomodus.
; Eingabeparameter:
; d0.w: neuer Videomodus
; Wenn d0.w=-1, dann wird nur der aktuelle
; Videomodus zurÅckgegeben.
; Ausgabeparameter:
; d0.w: alter Videomodus

                movem.l d1-d3/a0-a3,-(sp)
                move.w  d0,-(sp)
                move.w  #88,-(sp)       ;setmode
                trap    #14
                addq.l  #4,sp

                movem.l (sp)+,d1-d3/a0-a3
                rts
;***********************************************
                DATA
anfangstext:    DC.B "50/60 hz Umschaltungsprogramm",13,10
                DC.B "fÅr FALCON 030 von D.Richter.",13,10,0
nosensetext:    DC.B "Dieses Programm macht keinen Sinn auf",13,10
                DC.B "Ihrem Monitor.",13,10,0
evtltext:       DC.B "Sie haben einen Fernseher angeschlossen",13,10
                DC.B "Evtl. vertrÑgt er die Hertzumschaltung",13,10
                DC.B "nicht.  Bitte ",27,"pJ",27
                DC.B "q drÅcken zum Umschalten",13,10
                DC.B "der Frequenz.",13,10,0
                EVEN
                END

