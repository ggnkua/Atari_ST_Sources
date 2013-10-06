
/***************************************************************************

    XSIO.H

    - Atari 800 SIO service routines

    09/26/88 created

    10/17/88 20:00

***************************************************************************/

#define CLOCK192K   31
#define CLOCK48K    12

/* disk drive status flags */
#define STAT_CONN   0x80
#define STAT_WP     0x40
#define STAT_WARP   0x20
#define STAT_MOTOR  0x10
#define STAT_QD     0x08
#define STAT_DD     0x04
#define STAT_ED     0x02
#define STAT_SD     0x01

#define DENS_NONE   0
#define DENS_SNG    1
#define DENS_1050   2
#define DENS_DBL    3

/* bit masks */
#define BIT7    0x80
#define BIT6    0x40
#define BIT5    0x20
#define BIT4    0x10
#define BIT3    0x08
#define BIT2    0x04
#define BIT1    0x02
#define BIT0    0x01

/* SIO return codes */
#define SIO_OK      0x01
#define SIO_TIMEOUT 0x8A
#define SIO_NAK     0x8B
#define SIO_DEVDONE 0x90

/* timeout delays */
#define TO_BYTE        1000L
#define TO_SHORT      10000L
#define TO_SEC       100000L
#define TO_LONG     1000000L
#define TO_FORMAT  10000000L

extern unsigned uBaudClock;
extern long lTimeout;
extern char rgchCmdFrame[6] ;

extern void _SIO_Init();
extern void _SIO_UnInit();
extern int _SIO_DiskDens();
extern int _SIO_GetDens();
extern int _SIO_SetDens();
extern int _SIO_DriveStat();
extern int _SIO_DiskIO();
extern int _SIOV();
extern int SIOV();
extern void UtoPch();

/*
extern SendFrame();
extern unsigned int GetByte();
extern int GetFrame();
extern ReadSector();
extern enter_SIO();
*/
