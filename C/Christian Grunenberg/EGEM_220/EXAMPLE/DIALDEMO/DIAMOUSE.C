
/* DialogMouse (PRG): Demonstriert von der Mausposition abh„ngige Mausform/Infozeile */

#include <e_gem.h>
#include <string.h>
#include "diamouse.h"

DIAINFO *di;
OBJECT *tr;

char *dm="DiaMouse",
path[][MAX_PATH]={"\\ST-GUIDE.AC?","\\DOCUMENTS\\","\\SETTINGS\\","\\MODULES\\"},
*info[]={"","Hilfesystem","Pfad fr Dokumente...","Pfad fr Einstellungen...","Pfad fr Module...","Abbruch","","Best„tigen",""};

int ObInfo(DIAINFO *di,OBJECT *t,int ob,int l,int x,int y,GRECT *r)
{
	window_info(di->di_win,info[ob]);
	if (ob>=PATH1 && ob<=PATH4)
	{
		MouseCursor();
		return(DIALOG_MOUSE);
	}
	return(DIALOG_OBJECT);
}

void main()
{
	if (open_rsc("diamouse.rsc",NULL,dm,dm,"DIAMOUSE",0,0,0)==TRUE)
	{
		rsrc_gaddr(R_TREE,0,&tr);
		fix_objects(tr,NO_SCALING,8,16);
		if ((di=open_dialog(tr,dm,NULL,NULL,DIA_MOUSEPOS,FALSE,WIN_DIAL|WD_INFO,0,NULL,NULL))!=NULL)
		{
			char file[MAX_PATH],buf[MAX_PATH],*pa,ex;

			for (ex=0;ex<4;ex++)
				ob_set_text(tr,ex+PATH1,path[ex]);

			dialog_mouse(di,ObInfo);
			while ((ex=XFormObject(NULL,NULL))>=PATH1 && ex<=PATH4)
			{
				strcpy(file,GetFilename(strcpy(buf,pa=path[ex-PATH1])));
				GetPath(buf);
				if (FileSelect(info[ex],buf,file,NULL,FALSE,0,NULL)>0)
				{
					MakeFullpath(pa,buf,ex==PATH1 ? file : "");
					ob_draw(di,ex);
				}
				ob_select(di,tr,ex,FALSE,TRUE);
			}
		}
		close_rsc(TRUE,0);
	}
	exit(-1);
}
