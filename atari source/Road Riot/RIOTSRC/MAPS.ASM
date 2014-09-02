		TTL	'Map Tables'

SYSID		EQU	1	* VMS = 0	ARIUM = 1

		PAGE
		SECTION	6

		XDEF	map1,map1_end
map1:
		IFEQ	SYSID
		INCLUDE	'map1.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map1.asm
		ENDC

map1_end	EQU	*

		XDEF	map2,map2_end
map2:
		IFEQ	SYSID
		INCLUDE	'map2.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map2.asm
		ENDC

map2_end	EQU	*

		XDEF	map3,map3_end
map3:
		IFEQ	SYSID
		INCLUDE	'map3.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map3.asm
		ENDC

map3_end	EQU	*

		XDEF	map4,map4_end
map4:
		IFEQ	SYSID
		INCLUDE	'map4.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map4.asm
		ENDC

map4_end	EQU	*

		XDEF	map5,map5_end
map5:
		IFEQ	SYSID
		INCLUDE	'map5.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map5.asm
		ENDC

map5_end	EQU	*

		XDEF	map6,map6_end
map6:
		IFEQ	SYSID
		INCLUDE	'map6.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map6.asm
		ENDC

map6_end	EQU	*

		XDEF	map7,map7_end
map7:
		IFEQ	SYSID
		INCLUDE	'map7.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map7.asm
		ENDC

map7_end	EQU	*

		XDEF	map8,map8_end
map8:
		IFEQ	SYSID
		INCLUDE	'map8.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map8.asm
		ENDC

map8_end	EQU	*

		XDEF	map9,map9_end
map9:
		IFEQ	SYSID
		INCLUDE	'map9.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map9.asm
		ENDC

map9_end	EQU	*

		XDEF	map10,map10_end
map10:
		IFEQ	SYSID
		INCLUDE	'map10.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map10.asm
		ENDC

map10_end	EQU	*

		XDEF	map11,map11_end
map11:
		IFEQ	SYSID
		INCLUDE	'map11.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map11.asm
		ENDC

map11_end	EQU	*

		XDEF	map12,map12_end
map12:
		IFEQ	SYSID
		INCLUDE	'map12.asm'
		ENDC

		IFNE	SYSID
		INCLUDE	map12.asm
		ENDC

map12_end	EQU	*

		END

