/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <fcntl.h>
#include <osbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "xa_rsrc.h"
#include "objects.h"		/* HR */
#include "xa_shel.h"		/* HR */

/*
 *	RESOURCE FILE HANDLER
 *
 *	Simulate the standard GEM AES resource access functions.
 *	
 *	I've added these to Steve's routines to act as a bit of an interface
 *	to his routines. Each application has its own std_resource as part
 *	of the XA_CLIENT structure. As Steve's resource loader is happy to
 *	allow multiple resource files, I should add some extra calls to support it.
 */


/*
 * Fixup OBJECT coordinates; the lower byte contains a (character-based)
 * coordinate, the upper byte an additional (pixel) offset.
 */
/*
#define fixup(val,scale) (((val) & 0xff) * (scale) + (((val) >> 8) & 0xff))
*/
static
short fixup(short val, short scale)
{
	return (val&0xff)*scale + ((val>>8)&0xff);
}

global
void obfix(OBJECT *tree, short object)
{
	OBJECT *o = &tree[object];

	o->r.x = fixup(o->r.x, screen.c_max_w) ;
	o->r.y = fixup(o->r.y, screen.c_max_h) ;
	/*
	 * Special case handling: any OBJECT 80 characters wide is supposed
	 * to be a menu bar, which always covers the entire screen width...
	 */
	o->r.w = (o->r.w == 80) ?
			screen.r.w : fixup(o->r.w, screen.c_max_w) ;
	o->r.h = fixup(o->r.h, screen.c_max_h) ;
}

/*
 * Code in this module is based on the resource loader from
 * Steve Sowerby's AGiLE library. Thanks to Steve for allowing
 * me to use his code.
 */

static
short resWidth, resHeight;

/*
 * FixColourIconData : Convert a colour icon from device independent to device specific
 */
static
void FixColourIconData(XA_CLIENT *client, CICONBLK *icon, long base)	/* base is usefull for debug info */
{
	CICON *c;
	MFDB src, dst;
	unsigned long len, icon_len, new_len;
	short *new_data;
	short *tmp = 0;
/*	bool have_planes = false;			/* Do not transform icons that wont be needed. */
*/
	len = calc_back(&icon->monoblk.ic, 1);		/* HR: use functions !! */

DIAG((D.s,-1,"color icon: '%s' %d*%d %ld tx.w=%d\n",
		icon->monoblk.ib_ptext,
		icon->monoblk.ic.w, icon->monoblk.ic.h, len, icon->monoblk.tx.w));

	c = icon->mainlist;
	while (c /* and !have_planes */)
	{
/*		have_planes = c->num_planes == screen.planes;
*/		icon_len  = c->num_planes * len;
		new_len  = screen.planes * len;

DIAG((D.s,-1,"icon_len %ld, new_len %ld\n", icon_len, new_len));
		if (c->num_planes < screen.planes)	/* Create padded data if necessary */
		{
			if (!c->sel_data)
			{
				DIAG((D.x,-1,"XA_alloc 3 %ld\n", new_len));
				new_data = XA_alloc(&client->base, new_len, 3, client->rsct);		/* HR: and put in a list. */
				memcpy(        new_data,  c->col_data, icon_len);
				memset((char *)new_data + icon_len, 0, new_len - icon_len);
			} else
			{
				DIAG((D.x,-1,"XA_alloc 4 %ld\n", new_len * 2));
				new_data = XA_alloc(&client->base, new_len * 2, 4, client->rsct);	/* HR: and put in a list. */
				memcpy(        new_data,            c->col_data, icon_len);
				memset((char *)new_data + icon_len, 0, new_len - icon_len);
				memcpy((char *)new_data + new_len,  c->sel_data, icon_len);
				memset((char *)new_data + new_len + icon_len, 0, new_len - icon_len);
				c->sel_data = (short *)((char *)new_data + new_len);
			}
			c->col_data = new_data;
		}

		src.fd_w = icon->monoblk.ic.w;			/* Transform MFDB's */
		src.fd_h = icon->monoblk.ic.h;
		src.fd_wdwidth = (src.fd_w + 15) / 16;		/* HR: round up */
		src.fd_stand = 1;
		src.fd_r1 = src.fd_r2 = src.fd_r3 = 0;
		src.fd_nplanes = screen.planes;		/* HR */
		dst = src;

		dst.fd_addr = c->col_data;
		dst.fd_stand = 0;

		DIAG((D.rsrc, client->pid,"icon_len > MAX_IN_PLACE_TRNFM ?? %ld\n", icon_len));
		if (icon_len > MAX_IN_PLACE_TRNFM)
		{		/* HR: tmp is a local zeroised pointer */
					/* HR: bad bug!!  was icon_len + 10 ?? (too small!!) */
			DIAG((D.x,-1,"XA_calloc %d*%ld\n", 1, new_len));
			tmp = XA_calloc(&client->base, 1, new_len, 0, client->rsct);
			memcpy(tmp, c->col_data, new_len);
			src.fd_addr = tmp;
		} else
			src.fd_addr = c->col_data;

		vr_trnfm(C.vh, &src, &dst);

		if (c->sel_data)
		{
			dst.fd_addr = c->sel_data;
			if (icon_len > MAX_IN_PLACE_TRNFM)
				memcpy(tmp, c->sel_data, new_len);	/* HR: was icon_len */			
			else
				src.fd_addr = c->sel_data;
			vr_trnfm(C.vh, &src, &dst);
		}
/*		if (screen.planes > 8)		/* transform in place to higher colors system */
		{
			src.fd_nplanes = screen.planes;
			dst.fd_nplanes = screen.planes;
			src.fd_addr = c->col_data;
			dst.fd_addr = c->col_data;
			src.fd_stand = 0;
			dst.fd_stand = 0;
			vr_trnfm(C.vh, &src, &dst);
			if (c->sel_data)
			{
				src.fd_addr = c->sel_data;
				dst.fd_addr = c->sel_data;
				vr_trnfm(C.vh, &src, &dst);
			}
		}
*/		c = c->next_res;
	}
	
	if (tmp)
		free(tmp);
}

