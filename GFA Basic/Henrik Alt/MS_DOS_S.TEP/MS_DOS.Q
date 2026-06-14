;
;*****************************************************
;* Spurwechselzeiteinstellung zum Betrieb eines      *
;* 2x40 Spur Laufwerkes als Laufwerk B:.             *
;* Auch fÅr den AUTO-Ordner geeignet!                *
;* Quelltext fÅr Profimat-Assembler.                 *
;*                                                   *
;* Autor: Henrik Alt, Kirgelweg 25, 7160 Gaildorf    *
;*                                                   *
;*****************************************************
;
          lea       $FC0018,a0         ;Adresse des TOS-Erstellungsdatums
          cmpi.l    #$02061986,(a0)    ;TOS vom 6.2.1986 ?
          bne.s     blitter            ;wenn nein vieleicht Blitter-TOS?
          clr.w     $A0C               ;Spurwechselzeit auf 0 = 6ms
          bra.s     exit               ;das war's
blitter   cmpi.l    #$04221987,(a0)    ;Blitter-TOS vom 22.4.1987 ?
          bne.s     exit               ;wenn nein ohne Umschaltung verlassen
          clr.w     $A52               ;Spurwechselzeit auf 0 = 6ms
exit      clr.w     -(a7)              ;Programm mit Pterm
          trap      #1                 ;durch GEMDOS-Aufruf verlassen
          end

