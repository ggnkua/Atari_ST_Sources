/* ------------------------ System includes ------------------------------- */
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>

/* ------------------------ Platform includes ----------------------------- */
#include "config.h"
#include "net.h"
#ifdef MCF5445X
#include "mcf5445x.h"
#define MCF_UART_USR_RXRDY UART_USR_RXRDY
#define MCF_UART_USR_TXRDY UART_USR_TXRDY
#else
#include "mcf548x.h"
#endif
#include "get.h"
#include "m68k_disasm.h"
#include "../../include/ramcf68k.h"
#include "../../include/vars.h"
#ifndef MCF5445X
#ifdef SOUND_AC97
#include "../ac97/mcf548x_ac97.h"
#endif
#ifdef MCF547X
#define AC97_DEVICE 2 /* FIREBEE */
#else /* MCF548X */
#define AC97_DEVICE 3 /* M5484LITE */
#endif /* MCF547X */
#endif

/* ------------------------ FreeRTOS includes ----------------------------- */
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
#include "../freertos/semphr.h"

/* ------------------------ lwIP includes --------------------------------- */
#include "api.h"
#include "tcpip.h"
#include "memp.h"
#include "stats.h"
#include "loopif.h"
#include "etharp.h"
#include "resolv.h"
#include "err.h"
#include "sockets.h"
#include "netdb.h"
#include "tftp.h"
#include "web.h"
#include "usb.h"
#undef int8
#undef uint8
#undef int16
#undef uint16
#undef int32
#undef uint32
#include "transprt.h"

/* ------------------------ BDOS includes ----------------------------------*/
/* cannot use TOS trap out of CF68KLIB !!! */
#include "../bdos/bdos.h"

#ifdef NETWORK
#ifdef LWIP

/* ------------------------ Defines --------------------------------------- */
#undef KILL_TOS_ON_FAULT /* for debug */

/* Priorities for the demo application tasks. */
#define TOS_TASK_PRIORITY           ( 5 )
#define RTC_TASK_PRIORITY           ( 6 )
#define VBL_TASK_PRIORITY           ( 25 )
#define ROOT_TASK_PRIORITY          ( 10 )
#define WEB_TASK_PRIORITY           ( 10 )
#define FTP_TASK_PRIORITY           ( 10 )
#define TFTP_TASK_PRIORITY          ( 10 )
#define TELNET_TASK_PRIORITY        ( 15 )
#define DEBUG_TASK_PRIORITY         ( 20 )
#define STACK_DEFAULT               ( 4096 )

#define FTP_USERNAME "coldfire"
#define FTP_PASSWORD "atari"

#define SIZE_8      (8)
#define SIZE_16     (16)
#define SIZE_32     (32)
#define SIZE_64     (64)
#define ILLEGAL     (0x4AFC)
#define DEFAULT_MD_LINES    (8)
#define UIF_MAX_ARGS        (10)
#define UIF_MAX_LINE        (72)
#define UIF_MAX_BRKPTS      (16)
#define UIF_CMDTAB_SIZE     (sizeof(UIF_CMDTAB)/sizeof(UIF_CMD))
#define UIF_CMD_FLAG_REPEAT (0x0001)
#define UIF_CMD_FLAG_HIDDEN (0x0002)

#define MAX_HISTORY (5)
#define CTRL_C  0x03
#define CTRL_D  0x04      /* command line next */
#define CTRL_U  0x15      /* command line previous */
#define CTRL_R  0x12      /* last command repeat */

/* ------------------------ PCI ------------------------------------------- */
typedef struct
{
  long ident;
  union
  {
    long l;
    short i[2];
    char c[4];
  } v;
} COOKIE;

#ifdef MCF547X /* for start Emutos and recreate PCI cookie */ 
#ifndef PCI_COOKIE_TOTALSIZE /* #include ../../include/pci_bios.h create problems */
#define PCI_MAX_HANDLE           (7+1) /* Firebee specific ! */
#define PCI_MAX_FUNCTION         4  /* 4 functions per PCI slot */
#define PCI_DEV_DES_SIZE        20 
#define PCI_RSC_DESC_SIZE       24
#define PCI_RSC_DESC_TOTALSIZE  (PCI_RSC_DESC_SIZE*6)
#define PCI_COOKIE_ROUTINE       8   /* offset PCI BIOS routines            */
#define PCI_COOKIE_MAX_ROUTINES 45   /* maximum of routines                 */
#define PCI_COOKIE_SIZE          ((4*PCI_COOKIE_MAX_ROUTINES)+PCI_COOKIE_ROUTINE)
#define PCI_RSC_HANDLESTOTALSIZE (PCI_RSC_DESC_TOTALSIZE*PCI_MAX_HANDLE*PCI_MAX_FUNCTION)
#define PCI_DEV_HANDLESTOTALSIZE (PCI_DEV_DES_SIZE*PCI_MAX_HANDLE*PCI_MAX_FUNCTION)
#define PCI_INT_HANDLESTOTALSIZE (PCI_MAX_HANDLE*PCI_MAX_FUNCTION)
#define PCI_COOKIE_TOTALSIZE     (PCI_COOKIE_SIZE+PCI_RSC_HANDLESTOTALSIZE+PCI_DEV_HANDLESTOTALSIZE+PCI_INT_HANDLESTOTALSIZE)
#endif
#endif

/* ------------------------ TFTP ------------------------------------------ */
#define TimeOut       2   /* seconds */
#define NumberTimeOut 3   /* retries */
#define PortTFTP      69
#define TFTP_READ     0
#define TFTP_WRITE    1

/* Trivial File Transfer Protocol (IEN-133) */
#define SEGSIZE  512      /* data segment size */
#define PKTSIZE SEGSIZE+4 /* full packet size */

/* Packet types. */
#define RRQ   1           /* read request */
#define WRQ   2           /* write request */
#define DATA  3           /* data packet */
#define ACK   4           /* acknowledgement */
#define ERROR 5           /* error code */

struct tftphdr
{
  short th_opcode;        /* packet type */
  union {
    unsigned short  tu_block; /* block # */
    short tu_code;        /* error code */
    char tu_stuff[1];     /* request packet stuff */
  } th_u;
  char  th_data[1];       /* data or error string */
} __attribute__((packed));

#define th_block th_u.tu_block
#define th_code  th_u.tu_code
#define th_stuff th_u.tu_stuff
#define th_msg   th_data

/* ------------------------ Telnet ---------------------------------------- */
#define PortTELNET 23

/* States */
#define STATE_NORMAL 0
#define STATE_IAC    1
#define STATE_OPT    2
#define STATE_SB     3
#define STATE_OPTDAT 4
#define STATE_SE     5

/* Special telnet characters */
#define TELNET_SE    240   // End of subnegotiation parameters
#define TELNET_NOP   241   // No operation
#define TELNET_MARK  242   // Data mark
#define TELNET_BRK   243   // Break
#define TELNET_IP    244   // Interrupt process
#define TELNET_AO    245   // Abort output
#define TELNET_AYT   246   // Are you there
#define TELNET_EC    247   // Erase character
#define TELNET_EL    248   // Erase line
#define TELNET_GA    249   // Go ahead
#define TELNET_SB    250   // Start of subnegotiation parameters
#define TELNET_WILL  251   // Will option code
#define TELNET_WONT  252   // Won't option code
#define TELNET_DO    253   // Do option code
#define TELNET_DONT  254   // Don't option code
#define TELNET_IAC   255   // Interpret as command

/* Telnet options */
#define TELOPT_TRANSMIT_BINARY      0  // Binary Transmission (RFC856)
#define TELOPT_ECHO                 1  // Echo (RFC857)
#define TELOPT_SUPPRESS_GO_AHEAD    3  // Suppress Go Ahead (RFC858)
#define TELOPT_STATUS               5  // Status (RFC859)
#define TELOPT_TIMING_MARK          6  // Timing Mark (RFC860)
#define TELOPT_NAOCRD              10  // Output Carriage-Return Disposition (RFC652)
#define TELOPT_NAOHTS              11  // Output Horizontal Tab Stops (RFC653)
#define TELOPT_NAOHTD              12  // Output Horizontal Tab Stop Disposition (RFC654)
#define TELOPT_NAOFFD              13  // Output Formfeed Disposition (RFC655)
#define TELOPT_NAOVTS              14  // Output Vertical Tabstops (RFC656)
#define TELOPT_NAOVTD              15  // Output Vertical Tab Disposition (RFC657)
#define TELOPT_NAOLFD              16  // Output Linefeed Disposition (RFC658)
#define TELOPT_EXTEND_ASCII        17  // Extended ASCII (RFC698)
#define TELOPT_TERMINAL_TYPE       24  // Terminal Type (RFC1091)
#define TELOPT_NAWS                31  // Negotiate About Window Size (RFC1073)
#define TELOPT_TERMINAL_SPEED      32  // Terminal Speed (RFC1079)
#define TELOPT_TOGGLE_FLOW_CONTROL 33  // Remote Flow Control (RFC1372)
#define TELOPT_LINEMODE            34  // Linemode (RFC1184)
#define TELOPT_AUTHENTICATION      37  // Authentication (RFC1416)

#define TERM_UNKNOWN 0
#define TERM_CONSOLE 1
#define TERM_VT100   2

#define TELNET_BUF_SIZE 4096

struct term
{
  int type;
  int cols;
  int lines;
};

struct telbuf
{
  unsigned char data[TELNET_BUF_SIZE];
  unsigned char *start;
  unsigned char *end;
};

struct termstate
{
  int sock;
  int state;
  int code;
  unsigned char optdata[256];
  int optlen;
  struct term term;
  struct telbuf bi;
  struct telbuf bo;
};

/* ------------------------ Variables ------------------------------------- */
extern unsigned char __SDRAM_SIZE[];
extern unsigned long size_ram_disk, ext_write_protect_ram_disk;
extern xTaskHandle pxCurrentTCB, tid_TOS;
xTaskHandle tid_TELNET, tid_DEBUG, tid_HTTPd;

#ifdef MCF547X
xTaskHandle tid_ETOS;
unsigned long pseudo_dma_vec;
extern short boot_os;
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
void *pci_data;
#endif
#endif /* MCF547X */

#ifdef CONFIG_USB_OHCI
extern char ohci_inited;
#endif
#ifdef CONFIG_USB_EHCI
// extern char ehci_inited;
#endif

#ifdef MCF5445X
extern unsigned long save_imrl0, save_imrl0_tos, save_imrh0, save_imrh0_tos, save_imrh1, save_imrh1_tos;
#else
extern unsigned long save_imrl, save_imrl_tos, save_imrh, save_imrh_tos;
#endif
static int restart_debug, get_serial_vector, get_ikbd_vector, tos_suspend;
struct termstate *ts;

static const char PROMPT[] = "> ";
static const char SYNTAX[] = "Error: Invalid syntax for: %s\r\n";
static const char PAUSEMSG[] = "Press <ENTER> to continue.";
static const char HELPMSG[] = "Enter 'help' for help.\r\n";
static const char INVCMD[] = "Error: No such command: %s\r\n";
static const char INVARG[] = "Error: Invalid argument: %s\r\n";
static const char INVALUE[] = "Error: Invalid value: %s\r\n";
static const char HELPFORMAT[] = "%8s %-25s %s %s\r\n";

static char cmdline1[UIF_MAX_LINE];
static char cmdline2[UIF_MAX_LINE];

static int BASE;
static unsigned long md_last_address;
static int md_last_size;
static unsigned long disasm_last_address;

typedef char HISTENT[UIF_MAX_LINE];
static HISTENT history[MAX_HISTORY];
extern int errno;
int lwip_ok;
void *start_run;

int errno;
xSemaphoreHandle xSemaphoreBDOS;

typedef struct socket_cookie
{
  long version; /* 0x0101 for example */
  long magic; /* 'SOCK' */
  int (*socket)(int domain, int type, int protocol);
  int (*bind)(int s, struct sockaddr *name, socklen_t namelen);
  int (*listen)(int s, int backlog);
  int (*accept)(int s, struct sockaddr *addr, socklen_t *addrlen);
  int (*connect)(int s, struct sockaddr *name, socklen_t namelen);
  int (*write)(int s, void *dataptr, int size);
  int (*send)(int s, void *dataptr, int size, unsigned int flags);
  int (*sendto)(int s, void *dataptr, int size, unsigned int flags, struct sockaddr *to, socklen_t tolen);
  int (*read)(int s, void *mem, int len);
  int (*recv)(int s, void *mem, int len, unsigned int flags);
  int (*recvfrom)(int s, void *mem, int len, unsigned int flags, struct sockaddr *from, socklen_t *fromlen);
  int (*shutdown)(int s, int how);
  int (*close)(int s);
  int (*getsockname)(int s, struct sockaddr *name, socklen_t *namelen);
  int (*getpeername)(int s, struct sockaddr *name, socklen_t *namelen);
  int (*getsockopt)(int s, int level, int optname, void *optval, socklen_t *optlen);
  int (*setsockopt)(int s, int level, int optname, const void *optval, socklen_t optlen);
  int (*select)(int maxfdp1, fd_set *readset, fd_set *writeset, fd_set *exceptset, struct timeval *timeout);
  int (*ioctlsocket)(int s, long cmd, void *argp);
  struct hostent *(*gethostbyname)(const char *name);
  int (*geterrno)(void);
} SOCKET_COOKIE;

/*
 * The command table entry data structure, and the prototype for the
 * command table.
 */
typedef const struct
{
    char *  cmd;                    /* command name user types, ie. GO  */
    int     unique;                 /* num chars to uniquely match      */
    int     min_args;               /* min num of args command accepts  */
    int     max_args;               /* max num of args command accepts  */
    int     flags;                  /* command flags (repeat, hidden)   */
    void    (*func)(int, char **);  /* actual function to call          */
    char *  description;            /* brief description of command     */
    char *  syntax;                 /* syntax of command                */
} UIF_CMD;

typedef struct
{
    int dest;
    void (*func)(char);
    char *loc;
} PRINTK_INFO;

#define DEST_CONSOLE    (1)
#define DEST_STRING     (2)

/* ------------------------ Prototypes ------------------------------------ */
static void uif_cmd_help(int argc, char **argv);
static int make_argv(char *cmdline, char *argv[]);
extern err_t mcf_fec0_init(struct netif *netif);
extern err_t mcf_fec1_init(struct netif *netif);
extern int ftpd_start(char *username, char *password);
extern COOKIE *get_cookie(long id);
extern int add_cookie(COOKIE *cook);
extern int printk(PRINTK_INFO *info, const char *fmt, va_list ap);
extern int printD(const char *fmt, ...);
extern int sprintD(char *s, const char *fmt, ...);
extern void flush_caches(void);
extern void enable_caches(void);
extern void disable_caches(void);
extern char *disassemble_pc(unsigned long pc);
extern void uif_cmd_usb(int argc, char **argv);
extern void usb_enable_interrupt(void);

/* ------------------------ Implementation -------------------------------- */

// static 
int auxistat(void)
{
  register int ret __asm__("d0");
#ifdef MCF547X
  asm volatile (
        " move.l D2,-(SP)\n\t"
        " lea 0x165A,A0\n\t"        /* iorec RS232 */
        " moveq #-1,D0\n\t"         /* OK */
        " moveq #0,D1\n\t"
        " moveq #0,D2\n\t"
        " move.w 8(A0),D1\n\t"      /* tail index */
        " move.w 6(A0),D2\n\t"      /* head index */
        " cmp.l D2,D1\n\t"          /* buffer empty */
        " bne.s .ais1\n\t"          /* no */
        " moveq #0,D0\n\t"
        ".ais1:\n\t"
        " move.l (SP)+,D2" : "=d" (ret) :  : "d1", "d2", "a0", "memory", "cc" );
#else /* MCF548X */
  asm volatile (
        " move.l D2,-(SP)\n\t"
        " lea 0xF72,A0\n\t"         /* iorec RS232 */
        " moveq #-1,D0\n\t"         /* OK */
        " moveq #0,D1\n\t"
        " moveq #0,D2\n\t"
        " move.w 8(A0),D1\n\t"      /* tail index */
        " move.w 6(A0),D2\n\t"      /* head index */
        " cmp.l D2,D1\n\t"          /* buffer empty */
        " bne.s .ais1\n\t"          /* no */
        " moveq #0,D0\n\t"
        ".ais1:\n\t"
        " move.l (SP)+,D2" : "=d" (ret) :  : "d1", "d2", "a0", "memory", "cc" );
#endif /* MCF548X */
  return(ret);
}

static int rs232get(void)
{
  register int ret __asm__("d0");
#ifdef MCF547X
  asm volatile (
        " move.l D2,-(SP)\n\t"
        " lea 0x165A,A0\n\t"         /* iorec RS232 */
        " move.w SR,D2\n\t"
        " move.l D2,-(SP)\n\t"
        " or.l #0x700,D2\n\t"        /* mask interrupts */
        " move.w D2,SR\n\t"
        " moveq #0,D1\n\t"
        " move.w 6(A0),D1\n\t"       /* head index */
        " moveq #0,D2\n\t"
        " move.w 8(A0),D2\n\t"       /* tail index */
        " cmp.l D2,D1\n\t"
        " beq.s .rg1\n\t"            /* bufer empty */
        " addq.l #1,D1\n\t"
        " moveq #0,D2\n\t"
        " move.w 4(A0),D2\n\t"       /* size */
        " cmp.l D2,D1\n\t"
        " bcs.s .rg2\n\t"
        " moveq #0,D1\n\t"
        ".rg2:\n\t"
        " move.l (A0),A1\n\t"        /* buffer */
        " moveq #0,D0\n\t"
        " move.b (A1,D1.l),D0\n\t"   /* get data */
        " move.w D1,6(A0)\n\t"       /* head index */
        " bra.s .rg3\n\t"
        ".rg1:\n\t"
        " moveq #-1,D0\n\t"          /* no receive */
        ".rg3:\n\t"
        " move.l (SP)+,D2\n\t"
        " move.w D2,SR\n\t"
        " move.l (SP)+,D2" : "=d" (ret) :  : "d1", "d2", "a0", "a1", "memory", "cc" );
#else /* MCF548X */
  asm volatile (
        " move.l D2,-(SP)\n\t"
        " lea 0xF72,A0\n\t"          /* iorec RS232 */
        " move.w SR,D2\n\t"
        " move.l D2,-(SP)\n\t"
        " or.l #0x700,D2\n\t"        /* mask interrupts */
        " move.w D2,SR\n\t"
        " moveq #0,D1\n\t"
        " move.w 6(A0),D1\n\t"       /* head index */
        " moveq #0,D2\n\t"
        " move.w 8(A0),D2\n\t"       /* tail index */
        " cmp.l D2,D1\n\t"
        " beq.s .rg1\n\t"            /* bufer empty */
        " addq.l #1,D1\n\t"
        " moveq #0,D2\n\t"
        " move.w 4(A0),D2\n\t"       /* size */
        " cmp.l D2,D1\n\t"
        " bcs.s .rg2\n\t"
        " moveq #0,D1\n\t"
        ".rg2:\n\t"
        " move.l (A0),A1\n\t"        /* buffer */
        " moveq #0,D0\n\t"
        " move.b (A1,D1.l),D0\n\t"   /* get data */
        " move.w D1,6(A0)\n\t"       /* head index */
        " bra.s .rg3\n\t"
        ".rg1:\n\t"
        " moveq #-1,D0\n\t"          /* no receive */
        ".rg3:\n\t"
        " move.l (SP)+,D2\n\t"
        " move.w D2,SR\n\t"
        " move.l (SP)+,D2" : "=d" (ret) :  : "d1", "d2", "a0", "a1", "memory", "cc" );
#endif /* MCF547X */
  return(ret);
}

