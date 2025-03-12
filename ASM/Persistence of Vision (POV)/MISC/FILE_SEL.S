**** File selector....

appl_init	move.w	global,aes_version
		lea	path,a1
		lea	my_path,a2
load_path	move.b	(a2)+,(a1)+
		bne.s	load_path

		lea	file,a1
		lea	my_file,a2
load_file	move.b	(a2)+,(a1)+
		bne.s	load_file


;Now check AES version and call the relevant file selector

		cmp.w	#$130,aes_version
		bge	.aes130

fsel_input	;#path,#file
		bra	.not130
.aes130

fsel_exinput	#path,#file,#label
.not130

		move.w	int_out+2,button

	section bss

path		ds.b	128
file		ds.b	13
button		ds.w	1
aes_version	ds.w	1

	section data
my_path		dc.b	"a:\folder\*.*",0
my_file		dc.b	"test.s",0
label		dc.b	"Select a file",0


