;***************************************************************************
;    CECILE Device Driver
;    Copyright (C) 1999-2006  David Godec  (david.godec@online.fr)
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;
;***************************************************************************

	******************************
	* BPB - Bios Parameter Block *
	******************************
	
	rsreset
recsiz	rs.w	1	; sector size in bytes
clsiz	rs.w	1	; cluster size in sectors
clsizb	rs.w	1	; cluster size in bytes

rdlen	rs.w	1	; root directory length in records
fsiz	rs.w	1	; fat size in records

fatrec	rs.w	1	; first fat record (of last fat)
datrec	rs.w	1	; first data record

numcl	rs.w	1	; total number of data clusters
			; (FAT12/FAT15/FAT16)
			
bflags	rs.w	1	; 0 -> fat12
			; 1 -> fat15
	****
	
	; extended BPB (FAT32)

xb_magic	rs.l	1	; ascii "XBPB" magic marker
xb_flag	rs.b	1	; extended media bit flags
xb_type	rs.b	1	; volume type
xb_cnum	rs.l	1	; 32 bits total data clusters number
xb_serial	rs.l	1	; media serial number

	****
	
	; extended flags:
	;  bit | meaning
	; ----------------------------------
	;  15  | 1=media has been changed
	;  14  | 1=media is removable
	;  13  | 1=media is byte-swapped
	;  12  | 1=media is write protected
	
	; volume types:
	; -------------
	; $00 = DOS 12 bits FAT (msdos/gemdos floppies)
	; $01 = DOS 16 bits FAT (msdos/gemdos HDD)
	; $02 = DOS 32 bits FAT (WIN95/WIN98 HDD)
	
	******************************
