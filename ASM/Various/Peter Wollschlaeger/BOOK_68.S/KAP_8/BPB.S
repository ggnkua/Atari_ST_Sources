* BPB   BIOS Parameter Block  ausgeben

        move     #0,-(sp)      ;Drive A = 0
        move     #7,-(sp)      ;Funktion GETBPB
        trap     #13           ;BIOS aufrufen
        addq.l   #4,sp

        move.l   d0,a4         ;Zeiger auf BPB
        move.l   #texte,a5     ;Zeiger auf Texttabelle

        move     #7,d1         ;Schleife 8 mal
loop    move     (a4)+,d2      ;ein Wert uebergeben 
        bsr      print         ;und ausgeben
        dbra     d1,loop       ;u.s.w.

        move.w   #1,-(sp)      ;mit Funktion CONIN
        trap     #1            ;auf Taste warten
        addq.l   #2,sp         ;Stack korrigieren
        clr      -(sp)         ;Mit TERM
        trap     #1            ;zum Desktop 

print   move.l   a5,-(sp)      ;String ausgeben
        move     #9,-(sp)      ;mittels PRTLIN-Funktion
        trap     #1
        addq.l   #6,sp  
        add.l    #tlen,a5      ;Textzeiger weiter   
        move     d2,-(sp)      ;nun den Wert 
        pea      buffer        ;wandeln
        bsr      bindec        ;Ergebnis in buffer
        pea      buffer        ;buffer ausgeben
        move     #9,-(sp)      ;mittels PRTLIN-Funktion
        trap     #1
        addq.l   #6,sp         
        rts
      
        include  "bindec.s"   ;hier steckt bindec
 
        data
texte   dc.b     13,10,'Sektorgroesse in Bytes   : ',0
        ds.w     0
tlen    equ      *-texte
        dc.b     13,10,'Sektoren pro Cluster     : ',0
        ds.w     0
        dc.b     13,10,'Cluster-Groesse in Bytes : ',0
        ds.w     0
        dc.b     13,10,'Sektoren im Directory    : ',0
        ds.w     0
        dc.b     13,10,'Sektoren pro FAT         : ',0
        ds.w     0
        dc.b     13,10,'Start-Sektor von FAT 2   : ',0
        ds.w     0
        dc.b     13,10,'Start-Sektor Daten       : ',0
        ds.w     0
        dc.b     13,10,'Anzahl Daten-Cluster     : ',0
        bss
buffer  ds.b     6

        end


