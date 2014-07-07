; Convert bit reverse order to normal order in-place 
data      equ	$400
points    equ   512
org       p:$40
;          move 	#0,r1
;          move	#-1,m0				;linear address for initialization x memory
;          move	#data,r0			;get output buffer address
;          do		#512,loop
;          move	r1,x:(r0)+
;          move  (r1)+
;loop
          move	#data,r0			;get output buffer address
          move 	#0,m0				;bit reverse address
          move	#points/2,n0			;half of FFT length
          move	#data+1,r4			;don't swap first data
          move	#-1,m4				;linear addressing
          move	(r0)+n0				;point to the first srambled data
          do 	#points/2,bitrev		;do N/2 swap
          move	r4,y0				;to determine swap or not
          move	r0,a				;to determine swap or not
          cmp 	y0,a				;if r0 less than r4 no swap
          jle	 	incr	
          move	x:(r4),a1
          move	x:(r0),b1
          move	a1,x:(r0)+n0
          move	b1,x:(r4)+
          jmp		wast	
incr	  move	(r0)+n0				;increment r0 and r4
          move	(r4)+
wast	  nop
bitrev
