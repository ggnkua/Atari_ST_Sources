/* **[Client_PCI.c]************************* */
/* * Exemple de client pour l'utilisation  * */
/* * de _PCI.LDG                           * */
/* * 29/09/2003 28/02/2004                 * */
/* ***************************************** */


#include <STDLIB.H>
#include <STDIO.H>
#include <STRING.H>
#include <OSBIND.H>
#include <PORTAB.H>


#define  USE_GEMLIB
#include <GEMX.H>
#include <GEM.H>


#include <LDG.H>
#include <_PCI.H>
#include <PCI_BIOS.H>




/* fonction d'affichage erreur initialisation LDG */
VOID  affiche_ldg_error    ( LONG erreur );
VOID  go_test_fonction_PCI ( VOID );

#include "LDG_AfEr.C"




int main( void)
{
	/* handle pour la lib PCI.LDG */
	extern	LDG	*ldg_PCI;	/* defini dans <_PCI.H> */



	appl_init();


	/*-----------------------------*/
	/* Initialisation de _PCI.LDG  */
	/*-----------------------------*/
	printf( CRLF"* Initialisation de PCI.LDG"CRLF );
	{
		LONG	reponse;

		/* initialisation de la LDG COMPRESS.LDG */
		if( init_LDG_PCI() != TRUE )
		{
			/* Erreur, on retente une initialisation */
			reponse=init_LDG_PCI();
			if( reponse != TRUE )
			{
				/* Encore erreur, on s'arrˆte l… :( */
				affiche_ldg_error(reponse);

				appl_exit();
				return(0);
			}
		}
	}

	/* Info sur LDG manager */
	printf( "  - LDG Manager version %x.%02x"CRLF, ldg_PCI->vers_ldg>>8, ldg_PCI->vers_ldg & 0xFF );
	printf( "  - PCI.LDG     version %x.%02x"CRLF, ldg_PCI->vers>>8, ldg_PCI->vers & 0xFF );


	printf( CRLF"* Utilisation des fonction de PCI.LDG"CRLF );
	{
		long pci_version;
		long error_code;


		error_code=get_pci_version( &pci_version );

		if( error_code == PCI_SUCCESSFUL )
		{
			printf("  * PCI Bios version %ld.%02ld"CRLF, pci_version>>16, pci_version & 0xFFFF );

			go_test_fonction_PCI();
		}
		else
		{
			printf("  * PCI Bios absent ou incompatible"CRLF);
		}
	}



	printf( CRLF"* Fermeture de PCI.LDG"CRLF );
	ldg_close( ldg_PCI, ldg_global);


	printf( CRLF"* Fin du programme de test"CRLF );
	printf( CRLF"<Appuyer sur une touche pour terminer"CRLF );

	(void)Cconin();


	appl_exit();
	return 0;
}



VOID go_test_fonction_PCI( VOID )
{

	/* --- get_machine_id() --------------------------------------- */
	{
		LONG	dummy;
		ULONG	old_super;

		printf( CRLF"  * get_machine_id():"CRLF);

		old_super=Super( 0L );	/* on passe en Superviseur */
		dummy=get_machine_id();
		Super( old_super );		/* retour en mode Utilisateur */

		if( dummy != PCI_FUNC_NOT_SUPPORTED )
		{
			printf( "      Machine ID    : %ld"CRLF, (dummy>>24) );
			printf( "      Serial number : %ld"CRLF, (dummy & 0xFFFFFF) );
		}
		else
		{
			printf( "      Fonction non support‚ (%ld)"CRLF, dummy );
		}
	}


	/* --- get_pagesize() ----------------------------------------- */
	{
		LONG	dummy;
		ULONG	old_super;

		old_super=Super( 0L );  /* on passe en Superviseur */
		dummy=get_pagesize();
		Super( old_super );     /* retour en mode Utilisateur */

		printf( CRLF"  * get_page_size()" );
		printf( CRLF"      MMU page size = %ld octets"CRLF, dummy );
	}



	/* --- find_pci_device ---------------------------------------- */
	{
		LONG	index=0;
		LONG	handle;
		ULONG	old_super;

		printf( CRLF"  * find_pci_device( 0x0000FFFF, index )"CRLF);
		printf( "    Recherche de toutes les cartes PCI pr‚sentent:"CRLF );
		printf( "    - 0x....FFFF : Vendor ID"CRLF );
		printf( "    - 0x0000.... : Device ID"CRLF );

		do
		{
			old_super=Super( 0L );  /* on passe en Superviseur */
			handle=find_pci_device( 0x0000ffff, index );
			Super( old_super );     /* retour en mode Utilisateur */

			printf( CRLF"      Carte %02ld : handle PCI = $%lX", (index+1), handle );
			if( handle == PCI_DEVICE_NOT_FOUND )
			{
				printf( " (plus de carte pci)"CRLF );
				break;
			}
			index++;

		} while( handle != PCI_DEVICE_NOT_FOUND );

		printf( CRLF"      %ld carte(s) PCI trouv‚e(s) sur votre micro."CRLF, index );


	}


	printf( CRLF"<Une touche pour continuer>"CRLF );
	(void)Cconin();

	/* --- find_pci_classcode ------------------------------------- */
	{
		LONG	index=0;
		LONG	handle;
		ULONG	old_super;

		printf( CRLF"  * find_pci_classcode( 0x3030000, index )");
		printf( CRLF"    recherche carte graphique:"CRLF );
		printf( "    - 0x3...... : compare bass class, ignore subclass et prog.if"CRLF );
		printf( "    - 0x.03.... : bass class => 03=display class"CRLF );


		do
		{
			old_super=Super( 0L );  /* on passe en Superviseur */
			handle=find_pci_classcode( 0x3030000, index );;
			Super( old_super );     /* retour en mode Utilisateur */

			printf( CRLF"      Carte %02ld : handle PCI = $%lX", (index+1), handle );
			if( handle == PCI_DEVICE_NOT_FOUND )
			{
				printf( " (plus de carte pci)"CRLF );
			}
			index++;

		} while( handle != PCI_DEVICE_NOT_FOUND );

		printf( CRLF"      %ld carte(s) graphique(s) trouv‚e(s) sur votre micro."CRLF, (index-1) );


	}

	/* --- read config longword------------------------------------ */
    {
     ULONG valeur=0;
      LONG handle,reponse=0;
     ULONG old_super;

       printf( CRLF"  * read_config_longword( handle, 0, &valeur );"CRLF);

       old_super=Super( 0L );  /* on passe en Superviseur    */
       handle=find_pci_device( 0x0000FFFF, 0 );
       if( handle>0 )
       {
          reponse=read_config_longword( handle, 0, &valeur );
       }
       Super( old_super );     /* retour en mode Utilisateur */

       printf( "    handle device : $%lX"CRLF, handle );

       if( reponse == PCI_SUCCESSFUL )
       {
          printf( "    registre 0, valeur=$%lX"CRLF, valeur );
       }
       else
       {
          printf( "    read longword error: $%ld"CRLF, reponse );
       }
    }


}


