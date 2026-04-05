/******************************************************************************/
/*                                                                            */
/*                           P C I - B I O S   V1.13                          */
/*                                                                            */
/*                        PCI-BIOS for ATARI-Compatibles                      */
/*                                                                            */
/*  Module:        PCI-BIOS (PCI_BIOS.PRG)                                    */
/*  File:          PCI_BIOS.H                                                 */
/*  Description:   general declarations for the usage of the ATARI PCI-BIOS   */
/*                                                                            */
/*  (c)1997/1998 Markus Fichtenbauer                              30.08.1998  */
/*                                                                            */
/******************************************************************************/
/* $Id$ */
/******************************************************************************/
/* $Log$ */
/******************************************************************************/

#if !defined( __PCIBIOS__ )
#define __PCIBIOS__

/******************************************************************************/
/*                                                                            */
/*                         Declarations of data types                         */
/*                                                                            */
/******************************************************************************/
typedef struct                         /* structure of resource descriptor    */
{
  UWORD next;                          /* length of the following structure   */
  UWORD flags;                         /* type of resource and misc. flags    */
  ULONG start;                         /* start-address of resource           */
  ULONG length;                        /* length of resource                  */
  ULONG offset;                        /* offset PCI to phys. CPU Address     */
  ULONG dmaoffset;                     /* offset for DMA-transfers            */
} PCI_RSC_DESC;

typedef struct                         /* structure of address conversion     */
{
  ULONG adr;                           /* calculated address (CPU<->PCI)      */
  ULONG len;                           /* length of memory range              */
} PCI_CONV_ADR;

/******************************************************************************/
/*                                                                            */
/*                        Constant Data and Definitions                       */
/*                                                                            */
/******************************************************************************/
/*                         PCI Configuration Register                         */
/*                                                                            */
/* Under PCI, each device has 256 bytes of configuration address space, of    */
/* which the first 64 bytes are standardized as follows:                      */
/******************************************************************************/

/* Identification Register contains the Device ID in bits 31..16 and the      */
/* Vendor ID in bits 15..0                                                    */
#define CFID                 0x00      /* Identification Register (32 bits)   */
#define CFID_VENDOR_ID       0x00      /* Vendor ID Register (16 bits)        */
#define CFID_DEVICE_ID       0x02      /* Device ID Register (16 bits)        */

/* Command and Status Register contains the Status Register in bits 31..16    */
/* and the Command Register in bits 15..0                                     */
#define CFCS                 0x04      /* Command and Status Reg. (32 bits)   */
#define CFCS_INIT            0xFFFF0000L    /* reset Register to init. value  */
#define CFCS_COMMAND         0x04      /* Command Register (16 bits)          */
#define CFCR_FASTBACK        0x0200         /* Enable back-to-back writes     */
#define CFCR_SERR            0x0100         /* Enable system error (SERR)     */
#define CFCR_WAIT            0x0080         /* Enable address/data stepping   */
#define CFCR_PARITY          0x0040         /* Enable parity checking         */
#define CFCR_VGAPALETTE      0x0020         /* Enable palette snooping        */
#define CFCR_INVALIDATE      0x0010         /* Use memory write and invalidate*/
#define CFCR_SPECIAL         0x0008         /* Enable response to spec. cycles*/
#define CFCR_MASTER          0x0004         /* Enable bus master operation    */
#define CFCR_MEMSPACE        0x0002         /* Enable response in Memory space*/
#define CFCR_IOSPACE         0x0001         /* Enable response in I/O space   */
#define CFCS_STATUS          0x06      /* Status Register (16 bits)           */
#define CFSR_DETECTED_PARITY 0x8000         /* Set on detected parity error   */
#define CFSR_SIG_SYSTEM_ERR  0x4000         /* Set when we drive SERR         */
#define CFSR_REC_MASTER_AB   0x2000         /* Set on master abort            */
#define CFSR_REC_TARGET_AB   0x1000         /* Master ack of master abort     */
#define CFSR_SIG_TARGET_AB   0x0800         /* Set on target abort            */
#define CFSR_DEVSEL_MASK     0x0600         /* DEVSEL Timing                  */
#define CFSR_DEVSEL_FAST     0x0000              /* after 1 PCI bus cycle     */
#define CFSR_DEVSEL_MEDIUM   0x0200              /* after 2 PCI bus cycles    */
#define CFSR_DEVSEL_SLOW     0x0400              /* after 3 PCI bus cycles    */
#define CFSR_DATA_PARITY     0x0100         /* Detected parity error (master) */
#define CFSR_FASTBACK        0x0080         /* Capable of fast-back-to-back   */
#define CFSR_UDF             0x0040         /* Support User Definable Features*/
#define CFSR_66MHZ           0x0020         /* Support 66 MHz PCI 2.1 bus     */

