/**********************************************************************/
/* FILE: FILE.C							      */
/* DESCRIPTION: FILE I/O Routines				      */
/* CREATED:   							      */
/* LAST MODIFIED:   02/06/89					      */
/*								      */
/*		loadfile() 	- loads a file			      */
/*		instring()	- Searches a string for a character   */
/*		get_fs()	- Handle File Selector dialog box     */
/* 		save_doc()	- Save a document to disk	      */
/*		write_regions() - Write regions to disk		      */
/*		write_attrs()	- Write attributes to disk	      */
/*		write_prims()	- Write primitives to disk	      */
/*		write_articles()- Write articles to disk	      */
/*		write_pages()   - Write pages to disk		      */
/*		atbl_setup()	- Article table setup		      */
/*		rtble_setup()	- Region table setup		      */
/*		dread()		- Read characters from input buffer   */
/*		dwrite()	- Write characters to file	      */
/*		ddump()		- Write out file buffer to disk	      */
/*		load_doc()	- Load document from disk	      */
/*		load_arts()	- Load articles from disk	      */
/*		getrptr()	- Get region pointer from rtable      */
/*		fixup_rptrs()	- Fixup region ptrs after loading     */
/*		aindex_to_ptr() - Return article index pointer        */
/*		read_regions()  - Read regions from disk	      */
/*		read_prims()    - Read primitives from disk	      */
/*		read_pages()	- Read pages from disk		      */
/*		read_articles() - Read articles from disk	      */
/*		getaindex()	- Get article index		      */
/*		getrindex()	- Get region index 		      */
/*		save_clipb()	- Save clipboard to disk	      */
/*		load_clipb()	- Load clipboard from disk	      */
/*		extender()	- Handle file name extenders	      */
/**********************************************************************/

/**************************************************************************/
/* HISTORY								  */
/*									  */
/* 11/06/89  -   Added code to handle GOG.DFT file.			  */
/*	     -   new variables : char GOGbuff[50];			  */
/*				 char *GOGptr;				  */
/*				 char GOGindex;				  */
/*		 new routines:   read_GOG()				  */
/*		 		 GOGgetstr()				  */
/*				 write_GOG()				  */
/*				 GOGputstr()				  */
/*				 GOGputcr()				  */
/*		 The GOG.DFT file is read in at runtime in initsys()	  */
/*		 The file GOG.DFT is written out in do_pwrup()		  */
/*		 The file format is - DRESS FILE NAME			  */
/*				      DICTIONARY NAME			  */
/*				      KEYBOARD LAYOUT NAME		  */
/**************************************************************************/

#include "osbind.h"
#include "dbase.h"
#include "gemdefs.h"
#include "alert.h"
#include "deskset2.h"
#include <obdefs.h>

/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/
#define NOMEMORY	1
#define NODATA		2
#define NOFILE		3

#define DOCSIZE		5000L


/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern long lcalloc();
extern long lmalloc();
extern long calloc();
extern PAGE *get_fpage();
extern PAGE *get_npage();
extern REGION *get_fregion();
extern REGION *get_nregion();
extern ARTICLE *getf_article();
extern ARTICLE *getn_article();
extern unsigned char *buf_start;
extern unsigned char *buf_end;
extern unsigned char *free_start;
extern unsigned char *current_char;

extern int force_draw_flag;
extern int curr_page;

extern PAGE *pagehd;
extern PAGE *clippage;

extern ARTICLE *arthd;

extern int ptsarray[];

extern int clipfull;
extern unsigned char *get_lcmem();
extern char *dpath1;
extern char *dpath2;
extern char *dpath3;
extern char *dpath4;
extern ARTICLE *curart;

extern int hpage_size;
extern int vpage_size;
extern int pagemux[];
extern int pagemuy[];
extern int pagetype;
extern int shandle;
extern int view_size;
extern int pxy[];
extern int cur_scale;
extern GRECT pwork;
extern GRECT page_area;
extern int prev_handle;


extern PAGE *tpagehd;
extern PAGE *tcurpage;
extern int temp_page;
extern PAGE *curpage;
extern PAGE *right_tmplate;
extern PAGE *left_tmplate;
extern int dummy;
extern int tmplate_flag;

extern PNUMBER pnum;

extern ARTICLE *rtarthd;
extern ARTICLE *ltarthd;

extern int pstorage[];
extern char pnumtext[];

extern int active_prim;
extern int scan_xres;
extern int scan_yres;
extern OBJECT *ad_menu;

extern char *winfo[][4];
extern int unit_type;

/**************************************************************************/
/* GLOBAL VARIABLES						      	  */
/**************************************************************************/
typedef struct dta
	{
	char	res[21];
	char	attr;
	int	time;
	int	date;
	long	fsize;
	char	str[14];
	}DTA;

DTA	thedta;

long    chbuff;
int	fhandle;
long	bytes_in;
char	*textptr;
char	*endptr;
char	*tmpptr;
char 	fbuffer[100];
char	pathbuf[50];
char    fname[20];
char	*docbuf;
char	*docend;
char	*docptr;

long	*atable;
long	*rtable;

unsigned int gl_rcount;
long   bufpath;
int    pbufindex;
char *pbuff;


long   *tatable;
long   *trtable;
ARTICLE *tarthd;
int tcurr_page;


int rtmplate_flag;	/* Global variables for tmplate storage */
PAGE *rpagehd;		/* during save_doc() and save_tmplate() */
PAGE *rcurpage;		/* If variables used anywhere else, they*/
int rtemp_page;		/* are locals...			*/
ARTICLE *rarthd;
char pfname[20];	/* string to hold title for preview window */
char basefname[20];	/* string to hold title for base page	   */


char GOGbuff[50];	/* GOG default buffer			*/
char *GOGptr;		/* GOG ptr into buffer			*/
char GOGindex;		/* GOG index				*/

/**********************************************************************/
/* Function: loadfile()						      */
/* Description: Load file 'fname' into buffer			      */
/**********************************************************************/
loadfile(fname)
char *fname;
{
   long bufsize;

   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fname,0) <= -1)
   {
	return(0);
   }
   bufsize = (((thedta.fsize * 3L)> 2048L)? (thedta.fsize*3L):(2048L));
   if(chbuff = lcalloc(1L,bufsize))	/* Allocate more than we need */
   {
     fhandle = Fopen(fname,0);
     bytes_in = Fread(fhandle,thedta.fsize,chbuff);
     Fclose(fhandle);
     init_buffer(chbuff,chbuff+bufsize);
     set_buffer(bytes_in);
     return(1);
   }
   return(0);
}



/************************************************************************/
/*  Function: instring()						*/
/*  Description: Searches a string for a particular character 		*/
/************************************************************************/	
instring(c,s)
char	c;
register char	*s;
{
	while (*s)
		if (c == *s++)
			return(1);
	return(0);
}


