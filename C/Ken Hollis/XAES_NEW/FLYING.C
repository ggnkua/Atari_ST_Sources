/********************************************************************
 *																0.50*
 *	XAES: Flying Dialogs and Custom Screen save routines			*
 *	by Ken Hollis and Markus Gutschke								*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Commented routines are not yet used, but are functional.		*
 *	This code is by Markus Gutschke, which goes without saying.		*
 *	Markus makes a living out of *trying* to create convoluted code.*
 *																	*
 ********************************************************************/

#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>

#include "xaes.h"

void *bgbuffer;

GLOBAL int intersect(int  x1,int  y1,int  w1,int  h1,
      	   	         int  x2,int  y2,int  w2,int  h2,
          	         int *x3,int *y3,int *w3,int *h3)
{
	*x3	= max(x1,x2);
	*y3	= max(y1,y2);
	*w3	= min(x1+w1-1,x2+w2-1) - *x3 + 1;
	*h3	= min(y1+h1-1,y2+h2-1) - *y3 + 1;
	return ((*w3 > 0) && (*h3 > 0));
}

/* GLOBAL void *scrmove(void *buffer,int nx,int ny)
{
	#define	buffer	((Buffer *)buffer)
	Buffer	*newbuffer;
	int		w,h;
	int		rx,ry,rw,rh;
	int		pxy[8],rst[8];

	if (buffer != 0 && buffer->magic == 0x4711) {
		graf_mouse(M_OFF,0);
		w = buffer->pxy[2]-buffer->pxy[0]+1;
		h = buffer->pxy[3]-buffer->pxy[1]+1;
		newbuffer = scrsave(buffer->vdihandle,nx,ny,w,h);
		if (newbuffer == 0) {
			form_dial(FMD_FINISH,0,0,0,0,nx,ny,w,h);
			scrrestore(buffer);
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
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr); }
		if (intersect(pxy[0],pxy[1],w,h,
		              pxy[6]+1,pxy[1],pxy[2]-pxy[6],pxy[7]-pxy[1]+1,
		              &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr); }
		if (intersect(pxy[0],pxy[1],w,h,
		              pxy[4],pxy[7]+1,pxy[2]-pxy[4]+1,pxy[3]-pxy[7],
		              &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr); }
		if (intersect(pxy[0],pxy[1],w,h,
		              pxy[0],pxy[5],pxy[4]-pxy[0],pxy[3]-pxy[5]+1,
		              &rx,&ry,&rw,&rh)) {
			rst[2] = (rst[0] = rx - pxy[0]) + rw - 1;
			rst[3] = (rst[1] = ry - pxy[1]) + rh - 1;
			rst[6] = (rst[4] = rx) + rw - 1;
			rst[7] = (rst[5] = ry) + rh - 1;
			vro_cpyfm(buffer->vdihandle,S_ONLY,rst,&buffer->mfdb,&buffer->scr); }
		graf_mouse(M_ON,0);
		free(buffer);
		return(newbuffer); }
	return(0);
	
	#undef	buffer
} */

GLOBAL void *scrsave(int vdihandle,int x,int y,int w,int h)
{
	int		workout[57];
	Buffer	*buffer;
	long	size;
	int		planes,wdwidth;

	vq_extnd(vdihandle,1,workout);
	planes = workout[4];
	wdwidth = (int)((w + 15) / 16);
	size = sizeof(Buffer) + (long)planes*(long)h*2L*(long)wdwidth;
	if ((buffer = malloc(size)) == 0)
		return(0);
	else {
		buffer->magic = 0x4711;
		buffer->vdihandle		= vdihandle;
		buffer->mfdb.fd_addr 	= ((long) &buffer->data);
		buffer->mfdb.fd_w		= w;
		buffer->mfdb.fd_h		= h;
		buffer->mfdb.fd_wdwidth	= wdwidth;
		buffer->mfdb.fd_stand	= 0;
		buffer->mfdb.fd_nplanes	= planes;
		buffer->scr.fd_addr		= (long)(0L);
		buffer->scr.fd_w		= 
		buffer->scr.fd_h		= 
		buffer->scr.fd_wdwidth	= 
		buffer->scr.fd_stand	=
		buffer->scr.fd_nplanes	= 0;
		buffer->pxy[0]			= x;
		buffer->pxy[1]			= y;
		buffer->pxy[2]			= x + w - 1;
		buffer->pxy[3]			= y + h - 1;
		buffer->pxy[4] 			= 0;
		buffer->pxy[5] 			= 0;
		buffer->pxy[6] 			= w-1;
		buffer->pxy[7] 			= h-1;
		graf_mouse(M_OFF,0);
		vro_cpyfm(vdihandle,S_ONLY,buffer->pxy,
				  &buffer->scr,&buffer->mfdb);
		graf_mouse(M_ON,0);
		return((void *)buffer); }
}

GLOBAL void scrrestore(void *buffer)
{
	#define	buffer	((Buffer *)buffer)
	int		pxy[8];
	int		*s,*d;

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
	
	#undef	buffer
}

/* GLOBAL BOOL WCanFly(void)
{
	if (find_cookie('NVDI'))
		return TRUE;

	return FALSE;
} */