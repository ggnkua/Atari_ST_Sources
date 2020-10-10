  opt o+
;Quadratic splines by baah/positivity+Arm's Tech on march 2010.
;Sound by Cyclone/X-Troll
;The code is meant to be packed with an homebrew LZ77 packer,
;that's why many pieces of code are strangely unrolled.
;I first used two screens, but we must RESTORE the screen after
;the boot.
BOOTLAUNCHER
;SWITCH TO SUPERVISOR
  clr.l     -(sp)
  move.w    #32,-(sp)
  trap      #1
  addq.l    #2,sp
  lea       OldConfig(pc),a6
;SAVE PALETTE
  lea       $ffff8240.w,a0
  moveq.w   #16-1,d0
BL_SaveOneColor  
  move.w    (a0)+,(a6)+
 dbra d0,BL_SaveOneColor 
;SAVE @VRAM AND CLEAR SCREEN  
  move.w    #3,-(sp)            ;Get LogBase in d0.l 
  trap      #14
  addq.l    #2,sp
  move.l    d0,(a6)+
  move.l    d0,a0
  moveq.l   #0,d0
  move.w    #8000-1,d1
cls
  move.l    d0,(a0)+
 dbra d1,cls
;SAVE RESOLUTION AND CHANGE IT  
  move.b    $ffff8260.w,(a6)+   ;Resolution
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  move.b    #0,$ffff8260.w      ;Switch to 320*200*4bpp
;STOP MOUSE  
  dc.w      $a00a
  move.b    #18,$fffffc02.w

  jsr       BOOT                ;Execute boot code
  
;RESTORE MOUSE
  move.b    #8,$fffffc02.w
  dc.w      $a009
;RESTORE PALETTE
  lea       OldConfig(pc),a6
  lea       $ffff8240.w,a0
  moveq.w   #16-1,d0
BL_RestoreOneColor  
  move.w    (a6)+,(a0)+
 dbra d0,BL_RestoreOneColor 
;RESTORE RESOLUTION AND @VRAM  
  move.l    (a6)+,d0
  lsr.w     #8,d0               ;Set video shifter
  move.b    d0,$ffff8203.w
  swap.w    d0
  move.b    d0,$ffff8201.w
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  move.b    (a6)+,$ffff8260.w   ;Resolution
;TERMINATE
  clr.w     -(sp)
  trap      #1
  
OldConfig   
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  dc.l 0
  dc.w 0
  
  dc.b "boot" ;for extraction of the bootsector
;BOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOTBOOT

;######## MACROS ########

;Computes mask+offset for pixel (x;y). Please note that (0;0) is the
;upper right corner of the screen, ie @vram+160-8 with mask=1.
;Maybe it can be faster with a table for x too?
;IN   \1.w=x
;     \2.w=y
;     \4.w=15
;     \5.l=adress of Y offset tables (160-8, then +160 each line)
;OUT  \1.w=mask for pixel at (x;y)
;     \2.w=offset to pixel at (x;y)
;     \3.w killed
PIXEL MACRO
;  lsl.w     #5,\2       ;\2=y*32
;  move.w    \2,\3       ;\3=y*32
;  add.w     \2,\2       ;faster but bigger than "lsl.w #2,\2"
;  add.w     \2,\2
;  add.w     \3,\2       ;\2=y*160
  add.w     \2,\2
  move.w    (\5,\2.w),\2
  move.w    \1,\3
  and.w     \4,\3       ;\3=x mod(16)
  sub.w     \3,\1       ;\1=x-x mod(16)
  lsr.w     #1,\1       ;\1=(x-x mod(16))/2
  sub.w     \1,\2       ;\2=y*160-(x-x mod(16))/2 (from right to left)
  eor.w     \1,\1
  bset.l    \3,\1       ;\1=1<<(x mod(16))
 ENDM  

;Computes coefs for a Quadratic Spline with 2^N+1 points.
;IN   \1.l=m0
;     \2.l=m1
;     \3.l=m2
;OUT  \2.l=inc1
;     \3.l=inc2
;\2 & \3 must be data register
COEFS7 MACRO
  sub.l     \1,\2
  add.l     \2,\2   ;\2=b=2*(m1-m0)
  sub.l     \1,\3
  sub.l     \2,\3   ;\3=a=m2-2*m1
  lsl.l     #16-2*7,\3 ;smaller than  "add.l \3,\3"+"add.l \3,\3"
  lsl.l     #8,\2   ;incorrect is "lsl.l #16-7,\2"
  add.l     \2,\2
  add.l     \3,\2   ;\2=inc1=b<<(16-N)+a<<(16-2N)
  add.l     \3,\3   ;\3=inc2=2*a<<(16-2N)
 ENDM
 
;Used for drawing logo
DRAWBLOCK MACRO
  add.w     d4,d4
  dc.w      $6420 ;bcc.s DrawLogoNext 
  move.l    a4,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
  add.w     d0,a3
  move.b    d1,(a3)
