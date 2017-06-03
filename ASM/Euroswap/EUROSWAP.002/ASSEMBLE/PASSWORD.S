* PASSWORD CONTROLLER, by Jonathan Horton

* 20 Southerwicks,
* Corsham
* Wiltshire
* SN13 9NH	
* 


	pea	mess(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

input1
	bsr	key
	cmp	#"H",d0
	bne	input1
input2
	bsr	key
	cmp	#"E",d0
	bne	input2
input3
	bsr	key
	cmp	#"L",d0
	bne	input3
input4
	bsr	key
	cmp	#"P",d0
	bne	input4


exit	move	#20,-(sp)
	move	#$4c,-(sp)
	trap	#1


key
	move	#8,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
	
	even
mess	dc.b	27,69,13,10,27,89,35,40,27,112,"Enter Password:      "
	even
	dc.b	27,113,27,89,37,37," By J Horton   ", 189, "1992",0
	


	