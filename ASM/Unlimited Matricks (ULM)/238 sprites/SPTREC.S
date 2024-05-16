;  by Gunstick of ULM (c) 2004 and for all eternity...

; switches: 0 = on, 10 = off
def_version equ 10
d0_for_mcp equ 0
mcp_adr equ $00000500
colors	equ	10
calcmus equ	10
fastmus	equ	0
debuggable equ 10
cheatvbl equ 0
vblcheck equ 10   ; needs cheatvbl. exits if vbl exeeded
onlysprites equ 10

bglr equ 10     ; background left right scroll
bgtb equ 10	; background top bottom scroll

;        >PART 'my sync'

;        default 1
;	opt O+,O2-    ; devpac

;        opt X+,D+    ; tuboass
;        output 'E:\PROGRAMS\X.PRG'

        ifeq def_version
;        opt X-,D-
;        default 3
;        output 'E:\PACK\X.BIN'
;        org $00002500
        endc

        text
x:
        ifne def_version
        pea     start(pc)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp

        clr.w   -(sp)
        trap    #1
        endc

start:
        lea     oldcpu(pc),a0
        move.l  sp,(a0)+
        lea     my_stack,sp
        move    sr,(a0)+
        move    #$2700,sr
        move    usp,a1
        move.l  a1,(a0)+

        ifne def_version
        moveq   #$12,d0
        bsr     ikbd_wrt
        moveq   #$1a,d0
        bsr     ikbd_wrt

        move.l  $00000408.w,old_408
        move.l  #exit_with_408,$00000408.w
        endc

        bsr     get_st_type
        bsr     get_mfp_type

        bsr.s   save_system


        bsr     video_init
	ifne	debuggable
        bsr     vect_mfp_init
	endc
        bsr     sound_init

        bra     screen
back:
        lea     my_stack,sp

        bsr     sound_init

        bsr     restore_system

        bsr     video_init2

	ifeq	calcmus
 illegal
	endc

        ifne def_version
        moveq   #$14,d0
        bsr     ikbd_wrt
        moveq   #$08,d0
        bsr     ikbd_wrt
        endc

        lea     oldcpu(pc),a0
        movea.l (a0)+,sp
        move    (a0)+,sr
        movea.l (a0)+,a1
        move    a1,usp

        ifne def_version
        move.l  old_408(pc),$00000408.w
        rts
        endc

        ifeq def_version
        moveq   #d0_for_mcp,d0
        jsr     mcp_adr.w
        endc

save_system:
        lea     oldpsg(pc),a0
        moveq   #15,d0
save_psg_loop:
        move.b  d0,$ffff8800.w
        move.b  $ffff8800.w,(a0)+
        dbra    d0,save_psg_loop

        lea     oldvideo(pc),a0
        move.b  $ffff8260.w,(a0)+
        move.b  $ffff820a.w,(a0)+
        move.l  $ffff8200.w,(a0)+

        tst.w   st_type
        beq.s   save_system_no_ste

        move.b  $ffff8209.w,(a0)+
        move.b  $ffff820d.w,(a0)+
        move.b  $ffff820f.w,(a0)+
        move.b  $ffff8265.w,(a0)+

save_system_no_ste:
        movem.l $ffff8240.w,d0-d7
        movem.l d0-d7,(a0)

        lea     oldvectors(pc),a0
        move.l  $00000068.w,(a0)+
        move.l  $00000070.w,(a0)+
        move.l  $00000114.w,(a0)+
        move.l  $00000118.w,(a0)+
        move.l  $00000120.w,(a0)+
        move.l  $00000134.w,(a0)+

        lea     oldmfp(pc),a0
        move.b  $fffffa07.w,(a0)+
        move.b  $fffffa09.w,(a0)+
        move.b  $fffffa13.w,(a0)+
        move.b  $fffffa15.w,(a0)+
        move.b  $fffffa17.w,(a0)+
        move.b  $fffffa19.w,(a0)+
        move.b  $fffffa1b.w,(a0)+
        move.b  $fffffa1d.w,(a0)+

        rts

restore_system:
        lea     oldmfp(pc),a0
        move.b  (a0)+,$fffffa07.w
        move.b  (a0)+,$fffffa09.w
        move.b  (a0)+,$fffffa13.w
        move.b  (a0)+,$fffffa15.w
        move.b  (a0)+,$fffffa17.w
        move.b  (a0)+,$fffffa19.w
        move.b  (a0)+,$fffffa1b.w
        move.b  (a0)+,$fffffa1d.w

        lea     oldvectors(pc),a0
        move.l  (a0)+,$00000068.w
        move.l  (a0)+,$00000070.w
        move.l  (a0)+,$00000114.w
        move.l  (a0)+,$00000118.w
        move.l  (a0)+,$00000120.w
        move.l  (a0)+,$00000134.w

        lea     oldvideo(pc),a0
        move.b  (a0)+,$ffff8260.w
        move.b  (a0)+,$ffff820a.w
        move.l  (a0)+,$ffff8200.w

        tst.w   st_type
        beq.s   restore_system_no_ste

        move.b  (a0)+,$ffff8209.w
        move.b  (a0)+,$ffff820d.w
        move.b  (a0)+,$ffff820f.w
        move.b  (a0)+,$ffff8265.w

