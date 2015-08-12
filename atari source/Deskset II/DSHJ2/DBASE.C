/************************************************************************/
/*									*/
/*	DBASE.C								*/
/*									*/
/*	This file contains the data structures and the associated       */
/* 	routines for the DESKSET II page layout program			*/
/*									*/
/*	ROUTINES:							*/
/*									*/
/*	init_structs()		- Initialize pointers			*/
/*	create_article() 	- Add article structure to list 	*/
/*	add_to_article()	- Add region to article list    	*/
/*	getf_aregion()		- Get current articles first region 	*/
/*	getn_aregion()		- Get current articles next regions 	*/
/*	update_article()	- Set cur. arts. fname and buf_start	*/
/*	get_arttxt()		- Get text ptr of current article  	*/
/*	get_artfname()		- Get file name of article		*/
/* 	put_txtptr()		- Set text ptr of current region	*/
/*	put_txtattr()		- Set attributes of current region	*/
/*	get_txtptr()		- Get text ptr of current region        */
/*	get_txtattr()		- Get text attributes of current region */
/* 	get_grattr()		- Get graphic attributes of curr region */
/*	put_grattr()		- Put graphic attributes of curr region */
/*	add_page()		- Add page structure to page list       */
/*	add_region()		- Add a region to the current page      */
/*	valid_page()		- Set curpage to requested page,        */
/*				  return 0L if this page doesn't exist  */
/*	create_region()		- Call add_region for requested page    */
/*				  Call add_page if necessary		*/
/*	get_fregion()		- Get first region of requested page    */
/*	get_nregion()		- Get subsequent regions after that     */
/*	open_region()		- Make current region = requested one   */
/*	calc_newbounds()	- Calc bounding rectangle of region     */
/*	add_prim()		- Add a primitive to current region     */
/*	put_poly()		- Put a polygon into the primitive list */
/*	put_ellipse()		- Put an ellipse into "   "   "         */
/*	put_image()		- Put an picture into "   "   "		*/
/*	getpts()		- Put current primitive's points into   */
/*				  the global ptsarray			*/
/*	get_fprimitive()	- Get the current regions first prim.   */
/*	get_nprimitive()	- Get the regions next primitives	*/
/*	prev_region()		- Return the region right before the    */
/*				  requested one in the page list        */
/*	find_region()		- Given region at a given x and y 	*/
/*	prev_prim()		- Get primitive before requested one    */
/*	del_pts()		- Delete all blocks of a primitive      */
/*	delete_primitive()	- Delete current primitive		*/
/*	delete_region()		- Delete current region			*/
/* 	unlink_region()		- Unlink region from it's article 	*/
/*	get_fpage()		- Return first page of our page list    */
/*	get_npage()		- Return next pages of our page list    */
/*	prev_page()		- Get page previous to requested one    */
/*	delete_page()		- Delete current page			*/
/*	getf_article()		- Get first article in article list     */
/*	getn_article()		- Get next articles in list		*/
/*	prev_art()		- Get previous article in article list  */
/*	prev_aregion()		- Get prev region in article list       */
/*	delete_article()	- Delete current article 		*/
/*	getpagenum()		- Get page number of current page 	*/
/*	get_regart()		- Return register's article pointer     */
/*	open_article()		- Make given article the current one    */
/*	chk_repel()		- Check graphics repelling		*/
/*	get_curreg()		- return curregion and type		*/
/*	set_repbuff()		- Set gr. regions repel buffer          */
/*									*/
/************************************************************************/

#include "dbase.h"
#include "alert.h"
#include <osbind.h>
#include "deskset2.h"

ARTICLE *artptr;
ARTICLE *curart;
ARTICLE *arthd;

PAGE	*pagehd;
PAGE	*pageptr;
PAGE	*curpage;		/* Current page pointer		     */
PAGE    *clippage;

REGION	*curregion;		/* Current region working region     */
REGION  *sfregion;

PRIMITIVE *curprim;

PTSBLK	*curblk;

SCANINFO *sfscan;

#define NULLPTR 	0x0L
#define DSPOLY   	0
#define DSELLIPSE 	1
#define DSPICTURE	2
#define DSLINE		3
#define DSRBOX		4

#define NUMGRATTRS	9		/* Number of text attributes    */

int	ptsarray[256];			/* Global array where points are */
					/* Passed between data base and  */
					/* main module			 */

extern REGION   *insert_regptr;
extern unsigned char *buf_start;
extern unsigned char *buf_end;
extern unsigned char *free_start;
extern unsigned char *current_char;
extern char *get_lcmem();

extern int hpage_size;
extern int curr_page;

extern unsigned long scanptr;
extern int alerted;
extern int alt_offset;
extern int view_size;



/*************************************************************************/
/* Function: init_structs()						 */
/* Description:							  	 */
/*************************************************************************/
init_structs()
{
	arthd =	pagehd = NULLPTR;
}



/*************************************************************************/
/* Function: get_regart()						 */
/* Description:								 */
/*************************************************************************/
ARTICLE *get_regart(rptr)
REGION *rptr;
{
	return rptr->artptr;
}



/*************************************************************************/
/* Function: open_article()						 */
/* Description:								 */
/*************************************************************************/
open_article(aptr)
ARTICLE *aptr;
{
	curart = aptr;
}



/*************************************************************************/
/* Function: create_article()						 */
/* Description: Add an article to the article list			 */
/*************************************************************************/
create_article()
{
	ARTICLE *newart;

        newart = (ARTICLE *)get_lcmem((long)sizeof(ARTICLE));
	newart->nextart = NULLPTR;
  	if(arthd == NULLPTR)
	{
		arthd = newart;
	}
	else
	{
	   	artptr = arthd;

		while(artptr->nextart != NULLPTR)
			artptr = artptr->nextart;
		artptr->nextart = newart;
	}
	curart = newart;
}




/*************************************************************************/
/* Function: add_to_article()						 */
/* Description:	Add a region to the article list			 */
/*************************************************************************/
add_to_article(rptr)
register REGION *rptr;
{
	register REGION *regionptr;

	rptr->artptr = curart;
	regionptr = curart->regptr;
	if(regionptr == NULLPTR)
	{
	   curart->regptr = rptr;
	}
	else
	{	
	   while(regionptr->alink != NULLPTR)
	   {
		if(regionptr == rptr)
		    return;
		regionptr = regionptr->alink;
	   }
	   regionptr->alink    = rptr;
	}
}



/*************************************************************************/
/* Function: insert_to_article(()					 */
/* Description: Insert the region into the given article after		 */
/* the given region  							 */
/*************************************************************************/
insert_to_article(aptr,regptr,rptr)
ARTICLE *aptr;				/* Article to link to            */
REGION *regptr;				/* Region to link after          */
register REGION *rptr;			/* The region to link in	 */
{
	rptr->artptr = aptr;		
	rptr->alink = regptr->alink;	/* Link in the article		 */
	regptr->alink = rptr;
	insert_regptr = rptr;
}



/*************************************************************************/
/* Function: getf_aregion()						 */
/* Description: Get the first region in the article list pointed to      */
/* by curart 							         */
/*************************************************************************/
REGION *getf_aregion(x1,y1,x2,y2,page)
int *x1;
int *y1;
int *x2;
int *y2;
int *page;
{
   if(curart->regptr == NULLPTR)
	return (REGION *)NULLPTR;
   else
   {
	curregion = curart->regptr;
	*x1 = curregion->x1;
	*y1 = curregion->y1;
	*x2 = curregion->x2;
	*y2 = curregion->y2;
	*page = curregion->p;
	return curregion;
   }
}



/*************************************************************************/
/* Function: getn_aregion()						 */
/* Description:	Return the next article int curarts article list	 */
/*************************************************************************/
REGION 	*getn_aregion(x1,y1,x2,y2,page)
int *x1;
int *y1;
int *x2;
int *y2;
int *page;
{
   if(curregion->alink == NULLPTR)
      	return (REGION *)NULLPTR;
   else
   {
      	curregion = curregion->alink;
	*x1 = curregion->x1;
	*y1 = curregion->y1;
	*x2 = curregion->x2;
	*y2 = curregion->y2;
	*page = curregion->p;
     	return curregion;
   }
}


