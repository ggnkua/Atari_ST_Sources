/**************************************************************************/
/*  FILE:  CONVERT.C		PROGRAM TITLE: DeskSET II Alpha Version   */
/*  Date Created: 01/07/88						  */ 
/*  Last Modified: 02/10/89						  */
/*									  */
/*  Description: CONVERSION ROUTINES					  */
/*  Routines:								  */
/*   	o  hmutopix()  		- Horizontal Machine Units to Pixels.     */
/*	o  vmutopix()  		- Vertical Machine Units to Pixels.       */
/*	o  hpixtomu()  		- Horizontal Pixels to Machine Units.     */
/*	o  vpixtomu()  		- Vertical Pixels to Machine Units.	  */
/*	o  scrntomu()  		- Screen Pixels to Machine Units.	  */
/*	o  mutoscrn()  		- Machine Units to Screen Pixels.	  */
/*	o  mutomem()   		- Machine Units to Scanner Pixels	  */
/*	o  memtomu()   		- Scanner to Machine Units		  */
/*	o  scale()     		- Scale up/down MU to scrn/scrn to Mu     */
/*	o  scale_xy()		- Scale up/down MU to scrn/scrn to Mu	  */
/*	o  itoa()      		- Integer to ASCII conversion		  */
/*	o  reverse()   		- Reverse text string - Used by itoa()    */
/*	o  scale_me() 		- scale up/down - used by scale()	  */
/*	o  mutopage()  		- convert MU to Preview Page units        */
/*	o  scale_iv()  		- scaler for arrows,sliders etc. 	  */
/*				  (ok, its really a muldiv...)		  */
/*      o  scale_v()		- another muldiv			  */
/*	o  mutolas()   		- Machine Units to Laser Coordinates      */
/*	o  pttomu()    		- Point Size to Machine Units conversion  */
/*	o  get_scale_num()	- Get current scale size (quick and dirty)*/
/*				- based upon a muldiv for size to fit	  */
/*	o  scale_request()	- Get a scale number from table		  */
/*	o  scrn2mu()		- Scrn to Mu conversion - PADJCNT specific*/
/*	o do_trans_scale()	- Translation and scaling for typed coords*/
/*	o case12_scale()	- scale for opcodes 1 and 2 for typed "   */
/*	o scale_prim_coord()						  */
/*	o mutopt()							  */
/**************************************************************************/

/**************************************************************************/
/* HISTORY								  */
/*									  */
/* 11/07/89  - comment out scale_me() C function			  */
/*	     - convert all calls to scale_me() to _scaleme()		  */
/*	       which can be found in fast.s				  */
/*	     - scale()    - replace scale_me() with scaleme()		  */
/*	       scale_xy() - replace scale_me() with scaleme()		  */
/*	       scale_me() - commented out				  */
/*									  */
/* 11/07/89  - comment out scale_v()					  */
/*	     - convert all calls to scale_v() with scaler()		  */
/*	       which can be found in fast.s				  */
/*	     - scale_v()  - commented out				  */
/*									  */
/* 11/07/89  - comment out scale_iv()					  */
/*	     - convert all calls to scale_iv() with scaler()		  */
/*	       scrntomu()   - replace scale_iv() with scaler()		  */
/*	       mutoscrn()   - replace scale_iv() with scaler()		  */
/*	       mutopage()   - replace scale_iv() with scaler()		  */
/*	       get_scaled() - replace scale_iv() with scaler()		  */
/*	       scrn2mu()    - replace scale_iv() with scaler()            */
/*	       do_trans_scale() - " 	"		"		  */
/*	       case12_scale - replace scale_iv() with scaler()		  */
/*	       scale_prim_coord()   "       "      "     "  		  */
/*	       scale() - changed scaler variable to scd			  */
/*			 so as not to even remotely interfere		  */
/*									  */
/* 11/07/89  - comment out hmutopix(). Replaced with hmupix() in fast.s   */
/*	     - Replace hmutopix() calls with hmupix()			  */
/*	       mutoscrn()   -   replace hmutopix() with hmupix()	  */
/*	       mutomem()    -   replace hmutopix() with hmupix()          */
/*	       mutopage()   -   replace hmutopix() with hmupix()          */
/*	       mutolas()    -   replace hmutopix() with hmupix()          */
/*	       get_scale_num()    "        "         "     "              */
/*									  */
/* 11/07/89  - comment out vmutopix(). Replaced with vmupix() in Fast.s   */
/*	     - Replace vmutopix() calls with vmupix()			  */
/*	       mutoscrn()   -   replace vmutopix() with vmupix()	  */
/*	       mutomem()    -   replace vmutopix() with vmupix()          */
/*	       mutopage()   -   replace vmutopix() with vmupix()          */
/*	       mutolas()    -   replace vmutopix() with vmupix()          */
/*	       get_scale_num()    "        "         "     "              */
/*									  */
/* 11/07/89  - comment out hpixtomu(). Replaced with hpixmu() in fast.s   */
/*	       Replace hpixtomu() calls with hpixmu();			  */
/*	       scrntomu() - Replace hpixtomu() with hpixmu()		  */
/*	       memtomu()  - Replace hpixtomu() with hpixmu()		  */
/*	       scrn2mu()  - Replace hpixtomu() with hpixmu()		  */
/* 									  */
/* 11/07/89  - comment out vpixtomu(). Replaced with vpixmu() in fast.s   */
/*	       Replace vpixtomu() calls with vpixmu()			  */
/*	       scrntomu() - Replace vpixtomu() with vpixmu()		  */
/*	       memtomu()  - Replace vpixtomu() with vpixmu()		  */
/*	       scrn2mu()  - Replace vpixtomu() with vpixmu()		  */
/**************************************************************************/


