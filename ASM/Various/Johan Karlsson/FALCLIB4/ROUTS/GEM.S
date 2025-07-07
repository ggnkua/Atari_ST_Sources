*
* GEM.S
*
*	@gemdos	macro
* In	 #functionnbr, #stackcorrection
* ex.	 @gemdos 1,2	;waits for a key
*
*	@xbios	macro
* In	 #functionnbr, #stackcorrection
* ex.	 @xbios 37,2	;waits for vsync
*
*	@gem	macro
* In	 #functionnbr, #trapnbr, #stackcorrection
* ex.	 @gem 1,1,2	;waits for a key
*


@gemdos	macro
	move	#\1,-(sp)
	trap	#1
	add.l	#\2,sp
	endm

@xbios	macro
	move	#\1,-(sp)
	trap	#14
	add.l	#\2,sp
	endm

@gem	macro
	move	#\1,-(sp)
	trap	#\2
	add.l	#\3,sp
	endm
