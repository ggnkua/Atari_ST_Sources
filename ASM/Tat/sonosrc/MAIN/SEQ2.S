;-----------------------------------------------------------------------

		include	sequence\seqdec.s

;-----------------------------------------------------------------------
		rsreset
s		rs.b	1
o		rs.b	1
n		rs.b	1
l		rs.b	1
u		rs.b	1
m		rs.b	1
i		rs.b	1
e		rs.b	1
z		rs.b	1
icon1		rs.b	1
icon2		rs.b	1
icon3		rs.b	1
icon4		rs.b	1

;-----------------------------------------------------------------------
kick_in_script:
		system
		clear
		music
		quit
		
main_script:
		load	mars_data
		load	fish_data
		execute	mars_data,0,0,0
		execute	fish_data,0,0,0

		execute	mars_data,1,479,0
		term	mars_data
		execute	fish_data,1,100,0
		term	fish_data
		;quit

		load	title_data
		execute	title_data,0,0,0	;init

		wait	melody+0,$24
		execute	title_data,1,0,1	;fade on

		wait	melody+1,$20
		execute	title_data,1,0,2	;fade off

		wait	melody+2,$20
		execute	title_data,1,0,3	;fade title on

;main_script:
		load	tree_data
		load	letters_data
		load	pic1_data
		execute	tree_data,0,0,0
		execute	letters_data,0,0,0
		execute	pic1_data,0,0,0

		wait	melody+4,$00
		execute	title_data,1,0,4	;fade title off

		load	bee_data
		execute	bee_data,0,0,0

		wait	melody+4,$2f
		execute	title_data,1,0,5	;shut down titles
		term	title_data
		clear				;wipe all screens
; Introductory drums
		wait	melody+4,$30
		execute	letters_data,1,0,icon1
		wait	melody+4,$32
		execute	letters_data,1,0,icon2
		wait	melody+4,$35
		execute	letters_data,1,0,icon3
		wait	melody+4,$37
		execute	letters_data,1,0,icon4

; these are OK
		wait	melody+4,$38
		execute	letters_data,1,0,icon1
		wait	melody+4,$3a
		execute	letters_data,1,0,icon2
		wait	melody+4,$3c
		execute	letters_data,1,0,icon3
		wait	melody+4,$3d
		execute	letters_data,1,0,icon4
		wait	melody+4,$3e
		execute	letters_data,1,0,icon1
		wait	melody+4,$3f
		execute	letters_data,1,0,icon2
		
; do flashy bit here too
		wait	beat1,$00

		execute	tree_data,1,0,treeseq1
		execute	letters_data,1,0,s
		wait	beat1,$13

		execute	bee_data,1,0,beeseq1
		execute	letters_data,1,0,o
		wait	beat1,$23

		execute	tree_data,1,0,treeseq2
		execute	letters_data,1,0,n
		wait	beat1,$33

		execute	bee_data,1,0,beeseq2
		execute	letters_data,1,0,o
		wait	beat1+1,$03

		execute	tree_data,1,0,treeseq3
		execute	letters_data,1,0,l
		wait	beat1+1,$13

		execute	bee_data,1,0,beeseq3
		execute	letters_data,1,0,u
		wait	beat1+1,$23

		execute	tree_data,1,0,treeseq4
		execute	letters_data,1,0,m
		wait	beat1+1,$32

		execute	bee_data,1,0,beeseq4
		execute	letters_data,1,0,i
		wait	beat1+2,$03

		execute	tree_data,1,0,treeseq5
		execute	letters_data,1,0,n
		wait	beat1+2,$13

		execute	bee_data,1,0,beeseq5
		execute	letters_data,1,0,e
		wait	beat1+2,$23

		execute	tree_data,1,0,treeseq6
		execute	letters_data,1,0,s
		wait	beat1+2,$32

		execute	bee_data,1,0,beeseq6
		execute	letters_data,1,0,z
		wait	beat1+3,$03

		execute	tree_data,1,0,treeseq7
		execute	letters_data,1,0,e
		wait	beat1+3,$13

		execute	bee_data,1,0,beeseq7
		execute	letters_data,1,0,n
		wait	beat1+3,$23
		execute	bee_data,1,0,beeseq8
		execute	letters_data,1,0,Z
		wait	beat1+3,$31
