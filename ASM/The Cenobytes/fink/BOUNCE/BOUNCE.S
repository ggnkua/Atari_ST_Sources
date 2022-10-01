*************************************
*    BOUNCE ROUTINE BY -THE FINK-   *
*************************************



x:
	clr.l   -(sp)
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	move.l  d0,ssp

	dc.w	$a00a                     ;mouse off

	move.w  #4,-(sp)
	trap    #14
	addq.l  #2,sp
	move.w  d0,oldres

	clr.w   -(sp)                   ;low-res
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #5,-(sp)
	trap    #14
	lea     12(sp),sp


		

	move.l  $44e.w,screen           ;get video address
	movem.l $ffff8240.w,d0-d7       ;old palette
	movem.l d0-d7,oldpal            ;save it
	
	bsr     fillscreen              ;build up background pattern
	movem.l pal1(pc),d0-d7          ;1st palette
	movem.l d0-d7,$ffff8240.w       ;set

***************
	
read	move.l	#block1,a0
	add.l	#34,a0
	lea	buffer,a1
	moveq	#52,d0
*	move.l	#160,d1
lot	
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	20(a0),(a1)+
	move.l	24(a0),(a1)+
	move.l	28(a0),(a1)+
	move.l	32(a0),(a1)+
	move.l	36(a0),(a1)+
	move.l	40(a0),(a1)+
	move.l	44(a0),(a1)+
	move.l	48(a0),(a1)+
	move.l	52(a0),(a1)+
	move.l	56(a0),(a1)+
	move.l	60(a0),(a1)+
*	move.l	64(a0),(a1)+
	add.l	#160,a0
	dbf	d0,lot
	

**************************
	move.l  #dtab,dpos              ;initialise something
	move.l  screen(pc),clrzeiger

	move.l  #dobbs,$4d2.w           ;move transparent block
	bsr     keys
	clr.l   $4d2.w

	move.w  oldres(pc),-(sp)
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #5,-(sp)
	trap    #14
	lea     12(sp),sp

	movem.l oldpal(pc),d0-d7        ;old palette
	movem.l d0-d7,$ffff8240.w       ;set again
	dc.w   $a009                     ;mouse on

	move.l  ssp(pc),-(sp)
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp

	clr.w   -(sp)                   ;or terminate
	trap    #1

;------------------------------------------------
fillscreen:
	movem.l graphic(pc),d6-d7       ;these are data for 16 pixels
                                ;background is built from that
	move.l  screen(pc),a0
	add.l	#8000,a0
	moveq   #100-1,d1               ;fill 100*2 lines

alles:
	moveq   #20-1,d0                ;20*16 pixels = one line
zeile1:
	move.l  d6,(a0)+
	move.l  d7,(a0)+
	dbf     d0,zeile1

	moveq   #10-1,d0                ;fill every second column
zeile2:
	move.l  d6,(a0)+
	move.l  d7,(a0)+
	addq.l  #8,a0
	dbf     d0,zeile2

	dbf     d1,alles
	rts

graphic:
	dc.w    $55AA,$33CC,$0FF0,$0000 ;<--- last plane is empty!!

;------------------------------------------------
dobbs:
	move.l  clrzeiger(pc),a1        ;previous position
	moveq   #0,d7                   ;clear
	bsr     block

	clr.l   d2
	move.l  dpos(pc),a2             ;pointer on table
	move.w  (a2)+,d2                ;get value
	tst.w   (a2)
	bpl     w_dobbs                 ;negative? End of table
	lea     dtab(pc),a2             ;start anew

w_dobbs:
	move.l  a2,dpos
	mulu    #160,d2                 ;I know it can be done faster but
                                ;that isn't the point here

	move.l  screen(pc),a1
	add.l   d2,a1
	add.w   #48,a1                  ;block starts from pixel 96
	move.l  a1,clrzeiger            ;save value for next vbl

	moveq	#52,d0
	move.l	#buffer,a2
fink	move.l	(a2)+,(a1)
	move.l	(a2)+,4(a1)
	move.l	(a2)+,8(a1)
	move.l	(a2)+,12(a1)
	move.l	(a2)+,16(a1)
	move.l	(a2)+,20(a1)
	move.l	(a2)+,24(a1)
	move.l	(a2)+,28(a1)
	move.l	(a2)+,32(a1)
	move.l	(a2)+,36(a1)
	move.l	(a2)+,40(a1)
	move.l	(a2)+,44(a1)
	move.l	(a2)+,48(a1)
	move.l	(a2)+,52(a1)
	move.l	(a2)+,56(a1)
	move.l	(a2)+,60(a1)
