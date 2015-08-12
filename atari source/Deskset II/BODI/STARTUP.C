/**************************************************************************/
/*  FILE:  STARTUP.C		PROGRAM TITLE: DeskSET II Alpha Version   */
/*  Date Created: 12/15/87						  */ 
/*  Last Modified: 09/21/88						  */
/*  Modified from aps.c - G.O. Graphics 1987/1988/1989?			  */
/*									  */
/*  Description: Entry into DeskSET					  */
/*  Routines:	o main()   	- Start Application Here		  */
/*		o gsx_mon()	- Turn on Mouse and Release Semaphor      */
/*		o gsx_moff()	- Turn off Mouse and Seize Semaphor	  */
/*		o open_work()   - Open workstations, resource and windows */
/*		o close_vwork()	- Close in emergency			  */
/*		o close_work()	- close at end of day...		  */
/*		o laser_open()  - Open Laser Workstation		  */
/* 		o laser_close() - Close Laser Workstation		  */
/*		o page_open()   - Open Memory Workstation		  */
/*		o page_close()  - Close Memory Workstation		  */
/**************************************************************************/


/**************************************************************************/
/* INCLUDE FILES							  */
/**************************************************************************/
#include "define.h"
#include "gemdefs.h"
#include <osbind.h>
#include "alert.h"

/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/
#define SCANX   640				/* scan buffer resolution */
#define SCANY   1088				/* x and y resolution     */
						/* Legal Size Paper	  */
#define PREVIEW_SIZE 352600L			/* Calced at 80dpi	  */
						/* (648 * 1088 * 4)/8     */
#define LASER_SIZE   1223190L			/* calced at 300dpi	  */

#define SCAN_SIZE    88128L

/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern char rscerr[],rscerr1[],rscerr2[];	/* Error Alert Boxes...   */
extern int gl_apid;
extern long BADDR;
extern int dummy;
extern int *bltbuffer;				/* CS icon save buffer    */
extern int sdevm;
extern char scanerr[];
extern char preverr[];

extern unsigned char *get_lmem();
extern unsigned char *get_lcmem();
extern char *lmalloc();
extern char *lcalloc();
extern char *pbuff;

extern int axdpi[];
extern int aydpi[];

extern int half_xdpi[];
extern int half_ydpi[];

extern unsigned int xdpi[];		/* right, from ifout.c 		  */
extern unsigned int ydpi[];		/* and we shouldn't really be     */
					/* touching this...		  */

extern unsigned int gdostst();


extern char fbuffer[];

/**************************************************************************/
/* GLOBAL VARIABLES							  */
/**************************************************************************/
int contrl[12];						   /* Bindings... */
int intin[256];
int ptsin[256];
int intout[256];
int ptsout[256]; 

int charw,charh;					   /* Graf_handle */
int boxw,boxh;			           

int gl_wchar;						   /* System sizes*/
int gl_hchar;
int gl_wbox;
int gl_hbox;
 
int phys_handle;			        /* Physical Handle        */
int shandle;					/* Screen Handle          */
int phandle;					/* Printer Handle         */
int mhandle;					/* Memory Handle          */
int xor_handle;					/* drawing handle	  */
int rule_handle;

int sxres;					/* Screen x resolution    */
int syres;					/* Screen y resolution    */
int splane;					/* Screen Num of planes   */

int scan_xres,scan_yres;			/* scan buffer x,y rez    */
int pxres,pyres;				/* Printer Resolutions    */
int mxres,myres;				/* Memory resolutions     */
int oldpal[16];					/* Old Palette            */

unsigned long pageim;				/* Ptr to laser buffer    */
unsigned long pagesc;				/* ptrs to memory driver  */
unsigned long page_ptr;				/* buffer...              */
unsigned long scanesc;				/* Ptr to scan buffer     */
unsigned long scanptr;				/* ditto...		  */

unsigned long prev_bytes;
unsigned long laser_bytes;
unsigned long scan_bytes;

int cur_point_size;				/* Current Point Size	  */

int     mouse_on;				/* Mouse On/Off Flag      */
long 	lineav;					/* Get base of linea vars */
int	*gcurx;					/* Ptr to mouse x position*/
int	*gcury;					/* Ptr to mouse y position*/