#if 0
static
void list_free(XA_CLIENT *client, short ct)
{
	XA_RSCS *m = client->resources, *next;
DIAG((D.rsrc,client->pid,"list_free: %lx for %d\n", m, client->pid));
	while (m)
	{
		next = m->next;
		if (m->ct == ct)
		{
			if (m == client->resources)
				client->resources = m->next;
			if (m->prior)
				m->prior->next = m->next;
			if (m->next)
				m->next->prior = m->prior;
			
DIAG((D.rsrc,client->pid,"XA_freeed: @ %lx for %d\n", m, client->pid));
			XA_free(&client->base, m);
		}
		m = next;
	}
}
#endif

static
void list_resource(XA_CLIENT *client, void *resource)
{
	XA_RSCS *new;
	DIAG((D.x,-1,"XA_alloc 2 %ld\n", sizeof(XA_RSCS)));
	new = XA_alloc(&client->base, sizeof(XA_RSCS), 2, 0);
	if (new)
	{
DIAG((D.rsrc,client->pid,"list_resource %ld(%lx) for %s(%d) rsc:%ld(%lx)\n",new, new, client->name, client->pid, resource, resource));
		if (client->resources)
			client->resources->prior = new;		/* 1 */
		new->next = client->resources;			/* 2 */
		client->resources = new;			
		new->prior = nil;
		new->id = 2;
		new->ct = client->rsct;
		new->rsc = resource;
	}
}

/*
 * LoadResources : Load a GEM resource file
 * fname = name of file to load
 * Return = base pointer of resources or nil on failure
 */