; Now drum roll
		execute	letters_data,1,0,s
		wait	beat1+3,$32
		execute	letters_data,1,0,o
		wait	beat1+3,$33
		execute	letters_data,1,0,n
		wait	beat1+3,$34
		execute	letters_data,1,0,o
		wait	beat1+3,$35
		execute	letters_data,1,0,l
		wait	beat1+3,$36
		execute	letters_data,1,0,u
		wait	beat1+3,$37
		execute	letters_data,1,0,m
		wait	beat1+3,$38
		execute	letters_data,1,0,i
		wait	beat1+3,$39
		execute	letters_data,1,0,n
		wait	beat1+3,$3a
		execute	letters_data,1,0,e
		wait	beat1+3,$3b
		execute	letters_data,1,0,s
		wait	beat1+3,$3c
		execute	letters_data,1,0,z
		wait	beat1+3,$3d
		execute	letters_data,1,0,e
		wait	beat1+3,$3e
		execute	letters_data,1,0,n
		wait	beat1+3,$3f
		execute	letters_data,1,0,z
		wait	beat1+4,$01
; Crash here!
		execute	bee_data,1,0,beeseq9
		execute	letters_data,1,0,s
		wait	beat1+4,$13

		execute	tree_data,1,0,treeseq9
		execute	letters_data,1,0,o
		wait	beat1+4,$23

		execute	bee_data,1,0,beeseq10
		execute	letters_data,1,0,n
		wait	beat1+4,$33

		execute	tree_data,1,0,treeseq10
;beat+5
		execute	letters_data,1,0,o
		wait	beat1+5,$03
		execute	bee_data,1,0,beeseq11

		execute	letters_data,1,0,l
		wait	beat1+5,$13
		execute	tree_data,1,0,treeseq11

		execute	letters_data,1,0,u
		wait	beat1+5,$23
		execute	bee_data,1,0,beeseq12

		execute	letters_data,1,0,m
		wait	beat1+5,$33
		execute	tree_data,1,0,treeseq12

; Crash at beat1+6,$00
		execute	letters_data,1,0,i
		wait	beat1+6,$03
		execute	bee_data,1,0,beeseq13

		execute	letters_data,1,0,n
		wait	beat1+6,$13
		execute	tree_data,1,0,treeseq13

		execute	letters_data,1,0,e
		wait	beat1+6,$23
		execute	bee_data,1,0,beeseq14

		execute	letters_data,1,0,s
		wait	beat1+6,$33
		execute	tree_data,1,0,treeseq14

; Crash at beat1+7,$00
		execute	letters_data,1,0,z
		wait	beat1+7,$03
		execute	bee_data,1,0,beeseq15

		execute	letters_data,1,0,e
		wait	beat1+7,$13
		execute	tree_data,1,0,treeseq15

		execute	letters_data,1,0,n
		wait	beat1+7,$23
		execute	bee_data,1,0,beeseq16

		execute	letters_data,1,0,z
		wait	beat1+7,$33
		execute	bee_data,1,0,beeseq17

; bang bang bang bang etc.
		;show the pic now then

		execute	pic1_data,1,0,0
; load in all the major stuff again

;main_script:
		;load	letters_data
		;execute	letters_data,0,0,0

		load	inside_data
		execute	inside_data,0,0,0
		load	mhed_data
		execute	mhed_data,0,0,0
		load	tunnel_data
		execute	tunnel_data,0,0,0
		load	maphead_data
		execute	maphead_data,0,0,0
		load	avena_data
		execute	avena_data,0,0,0


	;ifne 0
	;ifne 0
;-----------------------------------------------------------------------
		wait	buildup,$00
		execute	mhed_data,1,0,mhedseq1

		wait	thump,$30
		execute	letters_data,1,0,s
		wait	thump,$32
		execute	letters_data,1,0,o
		wait	thump,$33
		execute	letters_data,1,0,n
		wait	thump,$34
		execute	letters_data,1,0,o
		wait	thump,$35
		execute	letters_data,1,0,l
		wait	thump,$36
		execute	letters_data,1,0,u
		wait	thump,$37
		execute	letters_data,1,0,m
		wait	thump,$38
		execute	letters_data,1,0,i
		wait	thump,$39
		execute	letters_data,1,0,n
		wait	thump,$3a
		execute	letters_data,1,0,e
		wait	thump,$3b
		execute	letters_data,1,0,s
		wait	thump,$3c
		execute	letters_data,1,0,z
		wait	thump,$3d
		execute	letters_data,1,0,e
		wait	thump,$3e
		execute	letters_data,1,0,n
		wait	thump,$3f
		execute	letters_data,1,0,z
	;endc
		wait	beatagain,$00
		execute	inside_data,1,0,insideseq1
		execute	inside_data,1,0,insideseq2

