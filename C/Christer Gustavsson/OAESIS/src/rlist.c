/****************************************************************************

 Module
  rlist.c
  
 Description
  Rectangle list routines used in oAESis.
  
 Author(s)
 	cg     (Christer Gustavsson <d2cg@dtek.chalmers.se>)

 Revision history
 
  951226 cg
   Created rlist.c and moved rectangle list functions from wind.c.
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <osbind.h>

#include "mintdefs.h"
#include "misc.h"
#include "rlist.h"
#include "types.h"

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static RLIST *free_rlist = 0L;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static RLIST *alloc(void) {
	RLIST *blk = free_rlist;
	
	if(blk) {
		free_rlist = free_rlist->next;
		
		return blk;
	};
	
	return Mxalloc(sizeof(RLIST),GLOBALMEM);
}

static void free(RLIST *blk) {
	blk->next = free_rlist;
	free_rlist = blk;
}

static WORD	tryinsert(RLIST **dst,RLIST **src) {				
	if((((*dst)->r.x + (*dst)->r.width) == (*src)->r.x)
		|| (((*src)->r.x + (*src)->r.width) == (*dst)->r.x))
	{
		LONG	area1,area2,area3,xnew,ynew,wnew,hnew,w,h;
		
		WORD	xup,yup,wup,xdn,hdn,wdn;
								
		ynew = max((*dst)->r.y,(*src)->r.y);
		hnew = min((*dst)->r.y + (*dst)->r.height,(*src)->r.y + (*src)->r.height)
			- ynew;
		
		
		if(hnew <= 0)
			return 0;				
					
		xnew = min((*dst)->r.x,(*src)->r.x);
		wnew = (*dst)->r.width + (*src)->r.width;
				
		area1 = hnew * wnew;
		
		w = (*dst)->r.width;
		h = (*dst)->r.height;
		area2 = w * h;
		
		if(area1 <= area2)
		{
			return 0;
		}
		
		w = (*src)->r.width;
		h = (*src)->r.height;
		area3 = w * h;
			
		if(area1 <= area3)
		{
			return 0;
		}
		
		if((*src)->r.y < (*dst)->r.y)
		{
			yup = (*src)->r.y;
			xup = (*src)->r.x;
			wup = (*src)->r.width;
		}
		else
		{
			yup = (*dst)->r.y;
			xup = (*dst)->r.x;
			wup = (*dst)->r.width;
		}
		
		if(((*src)->r.y + (*src)->r.height) < ((*dst)->r.y + (*dst)->r.height))
		{
			xdn = (*dst)->r.x;
			hdn = (*dst)->r.y + (*dst)->r.height - (WORD)(hnew + ynew);
			wdn = (*dst)->r.width;
		}
		else
		{
			xdn = (*src)->r.x;
			hdn = (*src)->r.y + (*src)->r.height - (WORD)(hnew + ynew);
			wdn = (*src)->r.width;
		}
		
		if((hdn == 0) && (ynew - yup) == 0)
		{
			RLIST	*c = *dst;
			
			*dst = (*dst)->next;
			free(c);
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
		}
		else if(hdn == 0)
		{
			RLIST	*c	= *dst;
			
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
			
			*dst = (*dst)->next;
			c->next = *src;
			*src = c;
			c->r.x = xup;
			c->r.y = yup;
			c->r.width = wup;
			c->r.height = (WORD)ynew - yup;
		}
		else if(ynew - yup == 0)
		{
			RLIST	*c	= *dst;
			
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
			
			*dst = (*dst)->next;
			c->next = *src;
			*src = c;
			c->r.x = xdn;
			c->r.y = (WORD)(ynew + hnew);
			c->r.width = wdn;
			c->r.height = hdn;
		}
		else
		{
			RLIST	*c	= *dst;
			
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
			
			*dst = (*dst)->next;
			c->next = *src;
			*src = c;
			c->r.x = xdn;
			c->r.y = (WORD)(ynew + hnew);
			c->r.width = wdn;
			c->r.height = hdn;
			
			c = alloc();
			
			c->next = *src;
			*src = c;
			c->r.x = xup;
			c->r.y = yup;
			c->r.width = wup;
			c->r.height = (WORD)ynew - yup;
		}
	}
	else 	if((((*dst)->r.y + (*dst)->r.height) == (*src)->r.y)
		|| (((*src)->r.y + (*src)->r.height) == (*dst)->r.y))
	{
		LONG	area1,area2,area3,xnew,ynew,wnew,hnew,w,h;
		
		WORD	xlf,ylf,hlf,yrt,hrt,wrt;
								
		xnew = max((*dst)->r.x,(*src)->r.x);
		wnew = min((*dst)->r.x + (*dst)->r.width,(*src)->r.x + (*src)->r.width)
			- xnew;
		
		
		if(wnew <= 0)
			return 0;				
					
		ynew = min((*dst)->r.y,(*src)->r.y);
		hnew = (*dst)->r.height + (*src)->r.height;
				
		area1 = hnew * wnew;
		
		w = (*dst)->r.width;
		h = (*dst)->r.height;
		area2 = w * h;
		
		if(area1 <= area2)
		{
			return 0;
		}
		
		w = (*src)->r.width;
		h = (*src)->r.height;
		area3 = w * h;
			
		if(area1 <= area3)
		{
			return 0;
		}
		
		if((*src)->r.x < (*dst)->r.x)
		{
			xlf = (*src)->r.x;
			ylf = (*src)->r.y;
			hlf = (*src)->r.height;
		}
		else
		{
			xlf = (*dst)->r.x;
			ylf = (*dst)->r.y;
			hlf = (*dst)->r.height;
		}
		
		if(((*src)->r.x + (*src)->r.width) < ((*dst)->r.x + (*dst)->r.width))
		{
			yrt = (*dst)->r.y;
			wrt = (*dst)->r.x + (*dst)->r.width - (WORD)(wnew + xnew);
			hrt = (*dst)->r.height;
		}
		else
		{
			yrt = (*src)->r.y;
			wrt = (*src)->r.x + (*src)->r.width - (WORD)(wnew + xnew);
			hrt = (*src)->r.height;
		}
		
		if((wrt == 0) && (xnew - xlf) == 0)
		{
			RLIST	*c = *dst;
			
			*dst = (*dst)->next;
			free(c);
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
		}
		else if(wrt == 0)
		{
			RLIST	*c	= *dst;
			
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
			
			*dst = (*dst)->next;
			c->next = *src;
			*src = c;
			c->r.x = xlf;
			c->r.y = ylf;
			c->r.width = (WORD)xnew - xlf;
			c->r.height = hlf;
		}
		else if(xnew - xlf == 0)
		{
			RLIST	*c	= *dst;
			
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
			
			*dst = (*dst)->next;
			c->next = *src;
			*src = c;
			c->r.y = yrt;
			c->r.x = (WORD)(xnew + wnew);
			c->r.width = wrt;
			c->r.height = hrt;
		}
		else
		{
			RLIST	*c	= *dst;
			
			(*src)->r.x = (WORD)xnew;
			(*src)->r.y = (WORD)ynew;
			(*src)->r.width = (WORD)wnew;
			(*src)->r.height = (WORD)hnew;
			
			*dst = (*dst)->next;
			c->next = *src;
			*src = c;
			c->r.y = yrt;
			c->r.x = (WORD)(xnew + wnew);
			c->r.width = wrt;
			c->r.height = hrt;
			
			c = alloc();
			
			c->next = *src;
			*src = c;
			c->r.x = xlf;
			c->r.y = ylf;
			c->r.width = (WORD)xnew - xlf;
			c->r.height = hlf;
		}
	}
	else
		return 0;
	
	return 1;
}



/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Rlist_insert                                                             *
 *  Combines the rectangle lists dst and src and create a list of the       *
 *  largest possible rectangles in dst. The rectangles in src should be     *
 *  deleted with rlistinsert when not needed anymore.                       *
 ****************************************************************************/