global
void *LoadResources(XA_CLIENT *client, char *fname, RSHDR *rshdr, short designWidth, short designHeight)
{
	long err;
	short handle;
	RSHDR hdr;
	OBJECT *obj, **trees;

	IFDIAG (OBJECT *tree;
	        short pid = client->pid;)

	CICONBLK **cibh;
	unsigned long osize, size;
	char *base;
	short i, j, type, numCibs = 0;

	resWidth = screen.c_max_w;
	resHeight = screen.c_max_h;

	if (fname)
	{
		DIAG((D.rsrc,pid,"LoadResources(%s)\n", fname));
		
		err = Fopen(fname, O_RDONLY);
		if (err < 0L)
		{
			DIAG((D.rsrc,pid,"LoadResources(): file not found\n"));
			return nil;
		}
		handle = (short)err;
		Fread(handle, sizeof(RSHDR), &hdr);
		size = (unsigned long)hdr.rsh_rssize;
		osize = (size + 1UL) & 0xfffffffeUL;
		if (hdr.rsh_vrsn & 4)	/* Extended format, get new 32-bit length */
		{
			Fseek(osize,handle, 0);
			Fread(handle, 4L, &size);
			DIAG((D.rsrc,pid,"extended format osize=%ld: read extended size=%ld\n", osize, size));
		}
	
		Fseek(0L, handle, 0);
	
		DIAG((D.x,-1,"XA_alloc 1 %ld\n", size));
		base = XA_alloc(&client->base, size, 1, client->rsct + 1);	/* HR: and put in a list. */
		if (!base)
		{
			DIAG((D.rsrc,pid,"Can't allocate space for resource file\n"));
			Fclose(handle);
			return nil;
		}

		Fread(handle, size, base);			/* Reread everything */
		Fclose(handle);
	othw
		DIAG((D.rsrc,pid,"LoadResources %ld(%lx)\n", rshdr, rshdr));
		if (rshdr)
		{
			hdr = *rshdr;
			(RSHDR *)base = rshdr;
			size = (unsigned long)hdr.rsh_rssize;
			osize = (size + 1UL) & 0xfffffffeUL;
		}
	}

	client->rsct++;

	list_resource(client, base);			/* Put the resource in a list. */

	{	/* fixup all free string pointers */
		char **fs = (char **)(base + hdr.rsh_frstr);
		for (i = 0; i < hdr.rsh_nstring; i++, fs++)
		{
			IFDIAG (char *d = *fs;)
			*fs += (long)base;
			DIAG((D.s,pid,"fs[%d]>%ld='%s'\n",i,d,*fs));
		}
		
		DIAG((D.rsrc,pid,"fixed up %d free_string pointers\n",hdr.rsh_nstring));
	}
	{	/* HR: fixup all free image pointers */
		char **fs = (char **)(base + hdr.rsh_frimg);
		for (i = 0; i < hdr.rsh_nimages; i++, fs++)
		{
			IFDIAG (char *d = *fs;)
			*fs += (long)base;
			DIAG((D.s,pid,"imgs[%d]>%ld=%lx\n",i,d,*fs));
		}
		
		DIAG((D.rsrc,pid,"fixed up %d free_image pointers\n",hdr.rsh_nimages));
	}
	{	/* fixup all tedinfo field pointers */
		TEDINFO *ti = (TEDINFO *)(base + hdr.rsh_tedinfo);
		for (i = 0; i < hdr.rsh_nted; i++, ti++)
		{
			(long)ti->te_ptext  += (long)base;
			(long)ti->te_ptmplt += (long)base;
			(long)ti->te_pvalid += (long)base;
		}
	
		DIAG((D.rsrc,pid,"fixed up %d tedinfo's\n",hdr.rsh_nted));
	}
	{	/* fixup all iconblk field pointers */
		ICONBLK *ib = (ICONBLK *)(base + hdr.rsh_iconblk);
		for (i = 0; i < hdr.rsh_nib; i++, ib++)
		{
			(long)ib->ib_pmask += (long)base;
			(long)ib->ib_pdata += (long)base;
			(long)ib->ib_ptext += (long)base;
		}
		
		DIAG((D.rsrc,pid,"fixed up %d iconblk's\n", hdr.rsh_nib));
	}
	{	/* fixup all bitblk data pointers */
		BITBLK *bb = (BITBLK *)(base + hdr.rsh_bitblk);
		for (i = 0; i < hdr.rsh_nbb; i++, bb++)
		{
			(long)bb->bi_pdata += (long)base;
		}

		DIAG((D.rsrc,pid,"fixed up %d bitblk's\n", hdr.rsh_nbb));
	}

	if (hdr.rsh_vrsn & 4)	/* It's an enhanced RSC file */
	{
		unsigned long *earray, *addr;

		DIAG((D.rsrc,pid,"Enhanced resource file\n"));

		earray = (unsigned long *)(osize + (long)base);		/* this the row of pointers to extensions */
															/*          terminated by a 0L */
		cibh = (CICONBLK **)(earray[1] + (long)base);
		if ((long)cibh > 0L)	/* Get colour icons */
		{
			CICONBLK *cib, **cp = cibh;

			while (*cp++ != (CICONBLK *) -1L)
				numCibs++;

			cib = (CICONBLK *)cp;

			for (i = 0; i < numCibs; i++)	/* Fix up all the CICONBLK's */
			{
				CICON *cicn;
				ICONBLK *ib = &cib->monoblk;
				short *pdata, numRez;

				cibh[i] = cib;
				size = calc_back(&ib->ic, 1);				/* HR:  use functions! once good, always good. */
				addr = (unsigned long*)((long)cib + sizeof(ICONBLK));
				numRez = addr[0];
				pdata = (short *)&addr[1];
				ib->ib_pdata = pdata;						/* mono data & mask */
				(long)pdata += size;
				ib->ib_pmask = pdata;
				(long)pdata += size;
/* HR: the texts are placed the same way as for all other objects
		when longer than 12 bytes.		*/
				if (ib->ib_ptext)
				{
					short l = ib->tx.w/6;
					ib->ib_ptext += (long)base;		/* HR: fix some resources */
					if (strlen(ib->ib_ptext) > l)
						*(ib->ib_ptext + l) = 0;
				} else
/*	HR: The following word is no of planes which cannot be larger than 32, so there is 1 zero byte there */
					ib->ib_ptext = (char *)pdata; 

				(long)pdata += 12;						/* (unused) place for name */

				cicn = (CICON *)pdata;
/* HR: There can be color icons with NO color icons, only the mono icon block. */
				cib->mainlist = nil;
				for (j = 0; j < numRez; j++)	/* Get CICON's at different rez's */
				{
					short planes = cicn->num_planes;
					long psize = size * planes;
					(long)pdata += sizeof(CICON);
					cicn->col_data = pdata;
					(long)pdata += psize;
					cicn->col_mask = pdata;
					(long)pdata +=  size;
					if (cicn->sel_data)				/* It's got a selected form */
					{
						cicn->sel_data = pdata;
						(long)pdata += psize;
						cicn->sel_mask = pdata;
						(long)pdata +=  size;
					} else	/* No selected version */
						cicn->sel_data = cicn->sel_mask = nil;

/* HR */			if (cib->mainlist == nil)
						cib->mainlist = cicn;

					if ((long)cicn->next_res == 1)
						cicn->next_res = (CICON *)pdata;
					else
						cicn->next_res = nil;

					cicn = (CICON *)pdata;
				}
				cib = (CICONBLK *)cicn;
			}
			DIAG((D.rsrc,pid,"fixed up %d color icons\n", numCibs));
		}
	}

/* HR: As you see, the objects are NOT in a pointer array!!! */
	obj = (OBJECT *)(base + hdr.rsh_object);

	IFDIAG (tree = obj;)

	for (i = 0; i < hdr.rsh_nobs; i++, obj++)	/* fixup all objects' ob_spec pointers */
	{
		type = obj->ob_type & 255;
DIAG((D.s,pid,"obj[%d]>%ld=%lx, %s;\t%d,%d,%d\n",
						i,
						(long)obj-(long)base,
						obj,
						object_type(tree,i),
						obj->ob_next,obj->ob_head,obj->ob_tail));
		switch (type) 	/* What kind of object is it? */
		{
		case G_TEXT:
		case G_BOXTEXT:
		case G_IMAGE:
		case G_BUTTON:
		case G_STRING:
		case G_SHORTCUT:	/* HR */
		case G_FTEXT:
		case G_FBOXTEXT:
		case G_ICON:
		case G_TITLE:
/*			obj->ob_spec = (void *)((unsigned long)obj->ob_spec + base);  */
			obj->ob_spec.string += (long)base;
			break;
		case G_CICON:
			FixColourIconData(client, cibh[obj->ob_spec.lspec], (long)base);
			obj->ob_spec.ciconblk = cibh[obj->ob_spec.lspec];
			break;
		case G_PROGDEF:
			obj->ob_spec.appblk = nil;
			break;
		case G_IBOX:
		case G_BOX:
		case G_BOXCHAR:
			break;
		default:
			DIAG((D.rsrc,pid,"Unknown object type %d\n", type));
			break;
		}
	}

	DIAG((D.rsrc,pid,"fixed up %d objects ob_spec\n", hdr.rsh_nobs));

/* HR!!!!! the pointer array wasnt fixed up!!!!! which made it unusable via global[5] */

	(unsigned long)trees = (unsigned long)(base + hdr.rsh_trindex);		/* HR: OBJECT **trees */
	for (i = 0; i < hdr.rsh_ntree; i++)
	{
		(unsigned long)trees[i] += (unsigned long)base;
		DIAG((D.s,pid,"tree[%d]>%ld = %lx\n",i,(long)trees[i]-(long)base,trees[i]));

		obj = trees[i];
		if ((obj[3].ob_type & 255) != G_TITLE)		/* Not a menu tree */
			do
			{			/* Fix all object coordinates */
				obj->r.x = (((obj->r.x & 255) * designWidth + (obj->r.x >> 8)) * resWidth) / designWidth;
				obj->r.y = (((obj->r.y & 255) * designHeight + (obj->r.y >> 8)) * resHeight) / designHeight;
				obj->r.w = (((obj->r.w & 255) * designWidth + (obj->r.w >> 8)) * resWidth) / designWidth;
				obj->r.h = (((obj->r.h & 255) * designHeight + (obj->r.h >> 8)) * resHeight) / designHeight;
			} while ( ! (obj++->ob_flags & LASTOB));
		else	/* Standard AES menu */
		{
			j = 0;
			do
				obfix(obj, j);
			while ( ! (obj[j++].ob_flags & LASTOB));
		}
	}
	
	return (void *)base;
}

