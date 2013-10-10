	org	p:$0
	jmp	start

	org	p:$40
start	
	move	#0,a
	move	#50,a1
	move	a1,x0
	move	#10,a1
	and	#$fe,ccr
	rep	#24
	div	x0,a

	move	#0,a
	move	#16,a1
	move	a1,x0
	move	#3,a1
	and	#$fe,ccr
	rep	#24
	div	x0,a

	move	#0,a
	move	#16,a1
	move	a1,x0
	move	#16,a1
	and	#$fe,ccr
	rep	#24
	div	x0,a

	move	#$135,r3
	move	#$7135,r7

	move	#0,a
	move	#16,a1
	move	a1,x0
	move	#4,a1
	and	#$fe,ccr
	rep	#24
	div	x0,a


	move	#0,a
	move	#25,a1
	move	a1,x0
	move	#3,a1
	and	#$fe,ccr
	rep	#24
	div	x0,a

	
	jmp	start