char    *gbutton;				/* Ptr to button state    */
FDB page_MFDB;					/* Preview Memory Form    */
FDB laser_MFDB;					/* Laser Memory Form	  */

extern int maxpat;			/* Graphic screen device limits   */
extern int maxhatch;
extern int maxlwidth;
extern int maxlstyles;

long pagebytes;

char envstr[80];

/**************************************************************************/
/* Function: main()							  */
/* Description: Must I really explain?					  */
/**************************************************************************/
main(argc,argv)
int argc;
char *argv[];
{
        int drv;
        char ch;
        char *pathptr;
        int i;

	lineai();				/* Get base of linea addr */
	gcurx = lineav - 602;			/* Ptr to mouse x pos.    */
	gcury = lineav - 600;			/* Ptr to mouse y pos.    */
    	gbutton = lineav - 348;			/* Ptr to button state    */

    	appl_init();
        if(argv[1])
        {
           pathptr = fbuffer;
           *pathptr++ = (drv = Dgetdrv())+'A';
	   *pathptr++ = ':';
	   Dgetpath(pathptr,drv+1);
	   strcat(pathptr,"\\");
	}

        strcpy(envstr,"DESK2.PRG");
        shel_find(envstr);
        if(envstr[1] == ':' && argv[1])
	{
	   ch = envstr[0];
	   ch -= 'A';
	   drv = (int)ch;
	   if(drv >= 0 && drv <= 15)
		Dsetdrv(drv);
	   for(i=strlen(envstr); i && !instring(envstr[i],"\\:");
						envstr[i--] = '\0');
	   Dsetpath(&envstr[2]);
	}
	       	
        if(!rsrc_load("DESKSET2.RSC"))
		alert_cntre(ALERT1);
        else
        {
	  if((phys_handle = graf_handle(&gl_wchar,&gl_hchar,
				      &gl_wbox,&gl_hbox))
				      && open_work())
            front_end(argv[1]);
        }
	appl_exit();
}




/*************************************************************************/
/* Function:    gsx_mon()						 */
/* Description: Turn mouse on and release screen metaphor.               */
/*************************************************************************/
gsx_mon()
{
	if(!mouse_on)
	{
	    graf_mouse(M_ON,0x0L);
	    wind_update(FALSE);
	    mouse_on = TRUE;
	}
}



/*************************************************************************/
/* Function:    gsx_moff()						 */
/* Description: Turn mouse off and grab screen metaphor.                 */
/*************************************************************************/
gsx_moff()
{
	if(mouse_on)
  	{
	    graf_mouse(M_OFF,0x0L);
	    wind_update(TRUE);
	    mouse_on = FALSE;   
	}
}



