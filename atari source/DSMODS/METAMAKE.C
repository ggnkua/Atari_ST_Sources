/*************************************************************************/
/* METAMAKE.C								 */
/* DATE CREATED:  0/0/0							 */
/* LAST MODIFIED: 09/21/88						 */
/*************************************************************************/

#include	<osbind.h>
#include	<gemdefs.h>
#include	"alert.h"

#define GDP		11
#define LINE_WIDTH	16
#define MARKER_HEIGHT	19
#define VST_HEIGHT	12
#define VST_POINT	107
#define V_UPDATE	4
#define ARC		2
#define PIE		3
#define CIRCLE		4
#define ELLIPSE		5
#define ELLARC		6
#define ELLPIE		7
#define JUSTEXT		10
#define V_CLEAR		3
#define VGTEXT		8
#define ESCAPE		5
#define V_WRITE		99
#define V_CLIP		129

extern	int	contrl[], intin[], ptsin[], intout[], ptsout[];
extern  int	ptsarray[];

extern  FDB	page_MFDB;
extern  FDB	laser_MFDB;
extern	int	mhandle;	/* memory driver handle		*/
extern 	int 	phandle;

extern  int 	scan_xres;
extern  long	scanptr;

extern  int	print_flag;
extern  char *get_lcmem();
extern  int     hpage_size;
extern  int     vpage_size;
extern  char    fbuffer[];
extern  char *dpath1;
extern  char *dpath2;
extern  char *dpath3;
extern  char *dpath4;
extern  int scan_xres,scan_yres;
extern  int mxres,myres;
extern  unsigned long page_ptr;

extern  int mnumfnt;
extern  int pnumfnt;

int font_flag;


long readswap();

int	meta_wd, meta_ht;
int	formw, formy;

int logo[16] = {
		 0x05a0,0x5a0,0x5a0,0x5a0,0xdb0,0x0db0,0x1db8,0x399c,
		 0x799e,0x718e,0x718e,0x6186,0x4182,0,0,0
	       };

long	readswap(handle, length, buffer)
long	length;
int	handle;
register char	*buffer;
{
	register long	count;
        long bytes_read;
	char	temp;

	bytes_read = Fread(handle,length,buffer);
	for (count = 0;count < bytes_read;count += 2) {
	  temp		 = buffer[count];
	  buffer[count]  = buffer[count+1];
	  buffer[count+1]= temp;
	}
	return(bytes_read);
}

mtadjx(x)
int	x;
{
	return((int)(((long)x * (long)formw) / (long)meta_wd));
}

mtadjy(y)
int	y;
{
	return((int)(((long)y * (long)formy) / (long)meta_ht));
}