restore_system_no_ste:
        movem.l (a0),d0-d7
        movem.l d0-d7,$ffff8240.w
        lea     oldpsg(pc),a0
        moveq   #15,d0
restore_psg_loop:
        move.b  d0,$ffff8800.w
        move.b  (a0)+,$ffff8802.w
        dbra    d0,restore_psg_loop

        rts

video_init:
        movem.l black(pc),d0-d7
        movem.l d0-d7,$ffff8240.w

        bsr     waitvbl
        move.b  #0,$ffff8260.w
        move.b  #2,$ffff820a.w

        tst.w   st_type
        beq.s   videoinit_no_ste
        clr.b   $ffff8209.w
        clr.b   $ffff820d.w
        clr.b   $ffff820f.w
        clr.b   $ffff8265.w
videoinit_no_ste:

        rts

video_init2:
        move.b  #2,$ffff820a.w
        bsr     waitvbl
        move.b  #0,$ffff820a.w
        bsr     waitvbl
        move.b  #2,$ffff820a.w
        bsr     waitvbl
        rts

sound_init:
        moveq   #10,d0
        lea     $ffff8800.w,a0
nextinit:
        move.b  d0,(a0)
        move.b  #0,2(a0)
        dbra    d0,nextinit
        move.b  #7,(a0)
        move.b  #$7f,2(a0)
        move.b  #14,(a0)
        move.b  #$26,2(a0)

        tst.w   st_type
        beq.s   sound_init_no_ste

        clr.w   $ffff8900.w

        move.w  #$07ff,$ffff8924.w
        move.w  #%0000010011101000,$ffff8922.w ;set volume
        move.w  #%0000010101010100,$ffff8922.w ;set left channel volume
        move.w  #%0000010100010100,$ffff8922.w ;set right channel volume
        move.w  #%0000010010000110,$ffff8922.w ;set treble
        move.w  #%0000010001000110,$ffff8922.w ;set bass
        move.w  #%0000010000000001,$ffff8922.w ;set mix GI sound chip output

sound_init_no_ste:
        rts

vect_mfp_init:
        move.l  #nix,$00000068.w
        move.l  #nix,$00000070.w
        move.l  #nix,$00000114.w
        move.l  #nix,$00000118.w
        move.l  #nix,$00000120.w
        move.l  #nix,$00000134.w

        bclr    #3,$fffffa17.w
        clr.b   $fffffa07.w
        clr.b   $fffffa09.w

        rts

waitvbl:
        movem.l d0-d1/a0,-(sp)
        lea     $ffff8209.w,a0
        movep.w -8(a0),d0
waitvblx1:
        tst.b   (a0)
        beq.s   waitvblx1
waitvblx2:
        tst.b   (a0)
        bne.s   waitvblx2
        movep.w -4(a0),d1
        cmp.w   d0,d1
        bne.s   waitvblx2
        movem.l (sp)+,d0-d1/a0
        rts

ikbd_wrt:
        lea     $fffffc00.w,a0
ik_wait:
        move.b  (a0),d1
        btst    #1,d1
        beq.s   ik_wait
        move.b  d0,2(a0)
        rts

get_mfp_type:
        move.b  #0,$fffffa19.w
        move.b  #255,$fffffa1f.w
        move.b  #1,$fffffa19.w

        moveq   #-1,d0
mfp_test_loop:
        dbra    d0,mfp_test_loop

        moveq   #0,d0
        move.b  $fffffa1f.w,d0
        move.b  #0,$fffffa19.w
        cmp.w   #$009b,d0
        ble.s   mfp_of_my_st
        move.w  #-1,mfp_type
mfp_of_my_st:
        rts

get_st_type:
        clr.w   st_type
        move.l  sp,gst_sp
        move.l  $00000008.w,gst_bussi
        move.l  #gst_bussibus,$00000008.w
        tst.w   $ffff8900
        move.w  #-$0001,st_type
gst_bussibus:
gst_sp  equ *+2
        lea     0,sp
gst_bussi equ *+2
        move.l  #0,$00000008.w
        rts

        ifne def_version
        dc.l 'XBRA'
        dc.l 'TFSY'
old_408:
        dc.l 0
