
/***************************************************************************

    XSIO.C

    - Atari XE SIO service routines
    - taken from QTU 1.3, to be used as a common module

    09/24/88 created

    05/04/89 22:00

***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include "xsio.h"

#define SOUNDSEL 0xFFFF8800
#define SOUNDREG 0xFFFF8802

int wSR;
unsigned uBaudClock = CLOCK192K;
long lTimeout;

/*******************************************************************
**  low level routines
*******************************************************************/

/*
** this involves setting the printer strobe high (5V/READY pin)
** and setting all the printer pins high.
** For now, hardcode 19.2K baud
*/
void _SIO_Init()
    {
asm
    {
    lea     0x8800,A0
    move.b  #0x0E,(A0)
    move.b  (A0),D0
    bset    #5,D0
    move.b  D0,2(A0)

    move.b  #0x0F,(A0)
    move.b  #0xFF,2(A0)
    }

 /*   uBaudClock = CLOCK192K; */
    }

/*
** this clears the printer port pins
*/
void _SIO_UnInit()
    {
asm
    {
    lea     0x8800,A0
    move.b  #0x0E,(A0)
    move.b  (A0),D0
    bclr    #5,D0
    move.b  D0,2(A0)

    move.b  #0x0F,(A0)
    move.b  #0x00,2(A0)
    }
    }

/*
**  produce a delay of cus microseconds
**  timing not terribly critical
*/

static DelayCus(cus)
register int cus;
    {
asm
    {
    lsr.w   #1,cus
loop:
    nop
    dbf     cus,loop
    }
    }

/* disable all interrupts */
static DI()
    {
asm
    {
    move.w  SR,D0
    move.w  D0,wSR              ; save old status register
    ori.w   #0x0700,SR          ; and disable interrupts
    }
    }

/* enable interrupts */
static EI()
    {
asm
    {
    move.w  wSR,D0
    move.w  D0,SR
    }
    }

static CommandHi()
    {
    DelayCus(500);

asm
    {
    lea     0x8800,A0
    move.b  #0x0F,(A0)
    move.b  #0xFF,2(A0)
    }
    }

static CommandLo()
    {
asm
    {
    lea     0x8800,A0
    move.b  #0x0F,(A0)
    move.b  #0xDF,2(A0)
    }

    DelayCus(500);
    }

char rgchCmdFrame[6] = { 0, 0, 0, 0, 0, 0 };

/*
    send a frame of bytes to DATA OUT

    D0 - current serial output byte
    D1 - current output byte from buffer
    D2 - cb
    D3 - scratch
    D4 - bit counter

    A0 - pointer to sound reg
    A1 - pointer to buffer

    DATA OUT - pin 5 - mask = $08, bit 3
    CLOCK OUT - pin 3 - mask = $02, bit 1
*/

static SendFrame(pb, cb)
register unsigned char *pb;
register unsigned int cb;
    {
    register unsigned int chksum = 0;
    register unsigned char *pch = pb;
    register unsigned int i = cb;
    unsigned char tmp;

#ifdef NEVER
    {
    int q;

    print("SendFrame: cb = %d   ");
    for (q=0; q<5; q++)
        {
        print("%d:%02x  ", q, pb[q]);
        }
    print("\n");
    }
#endif

    while (i--)
        {
        chksum += *pch++;
        if (chksum >= 0x100)
            chksum -= 0xFF;
        }
    tmp = *pch;         /* save old value of byte past frame */
    *pch = chksum;

asm
    {
    move.w  cb,D2
    movea.l pb,A1               ; A1 - point to buffer
    lea     0x8800,A0

    ; make SIO write sound
    move.b  #6,(A0)
    move.b  0x80,2(A0)
    move.b  #10,(A0)       ; volume voice C
    move.b  #8,2(A0)
    move.b  #7,(A0)
    move.b  (A0),D0
    andi.b  #0xDF,D0        ; enable noise C
    move.b  D0,2(A0)

    ; initialize
    move.b  #0x0F,(A0)
    move.b  (A0),D0             ; D0 - initial state
    bclr    #1,D0
    move.b  D0,2(A0)            ; reset CLOCK OUT
    move.l  0x012340L,0x012340L 
    move.l  0x012340L,0x012340L 

Lloop:
    clr.w   D1
    move.b  (A1)+,D1            ; get a byte
    add.w   D1,D1               ; add start bit
    bset    #9,D1               ; and stop bit
    moveq   #9,D4               ; bit counter = 8 bits + start + stop

    
Lloop2:
    lsr.w   #1,D1
    scs     D3
    andi.b  #0x08,D3            ; isolate DATA OUT pin
    andi.b  #0xF5,D0
    or.b    D3,D0               ; set new DATA OUT
    move.b  D0,2(A0)
    bset    #1,D0               ; set CLOCK OUT
    move.b  D0,2(A0)
    move.l  0x012340L,0x012340L ; kill 180 cycles
    move.l  0x012340L,0x012340L 
    move.l  0x012340L,0x012340L 
    move.l  0x012340L,0x012340L 
    move.l  0x012340L,0x012340L 
    bclr    #1,D0               ; clear CLOCK OUT
    move.b  D0,2(A0)
    move.l  0x012340L,0x012340L ; kill 108 cycles
    move.l  0x012340L,0x012340L 
    move.l  0x012340L,0x012340L 
    nop
    nop
    nop
    nop

    dbf     D4,Lloop2

    dbf     D2,Lloop

    move.b  #10,(A0)     ; volume voice C
    move.b  #0,2(A0)
    move.b  #7,(A0)
    move.b  (A0),D0
    ori.b   #0x20,D0        ; disable noise C
    move.b  D0,2(A0)
    }
    *pch = tmp;
    }