void              /*                                                        */
Rlist_insert(     /*                                                        */
RLIST **dst,      /* Destination rectangle list.                            */
RLIST **src)      /* Source rectangle list.                                 */
/****************************************************************************/
{
	RLIST	**c = dst;
	
	while(*src != 0L)
	{
		while(1)
		{
			if(*c == 0L)
			{
				*c = *src;
				*src = (*src)->next;
				(*c)->next = 0L;
				c = dst;
				break;
			}
			else
			{
				if(tryinsert(c,src))
				{
					c = dst;
				}
				else
				{
					c = &(*c)->next;
				}
			}
		}
	}
}


/****************************************************************************
 * Rlist_erase                                                              *
 *  Erase rectangle list.                                                   *
 ****************************************************************************/
void              /*                                                        */
Rlist_erase(      /*                                                        */
RLIST **src)      /* Rectangle list to erase.                               */
/****************************************************************************/
{
	RLIST	*rlwalk = *src;
	
	*src = 0L;
	
	while(rlwalk) {
		RLIST	*rl = rlwalk;
		
		rlwalk = rlwalk->next;
		
		free(rl);
	};
}


/****************************************************************************
 * Rlist_duplicate                                                          *
 *  Duplicate rectangle list.                                               *
 ****************************************************************************/