/* HR */
static
void Rsrc_setglobal(XA_CLIENT *client)
{
	if (client->globl_ptr)		/* The AES itself doesnt set this. */
	{
		RSHDR *h;
		OBJECT **o;
		h = client->std_resource;
		(unsigned long)o = (unsigned long)h + h->rsh_trindex;
	/* Fill in the application's global array with a pointer to the resource */
/* HR 150501:
   At last give in to the fact that it is a struct, NOT an array */
		client->globl_ptr->ptree = o;
		client->globl_ptr->rshdr = h;
		DIAG((D.rsrc,-1,"Resources %ld(%lx) in global[5,6]\n", o, o));
		DIAG((D.rsrc,-1,"      and %ld(%lx) in global[7,8]\n", h, h));
	}
}

/*
 * FreeResources : Dispose of a set of loaded resources
 * HR: improvements regarding multiple resources.
 */
global
void FreeResources(XA_CLIENT *client)
{
	XA_RSCS *cur = client->resources;
DIAG((D.rsrc,client->pid,"FreeResources: %ld for %d, ct=%d\n", cur, client->pid, client->rsct));

	if (cur and client->rsct)
	{
/* Put older rsrc back, and the pointer in global */
		while (cur)
		{
			XA_RSCS *nx = cur->next;
			if (cur->ct == client->rsct)	/* free the entry for the freed rsc. */
			{
				short i;
				RSHDR *hdr = cur->rsc;
				char *base = cur->rsc;
				OBJECT **trees,*obj;

/* Free the memory allocated for scroll list objects. */

				(unsigned long)trees = (unsigned long)(base + hdr->rsh_trindex);
				for (i = 0; i < hdr->rsh_ntree; i++)
				{
					short f = 0;
					obj = trees[i];
					do
					{	if ((obj[f].ob_type & 255) == G_SLIST)
							XA_free(&client->base, obj[f].ob_spec.listbox);
					} while ( ! (obj[f++].ob_flags & LASTOB));
				}
		
				XA_free_all(&client->base, -1, client->rsct);

				if (cur->prior)
					cur->prior->next = cur->next;
				if (cur->next)
					cur->next->prior = cur->prior;
				DIAG((D.rsrc,client->pid,"Free cur %ld\n", (long)cur - 16));
				XA_free(&client->base, cur);
			}
			else
			if (cur->ct == client->rsct - 1)		/* Yeah, there is a resource left! */
			{
				client->std_resource = cur->rsc;
				Rsrc_setglobal(client);
			}
			cur = nx;
		}
		client->rsct--;
	}
}


