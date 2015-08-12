/**************************************************************************/
/*  FILE:  DRAW.C		PROGRAM TITLE: DeskSET II Alpha Version   */
/*  Date Created: 01/11/88						  */ 
/*  Last Modified: 11/16/88						  */
/*									  */
/*  Description: POLYGON DRAW ROUTINES					  */
/*  Routines:	o   nada()		- Null Function			  */
/*              o   poly_draw()		- Draw and Store Polygon	  */
/*		o   ellipse_draw()	- Draw and Store Ellipse	  */
/*		o   circle_draw()	- Draw and Store Circle		  */
/*		o   box_draw()		- Draw and Store Box		  */
/*		o   redraw_ellipse()    - Redraw Ellipses and Circles     */
/*		o   redraw_polygon()    - Redraw Polygon		  */
/*		o   do_scanner()	- perform rectangle scanning      */
/*		o   do_outline()	- box around selected regions     */
/*		o   do_box()		- draw a filled box... 		  */
/*		o   write_black()	- set device to write black	  */
/*		o   write_white()	- set device to write white	  */
/*		o   write_atari()	- set device to write atari logo  */
/*		o   handle_atari()	- write white/atari for images    */
/*		o   handle_write()	- write white/black/pattern	  */
/**************************************************************************/

/**************************************************************************/
/* HISTORY								  */
/*									  */
/* 11/07/89  - Replace all calls to scale_v() with scaler()		  */
/*	     - circle_draw() - replace scale_v() with scaler()		  */
/**************************************************************************/

/**************************************************************************/
/* INCLUDE FILES							  */
/**************************************************************************/
#include "deskset2.h"
#include <obdefs.h>
#include "gemdefs.h"
#include "define.h"
#include "dbase.h"

/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/
#define max(x,y) (((x) > (y)) ? (x) : (y))
#define min(x,y) (((x) < (y)) ? (x) : (y))


/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern int phys_handle;				/* Handles, just in case  */
extern int shandle;				/* screen handle          */
extern int phandle;				/* printer handle         */
extern int mhandle;				/* preview buffer handle  */
extern int xor_handle;				/* second screen handle   */
extern int print_flag;				/* printing flag...       */

extern int ptsarray[];				/* data struct interface  */
extern int curr_page;				/* current page...        */

extern int prev_handle;				/* preview window handle  */

extern int pagew,pageh;				/* current width and ht.. */
						/* in pixels              */
extern mode_flag;				/* solid/text mode        */
extern write_flag;				/* write white/black flag */

extern unsigned long page_ptr;			/* preview buffer pointer */
extern unsigned long pagesc;			/* ditto...		  */

extern unsigned long scanptr;			/* scan buffer pointer    */
extern unsigned long scanesc;			/* ditto...		  */

extern int scan_xres;				/* scan buffer x res...   */
extern int scan_yres;				/* scan buffer y res...   */

extern int mxres,myres;				/* preview buffer x,y res */
extern int rect_in_mu[];			/* rectangle in MU...	  */

extern int ptsin[];				/* PTSIN[] array          */

extern char *tmpptr;				/* CS 2/6/88		  */
extern char *endptr;				
extern char *dotext();
extern struct slvll	*getslvptr();		/* Return regions slave ptr */
extern int view_size;				/* current view size      */
extern int axdpi[];				/* xdpi and ydpi arrays   */
extern int aydpi[];
extern int zdevice;

extern int pxyarray[];				/* Some global arrays     */
extern int pxy[];				/* ditto		  */
extern int status;				/* used by GDv_updwk()    */
extern int dummy;				/* dummy variable filler  */
extern int dumb;

extern int cur_scale;				/* current scale...       */
extern int cur_primitive;			/* current graphic        */
						/* primitive - RCS numbers*/
extern char fbuffer[];				/* file name buffer       */
extern int cur_pic_type;			/* NEO, IMG, GEM	  */
extern int graph_flag;				/* graphic region? 1-TRUE */
extern unsigned long gl_grregion_ptr;		/* Ptr to graphic region  */
extern struct txtattr gltxtattr;		/* Global text attr struct*/
extern int glgrattr[];				/* Global graphic attr    */
extern struct textobj gltext;

extern FDB laser_MFDB;
extern FDB page_MFDB;

extern char cpabt;
extern int opcode;
extern int maxpat;

extern REGION *curregion;
extern long getf_scaninfo();
extern long getn_scaninfo();

extern int hpage_size;
extern int vpage_size;
extern PNUMBER pnum;

extern unsigned char *buf_start;
extern unsigned char *buf_end;
extern unsigned char *free_start;
extern unsigned char *current_char;
extern int tmplate_flag;

extern int active_prim;

/**************************************************************************/
/* GLOBAL VARIABLES							  */
/**************************************************************************/
int (*funcs)();					/* current drawing funct. */
int SX,SY;					/* start scan here...     */
int flag;					/* variable flag...       */
int SH;						/* Line spacing for mask  */

typedef struct sfdb				/* Scan buffer structure  */
     {
        long BASE;				/* Base address of form   */
        int FORM_WD;				/* form width in bytes.   */
        int FORM_HT;				/* form height (pixels)   */
        int B_XMIN;				/* upper left x		  */
        int B_YMIN;				/* upper left y 	  */
        int B_XMAX;				/* lower left x           */
        int B_YMAX;				/* lower left y           */
     }  SFDB;					/* name of structure      */

SFDB jim_ptr;					/* pointer to structure   */

typedef	struct	mfdb
	{
	long	data;
	int	width;
	int	height;
	int	wwidth;
	int	format;
	int	planes;
	int	res1;
	int	res2;
	int	res3;
	}MFDB;

MFDB txtmfdb;					/* TEXT mfdb CS 2/6/88    */
int mboxx2[254];
int mboxy2[254];
int mboxx1[254];
int mboxy1[254];


/**************************************************************************/
/* Function:	nada()							  */
/* Description: Null drawing function used as the default.		  */
/**************************************************************************/
nada(){}



