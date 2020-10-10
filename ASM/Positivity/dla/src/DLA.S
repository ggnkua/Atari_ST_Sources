;DLA - Diffusion Limited Agregation
;baah/Arm's Tech on april/may 2009
;The code is meant to be packed with an homebrew LZ77 packer,
;that's why many pieces of code are strangely unrolled.
   opt o+
BOOTLAUNCHER
  clr.l     -(sp)               ;Switch to supervisor
  move.w    #32,-(sp)
  trap      #1
  addq.l    #2,sp
  lea       OldConfig(pc),a6
  move.b    $ffff8260.w,(a6)+   ;Resolution
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  move.b    #0,$ffff8260.w      ;Switch to 320*200*4bpp
  move.w    #3,-(sp)            ;Get LogBase in d0.l 
  trap      #14
  addq.l    #2,sp
  dc.w      $a00a               ;Stop mouse
  move.b    #18,$fffffc02.w
  move.l    d0,a0               ;Clear screen
  moveq.l   #0,d0
  move.l    #8000,d1
cls
  move.l    d0,(a0)+
 dbra d1,cls

  jsr       BOOT                ;Execute boot code
  
  move.b    #8,$fffffc02.w      ;Restore mouse
  dc.w      $a009
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  lea       OldConfig(pc),a6
  move.b    (a6)+,$ffff8260.w   ;Resolution
  clr.w     -(sp)               ;Terminate program
  trap      #1
OldConfig   
  dc.b "boot"

;baAhBaAhbaaHBAAHbaahbAaHBaahbAAhbAAHBaAHBAaHbaaHbAaHbaahBAAH
;BaahbaAhBAahbaAHbaAHBAaHBAAhBaahBaAhBaahbAAHBAahbaaHbAAhbaaH
;BaaHBAAhBAAHbAahbAaHbAahbaAHBAAhbaahBaAHbaahBAahBAAHbAAHBaAh

;######## MACROS ########
;IN   \1.w=x
;     \2.w=y
;OUT  \1.w=mask for pixel at (x;y)
;     \2.w=offset to pixel at (x;y)
;     \3.l and \4.w killed
PIXEL MACRO
  lsl.w     #5,\2       ;\2=y*32
  move.w    \2,\3       ;\3=y*32
  lsl.w     #2,\2       ;\2=y*128, slower but smaller than add.l \2,\2:add.l \2,\2
  add.w     \3,\2       ;\2=y*160
  move.w    \1,\4
  moveq.l   #15,\3
  and.w     \3,\4       ;\4=x mod(16)
  sub.w     \4,\1       ;\1=x-x mod(16)
  lsr.w     #1,\1       ;\1=(x-x mod(16))/2
  add.w     \1,\2       ;\2=y*160+(x-x mod(16))/2
  sub.w     \4,\3       ;\3=15-x mod(16)
  eor.w     \1,\1
  bset.l    \3,\1       ;\1=1<<(x mod(16))
 ENDM  

;IN   \1.l=random number
;OUT  \1.l=new random number
;     \2.l killed
RANDOM MACRO
  move.l    \1,\2
  ror.l     #7,\1
  ror.l     #4,\1
  sub.l     \2,\1
 ENDM

;######## BOOT SECTOR ########
;For the whole bootsector we have d7=RandomNb, a5=@Data+??? and a6=@videoram
BOOT
  clr.b     $484.w              ;Stop key bip, key repeat
  pea       Text(pc)            ;Draw text
  move.w    #9,-(sp)
  trap      #1
  addq.l    #6,sp
  move.l    $44e.l,a6           ;a6=@vram
  lea       Data(pc),a5         ;a5=@Data
  move.l    (a5),d7             ;Random number
;######## INIT SOUND ########  
  lea       $ffff8801.w,a0      ;??? also works if $ffff8800.w
 REPT 7
  move.w    (a5)+,d0
  movep.w   d0,0(a0)
 ENDR
;######## DRAW LOGO ########
  move.l    a6,a4
  add.w     #160*130+2*8,a4     ;a4=@start of logo in vram
  move.w    #160,d0
  moveq.l   #-1,d1
  moveq.l   #4,d2               ;5 lines
DrawLogoLine
  move.l    (a5)+,d4
  move.w    #15,d3              ;16*2 bits
DrawLogoBit
  add.l     d4,d4
  bcc.s     DrawLogoNext
  move.l    a4,a3
 REPT 7
  move.b    d1,(a3)
  move.b    d1,2(a3)
  add.w     d0,a3
 ENDR
  move.b    d1,(a3)
  move.b    d1,2(a3)
DrawLogoNext
  addq.l    #1,a4
  add.l     d4,d4
  bcc.s     DrawLogoNext2
  move.l    a4,a3
 REPT 7
  move.b    d1,(a3)
  move.b    d1,2(a3)
  add.w     d0,a3
 ENDR
  move.b    d1,(a3)
  move.b    d1,2(a3)
DrawLogoNext2
  addq.l    #7,a4
  dbra      d3,DrawLogoBit
  add.w     #160*7+4*8,a4
  dbra      d2,DrawLogoLine
  
  bsr       SwapColors        ;Put colors
  
  

;######## DIFFUSED LIMITED AGREGATION ########
  move.w    #129,a4           ;a4=miny (filled with 0s)
OneParticle
  move.l    a4,d6             ;d6=y=miny
  move.w    #320,a2
ParticleChooseX
  RANDOM    d7,d2
  move.l    d7,d5
  and.w     #511,d5           ;d5 randomly chosen in [0;511]
  cmp.w     a2,d5
  bge.s     ParticleChooseX   ;d5=x in [0;319]
