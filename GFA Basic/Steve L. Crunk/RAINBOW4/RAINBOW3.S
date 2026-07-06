/
/                            Rainbow for ATART ST
/
/                             By Steve L. Crunk
/                               Nov. 27, 1989    
/    Adapted from an article in ATARI ST USER (British mag)
/    by Gary Radburn.... program originally for FAST BASIC
/    but I figured what you could do in FAST BASIC, you could
/    probably do just as well in GFA BASIC (true, except for
/    the lack of inline assembly)
 	
.globl xmain			/ we use xmain here because this will
xmain:				/ run inline in GFA Basic program. Hence,
                                / we dont need a "main"
/color to rotate		
color_rotate	=	0xff8242

/horizontal blank interrupt vector
hbvec	=	0x120

/vertical blank interrupt vector
vbvec	=	0x70
		
start:	

	move.l	$setup, -(sp)          /put addr of routine on stack
	move	$38, -(sp)             /SUPER mode command
	trap	$14                    /execute setup
	addq.l	$6, sp                 /restore stack pointer
	rts                            /return control


stop:
	move.l	$restore, -(sp)        /put addr of routine on stack
	move	$38, -(sp)             /SUPER mode command
	trap	$14                    /execute restore
	addq.l	$6, sp                 /restore stack pointer
	rts                            /exit

setup:	
	move.b	0xfffa09, save1         /save registers
	move.b	0xfffa07, save2         /that are used as masks
	move.b	0xfffa13, save3         /for the interrupts

	move.l	hbvec, hbsave           /save original
	move.l	vbvec, vbsave           /interrupt vectors

	move	$0xf888, col            /initialise the first color 
	move	$0, start_red           /as black
	move	$0, start_green
	move	$0, start_blue
	move	$0, red
	move	$0, green
	move	$0, blue
	andi.b	$0xfe, 0xfffa07         /shut off hblank
	move.l	$hblank, hbvec          /change its vector
	ori.b	$1, 0xfffa07            /turn it back on
	ori.b	$1, 0xfffa13            /get set to change vbi vector
	move.l	$vblank, vbvec          /and do it
	rts                             /exit

restore:	
	move.b	save1, 0xfffa09         /restore all
	move.b	save2, 0xfffa07         /previously saved
	move.b	save3, 0xfffa13         /registers

	move.l	hbsave, hbvec          /restore previously          
	move.l	vbsave, vbvec          /saved vectors
	rts                            /and exit

/horizontal blank routine

hblank:	
	move	col, color_rotate     /change to new color
	addi	$1, blue              /add 1 to blue
	cmpi	$8, blue              /check if over 7
	bne	cont                  /no - then valid
	move	$0, blue              /else reset it
	addi	$1, green             /add 1 to green
	cmpi	$8, green             /check if over 7
	bne	cont                  /no - then valid
	move	$0, green             /else reset it
	addi	$1, red               /add 1 to red
	cmpi	$8, red               /check if over 7
	bne	cont                  /no - then valid
	move	$0, red               /else reset it
cont:	
	movem.l	${d0-d0,a0-a0}, -(sp) /save registers
	move	$0xf888, col          /set up base number (black)
	move	red, d0               /get red value
	asl	$8, d0                /*256
	add	d0, col               /add it to base
	move	green, d0             /get green value
	asl	$4, d0                /*16
	add	d0, col               /add it to base
	move	blue, d0              /get blue value
	add	d0, col               /add it to base
	movem.l	(sp)+, ${d0-d0,a0-a0} /restore registers
	bclr	$0, 0xfffa0f          /clear interrupt done flag
	rte                           /return from exception

/vertical blank interrupt routine

vblank:	
	move.b	$0, 0xfffa1b           /get set to change HBLANK value
verify:	
	move.b	$4, 0xfffa21           /set HBLANK to execute for
	cmpi.b	$4, 0xfffa21           /every 4 scan lines
	bne	verify                 /wait for it to be set
	move.b	$8, 0xfffa1b           /have changed value
	addi	$1, start_blue         /add one start blue value
	cmpi	$8, start_blue         /check if over 7
	bne	continue               /no - then valid
	move	$0, start_blue         /else reset
	addi	$1, start_green        /add 1 to start green value
	cmpi	$8, start_green        /check if over 7
	bne	continue               /no - then valid
	move	$0, start_green        /else reset
	addi	$1, start_red          /add 1 to start red value
	cmpi	$8, start_red          /check if over 7
 	bne	continue               /no - then valid
	move	$0, start_red          /else reset
continue:	
	movem.l	${d0-d0,a0-a0}, -(sp)  /store registers
	move	$0xf888, col           /set up base value (black)
	move	start_red, d0          /get start red value
	asl	$8, d0                 /*256
	add	d0, col                /add to base value
	move	start_green, d0        /get start green value
	asl	$4, d0                 /*16
	add	d0, col                /add to base value
	move	start_blue, d0         /get start blue value
	add	d0, col                /add to base value

	move	start_blue, blue       /set temp colours as start colours
	move	start_green, green
	move	start_red, red

	movem.l	(sp)+, ${d0-d0,a0-a0}  /restore registers
	rte


	.word	0x4ef9
vbsave:	.blkl	1                  	/continue with old vbi

save1:	.blkw	1                   	/save locations for
save2:	.blkw	1                   	/altered
save3:	.blkw	1                   	/registers

hbsave:	.blkl	1                  	/save location for old hbi interrupt

blue:	.blkw	1                    	/temp value for blue
green:	.blkw	1                   	/temp value for green
red:	.blkw	1                     	/temp value for red
start_blue:	.blkw	1              	/initial value of blue
start_green:	.blkw	1             	/initial value of green
start_red:	.blkw	1               /initial value of red
col:	.blkw	1                     	/calculated colour to portray


	

