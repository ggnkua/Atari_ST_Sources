; rasters
;
; create some nice rasters
; ST NEWS 4.3
; A Digital Insanity creation

                clr.l   -(sp)		supervisor mode on
                move.w  #$20,-(sp)
                trap    #1
                move.l  d0,savereg
                move.l  #$70000,a7

                move.l  #moff,-(sp)	mouse off
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $a00a

                move.w  #4,-(sp)	get resolution        
                trap    #14
                addq.l  #2,sp
                move.w  d0,oldrez
                move.l  $44e,oldscr
                move.l  #$70000,screen

                movem.l $ffff8240.w,d0-d7	set colors
                movem.l d0-d7,oldpal

                bsr     prepare		put some graphics on screen
                bsr     hblon		enable interrupts

                move.w  #1,-(sp)	wait for a key
                trap    #1
                addq.l  #2,sp

                bsr     hbloff		disable interrupts

                movem.l oldpal,d0-d7	old colors back
                movem.l d0-d7,$ffff8240.w
                move.w  oldrez,-(sp)	old resolution back
                move.l  oldscr,-(sp)
                move.l  oldscr,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                move.l  #mon,-(sp)	mouse on
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $a009

                move.l  savereg,-(sp)	leave supervisor
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

                clr.w   -(sp)		sayonara!
                trap    #1

oldrez:         dc.w    0
oldscr:         dc.l    0
savereg:        dc.l    0
screen:         dc.l    0
oldpal:         ds.w    16
mon:            dc.b    $08
moff:           dc.b    $12

                even

; see the article for comments about these addresses
hblon:          move.l  $120,oldtb
                move.l  $70,old4
                move.l  $70,new4b+2
                move.b  $fffffa07,old07
                move.b  $fffffa09,old09
                move.b  $fffffa0f,old0f
                move.b  $fffffa11,old11
                move.b  $fffffa1b,old1b
                and.b   #$df,$fffa09
                and.b   #$fe,$fffa07 
                move.l  #newtb1,$120
                move.l  #new4,$70
                or.b    #1,$fffffa07
                or.b    #1,$fffffa13
                rts

hbloff:         move.w  sr,-(sp)
                move.w  #$2700,sr
                move.b  old07(pc),$fffffa07
                move.b  old09(pc),$fffffa09
                move.b  old0f(pc),$fffffa0f
                move.b  old11(pc),$fffffa11
                move.b  old1b(pc),$fffffa1b
                move.l  oldtb,$120
                move.l  old4,$70
                move.w  (sp)+,sr
                rts

old4:           dc.l    0
oldtb:          dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old1b:          dc.b    0

                even

; This is the new VBL handler
new4:           clr.b   $fffffa1b.w
                move.b  #40,$fffffa21	; first raster at line 40
                move.b  #8,$fffffa1b
                move.w  #$0,$ff8240	; black screen
                move.l  #newtb1,$120	; Timer B vector
new4b:          jmp     $12345678

newtb1:         clr.b   $fffffa1b.w     ;timer stop
                movem.l d0-d7/a0-a1,-(sp)
                move.w  #$fa21,a1
		move.b	#40,(a1)	; second one at line 80
                move.l  #newtb2,$120
                move.b  #8,$fffffa1b.w

                moveq.w #27,d2	      ; number of colors in table
                move.l  #pal1,a0      ; pal1: color table
loop            move.b  (a1),d0
wait:           cmp.b   (a1),d0	      ; wait one scanline
                beq     wait
                move.w  (a0)+,d1
		move.w	d1,$ff8240    ; set colors
		move.w	d1,$ff8242
		move.w	d1,$ff8244
		move.w	d1,$ff8246
		move.w	d1,$ff8248
		move.w	d1,$ff824a
		move.w	d1,$ff824c
		move.w	d1,$ff824e
                dbra    d2,loop

		movem.l	pal1,d1-d7/a0
loopx		move.b	(a1),d0
waitx		cmp.b	(a1),d0
		beq	waitx
		movem.l	d1-d7/a0,$ff8240
                
                movem.l (sp)+,d0-d7/a0-a1
                bclr    #0,$fffffa0f.w  ;end of interrupt
                rte

newtb2:         clr.b   $fffffa1b.w     ;timer stop
                movem.l d0-d7/a0-a1,-(sp)
                move.w  #$fa21,a1
                move.b  #40,(a1)	; third one at line 120
                move.l  #newtb3,$120
                move.b  #8,$fffffa1b.w

                move.w  #14,d1		; raster is 14 scanlines
                move.l  #pal1,a0
loop2           move.b  (a1),d0
wait2           cmp.b   (a1),d0
                beq     wait2
                move.w  (a0)+,$ff8240
                dbra    d1,loop2

		movem.l	pal1,d1-d7/a0
		move.b	(a1),d0
waity		cmp.b	(a1),d0
		beq	waity
		movem.l	d1-d7/a0,$ff8240
                
                movem.l (sp)+,d0-d7/a0-a1
                bclr    #0,$fffffa0f.w  ;end of interrupt
                rte

newtb3:         clr.b   $fffffa1b.w     ;timer stop
                movem.l d0-d7/a0-a1,-(sp)
                move.w  #$fa21,a1
                move.b  #79,(a1)	; kill border at line 199
                move.l  #killborder,$120
                move.b  #8,$fffffa1b.w

                move.w  #14,d1
                move.l  #pal1+26,a0
loop3           move.b  (a1),d0
wait3           cmp.b   (a1),d0
                beq     wait3
                move.w  (a0)+,$ff8240
                dbra    d1,loop3

		movem.l	pal1,d1-d7/a0
		move.b	(a1),d0
waitz		cmp.b	(a1),d0
		beq	waitz
		movem.l	d1-d7/a0,$ff8240
                
                movem.l (sp)+,d0-d7/a0-a1
                bclr    #0,$fffffa0f.w  ;end of interrupt
                rte

killborder      clr.b   $fffffa1b.w     ;timer stop
                movem.l d0-d1/a0-a1,-(sp)
                move.w  #$fa21,a1
                move.b  #200,(a1)
                move.b  #8,$fffffa1b.w

                move.b  (a1),d0
wait4:          cmp.b   (a1),d0		; wait last scanline
                beq     wait4		
                clr.b   $ffff820a.w     ;60 Hz
                moveq   #4,d0
nopi2:          nop			; wait a while
                dbf     d0,nopi2
                move.b  #2,$ffff820a.w  ;50 Hz
                movem.l (sp)+,d0-d1/a0-a1       
                bclr    #0,$fffffa0f.w  ;end of interrupt
                rte

; now some routines to set the graphics

prepare:        move.w  #0,-(sp)        ;set low res
                move.l  screen(pc),-(sp)
                move.l  screen(pc),-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                movem.l graphic(pc),d6-d7
                move.l  screen(pc),a0
                move.w  #260-1,d1       ;fill 260 scanlines

line:           moveq   #20-1,d0        ;20 planes = one scanline
fill:           move.l  d6,(a0)+
                move.l  d7,(a0)+
                dbf     d0,fill
                dbf     d1,line

                movem.l pal1(pc),d0-d3
                movem.l d0-d3,$ffff8240.w
                rts

graphic:	dc.w    $55AA,$33CC,$0FF0,$0000

pal1:           dc.w    $000,$111,$222,$333,$444,$555,$666,$777
                dc.w    $666,$555,$444,$333,$222,$111
                dc.w    $001,$002,$003,$004,$005,$006,$007
                dc.w    $006,$005,$004,$003,$002,$001,$000
