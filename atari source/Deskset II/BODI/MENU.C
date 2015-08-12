/**************************************************************************/
/*  FILE:  MENU.C		PROGRAM TITLE: DeskSET II Alpha Version   */
/*  Date Created: 01/08/88						  */ 
/*  Last Modified: 06/30/89						  */
/*									  */
/*  Description: MENU ROUTINES						  */
/*  Routines:	o do_view_size()	-  change viewing scale handler   */
/* 		o genesis_region()	-  Create a new region 		  */
/*		o graphic_region()	-  Create Graphic Region	  */
/*		o close_region()	-  Close a regions		  */
/*		o draw_item()		-  Chooses function to draw with  */
/*		o erase_all()		-  Deletes regions		  */
/*		o do_flip_page()	-  Previous and Next Page Handler */
/*		o make_article()	-  Create Article		  */
/*		o close_article()	-  Close Article		  */
/*		o do_hot_link()		-  perform linking of regions	  */
/*		o check_top_window()    -  is preview window on top?	  */
/*		o display_toggle()      -  toggle to show/noshow images   */
/*		o do_artdelete()	-  Delete selected article	  */
/*		o do_artopen()		-  Open selected article for link */
/*		o reopen_region()	-  reopen a region - add primitive*/
/*		o del_prim()		-  delete currect active primitive*/
/*		o router_selected()	-  draw outline arnd active region*/
/*		o post_edit_prim()	-  conclusion of prim edit fnctns */
/*		o outline_primman()	-  Draw outline arnd active prim  */
/**************************************************************************/


/**************************************************************************/
/* INCLUDE FILES							  */
/**************************************************************************/
#include "define.h"
#include "deskset2.h"
#include <obdefs.h>
#include "gemdefs.h"
#include <osbind.h>
#include "alert.h"
#include "dbase.h"

/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/
#define MINSIZE  5000L

/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern int view_size;				/* Current scaling size   */
extern OBJECT *ad_menu;				/* Address of menu tree   */
extern OBJECT *ad_set_size;			/* Address of dialog box  */
extern OBJECT *ad_point_size;			/* address of dialog box  */
extern OBJECT *ad_go_page;			/* Current Page dialog	  */
extern OBJECT *ad_get_image;
extern OBJECT *adoutput;
extern OBJECT *ad_bkgrnd;
extern OBJECT *ad_filebuf;

extern char rscerr2[];
extern char linkerr[];
extern int prev_handle;				/* Preview window handle  */
extern int msg_buff[];				/* evnt multi buffer      */
extern int dummy;				/* well, dummy...	  */
extern int curr_page;				/* current page		  */

extern int ptsarray[];				/* Interface to structures*/

extern int mhandle;				/* Preview buffer handle  */
extern int mxres,myres;
extern int shandle;
extern int phandle;
extern int pxy[];
extern int prev_size;

extern int (*funcs)();				/* drawing function       */
extern int poly_draw();				/* polygon drawing...     */
extern int ellipse_draw();			/* ellipse drawing...     */
extern int circle_draw();			/* circle drawing...      */
extern int box_draw();				/* box drawing...         */
extern int nada();				/* null function	  */
extern char *winfo[][4];			/* preview text info line */

extern GRECT dpwork;				/* work area of window    */
extern GRECT pwork;				/* Preview work area      */

extern int scale_set;				/* User defined scale fact*/
extern GRECT page_area; 			/* GRECT area Preview area*/
extern long getf_article();
extern long get_fpage();
extern long get_npage();
extern long get_fregion();			/* Get first region	  */
extern long get_nregion();			/* Get next region	  */
extern unsigned long region_ptr;		/* Pointer to curr region */
extern unsigned long page_ptr;			/* Ptr to Preview Buffer  */
extern unsigned long pagesc;

extern unsigned long prev_bytes;

extern int SH;					/* Point Size...	  */
extern int mode_change;				/* text/mask changed?     */
extern int zdevice;				/* index into xdpi/ydpi   */

extern long find_region();
extern long create_region();

extern char fbuffer[];
extern int cur_point_size;			/* Current Point Size	  */

extern int graph_flag;
extern int image_status;

extern struct txtattr gltxtattr;		/* Global text attributes */
extern int glgrattr[];				/* Global graphic attrib  */
extern char pathbuf[];
extern int pagew,pageh;
extern int blit_flag;
extern int force_draw_flag;
extern long do_artobj();
extern long get_regart();
extern char *get_lmem();
extern int intout[];
typedef struct dta
{
     	char res[21];
	char attr;
	int  time;
	int  date;
	long fsize;
	char str[14];
} DTA;

extern DTA thedta;
extern char not_found[];
extern char dprint[];
extern long get_curreg();
extern int deferhj;
extern int pxres;
extern int pyres;
extern int alt_offset;
extern int active_prim;
extern int xor_handle;
extern int hpage_size;

extern char *dpath1;
extern char *dpath2;
extern char *dpath3;
extern char *dpath4;

extern long lcalloc();

extern int BSTATE;
extern int BREAL;

extern long prim_ptr;
extern int active_prim;

extern int *icdata;
extern int *primicons;
extern BITBLK *bgicptr;
extern int show_grids;
extern int snap_to_grids;

extern PAGE *tpagehd;
extern PAGE *tcurpage;
extern int  temp_page;
extern PAGE *pagehd;
extern PAGE *curpage;
extern PAGE *left_tmplate;
extern PAGE *right_tmplate;
extern int  displ_tmpl_flag;


extern ARTICLE *rtarthd;
extern ARTICLE *ltarthd;
extern ARTICLE *tarthd;
extern ARTICLE *arthd;

extern int multi_mode;
extern FDB page_MFDB;
extern int unit_type;
extern int TYF_handle;
extern REGION *curregion;
extern FDB laser_MFDB;
extern int pagetype;
extern int vpage_size;
extern long lmalloc();
extern long laser_bytes;

/**************************************************************************/
/* GLOBAL VARIABLES							  */
/**************************************************************************/
char *ruler_mode[] =  {
			"  Show Ruler     ^R",
			"  Hide Ruler     ^R"
		      };


char *mode_text[] = {				/* Menu text for modes    */
			"  Show Text          ^T",
			"  Show Mask          ^T"
		    };


char *write_mode[] = {				/* writing mode...        */
			"  Add Object   ",
			"  Subtract Obj "

                     };

char *template_mode[] = {
			  "  Edit Base Page    ",
			  "  Edit Preview      "
			};