/*************************************************************************/
/* Function: get_arttxt()						 */
/* Description:	Return the text pointer for the current article		 */
/*************************************************************************/
char *get_arttxt()
{
   return(curart->buf_start);
}



/*************************************************************************/
/* Function: get_artfname()						 */
/* Description: Return the filename pointer for the current article	 */
/*************************************************************************/
char *get_artfname()
{
   return(curart->filename);
}



/*************************************************************************/
/* Function: put_txtptr()						 */
/* Description:	Fill in a regions textptr.				 */
/*************************************************************************/
put_txtptr(rptr,charptr)
REGION  *rptr;
char	*charptr;
{
   rptr->txtstart = charptr;
}



/*************************************************************************/
/* Function: put_grattr()						 */
/* Description:	Fill in a regions graphic attributes			 */
/*************************************************************************/
put_grattr(rptr,attr)
register REGION  *rptr;
register int	attr[];
{
   register int i;

   for(i = 0;i < NUMGRATTRS;i++)
   {
	rptr->grattr[i] = attr[i];
   }
}



/*************************************************************************/
/* Function: put_txtattr()						 */
/* Description:	Fill in a regions text attributes			 */
/*************************************************************************/
put_txtattr(rptr,attr)
REGION  *rptr;
struct txtattr	*attr;
{
   rptr->text = *attr;
}



/************************************************************************/
/* Function: get_txtptr()					        */
/* Description: Return the requested regions text pointer		*/
/************************************************************************/
char *get_txtptr(rptr)
REGION  *rptr;
{
   return(rptr->txtstart);
}



/************************************************************************/
/* Function: get_grattr()						*/
/* Description: Return the requested regions graphics attribute list	*/
/************************************************************************/
get_grattr(rptr,attr)
register REGION  *rptr;
register int	attr[];
{
   register int i;

   for(i = 0;i < NUMGRATTRS;i++)
	attr[i] = rptr->grattr[i];
}



/************************************************************************/
/* Function: get_txtattr()						*/
/* Description: Return the requested regions attribute list		*/
/************************************************************************/
get_txtattr(rptr,attr)
REGION  *rptr;
struct txtattr *attr;
{
	*attr = rptr->text;
}



/*************************************************************************/
/* Function: update_article()						 */
/* Description:	Put the given filename and base address into the	 */
/* current article 							 */
/*************************************************************************/
update_article(fname)
char *fname;
{
	strcpy(&curart->filename[0],fname);
	curart->buf_start = buf_start;
	curart->buf_end   = buf_end;
	curart->free_start = free_start;
	curart->current_char = current_char;
}




/*************************************************************************/
/* Function: get_buffvars()						 */
/* Descrition:								 */
/*	Update the --GLOBAL-- buffer pointers with the ones from the     */
/*	article pointed to by the given region  			 */
/*************************************************************************/
get_buffvars(rptr)
REGION *rptr;
{
   register ARTICLE *aptr;

   aptr = rptr->artptr;
   buf_start = aptr->buf_start;
   buf_end   = aptr->buf_end;
   free_start = aptr->free_start;
   current_char = aptr->current_char;
}



/*************************************************************************/
/* Function: get_abuffvars()						 */
/* Description:								 */
/*	Update the --GLOBAL-- buffer pointers with the ones from the     */
/*	article pointed to			  			 */
/*************************************************************************/
get_abuffvars(aptr)
register ARTICLE *aptr;
{
   buf_start = aptr->buf_start;
   buf_end   = aptr->buf_end;
   free_start = aptr->free_start;
   current_char = aptr->current_char;
}



/************************************************************************/
/* Function: put_abuffvars()					        */
/* Description:								*/
/*	Update the articles buffer pointers with the ones in the        */
/*	--GLOBAL-- variables.  Article is found from the given		*/
/*	article pointer							*/
/************************************************************************/
put_abuffvars(aptr)
register ARTICLE *aptr;
{
   aptr->buf_start = buf_start;
   aptr->buf_end   = buf_end;
   aptr->free_start = free_start;
   aptr->current_char = current_char;
}



/*************************************************************************/
/* Function: put_buffvars()						 */
/* Description:								 */
/*************************************************************************/
put_buffvars(rptr)
REGION *rptr;
{
   register ARTICLE *aptr;

   aptr = rptr->artptr;
   aptr->buf_start = buf_start;
   aptr->buf_end   = buf_end;
   aptr->free_start = free_start;
   aptr->current_char = current_char;
}



	
/*************************************************************************/
/* Function: add_page()							 */
/* Description:	Add a page to the page list				 */
/*************************************************************************/
add_page(dpage)
int dpage;
{
	register PAGE	*newpage;
        register PAGE   *prev_ptr;
        register PAGE   *curr_ptr;

        newpage = (PAGE *)get_lcmem((long)sizeof(PAGE));

        if(pagehd == NULLPTR)			/* no pages  */
	{
		pagehd = newpage;
		newpage->nextpage = NULLPTR;
	}
	else
	{
	     curr_ptr = prev_ptr = pageptr = pagehd;
	   
	     if(dpage < pageptr->pagenum)		/* 1 page */
	     {
			newpage->nextpage = pagehd;
			pagehd = newpage;
	     }
	     else
	     {
		prev_ptr = pageptr;
		pageptr = pageptr->nextpage;

		for(;;)
		{
		    if(pageptr == NULLPTR)
	            {
			newpage->nextpage = NULLPTR;
			prev_ptr->nextpage = newpage;
			break;
		    }
		    else		/* check pagenum in node */
		    {
			if(dpage < pageptr->pagenum)
			{
			      newpage->nextpage = pageptr;
			      prev_ptr->nextpage = newpage;
			      break;
			}
			else
			{
			    prev_ptr = pageptr;
			    pageptr = pageptr->nextpage;
			}
		    }
		    
		}
	     }
	}
	newpage->pagenum = dpage;
	newpage->regptr = NULLPTR;
	curpage = newpage;
}



/**************************************************************************/
/* Function: add_region()						  */
/* Description:								  */
/*	Add a region to the page pointed to by curpage.			  */
/* 	Make curregion point to this newly created region		  */
/**************************************************************************/
add_region(type)
int type;
{
	register REGION	*regionptr;

        curregion = (REGION *)get_lcmem((long)sizeof(REGION));
	regionptr = curpage->regptr;
	if(regionptr == NULLPTR)
	{
	   curpage->regptr = curregion;
	}
	else
	{	
	   while(regionptr->plink != NULLPTR)
		regionptr = regionptr->plink;
	   regionptr->plink    = curregion;
	}
	curregion->plink    = NULLPTR;
	curregion->x1       = 0;
	curregion->y1       = 0;
	curregion->x2 	    = 0;
	curregion->y2	    = 0;
	curregion->p        = curpage->pagenum;
	curregion->type	    = type;
	curregion->primlist = NULLPTR;
	curregion->artptr   = NULLPTR;
	curregion->alink    = NULLPTR;
}




/************************************************************************/
/* Function: valid_page()						*/
/* Description:								*/
/*	Make curpage point to the page structure specified by "dpage" 	*/
/* 	If no such page exists, return 0				*/
/************************************************************************/
int valid_page(dpage)
int dpage;
{
   int found;
   register PAGE *pptr;


   found = FALSE;
   pptr = pagehd;
   if(pptr == NULLPTR)
	return FALSE;
   do
   {
	if(pptr->pagenum == dpage)
        {
	   found = TRUE;
	   curpage = pptr;
	   break;
	}
   	pptr = pptr->nextpage;
   }while(pptr != NULLPTR);
   return found;
}