/********************************/
/*	MetaFile display	*/
/********************************/
meta_make(handle, mx, my,mw,mh)
register int	handle;
int    mx, my, mw, mh;
{
   int  x1,y1,wid,ht;
   register int	i;
   int  dummy, header_length;
   int	pagex, pagey, llx, lly, urx, ury;
   register int  thandle;

   /*	first word is 0fffh	*/
   Fread(handle, 2L, &dummy);

   /*	read length of header in words	*/
   readswap(handle, 2L, &header_length);

   /*	skip over version number	*/
   Fread(handle, 2L, &dummy);

   /*	get scaling factors	*/
   readswap(handle, 2L, &dummy);	/* rc_ndc not used	*/
   readswap(handle, 2L, &dummy);	/* minx not used	*/
   readswap(handle, 2L, &dummy);	/* miny not used	*/
   readswap(handle, 2L, &dummy);	/* maxx not used	*/
   readswap(handle, 2L, &dummy);	/* maxy not used	*/
   readswap(handle, 2L, &pagex);
   readswap(handle, 2L, &pagey);
   readswap(handle, 2L, &llx);
   readswap(handle, 2L, &lly);
   readswap(handle, 2L, &urx);
   readswap(handle, 2L, &ury);

   /*	seek past the header	*/
   Fseek((long)header_length * 2L, handle, 0);

   meta_wd	= urx - llx + 1;
   meta_ht	= lly - ury + 1;


   if(print_flag== 1)  /* Convert to pixels and scale  */
   {
        mutolas(mx,my,&x1,&y1);
        mutolas(mw,mh,&wid,&ht);
        thandle = phandle;
   }
   else if(!print_flag)
   {
        mutopage(mx,my,&x1,&y1,0);
        mutopage(mw,mh,&wid,&ht,1);
        thandle = mhandle;
   }
   else if(print_flag == 2)
   {					/* Special case for repel image */
	mutomem(mx,my,&x1,&y1);
	mutomem(mw,mh,&wid,&ht);
	thandle = mhandle;
	GDvq_extnd(mhandle,0,intout,scan_xres,scan_yres,&scanptr);
   }

   formw = wid;
   formy = ht;

   for (;;) {
	/*	read opcode	*/
	readswap(handle, 2L, &contrl[0]);
	if (contrl[0]==0xFFFF) break;

	/*	read vertex count	*/
	readswap(handle, 2L, &contrl[1]);
      
	/*	read integer count	*/
	readswap(handle, 2L, &contrl[3]);

	/*	read sub-opcode		*/
	readswap(handle, 2L, &contrl[5]);
      
	/*	read in points and swap	*/
	readswap(handle, (long)contrl[1] * 4L, ptsin);

	/*	transform co-ords	*/
	switch (contrl[0]) {
	case GDP:
	   switch (contrl[5]) {
	   case CIRCLE:
	   case ARC:
	   case PIE:
	   case ELLIPSE:
	   case ELLPIE:
	   case ELLARC:
	   case JUSTEXT:
		ptsin[0] = x1 + mtadjx(ptsin[0]-llx);
		ptsin[1] = y1 + mtadjy(ptsin[1]-ury);
		for (i = 2;i < (contrl[1] * 2);i += 2) {
		   ptsin[i]   = mtadjx(ptsin[i]  );
		   ptsin[i+1] = mtadjy(ptsin[i+1]);
		}
		break;
	   default:
		goto others;
	   }
	   break;
	case LINE_WIDTH:
	case MARKER_HEIGHT:
	case VST_HEIGHT:
	   ptsin[0] = mtadjx(ptsin[0]);
	   ptsin[1] = mtadjy(ptsin[1]);
	   break;
	default:
	others:
	   for (i = 0;i < (contrl[1] * 2);i += 2) {
		ptsin[i]   = x1 + mtadjx(ptsin[i]  -llx);
		ptsin[i+1] = y1 + mtadjy(ptsin[i+1]-ury);
	   }
	   break;
	}

	/*	read in ints and swap	*/
	readswap(handle, (long)contrl[3] * 2L, intin);

	/*	for scaled image, change vst_point to vst_height
		and transform sizes	*/
	if (contrl[0] == VST_POINT) {
	  contrl[0] = VST_HEIGHT;
	  contrl[1] = 1;
	  contrl[3] = 0;
	  ptsin[0]  = 0;
	  ptsin[1]  = (int)(((long)intin[0] *3L* (long)formy)/ (long)pagey);
	}

	if((contrl[0] != V_UPDATE) && (contrl[0] != V_CLEAR) &&
           (contrl[0] != V_CLIP))
	{
          if(
              ((contrl[0] == VGTEXT) ||
	      ((contrl[0] == GDP) && (contrl[5] == JUSTEXT)))
            )
          {
	     if(((phandle == thandle) && pnumfnt) ||
	        ((mhandle == thandle) && mnumfnt) )
	     {
   	       contrl[6] = thandle;
	       vdi();
	     }
          }
          else
	  {
	     if(contrl[0] == ESCAPE)
	     {
		if(contrl[5] != V_WRITE)
		{
		       contrl[6] = thandle;
		       vdi();
		}
             }
             else
             {	
	       contrl[6] = thandle;
	       vdi();
	     }
          }
	}
   }
   if(print_flag == 2)
	GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);	

   vsf_udpat(thandle,logo,1);		/* user pattern to Atari Logo*/
   vsl_type(thandle,1);			/* Line type to solid	     */
   vsl_width(thandle,1);		/* Line width to 1	     */
   vsl_ends(thandle,0,0);		/* end points to squares...  */

   vswr_mode(thandle,1);		/* set to replace...	     */
   vst_color(thandle,1);		/* set text, fill and line   */
   vsf_color(thandle,1);		/* color index to 1	     */
   vsl_color(thandle,1);   
}



