
;
; Ste timings and MegaSTE issues:
;  >Start: 8 cycles
;  >Every read/write: 4 cycles
;
; http://www.freelists.org/post/steem/steem-Blitter-timing,1
; http://www.atari-forum.com/wiki/index.php/Blitter_execution_times
; move.b #mlinebusy,$ffff8a3c.w	  -> 38 nops
; move #1,$ffff8a38.w		  -> 4

blitter_start_adress equ $ffff8a00

 rsreset
blitter_halftone	rs.w 16		; $ffff8a00 16 words defining a display mask (see blitter_hop)  
blitter_src_xinc	rs.w 1		; $ffff8a20 offset in bytes to the next source word
blitter_src_yinc	rs.w 1      ; $ffff8a22 offset in bytes to the next source line
blitter_src_addr	rs.l 1      ; $ffff8a24 source adress
blitter_endmask1	rs.w 1      ; $ffff8a28 
blitter_endmask2	rs.w 1      ; $ffff8a2a 
blitter_endmask3	rs.w 1      ; $ffff8a2c 
blitter_dst_xinc	rs.w 1		; $ffff8a2e destination offset between words
blitter_dst_yinc	rs.w 1      ; $ffff8a30 destination offset between lines
blitter_dst_addr	rs.l 1      ; $ffff8a32 destination adress
blitter_xcount		rs.w 1      ; $ffff8a36 numbers of words
blitter_ycount		rs.w 1      ; $ffff8a38 number of lines
blitter_hop			rs.b 1      ; $ffff8a3a halftone operation (0=all ones, 1=halftone, 2=source, 3=source AND halftone)
blitter_operation	rs.b 1      ; $ffff8a3b logical operation (0-15, see BITBLT)
blitter_control		rs.b 1		; $ffff8a3c 0-3=LineNum (define halftone offset), 5=Smudge, 6=Hog (1=exclusive,0=50/50) 7=Busy(set to start the blitter)
blitter_skew		rs.b 1		; $ffff8a3d 0-3=shift of data, 6=NoFinalSourceRead, 7=ForceExtraSourceRead

valeur_hop=3
valeur_op=3
flinebusy=7
mlinebusy=128+64
SMUDGE=32
mskewfxsr=$80
mskewnfsr=$40

; Uses d0 and a6
; Assumes a5 points on the blitter registers
BLITIT macro
 lea blitter_control(a5),a6
 move.b #128,(a6)		; Start the blitter in BUS sharing mode
 moveq.l #7,d0
.\@
 bset.b d0,(a6)
 nop
 nop
 bne.s .\@
 endm



 SECTION TEXT
 
 even


 
; a0=source
; a1=destination
; d0=width in words
; d1=height 
; d2=stride source
; d3=stride dest
BlitterCopyBlock
 COLORHELP #$020

 lea $ffff8a00.w,a5
   
 move #$ffff,blitter_endmask1(a5)
 move #$ffff,blitter_endmask2(a5)
 move #$ffff,blitter_endmask3(a5)
 
 move d0,blitter_xcount(a5)
  
 ; 
 ; Copy the 4 bitplans, ine one go
 ;
 move #2,blitter_dst_xinc(a5)
 move #2,blitter_src_xinc(a5)
 
 move d2,blitter_src_yinc(a5)
 move d3,blitter_dst_yinc(a5)
 
 move.b #0,blitter_skew(a5)
 move.b #2,blitter_hop(a5)			; Source
 move.b #3,blitter_operation(a5)	; Source
 
 move.l a0,blitter_src_addr(a5)
 move.l a1,blitter_dst_addr(a5)
     
 move d1,blitter_ycount(a5)
   
 move.b #mlinebusy,blitter_control(a5)
  
 COLORHELP #$000 
 rts 

  
; a0=source
; a1=destination
; a2=mask
; d0=width in words
; d1=height 
; d2=stride source
; d3=stride dest
; d4=pixel offset
BlitterDrawSprite
 COLORHELP #$200

 lea $ffff8a00.w,a5

 move #2*4,blitter_dst_xinc(a5)
   
 move #$ffff,d7
 move d7,blitter_endmask1(a5)
 move d7,blitter_endmask2(a5)
 move d7,blitter_endmask3(a5)
 
 tst.b d4
 beq.s .no_shift
 lsr d4,d7
 move d7,blitter_endmask1(a5)
 not d7
 move d7,blitter_endmask3(a5)
  
 ;or.b #mskewfxsr,d4		; Force eXtra Source Read
 addq #1,d0				; One more word on the plan count
 subq #8,d2
 subq #8,d3
