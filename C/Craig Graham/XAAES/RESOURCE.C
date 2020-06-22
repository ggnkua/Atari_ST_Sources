/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <FCNTL.H>
#include <STDIO.H>
#include <OSBIND.H>
#include <VDI.H>
#include <memory.h>
#include "K_DEFS.H"
#include "RESOURCE.H"
#include "XA_GLOBL.H"
#include "XA_DEFS.H"
#include "XA_TYPES.H"

/*
	RESOURCE FILE HANDLER

	Simulate the standard GEM AES resource access functions.
	
	I've added these to Steve's routines to act as a bit of an interface
	to his routines. Each application has it's own std_resource as part
	of the XA_CLIENT structure. As Steve's resource loader is happy to
	allow multiple resource files, I should add some extra calls to support it.
*/


unsigned long XA_rsrc_load(short clnt_pid,AESPB *pb)
{
	char *n=(char*)(pb->addrin[0]);
	char full_path[180];
	void **glob_entry;
	short f;

/* If the client is overwriting it's existing resource then better free it
	 (it shouldn't, but just in case) */
/* I don't think this is a good idea - much better to have a memory leak
	than a process continuing to access a free'd memory region; GEM AES
	doesn't auto-free an existing RSC either, so this would be
	incompatible anyway... <mk>
*/
#if 0
 	if (clients[clnt_pid].std_resource)
 		FreeResources(clients[clnt_pid].std_resource);
#endif

/* What sort of path is it? */
	for(f=0; (n[f])&&(n[f]!='\\'); f++);
	if (n[f])
		sprintf(full_path,"%s",n);
	else
		sprintf(full_path,"%s\\%s",clients[clnt_pid].home_path,n);

	DIAGS(("rsrc_load('%s')\n",full_path));

	clients[clnt_pid].std_resource=LoadResources(full_path, DU_RSX_CONV, DU_RSY_CONV);
	if (clients[clnt_pid].std_resource)
		pb->intout[0]=1;
	else
		pb->intout[0]=0;

	DIAGS((" LoadResources returned %d\n",clients[clnt_pid].std_resource));

/* Fill in the application's global array with a pointer to the resource */
	glob_entry=(void**)(clients[clnt_pid].globl_ptr+5);
	*glob_entry=clients[clnt_pid].std_resource;

	return XAC_DONE;
}

unsigned long XA_rsrc_free(short clnt_pid,AESPB *pb)
{
	if (clients[clnt_pid].std_resource)
	{
		FreeResources(clients[clnt_pid].std_resource);
		clients[clnt_pid].std_resource=NULL;
		pb->intout[0]=1;
	}else{
		pb->intout[0]=0;
	}

	return XAC_DONE;
}

unsigned long XA_rsrc_gaddr(short clnt_pid,AESPB *pb)
{
	OBJECT **tree_addr;
	char **text_addr;
	void **image_addr,**glob;
	short type=pb->intin[0], index=pb->intin[1];

	if (!clients[clnt_pid].std_resource)
	{
		glob=(void**)(clients[clnt_pid].globl_ptr+5);
		clients[clnt_pid].std_resource=*glob;
	}
	
	switch(type)
	{
		case R_TREE:
			tree_addr=(OBJECT**)pb->addrout;
			*tree_addr=ResourceTree(clients[clnt_pid].std_resource,index);
			break;
		case R_STRING:
			text_addr=(char**)pb->addrout;
			*text_addr=ResourceString(clients[clnt_pid].std_resource,index);
			break;
		case R_IMAGEDATA:
			image_addr=(void**)pb->addrout;
			*image_addr=ResourceImage(clients[clnt_pid].std_resource,index);
			break;
	}
	
	if (pb->addrout[0])
		pb->intout[0]=1;
	else
		pb->intout[0]=0;
		
	return XAC_DONE;
}

/*
 *	Fixup OBJECT coordinates; the lower byte contains a (character-based)
 *	coordinate, the upper byte an additional (pixel) offset.
 */
#define fixup(val,scale) (((val)&0xff)*(scale)+(((val)>>8)&0xff))

