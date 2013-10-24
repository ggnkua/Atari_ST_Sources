packed_adr = $30000
length = $1234

	lea	packed_adr,a0
	move.l	#length,d0
	bsr	unpack


;---------------------------------------------------------------
unpack:	  movem.l   d0-d7/a0-a6,-(sp)
          move.l    d0,packed_length
          move.l    d0,actual_length
	  move.l    a0,load_addr
          btst      #0,d0		; odd length: not packed
          bne       end_read
          move.l    a0,d7		; odd address of buffer
          btst      #0,d7
          bne       end_read
          adda.l    d0,a0
          move.l    -(a0),d0  		; check if crunched file
          cmpi.l    #'JEK!',d0          ; crunched, last Longw. = 'JEK!'
          bne       end_read
          move.l    -(a0),actual_length
          subq.l    #4,packed_length
          move.l    load_addr(pc),a0
          adda.l    packed_length(pc),a0
          move.l    load_addr(pc),a1
          move.l    -(a0),a2
          adda.l    a1,a2
          move.l    -(a0),d5
          move.l    -(a0),d0
          eor.l     d0,d5
L541f8:   lsr.l     #1,d0
          bne.s     L54200
          bsr       L542be
L54200:   bcs.s     L54242
          moveq     #8,d1
          moveq     #1,d3
          lsr.l     #1,d0
          bne.s     L5420e
          bsr       L542be
L5420e:   bcs.s     L5426e
          moveq     #3,d1
          clr.w     d4
L54214:   bsr       L542ca
          move.w    d2,d3
          add.w     d4,d3
L5421c:   moveq     #7,d1
L5421e:   lsr.l     #1,d0
          bne.s     L54226
          bsr       L542be
L54226:   roxl.l    #1,d2
          dbra      d1,L5421e
          move.b    d2,-(a2)
          dbra      d3,L5421c
          bra.s     L5427c
L5423c:   moveq     #8,d1
          moveq     #8,d4
          bra.s     L54214
L54242:   moveq     #2,d1
          bsr.s     L542ca
          cmpi.b    #2,d2
          blt.s     L54264
          cmpi.b    #3,d2
          beq.s     L5423c
          moveq     #8,d1
          bsr.s     L542ca
          move.w    d2,d3
          move.w    #$c,d1
          bra.s     L5426e
L54264:   move.w    #9,d1
          add.w     d2,d1
          addq.w    #2,d2
          move.w    d2,d3
L5426e:   bsr.s     L542ca
L54272:   subq.l    #1,a2
          move.b    0(a2,d2.w),(a2)
          dbra      d3,L54272
L5427c:   cmpa.l    a2,a1
          blt       L541f8
end_read: 
          movem.l   (sp)+,d0-d7/a0-a6
          move.l    actual_length,d0
	  rts

L542be:   move.l    -(a0),d0
          eor.l     d0,d5
          move.w    #$10,ccr
          roxr.l    #1,d0
          rts       
L542ca:   subq.w    #1,d1
          clr.w     d2
L542ce:   lsr.l     #1,d0
          bne.s     L542dc
          move.l    -(a0),d0
          eor.l     d0,d5
          move.w    #$10,ccr
          roxr.l    #1,d0
L542dc:   roxl.l    #1,d2
          dbra      d1,L542ce
          rts       
actual_length:      
          DC.l 0
load_addr:          
          DC.l 0
packed_length:      
          DC.l 0


