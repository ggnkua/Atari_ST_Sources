/*******************************
    GEM Related Functions
*******************************/

/***********************************
	Will put dialog box on screen
	and return exit object after
	erasing it.
***********************************/
void erase_dialog(
	int	x,
	int	y,
	int	w,
	int	h	)
	{
	int sx,sy;
	sx=x+(w/2);
	sy=y+(h/2);
	form_dial(FMD_SHRINK,sx,sy,0,0,x,y,w,h);
	form_dial(FMD_FINISH,sx,sy,0,0,x,y,w,h);
	}

void draw_dialog(
	int		box_ind,
	int		*x,
	int		*y,
	int		*w,
	int		*h,
	char	draw	)
	{
	int		sx,sy;
	
	form_center(rs_trindex[box_ind],x,y,w,h);
	sx=*x+(*w/2);
	sy=*y+(*h/2);
	
	form_dial(FMD_START,sx,sy,0,0,*x,*y,*w,*h); 
	form_dial(FMD_GROW,sx,sy,0,0,*x,*y,*w,*h);
	if (draw) objc_draw(rs_trindex[box_ind],0,10,*x,*y,*w,*h);
	}
	
void dial_draw(
	int box_ind,
	int	obj	)
	{
	int		x1,y1;
	OBJECT	*redraw;
	
	redraw = &rs_object[rs_trloc[box_ind]+obj];
	objc_offset(rs_trindex[box_ind],obj,&x1,&y1);
	objc_draw(rs_trindex[box_ind],0,10,x1,y1,redraw->ob_width,redraw->ob_height);
	}

int	exit_dialog(
	int box_ind,
	int	x,
	int	y,
	int	w,
	int	h,
	int	draw	)
	{
	int 	e;
	
	if (draw) objc_draw(rs_trindex[box_ind],0,10,x,y,w,h);
	e = form_do(rs_trindex[box_ind],0);
	rs_object[rs_trloc[box_ind]+e].ob_state &= UNSELECT;
	dial_draw(box_ind,e);
	return(e);
	}

void redraw_dialog(
	int	box_ind,
	int	x,
	int	y,
	int	w,
	int	h	)
	{
	objc_draw(rs_trindex[box_ind],0,10,x,y,w+5,h+5);
	}

void dial2_draw(
	int box_ind,
	int	obj1,
	int	obj2	)
	{
	int		x1,y1;
	int		x2,y2;
	int		w,h;
	OBJECT	*redraw1,*redraw2;
	
	redraw1 = &rs_object[rs_trloc[box_ind]+obj1];
	redraw2 = &rs_object[rs_trloc[box_ind]+obj2];
	objc_offset(rs_trindex[box_ind],obj1,&x1,&y1);
	objc_offset(rs_trindex[box_ind],obj2,&x2,&y2);
	w = x2-x1+redraw2->ob_width;
	h = y2-y1+redraw2->ob_height;
	if (w < redraw1->ob_width)	w = redraw1->ob_width;
	if (h < redraw1->ob_height)	h = redraw1->ob_height;
	objc_draw(rs_trindex[box_ind],0,10,x1,y1,w,h);
	}