/************************************************************************/
/* Function: ins_page()						 	*/
/* Description: 							*/
/*	Insert a page by bumping the page number of all pages >= to     */
/*	current one.							*/
/************************************************************************/
int ins_page()
{
   register PAGE *pptr;
   register REGION *rptr;

   pptr = pagehd;
   if(pptr == NULLPTR)
	return FALSE;
   do
   {
	if(pptr->pagenum >= curr_page)
        {
	   pptr->pagenum += 1;
           rptr = pptr->regptr;
	   while(rptr)
	   {
	    rptr->p = pptr->pagenum;
	    rptr = rptr->plink;
	   }
	}
   	pptr = pptr->nextpage;
   }while(pptr != NULLPTR);
}



/**************************************************************************/
/* Function: create_region()						  */
/* Description:								  */
/*	Create a region on the specified page.  If this page does not 	  */
/*	exist, create a new one and fill in as many empty pages as needed */
/* 	in between.  Make this region the current one pointed to by       */
/*	curregion.							  */
/**************************************************************************/
REGION *create_region(page,type)
int page;
int type;
{
   if(!valid_page(page))
	add_page(page);
   add_region(type);
   return curregion;
}



/**************************************************************************/
/* Function: get_fregion()						  */
/* Description:								  */
/*	Get the first region on the specified page.  If none exist on the */
/*	page return NULLPTR.						  */
/**************************************************************************/
REGION	*get_fregion(page,x1,y1,x2,y2,type)
int	page;
int	*x1;
int	*x2;
int	*y1;
int 	*y2;
int	*type;
{
   if(!valid_page(page))
	return (REGION *)NULLPTR;
   if(curpage->regptr == NULLPTR)
	return (REGION *)NULLPTR;
   else
   {
	sfregion = curpage->regptr;
	*x1 = sfregion->x1;
	*y1 = sfregion->y1;
	*x2 = sfregion->x2;
	*y2 = sfregion->y2;
	*type = sfregion->type;
	return sfregion;
   }
}



/**************************************************************************/
/* Function: get_nregion()						  */
/* Description:								  */
/*	Get subsequent regions after the one returned by get_fregion.     */
/* 	If no other regions exist, NULLPTR is returned.  Note: A 	  */
/* 	get_fregion must be made sometime before this call.		  */
/**************************************************************************/
REGION 	*get_nregion(x1,y1,x2,y2,type)
int *x1;
int *y1;
int *x2;
int *y2;
int *type;
{
   if(sfregion->plink == NULLPTR)
      	return (REGION *)NULLPTR;
   else
   {
      	sfregion = sfregion->plink;
	*x1 = sfregion->x1;
	*y1 = sfregion->y1;
	*x2 = sfregion->x2;
	*y2 = sfregion->y2;
	*type = sfregion->type;
     	return sfregion;
   }
}




/**************************************************************************/
/* Function: open_region()						  */
/* Description:								  */
/* 	Open a region by simply having curregion point to the requested   */
/*	region.								  */
/**************************************************************************/
open_region(regptr)
REGION *regptr;
{
   curregion = regptr;
}




/**************************************************************************/
/* Function: calc_newbounds()						  */
/* Description:								  */
/*	Determine the new bounding rectangle that will enclose all of the */
/*	primitives of the current region.  If "first_prim" is true then   */
/*	just insert the new primitives minx,miny,maxx,maxy into           */
/*	curregions appropriate variables.  If false then compare these    */
/* 	values to curregions current variables to see whether they need   */
/*	to be replaced or not.						  */
/**************************************************************************/
calc_newbounds(first_prim,op,count)
int first_prim;
int op;
register int count;
{
   register int minx,miny,maxx;
   int maxy;
   register int i;
   
   if(op == DSELLIPSE)
   {
	minx = ptsarray[0] - ptsarray[2];
	maxx = ptsarray[0] + ptsarray[2];
	miny = ptsarray[1] - ptsarray[3];
	maxy = ptsarray[1] + ptsarray[3];
   }
   else if((op == DSPOLY) || (op == DSLINE) || (op == DSRBOX))
   {
	i = 0;
	--count;
	minx = maxx = ptsarray[i++];
	miny = maxy = ptsarray[i++];
	while(count--)
	{
	   if(ptsarray[i] > maxx)
		maxx = ptsarray[i];
	   if(ptsarray[i] < minx)
		minx = ptsarray[i];
	   i++;
	   if(ptsarray[i] > maxy)
		maxy = ptsarray[i];
	   if(ptsarray[i] < miny)
		miny = ptsarray[i];
	   i++;
	}
   }
   else if(op == DSPICTURE)
   {
	minx = ptsarray[0];
        miny = ptsarray[1];
        maxx = ptsarray[2];
	maxy = ptsarray[3];
   }

   if(first_prim)			    /* First primitive in list */
   {
	curregion->x1 = minx;
	curregion->x2 = maxx;
	curregion->y1 = miny;
	curregion->y2 = maxy;
   }
   else
   {
      if(minx < curregion->x1)
         curregion->x1 = minx;
      if(maxx > curregion->x2)
         curregion->x2 = maxx;
      if(miny < curregion->y1)
         curregion->y1 = miny;
      if(maxy > curregion->y2)
         curregion->y2 = maxy;
   }
}




/**************************************************************************/
/* Function: add_prim()							  */
/* Description:								  */
/*	Called by put_poly and put_ellipse.  Allocates space for a new    */
/* 	primitive and links it in to curregions primitive list.  Also     */
/*	allocate an initial points block to store the primitives coords.  */
/**************************************************************************/
add_prim(op,count,wrmode)
int op;
int count;
int wrmode;
{
   int first_prim;
   register PRIMITIVE *primptr;

   curprim = (PRIMITIVE *)get_lcmem((long)sizeof(PRIMITIVE));
   primptr = curregion->primlist;
   if(primptr == NULLPTR)
	{
	first_prim = TRUE;
   	curregion->primlist = curprim;
	}
   else
   {
	first_prim = FALSE;
	while(primptr->nextprim != NULLPTR)
	    primptr = primptr->nextprim;
	primptr->nextprim = curprim;
   }
   curprim->op = op;
   curprim->wrmode = wrmode;
   curprim->numpts = count;
   curblk = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
   curprim->blkptr = curblk;
   curblk->nextblk = NULLPTR;
   calc_newbounds(first_prim,op,count);
}




/**************************************************************************/
/* Function: put_poly()							  */
/* Description:								  */
/*	Add a polygon to the current region.  Grab points from the global */
/*	points array and allocate as many points blocks as necessary.	  */
/**************************************************************************/
put_poly(op,count,write_mode,type)
int op;
register int count;
int write_mode;
int type;
{
   register int i,j;

   add_prim(op,count,write_mode,type);
   i = j = 0;
   count *= 2;
   while(count--)
   {
	curblk->points[i++] = ptsarray[j++];
	if(i >= MAXBLK)
	{
	   curblk->nextblk = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
	   curblk = curblk->nextblk;
   	   curblk->nextblk = NULLPTR;
	   i = 0;
	}
   }
}



/**************************************************************************/
/* Function: put_ellipse()						  */
/* Description:	Put an ellipse into curregions primitive list		  */
/**************************************************************************/
put_ellipse(write_mode,type)
int write_mode;
{
   register int i;

   add_prim(DSELLIPSE,2,write_mode,type);
   for(i = 0;i < 4;i++)
	curblk->points[i] = ptsarray[i];
}   




/**************************************************************************/
/* Function: put_image()						  */
/* Description:								  */
/*	Put a picture descripter into curregions primitive list		  */
/*	Assume the bounding rectangle is stored in the global ptsarray    */
/*	Store the file name and other info using the put_poly call	  */
/*	ptsarray[0] = x1;						  */
/*	ptsarray[1] = y1;						  */
/*	ptsarray[2] = x2;						  */
/*	ptsarray[3] = y2;						  */
/*	ptsarray[4] = picture type --- 0 = Neo,1 = img,2 = Meta		  */
/*	ptsarray[5]...... = filename					  */
/**************************************************************************/
put_image(fname,pictype)
char *fname;
int  pictype;
{
	register int len;

	ptsarray[2] = ptsarray[4];
	ptsarray[3] = ptsarray[5];
	ptsarray[4] = pictype;
	len = strlen(fname);		/* Number of chars		  */
	len = (len/2)+4;		/* Number of ints required        */
	strcpy(&ptsarray[5],fname);
	put_poly(2,len,1,1);
}


	
/**************************************************************************/
/* Function: getpts()							  */
/* Description:								  */
/*	Get the points stored in the primitive pointed to by curprim and  */
/*	place them into the global ptsarray.				  */
/**************************************************************************/
getpts()
{
   register PTSBLK *curblk;
   register int i,j;
   register int  count;

   count = curprim->numpts;
   curblk = curprim->blkptr;
   i = j = 0;
   count *= 2;
   while(count--)
   {
	ptsarray[j++] = curblk->points[i++];
	if(i >= MAXBLK)
	{
	   curblk = curblk->nextblk;
	   i = 0;
	}
   }
}