static void install_inters_cf68klib(void)
{
  int tos_run = (int)(*(unsigned short *)_timer_ms);
  if(tos_run && !get_serial_vector)
  {
    int level = vPortSetIPL(portIPL_MAX);
#ifdef MCF5445X
    unsigned long *v1 = (unsigned long *)((64+INT0_LO_UART0+OFFSET_INT_CF68KLIB)*4);
    unsigned long *v2 = (unsigned long *)((64+INT0_LO_UART0)*4 + coldfire_vector_base);
#else
    unsigned long *v1 = (unsigned long *)((64+35+OFFSET_INT_CF68KLIB)*4);
    unsigned long *v2 = (unsigned long *)((64+35)*4 + coldfire_vector_base);
#endif
    if(*v1 != *v2)
    {
      *v2 = *v1;
#ifdef MCF5445X
      MCF_INTC_IMRL0 &= ~INTC_IMRL_INT_MASK26;    /* serial */
      save_imrl0 = MCF_INTC_IMRL0;
#else
      MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK35; /* serial */
      save_imrh = MCF_INTC_IMRH;
#endif
    }
    get_serial_vector = 1;
    vPortSetIPL(level);
  }
  if(tos_run && !get_ikbd_vector)
  {
    int level = vPortSetIPL(portIPL_MAX);
#ifdef MCF5445X
    unsigned long *v1 = (unsigned long *)((64+INT0_LO_UART2+OFFSET_INT_CF68KLIB)*4); /* UART 2 */
    unsigned long *v2 = (unsigned long *)((64+INT0_LO_UART2)*4 + coldfire_vector_base);
#else
    unsigned long *v1b = (unsigned long *)((64+55+OFFSET_INT_CF68KLIB)*4); /* ERROR CAN1 */
    unsigned long *v1a = (unsigned long *)((64+56+OFFSET_INT_CF68KLIB)*4); /* BUSOFF CAN1 */
    unsigned long *v1  = (unsigned long *)((64+57+OFFSET_INT_CF68KLIB)*4); /* MBOR CAN1 */
    unsigned long *v2b = (unsigned long *)((64+55)*4 + coldfire_vector_base);
    unsigned long *v2a = (unsigned long *)((64+56)*4 + coldfire_vector_base);
    unsigned long *v2  = (unsigned long *)((64+57)*4 + coldfire_vector_base);
#endif
    if(*v1 != *v2)
    {
      *v2 = *v1;
#ifdef MCF5445X
      MCF_INTC_IMRL0 &= ~INTC_IMRL_INT_MASK28; /* UART 2 */
      save_imrl0 = MCF_INTC_IMRL0;
#else
      *v2a = *v1a;
      *v2b = *v1b;
      MCF_INTC_IMRH &= ~(MCF_INTC_IMRH_INT_MASK55 | MCF_INTC_IMRH_INT_MASK56 | MCF_INTC_IMRH_INT_MASK57); /* CAN (IKBD) */
      save_imrh = MCF_INTC_IMRH;
#endif
    }
    get_ikbd_vector = 1;
    vPortSetIPL(level);
  }
}

static void deinstall_inters_cf68klib(void)
{
  int tos_run = (int)(*(unsigned short *)_timer_ms);
  if(tos_run && get_serial_vector)
  {
    int level = vPortSetIPL(portIPL_MAX);
    unsigned long *v1 = (unsigned long *)(64*4 + coldfire_vector_base); /* default CF68KLIB vector normally unchanged */
#ifdef MCF5445X
    unsigned long *v2 = (unsigned long *)((64+INT0_LO_UART0)*4 + coldfire_vector_base);
#else
    unsigned long *v2 = (unsigned long *)((64+35)*4 + coldfire_vector_base);
#endif
    if(*v1 != *v2)
    {
      *v2 = *v1;
#ifdef MCF5445X
      MCF_INTC_IMRL0 |= INTC_IMRL_INT_MASK26;    /* serial */
      save_imrl0 = MCF_INTC_IMRL0;
#else
      MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK35; /* serial */
      save_imrh = MCF_INTC_IMRH;
#endif
    }
    get_serial_vector = 0;
    vPortSetIPL(level);
  }
  if(tos_run && get_ikbd_vector)
  {
    int level = vPortSetIPL(portIPL_MAX);
    unsigned long *v1 = (unsigned long *)(64*4 + coldfire_vector_base); /* default CF68KLIB vector normally unchanged */
#ifdef MCF5445X
    unsigned long *v2 = (unsigned long *)((64+INT0_LO_UART2)*4 + coldfire_vector_base);
#else
    unsigned long *v2b = (unsigned long *)((64+55)*4 + coldfire_vector_base);
    unsigned long *v2a = (unsigned long *)((64+56)*4 + coldfire_vector_base);
    unsigned long *v2  = (unsigned long *)((64+57)*4 + coldfire_vector_base);
#endif
    if(*v1 != *v2)
    {
      *v2 = *v1;
#ifdef MCF5445X
      MCF_INTC_IMRL0 |= INTC_IMRL_INT_MASK28; /* UART 2 */
      save_imrl0 = MCF_INTC_IMRL0;
#else
      *v2a = *v1;
      *v2b = *v1;
      MCF_INTC_IMRH |= (MCF_INTC_IMRH_INT_MASK55 | MCF_INTC_IMRH_INT_MASK56 | MCF_INTC_IMRH_INT_MASK57); /* CAN (IKBD) */
      save_imrh = MCF_INTC_IMRH;
#endif
    }
    get_ikbd_vector = 0;
    vPortSetIPL(level);
  }
}

static int conin_debug(void)
{
  int tos_run;
  while(*(unsigned char *)(serial_mouse))
    vTaskDelay(1);
#ifdef MCF547X
  if((tos_suspend && !get_serial_vector) || (tid_ETOS != NULL))
#else
  if(tos_suspend && !get_serial_vector)
#endif
    tos_run = 0;
  else
    tos_run = (int)(*(unsigned short *)_timer_ms);
  /* if TOS runs we can use TOS interrupts routines also out of the CF68KLIB */
  while((!tos_run && !(MCF_UART_USR(0) & MCF_UART_USR_RXRDY))
   || (tos_run && !auxistat()))
  {
    vTaskDelay(1);
#ifdef MCF547X
    if((tos_suspend && !get_serial_vector) || (tid_ETOS != NULL))
#else
    if(tos_suspend && !get_serial_vector)
#endif
      tos_run = 0;
    else
      tos_run = (int)(*(unsigned short *)_timer_ms);
//    install_inters_cf68klib();
  }
  return(tos_run ? rs232get() & 0xFF : (int)MCF_UART_URB(0) & 0xFF);
}

void conout_debug(int c)
{
  if(!*(unsigned char *)(serial_mouse))
  {
#ifdef MCF547X
    if((pxCurrentTCB != tid_TOS) && (pxCurrentTCB != tid_ETOS))
#else
    if(pxCurrentTCB != tid_TOS)
#endif
    {
      int level = vPortSetIPL(portIPL_MAX);
      vPortSetIPL(level);
      while(!(MCF_UART_USR(0) & MCF_UART_USR_TXRDY))
      {
        if(!level)
          vTaskDelay(1);    
      }
      MCF_UART_UTB(0) = (char)c; // send the character
    }
    else
    {
      while(!(MCF_UART_USR(0) & MCF_UART_USR_TXRDY));
      MCF_UART_UTB(0) = (char)c; // send the character
    }
  }
}

void conws_debug(char *buf)
{
  int i = 0;
  while(buf[i])
    conout_debug(buf[i++]);
}

#ifdef DBUG

static int telnet_write_socket(char *response, int size, int flush)
{
  int i, n = 0, len;
  fd_set data_write;
  struct timeval tv;
  char *ptr = response;
  do
  {
    len = TELNET_BUF_SIZE - (int)(ts->bo.start - ts->bo.data);
    if(size < len)
      len = size;
    if(len >= 0)
    {
      memcpy(ts->bo.start, response, len);
      size -= len;
      ts->bo.start += len;
      response += len;  
    }
    if(((int)(ts->bo.start - ts->bo.data) >= TELNET_BUF_SIZE)
     || flush)
    {
      len = n = 0;
      ptr = (char *)ts->bo.data;
      do
      {
        FD_ZERO(&data_write);
        FD_SET(ts->sock, &data_write);
        tv.tv_sec = 1;
        tv.tv_usec = 0;
        i = select(FD_SETSIZE, NULL, &data_write, NULL, &tv);
        if((i > 0) && (FD_ISSET(ts->sock, &data_write) != 0))
        {
          n = send(ts->sock, ptr, (int)(ts->bo.start - ts->bo.data) - len, 0);
          if(n >= 0)
          {
            ptr += n;
            len += n;
          }
        }
      }
      while((n >= 0) && (len < (int)(ts->bo.start - ts->bo.data)) && (i > 0));
      ts->bo.start = ts->bo.data;
    }
  }
  while(size > 0);
  return(n < 0 ? n : len);
}

void board_printf(const char *fmt, ...)
{
  va_list ap;
  PRINTK_INFO info;
  info.dest = DEST_STRING;
  va_start(ap, fmt);
  if(pxCurrentTCB == tid_TOS)
  {
    static char buf_tos[TELNET_BUF_SIZE]; // minimize stack usage
    info.loc = buf_tos;
    printk(&info, fmt, ap);
    *info.loc = '\0';
    va_end(ap);
    conws_debug(buf_tos);
  }
  else
  {
    char *buf = (char *)pvPortMalloc(TELNET_BUF_SIZE);
    if(buf != NULL)
    {
      info.loc = buf;
      printk(&info, fmt, ap);
      *info.loc = '\0';
      va_end(ap);
      if(pxCurrentTCB == tid_TELNET)
      {
        if(ts->sock > 0)
          telnet_write_socket(buf, strlen(buf), 1);
      }
      else
        conws_debug(buf);
      vPortFree(buf);    
    }
  }
}

static char board_getchar(void)
{
  if(pxCurrentTCB == tid_TELNET)
    return(CTRL_C); 
  return((char)conin_debug());
}

void board_putchar(char c)
{
  if(pxCurrentTCB == tid_TELNET)
  {
    if(ts->sock > 0)
      telnet_write_socket(&c, 1, (c == '\n') ? 1 : 0);  
  }
  else
    conout_debug(c);
}

static void board_putchar_flush(void)
{
}

static void history_init(void)
{
  int index;
  for(index = 0; index < MAX_HISTORY; ++index)
    history[index][0] = '\0';
}

static int history_down(int *curr_hist, char *line)
{
  *curr_hist -= 1;
  if(*curr_hist < 0)
  {
    *curr_hist = -1;
    line[0] = '\0';
    return 0;
  }
  strcpy(line, history[*curr_hist]);
  board_printf("%s",line);
  board_putchar_flush();
  return strlen(line);
}

static int history_up(int *curr_hist, char *line)
{
  if(*curr_hist == -1)
    *curr_hist = 0;
  else
  {
    *curr_hist += 1;
    if(*curr_hist >= MAX_HISTORY)
      *curr_hist = (MAX_HISTORY-1);
  }
  strcpy(line, history[*curr_hist]);
  board_printf("%s",line);
  board_putchar_flush();
  return strlen(line);
}

static int history_repeat(char *line)
{
  strcpy(line, history[0]);
  board_printf("%s",line);
  board_putchar_flush();
  return strlen(line);
}

static void history_add(char *line)
{
  /* This routine is called after use has entered a line */
  int index;
  /* Move all history line buffers down */
  for(index = (MAX_HISTORY-1); index > 0; --index)
    strcpy(history[index],history[index-1]);
  /* Copy in the new one */
  strcpy(history[0], line);
}

static char *get_history_line(char *userline)
{
  char line[UIF_MAX_LINE];
  int pos, ch, i, curr_hist, repeat;
  curr_hist = -1; /* invalid */
  repeat = FALSE;
  pos = 0;
  ch = (int)board_getchar();
  while((ch != 0x0D /* CR */) && (ch != 0x0A /* LF/NL */) && (pos < UIF_MAX_LINE))
  {
    switch(ch)
    {
      case 0x08:      /* Backspace */
      case 0x7F:      /* Delete */
        if(pos > 0)
        {
          pos -= 1;
          board_putchar(0x08);    /* backspace */
          board_putchar(' ');
          board_putchar(0x08);    /* backspace */
        }
        break;
      case CTRL_U:
      case CTRL_D:
      case CTRL_R:
        for(i = 0; i < pos; ++i)
        {
          board_putchar(0x08);    /* backspace */
          board_putchar(' ');
          board_putchar(0x08);    /* backspace */
        }
        if(ch == CTRL_U)
        {
          pos = history_up(&curr_hist,line);
          break;
        }
        if(ch == CTRL_D)
        {
          pos = history_down(&curr_hist,line);
          break;
        }
        if(ch == CTRL_R)
        {
          pos = history_repeat(line);
          repeat = TRUE;
        }
        break;
      default:
        if((pos+1) < UIF_MAX_LINE)
        {
          /* only printable characters */
          if((ch > 0x1f) && (ch < 0x80))
          {
            line[pos++] = (char)ch;
            board_putchar((char)ch);
          }
        }
        break;
    }
    if(repeat)
      break;
    ch = (int)board_getchar();
  }
  line[pos] = '\0';
  board_putchar(0x0D);    /* CR */
  board_putchar(0x0A);    /* LF */
  if((strlen(line) != 0) && !repeat)
    history_add(line);
  strcpy(userline,line);
  return userline;
}

static char *get_line(char *line)
{
  int pos;
  int ch;
  pos = 0;
  board_putchar_flush();
  ch = (int)board_getchar();
  while((ch != 0x0D /* CR */) && (ch != 0x0A /* LF/NL */) && (pos < UIF_MAX_LINE))
  {
    switch(ch)
    {
      case 0x08:      /* Backspace */
      case 0x7F:      /* Delete */
        if(pos > 0)
        {
          pos--;
          board_putchar(0x08);    /* backspace */
          board_putchar(' ');
          board_putchar(0x08);    /* backspace */
        }
        break;
      default:
        if((pos+1) < UIF_MAX_LINE)
        {
          if((ch > 0x1f) && (ch < 0x80))
          {
            line[pos++] = (char)ch;
            board_putchar((char)ch);
          }
        }
        break;
    }
    ch = (int)board_getchar();
  }
  line[pos] = '\0';
  board_putchar(0x0D);    /* CR */
  board_putchar(0x0A);    /* LF */
  return line;
}

static unsigned long get_value(char *s, int *success, int base)
{
  unsigned long value;
  char *p;
  value = strtoul(s,&p,base);
  if((value == 0) && (p == s))
  {
    *success = FALSE;
    return 0;
  }
  else
  {
    *success = TRUE;
    return value;
  }
}

static void cpu_write_data(unsigned long address, int size, unsigned long data)
{
  switch(size)
  {
    case SIZE_8: *((uint8 *)address) = (uint8)data; break;
    case SIZE_16: *((uint16 *)address) = (uint16)data; break;
    case SIZE_32: *((unsigned long *)address) = (unsigned long)data; break;
    default: break;
  }
}

static unsigned long cpu_read_data(unsigned long address, int size)
{
  switch(size)
  {
    case SIZE_8: return *((uint8 *)address);
    case SIZE_16: return *((uint16 *)address);
    case SIZE_32: return *((unsigned long *)address);
    default: return 0;
  }
}

static unsigned long cpu_align_address(unsigned long address, int size)
{
  switch(size)
  {
    case SIZE_32:
    case SIZE_16: return(address & ~0x00000001);
    case SIZE_8:
    default: return (address);
  }
}

static int cpu_parse_size(char *arg)
{
  int i, size = SIZE_16;
  for (i = 0; arg[i] != '\0'; i++)
  {
    if(arg[i] == '.')
    {
      switch(arg[i+1])
      {
        case 'b':
        case 'B': size = SIZE_8; break;
        case 'w':
        case 'W': size = SIZE_16; break;
        case 'l':
        case 'L': size = SIZE_32; break;
        default: size = SIZE_16; break;
      }
      break;
    }
  }
  return size;
}

static void dump_mem(unsigned long begin, unsigned long end, int size)
{
  unsigned long data;
  unsigned long curr;
  char line[16];
  char *lcur;
  int i, ch;
  curr = begin;
  do
  {
    board_printf("%08X: ",(int)curr);
    lcur = line;
    i = 0;
    while(i < 16)
    {
      data = cpu_read_data(curr,size);
      switch(size)
      {
        case SIZE_8:
        board_printf("%02X ", (int)data);
        *(uint8 *)lcur = (uint8)data;
        curr++;
        lcur++;
        i++;
        break;
      case SIZE_16:
        board_printf("%04X ", (int)data);
        *(uint16 *)lcur = (uint16)data;
        curr += 2;
        lcur += 2;
        i += 2;
        break;
      case SIZE_32:
        board_printf("%08X ", (int)data);
        *(unsigned long *)lcur = data;
        curr += 4;
        lcur += 4;
        i += 4;
        break;
      }
    }
    for(i = 0; i < 16; i++)
    {
      ch = line[i];
      if((ch >= ' ') && (ch <= '~'))
        board_printf("%c",ch);
      else
        board_printf(".");
    }
    board_printf("\r\n");
  }
  while(curr < end);
}

#define BKPT_NONE   (0)
#define BKPT_PERM   (1)
#define BKPT_TEMP   (2)

/* Data structure used to maintain break points and trace information */
typedef struct
{
  xTaskHandle tid;
  unsigned long address;
  unsigned short instruction;
  int count;
  int trigger;
  int valid;  /* and type info */
} BRKENT;

static BRKENT brktab[UIF_MAX_BRKPTS];
static int auto_breakpoint;

static void breakpoint_clear(int index)
{
  if((index >= 0) && (index < UIF_MAX_BRKPTS))
  {
    if(brktab[index].tid)
    {
//      board_printf("Resume task TID: %X\r\n", brktab[index].tid);
      vTaskResume(brktab[index].tid);
    }
    brktab[index].tid = 0;
    brktab[index].address = 0;
    brktab[index].instruction = 0;
    brktab[index].count = 0;
    brktab[index].trigger = 0;
    brktab[index].valid = BKPT_NONE;
  }
}

static int breakpoint_find(unsigned long address)
{
  /* This function searches the breakpoint table for `address'.
   * If it is found, then an index into the table is returned,
   * otherwise -1 is returned. */
  int index;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].address == address)
      return(index);
  }
  return(-1);
}

static void breakpoint_display_info(int index)
{
  if((index >= 0) && (index < UIF_MAX_BRKPTS))
  {
    board_printf("     %d       %08X %08X %08X\r\n",
     (int)index, (int)brktab[index].address, brktab[index].count, brktab[index].trigger);
  }
}

static void breakpoint_display(int argc, char **argv)
{
  unsigned long address;
  int i,j;
  (void)argc;
  board_printf("INSTR_BREAK__ADDRESS___COUNT___TRIGGER_____________________________________\r\n");
  if(auto_breakpoint)
    board_printf("     ?   Pexec TOS armed ?        ?\r\n");
  if(*(unsigned char *)(trap_breakpoint))
    board_printf("     ?  Mshrink MiNT armed ?      ?\r\n");
  /* break points are listed one by one starting at argv[1]  */
  /* if no break points listed, argv[1] == NULL, display all */
  if(argv[1] == NULL)
  {
    /* display all */
    for(i = 0; i < UIF_MAX_BRKPTS; i++)
    {
      if(brktab[i].valid)
        breakpoint_display_info(i);
    }
  }
  else
  {
    i = 1;
    while(argv[i] != NULL)
    {
      address = (unsigned long )strtoul(argv[i],NULL,16);
      for(j = 0; j < UIF_MAX_BRKPTS; j++)
      {
        if(brktab[j].address == address)
          breakpoint_display_info(j);
      }
      i++;
    }
  }
}

static void breakpoint_set_count(unsigned long brkpnt, int count)
{
  int index = breakpoint_find(brkpnt);
  if((index >= 0) && (index < UIF_MAX_BRKPTS))
    brktab[index].count = count;
}

static void breakpoint_set_all_count(int value)
{
  int index;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
    brktab[index].count = value;
}

static void breakpoint_set_trigger(unsigned long brkpnt, int count)
{
  int index = breakpoint_find(brkpnt);
  if((index >= 0) && (index < UIF_MAX_BRKPTS))
    brktab[index].trigger = count;
}

static void breakpoint_set_all_trigger(int value)
{
  int index;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
    brktab[index].trigger = value;
}

static void breakpoint_remove(unsigned long address)
{
  int index;
  if((index = breakpoint_find(address)) != -1)
    breakpoint_clear(index);
}

static void breakpoint_add(unsigned long address, int type)
{
  int i;
  /* first check to make sure not already in table */
  if(breakpoint_find(address) != -1)
    return;
  /* find an open slot and put it in */
  for(i = 0; i < UIF_MAX_BRKPTS; i++)
  {
    if(!brktab[i].valid)
      break;
  }
  if(i == UIF_MAX_BRKPTS)
  {
    board_printf("Break table full\r\n");
    return;
  }
  /* Test for valid breakpoint address */
  if(address & 1) /* 16-bit boudary */
  {
    board_printf("Error:  Invalid breakpoint address!\r\n");
    return;
  }
//  unprotect_code();
  /* Test for read-only memory */
  brktab[i].instruction = *(unsigned short *)address;
  *(unsigned short *)address = (unsigned short)ILLEGAL;
  if(*(volatile unsigned short *)address != (unsigned short)ILLEGAL)
    board_printf("Error:  Address is read-only!\n");
  else
  {
    *(unsigned short *)address = brktab[i].instruction;
    brktab[i].address = address;
    brktab[i].count = 0;
    brktab[i].trigger = 1;
    brktab[i].valid = type;
  }
//  protect_code();
}

static int breakpoint_install(unsigned long address)
{
  /* This function inserts the breakpoints in user code.  Extensive
   * checking of breakpoints is done before entry into the table, so
   * all breakpoints in table should be OK to just implant.  If
   * a breakpoint with the same `address' is found, it is not
   * inserted, and TRUE is returned, otherwise FALSE.
   * This routine is generally called right before executing user
   * code. */
  int index, found = FALSE;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].valid)
    {
      if(brktab[index].address == address)
        found = TRUE;
      else
      {
//        unprotect_code();
        brktab[index].instruction = *(unsigned short *)brktab[index].address;
        *(unsigned short *)brktab[index].address = (unsigned short)ILLEGAL;
//        protect_code();
      }
    }
  }
  flush_caches();
  return(found);
}

