		TTL	'Track Curve and Slope Tables'

SYSID		EQU	1	* VMS = 0	ARIUM = 1

STRIP96		EQU	96	* Number of strips in a track
STRIP128	EQU	128
STRIP144	EQU	144

		PAGE
		SECTION	1

		XDEF	trk1,trk1_end,slope1
trk1:
slope1		EQU	*+(STRIP96*2)
		IFEQ	SYSID
		INCLUDE	'track1.asm'
		ENDC

		IFNE	SYSID
		INCLUDE track1.asm
		ENDC

trk1_end	EQU	*

		XDEF	trk2,trk2_end,slope2
trk2:
slope2		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track2.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track2.asm
		ENDC

trk2_end	EQU	*

		XDEF	trk3,trk3_end,slope3
trk3:
slope3		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track3.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track3.asm
		ENDC

trk3_end	EQU	*

		XDEF	trk4,trk4_end,slope4
trk4:
slope4		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track4.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track4.asm
		ENDC

trk4_end	EQU	*

		XDEF	trk5,trk5_end,slope5
trk5:
slope5		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track5.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track5.asm
		ENDC

trk5_end	EQU	*

		XDEF	trk6,trk6_end,slope6
trk6:
slope6		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track6.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track6.asm
		ENDC

trk6_end	EQU	*

		XDEF	trk7,trk7_end,slope7
trk7:
slope7		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track7.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track7.asm
		ENDC

trk7_end	EQU	*

		XDEF	trk8,trk8_end,slope8
trk8:
slope8		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track8.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track8.asm
		ENDC

trk8_end	EQU	*

		XDEF	trk9,trk9_end,slope9
trk9:
slope9		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track9.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track9.asm
		ENDC

trk9_end	EQU	*

		XDEF	trk10,trk10_end,slope10
trk10:
slope10		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track10.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track10.asm
		ENDC

trk10_end	EQU	*

		XDEF	trk11,trk11_end,slope11
trk11:
slope11		EQU	*+(STRIP144*2)
		IFEQ	SYSID
		INCLUDE	'track11.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track11.asm
		ENDC

trk11_end	EQU	*

		XDEF	trk12,trk12_end,slope12
trk12:
slope12		EQU	*+(STRIP128*2)
		IFEQ	SYSID
		INCLUDE	'track12.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	track12.asm
		ENDC

trk12_end	EQU	*

		END