/************************************************************************/
/* Function: get_fs()							*/
/* Description: Handle file selector					*/
/************************************************************************/
get_fs(buff,changed)
register char *buff;
int *changed;
{
	int button;
	register int i;
	register char *tbuff;
        char obuf[40];
        int drv;

    tbuff = pathbuf;
    if(pathbuf[0] == '\0')
    {
        *tbuff++ = (drv =Dgetdrv()) + 'A';
        *tbuff++ = ':';
        *tbuff++ = '\\';
        *tbuff++ = 0;
        Dgetpath(obuf,drv+1);
        if(strlen(obuf) == 0);
        else strcat(pathbuf,&obuf[1]);
    }    
	strcpy(buff,pathbuf);
	buff[40] = '\0';		/* filename goes here */
        fname[0] = '\0';
	fsel_input(buff,fname,&button);
	if(!strcmp(buff,pathbuf))
	   *changed = 0;
	else
	   *changed = 1;
					/* Backspace until a \ or a :	*/
	for (i = strlen(buff); i && !instring(buff[i],"\\:");
                                           buff[i--] = '\0'); 
	strcpy(pathbuf,buff);
	strcat(buff,fname);
	return button;
}



/************************************************************************/
/* Function: save_doc							*/
/* Description:	Save a document to disk.				*/
/************************************************************************/
save_doc()
{  
   int pagenum,dummy;
   register unsigned int  pcount,acount,rcount;
   unsigned long rtblsize;
   unsigned long atblsize;
   int status;   

   PAGE *pageptr;
   REGION *rptr;
   ARTICLE *aptr;
   long magic;
   
   magic = 0x12445334L;			/* 12DS34 */
   status = FALSE;

   strcpy(pathbuf,dpath4);
   strcat(pathbuf,"*.DS2");
   if(!get_fs(fbuffer,&dummy))
	return;

   push_sdoc();
   extender(fbuffer,".DS2");   

   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fbuffer,0) == 0)			/* File Already Exists  */
   {
	if(alert_cntre(ALERT37) == 2)		/* Cancel Button pressed*/
	{
	  pop_sdoc();
	  return;
	}
   }
   

   
   pageptr = get_fpage(&pagenum);
   if(!pageptr)
   {
	pop_sdoc();
	return;
   }


   
   docbuf = (char *)lmalloc(DOCSIZE);
   if(!docbuf)
   {
	alert_cntre(ALERT12);	
	pop_sdoc();
	return;
   }
   docptr = docbuf;
   docend = docbuf + DOCSIZE;   /* Points to 1 past max address */

   acount = 0;
   rcount = 0;			/* Initialize region count      */
   pcount = 0;			/* Initialize page count	*/

   while(pageptr)
   {
       pcount++;
       rptr = get_fregion(pagenum,&dummy,&dummy,&dummy,&dummy,&dummy);
       while(rptr)
       {
           rcount++;
           rptr = get_nregion(&dummy,&dummy,&dummy,&dummy,&dummy);
       }
       pageptr = get_npage(&pagenum);
   }
   rtblsize = 4L * ((long)rcount + 1L);

   rtable = (long *)lmalloc(rtblsize);
   if(!rtable)
   {
	alert_cntre(ALERT12);
	free(docbuf);
	pop_sdoc();
	return;
   }
   aptr = getf_article();
   while(aptr)
   {
	acount++;
	aptr = getn_article();
   }
   atblsize = 4L * ((long)acount + 1L);
   atable = (long *)lmalloc(atblsize);
   if(!atable)
   {
	free(rtable);
	free(docbuf);
	alert_cntre(ALERT12);
	pop_sdoc();
	return;
   }
  
   rtbl_setup();			/* Set up region table  */
   atbl_setup();			/* Set up article table */

   if((fhandle = Fcreate(fbuffer,0)) <= 0)
   {
	alert_cntre(ALERT19);
	pop_sdoc();
 	return;
   }

   dwrite(&magic,4);			/* Magic value		*/
   if(write_pages(pcount)    && 	/* If each is successful then */
      write_articles(acount) && 	/* continue to write the next */
      write_regions(rcount)  &&		/* else short circuit the     */
      write_tags() 	     &&		/* while statement and stop   */
      write_setp()           &&		/* writing		      */
      write_ptype()	     &&
      write_pnums()	     &&		/* write page number info...  */
      ddump())				/* Dump the buffer    */

	;	/* Everything was written OK */
		/* Let aes handle error messages */

   free(atable);
   free(rtable);
   free(docbuf);


   if(Fclose(fhandle))
	alert_cntre(ALERT18);		/* Close the file     */

   pop_sdoc();				/* restore variables  */
   strcpy(pfname," ");
   strcat(pfname,fname);
   extender(pfname,".DS2");
   strcat(pfname," ");
   wind_set(prev_handle,WF_NAME,pfname,0,0);
}



/************************************************************************/
/* Function: write_regions()						*/
/* Description: write regions to disk					*/
/************************************************************************/
write_regions(rcount)
unsigned int rcount;
{
   register int i;
   long rptr;
   
   if(!dwrite(&rcount,2))	/* Write number of regions    */
		    return(0);
   for(i = 0;i < rcount;i++)
   {
	rptr = rtable[i];
	if(!write_attrs(rptr))
			return(0);
	if(!write_prims(rptr))
	   	        return(0);
   }
   return(1);				/* ok */
}




/************************************************************************/
/* Function: write_attrs()						*/
/* Description: write attributes to disk				*/
/************************************************************************/
write_attrs(rptr)
register REGION *rptr;
{
   unsigned int temp;


   temp = ((!rptr->artptr) ? (0xffff) : (getaindex(rptr->artptr)));

   if(!dwrite(&temp,2))
		return(0);
   temp = ((!rptr->plink) ? (0xffff) : (getrindex(rptr->plink)));

   if(!dwrite(&temp,2))
		return(0);

   temp = ((!rptr->alink) ? (0xffff) : (getrindex(rptr->alink)));

   if(!dwrite(&temp,2))
		return(0);
   if(!dwrite(&rptr->x1,10))			  /* write x1,y1,x2,y2,p    */
		return(0);
   if(!dwrite(&rptr->reserved,4))		  /* 2 reserved words 	    */
		return(0);
   if(!dwrite(&rptr->text,sizeof(struct txtattr)))/* Write text attributes  */
		return(0);
   if(!dwrite(&rptr->grattr[0],2*11))	  	  /* Graphic attributes     */
		return(0);
   if(!dwrite(&rptr->type,2))		  	  /* Write type		    */
		return(0);
   return(1);					  /* no error */
}




