*    
* ts2.s
*
* v2003.03.03
* Copyright (c) 2003
* by Hermann Samso (Spacewalker)
*
* Intro TS numero 2.
*
* Utiliza:letras1b.ts
*         dwarfs1.ts
*         logo1.ts
*

start   bsr     initFromGEM

        bsr     initInterrupts

        bset.b  #2,flags

        * init troll
        bsr     initTroll
        move.l  logScr,oldOldTroll
        move.l  phyScr,oldTroll

        * set dwarf sine 1
        move.l  #sine1,a1
        move.l  #$2b48,d0
        bsr     dwarfSetSine

loop1   move.b  #1,vblWait
loop0   bsr     wvbl
        sub.b   #1,vblWait
        bne     loop0

        bsr     clrTroll
        bsr     clrDwarfs

        bsr     updateTroll
        bsr     updateDwarfs

        bsr     paintScroll
        bsr     paintTroll
;        bsr     paintTrollCoords
        bsr     paintDwarfs

        bsr     KCI

        bsr     xChangeScreens

        * make sound
        bsr     playMusic

        btst.b  #0,flags
        beq     loop1

        bsr     endInterrupts
        bra     endToGEM




****************************************
* Keyboard Command Input routine
****************************************
KCI     move.b  $fffffc02,d0
        * release key?
        cmp.b   #$79,d0
        ble     KCID
        * yes, return
        clr.b   kbdLast
        rts
        * new key ?
KCID    cmp.b   kbdLast,d0
        * yes, reset count
        bne     KCIC
        * end of delay ?
        cmp.b   #0,kbdCont
        * yes, use key
        ble     KCIB
        * decrement count
        sub.b   #1,kbdCont
        * return
        rts
        * reset count
KCIC    move.b  kbdDely,kbdCont
        move.b  d0,kbdLast
KCIB    cmp.b   #2,d0   ;'1'
        bne     KCI1
        * set scroll speed 1
        move.b  #1,newvelo
        rts
KCI1    cmp.b   #3,d0   ;'2'
        bne     KCI2
        * set scroll speed 2
        move.b  #2,newvelo
        rts
KCI2    cmp.b   #4,d0   ;'3'
        bne     KCI3
        * set scroll speed 4
        move.b  #4,newvelo
        rts
KCI3    cmp.b   #5,d0   ;'4'
        bne     KCI4
        * set dwarf sine 1
        move.l  #sine1,a1
        move.l  #$2b48,d0
        bsr     dwarfSetSine
        rts
KCI4    cmp.b   #6,d0   ;'5'
        bne     KCI5
        * set dwarf sine 2
        move.l  #sine2,a1
        move.l  #$2b48,d0
        bsr     dwarfSetSine
        rts
KCI5    cmp.b   #7,d0   ;'6'
        bne     KCI6
        * set dwarf sine 3
        move.l  #sine3,a1
        move.l  #$2b48,d0
        bsr     dwarfSetSine
        rts
KCI6    cmp.b   #8,d0   ;'7'
        bne     KCI7
        bsr     showTroll
        rts
KCI7    cmp.b   #9,d0   ;'8'
        bne     KCI8
        bsr     showLetras
        rts
KCI8    cmp.b   #10,d0  ;'9'
        bne     KCI9
        bsr     showDwarfs
        rts
KCI9    cmp.b   #11,d0  ;'0'
        bne     KCIA
        bchg.b  #2,flags
        rts
KCIA	cmp.b	#$ff,d0
        beq     KCIEnd
	cmp.b	#$39,d0
        beq     KCIEnd

        rts
        * signalize end of prg
KCIEnd  bset.b  #0,flags
        rts



****************************************
* Paint coordinates of troll.
****************************************
paintTrollCoords
        * X coordinate 'trollX'
        move.w  trollX,d0
        move.w  #0,d1
        move.w  #0,d2
        bsr     paintByte

        * Y coordinate 'trollY'
        move.w  trollY,d0
        move.w  #0,d1
        move.w  #1,d2
        bsr     paintByte

        rts



****************************************
* Paint unsigned Byte d0.b at
* (x,y)=(d1.w,d2.w) in hexadecimal.
****************************************
paintByte
        and.l   #$000000FF,d0
        move.l  d0,d6
        divu    #$10,d6
        swap    d6
        move.w  d6,d0
        add.b   #'0',d0
        cmp.b   #'9',d0
        ble     pntByt1
        add.b   #7,d0
pntByt1 addq.w  #1,d1
        bsr     paintLetter

        swap    d6
        divu    #$10,d6
        swap    d6
        move.w  d6,d0
        add.b   #'0',d0
        cmp.b   #'9',d0
        ble     pntByt2
        add.b   #7,d0
pntByt2 subq.w  #1,d1
        bsr     paintLetter

        rts


****************************************
* Paint letter d0.b at (x,y)=(d1.w,d2.w)
****************************************
paintLetter
        movem.l d0-d2/a0-a1,-(sp)

        sub.b   #32,d0
        blt     pntLtrE
        lea     letras,a0
        ext.w   d0
        mulu.w  #32,d0
        adda.l  d0,a0
        movea.l logScr,a1
        mulu.w  #160*16,d2
        adda.l  d2,a1
        mulu.w  #8,d1
        adda.l  d1,a1
