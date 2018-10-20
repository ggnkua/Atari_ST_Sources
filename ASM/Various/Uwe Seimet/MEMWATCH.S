***************************
*                         *
* MEMWATCH V1.0           *
*                         *
* Schreibschutz fÅr das   *
*                         *
* TEXT-Segment auf dem TT *
*                         *
* (C) 1991 by Uwe Seimet  *
*                         *
***************************


GEMDOS   = 1
CCONWS   = 9
SUPER    = 32
PTERMRES = 49
MSHRINK  = 74
PTERM    = 76


BIOS     = 13
BCONOUT  = 3


_sysbase = $4f2
_p_cookies = $5a0


         text

         move.l 4(sp),a6            ;Pointer auf
         			;Basepage
         lea stack+400,sp
         move.l 12(a6),a1           ;LÑnge des
         			;TEXT-Segments
         add.l 20(a6),a1            ;DATA-Segment
         add.l 28(a6),a1            ;BSS-Segment
         lea $100(a1),a1            ;fÅr Basepage
         move.l a1,prglen		;ProgrammlÑnge
         			;merken
         pea (a1)
         pea (a6)
         clr -(sp)
         move #MSHRINK,-(sp)
         trap #GEMDOS               ;Restspeicher
         			;freigeben
         lea 12(sp),sp
         tst.l d0                   ;alles klar?
         bne quit                   ;leider nicht-

         clr.l -(sp)
         move #SUPER,-(sp)          ;Supervisor-
         trap #GEMDOS               ;Modus
         addq.l #6,sp
         move.l d0,d7               ;SSP merken

         lea sterr,a5
         move.l _p_cookies,d0	;kein
         beq error                  ;cookie jar-
         move.l d0,a0
testjar: movem.l (a0)+,d0-d1
         tst.l d0
         beq endjar
         cmp.l #"_MCH",d0           ;Computertyp?
         bne nomch                  ;nein-
         swap d1
         subq #2,d1                 ;TT?
         bne error                  ;nein-
nomch:   cmp.l #"PMMU",d0           ;MMU-Programm
				;aktiv?
         bne testjar                ;nein-
         lea mmuerr,a5
         bra error

endjar:  move.l #"PMMU",-8(a0)	;kein
         clr.l -4(a0)               ;PMMU-Handler
         movem.l d0-d1,(a0)

         move.l #table+15,d6        ;Deskriptor-
         			;Tabelle
         and #$fff0,d6              ;auf Cacheline
         			;ausrichten
         pmove crp,crpreg           ;alter CRP
         pmove crpreg,srp
         move.l crpreg+4,a1         ;Pointer auf
                                    ;alte Tabelle
         move.l a1,a2
         move.l d6,crpreg+4         ;fÅr neuen
         			;CRP

         move.l d6,a0
         moveq #63,d0
tcopy:   move.l (a1)+,d1
         move.l d1,d2
         and #$02,d2		;Tabellen-
         cmp #$02,d2                ;Deskriptor?
         bne notable                ;nein-
         sub.l a2,d1
         add.l d6,d1
notable: move.l d1,(a0)+		;Tabelle
         dbra d0,tcopy              ;kopieren

         move.l a0,d1
         or #2,d1
         moveq #13,d0
         move.l d6,a1
         lea $c0(a1),a1
cdes:    move.l d1,(a1)+            ;Deskriptoren
         add.l #128,d1		;fÅr ST-RAM
         dbra d0,cdes

         moveq #1,d1
         move #511-64,d0		;Seiten-
dloop0:  move.l d1,(a0)+            ;Deskriptoren
         add.l #$8000,d1		;fÅr ST-RAM
         dbra d0,dloop0

         move.l a0,d2
         move.l a0,d1
         add.l #64,d1
         or #2,d1
         moveq #15,d0
dloop1:  move.l d1,(a0)+
         add.l #128,d1
         dbra d0,dloop1

         move.l #$01000001,d1
         move #511,d0		;Seiten-
dloop2:  move.l d1,(a0)+            ;Deskriptoren
         add.l #$8000,d1		;fÅr TT-RAM
         dbra d0,dloop2
         or #2,d2

         move.l d2,($44,d6.l)

         move.l #vectors+15,d0      ;VBR auf
         and #$fff0,d0              ;Cacheline
         move.l d0,a1               ;ausrichten
         move.l d0,a2
         movec vbr,a0
         move.l $08(a0),o_bus
         move.l $84(a0),o_gemdos
         move.w #255,d0
copyvec: move.l #newvec,(a1)+
         dbra d0,copyvec
         move.l #buserr,$08
         move.l #gemdos,$84
         movec a2,vbr

         lea dummy,a0		;keine
