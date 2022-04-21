/******************************************************************************
 * GFAXRSRC.C
 *
 ******************************************************************************/

#include <import.h>
#include <xrsrc.h>
#include <export.h>

/* Funktionen:																	*/

GLOBAL BOOLEAN init_global _((VOID));
GLOBAL BOOLEAN term_global _((VOID));

LOCAL VOID open_vwork _((VOID));
LOCAL VOID close_vwork _((VOID));


#define DESK          0        /* Window-Handle/classe du bureau dans l'objet */
#define RC            2        /* coordonnÇes graphiques */

/* VARIABLES: 																	*/

#if DR_C | LASER_C | MW_C
EXTERN WORD   gl_apid;                   /* Identification pour l'application */
#else
GLOBAL WORD    gl_apid;                   /* Identification pour l'application */
#endif

GLOBAL LOCAL WORD    gl_wattr;                  /* Largeur d'un attribut fenàtre */
GLOBAL LOCAL WORD    gl_hattr;                  /* Hauteur d'un attribut fenàtre */

GLOBAL LOCAL WORD    phys_handle;               /* Physical Workstation Handle */
GLOBAL BOOLEAN vwork_open=FALSE;                /* Virtual  Workstation oppened ? */

GLOBAL GRECT  desk;
GLOBAL WORD   gl_wbox;                       /* Largeur d'une boåte de dessin */
GLOBAL WORD   gl_hbox;                       /* hauteur d'une boåte de dessin */
GLOBAL WORD   vdi_handle=-1;                    /* Virtual Workstation Handle */


/* variables d'accäs:															*/

EXTERN WORD function_number;

EXTERN WORD wort1;
EXTERN WORD wort2;
EXTERN WORD wort3;
EXTERN WORD wort4;

EXTERN LONG long1;
EXTERN LONG long2;
EXTERN LONG long3;
EXTERN LONG long4;





/* fonctions d'appel globales des routines Xsrsc */

GLOBAL LONG gfa_call_function(VOID)
{
	switch(function_number)
	{
	case 1:

		return((LONG) xrsrc_load ((BYTE *) long1));

	case 2:

		return((LONG) xrsrc_free());

	case 3:

		return((LONG) xrsrc_gaddr (wort1 , wort2, (VOID *) long1));

	case 4:

		return((LONG) xrsrc_saddr (wort1 , wort2, (VOID *) long1));

	case 5:

		return((LONG) xrsrc_obfix ((OBJECT *) long1, wort1));

	case 128:

		return((LONG) init_global());

	case 129:

		return((LONG) term_global());

	}

	return(-42);
}

/*****************************************************************************/
/* Initialisation du module	                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_global ()

{	WORD   i;

	i = appl_init ();

	#if (LATTICE_C | TURBO_C) | (GEM & (GEM2 | GEM3 | XGEM))
		gl_apid = i;                          /* gl_apid non externe */
	#endif

	if (gl_apid < 0) return (FALSE);

	phys_handle = graf_handle (&gl_wbox, &gl_hbox, &gl_wattr, &gl_hattr); /* Handle de l'Çcran */
	vdi_handle = phys_handle;               /* nÇcessite un Çcran physique */

	wind_get (DESK, WF_WXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);        /* Taille du bureau */

	open_vwork ();                          /* ouvrir virtual Workstation */

	return (TRUE);

} /* init_global */

/*****************************************************************************/
/* Fin du module		                          	                         */
/*****************************************************************************/

GLOBAL BOOLEAN term_global ()

{
  if (gl_apid >= 0)
  {
    close_vwork ();                     /* Workstation schlieûen */
    appl_exit ();                       /* Applikation beenden */
  } /* if */
  return (TRUE);
} /* term_global */

/*****************************************************************************/
/* ôffne virtuelle Workstation                                               */
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
    work_in [10] = RC;                         /* CoordonnÇes graphiques */
    vdi_handle = phys_handle;
    v_opnvwk (work_in, &vdi_handle, work_out); /* ouvrir virtual Workstation */
  } /* if */
} /* open_vwork */

/*****************************************************************************/
/* Fermer virtual Workstation                                                */
/*****************************************************************************/

LOCAL VOID close_vwork ()

{
  if (vwork_open)
  {
    v_clsvwk (vdi_handle);                        /* LibÇrer la Workstation      */
    vdi_handle = phys_handle;                     /* nÇcessite l'Çcran Physique  */
    vwork_open = FALSE;
  } /* if */
} /* close_vwork */