/**************************************************************************/
/* INCLUDE FILES							  */
/**************************************************************************/
#include "define.h"
#include "deskset2.h"
#include <obdefs.h>
#include "gemdefs.h"

/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/


/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern int sxres;				   /* screen x resolution */
extern int syres;				   /* screen y resolution */

extern GRECT dpwork;				   /* window work area    */
extern GRECT pwork;				   /* Preview window work */

extern int pagew,pageh;				   /* Current page width  */
						   /* and height - pixels */
extern int dummy;				   /* well, dummy         */
extern GRECT page_area;				   /* blit area in preview*/
						   /* area...		  */
						   /* in MU units...	  */
extern int pxyarray[];				   /* temp variable       */
extern int pxy[];				   /* storage...	  */
extern int ptsarray[];				   /* interface array     */
						   /* for conversions     */
extern int alt_offset;
extern int print_flag;
extern int unit_type;
extern double modf();
extern int snap_to_grids;
extern int deltax,deltay;
extern unsigned long region_ptr;
extern unsigned long gl_region_ptr;
extern int count,wmode;
extern long get_regart();
extern int deferhj;

/**************************************************************************/
/* GLOBAL VARIABLES							  */
/**************************************************************************/
int hpage_size;			/* Current Horizontal Page Size (MU)	  */
int vpage_size;			/* Current Vertical Page Size (MU)        */

int view_size;			/* Current Page Scale Size		  */
int curr_page;			/* Current Region Page			  */

int tmpx,tmpy;			/* Several temp variables that are used   */
int dumb;

int zdevice;			/* index for which device..		  */
				/* Screen = 0, SCANNER = 1, Preview = 2   */
                                /* Laser = 3...				  */
int axdpi[4]     = {80,80,80,300};
int aydpi[4]     = {80,80,80,300};
int half_xdpi[4] = {40,40,40,150};/* Screen, Scanner, Preview Laser 1/2xdpi*/
int half_ydpi[4] = {40,40,40,150};/* Screen, Scanner, Preview Laser 1/2ydpi*/


/**************************************************************************/
/* Function:	hmutopix()						  */
/* Description: Horizontal Machine Units to Horizontal Pixel Conversion   */
/* INPUT : munits  - Machine Units (Horizontal)			  	  */
/* OUTPUT: returns the number of horizontal pixels			  */
/* 	   Calculation is based upon: o horizontal dpi			  */
/*				      o 18 mu per point			  */
/*				      o 72 pt per inch			  */
/* GLOBALS:   axdpi[] - array containing dpi of destination device	  */
/*	      zdevice- index into xdpi array				  */
/* Commented out 11/07/89 CJG - replaced with hmupix() in fast.s	  */
/**************************************************************************/
/*
int hmutopix(munits)
int munits;
{
     long tmp;

     tmp = (long)axdpi[zdevice] * (long)munits;
     munits = ((tmp % 1296L) > 648L);
     tmp /= 1296L;
     return((int)tmp + munits);
}
*/


/**************************************************************************/
/* Function:	vmutopix()						  */
/* Description: Vertical Machine Units to Vertical Pixel Conversion	  */
/* INPUT : munits - Machine Units (Vertical)				  */
/* OUTPUT: returns the number of vertical pixels			  */
/* 	   Calculation is based upon: o vertical dpi			  */
/*				      o 16 mu per point			  */
/*				      o 72 pt per inch			  */
/* GLOBALS:   aydpi[] - array containing dpi of destination device	  */
/*	      zdevice- index into ydpi array				  */
/* Commented out 11/07/89 CJG. Replaced with vmupix() in fast.s		  */
/**************************************************************************/
/*
vmutopix(munits)
int munits;
{
    long tmp;

    tmp = (long)aydpi[zdevice] * (long)munits;
    munits = ((tmp % 1152L) > 576L);
    tmp /= 1152L;
    return((int)tmp + munits);
}
*/




