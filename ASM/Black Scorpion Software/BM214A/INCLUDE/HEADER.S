*=======================================================*
*	Program header:	latest update 21/11/95		*
*=======================================================*

max_wad_entries		=	4096

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

max_things		=	1024
max_linedefs		=	4096
max_sidedefs		=	4096
max_vertices		=	2048
max_segs		=	4096
max_ssectors		=	2048
max_nodes		=	2048
max_sectors		=	1024

vbilock			=	1	; minimum vblanks before pageswap

window_max		=	1<<10

ZMIN			=	12	; minimum clipping Z

UPPER_TYPE		=	0	; wall definition codes
WALL_TYPE		=	1
LOWER_TYPE		=	2
TRANS_TYPE		=	13

maxwallruns		=	4096	; reserve space for wall runs
max_xint		=	64	; be careful when modifying these as a few
max_yint		=	64	; mults have been optimised using shifts instead.

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
*	Wall-run ministructure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
wall_i:			rs.w	1
wall_j1:		rs.b	1
wall_j2:		rs.b	1
wall_u:			rs.w	1
wall_dv:		rs.b	3
wall_lum:		rs.b	1
wall_v:			rs.w	1
wall_len:		rs.b	0

*-------------------------------------------------------*
*	Floor-run ministructure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
flat_lum:		rs.w	1
flat_x2:		rs.w	1
flat_len:		rs.b	0

*-------------------------------------------------------*
*	Vertex ministructure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
vtx_x:			rs.w	1
vtx_y:			rs.w	1
vtx_len:		rs.b	0

*-------------------------------------------------------*
*	Node-vertex ministructure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
nodevtx_y2:		rs.w	1
nodevtx_y1:		rs.w	1
nodevtx_x1:		rs.w	1
nodevtx_x2:		rs.w	1
nodevtx_len:		rs.b	0

*-------------------------------------------------------*
*	WAD Header structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
wh_sig			rs.l	1
wh_entries		rs.l	1
wh_directory		rs.l	1
wh_len			rs.b	0
 
*-------------------------------------------------------*
*	WAD directory structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
wd_offset		rs.l	1
wd_size			rs.l	1
wd_name			rs.b	8
wd_len			rs.b	0

*-------------------------------------------------------*
*	WAD Seg structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
seg_from:		rs.w	1
seg_to:			rs.w	1
seg_bam:		rs.w	1
seg_linedef:		rs.w	1
seg_sidedef:		rs.w	1
seg_distance:		rs.w	1
seg_length:		rs.l	1
seg_len:		rs.b	0

*-------------------------------------------------------*
*	WAD Sector structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
sector_floorht:		rs.w	1
sector_ceilht:		rs.w	1
sector_ftns:		rs.b	8
sector_ctns:		rs.b	8
sector_light:		rs.w	1
sector_special:		rs.w	1
sector_tag:		rs.w	1
sector_len:		rs.b	0

*-------------------------------------------------------*
*	WAD SSector structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
ssec_segments:		rs.w	1	
ssec_first:		rs.w	1
ssec_len:		rs.b	0

*-------------------------------------------------------*
*	WAD Sidedef structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
sidedef_xoff:		rs.w	1
sidedef_yoff:		rs.w	1
sidedef_utns:		rs.b	8
sidedef_ltns:		rs.b	8
sidedef_mtns:		rs.b	8
sidedef_sector:		rs.w	1
sidedef_len:		rs.b	0

*-------------------------------------------------------*
*	WAD Linedef structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
linedef_from:		rs.w	1
linedef_to:		rs.w	1
linedef_attrib:		rs.w	1
linedef_type:		rs.w	1
linedef_tag:		rs.w	1
linedef_right:		rs.w	1
linedef_left:		rs.w	1
linedef_len:		rs.b	0

*-------------------------------------------------------*
*	WAD Texture structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
wt_name:		rs.b	8
wt_null1:		rs.w	1
wt_null2:		rs.w	1
wt_width:		rs.w	1
wt_height:		rs.w	1
wt_null3:		rs.w	1
wt_null4:		rs.w	1
wt_patches:		rs.w	1
wt_len:			rs.b	0

*-------------------------------------------------------*
*	WAD Texture patch sub-structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
wtp_xoff:		rs.w	1
wtp_yoff:		rs.w	1
wtp_index:		rs.w	1
wtp_stepdir:		rs.w	1
wtp_colormap:		rs.w	1
wtp_len:		rs.b	0

*-------------------------------------------------------*
*	Texture structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
tex_name		rs.b	8
tex_index		rs.w	1
tex_width		rs.w	1
tex_height		rs.w	1
tex_patches		rs.w	1
tex_len			rs.b	0