/*
** get a single byte
*/

unsigned int GetByte()
    {
    register int chReturn;
    register int  uClock = uBaudClock;
asm
    {
    lea     0xFA01,A0           ; input port
    clr.w   D1                  ; return value
    moveq   #7,D3               ; bit counter = 8 bits + start + stop
    move.l  lTimeout,D2         ; set timeout loops

Lloop:
    move.b  (A0),D0    ; 8
    btst    #0,D0      ; 12
    beq.s   Lgotstart  ; 12

    subq.l  #1,D2
    bne.s   Lloop           ; loops until start bit detected
    move.w  #-1,chReturn
    bra     exit

Lgotstart:
    ; kill half a clock cycle into the start bit
    move.w  uClock,D0
    lsr.w   #2,D0
Lloop1:
    dbf     D0,Lloop1
    nop

    ; kill one clock cycle, then read a bit
Lloop2:
    move.w  uClock,D0
Lloop3:
    dbf     D0,Lloop3       ; 4 + 31*12 + 16 + 4 = 396 cycles
    nop

    move.b  (A0),D0  ; 8
    lsr.b   #1,D0    ; 8
    roxr.b  #1,D1    ; 8
    dbf     D3,Lloop2 ; 12/16

    andi.w  #0x00FF,D1
    move.w  D1,chReturn
exit:
    nop
    }
    return chReturn;
    }

int GetFrame(pb, cb)
register unsigned char *pb;
register int cb;
    {
    register unsigned int chksum = 0;
    register int i = cb;
    register unsigned int chk;

asm
    {
    ; do beep beep beep sound
    lea     0x8800,A0
    move.b  #4,(A0)
    move.w  uBaudClock,D0
    lsl.w   #2,D0
    move.b  D0,2(A0)
    move.b  #5,(A0)
    move.b  #0x00,2(A0)
    move.b  #10,(A0)     ; volume voice C
    move.b  #10,2(A0)
    move.b  #7,(A0)
    move.b  (A0),D0
    andi.b  #0xFB,D0        ; enable voice C
    move.b  D0,2(A0)
    }

    do
        {
        if ((*pb++ = GetByte()) == -1)
            {
            break;
            }
        lTimeout = TO_BYTE;
        } while (--cb);

    chk = GetByte();

asm
    {
    lea     0x8800,A0
    move.b  #10,(A0)     ; volume voice C
    move.b  #0,2(A0)
    move.b  #7,(A0)
    move.b  (A0),D0
    ori.b   #0x04,D0    ; disable voice C
    move.b  D0,2(A0)
    }

    while (i--)
        {
        chksum += *--pb;
        if (chksum >= 0x100)
            chksum -= 0xFF;
        }

/*    print("getframe: %d %d\n", chksum, chk); */

    if (chksum == chk)
        return SIO_OK;
    return SIO_TIMEOUT;
    }