/* Revision/Class Code Register contains the Classcode in bits 31..8 and the  */
/* Revision ID in bits 7..0 The Classcode itself contains the Base class in   */
/* in bits 31..24, the Sub class in bits 23..16 and the Register Level Progr. */
/* Interface in bits 15..8                                                    */
#define CFRV                 0x08      /* Revision/Class Code Reg. (32 bits)  */
#define CFRV_REVISION        0x08      /* Revision ID Register (8 bits)       */
#define CFRV_CLASS_PROG      0x09      /* Reg. Level Progr. Interface (8 bits)*/
#define CFRV_CLASS_SUB       0x0A      /* Sub class Register (8 bits)         */
#define CFRV_CLASS_BASE      0x0B      /* Base class Register (8 bits)        */

/* Header Type/Latency Timer Register contains the BIST (built in self test)  */
/* in bits 31..24, the Header Type in bits 23..16, the Latency Timer in bits  */
/* 15..8 and finally the Cache Line Size in bits 7..0                         */
#define CFHT                 0x0C      /* HeaderType/LatencyTimer Reg.(32bits)*/
#define CFHT_CACHE_LINE_SIZE 0x0C      /* Cache Line Size Register (8 bits)   */
#define CFHT_LATENCY_TIMER   0x0D      /* Latency Timer Register (8 bits)     */
#define CFHT_HEADER_TYPE     0x0E      /* Header Type Register (8 bits)       */
#define CFHT_BIST            0x0F      /* Built-in self test Register (8 bits)*/
#define CFHT_BIST_CODE_MSK   0x0F           /* Completion code of BIST        */
#define CFHT_BIST_START      0x40           /* 1 to start BIST, 2 secs or less*/
#define CFHT_BIST_CAPABLE    0x80           /* 1 if BIST capable              */

/* Base addresses specify locations in memory or I/O space. Decoded size can  */
/* be determined by writing a value of 0xffffffff to the register, and        */
/* reading it back.  Only 1 bits are decoded.                                 */
#define CBA1                 0x10      /* Base Address Register 1 (32 bits)   */
#define CBA2                 0x14      /* Base Address Register 2 (32 bits)   */
#define CBA3                 0x18      /* Base Address Register 3 (32 bits)   */
#define CBA4                 0x1C      /* Base Address Register 4 (32 bits)   */
#define CBA5                 0x20      /* Base Address Register 5 (32 bits)   */
#define CBA6                 0x24      /* Base Address Register 6 (32 bits)   */
#define CBA_MEMMASK          0xFFFFFFF0L    /* Mask for the memory addess     */
#define CBA_IOMASK           0xFFFFFFFCL    /* Mask for the I/O address       */

#define CCIS                 0x28      /* Cardbus CIS Register                */

/* Subsystem ID Register contains the Subsystem ID in bits 31..16, and the    */
/* Subsystem Vendor ID in bits 15..0                                          */
#define CSID                 0x2C      /* Subsystem ID Register (32 bits)     */
#define CSID_VENDOR_ID       0x2C      /* Subsystem Vendor ID (16 bits)       */
#define CSID_SYSTEM_ID       0x2E      /* Subsystem ID (16 bits)              */