.no_shift 

 move d0,blitter_xcount(a5)
 
 COLORHELP #$300
 
 ;jmp .end_mask 
 ;
 ; Mask out the background, using the mask
 ;
 cmp.l #0,a2
 beq.s .end_mask
 move d2,d6
 lsr #2,d6
 move d6,blitter_src_yinc(a5)
 move d3,blitter_dst_yinc(a5)
 
 move.b d4,blitter_skew(a5)
 move.b #2,blitter_hop(a5)			; Source
 move.b #1,blitter_operation(a5)			; Source AND Destination
 
 move.l a1,a3
 move #2,blitter_src_xinc(a5)
 moveq #4-1,d7
.loop_mask
 move.l a2,blitter_src_addr(a5)
 move.l a3,blitter_dst_addr(a5)

 lea 2(a3),a3
  
 move d1,blitter_ycount(a5)
   
 move.b #mlinebusy,blitter_control(a5)
 ;BLITIT 
 COLORSWAP

 dbra d7,.loop_mask
.end_mask 

 COLORHELP #$003
 
 ; 
 ; Copy the 4 bitplans, one plan at a time
 ;
 move #2*4,blitter_src_xinc(a5)
 
 move d2,blitter_src_yinc(a5)
 move d3,blitter_dst_yinc(a5)
 
 move.b d4,blitter_skew(a5)
 move.b #2,blitter_hop(a5)			; Source
 move.b #7,blitter_operation(a5)			; Source OR Destination
 
 moveq #4-1,d7
.loop 
 move.l a0,blitter_src_addr(a5)
 move.l a1,blitter_dst_addr(a5)
     
 move d1,blitter_ycount(a5)
   
 move.b #mlinebusy,blitter_control(a5)
 ;BLITIT  
 COLORSWAP

 lea 2(a0),a0
 lea 2(a1),a1
  
 dbra d7,.loop
  
 COLORHELP #$000
 rts 
 
  
; a0.l=destination
; d0.w=x0
; d1.w=y0
; d2.w=x1 (non included)
; d3.w=y1 (non included)
; d4.w=color / color index / bitplan masks
BlitterDrawRectangle
 COLORHELP #$200
 movem.l d0-a6,-(sp)

 lea $ffff8a00.w,a5
 
 ; Start vertical position added to the adress 
 move d1,d7
 mulu blit_stride,d7
 add.l d7,a0

 ; Compute maskes 
 moveq.l #-1,d7
 
 ; Middle mask
 move d7,blitter_endmask2(a5)
 
 ; Right mask
 move d2,d6
 and #15,d6
 lsr d6,d7
 not d7
 move d7,d5	
 
 ; Left mask
 move d0,d6
 and #15,d6
 swap d7
 lsr d6,d7

 ; Compute start position and width
 lsr #4,d0
 lsl #3,d0
 add d0,a0
 lsr #4,d2
 lsl #3,d2
 sub d0,d2	; Number of bytes between the two adresses
 lsr #3,d2	; Number of words per plan (/2 /4)
 bne.s .end_merge
.merge_masks
 and d5,d7
.end_merge 
 move d7,blitter_endmask1(a5)
 move d5,blitter_endmask3(a5)
 
 addq #1,d2	; +1
 move d2,blitter_xcount(a5)
     
 move blit_stride,d7
 lsl #3,d2
 sub d2,d7
 add #2*4,d7
 move d7,blitter_dst_yinc(a5)
    
 sub d1,d3	; Number of lines to draw
 beq.s .end_draw
 
 move #2*4,blitter_dst_xinc(a5)
        
 move.b #0,blitter_skew(a5)
 move.b #1,blitter_hop(a5)			; Halftone only
 move.b #3,blitter_operation(a5)			; Source (haltone) only
 
 moveq #4-1,d7
.loop_plan
  
 ; Get the color
 moveq #0,d0
 lsr #1,d4
 subx.l d0,d0	; Value for this bitplan (0000 or ffff)
 
 ; Check the plan
 swap d4
 lsr #1,d4
 bcc .skip_plane 
 
 ; Set color in the halftone memory
offset set 0 
 REPT 8
 move.l d0,offset(a5)
offset set offset+4
 ENDR

 ; Launch the blitter  
 move.l a0,blitter_dst_addr(a5)
 move d3,blitter_ycount(a5)
 ;move.b #mlinebusy,blitter_control(a5)
 ;bsr BlitIt
 BLITIT 
 
.skip_plane 
 lea 2(a0),a0
 swap d4
 dbra d7,.loop_plan

.end_draw
    
 movem.l (sp)+,d0-a6
 COLORHELP #$000
 rts 
  
  
; input: 
; d0.w=x pos
; d1.w=y pos 
; output:
; d2.l=final offset
ComputeScreenOffset
 moveq.l #0,d2
 lsr.w #4,d0
 lsl.w #3,d0
 add.w d0,d2

 mulu blit_stride,d1
 add.l d1,d2  
 rts
  
  