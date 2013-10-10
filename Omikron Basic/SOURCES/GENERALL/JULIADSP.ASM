; This program, originally available on the Motorola DSP bulletin board
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas  78735-8598.
;
; This program generates the Julia Set, found by Gaston Julia in
; early twentieth century.  It outputs N * N integers which
; can be mapped to color tables for display.  The points
; with integer value equal to "MAX" are in the Julia Set.
; The quadratic functions used : f(z) = z*z + c, where |c| < 2
; Example Seed values  :  c = c1 + c2
; (1) -1.0
; (2) 0.3 - j0.4
; (3) 0.360284 + j0.100376
; (4) -0.1 + j0.8
; Motorola DSP Applications
; Last Update : 8-3-90
; d0,d1 : store intermediate results
; d2 : intermediate result, and 4.0
; d3 : counter
; d4 : y0, starts at 2.0
; d5 : c2
; d6 : x0, starts at -2.0
; d7 : 1/50, or 0.02
; d8 : c1
; d9 : not used

main   equ $100
coef   equ $0
output equ $100
N      equ 200
MAX    equ 20

  org x:coef
      dc  2.0
      dc  4.0

  org y:coef
      dc  MAX

  org p:main
  move #coef+2,r0
  move #coef+3,r4                    ; temporary storage for x,y,x0,y0
  move #coef,r2
  move #output,r5
  clr  d3  #-2.0,d6.s                ; x0
  move #0.8,d5.s
  move #0.02,d7.s                    ; 1/50
  move #2.0,d4.s                     ; y0
  fadd.s d7,d6          #-0.1,d8.s   ; update x0, c1
  fsub.s d7,d4                       ; update y0
  move d6.s,x:(r0) d4.s,y:
  move d6.s,x:(r4) d4.s,y:           ; initiliazation

  do #N,_mloop
  do #N,_nloop
_count
  move   x:(r4),d6.s y:,d4.s
  fmpy.s d6,d6,d1    d8.s,d0.s                            ; x*x, c1
  fmpy   d4,d4,d0    fadd.s d0,d1                         ; y*y, x*x+c1
  fmpy   d4,d6,d0    fsub.s d0,d1  d4.s,d2.s x:(r2)+,d4.s ; x*y, x1, 2
  fmpy.s d0,d4,d0    d1.s,d4.s     d1.s,x:(r4)            ; 2*x*y, x1
  fmpy   d4,d4,d1    fadd.s d5,d0  d2.s,d4.s x:(r2)-,d2.s ; x1*x1, y1
  fmpy.s d0,d0,d0    d0.s,y:(r4)                          ; y1*y1
  fadd.s d1,d0                                            ; z
  fcmp   d0,d2       y:(r2),d2.l                          ; 4.0-z, MAX
  fjmi   _save                                     ; check for out of bound
  inc    d3                                               ; counter++
  cmp   d2,d3                                             ; MAX-counter
  jne   _count

_save
  move   x:(r0),d2.s y:,d4.s                              ; update y0
  fsub.s d7,d4       d3.l,y:(r5)+                         ; output
  clr    d3          d4.s,y:(r0)                          ; reset counter
  move   d2.s,x:(r4) d4.s,y:
_nloop

 move    x:(r0),d6.s
 fadd.s  d7,d6       x:(r2),d4.s                          ; update x0
 fsub.s  d7,d4       d6.s,x:(r0)                          ; update y0
 move    d6.s,x:(r4) d4.s,y:
 move    d4.s,y:(r0)
_mloop

s 7d    6sx(0         