#include "header.h"

int dofontselector(short whichfont){
short button,junk;
short check_boxes;
long id_in,pt_in,ratio_in;
long id,pt,ratio;
if(whichfont==0){id_in=(long)winfont;pt_in=(long)winpoint<<16;}
if(whichfont==1){id_in=(long)inpfont;pt_in=(long)inppoint<<16;}
ratio_in=1L << 16;

button = fnts_do( fnt_dialog, BUTTON_FLAGS, id_in, pt_in, ratio_in, &check_boxes, &id, &pt, &ratio );					
		switch ( button )
		{
			case	FNTS_CANCEL:									/* "Abbruch" */
			{
			vst_alignment(ws.handle,0,3,&junk,&junk);
			break;
			}
			case	FNTS_OK:											/* "OK" */
			{
		if(whichfont==0){winfont=(WORD)id;winpoint=(WORD)pt>>16;setwinfont();}
		if(whichfont==1){inpfont=(WORD)id;inppoint=(WORD)pt>>16;setinpfont();}
			break;
			}
			}

return 0;
}


int setwinfont()
{
short junk;
short attr[10],ret;
short mcto=0;
vst_font(ws.handle,(WORD)winfont);
vst_point(ws.handle,(WORD)winpoint,&ret,&ret,&ret,&ret);
vqt_attributes(ws.handle,attr);
vst_alignment(ws.handle,0,3,&junk,&junk);
tw=attr[8];th=attr[9];
while(mcto<NOFWIN){
if(wn[mcto].hand>-1){
wn[mcto].hght=(wn[mcto].wwa.g_h-2*ith-VT)/th;
initiateredraw(mcto,wn[mcto].wwa.g_x,wn[mcto].wwa.g_y,wn[mcto].wwa.g_w,wn[mcto].wwa.g_h);
}
mcto++;
}
return 0;
}

int setinpfont()
{
short attr[10],ret;
short mcto=0;
short junk;
vst_font(ws.handle,(WORD)inpfont);
vst_point(ws.handle,(WORD)inppoint,&ret,&ret,&ret,&ret);
vqt_attributes(ws.handle,attr);
vst_alignment(ws.handle,0,3,&junk,&junk);
ith=attr[9];
while(mcto<NOFWIN){
if(wn[mcto].hand>-1){
wn[mcto].hght=(wn[mcto].wwa.g_h-2*ith-VT)/th;
clearipb(mcto);
initiateredraw(mcto,wn[mcto].wwa.g_x,wn[mcto].wwa.g_y,wn[mcto].wwa.g_w,wn[mcto].wwa.g_h);
}
mcto++;
}
return 0;
}