RLIST *           /* The new rectangle list.                                */
Rlist_duplicate(  /*                                                        */
RLIST *src)       /* Rectangle list to duplicate.                           */
/****************************************************************************/
{
	RLIST	*rl = 0L;
	RLIST	*rlwalk;
	
	
	if(!src)
		return 0;
	
	rl = alloc();
	rl->r.x = src->r.x;
	rl->r.y = src->r.y;
	rl->r.width = src->r.width;
	rl->r.height = src->r.height;
	
	src = src->next;
	
	rlwalk = rl;
	
	while(src)
	{
		rlwalk->next = alloc();
		rlwalk = rlwalk->next;
		rlwalk->r.x = src->r.x;
		rlwalk->r.y = src->r.y;
		rlwalk->r.width = src->r.width;
		rlwalk->r.height = src->r.height;
	
		src = src->next;
	};
	
	rlwalk->next = 0L;
	
	return rl;
}


/****************************************************************************
 * Rlist_sort                                                               *
 *  Sort rectangle list in a "safe" order before moving (dx,dy).            *
 ****************************************************************************/
void              /*                                                        */
Rlist_sort(       /*                                                        */
RLIST **src,      /* Rectangle list to be sorted.                           */
WORD  dx,         /* Movement in x direction.                               */
WORD  dy)         /* Movement in y direction.                               */
/****************************************************************************/
{
	WORD	changed = 1;
	
	RLIST	**walk = src;

	while(changed)
	{
		changed = 0;
		
		while(*walk)
		{
			if(!(*walk)->next)
				break;
			
				
			if(dx > 0)
			{
				if((*walk)->r.x < (*walk)->next->r.x)
				{
					RLIST	*rl = (*walk);
					
					*walk = (*walk)->next;
					rl->next = (*walk)->next;
					(*walk)->next = rl;
					
					changed = 1;
				}
				else if((*walk)->r.x == (*walk)->next->r.x)
				{
					if(dy > 0)
					{
						if((*walk)->r.y < (*walk)->next->r.y)
						{
							RLIST	*rl = (*walk);
							
							*walk = (*walk)->next;
							rl->next = (*walk)->next;
							(*walk)->next = rl;
							
							changed = 1;
						};
					}
					else
					{
						if((*walk)->r.y + (*walk)->r.height
						> (*walk)->next->r.y + (*walk)->next->r.height)
						{
							RLIST	*rl = (*walk);
							
							*walk = (*walk)->next;
							rl->next = (*walk)->next;
							(*walk)->next = rl;
							
							changed = 1;
						};
					};
				};
			}
			else
			{
				if((*walk)->r.x > (*walk)->next->r.x)
				{
					RLIST	*rl = (*walk);
					
					*walk = (*walk)->next;
					rl->next = (*walk)->next;
					(*walk)->next = rl;
					
					changed = 1;
				}
				else if((*walk)->r.x == (*walk)->next->r.x)
				{
					if(dy > 0)
					{
						if((*walk)->r.y < (*walk)->next->r.y)
						{
							RLIST	*rl = (*walk);
							
							*walk = (*walk)->next;
							rl->next = (*walk)->next;
							(*walk)->next = rl;
							
							changed = 1;
						};
					}
					else
					{
						if((*walk)->r.y + (*walk)->r.height
						> (*walk)->next->r.y + (*walk)->next->r.height)
						{
							RLIST	*rl = (*walk);
							
							*walk = (*walk)->next;
							rl->next = (*walk)->next;
							(*walk)->next = rl;
							
							changed = 1;
						};
					};
				};
			};
			
			walk = &(*walk)->next;
		};
		
		walk = src;	
	};
}



