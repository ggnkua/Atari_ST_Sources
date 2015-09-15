
/***************************************************************************

   XFORMER.C   by Darek Mihocka  (CIS: 73657,2714    GEnie: DAREKM)

   Additional programming by Ignac A. Kolenko Jr. and Barry Green

   Created: July 15, 1986       Last update: June 18, 1987   13:30

   Coding convention used in this code:

   Code that's all bunched up like this:

    foo() {
       if (bar) {
           goo();
         }
     }

   should be re-written as:

     foo()
         {
         if (bar)
             {
             goo();
             }
         }

   For improved readability and easier debugging of complex expressions,
   variable names should start with the following prefixes:

    f - (flag) integer that can only have 2 values
    md - (mode) integer that can take on a few values
    b - byte
    ch - char
    w - signed integer
    u - unsigned integer
    l - long
    p - (near pointer) 16 bit pointer (not used, same as a q in this program)
    q - (far pointer) 32 bit pointer
    rgn - (range) a fixed array of n, where n is one of the above prefixes
    mpxy - (map) an array of type y that maps an x to a y
    st - (string) pointer to a character string, first byte is the length
    sz - (zero string) pointer to a null terminated string

  Follow these rules or forever write buggy code!

  This file contains no tabs cuz the editor I use expands tabs.

 ***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include "_xformer.h"              /* defines and global vars */

#define MAXCOL  78
#define MAXROW  22
#define MAXBYTE 16

char strCR[3] = {'\n','\r',0 };

static char *hex= {"0123456789ABCDEF"} ;

char buf[80] ,        /* monitor line input buffer */
     ch ,             /* character at buf[tp] */
     asc[17] ,        /* buffer for ASCII dump */
     hardcopy=FALSE;  /* if non-zero dumps to printer */

char
     *mem,            /* 65536 bytes to simulate 6502 memory */
     *stat,           /* status bits for each byte */
     *scr,            /* pointer to start of screen */
     *scr_emul,       /* pointer to start of emulation screen */
     *exitptr ;       /* pointer to exit_emul */

int  len,             /* length of inputted line */
     tp ,             /* pointer to current character in buf[] */
     hand,            /* disk handle */
     fRainbow=FALSE,  /* 128 colour on flag */
     fCartA = FALSE,  /* cartridge present flag */
     fCartB = FALSE,  /* cartridge present flag */
     isread,          /* read/write flag for opcodes */
     mode ;           /* screen rez */


int rgPalette[2][16] = {{0x006,0,0,0x557,0,0,0,0,0,0,0,0,0,0,0,0x557}};

unsigned int pc ,     /* program counter (16 bits) */
             ea ;
unsigned char a,x,y,sp,ir, p, fTrace ;

int colours[16];

int fMON=FALSE;

int fExec;            /* TRUE to run binary loads */

struct DTA {                   /* for disk directories */
         char reserved[21] ;
         char attrib ;
         int time, date ;
         long size ;
         char fname[11] ;
       }  ioblock ;

struct disk_info {
         long b_free,b_total,b_sec_siz,b_cl_siz ; } diskblock ;

extern long mnemonics[] ;

/*********************************************************************/

overlay "extra"

draw_menu ()
    {
    Setscreen(-1L,-1L,DISPMODE0);
    colors4();
    CR;
    print ("  ST XFORMER v 1.1 DOS MENU"); CR;
    CR;
    print ("  A. DIRECTORY"); CR;
    print ("  B. RUN CART."); CR;
    print ("  L. BINARY LOAD "); CR;
    print ("  M. RUN AT ADDR."); CR;
    print ("  P. 6502 MONITOR");CR;
    print ("  Q. Quit to Desktop"); CR;
    CR;
    }

help ()
    {
    print("   \033pCommand Summary for the 6502 Monitor\033q\n\r") ;
    CR ;
    print("  Syntax: ( all numbers are in hex )\n\r") ;
    print("    ssss - starting address       eeee - ending address\n\r") ;
    print("    dddd - destination address    nn   - an 8 bit value\n\r") ;
    print("    [optional parameters are shown in brackets]\n\r") ;
    CR ;
    print(
   "    : ssss nn [nn [nn [nn ...]]] - change memory starting from ssss\n\r") ;
    print("    B - coldstart the Atari 800\n\r") ;
    print("    D ssss [eeee] - display memory from ssss [to eeee]\n\r") ;
    print("    G ssss - start emulating at ssss \n\r") ;
    print("    H nn - nn is non-zero for hardcopy \n\r") ;
    print("    I [mask] - dIr of files on the disk\n\r") ;
    print("    L ssss [eeee] - disassemble from ssss [to eeee]\n\r") ;
    print("    M ssss eeee dddd - move memory block from ssss to dddd\n\r") ;
    print("    R[X] file - read binary file [and execute]\n\r") ;
    print("    S [ssss] - single step at [ssss] or pc\n\r") ;
    print("    T [ssss] - trace at [ssss] or pc\n\r") ;
    print("    V - view emulated screen display\n\r") ;
    print("    W ssss eeee file - write binary file from ssss to dddd\n\r") ;
    print("    X - exit to menu") ;
    }