exit_with_408:
        bsr.s   exit
        movea.l old_408(pc),a0
        jmp     (a0)
        endc

exit:
        clr.b   $ffff8207.w
        clr.b   $ffff8209.w
        move    #$2700,sr

        movem.l black(pc),d0-d7
        movem.l d0-d7,$ffff8240.w

        bra     back

load_file:
        move    sr,-(sp)
        move    #$2700,sr

        moveq   #15,d0
save_psg_loop_lf:
        move.b  d0,$ffff8800.w
        move.b  $ffff8800.w,-(sp)
        dbra    d0,save_psg_loop_lf

        lea     $fffffa00.w,a1
        movep.w $0007(a1),d0
        move.w  d0,-(sp)
        movep.l $0013(a1),d0
        move.l  d0,-(sp)
        movep.w $001b(a1),d0
        move.w  d0,-(sp)

        move.l  $00000068.w,-(sp)
        move.l  $00000070.w,-(sp)
        move.l  $00000114.w,-(sp)
        move.l  $00000118.w,-(sp)
        move.l  $00000120.w,-(sp)
        move.l  $00000134.w,-(sp)

        lea     oldpsg(pc),a0
        moveq   #15,d0
restore_psg_loop_lf:
        move.b  d0,$ffff8800.w
        move.b  (a0)+,$ffff8802.w
        dbra    d0,restore_psg_loop_lf

        lea     oldmfp(pc),a0
        move.b  (a0)+,$fffffa07.w
        move.b  (a0)+,$fffffa09.w
        move.b  (a0)+,$fffffa13.w
        move.b  (a0)+,$fffffa15.w
        move.b  (a0)+,$fffffa17.w
        move.b  (a0)+,$fffffa19.w
        move.b  (a0)+,$fffffa1b.w
        move.b  (a0)+,$fffffa1d.w

        lea     oldvectors(pc),a0
        move.l  (a0)+,$00000068.w
        move.l  (a0)+,$00000070.w
        move.l  (a0)+,$00000114.w
          move.l  (a0)+,$00000118.w
        move.l  (a0)+,$00000120.w
        move.l  (a0)+,$00000134.w

        move    #$2300,sr

        clr.w   -(sp)
        pea     (a5)
        move.w  #$003d,-(sp)
        trap    #1
        addq.l  #8,sp

        tst.w   d0
        bmi     exit

        move.w  d0,d7

        pea     (a6)
        move.l  #500000,-(sp)
        move.w  d7,-(sp)
        move.w  #$003f,-(sp)
        trap    #1
        lea     $000c(sp),sp

        move.w  d7,-(sp)
        move.w  #$003e,-(sp)
        trap    #1
        addq.l  #4,sp

        move    #$2700,sr

        move.l  (sp)+,$00000134.w
        move.l  (sp)+,$00000120.w
        move.l  (sp)+,$00000118.w
        move.l  (sp)+,$00000114.w
        move.l  (sp)+,$00000070.w
        move.l  (sp)+,$00000068.w

        lea     $fffffa00.w,a1
        move.w  (sp)+,d0
        movep.w d0,$001b(a1)
        move.l  (sp)+,d0
        movep.l d0,$0013(a1)
        move.w  (sp)+,d0
        movep.w d0,$0007(a1)

        moveq   #15,d0
restore_psg_loop_lf_:
        move.b  d0,$ffff8800.w
        move.b  (sp)+,$ffff8802.w
        dbra    d0,restore_psg_loop_lf_

        move    (sp)+,sr

        rts

nix:
        rte

oldcpu: ds.w 4
oldvideo:ds.w 21
oldpsg: ds.b 16
oldvectors:ds.l 6
oldmfp: ds.w 5
mfp_type:ds.w 1
st_type:ds.w 1
black:  ds.l 16

;        endpart

;        PART 'prepare'

screen:
	ifne fastmus
	moveq #1,d0
	jsr music
	endc
        lea     bss_start,a0
        lea     bss_end,a1
        movem.l black(pc),d1-d7/a2-a6
clear_loop:
        movem.l d1-d7/a2-a6,(a0)
        movem.l d1-d7/a2-a6,12*4(a0)
        movem.l d1-d7/a2-a6,24*4(a0)
        lea     36*4(a0),a0
        cmpa.l  a0,a1
        bpl.s   clear_loop

        move.l  #screenmem,d0
        add.l   #255,d0
        and.l   #$00ffff00,d0
        move.l  d0,screenad
        ror.l   #8,d0
        lea     $ffff8201.w,a0
        movep.w d0,0(a0)

        lea     my_stack,sp
        bsr     waitvbl
        movem.l pal,d0-d7
        movem.l d0-d7,$ffff8240.w


   ifeq colors
   move.l screenad,a0
   not.w 80(a0)
   add.l #32000,a0
   not.w 80+8(a0)
   add.l #32000,a0
   not.w 80+16(a0)
   add.l #32000,a0
   not.w 80+24(a0)
   endc
       