/**************************************************************************/
/* Function: 	hpixtomu()						  */
/* Description: Pixel to Horizontal Machine Unit Conversion		  */
/* INPUT : pixels - Horizontal Pixel units				  */
/* OUTPUT: returns the number of Horizontal Machine Units		  */
/* 	   Calculation is based upon: o horizontal dpi			  */
/*				      o 18 mu per point			  */
/*				      o 72 pt per inch			  */
/* GLOBALS:   axdpi[] - array containing dpi of destination device	  */
/*	      half_xdpi - array containin 1/2dpi of destination device    */
/*			  (used for defining rounding up/down... )	  */
/*	      zdevice- index into xdpi array				  */
/* Commented out 11/07/89 CJG. Replaced with hpixmu() in fast.s		  */
/**************************************************************************/
/*
hpixtomu(pixels)
int pixels;
{
   long tmp;
 
   tmp = (long)pixels * 1296L;
   pixels = ((tmp % (long)axdpi[zdevice]) > (long)half_xdpi[zdevice]);
   tmp /= (long)axdpi[zdevice];
   return((int)tmp + pixels);
}
*/



/**************************************************************************/
/* Function:	vpixtomu()						  */
/* Description: Vertical Pixel to Vertical Machine Unit Conversion	  */
/* INPUT : pixels - Vertical Pixel units				  */
/* OUTPUT: returns the number of Vertical Machine Units			  */
/* 	   Calculation is based upon: o horizontal dpi			  */
/*				      o 16 mu per point			  */
/*				      o 72 pt per inch			  */
/* GLOBALS:   aydpi[] - array containing dpi of destination device	  */
/*	      half_ydpi[] - array containing 1/2 dp of destination device */
/*			    (used for rounding up/down...)		  */
/*	      zdevice- index into ydpi array				  */
/* Commented out 11/07/89 CJG. Replaced with vpixtomu() in fast.s	  */
/**************************************************************************/
/*
vpixtomu(pixels)
int pixels;
{
     long tmp;

     tmp = (long)pixels * 1152L;
     pixels = ((tmp % (long)aydpi[zdevice]) > (long)half_ydpi[zdevice]);
     tmp /= (long)aydpi[zdevice];
     return((int)tmp + pixels);
}
*/
   


/**************************************************************************/
/* Function:	scrntomu()						  */
/* Description: Converts Screen Coordinates to Machine Unit Coordinates   */
/* INPUT:  ox,oy -  Screen Coordinates (Pixels)				  */
/*         nx,ny -  Pointers returning Machine Unit Positions		  */
/*	   flag  -  Flag  0 - Adjust for window offsets			  */
/*		          1 - Do Not Adjust for window offsets		  */
/*			  Vertices need to be adjusted, lengths do not.   */
/* OUTPUT: nx,ny contain new coordinate positions in machine units	  */
/* GLOBALS:  zdevice - defines index for destination device used to get   */
/*		       the devices dots per inch resolution		  */
/*	     pwork   - GRECT structure of preview window work area.       */
/*	     pagew   - width of page in pixels on the screen		  */
/*	     pageh   - height of page in pixels on the screen		  */
/*	     hpage_size - horizontal page size in machine units		  */
/*	     vpage_size - vertical page size in machine units		  */
/*	     page_area  - GRECT defining blit rectangle in Preview buffer */
/*			- page_area.g_x and page_area.g_y defines the     */
/*			  current offset of the scrolled preview window   */
/*	     view_size  - current view mode - PACTUAL etc...		  */
/**************************************************************************/
scrntomu(ox,oy,nx,ny,flag)
int ox,oy;					/* Old x,y vertice	  */
int *nx,*ny;					/* New adjusted vertice   */
int flag;					/* scale direction flag   */
{
         int tmpx;
         int tmpy;
	 int hwidth;
	 

         tmpx    = ox;				/* save for later...      */
         tmpy    = oy;
	 zdevice = SCREEN;			/* Device destination     */

         if(!flag)
         {
	     tmpx -= dpwork.g_x;		/* adjust for work offset */
	     tmpy -= dpwork.g_y;		/* of the window...       */
         }


         if((view_size == PSIZE) ||		/* Want Size to Fit       */
            (view_size == PADJCNT))
         {
	    hwidth = ((view_size == PADJCNT) ? (hpage_size * 2) : (hpage_size));
	    *nx = scaler(tmpx,hwidth,pagew);  
	    *ny = scaler(tmpy,vpage_size,pageh);

	    if(!flag && (view_size == PADJCNT) && (*nx > hpage_size))
	    {
		alt_offset = TRUE;
		*nx -= hpage_size;
	    }
	    else
		alt_offset = FALSE;
				    	    
         }
         else					/* otherwise all others   */
         {
	    alt_offset = FALSE;
            scale_xy(&tmpx,&tmpy,1);
            *nx = hpixmu(tmpx);
	    *ny = vpixmu(tmpy);

            if(!flag)				/* adjust for the scrolled*/
	    {					/* offset off of the      */
                *nx += page_area.g_x;		/* window		  */
                *ny += page_area.g_y;		/* be adjusted...         */
            }            			
         }

}