/*************************************************************************/
/* Function:    open_work();						 */
/* Description: o Open Workstations					 */
/*              o Allocate Default Buffers.				 */
/*		o Load Resource						 */
/*		o Display menu bar					 */
/*************************************************************************/
open_work()
{
    register unsigned int i;

    sdevm = Getrez();
    if(!sdevm)
    {
	alert_cntre(ALERT35);
	return(0);
    }
    intin[0] = sdevm + 2;				/* Get Rez...    */
    for(i = 1; i < 10; i++) intin[i] = 1;		/* Set up array  */
    intin[10] = 2;
    rule_handle = xor_handle = shandle = phys_handle;	/* copy handle   */
    v_opnvwk(intin,&shandle,intout);			/* open virtual  */
    if(!shandle)
    {    
          rsrc_free();
          return(0); 					/* Exit if error */
    }

    sxres = intout[0] + 1;			 	/* Get Resolution*/
    syres = intout[1] + 1;



    maxpat = intout[11] + 1;		/* + 1 for hollow     */
    maxhatch = intout[12];
    maxlwidth = intout[51];
    maxlstyles = 6;
    vq_extnd(shandle,1,intout);
    splane= intout[4];					/* Get Num planes*/

    if(gdostst() == -2)
    {
	alert_cntre(ALERT36);
	rsrc_free();
	v_clsvwk(shandle);
	return(0);
    }


    intin[0] = sdevm + 2;				/* Get drawing   */
    for(i = 1; i < 10; i++) intin[i] = 1;		/* handle        */
    intin[10] = 2;
    v_opnvwk(intin,&xor_handle,intout);    
    if (!xor_handle)
    {
	   rsrc_free();
	   v_clsvwk(shandle);
           return(0);
    }


    intin[0] = sdevm + 2;
    for(i = 1; i < 10; i++) intin[i] = 1;
    intin[10] = 2;
    v_opnvwk(intin,&rule_handle,intout);
    if(!rule_handle)
    {
	   rsrc_free();
	   v_clsvwk(xor_handle);
	   v_clsvwk(shandle);
	   return(0);
    }

    mhandle = 0;  					/* set handles   */
    scanesc = scanptr = pagesc = page_ptr = 0L;		/* and pointers  */

    adjustdpi();
    initsys();		/* CS moved from front_end */
    laser_bytes = LASER_SIZE;

    mouse_on = TRUE;
    gsx_moff();

 	/*    numbytes = (((xdpi * 8inches) * (ydpi * 14))/8)	    */
	/*    preview buffer = numbytes * 4;			    */

    mxres = scan_xres = axdpi[0] * 8;
    myres = scan_yres = aydpi[0] * 14;
/*    scan_bytes = ((((long)mxres) * ((long)myres)) / 8L);*/
    scan_bytes = (long)(((((long)mxres + 15L)/16L)*2L)*(long)(myres));
    prev_bytes = scan_bytes * 4L;
    pbuff  = get_lcmem(200L);
    scanptr = scanesc = (unsigned long)Malloc(scan_bytes);
    if((!scanesc) || (!pbuff))
    {
	     alert_cntre(ALERT14);
	     return(0);
    }


    if(!page_open())					/* Open preview  */
    {
	     alert_cntre(ALERT11);
             close_vwork();
	     return(0);				/* exit if error */
    }


    page_MFDB.fd_stand = 0;				/* set up MFDB   */
    page_MFDB.fd_nplanes = 1;				/* Mono only...  */
    laser_MFDB.fd_stand = 0;
    laser_MFDB.fd_nplanes = 1;

    for(i=0;i<16;i++) oldpal[i] = Setcolor(i,-1);       /* Save Colors   */

    set_icon_pos();
    open_resource();					/* open resources*/
    open_windows();					/* and windows...*/
/*  graf_mouse(ARROW,0L);				* set to arrow..*/
    return(1);						/* and TTFN...   */
}							/* Ta Ta For Now */



/*************************************************************************/
/* Function:    close_vwork()					         */
/* Description: Close workstations, free memory, release resources.      */
/*		This is used in case an error occurred allocating        */
/*		buffers or opening workstations...			 */
/*************************************************************************/
close_vwork()
{
   if(pbuff)
	   free(pbuff);
   if(pagesc)
           Mfree(pagesc);
   if(scanesc)
	   Mfree(scanesc);
   if(bltbuffer)
   	   free(bltbuffer);
   page_close();
   gsx_mon();
   rsrc_free();
   v_clsvwk(rule_handle);
   v_clsvwk(xor_handle);
   v_clsvwk(shandle);
   appl_exit();
   exit(0);
}



/*************************************************************************/
/* Function:    close_work()					         */
/* Description: Close workstations, free memory, release resources.      */
/*		Used to exit the program...			  	 */
/*************************************************************************/
close_work()
{
    if(pbuff)
	   free(pbuff);
    if(pagesc)
           Mfree(pagesc);
    if(scanesc)
	   Mfree(scanesc);
    if(bltbuffer)
    	   free(bltbuffer);
    free_templates();
    page_close();
    IF_close();		/* GOG font manager */
    shut_windows();
    close_resource();
    vex_butv(xor_handle,BADDR,&dummy);
    Setpallete(oldpal);
    gsx_mon();
    v_clsvwk(rule_handle);
    v_clsvwk(xor_handle);
    v_clsvwk(shandle);
    appl_exit();
    exit(0);
}



