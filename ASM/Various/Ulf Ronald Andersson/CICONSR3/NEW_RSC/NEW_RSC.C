/*
 * new_rsc.c dated 02/13/97
 *
 * (c) 1995-97 by Thomas Binder (binder@rbg.informatik.th-darmstadt.de),
 * Johann-Valentin-May-Straže 7, 64665 Alsbach-H„hnlein, Germany
 *
 * Contains routines to load extended resource-files under all
 * versions of TOS. Requires the routines from drawcicn.c.
 *
 * Permission is granted to spread this routine, but only the .c- and
 * the .h-file together, *unchanged*. Permission is also granted to
 * use this routine in own productions, as long as it's mentioned that
 * the routine was used and that it was written by me.
 *
 * I can't be held responsible for the correct function of this routine,
 * nor for any damage that occurs after the correct or incorrect use of
 * this routine. USE IT AT YOUR OWN RISK!
 *
 * If you find any bugs or have suggestions, please contact me!
 *
 * History:
 * 08/14-
 * 08/15/95: Creation
 * 08/16/95: Moved call rsrc_obfix to the end of get_objects
 * 08/22/95: get_iconblks and get_bitblks now also convert the bitmap-
 *           data into device-dependent format
 * 08/26/95: Removed serious bug which caused crashes when a color
 *           icon had no color data at all (in that case, mainlist
 *           pointed to the ICONBLK of the next color icon instead
 *           of NULL); added new constant named LOAD_MAGIC as a
 *           replacement for the simple 'RSRC'-long and changed the
 *           magic value into 'NRSC'
 * 10/19/95: Memdebug showed a memory leak: I forgot to free the
 *           temporary memory used for speeding up the vr_trnfm-
 *           calls, shame on me...
 * 12/11/96: Removed serious bug which caused crashes with certain
 *           VDIs: The width in pixel of BITBLKs was calculated
 *           wrong :(
 * 02/13/97: Applied Mario Becroft's Lattice C-diffs (with minor
 *           modifications)
 */

#include "new_rsc.h"

/* Workaround for typo in Pure C's aes.h */
#if defined(R_IPBTEXT) && !defined(R_IBPTEXT)
#define R_IBPTEXT	R_IPBTEXT
#endif

#ifdef __TURBOC__
#define LOAD_MAGIC	'NRSC'
#else
#define LOAD_MAGIC	0x4e525343	/* 'NRSC */
#endif

static	void get_cicons(_CICONBLK *table);
static	void get_tedinfos(void);
static	void get_iconblks(void);
static	void get_bitblks(void);
static	void get_frstrs(void);
static	void get_frimgs(void);
static	void get_objects(void);
static	void get_trees(void);

static	RSHDR		*rsc_file;
static	LONG		load_magic;
static	WORD		vh;
static	OBJECT		*rs_object;
static	TEDINFO		*rs_tedinfo;
static	ICONBLK		*rs_iconblk;
static	BITBLK		*rs_bitblk;
static	char		**rs_frstr;
static	WORD		*rs_imdata;
static	BITBLK		**rs_frimg;
static	OBJECT		**rs_trindex;
static	_CICONBLK	**rs_ciconblk;
static  UWORD		rs_ncib;

/*
 * rsc_load
 *
 * This function replaces the call rsrc_load and is able to load
 * extended resource-files, i.e. those with color-icons. In that
 * case, all CICON-objects are automatically transformed into
 * USERDEFs (see drawcicn.c/h), so you can use the resource with
 * older versions of TOS as well. Note that rsc_load doesn't set
 * global[5-9]!
 *
 * Input:
 * rname: Pointer to filename of the resource file, the routine uses
 *        shel_find to locate it, just as the normal rsrc_load would
 *        do.
 *
 * Output:
 * 0: An error occured, i.e. file not found or not enough memory
 *    (sorry that it's not possible to detect the type of error, but
 *    this is a tribute to having compatible return codes).
 * otherwise: Resource file loaded successfully
 */
