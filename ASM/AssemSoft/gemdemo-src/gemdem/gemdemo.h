		rsreset
FPS_real:	rs.l	1
FPS_average:	rs.l	1
FPS_updates:	rs.l	1
FPS_seconds:	rs.l	1
FPS_frames:	rs.l	1
FPS_second:	rs.b	1
		rs.b	1
FPS_ssize:	= __RS

		rsreset
HZ50_demos:	rs.l	1
HZ50_oldvect:	rs.l	1
HZ50_fps:	rs.b	FPS_ssize
HZ50_routine:	rs.l	0
