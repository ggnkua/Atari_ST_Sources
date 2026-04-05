
/******************************************************************************/
/*                          PCI-BIOS function pointers                        */
/******************************************************************************/

extern  LONG cdecl _find_pci_device		(ULONG id, ULONG index);
extern  LONG cdecl _find_pci_classcode	(ULONG class, ULONG index);

extern  LONG cdecl _read_config_byte		(LONG handle, ULONG reg, UBYTE *adresse);
extern  LONG cdecl _read_config_word		(LONG handle, ULONG reg, UWORD *adresse);
extern  LONG cdecl _read_config_longword	(LONG handle, ULONG reg, ULONG *adresse);

extern UBYTE cdecl _fast_read_config_byte		(LONG handle, ULONG reg);
extern UWORD cdecl _fast_read_config_word		(LONG handle, ULONG reg);
extern ULONG cdecl _fast_read_config_longword	(LONG handle, ULONG reg);

extern  LONG cdecl _write_config_byte		(LONG handle, ULONG reg, ULONG val);
extern  LONG cdecl _write_config_word		(LONG handle, ULONG reg, ULONG val);
extern  LONG cdecl _write_config_longword	(LONG handle, ULONG reg, ULONG val);

extern  LONG cdecl _hook_interrupt		(LONG handle, ULONG *routine, ULONG *parameter);
extern  LONG cdecl _unhook_interrupt	(LONG handle);

extern  LONG cdecl _special_cycle	(ULONG bus, ULONG data);

extern  LONG cdecl _get_routing		(LONG handle);

extern  LONG cdecl _set_interrupt	(LONG handle);

extern  LONG cdecl _get_resource	(LONG handle);

extern  LONG cdecl _get_card_used	(LONG handle, ULONG *adresse);
extern  LONG cdecl _set_card_used	(LONG handle, ULONG *callback);

extern  LONG cdecl _read_mem_byte		(LONG handle, ULONG offset, UBYTE *adresse);
extern  LONG cdecl _read_mem_word		(LONG handle, ULONG offset, UWORD *adresse);
extern  LONG cdecl _read_mem_longword	(LONG handle, ULONG offset, ULONG *adresse);

extern UBYTE cdecl _fast_read_mem_byte		(LONG handle, ULONG offset);
extern UWORD cdecl _fast_read_mem_word		(LONG handle, ULONG offset);
extern ULONG cdecl _fast_read_mem_longword	(LONG handle, ULONG offset);

extern  LONG cdecl _write_mem_byte		(LONG handle, ULONG offset, ULONG val);
extern  LONG cdecl _write_mem_word		(LONG handle, ULONG offset, ULONG val);
extern  LONG cdecl _write_mem_longword	(LONG handle, ULONG offset, ULONG val);

extern  LONG cdecl _read_io_byte		(LONG handle, ULONG offset, UBYTE *adresse);
extern  LONG cdecl _read_io_word		(LONG handle, ULONG offset, UWORD *adresse);
extern  LONG cdecl _read_io_longword	(LONG handle, ULONG offset, ULONG *adresse);

extern UBYTE cdecl _fast_read_io_byte		(LONG handle, ULONG offset);
extern UWORD cdecl _fast_read_io_word		(LONG handle, ULONG offset);
extern ULONG cdecl _fast_read_io_longword	(LONG handle, ULONG offset);

extern  LONG cdecl _write_io_byte		(LONG handle, ULONG offset, ULONG val);
extern  LONG cdecl _write_io_word		(LONG handle, ULONG offset, ULONG val);
extern  LONG cdecl _write_io_longword	(LONG handle, ULONG offset, ULONG val);

extern  LONG cdecl _get_machine_id	(void);

extern  LONG cdecl _get_pagesize	(void);

extern  LONG cdecl _virt_to_bus		(LONG handle, ULONG adresse, ULONG *pointer);
extern  LONG cdecl _bus_to_virt		(LONG handle, ULONG adresse, ULONG *pointer);

extern  LONG cdecl _virt_to_phys	(ULONG adresse, ULONG *pointer);
extern  LONG cdecl _phys_to_virt	(ULONG adresse, ULONG *pointer);