;DrawLogoNext  
 ENDM 
  
NBPOINTS=6
;######## BOOT SECTOR ########
BOOT
;  clr.b     $484.w              ;Stop key bip, key repeat

  move.l    $44e.l,a6           ;a6=@vram  
  lea       ColorData(pc),a5    ;a5=@data
;## PUT PALETTE ##
  lea       $ffff8240.w,a2
 REPT 4
  move.l    (a5)+,(a2)+
 ENDR
;## INIT SOUND ##
  lea       $ffff8801.w,a0      ;??? also works if $ffff8800.w
 REPT 7
  move.w    (a5)+,d0
  movep.w   d0,0(a0)
 ENDR
  move.w    (a5)+,d0            ;d0=160
;## DRAW OUTLINE LOGO ##
  move.l    a6,a4
  add.w     #160*84+48+4,a4     ;a4=@start of logo in vram
  moveq.l   #-1,d1
;1st line
  move.w    (a5)+,d4
 REPT 7
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+96+7,a4
;2nd line
  move.w    (a5)+,d4
 REPT 7
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+96+7,a4
;3rd line
  move.w    (a5)+,d4
 REPT 7
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+96+7,a4
;4th line
  move.w    (a5)+,d4
 REPT 7
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
;  add.w     #160*7+96+7,a4
  
;## CREATE Y OFFSETS TABLE, here a5=@YOffsetsTable, d0=160 ##
  move.l    a5,a3
;  move.w    d0,d1       ;d0=d1=160
  subq.l    #8,d0       ;d0=160-8
 REPT 199
  move.w    d0,(a3)+
  add.w     #160,d0
 ENDR
  move.w    d0,(a3)+
  
;######## QUADRATIC SPLINES ########
;a3=@AdressesTable
;a4=@ClearingRoutine
;a5=@YOffsetsTable, and -2(a5) used as LOOPCOUNTER
;a6=@WorkScreen (ie @Screen +0 or +2)
OneVBl
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
;!!!  move.w #$575,$ffff8240.w ;!!!
;SWAP COLORS 001 & 010, 101 & 110 
  lea       $ffff8244.w,a2
  move.l    a2,a1
  move.w    -(a1),d0
  move.w    (a2),(a1)
  move.w    d0,(a2)
  addq.l    #8,a2
  move.l    a2,a1
  move.w    -(a1),d0
  move.w    (a2),(a1)
  move.w    d0,(a2)
;Compute @Screen and @ClearRoutine
  lea       ClearingRoutines(pc),a4
  move.l    a6,d0
  bchg.l    #1,d0
  beq.s     PreviousWorkscreenWasBPL0
  add.w     #128*NBPOINTS*4+2,a4
PreviousWorkscreenWasBPL0
  move.l    d0,a6
;CLEAR PERVIOUS POINTS
  moveq.l   #0,d0
  jsr       (a4)
;COMPUTE COORDS OF SPLINES
  lea       PointsIncrements(pc),a1
  move.l    a1,a0
 REPT NBPOINTS+2
  move.w    -4(a0),d0         ;d0=B (ie xB or yB)
  move.w    (a1)+,d1          ;d1=dB
  add.w     d1,d0             ;d0=B+dB
  dc.w      $6d06 ;blt.s negate
  cmp.w     #319,d0           ;!!! 199 too to decrease size
  dc.w      $6d08 ;blt.s nonegate
;negate  
  neg.w     d1                ;negate dB
  add.      d1,d0             ;restore B
  move.w    d1,-2(a1)
;nonegate
  add.w     d0,d2             ;d2=A+B
  lsr.w     #1,d2             ;d2=(A+B)/2
  movem.w   d0/d2,-(a0)       ;save B and (A+B)/2
  move.w    d0,d2             ;replace A by B
 ENDR
 REPT NBPOINTS+2
  move.w    -4(a0),d0         ;d0=B (ie xB or yB)
  move.w    (a1)+,d1          ;d1=dB
  add.w     d1,d0             ;d0=B+dB
  dc.w      $6d06 ;blt.s negate
  cmp.w     #199,d0
  dc.w      $6d08 ;blt.s nonegate
;negate  
  neg.w     d1                ;negate dB
  add.      d1,d0             ;restore B
  move.w    d1,-2(a1)
;nonegate
  add.w     d0,d2             ;d2=A+B
  lsr.w     #1,d2             ;d2=(A+B)/2
  movem.w   d0/d2,-(a0)       ;save B and (A+B)/2
  move.w    d0,d2             ;replace A by B
 ENDR
 
;DRAW SPLINES (not the last pixel)
  lea       PointsCoords+2(pc),a2
  move.w    #NBPOINTS,-2(a5)  ;-2(a5)=LOOPCOUNTER