/**************************************************************************/
/* Function:	mutoscrn()						  */
/* Description: Machine Units to Screen Coordinate Conversion		  */
/* INPUT:    	ox,oy - Oldx Machine Unit Positions			  */
/*		nx,ny - New Screen Coordinates				  */
/*		flag  - 0 - Add workx and worky for offsets.		  */
/*			1 - Don't Add workx and worky offsets.		  */
/*			Vertices need to be adjusted, lengths do not.     */
/* OUTPUT: nx,ny contain new coordinate positions in pixel units	  */
/* GLOBALS:  zdevice - defines index for destination device used to get   */
/*		       the devices dots per inch resolution		  */
/*	     pwork   - GRECT structure of preview window work area.       */
/*	     pagew   - width of page in pixels on the screen		  */
/*	     pageh   - height of page in pixels on the screen		  */
/*	     hpage_size - horizontal page size in machine units		  */
/*	     vpage_size - vertical page size in machine units		  */
/*	     page_area  - GRECT defining blit rectangle in Preview buffer */
/*			- page_area.g_x and page_area.g_y defines the     */
/*			  current offset of the scrolled preview window   */
/*	     view_size  - current view mode - RCS numbers PACTUAL etc...  */
/**************************************************************************/
mutoscrn(ox,oy,nx,ny,flag)
int ox,oy;
int *nx,*ny;
int flag;
{
       int txoffset,tyoffset;
       int hwidth;

       tmpx    = ox;
       tmpy    = oy;
       zdevice = SCREEN;
            
       if((view_size == PSIZE) ||		/* Size to Fit...        */
	  (view_size == PADJCNT))
       {
		hwidth = ((view_size == PADJCNT)?(hpage_size * 2):(hpage_size));
		*nx = scaler(pagew,tmpx,hwidth);
		*ny = scaler(pageh,tmpy,vpage_size);
       }
       else					/* All others...         */
       {

           *nx = hmupix(tmpx);			/* scale the data...     */
	   *ny = vmupix(tmpy);
           scale_xy(nx,ny,0);

           if(!flag)				/* and adjust for offset */
           {					/* of scrolling.  Note   */
	      txoffset = page_area.g_x;
	      tyoffset = page_area.g_y;
	      
              txoffset = hmupix(txoffset);
              tyoffset = vmupix(tyoffset);
              scale_xy(&txoffset,&tyoffset,0);
              *nx -= txoffset;
              *ny -= tyoffset;              
           }					/* only...		 */
       }

       if(!flag)				/* adjust for the offset */
       {					/* of the work window    */
	   *nx += dpwork.g_x;			/* Again, only vertices  */
           *ny += dpwork.g_y;			/* need apply...         */
       }

}




/**************************************************************************/
/* Function:    mutomem()						  */
/* Description:	Converts Machine Units to Scanner Coordinates	  	  */
/* IN  : ox,oy  -  MU position to convert to the scan buffer.		  */
/* OUT : nx,ny  -  pixel positions in the scan buffer.			  */
/* NOTE: scan buffer is configured always for actual size... 		  */
/*	 with LEGAL size paper						  */
/* GLOBALS:   zdevice - defines index for destination device used to get  */
/*			the dots per inch resolution			  */
/**************************************************************************/
mutomem(ox,oy,nx,ny)
int ox,oy;
int *nx,*ny;
{
    zdevice = SCANNER;
    *nx = hmupix(ox);
    *ny = vmupix(oy);
}




/**************************************************************************/
/* Function:	memtomu()						  */
/* Description:	Converts Scanner Coordinates to Machine Units  	  	  */
/*									  */
/* IN : ox,oy   - scan buffer pixel positions to convert to MU		  */
/* OUT: nx,ny   - Converted machine units coordinates			  */
/* Note: Scan buffer is configured always for actual size...		  */
/*	 with LEGAL size paper						  */
/* GLOBALS:  zdevice - defines index for destination device used to get   */
/*		       the dots per inch resolution			  */
/**************************************************************************/
memtomu(ox,oy,nx,ny)
int ox,oy;
int *nx,*ny;
{
     zdevice = SCANNER;
     *nx = hpixmu(ox);
     *ny = vpixmu(oy);
     if((curr_page % 2) && (view_size == PADJCNT) && !print_flag)
			*nx += hpage_size;
}




/**************************************************************************/
/*  Function:	 scale()						  */
/*  Description: Scale routine to convert a data pair from:		  */
/*		 o A percentage to absolute 100% size ( % to MU)	  */
/*		 o Absolute 100% to any percentage size (MU to %)	  */
/*  IN:    tx,ty       - vertice					  */
/*         txoff,tyoff - x and y offset of scrolling.			  */
/*	   flag        - direction of scaling - up or down.		  */
/*			 0 - mu to percentage   1 - percentage to mu      */
/*  OUT:   tx,ty       - adjusted vertice				  */
/*         txoff,tyoff - adjusted x and y offset (compensates scrolling	  */
/* I believe that this routine is called by only one function.  The others*/
/* use scale_xy() for a better usage of the stack.			  */
/**************************************************************************/
scale(tx,ty,txoff,tyoff,flag)
int *tx,*ty;
int *txoff,*tyoff;
int flag;					/* 0 - mu to percentage   */
{						/* 1 - percentage to MU   */
      int scd;

      scd    = scale_request(view_size);	/* get a scale factor      */
      *tx    = scaleme(*tx,scd,flag);		/* scale them...	   */
      *ty    = scaleme(*ty,scd,flag);	
      *txoff = scaleme(*txoff,scd,flag);	
      *tyoff = scaleme(*tyoff,scd,flag);
}





