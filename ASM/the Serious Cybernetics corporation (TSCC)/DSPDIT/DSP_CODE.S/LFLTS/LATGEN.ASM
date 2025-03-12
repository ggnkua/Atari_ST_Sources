;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Generalized Lattice FIR/IIR Filter Macro.
; 
; Last Update 08 Aug 86   Version 1.0
;
latgen        macro   order
latgen        ident   1,0
;
;     Generalized Lattice FIR/IIR
;
;     Input value in register A, output value in register A.
;
;     Macro call:
;             latgen  order           ;call macro
;
;     where 'order' is the number of K coefficients.
;
;     Alters registers: x0 x1 y0 a b, r0 r4, pc sr
;
;     uses 2 locations on the stack.
;
;
  move           x:(r0)+,x0  y:(r4)-,y0     ;get first k, first s
  do    #order,_el                          ;calculate states
  macr  -x0,y0,a             b,y:(r4)+      ;a-k*s, save prev s
  move            a,x1       y:(r4)+,b      ;set a for mul, s again 
  macr  x1,x0,b  x:(r0)+,x0  y:(r4)-,y0     ;a*k+s, k, nxt s
_el
  move                       b,y:(r4)+      ;sv scnd to 1st st
  clr   a                    a,y:(r4)+      ;save first state
  move                       y:(r4)+,y0     ;get last state
  rep   #order
  mac   x0,y0,a  x:(r0)+,x0  y:(r4)+,y0     ;do fir taps
  macr  x0,y0,a              (r4)+          ;mac and round, adj pointer
  endm