/**************************************************************************/
/* Function:	poly_draw()						  */
/* Description: Draws polygons						  */
/* IN:  tmp_handle - handle of screen device - xor_handle or shandle	  */
/*      num        - number of points.					  */
/* OUT: none								  */
/* GLOBALS:  xor_handle - screen handle in xor mode			  */
/*	     shandle    - screen handle in replace mode			  */
/*	     mhandle    - Preview Buffer handle				  */
/*	     pxyarray[] - Vertice coordinates arrive this way...	  */
/*           graph_flag - graphic image? - 0 = no, 1 = yes		  */
/*	     write_flag - write white or write black mode		  */
/*			  0 = write white, 1 = write black		  */
/*	     pxy[]      - Vertice coordinates arrive this way		  */
/*	     ptsarray[] - Data stored in data structure passed in array   */
/**************************************************************************/
poly_draw(tmp_handle,num)
int tmp_handle;
int num;
{
     register int i,cnt;
     int tflag;
     int perimeter;

     if(!num)
	 return;
     if(tmp_handle == xor_handle)
	 v_pline(xor_handle,num,pxyarray);
     else
     {
         if(graph_flag)
	 {
	    if(cur_primitive == OLINE)
			handle_line(write_flag,mhandle);
	    else
	    		handle_atari(write_flag,mhandle);
	 }
         else
	   handle_write(write_flag,mhandle);

         tflag = (((curr_page%2)&&(view_size == PADJCNT))?(TRUE):(FALSE));
         cnt = 0;
	 for(i=0;i<num;i++)
         {
         scrn2mu(pxy[cnt],pxy[cnt+1],&ptsarray[cnt],&ptsarray[cnt+1],0,tflag);
	 mutopage(ptsarray[cnt],ptsarray[cnt+1],
			&pxyarray[cnt],&pxyarray[cnt+1],0);
	    cnt+=2;
         }
         mclip();
         if(cur_primitive == OLINE)
	 {
	   v_pline(mhandle,num,pxyarray);
	   put_poly(3,num,write_flag);
         }
	 else
         {
           v_fillarea(mhandle,num,pxyarray);
           perimeter = glgrattr[2] & 0x8000;
	   if(perimeter && graph_flag)
           {
	        handle_line(write_flag,mhandle);
    	        v_pline(mhandle,num,pxyarray);
           }
           put_poly(0,num,write_flag);
	 }
     }
}




/**************************************************************************/
/* Function:	ellipse_draw()						  */
/* Description: 2 stage ellipse draw.					  */
/*		1) arcs are drawn until position is planted.		  */
/*		2) ellipse drawn to screen and preview buffer             */
/*		3) ellipse data saved to data structure			  */
/*		   Data saved in GLOBAL  PTSARRAY[]			  */
/* IN:  tmp_handle - screen handle  REPLACE or XOR mode			  */
/* GLOBAL: write_flag - writing mode: 0 = write white, 1 = write black    */
/*	   ptsarray[] - data for data structures			  */
/*         pxyarray[] - used for data manipulation			  */
/*	   pxy[]      - data arrives in this way			  */
/*	   graph_flag - graphic image? 0 = no, 1 = yes			  */
/*	   xor_handle - screen xor mode handle				  */
/*	   shandle    - screen replace mode handle			  */
/*	   mhandle    - preview buffer handle				  */
/**************************************************************************/
ellipse_draw(tmp_handle)
int tmp_handle;
{
    int tflag;
    int perimeter;

    perimeter = glgrattr[2] & 0x8000;
    pxyarray[2] = abs(pxy[0] - pxy[2]);
    pxyarray[3] = abs(pxy[1] - pxy[3]);
    
    if(tmp_handle == xor_handle)
            v_ellarc(tmp_handle,pxy[0],pxy[1],
		     pxyarray[2],pxyarray[3],0,3600);
    else
    {
         if(graph_flag)
	    handle_atari(write_flag,mhandle);
         else
	    handle_write(write_flag,mhandle);

         tflag = (((curr_page%2)&&(view_size == PADJCNT))?(TRUE):(FALSE));
         scrn2mu(pxy[0],pxy[1],&ptsarray[0],&ptsarray[1],0,tflag);
	 mutopage(ptsarray[0],ptsarray[1],&pxy[0],&pxy[1],0);	    
         scrn2mu(pxyarray[2],pxyarray[3],&ptsarray[2],&ptsarray[3],1,tflag);
	 mutopage(ptsarray[2],ptsarray[3],&pxy[2],&pxy[3],1);

         mclip();
         v_ellipse(mhandle,pxy[0],pxy[1],pxy[2],pxy[3]);
	 if(perimeter && graph_flag)
	 {
            handle_line(write_flag,mhandle);
	    v_ellarc(mhandle,pxy[0],pxy[1],pxy[2],pxy[3],0,3600);
	 }
	 put_ellipse(write_flag);
    }
}



/**************************************************************************/
/* Function:	circle_draw()						  */
/* Description: Draws a circle.						  */
/*		1) draws elliptical arcs until planted.			  */
/*		2) draws into preview buffer and onto the screen	  */
/*		3) Data saved to data structure in GLOBAL PTSARRAY[]      */
/* IN:	  tmp_handle   - screen handle   XOR or REPLACE			  */
/* GLOBAL: write_flag  - write mode - 0 = write white, 1 = write black..  */
/*	   ptsarray[]  - data saved to data structure this way...	  */
/*	   pxy[]       - data arrives this way...			  */
/*	   graph_flag  - graphic images? 0 = no, 1 = yes...		  */
/*	   xor_handle  - screen xor mode handle				  */
/*	   shandle     - screen replace mode handle			  */
/*	   mhandle     - preview buffer handle				  */
/**************************************************************************/
circle_draw(tmp_handle)
{
    int radius;
    int tflag;
    int perimeter;
    int xradius,yradius,temp;

    perimeter = glgrattr[2] & 0x8000;    
    xradius = abs(pxy[0] - pxy[2]);
    yradius = abs(pxy[1] - pxy[3]);
    radius = max(xradius,yradius);
  
    if(axdpi[zdevice] == aydpi[zdevice])
              xradius = yradius = radius;
    else
    {
      if(axdpi[zdevice] > aydpi[zdevice])
      {
          temp = scaler(yradius,axdpi[zdevice],aydpi[zdevice]);
          if(xradius >= temp)
	  {
               yradius = scaler(xradius,aydpi[zdevice],axdpi[zdevice]);
	       radius = xradius;		
          }
          else
          {
	       xradius = temp;
	       radius = yradius;
          }
      } 
      else
      {
        temp = scaler(yradius,axdpi[zdevice],aydpi[zdevice]);
        if(xradius >= temp)
        {
             yradius = scaler(xradius,aydpi[zdevice],axdpi[zdevice]);
	     radius = xradius;
        }
        else
        {
	  xradius = temp;
          radius = yradius;
        }
      }
    }
 
    if(tmp_handle == xor_handle)
            v_ellarc(tmp_handle,pxy[0],pxy[1],xradius,yradius,0,3600);
    else
    {
       if(graph_flag)
	    handle_atari(write_flag,mhandle);
       else
	    handle_write(write_flag,mhandle);

       tflag = (((curr_page%2)&&(view_size == PADJCNT))?(TRUE):(FALSE));
       scrn2mu(pxy[0],pxy[1],&ptsarray[0],&ptsarray[1],0,tflag);
       mutopage(ptsarray[0],ptsarray[1],&pxy[0],&pxy[1],0);	    

       if(axdpi[zdevice] != aydpi[zdevice])
       {
          scrn2mu(xradius,yradius,&ptsarray[2],&ptsarray[3],1,tflag);
          if(xradius >= yradius)
          {
		ptsarray[3] = scaler(ptsarray[2],1152,1296);
          }
          else
          {
		ptsarray[2] = scaler(ptsarray[3],1296,1152);       
          }
       }
       else
       {
          scrn2mu(radius,radius,&ptsarray[2],&ptsarray[3],1,tflag);
       }
       mutopage(ptsarray[2],ptsarray[3],&xradius,&yradius,1);

       mclip();
       v_ellipse(mhandle,pxy[0],pxy[1],xradius,yradius);
       if(perimeter && graph_flag)
       {
          handle_line(write_flag,mhandle);
          v_ellarc(mhandle,pxy[0],pxy[1],xradius,yradius,0,3600);
       }
       put_ellipse(write_flag);
    }
}



