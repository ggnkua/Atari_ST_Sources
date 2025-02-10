
		ifd		protection

jump1		macro
AD_\1		move.l	$4.w,(a1)
		lea		.h(pc),a1
.h		jmp		AD_\2
		endm

jump2		macro
AD_\1		move.l	$4.w,(a1)
		lea		$24.w,a1
		bra		AD_\2
		endm

jump3		macro
AD_\1		move.l	$8.w,(a1)
		lea		AD_\1(pc),a1
		lea		AD_\2(pc),a0
		jsr		(a0)
		endm

jump4		macro
AD_\1		move.l	$24.w,(a1)
		lea		$24,a1
		pea		AD_\2(pc)
		rts
		endm

jump5		macro
AD_\1		move.l	$4.w,(a1)
		lea		.h(pc),a1
.h		lea		AD_\2-INIT,a0
		jmp		(a0,d0.l)
		endm

jump1b	macro
ADb_\1	move.l	$4.w,(a1)
		lea		.h(pc),a1
.h		jmp		ADb_\2
		endm

jump2b	macro
ADb_\1	move.l	$8.w,(a1)
		move.w	#$24,a1
		bra		ADb_\2
		endm

jump3b	macro
ADb_\1	move.l	$10.w,(a1)
		lea		ADb_\1(pc),a1
		lea		ADb_\2(pc),a0
		jmp		(a0)
		endm

jump4b	macro
ADb_\1	move.l	$4.w,(a1)
		moveq		#0,d1
		bset		#4,d1
		move.l	d1,a1
		pea		ADb_\2(pc)
		rts
		endm

jump5b	macro
ADb_\1	move.l	$4.w,(a1)
		lea		.h(pc),a1
.h		lea		ADb_\2-INIT,a0
		jmp		(a0,d0.l)
		endm


jump1c	macro
ADc_\1	move.l	$8.w,(a1)
		lea		.h(pc),a1
.h		jmp		ADc_\2
		endm

jump2c	macro
ADc_\1	move.l	$4.w,(a1)
		lea		$24.w,a1
		bra		ADc_\2
		endm

jump3c	macro
ADc_\1	move.l	$10.w,(a1)
		lea		ADc_\1(pc),a1
		lea		ADc_\2(pc),a0
		jsr		(a0)
		endm

jump4c	macro
ADc_\1	move.l	$8.w,(a1)
		lea		$24,a1
		pea		ADc_\2(pc)
		rts
		endm

jump5c	macro
ADc_\1	move.l	$4.w,(a1)
		lea		.h(pc),a1
.h		lea		ADc_\2-INIT,a0
		jmp		(a0,d0.l)
		endm

jump1d	macro
ADd_\1	move.l	$10.w,(a1)
		lea		.h(pc),a1
.h		jmp		ADd_\2
		endm

jump2d	macro
ADd_\1	move.l	$4.w,(a1)
		lea		$24.w,a1
		bra		ADd_\2
		endm

jump3d	macro
ADd_\1	move.l	$8.w,(a1)
		lea		$24,a1
		lea		ADd_\2(pc),a0
		jmp		(a0)
		endm

jump4d	macro
ADd_\1	move.l	$4.w,(a1)
		moveq		#1,d1
		lsl.w		#4,d1
		move.l	d1,a1
		pea		ADd_\2(pc)
		rts
		endm

jump5d	macro
ADd_\1	move.l	$4.w,(a1)
		lea		$24.w,a1
.h		lea		ADd_\2-INIT,a0
		jmp		(a0,d0.l)
		endm


