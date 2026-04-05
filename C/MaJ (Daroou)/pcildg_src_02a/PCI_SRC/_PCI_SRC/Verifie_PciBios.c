/* **[_PCI.LDG]***************** */
/* *                           * */
/* * 28/09/2003 # 29/02/2004   * */
/* ***************************** */
void verifie_PciBios( void )
{
 /*
  * extern ULONG PCI_pt_fonction;
  * extern  LONG PCI_bios_status;
  * extern ULONG PCI_bios_version;
  * extern ULONG PCI_bios_version_Full;
  *
  */

	ULONG	adr_pci_bios;
	ULONG	*pt_pci_bios_version;



	/* On regarde si le cookie '_PCI' est pr‚sent */
	if( test_cookies(COOKIE__PCI) == FALSE )
	{
		/* Mmmm... pas de cookie ! */
		PCI_bios_version=0;
		PCI_bios_status=PCI_BIOS_NOT_INSTALLED;
	}
	else
	{
		/* Adresse du PCI BIos en RAM */
		adr_pci_bios = get_cookies(COOKIE__PCI);


		/* Pointeur sur les fonctions PCI */
		PCI_pt_fonction      =  adr_pci_bios + 8;

		/* Pointeur vers la version du PCI Bios */
		pt_pci_bios_version  = (ULONG *)(adr_pci_bios + 4);

		PCI_bios_version_Full=  *pt_pci_bios_version;
		PCI_bios_version     = (*pt_pci_bios_version >> 16) & 0xFF ;



		/* On v‚rifie que cette version est support‚ */
		if( PCI_bios_version != 1)
		{
			PCI_bios_status=PCI_BIOS_WRONG_VERSION;
		}

	}
}


