
/***************************************************************************

    XMON.C

    - 6502 debugger/monitor

    01/30/88 created

    01/26/89 21:00

***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include "xglobal.h"

/* monitor screen size */
#define XCOMAX  78
#define YCOMAX  22
#define MAXBYTE 16

extern int fTrace, exit_code;

unsigned int uMemDump = 0, uMemDasm = 0;
char rgchHex[] = "0123456789ABCDEF";

char szCR[] = "\n\r";


char rgchIn[XCOMAX+2],  /* monitor line input buffer */
     rgchOut[XCOMAX+2],
     ch,              /* character at rgch[ich] */
     fHardCopy=FALSE; /* if non-zero dumps to printer */

int  cchIn,           /* cch of buffer */
     ichIn,           /* index into buffer character */
     cchOut,          /* size of output string */
     hand;            /* disk handle */


int fMON=FALSE;       /* TRUE if we are in 6502 monitor */

#ifdef LATER
struct DTA {                   /* for disk directories */
         char reserved[21] ;
         char attrib ;
         int time, date ;
         long size ;
         char fname[11] ;
       }  ioblock ;

struct disk_info {
         long b_free,b_total,b_sec_siz,b_cl_siz ; } diskblock ;
#endif

extern long rglMnemonics[] ;

/*********************************************************************/

/* format of mnemonics: 3 ascii codes of the opcode and the addressing mode:
   00 - implied     01 - immediate     02 - zero page         03 - zero page,x
   04 - zero page,y 05 - (zero page,x) 06 - (zero page),y
   07 - absolute    08 - absolute,x    09 - absolute,y        0A - accumulator
   0B - relative    0C - indirect      0D - absolute indirect

   used by the 6502 monitor for disassembling code
*/

long rglMnemonics[256] =
 {
 0x42524B00L, 0x4F524105L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x4F524102L,
 0x41534C02L, 0x3F3F3F00L, 0x50485000L, 0x4F524101L, 0x41534C0AL, 0x3F3F3F00L,
 0x3F3F3F00L, 0x4F524107L, 0x41534C07L, 0x3F3F3F00L, 0x42504C0BL, 0x4F524106L,
 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x4F524103L, 0x41534C03L, 0x3F3F3F00L,
 0x434C4300L, 0x4F524109L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x4F524108L,
 0x41534C08L, 0x3F3F3F00L, 0x4A535207L, 0x414E4405L, 0x3F3F3F00L, 0x3F3F3F00L,
 0x42495402L, 0x414E4402L, 0x524F4C02L, 0x3F3F3F00L, 0x504C5000L, 0x414E4401L,
 0x524F4C0AL, 0x3F3F3F00L, 0x42495407L, 0x414E4407L, 0x524F4C07L, 0x3F3F3F00L,
 0x424D490BL, 0x414E4406L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x414E4403L,
 0x524F4C03L, 0x3F3F3F00L, 0x53454300L, 0x414E4409L, 0x3F3F3F00L, 0x3F3F3F00L,
 0x3F3F3F00L, 0x414E4408L, 0x524F4C08L, 0x3F3F3F00L, 0x52544900L, 0x454F5205L,
 0x4C53520AL, 0x3F3F3F00L, 0x4A4D5007L, 0x454F5202L, 0x4C535202L, 0x3F3F3F00L,
 0x50484100L, 0x454F5201L, 0x4C53520AL, 0x3F3F3F00L, 0x4A4D5007L, 0x454F5207L,
 0x4C535207L, 0x3F3F3F00L, 0x4256430BL, 0x454F5206L, 0x3F3F3F00L, 0x3F3F3F00L,
 0x3F3F3F00L, 0x454F5203L, 0x4C535203L, 0x3F3F3F00L, 0x434C4900L, 0x454F5209L,
 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x454F5208L, 0x4C535208L, 0x3F3F3F00L,
 0x52545300L, 0x41444305L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x41444302L,
 0x524F5202L, 0x3F3F3F00L, 0x504C4100L, 0x41444301L, 0x524F520AL, 0x3F3F3F00L,
 0x4A4D500CL, 0x41444307L, 0x524F5207L, 0x3F3F3F00L, 0x4256530BL, 0x41444306L,
 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x41444303L, 0x524F5203L, 0x3F3F3F00L,
 0x53454900L, 0x41444309L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x41444308L,
 0x524F5208L, 0x3F3F3F00L, 0X3F3F3F00L, 0X53544105L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X53545902L, 0X53544102L, 0X53545802L, 0X3F3F3F00L, 0X44455900L, 0X3F3F3F00L,
 0X54584100L, 0X3F3F3F00L, 0X53545907L, 0X53544107L, 0X53545807L, 0X3F3F3F00L,
 0X4243430BL, 0X53544106L, 0X3F3F3F00L, 0X3F3F3F00L, 0X53545903L, 0X53544103L,
 0X53545804L, 0X3F3F3F00L, 0X54594100L, 0X53544109L, 0X54585300L, 0X3F3F3F00L,
 0X3F3F3F00L, 0X53544108L, 0X3F3F3F00L, 0X3F3F3F00L, 0X4C445901L, 0X4C444105L,
 0X4C445801L, 0X3F3F3F00L, 0X4C445902L, 0X4C444102L, 0X4C445802L, 0X3F3F3F00L,
 0X54415900L, 0X4C444101L, 0X54415800L, 0X3F3F3F00L, 0X4C445907L, 0X4C444107L,
 0X4C445807L, 0X3F3F3F00L, 0X4243530BL, 0X4C444106L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X4C445903L, 0X4C444103L, 0X4C445804L, 0X3F3F3F00L, 0X434C5600L, 0X4C444109L,
 0X54535800L, 0X3F3F3F00L, 0X4C445908L, 0X4C444108L, 0X4C445809L, 0X3F3F3F00L,
 0X43505901L, 0X434D5005L, 0X3F3F3F00L, 0X3F3F3F00L, 0X43505902L, 0X434d5002L,
 0X44454302L, 0X3F3F3F00L, 0X494E5900L, 0X434D5001L, 0X44455800L, 0X3F3F3F00L,
 0X43505907L, 0X434D5007L, 0X44454307L, 0X3F3F3F00L, 0X424E450BL, 0X434D5006L,
 0X3F3F3F00L, 0X3F3F3F00L, 0X3F3F3F00L, 0X434D5003L, 0X44454303L, 0X3F3F3F00L,
 0X434C4400L, 0X434D5009L, 0X3F3F3F00L, 0X3F3F3F00L, 0X3F3F3F00L, 0X434D5008L,
 0X44454308L, 0X3F3F3F00L, 0X43505801L, 0X53424305L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X43505802L, 0X53424302L, 0X494E4302L, 0X3F3F3F00L, 0X494E5800L, 0X53424301L,
 0X4E4F5000L, 0X3F3F3F00L, 0X43505807L, 0X53424307L, 0X494E4307L, 0X3F3F3F00L,
 0X4245510BL, 0X53424306L, 0X3F3F3F00L, 0X3F3F3F00L, 0X3F3F3F00L, 0X53424303L,
 0X494E4303L, 0X3F3F3F00L, 0X53454400L, 0X53424309L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X3F3F3F00L, 0X53424308L, 0X494E4308L, 0X3F3F3F00L
 } ;