static int breakpoint_install_from_cf68klib(unsigned long address)
{
  /* This function inserts the breakpoints in user code.  Extensive
   * checking of breakpoints is done before entry into the table, so
   * all breakpoints in table should be OK to just implant.  If
   * a breakpoint with the same `address' is found, it is not
   * inserted, and TRUE is returned, otherwise FALSE.
   * This routine is generally called right before executing user
   * code. */
  int index, found = FALSE;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].valid)
    {
      if(brktab[index].address == address)
        found = TRUE;
      else
      {
//        unprotect_code();
        brktab[index].instruction = *(unsigned short *)brktab[index].address;
        *(unsigned short *)brktab[index].address = (unsigned short)ILLEGAL;
//        protect_code();
      }
    }
  }
#if (__GNUC__ > 3)
  asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5485\n\t");
#else
  asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5200\n\t");
#endif
  return(found);
}

static int breakpoint_deinstall(unsigned long address, int *triggered, xTaskHandle tid)
{
  /* This function removes breakpoints from user code.  If
   * `address' is/was installed, TRUE is returned, else FALSE
   * if `address' was encountered, its count is incremented. */
  int index, found = FALSE;
  *triggered = FALSE;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].valid)
    {
//      unprotect_code();
      *(unsigned short *)brktab[index].address = (unsigned short)brktab[index].instruction;
//      protect_code();
      if(brktab[index].address == address)
      {
        brktab[index].tid = tid;
        found = TRUE;
        if(++brktab[index].count >= brktab[index].trigger)
          *triggered = TRUE;
      }
      if(brktab[index].valid == BKPT_TEMP)
      {
        /* knock out Temporary breakpoints */
        breakpoint_clear(index);
      }
    }
  }
  flush_caches();
  return found;
}

static int breakpoint_deinstall_from_cf68klib(unsigned long address, xTaskHandle tid)
{
  /* This function removes breakpoints from user code.  If
   * `address' is/was installed, TRUE is returned, else FALSE
   * if `address' was encountered, its count is incremented. */
  int index, found = FALSE;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].valid)
    {
//      unprotect_code();
      *(unsigned short *)brktab[index].address = (unsigned short)brktab[index].instruction;
//      protect_code();
      if(brktab[index].address == address)
      {
        brktab[index].tid = tid;
        found = TRUE;
      }
      if(brktab[index].valid == BKPT_TEMP)
      {
        /* knock out Temporary breakpoints */
        breakpoint_clear(index);
      }
    }
  }
#if (__GNUC__ > 3)
  asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5485\n\t");
#else
  asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5200\n\t");
#endif
  return found;
}

static void suspend_task(xTaskHandle tid)
{
  if(pxCurrentTCB == tid_TOS)
    tos_suspend = 1;
  vTaskSuspend(tid);
}

static void resume_task(xTaskHandle tid)
{
  if(tid == tid_TOS)
  {
    *(unsigned long *)_hz_200 = xTaskGetTickCount();
    tos_suspend = 0;
  }
  vTaskResume(tid);
}

void install_auto_breakpoint(unsigned long address) /* called from DBOS / CF68KLIB */
{
  if(auto_breakpoint && address && (address < (unsigned long)__SDRAM_SIZE)
   && ((address < 0xE00000) || (address >= 0x1000000)))
  {
    breakpoint_deinstall_from_cf68klib(address, pxCurrentTCB);
    breakpoint_add(address, BKPT_PERM);
    breakpoint_install_from_cf68klib((unsigned long)-1);
  }
}

static void breakpoint_init(void)
{
  int index;
  *(unsigned long *)(v_breakpoint_install) = (unsigned long)breakpoint_install;
  *(unsigned long *)(v_breakpoint_deinstall) = (unsigned long)breakpoint_deinstall;
  *(unsigned long *)(v_breakpoint_add) = (unsigned long)breakpoint_add; 
  *(unsigned long *)(v_breakpoint_remove) = (unsigned long)breakpoint_remove; 
  *(unsigned long *)(v_suspend_task) = (unsigned long)suspend_task; 
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
    breakpoint_clear(index);
  auto_breakpoint = 0;
  *(unsigned char *)(trap_breakpoint) = 0;
}

static void uif_cmd_cb(int argc, char **argv)
{
  int success, index;
  if((argc == 2) && (argv[1][0] != '*'))
  {
    index = get_value(argv[1],&success,10);
    if(success)
    {
      if((index >= UIF_MAX_BRKPTS) || (brktab[index].valid != BKPT_PERM))
      {
        board_printf("Error:  Bad index!\r\n");
        return;
      }
      breakpoint_remove(brktab[index].address);
    }
  }
  else
    breakpoint_init();
  *(unsigned short *)(save_format) = 0;
}

static void uif_cmd_db(int argc, char **argv)
{
  int i, value, success;
  unsigned long brkpnt;
  char *p;
  brkpnt = (unsigned long)-1;   /* improbable breakpoint address */
  if(argc == 1)
  {
    auto_breakpoint = 1;        /* for BDOS pexec, 1st word of program */
    /* display all break points */
    breakpoint_display(argc, argv);
    return;
  }
  /* parse through arguments */
  i = 1;
  while(i < argc)
  {
    if(argv[i][0] != '-')
    {
      /* must be a breakpoint address */
      success = 1;
      brkpnt = get_value(argv[i],&success,16);
      if(success == 0)
      {
        board_printf("Error:  Bad Value:  %s\r\n",argv[i]);
        return;
      }
      /* add breakpoint, if not already there */
      breakpoint_add(brkpnt, BKPT_PERM);
      i++;
    }
    else
    {
      /* must be an option of some sort */
      switch(argv[i][1])
      {
        case 'c':
        case 'C':
          /* set break point count */
          if(argv[i+1] == NULL)
            value = 0;
          else
          {
            value = strtoul(argv[++i],&p,BASE);
            if((value == 0) && (p == argv[i]))
              value = 0;
          }
          if(brkpnt == (unsigned long)-1)
          {
            /* set all counts */
            breakpoint_set_all_count(value);
            return;
          }
          else
            breakpoint_set_count(brkpnt,value);
          break;
        case 't':
        case 'T':
          /* set break point trigger */
          if(argv[i+1] == NULL)
            value = 1;
          else
          {
            value = strtoul(argv[++i],&p,BASE);
            if((value == 0) && (p == argv[i]))
              value = 1;
          }
          if(brkpnt == (unsigned long)-1)
          {
            /* set all triggers */
            breakpoint_set_all_trigger(value);
            return;
          }
          else
            breakpoint_set_trigger(brkpnt,value);
          break;
        case 'r':
        case 'R':
          /* remove break points */
          if(brkpnt == (unsigned long)-1)
          {
            /* check for address given after '-r' */
            if(argv[i+1] == NULL)
              breakpoint_init();
            else
            {
              while(++i < argc)
              {
                success = 1;
                brkpnt = get_value(argv[i],&success,16);
                if(success == 0)
                  breakpoint_init();
                else
                  breakpoint_remove(brkpnt);
              }
            }
          }
          else
            breakpoint_remove(brkpnt);
          *(unsigned short *)(save_format) = 0;
          break;
        case 'i':
        case 'I':
          breakpoint_set_all_trigger(1);
          breakpoint_set_all_count(0);
          break;
        case 'm':
        case 'M':
          *(unsigned char *)(trap_breakpoint) = 1; /* for trap #1 mshrink */
          break;
        default:
          board_printf("Error:  Invalid option:  %s\r\n",argv[1]);
          break;
      }
      i++;
    }
  }
}

static void uif_cmd_lb(int argc, char **argv)
{
  breakpoint_display(argc, argv);
}

#ifdef MCF547X /* FIREBEE */

void zero_devide(void)
{
  asm volatile (
        "_new_zero_divide:\n\t"
        " move.w #0x2700,SR\n\t"         /* disable interrupt */
        " move.l D0,-(SP)\n\t"
        " move.l A0,-(SP)\n\t"
        " move.l 12(SP),A0\n\t"          /* PC */
        " move.w (A0)+,D0\n\t"           /* opcode */
        " btst #7,D0\n\t"
        " bne.s .word\n\t"
        " addq.l #2,A0\n\t"              /* longword */
        ".word:\n\t"
        " and.l	#0x3F,D0\n\t"            /* source effective address */
        " cmp.l	#8,D0\n\t"
        " bls.s .end\n\t"                /* Dy */
        " addq.l #2,A0\n\t"
        " cmp.l	#0x39,D0\n\t"            /* absolute */
        " beq.s .absolute\n\t"
        "	cmp.l	#0x3C,D0\n\t"            /* immediate */
        " bne.s .end\n\t"
        ".absolute:\n\t"
        " addq.l #2,A0\n\t"
        ".end:\n\t"
        " move.l A0,12(SP)\n\t"          /* fix PC */
        "	move.l (SP)+,A0\n\t"
        "	move.l (SP)+,D0\n\t"
        "	rte\n\t" );
}

void trap_exception(void)
{
  asm volatile (
        "_new_trap:\n\t"
        " clr.l -(SP)\n\t"
        " move.l D0,-(SP)\n\t"
        " move.l A0,-(SP)\n\t"
        " move.w 12(SP),D0\n\t"
        " and.l #0x3FC,D0\n\t"
        " move.l D0,A0\n\t"
        " move.l (A0),8(SP)\n\t"
        " move.l (SP)+,A0\n\t"
        " move.l (SP)+,D0\n\t"
        " rts\n\t" );
}

void clear_int6(void)
{
  MCF_EPORT_EPFR |= MCF_EPORT_EPFR_EPF6; /* clear interrupt */ 
}

void inter_mfp(void)
{
  asm volatile (
        "_new_mfp:\n\t"
        " move.l 0x114,-(SP)\n\t"
        " lea -24(SP),SP\n\t"
        " movem.l D0-D2/A0-A2,(SP)\n\t" );
  clear_int6();
  asm volatile (
        " moveq #0,D1\n\t"
        " move.b 0xFFFFFA13,D1\n\t"      /* MFP IMRA (FPGA emulation) */
        " asl.l #8,D1\n\t"
        " move.b 0xFFFFFA15,D1\n\t"      /* MFP IMRB (FPGA emulation) */
        " move.b 0xFFFFFA0B,D0\n\t"      /* MFP IPRA (FPGA emulation) */
        " asl.l #8,D0\n\t"
        " move.b 0xFFFFFA0D,D0\n\t"      /* MFP IPRB (FPGA emulation) */
        " and.l D1,D0\n\t"
        " tst.l D0\n\t"
        " beq.s .is_not_mfp\n\t"
        " move.l 0xF0020000,D0\n\t"      /* ACP_MFP_INTACK_VECTOR (MFP vector base register + MFP int channel) * 4 */
        " and.l #0x3FC,D0\n\t"
        " cmp.l #0x13C,D0\n\t"
        " bne.s .not_pseudo_dma\n\t"     /* TOS pseudo dma routine */
        " move.l _pseudo_dma_vec,D0\n\t"
        " move.l D0,24(SP)\n\t"          /* move vector content to return address */
        " bra.s .is_not_mfp\n\t"
        ".not_pseudo_dma:\n\t"
        " move.l D0,A0\n\t"
        " move.l (A0),24(SP)\n\t"        /* move vector content to return address */
        ".is_not_mfp:\n\t"
        " movem.l (SP),D0-D2/A0-A2\n\t"
        " lea 24(SP),SP\n\t"
        " rts\n\t" );                    /* jump to MFP vector */
}

void function_vbl(void)
{
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_INTERRUPT_POLLING)
void usb_event_poll(int interrupt);
#endif
  MCF_INTC_INTFRCL &= ~MCF_INTC_INTFRCL_INTFRC4; /* clear interrupt */
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_INTERRUPT_POLLING)
  MCF_GPT_GMS(0) = 0;
  MCF_GPT_GCIR(0) = 20000 | (SYSTEM_CLOCK << 16); /* 20 mS */
  MCF_GPT_GMS(0) = MCF_GPT_GMS_TMS_GPIO | MCF_GPT_GMS_CE | MCF_GPT_GMS_WDEN; /* watchdog timer */
#ifdef CONFIG_USB_OHCI
  if(ohci_inited)
#endif
    usb_event_poll(1);                   /* if CTRL-ALT-(SHIFT-)DEL no return ! */
  MCF_GPT_GMS(0) = 0;                    /* clear watchdog timer */
#endif
}

void inter_vbl(void)
{
  asm volatile (
        "_new_vbl:\n\t"
        " lea -24(SP),SP\n\t"
        " movem.l D0-D2/A0-A2,(SP)\n\t" );
  function_vbl();
  asm volatile (
        " movem.l (SP),D0-D2/A0-A2\n\t"
        " lea 24(SP),SP\n\t"
        "	move.l 0x70,-(SP)\n\t"
        " rts\n\t" );                    /* jump to VBL vector */
}

#define MMUCR (*(volatile unsigned long *)(MMU_BASE+0x0000))
#define MMUOR (*(volatile unsigned long *)(MMU_BASE+0x0004))
#define MMUSR (*(volatile unsigned long *)(MMU_BASE+0x0008))
#define MMUAR (*(volatile unsigned long *)(MMU_BASE+0x0010))
#define MMUTR (*(volatile unsigned long *)(MMU_BASE+0x0014))
#define MMUDR (*(volatile unsigned long *)(MMU_BASE+0x0018))

#define MMUCR_EN           0x01

#define MMUOR_STLB        0x100
#define MMUOR_CA           0x80
#define MMUOR_CNL          0x40
#define MMUOR_CAS          0x20
#define MMUOR_ITLB         0x10
#define MMUOR_ADR          0x08
#define MMUOR_RW           0x04
#define MMUOR_ACC          0x02
#define MMUOR_UAA          0x01

#define MMUTR_SG           0x02
#define MMUTR_V            0x01

#define MMUDR_SZ1M        0x000
#define MMUDR_SZ4K        0x100
#define MMUDR_SZ8K        0x200
#define MMUDR_SZ1K        0x300
#define MMUDR_WRITETHROUGH 0x00
#define MMUDR_WRITEBACK    0x40
#define MMUDR_NOCACHE      0x80
#define MMUDR_SP           0x20
#define MMUDR_R            0x10
#define MMUDR_W            0x08
#define MMUDR_X            0x04
#define MMUDR_LK           0x02

#define MMUSR_HITN         0x02

static void mmu_map(long virt_addr, long phys_addr, long flag_itlb, long flags_mmutr, long flags_mmudr)
{
  extern unsigned char __MBAR[];
  unsigned long MMU_BASE = (unsigned long)__MBAR + 0x40000;
	MMUAR = virt_addr + 1;
	MMUOR = MMUOR_STLB + MMUOR_ADR + flag_itlb;
	MMUTR = virt_addr + flags_mmutr + MMUTR_V;
	MMUDR = phys_addr + flags_mmudr;
	MMUOR = MMUOR_ACC + MMUOR_UAA + flag_itlb;
}

static portTASK_FUNCTION(vVBL, pvParmeters)
{           
  extern void new_vbl(void);
  extern long get_videl_base(void);
  extern long get_videl_size(void);
  extern void get_mouseikbdvec(void);
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI) /* for usb_malloc */
#ifdef SOUND_AC97
  extern void det_xbios(void);
  extern long sndstatus(long reset);
  extern long old_vector_xbios;
  extern long flag_snd_init, flag_gsxb;
  int sound_err;
#endif /* SOUND_AC97 */
#endif /* defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI) */
  volatile unsigned char *rtc_reg = (volatile unsigned char *)0xFFFF8961; /* PFGA emulation */
  volatile unsigned char *rtc_data = (volatile unsigned char *)0xFFFF8963;
  long count = 0, physbase = get_videl_base();
  long date = 0, time = 0;
  *(unsigned long *)(((64+4) * 4) + coldfire_vector_base) = (unsigned long)new_vbl;
  MCF_GPIO_PODR_FEC1L &= ~MCF_GPIO_PODR_FEC1L_PODR_FEC1L4; /* led */
  vTaskDelay(configTICK_RATE_HZ);
  get_mouseikbdvec();  /* XBIOS calls !!! (for USB and screen WEB server) */
  old_vector_xbios = *(long *)0xB4; /* XBIOS */
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef SOUND_AC97
  sound_err = mcf548x_ac97_install(2);
#endif
#endif
  while(1)
  {
		unsigned long start_timer = *(unsigned long *)_hz_200;
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef SOUND_AC97
    if(!sound_err)
    {
      *(long *)0xB4 = (long)det_xbios;
      flag_snd_init = 1;
      flag_gsxb = 1;
      sndstatus(1);
    }
    else
      flag_snd_init = 0;
#endif /* SOUND_AC97 */
    board_printf("Add cookies\r\n");
    if(pci_data != NULL)
    {
      COOKIE pcookie;
      COOKIE *p = *(COOKIE **)cookie;
      int i = 0;
      pcookie.ident = '_PCI';
      pcookie.v.l = (long)pci_data;
      while(p != NULL)
      {
        if(p->ident == '_PCI')
        	continue;
        if((!p->ident) && (i+1 < p->v.l)) /* free space ? */
        {
          *(p+1) = *p; /* add cookie */
          *p++ = pcookie;
          break;
        }
#ifdef SOUND_AC97
        if((p->ident == '_SND') && !sound_err)
          p->v.l |= 0x27; /* bit 5: extended mode, bit 2: 16 bits DMA, bit 1: 8 bits DMA, bit 0: YM2149 */
#endif /* SOUND_AC97 */
        i++;
        p++;
      }
    }
#endif /* defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI) */
    while((*(unsigned long *)_hz_200 - start_timer) < 200UL)
    {
		  start_timer = *(unsigned long *)_hz_200;
      /* Videl screen change - FPGA memory */
      long new_physbase = get_videl_base();
      if(new_physbase != physbase)
      {
        long end_physbase = new_physbase + get_videl_size();
        physbase = new_physbase;
        new_physbase &= 0xf00000;
        end_physbase &= 0xf00000;
        if(new_physbase < 0xd00000)
        {
          int level = asm_set_ipl(7); /* disable interrupts */
          flush_caches();
          memcpy((void *)(new_physbase + 0x60000000), (void *)new_physbase, 0x100000);
          mmu_map(new_physbase,(new_physbase + 0x60000000),MMUOR_ITLB,MMUTR_SG,MMUDR_SZ1M+MMUDR_WRITETHROUGH+MMUDR_X+MMUDR_LK);
          mmu_map(new_physbase,(new_physbase + 0x60000000),0,MMUTR_SG,MMUDR_SZ1M+MMUDR_WRITETHROUGH+MMUDR_R+MMUDR_W);
				  if((end_physbase != new_physbase) && (end_physbase < 0xd00000)) /* 2nd page */
          {
            memcpy((void *)(end_physbase + 0x60000000), (void *)new_physbase, 0x100000);
            mmu_map(end_physbase,(end_physbase + 0x60000000),MMUOR_ITLB,MMUTR_SG,MMUDR_SZ1M+MMUDR_WRITETHROUGH+MMUDR_X+MMUDR_LK);
            mmu_map(end_physbase,(end_physbase + 0x60000000),0,MMUTR_SG,MMUDR_SZ1M+MMUDR_WRITETHROUGH+MMUDR_R+MMUDR_W);
          }
          asm_set_ipl(level);
//          board_printf("new videl screen at 0x%lX\r\n", physbase); 
        }
      }
      if(!(count % 50))
      {
#define NVRAM_RTC_SECONDS 0
#define NVRAM_RTC_MINUTES 2
#define NVRAM_RTC_HOURS 4
#define NVRAM_RTC_DAYS 7
#define NVRAM_RTC_MONTHS 8
#define NVRAM_RTC_YEARS 9
        int i;
        long new_date = 0, new_time = 0, delta_time;
        int level = asm_set_ipl(7); /* disable interrupts */
        unsigned char reg = *rtc_reg;
        *rtc_reg = NVRAM_RTC_HOURS;
        new_time |= (unsigned long)*rtc_reg;
        new_time <<= 8;
        *rtc_reg = NVRAM_RTC_MINUTES;
        new_time |= (unsigned long)*rtc_reg;
        new_time <<= 8;
        *rtc_reg = NVRAM_RTC_SECONDS;
        new_time |= (unsigned long)*rtc_reg;
        *rtc_reg = NVRAM_RTC_YEARS;
        new_date |= (unsigned long)*rtc_reg;
        new_date <<= 8;
        *rtc_reg = NVRAM_RTC_MONTHS;
        new_date |= (unsigned long)*rtc_reg;
        new_date <<= 8;
        *rtc_reg = NVRAM_RTC_DAYS;
        new_date |= (unsigned long)*rtc_reg;
        if(!time)
          time = new_time;
        if(!date)
          date = new_date;    
        delta_time = new_time - time;
        if(delta_time < 0)
          delta_time = - delta_time;
        if((delta_time > 2) || (date != new_date))     
        {
          MCF_UART3_UTB = 0x82; /* header */
          for(i = 0; i < 64; i++)
          {
            while(!(MCF_UART3_USR & MCF_UART_USR_TXEMP));
            *rtc_reg = (unsigned char)i;
            MCF_UART3_UTB = *rtc_data; /* send data */
          }
        }
        *rtc_reg = reg;
        asm_set_ipl(level);
//        if((delta_time > 2) || (date != new_date))     
//          board_printf("RTC update to the PIC\r\n"); 
        time = new_time;
        date = new_date;    
      }
       /* Toggle led */
      if(!(count & 7))
        MCF_GPIO_PODR_FEC1L &= ~MCF_GPIO_PODR_FEC1L_PODR_FEC1L4;
      else if((count & 7) == 4)
        MCF_GPIO_PODR_FEC1L |= MCF_GPIO_PODR_FEC1L_PODR_FEC1L4;
      /* RTC update to the PIC */
      /* Send VBL interrupt */
      MCF_INTC_INTFRCL |= MCF_INTC_INTFRCL_INTFRC4; /* force INT 4 */
      /* VBL delay */    
      vTaskDelay((20*configTICK_RATE_HZ)/1000);
      count++;
    }
  }
}

