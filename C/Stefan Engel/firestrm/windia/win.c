#define OB_SPEC
#include <aes.h>
#include <stdio.h>
#include "windia.h"
#include "windia.c"
#include "win_dia.h"
#include "win_dia2.h"

/***********************************************************************/
/***********************************************************************/
short        screenx, screeny, screenw, screenh, aes_ver;
short        work_in[11], work_out[57], ap_id, graf_id, xy[8],dummy;
char         d_temp[MAXSTRING];
FILE        *d_fil=NULL;
error        fel;
WINDOW       dias;
short        shortkeys[100];
short        shortkorr[100];
OBJECT      *menutree=NOLL,*poptree;
char       **key_table;
long         num_fonts;
short        font_width,font_height;
long int     timer=-1;
int          exist_3d,
             gdos;
EVENT_DATA   evnt;
char        *pop_string;
long        *pop_values;
RESULT       tebax;