pntLtr  rept    16
        move.w  (a0)+,(a1)
        adda.l  #160,a1
        endr

pntLtrE movem.l (sp)+,d0-d2/a0-a1

        rts



****************************************
* Initialize Trolls.
****************************************
initTroll
* Reserve memory for 16 trolls
	
        move.l  #((96+16)*96/2)*16,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,trolls

* Copy troll 16 times... 
        move.w  #0,d0
initTrollC
        lea     logo3,a0
        movea.l trolls,a1
	move.w	d0,d1
        mulu.w  #5376,d1
	adda.l	d1,a1
        move.w  #96-1,d1
initTrollB
        move.w  #12-1,d2
initTrollA
        move.l  (a0)+,(a1)+
        dbra    d2,initTrollA
        move.l  #0,(a1)+
        move.l  #0,(a1)+
        dbra    d1,initTrollB
        addq.w  #1,d0 
        cmp.w   #16,d0
        beq     initTroll3
        bra     initTrollC

* ... rotate trolls pixels
* rotates each line of troll
* from right (high) to left (low)
initTroll3
        move.w  #0,d1
initTroll4
        movea.l trolls,a0
        move.w  d1,d0
        addq.l  #1,d0
        mulu.w  #5376,d0
        adda.l  d0,a0
        suba.l  #2,a0
        * 96 lines
        move.w  #96-1,d3
initTroll5
        * 24*2+8 bytes each line
        move.w  #24-1,d0
initTroll7
        move.w  -8(a0),d2
        swap    d2
        move.w  (a0),d2
        ror.l   d1,d2
        move.w  d2,(a0)
        suba.l  #2,a0
        dbra    d0,initTroll7
* rotation line trail 
        move.w  #4-1,d0
initTroll6
        move.w  (a0),d2
        lsr.w   d1,d2
        move.w  d2,(a0)
        suba.l  #2,a0
        dbra    d0,initTroll6

        dbra    d3,initTroll5

        add.w   #1,d1
        cmp.w   #16,d1
        beq     initTroll8
        bra     initTroll4
initTroll8
	
* test if trolls rotated correctly
;bclf    clr.l   d1
;bcle    bsr     wvbl
;        movea.l trolls,a1
;        move.w  d1,d2
;        mulu.w  #5376,d2
;        adda.l  d2,a1
;        movea.l logScr,a0
;        move.w  #96-1,d0 
;bcld    movem.l (a1)+,d2-d7/a3
;        movem.l d2-d7/a3,(a0)
;        adda.l  #28,a0
;        movem.l (a1)+,d2-d7/a3
;        movem.l d2-d7/a3,(a0)
;        adda.l  #160-28,a0
;        dbra    d0,bcld
;        addq.b  #1,d1
;        cmp.b   #16,d1
;        bne     bcle
;        tst.b   $fffc02 ;wait for key
;        beq     bclf

        rts


****************************************
* update Troll position
* save 'oldTroll' to 'oldOldTroll'
****************************************
updateTroll
        * save 'oldTroll' for clear
        move.l  oldTroll,oldOldTroll

        * left,right movement
        move.w  trollSpeed,d0
        add.w   d0,trollX
        cmp.w   #320-96,trollX
        ble     updTrl1
        move.w  #320-96,trollX
        move.w  #-1,trollSpeed
        bra     updTrl2
updTrl1 cmp.w   #0,trollX
        bge     updTrl2
        move.w  #0,trollX
        move.w  #1,trollSpeed
        * up,down movement
updTrl2 movea.l pSinTrl,a0
        move.b  (a0)+,d0
        cmp.b   #127,d0
        bne     updTrl3
        lea     sine4,a0
        move.b  (a0)+,d0
updTrl3 move.l  a0,pSinTrl
        ext.w   d0
        add.w   d0,trollY
        cmp.w   #199-96,trollY
        ble     updTrl4
        move.w  #199-96,trollY
updTrl4 cmp.w   #0,trollY
        bge     updTrl5
        move.w  #0,trollY
updTrl5
        rts

	

****************************************
* Clear troll at 'oldOldTroll'
****************************************
clrTroll
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7

        movea.l oldOldTroll,a0
	move.w	#5-1,d0
clrTrl1 rept    19
        movem.l d1-d7,(a0)
        adda.w  #28,a0
        movem.l d1-d7,(a0)
	adda.w	#160-28,a0	
	endr
        dbra    d0,clrTrl1

        movem.l d1-d7,(a0)
        adda.w  #28,a0
        movem.l d1-d7,(a0)


        rts


****************************************
* Paint troll
* save screen position 'oldTroll'
****************************************
paintTroll
        * calc 'oldTroll' from
        * 'trollX','trollY'
        movea.l logScr,a1
        move.w  trollY,d0
        mulu.w  #160,d0
        adda.l  d0,a1
        move.w  trollX,d0
        move.w  d0,d1
        ext.l   d0
        lsr.l   #4,d0           ; /16
        lsl.l   #3,d0           ; *8
        adda.l  d0,a1
        move.l  a1,oldTroll
        and.w   #$000f,d1
        mulu.w  #5376,d1
        movea.l trolls,a0
        adda.l  d1,a0

	move.w	#5-1,d0