/************************************************************************/
/* Function: write_prims()						*/
/* Description: write primitives to disk				*/
/************************************************************************/
write_prims(rptr)
REGION *rptr;
{
   int pcount;
   int count,wrmode,op;

   pcount = 0;

   op = get_fprimitive(rptr,&count,&wrmode);
   while(op != 0xffff)
   {
	pcount++;
	op = get_nprimitive(&count,&wrmode);
   }
   if(!dwrite(&pcount,2))
		return(0);

   op = get_fprimitive(rptr,&count,&wrmode);
   while(op != 0xffff)
   {
	if(!dwrite(&op,2))			/* Write opcode         */
		   return(0);
	if(!dwrite(&wrmode,2))			/* Write writing mode   */
		   return(0);
	if(!dwrite(&count,2))			/* Write ptsarray count */
		   return(0);
	if(!dwrite(&ptsarray[0],4*count))	/* Write points 	*/
		   return(0);
	op = get_nprimitive(&count,&wrmode);
   }
   return(1);
}
	   
save_article(artptr)
ARTICLE *artptr;
{
      if(artptr->dirty)
      {
         open_article(artptr);
         strcpy(fbuffer,dpath1);
         strcat(fbuffer,&artptr->filename[0]);
         get_abuffvars(artptr);
         write_file(fbuffer);
         artptr->dirty = 0; 
      }
}

/************************************************************************/
/* Function: write_articles()						*/
/* Description: write articles to disk					*/
/************************************************************************/
write_articles(acount)
unsigned int acount;
{
   register int i;
   ARTICLE *aptr;
   REGION  *rptr;
   int temp;

   if(!dwrite(&acount,2))		/* Write number of articles    */
		return(0);
   for(i = 0;i < acount; i++)
   {
	aptr = (ARTICLE *)atable[i];
	rptr = aptr->regptr;

	temp = ((rptr) ? (getrindex(rptr)) : (0xffff));
        if(!dwrite(&temp,2))		/* Write index of first region  */
			return(0);
	if(!dwrite(&aptr->filename[0],40))	/* Write filename	*/
			return(0);
	
	save_article(aptr);
   }
   return(1);
}



	   
/************************************************************************/
/* Function: write_pages()						*/
/* Description: Write pages to disk					*/
/************************************************************************/
write_pages(pcount)
unsigned int pcount;
{
   PAGE *pageptr;
   REGION *rptr;
   int pagenum,dummy;
   int temp;

   if(!dwrite(&pcount,2))		/* Write number of pages  	*/
		return(0);
   pageptr = get_fpage(&pagenum);
   rptr = get_fregion(pagenum,&dummy,&dummy,&dummy,&dummy,&dummy);
   while(pageptr)
   {
	if(!dwrite(&pagenum,2))		/* Write page number 		*/
			return(0);
					/* Write index of first region       */
					/* else -1 = no region for this page */
	temp = ((rptr) ? (getrindex(rptr)) : (0xffff));
        if(!dwrite(&temp,2))
		return(0);
	pageptr = get_npage(&pagenum);
        rptr = get_fregion(pagenum,&dummy,&dummy,&dummy,&dummy,&dummy);
   }
   return(1);
}





/************************************************************************/
/* Function: atbl_setup()						*/
/* Description: Article Table setup					*/
/************************************************************************/
atbl_setup()
{
   register int i;
   ARTICLE *aptr;

   i = 0;

   aptr = getf_article();
   while(aptr)
   {
	atable[i++] = (long)aptr;
	aptr = getn_article();
   }
   atable[i] = 0L;
}



	
/************************************************************************/
/* Function: rtbl_setup()						*/
/* Description: region table setup					*/
/************************************************************************/
rtbl_setup()
{
   PAGE *pageptr;
   REGION *rptr;
   register int i;
   int pagenum;
   int dummy;

   i = 0;
   pageptr = get_fpage(&pagenum);
   while(pageptr)
   {
	rptr = get_fregion(pagenum,&dummy,&dummy,&dummy,&dummy,&dummy);
	while(rptr)
	{
	    rtable[i++] = (long)rptr;
	    rptr = get_nregion(&dummy,&dummy,&dummy,&dummy,&dummy);
	}
	pageptr = get_npage(&pagenum);
   }
   rtable[i] = 0L;
}




/************************************************************************/
/* Function: dread()							*/
/* Description: read characters from input buffer			*/
/************************************************************************/
dread(cptr,count)
register char *cptr;
register int count;
{
   while(count--)
   {
	*cptr++ = *docptr++;
   }
   if(count != -1)
	return(0);
   else
        return(1);
}




/************************************************************************/
/* Function: dwrite()							*/
/* Description: Write characters to file				*/
/************************************************************************/
dwrite(cptr,count)
register char *cptr;
register int count;
{
   while(count--)
   {
	if(docptr == docend)
	{
	   if(!ddump())
		   return(0);			/* error */
	}
	*docptr++ = *cptr++;
   }
   return(1);		/*ok */
}





/************************************************************************/
/* Function: ddump()							*/
/* Description: Write out file buffer to disk				*/
/************************************************************************/
ddump()
{
   long count;
   long num;

   count = (long)docptr - (long)docbuf;
   if((num = Fwrite(fhandle,count,docbuf)) >= 0)
   {
     docptr = docbuf;
     return(1);					/* ok */
   }
   return(0);					/* error */
}





