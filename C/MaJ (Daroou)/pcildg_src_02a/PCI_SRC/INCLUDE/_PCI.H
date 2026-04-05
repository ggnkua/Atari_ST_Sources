/*******************************************************************/
/*                                                                 */
/*                     _PCI.LDG  version 0.20a                     */
/*                                                                 */
/*  Cette LDG met … disposition les 43 fonctions PCI d‚finie par   */
/*  PCI BIOS version 1.xx, plus une permettant de connaŒtre les    */
/*  version du PCI BIOS support‚ (1.x, 2.x, etc...)                */
/*  Cette bibliothŠque de fonctions permet aux logiciels d'ˆtre    */
/*  ind‚pendant du hardware. _PCI.LDG int‚grera la version 2.0     */
/*  du PCI bios dŠs que celle-ci sera officiellement d‚fini.       */
/*                                                                 */
/*  (c)2003 Renaissance                                28.02.2004  */
/*                                                                 */
/*******************************************************************/

#ifndef  __PCI_LDG__
 #define __PCI_LDG__



 /* Quelques D‚fines */
 #ifndef	TRUE
  #define	TRUE	1
 #endif

 #ifndef FALSE
  #define	FALSE	0
 #endif

 #undef		CRLF
 #define	CRLF	"\015\012"


 #ifndef CHAR
  #define CHAR	char
 #endif

 #ifndef UCHAR
  #define UCHAR	unsigned char
 #endif

 #ifndef BYTE
  #define BYTE	signed char
 #endif

 #ifndef UBYTE
  #define UBYTE	unsigned char
 #endif

 #ifndef WORD
  #define WORD	signed short
 #endif

 #ifndef UWORD
  #define UWORD	unsigned short
 #endif

 #ifndef LONG
  #define LONG	signed long
 #endif

 #ifndef ULONG
  #define ULONG	unsigned long
 #endif


 #ifndef INT16
  #define INT16	short
 #endif

 #ifndef VOID
  #define VOID	void
 #endif




/* prototypes des 44 fonctions de PCI.LDG */
ULONG cdecl (*get_pci_version)( LONG *pci_version );

 LONG cdecl (*find_pci_device)(ULONG id, ULONG index);
 LONG cdecl (*find_pci_classcode)(ULONG class, ULONG index);

 LONG cdecl (*read_config_byte)    (LONG handle, ULONG reg, UBYTE *adresse);
 LONG cdecl (*read_config_word)    (LONG handle, ULONG reg, UWORD *adresse);
 LONG cdecl (*read_config_longword)(LONG handle, ULONG reg, ULONG *adresse);

UBYTE cdecl (*fast_read_config_byte)    (LONG handle, ULONG reg);
UWORD cdecl (*fast_read_config_word)    (LONG handle, ULONG reg);
ULONG cdecl (*fast_read_config_longword)(LONG handle, ULONG reg);

 LONG cdecl (*write_config_byte)    (LONG handle, ULONG reg, ULONG val);
 LONG cdecl (*write_config_word)    (LONG handle, ULONG reg, ULONG val);
 LONG cdecl (*write_config_longword)(LONG handle, ULONG reg, ULONG val);

 LONG cdecl (*hook_interrupt)  (LONG handle, ULONG *routine, ULONG *parameter);
 LONG cdecl (*unhook_interrupt)(LONG handle);

 LONG cdecl (*special_cycle)(ULONG bus, ULONG data);

 LONG cdecl (*get_routing)(LONG handle);

 LONG cdecl (*set_interrupt)(LONG handle);

 LONG cdecl (*get_resource)(LONG handle);

 LONG cdecl (*get_card_used)(LONG handle, ULONG *adresse);
 LONG cdecl (*set_card_used)(LONG handle, ULONG *callback);

 LONG cdecl (*read_mem_byte)    (LONG handle, ULONG offset, UBYTE *adresse);
 LONG cdecl (*read_mem_word)    (LONG handle, ULONG offset, UWORD *adresse);
 LONG cdecl (*read_mem_longword)(LONG handle, ULONG offset, ULONG *adresse);