pntTrl1 rept    19
        movem.l (a0)+,d1-d7
        movem.l d1-d7,(a1)
        adda.l  #28,a1
        movem.l (a0)+,d1-d7
        movem.l d1-d7,(a1)
        adda.l  #160-28,a1
	endr
        dbra    d0,pntTrl1

        movem.l (a0)+,d1-d7
        movem.l d1-d7,(a1)
        adda.l  #28,a1
        movem.l (a0)+,d1-d7
        movem.l d1-d7,(a1)

        rts


****************************************
* Show 'logo3.ts' statically.
****************************************
showTroll
        bclr.b  #2,flags

        movea.l phyScr,a0
        bsr     clrScreen

        movea.l phyScr,a0
        movea.l trolls,a1

        move.w  #96-1,d0 
shwTrl1 movem.l (a1)+,d2-d7/a3
        movem.l d2-d7/a3,(a0)
        adda.l  #28,a0
        movem.l (a1)+,d2-d7/a3
        movem.l d2-d7/a3,(a0)
        adda.l  #160-28,a0
        dbra    d0,shwTrl1

shwTrl3 move.b  $fffc02,d0
        cmp.b   #1,d0           ;[ESC]
        bne     shwTrl3

        movea.l phyScr,a0
        bsr     clrScreen

        bset.b  #2,flags

        rts


****************************************
* Change dwarfs' sine waves and
* to screen pointers
* a1->sine table
* d0->screen offset
****************************************
dwarfSetSine
        * clear last dwarfs
        lea     dwfOff,a0
        moveq.l #0,d6

        move.w  #9-1,d1
dwfSSin movea.l logScr,a2
        adda.l  (a0)+,a2
	rept	16
        move.l  d6,(a2)
        move.l  d6,4(a2)
        adda.l  #160,a2 
	endr
        dbra    d1,dwfSSin


        * calc new screen offsets
        lea     sinDwf,a0
        move.l  a1,(a0)
        lea     pSinDwf,a0
        move.l  a1,(a0)
        lea     dwfOff,a0

	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+
        add.l   #16,d0
	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+
        addq.l  #8,d0
	move.l	d0,(a0)+

	rts



**************************************** 
* update dwarfs' screen offsets
* move last painted to 'oldDwfOff'
****************************************
updateDwarfs
        * save screen offsets
        lea     lastOff,a0
        lea     oldLastOff,a1
        move.w  #9-1,d0
updDwf0 move.l  -(a0),-(a1)
        dbra    d0,updDwf0


        * shift screen offsets
        lea     lastOff,a0
	movea.l	a0,a1
	suba.l	#4,a1
	
	rept	5
	move.l	-(a1),-(a0)
	add.l	#8,(a0)
	endr
	move.l	-(a1),-(a0)
	add.l	#16,(a0)
	rept	2
	move.l	-(a1),-(a0)
	add.l	#8,(a0)
	endr

        * calc new offset
        movea.l pSinDwf,a0
        clr.l   d0
        move.b  (a0)+,d0
        cmp.b   #127,d0
        bne     updDwrf
        movea.l sinDwf,a0
        move.b  (a0)+,d0
updDwrf move.l  a0,pSinDwf
        ext.w   d0
	muls.w	#160,d0
        add.l   d0,(a1)

        rts



****************************************
* Clear forelast painted dwarfs.
* Deletes 1st, 2nd, 3rd and 4th plane.
****************************************
clrDwarfs
        lea     oldDwfOff,a0
        moveq.l #0,d6

	move.w	#9-1,d0
clrdwrf movea.l logScr,a1
        adda.l  (a0)+,a1
	rept	16
	move.l	d6,(a1)
        move.l  d6,4(a1)
	adda.l	#160,a1 
	endr
        dbra    d0,clrdwrf

        rts



****************************************
* Paint dwarfs.
* Clears 1st and 2nd planes,
* paints 3rd and 4th planes.
****************************************
paintDwarfs
        lea     dwfOff,a6
	lea	dwarfs,a0

	move.w	#9-1,d0	
pntDwrf movea.l logScr,a1
        adda.l  (a6)+,a1
	rept	16
        move.l  #0,(a1)
        move.l  (a0)+,4(a1)
        adda.l  #160,a1
	endr
        dbra    d0,pntDwrf

        rts



****************************************
* Show 'dwarfs1.ts' statically.
****************************************
showDwarfs
        bclr.b  #2,flags

        movea.l phyScr,a0
        bsr     clrScreen

        movea.l phyScr,a1
        lea     dwarfs,a0

        move.w  #9-1,d0 
shwDwf1 rept    16
        move.l  #0,(a1)
        move.l  (a0)+,4(a1)
        adda.l  #160,a1
        endr
        suba.l  #160*16-8,a1
        dbra    d0,shwDwf1


shwDwf3 move.b  $fffc02,d0
        cmp.b   #1,d0
        bne     shwDwf3         ;[ESC]

        movea.l phyScr,a0
        bsr     clrScreen

        bset.b  #2,flags

        rts



