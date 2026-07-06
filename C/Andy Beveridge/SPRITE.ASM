****************************************************
*                                                  *
* A simple graphics demo to bounce a sprite around *
*     This example is for hi-res (monochrome)      *
*                                                  *
****************************************************

* GENERAL PURPOSE HEADER FOR LINE "A" GRAPHICS

v_planes       EQU      0                   ;no. of video planes
v_lin_wr       EQU      2                   ;bytes per video line
fgbp1          EQU      24                  ;mask bit-plane 0 value
fgbp2          EQU      26                  ;mask bit-plane 1
fgbp3          EQU      28                  ;mask bit-plane 2
fgbp4          EQU      30                  ;mask bit-plane 3
lstlin         EQU      32                  ;set this to -1
ln_mask        EQU      34                  ;line style word
wrt_mode       EQU      36                  ;writing mode
x1             EQU      38                  ;x1 co-ord
y1             EQU      40                  ;y1 co-ord
x2             EQU      42                  ;x2 co-ord
y2             EQU      44                  ;y2 co-ord
patptr         EQU      46                  ;pointer to fill pattern
patmsk         EQU      50                  ;fill pattern mask
multifil       EQU      52                  ;multi plane fill flag
clip           EQU      54                  ;clipping flag(0 => off)

* line "A" opcodes follow

init           EQU      $a000               ;inititialise line "A"
line           EQU      $a003               ;draw a line
frect          EQU      $a005               ;filled rectangle
unsprite       EQU      $a00c               ;undraw sprite
dosprite       EQU      $a00d               ;draw a sprite
                                       
* MACRO DEFINITIONS FOR COMMON LINE "A" USE
*
* AINIT macro sets up line "A" graphics interface
*
AINIT          MACRO
               DC.W     init                ;op-code to init
               MOVE     #-1,lstlin(a0)      ;always set this to -1
               MOVE     #-1,ln_mask(a0)     ;set line drawing mask
               MOVE     #0,wrt_mode(a0)     ;writing mode = replace
               MOVE     #0,clip(a0)         ;clipping turned off
               ENDM                         ;END OF MACRO
*
* ARECTF macro to draw a filled rectangle
* (N.B. MUST SET UP FILL PATTERN FIRST)
*
ARECTF         MACRO
               MOVE     \1,x1(a0)            ;set-up co-ords
               MOVE     \2,y1(a0)            ;to top left
               MOVE     \3,x2(a0)            ;and bottom
               MOVE     \4,y2(a0)            ;right of rect
               DC.W     frect                ;line "A" draw rect
               ENDM

* code proper starts here

xmin           EQU      8                    ;screen bounds set to
ymin           EQU      8                    ;8 pixels from edge
xmax           EQU      631                  ;as sprite is 16 wide
ymax           EQU      391                  ;i.e. "bounce window"

start          AINIT                         ;first init line "A"
               MOVE.L   a0,a5                ;copy variables pointer
               MOVE     #1,fgbp1(a0)         ;set bit mask
               MOVE     #1,fgbp2(a0)         ;for each plane
               MOVE     #1,fgbp3(a0)         ;i.e.set color
               MOVE     #1,fgbp4(a0)
               MOVE.L   #filpat,patptr(a0)   ;point to pattern
               MOVE     #0,patmsk(a0)        ;dont mask the fill
               MOVE     #0,multifil(a0)      ;multiple planes off
               ARECTF   #1,#1,#638,#398      ;clear screen
               MOVE     xpos,d0              ;set up X
               MOVE     ypos,d1              ;and Y positions
               MOVE.L   #sprdef,a0           ;point line"A" at sprite
               MOVE.L   #sprsav,a2           ;&space to save screen
               DC.W     dosprite             ;first draw the sprite
movx           MOVE     xpos,d0              ;get X position
               ADD      xvel,d0              ;add X velocity
               CMP      #xmax,d0             ;within screen?
               BGT      xbounce              ;if not make it bounce
               CMP      #xmin,d0
               BGE      noxb
* o.k. bounce the x velocity
xbounce        NEG      xvel
               BRA      movx                 ;go try again
noxb           MOVE     d0,xpos
movy           MOVE     ypos,d1              ;as above but Y
               ADD      yvel,d1
               CMP      #ymax,d1
               BGT      ybounce
               CMP      #ymin,d1
               BGE      noyb
* o.k.bounce the Y velocity
ybounce        NEG      yvel
               BRA      movy                 ;go try again
noyb           MOVE     d1,ypos              ;update Y posn
               MOVE.L   #sprsav,a2
               DC.W     unsprite             ;undraw sprite
               MOVE     xpos,d0              ;set up x & y
               MOVE     ypos,d1              ;ready to redraw
               MOVE.L   #sprdef,a0           ;point to sprite
               MOVE.L   #sprsav,a2           ;and screen save block
               DC.W     dosprite             ;draw at new position
               MOVE     #37,-(sp)            ;wait for blanking
               TRAP     #14                  ;XBIOS function call
               ADDQ.L   #2,sp                ;POP fn call code
               BRA      movx                 ;loop forever

xpos           DC.W     100                  ;sprite horizontal posn
ypos           DC.W     100                  ;  "      vertical   "
xvel           DC.W     2                    ;and the horizontal
yvel           DC.W     2                    ;and vertical velocities


               DATA

*  here is the data for the sprite - a happy face

sprdef         DC.W     8                    ;x offset of hotspot
               DC.W     8                    ;y offset
               DC.W     -1                   ;use XOR for sprite format
               DC.W     0                    ;background colour
               DC.W     1                    ;foreground colour
sprite         DC.W     %0000000000000000    ;background for line 0
               DC.W     %0000001111000000    ;foreground for line 0
               DC.W     %0000000000000000    ;etc.
               DC.W     %0000111111110000
               DC.W     %0000000000000000
               DC.W     %0001111111111000
               DC.W     %0000000000000000
               DC.W     %0011111111111100
               DC.W     %0000000000000000
               DC.W     %0111111111111110
               DC.W     %0000000000000000
               DC.W     %0111111111111110
               DC.W     %0000000000000000
               DC.W     %1111001111001111
               DC.W     %0000000000000000
               DC.W     %1111001111001111
               DC.W     %0000000000000000
               DC.W     %1111111111111111
               DC.W     %0000000000000000
               DC.W     %1111111111111111
               DC.W     %0000000000000000
               DC.W     %0111111111111110
               DC.W     %0000000000000000
               DC.W     %0111101111011110
               DC.W     %0000000000000000
               DC.W     %0011110000111100
               DC.W     %0000000000000000
               DC.W     %0011111111111100
               DC.W     %0000000000000000
               DC.W     %0000111111110000
               DC.W     %0000000000000000
               DC.W     %0000001111000000

filpat         DC.W     $ffff

               BSS

sprsav         DS.B     74                   ;space for sprite save block

               END