/*************************************************************************/
/* Function:    laser_open()						 */
/* Description: Open Laser Workstation					 */
/*************************************************************************/
laser_open(buffptr,x,y)
long buffptr;
int x;
int y;
{
   register int i;
   int pxy[4];
   int mx,my;
   int dpix;
   int dpiy;

   intin[0] = 21;
   for (i=1;i<10;i++) intin[i] = 1;
   intin[10] = 2;
   pageim = buffptr;
   GDv_opnwk(intin,&phandle,intout,x,y,&pageim);
   pxres = intout[0];
   pyres = intout[1];
   mx    = intout[3];			/* x and y microns of 1 pixel */
   my    = intout[4];
   if(phandle && pageim)		/* printer MUST return BUFFER!*/
   {
        pxy[0] = pxy[1] = 0;
        laser_MFDB.fd_addr = pageim;
        pxy[2] = laser_MFDB.fd_w = pxres; 
        pxy[3] = laser_MFDB.fd_h = pyres;
	laser_MFDB.fd_wdwidth = (pxres + 15)/16;
        vs_clip(phandle,1,pxy);
        if((mx != 85) && (my != 85))	/* if a laser...then 300dpi always */
        {				/* cause 25400 would be 298dpi     */
	  dpix = 25400/mx;	        /* 25400 microns per inch */
          dpiy = 25400/my;        
	  axdpi[3] = xdpi[3] = dpix;	/* G.O. Graphics array... */
          aydpi[3] = ydpi[3] = dpiy;	/* and CG array...        */
 
	  half_xdpi[3] = dpix/2;	/* half of dpi...	  */
          half_ydpi[3] = dpiy/2;
        }
/*	laser_bytes = ((((long)pxres) * ((long)pyres))/8L);*/
        laser_bytes = (long)(((((long)pxres + 15L)/16L)*2L)*(long)pyres);
	IF_close();
	IF_open(0);
   }
   return((phandle && pageim));   
}



/*************************************************************************/
/* Function:   laser_close()						 */
/* Description: Close Laser Workstation					 */
/*************************************************************************/
laser_close()
{
   if(phandle)
   {
      vst_unload_fonts(phandle,0);
      v_clswk(phandle);		
   }				
}



/*************************************************************************/
/* Function:    page_open()						 */
/* Description: Open memory driver Workstation				 */
/*		Preview Buffer Workstation				 */
/*************************************************************************/
page_open()
{
    register int i;

    long tmpptr;

    intin[0] = 61;
    for(i=1;i<10;i++) intin[i] = 1;
    intin[10] = 2;
    tmpptr = lmalloc(100L);
    if(tmpptr)
    {
       GDv_opnwk(intin,&mhandle,intout,16,16,&tmpptr);
       if(mhandle)
           init_text(mhandle);
       page_ptr = pagesc = (unsigned long)Malloc(prev_bytes); /*4xlegal size*/
       if(mhandle && page_ptr)
       {
           GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);
	   pagebytes = prev_bytes;
       }
       free(tmpptr);
    }
    return((mhandle && page_ptr && tmpptr));

}



/*************************************************************************/
/* Function:    page_close()						 */
/* Description: Close memory driver workstation				 */
/*		Preview Buffer Workstation				 */
/*************************************************************************/
page_close()
{
    if(mhandle)
    {
	 vst_unload_fonts(mhandle,0);
         v_clswk(mhandle);
    }
}



unsigned char *get_lmem(size)
long size;
{
      unsigned char *memp;

      memp = lmalloc((long)size);
      return(memp);
}


unsigned char *get_lcmem(size)
long size;
{
     unsigned char *memp;
  
     memp = lcalloc(1L,size);
     return(memp);
}



adjustdpi()
{
   if(sdevm == 1)	/* medium rez */
   {			/* vertical rez is 1/2 of hi res */
      aydpi[0] = aydpi[1] = aydpi[2] = 40;
      half_ydpi[0] = half_ydpi[1] = half_ydpi[2] = 20;
      return;
   }

/*   if((sxres > 640) && (syres > 400))	* large monitor */
			  /* it's not low, med or high! */
   if( (sdevm > 2) || ((sdevm == 2) && ((sxres > 641) && (syres > 401))))
   {					/* 95 dpi        */
      axdpi[0] = axdpi[1] = axdpi[2] = 95;
      aydpi[0] = aydpi[1] = aydpi[2] = 95;
      half_xdpi[0] = half_xdpi[1] = half_xdpi[2] = 47;
      half_ydpi[0] = half_ydpi[1] = half_ydpi[2] = 47;

      sdevm = 0;
      xdpi[0] = 95;		/* change GO Graphics dpi */
      ydpi[0] = 95;		/* info for x and y dpi   */
   }
}
