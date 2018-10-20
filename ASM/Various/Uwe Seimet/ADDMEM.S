************************************
*                                  *
* ADDMEM V1.3                      *
*                                  *
* erlaubt in Verbindung mit FIX24  *
*                                  *
* die Nutzung des TT-RAM unter TOS *
*                                  *
* (C) 1991 by Uwe Seimet           *
*                                  *
************************************


	mc68030
	loadfast


GEMDOS   = 1
CCONWS   = 9
PTERMRES = 49
MALLOC	= 72
MFREE	= 73
MSHRINK	= 74


XBIOS    = 14
SUPEXEC  = 38


hdv_rw   = $476            ;Lese-/Schreibvektor
_sysbase	= $4f2
_p_cookies = $5a0          ;Pointer auf cookie jar


fixmagic = "FIX2"
magic    = "MADD"


	opt o+,w-


	text

	move.l 4(sp),a0
	lea stack+400,sp
	move.l 12(a0),a6		;LÑnge des TEXT-Segments
	add.l 20(a0),a6		;LÑnge des DATA-Segments
	add.l 28(a0),a6		;LÑnge des BSS-Segments
	lea $100(a6),a6		;fÅr Basepage
	pea (a6)
	pea (a0)
	clr -(sp)
	move #MSHRINK,-(sp)
	trap #GEMDOS		;ÅberzÑhligen Speicher freigeben
	lea 12(sp),sp
	tst.l d0			;alles klar?
	bne err1			;leider nicht-

	pea -1
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	subq.l #2,d0
	move.l d0,-(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l d0,d7

         pea install(pc)
         move #SUPEXEC,-(sp)
         trap #XBIOS
         addq.l #6,sp
         subq.b #1,errflg
         beq.b quit1                ;Fehler-
         bpl.b quit2                ;bereits
                                    ;installiert-

	move.l d7,-(sp)
	move #MFREE,-(sp)
	trap #GEMDOS
	addq.l #6,sp

         pea message(pc)
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
 
         clr -(sp)
         pea (a6)			;Programm
         move #PTERMRES,-(sp)
         trap #GEMDOS               ;resident
                                    ;halten
quit1:   pea fixerr(pc)
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
quit2:   clr -(sp)
         trap #GEMDOS

install:
         move.l _p_cookies,d0       ;keine
         beq.b err1                 ;cookies-
         move.l d0,a0
find_fix:movem.l (a0)+,d0-d1
         tst.l d0
         beq.b err1                 ;kein FIX24-
         cmp.l #magic,d0
         beq.b err2                 ;ADDMEM schon
                                    ;installiert-
         cmp.l #fixmagic,d0         ;FIX24 nicht
         bne find_fix               ;installiert-
         move.l #magic,-8(a0)       ;magic
                                    ;ersetzen
         move.l d1,d0
         clr d0
         swap d1
         clr d1
         move.l _sysbase,a0
         move.l $71e2,d2            ;Pointer auf MPB (TOS 3.01)
         cmp #$0301,2(a0)
         beq.s next_md
	move.l $70e8,d2		;MBP fÅr TOS 3.05
	cmp #$0301,2(a0)
	beq.s next_md
	move.l $73ca,d2		;MPB fÅr TOS 3.06
next_md: move.l d2,a0
         move.l (a0),d2             ;Zeiger auf nÑchsten MD holen
         bne next_md                ;noch nicht letzter Block-
         movem.l d0-d1,4(a0)        ;Start, LÑnge
                                    ;des neuen
                                    ;Blocks
         movem.l d0-d1,low

         move.l hdv_rw,o_rw       ;neue DMA-
         move.l #hrw,hdv_rw       ;Routinen
         rts

err1:    move.b #1,errflg
         rts

err2:	move.b #2,errflg
         rts


         dc.l "XBRA"
         dc.l magic
o_rw:    dc.l 0
hrw:
         move.l 6(sp),d0            ;Pufferadresse
         sub.l low(pc),d0
         bcs.b cont
         cmp.l len(pc),d0
         bcc.b cont
         add.l #$01000000,d0        ;neue Adresse
                                    ;berechnen
         move.l d0,6(sp)            ;und ersetzen
cont:    move.l o_rw(pc),a0         ;weiter
         jmp (a0)                   ;wie gehabt-


message: dc.b $0d,$0a,"ADDMEM V1.3 "
         dc.b "installiert",$0d,$0a
         dc.b "Ω 1991 by Uwe Seimet",$0d,$0a,$00
fixerr:  dc.b $0d,$0a,"ADDMEM lÑuft nur "
	dc.b "in Verbindung mit FIX24!"
	dc.b $0d,$0a,$00


         even

low:     dc.l 0   ;neue Startadresse des TT-RAM
len:     dc.l 0   ;Grîûe des TT-RAM-Bereichs

errflg:  dc.b 0   ;Fehlerflag


	bss

stack:	ds.l 100
