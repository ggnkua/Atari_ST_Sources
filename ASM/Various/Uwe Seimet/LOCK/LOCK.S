*****************************************
*                                       *
*           LOCK/UNLOCK V1.00           *
*                                       *
* Ver- oder entriegelt den Auswurfknopf *
*  von Wechselplatten unter Verwendung  *
*          des XHDI-Protokolls          *
*                                       *
*             by Uwe Seimet             *
*                                       *
*       (c) 1992 MAXON Computer         *
*                                       *
*****************************************


*MODE-Parameter je nach Bedarf auskommentieren
*MODE    = 0      ;Cartridge freigeben
MODE     = 1      ;Cartridge verriegeln


GEMDOS   = 1

XBIOS    = 14
SUPEXEC  = 38

_p_cookies = $5a0

XHInqTarget = 1
XHLock      = 3
XHDrvMap    = 6
XHInqDev    = 7

XHDIMAGIC = $27011992


         text

         pea act(pc)
         move #SUPEXEC,-(sp)
         trap #XBIOS
         addq.l #6,sp
         clr -(sp)
         trap #GEMDOS

act:
         move.l _p_cookies,d0       ;keine
         beq quit                   ;cookies-
         move.l d0,a0
noxhdi:  movem.l (a0)+,d0/a6
         tst.l d0                   ;kein
         beq quit                   ;XNDI-
         cmp.l #"XHDI",d0
         bne noxhdi
         cmp.l #XHDIMAGIC,-4(a6)
         bne noxhdi

         move #XHDrvMap,-(sp)       ;Ger„tevektor
         jsr (a6)                   ;holen
         addq.l #2,sp
         move.l d0,d6

         moveq #0,d7
loop:    btst d6,d7                 ;kein XHDI
         beq.s noxdev               ;Device-

         clr.l -(sp)
         clr.l -(sp)
         pea minor
         pea major
         move d7,-(sp)
         move #XHInqDev,-(sp)       ;Ger„tenummern
         jsr (a6)                   ;holen
         lea 20(sp),sp
         tst d0
         bmi.s noxdev

         clr.l -(sp)
         pea flags
         clr.l -(sp)
         move minor,-(sp)
         move major,-(sp)
         move #XHInqTarget,-(sp)
         jsr (a6)
         lea 18(sp),sp
         tst d0
         bmi.s noxdev
         btst #2,flags+3            ;kann Ger„t
                                    ;verriegelt
                                    ;werden?
         beq.s noxdev               ;nein-
         tst.l flags                ;Ger„t ist
         bmi.s noxdev               ;reserviert-

         clr -(sp)                  ;Dummy-Key
         move #MODE,-(sp)           ;Cartridge
         move minor,-(sp)           ;sperren oder
         move major,-(sp)           ;entriegel
         move #XHLock,-(sp)         (gem„ž MODE)
         jsr (a6)
         lea 10(sp),sp

noxdev:  addq #1,d7
         cmp #32,d7                 ;n„chstes
         bne loop                   ;Device-

quit:    clr -(sp)
         trap #GEMDOS
         

         bss

flags:   ds.l 1

major:   ds.w 1

minor:   ds.w 1