/**************************************************************************/
/* Function: get_fprimitive()						  */
/* Description:								  */
/*	Get the first primitive of the requested region. If no primitives */
/*	exist return a -1 as the opcode.  Fill in the points count and    */
/*	writing mode and return the opcode in d0			  */
/**************************************************************************/
int get_fprimitive(rptr,count,wrmode)
REGION *rptr;
int *count;
int *wrmode;
{

   if(rptr->primlist == NULLPTR)
   {
   	*count = 0;
      	return -1;
   }
   else
   {
	curprim = rptr->primlist;
	*count = curprim->numpts;
	*wrmode = curprim->wrmode;
	getpts();
	return curprim->op;
   }
}



/**************************************************************************/
/* Function: get_nprimitive()						  */
/* Description:								  */
/* 	Get subsequent primitives after the one returned by the get_fprim */
/*	call.								  */
/**************************************************************************/
int get_nprimitive(count,wrmode)
int *count;
int *wrmode;
{
   if(curprim->nextprim == NULLPTR)
   {
	*count = 0;
	return -1;
   }
   else
   {
	curprim = curprim->nextprim;
	*count = curprim->numpts;
  	*wrmode = curprim->wrmode;
 	getpts();
	return curprim->op;
   }
}



/**************************************************************************/
/* Function: prev_region()						  */
/* Description:								  */
/*	return the region just previous to the given region.  Return 0L   */
/*	if no other regions exist.  Assume curpage points to the current  */
/*	page.								  */
/**************************************************************************/
REGION *prev_region(rptr)
REGION *rptr;
{
   register REGION *tptr;

   tptr = curpage->regptr;
   if(tptr == rptr)
	return NULLPTR;
   else
   {
	while(tptr->plink != rptr)
	   tptr = tptr->plink;
	return tptr;
   }
}




/**************************************************************************/
/* Function: find_boundary()						  */
/* Description: Return the boundary points for the given region pointer	  */
/**************************************************************************/
find_boundary(rptr,minx,miny,maxx,maxy,type,page)
register REGION *rptr;
int *minx;
int *miny;
int *maxx;
int *maxy;
int *type;
int *page;
{
	   *minx = rptr->x1;
	   *miny = rptr->y1;
	   *maxx = rptr->x2;
	   *maxy = rptr->y2;
	   *type = rptr->type;
	   *page = rptr->p;
	   curregion = rptr;
}




/**************************************************************************/
/* Function: find_region()						  */
/* Description:								  */
/*	Return the region whose boundaries enclose the given location.    */
/*	return the boundary points for the callers use.			  */
/**************************************************************************/
REGION	*find_region(x,y,p,minx,miny,maxx,maxy,type)
int x,y;
int p;
int *minx;
int *miny;
int *maxx;
int *maxy;
int *type;
{
   int xoffset,yoffset;			/* Offset for 1 pixel of mu's */
   int xadjust,yadjust;
   register REGION *rptr;
   int temp;

   temp = alt_offset;
   scrntomu(2,2,&xoffset,&yoffset,1);
   alt_offset = temp;

   if(!valid_page(p))
	return (REGION *)NULLPTR;
   rptr = curpage->regptr;
   if(rptr == NULLPTR)
	return (REGION *)NULLPTR;
   while(rptr->plink != NULLPTR)   
   {
	rptr = rptr->plink;
   }
   do
   {
        if(rptr->x1 == rptr->x2 || rptr->y1 == rptr->y2)
	{
		xadjust = xoffset * 3;
		yadjust = yoffset * 3;
        }
	else
	{
		xadjust = xoffset;
		yadjust = yoffset;
  	}
		
	if(x >= (rptr->x1)-xadjust && x <= (rptr->x2)+xadjust &&
	   y >= (rptr->y1)-yadjust && y <= (rptr->y2)+yadjust)
	{
	   *minx = rptr->x1;
	   *miny = rptr->y1;
	   *maxx = rptr->x2;
	   *maxy = rptr->y2;
	   *type = rptr->type;
	   curregion = rptr;
	   return rptr;
	}
 	rptr = prev_region(rptr);
   }while(rptr != NULLPTR);
   return (REGION *)NULLPTR;
}




/*************************************************************************/
/* Function: find_page()						 */
/* Description:								 */
/*************************************************************************/
find_page(rptr,page)
REGION *rptr;
int *page;
{
   if(rptr)
   {
      *page = rptr->p;
      curregion = rptr;
      return 1;
   }
   else
      return 0;
}



/**************************************************************************/
/* Function: inside_region()						  */
/* Description:								  */
/*	Return the region whose boundaries enclose the given location.    */
/*	return the boundary points for the callers use.			  */
/**************************************************************************/
int inside_region(x,y,rptr,minx,miny,maxx,maxy,type,page)
int x,y;
register REGION *rptr;
int *minx;
int *miny;
int *maxx;
int *maxy;
int *type;
int *page;
{
   int xoffset,yoffset;			/* Offset for 1 pixel of mu's */
   int temp;

   temp = alt_offset;
   scrntomu(2,2,&xoffset,&yoffset,1);
   alt_offset = temp;

   if(rptr->x1 == rptr->x2 || rptr->y1 == rptr->y2)
   {
		xoffset *= 3;
		yoffset *= 3;
   }
   if(x >= (rptr->x1)-xoffset && x <= (rptr->x2)+xoffset &&
      y >= (rptr->y1)-yoffset && y <= (rptr->y2)+yoffset)
      {
	   *minx = rptr->x1;
	   *miny = rptr->y1;
	   *maxx = rptr->x2;
	   *maxy = rptr->y2;
	   *type = rptr->type;
	   *page = rptr->p;
	   curregion = rptr;
	   return 1;
      }
      else
	   return 0;
}




/**************************************************************************/
/* Function: prev_prim()						  */
/* Description:								  */
/*	Return the previous primitive in the primitive list.  If there    */
/*	isn't a previous primitive, return 0L.  Assume that curregion     */
/*	points to the region that is at the head of the current primitive */
/*	list.								  */
/**************************************************************************/
PRIMITIVE *prev_prim(pptr)
register PRIMITIVE *pptr;
{
   register PRIMITIVE *tptr;

   tptr = curregion->primlist;
   if(tptr == pptr)
	return NULLPTR;
   else
   {
      	while(tptr->nextprim != pptr)
	   tptr = tptr->nextprim;
	return tptr;
   }
}




/**************************************************************************/
/* Function: prev_blk()							  */
/* Description:	Return the previous ptsblk to the one that is given	  */
/**************************************************************************/
PTSBLK *prev_blk(pptr)
register PTSBLK *pptr;
{
   register PTSBLK *tptr;

   tptr = curprim->blkptr;
   if(tptr == pptr)
	return NULLPTR;
   else
   {
      	while(tptr->nextblk != pptr)
	   tptr = tptr->nextblk;
	return tptr;
   }
}




/**************************************************************************/
/* Function: del_pts()							  */
/* Description:	Delete all of the blocks associated with the given pointer*/
/**************************************************************************/
del_pts()
{
   register PTSBLK *tblk;
   register PTSBLK *pblk;

   pblk = tblk = curprim->blkptr;
   if(tblk == NULLPTR)
	return;
   while(tblk != NULLPTR)
   {
	tblk = pblk->nextblk;
	free(pblk);
	pblk = tblk;
   }
}