****************************************
* Paint scroll
****************************************
paintScroll
        movea.l ptext,a1
        movea.l logScr,a0
        adda.l  #160*184,a0
        moveq.l #0,d5
        move.b  count,d5

        * display 20 letters
        move.w  #20-1,d0
pntScrl1
        * get letter n
        move.b  (a1)+,d2
        sub.b   #32,d2
        ext.w   d2
        mulu    #32,d2
        lea     letras,a2
        adda.l  d2,a2
        * get letter n+1
        move.b  (a1),d2
        sub.b   #32,d2
        ext.w   d2
        mulu    #32,d2
        lea     letras,a3
        adda.l  d2,a3
        * display 16 letter lines
        move.w  #16-1,d1
pntScrl0
        move.w  (a3)+,d4
        swap    d4
        move.w  (a2)+,d4
        rol.l   d5,d4
        move.w  d4,(a0)
        adda.l  #160,a0
        dbra    d1,pntScrl0
        * displayed 16 letter lines
        suba.l  #16*160-8,a0
        dbra    d0,pntScrl1
        * displayed 20 letters

        * update 'count'
        add.b   velo,d5
        move.b  d5,count
        cmp.b   #16,d5
        blt     pntScrlE
        * reset 'count'
        move.b  #0,count
        * set new 'velo'
        move.b  newvelo,velo
        * advance 'ptext'
        add.l   #1,ptext
        * eof text ?
        cmp.b   #0,(a1)
        bne     pntScrlE
        * restore text pointer
        lea     text,a0
        move.l  a0,ptext
pntScrlE
        
        rts


****************************************
* Show 'letras' statically.
****************************************
showLetras
        bclr.b  #2,flags

        movea.l logScr,a0
        bsr     clrScreen

        move.b  #' ',d0
        move.w  #0,d2
shwLtr1 move.w  #0,d1
shwLtr2 bsr     paintLetter
        addq.b  #1,d0
        cmp.b   #'Z',d0
        beq     shwLtr4
        addq.w  #1,d1
        cmp.w   #20,d1
        bne     shwLtr2
        addq.w  #1,d2
        bra     shwLtr1

shwLtr4 bsr     xChangeScreens

shwLtr3 move.b  $fffc02,d0
        cmp.b   #1,d0           ;[ESC]
        bne     shwLtr3

        movea.l phyScr,a0
        bsr     clrScreen
        movea.l logScr,a0
        bsr     clrScreen

        bset.b  #2,flags

        rts



****************************************
* Clear screen routine.
* A0=start of screen
****************************************
clrScreen
        adda.l  #32000,a0  point to end

        movem.l d0-d5/a1-a5,-(sp)
        move.l  #0,d1
        move.l  d1,d2
        move.l  d1,d3
        move.l  d1,d4
        move.l  d1,d5
        movea.l d1,a1
        movea.l d1,a2
        movea.l d1,a3
        movea.l d1,a4
        movea.l d1,a5

        move.l  #80-1,d0
clrScr  rept    10
        movem.l d1-d5/a1-a5,-(a0)
        endr
        dbra    d0,clrScr

        movem.l (sp)+,d0-d5/a1-a5

	rts


****************************************
* Wait vor VBL
****************************************
wvbl
;        move.w  #37,-(sp)
;        trap    #14
;        addq.l  #2,sp

*        stop    #$2300  ;VBL interrupt

        btst.b  #1,flags
        beq     wvbl
        bclr.b  #1,flags
	rts



****************************************
* Set color palette
* A0 = new color palette pointer
****************************************
setPalette
        movem.l a1,-(sp)

        lea     $fff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr

        movem.l (sp)+,a1

        rts


****************************************
* Save color palette
* A0=palette cache
****************************************
savePalette
        movem.l a1,-(sp)

        lea     $fff8240,a1
	rept	8
        move.l  (a1)+,(a0)+
	endr

        movem.l (sp)+,a1

        rts


****************************************
* Exchange screen buffers:
* 'phyScr' <-> 'logScr'
****************************************
xChangeScreens
        move.l  phyScr,d0
        move.l  logScr,d1
        move.l  d0,logScr
        move.l  d1,phyScr

;        move.w  #-1,-(sp)
;        move.l  d1,-(sp)
;        move.l  d0,-(sp)
;        move.w  #5,-(sp)
;        trap    #14
;        add.l   #12,sp

;        move.w  #$2700,sr
        lsr.w   #8,d1
        move.b  d1,$ffff8203
        swap    d1
        move.b  d1,$ffff8201
;        move.w  #$2300,sr

        rts



****************************************
* Finalization routine into GEM
****************************************
endToGEM
        movea.l phyScr,a0
        bsr     clrScreen

        movea.l logScr,a0
        bsr     clrScreen

* restore 'pbase'&'lbase'
	move.w	#-1,-(sp)
        move.l  pbase,-(sp)
        move.l  lbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
* restore palette
        lea     oldpal,a0
        bsr     setPalette

* restore reserved memory for trolls
	move.l	trolls,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
* restore reserved screens memory
        move.l  pscrs,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
* restore reserved memory for prg
        move.l  basepage,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

