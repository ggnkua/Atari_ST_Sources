* Scroll.asm
*
* Bet you are trying to figure out how this works.
* I added some comment here and there.

* call this routine from GfA like this:

* Open "i",1,"scroll.tos"
* L%=Lof(#1)-28
* Scr$=Space$(L%)
* Seek #1,28                    * skip TOS header
* Bget #1,Varptr(Scr$),L%
* Close #1
* Dim Parm%(4)

* M%=Varptr(Scr$)
* Parm%(0) = address to scroll on screen
* Parm%(1) = address of 32 byte buffer
* Parm%(2) = address of text, ended with a null-byte
* Parm%(3) = scroll pixel counter (0-7), initial value should be 0
* Parm%(4) = character number to be scrolled
* Parm%(5) = address of font

* I put all these variables in here so you have maximum control
* over your scroll. You can make it dissapear and reapprear in exactly
* the same state if you buffer the scrolling region and do not modify
* any of the variables in the array.

* Repeat
*   Void C:M%(L:Varptr(Parm%(0)))
*   repeat it if you want to speed up scroll
*   Vsync
* Until Inkey$<>"" Or Mousek

scroll          move.w  #4,-(sp)
                trap    #14
                addq.l  #2,sp
                move.l  d0,d1      * resolution in d1

		move.l  4(sp),a0   * a0: address of parameter table
                move.l  8(a0),a6   * a6: address of text
                move.l  12(a0),d5  * d5: scroll pixel counter
                move.l  16(a0),d6  * d6: character number to be scrolled

                cmp.l   #-1,20(a0)           * font address -1?
                bne.s   fontok
                asl.l   #2,d1                * d1 times 4
                move.l  d1,d6                * save
                movem.l a0-a2/d1/d2,-(sp)    * save registers
                dc.w    $a000                * Line-A init
                move.l  0(a1,d6.w),a1        * get font address
                move.l  76(a1),d6            * font data address 
                movem.l (sp)+,a0-a2/d1/d2    * get registers back
                move.l  d6,20(a0)            * set font parameter

fontok		cmp.b   #2,d1      * monochrome?
                bne.s   scroll0    * no way
                move.w  #15,d2     * monochrome: 16 lines in a character
                bra.s   scroll1
scroll0         move.w  #7,d2      * medium: 8 lines in a character            
scroll1         bsr     scr        * perform the scroll
                dbra    d5,exit    * decrease d5, if >= 0: branch
                
* now we have to put a new letter in the buffer

                move.l  #7,d5           * set pixel counter
                clr.l   d4              * clear d4
                move.b  0(a6,d6.w),d4   * get a character
                bne.s   scroll2         * not a null byte
                
                clr.l   d6              * set d6 to zero
                move.b  (a6),d4         * get first character

scroll2         addq.l  #1,d6           * increase character counter
                move.l  4(a0),a1        * a1: buffer address
                move.l  20(a0),a2       * a2: font address
                move.w  d2,d0           * number of words to transfer
scroll3         move.b  0(a2,d4.w),(a1)+  * transfer a byte, increase a1
                clr.b   (a1)+           * clear next byte
                add.l   #256,a2         * next character line
                dbra    d0,scroll3      * decrease d0, >= 0: branch
                
* end of our routine, update values and return to GfA

exit            move.l  d5,12(a0)       * update values
                move.l  d6,16(a0)
                rts                     * back to GfA

* scr
* do the actual scrolling

scr             move.l  (a0),a1    * address on screen to scroll
                move.l  4(a0),a2   * buffer where letter comes from

                cmp.b   #2,d1      * monochrome?
                beq     scr2
 
* now: the medium res scroller
       
                move.w  #7,d0      * 8 scanlines to scroll
scr1            lsl.w   (a2)+      * scroll letter buffer
                roxl.w  156(a1)    * scroll screen
                roxl.w  152(a1)
                roxl.w  148(a1)
                roxl.w  144(a1)
                roxl.w  140(a1)
                roxl.w  136(a1)
                roxl.w  132(a1)
                roxl.w  128(a1)
                roxl.w  124(a1)
                roxl.w  120(a1)
                roxl.w  116(a1)
                roxl.w  112(a1)
                roxl.w  108(a1)
                roxl.w  104(a1)
                roxl.w  100(a1)
                roxl.w  96(a1)
                roxl.w  92(a1)
                roxl.w  88(a1)
                roxl.w  84(a1)
                roxl.w  80(a1)
                roxl.w  76(a1)
                roxl.w  72(a1)
                roxl.w  68(a1)
                roxl.w  64(a1)
                roxl.w  60(a1)
                roxl.w  56(a1)
                roxl.w  52(a1)
                roxl.w  48(a1)
                roxl.w  44(a1)
                roxl.w  40(a1)
                roxl.w  36(a1)
                roxl.w  32(a1)
                roxl.w  28(a1)
                roxl.w  24(a1)
                roxl.w  20(a1)
                roxl.w  16(a1)
                roxl.w  12(a1)
                roxl.w   8(a1)
                roxl.w   4(a1)
                roxl.w    (a1)
                add.l   #160,a1         * down one scanline
                dbra    d0,scr1         * repeat
                rts

scr2            move.w  #15,d0      	* 16 scanlines to scroll
scr3            lsl.w   (a2)+      	* scroll from buffer
                roxl.w  78(a1)     	* into screen
                roxl.w  76(a1)
                roxl.w  74(a1)
                roxl.w  72(a1)
                roxl.w  70(a1)
                roxl.w  68(a1)
                roxl.w  66(a1)
                roxl.w  64(a1)
                roxl.w  62(a1)
                roxl.w  60(a1)
                roxl.w  58(a1)
                roxl.w  56(a1)
                roxl.w  54(a1)
                roxl.w  52(a1)
                roxl.w  50(a1)
                roxl.w  48(a1)
                roxl.w  46(a1)
                roxl.w  44(a1)
                roxl.w  42(a1)
                roxl.w  40(a1)
                roxl.w  38(a1)
                roxl.w  36(a1)
                roxl.w  34(a1)
                roxl.w  32(a1)
                roxl.w  30(a1)
                roxl.w  28(a1)
                roxl.w  26(a1)
                roxl.w  24(a1)
                roxl.w  22(a1)
                roxl.w  20(a1)
                roxl.w  18(a1)
                roxl.w  16(a1)
                roxl.w  14(a1)
                roxl.w  12(a1)
                roxl.w  10(a1)
                roxl.w   8(a1)
                roxl.w   6(a1)
                roxl.w   4(a1)
                roxl.w   2(a1)
                roxl.w    (a1)
                add.l   #80,a1          * down 1 scanline = 80 bytes
                dbra    d0,scr3         * next scanline please!
                rts