/**************************************************************************/
/* Function: delete_primitive()						  */
/* Description:								  */
/*	Delete the current primitive pointed to by curprim.  Fix up links */
/* 	and do a free on the memory.  Assume that curprim belongs to      */
/*	the region pointed to by curregion.  Return 0 if there are no     */
/* 	other primitives in this region to delete.			  */
/**************************************************************************/
delete_primitive()
{
   PRIMITIVE *pprim;
   PRIMITIVE *tmpprim;

   if(curregion->primlist == NULLPTR)
	return(FALSE);
   pprim = prev_prim(curprim);
   if(pprim == NULLPTR)
   {
	curregion->primlist = curprim->nextprim;
    	tmpprim = curprim->nextprim;
   }
   else
   {

	pprim->nextprim = curprim->nextprim;   
	tmpprim = pprim;
   }
   del_pts();
   free(curprim);
   curprim = tmpprim;
   return(TRUE);
}




/**************************************************************************/
/* Function: delete_region()						  */
/* Description:								  */
/*	Delete the region pointed at by curregion.  Return 0 if there are */
/*	no regions to delete.  Set curregion to the region right before   */
/* 	the deleted one.  If no other regions exist set it to NULLPTR.    */
/**************************************************************************/
delete_region(rptr)
register REGION *rptr;
{
   REGION *pregion;
   register ARTICLE *artptr;
   register REGION *tregion;
   REGION *tmpregion;
   REGION *tmpcur;

   if(curpage->regptr == NULLPTR)
	return(FALSE);
   pregion = prev_region(rptr);
   if(pregion == NULLPTR)
   {
	curpage->regptr = rptr->plink;
	tmpregion = rptr->plink;
   }
   else
   {
	pregion->plink = rptr->plink;
        tmpregion = pregion;   
   }
   artptr = rptr->artptr;			/* Delete from article list */
   if(artptr != NULLPTR)
   {
      tregion = artptr->regptr;
      if(tregion == rptr)
	 artptr->regptr = tregion->alink;
      else
      {
      	 while(tregion->alink != rptr)
      	 {
	     tregion = tregion->alink;
   	 }
         tregion->alink = rptr->alink;
      }
   }
   tmpcur = curregion;
   curregion = rptr;
   curprim = prev_prim(NULLPTR);
   while(delete_primitive());
						/* Get last primitive in    */
						/* list (primitive right    */
						/* before NULLPTR.	    */
						/* Delete all prims in the  */
						/* list.  Assume curprim is */	
						/* updated by delete_prim.  */
   free_scanrects(rptr);			/* free scanlist structs    */
   curregion = tmpcur;				/* Restore curregion	    */
   free(rptr);
   return(TRUE);
}



/*************************************************************************/
/* Function: unlink_region()						 */
/* Description:								 */
/*************************************************************************/
unlink_region(rptr)
register REGION *rptr;
{
   ARTICLE *artptr;
   register REGION *tregion;

   artptr = rptr->artptr;			/* Delete from article list */
   if(artptr != NULLPTR)
   {
      tregion = artptr->regptr;
      if(tregion == rptr)
	 artptr->regptr = tregion->alink;
      else
      {
      	 while(tregion->alink != rptr)
      	 {
	     tregion = tregion->alink;
   	 }
         tregion->alink = rptr->alink;
      }
      rptr->artptr = (ARTICLE *)NULLPTR;
      rptr->alink = (ARTICLE *)NULLPTR;
      rptr->txtstart = (char *)0L;
      free_scanrects(rptr);
   }
}



/****************************************************************************/
/* Function: get_fpage()						    */
/* Description: Find the first page in our data structure.		    */
/****************************************************************************/
PAGE *get_fpage(pagenum)
int *pagenum;
{
   if(pagehd == NULLPTR)
	return NULLPTR;
   else	   
   {
	*pagenum = pagehd->pagenum;
	curpage = pagehd;
	return curpage;
   }
}



/****************************************************************************/
/* Function: get_npage()						    */
/* Description: Find the subsequent pages in our data structure.	    */
/****************************************************************************/
PAGE *get_npage(pagenum)
int *pagenum;
{
   if(curpage->nextpage == NULLPTR)
	return NULLPTR;
   else
   {
	curpage = curpage->nextpage;
	*pagenum = curpage->pagenum;
	return curpage;
   }
}




/****************************************************************************/
/* Function: prev_page()						    */
/* Description:	Find the page just before the requested one		    */
/****************************************************************************/
PAGE *prev_page(pptr)
register PAGE *pptr;
{
   register PAGE *tptr;

   tptr = pagehd;
   if(tptr == pptr)
	return NULLPTR;
   else
   {
	while(tptr->nextpage != pptr)
	   tptr = tptr->nextpage;
	return tptr;
   }
}



/****************************************************************************/
/* Function: delete_page()						    */
/* Description:	Delete the page pointed to by curpage.			    */
/****************************************************************************/
int delete_page()
{
   PAGE *ppage;
   PAGE *tmppage;
   int tpage;
   int dummy;
   register REGION *rptr;
   register PAGE *pptr;

   if(pagehd == NULLPTR)
	return FALSE;


   pptr = pagehd;		/* all pages AFTER the current one  */
   do				/* have their page numbers bumped   */
   {				/* DOWN by 1 due to deletion of page*/
      if(pptr->pagenum > curr_page)
      {
        pptr->pagenum -= 1;
        rptr = pptr->regptr;
	while(rptr)
	{
	 rptr->p = pptr->pagenum;
	 rptr = rptr->plink;
	}
      }
      pptr = pptr->nextpage;
   }while(pptr != NULLPTR);
   

   tpage = curpage->pagenum;
   rptr = get_fregion(tpage,&dummy,&dummy,&dummy,&dummy,&dummy);
   if(rptr != NULLPTR)
   {
       	while(rptr)
       	{
       	delete_region(rptr);
        rptr = get_nregion(&dummy,&dummy,&dummy,&dummy,&dummy);
       }
   }

   ppage = prev_page(curpage);
   if(ppage == NULLPTR)
   {
	if(curpage->nextpage == NULLPTR)
	   pagehd = NULLPTR;
	else
	{
	   pagehd = curpage->nextpage;
	   tmppage = pagehd;
        }
   }
   else
   {
	ppage->nextpage = curpage->nextpage;
	tmppage = ppage;   
   }
   free(curpage);
   curpage = tmppage;
   return(TRUE);
}





/****************************************************************************/
/* Function: getf_article()						    */
/* Description:	Find the first article in our data structure.		    */
/****************************************************************************/
ARTICLE *getf_article()
{
   if(arthd == NULLPTR)
	return NULLPTR;
   else	   
   {
	curart = arthd;
	return curart;
   }
}



/****************************************************************************/
/* Function: getn_article()						    */
/* Description:	Find the subsequent pages in our data structure.	    */
/****************************************************************************/
ARTICLE *getn_article()
{
   if(curart->nextart == NULLPTR)
	return NULLPTR;
   else
   {
	curart = curart->nextart;
	return curart;
   }
}



/**************************************************************************/
/* Function: prev_aregion()						  */
/* Description:								  */
/*	Return the region just previous to the given region.  Return 0L   */
/*	if no other regions exist.  Assume curart points to the current   */
/*	article.	(SEARCH BY ARTICLE LINKS)			  */
/**************************************************************************/
REGION *prev_aregion(rptr)
register REGION *rptr;
{
   register REGION *tptr;
   ARTICLE *artptr;

   artptr = rptr->artptr;
   if(!artptr)
	return NULLPTR;
   tptr = artptr->regptr;
   if(tptr == rptr)
	return NULLPTR;
   else
   {
	while(tptr->alink != rptr)
	   tptr = tptr->alink;
	return tptr;
   }
}




