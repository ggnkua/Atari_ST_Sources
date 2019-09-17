


			include		tosmacro.s
			

******  Go into supervisor mode and install routine in VBL  ******			
			
			
			supexec		#install						
			


******	This section forms a binary string in "buffer"  ******

loop		move.l		Abuff,d0			* Load in Results for pad A, found in long word at Abuff
			move.l		#31,d1				* Counter for 32 bits
			move.l		#buffer,a0			* Address of buffer where string is built up
			
loop1		btst		d1,d0				* Test next bit
			beq			zero				* Branch if its a zero
			move.b		#$31,(a0)+			* If not then send a "1" to buffer
			jmp			nxtbit				* Now we deal with the next bit
			
zero		move.b		#$30,(a0)+			* Send a "0" to buffer
			
nxtbit		dbf			d1,loop1			* Reduce counter by one (points to next bit)



******  Now we can print the string from the buffer  ******

			
			vsync							* Wait for Vblank
			
			c_conws		#buffer				* Print the 32 bits
			
			
******  See if * and # are being pressed on the joypad  ****** 
			
			move.l		Abuff,d0			* Test for reset
			cmpi.l		#$1010,d0
			beq			out					* And finish if found
			
			bra			loop				* If not then go round again
						
out			supexec		#restore			* Go into supervisor and restore VBL queue
			
			p_term0							* Quit
								
			
			
******  Install the joypad routine in the VBL queue  ******


install		move.l		#$4ce,a5			* Pointer to VBL queue

next		move.l		(a5)+,d0			* Look for an empty slot
			bne			next				* If its not empty try again
			move.l		#jtest,-(a5)		* If it is then load in our VBL routine
			move.l		a5,vblslot			* Save address of the slot we use
			rts								* Finish with supervisor mode
			
			
			
******  Restore the VBL queue to its original state  ******

restore		move.l		vblslot,a5			* Load address of slot into a5
			clr.l		(a5)				* Clear the slot
			rts
					
			
			
			
******  The joypad test routine  ************************

		
jtest		clr.l		d0
			clr.l		d1
			clr.l		d2
			clr.l		d3
			clr.l		d4
			clr.l		d5
			clr.l		d6
			clr.l		d7

* Test for U,D,L,R,Pause,F0 and put the results into d0 *
			
			move.w		#$ffee,$ff9202		* Test for U,D,L,R,Pause,F0
			move.w		$ff9200,d0			* Results for Pause, F0
			swap		d0					* Make space for $ff9202.w
			move.w		$ff9202,d0			* Results for U,D,L,R
			not.l		d0					* Invert the bits
			andi.l		#$fff00,d0			* Mask off results from rubbish
			

* Test for *,7,4,1,F1 and put the results into d1 *
			
			move.w		#$ffdd,$ff9202		* Test for *,7,4,1,F1
			move.w		$ff9200,d1			* Results for F1
			swap		d1					* Make space for $ff9202
			move.w		$ff9202,d1			* Results for *,7,4,1
			not.l		d1					* Invert the bits
			andi.l		#$aff00,d1			* Mask off results from rubbish
			
			
* Test for 0,8,5,2,F2 and put the results into d2 *

			move.w		#$ffbb,$ff9202		* Test for 0,8,5,2,F2
			move.w		$ff9200,d2			* Results for F2 
			swap		d2					* Make space for $ff9202
			move.w		$ff9202,d2			* Results for 0,5,8,2
			not.l		d2					* Invert the bits
			andi.l		#$aff00,d2			* Mask off the results
			
			
* Test for #,9,6,3,F3 and put the results into d3 *

			move.w		#$ff77,$ff9202		* Test for #,9,6,3,F3
			move.w		$ff9200,d3			* Results for F3
			swap		d3					* Make space for $ff9202
			move.w		$ff9202,d3			* Results for #,9,6,3,F3
			not.l		d3					* Invert the bits
			andi.l		#$aff00,d3			* Mask off the results
			
			
** Move the results for U,D,L,R,Pause,F0 for pad A into d5 **

			move.l		d0,d4				* Use d4 as temporary store
			andi.l		#$30f00,d4			* Mask off pad B bits
			ror.w		#8,d4				* Rotate bits into correct position
			eor.l		d4,d5				* put them into d5
			
** Move the results for U,D,L,R,Pause,F0 for pad B into d7 **

			move.l		d0,d6				* Use d6 as temporary store
			andi.l		#$cf000,d6			* Mask off pad A bits
			ror.l		#2,d6				* Rotate bits to correct position
			ror.w		#8,d6
			ror.b		#2,d6
			eor.l		d6,d7				* put them into d7
			
** Move the results for *,7,4,1,F1 for pad A into d5 **

			move.l		d1,d4				* d4 is temp store
			andi.l		#$20f00,d4			* Mask off pad B bits
			ror.w		#4,d4				* Rotate bits into position
			eor.w		d4,d5				* put them into d5
			andi.l		#$20000,d4			* Mask off bits
			rol.l		#1,d4				* Rotate into position
			eor.l		d4,d5				* put them into d5
			
** Move the results for *,7,4,1,F1 for pad B into d7 **

			move.l		d1,d6				* d6 is temp store
			andi.l		#$8f000,d6			* Mask off pad A bits
			ror.w		#8,d6				* Rotate bits into position
			eor.b		d6,d7				* Put them into d7
			andi.l		#$80000,d6			* Mask bits
			ror.l		#1,d6				* Rotate into position
			eor.l		d6,d7				* put into d7
			
** Move the results for 0,8,5,2,F2 for pad A into d5 **

			move.l		d2,d4				* d4 is temp store
			andi.l		#$20f00,d4			* Mask off pad B bits
			eor.w		d4,d5				* put them into d5
			andi.l		#$20000,d4			* Mask bits
			rol.l		#2,d4				* Rotate into position
			eor.l		d4,d5				* put them into d5
			
** Move the results for 0,8,5,2,F2 for pad B into d7 **

			move.l		d2,d6				* d6 is temp store
			andi.l		#$8f000,d6			* Mask off pad A bits
			ror.w		#4,d6				* Rotate bits into position
			eor.l		d6,d7				* put them into d7
			
** Move the results for #,9,6,3,F3 for pad A into d5 **

			move.l		d3,d4				* d4 is temp store
			andi.l		#$20f00,d4			* Mask off pad B bits
			rol.w		#4,d4				* Rotate bits into position
			eor.w		d4,d5				* put into d5
			andi.l		#$20000,d4			* Mask bits
			rol.l		#3,d4				* Rotate into position
			eor.l		d4,d5				* put into d5
			
** Move the results for #,9,6,3,F3 for pad B into D7 **

			move.l		d3,d6				* d6 is temp store
			andi.l		#$8f000,d6			* Mask off pad A bits
			eor.w		d6,d7				* put bits into d7
			andi.l		#$80000,d6			* Mask bits
			rol.l		#1,d6				* Rotate into posiion
			eor.l		d6,d7				* Put bits into d7
			

** Now move the full results for both pads into buffers **

			move.l		d5,Abuff
			move.l		d7,Bbuff
			
						  							
			
			rts								* VBL routine finished !
			
**********************************************************************				
				
				
Abuff		ds.l		1
Bbuff		ds.l		1
save_sp		ds.l		1
vblslot		ds.l		1
buffer		ds.b		32
			dc.b		27,89,32,32,27,102,0