static portTASK_FUNCTION(vETOS,pvParmeters)
{           
  void (*fp)(void) = (void(*)(void))0xE00000;
  (*fp)();
}

static void go_emutos(unsigned long source)
{
  extern void end_vdi();
  extern long init_videl(long width, long height, long bpp, long refresh, long extended);
  extern void new_zero_divide(void);
  extern void new_trap(void);
  extern void new_mfp(void);
  extern unsigned char __LWIP_BASE[];
  extern void *info_fvdi;
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
  extern void *usb_malloc(long amount);
  COOKIE *pci_cookie = *(COOKIE **)cookie;
#endif
  unsigned long top = (unsigned long)__LWIP_BASE - 0x100000; /* - 1MB */
  int i;
	mcf548x_ac97_uninstall(2, 0);
	vTaskDelay(1);
	deinstall_inters_cf68klib();
  vTaskDelete(tid_TOS);
	end_vdi(); /* for screen WEB server and mousexy() */
  if(source != 0xE0600000)
  {
    void (*fp)(void) = (void(*)(void))source;
    asm_set_ipl(7); /* disable interrupts */
    (*fp)();
  }
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_MEM_NO_CACHE)
  pci_data = NULL;
  while(pci_cookie != NULL)
  {
    if(pci_cookie->ident == '_PCI')
    {
  	  pci_data = usb_malloc(PCI_COOKIE_TOTALSIZE);
  	  if(pci_data != NULL)
			  memcpy(pci_data, (void *)pci_cookie->v.l, PCI_COOKIE_TOTALSIZE);
		  break;
    }
    if(!pci_cookie->ident)
    {
			pci_cookie = NULL;
			break;
    }
    pci_cookie++;
  }
#endif /* (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_MEM_NO_CACHE) */
#if 1
  init_videl(640, 480, 4, 60, 0xD00000);
	memset((void *)0xD00000, 0, (640 * 480 * 4) /sizeof(short));
#else
  init_videl(640, 480, 16, 60, 0xD00000);
	memset((void *)0xD00000, -1, 640 * 480 * sizeof(short));
#endif
	info_fvdi = NULL;
  asm_set_ipl(7); /* disable interrupts */
	for(i = 1; i < 16; *(unsigned long *)(((32+i) * 4) + coldfire_vector_base) = (unsigned long)new_trap, i++);
  *(unsigned long *)((5 * 4) + coldfire_vector_base) = (unsigned long)new_zero_divide; /* Zero Divide */
  *(unsigned long *)((10 * 4) + coldfire_vector_base) = (unsigned long)new_trap; /* LineA */
  *(unsigned long *)((15 * 4) + coldfire_vector_base) = (unsigned long)new_trap; /* LineF */
  *(unsigned long *)(((64+6) * 4) + coldfire_vector_base) = (unsigned long)new_mfp;  /* IRQ6 EPORT */
  pseudo_dma_vec = *(unsigned long *)0x13C;
	MCF_EPORT_EPIER |= MCF_EPORT_EPIER_EPIE6;
  if(save_imrl_tos & MCF_INTC_IMRL_INT_MASK5)
	  MCF_INTC_IMRL &= ~(MCF_INTC_IMRL_INT_MASK6 + MCF_INTC_IMRL_MASKALL);
	else /* PCI used */
	{
	  /* move PCI CF68KLIB interrupt vector to native coldfire vector */
    *(unsigned long *)(((64+5) * 4) + coldfire_vector_base) = *(unsigned long *)((64+5+OFFSET_INT_CF68KLIB) * 4); /* IRQ5 EPORT */
	  MCF_INTC_IMRL &= ~(MCF_INTC_IMRL_INT_MASK6 + MCF_INTC_IMRL_INT_MASK5 + MCF_INTC_IMRL_MASKALL);  
  }
  top &= 0xFFF00000;
  disable_caches();
  asm volatile (
        " move.l #0x0000E040,D0\n\t" /* zone at $00000000 to $00FFFFFF in cache inhibit */
        " movec.l D0,ACR0\n\t" );
  memcpy((void *)0xE00000,(void *)source,0x80000); /* copy Emutos */
  asm volatile (
        " moveq #0,D0\n\t"
        " movec.l D0,ACR0\n\t" );
  mmu_map(top,top,0,MMUTR_SG,MMUDR_SZ1M+MMUDR_NOCACHE+MMUDR_LK);
  *(unsigned long *)ramtop = top;
  enable_caches();
  xTaskCreate(vETOS, (void *)"ETOS", STACK_DEFAULT, NULL, TOS_TASK_PRIORITY, &tid_ETOS);
  xTaskCreate(vVBL, (void *)"VBL", STACK_DEFAULT, NULL, VBL_TASK_PRIORITY, NULL);
}

#endif /* MCF547X */

static void uif_cmd_go(int argc, char **argv)
{
  int index, success;
  if(argc == 2)
  {
    void (*fp)(void) = (void(*)(void))get_value(argv[1],&success,16);
    if(success == 0)
    {
      board_printf(INVALUE,argv[1]);
      return;
    }
#ifdef MCF547X
    if(((unsigned long)fp == 0xE0600000) || ((unsigned long)fp == 0xE0400000))
    {
    	go_emutos((unsigned long)fp);
      return;
    }
#endif
    (*fp)(); 
  }
  *(unsigned long *)(cpu_trace_count) = 0;
  if(breakpoint_install(*(unsigned short *)(save_format) ? *(unsigned long *)(save_pc) : (unsigned long)-1)) /* insert all breakpoints */
    *(unsigned long *)(cpu_trace_thru) = *(unsigned long *)(save_pc); /* PC is at breakpoint */
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].valid == BKPT_PERM)
    {
      if(brktab[index].tid)
      {
//        board_printf("Resume task TID: %X\r\n", brktab[index].tid);
        resume_task(brktab[index].tid);
        brktab[index].tid = 0;
      }
    }
  }
}

static void uif_cmd_st(int argc, char **argv)
{
  int index, success, found = 0;
  for(index = 0; index < UIF_MAX_BRKPTS; index++)
  {
    if(brktab[index].valid == BKPT_PERM)
    {
      if(brktab[index].tid)
      {
        *(unsigned long *)(cpu_trace_count) = 1;
        if(argc == 2)
        {
          *(unsigned long *)(cpu_trace_count) = get_value(argv[1],&success,10);
          if(!success)
            *(unsigned long *)(cpu_trace_count) = 1;
        }
        if(breakpoint_find(*(unsigned long *)(save_pc)) == -1)
        {
          *(unsigned long *)(cpu_step_over) = *(unsigned long *)(save_pc);
          breakpoint_add(*(unsigned long *)(cpu_step_over), BKPT_TEMP);
        }
        breakpoint_install((unsigned long)-1);
//        board_printf("Resume task TID: %X\r\n", brktab[index].tid);
        resume_task(brktab[index].tid);
        found = 1;
      }
    }
  }
  if(!found)
    board_printf("Error:  No task supended by a breakpoint to trace\r\n");
}

#ifndef MCF5445X
#ifdef SOUND_AC97

static void uif_cmd_ac97_pr(int argc, char **argv)
{
  unsigned long datar, dataw;
  int done, success;
  unsigned long address;
  char string[UIF_MAX_LINE];
  (void)argc;
  address = get_value(argv[1],&success,16);
  if(success == 0)
  {
    board_printf(INVALUE,argv[1]);
    return;
  }
  address = cpu_align_address(address,SIZE_16);
  if(argv[2] != NULL)
  {
    /* the data has been specified */
    dataw = get_value(argv[2],&success,BASE);
    if(success == 0)
      board_printf(INVALUE,argv[2]);
    else
      mcf548x_ac97_debug_write(AC97_DEVICE,address,dataw);
    return;
  }
  else if(pxCurrentTCB != tid_TELNET)
  {
    done = FALSE;
    while(!done)
    {
      address &= 0x7f;
      datar = mcf548x_ac97_debug_read(AC97_DEVICE,address);
      board_printf("%02X:  ", (int)address);
      board_printf("[%04X]  ", (int)datar);
      get_line(string);
      if(make_argv(string, NULL) == 0)
        goto next_addr;
      else
      {
        dataw = get_value(string, &success, BASE);
        if(!success)
        {
          /* Check for special cases */
          if(string[0] == '=')
             goto same_addr;
          if(string[0] == '^')
          {
            address -= 2;
            goto same_addr;
          }
          done = TRUE;
        }
        else
          mcf548x_ac97_debug_write(AC97_DEVICE,address,dataw);
      }
next_addr:
      address += 2;
same_addr:
      ;
    }
  }
  else
    board_printf(SYNTAX,argv[0]);  
}

#endif /* MCF5445X */
#endif /* SOUND_AC97 */

static void uif_cmd_md(int argc, char **argv)
{
  int success, size;
  unsigned long begin, end;
  unsigned long contents;
  size = cpu_parse_size(argv[0]);
  if(argc > 1)
  {
    if((argc == 2) && (argv[1][0] == '*'))
    {
      begin = get_value(&argv[1][1],&success,BASE);
      if(success)
      {
        contents = cpu_read_data(begin,SIZE_32);
        board_printf("%08X contains %08X\n", (int)begin, (int)contents);
        begin = contents;
        end = contents+(DEFAULT_MD_LINES*16);
        goto show_mem;
      }
      else
      {
        board_printf(INVALUE,argv[1]);
        return;
      }
    }
    begin = get_value(argv[1],&success,16);
    if(!success)
    {
      board_printf(INVALUE,argv[1]);
      return;
    }
    if(argc == 3)
    {
      end = get_value(argv[2],&success,16);
      if(!success)
      {
        board_printf(INVALUE,argv[2]);
        return;
      }
      if(begin > end)
      {
        unsigned long temp = end;
        end = begin;
        begin = temp;
      }
    }
    else
      end = begin + (DEFAULT_MD_LINES * 16);
  }
  else
  {
    begin = md_last_address;
    size = md_last_size;
    end = begin + (DEFAULT_MD_LINES * 16);
  }
show_mem:
  begin = cpu_align_address(begin,size);
  dump_mem(begin,end,size);
  md_last_address = end;
  md_last_size = size;
}

static void uif_cmd_pm(int argc, char **argv)
{
  unsigned long datar, dataw;
  int size, done, success;
  unsigned long address;
  char string[UIF_MAX_LINE];
  (void)argc;
  size = cpu_parse_size(argv[0]);
  address = get_value(argv[1],&success,16);
  if(success == 0)
  {
    board_printf(INVALUE,argv[1]);
    return;
  }
  address = cpu_align_address(address,size);
  if(argv[2] != NULL)
  {
    /* the data has been specified */
    dataw = get_value(argv[2],&success,BASE);
    if(success == 0)
      board_printf(INVALUE,argv[2]);
    else
      cpu_write_data(address,size,dataw);
    return;
  }
  else if(pxCurrentTCB != tid_TELNET)
  {
    done = FALSE;
    while(!done)
    {
      datar = cpu_read_data(address, size);
      board_printf("%08X:  ", (int)address);
      switch(size)
      {
        case SIZE_8: board_printf("[%02X]  ", (int)datar); break;
        case SIZE_16: board_printf("[%04X]  ", (int)datar); break;
        case SIZE_32: board_printf("[%08X]  ", (int)datar); break;
      }
      get_line(string);
      if(make_argv(string, NULL) == 0)
        goto next_addr;
      else
      {
        dataw = get_value(string, &success, BASE);
        if(!success)
        {
          /* Check for special cases */
          if(string[0] == '=')
             goto same_addr;
          if(string[0] == '^')
          {
            switch(size)
            {
              case SIZE_8: address -= 1;  break;
              case SIZE_16: address -= 2; break;
              case SIZE_32: address -= 4; break;
            }
            goto same_addr;
          }
          done = TRUE;
        }
        else
          cpu_write_data(address,size,dataw);
      }
next_addr:
      switch(size)
      {
        case SIZE_8: address += 1; break;
        case SIZE_16: address += 2; break;
        case SIZE_32: address += 4; break;
      }
same_addr:
      ;
    }
  }
  else
    board_printf(SYNTAX,argv[0]);  
}

static void uif_cmd_dis(int argc, char **argv)
{
  struct DisasmPara_68k dp;
  char buffer[16];
  m68k_word *ip, *p;
  char opcode[16];
  char operands[128];
  char iwordbuf[32];
  char *s;
  unsigned long pc;
  int i, n, success;
  pc = 0; // cpu_pc_get();
  if(argc == 2)
  {
    /* Address to start disasm at */
    pc = get_value(argv[1],&success,BASE);
    if(success == 0)
    {
      board_printf(INVALUE,argv[1]);
      return;
    }
  }
  else
  {
    /* command given with no args -- repeat */
    if(disasm_last_address != 0)
      pc = disasm_last_address;
  }
  p = (m68k_word *)pc;
  db_radix = BASE;
  dp.instr = NULL;              /* pointer to instruction to disassemble */
  dp.iaddr = NULL;              /* instr.addr., usually the same as instr */
  dp.opcode = opcode;           /* buffer for opcode, min. 16 chars. */
  dp.operands = operands;       /* operand buffer, min. 128 chars. */
  dp.radix = 16;                /* base 2, 8, 10, 16 ... */
/* call-back functions for symbolic debugger support */
  dp.get_areg = NULL;           /* returns current value of reg. An */
  dp.find_symbol = NULL;        /* finds closest symbol to addr and */
                                /*  returns (positive) difference and name */
/* changed by disassembler: */
  dp.type = 0;                  /* type of instruction, see below */
  dp.flags = 0;                 /* additional flags */
  dp.reserved = 0;
  dp.areg = 0;                  /* address reg. for displacement (PC=-1) */
  dp.displacement = 0;          /* branch- or d16-displacement */
  for(i=0;i<16;i++)
  {          
    for(n = 0; n<sizeof(opcode)-1; opcode[n++]=' ');
    opcode[n] = 0;
    for(n = 0; n<sizeof(operands); operands[n++]=0);
    dp.instr = dp.iaddr = p;
    p = M68k_Disassemble(&dp);
    /* print up to 5 instruction words */
    for(n = 0; n<26; iwordbuf[n++]=' ');
    iwordbuf[26] = 0;
    if((n = (int)(p-dp.instr)) > 5)
      n = 5;
    ip = dp.instr;
    s = iwordbuf;
    while(n--)
    {
      sprintD(buffer,"%04X",(int)((((unsigned long)*(unsigned char *)ip)<<8) | ((unsigned long)*((unsigned char *)ip+1))));
      *s++ = buffer[0];
      *s++ = buffer[1];
      *s++ = buffer[2];
      *s++ = buffer[3];
      s++;
      ip++;
    }
    board_printf("%08X: %s", (int)dp.iaddr, iwordbuf);
    strcpy(buffer, "       ");
    n = 0;
    while(opcode[n])
    {
      buffer[n] = opcode[n];
      n++;
    }
    buffer[n] = 0;
    board_printf("%s %s\r\n", buffer, operands);
  }
  disasm_last_address = (unsigned long)p;
}

static void uif_cmd_dr(int argc, char **argv)
{
  unsigned long reg[40];
  portSTACK_TYPE p[64];
  portSTACK_TYPE *p1; 
  portSTACK_TYPE pc;
  portSTACK_TYPE frame_format; 
  int i, j, vector;
  if(argv);
  if(argc);
  vTaskSuspendAll();
  memcpy(reg, (void *)(library_data_area), 40 * sizeof(unsigned long));
#ifdef MCF547X
  memcpy(p, (tid_ETOS != NULL) ? tid_ETOS  : tid_TOS, 64 * sizeof(portSTACK_TYPE));
#else
  memcpy(p, tid_TOS, 64 * sizeof(portSTACK_TYPE));
#endif
  p1 = (portSTACK_TYPE *)p[0];
  frame_format = p1[0];
  pc = p1[1];
  xTaskResumeAll();
#ifdef MCF547X
  if(tid_ETOS == NULL)
#endif
  {
    vector = (int)((reg[38] >> 2) & 255);
    board_printf("CF68KLIB data area, fault #%d: ", vector);
    switch(vector)
    {
      case 2: board_printf("Access Fault"); break;
      case 3: board_printf("Address Error"); break;
      case 4: board_printf("Illegal Instruction"); break;
      case 5: board_printf("Integer Zero Divide"); break;
      case 8: board_printf("Privilege Violation"); break;
      case 9: board_printf("Trace"); break;
      case 10: board_printf("Line A"); break;
      case 11: board_printf("Line F"); break;
      case 14: board_printf("Format Error"); break;
      case 32:
      case 33:
      case 34:
      case 35:
      case 36:
      case 37:
      case 38:
      case 39:
      case 40:
      case 41:
      case 42:
      case 43:
      case 44:
      case 45:
      case 46:
      case 47: board_printf("Trap #%d", vector - 32); break;
    }
    board_printf("\r\nStatus Register (SR): %04X\r\n", (int)reg[17]>>16);
    board_printf("Program Counter (PC): %08X\r\n", (int)reg[16]);
    board_printf("Supervisor Stack (SSP): %08X\r\n", (int)reg[19]);
    board_printf("User Stack (USP): %08X\r\n", (int)reg[18]);
    for(i = j = 0; i < 8; i++)
      board_printf("D%d: %08X  A%d: %08X\r\n", i, (int)reg[i], i, (int)reg[i+8]);
    if(((vector == 4) || (vector == 8))
     && (*(unsigned long *)(save_pc_cf68klib) < (unsigned long)__SDRAM_SIZE))
      board_printf("%s  (emul)\r\n", disassemble_pc(*(unsigned long *)(save_pc_cf68klib)));
    if(reg[16] < (unsigned long)__SDRAM_SIZE)
      board_printf("%s\r\n", disassemble_pc(reg[16]));
  }
  board_printf("TOS task context saving:\r\n");
  board_printf("Status Register (SR): %04X\r\n", (int)(frame_format & 0xFFFF));
  board_printf("Program Counter (PC): %08X\r\n", (int)pc);
  board_printf("Supervisor Stack (SSP): %08X\r\n", (int)p[0]);
  board_printf("User Stack (USP): %08X\r\n", (int)p[16]);
  for(i = j = 0; i < 8; i++, j += 2)
  {
    board_printf("D%d: %08X  A%d: %08X  FP%d: %08X%08X\r\n",
     i, (int)p[i+1], i, (int)p[i+9],
     i, (int)p[j+22], (int)p[j+23]);
  }
  if(pc < (portSTACK_TYPE)__SDRAM_SIZE)
    board_printf("%s\r\n", disassemble_pc(pc));
}

static void uif_cmd_qt(int argc, char **argv)
{
  if(argc);
  if(argv);
  static char buf[80*50];
#if( HAVE_USP == 1 )
  board_printf("Name\t\tTID\tPrio\tStatus\tSys/User Stack\t#\r\n");
#else
  board_printf("Name\t\tTID\tPrio\tStatus\tStack\t\t#\r\n");
#endif
  board_printf("------------------------------------------------------------");
  vTaskList((void *)buf);
  board_printf(buf);
}

