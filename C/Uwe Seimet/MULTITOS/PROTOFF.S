************************************
* MPROTOFF                         *
*                                  *
* Abschalten der Memory Protection *
*                                  *
* von MultiTOS auf Falcon und TT   *
*                                  *
* by Uwe Seimet                    *
* (c) MAXON Computer 1993          *
************************************


GEMDOS  = 1
MSHRINK = 74
PEXEC   = 75
PTERM   = 76


         ttmem
         ttram
         loadfast


         text

         move.l 4(sp),a0
         move.l 12(a0),a1
         add.l 20(a0),a1
         add.l 28(a0),a1
         lea 256(a1),a1
         pea (a1)
         pea (a0)
         clr -(sp)
         move #MSHRINK,-(sp)
         trap #GEMDOS
         lea 12(sp),sp
         crl.l -(sp)
         pea cmdline
         pea filename
         clr -(sp)
         move #PEXEC,-(sp)
         trap #GEMDOS               ;MiNT starten
         lea 16(sp),sp
         move #-1,-(sp)             ;Fehler,
         move #PTERM,-(sp)          ;falls RÅckkehr
         trap #GEMDOS


         data

cmdline: dc.b 2,"-p",0

filename:dc.b "\auto\mint.prg",0
