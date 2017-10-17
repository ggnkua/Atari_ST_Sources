#ifndef _PCI_BIOS_H_
#define _PCI_BIOS_H_

#define LITTLE_ENDIAN_LANE_SWAPPED
#define CHECK_PARITY
#undef SAME_CPU_PCI_MEM_ADDR // for fix DMA problems with some drivers

#ifdef COLDFIRE
#include "fire.h"
// host bridge configuration
#define PCI_RETRIES 0 // infinite (bug before date code XXX0445)
#define PCI_CACHE_LINE 8
#define PCI_MINGNT 1
#define PCI_MAXLAT 42
#else
#define PCI_MAXLAT 32
#endif

#define PCI_BIOS_REV          0x10000

#ifdef COLDFIRE
#undef PCI_DYNAMIC_MAPPING
#define PCI_LOCAL_CONFIG  MCF_PCI_PCIIDR
#ifdef MCF5445X
#define PCI_IRQ_BASE_VECTOR    (64+INT1_HI_PCI_SCR+64+OFFSET_INT_CF68KLIB)
#define PCI_MEMORY_OFFSET   0xA0000000
#define PCI_MEMORY_SIZE     0x10000000   /* 256 MB */ 
#define PCI_IO_OFFSET       0xB0000000
#define PCI_IO_SIZE         0x10000000   /* 256 MB */
#else /* MCF548X */
#define PCI_IRQ_BASE_VECTOR    (64+41+OFFSET_INT_CF68KLIB)
#define PCI_MEMORY_OFFSET   0x80000000
#define PCI_MEMORY_SIZE     0x40000000   /* 1024 MB */ 
#define PCI_IO_OFFSET       0xD0000000
#define PCI_IO_SIZE         0x10000000   /* 256 MB */
#endif /* MCF5445X */ 
#else /* ATARI - CTPCI */
#define PCI_DYNAMIC_MAPPING
/* note: Ethernat use 0x80000000-0x8000003F space and interrupts vectors 0xC4-0xC5 */
/*       Supervidel registers are at 0x80010000                                    */
#define PCI_IRQ_BASE_VECTOR       0xC9   /* offset 0x9:LINT - 0xA:INT#A - 0xB:INT#B - 0xC:INT#C - 0xD:INT#D */
#define PCI_CTPCI_CONFIG    0xE0000000   /* CTPCI registers */
#define PCI_CTPCI_CONFIG_PEND   (PCI_CTPCI_CONFIG+0)
#define PCI_CTPCI_CONFIG_ENABI  (PCI_CTPCI_CONFIG+1)
#define PCI_CTPCI_CONFIG_VECTOR (PCI_CTPCI_CONFIG+3)
#define PCI_CTPCI_CONFIG_RESET  (PCI_CTPCI_CONFIG+0x20)
#define ITF                 2            /* IDE Fast Timming for 75-100 MHz */
/* B0:INTON B4-B7:VE4-VE7 */
#define PCI_LOCAL_CONFIG    0xE8000000   /* CT60 bus slot - no cache - reserved */
#ifdef PCI_DYNAMIC_MAPPING
#define PCI_MEMORY_OFFSET_1 0x40000000   /* CT60 bus slot - cache */
#define PCI_MEMORY_SIZE_1   0x20000000   /* 512 MB */ 
#define PCI_IO_OFFSET_1     0xC0000000   /* CT60 bus slot - no cache */
#define PCI_IO_SIZE_1       0x20000000   /* 512 MB */
#define PCI_MEMORY_OFFSET_2 0x40000000   /* CT60 bus slot - cache */
#define PCI_MEMORY_SIZE_2   0x40000000   /* 1 GB */ 
#define PCI_IO_OFFSET_2     0x80000000   /* CT60 bus slot - no cache */
#define PCI_IO_SIZE_2       0x40000000   /* 1 GB */
#if PCI_MEMORY_SIZE_1 != PCI_IO_SIZE_1
#error PLX need MEM and I/O with the same size
#endif
#if PCI_MEMORY_SIZE_2 != PCI_IO_SIZE_2
#error PLX need MEM and I/O with the same size
#endif
#else /* !PCI_DYNAMIC_MAPPING */
#define PCI_MEMORY_OFFSET   0x40000000   /* CT60 bus slot - cache */
#define PCI_MEMORY_SIZE     0x20000000   /* 512 MB */ 
#define PCI_IO_OFFSET       0xC0000000   /* CT60 bus slot - no cache */
#define PCI_IO_SIZE         0x20000000   /* 512 MB */
#if PCI_MEMORY_SIZE != PCI_IO_SIZE
#error PLX need MEM and I/O with the same size
#endif
#endif /* PCI_DYNAMIC_MAPPING */
#define PCI_DRIVERS_OFFSET  0x21000000   /* RAM for drivers in flash */
#define PCI_DRIVERS_SIZE    0x00050000   /* => also in pci.lk !!!    */
#endif /* COLDFIRE */
#define GRAPHIC_CARD_SIZE   0x10000000

