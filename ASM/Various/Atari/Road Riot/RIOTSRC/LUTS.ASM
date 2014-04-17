		TTL	'Track Look-Up-Tables'

SYSID		EQU	1	* VMS = 0	ARIUM = 1

		PAGE
		SECTION	6
*
*	Look-Up-Tables
*
		XDEF	lut1,lut1_end
lut1:
		IFEQ	SYSID
		INCLUDE	'lut1.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut1.asm
		ENDC

lut1_end	EQU	*

		XDEF	lut2,lut2_end
lut2:
		IFEQ	SYSID
		INCLUDE	'lut2.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut2.asm
		ENDC

lut2_end	EQU	*

		XDEF	lut3,lut3_end
lut3:
		IFEQ	SYSID
		INCLUDE	'lut3.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut3.asm
		ENDC

lut3_end	EQU	*

		XDEF	lut4,lut4_end
lut4:
		IFEQ	SYSID
		INCLUDE	'lut4.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut4.asm
		ENDC

lut4_end	EQU	*

		XDEF	lut5,lut5_end
lut5:
		IFEQ	SYSID
		INCLUDE	'lut5.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut5.asm
		ENDC

lut5_end	EQU	*

		XDEF	lut6,lut6_end
lut6:
		IFEQ	SYSID
		INCLUDE	'lut6.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut6.asm
		ENDC

lut6_end	EQU	*

		XDEF	lut7,lut7_end
lut7:
		IFEQ	SYSID
		INCLUDE	'lut7.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut7.asm
		ENDC

lut7_end	EQU	*

		XDEF	lut8,lut8_end
lut8:
		IFEQ	SYSID
		INCLUDE	'lut8.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut8.asm
		ENDC

lut8_end	EQU	*

		XDEF	lut9,lut9_end
lut9:
		IFEQ	SYSID
		INCLUDE	'lut9.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut9.asm
		ENDC

lut9_end	EQU	*

		XDEF	lut10,lut10_end
lut10:
		IFEQ	SYSID
		INCLUDE	'lut10.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut10.asm
		ENDC

lut10_end	EQU	*

		XDEF	lut11,lut11_end
lut11:
		IFEQ	SYSID
		INCLUDE	'lut11.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut11.asm
		ENDC

lut11_end	EQU	*

		XDEF	lut12,lut12_end
lut12:
		IFEQ	SYSID
		INCLUDE	'lut12.asm'
		ENDC

		IFNE	SYSID
		INCLUDE lut12.asm
		ENDC

lut12_end	EQU	*

		END