;main_script:
		execute	tunnel_data,1,0,tunnelseq1
		execute	inside_data,1,0,insideseq3
		execute	tunnel_data,1,0,tunnelseq2

	;endc

; HUGE 3d2 head
		execute	maphead_data,1,0,mapheadseq1
		execute	avena_data,1,0,0
;main_script:
		clear

; Final picture
		load	pic2_data
		execute	pic2_data,0,0,0
		execute	pic2_data,1,0,0

		wait	end,0
;-----------------------------------------------------------------------
		quit
		even

;-----------------------------------------------------------------------

title_data:
		DC.L	load_address_3
		DC.W	0			;active flag
		DC.B	"DATA\TITLE.PRG",0	;filename
		EVEN

mars_data:
		DC.L	load_address_3
		DC.W	0			;active flag
		DC.B	"DATA\MARS.PRG",0	;filename
		EVEN

install_data:
		DC.L	load_address_install
		DC.W	0			;active flag
		DC.B	"DATA\INST1.PRG",0	;filename
		EVEN

fish_data:
		DC.L	load_address_1
		DC.W	0			;active flag
		DC.B	"DATA\FISH.PRG",0	;filename
		EVEN
tree_data:
		DC.L	load_address_2
		DC.W	0			;active flag
		DC.B	"DATA\TREE.PRG",0	;filename
		EVEN
bee_data:
		DC.L	load_address_bee
		DC.W	0			;active flag
		DC.B	"DATA\BEE.PRG",0	;filename
		EVEN

letters_data:
		DC.L	load_address_1
		DC.W	0			;active flag
		DC.B	"DATA\LETTERS.PRG",0	;filename
		EVEN

mhed_data:
		DC.L	load_address_mhed
		DC.W	0			;active flag
		DC.B	"DATA\MHED.PRG",0	;filename
		EVEN

inside_data:
		DC.L	load_address_inside
		DC.W	0			;active flag
		DC.B	"DATA\INSIDE.PRG",0	;filename
		EVEN
tunnel_data:
		DC.L	load_address_tunnel
		DC.W	0			;active flag
		DC.B	"DATA\TUNR.PRG",0	;filename
		EVEN
maphead_data:
		DC.L	load_address_maphead
		DC.W	0			;active flag
		DC.B	"DATA\MAPHEAD.PRG",0	;filename
		EVEN
avena_data:
		DC.L	load_address_avena
		DC.W	0			;active flag
		DC.B	"DATA\AVENA.PRG",0	;filename
		EVEN
pic1_data:
		DC.L	load_address_pic1
		DC.W	0			;active flag
		DC.B	"DATA\PIC1.PRG",0	;filename
		EVEN
pic2_data:
		DC.L	load_address_1
		DC.W	0			;active flag
		DC.B	"DATA\PIC2.PRG",0	;filename
		EVEN

;-----------------------------------------------------------------------
treeseq1:
	s_setlrotmov	6,10,20
	s_setcamera	0,0,$1000		;quite small
	s_setcameramov	$0,$0,0
	s_setview	0,-$300,0
	s_setrot	0,0,0
	s_setrotmov	$0,$30,$0
	s_setmisc	tree_speed_1,0
	s_waitmusic	beat1,$10
	s_end
treeseq2:
	s_setcamera	0,0,$800		;slightly bigger
	s_setcameramov	$0,$0,-$18		;VERY slow zoom
	s_setrotmov	$0,$30,$0
	s_setmisc	tree_speed_1,0
	s_waitmusic	beat1,$30
	s_end
treeseq3:
	s_setcamera	0,0,$700		;slightly bigger
	s_waitmusic	beat1+1,$10
	s_end
treeseq4:
	s_waitmusic	beat1+1,$30
	s_end

; Start swinging the tree. Don't zoom yet!
treeseq5:
	s_setmisc	tree_speed_1,$10	;start swinging
	s_setview	0,-$300,0
	s_setrotmov	0,0,0			;no movement
	s_setcamera	$0,$0,$900
	s_setcameramov	$0,$0,$0
	s_waitmusic	beat1+2,$10
	s_end