/**************************************************************************/
/* Function: scale_xy()							  */
/* Description:	same as scale, but used for those who only need to handle */
/*		vertices and nothing else.				  */
/* IN:  tx,ty - pointers to the vertice					  */
/*	flag  - direction of conversion					  */
/*		o  0 = 100% to any percentage (MU to %)			  */
/*		o  1 = percentage to 100%     (% to MU)			  */
/* OUT: tx,ty are pointers to new numbers.				  */
/**************************************************************************/
scale_xy(tx,ty,flag)
int *tx,*ty;
int flag;					/* 0 - mu to percentage   */
{						/* 1 - percentage to MU   */
      int scd;

      scd    = scale_request(view_size);	/* get scale factor	   */
      *tx    = scaleme(*tx,scd,flag);		/* and scale them...       */
      *ty    = scaleme(*ty,scd,flag);	
}




/**************************************************************************/
/*  Function:     itoa()						  */
/*  Description:  Integer to ASCII conversion				  */
/**************************************************************************/
itoa(n,s)
int n;
register char s[];
{
    register int i;
    int sign;
    if((sign = n) < 0)
	   n = -n;
    i = 0;
    do
    {
	s[i++] = n % 10 + '0';
    }while(( n /= 10) > 0);

    if(sign < 0)
       s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}




/**************************************************************************/
/*  Function:    reverse()						  */
/*  Description: reverses a text string. Used by itoa()			  */
/**************************************************************************/
reverse(s)
register char s[];
{
     int c;
     register int i,j;

     for(i=0,j=strlen(s) - 1; i<j; i++,j--)
     {
          c    = s[i];
          s[i] = s[j];
	  s[j] = c;
     }
}




/**************************************************************************/
/*  Function:    scale_me()						  */
/*  Description: Performs actual scaling of data.			  */
/*		 called by scale()					  */
/*  IN:      num    - number to scale					  */
/*	     scaler - scale factor					  */
/*	     flag   - scale from    0 - mu to percentage		  */
/*		      		    1 - percentage to mu		  */
/*  OUT:     returns in D0 the newly scaled number			  */
/*  Commented out 11/07/89 CJG - See fast.s for scaleme()		  */
/**************************************************************************/
/*
scale_me(num,scaler,flag)
int  num;
int  scaler;
int  flag;
{
      long  tmp;
      int  extra;
      long  half;      

      if(!flag)			*scale from full size to percentage  *
      {
           tmp = (long)num * (long)scaler;
           extra = ((tmp % 100L) > 50L);
	   tmp /= 100L;
	   return((int)tmp + extra);
      }
      else			* scale from percentage to full size *
      {
           half = (long)scaler / 2L;
	   tmp = (long)num * 100L;
	   extra = ((tmp % (long)scaler) > half);
           tmp /= (long)scaler;
           return((int)tmp + extra);
      }     

}
*/



/**************************************************************************/
/*  Function:    mutopage()						  */
/*  Description: Scale from MU to Preview Page Memory Driver		  */
/*  IN:      ox,oy  - MU units to convert to pixels			  */
/*  OUT:     nx,ny  - Returns Pixel units in Preview Page mode		  */
/*  GLOBALS: zdevice - defines index for destination device used to get   */
/*		       the devices dots per inch resolution		  */
/*	     pagew   - width of page in pixels on the screen		  */
/*	     pageh   - height of page in pixels on the screen		  */
/*	     hpage_size - horizontal page size in machine units		  */
/*	     vpage_size - vertical page size in machine units		  */
/*	     view_size  - current view mode - RCS numbers PACTUAL etc...  */
/**************************************************************************/
mutopage(ox,oy,nx,ny,flag)
int ox,oy;
int *nx,*ny;
int flag;
{
       int hwidth;

       tmpx = ox;
       tmpy = oy;

       zdevice = PREVIEW;

       if((view_size == PSIZE) ||		/* Handle Size to Fit	 */
	  (view_size == PADJCNT))
       {
		hwidth = ((view_size == PADJCNT)?(hpage_size*2):(hpage_size));
		*nx = scaler(pagew,tmpx,hwidth);
		*ny = scaler(pageh,tmpy,vpage_size);
		if(!flag && (curr_page % 2) && (view_size == PADJCNT))
			*nx += pagew/2;
       }
       else					/* And all others...       */
       {					/* Scale down appropriately*/
           *nx = hmupix(tmpx);
	   *ny = vmupix(tmpy);
           scale_xy(nx,ny,0);
       }
}




