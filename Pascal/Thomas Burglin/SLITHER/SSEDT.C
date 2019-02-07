/******************************************
Slither screen editor
copyright THOMAS R. BURGLIN   8/1988
all rights reserved
written using Megamax Laser C v1.1
******************************************/

#include "ssedt.h"

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <linea.h>
#include <strings.h>

#define   LWORD     long
#define   WORD      int
#define   BUSYBEE   HOURGLASS
#define   NRSET     10

   long   _stksize = 15000; 

   int    contrl[12];
   int    intin[128],  ptsin[128];
   int    intout[128], ptsout[128];
   WORD   handle;
   WORD   w_handle;
   char   defpath[64],workpath[80],filename[20],filepath[80];
   int    gdos;
   MFDB   screenbuffer;    /* raster buffer for screen  */
   MFDB   screen;          /* raster definition for screen  */
   char   *scptr;
   LWORD  menubar, diasave, diainfo, diagoto, diasym;
   
   WORD   out[128];
   WORD   clip[4];
   WORD   wi_1,wi_2,wi_3,wi_4;
   WORD   slsizx, slsizy, slposx, slposy;  /* sliders       */
   char   *stlevel = {"__"};
   char   *nrlevel = {"__"};
   char   *atlevel = {"__"};
   char   *gotoset = {"__"};
   char   *gotolevel = {"__"};
   typedef unsigned char FIDAR[30][5][38];
   FIDAR  setbuffer;
   FIDAR  *set[NRSET];
 
   int    level[NRSET];
   int    nrfields[NRSET];
   int    atfields[NRSET];
   int    maxsetindex;
   int    setindex;  
   int    levelindex[NRSET];
   int    changeset[NRSET];
   char   setname[NRSET][20];
   int    screenfield, screenunit;
   int    xscreenfield, xscreenunit;
   int    screenxs, screenys;
   WORD   fic[4], foc[4];
      
   WORD  dodialog();
   WORD  readfield();
   WORD  objcstate();
   WORD  whichbutton();
   lineaport *myport;