/**************************************************************************/
/* Function:	box_draw()						  */
/* Description: Draws a box.. but saved as a polygon...		  	  */
/* 		1) drawn as v_plines until planted.			  */
/*		2) box drawn to screen and preview buffer.		  */
/*		3) polygon saved to data structure.			  */
/*		   Data saved in GLOBAL PTSARRAY[]			  */
/* IN:    tmp_handle - screen handle in REPLACE or XOR mode		  */
/* OUT:   none								  */
/* GLOBAL:  write_flag - write mode: 0 - write white, 1 - write black.	  */
/*	    pxyarray[] - Internal data manipulation			  */
/*	    pxy[]      - Data arrives in this array			  */
/*	    ptsarray[] - Data passed to data structures through this...   */
/*          cur_primitive - current drawing primitive in RCS units	  */
/*	    xor_handle - screen xor mode handle				  */
/*	    shandle    - screen replace handle				  */
/*	    mhandle    - preview buffer handle				  */
/*	    								  */
/**************************************************************************/
box_draw(tmp_handle)
int tmp_handle;
{
    register int i;
    int tflag;
    int perimeter;
    int temp;

    perimeter = glgrattr[2] & 0x8000;    



    if(tmp_handle == xor_handle)
    {
       pxyarray[0] = pxyarray[6] = pxyarray[8] = pxy[0];
       pxyarray[1] = pxyarray[3] = pxyarray[9] = pxy[1];
       pxyarray[2] = pxyarray[4] = pxy[2];
       pxyarray[5] = pxyarray[7] = pxy[3];

       v_pline(tmp_handle,5,pxyarray);
    }
    else
    {
       if(pxy[2] < pxy[0])	/* swap if inverted... */
       {
	 temp = pxy[2];
	 pxy[2] = pxy[0];
	 pxy[0] = temp;
       }

       if(pxy[3] < pxy[1])
       {
         temp = pxy[3];
         pxy[3] = pxy[1];
         pxy[1] = temp;
       }
       pxyarray[0] = pxyarray[6] = pxyarray[8] = pxy[0];
       pxyarray[1] = pxyarray[3] = pxyarray[9] = pxy[1];
       pxyarray[2] = pxyarray[4] = pxy[2];
       pxyarray[5] = pxyarray[7] = pxy[3];

       if(cur_primitive == OIMAGE)
	     write_atari(mhandle);
       else
       {
	   if(graph_flag)
	     handle_atari(write_flag,mhandle);
           else
	     handle_write(write_flag,mhandle);
       }

         tflag = (((curr_page%2)&&(view_size == PADJCNT))?(TRUE):(FALSE));
       for(i=0;i<10;i+=2)
       {
         scrn2mu(pxyarray[i],pxyarray[i+1],&ptsarray[i],&ptsarray[i+1],0,tflag);
         mutopage(ptsarray[i],ptsarray[i+1],&pxy[i],&pxy[i+1],0);    
       }
       mclip();
       if(cur_primitive == ORBOX)
       {
		pxyarray[0] = pxy[0];
		pxyarray[1] = pxy[1];
		pxyarray[2] = pxy[4];
		pxyarray[3] = pxy[5];
		v_rfbox(mhandle,pxyarray);
		if(perimeter && graph_flag)
		{
		   handle_line(write_flag,mhandle);
		   v_rbox(mhandle,pxyarray);
		}
		put_poly(4,5,write_flag);
		return;
       }
       else	
       {
         v_fillarea(mhandle,5,pxy);
	 if(perimeter && graph_flag)
         {
            if(cur_primitive == OIMAGE)
	    {
	       vsl_type(mhandle,1);
	       vsl_width(mhandle,1);
	    }
	    else
	       handle_line(write_flag,mhandle);
	    if(pxy[0] == pxy[8] &&
	       pxy[1] == pxy[9])
	       {
	          pxy[10]     = pxy[2];
	          pxy[11]     = pxy[3];
	          v_pline(mhandle,6,pxy);
	       }
	       else
	          v_pline(mhandle,5,pxy);
	 }
       }
       if(cur_primitive == OIMAGE)
       {
	    remove_path(fbuffer);
            put_image(fbuffer,cur_pic_type);
       }
       else
            put_poly(0,5,write_flag);
    }

}



/**************************************************************************/
/* Function:    redraw_ellipse()					  */
/* Description: Redraws ellipse and circle				  */
/*		Depending upon the mode, draws either in black, or draws  */
/*		in black with a filled text outline.			  */
/* IN: wflag   - writing mode   -  1 = write black 0 = write white	  */
/* OUT: none								  */
/* GLOBAL:   mode_flag  - solid or text fill 				  */
/*	     PTSARRAY[] - contains coordinate data.			  */
/**************************************************************************/
redraw_ellipse(wflag,g_flag)
int wflag;
int g_flag;
{
   int thandle;
   int perimeter;

   perimeter = glgrattr[2] & 0x8000;
   if(!mode_flag)
   {
       if(g_flag)
               handle_atari(wflag,mhandle);
       else
	       handle_write(wflag,mhandle);

       mutopage(ptsarray[0],ptsarray[1],&pxy[0],&pxy[1],0);
       mutopage(ptsarray[2],ptsarray[3],&pxy[2],&pxy[3],1);
       v_ellipse(mhandle,pxy[0],pxy[1],pxy[2],pxy[3]);
       if(perimeter && g_flag)
       {
            handle_line(wflag,mhandle);
	    v_ellarc(mhandle,pxy[0],pxy[1],pxy[2],pxy[3],0,3600);
       }
   }
   else
   {
     if(g_flag)
     {
       if(print_flag)
       {
	   thandle = phandle;
           mutolas(ptsarray[0],ptsarray[1],&pxy[0],&pxy[1]);
           mutolas(ptsarray[2],ptsarray[3],&pxy[2],&pxy[3]);
       }
       else
       {
	   thandle = mhandle;
           mutopage(ptsarray[0],ptsarray[1],&pxy[0],&pxy[1],0);
           mutopage(ptsarray[2],ptsarray[3],&pxy[2],&pxy[3],1);
       }
       handle_atari(wflag,thandle);
       v_ellipse(thandle,pxy[0],pxy[1],pxy[2],pxy[3]);
       if(perimeter)
       {
            handle_line(wflag,thandle);
	    v_ellarc(thandle,pxy[0],pxy[1],pxy[2],pxy[3],0,3600);
       }
     }
     else
     {
       handle_write(wflag,mhandle);
       mutomem(ptsarray[0],ptsarray[1],&pxy[0],&pxy[1]);
       mutomem(ptsarray[2],ptsarray[3],&pxy[2],&pxy[3]);
       v_ellipse(mhandle,pxy[0],pxy[1],pxy[2],pxy[3]);
     }
   }
}