; screenad: long 00hh00mm   -> ffff8200
;                  hh  -> ffff8201
;		   mm  -> ffff8203

        move.l screenad,d0
	add.l #32000,d0
	move.l d0,drawad+8
	move.l d0,scrolldraw+4
	moveq #0,d2
	bsr	mkbg
	bsr	logshift
        lsr.w   #8,d0
        move.l d0,screenad+4

        move.l screenad,d0
	add.l #2*32000,d0
	move.l d0,drawad+12
	move.l d0,scrolldraw+8
	moveq #8,d2
	bsr	mkbg
	bsr	logshift
        lsr.w   #8,d0
        move.l d0,screenad+8

        move.l screenad,d0
	add.l #3*32000,d0
	move.l d0,drawad
	move.l d0,scrolldraw+12
	moveq #16,d2
	bsr	mkbg
	bsr	logshift
        lsr.w   #8,d0
        move.l d0,screenad+12

        move.l screenad,d0
	move.l d0,drawad+4
	move.l d0,scrolldraw.w
	moveq #24,d2
	bsr	mkbg
	bsr	logshift
        lsr.w   #8,d0
	move.l d0,screenad

	
	move.b #1,screencounter.w
	ifeq fastmus
	move.l	#musbuff,musptr.w
	endc
	move.l #scrolltext,scrollptr.w
	move.l #font+32*6,curfontpos.w   ;space
	clr.l	scrollbuff.w
	clr.l	4+scrollbuff.w
	clr.l	8+scrollbuff.w
	clr.l	12+scrollbuff.w
	clr.l	16+scrollbuff.w
        bsr     waitvbl

	bra mkraster

mkbg:
	lea background,a6
	move.w	#180,d3 ; screen hight
	move.l	d0,a5	; destination
	move.l	a6,a4	;source
	addq	#4,a5
	moveq #5,d5   ; 6 logo lines
	ifeq bgtb
	moveq #17+13,d6
	sub.w d2,d6
	lsl #2,d2
	lea (a6,d2),a4	
	bra.s	logcol1
	endc
logoloop:
	move.l	a6,a4	;source
	moveq #17+13,d6  ; logo is 18 high
logcol1:
	moveq #9,d7	; 10 logos per line
logline1:
	move.l	(a4),(a5)
	move.l	4(a4),8(a5)
	add.l	#16,a5
	dbra d7,logline1
	sub.w #1,d3
	ble.s endlogloop
	addq.l	#8,a4
	dbra d6,logcol1
	add.l  #3*160,a5
	dbra d5,logoloop
endlogloop:
	rts

logshift:
	ifeq bglr
	lea background,a6
	moveq #17,d6
logshiftl:
	move.w  (a6),d3
	swap d3
	move.w	4(a6),d3
	rol.l #8,d3
	move.w d3,4(a6)
	swap d3
	move.w d3,(a6)
	move.w  2(a6),d3
	swap d3
	move.w	6(a6),d3
	rol.l #8,d3
	move.w d3,6(a6)
	swap d3
	move.w d3,2(a6)
	addq.l #8,a6
	dbra d6,logshiftl
	endc
	rts

mkraster:

	ifne debuggable
        move.b  #%00000000,$fffffa1b.w ;B stop
        move.b  #199,$fffffa21.w ;B data   bottom of sprite area
        move.b  #%00001000,$fffffa1b.w ;B eventmode
	or.b    #%00000001,$fffffa07.w ;B enable irq
	or.b    #%00000001,$fffffa13.w ;B unmask irq
        move.b  #194,$fffffa21.w ;B data   
        move.l  #raster_i,$00000120.w
        move    #$2500,sr
	endc


       lea spritecode,a6
;        endpart

;        PART 'main loop'





loop:
        
        cmpi.b  #57,$fffffc02.w
        beq     exit
;       movem.l d0-d7/a0-a6,-(sp)
;       jsr music+8
;       movem.l (sp)+,d0-d7/a0-a6
	ifeq colors
       move.w  #$070,$ffff8240.w
	endc

no_key:
;       movem.l d0-d7/a0-a6,-(sp)

;        lea     $ffff8209.w,a0
	ifeq colors
       move.w  #$070,$ffff8240.w
	endc
;        move.b  $ffff8209.w,d7














;       move.l a6,-(sp)
;       jsr music+8
;       move.l (sp)+,a6
	ifeq colors
       move.w  #$007,$ffff8240.w
	endc

