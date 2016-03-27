#include <aes.h>
#include <vdi.h>

# include "vdi_bez.h"
# include "vdi_bind.h"

int     contrl [ 12 ];
int     intin  [ 128 ];
int     ptsin  [ 512 ];
int     intout [ 10 ];
int     ptsout [ 10 ];


int v_bez_on(int handle)
{
	set_contrl(VDIgdp,1,0,0,4,13,handle) ;
	callvdi();
	return intout[0];
}

	
void v_bez_off(int handle)
{
	set_contrl(VDIgdp,0,0,0,0,13,handle) ;
	contrl[6] = handle;
	callvdi();
}
	

void v_bez(int handle, int count, char *bezarr, int *xyarray,
           int *npts, int *nmove, int *extent)
{
	int i;

	set_contrl(VDIpline,count,2,(count + 1)/2,6,13,handle) ;

	for (i=0;i<count;i++)
		intin[i] = bezarr[i];
	for (i=0;i<count * 2;i++)
		ptsin[i] = xyarray[i];
	callvdi();
	*npts = intout[0];
	*nmove = intout[1];
	for (i=0;i<4;i++)
		extent[i] = ptsout[i];
}


void v_bezfill(int handle, int count, char *bezarr, int *xyarray,
               int *npts, int *nmove, int *extent)
{
	int i;
	
	set_contrl(VDIfillarea,count,2,(count + 1)/2,6,13,handle) ;

	for (i=0;i<count;i++)
		intin[i] = bezarr[i];
	for (i=0;i<count * 2;i++)
		ptsin[i] = xyarray[i];
	callvdi();
	*npts = intout[0];
	*nmove = intout[1];
	for (i=0;i<4;i++)
		extent[i] = ptsout[i];
}


void v_set_app_buf(void *address, int nparagraphs)
{
	set_contrl(-1,0,0,3,0,6,0) ; /* Who cares what the handle is? */

	intin[0] = (int)(((long)address) & 0x0000FFFFL);
	intin[1] = (int)((((long)address) & 0xFFFF0000L) >> 16);
	intin[2] = nparagraphs;

	callvdi();
}


void v_bez_qual(int handle, int prcnt, int *actual)
{
	set_contrl(VDIescape,0,0,3,1,90,handle) ;
	intin[0] = 32;
	intin[1] = 1;
	intin[2] = prcnt;
	callvdi();
	*actual = intout[0];
}
	
