#ifndef _CONFIG_H_
#define _CONFIG_H_

/* DEBUG */
#define DEBUG

/* DBUG */
#define DBUG

/* PCI XBIOS */
#undef PCI_XBIOS              /* faster by cookie */

/* NETWORK */
#ifdef COLDFIRE
#define NETWORK
#define ETHERNET_PORT 0       /* FEC channel */
#undef TEST_NETWORK
#undef DEBUG_PRINT
#define LWIP
#define WEB_LIGHT
#undef FTP_SERVER
#define ERRNO
#define MCD_PROGQUERY
#undef MCD_DEBUG

#ifdef MCF5445X               /* target untested */
#ifndef LWIP
#undef NETWORK                /* to do */
#endif /* LWIP */
#endif /* MCF5445X */

/* XBIOS */
#define TOS_ATARI_LOGO /* defined for use TOS4.04 logo */

/* BDOS */
#define NEWCODE
#endif /* COLDFIRE */

/* fVDI */
#define FVDI_STRUCT_2006

/* NVDI */
#define PATCH_NVDI

/* VDI */
#undef TOS_TABLES /* defined for use TOS4.04 index tables */
    
/* X86 emulator */
#undef DEBUG_X86EMU
#undef DEBUG_X86EMU_PCI
#define __BIG_ENDIAN__
#define NO_LONG_LONG

/* Radeon */
#define DEFAULT_MONITOR_LAYOUT ""
#define ATI_LOGO
#define CONFIG_FB_RADEON_I2C
#define CONFIG_FB_MODE_HELPERS
#undef RADEON_TILING /* normally faster but tile 16 x 16 is not compatible with accel.c read_pixel, blit/expand_area and writes on screen frame buffer */
#ifndef COLDFIRE
#define RADEON_RENDER
#endif
#undef RADEON_THEATRE /* unfinished */
#define RADEON_DIRECT_ACCESS /* MMIO access faster but don't check endian - little -> big conversion !!! */

/* Radeon VIDIX */
#undef VIDIX_FILTER
#undef VIDIX_ENABLE_BM /* unfinished */

/* RTC M5485EVB */
#undef USE_RTC

/* LynxEM M5485EVB */
#ifdef COLDFIRE
#ifndef MCF5445X
#ifndef MCF547X
#undef CONFIG_VIDEO_SMI_LYNXEM
#endif
#endif
#endif /* COLDFIRE */

/* XBIOS Setscreen */
#define MAX_WIDTH_EMU_MONO 1024
#define MAX_HEIGHT_EMU_MONO 768

/* AC97 */
#define SOUND_AC97

/* USB */
#undef USB_DEVICE /* Coldfire USB device */
#define USB_BUFFER_SIZE 0x10000
#define CONFIG_USB_OHCI /* PCI USB 1.1 */
#define CONFIG_USB_EHCI /* PCI USB 2.0 */
#undef CONFIG_EHCI_DCACHE
#define CONFIG_SYS_OHCI_SWAP_REG_ACCESS
#define CONFIG_SYS_USB_OHCI_MAX_ROOT_PORTS 15
#define CONFIG_SYS_USB_EHCI_MAX_ROOT_PORTS 15
#if defined(COLDFIRE) && !defined(MCF547X)
#undef CONFIG_USB_INTERRUPT_POLLING
#else
#define CONFIG_USB_INTERRUPT_POLLING
#endif /* COLDFIRE */
#undef CONFIG_LEGACY_USB_INIT_SEQ
#define CONFIG_USB_KEYBOARD
#define CONFIG_USB_MOUSE
#define CONFIG_USB_STORAGE
#ifdef COLDFIRE
#define CONFIG_USB_MEM_NO_CACHE
#endif /* COLDFIRE */

#endif /* _CONFIG_H_ */