treeseq6:
	s_setmisc	tree_speed_1,$18
	s_setrot	0,$800,$200		;look down
	s_setcamera	$0,0,$900
	s_waitmusic	beat1+2,$30
	s_end

treeseq7:
	s_setmisc	tree_speed_1,$18
	s_setrot	0,$800,$400		;look down
	s_setcamera	$0,0,$800
	s_setcameramov	$0,0,-$10
	s_waitmusic	beat1+3,$10
	s_end

;treeseq8:
;	s_setlrotmov	6,10,20
;	s_setcamera	0,0,$1000		;quite small
;	s_setcameramov	$0,$0,0
;	s_setview	0,-$300,0
;	s_setrot	0,0,0
;	s_setrotmov	$0,$30,$0
;	s_setmisc	tree_speed_1,0
;	s_waitmusic	beat1,$10
;	s_end

treeseq9:
	s_setcamera	0,0,$800		;slightly bigger
	s_setcameramov	$0,$0,-$18		;VERY slow zoom
	s_setrot	$0,$30,$0		;back to straight up
	s_setrotmov	$0,$30,$0
	s_setmisc	tree_speed_1,0
	s_waitmusic	beat1+4,$20
	s_end
treeseq10:
	s_setcamera	0,0,$700		;slightly bigger
	s_waitmusic	beat1+5,$00
	s_end
treeseq11:
	s_waitmusic	beat1+5,$20
	s_end

; Start swinging the tree. Don't zoom yet!
treeseq12:
	s_setmisc	tree_speed_1,$10	;start swinging
	s_setview	0,-$300,0
	s_setrotmov	0,0,0			;no movement
	s_setcamera	$0,$0,$900
	s_setcameramov	$0,$0,$0
	s_waitmusic	beat1+6,$00
	s_end
treeseq13:
	s_setmisc	tree_speed_1,$18
	s_setrot	0,$800,$200		;look down
	s_setcamera	$0,0,$900
	s_waitmusic	beat1+6,$20
	s_end

treeseq14:
	s_setmisc	tree_speed_1,$18
	s_setrot	0,$800,$400		;look down
	s_setcamera	$0,0,$600
	s_setcameramov	$0,0,+$20
	s_waitmusic	beat1+7,$00
	s_end

treeseq15:
	s_setmisc	tree_speed_1,$18
	s_setrot	0,$800,$400		;look down
	s_setcamera	$0,0,$800
	s_setcameramov	$0,0,-$10
	s_waitmusic	beat1+7,$20
	s_end

treeseq16:
	s_setmisc	tree_speed_1,$18
	s_setrot	0,$800,$400		;look down
	s_setcamera	$0,0,$800
	s_setcameramov	$0,0,-$10
	s_waitmusic	beat1+8,$00
	s_end

;-----------------------------------------------------------------------
beeseq1:
	s_setcamera	$0,$0,$3000
	s_setcameramov	$0,$0,$0
	s_setrot	0,0,0
	s_setrotmov	$0,$30,0		;same as tree
	s_waitmusic	beat1,$20
	s_end

beeseq2:
	s_setcamera	$0,$0,$2000
	s_setrot	$180,0,0
	s_setrotmov	$0,$30,0		;same as tree
	s_waitmusic	beat1+1,$00
	s_end
beeseq3:
	s_waitmusic	beat1+1,$20		;start zooming - slow
	s_setcamera	$0,0,$3000
	s_setcameramov	$0,0,-$50
	s_end
; Slow zoom
beeseq4:
	s_waitmusic	beat1+2,$00		;same as before
	s_setcamera	$0,0,$2800		;but very slightly bigger
	s_setcameramov	$0,0,-$50
	s_end
beeseq5:
	s_setcamera	$0,$0,$3000
	s_setcameramov	-$30,$0,-$60
	s_waitmusic	beat1+2,$20
	s_end
beeseq6:
	s_setrotmov	$0,+$50,6
	s_setcameramov	$30,$0,+$60
	s_waitmusic	beat1+3,$00
	s_end
beeseq7:
	s_setcamera	$0,$0,$3000
	s_setcameramov	$0,$0,-$60
	s_waitmusic	beat1+3,$20
	s_end