char *disp_tmpl[] = {
		     "  Display Base Page ",     
		     "  Hide Base Page    "
		    };

int tmplate_flag;
int  mode_flag;					/* current fill mode...   */
int  write_flag;				/* current writing mode   */
int  print_flag;				/* Printing to Laser?	  */
int  article_flag;				/* 0 - no article, 1 -    */
						/* then in create article */

int  cur_scale;					/* current scale in %     */


#define linkSIZE 37				/* Link mouse form        */
short mlink[linkSIZE] = 
{
	0x0000,0x0000,0x0001,0x0000,0x0001,
	0x7FE0,0xFFF0,0xFFF0,0xFFF0,0xFFFE,0xFFFF,0xFFFF,0xFFFF,
	0xFFFF,0xFFFF,0xFFFF,0x7FFF,0x0FFF,0x0FFF,0x0FFF,0x07FE,
	0x0000,0x3FC0,0x7FE0,0x6060,0x6060,0x636C,0x676E,0x6666,
	0x6666,0x76E6,0x36C6,0x0606,0x0606,0x07FE,0x03FC,0x0000

};
extern short mlink1[];

int cur_primitive;				/* current primitive   */
						/* according to RCS index */
int cur_pic_type;				/* Neo, IMG, Meta file    */
unsigned long gl_region_ptr;			/* current OPEN/SELECTED  */
						/* pointer to region      */
unsigned long gl_grregion_ptr;
						/* pointer to region      */
int gl_lstyle;					/* Global line attributes */
int gl_lwidth;
int gl_fstyle;					/* Global fill attributes */
int gl_findex;
int gl_repel;
int gl_repbounds;
int gl_repoffset;

int art_append;					/* Append region to article */
						/* or insert in middle if 0 */
long	insert_artptr;				/* Article to insert to     */
long	insert_regptr;				/* Region to insert after   */

int      reopen_prim;				/* flag if reopen_region()  */
long	daveptr;				/* daves's 4800 xxx buffer  */

/**************************************************************************/
/* Function:    do_view_size()						  */
/* Description: Handler for menu to switch scales - Actual size etc..	  */
/*		checks the chosen item.					  */
/*		Institutes a redraw of the preview window.		  */
/* IN:  item  - menu item						  */
/* OUT: none 								  */
/* GLOBAL: page_area  - resets GRECT for the MFDB			  */
/**************************************************************************/
do_view_size(item)
int item;
{
   register int i;
   int prev_item;
   int titem;


      
   prev_item = view_size;
   if(view_size != item)
   {
      view_size = item;
      for(i=PSIZE;i<= PADJCNT;i++)
		 menu_icheck(ad_menu,i,FALSE);
      menu_icheck(ad_menu,item,TRUE);
    
      if((item == PADJCNT) || (prev_size == PADJCNT))
    				recalc_alt_text();
      
      prev_item = item;
      if(view_size != PADJCNT)
 	titem = item;
      else
      {
        titem = ((curr_page % 2) ? (item + 1) : (item));	    
      }

      wind_set(prev_handle,WF_INFO,winfo[titem - PSIZE][unit_type]);
      wind_set(prev_handle,WF_TOP,&dummy,&dummy,&dummy,&dummy);
      page_area.g_x = page_area.g_y = 0L;
      active_prim = 0;	/* reset primitives */

      gsx_moff();
      vsf_interior(shandle,0);			/* Set to Solid   */
      alt_offset = FALSE;
      if( (view_size == PSIZE) ||
	  (view_size == PADJCNT))
		 pdraw_fit(view_size);
      else
		 pdraw_scale();


      prev_size = view_size;
      zoom_setup();
      cur_scale = get_scale_num(view_size);
      get_work(prev_handle);
      update_preview_blit();
      set_clip(TRUE,&pwork);
      vr_recfl(shandle,pxy);
      clear_window(prev_handle,2,1);
      init_rulers();
      graf_mouse(BUSY_BEE,&dummy);
      force_preview();
      slider_chk();
      set_clip(TRUE,&dpwork);
      graf_mouse(ARROW,&dummy);
      gsx_mon();
   }
}




/**************************************************************************/
/* Function: genesis_region()						  */
/* Description: Creates a NEW region					  */
/* 		Disables close region.					  */
/*		enables the drawing primitives.				  */
/**************************************************************************/
genesis_region()
{
     register int i;
     long msize;

     if( (msize = Malloc(-1L)) <= MINSIZE)     
     {
		alert_cntre(ALERT23);
		return;
     }

     menu_ienable(ad_menu,RCREATE,FALSE);
     menu_ienable(ad_menu,ROPENGR,FALSE);
     menu_ienable(ad_menu,RCLOSE,TRUE);
     menu_ienable(ad_menu,RTOGGLE,FALSE);
     menu_ienable(ad_menu,OADDPRIM,FALSE);
     menu_ienable(ad_menu,OPCOORD,FALSE);
     menu_ienable(ad_menu,OMOVEFNT,FALSE);
     menu_ienable(ad_menu,OMOVEBAK,FALSE);
     menu_ienable(ad_menu,ODELPRIM,FALSE);     
     menu_ienable(ad_menu,RCOORD,FALSE);
     menu_ienable(ad_menu,RMOVEFNT,FALSE);
     menu_ienable(ad_menu,RMOVEBAK,FALSE);
     active_prim =FALSE;
     prim_ptr = 0L;      
     
     for(i=OPOLYGON;i<=OBOX;i++)
                 menu_ienable(ad_menu,i,TRUE);
     check_region_ptr();
     gl_region_ptr = create_region(curr_page,FALSE);     
/*     init_tattr();	Remove? This would setup each region with its
			Defaults. Not what is in the font dialog box */
     funcs = &box_draw;
     put_txtattr(gl_region_ptr,&gltxtattr);	 /* and store in region   */
     check_top_window();     
     graf_mouse(OUTLN_CROSS,&dummy);
}




