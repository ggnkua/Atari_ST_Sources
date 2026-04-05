/* **[PCI info]************** */
/* *                        * */
/* * 17/04/2002 29/02/2004  * */
/* ************************** */

int   main ( VOID );


VOID  init_LibLdg ( VOID );
VOID  verifie_PciBios ( VOID );
LONG  ft_pci_not_supported ( VOID );


LONG  CDECL get_pci_version ( LONG *pci_bios_version );

/******************************************************************************/
/*                          PCI-BIOS function pointers                        */
/******************************************************************************/
 LONG	CDECL find_pci_device (ULONG id, ULONG index);
 LONG	CDECL find_pci_classcode (ULONG class, ULONG index);
 LONG	CDECL read_config_byte (LONG handle, ULONG reg, UBYTE *adresse);
 LONG	CDECL read_config_word (LONG handle, ULONG reg, UWORD *adresse);
 LONG	CDECL read_config_longword (LONG handle, ULONG reg, ULONG *adresse);
ULONG	CDECL fast_read_config_byte (LONG handle, ULONG reg);
ULONG	CDECL fast_read_config_word (LONG handle, ULONG reg);
ULONG	CDECL fast_read_config_longword (LONG handle, ULONG reg);
 LONG	CDECL write_config_byte (LONG handle, ULONG reg, ULONG val);
 LONG	CDECL write_config_word (LONG handle, ULONG reg, ULONG val);
 LONG	CDECL write_config_longword (LONG handle, ULONG reg, ULONG val);
 LONG	CDECL hook_interrupt (LONG handle, ULONG *routine, ULONG *parameter);
 LONG	CDECL unhook_interrupt (LONG handle);
 LONG	CDECL special_cycle (ULONG bus, ULONG data);
 LONG	CDECL get_routing (LONG handle);
 LONG	CDECL set_interrupt (LONG handle);
 LONG	CDECL get_resource (LONG handle);
 LONG	CDECL get_card_used (LONG handle, ULONG *adresse);
 LONG	CDECL set_card_used (LONG handle, ULONG *callback);
 LONG	CDECL read_mem_byte (LONG handle, ULONG offset, UBYTE *adresse);
 LONG	CDECL read_mem_word (LONG handle, ULONG offset, UWORD *adresse);
 LONG	CDECL read_mem_longword (LONG handle, ULONG offset, ULONG *adresse);
UBYTE	CDECL fast_read_mem_byte (LONG handle, ULONG offset);
UWORD	CDECL fast_read_mem_word (LONG handle, ULONG offset);
ULONG	CDECL fast_read_mem_longword (LONG handle, ULONG offset);
 LONG	CDECL write_mem_byte (LONG handle, ULONG offset, ULONG val);
 LONG	CDECL write_mem_word (LONG handle, ULONG offset, ULONG val);
 LONG	CDECL write_mem_longword (LONG handle, ULONG offset, ULONG val);
 LONG	CDECL read_io_byte (LONG handle, ULONG offset, UBYTE *adresse);
 LONG	CDECL read_io_word (LONG handle, ULONG offset, UWORD *adresse);
 LONG	CDECL read_io_longword (LONG handle, ULONG offset, ULONG *adresse);
UBYTE	CDECL fast_read_io_byte (LONG handle, ULONG offset);
UWORD	CDECL fast_read_io_word (LONG handle, ULONG offset);
ULONG	CDECL fast_read_io_longword (LONG handle, ULONG offset);
 LONG	CDECL write_io_byte (LONG handle, ULONG offset, ULONG val);
 LONG	CDECL write_io_word (LONG handle, ULONG offset, ULONG val);
 LONG	CDECL write_io_longword (LONG handle, ULONG offset, ULONG val);
 LONG	CDECL get_machine_id (void);
 LONG	CDECL get_pagesize (void);
 LONG	CDECL virt_to_bus (LONG handle, ULONG adresse, ULONG *pointer);
 LONG	CDECL bus_to_virt (LONG handle, ULONG adresse, ULONG *pointer);
 LONG	CDECL virt_to_phys (ULONG adresse, ULONG *pointer);
 LONG	CDECL phys_to_virt (ULONG adresse, ULONG *pointer);



