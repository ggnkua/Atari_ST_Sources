/***************************************************/
/*   Examiner plusieurs ‚vŠnements simultan‚ment   */
/*   Laser C               MULTI.C   */
/***************************************************/

#include <osbind.h>
#include "gem_inex.c"

int  which,
     touche, dummy;

main()
{
  gem_init();

  v_gtext (handle, 0, 14,
     "Tapez une touche. Si vous n'avez pas tap‚ de touche dans");
  v_gtext (handle, 0, 30,
     "3 secondes, le programme ");
  v_gtext (handle, 0, 46, "s'arrˆtera.");
  
  which = evnt_multi (33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0L, 3000, 0, &dummy, &dummy, &dummy,  
                      &dummy, &touche, &dummy);
  
  if (which == 1)
    v_gtext (handle, 0, 80, "Taper une touche pour quitter");
  else
    v_gtext (handle, 0, 80, "Arrˆt dans 3 secondes");
  
  Crawcin();   /* Attendre touche */
  gem_exit();
}