/****************************************************************************
 * Rlist_rectinter                                                          *
 *  Get rectangle parts from src that intersects with area and insert them  *
 *  in dst. No optimization will be done on dst or src.                     *
 ****************************************************************************/
void              /*                                                        */
Rlist_rectinter(  /*                                                        */
RLIST **dst,      /* Destination rectangle list.                            */
RECT  *area,      /* Area to grab parts of.                                 */
RLIST **src)      /* Source rectangle list.                                 */
/****************************************************************************/
{
	RLIST	*shead = 0L;
	
	while(*src != 0L)
	{
		RECT	r;
		
		switch(Misc_intersect(area,&(*src)->r,&r)) {
			RLIST	*t;
			
			case	1:	/*rectangle is partially covered*/
				t = *src;
				*src = (*src)->next;
				t->next = *dst;
				*dst = t;
				
				
				if((*dst)->r.x < r.x)
				{
					RLIST *rl = alloc();
					
					rl->next = shead;
					shead = rl;
					
					rl->r.x = (*dst)->r.x;
					rl->r.y = r.y;
					rl->r.width = r.x - (*dst)->r.x;
					rl->r.height = r.height;
					
				}
				
				if(((*dst)->r.x + (*dst)->r.width)
					> (r.x + r.width))
				{
					RLIST *rl = alloc();
					
					rl->next = shead;
					shead = rl;
					
					rl->r.x = r.x + r.width;
					rl->r.y = r.y;
					rl->r.width = (*dst)->r.x + (*dst)->r.width
						- r.x - r.width;
					rl->r.height = r.height;
				}
				
				if((*dst)->r.y < r.y)
				{
					RLIST *rl = alloc();
					
					rl->next = shead;
					shead = rl;
					
					rl->r.x = (*dst)->r.x;
					rl->r.y = (*dst)->r.y;
					rl->r.width = (*dst)->r.width;
					rl->r.height = r.y - (*dst)->r.y;
				}
				
				if(((*dst)->r.y + (*dst)->r.height)
					> (r.y + r.height))
				{
					RLIST *rl = alloc();
					
					rl->next = shead;
					shead = rl;
					
					rl->r.x = (*dst)->r.x;
					rl->r.y = r.y + r.height;
					rl->r.width = (*dst)->r.width;
					rl->r.height = (*dst)->r.y + (*dst)->r.height
						- r.y - r.height;
				}
				
				(*dst)->r.x = r.x;
				(*dst)->r.y = r.y;
				(*dst)->r.width = r.width;
				(*dst)->r.height = r.height;
				break;
				
			case	2:	/*rectangle is completely covered*/
				t = *src;
				*src = (*src)->next;
				t->next = *dst;
				*dst = t;
				break;
					
			default:	/*rectangle is not covered*/
				src = &(*src)->next;
		}
	}
	
	*src = shead;	/*append the not-used-rectangle list on src*/	
}
