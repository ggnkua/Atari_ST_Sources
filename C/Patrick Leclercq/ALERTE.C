/********************************/
/*  UTILISATION BOITE D'ALERTE  */
/********************************/
/*  Programme ALERTE.C          */
/********************************/
#include <STDIO.H>
#include <STRING.H>
#include <GEMFAST.H>
#include <INITGEM.H>

void tst_alerte()
{
 int rep;
 char mess[100];

 strcpy(mess,"[3][Exemple de|");
 strcat(mess,"boite d'alerte|");
 strcat(mess,"avec une seule|");
 strcat(mess,"option de clic.]");
 strcat(mess,"[Oui]");
 rep=form_alert(1,mess);
}

void main()
{
 InitGem();
 tst_alerte();
 CloseGem();
}