beeseq8:
	s_setcamera	$0,$0,$2400		;ZOOM!!!
	s_setcameramov	$0,$0,-$60
	s_setrot	$180,$21*-$10,0
	s_setrotmov	$0,$10,$30
	s_waitmusic	beat1+3,$30
	s_end
beeseq9:
	s_setmisc	bee_screenshake,30
	s_setmisc	bee_cracks,10
	s_setcamera	$0,$0,$1400
	s_setcameramov	$0,$0,+$30		;bounce off
	s_setrotmov	$0,$40,$20
	s_waitmusic	beat1+4,$10
	s_end
beeseq10:
	s_setcamera	$0,$0,$2000
	s_setrot	$180,0,0
	s_setrotmov	$0,$30,0		;same as tree
	s_waitmusic	beat1+4,$30
	s_end
beeseq11:
	s_setcamera	$0,0,$3000
	s_setcameramov	$0,0,-$50
	s_waitmusic	beat1+5,$10		;start zooming - slow
	s_end

; Slow zoom
beeseq12:
	s_setcamera	$0,$0,$2400		;ZOOM!!!
	s_setcameramov	$0,$0,-$60
	s_setrot	$100,$21*-$10,0
	s_setrotmov	$0,$10,$30
	s_waitmusic	beat1+5,$30
	s_end
beeseq13:
	s_setmisc	bee_screenshake,30
	s_setmisc	bee_cracks,16
	s_setcamera	$0,$0,$1400
	s_setcameramov	$0,$0,+$30		;bounce off #2
	s_setrotmov	$0,$40,$20
	s_waitmusic	beat1+6,$10
	s_end
beeseq14:
	s_setview	$0,$0,$0
	s_setcamera	$0,-$1000,$3000
	s_setcameramov	$0,+$80,0
	s_setrot	$d00,$0,$0		;upside down
	s_setrotmov	$0,+$50,0		;here he should drop down dazed
	s_waitmusic	beat1+6,$30
	s_end
beeseq15:
	s_setcamera	$0,$0,$3000
	s_setcameramov	$0,$0,-$60
	s_waitmusic	beat1+7,$10
	s_end
beeseq16:
	s_setcamera	$0,$0,$2400		;ZOOM1!!!
	s_setcameramov	$0,$0,-$60
	s_setrot	$21*9,$21*-$10,0
	s_setrotmov	-9,$10,$30
	s_waitmusic	beat1+7,$30
	s_end
beeseq17:
	s_setcamera	$0,$0,$2400		;ZOOM2!!!
	s_setcameramov	$0,$0,-$60
	s_setrot	$180,$1f*$10,0
	s_setrotmov	$0,-$10,$30
	s_waitmusic	beat1+8,$00
	s_end

;-----------------------------------------------------------------------
mhedseq1:
	s_setrot	0,0,0
	s_setrotmov	($c0+20*+$10)/$20,(20*+$10)/$20,$200/$20
	s_setcamera	0,0,$800
	s_setcameramov	0,0,+$1200/$20
	s_wait		$20

	;s_setrot	$c0+20*+$10,20*+$10,$200
	;s_setcamera	0,0,$1800

	rept	 3
	s_setcameramov	0,0,+$10
	s_setrotmov	$0,-$10,0
	s_wait		40
	s_setcameramov	-4,0,-$20
	s_setrotmov	-$10,0,-4
	s_wait		40
	s_setcameramov	0,0,+$10
	s_setrotmov	4,+$10,0
	s_wait		40
	s_setrotmov	+$10,0,4
	s_wait		40
	endr

	s_setrotmov	-($c0+20*+$10)/$20,-(20*+$10)/$20,-$200/$20
	s_setcameramov	0,0,-$1200/$20
	s_wait		$23
	s_end
	s_close

insideflash macro
		s_setmisc inside_texture_new,(\1-1)*4+1
		s_wait \2
		s_setmisc inside_texture_new,(\1-1)*4+2
		s_wait \2
		s_setmisc inside_texture_new,(\1-1)*4+3
		s_wait \2
		s_setmisc inside_texture_new,(\1-1)*4+4
		s_wait \2
	    endm
