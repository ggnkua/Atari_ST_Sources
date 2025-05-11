/*
AUTHOR:
------------------------------------------------------------------------------
Markus Gutschke | Internet: srb242@math.uni-muenster.de
Papenbusch 31   |		   Markus.Gutschke@uni-muenster.de
48159 M"unster  |-------------------------------------------------------------
W-Germany	   | "Death --- no excuse for not working!" 
				|						  ('Supreme Being' in 'Time Bandits')
*/

#include <aesbind.h>
#include <gemfast.h>
#include <macros.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <vdibind.h>

/* header for rectangle buffers (invisible to global functions)	 */

typedef struct {
	long	magic;
	int	 vdihandle;
	int	 pxy[8];
	MFDB	mfdb,scr;
	char	data[1];
} Buffer;

/* check, if two rectangles intersect							   */

static int  intersect(int  x1,int  y1,int  w1,int  h1,
					  int  x2,int  y2,int  w2,int  h2,
					  int *x3,int *y3,int *w3,int *h3)
{
	*x3 = max(x1,x2);
	*y3 = max(y1,y2);
	*w3 = min(x1+w1-1,x2+w2-1) - *x3 + 1;
	*h3 = min(y1+h1-1,y2+h2-1) - *y3 + 1;
	return ((*w3 > 0) && (*h3 > 0));
}

/* save screen rectangle and return handle						  */

void	*flysave(int vdihandle,int x,int y,int w,int h)
{
	int	 workout[57];
	Buffer  *buffer;
	long	size;
	int	 planes,wdwidth;

	vq_extnd(vdihandle,1,workout);
	planes = workout[4];
	wdwidth = (int)((w + 15) / 16);
	size = sizeof(Buffer) + long(planes)*h*2*wdwidth;
	if ((buffer = (Buffer*)malloc(size)) == 0)
		return(0);
	else {
		buffer->magic = 0x4711;
		buffer->vdihandle	   = vdihandle;
		buffer->mfdb.fd_addr	= (long)&buffer->data;
		buffer->mfdb.fd_w	   = w;
		buffer->mfdb.fd_h	   = h;
		buffer->mfdb.fd_wdwidth = wdwidth;
		buffer->mfdb.fd_stand   = 0;
		buffer->mfdb.fd_nplanes = planes;
		buffer->scr.fd_addr	 =
		buffer->scr.fd_w		= 
		buffer->scr.fd_h		= 
		buffer->scr.fd_wdwidth  = 
		buffer->scr.fd_stand	=
		buffer->scr.fd_nplanes  = 0;
		buffer->pxy[0]		  = x;
		buffer->pxy[1]		  = y;
		buffer->pxy[2]		  = x + w - 1;
		buffer->pxy[3]		  = y + h - 1;
		buffer->pxy[4]		  = 0;
		buffer->pxy[5]		  = 0;
		buffer->pxy[6]		  = w-1;
		buffer->pxy[7]		  = h-1;
		graf_mouse(M_OFF,0);
		vro_cpyfm(vdihandle,S_ONLY,buffer->pxy,
				  &buffer->scr,&buffer->mfdb);
		graf_mouse(M_ON,0);
		return(buffer); }
}

/* restore saved screen rectangle								   */

void	flyrestore(void *buffer)
{
	#define buffer  ((Buffer *)buffer)
	int	 pxy[8];
	int	 *s,*d;

	if (buffer != 0 && buffer->magic == 0x4711) {
		buffer->magic = 0;
		d = pxy; s = buffer->pxy+4;
		*d++ = *s++; *d++ = *s++; *d++ = *s++; *d++ = *s++;
		d = pxy+4; s = buffer->pxy;
		*d++ = *s++; *d++ = *s++; *d++ = *s++; *d++ = *s++;
		graf_mouse(M_OFF,0);
		vro_cpyfm(buffer->vdihandle,S_ONLY,pxy,
				  &buffer->mfdb,&buffer->scr);
		graf_mouse(M_ON,0);
		free(buffer); }
	return;
	
	#undef  buffer
}