outchar(ch)
char ch ;
    {
    if (ch & 0x80)
        {
        Cconws("\033p");
        Bconout (5,ch & 0x7F);
        Cconws("\033q");
        }
    else
        Bconout (5,ch);

    /* check if hardcopy on and printer ready */
    if ((fHardCopy) && (Bconstat(0)))
        Bconout (0,ch) ;

    if ((Bconstat(2)!=0) && ((char)(Bconin(2))==' '))
        Bconin(2);
    }

OutPchCch(pch, cch)
char *pch;
int cch;
    {
    while (cch--)
        outchar(*pch++);
    }

GetLine()
    {
    register long key;     /* return value of Bconin */
    register int wScan, wChar;

    cchIn = 0;      /* initialize input line cchIngth to 0 */
    Bconout(2,'>');

    loop
        {
        key = Bconin(2);
        wChar = (int)key;

#ifdef NEVER
        /* convert to uppercase */
        if (wChar>='a' && wChar<='z')
            wChar -= 32;
#endif
        /* if it's printable then print it and store it */
        if (wChar>=' ' && wChar < '~')
            {
            Bconout(2,wChar);
            rgchIn[cchIn++] = wChar;
            }

        /* if Backspace, delete last char */
        else if (wChar == 8 && cchIn>0)
            {           
            Cconws("\b \b");
            cchIn--;
            }

        /* Esc clears line */
        else if (wChar == 27)
            {
            Cconws("\033l>");
            cchIn = 0;
            }

#ifdef LATER
        /* if special key, get scan code */
        if (cchIn==0 && ch==0) {                /* if special key */
      ch = (char) (key>>16) ;             /* get scan code */
      if (ch==0x47) cls() ;                 /* is it Home? */
      if (ch==0x62) help() ;              /* is it Help? */
      break ;                             /* break out of loop */
      }
#endif
        /* stay in loop until rgchInfer full or Return pressed */
        if ((cchIn==XCOMAX) || (wChar==13 && cchIn))
            break;
        }
    Cconws(szCR);
    /* terminate input line with a space and null */
    rgchIn[cchIn] = ' ';
    rgchIn[cchIn+1] = 0;
    ichIn = 0;
    }

