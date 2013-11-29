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

		****
		text
		****
	
		; SDS (dev,cdb,buff,size,flags)
		
		; si buff=0 , pas de transfert
		; si size=0 , pas de transfert
		; si size<0 , ‚criture
		; si size>0 , lecture
		
		; flags:
		; bit 0 -> short/long time_out ( 5s / 262s )
		
		; le CDB doit etre padd‚ … au moins 12
		; octets avec des z‚ros pour l'atapi ...
		
		****
	
		rsset	8
_sds_dev		rs.w	1	; standard device number
_sds_cdb		rs.l	1	; address of the command descriptor block
_sds_buff		rs.l	1	; address of i/o buffer
_sds_size		rs.l	1	; length of i/o in bytes
_sds_flags	rs.w	1	; flags
	
		****
_SDS:
		link	a6,#0
		movem.l	d1-d3/a1-a3,-(sp)
		
		****
		sync	$43e.w
		****
		
		move.w	_sds_dev(a6),d0
		
		lea	_sds_jump(pc),a0
		add.w	(a0,d0.w*2),a0
		jsr	(a0)
		
		****
		sf	$43e.w
		****
		
		movem.l	(sp)+,d1-d3/a1-a3
		unlk	a6
		
		rtd	#16
	
		****
_sds_jump:
		dc.w	_sds_none-_sds_jump		; 0 -> acsi 0
		dc.w	_sds_none-_sds_jump
		dc.w	_sds_none-_sds_jump
		dc.w	_sds_none-_sds_jump
		dc.w	_sds_none-_sds_jump
		dc.w	_sds_none-_sds_jump
		dc.w	_sds_none-_sds_jump
		dc.w	_sds_none-_sds_jump 	; 7 -> acsi 7
		
		dc.w	_sds_scsi-_sds_jump 	; 8 -> scsi 0
		dc.w	_sds_scsi-_sds_jump
		dc.w	_sds_scsi-_sds_jump
		dc.w	_sds_scsi-_sds_jump
		dc.w	_sds_scsi-_sds_jump
		dc.w	_sds_scsi-_sds_jump
		dc.w	_sds_scsi-_sds_jump
		dc.w	_sds_scsi-_sds_jump 	; 15 -> scsi 7
		
		dc.w	_sds_atapi-_sds_jump	; 16 -> ide master
		dc.w	_sds_atapi-_sds_jump	; 17 -> ide slave
		
		****

****************************************************************
		
		****
_sds_none:
		moveq	#E_UNDEV,d0
		rts
				
		****

****************************************************************
