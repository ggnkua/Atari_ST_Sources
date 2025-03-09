************************************
*                                  *
* UNFIX24                          *
*                                  *
* deinstalliert FIX24 V1.1         *
*                                  *
* und hebt 24-Bit-Adressierung auf *
*                                  *
* (C) Mai 1991 by Uwe Seimet       *
*                                  *
************************************


GEMDOS   = 1
CCONWS   = 9
MADDALT  = 20
SUPER    = 32


_p_cookies = $5a0          ;Pointer auf cookie jar


magic    = "FIX2"          ;magic von FIX24


         text


         clr.l -(sp)
         move #SUPER,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         move.l d0,d7
         lea inserr(pc),a6
         move.l _p_cookies,d0
         beq quit                   ;kein
                                    ;cookie jar-
         move.l d0,a0
cloop:   movem.l (a0)+,d0/d6
         tst.l d0
         beq quit                   ;Ende des
                                    ;cookie jar-
         cmp.l #"FIX2",d0           ;FIX24 installiert?
         bne cloop                  ;nein-

erase:   movem.l (a0)+,d0-d1        ;Eintrag aus
         movem.l d0-d1,-16(a0)      ;cookie jar
         tst.l d0                   ;entfernen
         bne erase

         movec.l cacr,d0            ;Cache
         or #$0808,d0               ;lîschen
         and #$fefe,d0              ;und
         movec.l d0,cacr            ;abschalten
         pmove dummy,tc             ;öbersetzung
                                    ;anhalten
         pmove dummy,tt0
         pmove dummy,tt1

         lea $0700,a0               ;Deskriptoren-
                                    ;Adresse

         move.l #$742,(a0)+
         moveq #$00000001,d1
         moveq #6,d0
fill1:   move.l d1,(a0)+            ;Default-
         add.l #$10000000,d1        ;Tabelle
         dbra d0,fill1              ;aufbauen
         move.l #$80000041,d1
         moveq #7,d0
fill2:   move.l d1,(a0)+            ;dto
         add.l #$10000000,d1
         dbra d0,fill2

	pmove tt0reg(pc),tt0
         pmove trans(pc),tc         ;öbersetzung
                                    ;neu starten

         mulu.l #$00010000,d6       ;Speichergrîûe
         
         move.l d6,-(sp)            ;Speichergrîûe
         pea $01000000              ;neuen Speicher
         move #MADDALT,-(sp)        ;bereitstellen
         trap #GEMDOS
         lea 10(sp),sp

         lea message(pc),a6
quit:    move.l d7,-(sp)
         move #SUPER,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         pea (a6)
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
error:   clr -(sp)
         trap #GEMDOS


trans:   dc.l $80f04445    ;fÅr TC-Register

tt0reg:  dc.l $017e8107    ;transparente
                           ;öbersetzung
                           ;im TT-RAM


inserr:  dc.b $0d,$0a,"FIX24 ist nicht "
         dc.b "installiert!",$0d,$0a,$00
message: dc.b $0d,$0a,"FIX24 wurde "
         dc.b "deaktiviert!",$0d,$0a,$00


         bss

dummy:   ds.l 1            ;fÅr TC-Register