/* move previously stored rectangle to new position				 */

static void	 *scrmove(void *buffer,int nx,int ny)
{
	#define buffer  ((Buffer *)buffer)
	Buffer  *newbuffer;
	int	 w,h;
	int	 rx,ry,rw,rh;
	int	 pxy[8],rst[8];

	if (buffer != 0 && buffer->magic == 0x4711) {
		graf_mouse(M_OFF,0);
		w = buffer->pxy[2]-buffer->pxy[0]+1;
		h = buffer->pxy[3]-buffer->pxy[1]+1;
		newbuffer = (Buffer*) flysave(buffer->vdihandle,nx,ny,w,h);
		if (newbuffer == 0) {
			form_dial(FMD_FINISH,0,0,0,0,nx,ny,w,h);
			flyrestore(buffer);
			return(0); }
		buffer->magic = 0;
		pxy[0] = buffer->pxy[0];
		pxy[1] = buffer->pxy[1];
		pxy[2] = buffer->pxy[2];
		pxy[3] = buffer->pxy[3];
		pxy[6] = (pxy[4] = nx) + w - 1;
		pxy[7] = (pxy[5] = ny) + h - 1;
		if (intersect(pxy[0],pxy[1],w,h,
					  pxy[4],pxy[5],w,h,
					  &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx - nx) + rw - 1;
			rst[7] = (rst[5] = ry - ny) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,
					  &buffer->mfdb,&newbuffer->mfdb); }
		vro_cpyfm(buffer->vdihandle,S_ONLY,pxy,&buffer->scr,&buffer->scr);
		if (intersect(pxy[0],pxy[1],w,h,
					  pxy[0],pxy[1],pxy[6]-pxy[0]+1,pxy[5]-pxy[1],
					  &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr);}
		if (intersect(pxy[0],pxy[1],w,h,
					  pxy[6]+1,pxy[1],pxy[2]-pxy[6],pxy[7]-pxy[1]+1,
					  &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr);}
		if (intersect(pxy[0],pxy[1],w,h,
					  pxy[4],pxy[7]+1,pxy[2]-pxy[4]+1,pxy[3]-pxy[7],
					  &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr);}
		if (intersect(pxy[0],pxy[1],w,h,
					  pxy[0],pxy[5],pxy[4]-pxy[0],pxy[3]-pxy[5]+1,
					  &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr);}
		graf_mouse(M_ON,0);
		free(buffer);
		return(newbuffer); }
	return(0);
	
	#undef  buffer
}

void flyfly(int vdihandle, void **buffer, int* dx, int* dy, int opaque)
{
	#define buffer  ((Buffer **)buffer)

	int	 x,y,w,h;
	int	 orgx,orgy;
	int	 wx,wy,ww,wh;
	int	 posx,posy,mx,my,mb,mk;

	orgx=x=(*buffer)->pxy[0];
	orgy=y=(*buffer)->pxy[1];
	w=(*buffer)->mfdb.fd_w;
	h=(*buffer)->mfdb.fd_h;

	wind_get(0,WF_WORKXYWH,&wx,&wy,&ww,&wh);

	if (!opaque) {
		flyrestore(*buffer);
		graf_dragbox(w,h,x,y,wx,wy,ww,wh,&x,&y);
		*dx = x - orgx;
		*dy = y - orgy;
		*buffer = (Buffer*)flysave(vdihandle,x,y,w,h);
	} else {
		graf_mkstate(&mx,&my,&mb,&mk);

		posx = x - mx;
		posy = y - my;

		while (mb) {
			evnt_mouse(1,mx,my,1,1,&mx,&my,&mb,&mk);
			x = mx + posx;
			y = my + posy;
			if (x + w > wx + ww) x = wx + ww - w;
			if (x < wx) x = wx;
			if (y + h > wy + wh) y = wy + wh - h;
			if (y < wy) y = wy;
			*buffer = (Buffer*) scrmove(*buffer,x,y);
		}

		*dx = x - orgx;
		*dy = y - orgy;
	}

	#undef buffer
}