/**************************************************************************/
/*  Function:    scale_iv()						  */
/*  Description: A muldiv based on input paramters of INT, LONG, LONG     */
/*  IN:      visible  - amount of document visible			  */
/*	     factor   - new percentage to modify by...			  */
/*	     total    - total size of document				  */
/*  OUT:     Returns in D0 an adjusted size factor			  */
/*  Comment out scale_iv() All calls replaced with scaler()		  */
/*  which can be found in fast.s	CJG 11/07/89			  */
/**************************************************************************/
/*
scaler(visible,factor,total)
int visible;
int factor;
int total;
{
      long tmp;
      int munits;
      int half;

      half = total / 2;

      tmp = (long)visible * (long)factor + (long)half;
*      munits = ((tmp % (long)total) > half);*
      tmp /= (long)total;
*      return((int)tmp + munits);*
      return((int)tmp);
}
*/




/**************************************************************************/
/* Function:     scale_v()						  */
/* Description:  Another MULDIV based on INT, INT, INT			  */
/*  IN:      visible  - amount of document visible			  */
/*	     factor   - new percentage to modify by...			  */
/*	     total    - total size of document				  */
/*  OUT:     Returns in D0 an adjusted size factor			  */
/*  Commented out 11/07/89 CJG. replaced with scaler() in fast.s	  */
/**************************************************************************/
/*
scale_v(visible,factor,total)
int visible;
int factor;
int total;
{
      long tmp;
      int  munits;
      long half;

      half = ((long)total / 2L);

      tmp = (long)visible * (long)factor;
      munits = ((tmp % (long)total) > half);
      tmp /= (long)total;
      return((int)tmp + munits);
}
*/



/**************************************************************************/
/* Function:    mutolas()						  */
/* Description:	Converts Machine Units to Laser Driver Coordinates  	  */
/* IN: ox,oy  - MU position to convert to the laser buffer.		  */
/* OUT: nx,ny - pixel positions in the laser buffer.			  */
/* NOTE: Laser buffer is configured always for actual size... 		  */
/* GLOBAL:  zdevice - used to define device mode for conversion routines  */
/**************************************************************************/
mutolas(ox,oy,nx,ny)
int ox,oy;
int *nx,*ny;
{
    zdevice = LASER;
    *nx = hmupix(ox);
    *ny = vmupix(oy);
}



/**************************************************************************/
/* Function:    pttomu()						  */
/* Description:	Point Size Text to Vertical Machine Units.		  */
/* IN:   ptsize  - Point Size of Text					  */
/* OUT:  Returns vertical machine units.				  */
/**************************************************************************/
pttomu(ptsize)
{
    return(16*ptsize);
}




/**************************************************************************/
/* Function:    get_scale_num()						  */
/* Description: get a scale for the current size to pass to do_text       */
/* IN: size - current viewing mode in RCS units - ie: PACTUAL		  */
/* OUT: returns a scale # from 1 to 200					  */
/* GLOBAL:      vpage_size - vertical page size in machine units	  */
/*              pwork.g_h  - height of preview work window		  */
/**************************************************************************/
get_scale_num(size)
int size;
{
   int hwidth;
   int column;
   int pixw,pixh;

   if( (view_size == PSIZE) || (view_size == PADJCNT))
   {
      pixw = hmupix(hpage_size);
      pixh = vmupix(vpage_size);

      hwidth = ((view_size == PADJCNT) ? (pixw * 2) : (pixw));
      column = ((view_size == PADJCNT) ? (dpwork.g_w/2) : (dpwork.g_w));
      if(dpwork.g_w <= scaler(dpwork.g_h,hwidth,pixh))
         return(scaler(column,100,pixw));
      else
         return(scaler(dpwork.g_h,100,pixh));
   }
   else
     return(scale_request(size));
}




/**************************************************************************/
/* Function:  scale_request()						  */
/* Description: Gets a scale factor from a table between 1 to 200	  */
/* IN: size - view mode in RCS units ie: PACTUAL			  */
/* OUT: returns scale factor between 1 to 200				  */
/* GLOBAL: scale_set - current setting of user defined mode.		  */
/**************************************************************************/
scale_request(size)
int size;
{
      int factor;

        switch(size)
        {
          case P50:     factor = 50;
	  	        break;

          case P75:     factor = 75;
		        break;

	  case PACTUAL: factor = 100;
		        break;

          case P200:    factor = 200;
                        break;
        }
        return(factor);
}