/* Expansion ROM Base Address Register contains the address in bits 31..11    */
/* and the enable bit in bit 0. Bits 10..2 are reserved                       */
#define CBER                 0x30      /* Expansion ROM Base Address Register */
#define CBER_ROM_ENABLE      0x01           /* Write 1 to enable ROM          */

/* Registers at addresses 0x34 to 0x3B are reserved                           */

/* Interrupt Register contains the Max. Latency Timer value in bits 31..24,   */
/* the Min. Grant Time value in bits 23..16, the Interrupt Pin Register in    */
/* bits 15..8 and finally the Interrupt Line Register in bits 7..0            */
#define CFIL                 0x3C      /* Interrupt Register (32 bits)        */
#define CFIL_INTERRUPT_LINE  0x3C      /* Interrupt Line Register (8 bits)    */
#define CFIL_INTERRUPT_PIN   0x3D      /* Interrupt Pin Register (8 bits)     */
#define CFIL_MIN_GNT         0x3E      /* Min GNT value (8 bits)              */
#define CFIL_MAX_LAT         0x3F      /* Max LAT value (8 bits)              */

#define CFDA                 0x40      /* Driver Area Register                */

/******************************************************************************/
/*                             PCI Class Codes                                */
/******************************************************************************/

#define PCI_CLASS_NOT_DEFINED     0x0000    /* Base Class 0: (old devices)    */
#define PCI_CLASS_NOT_DEFINED_VGA 0x0001

#define PCI_BASE_CLASS_STORAGE    0x01      /* Base Class 1: Storage devices  */
#define PCI_CLASS_STORAGE_SCSI    0x0100
#define PCI_CLASS_STORAGE_IDE     0x0101
#define PCI_CLASS_STORAGE_FLOPPY  0x0102
#define PCI_CLASS_STORAGE_IPI     0x0103
#define PCI_CLASS_STORAGE_RAID    0x0104
#define PCI_CLASS_STORAGE_OTHER   0x0180

#define PCI_BASE_CLASS_NETWORK    0x02      /* Base Class 2: Network devices  */
#define PCI_CLASS_NETW_ETHERNET   0x0200
#define PCI_CLASS_NETW_TOKEN_RING 0x0201
#define PCI_CLASS_NETW_FDDI       0x0202
#define PCI_CLASS_NETW_ATM        0x0203
#define PCI_CLASS_NETW_OTHER      0x0280

#define PCI_BASE_CLASS_DISPLAY    0x03      /* Base Class 3: Display devices  */
#define PCI_CLASS_DISPLAY_VGA     0x0300
#define PCI_CLASS_DISPLAY_XGA     0x0301
#define PCI_CLASS_DISPLAY_OTHER   0x0380

#define PCI_BASE_CLASS_MULTIMEDIA 0x04      /* Base Class 4: Multimedia dev.  */
#define PCI_CLASS_MULTIM_VIDEO    0x0400
#define PCI_CLASS_MULTIM_AUDIO    0x0401
#define PCI_CLASS_MULTIM_OTHER    0x0480

#define PCI_BASE_CLASS_MEMORY     0x05      /* Base Class 5: Memory devices   */
#define PCI_CLASS_MEMORY_RAM      0x0500
#define PCI_CLASS_MEMORY_FLASH    0x0501
#define PCI_CLASS_MEMORY_OTHER    0x0580

#define PCI_BASE_CLASS_BRIDGE     0x06      /* Base Class 6: Bridge devices   */
#define PCI_CLASS_BRIDGE_HOST     0x0600
#define PCI_CLASS_BRIDGE_ISA      0x0601
#define PCI_CLASS_BRIDGE_EISA     0x0602
#define PCI_CLASS_BRIDGE_MC       0x0603
#define PCI_CLASS_BRIDGE_PCI      0x0604
#define PCI_CLASS_BRIDGE_PCMCIA   0x0605
#define PCI_CLASS_BRIDGE_NUBUS    0x0606
#define PCI_CLASS_BRIDGE_CARDBUS  0x0607
#define PCI_CLASS_BRIDGE_OTHER    0x0680

