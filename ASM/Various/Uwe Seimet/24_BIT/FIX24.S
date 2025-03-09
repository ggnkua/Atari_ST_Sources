**************************************
*                                    *
* FIX24.PRG                          *
*                                    *
* beschrÑnkt Adressierung auf 24 Bit *
*                                    *
* (C) Februar 1991 by Uwe Seimet     *
*                                    *
**************************************


GEMDOS   = 1
CCONWS   = 9
SUPER    = 32
PTERMRES = 49
MXALLOC  = 68
TERM     = 76


_p_cookies = $5a0                   ;Pointer auf
                                    ;cookie-jar


magic    = $1357bd13


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
         subq.l #2,d1               ;TT?
         bne quit                   ;nein-
         cmp.l #magic,$5a8          ;TT-RAM
                                    ;vorhanden?
         bne.b noram                ;nein-
         move.l $5a4,d0             ;Ende des
                                    ;TT-RAM
         cmp.l #$1000000,d0
         ble.b noram                ;kein
                                    ;TT-RAM-
         lea ramerr(pc),a6
         sub.l #$1000000,d0         ;ergibt Grîûe
                                    ;des TT-RAM
         move #1,-(sp)              ;TT-RAM
         move.l d0,-(sp)            ;belegen
         move #MXALLOC,-(sp)
         trap #GEMDOS
         addq.l #8,sp
         tst.l d0
         beq.b quit                 ;TT-RAM ist
                                    ;nicht leer-
noram:   movec.l cacr,d0            ;Cache
         or #$0808,d0               ;lîschen
         and #$fefe,d0              ;und
         movec.l d0,cacr            ;abschalten
         pmove dummy,tc             ;öbersetzung
                                    ;anhalten
         pmove dummy,tt0
         pmove dummy,tt1
         lea $0700,a0
         moveq #15,d0
fill1:   move.l #$00000742,(a0)+    ;Ebene 0
         dbra d0,fill1
         moveq #15,d0
fill2:   move.l #$000007c2,(a0)+    ;Ebene 1
         dbra d0,fill2
         moveq #1,d1
         moveq #14,d0
fill3:   move.l d1,(a0)+            ;Ebene 2
         add.l #$00100000,d1
         dbra d0,fill3
         move.l #$00f00041,(a0)     ;fÅr ROM-
                                    ;öbersetzung
         pmove trans,tc             ;öbersetzung
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


trans:   dc.l $80f04445    ;fÅr TC-Register

sterr:   dc.b $0d,$0a,"FIX24 lÑuft nur "
         dc.b "auf dem TT!",$0d,$0a,$00
message: dc.b $0d,$0a,"FIX24 V1.0 "
         dc.b "installiert",$0d,$0a
         dc.b "Ω 1991 by Uwe Seimet",$0d,$0a,$00
ramerr:  dc.b $0d,$0a,"Das TT-RAM ist "
         dc.b "nicht leer!",$0d,$0a,$00


         bss

dummy:   ds.l 1            ;fÅr TC-Register

