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

		********
		
		rsset	32

		; signature
		
_sys_sig		rs.b	6	"c‚cile"
_sys_ver		rs.w	1	version
		
		; table offsets data

_sys_offset	rs.w	0
_sys_ogem		rs.w	1
_sys_oscan	rs.w	1
_sys_osleep	rs.w	1
_sys_ormv		rs.w	1
_sys_ospec	rs.w	1
_sys_rsvd1	rs.w	1
_sys_rsvd2	rs.w	1
_sys_rsvd3	rs.w	1

		; table offsets code

_sys_ocputype	rs.w	1
_sys_oinicooky	rs.w	1
_sys_ovecbios1	rs.w	1
_sys_ovecbios2	rs.w	1
_sys_ovecnrj	rs.w	1
_sys_oinipun	rs.w	1
_sys_oinixbpb	rs.w	1
_sys_ogetid	rs.w	1
_sys_oinilim	rs.w	1
_sys_oinistack	rs.w	1
_sys_odevscan	rs.w	1
_sys_ocreabuf	rs.w	1
_sys_oaddfold	rs.w	1
_sys_ocreafrb	rs.w	1

		; table parametres gem
		
		rsreset
_sys_gfold	rs.w	1
_sys_gdat		rs.w	1
_sys_gfat		rs.w	1
_sys_gstart	rs.w	1
		
		********
		
		rsset	0
		
		; r‚glages sp‚ciaux ata
				
_ata_spd		rs.b	4
_ata_xfr		rs.b	2
		
		;  read look ahead
		; ( $AA=on , $55=off )

_ata_read_ahead	rs.b	2
		
		;  write cache
		; ( $02=on , $82=off )
		
_ata_write_cache	rs.b	2
		
		;  auto defect reallocation
		; ( $04=on , $84=off )
		
_ata_reassign	rs.b	2
		
		;  maximum sector pre-fetch

_ata_max_prefetch	rs.b	2
		
		;  cache segment width
		
_ata_segment	rs.b	2

_ata_adr_mode	rs.b	2
_ata_swap		rs.b	2
		
		********