*        pmove (a0),tt0             ;transparente
				;öbersetzung
         dc.l $f0100800             ;PMOVE (A0),TT0
         pmove crpreg,crp           ;neuer
				;Rootpointer
         pmove tc,tcreg
         bset #1,tcreg              ;SRE setzen
         pmove tcreg,tc

         move.l d7,-(sp)
         move #SUPER,-(sp)          ;RÅckkehr in
         trap #GEMDOS               ;User-Modus
         addq.l #6,sp

         pea message
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         clr -(sp)
         move.l prglen,-(sp)
         move #PTERMRES,-(sp)	;zurÅck
         trap #GEMDOS               ;zum TOS


gemdos:
         lea 8(sp),a0		;Supervisor-
         btst #5,(sp)               ;Modus?
         beq user                   ;nein-
cont:    jmp ([o_gemdos])
user:    move.l usp,a0              ;sonst
				;User-Stack
         tst (a0)
         beq term                   ;PTERM0-
         cmp #PTERM,(a0)
         beq term                   ;PTERM-
         cmp #MSHRINK,(a0)
         bne cont
         move.l ([_sysbase],40),a0
         move.l (a0),a0             ;zeigt auf PD
         move.l 12(a0),d0
         ptestw #2,([a0],8),#7,a0
wrset:   bset #2,3(a0)              ;W-Bit
         addq.l #4,a0               ;setzen
         sub.l #$8000,d0
         bcc wrset                  ;nÑchste Page-
         pflusha
         bra cont

term:
         move.l ([_sysbase],40),a0
         move.l (a0),a0             ;zeigt auf PD
         move.l 12(a0),d0
         ptestw #2,([a0],8),#7,a0
wrclr:   bclr #2,3(a0)              ;Schreibschutz
         addq.l #4,a0               ;entfernen
         sub.l #$8000,d0
         bcc wrclr                  ;nÑchste Page-
         pflusha
         bra cont


error:
         pea (a5)              	;Fehlermeldung
         move #CCONWS,-(sp)      	;ausgeben
         trap #GEMDOS
         addq.l #6,sp
         pea inserr              	;nicht
         move #CCONWS,-(sp)	;installiert
         trap #GEMDOS
         addq.l #6,sp
exit:    move.l d7,-(sp)
         move #SUPER,-(sp)       	;zurÅck in
         trap #GEMDOS            	;User-Modus
         addq.l #6,sp
quit:    clr -(sp)
         trap #GEMDOS


         align 16

newvec:
         move.l 4(sp),-(sp)	;Vektoroffset
         and.l #$fff,(sp)           ;isolieren
         move.l ([sp]),(sp)
         rts


buserr:
         movem.l d0/a6,-(sp)
         lea 8(sp),a6		;Throwaway-
         cmp #$1008,6(a6)           ;Stackframe?
         bne is_isp                 ;nein-
         movec msp,a6
is_isp:  move.b 11(a6),d0
         movec d0,dfc		;Deskriptor
         ptestw dfc,([16,a6]),#7    ;prÅfen
         subq.l #2,sp
         pmove psr,(sp)
         btst #3,(sp)+              ;W-Bit testen
         bne wrterr
         movem.l (sp)+,d0/a6
         move.l ([o_bus]),-(sp)     ;weiter im TOS
         rts

wrterr:
         move.l 16(a6),d0
         move.l ([_sysbase],40),a6
         move.l (a6),a6             ;zeigt auf PD
         sub.l 8(a6),d0             ;oberhalb oder
         bcs noerr                  ;unterhalb des
         cmp.l 12(a6),d0            ;TEXT-
         bcc noerr                  ;Segments?
         movem.l a0-a2/d0-d2,-(sp)
         move #7,-(sp)              ;BEL
         move #2,-(sp)
         move #BCONOUT,-(sp)        ;Warnton
         trap #BIOS                 ;ausgeben
         addq.l #6,sp
         movem.l (sp)+,a0-a2/d0-d2
noerr:   movem.l (sp)+,d0/a6
         bset #2,11(sp)             ;Befehl im
         rte                        ;Supervisor-
         			;Modus
                                    ;wiederholen


         data


message: dc.b $0d,$0a,"MEMWATCH V1.0 "
         dc.b "installiert",$0d,$0a
         dc.b "Ω 1991 by Uwe Seimet",$0d,$0a,0


*Diverse Fehlermeldungen

sterr:   dc.b $0d,$0a,"MEMWATCH lÑuft nur "
         dc.b "auf einem TT!",0

mmuerr:	dc.b $0d,$0a,"Es ist bereits ein "
	dc.b "MMU-Program aktiv!",0

inserr:  dc.b $0d,$0a,"MEMWATCH V1.0 "
         dc.b "nicht installiert",$0d,$0a,0


        	bss

stack:   ds.l 100

crpreg:  ds.l 2

tcreg:   ds.l 1

prglen:  ds.l 1

dummy:   ds.l 1

o_bus:   ds.l 1

o_gemdos:ds.l 1

table:   ds.b 512+1792+64+2048+15
			;Deskriptortabelle

vectors: ds.b 1024+15	;fÅr Vektoren
