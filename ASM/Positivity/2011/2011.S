  opt o+
  
;2011 by baah/positivity+Arm's Tech on december 2010.
;Sound by Dma-Sc/Sector One
;Bugfix by ggn
;The code is meant to be packed with an homebrew LZ77 packer,
;that's why many pieces of code are strangely unrolled.

MAXNBPARTICLES=230

;######## MACROS ########
;IN   \1.w=x
;     \2.w=y
;OUT  \1.w=mask for pixel at (x;y)
;     \2.w=offset to pixel at (x;y)
;     \3.l and \4.w killed
PIXEL MACRO
  lsl.w     #5,\2       ;\2=y*32
  move.w    \2,\3       ;\3=y*32
  add.w     \2,\2       ;faster but bigger than "lsl.w #2,\2"
  add.w     \2,\2
  add.w     \3,\2       ;\2=y*160
  move.w    \1,\4
  moveq.l   #15,\3
  and.w     \3,\4       ;\4=x mod(16)
  sub.w     \4,\1       ;\1=x-x mod(16)
  lsr.w     #1,\1       ;\1=(x-x mod(16))/2
  add.w     \1,\2       ;\2=y*160+(x-x mod(16))/2
  sub.w     \4,\3       ;\3=15-x mod(16)
  eor.w     \1,\1
  bset.l    \3,\1       ;\1=1<<(15x mod(16))
 ENDM  

