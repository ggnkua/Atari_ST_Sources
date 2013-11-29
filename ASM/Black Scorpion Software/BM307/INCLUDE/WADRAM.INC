*=======================================================*
*	WAD (ram) structures: updated 16/11/95		*
*=======================================================*
*	These structures are *strictly* for access	*
*	to the WAD structures held in RAM.		*
*	There is a separate set of structures for	*
*	direct access to the WAD file itself, so make	*
*	sure you don't mix them both up.		*
*=======================================================*

*-------------------------------------------------------*
*	Vertex ministructure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
vtx_x:			rs.w	1
vtx_y:			rs.w	1
vtx_len:		rs.b	0
 
*-------------------------------------------------------*
*	Seg structure					*
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
*	Sector structure				*
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
*	SSector structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
ssec_segments:		rs.w	1	
ssec_first:		rs.w	1
ssec_len:		rs.b	0

*-------------------------------------------------------*
*	Sidedef structure				*
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
*	Linedef structure				*
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
*	Node structure					*
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