;put musics here, don't change 
wait_end_of_video:
;        move.b  $ffff8209.w,d7
;        dcb 97-7-7-4-4,$00004e71
;        cmp.b   $ffff8209.w,d7   ; the incredible wobbly border detector
        tst.b  screencounter.w
	ifne debuggable
        bgt.s  wait_end_of_video
	endc
;        bne   end_of_video
;        move.w #10,d0
;vidwloop:
;        dbf d0,vidwloop
;        move.b  $ffff8209.w,d7
;        bra.s wait_end_of_video
end_of_video:
	addq.b #1,screencounter.w
	ifeq colors
       move.w  #$004,$ffff8240.w
	endc


        move.l drawad.w,d0     ; load non displaying
        move.l 4+drawad.w,drawad.w ; swap
        move.l 8+drawad.w,4+drawad.w ; swap
        move.l 12+drawad.w,8+drawad.w ; swap
        move.l d0,12+drawad.w

        movea.l d0,a0
    
        tst.w (a6)
        bge.s  notwaveend
        lea spritecode,a6
notwaveend:
	ifeq colors
        move.w  #$0707,$ffff8240.w
	endc

        bsr     drawallsprt

        bra.s     loop



raster_i:
;        move.b  #%00000000,$fffffa1b.w ;B stop
        move.b  #6,$fffffa21.w ;B data   bottom of sprite area
;        move.b  #%00001000,$fffffa1b.w ;B eventmode
;	or.b    #%00000001,$fffffa07.w ;B enable irq
;	or.b    #%00000001,$fffffa13.w ;B unmask irq
	move.l #raster,$120.w
	ifeq onlysprites
	rte
	endc
	movem.l	d0-d7/a0-a6,-(sp)


; yes we have a raster here, just do some crap so we
; fall into lower border to finally change palette



;  MUSIC
	 ifeq calcmus

	moveq #0,d0
	move.b $fffffa1d.w,d0
	and.w #$000f,d0
	beq.s sid

	move.w #$000,$ffff8240.w
	bra.s notsid
sid:
	move.w #$0077,$ffff8240.w
notsid:



	 move.l	musicsave,a0
	 lea ymregisters,a1
	 moveq #0,d2   ; which regs change
	 move.l a0,a2  ;save curr pointer for writing bitfield
 ;	 addq.l #2,a0
	  addq.l #1,a0

	 ; special r13 treatment
	 move.b #13,$ffff8800.w
	 move.b $ffff8800.w,d1
	 cmp.b #%0011,d1      ; no 'ULM' value, then it's gotten written to
	 beq.s ymr13notmod
 ;	 or.w #%100,d2
	 or.b #%1,d2
	 move.b d1,(a0)+  ;write r13
	add.w #1,2*13-26(a1)
ymr13notmod:

	 moveq #12,d3   ; remaining regs r0-r12
	  moveq #6,d4   ; remaining regs r6-r12
;	 moveq #-1,d3

ym_readloop:
;	 addq #1,d3
 ;	 add.w d2,d2  ; shift left
	  add.b d2,d2  ; shift left
	 move.b d3,$ffff8800.w
	 move.b $ffff8800.w,d1
	 cmp.b (a1,d3),d1
	 beq.s ymnotmod   ; modified
 ;	 or.w #%100,d2      ; set bit if mod
	 or.b #%1,d2      ; set bit if mod
	 move.b d1,(a0)+  ; only write this reg
	add.w	d3,d3
	add.w #1,-26(a1,d3)
	lsr.w #1,d3
ymnotmod:
	 move.b d1,(a1,d3)
	 subq #1,d3
 ;	dbra d3,ym_readloop
	  dbra d4,ym_readloop
 ;	 move.b d2,1(a2)   ; save bitfield, bit15=reg13, bit2=reg0, bit0&1 unused
	  move.b d2,(a2)   ; save bitfield, bit7=reg13, bit0=reg6

	  moveq #0,d2   ; which regs change
	  move.l a0,a2  ;save curr pointer for writing bitfield
	  addq.l #1,a0
	  moveq #5,d3   ; remaining regs r5-r0

ym_readloop2:
	  add.b d2,d2  ; shift left
	  move.b d3,$ffff8800.w
	  move.b $ffff8800.w,d1
	  cmp.b (a1,d3),d1
	  beq.s ymnotmod2   ; modified
	  or.w #%100,d2      ; set bit if mod
	  move.b d1,(a0)+  ; only write this reg
	add.w	d3,d3
	add.w #1,-26(a1,d3)
	lsr.w #1,d3
