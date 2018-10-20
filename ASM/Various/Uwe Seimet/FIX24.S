**************************************
*                                    *
* FIX24 V1.2                         *
*                                    *
* beschrÑnkt Adressierung auf 24 Bit *
*                                    *
* und erlaubt Nutzung des TT-RAM     *
*                                    *
* (C) 1993 by Uwe Seimet             *
*                                    *
**************************************


	mc68030
	loadfast


GEMDOS   = 1
CCONWS   = 9
SUPER    = 32
PTERMRES = 49
MXALLOC  = 68
TERM     = 76


memtop   = $42e            ;Speicherobergrenze
_p_cookies = $5a0          ;Pointer auf cookie-jar


magic    = "FIX2"          ;fÅr cookie
ttmagic  = $1357bd13       ;Flag fÅr TT-RAM


         text


         clr.l -(sp)
         move #SUPER,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         move.l d0,d7
         moveq #-1,d6               ;Fehlerflag
                                    ;setzen
         lea sterr(pc),a6
         move.l _p_cookies,d0
         beq quit                   ;kein
                                    ;cookie jar-
         move.l d0,a0
cloop:   movem.l (a0)+,d0-d1
         tst.l d0
         beq quit                   ;Ende des
                                    ;cookie jar-
         cmp.l #"_MCH",d0           ;Computertyp?
         bne cloop                  ;nein-
         swap d1
         subq #2,d1                 ;TT?
         bcs quit                   ;nein-
         moveq #0,d5
         cmp.l #ttmagic,$5a8        ;TT-RAM
                                    ;vorhanden?
         bne.b noram                ;nein-
         move.l $5a4,d0             ;Ende des
                                    ;TT-RAM
         sub.l #$1000000,d0
         ble.b noram                ;kein
                                    ;TT-RAM-
         lea ramerr(pc),a6
         move.l d0,d5               ;Grîûe
                                    ;des TT-RAM
                                    ;in Bytes
         swap d5                    ;Grîûe
         lsr #4,d5                  ;in MBytes
         move #1,-(sp)              ;TT-RAM
         move.l d0,-(sp)            ;komplett
         move #MXALLOC,-(sp)        ;belegen
         trap #GEMDOS
         addq.l #8,sp
         tst.l d0                   ;TT-RAM ist
         beq quit                   ;nicht leer-

noram:   movec cacr,d0              ;Cache
         or #$0808,d0               ;lîschen
         and #$fefe,d0              ;und
         movec.l d0,cacr            ;abschalten
         pmove dummy,tc             ;öbersetzung
                                    ;anhalten
         pmove dummy,tt0
         pmove dummy,tt1

         moveq #$00000001,d1
         lea $0700,a0               ;Deskriptoren-
                                    ;Adresse
         moveq #14,d0
fill1:   move.l d1,(a0)+            ;Default-
         add.l #$00100000,d1        ;Tabelle
         dbra d0,fill1              ;aufbauen
         move.l #$00f00041,(a0)     ;Hardware-
                                    ;öbersetzung
         subq #1,d5
         bmi.b no_cook              ;kein TT-RAM-
         move.l memtop,d0
         swap d0
         move d0,d4
         swap d4
         clr d4
         lsr #2,d0
         lea $0700,a0
         add.l d0,a0
         move.l #$01000001,d1
fill2:   add #$0010,d4              ;LÑngenfeld
         move.l d1,(a0)+            ;TT-RAM-
         add.l #$00100000,d1        ;Tabelle
                                    ;aufbauen
         cmp.l #$00e00000,(a0)      ;RAM-Ende
         dbcc d5,fill2              ;erreicht?
         move.l _p_cookies,a0
find:    movem.l (a0)+,d0-d1
         tst.l d0
         bne find
         movem.l d0-d1,(a0)
         move.l d4,-(a0)            ;cookie
         move.l #magic,-(a0)        ;eintragen

no_cook: pmove trans,tc             ;öbersetzung
                                    ;neu starten
         lea message(pc),a6
         clr d6                     ;Fehlerflag
                                    ;zurÅcksetzen
quit:    move.l d7,-(sp)
         move #SUPER,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         pea (a6)
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         move d6,-(sp)
         bmi.b error
         clr.l -(sp)
         move #PTERMRES,-(sp)
         trap #GEMDOS

error:
         move #TERM,-(sp)
         trap #GEMDOS


trans:   dc.l $80f84500    ;fÅr TC-Register

sterr:   dc.b $0d,$0a,"FIX24 lÑuft nur "
         dc.b "auf dem TT oder Falcon030!",$0d,$0a,$00
message: dc.b $0d,$0a,"FIX24 V1.2 "
         dc.b "installiert",$0d,$0a
         dc.b "Ω 1993 by Uwe Seimet",$0d,$0a,$00
ramerr:  dc.b $0d,$0a,"Das TT-RAM ist "
         dc.b "nicht leer!",$0d,$0a
         dc.b "FIX24 V1.2 "
         dc.b "nicht installiert",$0d,$0a,$00


         bss

dummy:   ds.l 1            ;fÅr TC-Register