/************************************************************************/
/* Function: load_doc()							*/
/* Description:								*/
/* 	Load a document from disk and set up region, article, and page  */
/*	structures.							*/
/************************************************************************/
load_doc(docname)
char *docname;
{
   long bufsize;
   int dummy;
   long magic;
   int i;

   if(docname)
   {
      strcat(fbuffer,docname);
   }
   else
   {
      strcpy(pathbuf,dpath4);
      strcat(pathbuf,"*.DS2");
      if(!get_fs(fbuffer,&dummy))
      {
	  return;
      }
      extender(fbuffer,".DS2");
   }
   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fbuffer,0) <= -1)
   {
      alert_cntre(ALERT8);
      return;
   }
   bufsize = thedta.fsize;
   if(!bufsize)
   {
      alert_cntre(ALERT39);
      return;
   }

   docbuf = (char *)lcalloc(1L,bufsize);
   if(!docbuf)
   {
	alert_cntre(ALERT12);
	return;
   }

   docptr = docbuf;
   if((fhandle = Fopen(fbuffer,0)) <= 0)
   {
	free(docbuf);
	alert_cntre(ALERT16);
	return;
   }
   bytes_in = Fread(fhandle,thedta.fsize,docbuf);
   if(bytes_in < thedta.fsize)
   {
	free(docbuf);
	alert_cntre(ALERT17);
        Fclose(fhandle);
	return;
   }
   Fclose(fhandle);

   erase_all(1);				/* Start fresh 		*/
   dread(&magic,4);
   if(magic != 0x12445334L)		/* Magic value 12DS34 */
   {
	free(docbuf);
	alert_cntre(ALERT29);
	return;
   }   
   if(read_pages()   && 
   read_articles()   &&
   read_regions())
	;		/* Everything is OK */
   else
   {
        alert_cntre(ALERT12);		/* Not enough memory	*/
	dbase_cleanup();
	free(rtable);
	free(docbuf);
        return;
   }
   
   free(rtable);
   fixup_rptrs();
   load_arts();
   clear_tags();
   read_tags();
   read_setp();
   sysfiles();				/* setup setp files */
   read_ptype();
   read_pnums();			/* read page number info*/

   curpage = pagehd;
   curr_page = pagehd->pagenum;
 
   free(docbuf);

   strcpy(pfname," ");
   if(docname)
	strcat(pfname,docname);
   else
        strcat(pfname,fname);
   strcat(pfname," ");
   wind_set(prev_handle,WF_NAME,pfname,0,0);
   do_pagenum(curr_page,(curr_page%2)?1:0);

   hpage_size = pagemux[pagetype - PA4];
   vpage_size = pagemuy[pagetype - PA4];
   page_area.g_x = page_area.g_y = 0L;
   mutomem(hpage_size,vpage_size,&scan_xres,&scan_yres);
   if(pagetype == PLEGAL + 4)	/* Legal Landscape   ? */
   {				/* view_size == P200 or PADJCNT? */
       if((view_size == P200) || (view_size == PADJCNT))
       {
                                  view_size = PACTUAL;
          for(i=PSIZE;i<= PADJCNT;i++)
	          menu_icheck(ad_menu,i,FALSE);
          menu_icheck(ad_menu,view_size,TRUE);
          wind_set(prev_handle,WF_INFO,winfo[view_size - PSIZE][unit_type]);
       }
       menu_ienable(ad_menu,P200,FALSE);
       menu_ienable(ad_menu,PADJCNT,FALSE);
   }
   else
   {
       menu_ienable(ad_menu,P200,TRUE);
       menu_ienable(ad_menu,PADJCNT,TRUE);
   }
   gsx_moff();
   vsf_interior(shandle,0);

   if((view_size == PSIZE) ||
      (view_size == PADJCNT))
          pdraw_fit(view_size);
   else
	  pdraw_scale();

   vr_recfl(shandle,pxy);
   gsx_mon();
   zoom_setup();
   cur_scale = get_scale_num(view_size);
   get_work(prev_handle);
   update_preview_blit();
   clear_window(prev_handle,2,1);
   set_clip(TRUE,&pwork);

   graf_mouse(2,&dummy);

   init_rulers();
   recalc_txtptrs();
   force_preview();
   slider_chk();
   graf_mouse(ARROW,&dummy);
}


/************************************************************************/
/*	Clean up data structures of pages,articles, and regions		*/
/************************************************************************/
dbase_cleanup()
{
register PAGE *tpage;
PAGE *npage;
register ARTICLE *tart;
ARTICLE *nart;

   tpage = npage = pagehd;		/* Clean up pages 	*/
   while(tpage)
   {
	npage = tpage->nextpage;
	free(tpage);
 	tpage = npage;
   }
   tart = nart = arthd;			/* Clean up articles    */
   while(tart)
   {
	nart = tart->nextart;
	free(tart);
 	tart = nart;
   }
   clean_regions();
   pagehd = (PAGE *)0L;
   arthd  = (ARTICLE *)0L;
}


/************************************************************************/
/*	Clean up regions in rtable along with their prims and ptsblks   */
/************************************************************************/
clean_regions()
{
REGION *rptr;
PRIMITIVE *nprim;
register PRIMITIVE *tprim;
PTSBLK *nblk;
PTSBLK *tblk;
register int i;

   for(i = 0; i < gl_rcount;i++)		/* Clean up regions 	  */
   {
	rptr = (REGION *)rtable[i];
   	tprim = nprim = rptr->primlist;		/* Clean up primitives    */
	while(tprim)
        {
	   nprim = tprim->nextprim;
   	   tblk = nblk = tprim->blkptr;      /* Clean up blocks	  */
	   while(tblk)
           {
	      nblk = tblk->nextblk;
	      free(tblk);
 	      tblk = nblk;
           }	
	   free(tprim);
 	   tprim = nprim;
        }	
        free(rptr);
    }
}

/************************************************************************/
/* Function: load_arts()						*/
/* Description: load articles from disk					*/
/************************************************************************/
load_arts()
{
register ARTICLE *aptr;
ARTICLE *naptr;
ARTICLE *pptr;

register REGION  *rptr;
REGION  *rnext;

   aptr = arthd;
   while(aptr)
   {
	strcpy(fbuffer,dpath1);
	strcat(fbuffer,&aptr->filename[0]);
	if(!loadfile(fbuffer))
        {
	   rptr = aptr->regptr;

	   while(rptr)
           {
		rptr->artptr = 0L;		/* clear ptr to article    */
		rnext = rptr->alink;   		
		rptr->alink = 0L;		/* clear ptr to next region*/
                rptr = rnext;			/* go on to next article   */
           }
           aptr->filename[0] = '\0';		/* clear filename of articl*/
           aptr->regptr = 0L;	        	/* zero it out */
	   aptr->dirty  = 0;
	   
        }
        else
        {
	    aptr->buf_start = buf_start;
	    aptr->buf_end = buf_end;
	    aptr->free_start = free_start;
	    aptr->current_char = current_char;
	    aptr->dirty  = 0;
        }
	aptr = aptr->nextart;
   }

   pptr = aptr = arthd;
   while(aptr)
   {

      if(aptr->regptr == 0L)
      {

	  if(aptr == arthd)
          {
              naptr = aptr->nextart;
	      arthd = pptr = naptr;
	      free(aptr);
 	      aptr = naptr;
          }
          else
          {
	    naptr = aptr->nextart;
	    pptr->nextart = naptr;
	    free(aptr);
	    aptr = naptr;
          }

      }
      else
      {

	 pptr = aptr;
         aptr = aptr->nextart;
      }
   }

   return(1);
}




/**********************************************************************/
/* Function: getrptr()						      */
/* Description: get region pointer from region table		      */
/**********************************************************************/
REGION *getrptr(index)
int index;
{
   if(index == 0xffff)
	return (REGION *)0L;
   else
        return (REGION *)rtable[index];   
}




/**********************************************************************/
/* Function: fixup_rptrs()					      */
/* Description: Fixup region pointers after loading...		      */
/**********************************************************************/
fixup_rptrs()
{
   register REGION *rptr;
   register ARTICLE *aptr;
   register PAGE *pptr;
   register int i;

   for(i = 0;i < gl_rcount;i++)
   {
	rptr = (REGION *)rtable[i];
	rptr->alink = getrptr((int)rptr->alink);
	rptr->plink = getrptr((int)rptr->plink);
   }
   pptr = pagehd;
   while(pptr)
   {
	pptr->regptr = getrptr((int)pptr->regptr);
  	pptr = pptr->nextpage;
   }
   aptr = arthd;
   while(aptr)
   {
	aptr->regptr = getrptr((int)aptr->regptr);
	aptr = aptr->nextart;
   }
}