#define PCI_NOBODYHOME          0xFFFF

#define PCI_MAX_FUNCTION             4  /* 4 functions per PCI slot */

#ifdef COLDFIRE

#ifdef MCF547X                         /* FIREBEE */
#define PCI_MAX_HANDLE           (7+1) /* 7 slots on the Firebee + host bridge MCF547X */
#else /* MCF548X - MCF5445X */   
#define PCI_MAX_HANDLE           (4+1) /* 4 slots on the M5484LITE/M5485EVB/M54455EVB + host bridge MCF548X/MCF5445X */
#endif /* MCF547X */

#define LAST_LOCAL_REGISTER  0x40

#define LOCAL_REGISTERS_BIG // local registers are in Big Endian on the Coldfire

#else /* PLX9054 */

#define PCI_MAX_HANDLE              5  /* 4 slots on the CTPCI + host bridge PLX9054 */

/* PLX9054 ID */
#define PLX9054            0x905410B5
#define PLX9054_SWAPPED    0xB5105490

/* PLX9054 local configuration registers */
#define LAS0RR                0x80   /* Local Address Space 0 Range
                                        Register for PCI-to-Local Bus       */
#define LAS0BA                0x84   /* Local Address Space 0 Local Base
                                        Address (Remap)                     */
#define MARBR                 0x88   /* Mode/DMA Arbitration                */
#define BIGEND                0x8C   /* Big/Little Endian Descriptor        */
#define LMISC                 0x8D   /* Local Miscellaneous Control         */
#define PROT_AREA             0x8E   /* Serial EEPROM Write-Protect
                                        Address Boundary                    */
#define EROMRR                0x90   /* Expansion ROM Range                 */
#define EROMBA                0x94   /* Expansion ROM Local Base Address
                                        (Remap)                             */
#define LBRD0                 0x98   /* Local Address Space 0/Expansion ROM
                                        Bus Region Descriptor               */
#define DMRR                  0x9C   /* Local Range Register for PCI 
                                        Initiator-to-PCI                    */
#define DMLBAM                0xA0   /* Local Bus Base Address Register for
                                        PCI Initiator-to-PCI Memory         */
#define DMLBAI                0xA4   /* Local Bus Base Address Register for
                                        PCI Initiator-to-PCI I/O Config     */
#define DMPBAM                0xA8   /* PCI Base Address (Remap) Register
                                        for PCI Initiator-to-PCI Memory     */
#define DMCFGA                0xAC   /* PCI Configuration Address Register
                                        for PCI Initiator-to-PCI I/O Config */
#define OPQIS                 0xB0   /* Outbound Post Queue Post Queue 
                                        Interrupt Status                    */
#define OPQIM                 0xB4   /* Outbound Post Queue Post Queue 
                                        Interrupt Mask                      */
#define MBOX0                 0xC0   /* Mailbox Register 0                  */
#define MBOX1                 0xC4   /* Mailbox Register 1                  */
#define MBOX2                 0xC8   /* Mailbox Register 2                  */
#define MBOX3                 0xCC   /* Mailbox Register 3                  */
#define MBOX4                 0xD0   /* Mailbox Register 4                  */
#define MBOX5                 0xD4   /* Mailbox Register 5                  */
#define MBOX6                 0xD8   /* Mailbox Register 6                  */
#define MBOX7                 0xDC   /* Mailbox Register 7                  */
#define P2LDBELL              0xE0   /* PCI-to-Local Doorbell               */
#define L2PDBELL              0xE4   /* Local-to-PCI Doorbell               */
#define INTCSR                0xE8   /* Interrupt Control/Status            */
#define CNTRL                 0xEC   /* Serial EEPROM Control, PCI Command
                                        Codes, User I/O Ctrl, and Init Ctrl */