WORD rsc_load(char *rname)
{
	char		filename[128];
	WORD		handle,
				work_in[11] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
				work_out[57],
				d;
	LONG		err,
				*extension,
				length;
	NRSC_DTA	*old_dta,
				my_dta;

/* Check if there has already been loaded a resource-file */
	if (load_magic == LOAD_MAGIC)
		return(0);
/* If not, try to locate the file and determine its length */
	strcpy(filename, rname);
	if (!shel_find(filename))
		return(0);
	old_dta = (NRSC_DTA *)Fgetdta();
	Fsetdta((ORIG_DTA *)&my_dta);
	err = (LONG)Fsfirst(filename, 0x17);
	Fsetdta((ORIG_DTA *)old_dta);
	if (err)
		return(0);
	length = my_dta.dta_size;
/* Open the file, allocate memory for it and load it */
	if ((handle = (WORD)Fopen(filename, 0)) < 6)
		return(0);
	if ((rsc_file = (RSHDR *)malloc(length)) == NULL)
	{
		Fclose(handle);
		return(0);
	}
	if (Fread(handle, length, rsc_file) != length)
	{
		Fclose(handle);
		free(rsc_file);
		return(0);
	}
	Fclose(handle);
/*
 * Reset the number of color-icon-blocks (it is not member of the
 * resource-header, so it has to be kept in a static variable
 */
	rs_ncib = 0;
/*
 * A quick test if the file is a valid resource file. The test is not
 * very secure, so the routine may crash when the resource file is
 * not what it claims to be.
 */
	if (rsc_file->rsh_vrsn)
	{
/*
 * If rsh_vrsn is not zero, it must be 4 (the identification for an
 * extended resource-file with color-icons), otherwise the file is
 * invalid.
 */
		if (rsc_file->rsh_vrsn != 4)
		{
			free(rsc_file);
			return(0);
		}
/*
 * Calculate the address of the extension array and check if the
 * first long equals the length of the file. If not, the file is
 * invalid.
 */
		extension = (LONG *)((LONG)rsc_file +
			(LONG)rsc_file->rsh_rssize);
		if (*extension++ != length)
		{
			free(rsc_file);
			return(0);
		}
/*
 * Determine the number of color-icons and the address of the
 * slots
 */
		rs_ciconblk = (_CICONBLK **)((LONG)rsc_file + *extension);
		for (; (LONG)(rs_ciconblk[rs_ncib]) != -1L; rs_ncib++);
/* Initialize the color-icons */
		get_cicons((_CICONBLK *)&rs_ciconblk[rs_ncib + 1]);
	}
	if (rs_ncib)
	{
/*
 * If there are color-icons in the resource file, we must now open a
 * virtual VDI-workstation for the drawing routines in drawcicn.c. If
 * this fails, the resource can't be used.
 */
		vh = graf_handle(&d, &d, &d, &d);
		v_opnvwk(work_in, &vh, work_out);
		if (!vh)
		{
			free(rsc_file);
			return(0);
		}
/* Initialise the color-icon-routines (important!) */
		init_routines(vh);
	}
/* Calculate the addresses of the slots... */
	rs_object = (OBJECT *)((LONG)rsc_file + rsc_file->rsh_object);
	rs_tedinfo = (TEDINFO *)((LONG)rsc_file + rsc_file->rsh_tedinfo);
	rs_iconblk = (ICONBLK *)((LONG)rsc_file + rsc_file->rsh_iconblk);
	rs_bitblk = (BITBLK *)((LONG)rsc_file + rsc_file->rsh_bitblk);
	rs_frstr = (char **)((LONG)rsc_file + rsc_file->rsh_frstr);
	rs_imdata = (WORD *)((LONG)rsc_file + rsc_file->rsh_imdata);
	rs_frimg = (BITBLK **)((LONG)rsc_file + rsc_file->rsh_frimg);
	rs_trindex = (OBJECT **)((LONG)rsc_file + rsc_file->rsh_trindex);
/* ... and initialize the data */
	get_tedinfos();
	get_iconblks();
	get_bitblks();
	get_frstrs();
	get_frimgs();
/*
 * Note that objects have to be initialised after all other
 * structures, because objects usually contain pointers to these
 * other structures, so the corresponding slots must be ready-to-use
 * before
 */
	get_objects();
	get_trees();
/* Set the magic to indicate that a resource-file has been loaded */
	load_magic = LOAD_MAGIC;
	return(1);
}

/*
 * rsc_free
 *
 * This function replaces the call rsrc_free and frees all memory
 * allocated by the rsc_load-call (including the memory used by the
 * color-icon-routines).
 *
 * Output:
 * 0: An error occurred, e.g. no call to rsr_load was done before
 * otherwise: Resource and memory freed successfully
 */
