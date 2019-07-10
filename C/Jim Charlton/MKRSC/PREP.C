#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "globals.h"
#include "strings.h"
#include <fcntl.h>
#include "mkrsc.h"

   /*   RSHDR structure             */
			/* rsh_vrsn	*/
			/* rsh_object	*/
	 		/* rsh_tedinfo	*/
			/* rsh_iconblk	*/
			/* rsh_bitblk	*/
			/* rsh_frstr	*/
			/* rsh_string	string data		*/
			/* rsh_imdata	image data		*/
			/* rsh_frimg	*/
			/* rsh_trindex	*/
			/* rsh_nobs	*/
			/* rsh_ntree	*/
			/* rsh_nted	*/
			/* rsh_nib	*/
			/* rsh_nbb	*/
			/* rsh_nstring	*/
			/* rsh_nimages	*/
			/* rsh_rssize	*/

int  fill_rsc_struct();
char *copy_trindex();
char *copy_obs();
char *copy_strings();
long calc_size();
char *copy_tis();

char *rel_strptr[MAXONUM];
char *rel_tiptr[MAXONUM];
char *rel_icptr[MAXONUM];

/* these rel_xxxptr variables are the relative offset from beginning
	of file image space of the specified things
*/ 


int make_rsc()
{
	long size, lret, rs_trindex[100];
	int handle, check;
	char *start, *next;
	RSHDR *rsc_struct_ptr;	
      
/*
  This programs builds the .RSC file in memory by mallocing space,
  setting the pointer, start, to the space, and then filling the 
  space with the various parts of the file.  Finally the whole image
  is saved to disk.
*/
	size = 0L;

/*	calc size of entire .RSC file  */
 	size = calc_size();
	if(size%2)
		size++;

/*	malloc space for file image */
	start = (char *)malloc((unsigned)size); 

	bzero(start,(int)size);

	rsc_struct_ptr = (RSHDR *)start;

/* save space for the RSHDR  structure */
	next = start + sizeof(RSHDR);

/* rel offset for string space */
	rsc_struct_ptr->rsh_string = next - start;

/* copy strings in */	
	next = copy_strings(next,start,rsc_struct_ptr);

	if((int)(next)%2)
		next += 1;

/*	next now points to the end of the string space
	copy in the tedinfos
*/
	rsc_struct_ptr->rsh_tedinfo = next - start;
	next = copy_tis(next, start,rsc_struct_ptr);

/*
	Just fill the rest of these with the string space address
	as they won't be used anyway with just a menu resource 
	and simple dialogs. 
*/

	rsc_struct_ptr->rsh_iconblk = next - start;
	rsc_struct_ptr->rsh_bitblk = next - start;
	rsc_struct_ptr->rsh_frstr = next - start;
	rsc_struct_ptr->rsh_imdata = next - start;
	rsc_struct_ptr->rsh_frimg = next - start;

	rsc_struct_ptr->rsh_object = next - start;

/*	copy in the object tree array	*/

	next = copy_obs(next,start,rsc_struct_ptr,rs_trindex);

	rsc_struct_ptr->rsh_trindex = next - start;
	next = copy_trindex(next,rs_trindex);

	check = next - start;

	rsc_struct_ptr->rsh_rssize = size;
	rsc_struct_ptr->rsh_vrsn = 0;

	fill_rsc_struct(rsc_struct_ptr);

	fix_ptrs(rsc_struct_ptr,start);

	save_file(size,start);
	thefrontwin->saved = TRUE;
}

long calc_size()
{
	objtreeptr	thetree, *linkptr;
	OBJECT		*inwinptr, *big_treeptr;
	long size;
	int i,j;
	char *next;
	int numobjs, order[MAXONUM];

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;

	size = sizeof(RSHDR);
	for( i=1;i < thetree->count + 1; i++)
	{	numobjs = trav_tree(linkptr[i]->objt,order);
		for(j=0;j < numobjs; j++)
		{	switch (linkptr[i]->objt[order[j]].ob_type)
			{
				case G_TEXT		:
				case G_BOXTEXT	:
				case G_FTEXT	:
				case G_FBOXTEXT	: 
					size += 1 + strlen(linkptr[i]->strings[order[j]]);
					size += 1 + strlen(linkptr[i]->template[order[j]]);
					size += 1 + strlen(linkptr[i]->valid[order[j]]);
					size += sizeof(TEDINFO);
					break;
				case G_BUTTON	:
				case G_STRING	:
				case G_TITLE	:
					size += 1 + strlen(linkptr[i]->strings[order[j]]);
					break;
				case G_ICON		:
					size += 1 + strlen(linkptr[i]->strings[order[j]]);
					size += sizeof(ICONBLK);
					break;
			}		
			size += sizeof(OBJECT);
		}
	}

/*	make room for tr_index array	*/

	size += thetree->count * sizeof(long);
	
	return(size);
}

