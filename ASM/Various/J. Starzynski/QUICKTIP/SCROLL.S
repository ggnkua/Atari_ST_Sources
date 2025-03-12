; Hardwarescrolling auf dem ST
; Autor: Fred Goyke
; Sprache: TURBOASS V:1.7.2
; Datum: 26.12.91
;
         pea      MAIN(PC)
         move.w   #$26.-(SP)
         trap     #14
         addq.l   #6,SP
MAIN:
         move     #$2700,SR

         move.l   #VBI_INT,$70.w
         clr.w    D6

         move     #$2300,SR
wait:
         bra.s    wait
VBI_INT:
         addq.b   #4,D6       ; 2, 4 oder 8 bei
         ; High-, Med- oder Low-Rez.
         move.b   D6,$FFFF8209.w
         ; VAC auf LOW!
         rte


