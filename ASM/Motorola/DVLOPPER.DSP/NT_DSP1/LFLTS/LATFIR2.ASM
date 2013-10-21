;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Lattice FIR Filter Macro (modified modulo count).
; 
; Last Update 08 Aug 86   Version 1.0
;
latfir2 macro   order
latfir2 ident   1,0
;
;       LATTICE FIR
;
;       Lattice FIR filter macro
;
;       Input value in register B, output value in register B.
;
;       Macro call:     latfir2 order
;               order   - order of filter (number of K coefficients)
;
;       Alters Data ALU Registers:
;       x0      y0      y1      a       b
;
;       Alters Address Registers:
;       r0      r4
;
;       Alters Program Control Registers:
;       pc      sr
;
;       Uses 2 locations on stack
;
  move           b,x:(r0)+    y:(r4)+,y0  ;sv B as fst st., mv fst k
  do    #order,_endlat
  move           x:(r0),a     b,y1        ;get state, set t for mul by k
  macr  y1,y0,a  a,x0                     ;t*k+s, copy s
  macr  x0,y0,b  a,x:(r0)+    y:(r4)+,y0  ;s*k+t, sv st., nxt k
_endlat
  move           x:(r0)-,x0   y:(r4)-,y0  ;adjust pointers
  endm
