*=======================================================*
*	Program header:	updated 12/06/97		*
*=======================================================*

*-------------------------------------------------------*
*	text, data & bss alignment size			*
*-------------------------------------------------------*

alignment		=	4

*-------------------------------------------------------*
*	Presets and constants				*
*-------------------------------------------------------*

max_wad_entries		=	4096			; max total wad entries

max_hash		=	max_wad_entries		; max number of hash entries

max_graphics		=	4096			; max graphics (all runtime gfx)
max_textures		=	1024			; max texture definitions
max_pnames		=	2048			; max pname entries
max_sprites		=	2048			; max sprite patches

max_spritenames		=	256			; max (unique) sprite prefixes
max_patches		=	72*2			; maximum patches per texture

max_upt			=	512			; max (unprocessed) things per frame
max_ups			=	512			; max (unprocessed) spans per frame

*-------------------------------------------------------*
*	Table constants					*
*-------------------------------------------------------*

turbres			=	64	; texture turbulence resolution

*-------------------------------------------------------*
*	Preset colours					*
*-------------------------------------------------------*

base_red		=	255	; baseline colours
base_green		=	255
base_blue		=	255

bg_colour		=	$000000	; 'background' colour ($RRGGBB)

sky_colour		=	56	; hack for sky colour

*-------------------------------------------------------*
*	Player attributes				*
*-------------------------------------------------------*

player_height		=	40	; player head-height

front_angle		=	$0000
right_angle		=	$4000

walk_speed		=	$11800
slide_speed		=	$10000
rotate_speed		=	360<<16

*-------------------------------------------------------*
*	Display engine constants			*
*-------------------------------------------------------*

vbilock			=	1	; minimum vblanks before pageswap

window_max		=	1<<10

attrib_twosided		=	1<<2	; twosided flag-mask

terminator		=	-1	; general list-terminator

*-------------------------------------------------------*
*	Memory allocation codes				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
STRAM_only		rs.b	1
VRAM_only		rs.b	1
STRAM_preferred		rs.b	1
VRAM_preferred		rs.b	1

