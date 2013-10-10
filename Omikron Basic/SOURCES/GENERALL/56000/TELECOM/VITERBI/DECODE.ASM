;This program is a Viterbi Decoder for V.32.  There is a 16
;time period delay which will approach the maximum possible 
;gain for this type of encoder.
	page 132,66,3,3,0
	opt cex
	org l:$0000

period	dsm  	128
location dsm	32
input	dsm	16
tables	dsm	8
temp	dsm	8
endlong	equ	*
	org x:endlong
storr6	ds	1
	org x:512
boundry1	ds	32
boundry2	ds	32
boundry3	ds	32
boundry4	ds	32
boundry5	ds	32
boundry6	ds	32
boundry7	ds	32
boundry8	ds	32
boundry9	ds	32
boundry10	ds	32
boundry11	ds	32
boundry12	ds	32
boundry13	ds	32

start	equ	$40
four    equ     $200000
three	equ	$180000
two	equ	$100000
one	equ	$080000
zero	equ	$000000
mone	equ	$f80000
mtwo	equ	$f00000
mthree	equ	$e80000
mfour	equ	$e00000
large	equ	.9
small	equ	.1
offset	equ	$010000

	org	p:start
	jsr 	initialize
	do 	#115,endrun
	jsr	readdata
	jsr	findmindist
	jsr	accumdist
	jsr	traceback
	jsr 	outputdata
endrun

;this initialization routine initializes register and modifiers
;as well as clearing the memeory.
;the constellation is also loaded into memory here.
;the accumulated distance array is set so that state zero starts out
;at a value of zero and all others start out larger, forcing the paths
;to merge at the zero states.

initialize
	move	#127,m1
	move	#127,m5
	move	#15,m6
	move	#0,r1
	clr 	b       #$0,r0
	clr 	a	r0,r5
	do #256,clrmem
	move 	a,x:(r0)+	b,y:(r5)+
clrmem
	move 	#tables+1,r7
	move	#$400000,a1
	rep #7
	move 	a1,x:(r7)+

	move	#input,b1
	move	b1,x:storr6  


;Now load full scale values of the constellationin the table location.
  

	move 	#location,r0
	move 	r0,r4
	move 	#mfour,a
	move	#one,b
	move 	a,x:(r0)+	b,y:(r4)+	
	move 	#zero,a
	move	#mthree,b	
	move	a,x:(r0)+	b,y:(r4)+
	move	#one,b
	move	a,x:(r0)+	b,y:(r4)+
	move  	#four,a       	
	move	a,x:(r0)+	b,y:(r4)+
	move   	#mone,b
	move 	a,x:(r0)+	b,y:(r4)+
	move	#zero,a
	move	#three,b
	move	a,x:(r0)+	b,y:(r4)+ 
	move	#mone,b
	move	a,x:(r0)+	b,y:(r4)+  
	move	#mfour,a
	move	a,x:(r0)+	b,y:(r4)+
	move 	#mtwo,a
	move	#three,b
	move	#mone,y1
	move	a,x:(r0)+	b,y:(r4)+
	move	a,x:(r0)+	y1,y:(r4)+
	move	#two,a
	move	a,x:(r0)+	b,y:(r4)+
	move	a,x:(r0)+	y1,y:(r4)+
	move	#one,b
	move	#mthree,y1
	move	a,x:(r0)+	y1,y:(r4)+
	move	a,x:(r0)+	b,y:(r4)+
	move	#mtwo,a
	move	a,x:(r0)+	y1,y:(r4)+
	move	a,x:(r0)+	b,y:(r4)+
	move	#one,a
	move	a,x0
	move	#mthree,a
	move	#two,b
	move	b,y0
	move	#mtwo,b
	move	a,x:(r0)+	b,y:(r4)+
	move	x0,x:(r0)+	b,y:(r4)+
	move	a,x:(r0)+	y0,y:(r4)+
	move	x0,x:(r0)+	y0,y:(r4)+
	move 	#three,a
	move	a,x0
	move	#mone,a
	move	x0,x:(r0)+	y0,y:(r4)+
	move	a,x:(r0)+	y0,y:(r4)+
	move	x0,x:(r0)+	b,y:(r4)+
	move	a,x:(r0)+	b,y:(r4)+
	move	#one,a
	move	#zero,b
	move	b,y0
	move	#four,b
	move	a,x:(r0)+	b,y:(r4)+
	move	#mthree,x0
	move	x0,x:(r0)+	y0,y:(r4)+
	move	a,x:(r0)+	y0,y:(r4)+
	move	#mfour,b
	move	a,x:(r0)+	b,y:(r4)+
	move	#mone,a
	move	a,x:(r0)+	b,y:(r4)+
	move	#three,x0
	move	x0,x:(r0)+	y0,y:(r4)+
	move	a,x:(r0)+	y0,y:(r4)+ 
	move	#four,b
	move	a,x:(r0)+	b,y:(r4)+
	rts

;readdata reads in the data from a simulator file.  Since it is read in as
;a point on the constellation, it must be converted to real and imaginary
;componenets by indexing into a table.
;it is also offfset by a value "offset" so it is not considered to be perfect
;data.

