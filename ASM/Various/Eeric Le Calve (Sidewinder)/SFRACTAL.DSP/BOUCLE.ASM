
; test exemple de boucle ( de merde)

	org	p:$0
	jmp	start
	
	org	p:$2000
	
start	move	#$0,x0
	move	x0,x:$0
	
boucle
	nop

	clr	a
	move	x:$0,a1
	move	#$1,x0
	add	x0,a
	move	a1,x:$0
	move	#$3,x0
	cmp	x0,a
	jmi	boucle
	
	nop
	nop
	
	
	
	