/**************************************************************************/
/* Function: graphic_region()						  */
/* Description: Creates a NEW graphic region				  */
/* 		Disables close region.					  */
/*		enables the drawing primitives.				  */
/**************************************************************************/
graphic_region()
{
     register int i;
     long msize;

     if( (msize = Malloc(-1L)) <= MINSIZE  )     
     {
		alert_cntre(ALERT23);
		return;
     }

     change_icstate(NORMAL,ICBOX1,1);
     menu_ienable(ad_menu,RCREATE,FALSE);
     menu_ienable(ad_menu,ROPENGR,FALSE);
     menu_ienable(ad_menu,RCLOSE,TRUE);
     menu_ienable(ad_menu,RTOGGLE,FALSE);
     menu_ienable(ad_menu,OADDPRIM,FALSE);
     menu_ienable(ad_menu,OPCOORD,FALSE);
     menu_ienable(ad_menu,OMOVEFNT,FALSE);
     menu_ienable(ad_menu,OMOVEBAK,FALSE);
     menu_ienable(ad_menu,ODELPRIM,FALSE);     
     menu_ienable(ad_menu,RCOORD,FALSE);
     menu_ienable(ad_menu,RMOVEFNT,FALSE);
     menu_ienable(ad_menu,RMOVEBAK,FALSE);
     active_prim = FALSE;     
     prim_ptr = 0L;

     for(i=OPOLYGON;i<=OIMAGE;i++)
                 menu_ienable(ad_menu,i,TRUE);

     write_flag = TRUE;
     menu_text(ad_menu,RWRITE,write_mode[write_flag]);
     check_region_ptr();
     gl_grregion_ptr = create_region(curr_page,TRUE);
     graph_flag = TRUE;

     glgrattr[0] = gl_lstyle;
     glgrattr[1] = gl_lwidth;
     glgrattr[2] = gl_fstyle;
     glgrattr[3] = gl_findex;
     glgrattr[4] = gl_repel;
     glgrattr[5] = gl_repoffset;
     glgrattr[6] = gl_repbounds;
     glgrattr[7] = glgrattr[8] = 0;
     put_grattr(gl_grregion_ptr,glgrattr);	 /* and store in region   */
     funcs = &box_draw;
     check_top_window();
     graf_mouse(OUTLN_CROSS,&dummy);
}




/**************************************************************************/
/* Function: close_region()						  */
/* Description: Closes a region						  */
/* IN: none								  */
/* OUT: none								  */
/* GLOBAL:   funcs - current drawing function set to null		  */
/*	     Disables close_region/enables create region		  */
/*	     Disables drawing primitives.				  */
/**************************************************************************/
close_region()
{
   int grtype;
   long tmpreg;
   register int i;
   int x,y;
   int opcode,count,wmode;

   tmpreg = get_curreg(&grtype);

   if(reopen_prim)
   {
	reopen_prim = FALSE;
	page_redraw(tmpreg);
	open_region(tmpreg);
	
   }

   if(grtype)
   {
	gl_grregion_ptr = tmpreg;
	update_repel(1,0L);
        gl_grregion_ptr = 0L;
   }
   if(!mode_flag)	/* Don't enable if we're displaying text */
   	menu_ienable(ad_menu,RCREATE,TRUE);

   menu_ienable(ad_menu,ROPENGR,TRUE);
   menu_ienable(ad_menu,RCLOSE,FALSE);
   menu_ienable(ad_menu,RTOGGLE,TRUE);
   menu_ienable(ad_menu,RWRITE,TRUE);
   menu_ienable(ad_menu,OADDPRIM,FALSE);
   active_prim = FALSE;

   for(i=OPOLYGON;i<=OIMAGE;i++)
                menu_ienable(ad_menu,i,FALSE);     
   funcs = &nada;
   gl_region_ptr = gl_grregion_ptr = region_ptr = 0L;
   if(multi_mode)
   {
      clr_multi_flags(curr_page);
      multi_mode = 0;
   }
   graph_flag = cur_primitive = FALSE;

   if(!article_flag)
   {
     write_flag = 1;
/*      image_status = FALSE;*/
     menu_text(ad_menu,RTOGGLE,mode_text[mode_flag]);
     menu_text(ad_menu,RWRITE,write_mode[write_flag]);
/*     menu_icheck(ad_menu,RDIMAGES,FALSE);*/
     menu_ienable(ad_menu,ACREATE,TRUE);
     graf_mouse(ARROW,&dummy);
   }
   rmenu_fix(0);

   if(bgicptr->bi_pdata == primicons)
   {
	   bgicptr->bi_pdata = icdata;
	   objc_offset(ad_bkgrnd,BGICBOX,&x,&y);
	   ad_bkgrnd[ICBOX6].ob_state = NORMAL;
	   ad_bkgrnd[ICBOX7].ob_state = NORMAL;
	   ad_bkgrnd[ICBOX8].ob_state = NORMAL;
	   clr_bgicons(0);
	   if(mode_flag)
	   {
		change_icstate(DISABLED,ICBOX1,0);
		change_icstate(SELECTED,ICBOX3,0);
	   }
	   if(image_status)
		change_icstate(SELECTED,ICBOX4,0);
	   if(show_grids)
		change_icstate(SELECTED,ICBOX7,0);
	   if(snap_to_grids)
		change_icstate(SELECTED,ICBOX8,0);
	   form_dial(3,0,0,0,0,x,y,
		ad_bkgrnd[BGICBOX].ob_width,
		ad_bkgrnd[BGICBOX].ob_height);
   }
   opcode = get_fprimitive(tmpreg,&count,&wmode);
   if(opcode == -1 || !count)		/* If empty region */
	delete_region(tmpreg);   
}





/**************************************************************************/
/* Function: draw_items()						  */
/* Description: Draws objects into the region				  */
/*		Selects the function to draw with.			  */
/* IN:      item  - menu item selected.					  */
/* GLOBAL:  funcs - function points to function to draw with.		  */
/**************************************************************************/
draw_items(item)
int item;
{
    cur_primitive = item;
    switch(item)
    {
       case OPOLYGON:   funcs = &poly_draw;
			break;
	
       case OCIRCLE:    funcs = &circle_draw;
			break;

       case OELLIPSE:   funcs = &ellipse_draw;
			break;

       case OBOX:	funcs = &box_draw;
			break;

       case OLINE:	funcs = &poly_draw;
			break;

       case ORBOX:      funcs = &box_draw;
			break;

       case OIMAGE:     funcs = &box_draw;
			if(!get_image())
				return;
			break;
    }
    graf_mouse(OUTLN_CROSS,&dummy);
    evnt_button(1,1,0,&dummy,&dummy,&dummy,&dummy);
}