outchar(x) char x ;
  {
  Bconout (2,x) ;     /* print to screen */
  if ((hardcopy)&&(Bconstat(0)))
    Bconout (0,x) ;   /* print to printer */
  if ((Bconstat(2)!=0) && ((char)(Bconin(2))==' '))
    Bconin(2);
  }

put_line(lin)
register char *lin ;         /* write string to screen */
  {
  register char c ;

  while (c=*lin++) put (c) ;
  }


get_line(maxc) int maxc ;       /* get line in buf[], set tp and len */
  {
  long key ;      /* scan code and character code returned by Bconin */
  len = 0 ;       /* initialize input line length to 0 */

  LOOP
    {
    key = Bconin(2) ;                    /* get a key */
    ch = (char) key ;                    /* isolate character code */
    if (ch>='a' && ch<='z') ch -= 32 ;   /* lowercase becomes uppercase */
    if (ch>=' ' && ch <='_') {           /* if it's printable */
      put(ch) ;                          /* then print it and store it */
      buf[len++] = ch ;
      }                                   /* if Backspace, delete last */
    if (ch==8 && len>0) {                /* character and reduce buffer */
      print("\b \b") ;
      len-- ;
      }
    if (len==0 && ch==0) {                /* if special key */
      ch = (char) (key>>16) ;             /* get scan code */
      if (ch==0x47) cls() ;                 /* is it Home? */
      if (ch==0x62) help() ;              /* is it Help? */
      break ;                             /* break out of loop */
      }
                        /* stay in loop until buffer full or Return pressed */
    if (len==maxc || ch==13 || ch=='\n' || ch == '\033') break ;
    }
  CR ;
  buf[len] = 0 ;        /* terminate input line with a null character */
  tp = 0 ;              /* text pointer points to first character */
  }


skip_space ()           /* advance tp to point to non-space */
{
  while ((ch=buf[tp])==' ' && tp<len) tp++ ;
}


skip_blank ()            /* advance tp to point to non-blank */
{
  while (((ch=buf[tp])<'0' || (ch>'9' && ch<'A') || (ch>'F')) && tp<len) tp++ ;
}


unsigned char get_byte () {    /* return 8 bit value at tp */

  unsigned char byte=0, digit=0 ;

  skip_blank() ;
  while ((tp<len) && (                           /* find next hex character */
           ((ch = buf[tp]) >='0' && ch<='9') ||
           (ch>='A' && ch<='F')
           )
         && (digit++<2) ) {
    byte <<= 4 ;
    byte += (ch>='0' && ch<='9') ? ch-48 : ch-55 ;
    tp++ ;
   }
  return (byte) ;
}


unsigned int get_addr () {    /* return 16 bit value at tp */

  unsigned int addr=0, digit=0 ;

  skip_blank() ;
  while ( (((ch = buf[tp]) >='0' && ch<='9')
               || (ch>='A' && ch<='F'))
               && (digit++<4) ) {
    addr <<= 4 ;
    addr += (ch>='0' && ch<='9') ? ch-48 : ch-55 ;
    tp++ ;
   }
  return (addr) ;
}

     /* disassemble #line commands starting at current pc */

