;RNDCELL - CELLular automaton with RaNDomness
;baah/Arm's Tech on may 2011
;The code is meant to be packed with an homebrew LZ77 packer,
;that's why many pieces of code are strangely unrolled.
;39438 bytes -> 418 bytes
   opt o+
BOOTLAUNCHER
  clr.l     -(sp)               ;Switch to supervisor
  move.w    #32,-(sp)
  trap      #1
  addq.l    #2,sp
  lea       OldConfig(pc),a6
  jsr       SwapColors
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
  jsr       SwapColors
  move.b    (a6)+,$ffff8260.w   ;Resolution
  clr.w     -(sp)               ;Terminate program
  trap      #1
  
  
SwapColors
  lea       $ffff8240.w,a0
 REPT 8
  move.l    (a0),d0
  move.l    (a6),(a0)+
  move.l    d0,(a6)+
 ENDR
  rts
  
OldConfig
  dc.l 0,0,0,0,0,0,0,0
  dc.b "boot"

;baAhBaAhbaaHBAAHbaahbAaHBaahbAAhbAAHBaAHBAaHbaaHbAaHbaahBAAH
;BaahbaAhBAahbaAHbaAHBAaHBAAhBaahBaAhBaahbAAHBAahbaaHbAAhbaaH
;BaaHBAAhBAAHbAahbAaHbAahbaAHBAAhbaahBaAHbaahBAahBAAHbAAHBaAh

;IN   \1.l=random number (can be an adress register)
;OUT  \1.l=new random number
;     \2.l killed (old random number)
RANDOM MACRO
  move.l    \1,\2
  ror.l     #3,\2
;  ror.l     #7,\1
;  ror.l     #4,\1
  sub.l     \2,\1
 ENDM

;Used for drawing logo
DRAWBLOCK MACRO
  add.l     d4,d4
  dc.w      $6420 ;bcc.s DrawLogoNext 
  move.l    a4,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
  add.w     d7,a3
  move.b    d6,(a3)
;DrawLogoNext  
 ENDM 
  

;######## BOOT SECTOR ########
;For the whole bootsector we have ?=RandomNb, a5=@Data+??? and a6=@videoram
BOOT
;  clr.b     $484.w              ;Stop key bip, key repeat
  lea       Data(pc),a5         ;a5=@Data
  move.l    $44e.l,a6           ;a6=@vram

;######## CHANGE COLORS ########
  lea     $ffff8240.w,a0
 REPT 2
  move.l  (a5)+,(a0)+
 ENDR
;######## INIT SOUND ########  
  lea       $ffff8801.w,a0      ;??? also works if $ffff8800.w
 REPT 7
  move.w    (a5)+,d0
  movep.w   d0,0(a0)
 ENDR
 
  movem.w   (a5)+,d6-d7         ;d6=255, d7=160
;######## DRAW LOGO ########
  move.l    a6,a4
  add.w     #160*100+2*8+2,a4   ;a4=@start of logo in vram
;1st line
  move.l    (a5)+,d4
 REPT 15
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+4*8+7,a4
;2nd line
  move.l    (a5)+,d4
 REPT 15
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+4*8+7,a4
;3rd line
  move.l    (a5)+,d4
 REPT 15
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+4*8+7,a4
;4th line
  move.l    (a5)+,d4
 REPT 15
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  add.w     #160*7+4*8+7,a4
;5th line
  move.l    (a5)+,d4
 REPT 15
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK
  addq.l    #7,a4
 ENDR
  DRAWBLOCK
  addq.l    #1,a4
  DRAWBLOCK

;######## RND CELL ########

NbINcrements=10

;  lea    Probas(pc),a5
  move.l    a5,a3               ;a3=RandomNb
  lea       ProbasIncrements(pc),a4
;d6.w=255
;d7.w=160
;a6=@vram
;a5=@probas
;a4=@InterestingProbas
;a3=RandomNb

OneVBl
  move.w    #37,-(sp)           ;Wait Vertical SYNChronisation
  trap      #14
  addq.l    #2,sp

;  move.w    #$444,$ffff8240.w
  
;scroll up one line
  move.l    a6,a0
  move.l    a6,a1
  add.w     d7,a1
 REPT 199*20
  move.w  (a1),(a0)
  addq.l  #8,a1
  addq.l  #8,a0
 ENDR 

;a0=@vram+199*160
;a1=@vram+200*160 

  movem.w   (a5),d0-d4    ;d0=Pointer on ProbasIncrement, d1=NbIter, d2=p1, d3=p2, d4=p3
  subq.w    #1,d1
  beq.s     ChangeIncrement
  add.w     (a4,d0.w),d2  ;p1+=inc1
  add.w     2(a4,d0.w),d3 ;p2+=inc2
  add.w     4(a4,d0.w),d4 ;p3+=inc3
  bra.s     SaveProbasAndGo
  
ChangeIncrement
  move.w    #256,d1
  addq.w    #3*2,d0
  cmp.w     #3*2*NbINcrements,d0
  bne.s     SaveProbasAndGo
  moveq.l   #0,d0
    
SaveProbasAndGo
  movem.w   d0-d4,(a5)
  move.w    d3,12(a5)
  neg.w     d2
  add.w     d6,d2
  move.w    d2,18(a5)  ;1-p1
  neg.w     d3
  add.w     d6,d3
  move.w    d3,10(a5)  ;1-p2
  move.w    d3,16(a5)  ;1-p2
  neg.w     d4
  add.w     d6,d4
  move.w    d4,14(a5)  ;1-p3