/**************************************************************************/
/* Function: scrn2mu()							  */
/* Description: Converts screen coordinates to mu (PADJCNT specific)      */
/**************************************************************************/
scrn2mu(ox,oy,nx,ny,flag,flag2)
int ox,oy;					/* Old x,y vertice	  */
int *nx,*ny;					/* New adjusted vertice   */
int flag;					/* scale direction flag   */
int flag2;					/* 0 = first page	  */
						/* 2 = 2nd page		  */
{
         int tmpx;
         int tmpy;
	 int hwidth;
	 

         tmpx    = ox;				/* save for later...      */
         tmpy    = oy;
	 zdevice = SCREEN;			/* Device destination     */

         if(!flag)
         {
	     tmpx -= dpwork.g_x;		/* adjust for work offset */
	     tmpy -= dpwork.g_y;		/* of the window...       */
         }


         if((view_size == PSIZE) ||		/* Want Size to Fit       */
            (view_size == PADJCNT))
         {
	    hwidth = ((view_size == PADJCNT) ? (hpage_size * 2) : (hpage_size));
	    *nx = scaler(tmpx,hwidth,pagew);  
	    *ny = scaler(tmpy,vpage_size,pageh);

	    if((flag2) && (view_size == PADJCNT) && (!flag) )
	    {
		alt_offset = TRUE;
		*nx -= hpage_size;
	    }
	    else
		alt_offset = FALSE;
				    	    
         }
         else					/* otherwise all others   */
         {
            scale_xy(&tmpx,&tmpy,1);
            *nx = hpixmu(tmpx);
	    *ny = vpixmu(tmpy);

            if(!flag)				/* adjust for the scrolled*/
	    {					/* offset off of the      */
                *nx += page_area.g_x;		/* window		  */
                *ny += page_area.g_y;		/* be adjusted...         */
            }            			
         }

}





/**************************************************************************/
/* Function: do_trans_scale()						  */
/* Description: Handles typed in coordinates for translation and scaling  */
/**************************************************************************/
do_trans_scale(oldx,oldy,oldwidth,oldheight,newx,newy,newwidth,newheight,type)
int oldx,oldy,oldwidth,oldheight;
int newx,newy,newwidth,newheight;
int type;
{
     	int opcode;
	int fflag;
	int fx,fy;
        register int i;
	int toggle;
	int odeltax,ndeltax;
	int odeltay,ndeltay;
        int tempx,tempy;
        int oldrect[4];

        oldrect[0] = oldx;
 	oldrect[1] = oldy;
	oldrect[2] = oldx + oldwidth - 1;
	oldrect[3] = oldy + oldheight - 1;

	if((oldx != newx) || (oldy != newy) || (oldwidth != newwidth)
	   || (oldheight != newheight))
	{
	   if(snap_to_grids)
	   {
		tempx = newx + newwidth;
		tempy = newy + newheight;
		snap_mu(&newx,&newy);
		snap_mu(&tempx,&tempy);
		newwidth  = tempx - newx;
		newheight = tempy - newy;
           }

	   fx = (  (  (newx - oldx) < 0) ? (-1) : (1));
	   fy = (  (  (newy - oldy) < 0) ? (-1) : (1));

	   deltax = abs(newx - oldx);
	   deltay = abs(newy - oldy);
	
	   deltax *= fx;
	   deltay *= fy;
	   
	   opcode = get_fprimitive(region_ptr,&count,&wmode);
	   fflag = TRUE;
	   while(opcode != -1)
	   {
		switch(opcode)
		{
		    case 3:
		    case 4:
		    case 0: toggle = TRUE;		/* translate */
		            for(i=0;i<(count*2);i++)
			    {
			       ptsarray[i] += ((toggle) ? (deltax):(deltay));
			       toggle ^= TRUE;
			    }

			    i = 0;			/* and scale */
			    while(i<count*2)
			    {
				odeltax = ptsarray[i] - newx;
				ndeltax = scaler(odeltax,newwidth,oldwidth);
				ptsarray[i++] = newx + ndeltax;

				odeltay = ptsarray[i] - newy;
				ndeltay = scaler(odeltay,newheight,oldheight);
				ptsarray[i++] = newy + ndeltay;
			    }

			    break;

		    case 1: ptsarray[0] += deltax;	/* translate */
			    ptsarray[1] += deltay;
							/* and scale */
			    case12_scale(newx,newy,oldwidth,oldheight,
					newx,newy,newwidth,newheight,1);
			    break;

		    case 2: ptsarray[0] += deltax;	/* translate */
			    ptsarray[2] += deltax;
			    ptsarray[1] += deltay;
			    ptsarray[3] += deltay;
							/* and scale */
			    case12_scale(newx,newy,oldwidth,oldheight,
					newx,newy,newwidth,newheight,2);
			    break;
	   
		}	/* end of switch(opcode) */
		update_primitive(opcode,count,wmode,fflag);
		fflag = FALSE;
		opcode = get_nprimitive(&count,&wmode);
	   }		/* end of while		 */

	   if(!type)		/* text only */
	   {		
		page_redraw(region_ptr);
	   }
	   else
		update_repel(1,oldrect);
	   if(view_size != PADJCNT && !deferhj && gl_region_ptr)
		redraw_area(region_ptr,oldrect,1);
	}
	graf_mouse(0,&dummy);
}




