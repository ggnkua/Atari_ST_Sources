/*************************************************************************

	Aufruf von Accessories von der Okami-Shell aus

		von Wolfram Rîsler 22.6.91

**************************************************************************/
static char _M_ID[]="@(#)gem.c  - Okami Accessory-Aufruf";
 
#include <obdefs.h>
#include <ctype.h>
#include "system.c"

#define MOff()	graf_mouse(256,0)
#define MOn()	graf_mouse(257,0)
#define RSCFILE	"gem.rsc"

main()
{
  static OBJECT *Tree;
  int buf[8];
  char *Cmd;

  appl_init();

  /* Resourcefile laden. */
  if (rsrc_load(RSCFILE)==0)
  {
    form_alert(1,"[3][gem:|Resource file not found][  Pity  ]");
    appl_exit();
    return 1;
  }

  rsrc_gaddr(0,0,&Tree);

  for(;;)
  {
    menu_bar(Tree,1);

    /* Warten auf MenÅklick... */
    evnt_mesag(buf);

    if (buf[0]==10)
      menu_tnormal(Tree,buf[3],1);

    menu_bar(Tree,0);

    if (buf[0]==10)
    {
      /* Kommando aus dem Objektbaum holen. */
      Cmd = (char *)Tree[buf[4]].ob_spec;
      while(isspace(*Cmd)) Cmd++;

      /* Test auf Abbruchbedingung. */
      if (strncmp(Cmd,"exit",4)==0)
        break;

      MOff();
      system(Cmd);
      MOn();
    }
  }
  
  rsrc_free();
  appl_exit();

  return 0;
}
