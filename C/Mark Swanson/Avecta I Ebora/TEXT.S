*****************************************************************************
* textsix(FLAG,X,Y,LENGTH,STRING) is a call to output the string whose 
* starting address is (LONG) STRING, and whose length is (INT) LENGTH at the
* screen location (INT) X,Y.  If (INT) FLAG is set then the text will be output
* in inversed mode, background color 1 (black), foreground color 0 (white).
*****************************************************************************

.globl _textsix
.text
_textsix: link R14,#-4
          .dc.w $a000
          clr.l d3
          move.w 14(R14),d3    * d3 now holds the length of the string
          move.l 16(R14),a5    * a5 now holds the address of the string
          move.l a0,a4
          clr.l d4
          move.w 8(R14),d4     * d4 now holds the text flag
          movea.l (a1),a3       * a3 holds first fontheader address
          move.l 76(a3),84(a4)  * move font data address into line A 
          move.w 80(a3),88(a4)  * move font width value
          move.w 52(a3),80(a4)  
          move.w 82(a3),82(a4)
          move.w 12(R14),78(a4)  * select screen y-loc 8
          move.w #1,102(a4)
          move.w #1,68(a4)       * set yet another scaling flag
          move.w $8000,64(a4)    * must be set for a textblt ?
          move.w #1,106(a4)      * When running this is black
          cmp.w #1,d4
          bne norml 
          move.w #2,36(a4)      * Set XOR mode if flag = 1
          bra doit
norml:    move.w #0,36(a4)      * Set REPLACE mode if flag = 0
doit:     cmp.w #0,d3
          beq done
          move.w 10(R14),76(a4)  * select screen x-loc 8
          addq #6,10(R14)
          clr.l d6
          move.b (a5),d6
          mulu #6,d6
          addq #1,a5
          subq #1,d3
          move.w d6,72(a4)
          .dc.w $a008           * Do a textblt operation 
          bra doit
done:     unlk R14
          rts