#if 0
static void uif_cmd_trace(int argc, char **argv)
{
#define DEFAULT_TRACE_SIZE 0x10000
  static char *buffer_trace = NULL;
  static unsigned long size_trace = DEFAULT_TRACE_SIZE;
  static char default_name[] = "trace.bin";
  static char filename_trace[UIF_MAX_LINE];
  long file_w;
  int success;
  unsigned long val;
  if(strcmp(argv[1],"on") == 0)
  {
    if(buffer_trace != NULL)
    {
      board_printf("Trace tasks already running, use <trace off> before\r\n");
      return;
    }  
    if((argc == 3) && (val = get_value(argv[2],&success,10)) != 0)
    {
      size_trace = val;
      strcpy(filename_trace, default_name);
    }
    else if(argc > 3)
    {
      val = get_value(argv[3],&success,10);
      if(val)
        size_trace = val;
      else
        size_trace = DEFAULT_TRACE_SIZE;
      strcpy(filename_trace, argv[2]);
    }
    else
    {
      size_trace = DEFAULT_TRACE_SIZE;
      strcpy(filename_trace, default_name);
    }
    if((buffer_trace = (char *)pvPortMalloc(size_trace)) == NULL)
    {
      board_printf("Not enough memory for create trace buffer\r\n");
      return;
    }
    vTaskStartTrace(buffer_trace, size_trace);
  }
  else if(strcmp(argv[1],"off") == 0)
  {
    if(buffer_trace == NULL)
    {
      board_printf("Trace tasks already stopped, use <trace on> before\r\n");
      return;
    }
    val = ulTaskEndTrace(); 
    Fdelete(filename_trace);
    if((file_w = Fcreate(filename_trace, 0)) < 0)
      board_printf("Cannot create file %s\r\n", filename_trace);
    else
    {
      Fwrite(file_w, val, buffer_trace);
      Fclose(file_w);
    }
    vPortFree(buffer_trace);    
    buffer_trace = NULL;
  }
  else
    board_printf("Usage : trace on/off <file> <size>\r\n");
}  
#endif

static void uif_cmd_cat(int argc, char **argv)
{
#define SIZE_BUFFER_CAT 10000
#define SIZE_BUF_CAT 80
  long file_r = 0, file_w = 0;
  int i, timeout, len, edit=0, cat=0, size=0;
  char *p, *buffer=NULL;
  static char buf[SIZE_BUF_CAT+1];
  static char buf2[SIZE_BUF_CAT*2+1];
  buf[SIZE_BUF_CAT] = '\0';
  if(argc > 2)
  {
    p = argv[argc-2];
    if(p[0] == '>')
    {
      cat++;
      if(p[1] == '>')
        cat++;
      if(argc == 3)
        edit = 1;
    }
    switch(cat)
    {
      case 1:
        file_w = Fcreate(argv[argc-1], 0);
        if(file_w < 0)
        {
          board_printf("Cannot create file %s (error: %d)\r\n", argv[argc-1], file_w);
          return;
        }
        break;
      case 2:
        file_w = Fopen(argv[argc-1], 2);
        if(file_w == ENOENT)
          file_w = Fcreate(argv[argc-1], 0);
        if(file_w < 0)
        {
          board_printf("Cannot write file %s (error: %d)\r\n", argv[argc-1], file_w);
          return;
        }
        Fseek(0, file_w, 2); /* end */
        break;
    }
  }
  if(edit && ((buffer = pvPortMalloc(SIZE_BUFFER_CAT)) != NULL))
  {
    char ch;
    size = 0;
    while(((ch = board_getchar()) != CTRL_D) && (ch != CTRL_C)
     && (size < SIZE_BUFFER_CAT))
    {
      switch(ch)
      {
        case '\r':
          board_putchar('\r');
          board_putchar('\n');
          if(size < SIZE_BUFFER_CAT)
            buffer[size++] = '\r';
          if(size < SIZE_BUFFER_CAT)
            buffer[size++] = '\n';
          break;
        case 0x08:      /* Backspace */
        case 0x7F:      /* Delete */
          if(size > 0)
          {
            size--;
            board_putchar(0x08);    /* backspace */
            board_putchar(' ');
            board_putchar(0x08);    /* backspace */
          }
          break;
        default:
          if(size < SIZE_BUFFER_CAT)
          {
            if((ch > 0x1f) && ((unsigned char)ch < 0x80))
            {
              buffer[size++] = ch;
              board_putchar(ch);
            }
          }
          break;
      }
    }
    board_putchar('\r');
    board_putchar('\n');
    Fwrite(file_w, size, buffer);
  }
  for(i = 1; i < (cat ? argc-2 : argc); i++)
  {
    if((file_r = Fopen(argv[i], 0)) >= 0)
    {
      do
      {
        len = Fread(file_r, SIZE_BUF_CAT, buf);
        if(cat && (len > 0))
          len = Fwrite(file_w, len, buf);
        else if(!cat && (len == SIZE_BUF_CAT))
        {
          char ch = 0;
          int j = 0, k = 0;
          while(buf[j])
          {
            if((buf[j] == '\n') && (ch != '\r'))
              buf2[k++] = '\r';
            buf2[k++] = ch = buf[j++];
          }
          buf2[k] = 0;
          board_printf(buf2);
          timeout = 0;
          while(!(ch = auxistat()) && (timeout < (configTICK_RATE_HZ*1920)/(SIZE_BUF_CAT*1000)))
            vTaskDelay(1);
          if(ch && ((ch = rs232get() & 0xFF) == CTRL_C))
          {
            len = 0;
            i = argc;
            break;
          }
        }
      }
      while(len == SIZE_BUF_CAT);
      if(!cat)
      {
        char ch = 0;
        int j = 0, k = 0;
        buf[len] = '\0';
        while(buf[j])
        {
          if((buf[j] == '\n') && (ch != '\r'))
            buf2[k++] = '\r';
          buf2[k++] = ch = buf[j++];
        }
        buf2[k] = 0;
        board_printf(buf2);
        if(i >= argc-1)
          board_printf("\r\n");
        vTaskDelay((configTICK_RATE_HZ*1920)/(SIZE_BUF_CAT*1000));
      }
      Fclose(file_r);
    }
    else
      board_printf("Cannot open file %s (error: %d)\r\n", argv[1], file_r);
  }
  if(cat)
    Fclose(file_w);
  if(buffer != NULL)
    vPortFree(buffer);
}

static void uif_cmd_chdir(int argc, char **argv)
{
  int err;
  if(argc);
  if((err = Dsetpath(argv[1])) < 0)
    board_printf("Cannot change to directory %s (error: %d)\r\n", argv[1], err);
}

static void uif_cmd_chmod(int argc, char **argv)
{
  int err;
  long attr = 0;
  if(argc);
  if(strchr(argv[2], 'a'))
    attr |= FA_ARCHIVE;
  if(strchr(argv[2], 's'))
    attr |= FA_SYSTEM;
  if(strchr(argv[2], 'h'))
    attr |= FA_HIDDEN;
  if(strchr(argv[2], 'r'))
    attr |= FA_RO;
  if((err = Fattrib(argv[1], 1, attr)) < 0)
    board_printf("Cannot change attributes of file %s (error: %d)\r\n", argv[1], err);
}

static void uif_cmd_cp(int argc, char **argv)
{
  long file_r, file_w;
  int len;
  char buf[512];
  if((file_r = Fopen(argv[1], 0)) >= 0)
  {
    if((file_w = Fcreate(argv[2], 0)) >= 0)
    {
      do
      {
        len = Fread(file_r, 512, buf);
        if(len)
          Fwrite(file_w, len, buf);
      }
      while(len == 512);
      Fclose(file_w);
    }
    else
      board_printf("Cannot create file\r\n");    
    Fclose(file_r);
  }
  else
    board_printf("File not found\r\n");
}

static void uif_cmd_ls(int argc, char **argv)
{
  int i, err;
  static DTAINFO dta;
  char name[14];
  if(argc);
  if(argv);
  Fsetdta(&dta);
  if(argc > 1)
    err = Fsfirst(argv[1], FA_SUBDIR|FA_SYSTEM|FA_HIDDEN|FA_RO);
  else
    err = Fsfirst(".\\*.*", FA_SUBDIR|FA_SYSTEM|FA_HIDDEN|FA_RO);
  while(!err)
  {
    if(dta.dt_fname[0] == '.')
    {
      err = Fsnext();
      continue;
    }
    if(dta.dt_fattr & FA_ARCHIVE)
      board_printf("a");
    else
      board_printf("-");
    if(dta.dt_fattr & FA_SUBDIR)
      board_printf("d");
    else
      board_printf("-");
    if(dta.dt_fattr & FA_VOL)
      board_printf("v");
    else
      board_printf("-");
    if(dta.dt_fattr & FA_SYSTEM)
      board_printf("s");
    else
      board_printf("-");
    if(dta.dt_fattr & FA_HIDDEN)
      board_printf("h");
    else
      board_printf("-");
    if(dta.dt_fattr & FA_RO)
      board_printf("r");
    else
      board_printf("-");
    i = 0;
    while(dta.dt_fname[i])
    {
      if((dta.dt_fname[i] >= 'A') && (dta.dt_fname[i] <= 'Z'))
        name[i] = dta.dt_fname[i] + 0x20;
      else
        name[i] = dta.dt_fname[i];
      i++;
    }
    name[i] = '\0';
    board_printf(" %d\t%02d/%02d/%04d %02d:%02d\t%s\r\n",
     (int)dta.dt_fileln,
     (int)dta.dt_date & 0x1F,
     (int)(dta.dt_date >> 5) & 0xF,
     (int)((dta.dt_date >> 9) & 0x3F) + 1980,
     (int)(dta.dt_time >> 11) & 0x1F,
     (int)(dta.dt_time >> 5) & 0x3F,
     name);
    err = Fsnext();
  }
}

static void uif_cmd_mkdir(int argc, char **argv)
{
  int err;
  if(argc);
  if((err = Dcreate(argv[1])) < 0)
    board_printf("Cannot create directory %s (error: %d)\r\n", argv[1], err);
}

static void uif_cmd_mv(int argc, char **argv)
{
  int err;
  if(argc);
  if((err = Frename(argv[1], argv[2])) < 0)
    board_printf("Cannot rename file %s to %s (error: %d)\r\n", argv[1], argv[2], err);
}

static void uif_cmd_rm(int argc, char **argv)
{
  int err;
  if(argc);
  if((err = Fdelete(argv[1])) < 0)
    board_printf("Cannot remove file %s (error: %d)\r\n", argv[1], err);
}

static void uif_cmd_rmdir(int argc, char **argv)
{
  int err;
  if(argc);
  if((err = Ddelete(argv[1])) < 0)
    board_printf("Cannot remove directory %s (error: %d)\r\n", argv[1], err);
}

/*---------------------------------------------------------------------*/
/* Fonction arp                                                        */
/*---------------------------------------------------------------------*/

static void uif_cmd_arp(int argc, char **argv)
{
  extern struct netif *netif_list;
  struct netif *netif;
  struct in_addr addr;
  struct ip_addr ipaddr;
  struct eth_addr *eth_ret;
  struct ip_addr *ip_ret;
  if(strcmp(argv[1], "-a") == 0)
  {
    argc--;
    argv++;
  }
  if(argc == 2)
  {
    if(netif_list != NULL)
    {
      for(netif = netif_list; netif != NULL; netif = netif->next)
      {
        if((netif->name[0] == 'l') && (netif->name[1] == 'o'))
          continue;
        addr.s_addr = netif->ip_addr.addr;
        board_printf("Interface: %s:\r\n", inet_ntoa(addr));
        addr.s_addr = inet_addr(argv[1]);
        ipaddr.addr = addr.s_addr;
        if(etharp_find_addr(netif, &ipaddr, &eth_ret, &ip_ret) >= 0)
          board_printf(" %s at %02X:%02X:%02X:%02X:%02X:%02X\r\n", inet_ntoa(addr),
           eth_ret->addr[0], eth_ret->addr[1], eth_ret->addr[2],
           eth_ret->addr[3], eth_ret->addr[4], eth_ret->addr[5]);
      } 
    }
  }
  else
  {
    char i;
    if(netif_list != NULL)
    {
      for(netif = netif_list; netif != NULL; netif = netif->next)
      {
        if((netif->name[0] == 'l') && (netif->name[1] == 'o'))
          continue;
        addr.s_addr = netif->ip_addr.addr;
        board_printf("Interface: %s:\r\n", inet_ntoa(addr));
        i = 0;
        while((i = etharp_find_index_addr(netif, i, &eth_ret, &ip_ret)) >= 0)
        {
          addr.s_addr = ip_ret->addr;
          board_printf(" %s at %02X:%02X:%02X:%02X:%02X:%02X\r\n", inet_ntoa(addr),
           eth_ret->addr[0], eth_ret->addr[1], eth_ret->addr[2],
           eth_ret->addr[3], eth_ret->addr[4], eth_ret->addr[5]);
          i++;
        }
      }
    }  
  }
}

/*---------------------------------------------------------------------*/
/* Fonction ifconfig                                                   */
/*---------------------------------------------------------------------*/

static void ife_print(struct netif *ptr)
{
  struct in_addr addr;
  board_printf("%c%c%d  ", ptr->name[0], ptr->name[1], ptr->num);
  board_printf("flags=%d ( ", ptr->flags);
  if(ptr->flags == 0)
    board_printf("[NO FLAGS] ");
  if(ptr->flags & NETIF_FLAG_UP)
    board_printf("UP ");
  if(ptr->flags & NETIF_FLAG_BROADCAST)
    board_printf("BROADCAST ");
  if(ptr->flags & NETIF_FLAG_POINTTOPOINT)
    board_printf("POINTOPOINT ");
  if(ptr->flags & NETIF_FLAG_LINK_UP)
    board_printf("RUNNING ");
  board_printf(")  mtu %d \r\n", ptr->mtu);
  addr.s_addr = ptr->ip_addr.addr;
  board_printf("     inet %s  ", inet_ntoa(addr));
  addr.s_addr = ptr->netmask.addr;
  board_printf(" netmask %s  ", inet_ntoa(addr));
  addr.s_addr = ptr->gw.addr;
  board_printf(" gateway %s", inet_ntoa(addr));
  board_printf("\r\n");
  if((ptr->hwaddr[0] != 0) || (ptr->hwaddr[1] != 0) || (ptr->hwaddr[2] != 0)
   || (ptr->hwaddr[3] != 0) || (ptr->hwaddr[4] != 0) || (ptr->hwaddr[5] != 0))
    board_printf("     ether %02X:%02X:%02X:%02X:%02X:%02X\r\n",
     ptr->hwaddr[0], ptr->hwaddr[1], ptr->hwaddr[2], ptr->hwaddr[3], ptr->hwaddr[4], ptr->hwaddr[5]);
}

static int if_print(char *ifname)
{
  int res = 0; 
  if(!ifname)
  {
    extern struct netif *netif_list;
    struct netif *netif;
    if(netif_list != NULL)
    {
      for(netif = netif_list; netif != NULL; netif = netif->next) 
        ife_print(netif);
    }
    else
      res = -1;
  }
  else
  {
    struct netif *ife = netif_find(ifname);
    if(ife != NULL)
      ife_print(ife);
    else
      res = -1;
  }
  return(res);
}

/* Set a certain interface flag. */
static int netif_set_flag(char *ifname, int flag)
{
  struct netif *ifr = netif_find(ifname);
  if(ifr == NULL)
    return(-1);
  switch(flag)
  {
    case NETIF_FLAG_UP: netif_set_up(ifr); break;
    default : return(-1);
  }
  return(0);
}

/* Clear a certain interface flag. */
static int netif_clr_flag(char *ifname, int flag)
{
  struct netif *ifr = netif_find(ifname);
  if(ifr == NULL)
    return(-1);
  switch(flag)
  {
    case NETIF_FLAG_UP: netif_set_down(ifr); break;
    default : return(-1);
  }
  return(0);
}

static void usage_ifconfig(void)
{
  board_printf("Usage:\r\n  ifconfig [-a] <interface>\r\n");
  board_printf("  [dstaddr <address>]  [netmask <address>]  [gateway <address>]  [up|down]\r\n\n");
}

static void uif_cmd_ifconfig(int argc, char **argv)
{
#define IFNAMSIZ 4
  char ifr_name[IFNAMSIZ];
  int opt_a = 0;      /* show all interfaces */
  struct netif *netif;
  struct ip_addr addr;
  char host[64];
  int goterr = 0;
  char **spp;
  /* Find any options. */
  argc--;
  argv++;
  while(argc && *argv[0] == '-')
  {
    if(!strcmp(*argv, "-a"))
      opt_a = 1;
    if(!strcmp(*argv, "-?") || !strcmp(*argv, "-h")
     || !strcmp(*argv, "-help") || !strcmp(*argv, "--help"))
    {
      usage_ifconfig();
      return;
    }
    argv++;
    argc--;
  }
  /* Do we have to show the current setup? */
  if(argc == 0)
  {
    if_print((char *) NULL);
    return;
  }
  /* No. Fetch the interface name */
  spp = argv;
  strncpy(ifr_name, *spp++, IFNAMSIZ);
  if(*spp == NULL)
  {
    if_print(ifr_name);
    return;
  }
  /* Process the remaining arguments */
  while(*spp != NULL)
  {
    if(!strcmp(*spp, "up"))
      goterr = netif_set_flag(ifr_name, NETIF_FLAG_UP);
    else if(!strcmp(*spp, "down"))
      goterr = netif_clr_flag(ifr_name, NETIF_FLAG_UP);
    else if(!strcmp(*spp, "dstaddr"))
    {
      if(*++spp == NULL)
      {
        usage_ifconfig();
        return;
      }
      strncpy(host, *spp, (sizeof host));  
      netif = netif_find(ifr_name);
      addr.addr = inet_addr(host);
      if(netif != NULL)
        netif_set_ipaddr(netif, &addr);
      else
        goterr = -1;
    }
    else if(!strcmp(*spp, "netmask"))
    {
      if(*++spp == NULL)
      {
        usage_ifconfig();
        return;
      }
      strncpy(host, *spp, (sizeof host));
      netif = netif_find(ifr_name);
      addr.addr = inet_addr(host);
      if(netif != NULL)
        netif_set_netmask(netif, &addr);
      else
        goterr = -1;
    }
    else if(!strcmp(*spp, "gateway"))
    {
      if(*++spp == NULL)
      {
        usage_ifconfig();
        return;
      }
      strncpy(host, *spp, (sizeof host));  
      netif = netif_find(ifr_name);
      addr.addr = inet_addr(host);
      if(netif != NULL)
        netif_set_gw(netif, &addr);
      else
        goterr = -1;
    }
    if(goterr)
    {
      board_printf("Error: Interface %s not found\r\n", ifr_name);
      return;
    }
    spp++;
  }
}

/*---------------------------------------------------------------------*/
/* Fonction ping                                                       */
/*---------------------------------------------------------------------*/

// Structure de l'en-tête IP
typedef struct iphdr
{
  unsigned int version:4; // !!!!
  unsigned int h_len:4;   // swap if big-endian ????
  unsigned char tos:8;
  unsigned short total_len:16;
  unsigned short ident:16;
  unsigned short offset:16;
  unsigned char ttl:8;
  unsigned char proto:8;
  unsigned short checksum:16;
  unsigned int sourceIP:32;
  unsigned int destIP:32;
} IpHeader __attribute__((__packed__));

// Structure de l'en-tête ICMP
typedef struct icmphdr
{
  unsigned char type:8;
  unsigned char code:8;
  unsigned short checksum:16;
  unsigned short id;
  unsigned short sequence;
  unsigned long timestamp;
} IcmpHeader __attribute__((__packed__));

#define MAX_PACKET 1024
#define DATASIZE_ICMP 16
#define NBDEFAULT 4
#define DELAI 1000
#define IPPROTO_ICMP            1               /* control message protocol */

#if 0
// Définition des messages d'erreur
char Erreur3[16][55]=
{
  "Reseau inaccessible",
  "Impossible de joindre l'hote de destination",
  "Protocole inaccessible",
  "Port inaccessible",
  "Fragmentation necessaire",
  "Echec de la route source",
  "Reseau de destination inconnu",
  "Machine de destination inconnue",
  "Machine source isolee",
  "Reseau de destination administrativement interdit",
  "Machine de destination administrativement interdite",
  "Reseau inaccessible pour TOS",
  "Machine inaccessible pour TOS",
  "Communication administrativement interdite par filtrage",
  "Violation de la precedence de la machine",
  "Coupure de la precedence en action"
};

char Erreur4[1][16]=
{
  "Debit trop eleve"
};

char Erreur5[4][40]=
{
  "Redirige pour un reseau",
  "Redirige pour une machine",
  "Redirige pour type de service et reseau",
  "Redirige pour type de service et machine"
};

char Erreur11[2][40]=
{
  "Time-to-live a 0 pendant le transit",
  "Time-to-live a 0 pendant le reassemblage"
};

char Erreur12[2][25]=
{
  "Mauvais en-tete IP",
  "Option requise manquante"
};
#endif

static unsigned short checksum(unsigned short *, int);
static unsigned long GetTickCount(void);

static int max, min, moyenne, envoye, perte;