ymnotmod2:
	  move.b d1,(a1,d3)
	  dbra d3,ym_readloop2
	  move.b d2,(a2)   ; save bitfield, bit7=reg5, bit2=reg0


 ;	 lsr #8,d2
 ;	 move.b d2,(a2)
	 move.l	a0,musicsave

	move.b #13,$ffff8800.w      ; init r13 with
	move.b #%0011,$ffff8802.w   ; unusual 'ULM' value
	endc

	ifne fastmus
        jsr music+8
	endc
; 	andi.b #$f0,$fffffa1d.w

	ifeq fastmus
	lea $ffff8800.w,a1
	lea 2(a1),a2
	move.l musptr.w,a0

	move.b (a0)+,d2
	beq.s ymend8bit
	moveq #13,d3
playmus:
	add.b d2,d2  ; shift 1 -> carry
	bcc.s noymchange
	move.b d3,(a1)
	move.b (a0)+,(a2)
	tst.b d2
noymchange:
	dbeq d3,playmus   ; end loop if no more regs (1 bits)
ymend8bit:
	 move.b (a0)+,d2
	 beq.s ymend6bit
 	 moveq #5,d3
playmus2:
	 add.b d2,d2  ; shift 1 -> carry
	 bcc.s noymchange2
	 move.b d3,(a1)
	 move.b (a0)+,(a2)
	 tst.b d2
noymchange2:
	 dbeq d3,playmus2
	beq.s ymend6bit
; future extension: if d2 != 0 read another bitfield for SID&Ddrum
; e.g: d2!=0, but next bitfield=0 => loop music
; so end of music is: dc.b 0,1,0
 	 lea musbuff,a0
ymend6bit:
	move.l a0,musptr.w
	endc




	ifeq 0

; scroller....
	ifeq colors
        move.w  #$0770,$ffff8240.w
	endc

	move.w	scrollcount,d0
	addq.w	#1,d0
	andi.w	#%1111,d0   
	move.w	d0,scrollcount

	subq.w #1,d0
	andi.w	#%1111,d0   
	bne	   noscroll

	lea	scrolldraw.w,a6

	rept	4	; 4 screens
	move.l	(a6)+,a5          ;                 3
	adda.l	#160*194+8,a5 ; down there          3.5

; move 5 lines 8 bytes to left
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 2-7        31
	movem.l	d0-d7/a0-a4,-60(a5)   ; cols 0-5    31
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 8-13       31
	movem.l	d0-d7/a0-a4,-60(a5) ; cols 6-11     31
	movem.l	(a5)+,d0-d7/a0-a3 ; cols 14-19      29
	movem.l	d0-d7/a0-a3,-56(a5)  ; cols 12-17.5 29
	addq	#8,a5                      ;         2 = 184
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 2-7        31
	movem.l	d0-d7/a0-a4,-60(a5)   ; cols 0-5    31
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 8-13       31
	movem.l	d0-d7/a0-a4,-60(a5) ; cols 6-11     31
	movem.l	(a5)+,d0-d7/a0-a3 ; cols 14-19      29
	movem.l	d0-d7/a0-a3,-56(a5)  ; cols 12-17.5 29
	addq	#8,a5                    ;           2 = 184
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 2-7
	movem.l	d0-d7/a0-a4,-60(a5)   ; cols 0-5
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 8-13
	movem.l	d0-d7/a0-a4,-60(a5) ; cols 6-11
	movem.l	(a5)+,d0-d7/a0-a3 ; cols 14-19
	movem.l	d0-d7/a0-a3,-56(a5)  ; cols 12-17.5
	addq	#8,a5                      ;              184
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 2-7
	movem.l	d0-d7/a0-a4,-60(a5)   ; cols 0-5
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 8-13
	movem.l	d0-d7/a0-a4,-60(a5) ; cols 6-11
	movem.l	(a5)+,d0-d7/a0-a3 ; cols 14-19
	movem.l	d0-d7/a0-a3,-56(a5)  ; cols 12-17.5
	addq	#8,a5                    ;                184
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 2-7
	movem.l	d0-d7/a0-a4,-60(a5)   ; cols 0-5
	movem.l	(a5)+,d0-d7/a0-a4 ; cols 8-13
	movem.l	d0-d7/a0-a4,-60(a5) ; cols 6-11
	movem.l	(a5)+,d0-d7/a0-a3 ; cols 14-19
	movem.l	d0-d7/a0-a3,-56(a5)  ; cols 12-17.5       182
	endr

	ifeq colors
	not.w	$ffff8240.w
	endc

	ifeq 0    
; create new scroll data
; we need to create 16 shifts of 1 bit
 
	move.l	curfontpos.w,a0	;get pos inside font   ~4
	move.l	scrollptr.w,a1  ;                      ~4

	movem.w	scrollbuff.w,d3-d7	; get scrolldata ~9

	lea	   scrolldraw.w,a5      ;              ~2
	moveq.w #3,d0   ; 4 screens                    ~1
	moveq.w #15,d2  ;                              ~1
	swap d2                ;                       ~1
	move.w	#160*194+152,d2	; scrollpos on screen  ~2
	swap d2         ;                              ~1
