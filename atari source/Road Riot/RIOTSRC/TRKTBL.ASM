		TTL	'Track Tables'

SYSID		EQU	1	* VMS = 0	ARIUM = 1

		IFEQ	SYSID
		INCLUDE	'inc:hrdwmap.i'
		ENDC

		IFNE	SYSID
		INCLUDE	prog/inc/hrdwmap.i
		ENDC

		IFNE	EDIT_ON
PAGE1		EQU	$0000
PAGE2		EQU	$0000
PAGE3		EQU	$0000
		ENDC

		PAGE
		SECTION	13
*
* Track pointers
*
		XREF	trk1,trk2,trk3,trk4
		XREF	trk5,trk6,trk7,trk8
		XREF	trk9,trk10,trk11,trk12
		XREF	slope1,slope2,slope3,slope4
		XREF	slope5,slope6,slope7,slope8
		XREF	slope9,slope10,slope11,slope12
		XREF	lut1,lut2,lut3,lut4
		XREF	lut5,lut6,lut7,lut8
		XREF	lut9,lut10,lut11,lut12

		XDEF	tracks,tracks_end
tracks:		DC.L	trk1,trk2+PAGE3,trk3+PAGE1,trk4+PAGE2
		DC.L	trk5+PAGE3,trk6+PAGE2,trk7+PAGE1,trk8+PAGE2
		DC.L	trk9+PAGE1,trk10+PAGE3,trk11+PAGE2,trk12+PAGE1

		XDEF	slopes
slopes:		DC.L	slope1,slope2+PAGE2,slope3+PAGE1,slope4+PAGE2
		DC.L	slope5+PAGE3,slope6+PAGE3,slope7+PAGE1,slope8+PAGE2
		DC.L	slope9+PAGE2,slope10+PAGE1,slope11+PAGE3,slope12+PAGE2

tracks_end	EQU	*

		XDEF	trklut
trklut:		DC.L	lut1,lut2,lut3,lut4
		DC.L	lut5,lut6,lut7,lut8
		DC.L	lut9,lut10,lut11,lut12

		END