static void uif_cmd_ping(int argc, char **argv)
{
// Définition des différentes variables
  unsigned long IP;
  struct ip_addr xIpAddr;
  int sock;
  struct sockaddr_in sin, from;
  int envoi, recept;
  IcmpHeader *icmp_hdr;
  char ascii_IP[16];
  char icmp_data[DATASIZE_ICMP];
  char recvbuf[MAX_PACKET];
  int fromlen = sizeof(from);
  fd_set fdsr;
  struct timeval tv_timeout;
  int Nbping = 0;
  int id, i, taille;
  int recus, pourcent;
  int findelai, tpslimite = 0;
  min = 0x7ffffff;
  max = moyenne = envoye = perte = recus = pourcent = 0;  
  // Accès à l'aide
  if(argc < 2 || strcmp(argv[1],"--help") == 0)
  {
    board_printf("Usage : ping <-n echos> <-w delay> host\r\n");
    return;
  }
  // Identification des différentes options
  for(i = 1; i < argc; i++)
  {
    if(strcmp(argv[i],"-n") == 0)
      Nbping = (int)atol(argv[i+1]);
    if(strcmp(argv[i],"-w") == 0)
      tpslimite = (int)atol(argv[i+1]);
  }
  sock = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
  if(sock == -1)
    return;
  memset(&sin,0,sizeof(sin));
  // Récupération de l'IP
  if(!inet_aton(argv[argc-1],&sin.sin_addr))
    return;
  sin.sin_family = AF_INET;
  taille = sizeof(IpHeader) + sizeof(IcmpHeader);
  strcpy(ascii_IP, inet_ntoa(sin.sin_addr));
  board_printf("Envoi d'une requete 'ping' sur %s avec %d octets de donnees :\r\n\r\n", ascii_IP, taille);
  board_get_client((unsigned char *)&IP);
  xIpAddr.addr = htonl(IP);
  if(sin.sin_addr.s_addr == xIpAddr.addr)
    sin.sin_addr.s_addr = INADDR_LOOPBACK;
  // Initialisation du nombre de ping à faire
  if(Nbping == 0)
    Nbping = NBDEFAULT;
  // Initialisation du délai d'attente
  if(tpslimite == 0)
    tpslimite = DELAI;
  while(envoye != Nbping)
  {
    memset(icmp_data,0,DATASIZE_ICMP);
    id =(unsigned short)((int)pxCurrentTCB + envoye);
    // Construction du paquet ICMP
    icmp_hdr = (IcmpHeader*)icmp_data;
    icmp_hdr->type = 8; // Type du paquet ICMP : echo request
    icmp_hdr->code = 0; // Il n'y a pas de code spécifique pour ce type de paquet
    icmp_hdr->id = id;
    icmp_hdr->sequence = 1;
    icmp_hdr->timestamp = GetTickCount(); // Initialisation du temps lors de l'envoi
    // Somme de contrôle sur 16 bits
    ((IcmpHeader*)icmp_data)->checksum = checksum((unsigned short*)icmp_data, DATASIZE_ICMP);  
    // On envoie le paquet ICMP que l'on a construit
    envoi = sendto(sock, icmp_data, DATASIZE_ICMP, 0, (struct sockaddr *)&sin, DATASIZE_ICMP);
    findelai = 0;
    do
    {
      FD_ZERO(&fdsr);
      FD_SET(sock, &fdsr);
      tv_timeout.tv_sec = tpslimite/1000;
      tv_timeout.tv_usec = 0;
      if((i = select(FD_SETSIZE, &fdsr, NULL, NULL, &tv_timeout)) <= 0)
      {
        // Dans le cas où le temps est écoulé, on veut sortir de la boucle
        // on compte le paquet comme envoyé mais perdu
        board_printf("Delai d'attente de la demande depasse.\r\n");
        perte++;
        envoye++;
        findelai = 1;
      }
      if((i > 0) && FD_ISSET(sock, &fdsr))
      {
        IpHeader *iphdr;
        IcmpHeader *icmphdr;
        unsigned short iphdrlen;
        int ttl, time, taille;
        char tps[32];
        char buffer[32];
        // Dans le cas où le buffer du socket contient des données, on les décode
        recept = recvfrom(sock, recvbuf, MAX_PACKET, 0, (struct sockaddr *)&from, &fromlen);
        // Décodage du paquet ICMP de réponse
        iphdr = (IpHeader *)recvbuf;
        iphdrlen = iphdr->h_len * 4 ;
        icmphdr = (IcmpHeader*)(recvbuf + iphdrlen);
        if(id != (icmphdr->id))
          findelai = 0;     // Cas où le paquet n'est pas à nous
        else
        {
          findelai = 1;
          envoye++;
          if((icmphdr->type != 8) && (icmphdr->type != 0))
            board_printf("Reponse de %s : ", ascii_IP); 
          switch(icmphdr->type)
          {
#if 0
            case 3:
              board_printf("%s.\r\n", Erreur3[icmphdr->code]);
              break;
            case 4:
              board_printf("%s.\r\n", Erreur4[icmphdr->code]);
              break;
            case 5:
              board_printf(" %s.\r\n", Erreur5[icmphdr->code]);
              break;
            case 11:
              board_printf("%s.\r\n", Erreur11[icmphdr->code]);
              break;
            case 12:
              board_printf("%s.\r\n", Erreur12[icmphdr->code]);
              break;
#else
            case 3:
            case 4:
            case 5:
            case 11:
            case 12:
              board_printf("Erreur %d.\r\n", icmphdr->code);
              break;
#endif
            case 0:
            case 8:
              if((icmphdr->code) == 0)
              {
                ttl = (iphdr->ttl);
                time = GetTickCount(); // Récupération du temps courant
                time -= (icmphdr->timestamp); // Différence entre réception et émission
                if(time > 1000/configTICK_RATE_HZ)
                {
                  strcpy(tps, "=");
                  sprintD(buffer, "%d", time);
                  strcat(tps, buffer);
                }
                else
                {
                  strcpy(tps, "<");
                  sprintD(buffer, "%d", (int)(1000/configTICK_RATE_HZ));
                  strcat(tps, buffer);
                  time = 0;
                }
                if(time > max)
                   max = time;
                if(time < min)
                  min = time;
                moyenne += time;
                taille = iphdrlen + sizeof(IcmpHeader);
                board_printf("Reponse de %s: icmp=%d octets=%d ", ascii_IP, envoye, taille);
                board_printf("temps%s ms TTL=%d\r\n", tps, ttl);
              }
              break;
            default:
              // Cas où le type n'est pas une erreur reconnue par la RFC (cas très improblable !!!)
              board_printf("Erreur inconnue.\r\n");
              break;
          }   
        }
        memset(recvbuf,0,MAX_PACKET);
      }
      if(auxistat() && ((rs232get() & 0xFF) == CTRL_C))
         Nbping = envoye;
    }
    while(findelai == 0);
    // Latence d'une seconde entre chaque ping
    if(envoye != Nbping)
      vTaskDelay(configTICK_RATE_HZ);    
  }
  board_printf("\n\rStatistiques Ping pour %s :\r\n",ascii_IP);
  recus = envoye-perte;
  pourcent = (perte*100)/envoye;
  board_printf(" Paquets : envoyes = %d, recus = %d, perdus = %d (perte %d%%),\r\n", envoye, recus, perte, pourcent);
  board_printf("Duree approximative des boucles en millisecondes :\r\n");
  if(recus!=0)
    moyenne=moyenne/recus;
  if(min > max)
    min = 0;
  board_printf(" minimum = %dms, maximum = %dms, moyenne = %dms\r\n", min, max, moyenne);
  board_printf("\r\n");
}

static unsigned long GetTickCount(void)
{
  return(xTaskGetTickCount() * (1000 / configTICK_RATE_HZ));
}

// Fonction faisant la somme de contrôle sur 16 bits
static unsigned short checksum(unsigned short *buffer, int size)
{
  unsigned long cksum=0;
  while(size >1)
  {
    cksum+=*buffer++;
    size -=sizeof(unsigned short);
  }
  if(size)
    cksum += *(unsigned char*)buffer;
  cksum = (cksum >> 16) + (cksum & 0xffff);
  cksum += (cksum >>16);
  return (unsigned short)(~cksum);
}

static void uif_cmd_stats(int argc, char **argv)
{
  if(argc);
  if(argv);
  stats_display();
}

static void uif_cmd_cache(int argc, char **argv)
{
  if(argc);
  if((argc == 2) && (strcmp(argv[1],"on") == 0))
     enable_caches();
  else if((argc == 2) && (strcmp(argv[1],"off") == 0))
     disable_caches();
  else if(argc < 2)
  {
    unsigned long cacr = *(unsigned long *)(library_data_area + 96); // CACR cf68klib
    board_printf("CACR: 0x%08X\r\n", cacr);  
  }
  else
    board_printf("Usage : cache <on/off>\r\n");
}

static void uif_cmd_debug(int argc, char **argv)
{
  int success;
  unsigned long val;
  unsigned char debug = *(unsigned char *)(debug_cf68klib);
  if(strcmp(argv[1],"on") == 0)
  {
    if(!debug)
    {
      if(argc == 3)
      {
        val = get_value(argv[2],&success,10);
        if(val > 255) /* 0 => infinite */
          val  = 255;
        *(unsigned char *)(debug_cf68klib_count) = (unsigned char)val;
      }
      else
        *(unsigned char *)(debug_cf68klib_count) = 255;
      *(unsigned char *)(debug_cf68klib) = 1;      
    }
  }
  else if(strcmp(argv[1],"off") == 0)
  {
    if(debug)
       *(unsigned char *)(debug_cf68klib) = *(unsigned char *)(debug_cf68klib_count) = 0;
  }
  else
    board_printf("Usage : debug on/off\r\n");
}

static void uif_cmd_inter(int argc, char **argv)
{
  if((argc == 2) && strcmp(argv[1],"on") == 0)
    install_inters_cf68klib();
  else if((argc == 2) && strcmp(argv[1],"off") == 0)
    deinstall_inters_cf68klib();
#ifdef MCF5445X
  else if((argc == 2) && strcmp(argv[1],"abort") == 0)
  {
    int level = vPortSetIPL(portIPL_MAX);
    *(unsigned char *)(debug_int7) = 1;
    /* Enable EPORT interrupt 7 requests */
    MCF_EPORT_EPIER |= EPORT_EPIER_EPIE7;
    /* Allow interrupts from IRQ7 */
    MCF_INTC_IMRL0 &= ~INTC_IMRL_INT_MASK7;
    save_imrl0 = MCF_INTC_IMRL0;
    vPortSetIPL(level);
  }
  else
    board_printf("Usage : inter on/off/abort\r\n");
#else /* MCF548X */
  else if((argc == 2) && strcmp(argv[1],"abort") == 0)
  {
    int level = vPortSetIPL(portIPL_MAX);
    *(unsigned char *)(debug_int7) = 1;
    /* Enable EPORT interrupt 7 requests */
    MCF_EPORT_EPIER |= MCF_EPORT_EPIER_EPIE7;
    /* Allow interrupts from IRQ7 */
    MCF_INTC_IMRL &=  ~MCF_INTC_IMRL_INT_MASK7;
    save_imrl = MCF_INTC_IMRL;
    vPortSetIPL(level);
  }
  else if(argc < 2)
  {
    static char *names_int[] = {
     "",            /* 64 */
     "Edge port 1", /* 65 */
     "Edge port 2", /* 66 */
     "Edge port 3", /* 67 */
     "Edge port 4", /* 68 */
     "Edge port 5", /* 69 */
     "Edge port 6", /* 70 */
     "Edge port 7", /* 71 */
     "",            /* 72 */
     "",            /* 73 */
     "",            /* 74 */
     "",            /* 75 */
     "",            /* 76 */
     "",            /* 77 */
     "",            /* 78 */
     "USB 2.0",     /* 79 */
     "USB 2.0",     /* 80 */
     "USB 2.0",     /* 81 */
     "USB 2.0",     /* 82 */
     "USB 2.0",     /* 83 */
     "USB 2.0",     /* 84 */
     "USB 2.0",     /* 85 */
     "USB 2.0",     /* 86 */     
     "USB 2.0",     /* 87 */
     "USB 2.0",     /* 88 */
     "DSPI",        /* 89 */
     "DSPI",        /* 90 */
     "DSPI",        /* 91 */       
     "DSPI",        /* 92 */
     "DSPI",        /* 93 */
     "DSPI",        /* 94 */  
     "DSPI",        /* 95 */
     "PSC3",        /* 96 */
     "PSC2",        /* 97 */
     "PSC1",        /* 98 */
     "PSC0",        /* 99 */
     "Comm Timer",  /* 100 */
     "SEC",         /* 101 */
     "FEC1",        /* 102 */
     "FEC0",        /* 103 */
     "I2C",         /* 104 */
     "PCIARB",      /* 105 */
     "CBPCI",       /* 106 */
     "XLBPCI",      /* 107 */
     "",            /* 108 */
     "",            /* 109 */
     "",            /* 110 */
     "XLBARB",      /* 111 */
     "DMA",         /* 112 */
#ifdef MCF547X
     "",            /* 113 */
     "",            /* 114 */
     "",            /* 115 */
#else /* MCF548X */
     "CAN0 ERROR",  /* 113 */
     "CAN0 BUSOFF", /* 114 */
     "CAN0 MBOR",   /* 115 */
#endif /* MCF547X */
     "",            /* 116 */
     "SLT1",        /* 117 */
     "SLT0",        /* 118 */
#ifdef MCF547X
     "",            /* 119 */
     "",            /* 120 */
     "",            /* 121 */
#else /* MCF548X */
     "CAN1 ERROR",  /* 119 */
     "CAN1 BUSOFF", /* 120 */
     "CAN1 MBOR",   /* 121 */
#endif /* MCF547X */
     "",            /* 122 */
     "GPT3",        /* 123 */
     "GPT2",        /* 124 */
     "GPT1",        /* 125 */
     "GPT0",        /* 126 */
     ""             /* 127 */
    };
    int i;
    board_printf("NATIVE/RTOS\tCF68KLIB/TOS\tLEV\tPRI\tINTERRUPTS\r\n");
    for(i = 0; i < 64; i++)
    {
      if(strlen(names_int[i]))
      {
        if(i < 32) 
          board_printf("%s\t\t%s\t\t%d\t%d\t%s Int(%d)\r\n",
           !(save_imrl & (1 << i)) ? "ON" : "OFF",
           !(save_imrl_tos & (1 << i)) ? "ON" : "OFF",
           (MCF_INTC_ICRn(i) >> 3) & 7, MCF_INTC_ICRn(i) & 7, 
           names_int[i], i + 64);
        else
          board_printf("%s\t\t%s\t\t%d\t%d\t%s Int(%d)\r\n",
           !(save_imrh & (1 << (i - 32))) ? "ON" : "OFF",
           !(save_imrh_tos & (1 << (i - 32))) ? "ON" : "OFF",
           (MCF_INTC_ICRn(i) >> 3) & 7, MCF_INTC_ICRn(i) & 7, 
           names_int[i], i + 64);
      }
    }
  }
  else
    board_printf("Usage : inter <on/off>\r\n");
#endif /* MCF5445X */
}

static void uif_cmd_reset(int argc, char **argv)
{
  if(argc);
  if(argv);
  board_putchar('\r');
  board_putchar('\n');
  board_putchar_flush();
  (void)vPortSetIPL(portIPL_MAX);
  /* Watchdog Reset */
#ifdef MCF5445X
  MCF_INTC_IMRH0 = MCF_INTC_IMRL0 = MCF_INTC_IMRH1 = MCF_INTC_IMRL1 = 0xFFFFFFFF;
  MCF_SCM_CWCR = SCM_CWCR_CWE | SCM_CWCR_CWRI(2) | SCM_CWCR_CWT(8);
#else /* MCF548X */
  MCF_INTC_IMRH = MCF_INTC_IMRL = 0xFFFFFFFF;
  MCF_GPT_GMS(0) = 0;
  MCF_GPT_GCIR(0) = 10 | (SYSTEM_CLOCK << 16); /* 10 uS */
  MCF_GPT_GMS(0) = MCF_GPT_GMS_TMS_GPIO | MCF_GPT_GMS_CE | MCF_GPT_GMS_WDEN; /* watchdog timer */
#endif /* MCF5445X */
  while(1)
  {
		asm volatile(" nop\n\t");  
  }
}

static void uif_cmd_trap(int argc, char **argv)
{
  int success;
  unsigned long val;
  unsigned char debug = *(unsigned char *)(debug_trap);
  if(strcmp(argv[1],"on") == 0)
  {
    if(!debug)
    {
      if(argc == 3)
      {
        val = get_value(argv[2],&success,10);
        if(val > 255) /* 0 => infinite */
          val  = 255;
        *(unsigned char *)(debug_trap_count) = (unsigned char)val;
      }
      else
        *(unsigned char *)(debug_trap_count) = 255;
      *(unsigned char *)(debug_trap) = 1;      
    }
  }
  else if(strcmp(argv[1],"off") == 0)
  {
    if(debug)
       *(unsigned char *)(debug_trap) = *(unsigned char *)(debug_trap_count) = 0;
  }
  else
    board_printf("Usage : trap on/off\r\n");
}

static UIF_CMD UIF_CMDTAB[] =
{
  /* <1> command name user types, ie. GO  */
  /* <2> num chars to uniquely match      */
  /* <3> min num of args command accepts  */
  /* <4> max num of args command accepts  */
  /* <5> command flags (repeat, hidden)   */
  /* <6> actual function to call          */
  /* <7> brief description of command     */
  /* <8> syntax of command                */
#ifndef MCF5445X
#ifdef SOUND_AC97
  {"acpr",4,1,2,0,uif_cmd_ac97_pr,"AC97 Patch Register","addr <data>"},
#endif
#endif
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
  {"usb",3,0,4,0,uif_cmd_usb,"USB sub-system","<cmd ...>"},
#endif
  {"cb",2,0,1,0,uif_cmd_cb,"Clear Breakpoint","<index>"},
  {"db",2,0,UIF_MAX_ARGS-1,0,uif_cmd_db,"Define Breakpoint","<addr> <-c|t value> <-r addr..> <-i> <-m>"},
  {"dm",2,0,2,UIF_CMD_FLAG_REPEAT,uif_cmd_md,"Display Memory","begin <end>"},
  {"md",2,0,2,UIF_CMD_FLAG_REPEAT|UIF_CMD_FLAG_HIDDEN,uif_cmd_md,"Memory Display","begin <end>"},
  {"dis",2,0,1,UIF_CMD_FLAG_REPEAT,uif_cmd_dis,"Disassemble","<addr>"},
  {"dr",2,0,0,0,uif_cmd_dr,"Display Registers CF68KLIB",""},
  {"go",1,0,1,0,uif_cmd_go,"Execute, Insert Breakpt",""},
  {"lb",2,0,0,0,uif_cmd_lb,"List Breakpoints",""},
  {"pm",2,1,2,0,uif_cmd_pm,"Patch Memory","addr <data>"},
  {"qt",2,0,0,UIF_CMD_FLAG_REPEAT,uif_cmd_qt,"Query Tasks",""},
  {"st",2,0,1,UIF_CMD_FLAG_REPEAT,uif_cmd_st,"Single Step (after db)","<count>"},
//  {"trace",2,1,3,0,uif_cmd_trace,"Task Trace","on/off <file> <size>"},
  {"cat",2,1,UIF_MAX_ARGS-1,0,uif_cmd_cat,"Concatenate File(s)","file(s)"},
  {"cd",2,1,1,UIF_CMD_FLAG_HIDDEN,uif_cmd_chdir,"Change Directory","dir"},
  {"chdir",2,1,1,0,uif_cmd_chdir,"Change Directory","dir"},
  {"chmod",5,2,2,0,uif_cmd_chmod,"Change Attibutes","filename attributes"},
  {"cp",2,2,2,0,uif_cmd_cp,"Copy File","source dest"},
  {"copy",4,2,2,UIF_CMD_FLAG_HIDDEN,uif_cmd_cp,"Copy File","source dest"},
  {"del",3,1,1,UIF_CMD_FLAG_HIDDEN,uif_cmd_rm,"Remove File","file"},
  {"dir",3,0,1,UIF_CMD_FLAG_HIDDEN,uif_cmd_ls,"List Directory","<dir>"},
  {"ls",2,0,1,0,uif_cmd_ls,"List Directory","<dir>"},
  {"mkdir",2,1,1,0,uif_cmd_mkdir,"Make Directory","dir"},
  {"mv",2,2,2,0,uif_cmd_mv,"Rename File","source dest"},
  {"rename",3,2,2,UIF_CMD_FLAG_HIDDEN,uif_cmd_mv,"Rename File","source dest"},
  {"rm",2,1,1,0,uif_cmd_rm,"Remove File","file"},
  {"rmdir",2,1,1,0,uif_cmd_rmdir,"Remove Directory","dir"},
  {"type",4,1,UIF_MAX_ARGS-1,UIF_CMD_FLAG_HIDDEN,uif_cmd_cat,"Concatenate File(s)","file(s)"},
  {"arp",2,0,2,0,uif_cmd_arp,"Address Resol. Protocol","<-a> <host>"},
  {"ifconfig",2,0,UIF_MAX_ARGS-1,0,uif_cmd_ifconfig,"Interface Configuration","<-a> <interface> ..."},
  {"ping",2,1,5,0,uif_cmd_ping,"Ping","<-n echos> <-w delay> host"},
  {"netstat",2,0,0,0,uif_cmd_stats,"Network Stats",""},
  {"cache",2,0,1,0,uif_cmd_cache,"Cache","<on/off>"},
  {"debug",2,1,2,0,uif_cmd_debug,"Debug CF68KLIB","on/off <count (0:infinite)>"},
  {"inter",2,0,1,0,uif_cmd_inter,"Interrupts CF68KLIB","<on/off/abort>"},
  {"reset",5,0,0,0,uif_cmd_reset,"System Reset",""},
  {"shutdown",8,0,0,UIF_CMD_FLAG_HIDDEN,uif_cmd_reset,"System Reset",""},
  {"trap",4,1,2,0,uif_cmd_trap,"Traps CF68KLIB","on/off <count (0:infinite)>"},
  {"help",2,0,1,0,uif_cmd_help,"Help","<cmd>"},
};
static const int UIF_NUM_CMD = UIF_CMDTAB_SIZE;