WORD rsc_free(void)
{
/* Check if rsc_load has been successfully called before */
	if (load_magic != LOAD_MAGIC)
		return(0);
/*
 * Free all memory allocated by the color-icons and the resource-file
 * itself
 */
	if (rs_ncib)
	{
		deinit_routines();
		v_clsvwk(vh);
	}
	free(rsc_file);
/* Clear the magic to allow a new resource file to be loaded */
	load_magic = 0L;
	return(1);
}

/*
 * rsc_gaddr
 *
 * This function replaces the call rsrc_gaddr and determines
 * the addresses of certain structures found in the resource, e.g.
 * object trees, free strings, etc. Note that rsc_gaddr isn't able
 * to return the addresses of the color-icon-structures, mainly
 * because I have no information if rsrc_gaddr is able to do so, and,
 * if yes, what new constants are used for that. If you know this,
 * please contact me.
 *
 * Input:
 * type: What type of structure is requested. Refer to an AES-
 *       documentation for details
 * index: Index of requested structure
 * address: Pointer to the pointer where the address of the requested
 *          structure should be stored in.
 *
 * Output:
 * 0: An error occurred, e.g. no resource-file was loaded via
 *    rsc_load or the requested structure does not exist (i.e. the
 *    index is out of range). Note that the AES usually doesn't check
 *    this, i.e. rsrc_gaddr may return nonsense in address, which
 *    won't happen with this function.
 * otherwise: Everything OK
 */
WORD rsc_gaddr(WORD type, WORD index, void *address)
{
/* Check if a resource file is available */
	if (load_magic != LOAD_MAGIC)
		return(0);
/* The index can't be less than zero */
	if (index < 0)
		return(0);
/* Don't get confused by the many '*'s in here ;) */
	switch (type)
	{
		case R_TREE:
			if (index >= rsc_file->rsh_ntree)
				return(0);
/* Return the address of the first object of the requested tree */
			*(OBJECT **)address = rs_trindex[index];
			break;
		case R_OBJECT:
			if (index >= rsc_file->rsh_nobs)
				return(0);
/* Return the address of the requested object */
			*(OBJECT **)address = &rs_object[index];
			break;
		case R_TEDINFO:
			if (index >= rsc_file->rsh_nted)
				return(0);
/* Return the address of the requested TEDINFO-structure */
			*(TEDINFO **)address = &rs_tedinfo[index];
			break;
		case R_ICONBLK:
			if (index >= rsc_file->rsh_nib)
				return(0);
/* Return the address of the requested ICONBLK-structure */
			*(ICONBLK **)address = &rs_iconblk[index];
			break;
		case R_BITBLK:
			if (index >= rsc_file->rsh_nbb)
				return(0);
/* Return the address of the requested BITBLK-structure */
			*(BITBLK **)address = &rs_bitblk[index];
			break;
		case R_STRING:
			if (index >= rsc_file->rsh_nstring)
				return(0);
/* Return the address of the requested free string */
			*(char **)address = rs_frstr[index];
			break;
		case R_IMAGEDATA:
			if (index >= rsc_file->rsh_nimages)
				return(0);
/*
 * Return the address of the BITBLK-structure of the requested free
 * image
 */
			*(BITBLK **)address = rs_frimg[index];
			break;
		case R_OBSPEC:
			if (index >= rsc_file->rsh_nted)
				return(0);
/* Return the address of the ob_spec-field of the requested object */
#ifdef LATTICE
			*(BITBLK ***)address = &(BITBLK*)(rs_object[index].ob_spec);
#else
			*(BITBLK ***)address = &rs_object[index].ob_spec.bitblk;
#endif
			break;
		case R_TEPTEXT:
/*
 * Return the address of the pointer to the text of the requested
 * TEDINFO-structure
 */
			if (index >= rsc_file->rsh_nted)
				return(0);
			*(char ***)address = &rs_tedinfo[index].te_ptext;
			break;
		case R_TEPTMPLT:
			if (index >= rsc_file->rsh_nted)
				return(0);
/*
 * Return the address of the pointer to the template of the requested
 * TEDINFO-structure
 */
			*(char ***)address = &rs_tedinfo[index].te_ptmplt;
			break;
		case R_TEPVALID:
			if (index >= rsc_file->rsh_nted)
				return(0);
/*
 * Return the address of the pointer to the valid-input-string of the
 * requested TEDINFO-structure
 */
			*(char ***)address = &rs_tedinfo[index].te_pvalid;
			break;
		case R_IBPMASK:
			if (index >= rsc_file->rsh_nib)
				return(0);
/*
 * Return the address of the pointer to the mask-data of the
 * requested ICONBLK-structure
 */
			*(WORD ***)address = &rs_iconblk[index].ib_pmask;
			break;
		case R_IBPDATA:
			if (index >= rsc_file->rsh_nib)
				return(0);
/*
 * Return the address of the pointer to the icon-data of the
 * requested ICONBLK-structure
 */
			*(WORD ***)address = &rs_iconblk[index].ib_pdata;
			break;
		case R_IBPTEXT:
			if (index >= rsc_file->rsh_nib)
				return(0);
/*
 * Return the address of the pointer to the icon-text of the
 * requested ICONBLK-structure
 */
			*(char ***)address = &rs_iconblk[index].ib_ptext;
			break;
		case R_BIPDATA:
			if (index >= rsc_file->rsh_nbb)
				return(0);
/*
 * Return the address of the pointer to the image-data of the
 * requested BITBLK-structure
 */
			*(WORD ***)address = &rs_bitblk[index].bi_pdata;
			break;
		case R_FRSTR:
			if (index >= rsc_file->rsh_nstring)
				return(0);
/* Return the address of the pointer to the requested free string */
			*(char ***)address = &rs_frstr[index];
			break;
		case R_FRIMG:
			if (index >= rsc_file->rsh_nimages)
				return(0);
/*
 * Return the address of the pointer to the BITBLK-structure of the
 * requested free image
 */
			*(BITBLK ***)address = &rs_frimg[index];
			break;
		default:
/* Indicate an error for invalid values for type */
			return(0);
	}
	return(1);
}

