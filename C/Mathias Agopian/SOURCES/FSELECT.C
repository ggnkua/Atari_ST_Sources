/* Selecteur de fichiers */

/*
	 En sortie:	-1 -> Annuler
				-2 -> OK, mais nom=""
				 0 -> OK
*/

#include <tos.h>
#include <string.h>
#include <aes.h>

int fileselect(char *masque, char *deflt, char *sortie, char *label)
{
	static char path[256];
	static char nom[13];
	int back;
	int button;
	long i;

	strcpy(path,sortie);
	for (i=strlen(path)-1;((i>=0) && (path[i]!='\\'));path[i--]=0);
	if (i<0)
	{
		path[0]='A'+Dgetdrv();
		path[1]=':';
		Dgetpath(&path[2],0);
		strcat(path, "\\");
	}
	strcat(path,masque);
	strcpy(nom,deflt);
	back=fsel_exinput(path,nom,&button,label);
	if (button==0 || back==0)
		return(-1);

	for(i=strlen(path)-1;path[i]!='\\';i--);
	strcpy(masque,&path[++i]);
	path[i]='\0';
	strcat(path,nom);
	strcpy(sortie,path);
	strcpy(deflt,nom);
	return 0;
}