/**********************************************************************/
/* Function: aindex_to_ptr()					      */
/* Description: Return article index pointer			      */
/**********************************************************************/
ARTICLE *aindex_to_ptr(index)
unsigned int index;
{
   register int i;
   register ARTICLE *aptr;

   if(index == 0xffff)
	return (ARTICLE *)0L;
   aptr = arthd;
   for(i = 0; i < index;i++)
	aptr = aptr->nextart;
   return aptr;
}




/**********************************************************************/
/* Function: read_regions()					      */
/* Description: Read regions from disk				      */
/**********************************************************************/
read_regions()
{
   long rtblsize;
   register REGION  *rptr;
   unsigned int rindex;
   unsigned int aindex;
   long temp;
   register int i;

   dread(&gl_rcount,2);
   rtblsize = 4L * (long)gl_rcount;
   if(!(rtable = (long *)lmalloc(rtblsize)))
	   				return(0);
   for(i = 0;i < gl_rcount;i++)
   {
      if(!(rptr = (REGION *)calloc(1,sizeof(REGION))))
						return(0);
      rtable[i] = (long)rptr;
      dread(&aindex,2);
      rptr->artptr = aindex_to_ptr(aindex);
      dread(&rindex,2);
      temp = ((long)rindex & 0xffff);
      rptr->plink = (REGION *)temp;
      dread(&rindex,2);
      temp = ((long)rindex & 0xffff);
      rptr->alink = (REGION *)temp;
      dread(&rptr->x1,10);			/* Read x1,y1,x2,y2,p     */
      dread(&rptr->reserved,4);			/* 2 reserved words	  */
      dread(&rptr->text,sizeof(struct txtattr));/* Read text attributes   */
      dread(&rptr->grattr[0],2*11);		/* Graphic attributes     */
      dread(&rptr->type,2);			/* Read type		  */    
      if(!read_prims(rptr))			/* Read in primitives     */
  			return(0);
   }
   return(1);
}




/**********************************************************************/
/* Function: read_prims()					      */
/* Description: read primitives from disk			      */
/**********************************************************************/
read_prims(rptr)
REGION *rptr;
{
   register int i,j,k;
   int pcount;
   PRIMITIVE *prevprim;
   PRIMITIVE  *newprim;
   register PTSBLK *curblk;
   register int count;

   dread(&pcount,2);
   if(!(prevprim = (PRIMITIVE *)calloc(1,sizeof(PRIMITIVE))))
							return(0);
   rptr->primlist = prevprim;

   for(i = 0;i < pcount;i++)
   {
      dread(&prevprim->op,6);			/* Read op,wrmode,#pts */
      if(!(curblk = (PTSBLK *)calloc(1,sizeof(PTSBLK))))
					           return(0);
      curblk->nextblk = 0L;
      prevprim->blkptr = curblk;
      count = prevprim->numpts;
      count *= 2;			/* count = # vertices */
      dread(ptsarray,count*2);		/* times 2 for # of chars */
      j = k = 0;
      while(count--)
      {
	curblk->points[j++] = ptsarray[k++];
  	if(j >= MAXBLK)
 	{
	   if(!(curblk->nextblk = (PTSBLK *)calloc(1,sizeof(PTSBLK))))
						                return(0);
	   curblk = curblk->nextblk;
	   curblk->nextblk = 0L;
	   j = 0;
	}
      }
      if(i == pcount - 1)
	newprim = 0L;
      else
      {
        if(!(newprim = (PRIMITIVE *)calloc(1,sizeof(PRIMITIVE))))
							return(0);
      }
      prevprim->nextprim = newprim;
      prevprim = newprim;
   }
   return(1);
}




/**********************************************************************/
/* Function: read_pages()					      */
/* Description: read pages from disk				      */
/**********************************************************************/
read_pages()
{
   int pcount;
   PAGE *newpage;
   register PAGE *prevpage;
   unsigned int rindex;
   long temp;
   register int i;
   int pagenum;

   dread(&pcount,2);
   if(!(prevpage = (PAGE *)calloc(1,sizeof(PAGE))))
						return(0);
   pagehd = prevpage;

   for(i = 0;i < pcount;i++)
   {
      dread(&pagenum,2);
      prevpage->pagenum = pagenum;
      dread(&rindex,2);
      temp = ((long)rindex & 0xffff);
      prevpage->regptr = (REGION *)temp;
      if(i == pcount - 1)
	newpage = 0L;
      else
      {
        if(!(newpage = (PAGE *)calloc(1,sizeof(PAGE))))
						return(0);
      }
      prevpage->nextpage = newpage;
      prevpage = newpage;
   }
   return(1);
}




/**********************************************************************/
/* Function: read_articles()					      */
/* Description: read articles from disk				      */
/**********************************************************************/
read_articles()
{
   int acount;
   ARTICLE *newart;
   register ARTICLE *prevart;
   unsigned int rindex;
   long temp;
   register int i;

   dread(&acount,2);
   if(acount == 0)
	return(1);
   if(!(prevart = (ARTICLE *)calloc(1,sizeof(ARTICLE))))
						return(0);
   arthd = prevart;

   for(i = 0;i < acount;i++)
   {
      dread(&rindex,2);
      temp = ((long)rindex & 0xffff);
      prevart->regptr = (REGION *)temp;		/* Fill in the first region */
      dread(&prevart->filename[0],40);		/* Fill in the file name */
      if(i == acount - 1)
	newart = 0L;
      else
      {
        if(!(newart = (ARTICLE *)calloc(1,sizeof(ARTICLE))))
							return(0);
      }
      prevart->nextart = newart;
      prevart = newart;
   }
   return(1);
}




/**********************************************************************/
/* Function: getaindex()					      */
/* Description: get article index				      */
/**********************************************************************/
getaindex(aptr)
ARTICLE *aptr;
{
   register int i;

   i = 0;
   while(atable[i])
   {
	if(atable[i] == (long)aptr)
	{
	   return i;
	}
	i++;
   }
}




/**********************************************************************/
/* Function: getrindex()					      */
/* Description: get region index()				      */
/**********************************************************************/
getrindex(rptr)
REGION *rptr;
{
   register int i;
   i = 0;
   while(rtable[i])
   {
	if(rtable[i] == (long)rptr)
	{
	   return i;
	}
        i++;
   }
}





