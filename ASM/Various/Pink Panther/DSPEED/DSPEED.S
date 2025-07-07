* Diskettentester V1.01
* Geschrieben am 25. und 26.03.88 von Pink Panther.
* PUBLIC DOMAIN !
*
* Anmerkung: Einige schlaue Geister werden unken, daû die Bestimmung
* der Zugriffsgeschwindigkeit durch die Systemvariable _hz_200 zu ungenau
* sei, da der Interupt wÑhrend der DMA-Zyklen gesperrt wird.
* Ich kann nur sagen: RICHTIG. Ich dachte das auch. Aber die Praxis hat
* gezeigt, daû der Fehler sehr gering ist, so daû man damit leben kann.
*
* Falls sich jemand die MÅhe macht, das Programm zu verbessern bzw.
* erweitern, so mîge er doch bitte den kommentierten Sourcecode
* in BTS (069/6313879) hinterlassen und mir dort auch eine entsprechende
* Bemerkung schreiben (Pinky).
*
* Und nun zum Schluû noch einige Resultate:
*
* Floppy, einseitig  : ca. 15 Kbyte/sec
* Floppy, doppels.   : ca. 22 Kbyte/sec
* Micro Science Festplatte, 20Meg, OMTI 5520A mit C'T Adapter: ca. 100 K/s
* Resetfeste RAMDISK : ca. 1800 KByte/sec
*
* have phun !
*
* Ach ja: Das Format ist fÅr den MADMAC compiler von Atari.
* Noch was: Nach dem Compilen das Programm in DSPEED.TOS umbenennen,
* damit die Flugkakalake nicht stîrt...
*
*
gem             equ     1
xbios           equ     14
bios            equ     13
_hz_200         equ     $4ba
*
aufgehts:
                move.w  #$20,-(sp)      ;SUPER
                trap    #gem
                addq.l  #2,sp

                pea     signup1         ;some whistles and bells
                move.w  #9,-(sp)
                trap    #gem
                addq.l  #6,sp

auf_ein_neues:
                pea     signup2         ;clean up lower part of screen
                move.w  #9,-(sp)
                trap    #gem
                move.w  #7,-(sp)        ;raw conin, get drive id
                trap    #gem
                addq.l  #8,sp

                cmp.b   #'A',d0         ;char < 'A' ?
                bmi     exit0           ;if so, have a nice day
                and.w   #$1f,d0         ;ignore case
                subq.w  #1,d0           ;make number binary (a=0,b=1,...)
                move.w  d0,-(sp)        ;drive number
                move.w  d0,d6
                add.w   #'A',d0
                move.w  d0,-(sp)
                move.w  #2,-(sp)        ;conout for upper case echo
                trap    #gem
                addq.l  #4,sp

                move.w  #7,-(sp)        ;getbpb
                trap    #bios
                add.l   #4,sp
                tst.w   d0
                bne     cont
diskerr:
                move.w  d0,-(sp)        ;save error number
                pea     diskerrmsg
                move.w  #9,-(sp)
                trap    #gem
                addq.l  #6,sp
                move.w  (sp)+,d0
                neg     d0
                bsr     decout
                bra     godot

cont:
                move.l  d0,a0
                move.w  2(a0),d5        ;d5=cluster size in sectors
                mulu    14(a0),d5       ;d5=d5*max cluster number

                pea     sectors         ;print number of data sectors
                move.w  #9,-(sp)
                trap    #gem
                addq.l  #6,sp
                move.w  d5,d0
                bsr     decout

                pea     runningmsg
                move.w  #9,-(sp)
                trap    #gem
                addq.l  #6,sp
                sub.w   #10,d5          ;subtract number of sectors to read

                move.l  _hz_200,d7      ;start time =>d7
                move.w  #30,d4          ;counter control