/*******************************************************************
**  SIO level routines
*******************************************************************/

#ifdef QTU

/* first byte of status packet:
** b7 = enhanced   b5 = DD/SD  b4 = motor on   b3 = write prot */

_SIO_DriveStat(uDrive)
unsigned uDrive;     /* 0 - 3 */
    {
    int i1, i2, i3;
    unsigned int rgfStat = 0;
    int wRetry;
    char rgch[16];

    rgchCmdFrame[0] = 0x31 + uDrive;
    rgchCmdFrame[1] = 0x00 | 'S';
    rgchCmdFrame[2] = 0x00;
    rgchCmdFrame[3] = 0x00;

  /*  uBaudClock = CLOCK192K; */
    CommandLo();
    DI();
    SendFrame(rgchCmdFrame,4);
    CommandHi();
    lTimeout = TO_SHORT;
    i1 = GetByte();
    i2 = GetByte();
    if ((i1 == 'A') && (i2 == 'C'))
        i3 = GetFrame(rgch, 4);
    EI();
    DelayCus(2000);

    if (i1 == 'A')
        rgfStat |= STAT_CONN;
    else return 0;

    CommandLo();
    DI();
    rgchCmdFrame[1] = 0x80 | 'S';
    SendFrame(rgchCmdFrame,4);
    CommandHi();
    lTimeout = TO_SHORT;
    i1 = GetByte();
 /*   uBaudClock = CLOCK48K; */
    i2 = GetByte();
    if ((i1 == 'A') && (i2 == 'C'))
        i3 = GetFrame(rgch, 4);
    EI();
    DelayCus(2000);

    if ((i1 == 'A') && (i2 == 'C'))
        rgfStat |= STAT_WARP;

    rgfStat |= STAT_SD;
    if (rgch[0] & BIT7)
        rgfStat |= STAT_ED;
    if (rgch[0] & BIT5)
        rgfStat |= STAT_DD;
    if (rgch[0] & BIT3)
        rgfStat |= STAT_WP;

    return rgfStat;
    }

int _SIO_DiskIO(uDrive, uSector, cb, pb, fRead)
register unsigned int uDrive, uSector, cb;
register char *pb;
int fRead;
    {
    int i1, i2, i3;

    if (fRead)
        {
        i1 = _SIOV(pb, 0x31 + uDrive, 'R', 0x40, cb, uSector, 5);
        }
    else
        {
        i1 = _SIOV(pb, 0x31 + uDrive, 'W', 0x80, cb, uSector, 5);
        }

    return i1;
    }

int _SIO_DiskDens(uDrive)
int uDrive;
    {
    int i1;
    char rgch[260];
    
    i1 = _SIOV(rgch, 0x31 + uDrive, 'R', 0x40, 128, 1, 5);
    
    if (i1 == SIO_TIMEOUT)      /* a single density drive */
        {
        return DENS_NONE;
        }
    else if (i1 == SIO_OK)
        {
        i1 = _SIOV(rgch, 0x31 + uDrive, 'R', 0x40, 256, 4, 5);
        if (i1 == SIO_OK)
            return DENS_DBL;
        if (i1 == SIO_NAK)
            return DENS_SNG;
        }
        
    return DENS_NONE;
    }

int _SIO_GetDens(uDrive)
int uDrive;
    {
    int i1;
    char rgch[12];
    
    i1 = _SIOV(rgch, 0x31 + uDrive, 'N', 0x40, 12, 0, 2);
    
    if (i1 == SIO_TIMEOUT)      /* a single density drive */
        {
        return DENS_SNG;
        }
    else if (i1 == SIO_OK)
        {
        return (rgch[5] & 4) ? DENS_DBL : DENS_SNG;
        }
        
    return DENS_NONE;
    }

char rgchSetDens[12] =
    {
    40, 2, 0, 18, 0, 0, 0, 128, 255, 255, 255, 255
    };

int _SIO_SetDens(uDrive, uDens)
int uDrive, uDens;
    {
    int i1;
    char rgch[4];

    if (uDens == DENS_DBL)
        {
        rgch[5] = 4;
        rgch[6] = 1;
        rgch[7] = 0;
        }
    
    i1 = _SIOV(rgch, 0x31 + uDrive, 'O', 0x80, 12, 0, 2);
    
    if (i1 == SIO_OK)
        {
        return 0;
        }
    return -1;
    }

