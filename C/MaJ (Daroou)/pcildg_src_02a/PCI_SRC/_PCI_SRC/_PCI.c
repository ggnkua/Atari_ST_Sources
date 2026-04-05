/* *[_PCI.LDG]*************** */
/* *                        * */
/* * 28/09/2003 29/02/2004  * */
/* ************************** */

#include <STDLIB.H>
#include <STDIO.H>
#include <OSBIND.H>
#include <PORTAB.H>

#define  USE_GEMLIB
#include <GEMX.H>
#include <GEM.H>

#include <PCI_BIOS.H>
#include <LDG.H>


#include "Define.c"
#include "..\Fonction\Cookie_def.c"


/* # Prototypes des fonctions # */
LONG test_cookies( ULONG val_cookie );
LONG get_cookies ( ULONG val_cookie );
#include "Prototypes.c"

/* # Variables globales # */
#include "Variables_Globale.c"


/* Fonctions */
#include "Verifie_PciBios.c"
#include "init_LibLdg.c"
#include "Get_PCI_Version.c"
#include "Ft_PCI_Not_Supported.c"

/*-------------------------------------*/
/* Fonctions communes aux applications */
/*-------------------------------------*/
#include	"..\Fonction\Test_Cookies.c"
#include	"..\Fonction\Get_Cookies.c"


/* ******************************************************** */
/* * Fonction Main: Initialisation de la LDG              * */
/* ******************************************************** */
int main( void)
{
 /*
  * extern LDGLIB LibLdg[]; d‚fini dans Variables_Globale.c
  *
  */


	/* on se d‚clare … l'AES */
	appl_init();


	/* - Recherche cookie '_PCI'
	 * - V‚rification du num‚ro de version
	 * - Sauvegarde pointeur vers les fonctions PCI Bios
	 */
	verifie_PciBios();


	/* Si le PCI Bios n'est pas support‚, cette fonction
	 * remplace les fonctions du PCI Bios par une fonction
	 * renvoyant un code d'erreur (PCI_FUNC_NOT_SUPPORTED)
	 */
	init_LibLdg();


	/* On se d‚clare au LDG Manager */
	if( ldg_init(LibLdg) == -1)
	{
		form_alert( 1, "[3][_PCI.LDG version "PRG_VERSION"| |Cette application est une LDG|Execution impossible !][ Quitter ]");
	}


	/* On pr‚vient l'AES que l'on a plus besoin de ses services */
	appl_exit();


	return(EXIT_SUCCESS);

}