static void help_display(int index)
{
  board_printf(HELPFORMAT, UIF_CMDTAB[index].cmd, UIF_CMDTAB[index].description,
   UIF_CMDTAB[index].cmd, UIF_CMDTAB[index].syntax);
}

static void uif_cmd_help(int argc, char **argv)
{
  int index, displayed;
  if(argc == 1)
  {
    /* Display all command summaries */
    board_printf(HELPFORMAT,"Command","Description","Syntax","");
    displayed = 1;
    for(index = 0; index < UIF_NUM_CMD; index++)
    {
      if(!(UIF_CMDTAB[index].flags & UIF_CMD_FLAG_HIDDEN))
        help_display(index);
    }
    return;
  }
  else
  {
    /* Display specific command summary */
    for(index = 0; index < UIF_NUM_CMD; index++)
    {
      if(strcasecmp(UIF_CMDTAB[index].cmd,argv[1]) == 0)
      {
        board_printf(HELPFORMAT,"Command","Description","Syntax","");
        help_display(index);
        return;
      }
    }
    for(index = 0; index < UIF_NUM_CMD; index++)
    {
      if(strncasecmp(UIF_CMDTAB[index].cmd,argv[1], UIF_CMDTAB[index].unique) == 0)
      {
        board_printf(HELPFORMAT,"Command","Description","Syntax","");
        help_display(index);
        return;
      }
    }
    board_printf(INVCMD,argv[1]);
  }
}

static int make_argv(char *cmdline, char *argv[])
{
  int argc, i, in_text;
  /* break cmdline into strings and argv */
  /* it is permissible for argv to be NULL, in which case */
  /* the purpose of this routine becomes to count args */
  argc = 0;
  i = 0;
  in_text = FALSE;
  while(cmdline[i] != '\0')  /* getline() must place 0x00 on end */
  {
    if(((cmdline[i] == ' ') || (cmdline[i] == '\t')) )
    {
      if(in_text)
      {
        /* end of command line argument */
        cmdline[i] = '\0';
        in_text = FALSE;
      }
      else
      {
        /* still looking for next argument */
      }
    }
    else
    {
      /* got non-whitespace character */
      if(in_text)
      {
      }
      else
      {
        /* start of an argument */
        in_text = TRUE;
        if(argc < UIF_MAX_ARGS)
        {
          if(argv != NULL)
            argv[argc] = &cmdline[i];
          argc++;
        }
        else
          /*return argc;*/
          break;
      }
    }
    i++;    /* proceed to next character */
  }
  if(argv != NULL)
    argv[argc] = NULL;
  return argc;
}

static int run_cmd(void)
{
  /* Global array of pointers to emulate C argc,argv interface */
  int argc;
  char *argv[UIF_MAX_ARGS + 1];   /* one extra for null terminator */
  get_history_line(cmdline1);
  if(!(argc = make_argv(cmdline1, argv)))
  {
    /* no command entered, just a blank line */
     strcpy(cmdline1, cmdline2);
     argc = make_argv(cmdline1, argv);
  }
  cmdline2[0] = '\0';
  if(argc)
  {
    int i;
    /*
     * First try for an exact match on command name
     */
    for(i = 0; i < UIF_NUM_CMD; i++)
    {
      if(strcasecmp(UIF_CMDTAB[i].cmd,argv[0]) == 0)
      {
        if(((argc-1) >= UIF_CMDTAB[i].min_args) && ((argc-1) <= UIF_CMDTAB[i].max_args))
        {
          if(UIF_CMDTAB[i].flags & UIF_CMD_FLAG_REPEAT)
            strcpy(cmdline2,argv[0]);
          board_putchar_flush();
          UIF_CMDTAB[i].func(argc,argv);
          return(TRUE);
        }
        else
        {
          board_printf(SYNTAX,argv[0]);
          return(TRUE);
        }
      }
    }
    /*
     * Now try for short-hand match on command name
     */
    for(i = 0; i < UIF_NUM_CMD; i++)
    {
      if(strncasecmp(UIF_CMDTAB[i].cmd,argv[0], UIF_CMDTAB[i].unique) == 0)
      {
        if(((argc-1) >= UIF_CMDTAB[i].min_args) && ((argc-1) <= UIF_CMDTAB[i].max_args))
        {
          if(UIF_CMDTAB[i].flags & UIF_CMD_FLAG_REPEAT)
            strcpy(cmdline2,argv[0]);
          board_putchar_flush();
          UIF_CMDTAB[i].func(argc,argv);
          return(TRUE);
        }
        else
        {
          board_printf(SYNTAX,argv[0]);
          return(TRUE);
        }
      }
    }
    board_printf(INVCMD,argv[0]);
    board_printf(HELPMSG);
  }
  return(FALSE);
}

/*---------------------------------------------------------------------*/
/* FTP Server                                                          */
/*---------------------------------------------------------------------*/

#ifdef FTP_SERVER
static portTASK_FUNCTION(vFTPd, pvParameters)
{
  if(pvParameters);
  ftpd_start(FTP_USERNAME, FTP_PASSWORD);
  vTaskDelete(0);
}
#endif

/*---------------------------------------------------------------------*/
/* TFTP Server                                                         */
/*---------------------------------------------------------------------*/

