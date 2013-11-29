#ifndef __DH_XDIAL_H_
#define __DH_XDIAL_H_

#include "SuJi_glo.h"

typedef struct
{
    long id;             /* Identifikations-Code */
    long value;          /* Wert des Cookies     */
} COOKJAR;


void make_listbox_userdef(OBJECT *tree,USERBLK *ud);
int fsel(char *pfad,char *file,int *but,char *titel, GlobalArray *globa);

#endif