* User mode
	move.l	savesp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
			
* Restore mouse cursor
	dc.w	$a009

	
* end program
	clr.w	-(sp)
	trap	#1



****************************************
* From GEM Initialization
****************************************
initFromGEM
* Save User stack
* [Why? 1 stack fits all]
* [BTW, was never restored :)]
*        move.l  a7,sa7

* 4(a7) return address for this function
* 8(a7) binary start address (basepage)
        move.l  8(a7),a5
* + text, data, BSS segment sizes
        move.l  $c(a5),d0     ;text
        add.l   $14(a5),d0    ;data
        add.l   $1c(a5),d0    ;BSS
* + basepage size
        add.l   #$100,d0
        move.l  a5,basepage
* reserve only necessary memory
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        clr.w   -(sp)
        move.w  #$4a,-(sp)
* free the rest
        trap    #1
        lea     12(sp),sp
	
* enter Supervisor mode
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp		
	move.l	d0,savesp

* Save physical screen base 'pbase'
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
        move.l  d0,pbase

* Save logical screen base 'lbase'
        move.w  #3,-(sp)
	trap	#14
	addq.l	#2,sp
        move.l  d0,lbase

* Get mem for logical and physical
* screens 'logScr', 'phyScr'
        move.l  #64000+256,-(sp)
        move.w  #$48,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,pscrs
* make address 256Bytes divisible
        add.l   #256,d0
        clr.b   d0
        move.l  d0,logScr
        add.l   #32000,d0
        move.l  d0,phyScr

* remove mouse cursor
        dc.w    $a00a

        movea.l phyScr,a0
        bsr     clrScreen

        movea.l logScr,a0
        bsr     clrScreen

        lea     oldpal,a0
        bsr     savePalette

        lea     newpal,a0
        bsr     setPalette

        rts


****************************************
* HBL interrupt routine.
* Rainbow backgrounds.
* Red over black 'hbl3'.
****************************************
hbl     move.w  clrtbl0,$ff8240
hbl2    move.w  clrtbl2,$ff8242
        add.l   #2,hbl+2
        add.l   #2,hbl2+2
        bclr    #0,$fffffa0f.w

        rte


hbl3    move.w  #$000,$ff8240
        move.w  #$f00,$ff8242
        bclr    #0,$fffffa0f.w

        rte


****************************************
* VBL interrupt routine.
****************************************
vbl     movem.l a0,-(sp)

        btst.b  #2,flags    ;rainbow?
        bne     vbl1        
        lea     hbl3,a0     ;no, hang..
        move.l  a0,$120     ;..'hbl3'
        bra     vbl2
vbl1    movea.l pclrtbl,a0  ;actualize..
        adda.l  #2,a0       ;..'pclrtbl'
        cmpa.l  #clrtbl1,a0
        bne     vbl11
        lea     clrtbl0,a0
vbl11   move.l  a0,hbl+2    ;set rainbow
        move.l  a0,pclrtbl 
        lea     clrtbl2,a0  ;set rainbow
        move.l  a0,hbl2+2   ;..two
        lea     hbl,a0
        move.l  a0,$120
vbl2    bset.b  #1,flags    ;signal VBL

        add.l   #1,vblCount ;VBL cont+1

        movem.l (sp)+,a0
        rte


****************************************
* Set interrupts. HBLs and VBLs.
****************************************
initInterrupts
        ; ignore ALL interrupts
        move.w  #$2700,sr
        move.l  $70,svbl
        move.l  #vbl,$70
        move.l  $120,shbl
        move.l  #hbl,$120
        move.b  $fffffa07,sa07 ;IEA
        move.b  $fffffa09,sa09 ;IEB
        move.b  $fffffa13,sa13 ;IMRA
        move.b  $fffffa15,sa15 ;IMRB
        move.b  $fffffa21,sa21
        move.b  $fffffa1b,sa1b
        ;Int EnableB (200Hz Timer C)
        and.b   #$df,$fffffa09
        ;Int EnableA (HBL Timer B)
        and.b   #$fe,$fffffa07 
        or.b    #1,$fffffa07
        ;Int Mask RegA
        or.b    #1,$fffffa13
        move.w  #$25,-(sp)
        trap    #13
        addq.l  #2,sp
        ;Timer B Control stop
        move.b  #0,$fffffa1b
        ;Timer B Control Event Count mode
        move.b  #8,$fffffa1b
        ;Timer B Data
        move.b  #2,$fffffa21
        ; permit VBL interrupt
        move    #$2300,sr

        rts


****************************************
* End interrupts. HBLs and VBLs.
****************************************
endInterrupts 
        movem.l d0/a0,-(sp)

        * ignore ALL interrupts
        move.w  #$2700,sr
        clr.l   $4d6
        move.l  svbl,$70
        move.l  shbl,$120
        move.b  sa07,d0
        move.b  d0,$fffffa07
        move.b  sa09,d0
        move.b  d0,$fffffa09
        move.b  sa13,d0
        move.b  d0,$fffffa13
        move.b  sa15,d0
        move.b  d0,$fffffa15
        move.b  sa1b,d0
        move.b  d0,$fffffa1b
        move.b  sa21,d0
        move.b  d0,$fffffa21
        move.l  #$4ce+4,a0
        rept    7
        clr.l   (a0)+
        endr
        * permit VBL interrupt
        move    #$2300,sr

        movem.l (sp)+,d0/a0

        rts