main()
{
   WORD   x, y, i, j, k, l;
   WORD   oldx, oldy;
   WORD   gr_1,gr_2,gr_3,gr_4;
   WORD   wi_coutx, wi_couty, wi_coutw, wi_couth;
   WORD   wind_type;
   WORD   mgbuf[8], mox, moy, mob, mok, mkr, mbr; /* multi event parameters */
   WORD   whichevent;
   int    eventmode;
   int    ap_id;
   int    plotflag;
   int    drawflag;
   int    sw;
   int    copylevel;
   int    exflag;
   int    lineflag, dir;
   int    startx, starty;
   int    mode;
   int    symmode;
   char   text[40];
     
/* Set the system up to do GEM calls*/

   ap_id = appl_init();

   myport = a_init();
  
/* Open the workstation */

   handle = open_workstation (&screen);
   screenbuffer = screen;   /* set buffer to same as screen  */
   scptr = (char*)malloc(32010);
   if (scptr == NULL)
      {
      form_alert (1,"[3][ Not enough memory ][CANCEL]");
      goto end2;
      }
   screenbuffer.fd_addr = (long)scptr;

   v_show_c(handle,0);
   graf_mouse(BUSYBEE,0);

   defpath[0] = Dgetdrv()+'A';
   defpath[1] = ':';
   Dgetpath (&defpath[2],0);
   strcpy (workpath,defpath);
   strcat (workpath,"\\");
   strcat (workpath,"ssedt.rsc");

   i = rsrc_load(workpath);
   if (i==0) 
      {
      form_alert (1,"[3][Error in|Resource file][CANCEL]");
      goto end2;
      }
   strcpy (workpath,defpath);
   strcat (workpath,"\\*.*");
   rsrc_gaddr(0,D_SAVE,&diasave);
   rsrc_gaddr(0,MENU1,&menubar);
   rsrc_gaddr(0,D_INFO,&diainfo);
   rsrc_gaddr(0,D_GOTO,&diagoto);
   rsrc_gaddr(0,D_SYM,&diasym);
   menu_bar(menubar,1);

   strptr(stlevel,diasave,DS_FROM); /* bend pointer in resource to program
                                         strings  */
   strptr(nrlevel,diasave,DS_TO);
   strptr(atlevel,diasave,DS_AT);
   strptr(gotoset,diagoto,DG_SET);
   strptr(gotolevel,diagoto,DG_LEVEL);
   
   graf_mouse(ARROW,1);
   
/* request size of desktop window */
   wind_get(0,4,&wi_1,&wi_2,&wi_3,&wi_4);

   wind_type = UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|NAME;

/* calculate size of work area */
   wind_calc(1,wind_type,wi_1,wi_2,wi_3,wi_4,&wi_coutx,&wi_couty,&wi_coutw,&wi_couth);

/* make window of the max size */

   w_handle = wind_create(wind_type,wi_1,wi_2,wi_3,wi_4);
   wind_set(w_handle,WF_NAME,"",0,0);

   eventmode = MU_KEYBD|MU_MESAG|MU_BUTTON;
   
   if (Getrez() == 1) i = 2;
   else i = 1;

   screenunit = wi_couth / 40;
   xscreenunit = i * screenunit;
   screenfield = 40 * screenunit;
   xscreenfield = 40 * xscreenunit;
   foc[0] = wi_coutx + (wi_coutw - xscreenfield - 10);
   foc[1] = wi_couty + ((wi_couth - screenfield) / 2);
   foc[2] = foc[0] + xscreenfield + 1;
   foc[3] = foc[1] + screenfield + 1;
   fic[0] = foc[0] + xscreenunit;
   fic[1] = foc[1] + screenunit;
   fic[2] = foc[2] - xscreenunit - 2;
   fic[3] = foc[3] - screenunit - 2;
   screenfield = 38 * screenunit;
   xscreenfield = 38 * xscreenunit;

   v_hide_c(handle);
   clip[0] = wi_1; clip[1] = wi_2;
   clip[2] = wi_1 + wi_3 - 1; clip[3] = wi_2 + wi_4 - 1;
   vsf_interior(handle,2);
   vsf_style(handle,4);
   vsf_color(handle,0);
   v_bar(handle,clip);     /* clear window  */
   screensave();
   v_show_c(handle,1);

   setindex = maxsetindex = 0;
   exflag = 0;
   symmode = 0;
   plotflag = 0;   /* do not plot field when 0 */       
   xslidersize();
   sw = 0;
   lineflag = dir = 0;
   
bigloop: 
          
   if (maxsetindex > 0)
      {
      if (plotflag == 1)
         {
         wind_set (w_handle,WF_TOP,0,0,0,0);
         v_hide_c(handle);
         sprintf (text,"%2d",maxsetindex);
			v_gtext(handle,20,wi_couty+34,text);
         sprintf (text,"%2d",setindex + 1);
         v_gtext(handle,20,wi_couty+74,text);
         sprintf (text,"%-12s",setname[setindex]);
         v_gtext(handle,20,wi_couty+114,text);
         sprintf (text,"%2d",levelindex[setindex]);
         v_gtext(handle,20,wi_couty+154,text);
         plotfield(set[setindex],levelindex[setindex]-1);
         screensave();
         plotflag = 0;
         v_show_c(handle);
         }      
      }                 
   whichevent = evnt_multi(eventmode,1,1,1,
                           sw,fic[0],fic[1],xscreenfield,screenfield,
                           0,fic[0],fic[1],xscreenfield,screenfield,
                           mgbuf,0,0,&mox,&moy,
                           &mob,&mok,&mkr,&mbr);


   if (whichevent & MU_MESAG)
      {                  
      if (mgbuf[0] == WM_REDRAW && mgbuf[1] > 1) 
         {
   	   do_redraw(mgbuf[4],mgbuf[5],mgbuf[6],mgbuf[7]);
   	   goto bigloop;
         }  
      if (mgbuf[0] == MN_SELECTED)
        	{
        	i = menu_tnormal (menubar,mgbuf[3],1);
         }
      }
   wind_get (w_handle,WF_TOP,&i,&j,&j,&j);
   if (i > w_handle) goto bigloop;
   if (whichevent & MU_M1)
      {
      if (sw) 
         {
         sw = 0;
         graf_mouse(ARROW,0);
         screensave();
         }
      else 
         {
         sw = 1;
         graf_mouse(THIN_CROSS,0);
         }
      }   
   if (whichevent & MU_M2)
      {
      x = (mox - fic[0]) / xscreenunit;
    	y = (moy - fic[1]) / screenunit;
    	if ((x != oldx) || (y != oldy))
    	   { 
         sprintf (text,"%3d",x + 1);
         v_gtext(handle,fic[0],wi_couty - 4,text);
         sprintf (text,"%3d",y + 1);
         v_gtext(handle,fic[0]+50,wi_couty - 4,text);
         oldx = x; oldy = y;
         if (whichevent & MU_BUTTON && Kbshift(-1) & 3)
            {
            if (lineflag == 0)
               {
               startx = x;
               starty = y;
               lineflag++;
               }
            else if (lineflag == 1)
               {
               lineflag++;
               if (startx == x) dir = 0;
               else dir = 1;
               }
            }     
         }
      if (whichevent & MU_BUTTON) 
      	{
         if (Kbshift(-1) & 3 && lineflag > 1)
            {
            if (dir) y = starty;
            else x = startx;
            }   
      	plotpoint(set[setindex],levelindex[setindex]-1,x,y,drawflag);
      	drawflag = 1;
      	changeset[setindex] = 1;
      	switch(symmode)
      	   {
      	   case 0: goto bigloop;          
      	   case 5: x = 37 - x; break;
      	   case 4: y = 37 - y; break;
      	   case 6: plotpoint(set[setindex],levelindex[setindex]-1,
      	                     37-x,y,drawflag);
						  y = 37 - y;
      	           plotpoint(set[setindex],levelindex[setindex]-1,
      	                     x,y,drawflag);
      	           x = 37 - x;
      	           break;
      	   case 1: i = x; x = y; y = i; break;
      	   case 2: i = 37 - x; x = 37 - y; y = i; break;
      	   case 3: plotpoint(set[setindex],levelindex[setindex]-1,
      	                     y,x,drawflag);
      	           plotpoint(set[setindex],levelindex[setindex]-1,
      	           37-x,37-y,drawflag);
      	           i = 37 - x; x = 37 - y; y = i;
      	           break;
      	   }
      	plotpoint(set[setindex],levelindex[setindex]-1,x,y,drawflag);
      	}
      else lineflag = drawflag = 0;
      }   
   if (whichevent & MU_KEYBD)
      {
      whichevent = MU_MESAG;
      mgbuf[0] = MN_SELECTED;
      i = toupper(mkr & 0xff);
      if (i == 'L') mgbuf[4] = MF_LOAD;
      else if (i == 'S') mgbuf[4] = MF_SAVE;
      else if (i == 'R') mgbuf[4] = MF_CLOSE;
      else if (i == 'Q') mgbuf[4] = MF_QUIT;
      else if (i == 'C') mgbuf[4] = ME_COPY;
      else if (i == 'U') mgbuf[4] = ME_CUT;
      else if (i == 'H') mgbuf[4] = ME_EX; 
      else if (i == 'E') mgbuf[4] = ME_ERASE;
      else if (i == 'P') mgbuf[4] = ME_PASTE;
      else if (i == 'A') mgbuf[4] = ME_AND;
      else if (i == 'O') mgbuf[4] = ME_OR;
      else if (i == 'X') mgbuf[4] = ME_XOR;
      else if (i == 'G') mgbuf[4] = MO_GOTO;
      else if (i == 'T') mgbuf[4] = MO_CSET;
      else if (i == 'V') mgbuf[4] = MO_PSET;
      else if (i == 'Y') mgbuf[4] = MO_SYM;
      else if (mkr == 0x4d00) mgbuf[4] = MR_RIGHT;
      else if (mkr == 0x5000) mgbuf[4] = MR_DOWN;
      else if (mkr == 0x4800) mgbuf[4] = MR_UP;
      else if (mkr == 0x4b00) mgbuf[4] = MR_LEFT;
      else goto bigloop;
      if (objcstate(menubar,mgbuf[4]) & DISABLED) goto bigloop;
      }
   if (whichevent & MU_MESAG)
      {                  
      if (mgbuf[0] == MN_SELECTED)
        	{
        	i = menu_tnormal (menubar,mgbuf[3],1);
        	
        	if (mgbuf[4] == MF_NEW)
        	   {
        	   strcpy (filename,"UNTITLED.TXT");
        	   level[maxsetindex] = 1;
        	   nrfields[maxsetindex] = 30;
        	   set[maxsetindex] = (FIDAR *)malloc(sizeof(setbuffer)+5);
     	  	   if (set[maxsetindex] == NULL)
     	  	      {
        	  	   form_alert (1,"[3][ Not enough memory ][CANCEL]");
        	  	   goto bigloop;
        	  	   }
     	  	   else
     	  	      {
        	  	   arclr(set[maxsetindex],0,30);
        	  	   levelindex[maxsetindex] = 1;
              	goto fieldasign;
        	  	   }   
        	   }
        	if (mgbuf[4] == MF_LOAD)
        	  	{
        	   i = readfield (setbuffer,&level[maxsetindex],
        	                  &nrfields[maxsetindex]);
        	  	if (i != 0)
        	  	   {
          	   set[maxsetindex] = (FIDAR *)malloc(sizeof(setbuffer)+5);
        	  	   if (set[maxsetindex] == NULL)
        	  	      {
        	  	      form_alert (1,"[3][ Not enough memory ][CANCEL]");
        	  	      goto bigloop;
        	  	      }
        	  	   else
        	  	      {
        	  	      graf_mouse(BUSYBEE,0);
   	            menu_ienable(menubar,ME_PASTE,0);
   	            menu_ienable(menubar,MO_PSET,0);
             	  	arclr(set[maxsetindex],0,30);
        	  	      arcpy(set[maxsetindex],setbuffer,level[maxsetindex]-1,
        	  	            nrfields[maxsetindex]);
                  levelindex[maxsetindex] = level[maxsetindex];
                  graf_mouse(ARROW,0);
fieldasign:       strcpy (&setname[maxsetindex][0],filename);
  						atfields[maxsetindex] = level[maxsetindex];
        	  	      if (maxsetindex == 0)
        	  	         {
        	  	         v_hide_c(handle);
        	  	         wind_open(w_handle,wi_1,wi_2,wi_3,wi_4);
        	  	         eventmode |= MU_M1|MU_M2;
                     clip[0] = wi_coutx; 
                     clip[1] = wi_couty;
                     clip[2] = wi_coutx + wi_coutw - 1; 
                     clip[3] = wi_couty + wi_couth - 1;
							vsf_interior(handle,1);
   						vsf_color(handle,3);
   						if (Getrez == 2) vsf_color(handle,0);
   						v_bar(handle,clip);   
                     vsf_interior(handle,0);
                     vsf_color(handle,1);
                     clip[0] = 5;
                     clip[2] = 125;
                     for (i = 0; i < 4; i++)
                        {
                     	clip[1] = wi_couty + 2 + i * 40;
                     	clip[3] = clip[1] + 38;
                     	v_bar(handle,clip);
                     	}
   						vsf_interior(handle,1);
         				vsf_color(handle,1);
         				v_bar (handle,foc);
         			   vsf_color(handle,0);
   						v_bar (handle,fic);
   						i = fic[0] + 19 * xscreenunit + 1;
                     myport -> plane0 = 0;
                  	a_fillrect(i,fic[3]+2,i+xscreenunit-2,fic[3]+screenunit+1);
						   a_fillrect(i,foc[1]+1,i+xscreenunit-2,foc[1]+screenunit-1);
   						v_gtext(handle,10,wi_couty+16,"Number of sets");
         				v_gtext(handle,10,wi_couty+56,"Current set");
         				v_gtext(handle,10,wi_couty+96,"Setname");
                     v_gtext(handle,10,wi_couty+136,"Current level");
        	  	         menu_ienable(menubar,ME_COPY,1);
        	  	         menu_ienable(menubar,ME_CUT,1);
        	  	         menu_ienable(menubar,ME_ERASE,1);
        	  	         menu_ienable(menubar,MF_SAVE,1);
        	  	         menu_ienable(menubar,MF_CLOSE,1);
        	  	         menu_ienable(menubar,MR_UP,1);
        	  	         menu_ienable(menubar,MR_DOWN,1);
        	  	         menu_ienable(menubar,MR_LEFT,1);
        	  	         menu_ienable(menubar,MR_RIGHT,1);
        	  	         menu_ienable(menubar,MO_CSET,1);
        	  	         menu_ienable(menubar,MO_GOTO,1);
        	  	         screensave();
                     v_show_c(handle);
        	  	         }
        	  	      if (maxsetindex >= NRSET-1)
        	  	         { 
        	  	         menu_ienable(menubar,MF_LOAD,0);
        	  	         menu_ienable(menubar,MF_NEW,0);
        	  	         }
        	  	      setindex = maxsetindex;
        	  	      maxsetindex++;
        	  	      yposition(setindex,maxsetindex);
        	  	      xposition(levelindex[setindex]);
        	  	      yslidersize(maxsetindex);
        	  	      plotflag = 1;
        	  	      }
        	  	   }
        	   }
        	if (mgbuf[4] == MF_SAVE)
        	   {
            int item, i;
            sprintf(stlevel,"%d",level[setindex]);
            sprintf(atlevel,"%d",atfields[setindex]);
            i = nrfields[setindex] + level[setindex] - 1;
            sprintf(nrlevel,"%d",i);
            item = dodialog (diasave,DS_FROM);
            deselobjc (diasave,DS_CAN);
            if (item == DS_OK)
               {
               deselobjc (diasave,DS_OK);
               level[setindex] = atoi(stlevel);
               if (level[setindex] < 1) level[setindex] = 1;
               if (level[setindex] > 30) level[setindex] = 30;
               i = atoi(nrlevel) - level[setindex] + 1;
               if (i < 1) i = 1;
               atfields[setindex] = atoi(atlevel);
               if (atfields[setindex] < 1) atfields[setindex] = 1;
               if (atfields[setindex] > 31) atfields[setindex] = 30;
               if (i + atfields[setindex] > 31) i = 31 - atfields[setindex];
               nrfields[setindex] = i;
               strcpy(filename,setname[setindex]);
               j = savefield(set[setindex],atfields[setindex],
                             level[setindex],i);
               if (j)
                  { 
                  changeset[setindex] = 0;
                  strcpy(setname[setindex],filename);
                  plotflag = 1;
                  }
               }   
            }
        	if (mgbuf[4] == MO_GOTO)
        	   {
            int item;
            sprintf(gotolevel,"%d",levelindex[setindex]);
            sprintf(gotoset,"%d",setindex+1);
            item = dodialog (diagoto,DG_LEVEL);
            deselobjc (diagoto,DG_CAN);
            if (item == DG_OK)
               {
               deselobjc (diagoto,DG_OK);
               levelindex[setindex] = atoi(gotolevel);
               if (levelindex[setindex] < 1) levelindex[setindex] = 1;
               if (levelindex[setindex] > 30) levelindex[setindex] = 30;
               setindex = atoi(gotoset) - 1;
               if (setindex < 0) setindex = 0;
               if (setindex >= maxsetindex) setindex = maxsetindex - 1;
               yposition(setindex,maxsetindex);
               xposition(levelindex[setindex]);
               plotflag = 1; 
               }   
            }
          if (mgbuf[4] == MF_CLOSE)
            {
            int item;
            if (changeset[setindex])
               {
       	      item = form_alert (2,
       	      "[3][Set has been changed! | |    Close anyway? ][CANCEL|  OK  ]");
       	      if (item != 2) goto bigloop;
       	      }
       	   menu_ienable(menubar,MF_NEW,1);
       	   menu_ienable(menubar,MF_LOAD,1);
       	   changeset[setindex] = 0;   
       	   if (maxsetindex == 1)
       	      {
       	      maxsetindex = setindex = 0;   
        	  	   menu_ienable(menubar,ME_COPY,0);
        	  	   menu_ienable(menubar,ME_CUT,0);
        	  	   menu_ienable(menubar,ME_ERASE,0);
        	  	   menu_ienable(menubar,ME_PASTE,0);
        	  	   menu_ienable(menubar,ME_AND,0);
        	  	   menu_ienable(menubar,ME_OR,0);
        	  	   menu_ienable(menubar,ME_XOR,0);
        	  	   menu_ienable(menubar,MF_SAVE,0);
        	  	   menu_ienable(menubar,MF_CLOSE,0);
        	  	   menu_ienable(menubar,MR_UP,0);
        	  	   menu_ienable(menubar,MR_DOWN,0);
        	  	   menu_ienable(menubar,MR_LEFT,0);
        	  	   menu_ienable(menubar,MR_RIGHT,0);
        	  	   menu_ienable(menubar,MO_CSET,0);
        	  	   menu_ienable(menubar,MO_PSET,0);
        	  	   menu_ienable(menubar,MO_GOTO,0);
        	  	   wind_close(w_handle);
        	  	   eventmode &=  ~MU_M1 & ~MU_M2;
        	  	   goto bigloop;
        	  	   }
        	  	else
        	  	   {   
       	   	for (i = setindex; i < maxsetindex - 1; i++)
       	   	   {
       	   	   free (set[i]);
       	   	   set[i] = set[i+1];
       	   	   changeset[i] = changeset[i+1];
            	   level[i] = level[i+1];
            	   nrfields[i] = nrfields[i+1];
            	   levelindex[i] = levelindex[i+1];
            	   strcpy(setname[i],setname[i+1]);
            	   }
            	maxsetindex--;
            	setindex--;
            	if (setindex < 0) setindex = 0;
     	  	      xposition(levelindex[setindex]);
            	yposition(setindex,maxsetindex);
            	yslidersize(maxsetindex);
            	plotflag = 1;
            	}  
            }
        	if (mgbuf[4] == MO_SYM)
        	   {
         	WORD item;
         	selobjc(diasym,DY_B1 + symmode);
         	item = dodialog (diasym,0);
         	if (item == DY_OK)
         	   {
         	   deselobjc (diasym,DY_OK);
         	   symmode = whichbutton(diasym,DY_B1,6);
  					}
  				else
  				   {	
	         	deselobjc (diasym,DY_CAN);
	         	deselobjc (diasym,DY_B1+whichbutton(diasym,DY_B1,6));
	         	}
        	   }      
         if (mgbuf[4] == MO_CSET)
            {
            graf_mouse(BUSYBEE,0);
            arcpy(setbuffer,set[setindex],0,30);
            menu_ienable(menubar,MO_PSET,1);
            menu_ienable(menubar,ME_PASTE,0);
            menu_ienable(menubar,ME_AND,0);
            menu_ienable(menubar,ME_OR,0);
            menu_ienable(menubar,ME_XOR,0);
            graf_mouse(ARROW,0);
            }
         if (mgbuf[4] == MO_PSET)
            {
            graf_mouse(BUSYBEE,0);
            arcpy(set[setindex],setbuffer,0,30);
            changeset[setindex] = 1;
            plotflag = 1;
            graf_mouse(ARROW,0);
            }         
        	if (mgbuf[4] == ME_COPY)
        	   {
            copylevel = levelindex[setindex] - 1;
        	   arcpy(setbuffer,set[setindex],copylevel,1);
            menu_ienable(menubar,ME_PASTE,1);
            menu_ienable(menubar,ME_AND,1);
            menu_ienable(menubar,ME_OR,1);
            menu_ienable(menubar,ME_XOR,1);
            menu_ienable(menubar,MO_PSET,0);
        	   }
        	if (mgbuf[4] == ME_ERASE)
        	   {
        	   arclr(set[setindex],levelindex[setindex]-1,1);
       	   plotflag = 1;
       	   changeset[setindex] = 1;
        	   }
        	if (mgbuf[4] == ME_CUT)
        	   {
            menu_ienable(menubar,ME_PASTE,1);
            menu_ienable(menubar,ME_AND,1);
            menu_ienable(menubar,ME_OR,1);
            menu_ienable(menubar,ME_XOR,1);
            menu_ienable(menubar,MO_PSET,0);
        	   copylevel = levelindex[setindex] - 1; 
        	   arcpy(setbuffer,set[setindex],copylevel,1);
        	   arclr(set[setindex],copylevel,1);
        	   plotflag = 1;
        	   }
        	if (mgbuf[4] == ME_EX)
        	   {
        	   if (exflag) 
        	      {
        	      exflag = 0;
        	      menu_icheck(menubar,ME_EX,0);
        	      }
        	   else 
        	      {
        	      exflag = 1;
        	      menu_icheck(menubar,ME_EX,1);
        	      }
        	   }      
        	if (mgbuf[4] == ME_PASTE)
        	   {
        	   mode = 0;
placeit:	   i = copylevel + 1;
        	   if (i > 29) i = 0;
        	   levcpy(setbuffer,i,set[setindex],levelindex[setindex]-1,0);
        	   levcpy(set[setindex],levelindex[setindex]-1,setbuffer,
        	          copylevel,mode);
        	   if (exflag) copylevel = i;       
            changeset[setindex] = 1;          
        	   plotflag = 1;
        	   goto bigloop;
        	   }           
        	if (mgbuf[4] == ME_AND)
        	   {
            mode = 1;
            goto placeit;
        	   }           
        	if (mgbuf[4] == ME_OR)
        	   {
            mode = 2;
            goto placeit;
        	   }
       	if (mgbuf[4] == ME_XOR)
        	   {
        	   mode = 3;
        	   goto placeit;
        	   }    
        	if (mgbuf[4] == MR_RIGHT)
        	   {
        	   mode = 3;
rollit: 	   roll (set[setindex],levelindex[setindex]-1,mode);
        	   plotflag = 1;
            changeset[setindex] = 1;
        	   goto bigloop;
        	   }
         if (mgbuf[4] == MR_LEFT)
            {
            mode = 2;
            goto rollit;
            }
         if (mgbuf[4] == MR_UP)
            {
            mode = 0;
            goto rollit;
            }
         if (mgbuf[4] == MR_DOWN)
            {
            mode = 1;
            goto rollit;
            }	               
        	if (mgbuf[4] == MD_INFO)
        	   {
            i = dodialog (diainfo,0);
            deselobjc (diainfo,DI_OK);
            }
         if (mgbuf[4] == MF_QUIT) 
            {
            int item;
            for (i = 0; i < maxsetindex; i++)
               {
               if (changeset[i] > 0)
                  {
                  item = form_alert (2,
                  "[3][You have made changes| and not saved them.| |   Quit anyway?][CANCEL|OK]");
                  if (item == 1) goto bigloop;
                  else goto end;
                  }
               }   
            goto end;
            }
         }
         
      if (mgbuf[0] == WM_HSLID)
          {
          levelindex[setindex] = 1 + mgbuf[4] * 29 / 1000;
          goto arr8;
          }
      if (mgbuf[0] == WM_VSLID)
          {
          setindex =  mgbuf[4] * (maxsetindex - 1) / 1000;
          goto arr3; 
          }
      if (mgbuf[0] == WM_ARROWED)
          {
          switch (mgbuf[4])  
                   {
          case 0 : goto arr1;
          case 1 : goto arr2;
          case 2 : goto arr1;
          case 3 : goto arr2;
          case 4 : levelindex[setindex] -= 4;
                   goto arr6;
          case 5 : levelindex[setindex] += 4;
                   goto arr7;
          case 6 : goto arr6; 
          case 7 : goto arr7;
                   }
          arr1: setindex--;
                if (setindex < 0) setindex = 0;
                goto arr3;
          arr2: setindex++; 
                if (setindex >= maxsetindex) setindex = maxsetindex - 1;
          arr3: yposition(setindex,maxsetindex);
                goto arr8;
          arr6: levelindex[setindex]--;
                if (levelindex[setindex] < 1) levelindex[setindex] = 1;
                goto arr8;
          arr7: levelindex[setindex]++;
                if (levelindex[setindex] > 30) levelindex[setindex] = 30;
          arr8: xposition(levelindex[setindex]);
                plotflag = 1;
                goto bigloop;
          }         
      }
   goto bigloop;


/* Close the workstation */

end:  
   if (maxsetindex > 0) wind_close(w_handle);
   wind_delete(w_handle);
end2:
   v_clsvwk(handle);

/* Release GEM application */

   appl_exit();

/* and quit */

   _exit(0);

}   /* END MAIN */


