
**************************************
*                                    *
*  Write to disk by The Fate of ULM  *
*                                    *
**************************************

offset equ 28

sec_per_track equ 10

x:

        move.w  #0,-(sp)
        move.w  #7,-(sp)
        trap    #13
        addq.l  #4,sp

        lea     desttab(pc),a0
        move.w  #0,-(sp)
        move.w  (a0)+,d0
        mulu    #sec_per_track,d0
        add.w   (a0)+,d0
        subq.w  #1,d0
        move.w  d0,-(sp)
        move.w  (a0)+,-(sp)
        pea     buffer(pc)
        move.w  #3,-(sp)
        move.w  #4,-(sp)
        trap    #13
        lea     $0e(sp),sp

        clr.w   -(sp)
        trap    #1

********************************************************************************

; 1 word = destination track
; 2 word = destination sector
; 3 word = sector count

desttab:
        dc.w 1,1,250

	section	data
buffer equ *+offset
        incbin 'e:\paradist\p.bin'

        section bss
        ds.l 512

        end