insideflash2 macro
		s_setmisc inside_texture_new,(\1-1)*4+4
		s_wait \2
		s_setmisc inside_texture_new,(\1-1)*4+3
		s_wait \2
		s_setmisc inside_texture_new,(\1-1)*4+2
		s_wait \2
		s_setmisc inside_texture_new,(\1-1)*4+1
		s_wait \2
	    endm

insideseq1
	s_setcamera 0,0,$200
	insideflash 1,1
	s_waitmusic beatagain,$08
	insideflash 2,1
	s_waitmusic beatagain,$10
	insideflash 1,1
	s_waitmusic beatagain,$18
	insideflash 2,1
	s_waitmusic beatagain,$20
	insideflash 1,1
	s_waitmusic beatagain,$28
	insideflash 2,1
	s_waitmusic beatagain,$30
	insideflash 1,1
	s_waitmusic beatagain,$38
	insideflash 2,1
	s_waitmusic beatagain+1,$00
	insideflash 1,1
	s_waitmusic beatagain+1,$08
	insideflash 2,1
	s_waitmusic beatagain+1,$10
	insideflash 1,1
	s_waitmusic beatagain+1,$18
	insideflash 2,1
	s_waitmusic beatagain+1,$20
	insideflash 1,1
	s_waitmusic beatagain+1,$28
	insideflash 2,1
	s_waitmusic beatagain+1,$30
	insideflash 1,1
	s_waitmusic beatagain+1,$38
	insideflash 2,1

; Now do the head one instead:

	s_setcamera 0,0,$200
	s_waitmusic beatagain+2,$00
	s_sendobject 0			;(the head)
	s_setcamera -$0,$0,$2000
	s_setcameramov $0,$0,$0
	s_setrotmov 10,20,30
	s_setmisc inside_clearscreen,1

	insideflash 1,2
	s_waitmusic beatagain+2,$08
	s_setcamera -$800,$100,$2000
	insideflash 2,2
	s_waitmusic beatagain+2,$10
	insideflash 1,2
	s_waitmusic beatagain+2,$18
	insideflash 2,2
	s_waitmusic beatagain+2,$20
	insideflash 1,2
	s_waitmusic beatagain+2,$28
	insideflash 2,2
	s_waitmusic beatagain+2,$30
	insideflash 1,2
	s_waitmusic beatagain+2,$38
	insideflash 2,2

; Now start spazzing out:
	s_waitmusic beatagain+3,$00
	s_setcamera -$80,$100,$1000
	s_setcameramov $0,$0,+$400
	insideflash 1,2

	s_waitmusic beatagain+3,$08
	s_setcamera -$800,$100,$1000
	s_setcameramov $100,$0,+$400
	insideflash 2,2

	s_waitmusic beatagain+3,$10
	s_setcamera -$80,$c00,$1000
	s_setcameramov $0,$0,$400
	insideflash 1,2

	s_waitmusic beatagain+3,$18
	s_setcamera +$800,$100,$1000
	s_setcameramov $0,-$120,$400
	insideflash 2,2

	s_waitmusic beatagain+3,$20
	s_setcamera -$80,$100,$1000
	s_setcameramov $0,$130,$400
	insideflash 1,2

	s_waitmusic beatagain+3,$28
	s_setcamera -$80,$100,$1000
	s_setcameramov $0,$0,$400
	insideflash 2,2

	s_waitmusic beatagain+3,$30
	s_setcamera -$80,$100,$1000
	s_setcameramov $130,$0,+$3c0
	insideflash 1,2

; Last one zooms
	s_waitmusic beatagain+3,$38
	s_setcamera -$80,$100,$4000
	s_setcameramov $0,$0,-$300/2
	insideflash 2,2
	s_waitmusic beatagain+3,$3c		;head done
	insideflash2 2,2
	s_waitmusic beatagain+4,$00		;head done

; Zoom out the spiky object
	s_sendobject 1				;(the spikyness)
	s_setcameramov $0,$0,+$300/2
	insideflash 1,2
	s_setrotmov 10*2,20*2,30

	s_waitmusic beatagain+4,$10		;head done
; set this now for immediate effect in the next bit....??
	s_setmisc inside_wobble,-1
	s_end

