/* **[_PCI.LDG]***************** */
/* *                           * */
/* * 28/09/2003 # 29/02/2004   * */
/* ***************************** */

void init_LibLdg( void )
{
 /*
  * extern ULONG PCI_bios_version;
  * extern ULONG PCI_nb_fonction;
  * extern PROC  LibFunc[];
  *
  */

	UWORD	dummy;


	/* Si la version du PCI Bios n'est pas support‚... */
	if( PCI_bios_version != 1 )
	{
		for( dummy=1; dummy<PCI_nb_fonction; dummy++)
		{
			/* On modifie les pointeurs de fonctions pour
			 * qu'il renvoi le message d'erreur:
			 * PCI_FUNC_NOT_SUPPORTED

			 * Seul la fonction get_pci_version est conserv‚
			 * pour retourner l'erreur et si disponible, la
			 * version du PCI Bios
			 */

			LibFunc[dummy].func=ft_pci_not_supported;
		}
	}

}

