* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 data_07				*
* 		control matrices for rotation			*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* +ve rotation about the view frame x axis (left) by 5 degrees
rot_x_pos:
	dc.w	16384,0,0,0,16322,1428,0,-1428,16322

* -ve rotation about the xv axis (right)
rot_x_neg:
	dc.w	16384,0,0,0,16322,-1428,0,1428,16322

* +ve rotation about the yv axis (up)
rot_y_pos:
	dc.w	16322,0,-1428,0,16384,0,1428,0,16322

* -ve rotation about the yv axis (down)
rot_y_neg:
	dc.w	16322,0,1428,0,16384,0,-1428,0,16322

* +ve rotation about the zv axis (roll-right)
rot_z_pos:
	dc.w	16322,1428,0,-1428,16322,0,0,0,16384

* -ve rotation about the zv axis (roll-left)
rot_z_neg:
	dc.w	16322,-1428,0,1428,16322,0,0,0,16384
