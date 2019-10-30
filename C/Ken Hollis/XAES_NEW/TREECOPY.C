/* * treecopy.c * * (c) 1994 by Thomas Binder (binder@rbg.informatik.th-darmstadt.de), * Johann-Valentin-May-Straže 7, 64665 Alsbach-H„hnlein, Germany
 *
 * Modifications by Ken Hollis (khollis@chatlink.com) * * Contains a routine that dublicates an AES-object-tree. * * Permission is granted to spread this routine, but only the .c- and * the .h-file together, *unchanged*. Permission is also granted to * use this routine in own productions, as long as it's mentioned that * the routine was used and that it was written by me. * * I can't be held responsible for the correct function of this routine, * nor for any damage that occurs after the correct or incorrect use of * this routine. USE IT AT YOUR OWN RISK! * * If you find any bugs or have suggestions, please contact me! * * History: * 10/30/94: Creation
 * 12/04/94: Modifications to make sure objects are complient to their
 *			 original object type, and verbose error message if the
 *			 copy didn't work.  Formatted source to look better. */#include "xaes.h"
#include "treecopy.h"/* * tree_copy * * Copy a complete object-tree including all substructures (optional). *
 * CAUTION: The object-tree *must* have the LASTOB-flag (0x20) set in * it's physically last member. *
 * BUG: Up to now tree_copy won't copy the color-icon-structure, * because I'm too lazy ;) Maybe I'll do that one day. If you need it * urgently, contact me and force me to work... Btw, this doesn't mean * that G_CICONs won't be copied at all, but the copied tree will * share the CICONBLKs with the original. * * Input: * tree: Pointer to tree which should be copied * what: Specifies what substructures should be copied, too (see the *       C_xxx-definitions in tree-copy.h for details) * * Output: * NULL: Tree couldn't be copied (due to lack of memory) * otherwise: Pointer to copied tree, use free to dealloc it's memory */OBJECT *tree_copy(OBJECT *tree, WORD what){	WORD	i, objects;	size_t	to_malloc, size;	OBJECT	*new_tree;	char	*area;/* Make sure that C_xxxPOINTER implies C_xxx */	if (what & C_TEDINFOPOINTER)		what |= C_TEDINFO;
	if (what & C_ICONBLKPOINTER)		what |= C_ICONBLK;
	if (what & C_BITBLKPOINTER)		what |= C_BITBLK;
/* Calculate the number of bytes we need for the new tree */	to_malloc = (size_t) 0;	for (i = 0;;) {
/* Size of the OBJECT-structure itself */		to_malloc += sizeof(OBJECT);
		switch (tree[i].ob_type & 0xff)	{			case G_TEXT:			case G_BOXTEXT:			case G_FTEXT:			case G_FBOXTEXT:				if (what & C_TEDINFO)
/* Size of a TEDINFO-structure */					to_malloc += sizeof(TEDINFO);
				if (what & C_TEDINFOPOINTER) {/* Sizes of the strings in the TEDINFO-structure */
					to_malloc += (size_t)tree[i].ob_spec.tedinfo->te_txtlen;					to_malloc += (size_t)tree[i].ob_spec.tedinfo->te_txtlen;					to_malloc += (size_t)tree[i].ob_spec.tedinfo->te_tmplen;				}				break;
			case G_IMAGE:				if (what & C_BITBLK)
/* Size of the BITBLK-structure */					to_malloc += sizeof(BITBLK);
				if (what & C_BITBLKPOINTER) {/* Size of the image-data in the BITBLK-structure */
					to_malloc += (size_t)((LONG)tree[i].ob_spec.bitblk->bi_wb *
										  (LONG)tree[i].ob_spec.bitblk->bi_hl);				}				break;			case G_USERDEF:				if (what & C_USERBLK)
/* Size of the USERBLK-structure */					to_malloc += sizeof(USERBLK);				break;
			case G_BUTTON:			case G_STRING:			case G_TITLE:				if (what & C_TITLEBUTTONSTRING) {
/* Size of the string (with one null character at the end) */					to_malloc += strlen(tree[i].ob_spec.free_string) + 1L;				}				break;
			case G_ICON:				if (what & C_ICONBLK)
/* Size of the ICONBLK-structure */					to_malloc += sizeof(BITBLK);
				if (what & C_ICONBLKPOINTER) {
/* Sizes of icon-data, icon-mask and icon-text */					to_malloc += (size_t)((LONG)tree[i].ob_spec.iconblk->ib_wicon *
										  (LONG)tree[i].ob_spec.iconblk->ib_hicon /
												4L + 1L + (LONG)strlen(tree[i].ob_spec.iconblk->ib_ptext));				}				break;		}
/* If the size is odd, make it even */		if ((LONG)to_malloc & 1)			to_malloc++;
/* Exit if we've reached the last object in the tree */		if (tree[i].ob_flags & LASTOB)			break;
		i++;	}
	objects = i + 1;