#define PCIHIDR               0xF0   /* PCI Hardcoded Configuration ID      */
#define PCIHREV               0xF4   /* PCI Hardcoded Revision ID           */
#define DMAMODE0             0x100   /* DMA Channel 0 Mode                  */
#define DMAPADR0             0x104   /* DMA Channel 0 PCI Address           */
#define DMALADR0             0x108   /* DMA Channel 0 Local Address         */
#define DMASIZ0              0x10C   /* DMA Channel 0 Transfer Size (Bytes) */
#define DMADPR0              0x110   /* DMA Channel 0 Descriptor Pointer    */
#define DMAMODE1             0x114   /* DMA Channel 1 Mode                  */
#define DMAPADR1             0x118   /* DMA Channel 1 PCI Address           */
#define DMALADR1             0x11C   /* DMA Channel 1 Local Address         */
#define DMASIZ1              0x120   /* DMA Channel 1 Transfer Size (Bytes) */
#define DMADPR1              0x124   /* DMA Channel 1 Descriptor Pointer    */
#define DMASCR0              0x128   /* DMA Channel 0 Command/Status        */
#define DMASCR1              0x129   /* DMA Channel 1 Command/Status        */
#define DMAARB               0x12C   /* DMA Arbitration                     */
#define DMATHR               0x130   /* DMA Threshold                       */
#define DMADAC0              0x134   /* DMA Channel 0 PCI Dual Address
                                        Cycle Address                       */
#define DMADAC1              0x134   /* DMA Channel 1 PCI Dual Address
                                        Cycle Address                       */
#define MQCR                 0x140   /* Messaging Queue Configuration       */
#define QBAR                 0x144   /* Queue Base Address                  */
#define IFHPR                0x148   /* Inbound Free Head Pointer           */
#define IFTPR                0x14C   /* Inbound Free Tail Pointer           */
#define IPHPR                0x150   /* Inbound Post Head Pointer           */
#define IPTPR                0x154   /* Inbound Post Tail Pointer           */
#define OFHPR                0x158   /* Outbound Free Head Pointer          */
#define OFTPR                0x15C   /* Outbound Free Tail Pointer          */
#define OPHPR                0x160   /* Outbound Post Head Pointer          */
#define OPTPR                0x164   /* Outbound Post Tail Pointer          */
#define QSR                  0x168   /* Queue Status/Control                */
#define LAS1RR               0x170   /* Local Address Space 1 Range Register
                                        for PCI-to-Local Bus                */
#define LAS1BA               0x174   /* Local Address Space 1 Local Base
                                        Address (Remap)                     */
#define LBRD1                0x178   /* Local Address Space 1 Bus Region
                                        Descriptor                          */
#define DMDAC                0x17C   /* PCI Initiator PCI Dual Address Cycle*/

#define LAST_LOCAL_REGISTER  0x200

#endif /* COLDFIRE */

/* PCI configuration registers */
#define PCIIDR                0x00   /* PCI Configuration ID Register       */
#define PCICSR                0x04   /* PCI Command/Status Register         */
#define PCICR                 0x04   /* PCI Command Register                */
#define PCISR                 0x06   /* PCI Status Register                 */
#define PCIREV                0x08   /* PCI Revision ID Register            */
#define PCICCR                0x09   /* PCI Class Code Register             */
#define PCICLSR               0x0C   /* PCI Cache Line Size Register        */
#define PCILTR                0x0D   /* PCI Latency Timer Register          */
#define PCIHTR                0x0E   /* PCI Header Type Register            */
#define PCIBISTR              0x0F   /* PCI Build-In Self Test Register     */
#define PCIBAR0               0x10   /* PCI Base Address Register for Memory
                                        Accesses to Local, Runtime, and DMA */
#define PCIBAR1               0x14   /* PCI Base Address Register for I/O
                                        Accesses to Local, Runtime, and DMA */
#define PCIBAR2               0x18   /* PCI Base Address Register for Memory
                                        Accesses to Local Address Space 0   */