****************************************
* Play music. Directly thru' YM-2149.
* Plays 3 scores: channels A,B,C
****************************************
playMusic
        lea     sndTbl,a1

        * channel A score
        cmp.w   #0,countA  countA zero? 
        bne     plyMzkA 
        movea.l pScoreA,a0
        cmp.b   #-1,(a0)  end-of-score?        
        bne     plyMzk1
        movea.l chanelA,a0
plyMzk1 move.b  (a0)+,d0
        and.w   #$00ff,d0
        mulu    #4,d0
        move.l  (a1,d0),soundA
        moveq.w #0,d0
        move.b  (a0)+,d0
        and.w   #$00ff,d0
        move.w  d0,countA
        move.l  a0,pScoreA
plyMzkA movea.l soundA,a0
        bsr     playSound
        sub.w   #1,countA

        * channel B score
        cmp.w   #0,countB  countB zero? 
        bne     plyMzkB 
        movea.l pScoreB,a0
        cmp.b   #-1,(a0)  end-of-score?        
        bne     plyMzk2
        movea.l chanelB,a0
plyMzk2 move.b  (a0)+,d0
        and.w   #$00ff,d0
        mulu    #4,d0
        move.l  (a1,d0),soundB
        moveq.w #0,d0
        move.b  (a0)+,d0
        and.w   #$00ff,d0
        move.w  d0,countB
        move.l  a0,pScoreB
plyMzkB movea.l soundB,a0
        bsr     playSound
        sub.w   #1,countB

        * channel C score
        cmp.w   #0,countC  countC zero? 
        bne     plyMzkC 
        movea.l pScoreC,a0
        cmp.b   #-1,(a0)  end-of-score?         
        bne     plyMzk3
        movea.l chanelC,a0
plyMzk3 move.b  (a0)+,d0
        and.w   #$00ff,d0
        mulu    #4,d0
        move.l  (a1,d0),soundC
        moveq.w #0,d0
        move.b  (a0)+,d0
        and.w   #$00ff,d0
        move.w  d0,countC
        move.l  a0,pScoreC
plyMzkC movea.l soundC,a0
        bsr     playSound
        sub.w   #1,countC
plyMzkE
        rts


****************************************
* Play Sound. Directly thru' YM-2149.
* A0=pointer to sound
****************************************
playSound
        move.b  (a0)+,$ffff8800
        move.b  (a0)+,$ffff8802
        cmp.b   #127,(a0)
        bne     playSound

        rts


chanelA         dc.l    score1
pScoreA         dc.l    score1
soundA          dc.l    pauseABC
countA          dc.w    0

chanelB         dc.l    score2
pScoreB         dc.l    score2
soundB          dc.l    pauseABC
countB          dc.w    0

chanelC         dc.l    score3
pScoreC         dc.l    score3
soundC          dc.l    pauseABC
countC          dc.w    0


* table with pointers to sounds
sndTbl  dc.l    pauseABC ;0
        dc.l    pauseA   ;1
        dc.l    pauseB   ;2
        dc.l    pauseC   ;3
        dc.l    click1A  ;4
        dc.l    click2A  ;5
        dc.l    click1B  ;6
        dc.l    click1C  ;7
        dc.l    sweepA1  ;8
        dc.l    sweepB1  ;9
        dc.l    sweepC1  ;10
        dc.l    sonarC1  ;11
        dc.l    sonarC2  ;12
        dc.l    ballC1   ;13
        dc.l    crystlC1 ;14
        dc.l    nopABC   ;15
        dc.l    sonarC3  ;16
        dc.l    sonarC4  ;17

* scores of sounds for 3 channels
score1
        dc.b    8,      250
        dc.b    -1      end-of-score
score2
        dc.b    9,      250
        dc.b    -1      end-of-score
        dc.b    2,      250
        dc.b    -1      end-of-score
score3  dc.b    17,     1
        dc.b    15,     49
        dc.b    15,     24
        dc.b    12,     1
        dc.b    3,      12
        dc.b    12,     1
        dc.b    3,      12

        dc.b    17,     1
        dc.b    15,     49
        dc.b    15,     24
        dc.b    12,     1
        dc.b    3,      25
        dc.b    -1      end-of-score

* sounds
        * pause (A,B,C)
pauseABC
        dc.b 0,0,1,0,2,0,3,0
        dc.b 4,0,5,0,6,0,7,$ff,8,0
        dc.b 9,0,10,0,11,0,12,0,13,0
        dc.b 127
        * noOperation (A,B,C)
nopABC  dc.b 7,56
        dc.b 127
        * pause (A)
pauseA  dc.b 7,56
        dc.b 0,15,1,255
        dc.b 8,0
        dc.b 127
        * pause (B)
pauseB  dc.b 7,56
        dc.b 2,15,3,255
        dc.b 9,0
        dc.b 127
        * pause (C)
