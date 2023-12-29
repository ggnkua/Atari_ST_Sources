; Demo bss
	rsset 0
d_next:		rs.l 1	;Address of next Demo structure
d_winh		rs.w 1 	;Window handle of the window
d_zoom		rs.b 1	;Flag 0 = non zoom, 1 = 2x, 2 = 4x
d_resrv0	rs.b 1
d_winbss	rs.l 1	;Address of the windows BSS area
d_basepage	rs.l 1	;Address of this demo's basepage
d_init		rs.l 1	;Address of the init routine (used when converting th gfx)
d_50hz		rs.l 1	;Address of a 50Hz routine.. NOT YET IMPLEMENTED.
d_rout		rs.l 1	;Address of the update routine ;Install appropriate demo routine here
d_rout1x	rs.l 1	;Address of the update routine
d_rout2x	rs.l 1	;Address of the update routine 2x
d_rout4x	rs.l 1	;address of the update routine 4x
d_xres		rs.w 1	;X resolution (used to set window size)
d_yres		rs.w 1	;Y resolution (used to set window size)
d_texture	rs.l 1	;Texture map.. if I understand things correctly
d_texturesize	rs.l 1	;Size of the texture in bytes. Used when converting, for example.. (Total size.. after "expanding" or double-buffered or summin)
d_sinus		rs.l 1	;Sinus table for this demo (is this necessary? different sinus tables? )
d_scrnadr	rs.l 1	;Screen address (or plot address)
d_scnl_jump	rs.l 1	;This is where your plot routine gets the scanline_jump
d_mscnljmp	rs.l 1	;Value to subtract from scanline-width (Initially 288 in this case, or xx_xres*2)
d_sslj		rs.l 1	;The shell keeps a copy of the original value d_mscnljump here (for zooming stuff)
d_name		rs.l 8	;Null terminated name of this demo (31 chars+0 max)

d_ctrl1_name	rs.l 8

d_ctrl1_value	rs.l 1
d_ctrl1_max	rs.l 1
d_ctrl1_min	rs.l 1
d_ctrl1_step	rs.l 1
d_ctrl1_start	rs.l 1

d_ctrl2_name	rs.l 8
d_ctrl2_value	rs.l 1
d_ctrl2_max	rs.l 1
d_ctrl2_min	rs.l 1
d_ctrl2_step	rs.l 1
d_ctrl2_start	rs.l 1

d_ctrl3_name	rs.l 8
d_ctrl3_value	rs.l 1
d_ctrl3_max	rs.l 1
d_ctrl3_min	rs.l 1
d_ctrl3_step	rs.l 1
d_ctrl3_start	rs.l 1

d_ctrl4_name	rs.l 8
d_ctrl4_value	rs.l 1
d_ctrl4_max	rs.l 1
d_ctrl4_min	rs.l 1
d_ctrl4_step	rs.l 1
d_ctrl4_start	rs.l 1

d_ctrl5_name	rs.l 8
d_ctrl5_value	rs.l 1
d_ctrl5_max	rs.l 1
d_ctrl5_min	rs.l 1
d_ctrl5_step	rs.l 1
d_ctrl5_start	rs.l 1

d_ctrl6_name	rs.l 8
d_ctrl6_value	rs.l 1
d_ctrl6_max	rs.l 1
d_ctrl6_min	rs.l 1
d_ctrl6_step	rs.l 1
d_ctrl6_start	rs.l 1

;d_i_icon	rs.l 1
;d_i_button	rs.l 1
;d_i_top1	rs.l 1
;d_i_top2	rs.l 1
;d_i_top3	rs.l 1
;d_i_left1	rs.l 1
;d_i_left2	rs.l 1
;d_i_left3	rs.l 1
;d_i_left4	rs.l 1
;d_i_left5	rs.l 1
;d_i_left6	rs.l 1
;d_i_left7	rs.l 1
;d_i_right1	rs.l 1
;d_i_right2	rs.l 1
;d_i_right3	rs.l 1
;d_i_right4	rs.l 1
;d_i_right5	rs.l 1
;d_i_right6	rs.l 1
;d_i_right7	rs.l 1

dpb_ssize	= __RS

		rsset 0
di_memalloc	rs.l 1	;Address of the "alloc-mem" routine

di_ssize	= __RS

