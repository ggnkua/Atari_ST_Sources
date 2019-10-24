/* Trouve le chemin d'acces de l'application */


#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include "defines.h"
#include "string.h"
#include "appgpath.h"

char rsc[256]={"VOX.RSC"};				/* Nom du fichier ressource */

int app_get_path(char *path)
{
	char *s;
	shel_find(rsc);
	for(s=rsc+strlen(rsc);((s>=rsc) && (*s!='\\'));*s--=0);
	
	if (s>rsc)
		strcpy(path,rsc);
	else
	{
		path[0]='A'+Dgetdrv();
		path[1]=':';
		Dgetpath(&path[2],0);
		strcat(path, "\\");
	}
	return TRUE;
}