void obfix(OBJECT *tree, short object)
{
	OBJECT *o = &tree[object];

	o->ob_x = fixup(o->ob_x, display.c_max_w) ;
	o->ob_y = fixup(o->ob_y, display.c_max_h) ;
	/*
	* Special case handling: any OBJECT 80 characters wide is supposed
	* to be a menu bar, which always covers the entire screen width...
	*/
	o->ob_width = (o->ob_width==80) ?
			display.w : fixup(o->ob_width, display.c_max_w) ;
	o->ob_height = fixup(o->ob_height, display.c_max_h) ;
}

unsigned long XA_rsrc_obfix(short clnt_pid,AESPB *pb)
{
	obfix((OBJECT*)pb->addrin[0],pb->intin[0]);
	pb->intout[0]=1;
	return XAC_DONE;
}

/*
	Code in this module is based on the resource loader from
	Steve Sowerby's AGiLE library. Thanks to Steve for allowing
	me to use his code.
*/

short resWidth,resHeight;

/*
	FixColourIconData : Convert a colour icon from device independent to device specific
*/
void FixColourIconData(CICONBLK *icon)
{
	CICON *c;
	MFDB src,dst;
	unsigned long len=(((icon->monoblk.ib_wicon+15)>>3)&~1) * icon->monoblk.ib_hicon;
	unsigned long old_len,new_len,l;
	short *new_data;

	for(c=icon->mainlist; c; c=c->next_res)
	{
		
		if (c->num_planes!=display.planes)
		{
			old_len  = c->num_planes * len;
			new_len = display.planes * len;
		
			new_data = (short*)Mxalloc(new_len+10,MX_STRAM);
			
			for(l=0; l<(old_len+1)>>1; l++)
				new_data[l]=c->col_data[l];
			for(; l<(new_len+1)>>1; l++)
				new_data[l]=0;
			
			c->col_data=new_data;
		}
		
		src.fd_w = icon->monoblk.ib_wicon;				/*Transform standard icon*/
		src.fd_h = icon->monoblk.ib_hicon;
		src.fd_wdwidth = icon->monoblk.ib_wicon>>4;
		src.fd_stand = 1;
		src.fd_r1 = src.fd_r2 = src.fd_r3 = 0;
		src.fd_nplanes = display.planes;
		dst.fd_stand = 0;
		src.fd_addr = c->col_data;
		dst = src;
		vr_trnfm(V_handle,&src,&dst);

		if (c->sel_data)							/*Transform selected icon if exists*/
		{
			
			if (c->num_planes!=display.planes)
			{
				old_len  = c->num_planes * len;
				new_len = display.planes * len;
			
				new_data = (short*)Mxalloc(new_len+10,MX_STRAM);
				
				for(l=0; l<(old_len+1)>>1; l++)
					new_data[l]=c->col_data[l];
				for(; l<(new_len+1)>>1; l++)
					new_data[l]=0;
			
				c->sel_data=new_data;
			}
			
			src.fd_w = icon->monoblk.ib_wicon;
			src.fd_h = icon->monoblk.ib_hicon;
			src.fd_wdwidth = icon->monoblk.ib_wicon>>4;
			src.fd_stand = 1;
			src.fd_r1 = src.fd_r2 = src.fd_r3 = 0;
			src.fd_nplanes = display.planes;
			dst = src;
			dst.fd_stand = 0;
			src.fd_addr = c->sel_data;
			
			vr_trnfm(V_handle,&src,&dst);
		}
	}
}

