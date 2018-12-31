* COEUTIL.S - MC68000 cohort for NEWMOUSE
*   by Joe Chiazzese
* Copyright 1986 ANTIC Publishing

.globl _save_screen
_save_screen:
        move.w  6(sp),d1        ;copy height to d1
        subq.w  #1,d1           ;height - 1 = height if count starts at zero
        move.l  12(sp),a0       ;buffer address to a0
ss1:    move.w  4(sp),d0        ;copy width to d0
        move.l  8(sp),a1        ;absolute screen address to a1
ss0:    move.l  (a1)+,(a0)+     ;move all four planes
        move.l  (a1)+,(a0)+
        dbf     d0,ss0          ;repeat width times
        add.l   #160,8(sp)      ;move to next line
        dbf     d1,ss1          ;repeat height times
        rts                     ;done

.globl _restore_screen
_restore_screen:
        move.w  6(sp),d1        ;copy height to d1
        subq.w  #1,d1           ;height - 1 = height if count starts at zero
        move.l  12(sp),a0       ;buffer address to a0
rs1:    move.w  4(sp),d0        ;copy width to d0
        move.l  8(sp),a1        ;absolute screen address to a1
rs0:    move.l  (a0)+,(a1)+     ;move all four planes
        move.l  (a0)+,(a1)+     ;(2 longs = 4 words(planes))
        dbf     d0,rs0          ;repeat width times
        add.l   #160,8(sp)      ;move pointer to next line
        dbf     d1,rs1          ;repeat height times
        rts                     ;done

.globl _shift_image
_shift_image:
        move.w  6(sp),d1        ;height in d1
        move.w  16(sp),d2       ;offset to d2
        subq.w  #1,d1           ;height - 1 = height if count starts at zero
        subq.w  #1,4(sp)        ;width - 1 = width if count starts at zero
        move.l  8(sp),a0        ;object pointer to a0
        move.l  12(sp),a1       ;image pointer to a1
si1:    move.w  4(sp),d0        ;width in d0
        clr.l   (a1)            ;for each line, the first word of the
        clr.l   4(a1)           ;image must be cleared
si0:    clr.l   d4              ;make sure that the top halves of these
        clr.l   d5              ;registers are zeroed out
        clr.l   d6
        clr.l   d7
        move.w  (a0)+,d4        ;load in one word (four planes)
        move.w  (a0)+,d5        ;to be rotated
        move.w  (a0)+,d6
        move.w  (a0)+,d7
        ror.l   d2,d4           ;rotate all planes by the offset(d2)
        ror.l   d2,d5
        ror.l   d2,d6
        ror.l   d2,d7
        or.w    d4,(a1)+        ;add low order bits to the high order bits
        or.w    d5,(a1)+        ;stored by move instructions farther
        or.w    d6,(a1)+        ;down in this routine
        or.w    d7,(a1)+
        swap    d4              ;move high order bits into lower halves
        swap    d5              ;of the registers
        swap    d6
        swap    d7
        move.w  d4,(a1)         ;save the high orders bits to be ORed
        move.w  d5,2(a1)        ;in the loop (do not increment a1 because
        move.w  d6,4(a1)        ;the ORs in the loop must function on
        move.w  d7,6(a1)        ;the same addresses as these moves.
        dbf     d0,si0          ;repeat width times
        addq.l  #8,a1           ;new line, move to next word( * 4 planes = 8)
        dbf     d1,si1          ;repeat height times
        rts                     ;done

.globl _make_mask
_make_mask:
        move.w  6(sp),d1        ;height in d1
        subq.w  #1,d1           ;height - 1 = height if count starts at zero
        move.l  8(sp),a0        ;image pointer to a0
        move.l  12(sp),a1       ;mask pointer to a1
mm1:    move.w  4(sp),d0        ;width in d0
mm0:    move.w  (a0)+,d2        ;load first plane of bit image in d2
        or.w    (a0)+,d2        ;OR it with the 3 other planes
        or.w    (a0)+,d2
        or.w    (a0)+,d2
        move.w  d2,d3           ;store inverse mask in d3 (temporary)
        swap    d2              ;move inverse mask to top half of register
        move.w  d3,d2           ;and also in bottom half
        eor.l   #-1,d2          ;mask no longer inverse
        move.l  d2,(a1)+        ;store mask in buffer
        dbf     d0,mm0          ;repeat 'width' times
        dbf     d1,mm1          ;repeat 'height' times
        rts                     ;done

.globl _draw_image
_draw_image:
        move.w  6(sp),d1        ;height to d1
        subq.w  #1,d1           ;height - 1 = height if count starts at zero
        move.l  12(sp),a1       ;image pointer to a1
        move.l  20(sp),a2       ;mask pointer to a2
        move.l  16(sp),a3       ;screen buffer pointer to a3
di1:    move.w  4(sp),d0        ;width to d0
        move.l  8(sp),a0        ;absolute screen address to a0
di0:    move.l  (a2)+,d3        ;load mask data into d3
        move.l  (a1)+,d6        ;load screen image into d6 and d7
        move.l  (a1)+,d7        ;2 words each covers all 4 planes
        move.l  (a3)+,d4        ;do the same for the background
        move.l  (a3)+,d5        ;in d4 and d5 (from buffer, not screen)
        and.l   d3,d4           ;mask background
        and.l   d3,d5
        or.l    d6,d4           ;copy image onto background
        or.l    d7,d5           ;giving final image on top of background
        move.l  d4,(a0)+        ;copy final image into screen memory
        move.l  d5,(a0)+
        dbf     d0,di0          ;repeat for 'width' times
        add.l   #160,8(sp)      ;move to next screen line
        dbf     d1,di1          ;repeat 'height' times
        rts                     ;done