/* advance ichIn to point to non-space */
int FSkipSpace()
    {
    char ch;
    while ((ch = rgchIn[ichIn]) == ' ' && ichIn<cchIn)
        ichIn++ ;
    return (ichIn < cchIn);
    }


/* returns 0-15 if a valid hex character is at rgchIn[ichIn], else -1 */
/* returns -2 if character was a space */
int NextHexChar()
    {
    char ch;

    ch = rgchIn[ichIn++];

    if (ch>='0' && ch<='9')
        return ch-'0';
    if (ch>='A' && ch<='F')
        return ch-'A'+10;
    if (ch>='a' && ch<='f')
        return ch-'a'+10;

    return ((ch == ' ') ? -2 : -1);
    }

/* Get 8 bit value at rgchIn[ichIn]. Returns TRUE if valid number */
int FGetByte(pu)
register unsigned *pu;
    {
    register int x;
    int w=0, digit=0 ;

    if (!FSkipSpace())
        return FALSE;
    while (((x = NextHexChar()) >= 0) && digit++ < 2)
        {
        w <<= 4 ;
        w += x;
        }
    *pu = w;
    return (x != -1);
    }


/* Get 16 bit value at rgchIn[ichIn]. Returns TRUE if valid number */
int FGetWord(pu)
register unsigned *pu;
    {
    register int x;
    int w=0, digit=0 ;

    if (!FSkipSpace())
        return FALSE;
    while (((x = NextHexChar()) >= 0) && digit++ < 4)
        {
        w <<= 4 ;
        w += x;
        }
    *pu = w;
#ifdef NDEBUG
    print("FGetWord(): x = %d   returning %d\n", x, (x != -1));
#endif
    return (x != -1);
    }

