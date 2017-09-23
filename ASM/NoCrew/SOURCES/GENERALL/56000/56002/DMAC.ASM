;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
;
; **************************************************************
; **  Double Precision Multiplication & accumulate            **
; **************************************************************
;
;         This procedure assumes that no overflow occurs at any point
;         if there may be additions that might cause overflow then an
;         extention word is needed.
;         (multiplication cannot cause an overflow)
;
;         
;         r1 points to an arry of dubble precision numbers     x space
;         r5 points to an arry of dubble precision numbers     y space
;
;         at both spaces each even word contains lsw
;                    and each odd  word contains msw
;
;         the result of each multiplication is stored temporarily at the
;         following format:
;
;           HH            HL            LH          LL
;         x:(r0+1)      y(r0+1)        x:(r0)      y:(r0)
;         the result of the sum is stored at the
;         following format:
;
;           HH            HL            LH          LL
;         x:(r2+1)      y(r2+1)        x:(r2)      y:(r2)
;
N         equ    8
          org    p:$40
          clr    a
          move   a,l:(r2)+                           ; init sum LH,LL to 0
          move   a,l:(r2)-                           ; init sum HH,HL to 0
          do     #N,endploopa
          ori    #$40,mr                             ; turn on DP, SR(14)
          move   x:(r1)+,x0   y:(r5)+,y0             ; load p0, q0
          mpy    y0,x0,a   x:(r1)+,x1   y:(r5)+,y1   ; a = p0 * q0
          mac    x1,y0,a   a0,y:(r0)                 ; a = shifted(a) + p1 * q0
          mac    x0,y1,a                             ; a = shifted(a) + p0 * q1
          mac    y1,x1,a   a0,x:(r0)+                ; a = a + p1 * q1
          move   a,l:(r0)-                           ; 
          andi   #$bf,mr                             ; turn off DP, SR(14)

          move   l:(r2),b10                          ; load LH,LL of 2nd operand
          move   l:(r0)+,a10                         ; load LH,LL of 1st operand
          add    a,b          l:(r0)-,y              ; a+b->b  , load HH,HL of 1st operand
          move   b10,l:(r2)+                         ; store LH,LL of sum
          move   l:(r2),b                            ; load HH,HH of 2nd operand
          adc    y,b                                 ; a+b->b
          move   b10,l:(r2)-                         ; store HH,HH of sum
; if extention needed
;         move   b2,b0
;         move   #0,b1
;         move   exten,y0
;         move   #0,y1
;         add    y,b
;         move   b0,exten
endploopa
          andi   #$bf,mr                             ; turn off DP, SR(14)
          nop