arcpy (to, from, level, number)

   FIDAR   to;
   FIDAR   from;
   int     level;
   int     number;

   {
   int i, j, k;
   
   for (i = level; i < level+number; i++)
      {
      for (j = 0; j < 5; j++)
      	{
      	for (k = 0; k < 38; k++)
      	   {
      	   to[i][j][k] = from[i][j][k];
      	   }
      	}
      }
   }   	   

levcpy (to,tolevel,from,fromlevel,mode)

   FIDAR   to;
   FIDAR   from;
   int     tolevel;
   int     fromlevel;
   int     mode;
   
   {
   int j, k;
   
   for (j = 0; j < 5; j++)
      {
      for (k = 0; k < 38; k++)
         {
         if (mode == 0) to[tolevel][j][k] = from[fromlevel][j][k];
         if (mode == 1) to[tolevel][j][k] &= from[fromlevel][j][k];
         if (mode == 2) to[tolevel][j][k] |= from[fromlevel][j][k];
         if (mode == 3) to[tolevel][j][k] ^= from[fromlevel][j][k];
         }
      }
   }   	   
   
arclr (field,level,number)

   FIDAR field;
   int   level,number;
   {
   int i, k;
   
   for (i = level; i < level+number; i++)
      {
     	for (k = 0; k < 38; k++)
      	{
      	field[i][0][k] = 128;
      	field[i][1][k] = 0;
      	field[i][2][k] = 0;
      	field[i][3][k] = 0;
      	field[i][4][k] = 1;   
      	}
      }
   }   	   
   