/************************************************************************/
/* Function: save_clipb()						*/
/* Description:	Save clipboard to disk					*/
/************************************************************************/
save_clipb()
{
   unsigned long rtblsize;
   register unsigned int rcount;      
   register REGION *rptr;
   int i;
   int status;

   status = FALSE;
   if(!clipfull)	/* does this check the same thing as...*/
	return;

   if(!clippage->regptr)   /* this? Oh, well...just in case... */
		return;

   active_prim = FALSE;
   strcpy(pathbuf,dpath2);
   strcat(pathbuf,"*.CLP");
   if(!get_fs(fbuffer,&i))
   {
	return;
   }
   extender(fbuffer,".CLP");   


   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fbuffer,0) == 0)			/* File Already Exists  */
   {
	if(alert_cntre(ALERT37) == 2)		/* Cancel Button pressed*/
			return;
   }


   if((fhandle = Fcreate(fbuffer,0)) <=0)
   {
	alert_cntre(ALERT19);
	return;
   }
   docbuf = (char *)lmalloc(DOCSIZE);
   if(!docbuf)
   {
	alert_cntre(ALERT12);
	Fclose(fhandle);
	return;
   }
   docptr = docbuf;
   docend = docbuf + DOCSIZE - 1;
   rcount = 0;			/* Initialize region count      */

   rptr = clippage->regptr;
   while(rptr)
   {
       rcount++;
       rptr = rptr->plink;
   }  

   rtblsize = 4L * ((long)rcount + 1L);
   rtable = (long *)lmalloc(rtblsize);
   if(!rtable)
   {
	free(docbuf);
	alert_cntre(ALERT12);
	Fclose(fhandle);
	return;
   }
   rptr = clippage->regptr;
   i = 0;
   while(rptr)
   {
         rtable[i++] = (long)rptr;
         rptr = rptr->plink;
   }  
   if(write_regions(rcount))
   {
         if(!ddump())	/* Dump the buffer		*/
	     alert_cntre(ALERT20);
   }
   else
	 alert_cntre(ALERT20);		    
   free(rtable);
   free(docbuf);
   Fclose(fhandle);			/* Close the file		*/
}



/************************************************************************/
/* Function: load_clipb()						*/
/* Description:	Load clipboard						*/
/************************************************************************/
load_clipb()
{
   long bufsize;
   int i;
   REGION *rptr;
   int status;

   status = FALSE;

   strcpy(pathbuf,dpath2);
   strcat(pathbuf,"*.CLP");
   if(!get_fs(fbuffer,&i))
   {
	return NOFILE;
   }
   extender(fbuffer,".CLP");
   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fbuffer,0) <= -1)
   {
	alert_cntre(ALERT8);
	return NOFILE;
   }

   if(!thedta.fsize)
   {
	alert_cntre(ALERT39);
        return(1);
   }
   delete_clip();
   clippage = (PAGE *)get_lcmem((long)sizeof(PAGE));
   if(!clippage)
   {
	alert_cntre(ALERT12);
	return(1);
   }
   bufsize = thedta.fsize;
   docbuf = (char *)lcalloc(1L,bufsize);
   if(!docbuf)
   {
	free(clippage);
	alert_cntre(ALERT12);
	return(1);
   }
   docptr = docbuf;
   fhandle = Fopen(fbuffer,0);
   if(fhandle <= 0)
   {
	free(clippage);
	free(docbuf);
	alert_cntre(ALERT16);
	return(1);
   }
   bytes_in = Fread(fhandle,thedta.fsize,docbuf);
   if(bytes_in < thedta.fsize)
   {
	free(clippage);
	free(docbuf);
	alert_cntre(ALERT17);
        Fclose(fhandle);
	return(1);
   }
   Fclose(fhandle);
   if(!read_regions())
   {
	clean_regions();
	alert_cntre();
	free(rtable);
	free(docbuf);
	free(clippage);
	return(1);
   }
   for(i = 0;i < gl_rcount;i++)
   {
        rptr = (REGION *)rtable[i];
        rptr->plink = getrptr((int)rptr->plink);
   }
   clippage->regptr = (REGION *)rtable[0];

   free(rtable);
   free(docbuf);
   return(0);			/* normal return   */
}






/**********************************************************************/
/* Function: extender()						      */
/* Description: handle file name extenders			      */
/**********************************************************************/
extender(fname,ext)
char *fname;
register char *ext;
{
     register char *s;
     
     s = fname;
     while((*s != '.') && (*s != '\0'))
				*s++;

     if(*s == '\0')
	  strcat(fname,ext);
     else
     {	
       *s++;
       *ext++;
       if(*s == '\0')
	  strcat(fname,ext);
     }
}




load_path()
{
   long bufsize;
   
   Fsetdta(&thedta.res[0]);
   if(Fsfirst("DESK2.PTH",0) <= -1)
   {
	return(0);			/* path file not found */
   }					/* so use the defaults */
   bufsize = thedta.fsize;
   if(bufpath = lcalloc(1L,bufsize))
   {
      fhandle = Fopen("DESK2.PTH",0);
      bytes_in = Fread(fhandle,thedta.fsize,bufpath);
      Fclose(fhandle);
      return(1);
   }
}



write_paths(dpath1,dpath2,dpath3,dpath4)
char *dpath1;
char *dpath2;
char *dpath3;
char *dpath4;
{
        pbufindex = 0;
	add_slash(dpath1);
	bputstr(dpath1);
	bputcr();
	add_slash(dpath2);
	bputstr(dpath2);
	bputcr();
	add_slash(dpath3);
	bputstr(dpath3);
	bputcr();
	add_slash(dpath4);
	bputstr(dpath4);
	bputcr();
   
	if( (fhandle = Fcreate("DESK2.PTH",0)) > 0)
        {
	   Fwrite(fhandle,200L,pbuff);
	   Fclose(fhandle);
        }
}



store_paths(dpath1,dpath2,dpath3,dpath4)
char *dpath1;
char *dpath2;
char *dpath3;
char *dpath4;
{
        pbufindex = 0;
	bputstr(dpath1);
	bputcr();
	bputstr(dpath2);
	bputcr();
	bputstr(dpath3);
	bputcr();
	bputstr(dpath4);
	bputcr();
}


bputstr(str)
register char *str;
{
   while(*str)
	  pbuff[pbufindex++] = *str++;
}


bputcr()
{
   pbuff[pbufindex++] = 0x0D;
   pbuff[pbufindex++] = 0x0A;
}

read_path(dpath1,dpath2,dpath3,dpath4)
char *dpath1;
char *dpath2;
char *dpath3;
char *dpath4;
{
   pbufindex = 0;

   Fsetdta(&thedta.res[0]);
   if(Fsfirst("DESK2.PTH",0) <= -1)
   {
	return(0);
   }
   fhandle = Fopen("DESK2.PTH",0);
   bytes_in = Fread(fhandle,thedta.fsize,pbuff);
   Fclose(fhandle);

   bgetstr(dpath1);
   bgetstr(dpath2);
   bgetstr(dpath3);
   bgetstr(dpath4);
   return(1);
}