char *copy_strings(next, start,rsc_struct_ptr)
	char *next, *start;
	RSHDR	*rsc_struct_ptr;
{
	char *ptr;
	objtreeptr	thetree, *linkptr;
	TEDINFO *tiptr;
	ICONBLK *icptr;
	int i,j,num_str;
	int numobjs, order[MAXONUM];

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;

	num_str = 0;
	ptr = next;
	for( i=1;i < thetree->count + 1; i++)
	{	numobjs = trav_tree(linkptr[i]->objt,order);
		for(j=0;j < numobjs; j++)
		{	switch (linkptr[i]->objt[order[j]].ob_type)
			{
				case G_TEXT		:
				case G_BOXTEXT	:
				case G_FTEXT	:
				case G_FBOXTEXT	: 
					tiptr = (TEDINFO *)linkptr[i]->objt[order[j]].ob_spec;
					rel_strptr[num_str++] = (char *)(ptr - start);
					ptr = xtrcpy(ptr,linkptr[i]->strings[order[j]]) + 1;
					rel_strptr[num_str++] = (char *)(ptr - start);
					ptr = xtrcpy(ptr,linkptr[i]->template[order[j]]) + 1;
					rel_strptr[num_str++] = (char *)(ptr - start);
					ptr = xtrcpy(ptr,linkptr[i]->valid[order[j]]) + 1;
					break;
				case G_BUTTON	:
				case G_STRING	:
				case G_TITLE	:
					rel_strptr[num_str++] = (char *)(ptr - start);
					ptr = xtrcpy(ptr,linkptr[i]->strings[order[j]]) + 1;
					break;
				case G_ICON		:
					icptr = (ICONBLK *)linkptr[i]->objt[order[j]].ob_spec;
					rel_strptr[num_str++] = (char *)(ptr - start);
					ptr = xtrcpy(ptr,linkptr[i]->strings[order[j]]) + 1;
					break;
			}		
		}
	}
/*	rsc_struct_ptr->rsh_nstring = num_str;	*/

/*	putting the number of strings into rsh_nstring crashes any
	program using the resource!!!  I have no idea why.
*/

	return(ptr);
}

char *copy_tis(next, start,rsc_struct_ptr)
	char *next, *start;
	RSHDR	*rsc_struct_ptr;
{
	char *ptr;
	objtreeptr	thetree, *linkptr;
	TEDINFO *tiptr;
	int i,j, size_ti, num_ti;
	int numobjs, order[MAXONUM];

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;
	size_ti = sizeof(TEDINFO);

	num_ti = 0;
	ptr = next;
	for( i=1;i < thetree->count + 1; i++)
	{	numobjs = trav_tree(linkptr[i]->objt,order);
		for(j=0;j < numobjs; j++)
		{	switch (linkptr[i]->objt[order[j]].ob_type)
			{
				case G_TEXT		:
				case G_BOXTEXT	:
				case G_FTEXT	:
				case G_FBOXTEXT	: 
					tiptr = (TEDINFO *)linkptr[i]->objt[order[j]].ob_spec;
					bcopy((char *)tiptr,ptr,size_ti);
					rel_tiptr[num_ti++] = (char *)(ptr - start);
					ptr += size_ti;
					break;
			}		
		}
	}
	rsc_struct_ptr->rsh_nted = num_ti;
	return(ptr);
}

