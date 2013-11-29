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

		; structure du root sector GEM
		; (secteur physique zero)
		
		rsset	$1c2
hd_siz		rs.l	1	; taille disque en blocs de 512 bytes

p0_flg		rs.b	1	; flag part.0
p0_id		rs.b	3	; type gem part.0
p0_st		rs.l	1	; secteur phys. debut part.0
p0_siz		rs.l	1	; taille phys part.0

p1_flg		rs.b	1	; idem part.1
p1_id		rs.b	3
p1_st		rs.l	1
p1_siz		rs.l	1

p2_flg		rs.b	1	; idem part.2
p2_id		rs.b	3
p2_st		rs.l	1
p2_siz		rs.l	1

p3_flg		rs.b	1	; idem part.3
p3_id		rs.b	3
p3_st		rs.l	1
p3_siz		rs.l	1

bsl_st		rs.l	1	; pointeur 'bad sector list'
bsl_cnt		rs.l	1	; taille de la liste
		
		********
		
		; structure de boot GEM
		; (secteurs logiques zero)
		; (idem MSDOS / iso9293)
		; ATTN: words & longs format 80x86
		
		rsset	0
_b_jump		rs.b	8	; debut boot executable
_b_serial		rs.b	3	; numero de serie
_b_bps		rs.b	2	; octets par secteur logique
_b_spc		rs.b	1	; secteurs logiques par cluster
_b_res		rs.b	2	; secteurs reserves (boot y-compris)
_b_nfats		rs.b	1	; nombre d'exemplaires des fats
_b_ndirs		rs.b	2	; nombre d'entrees du repertoire racine
_b_nsects		rs.b	2	; nombre de secteurs logiques
_b_media		rs.b	1	; code media (ddur=$f8)
_b_spf		rs.b	2	; nbre de secteurs logiques par fat
_b_spt		rs.b	2	; secteurs par piste (obsolete)
_b_nsides		rs.b	2	; nbre de faces (tetes) (obsolete)
_b_nhid		rs.b	2	; nbre de secteurs caches (obsolete)
_b_boot		rs.b	1	; code principal si boot executable
		
		rsset	$20
_b_lnsect		rs.l	1	; nombre de secteurs en LONG
_b_lnfat		rs.l	1	; nombre de secteurs/fat en LONG
		
		********
		
		; structure 'pun_info'
		; compatible AHDI 3.00
		
		rsreset
		
pinfo_puns	rs.w	1	; nbre de peripheriques detectes
pinfo_pun		rs.b	16	; device physique pour chaque lecteur logique
pinfo_pstart	rs.l	16	; debut physique pour chaque lecteur logique
pinfo_cookie	rs.l	1	; cookie AHDI
pinfo_cookptr	rs.l	1	; retropointeur cookie
pinfo_vernum	rs.w	1	; version du driver
pinfo_maxsiz	rs.w	1	; taille max secteur (buffers gemdos)
pinfo_ptype	rs.l	16	; type de partition (was reserved)
pinfo_psize	rs.l	16	; taille de chaque lecteur
pinfo_pflags	rs.w	16	; flags de chaque lecteur
pinfo_size	rs	0

		********
		