/**************************************************************************/
/* Function:	redraw_polygon()					  */
/* Description: 							  */
/**************************************************************************/
redraw_polygon(count,wflag,g_flag)
int count;
int wflag;
int g_flag;
{
   int thandle;
   register int i;
   register int cnt;
   int perimeter;
   int index;

   perimeter = glgrattr[2] & 0x8000;

   if(!count)
	return;
   if(!mode_flag)
   {

       for(i=0;i<(count*2); i += 2)
	  mutopage(ptsarray[i],ptsarray[i+1],&pxy[i],&pxy[i+1],0);

       if(opcode == 3)
       {
		handle_line(wflag,mhandle);
		v_pline(mhandle,count,pxy);
       }
       else
       {
       		if(g_flag)
                     handle_atari(wflag,mhandle);
                else
	             handle_write(wflag,mhandle);
     

		if(opcode == 4)
		{
		   pxyarray[0] = pxy[0];
		   pxyarray[1] = pxy[1];
		   pxyarray[2] = pxy[4];
		   pxyarray[3] = pxy[5];
		   v_rfbox(mhandle,pxyarray);
		   if(perimeter && g_flag)
		   {
		        handle_line(write_flag,mhandle);
			v_rbox(mhandle,pxyarray);
		   }
		}
		else
	        {
       		   v_fillarea(mhandle,count,pxy);
	           if(perimeter && g_flag)
                   {
                      if(cur_primitive == OIMAGE)
	              {
	                 vsl_type(mhandle,1);
	                 vsl_width(mhandle,1);
	              }
	              else
	                 handle_line(write_flag,mhandle);
		      index = count * 2;
		      if(pxy[0] == pxy[index - 2] &&
		         pxy[1] == pxy[index - 1])
		      {
		         pxy[index]     = pxy[2];
		         pxy[index + 1] = pxy[3];
		         v_pline(mhandle,count+1,pxy);
		      }
		      else
		         v_pline(mhandle,count,pxy);
                   }
		}
       }
   }
   else
   {
     if(g_flag)
     {
	cnt = 0;
        if(print_flag)
        {
	  thandle = phandle;
	  for(i=0;i<count;i++)
          {
	   mutolas(ptsarray[cnt],ptsarray[cnt+1],&pxy[cnt],&pxy[cnt+1]);
	   cnt+= 2;
          }

        }
        else
        {
	  thandle = mhandle;
	  for(i=0;i<count;i++)
          {
	   mutopage(ptsarray[cnt],ptsarray[cnt+1],&pxy[cnt],&pxy[cnt+1],0);
	   cnt+= 2;
          }

        }

	
	if(opcode == 3)
	{
	     handle_line(wflag,thandle);
	     v_pline(thandle,count,pxy);
	}
	else
	{
             handle_atari(wflag,thandle);
	     if(opcode == 4)
	     {
		   pxyarray[0] = pxy[0];
		   pxyarray[1] = pxy[1];
		   pxyarray[2] = pxy[4];
		   pxyarray[3] = pxy[5];
		   v_rfbox(thandle,pxyarray);
	           if(perimeter)
                   {
		      handle_line(write_flag,thandle);
		      v_rbox(thandle,pxyarray);
                   }
	     }
	     else
	     {
	        v_fillarea(thandle,count,pxy);
	        if(perimeter)
                {
		      index = count * 2;
	              handle_line(write_flag,thandle);
		      if(pxy[0] == pxy[index - 2] &&
		         pxy[1] == pxy[index - 1])
		      {
		         pxy[index]     = pxy[2];
		         pxy[index + 1] = pxy[3];
		         v_pline(thandle,count+1,pxy);
		      }
		      else
		         v_pline(thandle,count,pxy);
                }
	     }
	}
     }
     else
     {
        handle_write(wflag,mhandle);
        cnt = 0;
	for(i=0;i<count;i++)
        {
	   mutomem(ptsarray[cnt],ptsarray[cnt+1],&pxy[cnt],&pxy[cnt+1]);
	   cnt+= 2;
        }
	v_fillarea(mhandle,count,pxy);
     }
   }
}



/**************************************************************************/
/* Function:	do_handjreg()						  */
/* Description: Scans the graphic mask in the scan buffer and returns 	  */
/*		rectangle coordinates.					  */
/* IN:      								  */
/*	    txtptr - ptr to text					  */
/*	    dflag  - done flag						  */ 
/* OUT: none								  */
/* GLOBAL:  regx1,regx2,regy1,regy2 - rectangular area of region	  */
/*	    jim_ptr  - data structure MFDB 				  */
/*          scanner() - performs actual scanning of mask.		  */
/*	    sx1,sx2,sy1,sy2 - rectangle to draw.			  */
/**************************************************************************/
extern struct txtattr cp;	   		   /* using GOG structure */