/*
	LoadResources : Load a GEM resource file
	fname = name of file to load
	Return = base pointer of resources or NULL on failure
*/
void *LoadResources(char *fname,short designWidth,short designHeight)
{
	long err;
	short handle;
	RSHDR hdr;
	OBJECT *obj,*tree;
	TEDINFO *ti;
	ICONBLK *ib;
	CICONBLK *cib,**cibh;
	BITBLK *bb;
	CICON *cicn,*pcicn;
	unsigned long osize,size,*index,*addr,*earray;
	char *base,*ptext;
	short i,j,type,numCibs=0,numRez,*pdata;

	resWidth = display.c_max_w;
	resHeight = display.c_max_h;
	
	err = Fopen(fname,O_RDONLY);
	if (err<0L)
	{
		DIAGS(("LoadResources():file not found\n"));
		return NULL;
	}
	handle = (short)err;
	Fread(handle,sizeof(RSHDR),&hdr);
	size = (unsigned long)hdr.rsh_rssize;
	osize = (size+1UL)&0xfffffffeUL;
	if (hdr.rsh_vrsn&4)
	{ /* Extended format, get new 32-bit length */
		Fseek(osize,handle,SEEK_SET);
		Fread(handle,4L,&size);
	}
	Fseek(0L,handle,SEEK_SET);
	base = (char*)Mxalloc(size+100,MX_STRAM);
	if (!base)
	{
		Fclose(handle);
		return NULL;
	}
	Fread(handle,size,base);
	Fclose(handle);

	ti = (TEDINFO*)(base+(unsigned long)hdr.rsh_tedinfo);
	for (i=0;i<hdr.rsh_nted;i++,ti++)
	{ /* Correct all tedinfo field pointers */
		ti->te_ptext = (char*)((unsigned long)ti->te_ptext+base);
		ti->te_ptmplt = (char*)((unsigned long)ti->te_ptmplt+base);
		ti->te_pvalid = (char*)((unsigned long)ti->te_pvalid+base);
	}

	ib = (ICONBLK*)(base+(unsigned long)hdr.rsh_iconblk);
	for (i=0;i<hdr.rsh_nib;i++,ib++)
	{ /* Correct all iconblk field pointers */
		ib->ib_pmask = (short*)((unsigned long)ib->ib_pmask+base);
		ib->ib_pdata = (short*)((unsigned long)ib->ib_pdata+base);
		ib->ib_ptext = (char*)((unsigned long)ib->ib_ptext+base);
	}

	bb = (BITBLK*)(base+(unsigned long)hdr.rsh_bitblk);
	for (i=0;i<hdr.rsh_nbb;i++,bb++) /* Correct all bitblk data pointers */
		bb->bi_pdata = (short*)((unsigned long)bb->bi_pdata+base);
	if (hdr.rsh_vrsn&4)
	{ /* It's an enhanced RSC file */

		earray = (unsigned long*)(osize+(long)base);

		cibh = (CICONBLK**)(earray[1]+(long)base);
		if ((long)cibh>0L)
		{ /* Get colour icons */
			while (*cibh++!=(CICONBLK*)-1L)
				numCibs++;

			cib = (CICONBLK*)cibh;
			cibh = (CICONBLK**)(earray[1]+(long)base);
			for (i=0;i<numCibs;i++)
			{ /* Fix up all the CICONBLK's */
				cibh[i] = cib;
				ib = &cib->monoblk;
				size = 2UL*(unsigned long)(ib->ib_wicon/16)*(unsigned long)ib->ib_hicon;
				addr = (unsigned long*)((long)cib+sizeof(ICONBLK));
				numRez = (short)*addr;
				pdata = (short*)&addr[1];
				ib->ib_pdata = pdata;
				ib->ib_pmask = (short*)((long)pdata+size);
				ptext = (char*)((long)pdata+size*2L);
				ib->ib_ptext = ptext;
				ptext[11] = 0;
				cicn = (CICON*)((long)ptext+12L);
				cib->mainlist = cicn;
				for (j=0;j<numRez;j++)
				{ /* Get CICON's at different rez's */
					pcicn = cicn;
					pdata = (short*)((long)cicn+sizeof(CICON));
					cicn->col_data = pdata;
					cicn->col_mask = (short*)((long)pdata+size*(unsigned long)cicn->num_planes);
					if (cicn->sel_data!=NULL)
					{ /* It's got a selected form */
						cicn->sel_data = (short*)((long)cicn->col_mask+size);
						cicn->sel_mask = (short*)((long)cicn->sel_data+size*(unsigned long)cicn->num_planes);
						cicn = (CICON*)((long)pcicn+sizeof(CICON)+2L*size*((unsigned long)pcicn->num_planes+1L));
					}
					else
					{ /* No selected version */
						cicn->sel_data = cicn->sel_mask = NULL;
						cicn = (CICON*)((long)pcicn+sizeof(CICON)+size*((unsigned long)pcicn->num_planes+1L));
					}
					if (pcicn->next_res==(CICON*)1L)
						pcicn->next_res = cicn;
					else
						pcicn->next_res = NULL;
				}
				cib = (CICONBLK*)cicn;
			}
		}
	}

	obj = (OBJECT*)(base+(unsigned long)hdr.rsh_object);
	for (i=0;i<hdr.rsh_nobs;i++,obj++)
	{ /* Correct all objects' ob_spec pointers */
		type = obj->ob_type&255;
		switch (type)
		{ /* What kind of object is it? */
			case G_TEXT:
			case G_BOXTEXT:
			case G_IMAGE:
			case G_BUTTON:
			case G_STRING:
			case G_FTEXT:
			case G_FBOXTEXT:
			case G_ICON:
			case G_TITLE:
				obj->ob_spec = (void*)((unsigned long)obj->ob_spec+base);
				break;
			case G_CICON:
				FixColourIconData(cibh[(long)obj->ob_spec]);
				obj->ob_spec = cibh[(long)obj->ob_spec];
				break;
			case G_PROGDEF:
				obj->ob_spec = NULL;
				break;
			case G_IBOX:
			case G_BOX:
			case G_BOXCHAR:
				break;
			default:
				Cconws("Unknown object type\r\n");
				break;
		}
	}

	index = (unsigned long*)(base+(unsigned long)hdr.rsh_trindex);
	for (i=0;i<hdr.rsh_ntree;i++,index++)
	{
		tree = obj = (OBJECT*)(*index+(unsigned long)base);
		if ((obj[3].ob_type&255)!=G_TITLE) /* Not a menu tree */
			do { /* Fix all object coordinates */
				obj->ob_x = (((obj->ob_x&255)*designWidth+(obj->ob_x>>8))*resWidth)/designWidth;
				obj->ob_y = (((obj->ob_y&255)*designHeight+(obj->ob_y>>8))*resHeight)/designHeight;
				obj->ob_width = (((obj->ob_width&255)*designWidth+(obj->ob_width>>8))*resWidth)/designWidth;
				obj->ob_height = (((obj->ob_height&255)*designHeight+(obj->ob_height>>8))*resHeight)/designHeight;
			} while (!(obj++->ob_flags&LASTOB));
		else
		{ /* Standard AES menu */
			j = 0;
			do { /* Use conventional AES routine */
/*				rsrc_obfix(tree,j);		// GEMAES */
			} while (!(tree[j++].ob_flags&LASTOB));
		}
	}
	return (void*)base;
}