DonTChange  

;d6.w=255
;d7.w=160
;a6=@vram
;a5=@Probas
;a4=@InterestingProbas
;a3=RandomNb
;a1=@vram+200*160 
;a0=@vram+199*160

  addq.l    #4,a5               ;a5=@Probas+4 (p1,p2,p3,1-p2,p2,1-p3,1-p2,1-p1)
  sub.w     d7,a1               ;a1=@vram+198*160
  sub.w     d7,a1             
  bsr       RndCell
  subq.l    #4,a5               ;a5=@Probas

;  move.w    #$676,$ffff8240.w
  
  cmpi.b    #$39,$fffffc02.w  ;Wait for any key
  bne       OneVBl
 

;######## END OF BOOTSECTOR ########
  lea       $ffff8801.w,a0    ;??? also works if $ffff8800.w
  move.w    #$0900,d0         ;canal B amplitude to 0
  movep.w   d0,0(a0)
  rts

;######## DATA ########

Data
;Only 4 colors will be changed
ColorData
  dc.w $676 ;000
  dc.w $343 ;001
  dc.w $600 ;010
  dc.w $300 ;011
;This wonderfull sound by cyclone/x-troll
SoundData  
  dc.w $02ee ;canal B period, mid and lower nibble
  dc.w $030e ;canal B period, upper nibble
  dc.w $0910 ;canal B amplitude from enveloppe
  dc.w $0bef ;enveloppe period, lower byte
  dc.w $0c00 ;enveloppe period, upper byte
  dc.w $0d0c ;enveloppe style $0c=/|/|/|, $0e=/\/\/\
  dc.w $07fd ;settings: canal B on (ie bit 2 set to 0), all the rest off
  
  dc.w  255
  dc.w  160
;;16*4 pixels baah logo 
;LogoData
; dc.w %0100000000000100 ;baah logo
; dc.w %0110001100110110
; dc.w %0101010101010101
; dc.w %0111011101110101
;32*5 pixels outline logo 
LogoData
  dc.l %01100100101111101000111011100111
  dc.l %10010100100010001000010010010100
  dc.l %10010100100010001000010010010110
  dc.l %10010100100010001000010010010100
  dc.l %01100011000010001110111010010111

Probas
  dc.w  0           ;Pointer on ProbasIncrement
  dc.w  256         ;NBIter
  dc.w 0  ;... p1  
  dc.w 0  ;..* p2  
  dc.w 0  ;.*. p3  
  dc.w 0  ;.** 1-p2  
  dc.w 0  ;*.. p2  
  dc.w 0  ;*.* 1-p3  
  dc.w 0  ;**. 1-p2  
  dc.w 0  ;*** 1-p1  
  
;NbINcrements set above
ProbasIncrements
  dc.w  1,1,0   ;>110
  dc.w  0,-1,0  ;>100
  dc.w  0,0,1   ;>101
  dc.w  -1,1,0  ;>011
  dc.w  0,-1,0  ;>001
  dc.w  1,1,0   ;>111
  dc.w  -1,0,0  ;>011
  dc.w  1,0,-1  ;>110
  dc.w  0,-1,1  ;>101
  dc.w  -1,0,-1 ;>000
  
  
;****************************************
;****            RNDCELL             ****
;****************************************

;IN   a0.l=@dest
;     a1.l=@src
;     a5=@probas
;     a3=RandomNb
;     d6.w=255=mask for probability
;KILLS d0-d5/a0-a2

RNDCELL MACRO
  add.l     d1,d1               ;bits 19;18;17 are pixels n-1;n;n+1
  move.l    d1,d2
  swap.w    d2
  and.l     d5,d2               ;bits 3;2;1 are pixels n-1;n;n+1
  move.w    (a5,d2.w),d2        ;d2=proba according to those 3 pixels
  RANDOM    a3,d3
  and.w     d6,d3               ;d3=rnd in [0;255]
  add.l     d0,d0               ;set dest pixel to 0
  cmp.w     d2,d3               ;flags=rnd-proba
  dc.w $6d02 ;blt.s +2          ;rnd<proba then pixel=0
  addq.l    #1,d0               ;          else pixel=1
 ENDM 

RndCell
  moveq.l   #%1110,d5           ;d5=mask for isolating three pixels*2
  
  move.w    152(a1),d1
  swap.w    d1
  move.w    (a1),d1
  addq.l    #8,a1
  add.l     d1,d1
  add.l     d1,d1

;PIXELS 0-287
 REPT 18
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  move.w    (a1),d1             ;Not faster than move.w d16(a1),d1
  addq.l    #8,a1               ;  but it will compress better
  RNDCELL
  RNDCELL
  move.w    d0,(a0)
  addq.l    #8,a0
 ENDR
;PIXELS 288-303
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  move.w    (a1),d1
  RNDCELL
  RNDCELL
  move.w    d0,(a0)
  addq.l    #8,a0
;PIXELS 304-319
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  RNDCELL
  move.w    -152(a1),d1         ;Reload start of line to compute last pixel
  RNDCELL
  RNDCELL
  move.w    d0,(a0)

  rts

RndCellEnd
   
  dc.b "boot"