disasm(line) int line ;
    {

    int bits, modes ;
    unsigned char opcode ;
    long crunch ;

    while (line--)
        {
        showpc() ;
        opcode = *(mem+pc) ;
        crunch = mnemonics[opcode] ;

        modes = crunch&0x0FL ;

        showhex(pc) ;
        put(' ') ;

        switch (modes)
            {
        case 0x00 :
        case 0x0A :
            print ("      ") ;
            break ;
        case 0x01 :
        case 0x02 :
        case 0x03 :
        case 0x04 :
        case 0x05 :
        case 0x06 :
        case 0x0B :
            showhex(pc+1) ;
            print ("    ") ;
            break ;

        case 0x07 :
        case 0x08 :
        case 0x09 :
        case 0x0C :
            showhex(pc+1) ;
            put(' ') ;
            showhex(pc+2) ;
            put(' ') ;
            break ;
            }

        for (bits=24 ; bits >0 ; bits -=8 )
            {
            put((char)(crunch>>24)) ;
            crunch <<= 8 ;
            }
        put (' ') ;

        pc++ ;
        switch (modes)
            {
        case 0x00 :
            print ("         ") ;
            break ;

        case 0x01 :
            print (" #$") ;
            showhex(pc++) ;
            print ("    ") ;
            break ;

        case 0x02 :
            print(" $") ;
            showhex(pc++) ;
            print ("     ") ;
            break ;

        case 0x03 :
            print (" $") ;
            showhex(pc++) ;
            print (",X") ;
            print ("   ") ;
            break ;

        case 0x04 :
            print (" $") ;
            showhex (pc++) ;
            print (",Y") ;
            print ("   ") ;
            break ;

        case 0x05 :
            print (" ($") ;
            showhex (pc++) ;
            print (",X)") ;
            print (" ") ;
            break ;

        case 0x06 :
            print (" ($") ;
            showhex (pc++) ;
            print ("),Y") ;
            print (" ") ;
            break ;

        case 0x07 :
            print (" $") ;
            showhex (pc+1) ;
            showhex (pc) ;
            print ("   ") ;
            pc +=2 ;
            break ;

        case 0x08 :
            print (" $") ;
            showhex (pc+1) ;
            showhex (pc) ;
            pc +=2 ;
            print (",X") ;
            print (" ") ;
            break ;

        case 0x09 :
            print (" $") ;
            showhex (pc+1) ;
            showhex (pc) ;
            pc +=2 ;
            print (",Y") ;
            print (" ") ;
            break ;

        case 0x0A :
            print (" A") ;
            print ("       ") ;
            break ;

      case 0x0B :
            print (" $") ;
            showaddr (pc + 1 + (int)((char)(*(mem+pc)))) ;
            print ("   ") ;
            pc ++ ;
            break ;

      case 0x0C :
            print (" ($") ;
            showhex(pc+1) ;
            showhex(pc) ;
            put (')') ;
            print (" ") ;
            pc+=2 ;
            break ;
            }
        if (!fTrace) CR ;
        }
    }

showreg() {

  print ("PC=") ;  showpc() ;
  print ("A=") ;   showbyte(a) ;
  print (" X=") ;  showbyte(x) ;
  print (" Y=") ;  showbyte(y) ;
  print (" S=") ;  showbyte(sp) ;
  print (" P=") ;  showbyte(p) ;
  print (" ") ;
  (p&NBIT) ? put('N') : put ('.') ;
  (p&VBIT) ? put('V') : put ('.') ;
  (p&BBIT) ? put('B') : put ('.') ;
  (p&DBIT) ? put('D') : put ('.') ;
  (p&IBIT) ? put('I') : put ('.') ;
  (p&ZBIT) ? put('Z') : put ('.') ;
  (p&CBIT) ? put('C') : put ('.') ;
  put (' ') ;
}

boot()
    {
    for (ea=0; ea<32767; mem[ea++]=0);
    pc = (*(mem+0xFFFD)*256)+(*(mem+0xFFFC)) ; /* RESET vector */
    p &= ~BBIT ;
    emulate(0,0) ;
    colors4();
    }

/* routine to perform a JSR and come back on an RTS */

jsr(addr)
unsigned int addr;
    {
    pc = addr;
    p &= ~BBIT ;
    mem[0x100|sp--] = 0xE4;
    mem[0x100|sp--] = 0x70;   /* push blackboard vector on stack */
    emulate(0,0) ;
    colors4();
    }

  /* routine to single step, trace, or execute at current pc */

emulate (count, mode) int count, mode ;
    {
    unsigned int pctemp ;
    unsigned char ptemp ;
    long usp;

    Cursconf(0,0);
    switch (mode)
        {
    case 0 :       /* regular emulation */
        {
        static long RegA5;
        show_emul() ;
        colors16() ;
        usp = Super(0L) ;     /* must go to supervisor mode */
        *(char*)0x00000484L &= ~5; /* disable keyclick */
        Super(usp) ;
  asm
    {
    move.l    A5,RegA5(GLOBAL)  /* probably not needed any more */
    }
        IntOn();                /* turn on all interrupts */
        usp = Super(0L) ;
        execute() ;
        Super(usp) ;
        IntOff();               /* turn off interrupts */
  asm
    {
    move.l    RegA5(GLOBAL),A5
    }
        usp = Super(0L) ;
        *(char*)0x00000484L |= 5;  /* enable keyclick */
        Super(usp) ;
        show_scr() ;
        if (fMON)
            {
            showreg() ;
            CR ;
            }
        fTrace=0 ;
        }
        break ;

    case 1 :       /* single step mode */
        pctemp = pc ;    /* remember pc                    */
        fTrace=255 ;
        disasm(1) ; /* dissassemble current opcode    */
        pc = pctemp ;    /* restore pc                     */
        emulate(0,0) ;
        break ;

    case 2 :       /* trace mode */
        p &= ~BBIT ;
        while (count-- && !(p&BBIT)) emulate(0,1) ;
        break ;
        }
    Cursconf(1,0);
    }

