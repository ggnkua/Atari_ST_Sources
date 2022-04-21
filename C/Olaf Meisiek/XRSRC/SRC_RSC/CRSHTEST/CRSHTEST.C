/*****************************************************************************/
/*                                                                           */
/* Modul: EXTOBFIX.C                                                         */
/* Datum: 17.02.91                                                           */
/*                                                                           */
/*****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <aes.h>
#include <vdi.h>

#include "xrsrcfix.h"
#include "crshtest.rh"
#include "crshtest.rsh"

/****** DEFINES **************************************************************/

#define DESK          0        /* Window-Handle/Klasse des Desktop als Objekt */
#define RC            2        /* Raster Koordinaten */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

#if DR_C | LASER_C | MW_C
EXTERN WORD   gl_apid;                   /* Identifikation fr Applikation */
#else
LOCAL WORD    gl_apid;                   /* Identifikation fr Applikation */
#endif

LOCAL WORD    gl_wattr;                  /* Breite eines Fensterattributes */
LOCAL WORD    gl_hattr;                  /* H”he eines Fensterattributes */

LOCAL WORD    phys_handle;               /* Physikalisches Workstation Handle */
LOCAL BOOLEAN vwork_open;                /* Virtuelle Workstation ge”ffnet ? */

LOCAL OBJECT  *dialbox;

WORD          vdi_handle;                /* Virtuelles Workstation Handle */
WORD          gl_wbox;                   /* Breite einer Zeichenbox */
WORD          gl_hbox;                   /* H”he einer Zeichenbox */
GRECT         desk;                      /* Desktop Gr”že */

/****** FUNCTIONS ************************************************************/

LOCAL VOID       fix_objs      _((OBJECT  *tree));
LOCAL VOID       trans_gimage  _((VOID *obspec, WORD typ));
LOCAL VOID       open_vwork    _((VOID));
LOCAL VOID       close_vwork   _((VOID));
LOCAL BOOLEAN    init_global   _((INT argc, BYTE *argv [], BYTE *acc_menu, WORD class));
LOCAL BOOLEAN    term_global   _((VOID));

LOCAL VOID       vdi_fix       _((MFDB *pfd, VOID *theaddr, WORD wb, WORD h));
LOCAL VOID       vdi_trans     _((WORD *saddr, WORD swb, WORD *daddr, WORD dwb, WORD h));

/*****************************************************************************/

LOCAL  VOID fix_objs (tree)
OBJECT  *tree;

{	WORD    obj;
  OBJECT  *ob;
  ICONBLK *ib;
  BITBLK  *bi;
  UWORD   type;
#if GEM & (GEM2 | GEM3 | XGEM)
  BYTE    *s;
#endif

  if (tree != NULL)
  {
    obj = NIL;

    do
    {
      ob    = &tree [++obj];
      type  = ob->ob_type & 0xFF;

			switch (type)
			{
				case G_ICON:
	        ib = (ICONBLK *)ob->ob_spec.index;
	        ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekth”he = Iconh”he */
	        trans_gimage (ib, type);                     /* Icons an Bildschirm anpassen */
	        break;
	      
	      case G_USERDEF:
		      if (ob->ob_spec.index > 0x600 && ((OBBLK *)ob->ob_spec.index)->old_type == G_CICON)
		      {
		        ib = (ICONBLK *)((OBBLK *)ob->ob_spec.index)->ublk.ub_parm;
		        ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekth”he = Iconh”he */
		        trans_gimage (ib, G_CICON);                  /* Farb-Icons an Bildschirm anpassen */
		      }
		      break;
		    
		    case G_IMAGE:
	        bi = (BITBLK *)ob->ob_spec.index;
	        ob->ob_height = bi->bi_hl;        /* Objekth”he = Imageh”he */
	        trans_gimage (bi, type);          /* Bit Images an Bildschirm anpassen */
	        break;
	    }
    } while (! (ob->ob_flags & LASTOB));
  } /* if */ 
} /* fix_objs */

/*****************************************************************************/