INIT:	move.l	#INIT,d0	
	lea		INIT(pc),a1
	jump1		1,2
	jump4		7,8
	jump4		5,6
	jump4		22,23
	jump3		2,3
	jump2		13,14
	jump2		92,93
	jump3		21,22
	jump3		17,18
	jump2		41,42
	jump5		6,7
	jump3		8,9
	jump5		19,20
	jump5		12,13
	jump1		25,26
	jump1		23,24
	jump1		34,35
	jump1		16,17
	jump2		9,10
	jump1		11,12
	jump2		15,16
	jump2		3,4
	jump1		37,38
	jump3		4,5
	jump4		10,11
	jump2		29,30
	jump1		28,29
	jump4		14,15
	jump2		38,39
	jump3		26,27
	jump4		18,19
	jump1		99,SETUP1
	jump5		33,34
	jump1		32,33
	jump3		44,45
	jump5		40,41
	jump5		35,36
	jump4		43,44
	jump3		48,49
	jump5		50,51
	jump1		31,32
	jump1		52,53
	jump1		49,50
	jump2		51,52
	jump1		55,56
	jump5		27,28
	jump3		30,31
	jump1		20,21
	jump2		47,48
	jump2		24,25
	jump1		88,89
	jump3		36,37
	jump1		39,40
	jump2		58,59
	jump4		98,99
	jump1		66,67
	jump1		42,43
	jump4		77,78
	jump1		60,61
	jump1		57,58
	jump5		62,63
	jump2		61,62
	jump5		45,46
	jump1		46,47
	jump2		56,57
	jump5		53,54
	jump2		70,71
	jump3		54,55
	jump1		82,83
	jump3		76,77
	jump1		69,70
	jump1		75,76
	jump5		79,80
	jump2		80,81
	jump2		65,66
	jump3		97,98
	jump4		59,60
	jump2		89,90
	jump1		78,79
	jump3		87,88
	jump2		85,86
	jump4		64,65
	jump1		81,82
	jump1		73,74
	jump1		95,96
	jump1		93,94
	jump4		90,91
	jump2		94,95
	jump2		96,97
	jump1		86,87
	jump5		91,92
	jump1		68,69
	jump3		63,64
	jump2		74,75
	jump1		84,85
	jump4		72,73
	jump3		67,68
	jump1		71,72
	jump4		83,84

AD_SETUP1:
	jsr			setup1

	move.l		#INIT,d0	
	lea			AD_SETUP1(pc),a1
	jump1b		1,2
	jump4b		7,8
	jump4b		5,6
	jump4b		22,23
	jump3b		2,3
	jump2b		13,14
	jump2b		92,93
	jump3b		21,22
	jump3b		17,18
	jump2b		41,42
	jump5b		6,7
	jump3b		8,9
	jump5b		19,20
	jump5b		12,13
	jump1b		25,26
	jump1b		23,24
	jump1b		34,35
	jump1b		16,17
	jump2b		9,10
	jump1b		11,12
	jump2b		15,16
	jump2b		3,4
	jump1b		37,38
	jump3b		4,5
	jump4b		10,11
	jump2b		29,30
	jump1b		28,29
	jump4b		14,15
	jump2b		38,39
	jump3b		26,27
	jump4b		18,19
	jump1b		99,SETUP2
	jump5b		33,34
	jump1b		32,33
	jump3b		44,45
	jump5b		40,41
	jump5b		35,36
	jump4b		43,44
	jump3b		48,49
	jump5b		50,51
	jump1b		31,32
	jump1b		52,53
	jump1b		49,50
	jump2b		51,52
	jump1b		55,56
	jump5b		27,28
	jump3b		30,31
	jump1b		20,21
	jump2b		47,48
	jump2b		24,25
	jump1b		88,89
	jump3b		36,37
	jump1b		39,40
	jump2b		58,59
	jump4b		98,99
	jump1b		66,67
	jump1b		42,43
	jump4b		77,78
	jump1b		60,61
	jump1b		57,58
	jump5b		62,63
	jump2b		61,62
	jump5b		45,46
	jump1b		46,47
	jump2b		56,57
	jump5b		53,54
	jump2b		70,71
	jump3b		54,55
	jump1b		82,83
	jump3b		76,77
	jump1b		69,70
	jump1b		75,76
	jump5b		79,80
	jump2b		80,81
	jump2b		65,66
	jump3b		97,98
	jump4b		59,60
	jump2b		89,90
	jump1b		78,79
	jump3b		87,88
	jump2b		85,86
	jump4b		64,65
	jump1b		81,82
	jump1b		73,74
	jump1b		95,96
	jump1b		93,94
	jump4b		90,91
	jump2b		94,95
	jump2b		96,97
	jump1b		86,87
	jump5b		91,92
	jump1b		68,69
	jump3b		63,64
	jump2b		74,75
	jump1b		84,85
	jump4b		72,73
	jump3b		67,68
	jump1b		71,72
	jump4b		83,84