dos()
    {
    int key;

    boot();
    draw_menu();

    for(;;)
        {
        CR;
        print ("  SELECT ITEM OR \033pRETURN\033q FOR MENU"); CR;
        CR;
        Cursconf(1,0);
        key  = Bconin(2) & 0x5F;
        put(key); CR;

        switch(key)
            {
        default:
            draw_menu();
            break;
        case 'A':
            print("DIRECTORY MASK: ");
            get_line(MAXCOL) ;          /* get a line of input */
            Directory(buf,0);
            break;
        case 'B':
            pc = 0xA000;     /* ####### WRONG *******/
            p &= ~BBIT ;
            emulate(0,0) ;
            break;
        case 'L':
            print("LOAD FILE: ");
            get_line(MAXCOL) ;          /* get a line of input */
            fExec=TRUE;
            Bload(buf);
            break;
        case 'M':
            print("RUN AT ADDRESS: ");
            get_line(MAXCOL) ;
            pc = get_addr();
            p &= ~BBIT ;
            emulate(0,0) ;
            break;
        case 'P':
            mon();
            break;
        case 'Q':
            return;
            }
        }
    }

mon()            /* the 6502 monitor */
    {

    int quit=0 ;                  /* quit flag */
    char com ;                    /* command character */
    int digit, chptr, cntr ;      /* temporary variables */
    unsigned addr1, addr2, addr3, byt ;
    unsigned char header[6] ;

    Setscreen(-1L,-1L,DISPMODE1);
    fMON=TRUE;
    show_scr();
    CR;
    Setcolor(0, 0x050);
    Setcolor(15, 0x777);
    print("6502 Monitor"); CR;

    Cursconf(1,0);
    do
        {
        print ("\n>") ;           /* print prompt */
        get_line(MAXCOL) ;          /* get a line of input */
        skip_space() ;              /* skip any leading spaces */
        com = buf[tp++] ;             /* get command character */

        if (com!='R') addr1 = get_addr() ;  /* no numbers for R */

        switch(com)
           {

        case '\000' :        /* empty line redraws menu */
        case ';' :           /* comment is ignored */
            break ;

        case 'X' : quit++ ;  /* X to quit */
            break ;

        case 'M' : pc = addr1 ;          /* block memory move */
            addr2 = get_addr() ;
            addr3 = get_addr() ;
            while (addr1<=addr2) *(mem+addr3++) = *(mem+addr1++) ;
            break ;

        case 'C' : pc = addr1 ;          /* block memory compare */
            addr2 = get_addr() ;
            addr3 = get_addr() ;
            while (addr1<=addr2)
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
                    CR;
                    }
            break ;

        case ':' :
            pc = addr1 ;          /* modify memory */
            skip_blank() ;
            while (buf[tp] && (tp<len))
                {
                *(mem+pc++) = get_byte() ;
                skip_blank() ;
                }
            break ;

        case 'D' :
            pc = addr1 ;        /* dump memory */
            addr2 = get_addr() ;
            if (addr2 <= addr1) addr2 = addr1 + MAXBYTE - 1 ;
                do
                    {
                    showpc() ;
                    for (cntr=0; cntr<MAXBYTE; cntr++)
                        {
                        if (pc<=addr2)
                            {
                            ch = (*(mem+pc))&0x7F ;
                            asc[cntr] = (ch>=32 && ch<=127) ? ch : '.' ;
                            showhex(pc++) ;
                            put (' ');
                            }
                        else
                            {
                            asc[cntr] = ' ' ;
                            print ("   ") ;
                            }
                        }
                    for (cntr=0; cntr<MAXBYTE; cntr++) put(asc[cntr]) ;
                    CR ;
                    } while (pc<=addr2 && pc>0x000F) ;
            break ;

        case 'L' :
            if (len>1) pc = addr1 ;     /* disassemble memory */
            disasm(MAXROW-4) ;
            break ;

        case 'T' :
            if (len>1) pc = addr1 ;     /* trace execution */
            p &= ~BBIT ;
            emulate(MAXROW-4,2) ;
            break ;

        case 'B' :
            boot();
            break ;

        case 'G' :
            pc = addr1 ;                /* execute 6502 code */
            p &= ~BBIT ;
            emulate(0,0) ;
            break ;

        case 'S' :
            if (len>1) pc = addr1 ;     /* step execution */
            emulate(0,1) ;
            break ;

        case '.' : showreg() ;            /* dump registers */
            break ;

        case 'I' : skip_space();
            CR;
            Directory(&buf[2],0);
            CR;
            break ;

        case 'W' :
            pc = addr1 ;            /* write memory to binary file */
            addr2 = get_addr() ;
            if (addr2 < addr1) break ;
            skip_space() ;
            if (tp==len) break ;
            strncpy (&buf[len],".bin",5) ;      /* append to filename */
            if ((hand=Fcreate (&buf[tp],0))<0) break ;
            print ("Writing...") ; CR ;
            header[0] = header[1] = 255 ;
            header[2] = addr1 ;           /* lo - hi format */
            header[3] = addr1>>8 ;
            header[4] = addr2 ;
            header[5] = addr2>>8 ;
            if (Fwrite (hand,6L,header)<0)
                {
                print ("Write error") ; CR ;
                goto err_close ;
                }
            if (Fwrite
                 (hand,(long)addr2-(long)addr1+1L,
                  mem+addr1)<0)
                print ("Write error") ; CR ;
  err_close:
            Fclose (hand) ;
            break ;

        case 'R' :
            if (buf[tp]=='X')
                {
                fExec=TRUE;
                tp++;
                }
            else
                fExec=FALSE;
            skip_space() ;            /* read binary file to memory */
            if (tp==len) break ;
            strncpy (&buf[len],".bin",5) ;

            Bload(&buf[tp]);
            break;

        case 'H' :
            hardcopy = addr1 ;         /* set hardcopy on/off flag */
            break ;

        case 'V' :
            show_emul() ;       /* view virtual machine screen */
            getchar() ;
            show_scr() ;
            break ;

        default :
            put(BEL) ;                 /* otherwise beep */
            }
        } while (!quit) ;

    Setscreen(-1L,-1L,DISPMODE0);
    fMON=FALSE;
    show_scr();
    Cursconf(0,0);
    }