/*
 *	HR: The routines below are almost entirely rewritten such, that it is
 *      quite easy to see the subtle differences.
 *
 * ResourceTree : Find the tree with a given index
 * hdr = pointer to base of resources
 * num = index number of tree
 * Return = pointer to tree or object or stuff, or nil on failure
 */

#define num_nok(t) (!hdr or num < 0 or num >= hdr->rsh_ ## t)
#define start(t) (unsigned long)index = (unsigned long)hdr + hdr->rsh_ ## t

/* HR: fixing up the pointer array is now done in Loadresources, to make it usable via global[5] */
global
OBJECT *ResourceTree(RSHDR *hdr, short num)
{
	OBJECT **index;
	
	if num_nok(ntree)
		return nil;
	start(trindex);
	return index[num];
}

/* Find the object with a given index  */
static
OBJECT *ResourceObject(RSHDR *hdr, short num)
{
	OBJECT *index;

	if num_nok(nobs)
		return nil;
	start(object);
	return index + num;
}

/* Find the tedinfo with a given index */
static
TEDINFO *ResourceTedinfo(RSHDR *hdr, short num)
{
	TEDINFO *index;

	if num_nok(nted)
		return nil;
	start(tedinfo);
	return index + num;
}

/* Colour icons are too new */

/* Find the iconblk with a given index */
static
ICONBLK *ResourceIconblk(RSHDR *hdr, short num)
{
	ICONBLK *index;

	if num_nok(nib)
		return nil;
	start(iconblk);
	return index + num;
}