mon()            /* the 6502 monitor */
    {
    register char chCom;                 /* command character */
    char ch;
    unsigned int pc, addr1, addr2, addr3;
    char *mem = (char *) lMemory;
    int cch;
    register int digit, cNum, cLines;
    unsigned u1, u2, u3, u4;
    register char *pch;
    unsigned char header[6];

    fMON=TRUE;

    /* position cursor to bottom of screen, so that the title scrolls off */
    Cconws ("\033E\n  6502 Monitor\n\r\n");

    Cursconf(1,0);
    loop
        {
        GetLine();
        FSkipSpace();              /* skip any leading spaces */

        chCom = rgchIn[ichIn++] ;      /* get command character */

        if ((chCom >= 'a') && (chCom <= 'z'))
            chCom -= 32;

        if (chCom == 'X')
            break;

        if (chCom == ';')
            continue;

        pch = rgchOut;

        /* Can't use a switch statement because that calls Binsrch */
        if (chCom == 'M')
            {
            if (FGetWord(&u1))
                {
#ifdef NDEBUG
                print("u1 OK = %4x\n", u1);
#endif
                uMemDump = u1;
                if (FGetWord(&u2))
                    {
#ifdef NDEBUG
                    print("u1 OK = %4x\n", u1);
#endif
                    u2++;
                    }
                else
                    u2 = u1 + MAXBYTE;
                }
            else
                {
                u2 = uMemDump + 16*MAXBYTE;
                }

#ifdef NDEBUG
            print("dump: u1 = %4x  u2 = %4x   uMemDump = %4x\n",
                u1, u2, uMemDump);
#endif
            do
                {
                Blitcz(' ', rgchOut, XCOMAX);
                rgchOut[0] = ':';
                rgchOut[57] = '\'';
                XtoPch((char *)&rgchOut[1], uMemDump);

                for (cNum=0; cNum<MAXBYTE; cNum++)
                    {
                    BtoPch(&rgchOut[7 + 3*cNum + (cNum>=MAXBYTE/2)],
                          ch = Peek(uMemDump++));
                    rgchOut[cNum+58] = ch;
                    if (uMemDump == u2)
                        break;
                    }
                OutPchCch(rgchOut,74);
                Cconws(szCR);
                } while (uMemDump != u2);
            }
        else if (chCom == 'D')
            {
            if (FGetWord(&u1))
                uMemDasm = u1;

            for (cNum=0; cNum<20; cNum++)
                {
                Blitcz(' ', rgchOut, XCOMAX);
                cch = CchDisAsm(rgchOut, &uMemDasm);
                OutPchCch(rgchOut, cch);
                Cconws(szCR);
                }
            }

        else if (chCom == '.')
            {
            /* dump/modify registers */
            Blitcz(' ', rgchOut, XCOMAX);
            cch = CchShowRegs(rgchOut);
            OutPchCch(rgchOut, cch);
            Cconws(szCR);
            }

        else if (chCom == 'H')
            {
            /* set hardcopy on/off flag */
            if (FGetByte(&u1))
                fHardCopy = u1;
            }
        else if (chCom == 'B')
            {
            ColdStart();
            cch = CchShowRegs(rgchOut);
            OutPchCch(rgchOut, cch);
            Cconws(szCR);
            }
        else if (chCom == ':')
            {
            /* modify memory */
            if (!FGetWord(&u1))
                Cconws("invalid address");
            else while (FGetByte(&u2))
                Poke(u1++, u2);
            }
        else if (chCom == 'M')
            {
#ifdef NEVER
            pc = addr1 ;          /* block memory move */
            addr2 = get_addr() ;
            addr3 = get_addr() ;
            while (addr1<=addr2) *(mem+addr3++) = *(mem+addr1++) ;
#endif
            }
        else if (chCom == 'C')
            {
#ifdef NEVER
            pc = addr1 ;          /* block memory compare */
            addr2 = get_addr() ;
            addr3 = get_addr() ;
            while (addr1<=addr2)
                {
                if (*(mem+addr3++) != *(mem+addr1++))
                    {
                    print(" (");
                    showaddr(addr1-1);
                    print(") ");
                    showhex(addr1-1);
                    print("   (");
                    showaddr(addr3-1);
                    print(") ");
                    showhex(addr3-1);
                    Cconws(szCR);
                    }
                }
#endif
            }
        else if (chCom == 'C')
            {
#ifdef NEVER
            show_emul() ;       /* view virtual machine screen */
            getchar() ;
            show_scr() ;
#endif
            }
        else if ((chCom == 'G') || (chCom == 'S') || (chCom == 'T'))
            {
            unsigned int u;

            cLines = (chCom == 'T') ? 20 : 1;
            fTrace = (chCom != 'G');

            if (FGetWord(&u1))
                reg_PC = u1;

            while (cLines--)
                {
                Blitcz(' ', rgchOut, XCOMAX);
                u = reg_PC;
                CchDisAsm(rgchOut, &u);
                do_do_execute();
                cch = CchShowRegs(rgchOut+32);
                OutPchCch(rgchOut, 32+cch);
                Cconws(szCR);
                }
            print("Exit code = %d\n", exit_code);
            }
        else
            Cconws("what??\007\r\n");
        }

    fMON=FALSE;
    Cursconf(0,0);
    }

int XtoPch(pch, u)
register char *pch;
register unsigned int u;
    {
    *pch++ = rgchHex[(u>>12)&0xF];
    *pch++ = rgchHex[(u>>8)&0xF];
    *pch++ = rgchHex[(u>>4)&0xF];
    *pch++ = rgchHex[u&0xF];
    }

int BtoPch(pch, b)
register char *pch;
register unsigned int b;
    {
    *pch++ = rgchHex[(b>>4)&0xF];
    *pch++ = rgchHex[b&0xF];
    }

ColdStart()
    {
    /* clear all registers */
    reg_A = 0;
    reg_X = 0;
    reg_Y = 0;
    reg_P = 0xFF;

    /* set initial SP = $FF */
    reg_SP = 0x1FF;
    reg_PC = 0;

    fReboot = FALSE;
    do_do_execute();
    }


/************************************************************************

    6502 Monitor subroutines, kept here for uP independence

************************************************************************/

int Peek(uAddr)
unsigned uAddr;
    {
    return ((int) *(char *)(lMemory + (long)uAddr)) & 0xFF;
    }

int Dpeek(uAddr)
unsigned uAddr;
    {
    return (unsigned)(Peek(uAddr)) + (unsigned)(Peek(uAddr+1)<<8);
    }

void Poke(uAddr, b)
unsigned uAddr;
int b;
    {
    *(char *)(lMemory + (long)uAddr) = (char)b;
    }