insideseq2
	s_setmisc inside_anim_size,600
	s_setcameramov $0,$0,-$180
	s_waitmusic beatagain+4,$18		;head done

	s_setcameramov $0,$00,+$80
	s_waitmusic beatagain+4,$20	
	s_setmisc inside_anim_size,600
	s_setcamera +$80,$000,$1800
	s_sendobject 2
	insideflash 1,1
	s_waitmusic beatagain+4,$30	
	s_setmisc inside_anim_size,600
	s_sendobject 1
	s_setcamera -$80,$100,$2000
	insideflash 1,1

; last fastish pattern?
	s_waitmusic beatagain+5,$00	
	s_setmisc inside_anim_size,600
	s_setcamera -$80,$100,$1800
	s_sendobject 2
	insideflash 1,1
	s_waitmusic beatagain+5,$10	
	s_setmisc inside_anim_size,600
	s_setcamera -$80,-$100,$2000
	s_sendobject 1
	insideflash 1,1
	s_waitmusic beatagain+5,$20	
	s_setmisc inside_anim_size,600
	s_setcamera +$80,$0,$1800
	s_sendobject 2
	insideflash 1,1
	s_waitmusic beatagain+5,$30	
	s_setmisc inside_anim_size,600
	s_setcamera -$80,$100,$2000
	s_sendobject 1
	insideflash 1,1
	s_waitmusic beatagain+5,$3c
	insideflash2 1,2
	s_end

insideseq3
	s_setmisc inside_texture_new,1*4+2

	s_setcamera -$80,$100,$2000
	s_setmisc inside_anim_size,600
	s_sendobject 2
	s_setcameramov $0,$00,+$80
	s_waitmusic happy,$18		;head done

	s_setmisc inside_texture_new,0*4+2
	s_setcameramov $0,$00,+$80
	s_sendobject 1
	s_waitmusic happy,$20	

	s_setmisc inside_texture_new,1*4+2
	s_setmisc inside_anim_size,600
	s_setcamera +$80,$000,$1800
	s_sendobject 2
	s_waitmusic happy,$30	

	s_setmisc inside_texture_new,0*4+2
	s_setmisc inside_anim_size,600
	s_sendobject 1
	s_setcamera -$80,$100,$2000
	s_waitmusic happy,$3c
	insideflash2 1,2
	s_waitmusic happy+1,$00
	s_end
	
tunnelseq1
	s_waitmusic tunneloff,$00
	s_end

tunnelseq2
	s_waitmusic tunneloff2,$00
	s_end

mapheadseq1
	s_setrot	0,0,0
	s_setrotmov	($c0+20*+$10)/$20,(20*+$10)/$20,$200/$20
	s_setcamera	0,0,$1000
	s_setcameramov	0,0,+$1200/$20
	s_wait		$20
	s_setcameramov	0,0,+$10
	s_setrotmov	$0,-$10,0
	s_waitmusic	mapheadoff,$00
	s_end

;-----------------------------------------------------------------------
pattern	macro
\1	= *-new_patterns
	endm

new_patterns:
	pattern	start_pattern
	dc.b	$0d			;nearly null pattern
	dc.b	$0e,$0f,$10,$11
	dc.b	$12,$12,$13
	dc.b	$13,$14

	pattern	melody
	; Melody intro
	dc.b	$15
	dc.b	$16,$17,$18

	dc.b	$19			; kick drum intro

	pattern	beat1
	dc.b	$1e,$1e,$1a		; beat in
	; Roll
	dc.b	$21

	pattern	beat2

	; Square wave added
	dc.b	$1b,$1d,$22
	; Roll
	dc.b	$23

	pattern	cymbals
	; Cymbals left/right
	dc.b	$24
	pattern	buildup

	; Staccato, slow build
	; can we make this faster??

	dc.b	$25,$26,$27
	dc.b	$2b,$2c

	; Bumbumbumbumbumbumbumbumbum
	pattern	thump at end
	dc.b	$28

	pattern beatagain
	dc.b	$29,$2a		;,$29,$2a

	; Staccato build
	dc.b	$20,$33		;,$20
	dc.b	$20,$2d
	dc.b	$2e,$2f

	pattern	tunnelon
	dc.b	$31,$32
	pattern tunneloff

	pattern	happy
	dc.b	$30

	pattern	tunnelon2
	dc.b	$00
	pattern tunneloff2
	; JMJ bits (can't be removed)
	dc.b	$34
	dc.b	$35
	pattern	mapheadoff
	dc.b	$36,$37

	pattern	end
	; STOP!
	dcb.b	20,$38			;repeats indefinitely


	even