static portTASK_FUNCTION(vTFTPd, pvParameters)
{
  extern long ram_disk_drive;
  long file;
  unsigned long bytes_read;
  static struct sockaddr_in address, adresse, from, to;
  socklen_t lg=sizeof(struct sockaddr_in);
  socklen_t fromlen=lg, tolen=lg;
  static char buf[PKTSIZE],ackbuf[PKTSIZE];
  struct tftphdr *tp = (struct tftphdr *)&buf;
  char filename[256];
  char *dat, *cp, *p;
  struct tftphdr *dp, *ap;
  int i=0, size, Oldsize=PKTSIZE, n, ntimeout, peer, sock, nextBlockNumber;
  struct timeval tv;
  fd_set data_read;
  if(pvParameters);
  if((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
  {
    board_printf("TFTPd: create server socket error (err %d)\r\n",errno);
    vTaskDelete(0);
  }
  address.sin_family=AF_INET;
  address.sin_addr.s_addr=htonl(INADDR_ANY);
  address.sin_port=htons(PortTFTP);
  if(bind(sock, (struct sockaddr *)&address, lg) < 0)
  {
    board_printf("TFTPd: bind server error (err %d)\r\n",errno);
    close(sock);
    vTaskDelete(0);
  }
  while(1)
  {
    do
      n=recvfrom(sock, tp, PKTSIZE, 0, (struct sockaddr *)&to, &tolen);
    while(n < 0);
    tp->th_opcode = htons((u_short)tp->th_opcode);
    cp = (char *)&tp->th_stuff[0];
    p = &cp[SEGSIZE-5];
    while((cp < p) && *cp && (*cp != ' '))
      cp++;
    if(*cp && (*cp != ' ')) 
      continue;
    *cp = '\0';
    filename[0] = 'C';
    filename[1] = ':';
    filename[2] = '\\';
    filename[3] = '\0';
    if(ram_disk_drive >= 1)
  	  filename[0] =(char)ram_disk_drive + 'A';
    strcat(filename, &tp->th_stuff[0]);
    dp = (struct tftphdr *)buf;
    ap = (struct tftphdr *)ackbuf;
    dat = (char*)&dp->th_data[0]; 
    cp = (char *)&dp->th_stuff[0];
    if((peer = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
    {
      board_printf("TFTPd: create socket client error (err %d)\r\n",errno);
      continue;
    }
    adresse.sin_family=AF_INET;
    adresse.sin_addr.s_addr=htonl(INADDR_ANY);
    adresse.sin_port=htons(0);
    if(bind(peer, (struct sockaddr *)&adresse, lg) < 0)
    {
      board_printf("TFTPd: bind client error (err %d)\r\n",errno);
      close(peer);
      continue;
    }    
    switch(tp->th_opcode)
    {
      case WRQ:
        Fdelete(filename);
        if((file = Fcreate(filename, 0)) < 0)
        {
          board_printf("TFTPd: cannot create file %s\r\n", filename);
          close(peer);
          break;    
        }
        ap->th_opcode=htons((u_short)ACK);
        ap->th_block=0;
        size=4;
        nextBlockNumber = 1; 
        do 
        {    
          ntimeout = 0;
          do
          {
            if(ntimeout == NumberTimeOut)
            /* could not make connection */
              goto tftp_close;
            if(sendto(peer, ap, size, 0, (struct sockaddr *)&to, tolen) != size)
            {
              board_printf("TFTPd: sendto error\r\n");
              goto tftp_close;
            }
            do
            {
              n = -1;
              FD_ZERO(&data_read);
              FD_SET(peer, &data_read); 
              tv.tv_sec = TimeOut;
              tv.tv_usec = 0;
              if((i = select(FD_SETSIZE, &data_read, NULL, NULL, &tv)) == -1)
              {
                board_printf("TFTPd: select error (err %d)\r\n",errno);
                goto tftp_close;
              }
              if((i > 0) && FD_ISSET(peer, &data_read))
                n = recvfrom(peer, dp, PKTSIZE, 0, (struct sockaddr *)&from, &fromlen);
            }
            while((n < 0) && (i > 0));
            if(i > 0)
            {
              to.sin_port = from.sin_port;
              dp->th_opcode = ntohs((unsigned short)dp->th_opcode);            
              dp->th_block = ntohs((unsigned short)dp->th_block);
              if(dp->th_opcode != DATA) 
              {
                if(dp->th_opcode == ERROR)
                  board_printf("TFTPd: TFTP error #%d : %s\r\n",(int)dp->th_code, &dp->th_data[0]);
                goto tftp_close;
              }
              if((int)dp->th_block < nextBlockNumber)
              {
                /* Re-ACK this packet */
                ap->th_block = htons(dp->th_block);
                ap->th_opcode = htons((unsigned short)ACK);    
                if(sendto(peer, ap, 4, 0,(struct sockaddr *)&to, tolen) != size)
                {
                  // write Re-ACK error
                  board_printf("TFTPd: sendto error (err %d)\r\n",errno);
                  goto tftp_close;
                }
                continue;
              }
              else if((int)dp->th_block != nextBlockNumber)
              /* This is NOT the block number expected */
                continue;
            }
            ntimeout++;
          }
          while((int)dp->th_block != nextBlockNumber);
          ap->th_block = htons((unsigned short)nextBlockNumber);
          size = 4;
          if(n-4 > 0)
          {
            bytes_read += (n-4);
            Fwrite(file, n-4, (char *)dat);          
          }
          nextBlockNumber++;
        }
        while(n == PKTSIZE);
        /* send the "final" ack */
        sendto(peer, ap, 4, 0,(struct sockaddr *)&to, tolen);
tftp_close:
        close(peer);
        Fclose(file);
        break;
      case RRQ:
        if((file = Fopen(filename, 0)) < 0)
        {
          board_printf("TFTPd: cannot open file %s\r\n", filename);
          close(peer);
          break;    
        }
        dp->th_opcode=htons((unsigned short)DATA);
        dp->th_block=htons((unsigned short)1);      
        size = Fread(file, SEGSIZE, (char *)dat);      
        if(size == 0)
          goto tftp_close;
        size += 4;
        nextBlockNumber = 1;
        do 
        {    
          ntimeout = 0;
          do
          {
            if(ntimeout == NumberTimeOut)
            /* could not make connection */
              goto tftp_close;
            if(sendto(peer, dp, size, 0, (struct sockaddr *)&to, tolen) != size)
            {
              board_printf("TFTPd: sendto error\r\n");
              goto tftp_close;
            };      
            do
            {
              n = -1;
              FD_ZERO(&data_read);
              FD_SET(peer,&data_read); 
              tv.tv_sec = TimeOut;
              tv.tv_usec = 0;
              if((i = select(FD_SETSIZE, &data_read, NULL, NULL, &tv)) == -1)
              {
                board_printf("TFTPd: select error (err %d)\r\n",errno);
                goto tftp_close;
              }
              if((i > 0) && FD_ISSET(peer, &data_read))
                n = recvfrom(peer, ap, PKTSIZE, 0,(struct sockaddr *)&from, &fromlen);
            }
            while((n < 0) && (i > 0));
            if(i > 0)
            {
              to.sin_port=from.sin_port;
              ap->th_opcode = ntohs((unsigned short)ap->th_opcode);
              ap->th_block = ntohs((unsigned short)ap->th_block);
              if(ap->th_opcode != ACK)
              {
                if(ap->th_opcode == ERROR)
                  board_printf("TFTPd: TFTP error #%d : %s\r\n",(int)ap->th_code, &ap->th_data[0]);
                goto tftp_close;
              }
              if((int)ap->th_block < nextBlockNumber)
              {
                /* Re-ACK this packet */
                dp->th_block = htons(ap->th_block);
                dp->th_opcode = htons((unsigned short)ACK);
                if(sendto(peer, dp, 4, 0,(struct sockaddr *)&to, tolen) != size)
                {
                  board_printf("TFTPd: sendto error (err %d)\r\n",errno);
                  goto tftp_close;
                }
                continue;
              }
              else if((int)ap->th_block != nextBlockNumber)
                continue;
            }
            ntimeout++;
          }
          while((int)ap->th_block != nextBlockNumber);
          if((size < PKTSIZE) && (nextBlockNumber != 0))
            break; // all is already send inside the 1st packet of DATA
          nextBlockNumber++;
          dp->th_block = htons((unsigned short)nextBlockNumber);
          if(nextBlockNumber == 1)
          {
            dp->th_opcode=htons((u_short)DATA); // used only if InClient=1
            size = Fread(file, SEGSIZE, (char *)dat);  
          }
          else 
          {
            Oldsize = size;
            if(Oldsize == PKTSIZE)
              size = Fread(file, SEGSIZE, (char *)dat);
          }
          size += 4;
        }
        while(Oldsize == PKTSIZE);
        close(peer);
        Fclose(file);
        break;
    }
  }
}

/*---------------------------------------------------------------------*/
/* Telnet Server                                                       */
/*---------------------------------------------------------------------*/

static void sendopt(struct termstate *ts, int code, int option)
{
  unsigned char buf[3];
  buf[0] = TELNET_IAC;
  buf[1] = (unsigned char) code;
  buf[2] = (unsigned char) option;
  send(ts->sock, buf, 3, 0);
}

static void parseopt(struct termstate *ts, int code, int option)
{
  switch(option)
  {
    case TELOPT_ECHO:
      break;
    case TELOPT_SUPPRESS_GO_AHEAD:
      if(code == TELNET_WILL || code == TELNET_WONT)
        sendopt(ts, TELNET_DO, option);
      else
        sendopt(ts, TELNET_WILL, option);
      break;
    case TELOPT_TERMINAL_TYPE:
    case TELOPT_NAWS:
    case TELOPT_TERMINAL_SPEED:
      sendopt(ts, TELNET_DO, option);
      break;
    default:
      if(code == TELNET_WILL || code == TELNET_WONT)
        sendopt(ts, TELNET_DONT, option);
      else
        sendopt(ts, TELNET_WONT, option);
      break;
  }
}

static void parseoptdat(struct termstate *ts, int option, unsigned char *data, int len)
{
  switch(option)
  {
    case TELOPT_NAWS:
      if(len == 4)
      {
        int cols = ntohs(*(unsigned short *) data);
        int lines = ntohs(*(unsigned short *) (data + 2));
        if(cols)
          ts->term.cols = cols;
        if(lines)
          ts->term.lines = lines;
      }
      break;
    case TELOPT_TERMINAL_SPEED:
      break;
    case TELOPT_TERMINAL_TYPE:
      break;
  }
}

static void parse(struct termstate *ts)
{
  unsigned char *p = ts->bi.start;
  unsigned char *q = p;
  while(p < ts->bi.end)
  {
    int c = *p++;
    switch (ts->state) 
    {
      case STATE_NORMAL:
        if (c == TELNET_IAC)
          ts->state = STATE_IAC;
        else
          *q++ = c;
        break;
      case STATE_IAC:
        switch (c) 
        {
          case TELNET_IAC:
            *q++ = c;
            ts->state = STATE_NORMAL;
            break;
          case TELNET_WILL:
          case TELNET_WONT:
          case TELNET_DO:
          case TELNET_DONT:
            ts->code = c;
            ts->state = STATE_OPT;
            break;
          case TELNET_SB:
            ts->state = STATE_SB;
            break;
          default:
            ts->state = STATE_NORMAL;
        }
        break;
      case STATE_OPT:
        parseopt(ts, ts->code, c);
        ts->state = STATE_NORMAL;
        break;
      case STATE_SB:
        ts->code = c;
        ts->optlen = 0;
        ts->state = STATE_OPTDAT;
        break;
      case STATE_OPTDAT:
        if(c == TELNET_IAC)
          ts->state = STATE_SE;
        else if(ts->optlen < sizeof(ts->optdata))
          ts->optdata[ts->optlen++] = c;
        break;
      case STATE_SE:
        if(c == TELNET_SE)
          parseoptdat(ts, ts->code, ts->optdata, ts->optlen);
        ts->state = STATE_NORMAL;
        break;
    } 
  }
  ts->bi.end = q;
}

static portTASK_FUNCTION(vTELNETd, pvParameters)
{
  struct sockaddr_in sin;
  fd_set fdsr;
  struct timeval tv_timeout;
  static char cmdline1[UIF_MAX_LINE];
  static char cmdline2[UIF_MAX_LINE];
  int sock, s, rc, n, argc, pos, ch, i, j;
  char *argv[UIF_MAX_ARGS + 1];   /* one extra for null terminator */
  pos = 0;
  if(pvParameters);
  ts = (struct termstate *)pvPortMalloc(sizeof(struct termstate));
  if(ts == NULL)
  {
    printD("TELNETd: malloc error\r\n");
    vTaskDelete(0);
  }
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if(sock < 0)
  {
    printD("TELNETd: error %d in socket\r\n", errno);
    vTaskDelete(0);
  }
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = INADDR_ANY;
  sin.sin_port = htons(PortTELNET);
  rc = bind(sock, (struct sockaddr *) &sin, sizeof sin);
  if(rc < 0)
  {
    printD("TELNETd: error %d in bind\r\n", errno);
    vTaskDelete(0);
  }
  rc = listen(sock, 5);
  if(rc < 0)
  {
    printD("TELNETd: error %d in listen\r\n", errno);
    close(sock);
    vTaskDelete(0);
  }
  while(1)
  {
    int off = 0;
    struct sockaddr_in sin;
    int len = sizeof(sin);
    s = accept(sock, (struct sockaddr *)&sin, &len);
    if(s < 0)
    {
      printD("TELNETd: error %d in accept\r\n", errno);
      close(sock);
      vTaskDelete(0);
    }
    setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char *)&off, sizeof(off));
    /* Initialize terminal state */
    memset(ts, 0, sizeof(struct termstate));
    ts->sock = s;
    ts->state = STATE_NORMAL;
    ts->term.type = TERM_VT100;
    ts->term.cols = 80;
    ts->term.lines = 25;
    /* Send initial options */
    sendopt(ts, TELNET_WILL, TELOPT_ECHO);
    ts->bo.start = ts->bo.data;
    board_putchar_flush();
    board_printf(PROMPT);
    board_putchar_flush();
    while(1)
    {
      FD_ZERO(&fdsr);
      FD_SET(ts->sock, &fdsr);
      tv_timeout.tv_sec = 1;
      tv_timeout.tv_usec = 0;
      if((i = select(FD_SETSIZE, &fdsr, NULL, NULL, &tv_timeout)) == -1)
      {
        printD("TELNETd: error %d in select\r\n", errno);
done:
        close(ts->sock);
        ts->sock = -1;
        break;
      }
      if((i > 0) && FD_ISSET(ts->sock, &fdsr))
      {
        if(ts->bi.start == ts->bi.end)
        {
          /* Read data from user */
          n = recv(ts->sock, ts->bi.data, sizeof(ts->bi.data), 0);
          if(n < 0)
            goto done;
          ts->bi.start = ts->bi.data;
          ts->bi.end = ts->bi.data + n;        
        }
        /* Parse user input for telnet options */
        parse(ts);
        if(ts->bi.start != ts->bi.end)
        {
          /* Write data to application */
          n = (int)(ts->bi.end - ts->bi.start);
          for(j = 0; j < n; j++)
          {
            ch = (int)ts->bi.start[j];
            if((ch != '\r') && (ch != '\n') && (pos < UIF_MAX_LINE))
            {
              switch(ch)
              {
                case 0x08:      /* Backspace */
                case 0x7F:      /* Delete */
                  if(pos > 0)
                  {
                    pos -= 1;
//                    board_putchar(0x08);    /* backspace */
//                    board_putchar(' ');
//                    board_putchar(0x08);    /* backspace */
                  }
                  break;
                default:
                  if((pos+1) < UIF_MAX_LINE)
                  {
                    /* only printable characters */
                    if((ch > 0x1f) && (ch < 0x80))
                    {
                      cmdline1[pos++] = (char)ch;
//                      board_putchar((char)ch);
                    }
                  }
                  break;
              }
            }
            else
            {
              cmdline1[pos] = '\0';
              board_putchar('\r');
              board_putchar('\n');
              if(!(argc = make_argv(cmdline1, argv)))
              {
                /* no command entered, just a blank line */
                 strcpy(cmdline1, cmdline2);
                 argc = make_argv(cmdline1, argv);
              }
              cmdline2[0] = '\0';
              if(argc)
              {
                /* First try for an exact match on command name */
                for(i = 0; i < UIF_NUM_CMD; i++)
                {
                  if(strcasecmp(UIF_CMDTAB[i].cmd,argv[0]) == 0)
                  {
                    if(((argc-1) >= UIF_CMDTAB[i].min_args) && ((argc-1) <= UIF_CMDTAB[i].max_args))
                    {
                      if(UIF_CMDTAB[i].flags & UIF_CMD_FLAG_REPEAT)
                        strcpy(cmdline2,argv[0]);
                      board_putchar_flush();
                      UIF_CMDTAB[i].func(argc,argv);
                      goto next_cmd;
                    }
                    else
                    {
                      board_printf(SYNTAX,argv[0]);
                      goto next_cmd;
                    }
                  }
                }
                /* Now try for short-hand match on command name */
                for(i = 0; i < UIF_NUM_CMD; i++)
                {
                  if(strncasecmp(UIF_CMDTAB[i].cmd,argv[0], UIF_CMDTAB[i].unique) == 0)
                  {
                    if(((argc-1) >= UIF_CMDTAB[i].min_args) && ((argc-1) <= UIF_CMDTAB[i].max_args))
                    {
                      if(UIF_CMDTAB[i].flags & UIF_CMD_FLAG_REPEAT)
                        strcpy(cmdline2,argv[0]);
                      board_putchar_flush();
                      UIF_CMDTAB[i].func(argc,argv);
                      goto next_cmd;
                    }
                    else
                    {
                      board_printf(SYNTAX,argv[0]);
                      goto next_cmd;
                    }
                  }
                }
                board_printf(INVCMD,argv[0]);
                board_printf(HELPMSG);
              }
next_cmd:
              board_putchar_flush();
              board_printf(PROMPT);
              board_putchar_flush();
              pos = 0;
            }
          }
          ts->bi.start += n;
        }
      }    
    }
  }
}

static void *test_debug_fault(unsigned long address, unsigned long vector, unsigned char *RegList)
{
#ifndef MCF547X
  (void)RegList;
#endif
  if(pxCurrentTCB == tid_TOS)
  {
#ifndef KILL_TOS_ON_FAULT
    if(address >= (unsigned long)__SDRAM_SIZE)
      vector = 0; /* => kill TOS */
    switch(vector)
    {
      case 3: /* Address Error */
      case 4: /* Illegal Instruction */
      case 5: /* Integer Zero Divide */
      case 8: /* Privilege Violation */
      case 11: /* Line F */
        return(NULL); /* hope than TOS fix fault himself */
      case 2: /* Access Fault */
        if((address < CF68KLIB) || (address >= CF68KLIB+0x10000)) /* 65KB */
          return(NULL); /* hope than TOS fix fault himself */
        /* else access fault inside CF68KLIB => kill TOS */
      default: /* other faults => kill TOS */
#endif /* KILL_TOS_ON_FAULT */
#ifdef MCF5445X
        save_imrl0 |= (INTC_IMRL_INT_MASK26 | INTC_IMRL_INT_MASK28); /* mask UART 0 (serial) & UART 2 (IKBD) */
        MCF_INTC_IMRL0 = save_imrl0;
        MCF_INTC_IMRH0 = save_imrh0;
        MCF_INTC_IMRH1 = save_imrh1;
#else
        MCF_INTC_IMRL = save_imrl;
        save_imrh |= (MCF_INTC_IMRH_INT_MASK35 | MCF_INTC_IMRH_INT_MASK55 | MCF_INTC_IMRH_INT_MASK56 | MCF_INTC_IMRH_INT_MASK57); /* mask serial & CAN (IKBD) */
        MCF_INTC_IMRH = save_imrh;
#endif
        *(unsigned short *)_timer_ms = 0; /* TOS is dead, flag used for polling serial ... */
#ifndef KILL_TOS_ON_FAULT
        break;
    }
#endif /* KILL_TOS_ON_FAULT */
		*(unsigned long *)memvalid = 0; /* force cold reset to next reset */
  }
#ifdef MCF547X
  else if((pxCurrentTCB == tid_ETOS) && (vector != 3) && (vector != 4)) /* rebuild return exception frame, EMUTOS not use the CF68KLIB */
  {
    unsigned long ssp = (*(unsigned long *)&RegList[76]) + 8;
    unsigned long pc = *(unsigned long *)&RegList[64];
    unsigned long sr = (unsigned long)(*(unsigned short *)&RegList[68]);
    unsigned long format = (vector << 18) | sr;
    unsigned long jump = *(unsigned long *)(vector * 4);
    switch(ssp & 3)
    {
      case 0: format |= 0x40000000UL; break;
      case 1: format |= 0x50000000UL; ssp--; break;
      case 2: format |= 0x60000000UL; ssp -= 2; break;
      case 3: format |= 0x70000000UL; ssp -= 3; break;
    }     
    if(*(unsigned long *)phystop <= 0x80000)
      *(unsigned long *)phystop = 0xE00000; /* FPGA 0xFFFF8006 has bad infos */  
    asm volatile (
          " move.l %0,SP\n\t"
          " move.l %1,-(SP)\n\t"
          " move.l %2,-(SP)\n\t"
          " move.l %3,-(SP)\n\t"
          " move.l %4,A0\n\t"
          " movem.l (A0),D0-D7/A0-A6\n\t"
          " rts"  :  : "d" (ssp), "d" (pc), "d" (format), "d" (jump), "d" (RegList) : "a0", "sp" );
  }
#endif
  else if(pxCurrentTCB == tid_DEBUG)
    restart_debug = 1;
  vTaskDelete(0);
  while(1);
}

static portTASK_FUNCTION(vDEBUG, pvParameters)
{
  /* The parameters are not used in this function */
  (void)pvParameters;
  *(unsigned long *)(handler_fault) = (unsigned long)test_debug_fault;
  BASE = 16;
  md_last_address = 0;
  md_last_size = 0;
  disasm_last_address = 0;
  cmdline1[0] = cmdline2[0] = '\0';  
  history_init();
  while(1)
  {
    board_putchar_flush();
    board_printf(PROMPT);
    board_putchar_flush();
    run_cmd();
  }
}

static void start_debug(vid)
{
  xTaskCreate(vDEBUG, (void *)"DBUG", STACK_DEFAULT, NULL, DEBUG_TASK_PRIORITY, &tid_DEBUG);
} 

#endif

static int geterrno(void)
{
  return(errno);
}

static SOCKET_COOKIE sc =
{
  0x0101, /* version */
  'SOCK', /* magic */
  lwip_socket,
  lwip_bind,
  lwip_listen,
  lwip_accept,
  lwip_connect,
  lwip_write,
  lwip_send,
  lwip_sendto,
  lwip_read,
  lwip_recv,
  lwip_recvfrom,
  lwip_shutdown,
  lwip_close,
  lwip_getsockname,
  lwip_getpeername,
  lwip_getsockopt,
  lwip_setsockopt,
  lwip_select,
  lwip_ioctl,
  gethostbyname,
  geterrno
};

void start_servers(void)
{
#ifdef DBUG
  xTaskCreate(vTELNETd, (void *)"TELNETd", STACK_DEFAULT, NULL, TELNET_TASK_PRIORITY, &tid_TELNET);
#endif
#ifdef FTP_SERVER
	xTaskCreate(vFTPd, (void *)"FTPd", STACK_DEFAULT, NULL, FTP_TASK_PRIORITY, NULL);
#endif
  xTaskCreate(vTFTPd, (void *)"TFTPd", STACK_DEFAULT, NULL, TFTP_TASK_PRIORITY, NULL);
  /* Start the webserver */
  xTaskCreate(vBasicWEBServer, (void *)"HTTPd", STACK_DEFAULT, NULL, WEB_TASK_PRIORITY, &tid_HTTPd);
}

void init_lwip(void)
{
  unsigned long IP;
  struct ip_addr xIpAddr, xNetMast, xGateway;
  static struct netif loop_if, fec54xx0_if;
#ifndef MCF547X
  static struct netif fec54xx1_if;
#endif
  errno = 0;
  /* Initialize lwIP and its interface layer */
  sys_init();
  mem_init();
  memp_init();
  pbuf_init();
  netif_init();
  ip_init();
  tcpip_init(NULL, NULL);
  socket_init();
  board_get_server((unsigned char *)&IP);
  xIpAddr.addr = htonl(IP); // not used actually
  // => DNS_SERVER_ADDRESS in dns.c
  /* Initialize the loopback interface structure */
  xIpAddr.addr = INADDR_LOOPBACK;
  xGateway.addr = 0;
  xNetMast.addr = 0; // 0xFF000000
  if(netif_add(&loop_if, &xIpAddr, &xNetMast, &xGateway, NULL, loopif_init, tcpip_input) != NULL)
  {
    /* make it the default interface */
    netif_set_default(&loop_if);
    /* bring it up */
    netif_set_up(&loop_if);
  }    
  else
  {
    board_printf("Loopback init error\r\n");
    while(1)
      vTaskDelay(1);
  }
  /* Initialize the network interface structure */
  board_get_client((unsigned char *)&IP);
  xIpAddr.addr = htonl(IP);
  board_get_gateway((unsigned char *)&IP);
  xGateway.addr = htonl(IP);
  board_get_netmask((unsigned char *)&IP);
  xNetMast.addr = htonl(IP);
  /* caches must be disabled */
  if(netif_add(&fec54xx0_if, &xIpAddr, &xNetMast, &xGateway, NULL, mcf_fec0_init, tcpip_input) != NULL)
  {
    /* make it the default interface */
    netif_set_default(&fec54xx0_if);
    /* bring it up */
    netif_set_up(&fec54xx0_if);
  }
  else
  {
    board_printf("FEC0 init error\r\n");
    while(1)
      vTaskDelay(1);
  }
#if 0
#ifndef MCF547X
  board_get_client((unsigned char *)&IP);
  IP += 0x100;
  xIpAddr.addr = htonl(IP);
  board_get_gateway((unsigned char *)&IP);
  xGateway.addr = htonl(IP);
  board_get_netmask((unsigned char *)&IP);
  xNetMast.addr = htonl(IP);
  if(netif_add(&fec54xx1_if, &xIpAddr, &xNetMast, &xGateway, NULL, mcf_fec1_init, tcpip_input) != NULL)
  {
    /* make it the default interface */
    netif_set_default(&fec54xx1_if);
    /* bring it up */
    netif_set_up(&fec54xx1_if);
  }    
  else
  {
    board_printf("FEC1 init error\r\n");
    while(1)
      vTaskDelay(1);
  }
#endif
#endif
  enable_caches();
#ifdef DBUG
  breakpoint_init();
#endif
#ifdef MCF547X
  if(MCF_GPIO_PPDSDR_PSC3PSC2 & MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC27)
#endif
  {
    start_servers();
  }
  lwip_ok = 1;
}

static portTASK_FUNCTION(vTOS, pvParameters)
{
  void (*return_address)(void) = (void (*)(void))pvParameters;
  vTaskDelay(configTICK_RATE_HZ/10);
  return_address();
  while(1);
}

static portTASK_FUNCTION(vROOT, pvParameters)
{
#ifdef USB_DEVICE
#ifndef MCF5445X
#ifndef MCF547X
  int init_usb = 0;
#endif
#endif
#endif
//  int error = 0;
#if 0 // #ifdef MCF547X
  extern void hbl_int(void);
  extern unsigned long get_timer(void);
  int tick_count = 0;
	unsigned long start_timer = get_timer();
  int level = vPortSetIPL(portIPL_MAX);
  old_hbl = *(unsigned long *)((64+2)*4 + coldfire_vector_base);
  *(unsigned long *)((64+2)*4 + coldfire_vector_base) = (unsigned long)hbl_int;
  MCF_EPORT_EPIER |= MCF_EPORT_EPIER_EPIE2;
	MCF_EPORT_EPFR |= MCF_EPORT_EPFR_EPF2; /* clear interrupt	*/
  MCF_INTC_IMRL &= ~MCF_INTC_IMRL_INT_MASK2; /* enable interrupt */
  asm_set_ipl(level);
#endif /* MCF547X */
#ifdef USE_RTC
#ifndef MCF5445X
#ifndef MCF547X
  extern void RTC_task(void);
  xTaskCreate((pdTASK_CODE)RTC_task, (void *)"RTCd", STACK_DEFAULT, NULL, RTC_TASK_PRIORITY, NULL);
#endif
#endif
#endif
  restart_debug = 0;
  init_lwip();
  xTaskCreate(vTOS, (void *)"TOS", STACK_DEFAULT, pvParameters, TOS_TASK_PRIORITY, &tid_TOS);
#ifdef DBUG
  start_debug();
#endif
  while(1)
  {
#ifdef USB_DEVICE
#ifndef MCF5445X
#ifndef MCF547X
    if(size_ram_disk && !init_usb)
    {
      vTaskDelay(configTICK_RATE_HZ);
      init_usb_device();
      init_usb = 1;
    }
#endif /* MCF547X */
#endif /* MCF5445X */
#endif /* USB_DEVICE */
#ifdef DBUG
    if(restart_debug == 1)
    {
      restart_debug = 0;
      vTaskDelay(configTICK_RATE_HZ/2);
      start_debug();
    }
#if 0
    if(!error
     && (*(unsigned long *)VBL_VEC >= (unsigned long)__SDRAM_SIZE))
    {
      board_printf("VBL vector destroyed!\r\n");
       error = 1;
    }
#endif
#endif /* DBUG */
#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
    if(1
#ifdef CONFIG_USB_OHCI
     && ohci_inited
#endif
#ifdef CONFIG_USB_EHCI
//     && ehci_inited
#endif
    )
    {
#ifndef CONFIG_USB_INTERRUPT_POLLING
#ifndef MCF5445X
#ifndef MCF547X
      /* move INT7 to native interrupt (M5484LITE/M5485EVB) */
      /* INT7 call INT2 who is masked by other task than TOS (level 3) */
      if((save_imrl & (1 << 7)) && !(save_imrl_tos & (1 << 7)))
      {
        int level = asm_set_ipl(7); /* disable interrupts */
        *(unsigned long *)(((64+7) * 4) + coldfire_vector_base) = *(unsigned long *)((64+7+OFFSET_INT_CF68KLIB) * 4);
        MCF_INTC_IMRL &= ~MCF_INTC_IMRL_INT_MASK7; /* enable interrupt */
        asm_set_ipl(level);
      }
#endif /* MCF547X */
#endif /* MCF5445X */
#endif /* CONFIG_USB_INTERRUPT_POLLING */
    }
#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */
#ifdef MCF547X
   if(boot_os)
   {
      unsigned long start_addr = 0;
      extern short swi;
      switch(boot_os)
      {      
        case 1:
          start_addr = 0xE0600000;
          break;
        default:
          if(swi & 1) /* boot from rescue TOS at 0xE0000000 */
            start_addr = 0xE0400000;
#ifdef DBUG
          else if((tid_TELNET == NULL) && (tid_HTTPd == NULL))
#else
          else if(tid_HTTPd == NULL)
#endif
            start_servers();
        	break;
      }
      if(start_addr)
		  {
		    if(*(short *)start_addr == 0x602E)
          go_emutos(start_addr);
        boot_os = 0;
      }
    }
#endif
#if 0 // #ifdef MCF547X
    tick_count++;
    if(tick_count > configTICK_RATE_HZ*10)
    {
    	unsigned long time = get_timer();
			board_printf("VBL interval %d uS (%d %d)\r\n", (int)((time - start_timer)/(hbl_count * SYSTEM_CLOCK)), hbl_count, (time - start_timer)/SYSTEM_CLOCK);
      level = vPortSetIPL(portIPL_MAX);
			start_timer =  get_timer();
      tick_count = 0;
			hbl_count = 0;		
      asm_set_ipl(level);
    }
#endif
    vTaskDelay(1);
  }
} 

void xSemaphoreTakeBDOS(void)
{
  while(xSemaphoreAltTake(xSemaphoreBDOS, portMAX_DELAY) != pdTRUE);
}

void xSemaphoreGiveBDOS(void)
{
  xSemaphoreAltGive(xSemaphoreBDOS);
}

int tftpreceive(unsigned char *server, char *sname, short handle, long *size)
{
  struct sockaddr_in address_server;
  address_server.sin_family = AF_INET;
  address_server.sin_port = htons(PortTFTP);
  memcpy(&address_server.sin_addr.s_addr, server, 4);
  address_server.sin_addr.s_addr = htonl(address_server.sin_addr.s_addr);
  return(tftp_receive(&address_server, sname, "octet", handle, size) == 0 ? TRUE : FALSE);
}

int tftpsend(unsigned char *server, char *sname, short handle)
{
  struct sockaddr_in address_server;
  address_server.sin_family = AF_INET;
  address_server.sin_port = htons(PortTFTP);
  memcpy(&address_server.sin_addr.s_addr, server, 4);
  address_server.sin_addr.s_addr = htonl(address_server.sin_addr.s_addr);
  return(tftp_send(&address_server, sname, "octet", handle) == 0 ? TRUE : FALSE);
}

int usb_load_files(void)
{
#ifdef USB_DEVICE
#ifdef MCF5445X
  return(FALSE);
#else /* MCF548X */
#ifdef MCF547X
  return(FALSE);
#else /* MCF548X */
  int sec = 60; /* seconds */
  board_printf("Waiting USB mass storage link...\r\n");
  while(ext_write_protect_ram_disk == FALSE)
  {
    vTaskDelay(configTICK_RATE_HZ);
    sec--;
    if(sec <= 0)
      return(FALSE); /* timeout */
  }
  while(ext_write_protect_ram_disk == TRUE)
    vTaskDelay(1);
  return(TRUE); /* continue boot with updated ram-disk */
#endif /* MCF547X */
#endif /* MCF5445X */
#else
  return(FALSE);
#endif /* USB_DEVICE */
}

int init_network(void)
{
  extern DRV_LIST stik_driver;
  extern int gs_init_stik_if(void);
  extern int gs_init_mem(void);
  COOKIE pck;
  if(!lwip_ok)
    return(FALSE);
  pck.ident = 'SOCK';
  pck.v.l = (long)&sc;
  add_cookie(&pck);
  gs_init_stik_if();
  gs_init_mem();
  pck.ident = 'STiK';
  pck.v.l = (long)&stik_driver;
  add_cookie(&pck);
  return(TRUE);
}

int init_rtos(void *params)
{
  extern unsigned char _bss_start_freertos[];
  extern unsigned char _end_freertos[];
  extern void init_dma(void);
  memset(_bss_start_freertos, 0, (int)(_end_freertos-_bss_start_freertos));
  size_ram_disk = 0;
  pxCurrentTCB = NULL;
  tid_TOS = (void *)-1; /* for vPortSetIPL() */
  tid_TELNET = tid_DEBUG = tid_HTTPd = NULL;
#ifdef MCF547X
  tid_ETOS = NULL;
  boot_os = 0;
#endif
  start_run = NULL;
  lwip_ok = get_serial_vector = get_ikbd_vector = tos_suspend = 0;
  *(unsigned short *)_timer_ms = 0;
  vSemaphoreCreateBinary(xSemaphoreBDOS);
  init_dma();
  xTaskCreate(vROOT, (void *)"ROOT", STACK_DEFAULT, params, ROOT_TASK_PRIORITY, NULL);
  vTaskStartScheduler();
  return 0;
}

#endif /* LWIP */
#endif /* NETWORK */