char *copy_obs(next,start,rsc_struct_ptr,rs_trindex)
	char *next, *start;
	RSHDR	*rsc_struct_ptr;
	long	rs_trindex[];
{
	char *ptr;
	objtreeptr	thetree, *linkptr;
	OBJECT tempobj, *objptr;
	int i,j, size_ob, num_obs, upb;
	int k, ttls[80], head, nx, count;	
	int numobjs, order[MAXONUM];

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;
	size_ob = sizeof(OBJECT);

	num_obs = 0;
	ptr = next;
	for( i=1;i < thetree->count + 1; i++)
	{	rs_trindex[i-1] = (long)(ptr - start);
		{	numobjs = trav_tree(linkptr[i]->objt,order);
			next = ptr;
			for(j=0;j < numobjs; j++)
			{	tempobj = linkptr[i]->objt[order[j]];
				/*	fix the size and width and special bytes	*/
				if(order[j]==0)
					tempobj.ob_x = tempobj.ob_y = 0;
				upb = (tempobj.ob_x & ~0xFFF8) << 8;
				tempobj.ob_x = tempobj.ob_x/gl_wchar + upb;
				upb = (tempobj.ob_width & ~0xFFF8) << 8;
				tempobj.ob_width = tempobj.ob_width/gl_wchar + upb;
				upb = (tempobj.ob_y & ~(0xFFFF-gl_hchar+1)) << 8;
				tempobj.ob_y = tempobj.ob_y/gl_hchar + upb;
				upb = (tempobj.ob_height & ~(0xFFFF-gl_hchar+1)) << 8;
				tempobj.ob_height = tempobj.ob_height/gl_hchar + upb;

/*	certain objects in menus have the upper byte of ob_height
		or ob_y set to 0x2 or 0x3 to give bit offsets to objects.

				if(thetree->kind[i] == TMENU)
				{
					if(order[j]==1)
						tempobj.ob_height |= 0x200;
					else if( (order[j]==2)||(tempobj.ob_type == G_TITLE) )
						tempobj.ob_height |= 0x300;
					else if(tempobj.ob_next == 0)
						tempobj.ob_y |= 0x300;
				}
*/

	/*	mark last object in subtree	*/
				if(j == (numobjs - 1))
					tempobj.ob_flags |= LASTOB;
				else
					tempobj.ob_flags &= ~LASTOB;
				bcopy((char *)&tempobj,ptr,size_ob);
				ptr += size_ob;
				num_obs++;
			}	/*	end of for(j=.... 	*/
/*	reset the pointers in the object tree...  newpos() in tree.c	*/
			objptr = (OBJECT *)next;
			for (j=0;j<numobjs;j++)
			{	objptr[j].ob_next = newpos(objptr[j].ob_next,numobjs,order);
				objptr[j].ob_head = newpos(objptr[j].ob_head,numobjs,order);
				objptr[j].ob_tail = newpos(objptr[j].ob_tail,numobjs,order);
			}

		}
	}
	rsc_struct_ptr->rsh_nobs = num_obs;
	return(ptr);
}

char *copy_trindex(next,rs_trindex)
	char *next;
	long	rs_trindex[];
{
	objtreeptr	thetree, *linkptr;
	int cnt;

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;

	cnt = thetree->count * (sizeof(long));
	bcopy( (char *)rs_trindex, next, cnt);
	return(next + cnt);
}

int  fill_rsc_struct(rsc_struct_ptr)
	RSHDR	*rsc_struct_ptr;
{ 
	objtreeptr	thetree;

	thetree = thefrontwin->inwindow;

	rsc_struct_ptr->rsh_ntree = thetree->count;
	rsc_struct_ptr->rsh_nib = 0;
	rsc_struct_ptr->rsh_nbb = 0;
	rsc_struct_ptr->rsh_nimages = 0;
}

int fix_ptrs(rsc_struct_ptr,start)
	RSHDR	*rsc_struct_ptr;
	char 	*start;
{
	OBJECT *objptr;
	TEDINFO *tiptr;
	ICONBLK *icptr;
	int i,j, num_str, num_ti, num_ic;


/* objptr is the start of the array of objects in the file image
	area that is going to be saved in the RSC file.
*/

	objptr = (OBJECT *)(start + rsc_struct_ptr->rsh_object);
	num_ti = num_str = num_ic = 0;
	
	for( i=0;i < rsc_struct_ptr->rsh_nobs+1; i++)
	{	switch (objptr[i].ob_type)
		{
			case G_TEXT		:
			case G_BOXTEXT	:
			case G_FTEXT	:
			case G_FBOXTEXT	:
				objptr[i].ob_spec = rel_tiptr[num_ti++];
			tiptr = (TEDINFO *)((long)objptr[i].ob_spec + (long)start);
				tiptr->te_ptext = rel_strptr[num_str++];
				tiptr->te_ptmplt = rel_strptr[num_str++];
				tiptr->te_pvalid = rel_strptr[num_str++];				
				break;
			case G_BUTTON	:
			case G_STRING	:
			case G_TITLE	:
					objptr[i].ob_spec = rel_strptr[num_str++];
					break;
			case G_ICON		:
					objptr[i].ob_spec = rel_icptr[num_ic++];
				icptr = (ICONBLK *)((long)objptr[i].ob_spec + (long)start);
					icptr->ib_ptext = rel_strptr[num_str++];
					break;
		}		
	}
}