/**************************************************************************/
/* Function: erase_all()						  */
/* Description: Deletes all regions in data structure			  */
/*		Unless the Alert Box button == CANCEL			  */
/*		Deletes all pages 					  */
/*		Deletes all articles					  */
/**************************************************************************/
erase_all(flag)
int flag;		/* Clean up more stuff if not quitting 		 */
{
     int dummy;
     long art;

     if(tmplate_flag && flag)
     {
       pagehd = tpagehd;
       curpage = tcurpage;
       arthd   = tarthd;
       tmplate_flag = FALSE;
       wind_set(prev_handle,WF_NAME,"Preview Window",0,0);
       menu_text(ad_menu,OEDITTMP,template_mode[tmplate_flag]);
       menu_ienable(ad_menu,OERASETP,FALSE);
       menu_ienable(ad_menu,PGOTO,TRUE);
       menu_ienable(ad_menu,PDELETE,TRUE);
       menu_ienable(ad_menu,PINSERT,TRUE);
     }

     clear_tags();
     get_fpage(&dummy);
     while(delete_page());
     art = getf_article();
     while(delete_article());
     if(flag)
     {
        IF_close();
	IF_open(0);			/* Free cache memory */
        gl_grregion_ptr = gl_region_ptr = 0L;
        multi_mode = 0;
        temp_page = curr_page = 1;
        page_area.g_x = page_area.g_y = 0L;
        slider_chk();     
        force_preview();
        do_pagenum(curr_page,(curr_page%2)?1:0);
     }
}




/**************************************************************************/
/* Function:    do_flip_page()						  */
/* Description: Handles Previous and Next Page Menu Calls		  */
/**************************************************************************/
do_flip_page(item)
int item;
{
     register int tmp;
     int titem;
     int flag;

     tmp = curr_page;
     titem = view_size;

     tmp = ((item == PPREV) ? (--tmp) :(++tmp));
     if(tmplate_flag)
     {
       if(tmp < -2) tmp = -2;
       if(tmp > -1) tmp = -1;

       if(tmp == -2)
       {	   
	  curpage = pagehd = left_tmplate;
	  rtarthd = arthd;	/* cjg */	  
	  arthd   = ltarthd;
       }
       else
       {
	  curpage = pagehd = right_tmplate;
	  ltarthd = arthd;	/* cjg */
	  arthd   = rtarthd;
       }
     }
     else
     {
       if(tmp < 0) tmp = 0;
       if(tmp > 999) tmp = 999;
     }
     curr_page = tmp;

     set_int(ad_go_page,GOTOPAGE,curr_page);
     flag = TRUE;

     if(view_size == PADJCNT)
     {
        titem = ((curr_page % 2) ? (titem + 1) : (titem));
        wind_set(prev_handle,WF_INFO,winfo[titem - PSIZE][unit_type]);        

        if(item == PPREV)
	   flag = (( !(curr_page % 2)) ? (FALSE):(TRUE));
        else
	   flag = ((curr_page % 2) ? (FALSE):(TRUE));
     }

     if(flag)     
     {
         mode_change = TRUE;
         force_preview();
     }
     else
	 do_blit();
}


/**************************************************************************/
/* Function:    make_article()						  */
/* Description: Creates Article						  */
/**************************************************************************/
make_article()
{
   long msize;
   int dummy;
   int button;
   int x,y,w,h;
   long num;
 
   if( (msize = Malloc(-1L)) <= MINSIZE)     
   {
		alert_cntre(ALERT23);
		return;
   }

   strcpy(pathbuf,dpath1);
   strcat(pathbuf,"*.TXT");
   if(!get_fs(fbuffer,&dummy))
   {
	graf_mouse(ARROW,&dummy);
	return;
   }
   extender(fbuffer,".TXT");
   Fsetdta(&thedta.res[0]);
   if(Fsfirst(fbuffer,0) <= -1)
   {
/*        if((alert_cntre(ALERT24)==1))*/

	set_int(ad_filebuf,FBUFSIZE,10);

        form_center(ad_filebuf,&x,&y,&w,&h);
        form_dial(0,0,0,36,36,x,y,w,h);
        objc_draw(ad_filebuf,0,MAX_DEPTH,x,y,w,h);
   err:
        button = form_do(ad_filebuf,FBUFSIZE);
        ad_filebuf[button].ob_state = NORMAL;
        if(button == FBUFOK)
        {
	   num = get_int(ad_filebuf,FBUFSIZE);
	   if(num < 10)
           {
                objc_draw(ad_filebuf,FBUFOK,MAX_DEPTH,x,y,w,h);
		goto err;
           }
           form_dial(3,0,0,3,36,x,y,w,h);	
	   num *= 1024L;
           if( (msize = Malloc(-1L)) <= num)     
           {
		alert_cntre(ALERT23);
	        graf_mouse(ARROW,&dummy);    /* Abort	*/
		return;
           }
	   ed_new_article(num);		/* Create new file with editor */
        }
	else
	{
	   graf_mouse(ARROW,&dummy);    /* Abort	*/
	   form_dial(3,0,0,3,36,x,y,w,h);
	   return;
	}
   }
   else
	loadfile(fbuffer);
   amenu_fix(1);
   graf_mouse(2,&dummy);
   create_article();
   remove_path(fbuffer);
   update_article(fbuffer);
   graf_mouse(ARROW,&dummy);
   art_append = TRUE;
   menu_ienable(ad_menu,ASAVEART,FALSE);
   menu_ienable(ad_menu,AAUTOFL,TRUE);
   menu_ienable(ad_menu,ACLOSE,TRUE);
   menu_ienable(ad_menu,ACREATE,FALSE);
   menu_ienable(ad_menu,OADDPRIM,FALSE);
   graf_mouse(255,mlink);
   article_flag = TRUE;
   check_top_window();
}



/**********************************************************************/
/* Function: ed_new_article()					      */
/* Description: Setup buffers to edit a new article		      */
/**********************************************************************/
ed_new_article(msize)
long msize;
{
   long chbuff;

   if(chbuff = lcalloc(1L,msize))	/* Allocate initial buffer */
   {
     init_buffer(chbuff,chbuff+msize);
     set_buffer(0L);
     return(1);
   }
   return(0);
}


/**************************************************************************/
/* Function:    close_article()						  */
/* Description: Closes Article						  */
/**************************************************************************/
close_article()
{
   menu_ienable(ad_menu,ASAVEART,TRUE);
   menu_ienable(ad_menu,AAUTOFL,FALSE);
   menu_ienable(ad_menu,ACREATE,TRUE);
   menu_ienable(ad_menu,ACLOSE,FALSE);
   graf_mouse(2,&dummy);
   if(tmplate_flag)
   {
     if(curr_page == -2)
	ltarthd = arthd;
     else
	rtarthd = arthd;
   }

   article_flag = FALSE;
   do_update_text();
   if(mode_flag)
	force_preview();
   graf_mouse(0,&dummy);
   amenu_fix(0);
   region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
}




