	TTL	'Laser speed table'

SYSID	EQU	1	* VMS = 0, ARIUM = 1

	PAGE
	SECTION	13
	XDEF	laserx,lasery

	IFEQ	SYSID
	INCLUDE	'[speed.tools]laser_spd.asm'
	ENDC

	IFNE	SYSID
	INCLUDE	/usr/speed1/tools/laser_spd.asm
	ENDC

	PAGE
*	SECTION	1
	XDEF	lxoff,lyoff
lxoff	EQU	*
lyoff	EQU	*+64

	XDEF	lastbl,lastbl_end
lastbl:
	IFEQ	SYSID
	INCLUDE	'laser_offset.asm'
	ENDC

	IFNE	SYSID
	INCLUDE	laser_offset.asm
	ENDC

lastbl_end	EQU	*-1

	END