loop:
                move.w  #17,-(sp)
                trap    #xbios          ;get random number
                addq.l  #2,sp
                mulu    d5,d0
                swap    d0
                move.w  d6,-(sp)        ;drive number
                move.w  d0,-(sp)        ;record number
                move.w  #10,-(sp)       ;record counter= 10*512 bytes
                pea     buffer          ;disk i/o buffer
                clr.w   -(sp)           ;read data
                move.w  #4,-(sp)        ;rwabs
                trap    #bios
                add.l   #14,sp
                tst.w   d0
                bmi     diskerr

                move.w  #'.',-(sp)
                move.w  #2,-(sp)
                trap    #gem            ;print '.'
                move.w  #$ff,-(sp)
                move.w  #6,-(sp)
                trap    #gem
                addq.l  #8,sp
                cmpi.b  #3,d0
                dbeq    d4,loop
                beq     exit            ;ctrl-c => exit

                sub.l   _hz_200,d7
                neg.l   d7              ;d7=elapsed time in 1/200sec

                pea     resultmsg1      ;print result string
                move.w  #9,-(sp)
                trap    #gem
                addq.l  #6,sp
                move.l  #60000,d0       ;30 x 200Hz x 10kbyte
                addq.l  #1,d7
                divu    d7,d0
                bsr     decout
                pea     resultmsg2
                move.w  #9,-(sp)
                trap    #gem
                addq.l  #6,sp
godot:
                move.w  #1,-(sp)        ;warten auf godot
                trap    #gem
                addq.l  #2,sp
                bra     auf_ein_neues

        
exit:
                move.w  #1,-(sp)
                trap    #gem
exit0:
                clr.w   -(sp)              ;warmstart
                trap    #gem



decout:
                lea     .buf+6,a0       ;output d0 as decimal number
                clr.b   -(a0)           ;corrupted reg's: a0,d0
                and.l   #$ffff,d0

.loop:          divu.w  #10,d0
                swap    d0
                add.w   #'0',d0
                move.b  d0,-(a0)
                clr.w   d0
                swap    d0
                bne     .loop

                move.l  a0,-(sp)        ;decimal string adress
                move.w  #9,-(sp)        ;print string
                trap    #gem
                addq.l  #6,sp
                rts
.bss
.buf:           ds.b    7
.text

.data
signup1:        dc.b    27,'E',9,9,9
                dc.b    'Non-Destructive random seek test v1.00',13,10,10
                dc.b    'Dieser Test bestimmt eine zufÑllige Stelle auf der angegebenen Diskette',13,10
                dc.b    'und liest ab dort 10 KByte ein. Die dazu benîtigte Zeit wird in die Angabe',13,10
                dc.b    'Kilobyte pro Sekunde umgerechnet. Der Durchschnittswert von 30 Versuchen',13,10
                dc.b     'wird ermittelt (dauert bis zu 30 Sekunden bei lahmen Floppys !) und dann',13,10
                dc.b    'ausgegeben.',13,10,10
                dc.b    'Geschrieben am 25. und 26.03.88 von Pinky.',13,10
                dc.b    'Public Domain. Kopieren nur KOSTENLOS gestattet...!',13,10
                dc.b    10
                dc.b    'Abbruch jederzeit durch CTRL-C.',13,10,10,0
signup2:        dc.b    27,'Y',45,32,27,'J'
                dc.b    'Welches Laufwerk testen (A,B,C,...) : ',0
sectors:        dc.b    13,10,10,'Anzahl der Datensektoren: ',0
runningmsg:     dc.b    13,10,'Test lÑuft :',0
diskerrmsg:     dc.b    13,10,10,'*** DISK ERROR -',0
resultmsg1:     dc.b    13,10,10,'Durchschnittliche Lesegeschwindigkeit : ',0
resultmsg2:     dc.b    ' Kbyte/Sekunde.',13,10,10
                dc.b    9,9,9,9,'Bitte eine Taste drÅcken ',0

.bss

buffer:         ds.w    5120            ;20 sectors = 10kbyte = 5kword

.end
 

