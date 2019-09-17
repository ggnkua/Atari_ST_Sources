*****************************************************************************
*			BLOCK UNPACKER - use blockpac.s with a memory image				*
*							 of sprite.										*
*						   - this unpacks to screen & will use the 			*
*							 following alogrythm...							*
*****************************************************************************
*			On Entry.......													*
*			A0 = Address of Screen		A1 = Address of packed data			*
*			D0 = X Width				D1 = Y Height						*
*****************************************************************************
*			By Iain Mcleod	16/10/94	on a FALCON030						*
*			Complied on Lattice C ASM ( was part of a large project )		*
*			Note : Is instruction at line 55 allowed on 68000? (ST)			*
*				   I think so but if not replace with:						*
*				   asl.w	#1,d3											*
*				   lea		(a0.l,d3.w),a0									*
*****************************************************************************
*			Set TAB to 4													*
*****************************************************************************
*			No header as I've not made one since its part of a project.		*
*			Do one yourself if you want to make it executable!				*
*****************************************************************************



			SECTION TEXT
			XDEF	@unpack					*I'm passing by Register args - replace all
											*with _unpack if by stack only on lattice C
@unpack
			movem.l	d2-d3,-(sp)
			
			bsr		do_calc

			movem.l	(sp)+,d2-d3
			
			rts
			
			
*-----------Unpack to screen alogrythm

do_calc
			clr.w	d2					*d2 = X counter
			tst.w	(a1)+				*Start of line is blank or actual data?
			beq		.blank				
			
.coloured
			move.w	(a1)+,d3			*d3 = No. of coloured pixels
			beq		.blank				*If 0 then goto Blank - slight mishap in packer code!
			add.w	d3,d2				*d2 = How far along screen now
			subq.w	#1,d3				*Counts down including zero
.colour_loop
			move.w	(a1)+,(a0)+
			dbra	d3,.colour_loop
			
			cmp.w	d2,d0				*Reached width of screen?
			beq		.done_line			*Next line please...

.blank		
			move	(a1)+,d3
			add.w	d3,d2				*d2 = How far along screen now
			lea		(a0,d3*2),a0		*Add offset onto screen pointer 
										* See above on this INSTRUCTION if using ST
			
			cmp.w	d2,d0				*Reached width of screen?
			beq		.done_line			*Next line please...
			bra		.coloured			*Else more...
			
.done_line
			subq.w	#1,d1				*Done that line
			bne		do_calc				*Again if more.
			
			rts


			END