int CchShowRegs(pch)
register char *pch;
    {
    register char regP = reg_P;
    register char chNil = '.';

    Blit("PC:     A:   X:   Y:   SP:   P:   ", pch);

    XtoPch(pch+3, reg_PC);
    BtoPch(pch+10, reg_A);
    BtoPch(pch+15, reg_X);
    BtoPch(pch+20, reg_Y);
    BtoPch(pch+26, reg_SP);
    BtoPch(pch+31, regP);
    pch[34] = (regP & NBIT) ? 'N' : chNil;
    pch[35] = (regP & VBIT) ? 'V' : chNil;
    pch[36] = '_';
    pch[37] = (regP & BBIT) ? 'B' : chNil;
    pch[38] = (regP & DBIT) ? 'D' : chNil;
    pch[39] = (regP & IBIT) ? 'I' : chNil;
    pch[40] = (regP & ZBIT) ? 'Z' : chNil;
    pch[41] = (regP & CBIT) ? 'C' : chNil;

    return 42;
    }


/* Disassemble instruction at location uMem to space filled buffer pch. */
/* Returns with puMem incremented appropriate number of bytes. */

int CchDisAsm(pch, puMem)
register char *pch;
register unsigned int *puMem;
    {
    register unsigned char bOpcode;
    register long lPackedOp;
    register char *pch0 = pch;
    register int md;

    *pch++ = ',';
    XtoPch(pch, *puMem) + 1;
    pch += 5;

    /* get opcode */
    bOpcode = Peek(*puMem);
    BtoPch(pch, bOpcode);

    /* get packed opcode mnemonic and addressing mode */
    lPackedOp = rglMnemonics[bOpcode] ;

    /* addressing mode is LSB of long */
    md = (int)(lPackedOp & 0x0FL);

    /* first hex dump the bytes of the instruction */
    switch (md)
        {
    /* 2 operands */
    case 0x07:
    case 0x08:
    case 0x09:
    case 0x0C:
        BtoPch(pch + 6, Peek(*puMem + 2));

    /* one operand */
    case 0x01:
    case 0x02:
    case 0x03:
    case 0x04:
    case 0x05:
    case 0x06:
    case 0x0B:
        BtoPch(pch + 3, Peek(*puMem + 1));

    /* no operands */
    case 0x00:
    case 0x0A:
        pch += 10;
        break;
        }

    /* now dump the mnemonic */
asm
    {
    move.b  #' ',lPackedOp      ; clear the addressing mode byte
    }
    Assert(((long)pch & 1L) == 0L, "dump mnemonic at odd address!!");
    *(long *)pch = lPackedOp;
    pch += 4;

    *puMem += 1;

    switch (md)
        {
    case 0x00:
        break;

    case 0x01:
        pch = Blit("#$", pch);
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        *puMem += 1;
        break;

    case 0x02:
        *pch++ = '$';
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        *puMem += 1;
        break;

    case 0x03:
        *pch++ = '$';
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        pch = Blit(",X",pch);
        *puMem += 1;
        break;

    case 0x04:
        *pch++ = '$';
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        pch = Blit(",Y",pch);
        *puMem += 1;
        break;

    case 0x05:
        pch = Blit("($", pch);
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        pch = Blit(",X)", pch);
        *puMem += 1;
        break;

    case 0x06:
        pch = Blit("($", pch);
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        pch = Blit("),Y", pch);
        *puMem += 1;
        break;

    case 0x07:
        *pch++ = '$';
        BtoPch(pch, Peek(*puMem + 1));
        pch += 2;
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        *puMem += 2;
        break;

    case 0x08:
        *pch++ = '$';
        BtoPch(pch, Peek(*puMem + 1));
        pch += 2;
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        *puMem += 2;
        pch = Blit(",X", pch);
        break;

    case 0x09:
        *pch++ = '$';
        BtoPch(pch, Peek(*puMem + 1));
        pch += 2;
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        *puMem += 2;
        pch = Blit(",Y", pch);
        break;

    case 0x0A:
        *pch++ = 'A';
        break;

    case 0x0B:
        {
        unsigned uMem;

        *pch++ = '$';
        uMem = (*puMem + 1 + (int)((char)Peek(*puMem)));
        BtoPch(pch, uMem>>8);
        pch += 2;
        BtoPch(pch, (char)uMem);
        pch += 2;
        *puMem += 1;
        }
        break;

    case 0x0C:
        pch = Blit("($", pch);
        BtoPch(pch, Peek(*puMem + 1));
        pch += 2;
        BtoPch(pch, Peek(*puMem));
        pch += 2;
        *pch++ = ')';
        *puMem += 2;
        break;
        }

    return (int)(pch - pch0);
    }

/***********************************************************************/

/* end of _XMON.C */

