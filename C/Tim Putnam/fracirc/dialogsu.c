#include "vars.h"
#include "fractel.h"
int __stdargs __saveds andabout(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks, void *data);

int is_dw_open(DIALOG *dialog)
{
short i;
for(i=0;i <= 127; i++){
if(dials[i] == dialog)return 1;
}
return 0;
}

void wd_close(DIALOG *dialog)
{
short i=0;
while(i<128){
if(dials[i]==dialog){dials[i]=0;i=130;}
i++;
}
wdlg_close(dialog,0,0);
}

void add_dial(DIALOG *dialog)
{
short i=0;
while(i<128){
if(dials[i]==0){dials[i]=dialog;i=130;}
i++;
}
}
void finishdialogs(void)
{
short mcto=0;
wdlg_delete(habout);
}

void initdialogs(void)
{
OBJECT *tree;
rsrc_gaddr(R_TREE,aboutform,&tree);
habout=wdlg_create(andabout,tree,0L,0,0L,WDLG_BKGD);
}