pauseC  dc.b 7,56
        dc.b 4,15,5,255
        dc.b 10,0
        dc.b 127
        * key click 1 (A) 
click1A dc.b 7,56
        dc.b 1,9,0,52
        dc.b 8,15
        dc.b 6,0
        dc.b 127    end-of-sound
click2A * key click 2 (A)
        dc.b 7,56
        dc.b 0,54   chnl A fine tune
        dc.b 1,15   chnl A coarse tune
        dc.b 6,0    noise generator
        dc.b 8,15   max volume A
        dc.b 127    end-of-sound
click1B * key click 3 (B)
        dc.b 7,56
        dc.b 2,12   chnl B fine tune
        dc.b 3,2    chnl B coarse tune
        dc.b 6,0    noise generator
        dc.b 9,15   max volume B
        dc.b 127    end-of-sound
click1C * key click 4 (C)
        dc.b 7,56
        dc.b 5,10   chnl C coarse tune
        dc.b 4,10   chnl C fine tune
        dc.b 6,0    noise generator
        dc.b 10,15  max C volume
        dc.b 13,2   attack
        dc.b 127    end-of-sound
        * sound (A)
sweepA1 dc.b 7,56
        dc.b 1,$f,0,$fe
        dc.b 8,$f
        dc.b 127
        * deep sweep (B)
sweepB1 dc.b 7,56
        dc.b 3,$f,2,$ef
        dc.b 9,$f
        dc.b 127
        * deep sweep (C)
sweepC1 dc.b 7,56
        dc.b 5,$f,4,$ff
        dc.b 10,$f
        dc.b 13,2
        dc.b 127
        * sonar (C)
sonarC1 dc.b 7,56
        dc.b 5,$0,4,$ff
        dc.b 6,0
        dc.b 10,$1f
        dc.b 12,$ff,11,$fd
        dc.b 13,0
        dc.b 127
        * sonar (C)
sonarC2 dc.b 7,56
        dc.b 5,$0,4,$30
        dc.b 6,0
        dc.b 10,$10
        dc.b 12,$ff,11,$fd
        dc.b 13,2
        dc.b 127
        * sonar (C)
sonarC3 dc.b 7,56
        dc.b 5,$2,4,$30
        dc.b 6,0
        dc.b 10,$10
        dc.b 12,$ff,11,$fd
        dc.b 13,2
        dc.b 127
sonarC4 dc.b 7,56
        dc.b 5,$4,4,$30
        dc.b 6,0
        dc.b 10,$10
        dc.b 12,$ff,11,$fd
        dc.b 13,2
        dc.b 127
ballC1  dc.b 7,56
        dc.b 5,$3,4,$30
        dc.b 10,$10
        dc.b 12,$16,11,$00
        dc.b 13,2
        dc.b 127
crystlC1
        dc.b 7,56
        dc.b 5,$0,4,$30
        dc.b 10,$10
        dc.b 12,$16,11,$00
        dc.b 13,2
        dc.b 127
	even

basepage        dc.l    0
savesp          dc.l    0
pscrs           dc.l    0
phyScr          dc.l    0
logScr          dc.l    0
pbase           dc.l    0
lbase           dc.l    0
ptext           dc.l    text
pclrtbl         dc.l    clrtbl0
dwfOff          dc.l    0,0,0,0,0
                dc.l    0,0,0,0
lastOff
oldDwfOff       dc.l    0,0,0,0,0
                dc.l    0,0,0,0
oldLastOff
trolls          dc.l    0
oldTroll        dc.l    0
oldOldTroll     dc.l    0
trollSpeed      dc.w    1
trollX          dc.w    177
trollY          dc.w    0
letra           ds.l    8
shbl            dc.l    0
svbl            dc.l    0
vblCount        dc.l    0
oldpal  ds.w    16
newpal  dc.w    $000,$700,$070,$070,$337,$000,$700,$000
        dc.w    $114,$775,$700,$500,$557,$700,$225,$765
clrtbl0 dc.w    $301,$402,$502,$603,$703,$703,$603,$502,$402,$301
	dc.w	$030,$040,$050,$060,$070,$070,$060,$050,$040,$030
	dc.w	$303,$404,$505,$606,$707,$707,$606,$505,$404,$303
	dc.w	$003,$004,$005,$006,$007,$007,$006,$005,$004,$003
        dc.w    $031,$042,$052,$063,$073,$073,$063,$052,$042,$031
	dc.w	$300,$400,$500,$600,$700,$700,$600,$500,$400,$300
        dc.w    $330,$440,$550,$660,$770,$770,$660,$550,$440,$330
        dc.w    $302,$403,$504,$605,$706,$706,$605,$504,$403,$302
        dc.w    $103,$204,$205,$306,$307,$307,$306,$205,$204,$103
        dc.w    $332,$442,$553,$663,$775,$775,$663,$553,$442,$332
