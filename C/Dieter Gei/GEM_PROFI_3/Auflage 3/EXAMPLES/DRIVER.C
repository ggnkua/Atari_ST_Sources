#include <stdio.h>
#include <portab.h>
#include <vdi.h>

/****** Variablen ************************************************************/

GLOBAL WORD    contrl [12];
GLOBAL WORD    intin [128];
GLOBAL WORD    ptsin [128];
GLOBAL WORD    intout [128];
GLOBAL WORD    ptsout [128];

/****** Prototypen ***********************************************************/

EXTERN VOID vdi               _((VOID));
LOCAL  VOID v_get_driver_info _((WORD device_id, WORD info_select, UBYTE *info_string));

/****** Funktionen ***********************************************************/

LOCAL VOID v_get_driver_info (device_id, info_select, info_string)
WORD      device_id;
WORD      info_select;
UBYTE FAR *info_string;

{
   WORD i;
   BYTE *bptr;

   contrl [0] = -1;
   contrl [1] = 0;
   contrl [3] = 2;
   contrl [5] = 4;
   contrl [6] = 0;

   intin [0] = device_id;
   intin [1] = info_select;

   vdi ();

   if (info_select != 5)
   {
      bptr = (BYTE *)intout;
      for (i = 0; i < contrl [4]; i++) *info_string++ = *bptr++;
      *info_string = 0;
   } /* if */
   else
      *(WORD *)info_string = intout [0];
} /* v_get_driver_info */

/*****************************************************************************/

GLOBAL WORD main ()

{
  UBYTE info_string [255];
  WORD  device_id, info_select, device;

  for (info_select = 1; info_select < 6; info_select++)
  {
    printf ("\ninfo_select: %d\n", info_select);

    for (device_id = 1; device_id <= 60; device_id += 10)
    {
      device = device_id;

      do
      {
        v_get_driver_info (device, info_select, info_string);

        if (info_select == 5)
            printf ("device id: %2d, info_word = %d\n", device, *(WORD *)&info_string [0]);
          else
            if (*info_string) printf ("device id: %2d, info_string = %s\n", device, info_string);

        device++;
      } while (*info_string && (device % 10 != 0));
    } /* for */
  } /* for */

  return (0);
} /* main */