#define PCIBAR3               0x1C   /* PCI Base Address Register for Memory
                                        Accesses to Local Address Space 1   */ 
#define PCIBAR4               0x20   /* PCI Base Address Register, reserved */
#define PCIBAR5               0x24   /* PCI Base Address Register, reserved */
#define PCICIS                0x28   /* PCI Cardbus CIS Pointer, not support*/
#define PCISVID               0x2C   /* PCI Subsystem Vendor ID             */
#define PCISID                0x2E   /* PCI Subsystem ID                    */
#define PCIERBAR              0x30   /* PCI Expansion ROM Base Register     */
#define CAP_PTR               0x34   /* New Capability Pointer              */
#define PCIILR                0x3C   /* PCI Interrupt Line Register         */
#define PCIIPR                0x3D   /* PCI Interrupt Pin Register          */
#define PCIMGR                0x3E   /* PCI Min_Gnt Register                */
#define PCIMLR                0x3F   /* PCI Max_Lat Register                */
#define PMCAPID               0x40   /* Power Management Capability ID      */
#define PMNEXT                0x41   /* Power Management Next Capability
                                        Pointer                             */
#define PMC                   0x42   /* Power Management Capabilities       */
#define PMCSR                 0x44   /* Power Management Control/Status     */
#define PMCSR_BSE             0x46   /* PMCSR Bridge Support Extensions     */
#define PMDATA                0x47   /* Power Management Data               */
#define HS_CNTL               0x48   /* Hot Swap Control                    */
#define HS_NEXT               0x49   /* Hot Swap Next Capability Pointer    */
#define HS_CSR                0x4A   /* Hot Swap Control/Status             */
#define PVPDCNTL              0x4C   /* PCI Vital Product Data Control      */
#define PVPD_NEXT             0x4D   /* PCI Vital Product Data Next
                                        Capability Pointer                  */
#define PVPDAD                0x4E   /* PCI Vital Product Data Address      */
#define PVPDATA               0x50   /* PCI VPD Data                        */

/* Command register bit definitions */
#define PCI_CMDREG_IOSP          1   /* Enable IO space accesses            */
#define PCI_CMDREG_MEMSP         2   /* Enable MEM space accesses           */
#define PCI_CMDREG_MASTR         4   /* Enable PCI Mastership               */
#define PCI_CMDREG_SPCYC         8   /* Monitor special cycles              */
#define PCI_CMDREG_MEMWINV    0x10   /* Enable memory write and invalidate  */
#define PCI_CMDREG_VGASNP     0x20   /* Enable VGA palette snooping         */
#define PCI_CMDREG_PERR       0x40   /* Enable Parity error response        */
#define PCI_CMDREG_STEP       0x80   /* Enable address/data stepping        */
#define PCI_CMDREG_SERR      0x100   /* Enable SERR driver                  */
#define PCI_CMDREG_FSTB2B    0x200   /* Enable back to back transactions    */

/* Status register bit definitions */
#define PCI_STATREG_C         0x10   /* Capabilities                        */
#define PCI_STATREG_66M       0x20   /* 66MHz Capable                       */
#define PCI_STATREG_UDF       0x40   /* UDF Supoorted                       */
#define PCI_STATREG_TFBBC     0x80   /* Fast Back to Back capable           */
#define PCI_STATREG_DP_D     0x100   /* data data parity error              */
#define PCI_STATREG_SPEED    0x600   /* device speed mask                   */
#define PCI_STATREG_S_TA     0x800   /* Signalled Target Abort              */
#define PCI_STATREG_R_TA    0x1000   /* Received Target Abort               */
#define PCI_STATREG_R_MA    0x2000   /* Received Master Abort               */
#define PCI_STATREG_S_SERR  0x4000   /* Signalled SERR#                     */
#define PCI_STATREG_D_PE    0x8000   /* Detected Parity Error               */

