/******************************************************************************/
/*                                                                            */
/*                           P C I - B I O S   V1.11                          */
/*                                                                            */
/*                          PCI-Bios for HADES040/060                         */
/*                                                                            */
/*  Module:        PCI-BIOS (PCI_BIOS.PRG)                                    */
/*  File:          PCI_BIOS.H                                                 */
/*  Description:   general declarations for the usage of PCI-BIOS             */
/*                                                                            */
/*  (c)1997/1998 Markus Fichtenbauer                              28.03.1998  */
/*                                                                            */
/******************************************************************************/
/* $Id$ */
/******************************************************************************/
/* $Log$ */
/******************************************************************************/

typedef struct
{
	UWORD next;
	UWORD flags;
	ULONG start;
	ULONG length;
	ULONG offset;
	ULONG dmaoffset;
} PCI_RSC_DESC;

#define NEXT_RSC(ptr) ptr=(PCI_RSC_DESC *)(((UBYTE*)ptr)+ptr->next)

typedef struct                         /* Aufbau der Umrechnungsstruktur      
*/
{
  ULONG adr;                           /* umgerechnete Adresse (CPU<->PCI)    */
  ULONG len;                           /* L„nge des Speicherbereichs          */
} PCI_CONV_ADR;

/******************************************************************************/
/*                                                                            */
/*                        Constant Data and Definitions                       */
/*                                                                            */
/******************************************************************************/
/*                         PCI Configuration Register                         */
/******************************************************************************/
#define CFID  0x00                     /* Identification Register             */
#define CFCS  0x04                     /* Command and Status Register         */
#define CFRV  0x08                     /* Revision/Class Code Register        */
#define CFHT  0x0C                     /* Header Type/Latency Timer Register  */
#define CBA1  0x10                     /* Base Address Register 1             */
#define CBA2  0x14                     /* Base Address Register 2             */
#define CBA3  0x18                     /* Base Address Register 3             */
#define CBA4  0x1C                     /* Base Address Register 4             */
#define CBA5  0x20                     /* Base Address Register 5             */
#define CBA6  0x24                     /* Base Address Register 6             */
#define CBER  0x30                     /* Expansion ROM Base Address          */
#define CFIL  0x3C                     /* Interrupt Register                  */

/******************************************************************************/
/*                          PCI-BIOS Error Codes                              */
/******************************************************************************/
#define PCI_SUCCESSFUL           0x0L            /* everything's fine         */
#define PCI_FUNC_NOT_SUPPORTED   0xFFFFFFFEL     /* function not supported    */
#define PCI_BAD_VENDOR_ID        0xFFFFFFFDL     /* wrong Vendor ID           */
#define PCI_DEVICE_NOT_FOUND     0xFFFFFFFCL     /* PCI-Device not found      */
#define PCI_BAD_REGISTER_NUMBER  0xFFFFFFFBL     /* wrong register number     */
#define PCI_SET_FAILED           0xFFFFFFFAL     /* reserved for later use    */
#define PCI_BUFFER_TOO_SMALL     0xFFFFFFF9L     /* reserved for later use    */
#define PCI_GENERAL_ERROR        0xFFFFFFF8L     /* general BIOS error code   */
#define PCI_BAD_HANDLE           0xFFFFFFF7L     /* wrong/unknown PCI-handle  */
#define PCI_BIOS_NOT_INSTALLED   0xFFFFF001L     /* PCI-BIOS is not installed */
#define PCI_BIOS_WRONG_VERSION   0xFFFFF000L     /* wrong version of BIOS     */

/******************************************************************************/
/*                      Flags used in Resource-Descriptor                     */
/******************************************************************************/
#define RSC_IO     0x4000              /* Ressource in IO range               */
#define RSC_LAST   0x8000              /* last ressource                      */
#define FLG_8BIT   0x0100              /* 8 bit accesses allowed              */
#define FLG_16BIT  0x0200              /* 16 bit accesses allowed             */
#define FLG_32BIT  0x0400              /* 32 bit accesses allowed             */
#define FLG_INTLS  0x0004              /* Byte ordering Intel, lane swapped   */