do16shifts:
	move.b	(a0)+,d1  ;get one slice of letter  ~2
	; extract 5 top bits for 5 lines scroll
	add.b	d1,d1
	addx.w	d3,d3
	add.b	d1,d1
	addx.w	d4,d4
	add.b	d1,d1
	addx.w	d5,d5
	add.b	d1,d1
	addx.w	d6,d6
	add.b	d1,d1
	addx.w	d7,d7
	add.b	d1,d1                        ; ~11
	beq.s	nonextchar   ; bit below font set=end of char ~3
nextchar:
	moveq #0,d1                     ;        (~1)
	move.b	(a1)+,d1	; get next char  (~2)
	bne.s	noscrolltextend	;end of text     (~3)
scrolltextend:
	move.l	#scrolltext,a1                  ; (~3)
	move.b	(a1)+,d1	; get ascii val   (~2)
noscrolltextend:

	; calculate charaddr
;	muls.w	#6,d1	;each char is 6 bytes
	add.w	d1,d1
	move.l	#font,a0
	add.w	d1,a0
	add.w	d1,d1
	add.w	d1,a0   ; new char         (~7)


nonextchar:
	; write the data for each shift
	move.l	(a5)+,a2   ;get drawad    ~2
	swap	d2
	adda.w	d2,a2
	move.w	d3,(a2)
	move.w	d4,160(a2)
	move.w	d5,160*2(a2)
	move.w	d6,160*3(a2)
	move.w	d7,160*4(a2)   ; ~16
	dbra d0,nodrawadloop   ; ~3
drawadloop:
	lea	scrolldraw.w,a5
	addq.w	#2,d2		; next columns
	moveq #3,d0	; 4 screens again
nodrawadloop:

	swap d2
	dbra	d2,do16shifts

	move.l	a0,curfontpos.w
	move.l	a1,scrollptr.w
	movem.w	d3-d7,scrollbuff.w	; save scrolldata

	endc
noscroll:


	ifeq colors
        move.w  #$000,$ffff8240.w
	endc


; main Palette setting

	movem.l	pal,d0-d7
	movem.l d0-d7,$ffff8240.w


	endc


	movem.l	(sp)+,d0-d7/a0-a6

	rte




raster:
	ifeq colors
	move.w #$700,$ffff8240.w
	endc

	movem.l	a0/a1,-(sp)

; cycle screens

	ifeq cheatvbl
	cmp.b #-1,screencounter.w
	beq.s	bof
noboff:
	endc
	subq.b #1,screencounter.w

        move.l screenad.w,a0
	move.l	a0,$ffff8200.w     ; set new screen addr
        move.l 4+screenad.w,screenad.w ; swap
        move.l 8+screenad.w,4+screenad.w ; swap
        move.l 12+screenad.w,8+screenad.w ; swap
        move.l a0,12+screenad.w

	ifne onlysprites
	move.l	scrollpalanimpos,a0
	move.l	(a0)+,a1
	cmpa.l	#scrollpalanimend,a0
	bne.s	notpalanimend
	lea	scrollpalanim,a0
notpalanimend:
	move.l	a0,scrollpalanimpos
	lea $ffff8240.w,a0
	rept 8
	move.l	(a1)+,(a0)+
	endr
	endc

boff:

        move.b  #194,$fffffa21.w ;B data
	move.l #raster_i,$120.w

	movem.l (sp)+,a0/a1

	ifeq colors
	move.w #$070,$ffff8240.w
	move.w #$0,$ffff8240.w
	endc

	rte
	ifeq cheatvbl
bof:
	cmp.w	#0,scrollcount
	bne.s noboff
	subq.w	#1,scrollcount

	ifne onlysprites
	move.l	scrollpalanimpos,a0
	move.l	(a0),a1
	lea	scrollpalanim,a0
	lea $ffff8240.w,a0
	rept 8
	move.l	(a1)+,(a0)+
	endr
	endc

	ifeq	vblcheck
	bra exit
	endc

	bra.s boff
	endc

drawallsprt:
        include 'CBLESPRT.S'

;        endpart

        data

;        PART 'data'
spritecode:
	incbin 'cblesprt.bin'
pal:
        dc.w $0000,$0003,$0337,$0005,$0444,$0003,$0337,$0005
        dc.w $0222,$0003,$0337,$0005,$0777,$0003,$0337,$0005
	ifeq colors
scrollpal0:
	dc.w 0,0,0,0,0,0,0,0
	dc.w $777,$777,$777,$777,$777,$777,$777,$777