/* Find the bitblk with a given index */
static
BITBLK *ResourceBitblk(RSHDR *hdr, short num)
{
	BITBLK *index;

	if num_nok(nbb)
		return nil;
	start(bitblk);
	return index + num;
}

/* Find the string with a given index */

/* HR: I think free_strings are the target; The only difference
			is the return value.
	   Well at least TERADESK now works the same as with other AES's */

static
char *ResourceString(RSHDR *hdr, short num)
{
	char **index;

	if num_nok(nstring)
		return nil;
	start(frstr);
DIAG((D.s,-1,"Gaddr 5 %lx '%s'\n", index[num], index[num]));
	return index[num];
}

/* Find the image with a given index */
/* HR: images (like strings) have no fixed length, so they must be held
       (like strings) in a pointer array, which should have been fixed up.
       Where????? Well I couldnt find it, so I wrote it, see loader.
 */
static
void *ResourceImage(RSHDR *hdr, short num)
{
	void **index;

	if num_nok(nimages)
		return nil;
	start(frimg);
	return index[num];
}

/* HR: At last the following 2 make sense */

/* Find the ref to the free strings array */
static
char **ResourceFrstr(RSHDR *hdr, short num)
{
	char **index;

	start(frstr);
DIAG((D.s,-1,"Gaddr 15 %lx '%s'\n", index, *index));
	return index;
}

/* Find the ref to free images array */
static
void **ResourceFrimg(RSHDR *hdr, short num)
{
	void **index;

	start(frimg);
DIAG((D.s,-1,"Gaddr 16 %lx\n", index));
	return index;
}

AES_function XA_rsrc_load		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *path;

	CONTROL(0,1,1)

/* If the client is overwriting its existing resource then better free it
	 (it shouldn't, but just in case) */
/* I don't think this is a good idea - much better to have a memory leak
	than a process continuing to access a freed memory region; GEM AES
	doesn't auto-free an existing RSC either, so this would be
	incompatible anyway... <mk>

	HR: suggestion: put them in a list, last in front. So you can free what is
	    left in XA_client_exit.
	    7/9/200   done.  As well as the memory allocated for colour icon data.
*/
	path = shell_find(lock, client, pb->addrin[0]);
	
	if (path)
	{
		DIAG((D.rsrc,client->pid,"rsrc_load('%s')\n", path));
	
		client->std_resource = LoadResources(client, path, nil, DU_RSX_CONV, DU_RSY_CONV);
		if (client->std_resource)
		{
#if GENERATE_DIAGS
			if (client->globl_ptr != pb->globl)
			{
				DIAGS(("WARNING: rsrc_load global is different from appl_init's global\n"));
			}
#endif
			Rsrc_setglobal(client);
	
			pb->intout[0] = 1;
			return XAC_DONE;
		}
	}

	DIAGS(("ERROR: rsrc_load '%s' failed\n", pb->addrin[0] ? pb->addrin[0] : "~~"));
	pb->intout[0] = 0;
	return XAC_DONE;
}