/****************************************************************************/
/* Function: prev_art()							    */
/* Description:	Find the article just before requested one		    */
/****************************************************************************/
ARTICLE *prev_art(aptr)
register ARTICLE *aptr;
{
   register ARTICLE *tptr;

   tptr = arthd;
   if(tptr == aptr)
	return NULLPTR;
   else
   {
	while(tptr->nextart != aptr)
	   tptr = tptr->nextart;
	return tptr;
   }
}




/****************************************************************************/
/* Function: delete_article()						    */
/* Description:	Delete the article pointed to by curart.		    */
/****************************************************************************/
int delete_article()
{
   ARTICLE *prevart;
   register REGION *rptr;
   REGION *prev_reg;

   if(arthd == NULLPTR)
	return FALSE;
   prevart = prev_art(curart);
   if(prevart == NULLPTR)
   {
	if(curart->nextart == NULLPTR)
           arthd = NULLPTR;
	else
	{
	   arthd = prevart = curart->nextart;
	}
   }
   else
   {
	prevart->nextart = curart->nextart;   
   }


   rptr = curart->regptr;
   if(rptr != NULLPTR)
   {
      while(rptr->alink != NULLPTR)   
      {
	 rptr = rptr->alink;
      }
      do
      {
	   prev_reg = prev_aregion(rptr);
	   rptr->artptr = NULLPTR;	/* Restore region variables */
	   rptr->alink  = NULLPTR;
	   rptr->txtstart = NULLPTR;
	   free_scanrects(rptr);
	   rptr = prev_reg;
      }while(rptr != NULLPTR);
   }
   free(curart->buf_start);
   free(curart);
   curart = prevart;
   return(TRUE);
}



/**************************************************************************/
/* Function: getpagenum()						  */
/* Description:	Get the page number of the current page			  */
/**************************************************************************/
getpagenum()
{
	if(pagehd == NULLPTR)
		return 1;
	return curpage->pagenum;
}




/*************************************************************************/
/* Function: update_primitive()						 */
/* Description: 							 */
/*************************************************************************/
update_primitive(op,count,wrmode,first_prim)
int op;
register int count;
int wrmode;
int first_prim;
{
   register int i,j;

   curprim->op = op;		/* ok, not really needed...     */
   curprim->numpts = count;     /* would count change? probably */
   curprim->wrmode = wrmode;    /* probably not change also...  */
   del_pts();

   curblk = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
   curprim->blkptr = curblk;
   curblk->nextblk = NULLPTR;
   calc_newbounds(first_prim,op,count);   /* first prim is needed */

   switch(op)			/* update ptsarray info according*/
   {				/* to the op...			 */
     case DSRBOX:
     case DSLINE:
     case DSPOLY:  i = j = 0;
   		   count *= 2;
   		   while(count--)
		   {
		   curblk->points[i++] = ptsarray[j++];
		     if(i >= MAXBLK)
		     {
		        curblk->nextblk = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
	   	        curblk = curblk->nextblk;
   	   	        curblk->nextblk = NULLPTR;
	   	        i = 0;
		     }
   		   }
		   break;

     case DSELLIPSE:    for(i=0;i < 4;i++)
			   curblk->points[i] = ptsarray[i];
			break;

     case DSPICTURE:    i = j = 0;
			count *= 2;
   		        while(count--)
		        {
		           curblk->points[i++] = ptsarray[j++];
		           if(i >= MAXBLK)
		           {
	                   curblk->nextblk = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
	   	           curblk = curblk->nextblk;
   	   	           curblk->nextblk = NULLPTR;
	   	           i = 0;
			   }
		        }
			break;
   }
}




/*************************************************************************/
/* Function: gr_intersect()						 */
/* Description:								 */
/*************************************************************************/
int gr_intersect(repel_mode,repoffset,rptr,rect)
int repel_mode;
int repoffset;
register REGION *rptr;			/* graphic region */
int rect[];				/* text region area */
{
   int hoffset,voffset;
   int grect[4];
	
	grect[0] = rptr->x1;
	grect[1] = rptr->y1;
	grect[2] = rptr->x2;
	grect[3] = rptr->y2;
	if(rect_intersect(grect,rect))
	{
	   hoffset = repoffset * 18;		/* cnvrt to mu */
	   voffset = repoffset * 16;
           if(repel_mode == 1)
	   {
	      ptsarray[0] = ptsarray[6] = 0;
	      ptsarray[2] = ptsarray[4] = hpage_size - 1;
	   }
	   else 
	   {
	      ptsarray[0] = ptsarray[6] = rptr->x1 - hoffset;
	      ptsarray[2] = ptsarray[4] = rptr->x2 + hoffset;
	   }
           ptsarray[1] = ptsarray[3] = rptr->y1 - voffset;
           ptsarray[5] = ptsarray[7] = rptr->y2 + voffset;
           return(1);
	}
	else
	   return(0);
}	   




/*************************************************************************/
/* Function: chk_repel()						 */
/* Description:								 */
/*************************************************************************/
chk_repel(rptr,rect)
REGION *rptr;
int rect[];
{
   register REGION *region_ptr;
   int g_flag;
   int tmpattr[11];
   PAGE *tmppage;

   alerted = 0;				/* No errors yet    */
   tmppage = curpage;			/* Save off curpage */
   valid_page(rptr->p);			/* Set curpage to rptr's page */
   region_ptr = curpage->regptr;	/* Get first region	      */
   curpage = tmppage;			/* restore curpage	      */
   while(region_ptr)
   {
       g_flag = region_ptr->type;
       if(g_flag && !alerted) 
       {
           get_grattr(region_ptr,tmpattr);
	   if(tmpattr[4] && gr_intersect(tmpattr[4],tmpattr[5],
			region_ptr,rect))
	        if(tmpattr[6])			/* repel image */
		   repel_images(region_ptr,region_ptr->x1,region_ptr->y1,
			                   region_ptr->x2,region_ptr->y2,
					   tmpattr[5],&tmpattr[7]);
		else
		{
		   redraw_polygon(4,0,0);       /* repel region */
  		}
       }
       region_ptr = region_ptr->plink;
   }
   alerted = 0;
}




/************************************************************************/
/* Function: set_repbuff()						*/
/* Description:	Set graphic regions repel buffer to the given address	*/
/************************************************************************/
set_repbuff(rptr,addr)
REGION *rptr;
long addr;
{
    stuffpt(&addr,&rptr->grattr[7]);
}




/************************************************************************/
/* Function: clr_grbuff()						*/
/* Description:	Clear repel buffer and zero the pointer			*/
/************************************************************************/
clr_grbuff(rptr)
register REGION *rptr;
{
   long addr;

   stuffpt(&rptr->grattr[7],&addr);
   if(addr)
	free(addr);
   rptr->grattr[7] = 0;
   rptr->grattr[8] = 0;
}




/*************************************************************************/
/* Function: get_curreg()						 */
/* Description:								 */
/*************************************************************************/
REGION *get_curreg(type)
int *type;
{
   if(curregion == (REGION *)NULLPTR)
   {
	*type = 0;
	return(REGION *)NULLPTR;
   }
   *type = curregion->type;
   return curregion;
}




/*************************************************************************/
/* Function: calc_rmem()						 */
/* Description:								 */
/*	Add up memory needed to store structure of the page.		 */
/*	Add 10 to each structure for memory manager pointers whatever    */
/*	that requirement might be...this should be enough		 */
/*************************************************************************/
calc_rmem(pageptr,count)
PAGE *pageptr;
long *count;
{
register REGION *rptr;
register PRIMITIVE *pptr;
register PTSBLK *bptr;

   rptr = pageptr->regptr;
   if(!rptr)
	return;
   while(rptr)
   {
   	pptr =  rptr->primlist;
	while(pptr)
        {
   	   bptr = pptr->blkptr;
	   while(bptr)
           {
	      *count += (long)sizeof(PTSBLK) + 10L;
	      bptr = bptr->nextblk;
           }	
	   *count += (long)sizeof(PRIMITIVE) + 10L;
	   pptr = pptr->nextprim;
        }	
	*count += (long)sizeof(REGION) + 10L;
	rptr = rptr->plink;
    }
}