/* Binary load a file *****************************************

   -szName points to GEMDOS compatible name

 returns: 1 - OK   0 - error
*/

Bload(szName)
char *szName;
    {
    register unsigned addr1, addr2 ;
    unsigned char header[6] ;
    register int cntr ;      /* temporary variables */

    if ((hand = Fopen (szName,0))<0)
        {
        print ("FILE NOT FOUND") ; CR ;
        goto Rclose ;
        }

    mem[0x2E0] = mem[0x2E1] = 0;     /* clear RUN and INIT vectors */
    mem[0x2E2] = mem[0x2E3] = 0;

    if (Fread (hand,6L,header)<0)
        {
        print ("READ ERROR") ; CR ;
        goto Rclose ;
        }

    if (header[1]&header[0] != 255)  /* verify it's binary file */
        {
        print ("NOT BINARY FILE") ;
        goto Rclose ;
        }

    addr1 = header[2] + (header[3] << 8) ;
    addr2 = header[4] + (header[5] << 8) ;

    if (Fread (hand,(long)addr2-(long)addr1+1L, mem+addr1)<0)
        {
        print ("READ ERROR") ;
        goto Rclose ;
        }

    if (fMON)
        {
        printf ("SEGMENT START: %4x  END: %4x\n",addr1,addr2) ;
        fflush(stdout);
        }
    cntr=0;

more_segs:
    header[0]=header[1]=255;
    if (Fread (hand,2L,header)<0)
        {
        print ("READ ERROR") ;
        goto Rclose ;
        }

 /* check if EOF reached */
    if ((cntr++ == 2) || ((header[1]==26) && (header[0]==26))
            || ((header[1]==0) && (header[0] == 0)))
        {
        Fclose (hand) ;
        if (fExec && (mem[0x2E0]|mem[0x2E1]))   /* run location */
            jsr((unsigned)mem[0x2E0] + (unsigned)(256*(unsigned)(mem[0x2E1])));
        show_scr();
        return;
        }

    if (header[1]&header[0] == 255)
        goto more_segs ;

    cntr=0;
    if (Fread (hand,2L,&header[2])<0)
        goto Rclose;
    addr1 = header[0] + (header[1] << 8) ;
    addr2 = header[2] + (header[3] << 8) ;
    if (Fread(hand,(long)addr2-(long)addr1+1L, mem+addr1)<0)
        {
        print ("READ ERROR") ;
        goto Rclose ;
        }

    if (fMON)
        {
        printf ("SEGMENT START: %4x  END: %4x\n",addr1,addr2) ;
        fflush(stdout);
        }

    if (fExec && (mem[0x2E2]|mem[0x2E3]))    /* initialize location */
        {
        jsr((unsigned)mem[0x2E2] + (unsigned)(256*(unsigned)(mem[0x2E3])));
        mem[0x2E2] = mem[0x2E3] = 0;
        show_scr();
        }
    goto more_segs;

Rclose:
    Fclose (hand) ;
    show_scr();
    }