plotfield (field,index)

   FIDAR    field;
   int      index;

   {
   WORD squ[4];
   int  i, j, k;
   int  xs, ys, xe, ye;
   int  smallunit, xsmallunit; 
   unsigned char testbit;

/* clear field */

   vsf_color(handle,0);
   v_bar (handle,fic);  

   vsf_color(handle,1);
   myport -> plane1 = 1;
   myport -> plane0 = 1;
   myport -> plane2 = 1;
   myport -> plane3 = 1;
   
/* create grid   */

   xs = fic[0];
   xe = fic[2];
   ys = fic[1];
   for (i = 0; i < 38; i++)
      {
      a_hline(xs,xe,ys);
      ys += screenunit;
      }
   xs = fic[0];
   ys = fic[1];
   ye = fic[3];
   for (i = 0; i < 38; i++)
      {
      a_line(xs,ys,xs,ye);
      xs += xscreenunit;
      }
            
/* draw  field   */
            
   smallunit = screenunit - 2;
   xsmallunit = xscreenunit - 2;         
   squ[1] = fic[1] + 1;
   for (i = 0; i < 38; i++)
      {
      squ[3] = squ[1] + smallunit;
      squ[0] = fic[0] + 1;
      for (j = 0; j < 5; j++)
      	{
      	testbit = 128;
      	for (k = 0; k < 8; k++)
      	   {
      	   if ((j > 0 || testbit != 128) && (j < 4 || testbit != 1))
               {
         	   squ[2] = squ[0] + xsmallunit;
      	   	if (field[index][j][i] & testbit)
      	   	   {  
            	   a_fillrect(squ[0],squ[1],squ[2],squ[3]);
            	   }
               squ[0] += xscreenunit;   
            	}   
            testbit >>= 1;   
            }   
         }
      squ[1] += screenunit;
      }
   }      
   