/*
 * get_cicons
 *
 * This function initialises the CICONBLK-structures and their
 * pointers.
 *
 * Input:
 * table: Pointer to first CICONBLK
 */
static void get_cicons(_CICONBLK *table)
{
	LONG	psize;
	char	*help;
	WORD	i,
			j,
			ncdata;
	_CICON	*cicon;

	for (i = 0; i < rs_ncib; i++)
	{
/* Enter the address of the current CICONBLK in the table */
		rs_ciconblk[i] = table;
/* Calculate the size of one plane of the current icon (in bytes) */
		psize = (LONG)((table->monoblk.ib_wicon + 15) / 16) *
			(LONG)table->monoblk.ib_hicon * 2;
/*
 * Step through the current icon and initialise all pointers of the
 * CIOCNBLK with the correct values
 */
		help = (char *)&table[1];
		table->monoblk.ib_pdata = (WORD *)help;
		help += psize;
		table->monoblk.ib_pmask = (WORD *)help;
		help += psize;
		table->monoblk.ib_ptext = help;
		help += 12;
/*
 * Check how many CICONs in different resolutions follow. If there
 * are none, set mainlist to NULL, else initialise the CICONs.
 */
		if ((ncdata = (WORD)table->mainlist) == 0)
			table->mainlist = NULL;
		else
		{
			table->mainlist = (_CICON *)help;
/*
 * Now initialise the linked list of CICON-structures for the current
 * color icon
 */
			for (j = 0; j < ncdata; j++)
			{
				cicon = (_CICON *)help;
				help += sizeof(_CICON);
				cicon->col_data = (WORD *)help;
				help += psize * cicon->num_planes;
				cicon->col_mask = (WORD *)help;
				help += psize;
				if (cicon->sel_data)
				{
					cicon->sel_data = (WORD *)help;
					help += psize * cicon->num_planes;
					cicon->sel_mask = (WORD *)help;
					help += psize;
				}
				else
					cicon->sel_data = cicon->sel_mask = NULL;
				if (j < (ncdata - 1))
					cicon->next_res = (_CICON *)help;
				else
					cicon->next_res = NULL;
			}
		}
		table = (_CICONBLK *)help;
	}
}

/*
 * get_objects
 *
 * Initialises all objects in the resource-file, i.e. it inserts the
 * right pointers for the different object-types and adjusts the
 * sizes.
 */