/********************************/
/*	IMG File display	*/
/********************************/
disp_img(filename,x1,y1,x2,y2)
register char	*filename;
int	x1,y1,x2,y2;
{
	int 	thandle;
	register int	i;
	int	tx1,ty1,tx2,ty2;

   	if(print_flag == 1)  /* Convert to pixels and scale  */
   	{
           mutolas(x1,y1,&tx1,&ty1);
           mutolas(x2,y2,&tx2,&ty2);
           thandle = phandle;
   	}
   	else if(!print_flag)
   	{
           mutopage(x1,y1,&tx1,&ty1,0);
           mutopage(x2,y2,&tx2,&ty2,0);
           thandle = mhandle;
   	}
	else if(print_flag == 2)
        {
	   mutomem(x1,y1,&tx1,&ty1);
	   mutomem(x2,y2,&tx2,&ty2);
	   thandle = mhandle;
	   GDvq_extnd(mhandle,0,intout,scan_xres,scan_yres,&scanptr);	   
        }
	
	contrl[0] = 5;
	contrl[1] = 2;
	contrl[2] = 0;
	contrl[4] = 0;
	contrl[5] = 23;
	contrl[6] = thandle;
	intin[0]  = intin[1] = intin[2] = intin[3] = intin[4] = 0;

	for (i = 0;filename[i];intin[i+5] = (int)filename[i++]);
	contrl[3] = i + 5;

	ptsin[0]  = tx1;
	ptsin[1]  = ty1;
	ptsin[2]  = tx2;
	ptsin[3]  = ty2;
	vdi();
/*	if(print_flag == 0 || print_flag == 2)*/
	    v_clear_disp_list(mhandle);		/* Frees up image buffers */
	if(print_flag == 2)
	    GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);

}


/********************************/
/*	NEO File display	*/
/********************************/
disp_neo(grbuf,cobuf,x1,y1,w,h)
unsigned char	*grbuf;
unsigned	*cobuf;
int	x1, y1;
int 	w,h;
{
        int tmp;

	struct	{
	  unsigned char	*sMF;	/* +00 Source Memory Form base address	*/
	  unsigned	swb;	/* +04 Width of memory form (in bytes)	*/
	  unsigned	sx;	/* +06 Xmin of source rectangle		*/
	  unsigned	sy;	/* +08 Ymin of source rectangle		*/
	  unsigned	sw;	/* +10 Width	(in pixels)		*/
	  unsigned	sh;	/* +12 Height	(in pixels)		*/

	  unsigned long	dMF;	/* +14 Target Memory Form base address	*/
	  unsigned	dwb;	/* +18 Width of memory form (in bytes)	*/
	  unsigned	dx;	/* +20 Xmin of target rectangle		*/
	  unsigned	dy;	/* +22 Ymin of target rectangle		*/
	  unsigned	dw;	/* +24 Width	(in pixels)		*/
	  unsigned	dh;	/* +26 Height	(in pixels)		*/
	}	neo;

	neo.sMF	= grbuf;
	neo.swb	= 160;
	neo.sx	= 0;
	neo.sy	= 0;
	neo.sw	= 320;
	neo.sh	= 200;

	if((x1 >= hpage_size) || /* If the object is off the page, then */
	   (y1 >= vpage_size) || /* Don't print it...                   */
	   ((x1 + w) <= 0)    ||
           ((y1 + h) <= 0)
          )return;

	if(x1 < 0)		 /* Otherwise, clip them...             */
	{
		neo.sx = scale_iv(abs(x1),320,w);
		w  -= abs(x1);
		x1 = 0;
		neo.sw -= neo.sx;
	}
	        
	if((x1 + w) > hpage_size) 
	{
	        tmp = (x1 + w) - hpage_size; 
		neo.sw -= scale_iv(tmp,320,w);
		w -= tmp;
  	}
		
        if(y1 < 0)
	{
	        neo.sy = scale_iv(abs(y1),200,h);
		h -= abs(y1);
		y1 = 0;
		neo.sh -= neo.sy;
	}

	if((y1 + h) > vpage_size)
	{
	        tmp = (y1 + h) - vpage_size;
	  	neo.sh -= scale_iv(tmp,200,h);
		h -= tmp;
	}
	
        if(print_flag == 1)  /* Convert to pixels and scale  */
        {
 	       mutolas(x1,y1,&neo.dx,&neo.dy);
 	       mutolas(w,h,&neo.dw,&neo.dh);
	       neo.dMF = laser_MFDB.fd_addr;
	       neo.dwb = ((laser_MFDB.fd_w + 15)/16)*2;
	       neo.dw--;
        }
        else if(!print_flag)
        {
 	       mutopage(x1,y1,&neo.dx,&neo.dy,0);
 	       mutopage(w,h,&neo.dw,&neo.dh,1);
	       neo.dMF	= page_MFDB.fd_addr;
	       neo.dwb = ((page_MFDB.fd_w + 15)/16)*2;
	       neo.dw--;
        }
	else if(print_flag == 2)
	{
	       mutomem(x1,y1,&neo.dx,&neo.dy);
	       mutomem(w,h,&neo.dw,&neo.dh);
	       neo.dMF  = scanptr;
               neo.dwb = ((scan_xres + 15)/16)*2;
	       neo.dw--;
	}

	haftone(&neo,cobuf);
}