ADb_SETUP2:
	jsr			setup2

	lea			ADb_SETUP2(pc),a1
	move.l		#INIT,d0	
	jump1c		1,2
	jump4c		7,8
	jump4c		5,6
	jump4c		22,23
	jump3c		2,3
	jump2c		13,14
	jump2c		92,93
	jump3c		21,22
	jump3c		17,18
	jump2c		41,42
	jump5c		6,7
	jump3c		8,9
	jump5c		19,20
	jump5c		12,13
	jump1c		25,26
	jump1c		23,24
	jump1c		34,35
	jump1c		16,17
	jump2c		9,10
	jump1c		11,12
	jump2c		15,16
	jump2c		3,4
	jump1c		37,38
	jump3c		4,5
	jump4c		10,11
	jump2c		29,30
	jump1c		28,29
	jump4c		14,15
	jump2c		38,39
	jump3c		26,27
	jump4c		18,19
	jump1c		99,SETUP3
	jump5c		33,34
	jump1c		32,33
	jump3c		44,45
	jump5c		40,41
	jump5c		35,36
	jump4c		43,44
	jump3c		48,49
	jump5c		50,51
	jump1c		31,32
	jump1c		52,53
	jump1c		49,50
	jump2c		51,52
	jump1c		55,56
	jump5c		27,28
	jump3c		30,31
	jump1c		20,21
	jump2c		47,48
	jump2c		24,25
	jump1c		88,89
	jump3c		36,37
	jump1c		39,40
	jump2c		58,59
	jump4c		98,99
	jump1c		66,67
	jump1c		42,43
	jump4c		77,78
	jump1c		60,61
	jump1c		57,58
	jump5c		62,63
	jump2c		61,62
	jump5c		45,46
	jump1c		46,47
	jump2c		56,57
	jump5c		53,54
	jump2c		70,71
	jump3c		54,55
	jump1c		82,83
	jump3c		76,77
	jump1c		69,70
	jump1c		75,76
	jump5c		79,80
	jump2c		80,81
	jump2c		65,66
	jump3c		97,98
	jump4c		59,60
	jump2c		89,90
	jump1c		78,79
	jump3c		87,88
	jump2c		85,86
	jump4c		64,65
	jump1c		81,82
	jump1c		73,74
	jump1c		95,96
	jump1c		93,94
	jump4c		90,91
	jump2c		94,95
	jump2c		96,97
	jump1c		86,87
	jump5c		91,92
	jump1c		68,69
	jump3c		63,64
	jump2c		74,75
	jump1c		84,85
	jump4c		72,73
	jump3c		67,68
	jump1c		71,72
	jump4c		83,84

ADc_SETUP3:
	jsr			setup3

	move.l		#INIT,d0	
	lea			ADc_SETUP3(pc),a1
	jump1d		1,2
	jump4d		7,8
	jump4d		5,6
	jump4d		22,23
	jump3d		2,3
	jump2d		13,14
	jump2d		92,93
	jump3d		21,22
	jump3d		17,18
	jump2d		41,42
	jump5d		6,7
	jump3d		8,9
	jump5d		19,20
	jump5d		12,13
	jump1d		25,26
	jump1d		23,24
	jump1d		34,35
	jump1d		16,17
	jump2d		9,10
	jump1d		11,12
	jump2d		15,16
	jump2d		3,4
	jump1d		37,38
	jump3d		4,5
	jump4d		10,11
	jump2d		29,30
	jump1d		28,29
	jump4d		14,15
	jump2d		38,39
	jump3d		26,27
	jump4d		18,19
	jump1d		99,SETUP4
	jump5d		33,34
	jump1d		32,33
	jump3d		44,45
	jump5d		40,41
	jump5d		35,36
	jump4d		43,44
	jump3d		48,49
	jump5d		50,51
	jump1d		31,32
	jump1d		52,53
	jump1d		49,50
	jump2d		51,52
	jump1d		55,56
	jump5d		27,28
	jump3d		30,31
	jump1d		20,21
	jump2d		47,48
	jump2d		24,25
	jump1d		88,89
	jump3d		36,37
	jump1d		39,40
	jump2d		58,59
	jump4d		98,99
	jump1d		66,67
	jump1d		42,43
	jump4d		77,78
	jump1d		60,61
	jump1d		57,58
	jump5d		62,63
	jump2d		61,62
	jump5d		45,46
	jump1d		46,47
	jump2d		56,57
	jump5d		53,54
	jump2d		70,71
	jump3d		54,55
	jump1d		82,83
	jump3d		76,77
	jump1d		69,70
	jump1d		75,76
	jump5d		79,80
	jump2d		80,81
	jump2d		65,66
	jump3d		97,98
	jump4d		59,60
	jump2d		89,90
	jump1d		78,79
	jump3d		87,88
	jump2d		85,86
	jump4d		64,65
	jump1d		81,82
	jump1d		73,74
	jump1d		95,96
	jump1d		93,94
	jump4d		90,91
	jump2d		94,95
	jump2d		96,97
	jump1d		86,87
	jump5d		91,92
	jump1d		68,69
	jump3d		63,64
	jump2d		74,75
	jump1d		84,85
	jump4d		72,73
	jump3d		67,68
	jump1d		71,72
	jump4d		83,84

ADd_SETUP4:

	elseif
	
	jsr			setup1
	jsr			setup2
	jsr			setup3

	endc

