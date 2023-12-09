#define FALSE      0
#define TRUE       1

#define OK         0L           /* OK status */
#define ERROR     -1L           /* ERROR status (timeout) */
#define ERRORL    -2L           /* ERROR status (long timeout) */
#define EWRITF    -10           /* GEMDOS write error code */
#define EREADF    -11           /* GEMDOS read error code */
#define CRITRETRY 0x00010000L   /* RETRY return code */

#define NRETRIES   3            /* number of times to retry -1 */
#define MAX_UNITS  16           /* Max number of drives attached */
#define MAXSECTORS 254          /* Max # sectors for a DMA */
#define MAXRETRIES 1

/* Timing constants */
#define LTIMEOUT   600L         /* long-timeout 3 sec */
#define STIMEOUT    20L         /* short-timeout 100 msec */

/* RWABS flags */
#define RW_FLAG       0x01      /* flag for read/write */
#define MEDIACH_FLAG  0x02      /* flag for read/write with mediachange */
#define RETRY_FLAG    0x04      /* flag for read/write with retries */
#define PHYSOP_FLAG   0x08      /* flag for physical/logical read/write */
/* ------------------------------------------ */
/* ASCI Commands */
#define HD_TDR   0x00           /* Test Drive Ready */
#define HD_RS    0x03           /* Request Sense */
#define HD_FD    0x04           /* Format Drive */
#define HD_READ  0x08           /* Read */
#define HD_WRITE 0x0A           /* Write */
#define HD_SEEK  0x0B           /* Seek */
#define HD_MSEL  0x15           /* Mode Select */
/* -------------------------------------- */
#define MFP_ADDR 	0xFFFA00L      /* MFP device addres */

#define MFP     	((struct mfp_chip *) MFP_ADDR)

#define GPIP    	reg[1]          /* general purpose I/O (interrupt port) */
#define IO_DINT     0x20        /* DMA interrupt (FDC or HDC) */

#define BYTE		unsigned char

long wait_dma_cmpl(unsigned long t_ticks);
long fdone(void);
long qdone(void);
void setdma(unsigned long int addr);
long hdone(void);
long endcmd(short mode);
BYTE LongRW(BYTE ReadNotWrite, BYTE *cmd, BYTE *buffer);
/*---------------------------------------*/
#define DMA_ADDR 0xFF8600L      /* DMA device addres */
#define DMA      ((struct dma_chip *) DMA_ADDR)

struct dma_chip 
{
  short reserved[2]; /* reserved registers */
  short DATA;        /* controller & sector count reg */
  short MODE;        /* mode & status register */
  char  ADDR[6];     /* base addres. High/Mid/Low */
};

/* pseudo names */
#define SECT_CNT     DATA
#define STATUS       MODE

/* offset into addr, odd bytes used only */
#define HIGH         1
#define MID          3
#define LOW          5

/* Mode Register bits */
#define NOT_USED     0x0001     /* not used bit */
#define A0           0x0002     /* A0 line, A1 on DMA port */
#define A1           0x0004     /* A1 line, not used on DMA port */
#define HDC          0x0008     /* HDC / FDC register select */
#define SC_REG       0x0010     /* Sector count register select */
#define RESERVED5    0x0020     /* reserved for future expansion ? */
#define RESERVED6    0x0040     /* bit has no function */
#define NO_DMA       0x0080     /* disable / enable DMA transfer */
#define DMA_WR       0x0100     /* Write to / Read from DMA port */

/* Status Register bits */
#define DMA_OK       0x0001     /* DMA transfer went OK */
#define SC_NOT_0     0x0002     /* Sector count register not zero */
#define DATA_REQ     0x0004     /* DRQ line state */
/*---------------------------------------*/