/* Base register bit definitions */
#define PCI_BASE_SPACE_M         1   /* memory space indicator              */
#define PCI_BASE_SPACE_IO        1   /* IO space                            */
#define PCI_BASE_SPACE_MEM       0   /* memory space                        */
#define PCI_BASE_TYPE_MEM        0   /* 32-bit memory address               */
#define PCI_BASE_TYPE_LOW        2   /* less than 1Mb address               */
#define PCI_BASE_TYPE_ALL        4   /* 64-bit memory address               */
#define PCI_BASE_TYPE_RES        6   /* reserved                            */
#define PCI_BASE_TYPE_M     0x00000006  /* type indicator mask              */
#define PCI_BASE_PREF_M     0x00000008  /* prefetch mask                    */
#define PCI_BASE_M_ADDR_M	  0xFFFFFFF0  /* memory address mask              */
#define PCI_BASE_IO_ADDR_M  0xFFFFFFFC  /* I/O address mask                 */
#define PCI_BASE_ROM_ADDR_M 0xFFFFF800  /* ROM address mask                 */
#define PCI_BASE_ROM_ENABLE 0x00000001  /* ROM decoder enable               */

/* PCI Class codes */
#define PCI_CLASS_NONE           0   /* class code for pre-2.0 devices      */
#define PCI_CLASS_MASS           1   /* Mass Storage Controller class       */
#define PCI_CLASS_NET            2   /* Network Controller class            */
#define PCI_CLASS_DISPLAY        3   /* Display Controller class            */
#define PCI_CLASS_MM             4   /* Multimedia Controller class         */
#define PCI_CLASS_MEM            5   /* Memory Controller class             */
#define PCI_CLASS_BRIDGE         6   /* Bridge Controller class             */
#define PCI_CLASS_COMM           7   /* Communications Controller class     */
#define PCI_CLASS_PERIPH         8   /* Peripheral Controller class         */
#define PCI_CLASS_INPUT          9   /* Input Device class                  */
#define PCI_CLASS_DOCK          10   /* Docking Station class               */
#define PCI_CLASS_PROCESSOR     11   /* Processor class                     */
#define PCI_CLASS_SERIALBUS     12   /* Serial Bus class                    */
#define PCI_CLASS_WIRELESS      13   /* Wireless Controller class           */
#define PCI_CLASS_INTIO         14   /* Intelligent IO Controller class     */
#define PCI_CLASS_SATELLITE     15   /* Satellite Communication class       */
#define PCI_CLASS_CRYPT         16   /* Encrytion/Decryption class          */
#define PCI_CLASS_SIGNAL        17   /* Signal Processing class             */

/* PCI Sub-class codes - base class 0 (no new devices should use this code) */
#define PCI_NONE_NOTVGA          0   /* All devices except VGA compatible   */
#define PCI_NONE_VGA             1   /* VGA compatible                      */

/* PCI Sub-class codes - base class 1 (mass storage controllers) */
#define PCI_MASS_SCSI            0   /* SCSI bus Controller                 */
#define PCI_MASS_IDE             1   /* IDE Controller                      */
#define PCI_MASS_FD              2   /* floppy disk Controller              */
#define PCI_MASS_IPI             3   /* IPI bus Controller                  */
#define PCI_MASS_RAID            4   /* RAID Controller                     */
#define PCI_MASS_ATA             5   /* ATA Controller                      */
#define PCI_MASS_SATA            6   /* Serial ATA                          */
#define PCI_MASS_OTHER        0x80   /* Other Mass Storage Controller       */

/* PCI Sub-class codes - base class 2 (Network controllers) */
#define PCI_NET_ENET             0   /* Ethernet Controller                 */
#define PCI_NET_TOKEN            1   /* Token Ring Controller               */
#define PCI_NET_FDDI             2   /* FDDI Controller                     */
#define PCI_NET_ATM              3   /* ATM Controller                      */
#define PCI_NET_ISDN             4   /* ISDN Controller                     */
#define PCI_NET_WFIP             5   /* WorldFip Controller                 */
#define PCI_NET_PICMG            6   /* PICMG 2.14 Multi Computing          */
#define PCI_NET_OTHER         0x80   /* Other Network Controller            */

/* PCI Sub-class codes - base class 3 (display controllers) */
#define PCI_DISPLAY_VGA          0   /* VGA device                          */
#define PCI_DISPLAY_XGA          1   /* XGA device                          */
#define PCI_DISPLAY_3D           2   /* 3D controller                       */
#define PCI_DISPLAY_OTHER     0x80   /* Other Display Device                */

