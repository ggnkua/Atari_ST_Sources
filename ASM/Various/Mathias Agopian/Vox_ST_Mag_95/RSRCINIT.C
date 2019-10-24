/* Gestion des USERDEF */

#include <tos.h>
#include <vdi.h>
#include <string.h>

#include "DEFINES.H"
#include "USERDEF.H"
#include "BARSEUIL.H"

#define nb_user_max		10
#define IndexBarSeuil	1

extern int WorkHCeil;
extern int handle;

USERBLK adr_usr[nb_user_max];
int ValBarSeuil;
int TauxAppr,TauxReco,TauxMin,SeuilStart,SeuilEnd;

void rsrc_init(char *filename)
{
	OBJECT *adr;
	RSHDR rsh;
	int fh,nb_form;
	int i,j,xtype;

	adr_usr[1].ub_code=BarSeuil;
	adr_usr[2].ub_code=BarSeuil;
	adr_usr[3].ub_code=BarSeuil;
	adr_usr[4].ub_code=BarSeuil;
	adr_usr[5].ub_code=BarSeuil;
	adr_usr[6].ub_code=BarSeuil;
	adr_usr[1].ub_parm=(long)(&ValBarSeuil);
	adr_usr[2].ub_parm=(long)(&TauxAppr);
	adr_usr[3].ub_parm=(long)(&TauxReco);
	adr_usr[4].ub_parm=(long)(&TauxMin);
	adr_usr[5].ub_parm=(long)(&SeuilStart);
	adr_usr[6].ub_parm=(long)(&SeuilEnd);

	fh=(int)Fopen(filename,FO_READ);
	Fread(fh,sizeof(rsh),&rsh);
	Fclose(fh);
	nb_form=rsh.rsh_ntree;

	for(i=0;i<nb_form;i++)
	{
		rsrc_gaddr(R_TREE,i,&adr);

		j=0;
		do
		{
			xtype=adr[j].ob_type>>8;
			switch(xtype)
			{
				case 1:
					adr[j].ob_type=G_USERDEF;
					adr[j].ob_spec.userblk=&adr_usr[adr[j].ob_spec.userblk->ub_parm];
					break;
			}
		}while(!(adr[j++].ob_flags & LASTOB));
	}
}