AES_function XA_rsrc_free		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,1,0)

	if (client->std_resource)
	{
		FreeResources(client);
		pb->intout[0] = 1;
	} else
	{
		pb->intout[0] = 0;
	}

	return XAC_DONE;
}

AES_function XA_rsrc_gaddr	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	void **addr = (void **)pb->addrout;
	short type = pb->intin[0], index = pb->intin[1];

	CONTROL(2,1,0)

	DIAG((D.s,-1,"rsrc_gaddr type %d, index %d\n", type, index));

	if (!client->std_resource)
		client->std_resource = client->globl_ptr->rshdr;	/* HR 310501 global is a structure */

	if (!client->std_resource)
	{
		pb->intout[0] = 0;
		if (addr)
			*addr = nil;
		DIAG((D.rsrc,-1,"NO resource loaded!!!\n"));
		return XAC_DONE;
	}

	if (addr)	/* HR: It is better to let the client bomb out in stead of precious us. */
	{
		switch(type)
		{
		default:
			pb->intout[0] = 0;
			break;
		case R_TREE:
			*addr = ResourceTree(client->std_resource, index);
			break;
		case R_OBJECT:
			*addr = ResourceObject(client->std_resource, index);
			break;
		case R_TEDINFO:
			*addr = ResourceTedinfo(client->std_resource, index);
			break;
		case R_ICONBLK:
			*addr = ResourceIconblk(client->std_resource, index);
			break;
		case R_BITBLK:
			*addr = ResourceBitblk(client->std_resource, index);
			break;
/*!*/	case R_STRING:
			*addr = ResourceString(client->std_resource, index);		/* HR */
			break;
/*!*/	case R_IMAGEDATA:
			*addr = ResourceImage(client->std_resource, index);
			break;
		case R_OBSPEC:
			*addr = (void *)ResourceObject(client->std_resource, index)->ob_spec.lspec;
			break;
		case R_TEPTEXT:
			*addr = ResourceTedinfo(client->std_resource, index)->te_ptext;
			break;
		case R_TEPTMPLT:
			*addr = ResourceTedinfo(client->std_resource, index)->te_ptmplt;
			break;
		case R_TEPVALID:
			*addr = ResourceTedinfo(client->std_resource, index)->te_pvalid;
			break;
		case R_IBPMASK:
			*addr = ResourceIconblk(client->std_resource, index)->ib_pmask;
			break;
		case R_IBPDATA:
			*addr = ResourceIconblk(client->std_resource, index)->ib_pdata;
			break;
		case R_IBPTEXT:
			*addr = ResourceIconblk(client->std_resource, index)->ib_ptext;
			break;
		case R_BIPDATA:
			*addr = ResourceBitblk(client->std_resource, index)->bi_pdata;
			break;
/*!*/	case R_FRSTR:
			*addr = ResourceFrstr(client->std_resource, index);
			break;
/*!*/	case R_FRIMG:
			*addr = ResourceFrimg(client->std_resource, index);
			break;
		}
		DIAG((D.s,-1,"  --> %ld\n",*addr));		
		pb->intout[0] = 1;
	}
	else
		pb->intout[0] = 0;
	return XAC_DONE;
}

AES_function XA_rsrc_obfix	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,1,1)

	obfix((OBJECT *)pb->addrin[0], pb->intin[0]);
	pb->intout[0] = 1;
	return XAC_DONE;
}

/* HR 240601 implementation. */
AES_function XA_rsrc_rcfix		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,1,1)
	
	DIAG((D.rsrc,client->pid,"rsrc_rcfix for %s(%d) on %ld(%lx)\n",client->name, client->pid, pb->addrin[0], pb->addrin[0]));

	client->std_resource = LoadResources(client, nil, pb->addrin[0], DU_RSX_CONV, DU_RSY_CONV);
	if (client->std_resource)
	{
#if GENERATE_DIAGS
		if (client->globl_ptr != pb->globl)
		{
			DIAGS(("WARNING: rsrc_rcfix global %ld(%lx) is different from appl_init's global %ld(%lx)\n", pb->globl, pb->globl, client->globl_ptr, client->globl_ptr));
		/*	client->globl_ptr = pb->globl; */
		}
#endif
		Rsrc_setglobal(client);

		pb->intout[0] = 1;
		return XAC_DONE;
	}

	pb->intout[0] = 0;
	return XAC_DONE;
}