UBYTE cdecl (*fast_read_mem_byte)    (LONG handle, ULONG offset);
UWORD cdecl (*fast_read_mem_word)    (LONG handle, ULONG offset);
ULONG cdecl (*fast_read_mem_longword)(LONG handle, ULONG offset);

 LONG cdecl (*write_mem_byte)    (LONG handle, ULONG offset, ULONG val);
 LONG cdecl (*write_mem_word)    (LONG handle, ULONG offset, ULONG val);
 LONG cdecl (*write_mem_longword)(LONG handle, ULONG offset, ULONG val);

 LONG cdecl (*read_io_byte)    (LONG handle, ULONG offset, UBYTE *adresse);
 LONG cdecl (*read_io_word)    (LONG handle, ULONG offset, UWORD *adresse);
 LONG cdecl (*read_io_longword)(LONG handle, ULONG offset, ULONG *adresse);

UBYTE cdecl (*fast_read_io_byte)    (LONG handle, ULONG offset);
UWORD cdecl (*fast_read_io_word)    (LONG handle, ULONG offset);
ULONG cdecl (*fast_read_io_longword)(LONG handle, ULONG offset);

 LONG cdecl (*write_io_byte)    (LONG handle, ULONG offset, ULONG val);
 LONG cdecl (*write_io_word)    (LONG handle, ULONG offset, ULONG val);
 LONG cdecl (*write_io_longword)(LONG handle, ULONG offset, ULONG val);

 LONG cdecl (*get_machine_id)(void);

 LONG cdecl (*get_pagesize)(void);

 LONG cdecl (*virt_to_bus)(LONG handle, ULONG adresse, ULONG *pointer);
 LONG cdecl (*bus_to_virt)(LONG handle, ULONG adresse, ULONG *pointer);

 LONG cdecl (*virt_to_phys)(ULONG adresse, ULONG *pointer);
 LONG cdecl (*phys_to_virt)(ULONG adresse, ULONG *pointer);



/* handle pour la lib PCI.LDG */
LDG	*ldg_PCI=NULL;

/* prototype fonction d'initialisation de la LDG PCI */
LONG  init_LDG_PCI( VOID );

/* fonction d'initialisation de la LDG PCI
 *
 * En cas d'erreur, la LDG est referm‚ et une valeur
 * (n‚gative) est retourn‚ par la fonction. Voir message
 * d'erreur dans la Documention LDG, … 'ldg_error()'.
 *
 * Renvoi 'TRUE' en cas de succŠs
 *
 */