void UtoPch(u, pch)
register unsigned u;
register char *pch;
    {
    register ch;

    ch = '0';
    while (u > 99)
        {
        ch++;
        u -= 100;
        }
    *pch++ = ch;

    ch = '0';
    while (u > 9)
        {
        ch++;
        u -= 10;
        }
    *pch++ = ch;

    ch = '0' + u;
    *pch++ = ch;

    *pch = '\0';
    }

#endif /* QTU */


/******************************************************************
**
** SIO entry point emulation
**
** return SIO return code
**
** qch  - pointer to buffer (if applicable)
** wDev - deviec ID (this is really wDev + wDrive)
** wCom - SIO command
** wStat - type of command ($00, $40, or $80)
** wBytes - bytes to transfer (if applicable)
** wSector - also knows as Aux1 and Aux2
** wTimeout - timeout in seconds
**
******************************************************************/

int _SIOV(qch, wDev, wCom, wStat, wBytes, wSector, wTimeout)
register char *qch;
int wDev, wCom, wStat, wBytes, wSector, wTimeout;
    {
    int wRetStat;
    char bAux1, bAux2;
    int fWarp = (wCom & 0x80);
    register int i,j;

    fWarp = 0;

    bAux1 = wSector & 0xFF;
    bAux2 = wSector >> 8;
    
    rgchCmdFrame[0] = wDev;
    rgchCmdFrame[1] = wCom;
    rgchCmdFrame[2] = bAux1;
    rgchCmdFrame[3] = bAux2;

    lTimeout = TO_SHORT;

    if (wStat == 0x00)
        {
        DI();
        CommandLo();
      /*  uBaudClock = CLOCK192K; */
        lTimeout = TO_SHORT;
        SendFrame(rgchCmdFrame,4);
        CommandHi();
        i = GetByte();
        lTimeout = TO_SEC * (long)wTimeout;
        j = GetByte();
        if ((i == 'A') && (j == 'C'))
            wRetStat = SIO_OK;
        else if ((i == 'N') || (j == 'N'))
            wRetStat = SIO_NAK;
        else
            wRetStat = SIO_TIMEOUT;
        EI();
        }

    else if (wStat == 0x40)
        {
        int wRetry = 13;

        DI();
lRetry40:
        CommandLo();
      /*  uBaudClock = CLOCK192K; */
        lTimeout = TO_SHORT;
        SendFrame(rgchCmdFrame,4);
        CommandHi();
        if ((i = GetByte()) != 'A')
            {
            if (--wRetry)
                goto lRetry40;
            else
                goto lTO40;
            }
/*
        if (fWarp)
            uBaudClock = CLOCK48K;
*/
        lTimeout = TO_SEC * (long)wTimeout;
        j = GetByte();
        if ((i == 'A') && (j == 'C'))
            wRetStat = GetFrame(qch, wBytes);
        else if ((i == 'N') || (j == 'N'))
            wRetStat = SIO_NAK;
        else
            {
lTO40:
            wRetStat = SIO_TIMEOUT;
            }
        EI();

/*
        if (fWarp)
            {
            print("were warping: i = %d  j = %d  wRetStat = %d\n",
                i, j, wRetStat);
            }
        else
*/
        }
    else if (wStat == 0x80)
        {
        DI();
        CommandLo();
      /*  uBaudClock = CLOCK192K; */
        lTimeout = TO_SHORT;
        SendFrame(rgchCmdFrame,4);
        CommandHi();
        if (GetByte() == 'A')
            {
            DelayCus(500);
            SendFrame(qch, wBytes);
            i = GetByte();
            lTimeout = TO_SEC * (long)wTimeout;
            j = GetByte();
            if ((i == 'A') && (j == 'C'))
                wRetStat = SIO_OK;
            else if ((i == 'N') || (j == 'N'))
                wRetStat = SIO_NAK;
            else
                wRetStat = SIO_TIMEOUT;
            }
        EI();
        }
    else
        wRetStat = SIO_NAK;
    
LexitSIO:
/*  print("SIOV returning %d\n", wRetStat); */
    /* return status */
    return wRetStat;
    }


