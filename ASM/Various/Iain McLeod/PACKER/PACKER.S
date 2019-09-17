*****************************************************************************
*			Sprite packer : Sprites should be designed with a background	*
*							colour of BLACK so that all black pixels		*
*							are removed and replaced with how many there	*
*							are.Actual pixels are kept with also a count	*
*							of how many there are of those as well.			*
*			E.G : I had 4 large intro sprites totaling 614400 bytes.		*
*				  Now reduced to 105564 = 17.18% saving						*
*				  You can also blit & apply effects quicker					*
*****************************************************************************
*			On Entry.......													*
*			D0 = Handle of input file	D1 = Handle of output file			*
*****************************************************************************
*			By Iain Mcleod	16/10/94	on a FALCON030						*
*			Complied on Lattice C ASM ( was part of a large project )		*
*			Note : Is instructions at lines xx allowed on 68000? (ST)		*
*				   I think so but if not replace with:						*
*				   asl.w	#1,d0											*
*				   xxxx		(a0.l,d0.w),xxx									*
*				   asr.w	#1,d0											*
*****************************************************************************
*			Set TAB to 4													*
*****************************************************************************
*			NOTE : Two external function are ask for :						*
*				   xres > Ask for x resolution of picture-Return in d0		*
*				   yres > Ask for y resolution of picture-Return in d0		*
*			You can make your own method or just delete the line and		*
*			on the following line put the res value into the respective		*
*			register if you are working on the same sizes.					*
*****************************************************************************
*			No header as I've not made one since its part of a project		*
*			Do one yourself if you want to make it executable!				*
*****************************************************************************

			SECTION CODE
			XDEF	@packer
			XREF	@get_xres,@get_yres

			
@packer
			movem.l	d2-d6/a2,-(sp)
			
			move	d0,d2						*d2 = in_handle
			move	d1,d3						*d3 = out_handle

			bsr		@get_xres					*Function to ask for xres
			move	d0,d5						*d5 = xres
			
			bsr		@get_yres					*Function to ask for yres
			move	d0,d6						*d6 = yres
			
_calculate
			bsr		read_line
			
			lea		in_line,a0
			lea		out_line,a1

			bsr		do_calc

			bsr		write_out_line

			subq.w	#1,d6
			bne		_calculate
			
			movem.l	(sp)+,d2-d6/a2
			rts
			
*-----------Read in a line a from the in_file			

read_line
			move	d5,d0
			asl		#1,d0						*True Colour so, xres*2 bytes
			
			pea		in_line
			move.l	d0,-(sp)
			move.w	d2,-(sp)
			move.w	#$3f,-(sp)
			trap	#1
			lea		12(sp),sp

			rts
			
*-----------Alogrythm Code

do_calc
			clr.w	d0
			tst.w	(a0)
			beq		_blank_start
			
_colour_start									*Starting byte are coloured pixels
			move.w	#1,(a1)+
_colour											*It's a coloured pixel
			move.l	a1,a2						*Save position for size of coloured pixels
			addq.l	#2,a1			
			move	d0,d1
_colour_loop			
			cmp.w	d5,d0						*Whole line done?
			beq		_done_colour				
			tst.w	(a0,d0.w*2)					*Is it a black(blank) pixel?
			beq		_finish_colour
			move.w	(a0,d0.w*2),(a1)+			*It's a colored pixel, save in buffer
			addq.w	#1,d0						*Next please...
			bra		_colour_loop
_finish_colour
			sub.w	d0,d1						*Get length of pattern
			neg.w	d1
			move.w	d1,(a2)						*Put at the start of block
			
			bra		_blank
			
_blank_start									*Starting byte is blank
			clr.w	(a1)+
_blank											*It's a blank pixel
			move	d0,d1
_blank_loop
			cmp.w	d5,d0						*Whole line done
			beq		_done_blank
			tst.w	(a0,d0.w*2)					*Pixel still a blank?
			bne		_finish_blank
			addq.w	#1,d0						*Next pixel please...
			bra		_blank_loop
_finish_blank
			addq.w	#1,d0				
			sub.w	d0,d1						*Get length of pattern
			neg.w	d1							
			move.w	d1,(a1)+					*Put size in buffer
			
			bra		_colour
			
_done_colour
			cmp.w	d0,d1
			beq		_done
			sub.w	d0,d1						*Get length of pattern
			neg.w	d1
			move.w	d1,(a1)+					*Put size in buffer
			
			bra		_done
			
_done_blank			
			sub.w	d0,d1						*Get length of pattern
			neg.w	d1
			move.w	d1,(a1)+					*Put size in buffer
			
_done		
			lea		out_line,a2

			rts


*-----------Write the line to the out_file

write_out_line
			lea		out_line,a0					*Get address
			suba.l	a0,a1						*Find length
			move.l	a1,d0						*Put the size in d0
			
			pea		out_line					*And save to disk
			move.l	d0,-(sp)
			move.w	d3,-(sp)
			move.w	#$40,-(sp)
			trap	#1
			lea		12(sp),sp
			
			rts
			
			
************
			
			SECTION BSS
			
in_line		ds.b	1024*2
out_line	ds.b	1024*2
			
		
			END