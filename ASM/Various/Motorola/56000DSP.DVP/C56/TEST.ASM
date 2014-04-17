; beginning of module
 org xh:
 org ph:
Gmain
 clr b #>1,x1
 move b,y1
 move x:-(r6),x0
 move #>0,a
 move a,x:(r6)
_L1
 move x:(r6),a
 move #>2,y0
 cmp y0,a
 tle y1,a
 tgt x1,a
 jle _F1
 jmp _L3
_L4
 move x:(r6),a
 add x1,a
 move a,x:(r6)
 sub x1,a
 jmp _L1
_L3
 jmp _L4
_L2
_F1
 move x:(r6)+,x0
 rts
 org xh:
; end of module