/*
	FreeResources : Dispose of a set of loaded resources
	base = pointer to base of resources
*/
void FreeResources(void *base)
{
	Mfree(base);
}


/*
	ResourceTree : Find the tree with a given index
	base = pointer to base of resources
	num = index number of tree
	Return = pointer to tree or NULL on failure
*/
OBJECT *ResourceTree(void *base,short num)
{
	unsigned long *index,offset;
	RSHDR *hdr = (RSHDR*)base;

	if ((!hdr)||(num<0)||(num>=hdr->rsh_ntree))
		return NULL;
	index = (unsigned long*)((unsigned long)base+(unsigned long)hdr->rsh_trindex);
	offset = index[num];
	return (OBJECT*)((unsigned long)base+offset);
}

/* ResourceString : Find the string with a given index
	base = pointer to base of resources
	num = index number of string
	Return = pointer to string or NULL on failure
*/
char *ResourceString(void *base,short num)
{
	unsigned long *index,offset;
	RSHDR *hdr = (RSHDR*)base;

	if (!(hdr)||(num<0)||(num>=hdr->rsh_nstring))
		return(NULL);
	index = (unsigned long*)((unsigned long)base+(unsigned long)hdr->rsh_frstr);
	offset = index[num];
	return((char*)((unsigned long)base+offset));
}

/*
	ResourceImage : Find the image with a given index
	base = pointer to base of resources
	num = index number of image
	Return = pointer to image or NULL on failure
*/
void *ResourceImage(void *base,short num)
{
	unsigned long *index,offset;
	RSHDR *hdr = (RSHDR*)base;

	if ((!hdr)||(num<0)||(num>=hdr->rsh_nimages))
		return(NULL);
	index = (unsigned long*)((unsigned long)base+(unsigned long)hdr->rsh_frimg);
	offset = index[num];
	return((void*)((unsigned long)base+offset));
}