*        dc.w    $320,$530,$640,$750,$760,$760,$750,$640,$530,$320
clrtbl1 dc.w    $301,$402,$502,$603,$703,$703,$603,$502,$402,$301
	dc.w	$030,$040,$050,$060,$070,$070,$060,$050,$040,$030
	dc.w	$303,$404,$505,$606,$707,$707,$606,$505,$404,$303
	dc.w	$003,$004,$005,$006,$007,$007,$006,$005,$004,$003
        dc.w    $031,$042,$052,$063,$073,$073,$063,$052,$042,$031
	dc.w	$300,$400,$500,$600,$700,$700,$600,$500,$400,$300
        dc.w    $330,$440,$550,$660,$770,$770,$660,$550,$440,$330
        dc.w    $302,$403,$504,$605,$706,$706,$605,$504,$403,$302
        dc.w    $103,$204,$205,$306,$307,$307,$306,$205,$204,$103
        dc.w    $332,$442,$553,$663,$775,$775,$663,$553,$442,$332
*        dc.w    $320,$530,$640,$750,$760,$760,$750,$640,$530,$320
clrtbl2 dc.w    $277,$177,$077,$166,$255,$344,$433,$522,$611,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770,$670,$570,$470
	dc.w	$370,$270,$170,$070,$071,$072,$073,$074,$075,$076
	dc.w	$077,$067,$057,$047,$037,$027,$017,$007,$107,$207
	dc.w	$307,$407,$507,$607,$707,$706,$705,$704,$703,$702
	dc.w	$701,$700,$710,$720,$730,$740,$750,$760,$770,$670
	dc.w	$570,$470,$370,$270,$170,$070,$071,$072,$073,$074
	dc.w	$075,$076,$077,$067,$057,$047,$037,$027,$017,$007
        dc.w    $107,$207,$307,$407,$507,$607,$707,$706,$705,$704
        dc.w    $703,$702,$701,$700,$710,$720,$730,$740,$750,$760
*        dc.w    $000,$000,$111,$222,$333,$444,$333,$222,$111,$000
vblWait dc.b    0
sa07    dc.b    0 ;InterruptEnableA
sa09    dc.b    0 ;InterruptEnableB
sa13    dc.b    0 ;InterruptMaskRegA
sa15    dc.b    0 ;InterruptMaskRegB
sa1f    dc.b    0 ;TimerAData
sa21    dc.b    0 ;TimerBData
sa19    dc.b    0 ;TimerAControl
sa1b    dc.b    0 ;TimerBControl
sa01	dc.b	0
* keyboard delay,count&last key
kbdDely dc.b    25
kbdCont dc.b    5
kbdLast dc.b    0
* senos de dwarfs
	even
sinTrl  dc.l    sine4
pSinTrl dc.l    sine4
sinDwf  dc.l    sine1
pSinDwf dc.l    sine1
sine1   dc.b    0,0,0,1,1,1,2,2,2,3,3,3
        dc.b    4,4,4,5,5,5,5,5,5,4,4,4
        dc.b    3,3,3,2,2,2,1,1,1
        dc.b    0,0,0,-1,-1,-1,-2,-2,-2
        dc.b    -3,-3,-3,-4,-4,-4,-5,-5
        dc.b    -5,-5,-5,-5,-4,-4,-4,-3
        dc.b    -3,-3,-2,-2,-2,-1,-1,-1
        dc.b    127
sine2   dc.b    0,0,1,1,2,2,3,3,4,4,5,5
        dc.b    5,6,6,6,6,7,7,7,7
        dc.b    -7,-7,-7,-7,-6,-6,-6,-6
        dc.b    -5,-5,-5,-4,-4,-3,-3,-2
        dc.b    -2,-1,-1,0,0
        dc.b    127
sine3   dc.b    0,1,2,5,2,1,0
        dc.b    0,-1,-2,-5,-2,-1,0
        dc.b    127
sine4   dc.b    0,0,1,1,1,2,2,3,3,4,4,5
        dc.b    5,5,6,6,6,7,7,7,7,7
        dc.b    -7,-7,-7,-7,-7
        dc.b    -6,-6,-6,-5,-5
        dc.b    -5,-4,-4,-3,-3
        dc.b    -2,-2,-1,-1,-1,0,0
        dc.b    127
text    dc.b    "                    "
        dc.b    "HELLO! THIS IS THE SPACEWALKER TALKING TO YOU!   "
        dc.b    "THE MEMBERS OF THE BEASTS PROUDLY PRESENT:      "
        dc.b    "INTRO#2 REFURBISHED! WE ARE DOWN THE INTERNET "
        dc.b    "WIRE AND HOPE YOU STILL LIKE THIS OLDIES. "
        dc.b    "WE WRITE 2003.03.01 IMPLEMENTING SOUND "
        dc.b    "ROUTINES AND MUSIC. "
        dc.b    "THE INTRO IS FINISHED AND READY.   "
        dc.b    "EXPECT PORT TO UNIX.  "
        dc.b    "PUNCTUATION CHARS <>!$%&/()=*+'#,.;:-",'"'
        dc.b    "                   WARP!                "
        dc.b    "                    "
        dc.b    0


* flags:
*       0 end of program
*       1 VBL
*       2 background Rainbow
flags   dc.b    0
* scroll vars
count   dc.b    0
velo	dc.b	1
newvelo dc.b    1
	even
letras  incbin  'letras1b.ts'
        even
logo3   incbin  'logo3.ts'
        even
dwarfs	incbin	'dwarfs1.ts'



