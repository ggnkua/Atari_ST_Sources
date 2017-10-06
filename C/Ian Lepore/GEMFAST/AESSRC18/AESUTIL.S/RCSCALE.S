;*************************************************************************
;* RCSCALE.S - Scale source rect into dest using specified percentage.
;*             Dest is centered over/within source.
;*************************************************************************

_rc_scale::

          .cargs    #4,.psource.l,.pdest.l,.percentage.w
                    
          move.l    .psource(sp),a0     ; load psource
          move.l    .pdest(sp),a1       ; load pdest
          move.w    .percentage(sp),d2  ; load percentage
          
          tst.w     d2                  ; negative percentages are a 
          bpl.s     .inrange            ; no-no, just force them
          moveq.l   #100,d2             ; to 100%.
.inrange:
          move.w    4(a0),d0            ; load wsource
          move.w    d0,d1               ; copy to wdest
          mulu      d2,d1               ; multiply by percentage
          divu      #100,d1             ; scale back down
          
          sub.w     d1,d0               ; calc pdest->g_x =
          asr.w     #1,d0               ;   ((wsource - wdest) / 2) +
          add.w     (a0),d0             ;   psource->g_x
          move.w    d0,(a1)             ; store pdest->g_x.
          
          tst.w     d1                  ; if wdest was non-zero 
          bne.s     .nzw                ; we're cool, else force
          moveq.l   #1,d1               ; it to one, zero widths are ugly.
.nzw:
          move.w    d1,4(a1)            ; store pdest->g_w
          
          move.w    6(a0),d0            ; load hsource
          move.w    d0,d1               ; copy to hdest
          mulu      d2,d1               ; multiply by percentage
          divu      #100,d1             ; scale back down
          
          sub.w     d1,d0               ; calc pdest->g_y =
          asr.w     #1,d0               ;   ((hsource - hdest) / 2) +
          add.w     2(a0),d0            ;   psource->g_y
          move.w    d0,2(a1)            ; store pdest->g_y.
          
          tst.w     d1                  ; if hdest was non-zero 
          bne.s     .nzh                ; we're cool, else force
          moveq.l   #1,d1               ; it to one, zero heights are ugly.
.nzh:
          move.w    d1,6(a1)            ; store pdest->g_h
          
          move.l    a1,d0               ; return pdest
          rts
          
           .end