bgetstr(dpath)
register char *dpath;
{
     while(pbuff[pbufindex] != 0x0D)
		*dpath++ = pbuff[pbufindex++];
     pbufindex++;			/* get rid of 0x0D */   
     pbufindex++;			/* get rid of 0x0A */   
     *dpath++ = 0x0;
}



restore_paths(dpath1,dpath2,dpath3,dpath4)
char *dpath1;
char *dpath2;
char *dpath3;
char *dpath4;
{
   pbufindex = 0;
   bgetstr(dpath1);
   bgetstr(dpath2);
   bgetstr(dpath3);
   bgetstr(dpath4);
}



remove_path(str)
char *str;
{
   char s[100];
   register int  i; 

   i = 0;
   strcpy(&s[0],str);

   while(s[i++]);

   while(s[i-1] != '\\' && i)
	   i--;
   strcpy(str,&s[i]);
}



write_ptype()
{
    if(!dwrite(&pagetype,2))
			return(0);
    else return(1);
}



read_ptype()
{
   dread(&pagetype,2);			/* Don't forget landscape */
   if( (pagetype >= PA4) && (pagetype <= (PLEGAL + 4))) /* <- + 4 */
				return;
   else
      pagetype = PLETTER;
}



write_tmplates()
{
  register unsigned int pcount,acount,rcount;
  unsigned long rtblsize;
  unsigned long atblsize;
  int lap;
  ARTICLE *aptr;
  REGION *rptr;

  for(lap = 0;lap <= 1;lap++)
  {
    if(lap)
    {
      pagehd = curpage = right_tmplate;
      curr_page = right_tmplate->pagenum;
      arthd = rtarthd;
    }
    else
    {
      pagehd = curpage = left_tmplate;
      curr_page = left_tmplate->pagenum;
      arthd = ltarthd;
    }
    
    pcount = 1;
    acount = rcount = 0;
    rptr = get_fregion(curr_page,&dummy,&dummy,&dummy,&dummy,&dummy);
    while(rptr)
    {
      rcount++;
      rptr = get_nregion(&dummy,&dummy,&dummy,&dummy,&dummy);
    }

    rtblsize = 4L * ((long)rcount + 1L);

    rtable = (long *)lmalloc(rtblsize);
    if(!rtable)
    {
	alert_cntre(ALERT12);
	return;
    }
    rtbl_setup();
    aptr = getf_article();
    while(aptr)
    {
	acount++;
	aptr = getn_article();
    }
    atblsize = 4L * ((long)acount + 1L);
    atable = (long *)lmalloc(atblsize);
    if(!atable)
    {
	free(rtable);
	alert_cntre(ALERT12);
	return;
    }
    atbl_setup();
    if(write_pages(pcount)     &&
       write_articles(acount)  &&
       write_regions(rcount))
	;
    else
    {	
	alert_cntre(ALERT20);
        free(atable);
        free(rtable);
	return;
    }
    free(atable);
    free(rtable);
  }
  if(!ddump())
	alert_cntre(ALERT20);
  return;
}


read_tmplates()
{
  int i;

  for(i=0;i<=1;i++)
  {
    pagehd = curpage = ((i)?(right_tmplate):(left_tmplate)); 
    arthd = ((i)?(rtarthd):(ltarthd));
    tread_pages();
    read_articles();
    read_regions();
    fixup_rptrs();
    load_arts();
    recalc_txtptrs();  
    if(rtable)
         free(rtable);
    if(i)
  	rtarthd = arthd;
    else
	ltarthd = arthd;
  }
  return(1);
}



tread_pages()
{
  int pcount;
  int pagenum;
  unsigned int rindex;
  long temp;
  register PAGE *prevpage;

  prevpage = pagehd;  
  dread(&pcount,2);
  dread(&pagenum,2);
  prevpage->pagenum = pagenum;
  dread(&rindex,2);
  temp = ((long)rindex & 0xffff);
  prevpage->regptr = (REGION *)temp;
  prevpage->nextpage = 0L;
}




load_tmplate()
{

   long bufsize;
   int dummy;

   strcpy(pathbuf,dpath2);
   strcat(pathbuf,"*.BPL");
   if(!get_fs(fbuffer,&dummy))
   {
	return;
   }
   extender(fbuffer,".BPL");
   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fbuffer,0) <= -1)
   {
	alert_cntre(ALERT8);
	return;
   }
   rtmplate_flag = tmplate_flag;
   rtemp_page = curr_page;
   rpagehd    = pagehd;
   rcurpage   = curpage;
   rarthd     = arthd;

   bufsize = thedta.fsize;

   if(!bufsize)
   {
	alert_cntre(ALERT39);
	return;
   }

   docbuf = (char *)lcalloc(1L,bufsize);
   if(!docbuf)
   {
	alert_cntre(ALERT12);
	return;
   }
   docptr = docbuf;
   if((fhandle = Fopen(fbuffer,0)) <= 0)
   {
	alert_cntre(ALERT16);
	free(docbuf);
	return;
   }
   bytes_in = Fread(fhandle,thedta.fsize,docbuf);
   if(bytes_in < thedta.fsize)
   {
	alert_cntre(ALERT17);
	free(docbuf);
        Fclose(fhandle);
	return;
   }
   Fclose(fhandle);
   delete_tmplates();
   if(!read_tmplates())
   {
	free(docbuf);
        tmplate_flag = rtmplate_flag;
        curr_page    = rtemp_page;
        pagehd       = rpagehd;
        curpage      = rcurpage;
         arthd	     = rarthd;
	return;
   }
   free(docbuf);
   strcpy(basefname," ");
   strcat(basefname,fname);
   strcat(basefname," ");

   tmplate_flag = rtmplate_flag;

   if(tmplate_flag)
   {
     pagehd = curpage = ((curr_page % 2) ? (right_tmplate):(left_tmplate));
     curr_page = pagehd->pagenum;
     arthd = ((curr_page % 2)?(rtarthd):(ltarthd));
     wind_set(prev_handle,WF_NAME,basefname,0,0);
   }
   else
   {
     curr_page    = rtemp_page;
     pagehd       = rpagehd;
     curpage      = rcurpage;
     arthd	  = rarthd;
   }
   force_preview();
}






