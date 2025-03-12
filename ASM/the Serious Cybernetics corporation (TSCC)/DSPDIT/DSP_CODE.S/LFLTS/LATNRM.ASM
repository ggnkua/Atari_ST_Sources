;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Normalized Lattice IIR Filter Macro.
; 
; Last Update 01 Aug 86   Version 1.0
;
latnrm  macro   order
latnrm  ident   1,0
;
;       Normalized Lattice filter macro
;
;       Input value in register y0, output value in register A
;
;       Macro call:
;               latnrm  order           ;call macro
;
;       where 'order' is the number of reflections coefficients
;       in the filter.
;
;       Alters registers: x0 x1 y0 y1 a b, r0 r4, pc sr
;
;       Uses 2 locations on stack
;
;
  move           x:(r0)+,x1               ;get first Q in table
  do    #order,_endnlat
  mpy   x1,y0,a  x:(r0)+,x0   y:(r4),y1   ;q*w, get k, get s
  macr -x0,y1,a  b,y:(r4)+                ;a-k*s, save new s
  mpy   x0,y0,b               a,y0        ;k*w, set new w
  macr  x1,y1,b  x:(r0)+,x1               ;b+q*s, get next q
_endnlat              
  move                        b,y:(r4)+   ;sv scnd lst st
  move                        a,y:(r4)+   ;save last state
  clr   a                     y:(r4)+,y0  ;clr acc, get fst st
  rep   #order                            ;do fir taps
  mac   x1,y0,a  x:(r0)+,x1   y:(r4)+,y0
  macr  x1,y0,a               (r4)+       ;lst tap, rnd, adj pointer
  endm