StoreCols()
    {
    register cw=16;

    while (cw--)
        colours[cw] = Setcolor(cw,-1);
    }

/* restore old colours */

RestoreCols()
    {
    register cw=16;

    while (cw--)
        Setcolor(cw,colours[cw]);
    }

/* copy from pchFrom to pchTo and return pointer to byte after */

char *blit(pchFrom, pchTo)
register char *pchFrom, *pchTo;
    {
    while (*pchFrom)
        *pchTo++ = *pchFrom++;
    return(pchTo);
    }

/* copy ch to pchTo cb times and return pointer to byte after */

char *blitc(ch, pchTo, cb)
register char ch;
register char *pchTo;
register unsigned int cb;
    {
    while (cb--)
        *pchTo++ = ch;
    return(pchTo);
    }

showpc()
    {                          /* print out PC */
    int bit ;

    for (bit = 12; bit>=0; bit-=4)
        put (hex[(pc>>bit)&0x0F]) ;
    print(": ") ;
    }


showaddr(addr) unsigned int addr ;  /* print 16 bit number */
    {
    put (hex[addr>>12]) ;
    put (hex[(addr>>8)&0x0f]) ;
    put (hex[(addr>>4)&0x0f]) ;
    put (hex[addr&0x0f]) ;
    }

showhex(addr) unsigned int addr ;   /* print 8 bit number in memory */
    {
    unsigned char byte ;

    byte = *(mem+addr) ;
    put (hex[byte>>4]) ;
    put (hex[byte&0x0f]) ;
    }

showbyte(byte) unsigned char byte ; /* print 8 bit number */
    {
    put (hex[byte>>4]) ;
    put (hex[byte&0x0f]) ;
    }

show_emul()
    {                       /* display virtual video chip output */
    long usp;
    Setscreen (scr_emul,scr_emul,-1) ;
    usp = Super(0L) ;
    *(char *)0xFFFF8260=DISPMODE0;
    Super(usp);
    colors16();
    }

show_scr()
    {                        /* display 6502 monitor or DOS output */
    long usp;
    Setscreen (scr,scr,-1) ;
    usp = Super(0L) ;
    if (fMON)
        *(char *)0xFFFF8260=DISPMODE1;
    else
        *(char *)0xFFFF8260=DISPMODE0;
    Super(usp);
    colors4();
    }

cls()
    {
    put (27) ; put ('E') ;
    }

colors4()
    {
    Setpalette(rgPalette[0]);
    }

colors16()
    {
    Setpalette(rgPalette[1]);
    }

/***************  Routines to do the rainbow title page *************/

#define HBLANK 0x68L
#define VBLANK 0x70L

extern hblank(), old_hblank();
extern vblank(), old_vblank();
extern where_col();

ignore()
    {
  asm
    {
vcount:
    nop
    nop
hcount:
    nop
hblank:
    movem.l D0/A0,-(A7)
    clr.l   D0
    move.b  0x8207,-(A7)
    move.w  (A7)+,D0
    move.b  0x8209,D0
    divu    #20,D0
    add.w   vcount(PC),D0
    lsr.w   #3,D0
    andi.l  #254,D0
    move.l  where_col(PC),A0
    move.w  0(A0,D0.L),D0
    move.w  D0,0x8246
    movem.l (A7)+,D0/A0
    rte
old_hblank:
    dc.l    0
    nop
where_col:
    dc.l    0

vblank:
    movem.l D0/A0/A1,-(A7)
    lea     hcount,A1
    lea     vcount,A0
    move.w  (A0),D0
    addq.w  #7,D0
    move.w  D0,(A0)
    move.w  D0,(A1)
    movem.l (A7)+,D0/A0/A1
old_vblank:
    jmp     0xfff00666L         ; old_vblank
    }
    }

