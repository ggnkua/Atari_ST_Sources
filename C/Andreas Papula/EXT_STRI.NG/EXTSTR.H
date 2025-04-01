/*  EXTSTRLIB.H */
/*  Include-Datei zu EXTSTRLIB.C. */
/*  Revision:   1 */
/*  Datum       :   15.06.1992 */
/*  Autor       :   Andreas Papula */
/*  Copyright 1992 by MAXON Computer GmbH. */

#include <portab.h>

BYTE *str_rjust(BYTE *string);
BYTE *str_ljust(BYTE *string);
BYTE *str_center(BYTE *string);
BYTE *str_bjust(BYTE *string);
BYTE *str_shuffle(BYTE *string);
BYTE *str_arm(BYTE *string);
BYTE *str_lrm(BYTE *string);
BYTE *str_rrm(BYTE *string);
BYTE *str_split(BYTE *string_1, BYTE *string_2, WORD n);
BYTE *str_fill(BYTE *string_1, BYTE *string_2, WORD n);

/* Ende der Datei */