scrollpal1:
	dc.w 0,0,0,0,$700,$700,$700,$700
	dc.w 0,0,0,0,$700,$700,$700,$700
scrollpal2:
	dc.w 0,0,$70,$70,0,0,$70,$70
	dc.w 0,0,$70,$70,0,0,$70,$70
scrollpal3:
	dc.w 0,$77,0,$77,0,$77,0,$77
	dc.w 0,$77,0,$77,0,$77,0,$77
	endc
	ifne colors
sc equ $077
scrollpal0:
	dc.w 0,0,0,0,0,0,0,0
	dc.w sc,sc,sc,sc,sc,sc,sc,sc
scrollpal1:
	dc.w 0,0,0,0,sc,sc,sc,sc
	dc.w 0,0,0,0,sc,sc,sc,sc
scrollpal2:
	dc.w 0,0,sc,sc,0,0,sc,sc
	dc.w 0,0,sc,sc,0,0,sc,sc
scrollpal3:
	dc.w 0,sc,0,sc,0,sc,0,sc
	dc.w 0,sc,0,sc,0,sc,0,sc
	endc
scrollpalanim:
	dc.l	scrollpal3,scrollpal3,scrollpal3,scrollpal3
	dc.l	scrollpal2,scrollpal2,scrollpal2,scrollpal2
	dc.l	scrollpal1,scrollpal1,scrollpal1,scrollpal1
	dc.l	scrollpal0,scrollpal0,scrollpal0,scrollpal0
scrollpalanimend:
scrollpalanimpos:
	dc.l	scrollpalanim+12+16*3

scrollcount:
	dc.w -1
scrolltext:
	incbin 'scroll.txt'
	dc.b 0
	even
background:
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFE,$FFFF
	dc.w	$FFFF,$FFFF,$FFFC,$FFFF
	dc.w	$FFFF,$E000,$FFF8,$0007
	dc.w	$FFFF,$E000,$FFF8,$0007
	dc.w	$FFFF,$E336,$FFF8,$18C7
	dc.w	$FF76,$E3BF,$FFD8,$1DE7
	dc.w	$FF76,$E3BF,$FFD8,$1FE7
	dc.w	$FF76,$E3BF,$FAD8,$1FE7
	dc.w	$FF76,$E3BF,$FAD8,$1DE7
	dc.w	$FFF7,$E3FF,$FBD8,$DCE7
	dc.w	$FFE7,$E1FF,$DBD8,$FCE7
	dc.w	$FF0C,$E0F3,$1318,$ECE7
	dc.w	$FFFF,$E000,$FFF8,$0007
	dc.w	$E000,$FFFF,$0000,$FFFF
	dc.w	$C000,$FFFF,$0000,$FFFF
	dc.w	$8000,$FFFF,$0000,$FFFF
	dc.w	$8000,$FFFF,$0000,$FFFF
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0

font	equ *-6*32+113     ; pbm without header, 6*32=offset ascii space
	incbin "FONT5RM.PBM"
        dc.l $ffffffff

	ifne fastmus
music:
	incbin 'E:\MUSIX\TFMX\MAD_VIS.BIN'
;	incbin 'E:\MUSIX\LAP\LAP27.BIN'
;	incbin 'E:\MUSIX\SNDH\SNDH.SF\ATARI.I-P\MADMAX\1.BIN'
	even
	endc

	ifeq fastmus
musbuff:
;	incbin 'ALL.YMX'
;	incbin 'LAP27.YMX'
;	incbin 'MUSIC.BIN'
	incbin 'SOS_N.BIN'
;	dc.b 0,1,0
	even
musbuffend:
	even
	dc.l 0
	endc

	ifeq calcmus
musicsave:
	dc.l	musbuff
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0
ymregisters:
	dcb.b 14,-1
	endc
;        endpart

        bss

bss_start:                      ;here starts the bss

;        PART 'bss'
screenad equ $200		; 4 long, use "unused TOS area"
;	ds.l 4
drawad equ $200+16	; 4 long
;	ds.l 4
screencounter equ $200+32
;	ds.w 1
musptr	equ $200+32+2
;	ds.l 1
scrolldraw equ $200+32+2+4
;	ds.l 4
scrollbuff equ $200+32+2+4+16
;	ds.l 5
scrollptr equ $200+32+2+4+16+20
;	dc.l scrolltext
curfontpos equ $200+32+2+4+16+20+4
;	dc.l font+32*6   ;space

	ifeq calcmus
musbuff:
	ds.b 14*50*60*3
	endc

screenmem:ds.l 64
        ds.l 8000
        ds.l 8000
        ds.l 8000
        ds.l 8000
        ds.l 100
my_stack:

;        endpart

bss_end:                        ;here ends the bss
        end
 