/**************************************************************************/
/* Function:    do_hot_link()						  */
/* Description: Link regions togethor for articles			  */
/**************************************************************************/
do_hot_link(mx,my)
int mx,my;
{
   int nmx,nmy;
   int g_flag;
   int tpage;
   int dummy;

   tpage = curr_page;
   scrntomu(mx,my,&nmx,&nmy,0);
   if(view_size == PADJCNT)
   {
	if(alt_offset)
	{
	     if(!(curr_page % 2))
			curr_page++;
        }
	else
	{
  	     if( curr_page % 2)
			curr_page--;
	}
   }

   region_ptr = find_region(nmx,nmy,curr_page,
		&dummy,&dummy,&dummy,&dummy,&g_flag);
   if(region_ptr)
   {
     if(get_regart(region_ptr))
     {
	alert_cntre(ALERT5);
	return;
     }
     if((region_ptr != 0x0L) && !g_flag)
     {
	if(art_append)
	   add_to_article(region_ptr);
	else
	   insert_to_article(insert_artptr,insert_regptr,region_ptr);
	if(mode_flag)
	{
	   mlink1[3] = 0;
	   mlink1[4] = 1;
	}
	else
	{
	   mlink1[3] = 1;
	   mlink1[4] = 0;
	}
   	graf_mouse(255,mlink1);
     }
   }
   curr_page = tpage;
   
   graf_mkstate(&nmx,&nmy,&dummy,&dummy);
   evnt_mouse(1,nmx - 4,nmy - 4,8,8,&dummy,&dummy,&dummy,&dummy);
   graf_mouse(255,mlink);
   BSTATE = 0;
}




/**************************************************************************/
/* Function:    check_top_window					  */
/* Description: checks if preview window is on top, and forces it to be   */
/**************************************************************************/
check_top_window()
{
   int thandle;

     wind_get(0,WF_TOP,&thandle,&dummy,&dummy,&dummy);
     if(thandle != prev_handle)
           wind_set(prev_handle,WF_TOP,0,0,0,0);
}



/**************************************************************************/
/* Function:    display_toggle()					  */
/* Description: 							  */
/**************************************************************************/
display_toggle()
{
	int x,y;

        menu_ienable(ad_menu,RCREATE,mode_flag);
	menu_ienable(ad_menu,RWRITE,mode_flag);
	menu_ienable(ad_menu,ADEFER,mode_flag);
	mode_flag ^= TRUE;
	if(mode_flag && deferhj)
	{
	   deferhj = 0;
	   menu_icheck(ad_menu,ADEFER,0);
	   recalc_txtptrs();
	}
	if(mode_flag)
	{
	    ad_bkgrnd[ICBOX1].ob_state = DISABLED;
	    menu_ienable(ad_menu,OADDPRIM,FALSE);
	}
	else
	{
	    ad_bkgrnd[ICBOX1].ob_state = NORMAL;
	}
	objc_offset(ad_bkgrnd,ICBOX1,&x,&y);
	form_dial(3,0,0,0,0,x,y,
			ad_bkgrnd[ICBOX1].ob_width,
			2*ad_bkgrnd[ICBOX1].ob_height);

	menu_text(ad_menu,RTOGGLE,mode_text[mode_flag]);
	mode_change = TRUE;
        force_preview();
/*	send_redraw(prev_handle);*/
}



/**************************************************************************/
/* Function:    do_artdelete()						  */
/* Description:  Delete the selected article.				  */
/**************************************************************************/	

do_artdelete()
{
long artptr;

   artptr = do_artobj();
   if(artptr)
   {
	open_article(artptr);
	delete_article();
	force_draw_flag = 1;
	force_preview();
   }
}



/**************************************************************************/
/* Function:    do_artopen()						  */
/* Description:  Open the selected article and link regions to it.	  */
/**************************************************************************/
do_artopen()
{
int dolink;
long artptr;
   
   dolink = 0;
   if(gl_region_ptr)
   {
	if((insert_artptr = get_regart(gl_region_ptr)))
	{
  	   open_article(insert_artptr);
	   insert_regptr = gl_region_ptr;
	   art_append = FALSE;
	   dolink = TRUE;
   	}
   }
   else
   {
	artptr = do_artobj();
	if(artptr)
	{
	   open_article(artptr);
	   dolink = TRUE;
	   art_append = TRUE;
	}
   }
   if(dolink)
   {
       amenu_fix(1);
       menu_ienable(ad_menu,ASAVEART,FALSE);
       menu_ienable(ad_menu,ACLOSE,TRUE);
       menu_ienable(ad_menu,ACREATE,FALSE);
       graf_mouse(255,mlink);
       article_flag = TRUE;
   }
}

do_saveart()
{
long artptr;

   artptr = do_artobj();
   if(artptr)
   {
	save_article(artptr);
   }
}




/**************************************************************************/
/* 	Handle autoflow of regions into the article			  */
/**************************************************************************/
do_autoflow()
{
int minpage,maxpage;
int page;
register long pptr,rptr;
int gflag;
int x;

   if(!get_range(&minpage,&maxpage))
	return;
   pptr = get_fpage(&page);
   if(!pptr)
	return;
   while(pptr)
   {
	if(page >= minpage && page <= maxpage)
	{
	   rptr = get_fregion(page,&x,&x,&x,&x,&gflag);
    	   while(rptr)
	   {
	 	if((!get_regart(rptr)) && (!gflag))
		{
    		   add_to_article(rptr);
		}
	        rptr = get_nregion(&x,&x,&x,&x,&gflag);
	   }
 	}
        pptr = get_npage(&page);
   }
   close_article();
}


/**************************************************************************/
/*  Function: reopen_region()						  */
/*  Description: opens an existing region for adding more primitives	  */
/**************************************************************************/
reopen_region()
{
    int type;
    register int i;
    int j;
    unsigned long tregion;

    tregion = get_curreg(&type);
    menu_ienable(ad_menu,RCLOSE,TRUE);
    menu_ienable(ad_menu,RCREATE,FALSE);
    menu_ienable(ad_menu,OADDPRIM,FALSE);
    menu_ienable(ad_menu,RTOGGLE,FALSE);
    menu_ienable(ad_menu,ROPENGR,FALSE);
    write_flag = TRUE;

    menu_text(ad_menu,RWRITE,write_mode[write_flag]);

    if(type)
    {
	graph_flag = TRUE;
        j = OIMAGE;
    }
    else
	j = OBOX;
    for(i=OPOLYGON;i<=j;i++)
		menu_ienable(ad_menu,i,TRUE);
    check_top_window();
    reopen_prim = TRUE;
    funcs = &box_draw;
    graf_mouse(OUTLN_CROSS,&dummy);
}





