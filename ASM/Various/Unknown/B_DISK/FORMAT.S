        include "macros.mac"
        include "xbios.mac"
        include "bios.mac"
        include "tos.mac"
        print   wrnmes
        necin
        move    #0,d7
frmt    flopfmt puffer,#0,#9,d7,#1,#1,#$0000
        bne     fehler
        addq    #1,d7
        cmp     #80,d7
        bne     frmt
        print   okmess
        necin
        gemdos  #$4c
fehler  print   fehlmes
        necin
        gemdos  #$4c
wrnmes  dc.b    "Achtung! Daten auf der RÅckseite werden gelîscht.",13,10,0
okmess  dc.b    "Formatierung durchgefÅhrt",0
fehlmes dc.b    "Fehler bei Formatierung",0
puffer  ds.w    0
        end