readdata
	move	y:$efe,a
	move	a,n2
	move    #location,r2
	move	x:storr6,r6
	lua	(r2)+n2,r4
	move	#>offset,x0
	move	x:(r4),a
	add	x0,a	y:(r4),b
	add	x0,b 	a,x:(r6)
	move	b,y:(r6)+
	move	r6,x:storr6
	rts

;the minimum distance is found to the closest point in every state and stored.
;the values are stored so that indexing is made easier, state 0,2,3,1,4,7,6,5.
;this will greatly reduce the number of cycles needed later.
;a smoothing function is used to accumulate distances in the accumulated    
;table so this minimum distance is multiplied by .1.

findmindist
	
	move	x:-(r6),a	
	move	#one,x0
	cmpm	x0,a	y:(r6),b
	jgt	bigone	;x>1
	cmpm	x0,b	#boundry1,r2
	jlt	continue	;x<1,y<1, load r2 with boundry 1 and continue
	move	#two,x1
	cmpm	x1,b	#boundry4,r2
	jlt	continue	;x<1,y>1andy<2, load r2 with boundry4, go on
	move	#boundry6,r2
	jmp	continue	;x<1,y>2, load r2 with boundry6 and continue
bigone	move #two,x1	
	cmpm	x1,a
	jgt	bigtwo		;x>2, jmp to that case
	cmpm	x0,b	#boundry2,r2
	jlt	continue	;x>1 ans x<2, y<1 load boundry2 and continue
	cmpm	x1,b	#boundry5,r2
	jlt	continue	;x>1,y<2 load boundry 5 and continue
bigtwo	cmpm	x0,b	#boundry3,r2
	jlt	continue	;x>2 and y<1 so load boundry3 and continue
	abs	a	#two,y0
	abs	b	a,x1
	sub	y0,a	b,y1	
	sub	x0,b
	cmpm	a,b	y1,b
	jgt	greatery1
	cmp	y0,b	#boundry7,r2
	jlt	continue 
	move	#boundry12,r2
	jmp	continue
greatery1	sub	y0,b	x1,a	
	sub	x0,a	
	cmpm	a,b	x1,a	
	jgt	greatery2
	cmp	y0,a	#boundry10,r2
	jlt	continue
	move	y1,b
	cmp	y0,b	#boundry11,r2
	jlt	continue
	move	#boundry9,r2
	jmp	continue
greatery2	cmp	y0,a	#boundry8,r2
	jlt	continue
	move	#boundry13,r2
continue	clr	a	x:(r6),x1
	cmp	x1,a	y:(r6),y1
	jgt	negx
	cmp	y1,a	#24,n2
	jgt	posxnegy
posxposy	jmp findist
posxnegy	move	x:(r2)+n2,x0	;update r2 by 24
	jmp findist
negx	cmp	y1,a	#8,n2
	jgt	negxnegy
negxposy	move	x:(r2)+n2,x0	;update r2 by 8
	jmp findist
negxnegy	move	x:(r2)+n2,x0	;update r2 by 16
	move	x:(r2)+n2,x0
findist
	move	x:(r2)+,r0
	move	#tables,r4
	move	x:(r0),a
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0	
	move	#small,x0	a,y0
	mpy	x0,y0,a	
	move	x:(r0),a	a,y:(r4)+
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0	y:(r4)+,y0	
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0	
	move	#small,x0	a,y0	
	mpy	x0,y0,a	y:(r4)+,b	
	move	x:(r0),a	a,y:(r4)-
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0	y:(r4)-,y0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0
	move	#small,x0	a,y0
	mpy	x0,y0,a		
	move	x:(r0),a	a,y:(r4)+
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0
	move	#small,x0	a,y0
	mpy	x0,y0,a	
	move	x:(r0),a	a,y:(r4)+
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0	y:(r4)+,y0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0
	move	#small,x0	a,y0	
	mpy	x0,y0,a	
	move	x:(r0),a	a,y:(r4)+
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0	y:(r4)+,y0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a		x:(r2)+,r0
	move	#small,x0	a,y0	
	mpy	x0,y0,a		y:(r4)+,b
	move	x:(r0),a	a,y:(r4)-
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0
	move	#small,x0	a,y0
	mpy	x0,y0,a	
	move	x:(r0),a	a,y:(r4)-
	sub	x1,a	y:(r0),b
	sub	y1,b	a,x0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a	x:(r2)+,r0	
	move	#small,x0	a,y0
	mpy	x0,y0,a
	move	a,y:(r4)




	rts  

;the accumulted distance routine  adds the smallest distance from the         
;previously computed table for all pathes going into a state and     
;does this for all eight states.
accumdist
	clr	a	#tables,r0
	move	#$7fffff,a1
	move	r0,r4
	move	#temp,r2
	move	#3,m0
	move	m0,m4
	move	#2,n1
	move	n1,n5
	move	r1,r5



;find minimum distance to state zero
	do	#4,statezero
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)+,b
statezero
	move	r3,x:(r1)+n1
	move	a,x:(r2)+	y:(r4)+,b
	clr 	a		r7,y:(r5)+n5
	move	#$7fffff,a1