/**************************************************************************/
/*  Function: del_prim()						  */
/*  Description: Delete the current active primitive			  */
/**************************************************************************/
del_prim()
{
     unsigned long tregion;
     int oldrect[4];
     int dummy;
     REGION *tptr;
     int type;

     if(!region_ptr)			/* Well, if no active region...*/
     {					/* how can we have an active   */
	  clear_regprim_flags();	/* primitive?...:-)	       */
	  return;
     }

     if((alert_cntre(ALERT40) == 1))
     {
       find_boundary(region_ptr,&oldrect[0],&oldrect[1],&oldrect[2],
			&oldrect[3],&type,&dummy);
       delete_primitive();
       menu_ienable(ad_menu,ODELPRIM,FALSE);
       menu_ienable(ad_menu,OPCOORD,FALSE);
       menu_ienable(ad_menu,OMOVEFNT,FALSE);
       menu_ienable(ad_menu,OMOVEBAK,FALSE);
       active_prim = FALSE;
       tptr = tregion = region_ptr;
       open_region(tregion);
       recalc_region();
       if(tptr->primlist == 0L)	/* if last primitive, delete region also */
       {
	  tregion = 0L;
	  do_delregion();
	  clear_regprim_flags();
	  return;
       }
       
       if(!type)
       {		
	   page_redraw(region_ptr);
           redraw_area(region_ptr,oldrect,1);   /* Cleanup old area */		
       }
       else
         update_repel(1,oldrect);

   
       region_ptr = tregion;
       if(region_ptr)
       		router_selected();
    }
}



/**************************************************************************/
/* Function: router_selected()						  */
/* Description: Draws outline on current active region			  */
/**************************************************************************/
router_selected()
{
     int page;
     int minx,miny,maxx,maxy;
     int type;

     find_boundary(region_ptr,&minx,&miny,&maxx,&maxy,&type,&page);
     outline_primman(minx,miny,maxx,maxy,type,page);
}





/**************************************************************************/
/* Function: post_edit_prim()						  */
/* Description: Conclusion of prim editing functions			  */
/**************************************************************************/
post_edit_prim(opcode,pcount,wmode,prim_ptr)
int opcode;
int pcount;
int wmode;
long prim_ptr;
{
     unsigned long tregion_ptr;
     int mx,my,mbutton;
     int minx,miny,maxx,maxy;
     int type;
     int page;
     int oldrect[4];
     int dummy;

     find_boundary(region_ptr,&oldrect[0],&oldrect[1],&oldrect[2],
			&oldrect[3],&dummy,&dummy);
     update_primitive(opcode,pcount,wmode,0);
     recalc_region();

     tregion_ptr = region_ptr;
     graf_mkstate(&mx,&my,&mbutton,&dummy);
     if(gl_region_ptr)
     {
        if(view_size != PADJCNT)
	{
           tregion_ptr = region_ptr;
           redraw_area(region_ptr,oldrect,1);   /* Cleanup old area */		
	   region_ptr = gl_region_ptr = tregion_ptr;		
	}
	page_redraw(gl_region_ptr);
	gl_region_ptr = tregion_ptr;
     }
     else
     {
        update_repel(1,oldrect);
	gl_grregion_ptr = tregion_ptr;
     }
     region_ptr = tregion_ptr;
     active_prim = TRUE;
     open_region(region_ptr);
     set_cur_prim(prim_ptr);
     calc_prim(opcode,&minx,&miny,&maxx,&maxy,pcount);
     find_page(region_ptr,&page);
     region_ptr = get_curreg(&type);
     outline_primman(minx,miny,maxx,maxy,type,page);
}




/**************************************************************************/
/* Function: outline_primman()						  */
/* Description: Draws outline arnd active primitive			  */
/*		Works in unison with post_edit_prim()			  */
/**************************************************************************/
outline_primman(minx,miny,maxx,maxy,type,page)
int minx,miny,maxx,maxy;
int type,page;
{
     if(type)
	gl_grregion_ptr = region_ptr;
     else
	gl_region_ptr = region_ptr;

     if((page % 2) && (view_size == PADJCNT))
     {
	alt_offset = TRUE;
	minx += hpage_size;
	maxx += hpage_size;
     }
     mutoscrn(minx,miny,&pxy[0],&pxy[1],0);
     mutoscrn(maxx,maxy,&pxy[2],&pxy[3],0);
     gsx_moff();
     do_outline(xor_handle,pxy);
     gsx_mon();
}



region_front()
{

   if(!region_ptr)			/* if none selected, return */
   {
      clear_regprim_flags();   
      return;			/* Just in case  	    */
   }
   do_reg_front(region_ptr);
   redr_regarea(region_ptr,1);
   clear_regprim_flags();   
}




region_back()
{
   if(!region_ptr)			/* if none selected, return */
   {
      clear_regprim_flags();
      return;			/* Just in case  	    */
   }
   do_reg_back(region_ptr);   
   redr_regarea(region_ptr,1);
   clear_regprim_flags();
}




prim_front()
{
   unsigned long pptr;
   int wrmode;
   int count;


   if(!region_ptr)			/* if none selected, return */
   {
      clear_regprim_flags();
      return;			/* Just in case  	    */
   }
   get_cur_prim(&count,&wrmode,&pptr);
   if(!pptr)
   {
       clear_regprim_flags();   
       return;
   }
   do_prim_front(pptr);
   redr_regarea(region_ptr,1);
   clear_regprim_flags();
}



prim_back()
{
   unsigned long pptr;
   int wrmode;
   int count;


   if(!region_ptr)			/* if none selected, return */
   {
      clear_regprim_flags();
      return;			/* Just in case  	    */
   }
   get_cur_prim(&count,&wrmode,&pptr);
   if(!pptr)
   {
        clear_regprim_flags();   
	return;
   }
   do_prim_back(pptr);
   redr_regarea(region_ptr,1);
   clear_regprim_flags();
}