/* PCI Sub-class codes - base class 4 (multi-media devices) */
#define PCI_MM_VIDEO             0   /* Video device                        */
#define PCI_MM_AUDIO             1   /* Audio device                        */
#define PCI_MM_TELEPHONY         2   /* Computer Telephony device           */
#define PCI_MM_OTHER          0x80   /* Other Multimedia Device             */

/* PCI Sub-class codes - base class 5 (memory controllers) */
#define PCI_MEM_RAM              0   /* RAM device                          */
#define PCI_MEM_FLASH            1   /* FLASH device                        */
#define PCI_MEM_OTHER         0x80   /* Other Memory Controller */

/* PCI Sub-class codes - base class 6 (Bridge devices) */
#define PCI_BRIDGE_HOST          0   /* Host/PCI Bridge                     */
#define PCI_BRIDGE_ISA           1   /* PCI/ISA Bridge                      */
#define PCI_BRIDGE_EISA          2   /* PCI/EISA Bridge                     */
#define PCI_BRIDGE_MC            3   /* PCI/MC Bridge                       */
#define PCI_BRIDGE_PCI           4   /* PCI/PCI Bridge                      */
#define PCI_BRIDGE_PCMCIA        5   /* PCI/PCMCIA Bridge                   */
#define PCI_BRIDGE_NUBUS         6   /* PCI/NUBUS Bridge                    */
#define PCI_BRIDGE_CARDBUS       7   /* PCI/CARDBUS Bridge                  */
#define PCI_BRIDGE_RACE          8   /* RACE-way Bridge                     */
#define PCI_BRIDGE_STPCI         9   /* Semi-transparent PCI/PCI Bridge     */
#define PCI_BRIDGE_IB           10   /* InfiniBand/PCI host Bridge          */
#define PCI_BRIDGE_OTHER      0x80   /* PCI/Other Bridge Device             */

/* PCI Sub-class codes - base class 7 (communication devices) */
#define PCI_COMM_GENERIC_XT      0   /* XT Compatible Serial Controller     */
#define PCI_COMM_PARALLEL        1   /* Parallel Port Controller            */
#define PCI_COMM_MSC             2   /* Multiport Serial Controller         */
#define PCI_COMM_MODEM           3   /* Modem Controller                    */
#define PCI_COMM_GPIB            4   /* GPIB Controller                     */
#define PCI_COMM_SMARTCARD       5   /* Smart Card Controller               */
#define PCI_COMM_OTHER        0x80   /* Other Communications Controller     */

/* PCI Sub-class codes - base class 8 */
#define PCI_PERIPH_PIC           0   /* Generic PIC                         */
#define PCI_PERIPH_DMA           1   /* Generic DMA Controller              */
#define PCI_PERIPH_TIMER         2   /* Generic System Timer Controller     */
#define PCI_PERIPH_RTC           3   /* Generic RTC Controller              */
#define PCI_PERIPH_HPC           4   /* Generic PCI Hot-Plug Controller     */
#define PCI_PERIPH_OTHER      0x80   /* Other System Peripheral             */

/* PCI Sub-class codes - base class 9 */
#define PCI_INPUT_KEYBOARD       0   /* Keyboard Controller                 */
#define PCI_INPUT_DIGITIZ        1   /* Digitizer (Pen)                     */
#define PCI_INPUT_MOUSE          2   /* Mouse Controller                    */
#define PCI_INPUT_SCANNER        3   /* Scanner Controller                  */
#define PCI_INPUT_GAMEPORT       4   /* Gameport Controller                 */
#define PCI_INPUT_OTHER       0x80   /* Other Input Controller              */

/* PCI Sub-class codes - base class 10 */
#define PCI_DOCK_GENERIC         0   /* Generic Docking Station             */
#define PCI_DOCK_OTHER        0x80   /* Other Type of Docking Station       */

/* PCI Sub-class codes - base class 11 */
#define PCI_PROCESSOR_386        0   /* 386                                 */
#define PCI_PROCESSOR_486        1   /* 486                                 */
#define PCI_PROCESSOR_PENT       2   /* Pentium                             */
#define PCI_PROCESSOR_ALPHA   0x10   /* Alpha                               */
#define PCI_PROCESSOR_POWERPC 0x20   /* PowerPC                             */
#define PCI_PROCESSOR_MIPS    0x30   /* MIPS                                */
#define PCI_PROCESSOR_COPROC  0x40   /* Co-processor                        */