*-------------------------------------------------------*
*	General display structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
*	Global array pointers				*
*-------------------------------------------------------*
gbl_segs_ptr:		rs.l	1	; seg-array
gbl_sectors_ptr:	rs.l	1	; sector-array
gbl_nodes_ptr:		rs.l	1	; node-array
gbl_ssectors_ptr:	rs.l	1	; ssector-array
gbl_sidedefs_ptr:	rs.l	1	; sidedef-array
gbl_linedefs_ptr:	rs.l	1	; linedef-array
gbl_vertices_ptr:	rs.l	1	; vertex-array
*-------------------------------------------------------*
*	Player specific variables			*
*-------------------------------------------------------*
gbl_player_x:		rs.l	1	; player x
gbl_player_y:		rs.l	1	; player y
gbl_player_height:	rs.l	1	; player height
gbl_player_sina:	rs.l	1	; player sin(angle)
gbl_player_cosa:	rs.l	1	; player cos(angle)
gbl_player_sector:	rs.l	1	; player sector
gbl_player_ssector:	rs.l	1	; player ssector
*-------------------------------------------------------*
*	Sector processing variables			*
*-------------------------------------------------------*
gbl_newsector_ptr:	rs.l	1	; current sector
gbl_sector_light:	rs.l	1	; current light level
gbl_last_light:		rs.l	1	; last light level
gbl_ceiling_height:	rs.l	1	; ceiling height
gbl_ceiling_tex:	rs.l	1	; ceiling texture
gbl_floor_height:	rs.l	1	; floor height
gbl_floor_tex:		rs.l	1	; floor texture
*-------------------------------------------------------*
*	Seg processing variables			*
*-------------------------------------------------------*
gbl_seg_i1:		rs.l	1	; wall screen-x1 (unclipped)
gbl_seg_i2:		rs.l	1	; wall screen-x2 (unclipped)
gbl_seg_clip_i2:	rs.l	1	; wall screen-x2 (clipped)
gbl_seg_y1:		rs.l	1	; wall top
gbl_seg_y2:		rs.l	1	; wall bottom
gbl_seg_z1:		rs.l	1	; wall z1
gbl_seg_z2:		rs.l	1	; wall z2
gbl_seg_pz1:		rs.l	1	; wall perspective-z1
gbl_seg_pz2:		rs.l	1	; wall perspective-z2
gbl_seg_rz1:		rs.l	1	; wall real-z1
gbl_seg_rz2:		rs.l	1	; wall real-z2
gbl_seg_y1a:		rs.l	1	; wall y1 (upper-edge) accumulator
gbl_seg_y2a:		rs.l	1	; wall y2 (lower-edge) accumulator
gbl_seg_y1i:		rs.l	1	; wall y1 (top-edge) increment
gbl_seg_y2i:		rs.l	1	; wall y2 (lower-edge) increment
gbl_seg_tu1:		rs.l	1	; wall u1
gbl_seg_tu2:		rs.l	1	; wall u2
gbl_seg_t1:		rs.l	1	; wall t1
gbl_seg_t2:		rs.l	1	; wall t2
gbl_seg_ti:		rs.l	1	; wall t increment
gbl_seg_umag:		rs.l	1	; seg u-magnitude
gbl_seg_adj_sec:	rs.l	1	; seg adjacent sector
gbl_seg_sidedef:	rs.l	1	; seg sidedef
gbl_seg_unpeg:		rs.l	1	; unpegging offset
gbl_seg_texheight:	rs.l	1	; texture height
gbl_seg_u_index:	rs.l	1	; seg u-index
gbl_seg_v_index:	rs.l	1	; seg v-index
gbl_seg_tex:		rs.l	1	; seg texture id
gbl_seg_uoff:		rs.l	1	; seg texture u-offset
gbl_seg_start:		rs.l	1	; initial seg index for ssector
gbl_seg_number:		rs.l	1	; seg count for ssector
gbl_seg_mode:		rs.l	1	; wall mode (linear/perspected)
gbl_seg_opaque:		rs.l	1	; solid flag for textures with holes
gbl_seg_type:		rs.l	1	; wall type (upper/lower/main)
gbl_seg_sdx:		rs.l	1	;
gbl_seg_sdy:		rs.l	1	;
gbl_seg_sx1:		rs.l	1	;
gbl_seg_sy1:		rs.l	1	;
*-------------------------------------------------------*
*	Sprite processing variables			*
*-------------------------------------------------------*
gbl_spr_umag:		rs.l	1	; sprite u-magnitude
gbl_spr_reflect:	rs.l	1	; sprite reflect flag
gbl_spr_wx1:		rs.l	1	; sprite wall-x1
gbl_spr_wx2:		rs.l	1	; sprite wall-x2
gbl_spr_sx1:		rs.l	1	; sprite span-x1
gbl_spr_sx2:		rs.l	1	; sprite span-x2
gbl_spr_zmax:		rs.l	1	; wall max-z
*-------------------------------------------------------*
*	Span processing variables			*
*-------------------------------------------------------*
gbl_upt_used:		rs.l	1
gbl_upt_free:		rs.l	1
gbl_ups_used:		rs.l	1
gbl_ups_free:		rs.l	1
*-------------------------------------------------------*
*	Linedef variables				*
*-------------------------------------------------------*
gbl_line_flags:		rs.l	1	; linedef flags
gbl_line_2side:		rs.l	1	; linedef 2sided flag
*-------------------------------------------------------*
*	General purpose variables			*
*-------------------------------------------------------*
gbl_bsp_pass:		rs.l	1	; updated each frame
gbl_free_columns:	rs.l	1	; incomplete columns
gbl_width:		rs.l	1	; window x-size
gbl_height:		rs.l	1	; window y-size
gbl_half_height:	rs.l	1	; window y-size/2
gbl_v_scale:		rs.l	1	; window y-scale
*-------------------------------------------------------*
display_len:		rs.b	0
*-------------------------------------------------------*

*-------------------------------------------------------*
field_count:		=	10
*-------------------------------------------------------*
*	Leveldata field structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
field_ascii		rs.l	1
field_module		rs.l	1
field_len		rs.b	0

*-------------------------------------------------------*