static void get_objects(void)
{
	WORD	i;

	for (i = 0; i < rsc_file->rsh_nobs; i++)
	{
/*
 * Initialise ob_spec of the current object, depending on its type
 */
		switch (rs_object[i].ob_type & 0xff)
		{
			case G_TEXT:
			case G_BOXTEXT:
			case G_FTEXT:
			case G_FBOXTEXT:
#ifdef LATTICE
				(TEDINFO*)(rs_object[i].ob_spec) =
#else
				rs_object[i].ob_spec.tedinfo =
#endif
					(TEDINFO *)((LONG)rsc_file +
#ifdef LATTICE
					(LONG)rs_object[i].ob_spec);
#else
					(LONG)rs_object[i].ob_spec.tedinfo);
#endif
				break;
			case G_IMAGE:
#ifdef LATTICE
				(BITBLK*)(rs_object[i].ob_spec) =
#else
				rs_object[i].ob_spec.bitblk =
#endif
					(BITBLK *)((LONG)rsc_file +
#ifdef LATTICE
					(LONG)rs_object[i].ob_spec);
#else
					(LONG)rs_object[i].ob_spec.bitblk);
#endif
				break;
			case G_BUTTON:
			case G_STRING:
			case G_TITLE:
#ifdef LATTICE
				(char*)(rs_object[i].ob_spec) =
#else
				rs_object[i].ob_spec.free_string =
#endif
					(char *)((LONG)rsc_file +
#ifdef LATTICE
					(LONG)rs_object[i].ob_spec);
#else
					(LONG)rs_object[i].ob_spec.free_string);
#endif
				break;
			case G_ICON:
#ifdef LATTICE
				(ICONBLK*)(rs_object[i].ob_spec) =
#else
				rs_object[i].ob_spec.iconblk =
#endif
					(ICONBLK *)((LONG)rsc_file +
#ifdef LATTICE
					(LONG)rs_object[i].ob_spec);
#else
					(LONG)rs_object[i].ob_spec.iconblk);
#endif
				break;
			case _G_CICON:
#ifdef LATTICE
				(char*)(rs_object[i].ob_spec) = (char *)
					rs_ciconblk[(LONG)rs_object[i].ob_spec];
#else
				rs_object[i].ob_spec.free_string = (char *)
					rs_ciconblk[(LONG)rs_object[i].ob_spec.iconblk];
#endif
				break;
		}
/*
 * Convert the char-coordinates of the current object into pixel-
 * coordinates
 */
		rsrc_obfix(&rs_object[i], 0);
	}
}

/*
 * get_tedinfos
 *
 * Inserts the correct pointers into the TEDINFO-structures.
 */
static void get_tedinfos(void)
{
	WORD	i;

	for (i = 0; i < rsc_file->rsh_nted; i++)
	{
		rs_tedinfo[i].te_ptext = (char *)((LONG)rsc_file +
			(LONG)rs_tedinfo[i].te_ptext);
		rs_tedinfo[i].te_ptmplt = (char *)((LONG)rsc_file +
			(LONG)rs_tedinfo[i].te_ptmplt);
		rs_tedinfo[i].te_pvalid = (char *)((LONG)rsc_file +
			(LONG)rs_tedinfo[i].te_pvalid);
	}
}

/*
 * get_iconblks
 *
 * Inserts the correct pointers into the ICONBLK-structures and
 * converts mask and data into device-dependent format.
 */