/*************************************************************************/
/* Function: page_to_clip()						 */
/* Description:								 */
/*************************************************************************/
page_to_clip()
{
   REGION *rptr;
   PRIMITIVE *primptr;
   register PTSBLK *blkptr;

   register REGION *crptr;
   PRIMITIVE *cprimptr;
   register PTSBLK *cblkptr;

   REGION *tcurregion;
   PRIMITIVE *tcurprim;

   register int i;
   long memneeded;
   long memfree;

   if(!valid_page(curr_page))
	return(0);

   memneeded = 0L;
   calc_rmem(curpage,&memneeded);
   memfree = Malloc(-1L);
   if(memfree < memneeded)
   {
	alert_cntre(ALERT12);
	return(0);
   }      
   tcurregion = curregion;
   tcurprim = curprim;

   clippage = (PAGE *)get_lcmem((long)sizeof(PAGE));

   rptr = prev_region(NULLPTR);
   while(rptr)
   {
	curregion = rptr;
        crptr = (REGION *)get_lcmem((long)sizeof(REGION));
	crptr->plink = clippage->regptr;	
	clippage->regptr = crptr;
	crptr->x1 = rptr->x1;
  	crptr->y1 = rptr->y1;
	crptr->x2 = rptr->x2;
	crptr->y2 = rptr->y2;
	crptr->text = rptr->text;
	for(i = 0;i < 11;i++)
	   crptr->grattr[i] = rptr->grattr[i];
	crptr->type = rptr->type;
	primptr = prev_prim(NULLPTR);
	while(primptr)
	{
	   curprim = primptr;
   	   cprimptr = (PRIMITIVE *)get_lcmem((long)sizeof(PRIMITIVE));
	   cprimptr->nextprim = crptr->primlist;
	   crptr->primlist = cprimptr;
	   cprimptr->op = primptr->op;
  	   cprimptr->wrmode = primptr->wrmode;
	   cprimptr->numpts = primptr->numpts;
	   blkptr = prev_blk(NULLPTR);
	   while(blkptr)
	   {
		cblkptr = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
		cblkptr->nextblk = cprimptr->blkptr;
		cprimptr->blkptr = cblkptr;
		for(i = 0;i < 8;i++)
		   cblkptr->points[i] = blkptr->points[i];
		blkptr = prev_blk(blkptr);
  	   }
	   primptr = prev_prim(primptr);
  	}
        rptr = prev_region(rptr);
    }
    curregion = tcurregion;
    curprim = tcurprim;
    return(1);
}




/*************************************************************************/
/* Function: clip_to_page()						 */
/* Description:								 */
/*************************************************************************/
clip_to_page(page)
int page;
{
   REGION *rptr;
   PRIMITIVE *primptr;
   register PTSBLK *blkptr;

   register REGION *crptr;
   PRIMITIVE *cprimptr;
   register PTSBLK *cblkptr;

   PAGE *tcurpage;

   register int i;
   long memneeded;
   long memfree;

   memneeded = 0L;
   calc_rmem(clippage,&memneeded);
   memfree = Malloc(-1L);
   if(memfree < memneeded)
   {
	alert_cntre(ALERT12);
	return(0);
   }      

   if(!valid_page(page))
      add_page(page);
   tcurpage = curpage;
   curpage = clippage;
   rptr = prev_region(NULLPTR);
   while(rptr)
   {
	curregion = rptr;
        crptr = (REGION *)get_lcmem((long)sizeof(REGION));
	crptr->plink = tcurpage->regptr;	
	tcurpage->regptr = crptr;
	crptr->x1 = rptr->x1;
  	crptr->y1 = rptr->y1;
	crptr->x2 = rptr->x2;
	crptr->y2 = rptr->y2;
	crptr->text = rptr->text;
	crptr->p = page;	
	for(i = 0;i < 11;i++)
	   crptr->grattr[i] = rptr->grattr[i];
	crptr->type = rptr->type;
	primptr = prev_prim(NULLPTR);
	while(primptr)
	{
	   curprim = primptr;
   	   cprimptr = (PRIMITIVE *)get_lcmem((long)sizeof(PRIMITIVE));
	   cprimptr->nextprim = crptr->primlist;
	   crptr->primlist = cprimptr;
	   cprimptr->op = primptr->op;
  	   cprimptr->wrmode = primptr->wrmode;
	   cprimptr->numpts = primptr->numpts;
	   blkptr = prev_blk(NULLPTR);
	   while(blkptr)
	   {
		cblkptr = (PTSBLK *)get_lcmem((long)sizeof(PTSBLK));
		cblkptr->nextblk = cprimptr->blkptr;
		cprimptr->blkptr = cblkptr;
		for(i = 0;i < 8;i++)
		   cblkptr->points[i] = blkptr->points[i];
		blkptr = prev_blk(blkptr);
  	   }
	   primptr = prev_prim(primptr);
  	}
        rptr = prev_region(rptr);
    }
    curpage = tcurpage;
    curregion = curpage->regptr;
    curprim = curregion->primlist;
    return(1);
}




/*************************************************************************/
/* Function: delete_clip()						 */
/* Description:								 */
/*************************************************************************/
delete_clip()
{
   PAGE *temppage;
   register REGION *rptr;

   if(clippage == NULLPTR)
	return;
   temppage = curpage;
   curpage = clippage;
   rptr = curpage->regptr;
   while(rptr)
   {
      delete_region(rptr);
      rptr = curpage->regptr;
   }
   free(curpage);
   curpage = temppage;
   clippage = NULLPTR;
}




/*************************************************************************/
/* Function: get_cur_prim()						 */
/* Description:								 */
/*************************************************************************/
int get_cur_prim(count,wrmode,pptr)
int *count;
int *wrmode;
long *pptr;
{
   if(curprim == NULLPTR)
   {
	*count = 0;
	*pptr  = curprim;
	return -1;
   }
   else
   {
	*count  = curprim->numpts;
  	*wrmode = curprim->wrmode;
	*pptr   = curprim; 
 	getpts();
	return curprim->op;
   }
}




/*************************************************************************/
/* Function: set_cur_prim()						 */
/* Description:								 */
/*************************************************************************/
set_cur_prim(pptr)
long pptr;
{
	curprim = pptr;
	getpts();
}




/**************************************************************************/
/* Function: do_reg_front()						  */
/* Description:								  */
/* 	Bring the region to the front of the list or send it to the back  */
/**************************************************************************/
do_reg_front(rptr)
register REGION *rptr;
{
   register REGION *tptr;

   if(rptr->plink == (REGION *)NULLPTR)		/* Already at end of list */
	return;
   tptr = curpage->regptr;
   if(tptr == rptr)
   {
	curpage->regptr = rptr->plink;		/* remove from head of list */
   }
   else
   {
      while(tptr->plink != rptr)
      {
	 tptr = tptr->plink;
      }
      tptr->plink = rptr->plink;		/* Remove from list	*/
   }
   while(tptr->plink != (REGION *)NULLPTR)
	tptr = tptr->plink;
   tptr->plink = rptr;
   rptr->plink = (REGION *)NULLPTR;
}




/*************************************************************************/
/* Function: do_reg_back()						 */
/* Description:								 */
/*************************************************************************/
do_reg_back(rptr)
register REGION *rptr;
{
   register REGION *tptr;

   if(curpage->regptr == rptr)		/* Already at stanrt of list */
	return;
   tptr = curpage->regptr;
   while(tptr->plink != rptr)
   {
	tptr = tptr->plink;
   }
   tptr->plink = rptr->plink;			/* Remove from list	*/
   rptr->plink = curpage->regptr;
   curpage->regptr = rptr;
}