#define PCI_BASE_CLASS_COMM       0x07      /* Base Class 7: Communication    */
#define PCI_CLASS_COMM_SERIAL     0x0700
#define PCI_CLASS_COMM_PARALLEL   0x0701
#define PCI_CLASS_COMM_OTHER      0x0780

#define PCI_BASE_CLASS_SYSTEM     0x08      /* Base Class 8: System devices   */
#define PCI_CLASS_SYSTEM_PIC      0x0800
#define PCI_CLASS_SYSTEM_DMA      0x0801
#define PCI_CLASS_SYSTEM_TIMER    0x0802
#define PCI_CLASS_SYSTEM_RTC      0x0803
#define PCI_CLASS_SYSTEM_OTHER    0x0880

#define PCI_BASE_CLASS_INPUT      0x09      /* Base Class 9: Input devices    */
#define PCI_CLASS_INPUT_KEYBOARD  0x0900
#define PCI_CLASS_INPUT_PEN       0x0901
#define PCI_CLASS_INPUT_MOUSE     0x0902
#define PCI_CLASS_INPUT_OTHER     0x0980

#define PCI_BASE_CLASS_DOCKING    0x0A      /* Base Class 10: Docking devices */
#define PCI_CLASS_DOCKING_GENERIC 0x0A00
#define PCI_CLASS_DOCKING_OTHER   0x0A01

#define PCI_BASE_CLASS_PROCESSOR  0x0B      /* Base Class 11: Processors      */
#define PCI_CLASS_PROC_386        0x0B00
#define PCI_CLASS_PROC_486        0x0B01
#define PCI_CLASS_PROC_PENTIUM    0x0B02
#define PCI_CLASS_PROC_ALPHA      0x0B10
#define PCI_CLASS_PROC_POWERPC    0x0B20
#define PCI_CLASS_PROC_CO         0x0B40

#define PCI_BASE_CLASS_SERIAL     0x0C      /* Base Class 12: Serial devices  */
#define PCI_CLASS_SERIAL_FIREWIRE 0x0C00
#define PCI_CLASS_SERIAL_ACCESS   0x0C01
#define PCI_CLASS_SERIAL_SSA      0x0C02
#define PCI_CLASS_SERIAL_USB      0x0C03
#define PCI_CLASS_SERIAL_FIBER    0x0C04

#define PCI_CLASS_OTHERS          0xFF      /* Base class 255: all other dev. */

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
#define FLG_IO        0x4000           /* Ressource in IO range               */
#define FLG_LAST      0x8000           /* last ressource                      */
#define FLG_8BIT      0x0100           /* 8 bit accesses allowed              */
#define FLG_16BIT     0x0200           /* 16 bit accesses allowed             */
#define FLG_32BIT     0x0400           /* 32 bit accesses allowed             */
#define FLG_ENDMASK   0x000F           /* mask for byte ordering              */
/******************************************************************************/
/*                 Values used in FLG_ENDMASK for Byte Ordering               */
/******************************************************************************/
#define ORD_MOTOROLA       0           /* Motorola (big endian)               */
#define ORD_INTEL_AS       1           /* Intel (little endian), addr.swapped */
#define ORD_INTEL_LS       2           /* Intel (little endian), lane swapped */
#define ORD_UNKNOWN       15           /* unknown (BIOS-calls allowed only)   */

/******************************************************************************/
/*                   Status Info used in Device-Descriptor                    */
/******************************************************************************/
#define DEVICE_FREE        0           /* Device is not used                  */
#define DEVICE_USED        1           /* Device is used by another driver    */
#define DEVICE_CALLBACK    2           /* used, but driver can be cancelled   */
#define DEVICE_AVAILABLE   3           /* used, not available                 */
#define NO_DEVICE         -1           /* no device detected                  */

/******************************************************************************/
/*                            Callback-Routinen                               */
/******************************************************************************/
#define GET_DRIVER_ID      0           /* CB-Routine 0: Get Driver ID         */
#define REMOVE_DRIVER      1           /* CB-Routine 1: Remove Driver         */

#endif                                 /* __PCIBIOS__                         */