/******************************************************************************/
/*                   Status Info used in Device-Descriptor                    */
/******************************************************************************/
#define DEVICE_FREE        0           /* Device is not used                  */
#define DEVICE_USED        1           /* Device is used by another driver    */
#define DEVICE_CALLBACK    2           /* used, but driver can be cancelled   */
#define DEVICE_AVAILABLE   3           /* used, not available                 */
#define NO_DEVICE         -1           /* no device detected                  */

/******************************************************************************/
/*                         PCI-BIOS function prototypes                       */
/******************************************************************************/
extern LONG pcibios_init(void);

#if 0
LONG (*find_pci_device)(ULONG id, UWORD index) = NULL;
LONG (*find_pci_classcode)(ULONG class, UWORD index) = NULL;
LONG (*read_config_byte)(LONG handle, UBYTE reg, UBYTE *adresse) = NULL;
LONG (*read_config_word)(LONG handle, UBYTE reg, UWORD *adresse) = NULL;
LONG (*read_config_longword)(LONG handle, UBYTE reg, ULONG *adresse) = NULL;
UBYTE (*fast_read_config_byte)(LONG handle, UBYTE reg) = NULL;
UWORD (*fast_read_config_word)(LONG handle, UBYTE reg) = NULL;
ULONG (*fast_read_config_longword)(LONG handle, UBYTE reg) = NULL;
LONG (*write_config_byte)(LONG handle, UBYTE reg, UBYTE val) = NULL;
LONG (*write_config_word)(LONG handle, UBYTE reg, UWORD val) = NULL;
LONG (*write_config_longword)(LONG handle, UBYTE reg, ULONG val) = NULL;
LONG (*hook_interrupt)(LONG handle, ULONG *routine, ULONG *parameter) = NULL;
LONG (*unhook_interrupt)(LONG handle) = NULL;
LONG (*special_cycle)(UBYTE bus, ULONG data) = NULL;
LONG (*get_routing)(LONG handle) = NULL;
LONG (*set_interrupt)(LONG handle) = NULL;
LONG (*get_resource)(LONG handle) = NULL;
LONG (*get_card_used)(LONG handle, ULONG *adresse) = NULL;
LONG (*set_card_used)(LONG handle, ULONG *callback) = NULL;
LONG (*read_mem_byte)(LONG handle, ULONG offset, UBYTE *adresse) = NULL;
LONG (*read_mem_word)(LONG handle, ULONG offset, UWORD *adresse) = NULL;
LONG (*read_mem_longword)(LONG handle, ULONG offset, ULONG *adresse) = NULL;
UBYTE (*fast_read_mem_byte)(LONG handle, ULONG offset) = NULL;
UWORD (*fast_read_mem_word)(LONG handle, ULONG offset) = NULL;
ULONG (*fast_read_mem_longword)(LONG handle, ULONG offset) = NULL;
LONG (*write_mem_byte)(LONG handle, ULONG offset, UBYTE val) = NULL;
LONG (*write_mem_word)(LONG handle, ULONG offset, UWORD val) = NULL;
LONG (*write_mem_longword)(LONG handle, ULONG offset, ULONG val) = NULL;
LONG (*read_io_byte)(LONG handle, ULONG offset, UBYTE *adresse) = NULL;
LONG (*read_io_word)(LONG handle, ULONG offset, UWORD *adresse) = NULL;
LONG (*read_io_longword)(LONG handle, ULONG offset, ULONG *adresse) = NULL;
UBYTE (*fast_read_io_byte)(LONG handle, ULONG offset) = NULL;
UWORD (*fast_read_io_word)(LONG handle, ULONG offset) = NULL;
ULONG (*fast_read_io_longword)(LONG handle, ULONG offset) = NULL;
LONG (*write_io_byte)(LONG handle, ULONG offset, UBYTE val) = NULL;
LONG (*write_io_word)(LONG handle, ULONG offset, UWORD val) = NULL;
LONG (*write_io_longword)(LONG handle, ULONG offset, ULONG val) = NULL;
LONG (*get_machine_id)(void) = NULL;
LONG (*get_pagesize)(void) = NULL;
LONG (*virt_to_bus)(LONG handle, ULONG adresse, ULONG *pointer) = NULL;
LONG (*bus_to_virt)(LONG handle, ULONG adresse, ULONG *pointer) = NULL;
#endif

