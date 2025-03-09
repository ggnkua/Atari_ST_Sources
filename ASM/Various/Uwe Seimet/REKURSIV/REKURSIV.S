******************************************
* rekursives Durchsuchen von Directories *
*                                        *
*              in Assembler              *
*             by Uwe Seimet              *
*       (c) 1991 MAXON Computer          *
******************************************


GEMDOS   = 1
DSETDRV  = 14
FSETDTA  = 26
FGETDTA  = 47
DSETPATH = 59
MSHRINK  = 74
FSFIRST  = 78
FSNEXT   = 79


   text

   move.l sp,a0
   lea stack+400,sp
   move.l 4(a0),a0
   move.l 12(a0),a1     ;LÑnge des TEXT-Segments
   add.l 20(a0),a1         ;DATA-Segment
   add.l 28(a0),a1         ;BSS-Segment
   lea $100(a1),a1         ;fÅr Basepage
   move.l a1,-(sp)
   move.l a0,-(sp)
   clr -(sp)
   move #MSHRINK,-(sp)
   trap #GEMDOS            ;nicht benîtigten Speicher freigeben
   lea 12(sp),sp
   tst.l d0
   bmi.s error
   bsr.s act
error:   clr -(sp)
   trap #GEMDOS

act:
   lea path,a3
   move.b #"\\",(a3)+
   clr.b (a3)
   move #FGETDTA,-(sp)
   trap #GEMDOS
   addq.l #2,sp
   move.l d0,a4
next: pea path
   move #DSETPATH,-(sp)
   trap #GEMDOS
   addq.l #6,sp
   link a6,#-44         ;Stackbereich fÅr DTA-Puffer
   pea (a4)                ;alter DTA-Bereich
   lea 4(sp),a4
   bsr.s setdta
   move #$10,-(sp)
   pea dummy(pc)
   move #FSFIRST,-(sp)
   trap #GEMDOS
   addq.l #8,sp
   bra.s free2
loop: move #FSNEXT,-(sp)
   trap #GEMDOS
   addq.l #2,sp
free2:   tst.l d0       ;noch etwas gefunden?
   bne.s free0          ;nein-
   cmp.b #$e5,30(a4) ;gelîschter Eintrag?
   beq loop       ;ja-
   btst #4,21(a4)    ;Ordner?
   bne.s folder         ;ja-
   bsr.s file
   bra loop
folder:  cmp.b #'.',30(a4) ;Verwaltungseintrag?
   beq loop             ;ja-
   lea 30(a4),a0        ;Pointer auf Namen des Ordners
copy: move.b (a0)+,(a3)+   ;Pfad erweitern
   bne copy
   move.b #'\\',-1(a3)
   clr.b (a3)
   bsr next
   bsr.s setdta
   bra loop
free0:   move.l (sp)+,a4      ;alter DTA-Bereich
   unlk a6
   subq.l #1,a3
   cmp.l #path,a3    ;Ende der Suche?
   beq.s ret               ;ja-
lop:  cmp.b #'\\',-(a3)
   bne lop
   addq.l #1,a3
   clr.b (a3)
ret:  rts

setdta:
   pea (a4)             ;neuer DTA-Bereich
   move #FSETDTA,-(sp)
   trap #GEMDOS
   addq.l #6,sp
   rts

file:
   rts


dummy:   dc.b "*.*",0


   bss

path: ds.b 130

stack:   ds.l 100