ParticleFalling
  move.l    d6,d4
  addq.l    #1,d4             ;d4=y+1
  cmp.w     #200,d4           ;Bottom of screen reached?
  beq.s     ParticleDraw      ;Then draw
;  moveq.l   #3,d1
ParticleChooseDir
  RANDOM    d7,d2
  move.l    d7,d2
  andi.w    #3,d2             ;d2 randomly chosen in [0;3]
  beq.s     ParticleChooseDir ;d2 in [1;3]
  subq.l    #2,d2             ;d2=dir in [-1;1]
  move.w    d5,d3
  add.w     d2,d3             ;d3=x+dir
  bge.s     ParticleClipX     ;x+dir<0?
  add.w     a2,d3             ;then add 320
ParticleClipX
  cmp.w     a2,d3             
  blt.s     ParticleClipX2    ;x+dir>=320?
  sub.w     a2,d3             ;then sub 320
ParticleClipX2
  PIXEL d3,d4,d0,d1           ;d3=mask, d4=adress
  move.w    (a6,d4.w),d4
  and.w     d3,d4             ;pixel(x+dir;y+1) is set?
  bne.s     ParticleDraw      ;Then draw
  add.w     d2,d5             ;d5=x+dir
  addq.l    #1,d6             ;d6=y+1
  bra.s     ParticleFalling
ParticleDraw
  cmp.w     a4,d6             ;y=miny?
  bne       ParticleMinyOk
  subq.l    #1,a4             ;Then miny=y-1
  cmp.w     #0,a4             ;!!!??? The subq before doesn't actualise Z flag
  bne       ParticleMinyOk
;Top of the screen reached, so let's scroll!  
;For the scrolling, i copy the lines from bitplane 0 to bitplane 2
;(or vice-versa) then after a VSYNC i set colors to show bitplane 2.
;Then we change a6=@vram with an xor to point to good bitplane.
ParticleScroll
  addq.l    #1,a4             ;miny increases
  addq.l    #1,d6             ;And also y
  move.l    a6,a3             ;a3=@src
  move.l    a6,d3
  eori.b    #4,d3
  move.l    d3,a6             ;a6=new @vram with other bitplane
  move.l    a6,a2
  adda.w    #160,a2           ;a2=@dest (one line down)
  move.w    #198,d3           ;copy 199 lines
ParticleScrollLine
 REPT 20
  move.w    (a3)+,(a2)+
  addq.l    #6,a2
  addq.l    #6,a3
 ENDR
  dbra      d3,ParticleScrollLine
  move.w    #37,-(sp)         ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp
  lea       $ffff8242.w,a2    ;Swap colors 001 & 100
  lea       $ffff8248.w,a3
  move.w    (a2),d0
  move.w    (a3),(a2)
  move.w    d0,(a3)
  addq.l    #4,a2             ;Then colors 011 & 110
  addq.l    #4,a3
  move.w    (a2),d0
  move.w    (a3),(a2)
  move.w    d0,(a3)
  
ParticleMinyOk
  move.w    d5,d3
  move.w    d6,d4
  PIXEL d3,d4,d0,d1           ;d3=mask, d4=adress
  or.w      d3,(a6,d4.w)      ;Draw pixel
  cmpi.b    #$39,$fffffc02.w  ;Wait for any key
  bne       OneParticle

;######## END OF BOOTSECTOR ########
  lea       $ffff8801.w,a0    ;??? also works if $ffff8800.w
  move.w    #$0900,d0         ;canal B amplitude to 0
  movep.w   d0,0(a0)
SwapColors 
  lea     $ffff8240.w,a0
 REPT 8
  move.l  (a0),32(a5)
  move.l  (a5)+,(a0)+
 ENDR
  rts

;######## DATA ########
Data
;This wonderfull sound by cyclone/x-troll
SoundData  
  dc.w $02ee ;canal B period, mid and lower nibble
  dc.w $030e ;canal B period, upper nibble
  dc.w $0910 ;canal B amplitude from enveloppe
  dc.w $0bef ;enveloppe period, lower byte
  dc.w $0c00 ;enveloppe period, upper byte
  dc.w $0d0c ;enveloppe style $0c=/|/|/|, $0e=/\/\/\
  dc.w $07fd ;settings: canal B on (ie bit 2 set to 0), all the rest off
;32*7 pixels baah logo 
;  dc.l %01100000000000000000000001100000
;  dc.l %01101110001111110011111101101110
;  dc.l %01110011011000110110001101110011
;  dc.l %01100011011000110110001101100011
;  dc.l %01100011011001110110011101100110
;  dc.l %00111110001110110011101101100111
;32*5 pixels outline logo 
LogoData
  dc.l %01100100101111101000111011100111
  dc.l %10010100100010001000010010010100
  dc.l %10010100100010001000010010010110
  dc.l %10010100100010001000010010010100
  dc.l %01100011000010001110111010010111
;Only 8 colors will be changed
ColorData
  dc.w $777 ;000
  dc.w $252 ;001
  dc.w $444 ;010
  dc.w $131 ;011
  dc.w $777 ;100
  dc.w $252 ;101
  dc.w $444 ;110
  dc.w $131 ;111
 REPT 8
  dc.w 0    ;black
 ENDR
Text
 REPT 23
  dc.b    $d,$a
 ENDR
  ;     1234567890123456789012345678901234567890
  dc.b "     cODe by bAAh, sOUND bY CYClOne",$0
   
  dc.b "boot"