char *do_handjreg(txtptr,dflag,mode,rect_in_mu)
char *txtptr;
int  *dflag;
int  mode;
int  rect_in_mu[];
{
    int  tmp_handle;
    int ptsin1[25];
    int x1,y1,x2,y2;
    int  sx1,sx2,sy1,sy2;
    int  save_sx1;
    FDB  *fdb_ptr;
    int tmppage;
    int muy;
    long line_space;
    int scanoff;
    int dummy;

    *dflag = 0;
    line_space = gltxtattr.lnsp;
    tmppage = curr_page;
    if(view_size == PADJCNT)
    {
	curr_page = curregion->p;
    }
	
    f_move(&gltxtattr,&cp,sizeof(cp));			/* GOG  */
    cp.depth = cp.lnsp;
    tmp_handle = shandle;

    if(mode == 3)
        resetIFpos();

    mutomem(rect_in_mu[0],rect_in_mu[1],&sx1,&sy1);
    mutomem(rect_in_mu[2],rect_in_mu[3],&sx2,&sy2);

    muy = rect_in_mu[1];
    muy = max(muy,0);
    if(cp.scoff)
    {
       if(muy + cp.scoff < rect_in_mu[3] )
       {
          muy += cp.scoff;	  		/* offset into scanner */
	  mutomem(muy,muy,&scanoff,&sy1);
       }
    }

    jim_ptr.BASE    = scanptr;
    jim_ptr.FORM_WD = ((scan_xres + 15)/16)*2;
    jim_ptr.FORM_HT = scan_yres;
    sx1 = max(sx1,0);
    save_sx1 = sx1;
    sy1 = max(sy1,0);
    sx2 = min(sx2,scan_xres);
    sy2 = min(sy2,scan_yres);
    jim_ptr.B_XMIN  = sx1;
    jim_ptr.B_YMIN  = sy1;
    jim_ptr.B_XMAX  = sx2;
    jim_ptr.B_YMAX  = sy2;

    gltext.State = 0;
    gltext.slvlist = 0L;

    ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
    ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
    ptsin1[8] = ((print_flag) ? (100):(cur_scale));
    ptsin1[9] = tmp_handle;

    fdb_ptr = ((print_flag) ?(&laser_MFDB):(&page_MFDB));                 

    SX = sx1;
    SY = sy1;
    cpabt = 0;
    tmpptr = endptr = txtptr;
    while(scanner(&jim_ptr,SX,SY,SH,&sx1,&sy1,&sx2))
    {
       if(sy1 != SY)
       {
	  if(sy1 == SY + SH)			/* Drop down a line */
	     muy += line_space - 1;
	  else
	     memtomu(dummy,sy1,&dummy,&muy);
       }
       if(sx2 == SX - 1 && sy1 == SY)
       {
	  muy += line_space - 1;
	  SY += SH;		/* Rectangle hasn't moved */
	  SX = save_sx1;	/* Set to beginning of next line */
       }
       else
       {
          SX     = sx2 + 1;
          SY     = sy1;
       }
       sy2    = sy1 + SH;

       if(muy + line_space - 1 > rect_in_mu[3])
	   	break;

       memtomu(sx1,sy1,&x1,&y1);
       memtomu(sx2,sy2,&x2,&y2);
       
       ptsin1[0] = x1;
       ptsin1[3] = x2;

       cp.llen = x2 - x1 + 1;
/*
       cp.depth = (long)(y2 - y1 + 1);
       cp.lnsp = cp.depth; 
*/
       ptsin1[1] = ptsin1[4] = 0;
       ptsin1[2] =  y1 = muy;
       ptsin1[5] = y2 = muy + line_space - 1;
       

       gltext.begtext   = tmpptr;
       gltext.slvlist = 0L;       

       endptr = dotext(&gltext,ptsin1,fdb_ptr,mode,dflag);
       switch(cpabt)
       {
	  case 0:
          	add_scaninfo(curregion,x1,y1,x2,y2,tmpptr,gltext.slvlist);
		break;
	  case 4:
		*dflag = 0;
		endptr = tmpptr;
	  	freeslvlist(gltext.slvlist);
		break;
	  case 8:
          	add_scaninfo(curregion,x1,y1,x2,y2,tmpptr,gltext.slvlist);
		*dflag = 0;
		curr_page = tmppage;
		return(endptr);
		break;
	  case 1:
	  case 2:
	  case 3:
	  case 5:
	  case 6:
	  case 7:
	      do_txterr(cpabt);
	      *dflag = 1;
	      break;
       }

       if(*dflag)				/* Done */
	     break;
       tmpptr = endptr;       
    }
    curr_page = tmppage;    
    return(endptr);
}



/**************************************************************************/
/*	do_regoutput							  */
/**************************************************************************/
do_regoutput(txtptr,dflag)
char *txtptr;
int  *dflag;
{
    int x1,y1,x2,y2;
    long tptr;
    long slvptr;

    if(getf_scaninfo(curregion,&x1,&y1,&x2,&y2,&tptr,&slvptr))
    {
      if(slvptr)
	  do_output(dflag);
      else
	  do_slvout(txtptr,dflag);
    }
    else
	  do_slvout(txtptr,dflag);
}	



/**************************************************************************/
/* Function:	do_slvout()						  */
/**************************************************************************/
do_slvout(txtptr,dflag)
char *txtptr;
int  *dflag;
{
    int  tmp_handle;
    int ptsin1[25];
    int x1,y1,x2,y2;
    FDB  *fdb_ptr;
    long *yptr;
    long scanlist;
    long tptr;
    long slvptr;

    f_move(&gltxtattr,&cp,sizeof(cp));			/* GOG  */
    tmp_handle = shandle;

    resetIFpos();
    gltext.State = 1;
    
    ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
    ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
    ptsin1[8] = ((print_flag) ? (100):(cur_scale));
    ptsin1[9] = tmp_handle;
    ptsin1[10] = 0;

    fdb_ptr = ((print_flag) ?(&laser_MFDB):(&page_MFDB));                 

    cpabt = 0;
    tmpptr = txtptr;
    scanlist = getf_scaninfo(curregion,&x1,&y1,&x2,&y2,&tptr,&slvptr);
    while(scanlist)
    {
       ptsin1[0] = x1;
       ptsin1[3] = x2;

       cp.llen = x2 - x1 + 1;
       cp.depth = (long)(y2 - y1 + 1);
       cp.lnsp = cp.depth;

       yptr = (unsigned long *)(ptsin1 + 1);
       *yptr = (long)y1;
       yptr = (unsigned long *)(ptsin1 + 4);
       *yptr = (long)y2; 

       gltext.begtext   = tmpptr;
       gltext.slvlist = 0L;   
       endptr = dotext(&gltext,ptsin1,fdb_ptr,6,dflag);

       if(endptr == (char *)-1L)
       {
	   if(cpabt == 4)		/* Line measure too short */
	   {
		*dflag = 0;
		endptr = tmpptr;
	   }
	   else
	   {
	      do_txterr(cpabt);
	      break;
   	   }
       }
       put_scaninfo(scanlist,gltext.slvlist);       
       if(*dflag)			/* Done or Output only mode */
	     break;
       tmpptr = endptr;
       scanlist = getn_scaninfo(&x1,&y1,&x2,&y2,&tptr,&slvptr);
    }
    
    if(print_flag) 
	write_black(mhandle);
}


