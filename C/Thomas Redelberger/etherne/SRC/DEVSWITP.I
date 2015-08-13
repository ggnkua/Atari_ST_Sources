*********************************************************************************
*										*
*	Generic NEx000 driver for any BUS interface and STinG and MagicNet	*
*	and MINTNet (untestet)							*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* Development switches								*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: devswitp.i 1.3 2002/06/08 16:26:52 Thomas Exp Thomas $


*
* development switches
*

MajVersion	EQU	1
MinVersion	EQU	15

VersionStr	MACRO
		DC.B	'v\<MajVersion>.\<MinVersion> prd'
		ENDM


RXDEBPRT	EQU	0		; Receive  debug printout level
					; 0=nothing except fatal stuff
					; 1=only hopeless
					; 2=all odd
					; 3=all packets
					; 4=full detail
TXDEBPRT	EQU	0		; Transmit debug printout level
					; 0=nothing except fatal stuff
					; 1=only hopeless
					; 2=all odd
					; 3=all packets
					; 4=full detail
PARANOIA	EQU	0		; <> 0 read critical 8390 registers twice
MACAddDEBPRT	EQU	0		; <> 0 print NE's PROM