*	move.l	(a2)+,64(a1)
	add.l	#160,a1
	dbf	d0,fink
	
*	moveq   #-1,d7                  ;fill it this time
*	bsr     block
	rts

;---------------------
block:
	moveq   #52,d0                  ;number of lines (historical reasons!)
	move.l  #160,d1                 ;
fill_zeilen:
	move.l	d7,(a1)
	move.l	d7,4(a1)
	move.l  d7,8(a1)                ;each time, only the last plane
	move.l	d7,12(a1)
	move.l  d7,16(a1)               ;is changed
	move.l	d7,20(a1)
	move.l  d7,24(a1)
	move.l	d7,28(a1)
	move.l  d7,32(a1)
	move.l	d7,36(a1)
	move.l  d7,40(a1)
	move.l	d7,44(a1)
	move.l  d7,48(a1)
	move.l	d7,52(a1)
	move.l  d7,56(a1)
	move.l	d7,60(a1)
*	move.l  d7,64(a1)               ;(at a width of 8*16 pixels)
	add.l   d1,a1
	dbf     d0,fill_zeilen
	rts

;------------------------------------------------
keys:
	move.w  #7,-(sp)                ;conin
	trap    #1
	addq.l  #2,sp

	cmp.b   #"0",d0                 ;between 0 and 4
	blt     keys
	cmp.b   #"4",d0
	bgt     keys

	cmp.b   #"0",d0
	beq     exit
	ext.w   d0
	sub.w   #$31,d0                 ;"1" is now 0
	add.w   d0,d0
	add.w   d0,d0

	move.l  colors(pc,d0.w),a0      ;get pointer to pal1-4
	movem.l (a0),d0-d7
	movem.l d0-d7,$ffff8240.w       ;and set them
	bra     keys

exit:
	rts

;------------------------------------------------
colors: dc.l pal1,pal2,pal3,pal4

pal1:
	dc.w    $000,$111,$222,$333,$444,$555,$666,$777
	dc.w    $772,$772,$772,$772,$772,$772,$772,$772
pal2:
	dc.w    $000,$111,$222,$333,$444,$555,$666,$777
	dc.w    $772,$111,$222,$333,$444,$555,$666,$777
pal3:
	dc.w    $000,$111,$222,$333,$444,$555,$666,$777
	dc.w    $772,$772,$772,$772,$444,$555,$666,$777
pal4:
	dc.w    $000,$111,$222,$333,$444,$555,$666,$777
	dc.w    $400,$600,$720,$730,$740,$750,$760,$772

screen:         dc.l 0
ssp:            dc.l 0
oldres:         dc.w 0
oldpal:         ds.w 16

clrzeiger:      dc.l 0
dpos:           dc.l 0

dtab:
 dc.w 46,51,56,61,66    ;End with -1!
 dc.w 72,78,84,78,72
 dc.w 66,61,56,51,46
 dc.w 41,37,33,30,26
 dc.w 23,20,17,15,13
 dc.w 11,09,08,07,06
 dc.w 05,05,05,05,05
 dc.w 06,07,08,09,11
 dc.w 13,15,17,20,23
 dc.w 26,30,33,37,41
 dc.w 46,51,56,61,66
 dc.w 72,78,84,78,72
 dc.w 66,61,56,51,46
 dc.w 42,38,34,31,27
 dc.w 24,22,19,17,16
 dc.w 15,15,15,15,16
 dc.w 17,19,22,24,27
 dc.w 30,34,38,41,45
 dc.w 49,53,56,60,63
 dc.w 66,68,71,72,73
 dc.w 74,74,74,74,72
 dc.w 71,69,66,63,60
 dc.w 57,53,50,46,42
 dc.w 38,34,31,28,25
 dc.w 22,20,18,16,15
 dc.w 15,15,15,16,17
 dc.w 19,21,24,27,30
 dc.w 34,37,41
 dc.w -1        ;end byte: Don't forget


block1	incbin	"\bounce\block.pi1"
block2	dc.l	block1+34
buffer	dc.l	9*53*4
	