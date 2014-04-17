	TTL	'Fixed tables'

SYSID	EQU	1	* VMS = 0	ARIUM = 1

		PAGE
		SECTION	13
*
* 	Wheel Dust offsets
*
		XDEF	dust_xoff,dust_yoff,dust_end
dust_xoff	EQU	*
dust_yoff	EQU	*+(96*2)

		IFEQ	SYSID
		INCLUDE	'dust_tbl.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	dust_tbl.asm
		ENDC

dust_end	EQU	*

		PAGE
*
* 	Bouncy table
*
		XDEF	bounce_tbl
bounce_tbl:
		IFEQ	SYSID
		INCLUDE	'tools:bounce.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	/usr/speed1/tools/bounce.asm
		ENDC

		PAGE
*
* 	Line Accel offset table
*
		XDEF	lacc_tbl

		IFEQ	SYSID
		INCLUDE	'tools:line_acc.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	/usr/speed1/tools/line_acc.asm
		ENDC

		PAGE
*
* 	Steering table
*
		XDEF	steer_tbl
steer_tbl:
		IFEQ	SYSID
		INCLUDE	'tools:steer.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	/usr/speed1/tools/steer.asm
		ENDC

		END