color_on()
    {
    long    usp;
    if (fRainbow)
        return;

    usp=Super(0L);
  asm
    {
    lea     rainbow(GLOBAL),A0
    lea     where_col,A1
    move.l  A0,(A1)
    lea     old_vblank,A0
    move.l  VBLANK,2(A0)
    lea     vblank,A0
    move.l  A0,VBLANK
    lea     old_hblank,A0
    move.l  HBLANK,(A0)
    lea     hblank,A0
    move.l  A0,HBLANK
    andi.w  #0xF0FF,SR
    ori.w   #0x0100,SR
    }
    Super(usp);
    fRainbow=TRUE;
    }

color_off()
    {
    long    usp;
    if (!fRainbow)
        return;

    usp=Super(0L);
  asm
    {
    andi.w  #0xF0FF,SR
    ori.w   #0x0300,SR
    lea     old_hblank,A0
    move.l  (A0),HBLANK
    lea     old_vblank,A0
    move.l  2(A0),VBLANK
    }
    Super(usp);
    fRainbow=FALSE;
    }

scroll(qscr,qFrom,cScan)
register char *qscr;
register char *qFrom;
register int cScan;
    {
  asm
    {
    subq.w  #1,cScan
  LOOPscroll:
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    move.l  (qFrom)+,(qscr)+
    dbf     cScan,LOOPscroll
    }
    }

fade_out()
    {
    long qScreen;
    int count;

    qScreen = Physbase();

    for (count=0; count<199; count++)
        {
        Setcolor(3, 199-count);
        Sound(2,210-count,10,15);
        scroll(qScreen, qScreen+160, 398);
        }
    Sound(0,8,10,15);
    Sound(2,9,10,15);
    }


/********* good a place as any to put a disk directory routine *******/

Directory(mask,handle)
register char *mask;
int handle;
   {
   register struct DTA *dta ;
   register char *pch;
   register int  ok ;
   register long fre_by;
   int cSecs;
   char DOSbuf[20];

   if (!(*mask))
        mask = "*.*";

   ok = Fsfirst (mask,17) ;
   dta = (struct DTA *) Fgetdta();
   while (ok >= 0)
      {
      blitc(' ',DOSbuf,17);

      pch = &dta->fname[0];
      if (!(*pch=='.' || *pch=='/' || *pch=='_'))
          {
          int cb=0;

          if (dta->attrib & 1)
              DOSbuf[1] = '*';

          while ((cb<8) && (*pch) && (*pch!='.'))
              {
              DOSbuf[cb++ +2] = *pch++;
              }
          cb=8;
          while (*++pch)
             {
             DOSbuf[cb++ +2] = *pch;
             }

          cSecs = (int)((dta->size+124L)/125L);

          DOSbuf[14] = '0' + (cSecs/100);
          DOSbuf[15] = '0' + ((cSecs/10)%10);
          DOSbuf[16] = '0' + (cSecs%10);

          if (handle)
               {
               DOSbuf[17] = 155;
               Fwrite (handle,18L,DOSbuf);
               }
          else
               {
               DOSbuf[17]=0;
               print(DOSbuf) ;
               CR;
               }
          }
      ok = Fsnext () ;
      }

   Dfree (&diskblock,0) ;
   fre_by = (diskblock.b_sec_siz * diskblock.b_cl_siz * diskblock.b_free) ;
   cSecs = (int)((fre_by+127L)/128L);
   if (cSecs>999 || cSecs<0)
        cSecs=999;
   DOSbuf[0] = '0' + (cSecs/100);
   DOSbuf[1] = '0' + ((cSecs/10)%10);
   DOSbuf[2] = '0' + (cSecs%10);

   blit(" FREE SECTORS",&DOSbuf[3]);
   if (handle)
       {
       DOSbuf[16] = 155;
       Fwrite (handle,17L,DOSbuf);
       }
   else
       {
       DOSbuf[16]=0;
       print(DOSbuf) ;
       CR;
       CR;
       }
   }


/***************************************************************************/

overlay "main"

