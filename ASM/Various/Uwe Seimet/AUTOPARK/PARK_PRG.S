*************************************************
*                                               *
*            XHDI-Autoparker V1.00              *
*                                               *
*   Parkt GerÑte, die von einem XHDI-Treiber    *
*  verwaltet werden, nach einer einstellbaren   *
*               Zeit automatisch.               *
*                                               *
* Benîtigt werden AUTOPARK.PRG und AUTOPARK.ACC *
*                                               *
*                 by Uwe Seimet                 *
*                                               *
*           (c) 1992 MAXON Computer             *
*                                               *
*************************************************


GEMDOS   = 1
CCONWS   = 9
SUPER    = 32
PTERMRES = 49
FOPEN    = 61
FCLOSE   = 62
FREAD    = 63
MSHRINK  = 74

XBIOS    = 14
SUPEXEC  = 38

resvalid = $426
resvector= $42a
hdv_rw   = $476
_hz_200  = $4ba
_p_cookies= $5a0

XHDIMAGIC= $27011992
USPK     = $5553504b


   loadfast
   ttmem
   ttram


         text

         move.l 4(sp),a5
         move.l 12(a5),a6           ;TEXT-Segment
         add.l 20(a5),a6            ;DATA-Segment
         add.l 28(a5),a6            ;BSS-Segment
         lea $100(a6),a6            ;fÅr Basepage
         pea (a6)
         pea (a5)
         clr -(sp)
         move #MSHRINK,-(sp)        ;ÅberzÑhligen
         trap #GEMDOS               ;Speicher
         lea 12(sp),sp              ;freigebem

         pea install(pc)
         move #SUPEXEC,-(sp)
         trap #XBIOS
         addq.l #6,sp
         tst.b instflg              ;bereits
         bne.s quit                 ;installiert-

         pea message1
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         add.l #newcook-lastacst,a6 ;fÅr cookies
         add.l cookmem,a6           ;benîtiger
         sub.l 28(a5),a6            ;Speicher
         clr -(sp)
         pea (a6)                   ;Programm
         move #PTERMRES,-(sp)       ;resident
         trap #GEMDOS               ;halten

quit:    pea message2
         move #CCONWS,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         clr -(sp)                  ;nicht
         trap #GEMDOS               ;installieren

install:
         move.l _p_cookies,d0       ;cookie jar
         bne.s jar                  ;vorhanden-

         move.l resvalid,valsave
         move.l resvector,vecsave
         move.l #reset,resvector
         move.l #$31415926,resvalid
         moveq #31,d1               ;32 cookie-
                                    ;EintrÑge
         lea newcook,a0
         move.l a0,_p_cookies
         bra.s newjar

jar:     move.l d0,a0
         lea newcook,a1
         moveq #0,d2                ;zÑhlt cookies
loop:    movem.l (a0)+,d0-d1
         cmp.l #USPK,d0
         seq instflg                ;schon
         beq.s ret                  ;installiert-
         movem.l d0-d1,(a1)         ;EintrÑge
         addq.l #8,a1               ;kopieren
         addq.l #1,d2
         tst.l d0
         bne loop
         subq.l #8,a0               ;cookie jar
         cmp.l d1,d2                ;voll?
         bcs.s nofull               ;nein-
         lea -8(a1),a0              ;8 zusÑtzliche
         addq.l #8,d1               ;EintrÑge
         move.l #newcook,_p_cookies
newjar:  move.l d1,d2
   addq.l #1,d2
         asl.l #3,d2
         move.l d2,cookmem
nofull:  lea lastacst,a1
         move.l #"USPK",(a0)+
         move.l a1,(a0)+
         movem.l d0-d1,(a0)
         lea lastacst,a0
         moveq #31,d0
init:    move.l _hz_200,(a0)+       ;Timerwerte
         dbra d0,init               ;zurÅcksetzen
         move.l hdv_rw,old_rw
         move.l #new_rw,hdv_rw
ret:     rts


         dc.l "XBRA"
         dc.l "USPK"
old_rw:  dc.l 0
new_rw:
         move 14(sp),d0             ;Drivenummer
         cmp #32,d0                 ;Absicherung
         bcc.s norw                 ;gegen falsche
                                    ;Drivenummer
         add d0,d0
         add d0,d0
         lea lastacst,a0            ;Zugriffszeit
         move.l _hz_200,(a0,d0)     ;merken
norw:    move.l old_rw(pc),a0
         jmp (a0)

*cookie jar nach Reset zurÅcksetzen
reset:
         clr.l _p_cookies
         move.l valsave,resvalid
         move.l vecsave,resvector
         jmp (a6)


         data

message1:dc.b $0d,$0a
         dc.b "XHDI-Autoparker V1.00 installiert"
         dc.b $0d,$0a
         dc.b "Ω 1992 by Uwe Seimet",$0d,$0a,$00

message2:dc.b $0d,$0a
         dc.b "XHDI-Autoparker ist bereits "
         dc.b "installiert",$0d,$0a,$00


         bss

lastacst:ds.l 32  ;Tabelle mit Zugriffszeiten

valsave: ds.l 1   ;altes Reset-Magic

vecsave: ds.l 1   ;alter Reset-Vektor

newcook: ds.l 512 ;Platzhalter fÅr 256 EintrÑge

cookmem: ds.l 1   ;Grîûe des neuen cookie jar

instflg: ds.b 1   ;Flag fÅr Zweitinstallation
