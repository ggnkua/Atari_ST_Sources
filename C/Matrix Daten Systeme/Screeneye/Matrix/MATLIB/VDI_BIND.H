# define VDIescape		 5
# define VDIpline		 6
# define VDIfillarea	 9
# define VDIgdp			11

# define set_contrl(vn,pin,pout,iin,iout,svn,handle)\
	contrl[0] = vn ;\
	contrl[1] = pin ;\
	contrl[2] = pout ;\
	contrl[3] = iin ;\
	contrl[4] = iout ;\
	contrl[5] = svn ;\
	contrl[6] = handle ;

# define set_point(xx,yy)\
	ptsin[0] = xx ;\
	ptsin[1] = yy ;

# define set_ptr(i,p,t)\
	*(t **)&intin[i] = p ;

# define set_rgb(rrggbb)\
	intin[0] = *rrggbb++ ;\
	intin[1] = *rrggbb++ ;\
	intin[2] = *rrggbb   ;

# define get_rgb(rrggbb)\
	*rrggbb++ = intout[0] ;\
	*rrggbb++ = intout[1] ;\
	*rrggbb   = intout[2] ;


extern void callvdi(void);

