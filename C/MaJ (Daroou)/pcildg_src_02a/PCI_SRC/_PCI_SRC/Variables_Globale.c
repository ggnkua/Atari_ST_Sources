/* **[_PCI.LDG]************** */
/* *                        * */
/* * 28/09/2003 29/02/2004  * */
/* ************************** */



 LONG  PCI_bios_status=PCI_SUCCESSFUL;
ULONG  PCI_bios_version=0;
ULONG  PCI_bios_version_Full=0;


/* D‚fini dans PCI_BIOS.S */
extern	ULONG	PCI_pt_fonction;



/* ******************************************************* */
/* * tableau contenant la liste des fonctions de la LDG  * */
/* *                                                     * */
/* * Pour chaque fonction:                               * */
/* * - son nom                                           * */
/* * - information la concernant (prototypes, etc...)    * */
/* * - l'adresse de la fonction                          * */
/* ******************************************************* */
PROC LibFunc[]=
		{
			{
				"get_pci_version",
				"LONG get_pci_version ( LONG *pci_bios_version );"CRLF"-"CRLF
				"Function return PCI Bios error code"CRLF
				"-"CRLF"pci_bios_version Format : $hhhhllll"CRLF
				". hhhh: major version"CRLF
				". llll: minor version",
				get_pci_version
			},
			{
				"find_pci_device",
				"LONG find_pci_device ( id, index );"CRLF
				"ULONG id:"CRLF
				"-Device ID in bits 31..16 (0-$FFFF)"CRLF
				"-Vendor ID in bits 15..0  (0-$FFFE)"CRLF
				"ULONG index:"CRLF" 0 - # of card with these IDs"CRLF
				"-"CRLF
				"Vendor ID $FFFF can be used to query all cards found in the system.",
				find_pci_device
			},
			{
				"find_pci_classcode",
				"LONG find_pci_classcode ( ULONG class, ULONG index );"CRLF
				"classcode: classcode in bits 23..0"CRLF
				"-Base Class in bit 23..16 (0-$FF)"CRLF
				"-Sub  Class in bit 15..8  (0-$FF)"CRLF
				"-Prog. If.  in bit  7..0  (0)"CRLF
				"mask in bits 26..24:"CRLF
				"-bit 26: if 0 = compare base class, else ignore it"CRLF
				"-bit 25: if 0 = compare sub  class, else ignore it"CRLF
				"-bit 24: if 0 = compare prog. if.,  else ignore it",
				find_pci_classcode
			},
			{
				"read_config_byte",
				"LONG read_config_byte ( handle, reg, address );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  reg    : Register number (0,1,2,3,..,255)"CRLF
				"UBYTE *address: pointer to space for read data"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_config_byte
			},
			{
				"read_config_word",
				"LONG read_config_word ( handle, reg, address );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  reg    : Register number (0,2,4,6,..,254)"CRLF
				"UWORD *address: pointer to space for read data"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_config_word
			},
			{
				"read_config_longword",
				"LONG read_config_longword ( handle, reg, address );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  reg    : Register number (0,4,8,12,..,252)"CRLF
				"ULONG *address: pointer to space for read data"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_config_longword
			},
			{
				"fast_read_config_byte",
				"UBYTE fast_read_config_byte ( handle, reg );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG reg   : Register number (0,1,2,3,..,255)"CRLF
				"-"CRLF
				"function return read data",
				fast_read_config_byte
			},
			{
				"fast_read_config_word",
				"UWORD fast_read_config_word ( handle, reg );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG reg   : Register number (0,2,4,6,..,254)"CRLF
				"-"CRLF
				"function return read data",
				fast_read_config_word
			},
			{
				"fast_read_config_longword",
				"ULONG fast_read_config_longword ( handle, reg );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG reg   : Register number (0,4,8,12,..,252)"CRLF
				"-"CRLF
				"function return read data",
				fast_read_config_longword
			},
			{
				"write_config_byte",
				"LONG write_config_byte ( handle, reg, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG reg   : Register number (0,1,2,3,..,255)"CRLF
				"ULONG val   : data to write (8bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_config_byte
			},
			{
				"write_config_word",
				"LONG write_config_word ( handle, reg, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG reg   : Register number (0,2,4,6,..,254)"CRLF
				"ULONG val   : data to write (16bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_config_word
			},
			{
				"write_config_longword",
				"LONG write_config_longword ( handle, reg, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG reg   : Register number (0,4,8,12,..,252)"CRLF
				"ULONG val   : data to write (32bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_config_longword
			},
			{
				"hook_interrupt",
				"LONG hook_interrupt ( handle, routing, parameter );"CRLF
				"-"CRLF
				"LONG   handle   : device handle"CRLF
				"ULONG *routing  : pointer to interrupt handler"CRLF
				"ULONG *parameter: parameter for interrupt handler"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				hook_interrupt
			},
			{
				"unhook_interrupt",
				"LONG unhook_interrupt ( handle );"CRLF
				"-"CRLF
				"LONG handle: device handle"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				unhook_interrupt
			},
			{
				"special_cycle",
				"LONG special_cycle ( bus, data );"CRLF
				"-"CRLF
				"ULONG bus : bus number"CRLF
				"ULONG data: special cycle data"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				special_cycle
			},
			{
				"get_routing",
				"LONG get_routing ( handle );"CRLF
				"-"CRLF
				"to be defined. Not for use by device drivers",
				get_routing
			},
			{
				"set_interrupt",
				"LONG set_interrupt ( handle );"CRLF
				"-"CRLF
				"to be defined. Not for use by device drivers",
				set_interrupt
			},
			{
				"get_resource",
				"LONG get_resource ( handle );"CRLF
				"-"CRLF
				"LONG handle: device handle"CRLF
				"-"CRLF
				"return pointer to array of resource descriptors or error code",
				get_resource
			},
			{
				"get_card_used",
				"LONG get_card_used ( handle, adresse );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG *adresse: pointer to longword where call-back address is stored"CRLF
				"-"CRLF
				"return error code or status",
				get_card_used
			},
			{
				"set_card_used",
				"LONG set_card_used ( handle, callback );"CRLF
				"-"CRLF
				"LONG   handle  : device handle"CRLF
				"ULONG *callback: address of call-back entry (not pointer to address!)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				set_card_used
			},
			{
				"read_mem_byte",
				"LONG read_mem_byte ( handle, offset, adresse );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  offset : address to access (in PCI memory address space)"CRLF
				"UBYTE *adresse: pointer to data in memory"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_mem_byte
			},
			{
				"read_mem_word",
				"LONG read_mem_word ( handle, offset, adresse );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  offset : address to access (in PCI memory address space)"CRLF
				"UWORD *adresse: pointer to data in memory"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_mem_word
			},
			{
				"read_mem_longword",
				"LONG read_mem_longword ( handle, offset, adresse );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  offset : address to access (in PCI memory address space)"CRLF
				"ULONG *adresse: pointer to data in memory"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_mem_longword
			},
			{
				"fast_read_mem_byte",
				"UBYTE fast_read_mem_byte ( handle, offset );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI memory address space)"CRLF
				"-"CRLF
				"function return read data (8bits)",
				fast_read_mem_byte
			},
			{
				"fast_read_mem_word",
				"UWORD fast_read_mem_word ( handle, offset );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI memory address space)"CRLF
				"-"CRLF
				"function return read data (16bits)",
				fast_read_mem_word
			},
			{
				"fast_read_mem_longword",
				"ULONG fast_read_mem_longword ( handle, offset );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI memory address space)"CRLF
				"-"CRLF
				"function return read data (32bits)",
				fast_read_mem_longword
			},
			{
				"write_mem_byte",
				"LONG write_mem_byte ( handle, offset, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI memory address space)"CRLF
				"ULONG val   : data to write (8bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_mem_byte
			},
			{
				"write_mem_word",
				"LONG write_mem_word ( handle, offset, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI memory address space)"CRLF
				"ULONG val   : data to write (16bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_mem_word
			},
			{
				"write_mem_longword",
				"LONG write_mem_longword ( handle, offset, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI memory address space)"CRLF
				"ULONG val   : data to write (32bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_mem_longword
			},
			{
				"read_io_byte",
				"LONG read_io_byte ( handle, offset, address );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  offset : address to access (in PCI IO address space)"CRLF
				"UBYTE *address: pointer to data in memory (8bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_io_byte
			},
			{
				"read_io_word",
				"LONG read_io_word ( handle, offset, address );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  offset : address to access (in PCI IO address space)"CRLF
				"UWORD *address: pointer to data in memory (16bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_io_word
			},
			{
				"read_io_longword",
				"LONG read_io_longword ( handle, offset, address );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  offset : address to access (in PCI IO address space)"CRLF
				"ULONG *address: pointer to data in memory (32bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				read_io_longword
			},
			{
				"fast_read_io_byte",
				"UBYTE fast_read_io_byte ( handle, offset );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI IO address space)"CRLF
				"-"CRLF
				"function return read data (8bits)",
				fast_read_io_byte
			},
			{
				"fast_read_io_word",
				"UWORD fast_read_io_word ( handle, offset );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI IO address space)"CRLF
				"-"CRLF
				"function return read data (16bits)",
				fast_read_io_word
			},
			{
				"fast_read_io_longword",
				"ULONG fast_read_io_longword ( handle, offset );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI IO address space)"CRLF
				"-"CRLF
				"function return read data (32bits)",
				fast_read_io_longword
			},
			{
				"write_io_byte",
				"LONG write_io_byte ( handle, offset, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI IO address space)"CRLF
				"ULONG val   : data to write (8bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_io_byte
			},
			{
				"write_io_word",
				"LONG write_io_word ( handle, offset, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI IO address space)"CRLF
				"ULONG val   : data to write (16bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_io_word
			},
			{
				"write_io_longword",
				"LONG write_io_longword ( handle, offset, val );"CRLF
				"-"CRLF
				"LONG  handle: device handle"CRLF
				"ULONG offset: address to access (in PCI IO address space)"CRLF
				"ULONG val   : data to write (32bits)"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				write_io_longword
			},
			{
				"get_machine_id",
				"LONG get_machine_id (void);"CRLF
				"-"CRLF
				"function return Machine Id, or 0 (no ID available), or error code"CRLF
				"-"CRLF
				"They contain a manufacturer code in bit 24..31 and a unique "
				"serial number wich is set by the manufacturer during "
				"production in bit 23..0",
				get_machine_id
			},
			{
				"get_pagesize",
				"LONG get_pagesize ( VOID );"CRLF
				"-"CRLF
				"function return active pagesize or 0 if paging is not active.",
				get_pagesize
			},
			{
				"virt_to_bus",
				"LONG virt_to_bus ( handle, address, pointer );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  address: address in virtual CPU space"CRLF
				"ULONG *pointer: pointer to mem-struct for results"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				virt_to_bus
			},
			{
				"bus_to_virt",
				"LONG bus_to_virt ( handle, address, pointer );"CRLF
				"-"CRLF
				"LONG   handle : device handle"CRLF
				"ULONG  address: PCI bus address"CRLF
				"ULONG *pointer: pointer to mem-struct for results"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				bus_to_virt
			},
			{
				"virt_to_phys",
				"LONG virt_to_phys ( address, pointer );"CRLF
				"-"CRLF
				"ULONG  address: address in virtual CPU space"CRLF
				"ULONG *pointer: pointer to mem-struct for results"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				virt_to_phys
			},
			{
				"phys_to_virt",
				"LONG phys_to_virt ( address, pointer );"CRLF
				"-"CRLF
				"ULONG  address: physical CPU address"CRLF
				"ULONG *pointer: pointer to mem-struct for results"CRLF
				"-"CRLF
				"function return PCI_SUCCESSFUL or error code",
				phys_to_virt
			}
		};

ULONG PCI_nb_fonction=sizeof(LibFunc)/sizeof(*LibFunc);

/* ******************************************************* */
/* * Tableu de description de la LDG                     * */
/* ******************************************************* */
LDGLIB LibLdg[]=
		{
			{
				PCI_LDG_VERSION,	/* version librairie '0.1' */
				sizeof(LibFunc)/sizeof(*LibFunc),	/* nombre de fonction */
				LibFunc,	/* adresse tableau de fonction */
				"Fonction du PCI Bios version 1.00"CRLF
				"Jean-Marc Stocklausen // Renaissance"CRLF
				"F‚vrier 2004",
		  					/* informations sur la LDG */
				0,    		/* Flags Librairie */
				0,
				0
			}
		};


