extern int  v_bez_on(int handle);
extern void v_bez_off(int handle);
extern void v_bez(int handle, int count, char *bezarr, int *xyarray,
           			int *npts, int *nmove, int *extent);
extern void v_bezfill(int handle, int count, char *bezarr, int *xyarray,
	                int *npts, int *nmove, int *extent);
extern void v_set_app_buf(void *address, int nparagraphs);
extern void v_bez_qual(int handle, int prcnt, int *actual);