;find minimum distance to state two 
	do	#4,statetwo
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)-,b
statetwo
	move	r3,x:(r1)+n1
	move	a,x:(r2)+	y:(r4)+,b	
	clr	a		r7,y:(r5)+n5
	move	#$7fffff,a1

;find minimum distance to state four 
	do	#4,statefour
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)+,b
statefour
	move	r3,x:(r1)+n1
	move	a,x:(r2)+	y:(r4)+,b	
	clr	a		r7,y:(r5)+n5
	move	#$7fffff,a1

;find minimum distance to state six 
	do	#4,statezsix
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)-,b
statezsix
	move	r3,x:(r1)-n1
	move	a,x:(r2)+	
	move	r7,y:(r5)
	move	#tables+4,r4
	move	r4,r0
	move	x:(r1)-n1,a	
	clr	a	x:(r1)-,b	
	move	#$7fffff,a1
	move	r1,r5

;find minimum distance to state one 
	do	#4,stateone
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)+,b
stateone
	move	r3,x:(r1)+n1
	move	a,x:(r2)+	y:(r4)+,b	
	clr	a	r7,y:(r5)+n5
	move	#$7fffff,a1

;find minimum distance to state three 
	do	#4,statethree
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)-,b
statethree
	move	r3,x:(r1)+n1
	move	a,x:(r2)+	y:(r4)+,b	
	clr	a	r7,y:(r5)+n5
	move	#$7fffff,a1
	move	(r4)+

;find minimum distance to state five 
	do	#4,statefive
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)-,b
statefive
	move	r3,x:(r1)+n1
	move	a,x:(r2)+	y:(r4)-,b	
	clr	a	r7,y:(r5)+n5
	move	#$7fffff,a1

;find minimum distance to state seven 
	do	#4,stateseven
	move	x:(r0),x0	y:(r4),b
	add	x0,b
	cmp	b,a
	tge	b,a	r0,r3
	tge	b,a	r4,r7
	move	x:(r0)+,x0	y:(r4)+,b
stateseven
	move	r3,x:(r1)+
	move	a,x:(r2)+	y:(r4)+,b	
	clr	b	r7,y:(r5)+
	move	#$7fffff,b1

;now move new accumulated distances into the  accumulated distance
;table from the temporary table 
;also find the min distance state and store in r4 which is no longer used
	move	#$ffff,m0
	move	#$ffff,m4
	move	#temp,r3
	move	#tables,r0
	move	#large,x1
	move	#2,n0
	do 	#4,endtable
	move	x:(r3)+,x0
	mpy     x1,x0,a
	cmp	a,b	a,x:(r0)+n0
	tge	a,b	r0,r4
endtable
	move	#tables+1,r0
	do	#4,endtablex
	move	x:(r3)+,x0
	mpy	x1,x0,a
	cmp	a,b	a,x:(r0)+n0
	tge	a,b	r0,r4
endtablex
;store in r0 instead of r4
	
	move	r4,r0
	move	#8,n1
	move  	(r0)-n0
	rts


;the traceback routine now goes back through every time period starting
;with the current time period and finds the state from which the path
;came from one time period previous.  At the end of this search, the
;last state found will also point to the path at that state, which is the 
;output  of the trellis.

traceback

;find the displacement from the pointer to table and store value in n4
	move	#tables,n0
	move	(r1)-n1
	lua	(r0)-n0,n5
	move	r1,r5
	do	#15,endtrace
	move	(r1)-n1
	move	x:(r5+n5),r0 
	move	r1,r5
	lua	(r0)-n0,n5
endtrace
	move	#location,r0
	move	y:(r5+n5),a
	rts

;the output data routine unscrambles the path order and finds one 
;of the four points on the constellation coresponding to the output state
;which is closest to the original input at that time period.

outputdata
	move	a,b
	move	#>$b1,x0
	cmp	x0,a	#>$b2,y0	
	teq	y0,b	
	cmp	y0,a	#>$b3,x0	
	teq	x0,b
	cmp	x0,a	#>$b1,y0
	teq	y0,b
	move	#>$b5,x0
	cmp	x0,a	#>$b7,y0
	teq	y0,b
	cmp	y0,a
	teq	x0,b
	move	b,r2
	move	#tables,n2
	move	x:storr6,r6
	lua	(r2)-n2,n3
	move	n3,a
	asl	a
	asl	a
	move 	a,n0
	move	r6,r3
	lua	(r0)+n0,r4
	move	#>$7fffff,x1
	move	r4,r0
	do 	#4,endout
	move 	x:(r3),a	y:(r6),b
	move	x:(r0)+,x0	y:(r4)+,y0
	sub	x0,a
	sub	y0,b	a,x0
	mpy	x0,x0,a	b,y0
	mac	y0,y0,a
	tfr	a,b	x1,a
	cmp	x1,b
	tlt	b,a	r0,r7
	move	a,x1
endout
	clr	a	(r7)-
	move	#location,n0
	move	r7,r0
	move	#$f,a1
	lua	(r0)-n0,r7
	move	r7,x0
	and   	x0,a
	move	a1,y:$eff
	rts

