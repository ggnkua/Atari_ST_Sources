
.globl _textbig
.text
_textbig: link R14,#-4
          .dc.w $a000
          move.w 8(R14),d0
          mulu #8,d0         * must convert ascii into offset for 8 pixel text
          movea.l 8(a1),a3      * a3 holds third fontheader address
          move.l 76(a3),84(a0)  * move font data address into line A 
          move.w 80(a3),88(a0)  * move font width value
          move.w 52(a3),80(a0)  
          move.w 82(a3),82(a0)
          move.w d0,72(a0)      * select ascii value in d0
          move.w 10(R14),76(a0) * select screen x-loc 8
          move.w 12(R14),78(a0) * select screen y-loc 8
          move.w #1,102(a0)
          move.w #1,68(a0)      * set yet another scaling flag
          move.w $8000,64(a0)   * must be set for a textblt ?
          move.w #254,d3
          mulu #256,d3
          move.w d3,66(a0)
          move.w #1,90(a0)      * Thickened text
          move.w #1,106(a0)     * Set text color to be red
          move.w #0,36(a0)      * Set replace mode
          .dc.w $a008           * Do a textblt operation 
          unlk R14
          rts

