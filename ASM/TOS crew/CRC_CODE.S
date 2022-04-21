;
; ARJ CRC function
; Size optimized
; (c) 1993 Mr Ni! (the Great) of the TOS-crew
;
; ulong crc_buf(char *str, ulong len)
;
; CALL:
; D0 = #bytes (long)
; A0 = buffer
;
; Return:
; D0 = CRC-code
;
; uses 1kB buffer on stack
;
crc_buf:
     move.l  d3,-(sp)
     move.l  d0,-(sp)
     lea     (sp),a1
     lea     -1024(sp),sp
     moveq   #0,d0
     subq.b  #1,d0
     move.l  #$EDB88320,d2
.loop_0:
     moveq   #7,d3
     move.l  d0,d1
.loop_1:
     lsr.l   #1,d1
     bcc.s   .next
     eor.l   d2,d1
.next:
     dbra    d3,.loop_1
     move.l  d1,-(a1)
     dbra    d0,.loop_0
     move.l  1024(sp),d0
     moveq   #-1,d1
.crc_loop:
     moveq   #0,d2
     move.b  (a0)+,d2
     eor.b   d1,d2
     lsr.l   #8,d1
     lsl.w   #2,d2
     move.l  0(a1,d2.w),d2
     eor.l   d2,d1
     subq.l  #1,d0
     bne.s   .crc_loop
     lea     1028(sp),sp
     not.l   d1
     move.l  d1,d0
     move.l  (sp)+,d3
     rts

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
*******************************************************************************

     END