/* If there's not enough memory left for the new tree, return NULL */	if ((new_tree = (OBJECT *) malloc(to_malloc)) == NULL) {
		form_alert(1, "[3][Sorry, there is no available|memory for this copy!][ OK ]");		return(NULL);
	}
/* * area contains a pointer to the area where we copy the structures to */	area = (char *)((LONG)new_tree + (LONG)objects * (LONG)sizeof(OBJECT));
	for (i = 0; i < objects; i++) {
/* Copy the contents of the OBJECT-structure */		new_tree[i] = tree[i];

/* This was added to assure true copies of the object type */
		new_tree[i].ob_type = tree[i].ob_type;
		switch (tree[i].ob_type & 0xff) {			case G_TEXT:			case G_BOXTEXT:			case G_FTEXT:			case G_FBOXTEXT:				if (what & C_TEDINFO) {
/* Copy the contents of the TEDINFO-structure */					*(TEDINFO *)area = *tree[i].ob_spec.tedinfo;					new_tree[i].ob_spec.tedinfo = (TEDINFO *)area;					area += sizeof(TEDINFO);				}
				if (what & C_TEDINFOPOINTER) {
/* Copy the strings in the TEDINFO-structure */					strncpy(area, tree[i].ob_spec.tedinfo->te_ptext, tree[i].ob_spec.tedinfo->te_txtlen);					new_tree[i].ob_spec.tedinfo->te_ptext = area;					area += tree[i].ob_spec.tedinfo->te_txtlen;					strncpy(area, tree[i].ob_spec.tedinfo->te_ptmplt, tree[i].ob_spec.tedinfo->te_tmplen);					new_tree[i].ob_spec.tedinfo->te_ptmplt = area;					area += tree[i].ob_spec.tedinfo->te_tmplen;					strncpy(area, tree[i].ob_spec.tedinfo->te_pvalid, tree[i].ob_spec.tedinfo->te_txtlen);					new_tree[i].ob_spec.tedinfo->te_pvalid = area;					area += tree[i].ob_spec.tedinfo->te_txtlen;				}				break;
			case G_IMAGE:				if (what & C_BITBLK) {
/* Copy the contents of the BITBLK-structure */					*(BITBLK *)area = *tree[i].ob_spec.bitblk;					new_tree[i].ob_spec.bitblk = (BITBLK *)area;					area += sizeof(BITBLK);				}
				if (what & C_BITBLKPOINTER) {
/* Copy the image-data */					size = (size_t)((LONG)tree[i].ob_spec.bitblk->bi_wb *
									 (LONG)tree[i].ob_spec.bitblk->bi_hl);					memcpy(area, tree[i].ob_spec.bitblk->bi_pdata, size);					new_tree[i].ob_spec.bitblk->bi_pdata = (WORD *)area;					area += size;				}				break;
			case G_USERDEF:
				if (what & C_USERBLK) {
/* Copy the contents of the USERBLK-structure */					*(USERBLK *)area = *tree[i].ob_spec.userblk;					new_tree[i].ob_spec.userblk = (USERBLK *)area;					area += sizeof(USERBLK);				}				break;
			case G_BUTTON:			case G_STRING:			case G_TITLE:				if (what & C_TITLEBUTTONSTRING) {
/* Copy the string */					size = strlen(tree[i].ob_spec.free_string) + 1L;					strcpy(area, tree[i].ob_spec.free_string);					new_tree[i].ob_spec.free_string = area;					area += size;				}				break;
			case G_ICON:				if (what & C_ICONBLK) {
/* Copy the contents of the ICONBLK-structure */					*(ICONBLK *)area = *tree[i].ob_spec.iconblk;					new_tree[i].ob_spec.iconblk = (ICONBLK *)area;					area += sizeof(ICONBLK);				}
				if (what & C_ICONBLKPOINTER) {					size = (size_t)((LONG)tree[i].ob_spec.iconblk->ib_wicon *
									(LONG)tree[i].ob_spec.iconblk->ib_hicon /
									8L);/* Copy the mask-data */					memcpy(area, tree[i].ob_spec.iconblk->ib_pmask, size);					new_tree[i].ob_spec.iconblk->ib_pmask =	(WORD *)area;					area += size;
/* Copy the icon-data */					memcpy(area, tree[i].ob_spec.iconblk->ib_pdata, size);					new_tree[i].ob_spec.iconblk->ib_pdata = (WORD *)area;					area += size;					size = strlen(tree[i].ob_spec.iconblk->ib_ptext) + 1L;
/* Copy the icon-string */					strcpy(area, tree[i].ob_spec.iconblk->ib_ptext);					new_tree[i].ob_spec.iconblk->ib_ptext = area;					area += size;				}				break;		}
/* Assure that area contains an even address */		if ((LONG)area & 1)			area++;	}
	return(new_tree);}/* EOF */