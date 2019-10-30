/******************************/
/*  TEST CONDITION DE SORTIE  */
/******************************/
/*  Programme SORTIE.C        */
/******************************/
#include <STDIO.H>
#include <STRING.H>
#include <GEMFAST.H>
#include <INITGEM.H>

int sortie;

/********************/
/*  TEST SI SORTIE  */
/********************/
void tst_sortie()
{
 int rep;
 char message[100];

 strcpy(message,"[2][Voulez-Vous");
 strcat(message," quitter| Ce ");
 strcat(message,"programme ?]");
 strcat(message,"[Oui|Non]");
 rep=form_alert(1,message);
 if (rep==1) sortie=TRUE;
}

void main()
{
 InitGem();
 sortie=FALSE;
 do {
      tst_sortie();
    } while(sortie==FALSE);
 CloseGem();
}

