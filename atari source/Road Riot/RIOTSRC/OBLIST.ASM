		TTL	'Object lists data base'

SYSID		EQU	1	* VMS = 0, ARIUM = 1

		PAGE
		ORG	$7A000		* Put on page boundary

*
* Object lists worlds
*

*
* World #1
*
		XDEF	w1,w1_end
w1		EQU	*
w1_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list1.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list1.asm
		ENDC

		DS.B	$800-(*-w1)	* This world $800 long

*
* World #2
*
		XDEF	w2,w2_end
w2		EQU	*
w2_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list2.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list2.asm
		ENDC

		DS.B	$800-(*-w2)	* This world $800 long

*
* World #3
*
		XDEF	w3,w3_end
w3		EQU	*
w3_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list3.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list3.asm
		ENDC

		DS.B	$800-(*-w3)	* This world $800 long

*
* World #4
*
		XDEF	w4,w4_end
w4		EQU	*
w4_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list4.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list4.asm
		ENDC

		DS.B	$800-(*-w4)	* This world $800 long

*
* World #5
*
		XDEF	w5,w5_end
w5		EQU	*
w5_end		EQU	*+$800
		IFEQ	SYSID
		INCLUDE	'list5.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list5.asm
		ENDC

		DS.B	$800-(*-w5)	* This world $800 long

*
* World #6
*
		XDEF	w6,w6_end
w6		EQU	*
w6_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list6.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list6.asm
		ENDC

		DS.B	$800-(*-w6)	* This world $800 long

*
* World #7
*
		XDEF	w7,w7_end
w7		EQU	*
w7_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list7.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list7.asm
		ENDC

		DS.B	$800-(*-w7)	* This world $800 long

*
* World #8
*
		XDEF	w8,w8_end
w8		EQU	*
w8_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list8.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list8.asm
		ENDC

		DS.B	$800-(*-w8)	* This world $800 long

*
* World #9
*
		XDEF	w9,w9_end
w9		EQU	*
w9_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list9.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list9.asm
		ENDC

		DS.B	$800-(*-w9)	* This world $800 long

*
* World #10
*
		XDEF	w10,w10_end
w10		EQU	*
w10_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list10.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list10.asm
		ENDC

		DS.B	$800-(*-w10)	* This world $800 long


*
* World #11
*
		XDEF	w11,w11_end
w11		EQU	*
w11_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list11.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list11.asm
		ENDC

		DS.B	$800-(*-w11)	* This world $800 long

*
* World #12
*
		XDEF	w12,w12_end
w12		EQU	*
w12_end		EQU	*+$800

		IFEQ	SYSID
		INCLUDE	'list12.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	list12.asm
		ENDC

		DS.B	$800-(*-w12)	* This world $800 long

		END
