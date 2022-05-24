make_yuv:	move	#conv_red,r4
		move	#conv_green,r5
		move	#conv_blue,r6
		move	#conv_gray,r7
		move	#>$0000,y0
		do	#$80,first_lp
		move	y0,y:(r4)+
		move	y0,y:(r5)+
		move	y0,y:(r6)+
		move	y0,y:(r7)+
first_lp
		move	#0,r0
		move	#$100,n0

		move	#>$f800,x1
		do	#256,make_conv_rgb
		move	r0,b
		and	x1,b	#>($800000>>5),x0
		move	b,y0
		move	b,y:(r4)+
		mpy	x0,y0,a	#>($800000>>11),x0
		add	a,b		a,y:(r5)+
		mpy	x0,y0,a		(r0)+n0
		add	a,b		a,y:(r6)+
		move	b,y:(r7)+
make_conv_rgb
		move	#>$f800,y0
		move	#>$07c0,y1
		move	#>$001f,x0
		move	#>$ffdf,x1
		do	#$80,last_lp
		move	y0,y:(r4)+
		move	y1,y:(r5)+
		move	x0,y:(r6)+
		move	x1,y:(r7)+
last_lp		