LONG init_LDG_PCI( VOID )
{
	extern 	LDG 	*ldg_PCI;
			LONG 	erreur=FALSE;


	ldg_PCI=ldg_open( "_PCI.LDG", ldg_global );


	if( !ldg_PCI )
	{
		return( ldg_error() );
	}

	get_pci_version = ldg_find( "get_pci_version", ldg_PCI );
	if( !get_pci_version ) erreur=TRUE;

	find_pci_device = ldg_find( "find_pci_device", ldg_PCI );
	if( !find_pci_device ) erreur=TRUE;

	find_pci_classcode = ldg_find( "find_pci_classcode", ldg_PCI );
	if( !find_pci_classcode ) erreur=TRUE;

	read_config_byte = ldg_find( "read_config_byte", ldg_PCI );
	if( !read_config_byte ) erreur=TRUE;

	read_config_word = ldg_find( "read_config_word", ldg_PCI );
	if( !read_config_word ) erreur=TRUE;

	read_config_longword = ldg_find( "read_config_longword", ldg_PCI );
	if( !read_config_longword ) erreur=TRUE;

	fast_read_config_byte = ldg_find( "fast_read_config_byte", ldg_PCI );
	if( !fast_read_config_byte ) erreur=TRUE;

	fast_read_config_word = ldg_find( "fast_read_config_word", ldg_PCI );
	if( !fast_read_config_word ) erreur=TRUE;

	fast_read_config_longword = ldg_find( "fast_read_config_longword", ldg_PCI );
	if( !fast_read_config_longword ) erreur=TRUE;

	write_config_byte = ldg_find( "write_config_byte", ldg_PCI );
	if( !write_config_byte ) erreur=TRUE;

	write_config_word = ldg_find( "write_config_word", ldg_PCI );
	if( !write_config_word ) erreur=TRUE;

	write_config_longword = ldg_find( "write_config_longword", ldg_PCI );
	if( !write_config_longword ) erreur=TRUE;


	hook_interrupt = ldg_find( "hook_interrupt", ldg_PCI );
	if( !hook_interrupt ) erreur=TRUE;

	unhook_interrupt = ldg_find( "unhook_interrupt", ldg_PCI );
	if( !unhook_interrupt ) erreur=TRUE;

	special_cycle = ldg_find( "special_cycle", ldg_PCI );
	if( !special_cycle ) erreur=TRUE;

	get_routing = ldg_find( "get_routing", ldg_PCI );
	if( !get_routing ) erreur=TRUE;

	set_interrupt = ldg_find( "set_interrupt", ldg_PCI );
	if( !set_interrupt ) erreur=TRUE;

	get_resource = ldg_find( "get_resource", ldg_PCI );
	if( !get_resource ) erreur=TRUE;

	get_card_used = ldg_find( "get_card_used", ldg_PCI );
	if( !get_card_used ) erreur=TRUE;

	set_card_used = ldg_find( "set_card_used", ldg_PCI );
	if( !set_card_used ) erreur=TRUE;

	read_mem_byte = ldg_find( "read_mem_byte", ldg_PCI );
	if( !read_mem_byte ) erreur=TRUE;

	read_mem_word = ldg_find( "read_mem_word", ldg_PCI );
	if( !read_mem_word ) erreur=TRUE;

	read_mem_longword = ldg_find( "read_mem_longword", ldg_PCI );
	if( !read_mem_longword ) erreur=TRUE;

	fast_read_mem_byte = ldg_find( "fast_read_mem_byte", ldg_PCI );
	if( !fast_read_mem_byte ) erreur=TRUE;

	fast_read_mem_word = ldg_find( "fast_read_mem_word", ldg_PCI );
	if( !fast_read_mem_word ) erreur=TRUE;

	fast_read_mem_longword = ldg_find( "fast_read_mem_longword", ldg_PCI );
	if( !fast_read_mem_longword ) erreur=TRUE;

	write_mem_byte = ldg_find( "write_mem_byte", ldg_PCI );
	if( !write_mem_byte ) erreur=TRUE;

	write_mem_word = ldg_find( "write_mem_word", ldg_PCI );
	if( !write_mem_word ) erreur=TRUE;

	write_mem_longword = ldg_find( "write_mem_longword", ldg_PCI );
	if( !write_mem_longword ) erreur=TRUE;

	read_io_byte = ldg_find( "read_io_byte", ldg_PCI );
	if( !read_io_byte ) erreur=TRUE;

	read_io_word = ldg_find( "read_io_word", ldg_PCI );
	if( !read_io_word ) erreur=TRUE;

	read_io_longword = ldg_find( "read_io_longword", ldg_PCI );
	if( !read_io_longword ) erreur=TRUE;

	fast_read_io_byte = ldg_find( "fast_read_io_byte", ldg_PCI );
	if( !fast_read_io_byte ) erreur=TRUE;

	fast_read_io_word = ldg_find( "fast_read_io_word", ldg_PCI );
	if( !fast_read_io_word ) erreur=TRUE;

	fast_read_io_longword = ldg_find( "fast_read_io_longword", ldg_PCI );
	if( !fast_read_io_longword ) erreur=TRUE;

	write_io_byte = ldg_find( "write_io_byte", ldg_PCI );
	if( !write_io_byte ) erreur=TRUE;

	write_io_word = ldg_find( "write_io_word", ldg_PCI );
	if( !write_io_word ) erreur=TRUE;

	write_io_longword = ldg_find( "write_io_longword", ldg_PCI );
	if( !write_io_longword ) erreur=TRUE;

	get_machine_id = ldg_find( "get_machine_id", ldg_PCI );
	if( !get_machine_id ) erreur=TRUE;

	get_pagesize = ldg_find( "get_pagesize", ldg_PCI );
	if( !get_pagesize ) erreur=TRUE;

	virt_to_bus = ldg_find( "virt_to_bus", ldg_PCI );
	if( !virt_to_bus ) erreur=TRUE;

	bus_to_virt = ldg_find( "bus_to_virt", ldg_PCI );
	if( !bus_to_virt ) erreur=TRUE;

	virt_to_phys = ldg_find( "virt_to_phys", ldg_PCI );
	if( !virt_to_phys ) erreur=TRUE;

	phys_to_virt = ldg_find( "phys_to_virt", ldg_PCI );
	if( !phys_to_virt ) erreur=TRUE;


	if( erreur )
	{
		ldg_close( ldg_PCI, ldg_global);
		return( LDG_NO_FUNC );
	}

	return(TRUE);
}



#endif	/* #ifndef __PCI_LDG__ */


