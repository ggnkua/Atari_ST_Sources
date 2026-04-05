/* **[_PCI.LDG]********************************* */
/* * Retourne le num‚ro de version du Bios PCI * */
/* * 28/09/2003 29/02/2004                     * */
/* ********************************************* */

LONG get_pci_version( LONG	*pcibios_version )
{
 /*
  * extern ULONG PCI_bios_version_Full;
  * extern LONG  PCI_bios_status;
  *
  */

	
	if( PCI_bios_status==PCI_SUCCESSFUL || PCI_bios_status==PCI_BIOS_WRONG_VERSION )
	{
		/* On v‚rifie que l'adresse transmise n'est pas NULL */
		if( pcibios_version != (LONG *)NULL )
		{
			*pcibios_version=PCI_bios_version_Full;
		}
	}


	return( PCI_bios_status );

	/* Si une erreur a ‚t‚ d‚tect‚ dans l'initialisation
	 * des foncions PCI, PCI_bios_status contient le num‚ro
	 * de l'erreur, sinon contient 0 (z‚ro).

	 * Erreur possible:
	 * PCI_BIOS_NOT_INSTALLED: cookie _PCI absent !
	 * PCI_BIOS_WRONG_VERSION: version PCI Bios non support‚.
	 *
	 */

}

