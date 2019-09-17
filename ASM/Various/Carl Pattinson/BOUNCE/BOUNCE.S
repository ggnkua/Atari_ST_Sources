;Routine to calculate the position of a sprite under the effects of 
;gravity whilst moving it left and right about the screen.
;ENTRY: D0.w = Current X value of sprite        X
;       D1.w = Current Y value of sprite        Y
;       D2.w = Increment of X value     ( +ve or -ve )  DX
;       D3.w = Increment of Y value     ( +ve or -ve )  DY
;EXIT:  D0.w = New X value for sprite           X
;       D1.w = New Y value for sprite           Y
;       D2.w = New Increment of X value ( +ve or -ve )  DX
;       D3.w = New Increment of Y value ( +ve or -ve )  DY
;USES:  D0-D3

maxX    equ     300     Maximum X value     ( Based on a 16x16
minX    equ     4       Minimum X value       sprite block ).
maxY    equ     184     Maximum Y value
maxDY   equ     19      Maximum DY value

        TEXT

bounce  

; First we sort out the X value because it is easy with not being
; affected by gravity. ( Condition of parabolic motion !!! for all
; you physicists out there. ! )  

        add.w   d2,d0           ;Add DX to X
        cmp.w   #maxX,d0        ;Is X = Max X value ?
        bgt.s   negx            ;Greater than
        cmp.w   #minX,d0        ;Is X = Min X value ?
        blt.s   negx            ;Less than
        bra     yvar            ;Do y variable
negx    neg     d2              ;Negate DX (subtract it from 0 )

; If X is greater than maxX then we just make the DX value negative 
; coz when you add the negative DX value it will decrease the 
; X value.


; Now here comes the vertical (Y) value. This is affected by a 
; psuedo-gravity thingy. Every time the routine is called 1 is
; added to DY if it is less than the max DY value. If it is 
; equal to maxDY value then the DY value is then added to the 
; Y value.

yvar    cmp.w   #maxDY,d3       ;Is DY = Max DY value ?
        blt.s   less_than       ;Less than
        bra.s   not_less        ;Greater or equal
less_than       
        add.w   #1,d3           ;Add 1 to DY
not_less        
        add.w   d3,d1           ;Add DY to Y
        cmp.w   #maxY,d1        ;Is Y = Max Y value ?
        bgt.s   greathan        ;Greater than
        bra.s   endrout         ;Less or equal
greathan        
        move.w  #maxY,d1        ;Make Y = Max Y value
        neg     d3              ;Negate DY ( subtract it from 0 )

; If Y is greater than the maxY value then Y=maxY
 
endrout 
        rts                     ;Return !!
