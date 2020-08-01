/****************************************************************
*
* Dieses Modul enth„lt MT-sichere AES-Funktionen.
*
* Assembler-Teil
*
* Andreas Kromke
* 16.3.96
*
****************************************************************/

	XDEF	_crystal

; void _crystal( AESPB *aespb );

_crystal:
 move.l	a0,d1
 move.w	#$c8,d0
 trap	#2
 rts

	END
