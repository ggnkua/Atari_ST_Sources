		rsreset
save_log	rs.l	1	
set_log		rs.l	1
restore_log	rs.l	1

save_reso	rs.l	1	
set_reso	rs.l	1
restore_reso	rs.l	1

save_pal	rs.l	1	
set_pal		rs.l	1
restore_pal	rs.l	1



asave_screen		macro
			clr.l	(save_log,[$40c.w])
			endm

asave_palette		macro
			clr.l	(save_pal,[$40c.w])
			endm

asave_video		macro
			clr.l	(save_reso,[$40c.w])
			endm

arestore_screen		macro
			clr.l	(restore_log,[$40c.w])
			endm

arestore_palette	macro
			clr	(restore_pal,[$40c.w])
			endm

arestore_video		macro
			clr.l	(restore_reso,[$40c.w])
			endm

aset_screen		macro
			move.l	\1,(set_log,[$40c.w])
			endm

aset_palette	macro
			move.l	\1,(set_pal,[$40c.w])
			endm

aset_video		macro
			move.l	\1,(set_reso,[$40c.w])
			endm

	



