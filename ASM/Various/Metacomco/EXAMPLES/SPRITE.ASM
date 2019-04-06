****************************************************
*                                                  *
*                  SPRITE.ASM                      *
*                                                  *
* A simple graphics demo to bounce a sprite around *
*     This example is for hi-res (monochrome)      *
*                                                  *
****************************************************

               INCLUDE  'LINEA.I'
               INCLUDE  'OSBIND.I' 

* Macro definitions for two common lineA calls

* AINIT macro sets up line "A" graphics interface

AINIT          MACRO
               DC.W     A_Init               ; initialise the lineA
               MOVE     #-1,_LSTLIN(a0)      ; always set this to -1
               MOVE     #-1,_LN_MASK(a0)     ; set line drawing mask
               MOVE     #0,_WRT_MODE(a0)     ; writing mode = replace
               MOVE     #0,_CLIP(a0)         ; clipping turned off
               ENDM                          ; END OF MACRO

* ARECTF macro to draw a filled rectangle
* (N.B. Must set up fill pattern first)

ARECTF         MACRO
               MOVE     \1,_X1(a0)           ; set-up co-ords
               MOVE     \2,_Y1(a0)           ; to top left
               MOVE     \3,_X2(a0)           ; and bottom
               MOVE     \4,_Y2(a0)           ; right of rect
               DC.W     A_FillRect           ; line "A" draw rect
               ENDM

* BELL macro to ring the Bell

BELL           MACRO
               MOVE.W   #7,-(SP)             ; bell character
               MOVE.W   #cconout,-(SP)
               TRAP     #gemdos              ; BEEP
               ADDQ.L   #4,SP                ; restore the stack
               ENDM

* Define the size of the screen
 
xmin           EQU      8                    ; screen bounds set to
ymin           EQU      8                    ; 8 pixels from edge
xmax           EQU      631                  ; as sprite is 16 wide
ymax           EQU      391                  ; i.e. "bounce window"
ntimes         EQU      1000                 ; number of times to loop

* Code starts here

start          AINIT                         ; first init line "A"
               MOVE.L   a0,a5                ; copy variables pointer
               MOVE     #1,_FG_BP_1(a0)      ; set bit mask
               MOVE     #1,_FG_BP_2(a0)      ; for each plane
               MOVE     #1,_FG_BP_3(a0)      ; i.e.set colour
               MOVE     #1,_FG_BP_4(a0)
               MOVE.L   #filpat,_patptr(a0)  ; point to pattern
               MOVE     #0,_patmsk(a0)       ; dont mask the fill
               MOVE     #0,_multifill(a0)     ; multiple planes off
               ARECTF   #1,#1,#638,#398      ; clear screen (leave border)
               MOVE     xpos,d0              ; set up X
               MOVE     ypos,d1              ; and Y positions
               MOVE.L   #sprdef,a0           ; point line"A" at sprite
               MOVE.L   #sprsav,a2           ; &space to save screen
               DC.W     A_DrawSprite         ; first draw the sprite
               MOVE.W   #ntimes,d3           ; set loop counter
movx           MOVE     xpos,d0              ; get X position
               ADD      xvel,d0              ; add X velocity
               CMP      #xmax,d0             ; within screen?
               BGT.S    xbounce              ; if not make it bounce
               CMP      #xmin,d0
               BGE.S    noxb                 ; branch if no x bounce

* o.k. bounce the x velocity

xbounce        NEG      xvel
               BELL                          ; ring the bell
               BRA.S    movx                 ; go try again

noxb           MOVE     d0,xpos              ; update X position
movy           MOVE     ypos,d1              ; as above but Y
               ADD      yvel,d1
               CMP      #ymax,d1
               BGT.S    ybounce
               CMP      #ymin,d1
               BGE.S    noyb

* o.k.bounce the Y velocity

ybounce        NEG      yvel
               BELL                          ; ring the bell
               BRA.S    movy                 ; go try again

noyb           MOVE     d1,ypos              ; update Y position
               MOVE.L   #sprsav,a2
               DC.W     A_UndrawSprite       ; undraw sprite
               MOVE     xpos,d0              ; set up x & y
               MOVE     ypos,d1              ; ready to redraw
               MOVE.L   #sprdef,a0           ; point to sprite
               MOVE.L   #sprsav,a2           ; and screen save block
               DC.W     A_DrawSprite         ; draw at new position
               MOVE     #vsync,-(sp)         ; wait for blanking
               TRAP     #xbios
               ADDQ.L   #2,sp                ; restore the stack
               DBF      d3,movx              ; loop

               MOVE.W   #0,-(A7)             ; set OK return code
               MOVE.W   #pterm,-(a7)         ; terminate and dont return
               TRAP     #gemdos

************************************************************************

               DATA

* First the save areas for the sprite position and velocities

xpos           DC.W     100                  ; sprite horizontal position
ypos           DC.W     50                   ;   "      vertical    "
xvel           DC.W     2                    ; and the horizontal
yvel           DC.W     2                    ; and vertical velocities

* Here is the data for the sprite - a happy face

sprdef         DC.W     8                    ; x offset of hotspot
               DC.W     8                    ; y offset
               DC.W     -1                   ; use XOR for sprite format
               DC.W     0                    ; background colour
               DC.W     1                    ; foreground colour
sprite         DC.W     %0000000000000000    ; background for line 0
               DC.W     %0000001111000000    ; foreground for line 0
               DC.W     %0000000000000000    ; etc.
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

* Finally the uninitialised data section for the sprite save block

               BSS

sprsav         DS.B     74                   ; space for sprite save block

               END


