        
****** Drive, Track, Sektor lesen
        xdef    RDTS

RDTS    move.l  (a7)+,retsave   ;save ret adr
        move.w  (a7)+,d2        ;get sector
        move.w  (a7)+,d1        ;get track
        move.w  (a7)+,d0        ;get drive
  
        move.w  #1,-(a7)        ;1 Sektor
        move.w  #0,-(a7)        ;Seite 0
        move.w  d1,-(a7)        ;Track
        move.w  d2,-(a7)        ;Sektor  
        move.w  d0,-(a7)        ;Drive 
        clr.l   -(a7)           ;Filler
        pea     buffer          ;Bufferadresse
        move.w  #8,-(a7)        ;Funktion Read T/S
        trap    #14             ;call XBIOS
        add.l   #20,a7

        move.w  d0,flag         ;Status uebergeben
        move.l  #buffer,d0      ;Pufferadresse als Ergebnis
        move.l  retsave,a0      ;get ret adr
        jmp     (a0)            ;ret to pascal
      
        bss
retsave ds.l    1              ;Return Adresse
buffer  ds.w    256            ;Puffer Sektor Daten
flag    ds.w    1              ;Status (d0) des Read
        end