/* PCI Sub-class codes - base class 12 (Serial Controllers) */
#define PCI_SERIAL_FIRE          0   /* FireWire (IEEE 1394)                */
#define PCI_SERIAL_ACCESS        1   /* ACCESS.bus                          */
#define PCI_SERIAL_SSA           2   /* SSA                                 */
#define PCI_SERIAL_USB           3   /* Universal Serial Bus                */
#define PCI_SERIAL_FIBRE         4   /* Fibre Channel                       */
#define PCI_SERIAL_SMBUS         5   /* System Management Bus               */
#define PCI_SERIAL_IB            6   /* InfiniBand                          */
#define PCI_SERIAL_IPMI          7   /* IPMI                                */
#define PCI_SERIAL_SERCOS        8   /* SERCOS Interface Std (IEC 61491)    */
#define PCI_SERIAL_CANBUS        9   /* CANbus                              */

/* PCI Sub-class codes - base class 13 (Wireless controllers) */
#define PCI_WIRELESS_IRDA        0   /* iRDA Compatible Controller          */
#define PCI_WIRELESS_IR          1   /* Consumer IR Controller              */
#define PCI_WIRELESS_RF         16   /* RF Controller                       */
#define PCI_WIRELESS_BLUETOOTH  17   /* Bluetooth Controller                */
#define PCI_WIRELESS_BROADBAND  18   /* Broadband Controller                */
#define PCI_WIRELESS_80211A     32   /* Ethernet 802.11a 5 GHz              */
#define PCI_WIRELESS_80211B     33   /* Ethernet 802.11b 2.4 GHz            */
#define PCI_WIRELESS_OTHER    0x80   /* Other Wireless Controllers          */

/* PCI Sub-class codes - base class 14 (Intelligent I/O controllers) */
#define PCI_INTIO_I20            1   /* I20 Arch Spec 1.0                   */

/* PCI Sub-class codes - base class 15 (Satellite Communication controllers) */
#define PCI_SATELLITE_COMM_TV    1   /* TV                                  */
#define PCI_SATELLITE_COMM_AUDIO 2   /* Audio                               */
#define PCI_SATELLITE_COMM_VOICE 3   /* Voice                               */
#define PCI_SATELLITE_COMM_DATA  4   /* DATA                                */

/* PCI Sub-class codes - base class 16 (Encryption/Decryption controllers) */
#define PCI_CRYPT_NETWORK		 0   /* Network and Computing               */
#define PCI_CRYPT_ENTERTAINMENT 16   /* Entertainment en/decrypt            */
#define PCI_CRYPT_OTHER       0x80   /* Other en/decryption ctrlrs          */

/* PCI Sub-class codes - base class 17 (Signal Processing controllers) */
#define PCI_SIGNAL_DPIO          0   /* DPIO modules                        */
#define PCI_SIGNAL_PERF_COUNTERS 1   /* Performance counters                */
#define PCI_SIGNAL_COMM_SYNC  0x10   /* Comm. synchronization plus          */
                                     /* time and freq test ctrlr            */
#define PCI_SIGNAL_MANAGEMENT 0x20   /* Management card                     */
#define PCI_SIGNAL_OTHER      0x80   /* DSP/DAP controller                  */

/* PCI Resource Descriptor */
#define PCI_RSC_DESC_NEXT        0   /* length of the following structure   */
#define PCI_RSC_DESC_FLAGS       2   /* type of resource and misc. flags    */
#define PCI_RSC_DESC_START       4   /* start-address of resource           */
#define PCI_RSC_DESC_LENGTH      8   /* length of resource                  */
#define PCI_RSC_DESC_OFFSET     12   /* offset PCI to phys. CPU Address     */
#define PCI_RSC_DESC_DMAOFFSET  16   /* offset for DMA-transfers            */
#define PCI_RSC_DESC_ERROR      20   /* internal error code                 */
#define PCI_RSC_DESC_SIZE       24
#define PCI_RSC_DESC_TOTALSIZE  (PCI_RSC_DESC_SIZE*6)