/**************************************************************************/
/* Function:	do_slvout()						  */
/**************************************************************************/
do_slave_only(txtptr,dflag)
char *txtptr;
int  *dflag;
{
    int  tmp_handle;
    int ptsin1[25];
    int x1,y1,x2,y2;
    FDB  *fdb_ptr;
    long *yptr;
    long scanlist;
    long tptr;
    long slvptr;

    f_move(&gltxtattr,&cp,sizeof(cp));			/* GOG  */
    tmp_handle = shandle;

    resetIFpos();
    gltext.State = 1;
    
    ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
    ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
    ptsin1[8] = ((print_flag) ? (100):(cur_scale));
    ptsin1[9] = tmp_handle;
    ptsin1[10] = 0;

    fdb_ptr = ((print_flag) ?(&laser_MFDB):(&page_MFDB));                 

    cpabt = 0;
    tmpptr = txtptr;
    scanlist = getf_scaninfo(curregion,&x1,&y1,&x2,&y2,&tptr,&slvptr);
    while(scanlist)
    {
       ptsin1[0] = x1;
       ptsin1[3] = x2;

       cp.llen = x2 - x1 + 1;
       cp.depth = (long)(y2 - y1 + 1);
       cp.lnsp = cp.depth;

       yptr = (unsigned long *)(ptsin1 + 1);
       *yptr = (long)y1;
       yptr = (unsigned long *)(ptsin1 + 4);
       *yptr = (long)y2; 

       gltext.begtext   = tmpptr;
       gltext.slvlist = 0L;   
       endptr = dotext(&gltext,ptsin1,fdb_ptr,2,dflag);

       if(endptr == (char *)-1L)
       {
	   if(cpabt == 4)		/* Line measure too short */
	   {
		*dflag = 0;
		endptr = tmpptr;
	   }
	   else
	   {
	      do_txterr(cpabt);
	      break;
   	   }
       }
       put_scaninfo(scanlist,gltext.slvlist);       
       if(*dflag)			/* Done or Output only mode */
	     break;
       tmpptr = endptr;
       scanlist = getn_scaninfo(&x1,&y1,&x2,&y2,&tptr,&slvptr);
    }
}

/**************************************************************************/
/* Function:	do_tdoout()						  */
/**************************************************************************/
do_tdoout(txtptr,dflag)
char *txtptr;
int  *dflag;
{
    int  tmp_handle;
    int ptsin1[25];
    int x1,y1,x2,y2;
    FDB  *fdb_ptr;
    long scanlist;
    long tptr;
    long slvptr;

    f_move(&gltxtattr,&cp,sizeof(cp));			/* GOG  */
    tmp_handle = shandle;

    topPge_TYF();
    gltext.State = 1;
    
    ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
    ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
    ptsin1[8] = ((print_flag) ? (100):(cur_scale));
    ptsin1[9] = tmp_handle;
    ptsin1[10] = 0;

    fdb_ptr = ((print_flag) ?(&laser_MFDB):(&page_MFDB));                 

    cpabt = 0;
    tmpptr = txtptr;
    scanlist = getf_scaninfo(curregion,&x1,&y1,&x2,&y2,&tptr,&slvptr);
    while(scanlist)
    {
       ptsin1[0] = x1;
       ptsin1[3] = x2;

       cp.llen = x2 - x1 + 1;
       cp.depth = (long)(y2 - y1 + 1);
       cp.lnsp = cp.depth;

       ptsin1[2] = y1;
       ptsin1[5] = y2;
       ptsin1[1] = ptsin1[4] = 0;

       gltext.begtext   = tmpptr;
       gltext.slvlist = 0L;   
       endptr = dotext(&gltext,ptsin1,fdb_ptr,2,dflag);

       if(endptr == (char *)-1L)
       {
	   if(cpabt == 4)		/* Line measure too short */
	   {
		*dflag = 0;
		endptr = tmpptr;
	  	freeslvlist(gltext.slvlist);
	   }
	   else
	   {
	      do_txterr(cpabt);
	      break;
   	   }
       }
       writeslv(gltext.slvlist);       
       if(*dflag)			/* Done or Output only mode */
	     break;
       tmpptr = endptr;
       scanlist = getn_scaninfo(&x1,&y1,&x2,&y2,&tptr,&slvptr);
    }
}




/**************************************************************************/
/* Function:	do_output()						  */
/**************************************************************************/
do_output(dflag)
int  *dflag;
{
    int  tmp_handle;
    int ptsin1[25];
    int x1,y1,x2,y2;
    FDB  *fdb_ptr;
    long scanlist;
    long tptr;

    tmp_handle = shandle;
    
    resetIFpos();
    gltext.State = 3;

    ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
    ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
    ptsin1[8] = ((print_flag) ? (100):(cur_scale));
    ptsin1[9] = tmp_handle;
    ptsin1[10] = 0;		/* No clipping */
    fdb_ptr = ((print_flag) ?(&laser_MFDB):(&page_MFDB));                 

    cpabt = 0;

    scanlist = getf_scaninfo(curregion,&x1,&y1,&x2,&y2,&tptr,&gltext.slvlist);
    while(scanlist)
    {
       if(gltext.slvlist)
       {
          endptr = dotext(&gltext,ptsin1,fdb_ptr,4,dflag);

          if(endptr == (char *)-1L)
          {
	      if(cpabt == 4)		/* Line measure too short */
	      {
		 *dflag = 0;
	      }
	      else
	      {
	         do_txterr(cpabt);
	         break;
   	      }
	  }
       }
       scanlist = getn_scaninfo(&x1,&y1,&x2,&y2,&tptr,&gltext.slvlist);
    }
    
    if(print_flag) 
	write_black(mhandle);
}