save_tmplate()
{
   int dummy;

   if(!right_tmplate->regptr && !left_tmplate->regptr)
				return;

   strcpy(pathbuf,dpath2);
   strcat(pathbuf,"*.BPL");
   if(!get_fs(fbuffer,&dummy))
   {
       return;
   }

   push_tmplate();		/* Save global variables*/


   extender(fbuffer,".BPL");   

   Fsetdta(&thedta.res[0]);			/* Init a dta area	*/
   if(Fsfirst(fbuffer,0) == 0)			/* File Already Exists  */
   {
	if(alert_cntre(ALERT37) == 2)		/* Cancel Button pressed*/
	{
	   pop_tmplate();	
	   return;
	}
   }

   if((fhandle = Fcreate(fbuffer,0)) <=0)
   {
	alert_cntre(ALERT19);
	pop_tmplate();
	return;
   }
   docbuf = (char *)lmalloc(DOCSIZE);
   if(!docbuf)
   {
	alert_cntre(ALERT12);
	pop_tmplate();
	return;
   }
   docptr = docbuf;
   docend = docbuf + DOCSIZE - 1;
   write_tmplates();
   free(docbuf);
   Fclose(fhandle);

   pop_tmplate();		/* Restore global variables */
   strcpy(basefname," ");
   strcat(basefname,fname);
   extender(basefname,".BPL");
   strcat(basefname," ");
   if(tmplate_flag)
        wind_set(prev_handle,WF_NAME,basefname,0,0);
}




write_pnums()
{
    if(!dwrite(&pnum,sizeof(struct pnumber)))
				return(0);
    else return(1);
}



read_pnums()
{
    dread(&pnum,sizeof(struct pnumber));   
}





write_defaults()
{
   int fd;
 
   if((fd = Fcreate("DESK2.DFT",0)) > 0)
   {
	Fwrite(fd,102L,pstorage);
	Fwrite(fd,(long)pstorage[50],pnumtext);
	Fclose(fd);
   }

}




read_defaults()
{
     int fd;
     int nbytes;

     Fsetdta(&thedta.res[0]);
     if(Fsfirst("DESK2.DFT",0) <= -1)
     			return(0);
     fd = Fopen("DESK2.DFT",0);
     nbytes = Fread(fd,102L,pstorage);
     nbytes = Fread(fd,(long)pstorage[50],pnumtext);
     Fclose(fd);
     return(1);
}






/* Save these variables for save_doc()	*/
/* this was necessary if in tmplate mode*/
push_sdoc()
{
   rtmplate_flag = tmplate_flag;
   rtemp_page = curr_page;
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

}





/* Restore original variables for save_doc()*/
pop_sdoc()
{
   tmplate_flag = rtmplate_flag;
   curr_page = rtemp_page;
   if(tmplate_flag)
   {
     pagehd = rpagehd;
     curpage = rcurpage;
     arthd   = rarthd;
   }

}



/* Save global variables for save tmplate */
/* related to if in tmplate mode 	  */
push_tmplate()
{
   rtmplate_flag = tmplate_flag;
   rtemp_page = curr_page;
   rpagehd    = pagehd;
   rcurpage   = curpage;
   rarthd     = arthd;
}



/* Restore global variables in save_tmplate*/
pop_tmplate()
{
   arthd        = rarthd;
   tmplate_flag = rtmplate_flag;
   curr_page    = rtemp_page;
   pagehd       = rpagehd;
   curpage      = rcurpage;
}




add_slash(path)
char *path;
{
   int i;

   i = strlen(path);   
   if(path[i-1] != '\\')
	strcat(path,"\\");
}



load_tags()
{
  int dummy;
  long bufsize;

  strcpy(pathbuf,dpath2);
  strcat(pathbuf,"*.TAG");
  if(!get_fs(fbuffer,&dummy))
  {
	return;
  }

  extender(fbuffer,".TAG");
  Fsetdta(&thedta.res[0]);
  if(Fsfirst(fbuffer,0) <= -1)
  {
     alert_cntre(ALERT8);
     return;
  }

  
  bufsize = thedta.fsize;
  if(!bufsize)
  {
	alert_cntre(ALERT39);
	return;
  }

  docbuf  = (char *)lcalloc(1L,bufsize);
  if(!docbuf)
  {
	alert_cntre(ALERT12);
	return;
  }

  docptr = docbuf;
  if((fhandle = Fopen(fbuffer,0)) <= 0)
  {
     alert_cntre(ALERT16);
     free(docbuf);
     return;
  }

  bytes_in = Fread(fhandle,thedta.fsize,docbuf);
  if(bytes_in < thedta.fsize)
  {
     alert_cntre(ALERT17);
     free(docbuf);
     Fclose(fbuffer);     
     return;
  }
  Fclose(fbuffer);

  clear_tags();
  read_tags();
  free(docbuf);
}




save_tags()
{
   int dummy;

   strcpy(pathbuf,dpath2);
   strcat(pathbuf,"*.TAG");
   if(!get_fs(fbuffer,&dummy))
   {
	return;
   }

   extender(fbuffer,".TAG");

   Fsetdta(&thedta.res[0]);
   if(Fsfirst(fbuffer,0) == 0)
   {
	if(alert_cntre(ALERT37) == 2)	/* Cancel Button */
	{
	     return;
	}
   }

   if((fhandle = Fcreate(fbuffer,0)) <= 0)
   {
	alert_cntre(ALERT19);
	return;
   }

   docbuf = (char *)lmalloc(DOCSIZE);
   if(!docbuf)
   {
	alert_cntre(ALERT12);
	return;
   }
   docptr = docbuf;
   docend = docbuf + DOCSIZE - 1;
   
   if(write_tags())
	   ddump();	/* let AES handle error message */
   free(docbuf);
   if(Fclose(fhandle))
	 alert_cntre(ALERT18);
}





read_GOG()
{
   pbufindex = 0;

   Fsetdta(&thedta.res[0]);
   if(Fsfirst("GOG.DFT",0) <= -1)
   {
	return(0);
   }
   fhandle = Fopen("GOG.DFT",0);
   bytes_in = Fread(fhandle,thedta.fsize,GOGbuff);
   Fclose(fhandle);

   GOGgetstr(setp.ftdrs);
   GOGgetstr(setp.edict);
   GOGgetstr(setp.kblyt);
   return(1);
}




GOGgetstr(dpath)
register char *dpath;
{
     while(GOGbuff[GOGindex] != 0x0D)
		*dpath++ = GOGbuff[GOGindex++];
     GOGindex++;			/* get rid of 0x0D */   
     GOGindex++;			/* get rid of 0x0A */   
     *dpath++ = 0x0;
}




write_GOG()
{
        GOGindex = 0;
	GOGputstr(setp.ftdrs);
	GOGputcr();
	GOGputstr(setp.edict);
	GOGputcr();
	GOGputstr(setp.kblyt);
	GOGputcr();
   
	if( (fhandle = Fcreate("GOG.DFT",0)) > 0)
        {
	   Fwrite(fhandle,50L,GOGbuff);
	   Fclose(fhandle);
        }
}



GOGputstr(str)
register char *str;
{
   while(*str)
	  GOGbuff[GOGindex++] = *str++;
}


GOGputcr()
{
   GOGbuff[GOGindex++] = 0x0D;
   GOGbuff[GOGindex++] = 0x0A;
}