clear_regprim_flags()
{
   curregion = prim_ptr = gl_grregion_ptr = gl_region_ptr = region_ptr = 0L;
   if(multi_mode)
   {
      clr_multi_flags(curr_page);
      multi_mode = 0;
   }
   active_prim = FALSE;
   
   menu_ienable(ad_menu,OADDPRIM,FALSE);
   menu_ienable(ad_menu,ODELPRIM,FALSE);
   menu_ienable(ad_menu,OPCOORD,FALSE);
   menu_ienable(ad_menu,OMOVEFNT,FALSE);
   menu_ienable(ad_menu,OMOVEBAK,FALSE);

   menu_ienable(ad_menu,RUNLINK,FALSE);
   menu_ienable(ad_menu,RDELETE,FALSE);
   menu_ienable(ad_menu,RCOORD,FALSE);
   menu_ienable(ad_menu,RMOVEFNT,FALSE);
   menu_ienable(ad_menu,RMOVEBAK,FALSE);
}


recalc_alt_text()
{
   PAGE    *rpagehd;
   PAGE    *rcurpage;
   int     rcurr_page;
   ARTICLE *rarthd;

   recalc_txtptrs();		/* recalc current page */

   rpagehd    = pagehd;		/* save the settings   */
   rcurpage   = curpage;
   rcurr_page = curr_page;
   rarthd     = arthd;

   if(tmplate_flag)		/* take care of preview window */
   {				/* and other tmplate page      */
      arthd = ((curr_page % 2)?(ltarthd):(rtarthd));
      pagehd = curpage = ((curr_page%2)?(left_tmplate):(right_tmplate));
      curr_page = pagehd->pagenum;
      recalc_txtptrs();

      arthd = tarthd;		/* recalc preview text */
      pagehd = tpagehd;
      curpage = tcurpage;
      curr_page = temp_page;
      recalc_txtptrs();
   }
   else				/* recalc left and right tmplates*/
   {
      arthd = ltarthd;
      pagehd = curpage = left_tmplate;
      curr_page = pagehd->pagenum;
      recalc_txtptrs();		/* recalc left tmplate page */      

      arthd = rtarthd;		/* and recalc right tmplate */
      pagehd = curpage = right_tmplate;
      curr_page = pagehd->pagenum;
      recalc_txtptrs();
   }
   pagehd    = rpagehd;			/* restore previous settings */
   curpage   = rcurpage;
   curr_page = rcurr_page;
   arthd     = rarthd;
}



/**************************************************************************/
/* Function: output_doc()						  */
/* Description: kicks out a file to either the printer or a TDO file...   */
/**************************************************************************/
output_doc()
{
    int pagenum;
    int button;
    int copies;
    int lastpage;
    int firstp;
    int lastp;
    int firstpage;

    PAGE *rpagehd;
    PAGE *rcurpage;
    int  rtemp_page;
    int  tdisp_flag;
    int  rtmplate_flag;
    int  timage_status;
    ARTICLE *rarthd;

    long freemem;
    int mem_needed;
    int device;
    int tview;

    int dxres,dyres;
    long *landptr,*landesc;
    int pxy[4];
    long membytes;

    rtmplate_flag = tmplate_flag;
    rtemp_page = curr_page;
    timage_status = image_status;
    image_status = TRUE;

    if(tmplate_flag)
    {
      rpagehd = pagehd;
      rcurpage = curpage;
      rarthd   = arthd;

      pagehd = tpagehd;
      curpage = tcurpage;
      arthd   = tarthd;

      tmplate_flag = FALSE;
    }


    tdisp_flag = displ_tmpl_flag;
    displ_tmpl_flag = TRUE;

    graf_mouse(ARROW,&dummy);
    mem_needed = 0;
    device = OTDO;

    if(get_fpage(&pagenum))
    {
        set_int(adoutput,OFROMPAG,pagenum);
        firstpage = pagenum;
        do
        {
            lastpage = pagenum;
        }while(get_npage(&pagenum));

        set_int(adoutput,OTOPAGE,lastpage);
        set_int(adoutput,OCOPIES,1);
        adoutput[OPRINTER].ob_state = SELECTED;
	adoutput[OTDO].ob_state = NORMAL;
        button = execform(adoutput,OCOPIES);
        graf_mouse(BUSY_BEE,&dummy);			/* busy bee     */
        adoutput[button].ob_state = NORMAL;		/* reset button */


        if(button == OPRINT)
        {
	   copies = get_int(adoutput,OCOPIES);
	   firstp = max(get_int(adoutput,OFROMPAG),firstpage);
	   lastp = min(get_int(adoutput,OTOPAGE),lastpage);
	   if(lastp < firstp)
			lastp = 9999;
	   
	   if(deferhj)			/* if H&J deferred, recalc text)*/
	   {
		menu_icheck(ad_menu,ADEFER,0);
		deferhj = 0;
 	        tview = view_size;
		view_size = PACTUAL;
		recalc_alt_text();
     	        view_size = tview;				
           }
	   if(!deferhj && view_size == PADJCNT)
           {
		   tview = view_size;
		   view_size = PACTUAL;
		   recalc_alt_text();
		   view_size = tview;				
           }
	   
		   
           if(adoutput[OPRINTER].ob_state == SELECTED)
           {
	       device = OPRINTER;
               freemem = Malloc(-1L);
               if(freemem < 1230000L)
               {
		  mem_needed = 1;
		  Mfree(page_ptr);		/* Free page buffer  */
    	       }

		 if(pagetype > PLEGAL)
		 {
                   mutolas(hpage_size,vpage_size,&dxres,&dyres);
		   membytes = (long)(((((long)dxres + 15L)/16L)*16L)*((((long)dyres + 15L)/16L) * 16L));
		   membytes /= 8L;
		   membytes += 1;
		   membytes &= 0xFFFFFFFEL;
   		   landptr = landesc = Malloc(membytes);
		   daveptr = Malloc(20000L);
  		   if(!landptr || !daveptr)
		   {
			alert_cntre(ALERT3);
			goto leave;
  		   }
   		   GDvq_extnd(mhandle,0,intout,dxres,dyres,&landesc);
		   dxres -= 1;
		   dyres -= 1;
		 }
		 else
		 {
		   landptr = 0L;
		   dxres = dyres = 0;
		 }
	
    	         if(!laser_open(landptr,dyres,dxres))
		 {
			switch(intout[0])
			{
			   case 1:  /* No Printer Attached */
				    alert_cntre(ALERT41);
				    break;

			   case 2:  /* Not Enough Memory   */
				    alert_cntre(ALERT42);
				    break;

			   case 3:  /* Wrong Paper Size with Landscape */
				    alert_cntre(ALERT43);
				    break;

			   default: /* Catch All Phrase...*/
	    			    alert_cntre(ALERT3);
				    break;
			}
                 }
	         else
                 {
		    if(pagetype > PLEGAL)
		    {
 	                mutolas(hpage_size,vpage_size,&dxres,&dyres);
	   		GDvq_extnd(mhandle,0,intout,dxres,dyres,&landesc);
			laser_MFDB.fd_w = dxres;
			laser_MFDB.fd_h = dyres;
			laser_MFDB.fd_wdwidth = (dxres + 15)/16;
			laser_bytes = membytes;
	   		pxy[0] = pxy[1] = 0;
        	        pxy[2] = dxres-1;
           	        pxy[3] = dyres-1;
           	        vs_clip(mhandle,1,pxy);
		    }
		    laser_out(firstp,lastpage,mem_needed,copies,lastp);
		    laser_close();
		    IF_close();			/* clear the font cache*/
		    IF_open(0);
                 }

leave:	      
               print_flag = FALSE;    
	       if(pagetype > PLEGAL)
	       {
		    if(landesc)
			Mfree(landesc);		   
		    if(daveptr)
			Mfree(daveptr);
		    landesc = daveptr = 0L;
	       }

              if(mem_needed)
               {
                  page_ptr = pagesc = (unsigned long) Malloc(prev_bytes);
                  page_MFDB.fd_addr = page_ptr;
	          GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);
       	       }
	       if((pagetype > PLEGAL) && !mem_needed) /* reset ptrs...*/
	             GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);	
	       mclip();
	      

           }  
           else 				/* TDO		*/
           {
             device = OTDO;
    	     force_blit_redraw(0);
	     tdo_out(firstp,lastpage,lastp,copies);
           }

       }				  /* End of Ok BUTTON TO PRINT */

    }   		/* end of no pages to print in the first place */

    tmplate_flag = rtmplate_flag;
    curr_page = rtemp_page;
    image_status = timage_status;
    if(tmplate_flag)
    {
      pagehd = rpagehd;
      curpage = rcurpage;
      arthd   = rarthd;
    }
    if(device == OPRINTER)
    {

       if(view_size == PADJCNT)
		recalc_alt_text();
    }
    displ_tmpl_flag = tdisp_flag;
