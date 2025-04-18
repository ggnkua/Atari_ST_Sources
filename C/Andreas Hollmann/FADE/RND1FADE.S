;******************************************************************************
;*        RND1FADE - Pixelwise fading between two screens                     *
;*        with Pseudo-random count                 by Andreas Hollmann        *
;*    (c) 1992 MAXON Computer GmbH                                            *
;******************************************************************************
GLOBL  rnd1fade;

rnd1fade:   movea.l   4(sp),a0        ;fetch src_adr 
            movea.l   8(sp),a1        ;fetch dst_adr 
;------------------------------------------------------------------------------
            moveq     #1,d0           ;Load Sliding-Register with Start value of 1 
            move.l    #255999,d3      ;for comparing upper limit (faster !)
            moveq     #0,d4           ;for 1st  handle out (faster !)
            moveq     #7,d5           ;for 2nd  handle out (faster !)
            move.w    #17,d6          ;for left Bit (faster !)
            move.l    #255999,d7      ;how many Bits will it copy
;------------------------------------------------------------------------------
;Production of Pseudo-random count with a return linked Sliding register:
;
calc_rnd:   btst      d4,d0           ;1st  handle out (Bit 0)
            beq.s     bits0x          ;if Bit=0 ->

bits1x:     btst      d5,d0           ;2nd  handle out (Bit 1)
            beq.s     bits10
bits11:     lsr.l     #1,d0           ;no Bit set, because 1 eor 1 = 0 
            bra.s     chk_rnd
bits10:     lsr.l     #1,d0
            bset      d6,d0           ;because 1 eor 0 = 1 
            bra.s     chk_rnd

bits0x:     btst      d5,d0           ;2nd  handle out (Bit 1)
            beq.s     bits00
bits01:     lsr.l     #1,d0
            bset      d6,d0           ;because 0 eor 1 = 1 
            bra.s     chk_rnd
bits00:     lsr.l     #1,d0           ;no Bit set, because 0 eor 0 = 0 
;------------------------------------------------------------------------------
chk_rnd:    cmp.l     d3,d0           ;max. 255999 ! (in d3 steht 255999)
            bhi.s     calc_rnd        ;otherwise new random number...

            move.b    d0,d1           ;Copy random number to d1 
            and.b     #7,d1           ;Calculate Pixels 
            move.l    d0,d2           ;Copy random number to d2 
            asr.l     #3,d2           ;Calculate Bytes 

            btst      d1,0(a0,d2.w)   ;test src_adr-Bit 
            beq.s     clr_bit
            bset      d1,0(a1,d2.w)   ;set dst_adr-Bit 
            bra.s     dec_count
clr_bit:    bclr      d1,0(a1,d2.w)   ;remove dst_adr-Bit 

dec_count:  subq.l    #1,d7           ;Decrement Pixel-Counter
            bpl.s     calc_rnd
;------------------------------------------------------------------------------
            rts
            END