/**************************************************************************/
/* Function:	do_clipregout()						  */
/**************************************************************************/
do_clipregout(clx1,cly1,clx2,cly2)
int clx1,cly1,clx2,cly2;
{
    int  tmp_handle;
    int ptsin1[25];
    int x1,y1,x2,y2;
    FDB  *fdb_ptr;
    long scanlist;
    long tptr;
    int dflag;
    int rx1,ry1,rx2,ry2;
    int pos_not_set;
    int rx[4];
    int sx[4];
    int oldy, offset_y;
    oldy = 0;
    tmp_handle = shandle;
    
    resetIFpos();
    gltext.State = 3;

    ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
    ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
    ptsin1[8] = ((print_flag) ? (100):(cur_scale));
    ptsin1[9] = tmp_handle;
    ptsin1[10] = 1;		/*  clipping */
    ptsin1[11] = sx[0] = clx1;
    ptsin1[12] = sx[1] = cly1;
    ptsin1[13] = sx[2] = clx2 + 1;	/* 1 pixel off on clipping */
    ptsin1[14] = sx[3] = cly2 + 1;

    fdb_ptr = ((print_flag) ?(&laser_MFDB):(&page_MFDB));                 

    cpabt = 0;


    scanlist = getf_scaninfo(curregion,&x1,&y1,&x2,&y2,&tptr,&gltext.slvlist);
    mutopage(x1,y1,&rx[0],&rx[1],0);
    mutopage(x2,y2,&rx[2],&rx[3],0);
    if(rect_intersect(rx,sx))
    {
	resetIFpos();
	pos_not_set = 0;
    }
    else
	pos_not_set = 1;
    while(scanlist)
    {
       if(gltext.slvlist)
       { 
          if(oldy != y1)		/* Need to add line space to all */
	  {				/* scanrects that don't have     */
	     	oldy = offset_y = y1;	/* positioning info in them      */
	 				/* i.e. a scan directly to the   */
	  }				/* right and parallel with another */
	  else				/* scan				   */
	  {
                offset_y = y1 + curregion->text.lnsp - 1;
		pos_not_set = 1;
	  }
          mutopage(x1,y1,&rx[0],&rx[1],0);
          mutopage(x2,y2,&rx[2],&rx[3],0);
          if(rect_intersect(rx,sx))	    /* if the scan overlaps the clip*/
          {
	     if(pos_not_set)
	     {
		setYpos(offset_y);
		pos_not_set = 0;
	     }
             endptr = dotext(&gltext,ptsin1,fdb_ptr,4,&dflag);
             if(endptr == (char *)-1L)
             {
    	        if(cpabt == 4)		/* Line measure too short */
	        {
		  dflag = 0;
	        }
	        else
	        {
	           do_txterr(cpabt);
	           break;
   	        }
             }
	  }
       }
       scanlist = getn_scaninfo(&x1,&y1,&x2,&y2,&tptr,&gltext.slvlist);
    }
    
    if(print_flag) 
	write_black(mhandle);
}



/**************************************************************************/
/* Function:	do_outer()						  */
/* Description:								  */
/**************************************************************************/
do_outer(handle,pxy)
int handle;
register int pxy[];
{
   int txy[10];

   txy[0] = pxy[0] - 5;txy[1] = pxy[1] - 5;
   txy[2] = pxy[2] + 5;txy[3] = pxy[3] + 5;
   do_box(handle,txy[0],txy[1],txy[2],txy[3]);
}



do_outline(handle,pxy)
int handle;
register int pxy[];
{
   int midx,midy;
   int txy[10];
   register int i;
     
      txy[0] = pxy[0] - 5;txy[1] = pxy[1] - 5;
      txy[2] = pxy[2] + 5;txy[3] = pxy[3] + 5;
      do_box(handle,txy[0],txy[1],txy[2],txy[3]);

      if(active_prim)
      {
	midx = (txy[0] + txy[2])/2;
	midy = (txy[1] + txy[3])/2;


	mboxx1[1] = mboxx1[5] = midx;
	mboxy1[0] = mboxy1[1] = mboxy1[2] = txy[1];

	mboxx1[2] = mboxx1[3] = mboxx1[4] = txy[2];
	mboxy1[3] = mboxy1[7] = midy;

	mboxy1[4] = mboxy1[5] = mboxy1[6] = txy[3];

	mboxx1[0] = mboxx1[6] = mboxx1[7] = txy[0];


	for(i=0;i<=8;i++)
		do_diamond(handle,mboxx1[i],mboxy1[i]);
      }

       mboxx1[0] = mboxx1[6] = mboxx1[7] = txy[0] - 3;
       mboxx2[0] = mboxx2[6] = mboxx2[7] = txy[0] + 3;
       mboxx1[2] = mboxx1[3] = mboxx1[4] = txy[2] - 3;
       mboxx2[2] = mboxx2[3] = mboxx2[4] = txy[2] + 3;
       mboxy1[0] = mboxy1[1] = mboxy1[2] = txy[1] - 3;
       mboxy2[0] = mboxy2[1] = mboxy2[2] = txy[1] + 3;
       mboxy1[4] = mboxy1[5] = mboxy1[6] = txy[3] - 3;
       mboxy2[4] = mboxy2[5] = mboxy2[6] = txy[3] + 3;
       midx = (txy[0] + txy[2])/2;
       midy = (txy[1] + txy[3])/2;
       mboxx1[1] = mboxx1[5] = midx - 3;
       mboxx2[1] = mboxx2[5] = midx + 3;

       mboxy1[3] = mboxy1[7] = midy - 3;
       mboxy2[3] = mboxy2[7] = midy + 3;
      
      if(!active_prim)
      {
        for(i=0;i<8;i++)
           do_box(handle,mboxx1[i],mboxy1[i],mboxx2[i],mboxy2[i]);
      }
      
}



do_diamond(handle,x1,y1)
int handle;
int x1,y1;
{
    pxyarray[0] = pxyarray[8] = x1-5;
    pxyarray[1] = pxyarray[9] = pxyarray[5] = y1;

    pxyarray[2] = pxyarray[6] = x1;
    pxyarray[3] = y1 - 5;

    pxyarray[4] = x1 + 5;
    pxyarray[7] = y1 + 5;
    v_pline(handle,5,pxyarray);
}




/**************************************************************************/
/* Function:	do_box()						  */
/* Description: Called by do_scan to draw the rectangle bar into the	  */
/*		workstation buffer designated by handle...		  */
/**************************************************************************/
do_box(handle,x1,y1,x2,y2)
int handle;
int x1,y1,x2,y2;
{
    pxyarray[0] = pxyarray[6] = pxyarray[8] = x1;
    pxyarray[1] = pxyarray[3] = pxyarray[9] = y1;
    pxyarray[2] = pxyarray[4] = x2;
    pxyarray[5] = pxyarray[7] = y2;
    v_pline(handle,5,pxyarray);
}



/**************************************************************************/
/* Function:	write_black()						  */
/* Description: switches fill style for writing to solid black.		  */
/**************************************************************************/
write_black(handle)
int handle;
{
   vsf_interior(handle,1);
   vsf_perimeter(handle,FALSE);
}



/**************************************************************************/
/* Function:	write_white()						  */
/* Description: Changes device fill style to write in white.		  */
/**************************************************************************/
write_white(handle)
int handle;
{
   vsf_interior(handle,0);
   vsf_perimeter(handle,FALSE);
}