main()
{
	WORD x, y, w, h;

	if (!init_global (0, NULL, NULL, 0))
		return (0);
	else
	{
		graf_mouse (ARROW, NULL);
		form_center (dialbox, &x, &y, &w, &h);
		form_dial (FMD_START, 0, 0, 0, 0, x, y, w, h);
		objc_draw (dialbox, ROOT, MAX_DEPTH, x, y, w, h);
		form_do (dialbox, ROOT);
		form_dial (FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

		term_global ();
	}

	return (0);
}

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

LOCAL BOOLEAN init_global (argc, argv, acc_menu, class)
INT  argc;
BYTE *argv [];
BYTE *acc_menu;
WORD class;

{	WORD   i;

  i = appl_init ();                       /* Applikationsnummer besorgen */

#if (LATTICE_C | TURBO_C) | (GEM & (GEM2 | GEM3 | XGEM))
  gl_apid = i;                            /* gl_apid nicht extern */
#endif

  if (gl_apid < 0) return (FALSE);

  phys_handle = graf_handle (&gl_wbox, &gl_hbox, &gl_wattr, &gl_hattr); /* Handle des Bildschirms */
  vdi_handle  = phys_handle;              /* Benutze physikalischen Bildschirm */
  vwork_open  = FALSE;

  wind_get (DESK, WF_WXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);        /* Gr”že des Desktop */

  open_vwork ();                          /* ™ffne virtuelle Workstation */

#ifdef rgb_palette
	init_xrsrc (vdi_handle, rs_object, NUM_OBS, NUM_CIB, rgb_palette);
#else
	init_xrsrc (vdi_handle, rs_object, NUM_OBS, NUM_CIB, NULL);
#endif
	
  dialbox = rs_trindex[0];                /* Adresse der Hilfeseite */
  fix_objs (dialbox);
	
  return (TRUE);
} /* init_global */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

LOCAL BOOLEAN term_global ()

{
  if (gl_apid >= 0)
  {
		term_xrsrc (NUM_CIB);		            /* Resourcen freigeben */
    close_vwork ();                     /* Workstation schliežen */
    appl_exit ();                       /* Applikation beenden */
  } /* if */

  return (TRUE);
} /* term_global */

/*****************************************************************************/
/* ™ffne virtuelle Workstation                                               */
/*****************************************************************************/

LOCAL VOID open_vwork ()

{
  WORD i;
  WORD work_in [11];
  WORD work_out [57];

  if (! vwork_open)
  {
    vwork_open = TRUE;

    for (i = 0; i < 10; work_in [i++] = 1);
    work_in [10] = RC;                         /* Raster Koordinaten */
    vdi_handle = phys_handle;
    v_opnvwk (work_in, &vdi_handle, work_out); /* ™ffne virtuelle Workstation */
  } /* if */
} /* open_vwork */

/*****************************************************************************/
/* Schlieže virtuelle Workstation                                            */
/*****************************************************************************/

LOCAL VOID close_vwork ()

{
  if (vwork_open)
  {
    v_clsvwk (vdi_handle);                      /* Workstation freigeben */
    vdi_handle = phys_handle;                   /* Physikalischen Bildschirm benutzen */
    vwork_open = FALSE;
  } /* if */
} /* close_vwork */

/*****************************************************************************/

LOCAL VOID trans_gimage (obspec, typ)
VOID *obspec;
WORD typ;

{
  ICONBLK *piconblk;
  BITBLK  *pbitblk;
  WORD    *taddr;
  WORD    wb, hl;

  switch (typ)
  {
  	case G_CICON  :
		case G_ICON   :
			piconblk = (ICONBLK *)obspec;
			taddr    = piconblk->ib_pmask;
			wb       = piconblk->ib_wicon;
			wb       = wb >> 3;
			hl       = piconblk->ib_hicon;
			
			vdi_trans (taddr, wb, taddr, wb, hl);
			
			taddr = piconblk->ib_pdata;
			break;
			
		case G_IMAGE  :
			pbitblk = (BITBLK *)obspec;
			taddr   = pbitblk->bi_pdata;
			wb      = pbitblk->bi_wb;
			hl      = pbitblk->bi_hl;
			break;
	}

  vdi_trans (taddr, wb, taddr, wb, hl);
} /* trans_gimage */

/*****************************************************************************/

LOCAL VOID vdi_fix (pfd, theaddr, wb, h)
MFDB *pfd;
VOID *theaddr;
WORD wb, h;

{
  pfd->mp  = theaddr;
  pfd->fwp = wb << 3;
  pfd->fh  = h;
  pfd->fww = wb >> 1;
  pfd->np  = 1;
} /* vdi_fix */

/*****************************************************************************/

LOCAL VOID vdi_trans (saddr, swb, daddr, dwb, h)
WORD *saddr;
WORD swb;
WORD *daddr;
WORD dwb;
WORD h;

{
  MFDB src, dst;

  vdi_fix (&src, saddr, swb, h);
  src.ff = TRUE;

  vdi_fix (&dst, daddr, dwb, h);
  dst.ff = FALSE;

  vr_trnfm (vdi_handle, &src, &dst);
} /* vdi_trans */
