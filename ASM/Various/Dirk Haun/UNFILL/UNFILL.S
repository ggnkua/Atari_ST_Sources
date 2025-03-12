; Turbo-Turbo-Unfill in Assembler
; Autor: Dirk Haun, Europastr. 8, 6085 Nauheim

         move.l 4(a7),a0
         move.l 12(a0),a1
         add.l  20(a0),a1
         add.l  28(a0),a1
         add.w  #256+128,a1 ; Basepage + Stack
         lea    0(a0,a1),a7
         move.l a1,-(a7)
         move.l a0,-(a7)
         clr.w  -(a7)
         move.w #74,-(a7)   ; Mshrink()
         trap   #1          ; Speicher freigeben
         add.w  #12,a7
         clr.w  -(a7)       ; Cursor aus, sonst
         clr.w  -(a7)       ; wird er auch
         move.w #21,-(a7)   ; "entfÅllt"
         trap   #14
         addq.l #6,a7
         lea    buffer,a3   ; Pufferadr. in a3
         clr.w  -(a7)       ; Bild einlesen ...
         pea    fname
         move.w #61,-(a7)   ; Fopen()
         trap   #1
         addq.l #8,a7
         move.w d0,d7       ; Filehandle nach d7
         bmi    quit        ; Ende, falls Fehler
         move.l a3,-(a7)
         move.l #32000,-(a7)
         move.w d7,-(a7)
         move.w #63,-(a7)   ; Fread()
         trap   #1
         add.w  #12,a7
         move.w d7,-(a7)
         move.w #62,-(a7)   ; Fclose()
         trap   #1
         addq.l #4,a7
         move.w #2,-(a7)    ; Physbase()
         trap   #14         ; Screenadr. holen
         addq.l #2,a7
         move.l d0,a4       ; Screenadr. in a4
         move.l d0,a1
         move.l a3,a0
         move.w #7999,d0    ; auf Bildschirm
cploop   move.l (a0)+,(a1)+ ; kopieren
         dbf    d0,cploop
         move.w #7919,d0
         move.l a4,a1
         lea    80(a1),a0   ; Anfangsadr 2.Zeile
exor1    move.l (a0)+,d1    ; je 32 Nachfolger
         eor.l  d1,(a1)+    ; EXOR-verknÅpfen
         dbf    d0,exor1
         move.l a3,a0
         add.w  #32000,a0   ; hinten anfangen
         move.w #7999,d0
exor2    move.l -(a0),d1
         roxl.l #1,d1       ; 32 Nachfolger holen
         eor.l  d1,(a0)     ; und EXOR-verknÅpfen
         dbf    d0,exor2
         move.l a3,a0
         move.l a4,a1
         move.w #7999,d0
orloop   move.l (a0)+,d1    ; Bilder "zusammen-
         or.l   d1,(a1)+    ; odern"
         dbf    d0,orloop

ende     move.w #1,-(a7)    ; auf Taste warten
         trap   #1
         addq.l #2,a7
quit     clr.w  -(a7)       ; Ende d. Vorstellung
         trap   #1

         data
fname    dc.b   "TEST.PIC",0
         bss
buffer   ds.b   32000       ; Zwischenspeicher
         end