/**************************************************************************/
/* Function:	write_atari()						  */
/* Description:								  */
/**************************************************************************/
write_atari(handle)
int handle;
{
int curindex;
int curstyle;

     if((cur_primitive == OIMAGE) || (opcode == 2))
     {
        vsf_interior(handle,4);
     }
     else
     {
	curstyle = glgrattr[2] & 0x7fff;
	curindex = glgrattr[3];
	if(curstyle == 2)
	{
           if(curindex >= maxpat)
	      curstyle = 0;				/* Hollow	*/
	}
        vsf_interior(handle,curstyle);
        vsf_style(handle,curindex);
     }
     vsf_perimeter(handle,0);		/* handle perimeter ourselves   */
}



/**************************************************************************/
/* Function:	handle_atari()						  */
/* Description:								  */
/**************************************************************************/
handle_atari(wflag,handle)
int wflag;
int handle;
{
     if(wflag)
           write_atari(handle);
     else 
	   write_white(handle);
}



/**************************************************************************/
/* Function:	handle_write()						  */
/* Description:								  */
/**************************************************************************/
handle_write(wflag,handle)
int wflag;
int handle;
{
       if(wflag)
	   write_black(handle);
       else
	   write_white(handle);
}



handle_line(wflag,handle)
int wflag;
int handle;
{
        int tmpwidth;
	int dummy;
        int mu_width;

	if(wflag)
	    vsl_color(handle,TRUE);
	else
	    vsl_color(handle,FALSE);
	if(glgrattr[1])			/* If line width in points... */
 	   vsl_type(handle,1);		/* Set style to solid		*/
	else				/* Else single line so use pattern */
	   vsl_type(handle,glgrattr[0]);
        if(!glgrattr[1])			/* line width of 1 */
	   tmpwidth = 1;
        else
	{
	   mu_width = pttomu(glgrattr[1]);
	   if(handle == phandle)
	      mutolas(dummy,mu_width,&dummy,&tmpwidth);
	   else
	      mutopage(dummy,mu_width,&dummy,&tmpwidth,1);
        }
	vsl_width(handle,tmpwidth);
}



/***********************************************************************/
/* Function: do_numbers()					       */
/* Description: Print actual page numbers...			       */
/***********************************************************************/
do_numbers(rgrect,tdo_flag)
int rgrect[];
int tdo_flag;
{
   long *yptr;
   FDB *fdbptr;
   int dflag;
   register int i,j;
   int size;
   int ptype;
   int y1,y2;
   int vbase;
   int ptsin1[25];
   char str[4];
   char text[PTEXTMAX];
   int just;
   int tgrect[4];
   int tpxy[4];


   if(pnum.display && pnum.text[0] && !tmplate_flag)
   {			/* display on and text exists and not template mode */

     ptype = ((curr_page%2)?(1):(0));

     if((pnum.usage == 0) && ptype)
			return;
     if((pnum.usage == 1) && !ptype)
			return;

     if((curr_page < pnum.fpage) || (curr_page > pnum.tpage))
					return;

     just = ((ptype)?(pnum.rjust):(pnum.ljust));
     switch(just)
     {
	  case 0: pnum.tattrib.jstmd = 1;	/* quad left  */
		  break;
	  case 1: pnum.tattrib.jstmd = 3;	/* quad center*/
		  break;
	  case 2: pnum.tattrib.jstmd = 2;	/* quad right */
		  break;
     };
     f_move(&pnum.tattrib,&cp,sizeof(cp));

     if(tdo_flag)
	topPge_TYF();
     else
        resetIFpos();

     for(i=0;i<=4;i++)
	   str[i] = 0x0;
     for(i=0;i<=PTEXTMAX;i++)
			text[i] = 0x0;

     itoa(curr_page,str);
     i=0;
     j=0;
     while((pnum.text[i]) && (i<=PTEXTMAX))
     {
	if(pnum.text[i] != '#')
		text[j++] = pnum.text[i];
        else
        {
	   if(pnum.text[i+1] == '#')
	   {
		text[j++] = pnum.text[i];
		i++;
	   }
	   j += strlen(str);
	   if(j<=PTEXTMAX)
	   	strcat(text,str);
	   else
	     i=PTEXTMAX;
        }
	i++;
     }

     buf_start =  &text[0];
     buf_end   =  &text[PTEXTMAX];

     size = strlen(&text[0]);
     free_start = size + buf_start;
     current_char = buf_end;


     vbase = ((pnum.vpos)?(vpage_size):(0));	/* top or bottom? */
     y1 = ((vbase)?(vbase - pnum.distance):(pnum.distance));
     y2 = y1 + pttomu((pnum.pptsize / 8) + 5);

     if((print_flag) || (view_size != PADJCNT))
     {
        ptsin1[0] = 0;
        ptsin1[3] = hpage_size;
     }
     else
     {
	ptsin1[0] = ((curr_page % 2)?(hpage_size):(0));
	ptsin1[3] = ((curr_page % 2)?(2*hpage_size):(hpage_size));
     }

     if(rgrect)
     {
        mutopage(ptsin1[0],y1,&tpxy[0],&tpxy[1],0);
        mutopage(ptsin1[3],y2,&tpxy[2],&tpxy[3],0);

	tgrect[0] = tpxy[0];
        tgrect[1] = tpxy[1];
        tgrect[2] = tpxy[2] - tpxy[0] + 1;
        tgrect[3] = tpxy[3] - tpxy[1] + 1;
     }

     if(!rgrect || rc_intersect(rgrect,tgrect))
     {
       yptr = (unsigned long *)(ptsin1 + 1);
       *yptr = (long)y1;
       yptr = (unsigned long *)(ptsin1 + 4);
       *yptr = (long)y2;


       ptsin1[6] = ((print_flag) ? (axdpi[LASER]):(axdpi[PREVIEW]));
       ptsin1[7] = ((print_flag) ? (aydpi[LASER]):(aydpi[PREVIEW]));
       ptsin1[8] = ((print_flag) ? (100):(cur_scale));
       ptsin1[9] = shandle;
       ptsin1[10] = 0;					/* no clip flag */

       fdbptr = ((print_flag) ? (&laser_MFDB) : (&page_MFDB));     

 
       gltext.State = 1;
       gltext.slvlist = 0L;
       gltext.begtext = buf_start;

       cp.llen = ptsin1[3] - ptsin1[0] + 1;
       cp.depth = (long)(y2 - y1 + 1);
       cp.lnsp = cp.depth;
       if(tdo_flag)
       {
	 endptr = dotext(&gltext,ptsin1,fdbptr,2,&dflag);
	 writeslv(gltext.slvlist);
       }
       else
         endptr = dotext(&gltext,ptsin1,fdbptr,6,&dflag);
     }
   }	/* pnum.display == FALSE */

}
