 OPT l2
;  #[ C Definitions:

 XDEF Display
 XDEF DisplayBuffer

;  #] C Definitions:
 TEXT
;  #[ Display Function:
;
; IN:
; D0 = DSP Word (Lowest 24 Bits)
Display:
 movem.l d3-d5,-(sp)		; Save Used Registers
 addq.b #1,DisplayOffset		; Plot at Last Line (Scroll) ???
 bpl.s .NoScroll		; No -> .NoScroll
.Scroll:			; Scroll Buffer By One Pixel Left
 lea DisplayBuffer,a0		; Get Buffer Address
 moveq #$7f,d5		; Loop on 128 Lines
.ScrollLoop:
 movem.l (a0)+,d1-d4		; Get One Line
 add.l d4,d4			; Scroll Left 
 addx.l d3,d3
 addx.l d2,d2
 addx.l d1,d1
 movem.l d1-d4,-$10(a0)		; Put Scrolled Line
 dbf d5,.ScrollLoop		; Loop
 subq.b #1,DisplayOffset		; DisplayOffset is 127, not 128
.NoScroll:
 moveq #0,d1
 swap d0			; Get DSP High Byte
 ext.w d0			; Extend Word
 asr.w #1,d0			; Convert (-128->+127) to (-64->+63)
; addx.w d1,d0
 neg d0
 negx d0
 lsl.w #4,d0			; Convert To Y Offset
 moveq #0,d1
 move.b DisplayOffset,d1
 lea DisplayBuffer+$400,a0		; Get Buffer Middle Pointer
 move.w d1,d2
 and.w #7,d1
 eor.w d1,d2
 lsr.w #3,d2			; Calculate X Offset
 add.w d2,d0			; Add To X Offset
 not.w d1
 and.w #7,d1			; Get bit Number
 bset d1,0(a0,d0.w)		; And Set It
.DrawBar:
 lea DisplayBuffer+$400,a0		; Display Middle Bar
 moveq #-1,d0
 move.l d0,(a0)+
 move.l d0,(a0)+
 move.l d0,(a0)+
 move.l d0,(a0)
 movem.l (sp)+,d3-d5		; Restore Registers
 rts			; And Return To Caller

;  #] Display Function:
 BSS
;  #[ BSS Section:

DisplayBuffer:
 ds.b $800			; (128*128)/8

DisplayOffset:
 ds.b 1

 EVEN

;  #] BSS Section:
 END
