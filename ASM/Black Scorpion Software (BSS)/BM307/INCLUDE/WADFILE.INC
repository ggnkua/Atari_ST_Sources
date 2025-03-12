*=======================================================*
*	WAD (file) structures: updated 16/11/95		*
*=======================================================*
*	These structures are *strictly* for WAD		*
*	access inside the 'io.s' source module.		*
*	They are *not* compatible with the same		*
*	structures held in RAM since they are		*
*	reformatted when they are loaded in!		*
*=======================================================*

*-------------------------------------------------------*
*	Thing structure					*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Thing_x			rs.w	1
Thing_y			rs.w	1
Thing_angle		rs.w	1
Thing_type		rs.w	1
Thing_attr		rs.w	1
Thing_len		rs.w	1

*-------------------------------------------------------*
*	Linedef structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Line_from		rs.w	1
Line_to			rs.w	1
Line_flags		rs.w	1
Line_special		rs.w	1
Line_tag		rs.w	1
Line_side0		rs.w	1
Line_side1		rs.w	1
Line_len		rs.w	1

*-------------------------------------------------------*
*	Sidedef structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Side_tm_xoff		rs.w	1
Side_tm_yoff		rs.w	1
Side_upr_txtr		rs.b	8
Side_lwr_txtr		rs.b	8
Side_full_txtr		rs.b	8
Side_sector		rs.w	1
Side_len		rs.w	1

*-------------------------------------------------------*
*	Vertex structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Vertex_x		rs.w	1
Vertex_y		rs.w	1
Vertex_len		rs.w	1

*-------------------------------------------------------*
*	Segs structure					*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Seg_from		rs.w	1
Seg_to			rs.w	1
Seg_angle		rs.w	1
Seg_line		rs.w	1
Seg_line_side		rs.w	1
Seg_line_offset		rs.w	1
Seg_len			rs.w	1

*-------------------------------------------------------*
*	Ssectors structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Ssect_numsegs		rs.w	1
Ssect_firstseg		rs.w	1
Ssect_len		rs.w	1

*-------------------------------------------------------*
*	Nodes structure					*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Node_x			rs.w	1
Node_y			rs.w	1
Node_dx			rs.w	1
Node_dy			rs.w	1
Node_ry2		rs.w	1
Node_ry1		rs.w	1
Node_rx1		rs.w	1
Node_rx2		rs.w	1
Node_ly2		rs.w	1
Node_ly1		rs.w	1
Node_lx1		rs.w	1
Node_lx2		rs.w	1
Node_right		rs.w	1
Node_left		rs.w	1
Node_len		rs.w	1

*-------------------------------------------------------*
*	Sectors structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Sector_floorht		rs.w	1
Sector_ceilht		rs.w	1
Sector_flr_txtr		rs.b	8
Sector_clg_txtr		rs.b	8
Sector_light		rs.w	1
Sector_type		rs.w	1
Sector_trigger		rs.w	1
Sector_len		rs.w	1

*-------------------------------------------------------*
*	Blockmap structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
Blockmap_Xorig		rs.w	1
Blockmap_Yorig		rs.w	1
Blockmap_Ncols		rs.w	1
Blockmap_Nlins		rs.w	1

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

