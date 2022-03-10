;*************************************************************************
;* FRMXCENT.S - Extended form_center() binding.
;*************************************************************************

          .include  "aesfast.sh"
          
          .data
dmyrect:  .dc.w     0,0,0,0

          .text

_frmx_dial::
          .cargs    #8,.flag.w,.plittle.l,.pbig.l

          link      a6,#-2              ; allocate intout[1]

          move.l    .pbig(a6),a0        ; build intin on the stack...
          move.l    4(a0),-(sp)         ; first goes the big rectangle
          move.l    (a0),-(sp)
          
          move.l    .plittle(a6),a0     ; the little rectangle is 
          move.l    a0,d0               ; optional; if we were given a 
          bne.s     .notnull            ; null pointer, supply a dummy
          lea       dmyrect,a0          ; rectangle of {0,0,0,0}.
.notnull:
          move.l    4(a0),-(sp)         ; stack little rectangle...
          move.l    (a0),-(sp)
          
          move.w    .flag(a6),-(sp)     ; stack operation flag
          
          move.l    sp,a1               ; load intin pointer into a1
          
          AControl  51,9,1,0
          moveq.l    #-2,d2             ; size of intout
          ACall     RET2HERE
          
          moveq.l   #-2,d1              ; size of intout
          jmp       (a0)                ; go return intout[0]
          
          .end
          