;IN   \1.l=random number (can be a 
;OUT  \1.l=new random number
;     \2.l killed (old random number)
RANDOM MACRO
  move.l    \1,\2
;  ror.l     #3,\1
  ror.l     #7,\2
  ror.l     #4,\2
  sub.l     \2,\1
 ENDM

;######## CODE ########

;SWITCH TO SUPERVISOR
  clr.l     -(sp)
  move.w    #32,-(sp)
  trap      #1
  addq.l    #2,sp
  lea       OldConfig(pc),a6
;STOP MOUSE  
  dc.w      $a00a
  move.b    #18,$fffffc02.w
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
  move.l    d0,a5
  
  move.l    a5,a0
  move.w    #8000-1,d0
  moveq.l   #0,d1
cls
  move.l    d1,(a0)+
  dbra d0,cls

;SAVE RESOLUTION AND CHANGE IT  
  move.b    $ffff8260.w,(a6)+   ;Resolution
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  move.b    #0,$ffff8260.w      ;Switch to 320*200*4bpp
  
;SAVE MFP DATA
  move.b    $fffffa07.w,(a6)+   ;IERA=Interrupt Enable A
  move.b    $fffffa09.w,(a6)+   ;IERB
  move.b    $fffffa13.w,(a6)+   ;IMRA=Interrupt Mask A
  move.l    $70.w,(a6)+         ;Save Old_VBl
  move.l    $120.w,(a6)+        ;Save Old_HBl (Timer B)

;COPY 60 LINES OF .DOO IMAGE
  move.l    a5,a4
  move.w    #40*60-1,d0
  lea       Image+34,a3
copy_image1
  move.l    (a3)+,(a4)+
  dbra d0,copy_image1
  
;######## MY FIRST ASSEMBLY CODE WAS KINDA LIKE THIS! ########
  move.w    #0,$ffff824c.w
  move.w    #$f,d6
colorcycle2
  move.w    #$ffff,d7
colorcycle
  move.w    d7,$ffff8240.w
  dbra d7,colorcycle
  dbra d6,colorcycle2
  
;COPY FULL .DOO IMAGE
  move.l    a5,a4
  move.w    #8000-1,d0
  lea       Image+34,a3
copy_image
  move.l    (a3)+,(a4)+
  dbra d0,copy_image


;######## SNOW ########
SNOW
  move.l    a5,a6               ;a6=@vram
;PUT PALETTE
  lea       Image+2,a5
  lea       $ffff8240.w,a2
 REPT 8
  move.l    (a5)+,(a2)+
 ENDR
;INIT MUSIC
  jsr       Music
  move.l    #Dumb_VBl,$70.w

;a4=Random number
;a6=@Screen
 lea        NbParticles,a5 ;a5=@NbParticles (1 word, then MaxNbParticles*2 words for coords)
 
OneVBl
VBl_SYNC
  tst.b     VBl_Flag
  beq.s     VBl_SYNC
  move.b  #0,VBl_Flag

;  jsr    Music+8

;  move.w #$343,$ffff8240.w ;!!!

  move.l    a5,a3
  move.w    (a3)+,d0            ;d7=NbParticles
  cmp.w     #MAXNBPARTICLES,d0
  beq.s     DonTIncreaseNbParticles
  addq.w    #1,d0
  move.w    d0,-2(a3)
DonTIncreaseNbParticles  
  
OneSnowflake
  movem.w   (a3),d1-d2      ;d1=x, d2=y
GetRandomDisplacement
  RANDOM    a4,d3
  and.w     #3,d3
  beq.s     GetRandomDisplacement
  subq.w    #2,d3           ;d3=random number in {-1;0;1}
  add.w     d1,d3           ;d3=x+rnd
  bge.s     NewXClipping1
  move.w    #319,d3
NewXClipping1
  cmp.w     #319,d3
  ble.s     NewXClipping2
  moveq.l   #0,d3
NewXClipping2
  move.w    d2,d4
  addq.w    #1,d4           ;d4=y+1
  movem.w   d3-d4,(a3)
  PIXEL     d3,d4,d6,d7     ;d3=mask, d4=offset
  move.w    (a6,d4.w),d7
  or.w      2(a6,d4.w),d7
  and.w     d3,d7           ;Another snowflake or a blocked pixel on (x+r;y+1)
  bne.s     SnowFlakeWonTMove ;... then the snowflake won't move
;Snowflake moves to (x+r;y+1)  
  or.w      d3,(a6,d4.w)    ;Plot snowflake on (x+r;y+1)
  PIXEL     d1,d2,d6,d7
  eor.w     d1,(a6,d2.w)    ;Clear snowflake at (x;y)
  bra NextSnowFlake
  
;Is snowflake blocked, ie pixels (x-1;y+1), (x;y+1) & (x+1;y+1) are blocked?
SnowFlakeWonTMove
  movem.w   d1-d2,(a3)      ;Restore snowflake at position (x;y)
  addq.w    #1,d2
  
  move.w    d1,d3
  subq.w    #1,d3
  bge.s     NewXClipping3
  move.w    #319,d3
NewXClipping3
  move.w    d2,d4           ;d3|d4=(x-1;y+1)
  PIXEL     d3,d4,d6,d7     ;d3=mask, d4=offset
  and.w     2(a6,d4.w),d3
  beq SnowFlakeNotBlocked
  
  move.w    d1,d3
  move.w    d2,d4           ;d3|d4=(x;y+1)
  PIXEL     d3,d4,d6,d7     ;d3=mask, d4=offset
  and.w     2(a6,d4.w),d3
  beq SnowFlakeNotBlocked
  
  move.w    d1,d3
  addq.w    #1,d3
  cmp.w     #319,d3
  ble.s     NewXClipping4
  moveq.l   #0,d3
NewXClipping4
  move.w    d2,d4           ;d3|d4=(x+1;y+1)
  PIXEL     d3,d4,d6,d7     ;d3=mask, d4=offset
  and.w     2(a6,d4.w),d3
  beq.s SnowFlakeNotBlocked
  
SnowFlakeBlocked
  subq.w    #1,d2           ;d1|d2=(x;y)
  PIXEL     d1,d2,d6,d7
  eor.w     d1,(a6,d2.w)    ;clear snowflake
  or.w      d1,2(a6,d2.w)   ;draw blocked snowflake
  
CreateRandomSnowFlake
  RANDOM    a4,d1
  and.w     #511,d1
  cmp.w     #320,d1
  bge.s CreateRandomSnowFlake
  moveq.l   #0,d2
  movem.w   d1-d2,(a3)      ;Save new snowflake
  PIXEL     d1,d2,d6,d7
  or.w      d1,(a6,d2.w)    ;draw snowflake
  
;bitplane 3 to 0  
;0000 empty
;0001 snowflake
;0010 blocked snowflake
;0110 \
;1010  > background
;1110 /
SnowFlakeNotBlocked
NextSnowFlake
  addq.l    #4,a3
  subq.w    #1,d0
 bne OneSnowflake  

;  move.w    #$000,$ffff8240.w ;!!!
  cmpi.b    #$39,$fffffc02.w  ;Wait for any key
 bne OneVBl

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
;RESTORE MOUSE
  move.b    #8,$fffffc02.w
  dc.w      $a009
;RESTORE MFP
  move.b    (a6)+,$fffffa07.w
  move.b    (a6)+,$fffffa09.w
  move.b    (a6)+,$fffffa13.w

  move.l    (a6)+,$70.w
;KILL MUSIC
  jsr       Music+4
;  move.l    #$08080000,$ffff8800.w
;  move.l    #$09090000,$ffff8800.w
;  move.l    #$0a0a0000,$ffff8800.w

  move.l    (a6)+,$120.w
 
;TERMINATE
  clr.w     -(sp)
  trap      #1
  
OldConfig   
  dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  dc.l 0
  dc.w 0
  dc.w 0,0,0
  dc.l 0,0
  

Dumb_VBl
  addq.l  #$1,$466.w  ; Increase _frclock.
  move.b  #1,VBl_Flag
  jsr    Music+8
  rte

VBl_Flag
  dc.w    0
  

;######## DATA - LEAVE IN THIS ORDER ########

NbParticles
  dc.w  0    
ParticlesCoords
 REPT MAXNBPARTICLES
  dc.w  160,198
 ENDR

;  dc.w $243 ;0000=0 background
;  dc.w $777 ;0001=1 snowflake
;  dc.w $777 ;0010=2 blocked snowflake 
;  dc.w $777 ;0011=3
;  dc.w $777 ;0100=4
;  dc.w $777 ;0101=5
;  dc.w $000 ;0110=6 text
;  dc.w $777 ;0111=7
;  dc.w $777 ;1000=8
;  dc.w $777 ;1001=9
;  dc.w $111 ;1010=a text
;  dc.w $777 ;1011=b
;  dc.w $777 ;1100=c
;  dc.w $777 ;1101=d
;  dc.w $222 ;1110=e text
;  dc.w $777 ;1111=f

Image: incbin "2011.pi1"
Music: incbin '2011.snd'
    

 
 

  