/****************************************************************
*	Function Name :		insert_graphic()		*
*	Desc :	This routine handles graphics file insertion.	*
*	Calling convention :	insert_graphic(cmd_ptr,arg)	*
*		unsigned char	cmd_ptr : pointer to command	*
*		unsigned	arg : argument value		*
****************************************************************/
insert_graphic()
{
	unsigned char	*gfile;
	long	grbuf;
	int	cobuf[16];
	register int	fid;
	int	w, h, pw, ph;

	
   gfile	= &ptsarray[5];  	/* graphics image DOS filename	*/
   strcpy(fbuffer,dpath3);
   strcat(fbuffer,gfile);
   if (((fid = Fopen(fbuffer,0)) <= 0)) 
   {
      alert_cntre(ALERT16);
      return;
   }
   switch((int)ptsarray[4]) {
	case 0	:				/* NEOchrome image	*/
		grbuf = (long)get_lcmem(32000L);
		if(!grbuf)
		{
		   alert_cntre(ALERT32);
		   Fclose(fid);
		   return;
		}
		Fseek(4L,fid,0);		/* skip first 4 bytes	*/
		Fread(fid,32L,cobuf);		/* read color buffer	*/
		Fseek(128L,fid,0);		/* skip 128bytes header */
		Fread(fid,32000L,grbuf);	/* read file bit block	*/
		disp_neo(grbuf,cobuf,ptsarray[0],ptsarray[1],
			  ptsarray[2] - ptsarray[0],
			  ptsarray[3] - ptsarray[1]);
		free(grbuf);			/* free graphics buffer */
		break;
	case 1	:				/* IMG (Gem bit) image	*/
		Fseek(8L,fid,0);		/* skip 8 bytes header	*/
		Fread(fid,2L,&pw);		/* read pixel micron W	*/
		Fread(fid,2L,&ph);		/* read pixel micron H	*/
		Fread(fid,2L,&w);		/* read width  of page	*/
		Fread(fid,2L,&h);		/* read height of page	*/
		disp_img(fbuffer,ptsarray[0],ptsarray[1],
			 ptsarray[2],ptsarray[3]);
		break;
	case 2	:				/* Gem Metafile image	*/
		meta_make(fid,ptsarray[0],ptsarray[1],
			  ptsarray[2] - ptsarray[0],
			  ptsarray[3] - ptsarray[1]);
		break;

	case 3  :				/* PI1 Degas Low Rez	*/
		grbuf = (long)get_lcmem(32000L);
		if(!grbuf)
		{
		   alert_cntre(ALERT32);
		   Fclose(fid);
		   return;
		}
		Fseek(2L,fid,0);		/* skip first 2 bytes	*/
		Fread(fid,32L,cobuf);		/* read color buffer	*/
		Fseek(34L,fid,0);		/* skip 34 bytes header */
		Fread(fid,32000L,grbuf);	/* read file bit block	*/
		disp_neo(grbuf,cobuf,ptsarray[0],ptsarray[1],
			  ptsarray[2] - ptsarray[0],
			  ptsarray[3] - ptsarray[1]);
		free(grbuf);			/* free graphics buffer */
		break;
   }
   Fclose(fid);				/* close graphics file	*/

}