main()
    {

    appl_init();

    StoreCols();
    cls();

    scr = (char *) Physbase() ;   /* find screen memory pointer */
    scr_emul = scr - 32768L ;
    mem = scr - 32768L - 65536L;  /* must be on a 64K boundary!!!! */
    stat = mem - 65536L + 32768L ;  /* use relative addressing */

    mode = Getrez();             /* get current screen resolution */

    if (mode==2)
        {
        form_alert(1,"[0][ Works only |  in color  ][ SORRY! ]") ;
        exit(0) ;
        }
    {                             /* load the operating system */
    int hand ;
    char *qch;

    if ((hand=Fopen ("_*.OSB",0))<0)
        {
        form_alert(1,"[0][  _*.OSB file |   missing!   ][ Read docs! ]");
        exit(0) ;
        }
    if (((Fread (hand,7174L,mem+0xE400L-6L))<0) || (*(mem+0xE400L-6L) != -1))
        {
        form_alert(1,"[0][  _*.OSB file |   invalid!   ][ Read docs! ]");
        exit(0) ;
        }
    Fclose (hand) ;

    if ((hand=Fopen ("_*.FNT",0))<0)
        {
        form_alert(1,"[0][  _*.FNT file |   missing!   ][ Read docs! ]");
        exit(0) ;
        }
    if (((Fread (hand,1030L,mem+0xE000L-6L))<0) || (*(mem+0xE000L-6L) != -1))
        {
        form_alert(1,"[0][  _*.OSB file |   invalid!   ][ Read docs! ]");
        exit(0) ;
        }
    Fclose (hand) ;

    if ((hand=Fopen ("_*.FP",0))<0)
        {
        form_alert(1,"[0][  _*.FP file |   missing!   ][ Read docs! ]");
        exit(0) ;
        }
    if (((Fread (hand,2054L,mem+0xD800L-6L))<0) || (*(mem+0xD800L-6L) != -1))
        {
        form_alert(1,"[0][  _*.OSB file |   invalid!   ][ Read docs! ]");
        exit(0) ;
        }
    Fclose (hand) ;

    if ((hand=Fopen ("_*.CTA",0))>=0)
        {
        if (((Fread(hand,8198L,mem+0xA000L-6L))<0) || (*(mem+0xA000L-6) != -1))
            {
            form_alert(1,"[0][   cart B  |   invalid!   ][ Read docs! ]");
            exit(0) ;
            }
        else
           fCartA = TRUE;
       }
    Fclose (hand) ;

    if ((hand=Fopen ("_*.CTB",0))>=0)
        {
        if (((Fread(hand,8198L,mem+0x8000L-6L))<0) || (*(mem+0x8000L-6) != -1))
            {
            form_alert(1,"[0][   cart A  |   invalid!   ][ Read docs! ]");
            exit(0) ;
            }
        else
            fCartB = TRUE;
        }
    Fclose (hand) ;
    }

    InitMachine();        /* set up memory, initialize all arrays, etc */

    fMON = TRUE;       /* force 80 columns */
    Setscreen(-1L,-1L,DISPMODE1);
    show_scr();
    fMON = FALSE;
    Setcolor(0, 0x000);

    print("                         ST LOG presents:");
    CR; CR;
    print("       ST XFORMER v1.11 Atari 800 simulator by Darek Mihocka");
    CR; CR;
   print ("  OS and BASIC (c) 1978,1979 by Atari Corp., all rights reserved.");
    CR;
    print ("  Used with permission.");
    CR; CR;
 print ("  Fastchip by Charles Marslett & alternate OS used with permission:");
    CR;
    print ("    (c) Newell Industries, 602 E. HWY 78, Wylie, TX 75098");
    CR; CR;
    print ("  Designed and programmed by Darek Mihocka.");
    CR;
    print ("  Additional programming by Ignac A. Kolenko Jr. & Barry Green.");
    CR;
    print ("  Report bugs and improvements to DAREKM on GEnie.");
    CR;
    print ("  Testing hardware supplied by Carmine Caccioppoli.");
    CR;
    print ("  Thanks to John Nagy, George and Jim Adamson for their help.");
    CR; CR;
    print ("  Development hardware supplied by:");
    CR;
    print ("    Xanth F/X, 14100 NE 20th #105, Bellevue, WA 98007");
    CR; CR;

    if (!(fCartA|fCartB))
        print ("  NO CARTRIDGE PRESENT  48K RAM");
    else if (!fCartB)
        print ("  8K CARTRIDGE PRESENT  40K RAM");
    else
        print ("  16K CARTRIDGE PRESENT 32K RAM");
    CR; CR;
    print ("  Alt=BREAK  F4=caps  F5=inverse");
    print ("  F7..F9=START SELECT OPTION  F10=RESET");
    CR; CR;
    print ("  Press any key to power up the Atari 800...");

    color_on();
    Sound(0,199,10,15);
    Sound(1,200,10,15);
    Bconin(2);
    color_off();

    Setcolor(0,0);
    fade_out();
    Sound(0,0,0,0);
    Sound(1,0,0,0);
    Sound(2,0,0,0);

    dos();

    Setscreen(-1L,-1L,mode);
    RestoreCols();

    appl_exit();
    }

/* end of _XFORMER.C */

