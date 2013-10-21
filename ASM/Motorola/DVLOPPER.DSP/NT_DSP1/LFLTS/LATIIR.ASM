;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Lattice IIR Filter Macro.
; 
; Last Update 31 Jul 86   Version 1.0
;
latiir  macro   order
latiir  ident   1,0
;
;       Lattice IIR filter macro
;
;       Input value in register A, output value in register A
;
;       Macro call:
;               latiir  order           ;call macro
;
;       where 'order' is the number of reflections coefficients
;       in the filter.
;
;       Alters registers: x0 x1 y0 a b, r0 r4, pc sr
;
;       Uses 2 locations on stack
;
;
  move            x:(r0)-,x0  y:(r4)+,y0    ;get first k, first state
  macr  -x0,y0,a  x:(r0)-,x0  y:(r4)-,y0    ;do first section
  do    #order-1,_endlat                    ;do remaining sections
  macr  -x0,y0,a              b,y:(r4)+     ;a-k*s, save previous state
  move  a,x1                  y:(r4)+,b     ;set a for mul, get st again
  macr  x1,x0,b   x:(r0)-,x0  y:(r4)-,y0    ;fnd nxt s, nxt s, nxt k
_endlat
  move                        b,y:(r4)+     ;round; save second last state
  move            x:(r0)+,x0  a,y:(r4)+     ;update r0, save last state
  endm 
