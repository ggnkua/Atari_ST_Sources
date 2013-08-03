start	pea	message		Request other disk
	move.w	#9,-(sp)		Print message
	trap	#1		Call GEMDOS
	addq.l	#6,sp		Correct stack
	move.w	#1,-(sp)		Wait key
	trap	#1		Call GEMDOS
	addq.l	#2,sp		Correct stack
	clr.l	-(sp)		Switch to supervisor mode
	move.w	#$20,-(sp)	Function number
	trap	#1		Call GEMDOS
	add.l	#6,sp		Correct stack
	move.w	#1,-(sp)		Read 1 sector
	move.w	#0,-(sp)		Side 0
	move.w	#0,-(sp)		Track 0
	move.w	#1,-(sp)		Sector 1
	move.w	#0,-(sp)		Drive A
	clr.l	-(sp)		Filler
	move.l	#$c0000,-(sp)	Address to load to
	move.w	#8,-(sp)		Function number
	trap	#14		Call XBIOS
	add.l	#20,sp		Correct stack
	move.l	#$c0000,a0	Address of program
	move.w	#$4e71,$c0056	Don't depack logo
	move.w	#$4e71,$c006a	Don't display logo
	move.l	#start,d0		New load address
	move.w	d0,$c0084		Copy into memory
	move.l	#start+28,d0	New relocate address
	move.w	d0,$c009c		Copy into memory
	move.w	#$2700,sr		No interruptions
	jmp	(a0)		Run it

message	dc.b	27,"E",10,10,10,10,10,10,10,10,10,10,10
	dc.b	"Please Insert Destruction Imminent Disk",13,10
	dc.b	"      And press space to continue.",0