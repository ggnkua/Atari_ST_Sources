export preshift, copy_2plane, trap3_handler

;void preshift(char* buffer)
; preshift data in buffer
; buffersize =16*32000 bytes
; 2 bitplane data
preshift:
   move.l  d3,-(sp)
   move.w  #8000-1,d0
   move.w  (a0)+,d1
   move.w  (a0)+,d2
.loop0:
   lea     (a0),a1
   swap    d1
   swap    d2
   move.w  (a0)+,d1
   move.w  (a0)+,d2
   swap    d1
   swap    d2
   moveq   #15,d3
.loop1:
   lea     32000-4(a1),a1
   rol.l   #1,d1
   rol.l   #1,d2
   move.w  d1,(a1)+
   move.w  d2,(a1)+
   dbra    d3,.loop1
   dbra    d0,.loop0
   move.l  (sp)+,d3
   rts

;void copy_2plane(char* src1, char* src2, long dst)
;copy 2 bitplane data from src1 and src2 to dst (screen)
copy_2plane:
   movem.l d3-d7/a2-a6,-(sp)
   move.l  sp,save_ssp
   and     #$fff,sr         ; go user!
   move.l  sp,save_usp

   move.l  d0,a2
   REPT 200
   movem.l (a0)+,d0/d2/d4/d6/a3/a5/a7
   movem.l (a1)+,d1/d3/d5/d7/a4/a6
   movem.l d0-d7/a3-a7,(a2)
   movem.l (a1)+,d0/d2/d4/d6/a3/a5/a7
   movem.l (a0)+,d1/d3/d5/d7/a4/a6
   movem.l d0-d7/a3-a7,1*52(a2)
   movem.l (a0)+,d0/d2/d4/d6/a3/a5/a7
   movem.l (a1)+,d1/d3/d5/d7/a4/a6
   movem.l d0-d7/a3-a7,2*52(a2)
   lea     160-4(a2),a2
   move.l  (a1)+,(a2)+
   lea     80(a0),a0
   ENDM

   move.l  save_usp,sp   
   trap    #3

trap3_handler:
   move.l  save_ssp,sp         ; restore stack
   movem.l (sp)+,d3-d7/a2-a6; restore registers
   rts

BSS:
save_usp:
ds.l 1
save_ssp:
ds.l 1