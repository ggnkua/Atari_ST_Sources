Parameters_for_the_current_file:
	lea	Filename_to_load(pc),a0
	move.l	Adress_to_load_file,a1
	movea.l	#80000,a2

Loading_current_file:
	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp

Read_all_the_current_file:
	move.w	d0,d3
	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.w	d3,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	move.l	d0,Length_of_the_current_file
	adda.l	#12,sp
	
Close_the_current_file:
	move.w	d3,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
Filename_to_load:
	dc.b	"a:\*.pi1"
	dc.b	$0
	even

Adress_to_load_file:
	dc.l	$f8000

Length_of_the_current_file:
	dc.b	"zzzzzzzz"