static inline LONG find_pci_device(ULONG dev, UWORD index)
{
	register ULONG ret __asm__("d0");
	register LONG _dev __asm__("d0") = dev;
	register UWORD _index __asm__("d1") = index;

	asm volatile("
		move.l _bios_cookie,a0
		move.l 0x0C(a0),a0
		jsr (a0)
		": "=r" (ret)
		: "di"(_dev), "di"(_index)
		: "cc","d1","a0");
	return ret;
}
static inline LONG find_pci_classcode(ULONG class, UWORD index)
{
	register ULONG ret __asm__("d0");
	register LONG _class __asm__("d0") = class;
	register UWORD _index __asm__("d1") = index;

	asm volatile("
		move.l _bios_cookie,a0
		move.l 0x0C(a0),a0
		jsr (a0)
		": "=r" (ret)
		: "di"(_class), "di"(_index)
		: "cc","d0","d1","a0");
	return ret;
}

static inline ULONG fast_read_config_longword(LONG handle, UBYTE reg)
{
	register ULONG ret __asm__("d0");
	register LONG _handle __asm__("d0") = handle;
	register UBYTE _reg __asm__("d1") = reg;

	asm volatile("
		move.l _bios_cookie,a0
		move.l 0x24(a0),a0
		jsr (a0)
		": "=r" (ret)
		: "di"(_handle), "di"(_reg)
		: "cc","d0","d1","a0");
	return ret;
}

static inline ULONG write_config_longword(LONG handle, UBYTE reg, ULONG val)
{
	register ULONG ret __asm__("d0");
	register LONG _handle __asm__("d0") = handle;
	register UBYTE _reg __asm__("d1") = reg;
	register ULONG _val __asm("d2") = val;

	asm volatile("
		move.l _bios_cookie,a0
		move.l 0x30(a0),a0
		jsr (a0)
		": "=r" (ret)
		: "di"(_handle), "di"(_reg), "di"(_val)
		: "cc","d0","d1","d2","a0");
	return ret;
}

static inline PCI_RSC_DESC *get_resource(LONG handle)
{
	register PCI_RSC_DESC *ret __asm__("d0");
	register LONG _handle __asm__("d0") = handle;
	asm volatile("
		move.l _bios_cookie,a0
		move.l 0x48(a0),a0
		jsr (a0)
		": "=r" (ret)
		: "di"(_handle)
		: "cc","d0","a0");
	return ret;
}

static inline ULONG get_machine_id(void)
{
	register ULONG ret __asm__("d0");
	asm volatile("
		move.l _bios_cookie,a0
		move.l 0x9C(a0),a0
		jsr (a0)
		": "=r" (ret)
		:
		: "cc","d0","a0");
	return ret;
}

static inline ULONG get_pagesize(void)
{
	register ULONG ret __asm__("d0");
	asm volatile("
		move.l _bios_cookie,a0
		move.l 0xa0(a0),a0
		jsr (a0)
		": "=r" (ret)
		:
		: "cc","d0","a0");
	return ret;
}

static inline LONG virt_to_bus(LONG handle, ULONG addr, PCI_CONV_ADR *conv)
{
	register LONG   ret __asm__("d0") = handle;
	register ULONG _addr __asm__("d1") = addr;
	register PCI_CONV_ADR *_conv __asm__("a0") = conv;
	asm volatile("
		move.l _bios_cookie,a1
		move.l 0xa4(a1),a1
		jsr (a1)
		": "=r" (ret)
		: "di"(ret), "di"(_addr), "a" (_conv)
		: "cc","d0","d1","a0","a1");
	return ret;
}

static inline LONG get_card_used(LONG handle, ULONG *addr)
{
	register LONG   ret __asm__("d0") = handle;
	register ULONG *_addr __asm__("a0") = addr;
	asm volatile("
		move.l _bios_cookie,a1
		move.l 0x4c(a1),a1
		jsr (a1)
		": "=r" (ret)
		: "di"(ret), "a"(_addr)
		: "cc","d0","a0","a1");
	return ret;
}

static inline LONG set_card_used(LONG handle, void *addr)
{
	register LONG   ret __asm__("d0") = handle;
	register void *_addr __asm__("a0") = addr;
	asm volatile("
		move.l _bios_cookie,a1
		move.l 0x50(a1),a1
		jsr (a1)
		": "=r" (ret)
		: "di"(ret), "a"(_addr)
		: "cc","d0","a0","a1");
	return ret;
}