/*    if(mem_needed) */
	force_preview(); /* After printing, the slave is gone...      */
			 /* and we'll have to recreate the slave then */
    graf_mouse(ARROW,&dummy);
}




laser_out(firstp,lastpage,mem_needed,copies,lastp)
int firstp;
int lastpage;
int mem_needed;
int copies;
int lastp;
{
    int event;
    int key;
    int pagenum;
    int pxy[4];
    int dummy;
    int tmp_buff[8];
    int rmu[4];
    int gflag;
    long rptr;
    int  dxres,dyres;
   
    if(copies > 1)
	v_pgcount(phandle,--copies);

    if(phandle)
         init_text(phandle);
    print_flag = TRUE;
    
    force_blit_redraw(mem_needed);  /* SLM 804      */
    if(pagetype > PLEGAL)
    {
       mutolas(hpage_size,vpage_size,&dxres,&dyres);
       pxy[0] = pxy[1] = 0;
       pxy[2] = dxres-1;
       pxy[3] = dyres-1;
       vs_clip(mhandle,1,pxy);
    }
    
    if((get_fpage(&pagenum)) && (firstp <= lastpage) )
    {
	while(pagenum < firstp)
		get_npage(&pagenum);
        do
        {
           graf_mouse(BUSY_BEE,&dummy);			/* busy bee     */

	   if(view_size == PADJCNT)
	   {
	     if(pagenum % 2)
	     {
               rptr = get_fregion(pagenum,&rmu[0],&rmu[1],&rmu[2],&rmu[3],&gflag);
	       while(rptr)
	       {
		  if(!gflag)
		    free_regslv(rptr);
		  rptr = get_nregion(&rmu[0],&rmu[1],&rmu[2],&rmu[3],&gflag);
	       }
	     }
 	   }

	   curr_page = pagenum;
	   redraw_laser(pagenum);
           pxy[2] = pxres;
           pxy[3] = pyres;
           pxy[0] = pxy[1] = 0;
	   vs_clip(phandle,1,pxy);

           rptr = get_fregion(pagenum,&rmu[0],&rmu[1],&rmu[2],&rmu[3],&gflag);
	   while(rptr)
	   {
		if(!gflag)
		    free_regslv(rptr);
		rptr = get_nregion(&rmu[0],&rmu[1],&rmu[2],&rmu[3],&gflag);
	   }
	   event = evnt_multi((MU_KEYBD|MU_TIMER),
		         0,0,0,
		         0,0,0,0,0,
		         0,0,0,0,0,
		         tmp_buff,
		         0,0,		/* timer == 0 */
		         &dummy,&dummy,
		         &dummy,&dummy,
		         &key,&dummy);

	   if(event != MU_TIMER)
		      break;

        }while((get_npage(&pagenum)) && (pagenum <= lastp));
    }
}




tdo_out(firstp,lastpage,lastp,copies)
int firstp;
int lastpage;
int lastp;
int copies;
{

    int dummy;
    int pagenum;
    int count;
    int i;

    strcpy(pathbuf,dpath4);
    strcat(pathbuf,"*.TYF");
    if(!get_fs(fbuffer,&dummy))
	return;
    extender(fbuffer,".TYF");
    Fsetdta(&thedta.res[0]);
    if(Fsfirst(fbuffer,0)==0)
    {
	if(alert_cntre(ALERT37)==2)
        {
	   return;
        }
    }
    if((TYF_handle=Fcreate(fbuffer,0)) <= 0)
    {
	alert_cntre(ALERT19);
        return;
    }
    
    Start_TYF();	

    if((get_fpage(&pagenum)) && (firstp <= lastpage))
    {
	while(pagenum < firstp)
		get_npage(&pagenum);
	if(copies == 0) copies = 1;
        count = copies;
	do
        {
	     curr_page = pagenum;
	     for(i=1;i<=count;i++)
	     		redraw_tdo(pagenum,lastp);
        }while((get_npage(&pagenum)) && (pagenum <= lastp));
    }
    End_TYF();
    Fclose(TYF_handle);

}