static void get_iconblks(void)
{
	WORD	i,
			du,
			wdw,
			handle,
			*temp;
	MFDB	source,
			dest;
	LONG	psize;

/*
 * Get the handle of the physical AES workstation; this is needed to
 * convert the bitmap data. Using the AES-workstation should normally
 * be avoided, but in this case it saves us the effort of opening
 * an own virtual workstation (which may fail). Additionally, a call
 * to vr_trnfm doesn't influence any parameters of the workstation,
 * so there won't be any problems for the AES afterwards.
 */
	handle = graf_handle(&du, &du, &du, &du);
	for (i = 0; i < rsc_file->rsh_nib; i++)
	{
		rs_iconblk[i].ib_pmask = (WORD *)((LONG)rsc_file +
			(LONG)rs_iconblk[i].ib_pmask);
		rs_iconblk[i].ib_pdata = (WORD *)((LONG)rsc_file +
			(LONG)rs_iconblk[i].ib_pdata);
		rs_iconblk[i].ib_ptext = (char *)((LONG)rsc_file +
			(LONG)rs_iconblk[i].ib_ptext);
		wdw = (rs_iconblk[i].ib_wicon + 15) / 16;
		psize = (LONG)wdw * rs_iconblk[i].ib_hicon * 2L;
/*
 * Try to get temporary memory for vr_trnfm to speed up the
 * transformation. If this fails, vr_trnfm will have to convert the
 * data in the same memory region, leading to performance loss.
 */
		temp = malloc(psize);
		source.fd_addr = rs_iconblk[i].ib_pmask;
		source.fd_w = rs_iconblk[i].ib_wicon;
		source.fd_h = rs_iconblk[i].ib_hicon;
		source.fd_wdwidth = wdw;
		source.fd_stand = source.fd_nplanes = 1;
		dest = source;
		if (temp != NULL)
			dest.fd_addr = temp;
		vr_trnfm(handle, &source, &dest);
		if (temp != NULL)
			memcpy(source.fd_addr, temp, psize);
		source.fd_addr = rs_iconblk[i].ib_pdata;
		source.fd_stand = 1;
		if (temp == NULL)
			dest.fd_addr = source.fd_addr;
		vr_trnfm(handle, &source, &dest);
		if (temp != NULL)
		{
			memcpy(source.fd_addr, temp, psize);
			free(temp);
		}
	}
}

/*
 * get_bitblks
 *
 * Inserts the correct pointers into the BITBLK-structures and
 * converts the bitmap into device dependent format.
 */
static void get_bitblks(void)
{
	WORD	i,
			du,
			wdw,
			handle,
			*temp;
	MFDB	source,
			dest;
	LONG	psize;

/*
 * Get the handle of the physical AES workstation; see get_iconblks
 * for details
 */
	handle = graf_handle(&du, &du, &du, &du);
	for (i = 0; i < rsc_file->rsh_nbb; i++)
	{
		rs_bitblk[i].bi_pdata = (WORD *)((LONG)rsc_file +
			(LONG)rs_bitblk[i].bi_pdata);
		wdw = rs_bitblk[i].bi_wb / 2;
		psize = (LONG)wdw * rs_bitblk[i].bi_hl * 2L;
/*
 * Try to get temporary memory for vr_trnfm to speed up the
 * transformation. If this fails, vr_trnfm will have to convert the
 * data in the same memory region, leading to performance loss.
 */
		temp = malloc(psize);
		source.fd_addr = rs_bitblk[i].bi_pdata;
		source.fd_w = wdw * 16;
		source.fd_h = rs_bitblk[i].bi_hl;
		source.fd_wdwidth = wdw;
		source.fd_stand = source.fd_nplanes = 1;
		dest = source;
		if (temp != NULL)
			dest.fd_addr = temp;
		vr_trnfm(handle, &source, &dest);
		if (temp != NULL)
		{
			memcpy(source.fd_addr, temp, psize);
			free(temp);
		}
	}
}

/*
 * get_frstrs
 *
 * Inserts the correct pointers for the free strings.
 */
static void get_frstrs(void)
{
	WORD	i;

	for (i = 0; i < rsc_file->rsh_nstring; i++)
		rs_frstr[i] = (char *)((LONG)rsc_file + (LONG)rs_frstr[i]);
}

/*
 * get_frimgs
 *
 * Inserts the correct pointers for the free images.
 */
static void get_frimgs(void)
{
	WORD	i;

	for (i = 0; i < rsc_file->rsh_nimages; i++)
		rs_frimg[i] = (BITBLK *)((LONG)rsc_file + (LONG)rs_frimg[i]);
}

/*
 * get_trees
 *
 * Inserts the correct pointers for the object-trees and converts
 * all color-icons into USERDEFs, if necessary and possible.
 */
static void get_trees(void)
{
	WORD	i;

	for (i = 0; i < rsc_file->rsh_ntree; i++)
	{
		rs_trindex[i] = (OBJECT *)((LONG)rsc_file +
			(LONG)rs_trindex[i]);
/*
 * Convert the color-icons of the current tree into USERDEFs (only if
 * the resource contains at least one color icon). Note that if
 * init_tree encounters a memory shortage, all or some of the color-
 * icons are just converted into "normal" icons. The same happens
 * when init_tree doesn't find usable color-icon-data for the current
 * color-depth.
 */
		if (rs_ncib)
			init_tree(rs_trindex[i]);
	}
}

/* EOF */
