/**************************************************************************/
/*                                                                        */
/*  NAME:         popmenu.inc                                             */
/*                                                                        */
/*  DATUM:        31.05.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Include-Datei fuer popmenu.c.                           */
/*                                                                        */
/**************************************************************************/

#include <portab.h>

#define PMVALUE  0x1        /* Menue-Eintrag ist Wert                     */
#define PMFUNC   0x2        /* Menue-Eintrag ist Funktion                 */
#define PMPROC   0x4        /* Menue-Eintrag ist Prozedur -> kein return  */
#define PMMENU   0x8        /* Menue-Eintrag ist Untermenue               */
#define PMSELECT 0x100      /* Menue-Eintrag kann selektiert werden       */

#define ISSUBMENU TRUE   

#define NULLPME  ((PME *) 0L)

struct pmenuentry
{
   BYTE *pme_text;
   WORD  pme_type;
   BYTE *pme_ret;
   BYTE *pme_param;
};
typedef struct pmenuentry PME;

struct pmenu
{
   BYTE *pm_title;
   WORD  pm_width;
   WORD  pm_height;
   WORD  pm_size;
   PME  *pm_entries;
};
typedef struct pmenu PM;

#define PMTABSIZE(tab)    ((WORD) sizeof (tab) / sizeof (PME))

extern BYTE *pmexec();
extern WORD  pmselect();

#define PMIsSelect(e)     (e->pme_type & PMSELECT)
#define PMIsDesel(e)      (!PMIsSelect(e))
#define PMSelect(m, t)    (pmselect (m, t, TRUE))
#define PMDesel(m, t)     (pmselect (m, t, FALSE))