*-------------------------------------------------------*
*	Texture patch sub-structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
texp_xoff		rs.w	1
texp_yoff		rs.w	1
texp_index		rs.w	1
texp_len		rs.b	0

*-------------------------------------------------------*
*	WAD Node structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
node_x:			rs.w	1
node_y:			rs.w	1
node_dx:		rs.w	1
node_dy:		rs.w	1
node_rvtx:		rs.b	0
node_ry2:		rs.w	1
node_ry1:		rs.w	1
node_rx1:		rs.w	1
node_rx2:		rs.w	1
node_lvtx:		rs.b	0
node_ly2:		rs.w	1
node_ly1:		rs.w	1
node_lx1:		rs.w	1
node_lx2:		rs.w	1
node_right:		rs.w	1	
node_left:		rs.w	1
node_len:		rs.b	0

*-------------------------------------------------------*
*	General display structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
display_sina:		rs.w	1	; sin(pangle)
display_cosa:		rs.w	1	; cos(pangle)
display_px:		rs.w	1	; px
display_py:		rs.w	1	; py
display_width:		rs.w	1	; window x-size
display_height:		rs.w	1	; window y-size
display_rheight:	rs.w	1	; window y-size (ratio)
display_hwid:		rs.w	1	; window x-size/2
display_hhig:		rs.w	1	; window y-size/2
display_hscale:		rs.w	1	; window x-scale
display_vscale:		rs.w	1	; window y-scale
display_imin:		rs.l	1	; projected node min-x
display_imax:		rs.l	1	; projected node max-x
display_segbase:	rs.w	1	; initial seg index for ssector
display_segnum:		rs.w	1	; seg count for ssector
display_segs:		rs.l	1	; seg-array
display_sectors:	rs.l	1	; sector-array
display_nodes:		rs.l	1	; node-array
display_ssectors:	rs.l	1	; ssector-array
display_sidedefs:	rs.l	1	; sidedef-array
display_linedefs:	rs.l	1	; linedef-array
display_vertices:	rs.l	1	; vertex-array
display_columns:	rs.w	1	; columns drawn so far
display_sectorptr:	rs.l	1
display_firstssec:	rs.w	1
display_ch:		rs.w	1
display_fh:		rs.w	1
display_ct:		rs.w	1
display_ft:		rs.w	1
display_ph:		rs.w	1
*-------------------------------------------------------*
*	AddWall local variable structure		*
*-------------------------------------------------------*
addwall_tex:		rs.l	1	; wall texture ID
addwall_i1:		rs.l	1	; wall screen-x1 (unclipped)
addwall_i2:		rs.l	1	; wall screen-x2 (unclipped)
addwall_ci2:		rs.l	1	; wall screen-x2 (clipped)
addwall_y1:		rs.l	1	; wall top
addwall_y2:		rs.l	1	; wall bottom
addwall_z1:		rs.l	1	; wall z1
addwall_z2:		rs.l	1	; wall z2
addwall_pz1:		rs.l	1	; wall perspective-z1
addwall_pz2:		rs.l	1	; wall perspective-z2
addwall_rz1:		rs.l	1	; wall real-z1
addwall_rz2:		rs.l	1	; wall real-z2
addwall_y1a:		rs.l	1	; wall y1 (upper-edge) accumulator
addwall_y2a:		rs.l	1	; wall y2 (lower-edge) accumulator
addwall_y1i:		rs.l	1	; wall y1 (top-edge) increment
addwall_y2i:		rs.l	1	; wall y2 (lower-edge) increment
addwall_tu1:		rs.l	1	; wall u1
addwall_tu2:		rs.l	1	; wall u2
addwall_t1:		rs.l	1	; wall t1
addwall_t2:		rs.l	1	; wall t2
addwall_ti:		rs.l	1	; wall t increment
addwall_hi:		rs.l	1	; high-res (16.16) screen-x (x1)
addwall_hdi:		rs.l	1	; high-res (16.16) screen-dx (x2-x1)
addwall_width:		rs.w	1	; window x-size
addwall_height:		rs.w	1	; window y-size
addwall_rheight:	rs.w	1	; window y-size (ratio)
addwall_hwid:		rs.w	1	; window x-size/2
addwall_hhig:		rs.w	1	; window y-size/2
addwall_hscale:		rs.w	1	; window x-scale
addwall_vscale:		rs.w	1	; window y-scale
addwall_runs:		rs.w	1	; local copy of wall-runs total
addwall_columns:	rs.w	1	; local copy of column-count
addwall_fc:		rs.w	1	; floor colour/texture-ID
addwall_cc:		rs.w	1	; ceiling colour/texture-ID
addwall_opaque:		rs.b	1	; solid flag for textures with holes
addwall_type:		rs.b	1	; wall type (upper/lower/main)
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