/**************************************************************************/
/* Function: do_prim_front()						  */
/* Description:								  */
/* 	Bring the given prim to the front of the list or send it to the   */
/*	back								  */
/**************************************************************************/
do_prim_front(pptr)
register PRIMITIVE *pptr;
{
   register PRIMITIVE *tptr;

   if(pptr->nextprim == (PRIMITIVE *)NULLPTR)	/* Already at end of list */
	return;
   tptr = curregion->primlist;
   if(tptr == pptr)
   {
	curregion->primlist = pptr->nextprim;	/* remove from head of list */
   }
   else
   {
      while(tptr->nextprim != pptr)
      {
	 tptr = tptr->nextprim;
      }
      tptr->nextprim = pptr->nextprim;		/* Remove from list	*/
   }
   while(tptr->nextprim != (PRIMITIVE *)NULLPTR)
	tptr = tptr->nextprim;
   tptr->nextprim = pptr;
   pptr->nextprim = (PRIMITIVE *)NULLPTR;
}




/*************************************************************************/
/* Function: do_prim_back()						 */
/* Description:								 */
/*************************************************************************/
do_prim_back(pptr)
register PRIMITIVE *pptr;
{
   register PRIMITIVE *tptr;

   if(curregion->primlist == pptr)	/* Already at start of list */
	return;
   tptr = curregion->primlist;
   while(tptr->nextprim != pptr)
   {
	tptr = tptr->nextprim;
   }
   tptr->nextprim = pptr->nextprim;		/* Remove from list	*/
   pptr->nextprim = curregion->primlist;
   curregion->primlist  = pptr;
}





/**************************************************************************/
/* Function: put_scaninfo()						  */
/* Description:								  */
/* 	Put slave code information into the given scaninfo structure	  */
/**************************************************************************/
put_scaninfo(sptr,slaveptr)
SCANINFO *sptr;
struct slvlist *slaveptr;
{
   sptr->slaveptr = slaveptr;
}





/**************************************************************************/
/* Function: add_scaninfo()						  */
/* Description:								  */
/*	Create a scan rect structure and initialize it with the given     */
/*	data.								  */
/**************************************************************************/
add_scaninfo(rptr,x1,y1,x2,y2,textptr,slaveptr)
REGION *rptr;
int x1,y1,x2,y2;
char *textptr;
struct slvlist *slaveptr;
{
   register SCANINFO *curscan;
   register SCANINFO *tscan;

        curscan = (REGION *)get_lcmem((long)sizeof(SCANINFO));
	tscan = rptr->scanlist;
	if(tscan == NULLPTR)
	{
	   rptr->scanlist = curscan;
	}
	else
	{	
	   while(tscan->nextscan != NULLPTR)
		tscan = tscan->nextscan;
	   tscan->nextscan = curscan;
	}
	curscan->x1 = x1;
	curscan->x2 = x2;
	curscan->y1 = y1;
	curscan->y2 = y2;
	curscan->textptr = textptr;
	curscan->slaveptr = slaveptr;
	curscan->nextscan = NULLPTR;
}





/**************************************************************************/
/* Function: getf_scaninfo()						  */
/* Description:								  */
/*	Get the first scaninfo struct in the given regions list		  */
/**************************************************************************/
SCANINFO *getf_scaninfo(rptr,x1,y1,x2,y2,textptr,slaveptr)
REGION *rptr;
int *x1;
int *y1;
int *x2;
int *y2;
long *textptr;
long *slaveptr;
{

   sfscan = rptr->scanlist;
   if(sfscan == NULLPTR)
   {
     *x1 = *y1 = *x2 = *y2 = 0;
     *textptr = *slaveptr = 0L;	
     return(NULLPTR);
   }
   else
   {
     *x1 = sfscan->x1;
     *y1 = sfscan->y1;
     *x2 = sfscan->x2;
     *y2 = sfscan->y2;
     *textptr = (long)sfscan->textptr;
     *slaveptr = (long)sfscan->slaveptr;
     return sfscan;
   }
}




/**************************************************************************/
/* Function: getn_scaninfo()						  */
/* Description:								  */
/*	Get subsequent scaninfo structs after a getf_scaninfo call	  */
/**************************************************************************/
SCANINFO *getn_scaninfo(x1,y1,x2,y2,textptr,slaveptr)
int *x1;
int *y1;
int *x2;
int *y2;
long *textptr;
long *slaveptr;
{
   if(sfscan->nextscan == NULLPTR)
   {
      *x1 = *y1 = *x2 = *y2 = 0;
      *textptr = *slaveptr = 0L;	
      return(NULLPTR);
   }
   else
   {
     sfscan = sfscan->nextscan;
     *x1 = sfscan->x1;
     *y1 = sfscan->y1;
     *x2 = sfscan->x2;
     *y2 = sfscan->y2;
     *textptr = (long)sfscan->textptr;
     *slaveptr = (long)sfscan->slaveptr;
     return sfscan;
   }
}





/**************************************************************************/
/* Function: free_scanrects()						  */
/* Description:								  */
/*	Delete scan rectangle structures and free slave ptrs		  */
/**************************************************************************/
free_scanrects(rptr)
REGION *rptr;
{
   SCANINFO *tscan;
   register SCANINFO *pscan;

   pscan = tscan = rptr->scanlist;
   if(tscan == NULLPTR)
	return;
   while(tscan != NULLPTR)
   {
	tscan = pscan->nextscan;
	if(pscan->slaveptr)
   	   freeslvlist(pscan->slaveptr);      /* Free slave list	    */
	free(pscan);
	pscan = tscan;
   }
   rptr->scanlist = NULLPTR;
   rptr->txtstart = NULLPTR;
}





/**************************************************************************/
/* Function: free_regslv()						  */
/* Description:								  */
/*	Free slave pointers in the scan rectangle structures		  */
/**************************************************************************/
free_regslv(rptr)
REGION *rptr;
{
   register SCANINFO *tscan;

   tscan = rptr->scanlist;
   while(tscan != NULLPTR)
   {
	if(tscan->slaveptr)
	{
   	   freeslvlist(tscan->slaveptr);      /* Free slave list	    */
	   tscan->slaveptr = NULLPTR;
	}
	tscan = tscan->nextscan; 
   }
}



/*************************************************************************/
/* Function: calc_multbox()						 */
/* Description:								 */
/*************************************************************************/
calc_multbox(rect)
register int rect[];
{
   register REGION *rptr;
   int found;
   found = 0;
   rptr = curpage->regptr;
   while(rptr)
   {
	if(rptr->multi_select)
	{
	   if(!found)
	   {
		rect[0] = rptr->x1;
		rect[1] = rptr->y1;
		rect[2] = rptr->x2;
		rect[3] = rptr->y2;
		found = 1;
	   }
	   else
	   {
		rect[0] = min(rect[0],rptr->x1);
		rect[1] = min(rect[1],rptr->y1);
		rect[2] = max(rect[2],rptr->x2);
		rect[3] = max(rect[3],rptr->y2);
           }
	}
	rptr = rptr->plink;
   }
   if(curr_page % 2 && view_size == PADJCNT)
   {
	rect[0] += hpage_size;
	rect[2] += hpage_size;
   }
}




/*************************************************************************/
/* Function: clr_multi_flags()						 */
/* Description:								 */
/*************************************************************************/   
clr_multi_flags(page)
{
   register REGION *rptr;

   if(!valid_page(page))
	return;
   rptr = curpage->regptr;
   while(rptr)
   {
	rptr->multi_select = 0;
        rptr = rptr->plink;
   }
}




/*************************************************************************/
/* Function: mcalc_multbox()						 */
/* Description:								 */
/*************************************************************************/
mcalc_multbox(rect)
register int rect[];
{
   register REGION *rptr;
   int found;

   found = 0;
   rptr = curpage->regptr;
   while(rptr)
   {
	if(rptr->multi_select)
	{
	   if(!found)
	   {
		rect[0] = rptr->x1;
		rect[1] = rptr->y1;
		rect[2] = rptr->x2;
		rect[3] = rptr->y2;
		found = 1;
	   }
	   else
	   {
		rect[0] = min(rect[0],rptr->x1);
		rect[1] = min(rect[1],rptr->y1);
		rect[2] = max(rect[2],rptr->x2);
		rect[3] = max(rect[3],rptr->y2);
           }
	}
	rptr = rptr->plink;
   }
}
