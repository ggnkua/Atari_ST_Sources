******************************
*           REZFIX           *
*                            *
*  geÑnderte GETREZ-Routine  *
*                            *
* Oktober 1990 by Uwe Seimet *
*                            *
******************************


GEMDOS   =  1
PTERMRES = 49

BIOS     = 13
SETEXC   =  5

XBIOS    = 14
GETREZ   =  4


         text

         move.l 4(sp),a6      ;Basepage-Adresse
         pea newxbios(pc)     ;neuer
         move #46,-(sp)       ;XBIOS-Vektor
         move #SETEXC,-(sp)
         trap #BIOS
         addq.l #8,sp
         move.l d0,oldxbios+2 ;alter Vektor
         move.l 12(a6),a0     ;TEXT-Segment
         lea $100(a0),a0      ;LÑnge der Basepage
         clr -(sp)
         pea (a0)
         move #PTERMRES,-(sp)
         trap #GEMDOS         ;zurÅck zum TOS

newxbios:
         lea 8(sp),a0
         btst #5,(sp)         ;Supervisor-Modus?
         bne *+4              ;ja-
         move.l usp,a0        ;sonst User-Stack
         cmp #GETREZ,(a0)
         bne.s oldxbios
         tas xbiosflg         ;bereits im XBIOS?
         bne.s oldxbios       ;ja-
         move #GETREZ,-(sp)   ;wahre Auflîsung
         trap #XBIOS          ;erfragen
         addq.l #2,sp
         cmp #4,d0            ;Auflîsung Ñndern?
         bcs.s ret            ;nein-
         moveq #2,d0          ;hohe ST-Auflîsung
ret:     clr.b xbiosflg
         rte
oldxbios:jmp $ffff            ;weiter im Text-


*xbiosflg verhindert eine Endlosschleife
xbiosflg:dc.b 0
