#include <portab.h>
#include <stdio.h>
#include <aes.h>

#include "cogito.h"
#include "cogito.rh"
#include "cogito.rsh"

#define DHEADER   1
#define DCHECKBOX 3

extern OBJECT *packmenu,*packdial,*setdial,*set2dial;
extern int aeshandle,boxh;

/***************************************************************************/
/*	                                      												*/
/***************************************************************************/
static void fix_tree(int n_tree)
{
  register int tree,	  /* index for trees */
					object;	/* index for objects */
  OBJECT		 *pobject;

  for (tree = 0; tree < n_tree; tree++) /* fix trees */
  {
	 object  = 0;
	 pobject = rs_trindex [tree];
	 do
	 {
		rsrc_obfix(pobject,object);
	 }
	 while (! (pobject [object++].ob_flags & LASTOB));
  } /* for */
} /* fix_tree */

static void form_fix(OBJECT *tree, BOOLEAN is_dialog)
{
  WORD	 obj;
  OBJECT  *ob;
  UWORD	type, xtype;
  extern int boxh;

  if (tree != NULL)
  {
	 obj = 0;
	 do
	 {
		ob = &tree [++obj];
		type  = ob->ob_type & 0xFF;
		xtype = ob->ob_type >> 8;
		switch (xtype)
		{
			case DHEADER: 
			   ob->ob_y	-= boxh / 2;
			   ob->ob_type &= 0x00FF;
			   break;
			case DCHECKBOX:
			   ob->ob_x+=1;
			   ob->ob_y+=1;
			   ob->ob_width-=2;
			   ob->ob_height-=2;
			   ob->ob_type &= 0x00FF;
			   break;
			default:
			   break;
		} 
	 } while (! (ob->ob_flags & LASTOB));
  } 
} 
/***************************************************************************/
/*	                                      												*/
/***************************************************************************/
void rsrc_init(char *rscfile)
{
	int ret;

	wind_update(BEG_UPDATE);

#ifndef RSRC_LOAD
	fix_tree(NUM_TREE);
	packmenu  =(OBJECT *)rs_trindex[PACKMENU];
	packdial  =(OBJECT *)rs_trindex[PACKDIAL];
	setdial   =(OBJECT *)rs_trindex[SETDIAL];
	set2dial  =(OBJECT *)rs_trindex[SET2DIAL];
#else
   rsrc_load(rscfile);
	rsrc_gaddr(R_TREE,PACKMENU,&packmenu);
	rsrc_gaddr(R_TREE,PACKDIAL,&packdial);
	rsrc_gaddr(R_TREE,SETDIAL, &setdial);
	rsrc_gaddr(R_TREE,SET2DIAL,&set2dial);
#endif
   form_fix(packdial,TRUE);
   form_center(packdial,&ret,&ret,&ret,&ret);
 
   form_fix(setdial,TRUE);
   form_center(setdial,&ret,&ret,&ret,&ret);

   form_fix(set2dial,TRUE);
   form_center(set2dial,&ret,&ret,&ret,&ret);

	wind_update(END_UPDATE);
}