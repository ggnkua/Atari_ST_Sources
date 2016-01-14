

;
; Depacking description
;
 rsreset
depack_source		rs.l 1	; Pointer to the source (compressed)
depack_destination	rs.l 1	; Pointer to the destination (decompressed)
depack_size			rs.l 1 	; Size of the decompressed data


 SECTION TEXT

 even
  
; a0=Source (compressed) data
; a1=Destination buffer 
; d0.l=destination buffer size
DepackDelta
 movem.l d0-a6,-(sp)
 
 lea DepackDeltaTable,a2
 move.b (a0)+,d1	; Start value
 eor.b #$80,d1		; Sign change
 move.b d1,(a1)+

 moveq #0,d2
.loop 
 REPT 4
 move.b (a0)+,d2	; Fetch two nibbles
 
 add.b (a2,d2),d1
 move.b d1,(a1)+

 lsr #4,d2
 add.b (a2,d2),d1
 move.b d1,(a1)+
 ENDR
 
 subq.l #2*4,d0
 bpl.s .loop
   
 movem.l (sp)+,d0-a6
 rts
 
 
; a0=pointer on the first depack description block 
; d0=number of blocks to depack
DepackBlockMulti
 subq #1,d0
.loop
 movem.l d0/a0,-(sp)
 bsr DepackBlock
 movem.l (sp)+,d0/a0
 lea 12(a0),a0
 dbra d0,.loop
 rts
 
 
; a0=pointer on the depack description block 
DepackBlock
 movem.l d0/a0/a1,-(sp)
 move.l depack_destination(a0),a1
 move.l depack_size(a0),d0
 move.l depack_source(a0),a0
 bsr DepackLz77
 movem.l (sp)+,d0/a0/a1
 rts
 
; a0=Source (compressed) data
; a1=Destination buffer 
; d0.l=destination buffer size
DepackLz77
 movem.l d0/a0/a1,-(sp)
 
 moveq #0,d1	; mask
 moveq #0,d3
 moveq #0,d4
 
.loop 
 ; Test mask
 add.b d1,d1		; Adjust mask
 bne.s .mask_ok
 ; Init mask and reload value
 moveq #1,d1
 move.b (a0)+,d2	; value
.mask_ok 

 ; Test single byte copy
 lsr.b #1,d2
 bcc.s .copy_single_byte

.copy_from_offset 
 ; temp clearing, just to get it to work
 moveq #0,d5
 move.b (a0)+,d3	; Offset, low byte
 move.b (a0)+,d4	; Offset, high nibble (top four bits: count)
 
 move.b d4,d5
 lsr.b #4,d5
 addq.b #3,d5		; Final size
 sub.l d5,d0		; Adjust size
 
 and.b #$0f,d4
 lsl.w #8,d4
 or.w d3,d4
 addq.w #1,d4		; Get fulloffset
   
 move.l a1,a2		; Copy dest
 sub d4,a2			; -Offset
  
 add.w d5,d5		; Jump into unrolled string copy loop
 neg.w d5
 jmp .unroll(pc,d5.w)

 REPT 18
 move.b	(a2)+,(a1)+
 ENDR
.unroll
 
 tst.l d0
 bpl.s .loop
 movem.l (sp)+,d0/a0/a1
 rts
 

.copy_single_byte
 move.b (a0)+,(a1)+
 subq.l #1,d0		; Adjust size
 bpl.s .loop
 movem.l (sp)+,d0/a0/a1
 rts

	
 SECTION DATA
 
 even

DepackDeltaTable
 REPT 16
 dc.b -64
 dc.b -32
 dc.b -16
 dc.b -8
 dc.b -4
 dc.b -2
 dc.b -1
 dc.b 0
 dc.b 1
 dc.b 2
 dc.b 4
 dc.b 8
 dc.b 16
 dc.b 32
 dc.b 64
 dc.b 127
 ENDR
 
 	