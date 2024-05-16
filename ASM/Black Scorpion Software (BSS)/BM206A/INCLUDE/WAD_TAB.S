*=======================================================*
*	WAD tables: latest update 16/11/95		*
*=======================================================*

*----------------------------------------------*
* Offsets for 'THINGS' table
*----------------------------------------------*
		rsreset
Thing_x		rs.w	1
Thing_y		rs.w	1
Thing_angle	rs.w	1
Thing_type	rs.w	1
Thing_attr	rs.w	1
Thing_len	rs.w	1

*----------------------------------------------*
* Offsets for 'LINEDEFS' table'
*----------------------------------------------*
		rsreset
Line_from	rs.w	1
Line_to		rs.w	1
Line_flags	rs.w	1
Line_special	rs.w	1
Line_tag	rs.w	1
Line_side0	rs.w	1
Line_side1	rs.w	1
Line_len	rs.w	1

*----------------------------------------------*
* Offsets for 'SIDEDEFS' table'
*----------------------------------------------*
		rsreset
Side_tm_xoff	rs.w	1
Side_tm_yoff	rs.w	1
Side_upr_txtr	rs.b	8
Side_lwr_txtr	rs.b	8
Side_full_txtr	rs.b	8
Side_sector	rs.w	1
Side_len	rs.w	1

*----------------------------------------------*
* Offsets for 'VERTEXES' table'
*----------------------------------------------*
		rsreset
Vertex_x	rs.w	1
Vertex_y	rs.w	1
Vertex_len	rs.w	1

*----------------------------------------------*
* Offsets for 'SEGS' table
*----------------------------------------------*
		rsreset
Seg_from	rs.w	1
Seg_to		rs.w	1
Seg_angle	rs.w	1
Seg_line	rs.w	1
Seg_line_side	rs.w	1
Seg_line_offset	rs.w	1
Seg_len		rs.w	1

*----------------------------------------------*
* Offsets for 'SSECTORS' table
*----------------------------------------------*
		rsreset
Ssect_numsegs	rs.w	1
Ssect_firstseg	rs.w	1
Ssect_len	rs.w	1

*----------------------------------------------*
* Offsets for 'NODES' table
*----------------------------------------------*
		rsreset
Node_x		rs.w	1
Node_y		rs.w	1
Node_dx		rs.w	1
Node_dy		rs.w	1
Node_ry2	rs.w	1
Node_ry1	rs.w	1
Node_rx1	rs.w	1
Node_rx2	rs.w	1
Node_ly2	rs.w	1
Node_ly1	rs.w	1
Node_lx1	rs.w	1
Node_lx2	rs.w	1
Node_right	rs.w	1
Node_left	rs.w	1
Node_len	rs.w	1

*----------------------------------------------*
* Offsets for 'SECTORS' table
*----------------------------------------------*
		rsreset
Sector_floorht	rs.w	1
Sector_ceilht	rs.w	1
Sector_flr_txtr	rs.b	8
Sector_clg_txtr	rs.b	8
Sector_light	rs.w	1
Sector_type	rs.w	1
Sector_trigger	rs.w	1
Sector_len	rs.w	1