xposition (level)

   WORD level;
	   
   {
   WORD slposx;
   
   slposx = (1000 * (long)(level - 1)) / 29;
   wind_set(w_handle,8,slposx,0,0,0);
   }

yposition (set,maxset)  
 
   WORD set, maxset;
  
   {
   WORD slposy;
   set++;
   if (maxset == 1) slposy = 1;
   else slposy = (1000 * (long)(set - 1)) / (maxset - 1);
   wind_set(w_handle,9,slposy,0,0,0);
   }
  
yslidersize (maxset)
 
   WORD maxset;
   { 
   WORD slsizy;

   slsizy = 1000 / maxset;
   slsizy = (1000 < slsizy) ? 1000 : slsizy;
   wind_set(w_handle,16,slsizy,0,0,0);
   }
   
xslidersize ()
 
   { 
   WORD slsizx;

   slsizx = 1000 / 29;
   wind_set(w_handle,15,slsizx,0,0,0);
   }

plotpoint (field,level,x,y,flag)

   register FIDAR field;
   register int   level; 
   int x, y, flag;
   {
   register int squ[4];
   register int bit, column;
   static int drawon;

   column = (x + 1) / 8;
   bit = 1 << (8 * column + 6 - x);
   vsf_color(handle,1);

   if (flag == 0)
      {
   	if (field[level][column][y] & bit) drawon = 1;
   	   else drawon = 0;
   	}   
   if (drawon)
      {
      field[level][column][y] &= (~bit);
      myport -> plane1 = 0;
      myport -> plane0 = 0;
      myport -> plane2 = 0;
      myport -> plane3 = 0;
      }
   else
      {    	   
      field[level][column][y] |= bit;
      myport -> plane0 = 1;
      myport -> plane1 = 1;
      myport -> plane2 = 1;
      myport -> plane3 = 1;
      }
   squ[0] = fic[0] + 1 + xscreenunit * x;
   squ[1] = fic[1] + 1 + screenunit * y; 
   squ[2] = squ[0] + xscreenunit - 2;
   squ[3] = squ[1] + screenunit - 2;
	a_hidemouse();
 	a_fillrect(squ[0],squ[1],squ[2],squ[3]);
   a_showmouse();
   }