LOOP
  movem.w   (a2),d1/d3/d5     ;load y0,y1,y2
  add.w     #2*2*(NBPOINTS+2),a2
  movem.w   (a2),d0/d2/d4     ;load x0,x1,x2
  sub.w     #2*2*(NBPOINTS+2)-4,a2
  
  COEFS7 d0,d2,d4 ;compute d2=inc1x, d4=inc2x
  swap.w    d0
  move.l    d4,a0
  COEFS7 d1,d3,d5 ;compute d3=inc1y, d5=inc2y
  swap.w    d1
  move.l    d5,a1
  
  moveq.l   #15,d5
 REPT 128-1
  move.l    d0,d6
  swap.w    d6        ;d6=x1
  move.l    d1,d7
  swap.w    d7        ;d7=y1
  PIXEL d6,d7,d4,d5,a5
  or.w      d6,(a6,d7.w)
  addq.l    #2,a4
  move.w    d7,(a4)+
  add.l     d2,d0 ;x+=inc1x
  add.l     d3,d1 ;y+=inc1y
  add.l     a0,d2 ;inc1x+=inc2x
  add.l     a1,d3 ;inc1y+=inc2y
 ENDR
  move.l    d0,d6
  swap.w    d6        ;d6=x1
  move.l    d1,d7
  swap.w    d7        ;d7=y1
  PIXEL d6,d7,d4,d5,a5
  or.w      d6,(a6,d7.w)
  addq.l    #2,a4
  move.w    d7,(a4)+
  
  subq.w    #1,-2(a5)
  bne       LOOP
;!!!  move.w    #$777,$ffff8240.w ;!!!
  cmpi.b    #$39,$fffffc02.w  ;Wait for any key
 bne OneVBl

;######## END OF BOOTSECTOR ########
  lea       $ffff8801.w,a0    ;??? also works if $ffff8800.w
  move.w    #$0900,d0         ;canal B amplitude to 0
  movep.w   d0,0(a0)
;Palette is restored by system...  
  rts

;A multiplier par le nombre d'ecrans  
ClearingRoutines
 REPT 128*NBPOINTS
  dc.w $3d40,$3d40    ;"move.w d0,$3d40(a6)" the second word being the offset
 ENDR
  rts
 REPT 128*NBPOINTS
  dc.w $3d40,$3d40
 ENDR
  rts
   
;######## DATA - LEAVE IN THIS ORDER ########
;In reversed order due to "movem d?/d?,-(a?)"
;y2,(y1+y2)/2,y1,(yN+y1)/2,yN, ...  ,y3,(y2+y3)/2,y2,(y1+y2)/2,y1,junk=(x2+y1)/2
;x2,(x1+x2)/2,x1,(xN+x1)/2,xN, ...  ,x3,(x2+x3)/2,x2,(x1+x2)/2,x1,junk= (?+x1)/2

;4*(NBPOINTS+2)
PointsCoords
  dc.w 4,5
  dc.w 1,2,3,4,5
  dc.w 1,2,3,4,5
  dc.w 1,2,3,4,5
  dc.w 1,2,3,4,5
  dc.w 1,2,3,4,5
  dc.w 1,2,3,4,5
; REPT 2*(NBPOINTS+2)
;  dc.w 1
; ENDR
; REPT 2*(NBPOINTS+2)
;  dc.w 1
; ENDR

;dx1,dx2, ... ,dxN,dx1,dx2
;dy1,dy2, ... ,dyN,dy1,dy2
PointsIncrements
  dc.w  1,2, 3,4, 5,1, 2,3
  dc.w  4,5, 1,2, 3,4, 5,1
 
;Only 8 colors will be changed
ColorData
  dc.w $fff ;0000
  dc.w $fff ;0001
  dc.w $333 ;0010
  dc.w $333 ;0011
  dc.w $252 ;0100
  dc.w $252 ;0101
  dc.w $010 ;0110
  dc.w $010 ;0111
;This wonderfull sound by cyclone/x-troll
SoundData  
  dc.w $02ee ;canal B period, mid and lower nibble
  dc.w $030e ;canal B period, upper nibble
  dc.w $0910 ;canal B amplitude from enveloppe
  dc.w $0bef ;enveloppe period, lower byte
  dc.w $0c00 ;enveloppe period, upper byte
  dc.w $0d0c ;enveloppe style $0c=/|/|/|, $0e=/\/\/\
  dc.w $07fd ;settings: canal B on (ie bit 2 set to 0), all the rest off 
  
  dc.w  160
;16*4 pixels baah logo 
LogoData
 dc.w %0100000000000100 ;baah logo
 dc.w %0110001100110110
 dc.w %0101010101010101
 dc.w %0111011101110101
    
YOffsetsTable
; REPT 200
;  dc.w 0
; ENDR

  dc.b "boot" ;for extraction of the bootsector
  