/**************************************************************************/
/* Function: case12_scale()						  */
/* Description: Scale for opcodes 1 and 2 for typed in vertices		  */
/**************************************************************************/
case12_scale(oldx,oldy,oldw,oldh,newx,newy,neww,newh,flag)
int oldx,oldy,oldw,oldh;
int newx,newy,neww,newh;
int flag;
{
     int odeltax,odeltay;
     int ndeltax,ndeltay;

     odeltax = ptsarray[0] - oldx;
     ndeltax = scaler(odeltax,neww,oldw);
     ptsarray[0] = newx + ndeltax;

     odeltay = ptsarray[1] - oldy;
     ndeltay = scaler(odeltay,newh,oldh);
     ptsarray[1] = newy + ndeltay;

     if(flag == 1)
     {
         odeltax = ptsarray[2];
         ndeltax = scaler(odeltax,neww,oldw);
         ptsarray[2] = ndeltax;

         odeltay = ptsarray[3];
         ndeltay = scaler(odeltay,newh,oldh);
         ptsarray[3] = ndeltay;
     }
     else
     {
         odeltax = ptsarray[2] - oldx;
         ndeltax = scaler(odeltax,neww,oldw);
         ptsarray[2] = newx + ndeltax;

         odeltay = ptsarray[3] - oldy;
         ndeltay = scaler(odeltay,newh,oldh);
         ptsarray[3] = newy + ndeltay;
     }
}




/**************************************************************************/
/* Function: scale_prim_coord()					          */
/* Description: Scales primitive coordinates				  */
/**************************************************************************/
scale_prim_coord(opcode,oldx,oldy,oldwidth,oldheight,newx,newy,
		 newwidth,newheight,type,count,wmode)
int opcode;
int oldx,oldy,oldwidth,oldheight;
int newx,newy,newwidth,newheight;
int type;
int count;
int wmode; 
{
	int fx,fy;
        register int i;
	int toggle;
	int odeltax,ndeltax;
	int odeltay,ndeltay;
        int tempx,tempy;

        int oldrect[4];

        oldrect[0] = oldx;
 	oldrect[1] = oldy;
	oldrect[2] = oldx + oldwidth - 1;
	oldrect[3] = oldy + oldheight - 1;

	if((oldx != newx) || (oldy != newy) || (oldwidth != newwidth)
	   || (oldheight != newheight))
	{
	   if(snap_to_grids)
	   {
		tempx = newx + newwidth;
		tempy = newy + newheight;
		snap_mu(&newx,&newy);
		snap_mu(&tempx,&tempy);
		newwidth  = tempx - newx;
		newheight = tempy - newy;
           }

	   fx = (  (  (newx - oldx) < 0) ? (-1) : (1));
	   fy = (  (  (newy - oldy) < 0) ? (-1) : (1));

	   deltax = abs(newx - oldx);
	   deltay = abs(newy - oldy);
	
	   deltax *= fx;
	   deltay *= fy;

		switch(opcode)
		{
		    case 3:
		    case 4:
		    case 0: toggle = TRUE;		/* translate */
		            for(i=0;i<(count*2);i++)
			    {
			       ptsarray[i] += ((toggle) ? (deltax):(deltay));
			       toggle ^= TRUE;
			    }

			    i = 0;			/* and scale */
			    while(i<count*2)
			    {
				odeltax = ptsarray[i] - newx;
				ndeltax = scaler(odeltax,newwidth,oldwidth);
				ptsarray[i++] = newx + ndeltax;

				odeltay = ptsarray[i] - newy;
				ndeltay = scaler(odeltay,newheight,oldheight);
				ptsarray[i++] = newy + ndeltay;
			    }

			    break;

		    case 1: ptsarray[0] += deltax;	/* translate */
			    ptsarray[1] += deltay;
							/* and scale */
			    case12_scale(newx,newy,oldwidth,oldheight,
					newx,newy,newwidth,newheight,1);
			    break;

		    case 2: ptsarray[0] += deltax;	/* translate */
			    ptsarray[2] += deltax;
			    ptsarray[1] += deltay;
			    ptsarray[3] += deltay;
							/* and scale */
			    case12_scale(newx,newy,oldwidth,oldheight,
					newx,newy,newwidth,newheight,2);
			    break;
	   
		}	/* end of switch(opcode) */
		update_primitive(opcode,count,wmode,0);
		recalc_region();

	   if(!type)		/* text only */
	   {
		page_redraw(region_ptr);
	   }
	   else
		update_repel(1,oldrect);
	   if(view_size != PADJCNT && !deferhj && gl_region_ptr)
		redraw_area(region_ptr,oldrect,1);
	}
	graf_mouse(0,&dummy);
}




/**************************************************************************/
/* Function: mutopt()							  */
/* Description: 							  */
/**************************************************************************/
mutopt(munits)
int munits;
{
   return(munits / 16);
}
