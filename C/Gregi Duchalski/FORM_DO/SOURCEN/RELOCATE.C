 /***************************************************************
 *  Userdefined Objects in GFA-BASIC 3.x                        *
 *  (c)8/92 Gregi Duchalski                                     *
 *																*
 *  last change 03.08.92                                        *
 *      														*
 *  RELOZIEREN (Routine von Martin K”hling)         (Tabweite 4)*
 ***************************************************************/

#include <gregs.h>
#include <portab.h>

void cdecl relocate (PH *ph)
{
   UBYTE *reloctable;
   LONG *code;
   LONG text_start;

   if (ph->ph_absflag == 0)
   {
      text_start = (LONG) ph + sizeof(*ph);
      reloctable = (UBYTE *) (text_start +
                              ph->ph_tlen + ph->ph_dlen + ph->ph_slen);
      code = (LONG *) (text_start + *((LONG *) reloctable)++);
      if ((void *) code != (void *)ph)
      {
         /* reloctable is not empty */
         while (1)
         {
            *code += text_start; /* relocate */
            while (*reloctable == 1)
            {
               (LONG) code += 254;
               reloctable++;
            }
            if (*reloctable==0)
               break;
            (LONG) code += *reloctable++;
         }
      }
   }
}

