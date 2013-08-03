
/***************************************************************************

    XSIOV.C

    - SIO emulation for Xformer 2.5

    02/14/89 created

    05/14/89 17:00

***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include "xglobal.h"
#include "xsio.h"

DRIVE rgDrives[8];


init_SIOV()
    {
    register int i;
    register int chDrive;
    register DRIVE *pdrive = &rgDrives[0];

    chDrive = Dgetdrv();

    for (i=0; i<8; i++)
        {
        pdrive->mode = MD_OFF;
        pdrive->fWP = 0;
        pdrive->wSectorMac = 0;
        pdrive->pbRAMdisk = 0L;
        pdrive->path[0] = chDrive + 'A';
        pdrive->path[1] = ':';
        Dgetpath(&pdrive->path[2], chDrive);
        pdrive->path[2] = '\\';
        pdrive->name[0] = 0;
        pdrive->name[1] = 0;
        update_drive(i);        /* update desktop */

        pdrive++;
        }
    pathXCX[0] = chDrive + 'A';
    }

SIOV()
    {
    unsigned int wDev, wDrive, wCom, wStat, wBuff, wBytes, wSector, bAux1, bAux2;
    int wTimeout;
    int fDD;
    register int wRetStat = SIO_OK;
    register int h;
    register int md;
    register DRIVE *pdrive;
    register unsigned long lcbSector;

#ifdef NDEBUG
    print("Device ID = %2x\n", Peek(0x300));
    print("Drive # = %2x\n", Peek(0x301));
    print("Command = %2x\n", Peek(0x302));
    print("SIO Command = %2x\n", Peek(0x303));
    print("Buffer = %2x\n", Dpeek(0x304));
    print("Timeout = %2x\n", Dpeek(0x306));
    print("Byte count = %2x\n", Dpeek(0x308));
    print("Sector = %2x\n", Dpeek(0x30A));
    print("Aux1 = %2x\n", Peek(0x30A));
    print("Aux2 = %2x\n", Peek(0x30B));
#endif

    wDev = Peek(0x300);
    wDrive = Peek(0x301)-1;
    wCom = Peek(0x302);
    wStat = Peek(0x303);
    wBuff = Dpeek(0x304);
    wTimeout = Dpeek(0x306);
    wBytes = Dpeek(0x308);
    wSector = Dpeek(0x30A);
    bAux1 = Peek(0x30A);
    bAux2 = Peek(0x30B);

    if (wDev == 0x31)       /* disk drives */
        {
        if ((wDrive < 0) || (wDrive >= 8))
            goto lTO;

        pdrive = &rgDrives[wDrive];

        md = pdrive->mode;

        if (md == MD_OFF)           /* drive is off */
            {
            wRetStat = 138;
            goto lExit;
            }

        if (md == MD_EXT)           /* drive is external */
            {
            if (fXCD)
                goto lEXT;
            else
                goto lTO;           /* no cable, no drive! */
            }

        if (md == MD_35)            /* 3.5" 720K disk */
            {
lNAK:
            wRetStat = SIO_NAK;
            goto lExit;
            }

        fDD = (md==MD_QD) || (md==MD_DD) || (md==MD_HD) || (md==MD_RD);

        if (pdrive->h == -1)
            goto lNAK;

        /* the disk # is valid, the sector # is valid, # bytes is valid */


        switch(wCom)
            {
        default:
         /*   print("SIO command %c\n", wCom); */
            wRetStat = SIO_NAK;
            break;
        
        /* format enhanced density, we don't support that */
        case '"':
            if (md != MD_ED)
                wRetStat = SIO_NAK;
            break;
  
        case '!':
            if (pdrive->fWP)       /* is drive write-protected? */
                {
                wRetStat = SIO_DEVDONE;
                break;
                }

            /* "format" disk, just zero all sectors */
            break;

        /* status request */
        case 'S':
          /*  print("SIO command 'S'\n"); */

            /* b7 = enhanced   b5 = DD/SD  b4 = motor on   b3 = write prot */
            Poke (wBuff++, ((md == MD_ED) ? 128 : 0) + (fDD ? 32 : 0) + (pdrive->fWP ? 8 : 0));

            Poke (wBuff++, 0xFF);         /* controller */
            Poke (wBuff++, 0xE0);         /* format timeout */
            Poke (wBuff, 0x00);           /* unused */
            break;
            
        /* get configuration */
        case 'N':
          /*  print("SIO command 'N'\n"); */
            if (md == MD_HD)
                {
                pdrive->wSectorMac--;
                Poke (wBuff++, 1);   /* tracks */
                Poke (wBuff++, 0);    /* ?? */
                Poke (wBuff++, pdrive->wSectorMac & 255);   /* ?? */
                Poke (wBuff++, pdrive->wSectorMac >> 8);    /* sectors/track */
                Poke (wBuff++, 0x00);         /* ?? */
                pdrive->wSectorMac++;
                }
            else
                {
                Poke (wBuff++, 0x28);         /* tracks */
                Poke (wBuff++, 0x02);         /* ?? */
                Poke (wBuff++, 0x00);         /* ?? */
                Poke (wBuff++, (md == MD_ED) ? 0x1A : 0x12); /* secs/track */
                Poke (wBuff++, 0x00);         /* ?? */
                }

            if (fDD)
                {
                Poke (wBuff++, 0x04);     /* density: 4 = dbl  0 = sng */
                Poke (wBuff++, 0x01);     /* bytes/sector hi */
                Poke (wBuff++, 0x00);     /* bytes/sector lo */
                }
            else
                {
                Poke (wBuff++, 0x00);     /* density: 4 = dbl  0 = sng */
                Poke (wBuff++, 0x00);     /* bytes/sector hi */
                Poke (wBuff++, 0x80);     /* bytes/sector lo */
                }
            Poke (wBuff++, 0xFF);         /* unused */
            Poke (wBuff++, 0xFF);         /* unused */
            Poke (wBuff++, 0xFF);         /* unused */
            Poke (wBuff, 0xFF);           /* unused */
            break;

        /* set configuration - we don't support it */
        case 'O':
          /*  print("SIO command 'O'\n"); */
            wRetStat = SIO_OK;
            break;
            goto lNAK;

        case 'P':
        case 'W':
        case 'R':
            if (wSector < 1)            /* invalid sector # */
                goto lNAK;

            if ((wSector < 4) || (md == MD_SD) || (md == MD_ED))
                {
                if (wBytes != 128)
                    goto lNAK;
                }
            else if (md == MD_HD)
                wBytes = 256;
            else if (wBytes != 256)
                goto lNAK;

            if ((md == MD_SD) || (md == MD_ED))
                lcbSector = 128L;
            else
                lcbSector = 256L;

            if (wSector > pdrive->wSectorMac)   /* invalid sector # */
                goto lNAK;

            if (md == MD_RD)
                {
                if ((wCom == 'R') && (wStat == 0x40))
                    {
                    Blitb(pdrive->pbRAMdisk +
                            (unsigned long)(wSector-1) * lcbSector,
                        lMemory+(unsigned)wBuff, wBytes);
                    wRetStat = SIO_OK;
                    }
                else if ((wCom == 'W') || (wCom == 'P'))
                    Blitb(lMemory+(unsigned)wBuff,
                       pdrive->pbRAMdisk +
                       (unsigned long)(wSector-1) * lcbSector, wBytes);
                    wRetStat = SIO_OK;
                break;
                }

            Fseek((unsigned long)(wSector-1) * lcbSector,pdrive->h,0);

            if ((wCom == 'R') && (wStat == 0x40))
                {
/*                print("Read: sector = %d  wBuff = $%4x  wBytes = %d  lcbSector = %ld  md = %d\n",
                    wSector, wBuff, wBytes, lcbSector, md);
*/
                /* temporary kludge to prevent reading over ROM */
            /*    if (wBuff >=uAtRAM)
                    wRetStat = SIO_OK;
                else */
                if (Fread(pdrive->h,(long)wBytes,lMemory+(unsigned)wBuff) < 0)
                    wRetStat = SIO_DEVDONE;
                else
                    wRetStat = SIO_OK;
                }
            else if ((wCom == 'W') || (wCom == 'P'))
                {
                if (wStat != 0x80)
                    goto lNAK;
                if (pdrive->fWP)
                    {
                    wRetStat = SIO_DEVDONE;
                    break;
                    }
                if (Fwrite(pdrive->h,(long)wBytes,lMemory+(unsigned)wBuff) < 0)
                    wRetStat = SIO_DEVDONE;
                else
                    wRetStat = SIO_OK;
                }
            break;
            }
        }
    else if (wDev == 0x40)      /* printer */
        {
#ifdef DEBUG
        print("printer SIO: wDev = %2x  wCom = %2x  wBytes = %2x\n",
            wDev, wCom, wBytes);
        print("SIO: wBuff = %4x  bAux1 = %2x  bAux2 = %2x\n",
            wBuff, bAux1, bAux2);
#endif

        if (fXCP)
            goto lEXT;

        switch(wCom)
            {
        /* status request */
        case 'S': 
            {
            long timeout = 1000000L;

            wRetStat = SIO_TIMEOUT;

            while (timeout--)
                {
                if ((*(char *)0xFFFFFA01L & 1) == 0)
                    {
                    wRetStat = SIO_OK;
                    break;
                    }
                }
            }
            break;
            
        case 'W':
            /* print line */
            {
            long timeout = 10000L;
            char *pchBuf = (char *)lMemory + (unsigned)wBuff;
            int  cch = wBytes;

            while ((pchBuf[cch-1] == ' ') && (cch>0))
                cch--;

            while ((cch-- > 0) && (wRetStat == SIO_OK))
                {
                while (timeout--)
                    {
                    if (Cprnos())
                        {                       /* if printer is ready */
                        if (*pchBuf != (char)0x9B)
                            Cprnout (*pchBuf++); /* check for CR and print */
                        else
                            {
                            pchBuf++;
                            Cprnout(13);     
                            Cprnout(10);
                            }
                        wRetStat = SIO_OK;
                        break;
                        }
                    wRetStat = SIO_TIMEOUT;  /* else status = timeout error */
                    }
                }
            }
            }
        }
    else if (fXCD)       /* assume device is on the serial bus */
        {
lEXT:
      /*  print("SIO command %c\n", wCom); */

        /* temporary kludge to prevent reading over ROM */
    /*    if ((wStat == 0x40) && (wBuff >=uAtRAM))
            wRetStat = SIO_OK;
        else */

        wRetStat = _SIOV(lMemory + (unsigned)wBuff, wDev+wDrive,
             wCom, wStat, wBytes, wSector, wTimeout);
#ifdef DEBUG
        if (wCom == 'S')
            {
            print("Status packet = %02x %02x %02x %02x\n",
                Peek(wBuff),
                Peek(wBuff+1),
                Peek(wBuff+2),
                Peek(wBuff+3));
            }
#endif
        }
    else
        {
lTO:
        wRetStat = SIO_TIMEOUT;
        }


#ifdef NDEBUG
    print("wRetStat = %d\n", wRetStat);
#endif

lExit:
    Poke (0x303,wRetStat);
    reg_Y = wRetStat;
    reg_Z = wRetStat;
    reg_N = (wRetStat & 0x80) ? TRUE : FALSE;
    reg_PC = 0xE45B;
    }