/* Flags used in Resource Descriptor */
#define FLG_IO              0x4000   /* Resource in IO range                */
#define FLG_ROM             0x2000   /* Expansion ROM */
#define FLG_LAST            0x8000   /* last resource                       */
#define FLG_8BIT            0x0100   /* 8 bit accesses allowed              */
#define FLG_16BIT           0x0200   /* 16 bit accesses allowed             */
#define FLG_32BIT           0x0400   /* 32 bit accesses allowed             */
#define FLG_ENDMASK         0x000F   /* mask for byte ordering              */   
#define ORD_MOTOROLA             0   /* Motorola (big endian)               */
#define ORD_INTEL_AS             1   /* Intel (little endian), addr.swapped */
#define ORD_INTEL_LS             2   /* Intel (little endian), lane swapped */
#define ORD_UNKNOWN             15   /* unknown (BIOS-calls allowed only)   */

/* PCI Status Descriptor */
#define PCI_DEV_DES_STATUS       0   /* Status PCI                          */
#define PCI_DEV_DES_CALLBACK     4   /* Address of Callback Routine         */
#define PCI_DEV_DES_HANDLER      8   /* Address of Interrupt Handlers       */
#define PCI_DEV_DES_PARAMETER   12   /* Parameter for Interrupt Handler     */
#define PCI_DEV_DES_START_IRQ   16   /* Routine Start IRQ                   */
#define PCI_DEV_DES_SIZE        20 

/* PCI Address conversion */
#define PCI_CONV_ADDR_ADDR       0   /* calculated address (CPU<->PCI)      */
#define PCI_CONV_ADDR_LEN        4   /* length of memory range              */

/* PCI cookie */
#define PCI_COOKIE_SUBCOOKIE     0   /* Sub-Cookie for PCI_CONF             */
#define PCI_COOKIE_VERSION       4   /* version PCI BIOS                    */
#define PCI_COOKIE_ROUTINE       8   /* offset PCI BIOS routines            */
#define PCI_COOKIE_MAX_ROUTINES 45   /* maximum of routines                 */
#define PCI_COOKIE_SIZE          ((4*PCI_COOKIE_MAX_ROUTINES)+PCI_COOKIE_ROUTINE)
#define PCI_RSC_HANDLESTOTALSIZE (PCI_RSC_DESC_TOTALSIZE*PCI_MAX_HANDLE*PCI_MAX_FUNCTION)
#define PCI_DEV_HANDLESTOTALSIZE (PCI_DEV_DES_SIZE*PCI_MAX_HANDLE*PCI_MAX_FUNCTION)
#define PCI_INT_HANDLESTOTALSIZE (PCI_MAX_HANDLE*PCI_MAX_FUNCTION)
#define PCI_COOKIE_TOTALSIZE     (PCI_COOKIE_SIZE+PCI_RSC_HANDLESTOTALSIZE+PCI_DEV_HANDLESTOTALSIZE+PCI_INT_HANDLESTOTALSIZE)

/* Error codes */
#define PCI_SUCCESSFUL           0   /* everything's fine         */
#define PCI_FUNC_NOT_SUPPORTED  -2   /* function not supported    */
#define PCI_BAD_VENDOR_ID       -3   /* wrong Vendor ID           */
#define PCI_DEVICE_NOT_FOUND    -4   /* PCI-Device not found      */
#define PCI_BAD_REGISTER_NUMBER -5   /* wrong register number     */
#define PCI_SET_FAILED          -6   /* reserved for later use    */
#define PCI_BUFFER_TOO_SMALL    -7   /* reserved for later use    */
#define PCI_GENERAL_ERROR       -8   /* general BIOS error code   */
#define PCI_BAD_HANDLE          -9   /* wrong/unknown PCI-handle  */
/* Internal error codes */
#define PCI_NO_MORE_IO_SPACE      -100 /* no more IO-space available           */
#define PCI_NO_MORE_MEM_SPACE     -101 /* no more MEM-space                    */
#define PCI_NO_MORE_MEM_BELOW_1MB -102 /* no more memory space below 1 MB      */
#define PCI_NEED_MORE_THAN_4GB    -103 /* device requests more than 4GB memory */
#define PCI_UNKNOW_MEMORY_TYPE    -104 /* device requests unknown memory type  */
#define PCI_PARITY_ERROR          -105 /* parity error                         */

#endif /* _PCI_BIOS_H_ */
