
/***************************************************************************

   XATARI.C  by Darek Mihocka (CIS: 73657,2714   GEnie: DAREKM)

   This file contains the hardware emulation routines of an Atari 800.

   June 14, 1987     19:50

 ***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include "_xformer.h"

#define QNIL (DL *)0L

typedef struct
    {
    int mode;       /* antic mode */
    int height;     /* height in scan lines */
    int width;      /* width in bytes per line */
    int block_size; /* number of consecutive bytes displayed */
    int scan;       /* starting scan line */
    unsigned start; /* location of first byte being displayed */
    } DL;

#define Rnewfont A1
#define Rhorbyte D2
#define Rscansiz D3

#define SETREAD   ADDQ.W #1,isread(A4)
#define SETWRITE  CLR.W  isread(A4)
#define TESTWRITE TST.W  isread(A4)

/* The following are variables required for the service routines */

unsigned int dl=0;   /* value of start of display list */
int fRedraw=FALSE;   /* flag to redraw the screen during VBI */
    gtia=0,          /* set if in GTIA display mode */
    mdPMG=0,         /* 0= off, 1= byte mode, 2=single line, 3=double line */
    mdWidth,         /* 1 = 32 columns,  2 = 40 columns, 0,3 undefined */
    dma=0,           /* state of video chip access */
     /* bit 1,0 select playfield width, stored in mdWidth */
     /* bit 2 unknown, ignored here */
     /* bit 3, unknown, ignored here */
     /* bit 4, 1= double line PMG, 0= single line PMG */
     /* bit 5, PMG DMA enabled */
     /* bit 6, unknown, ignored here */
     /* bit 7  unknown, ignored here */
    fSTART, fSELECT, fOPTION,  /* console key flags */
    fBREAK,      /* BREAK key flag */
    IKBD,        /* value of keyboard interrupt */
    cBeep=0,     /* counter for speaker access */
    pmg,     /* $D01D contains flags for PMG */
    pmbase,      /* $D407 */
    hposP[4],    /* $D000 horizontal position of players */
    hposM[4],    /* $D004 horizontal position of missles */
    grafP[4],    /* $D00D data for players if DMA is not on */
    grafM=0;     /* $D011 data for missles */

char *qP[4], *qM;    /* pointers to player missle data */

char shadows[16];    /* 8 bit values stored in shadow registers */
char keyboard=255;   /* value of keyboard register */
int DOS_hand[8];     /* atari 2.0 DOS file handles for GEMDOS */
int DOS_mode[8];     /* open modes for each file */
char filename[15];

DL dlBlocks[200];

long *IntrptPtr;
int IRet;

char norm_font[2048] ;
int wide_font[2048] ;    /* conversion from 8 bit pattern to wide 16 bits */
int wide_byte[256] ;

int mul40[200],mul80[200],mul160[200];

extern
  nul() ,    /* should never execute */
  w_ROM(),       /* attempt to write to ROM */
  w_0230(),      /* DL pointer */
  w_022F(),      /* DMA control */
  w_dl(),    /* changing the display list */
  w_GTIA(),      /* GTIA display mode register */
  screen(),      /* attempt to plot to ANTIC mode 0-15 */
  w_710(),       /* shadow color register */
  w_D012(),      /* hardware color register */
  w_02F4(),      /* chset base page */
  s_brk(),       /* break key flag */
  s_con(),       /* console keys */
  s_rnd(),       /* random number location */
  s_vcount(),    /* scan line counter register */
  w_D200(),      /* sound registers */
  w_xP(),    /* horizontal player positions write */
  w_xM(),    /* horizontal missle positions write */
  w_gM(),    /* graphics data for missle */
  w_gP(),    /* graphics data for player */
  w_sP(),    /* size of player */
  w_sM(),    /* size of missle */
  w_P0(),    /* writing to player 0 data array */
  w_P1(),    /* writing to player 1 data array */
  w_P2(),    /* writing to player 2 data array */
  w_P3(),    /* writing to player 3 data array */
  w_M(),     /* writing to missle data array */
  w_PMB(),   /* writing to PMBASE */
  w_PMG()    /* writing to DMACTL */
 ;

/* This array is used to map one of 128 8 bit colours to ST colours */

int rainbow[128] = {
  0x000, 0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777,
  0x200, 0x320, 0x430, 0x541, 0x650, 0x653, 0x764, 0x775,
  0x200, 0x420, 0x530, 0x742, 0x753, 0x754, 0x754, 0x765,
  0x200, 0x400, 0x500, 0x630, 0x643, 0x754, 0x754, 0x765,
  0x400, 0x500, 0x511, 0x600, 0x744, 0x755, 0x755, 0x766,
  0x301, 0x402, 0x513, 0x613, 0x634, 0x645, 0x756, 0x766,
  0x202, 0x303, 0x404, 0x526, 0x636, 0x646, 0x757, 0x767,
  0x203, 0x204, 0x325, 0x426, 0x446, 0x557, 0x667, 0x667,
  0x003, 0x004, 0x115, 0x226, 0x346, 0x457, 0x567, 0x667,
  0x003, 0x004, 0x115, 0x236, 0x346, 0x457, 0x567, 0x667,
  0x012, 0x023, 0x234, 0x345, 0x366, 0x466, 0x577, 0x677,
  0x022, 0x032, 0x043, 0x243, 0x354, 0x465, 0x576, 0x676,
  0x020, 0x030, 0x040, 0x242, 0x353, 0x464, 0x575, 0x676,
  0x220, 0x230, 0x342, 0x352, 0x463, 0x473, 0x674, 0x775,
  0x220, 0x330, 0x332, 0x442, 0x553, 0x663, 0x664, 0x775,
  0x210, 0x320, 0x432, 0x540, 0x543, 0x654, 0x764, 0x775 } ;

int scan_table[16] = {    /* height in pixels of each ANTIC mode */
  0,1,8,10,8,16,8,16,8,4,4,2,1,2,1,1 } ;

/* bytes per scan line */
int rghor_bytes[4][16] =
  {
  {0,0,20,20,20,20,10,10,05,05,10,10,10,20,20,20},
  {0,0,32,32,32,32,16,16,8,8,16,16,16,32,32,32},
  {0,0,40,40,40,40,20,20,10,10,20,20,20,40,40,40},
  {0,0,40,40,40,40,20,20,10,10,20,20,20,40,40,40}
  } ;

int *phor_bytes;

int (*serv_hrdw[256])() = {    /* array of pointers to 256 service routines */

  nul  ,w_022F,w_ROM,  nul  ,w_0230,w_D200, w_710,w_D012, /* 128 write */
  w_GTIA,nul  , nul  , nul  , nul  , nul  ,w_02F4, nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  w_xP , w_xM , w_gP , w_gM , w_sP , w_sM , w_M  , w_PMG, /* player missle */
  w_P0 , w_P1 , w_P2 , w_P3 , nul  , nul  , nul  , w_PMB, /* locations */
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  w_dl , screen,nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,
  nul  , s_con, s_rnd, s_vcount,nul, nul  , nul  , nul  ,  /* 128 read */
  nul  , nul  , nul  , nul  , nul  , nul  , nul  , nul  ,  /* and write */
  nul  /* don't need the rest */
 } ;


/* given a vector, insert the given opcode at the address pointed to */

patch(vec,opc)
register unsigned vec;
register char opc;
    {
    register char *pch;

    pch = mem + (unsigned)(*(mem+vec)) + (unsigned)(*(mem+vec+1))*256;
    *pch = opc;
    }


/* given a handler vector, insert the given opcode at the address pointed to */

patchind(vec,opc)
register unsigned vec;
register char opc;
    {
    register char *pch;

    pch = mem + (unsigned)(*(mem+vec)) + (unsigned)(*(mem+vec+1))*256 + 1 ;
    *pch = opc;
    }


/* initialize the stat[] array and set defaults for power on */

InitMachine()
  {

  register int old, num8, num16 ;

  /* Patch the operating system */
  {
    char *qch;
    unsigned addr;

    /* replace cassette vectors with DOS vectors */
    patchind (0xE440,0x0F);
    patchind (0xE442,0x1F);
    patchind (0xE444,0x2F);
    patchind (0xE446,0x3F);
    patchind (0xE448,0x4F);
    patchind (0xE44A,0x5F);

    /* patch new P: vectors */
    patchind (0xE430,0x7F);
    patchind (0xE432,0x7F);
    patchind (0xE434,0x7F);
    patchind (0xE436,0x6F);
    patchind (0xE438,0x7F);
    patchind (0xE43A,0x7F);


    /* E: put */
   /* patchind (0xE406,0x0C); */

    /* blackboard vector */
    patch (0xE472,0x00);

    /* SIO vectors */
    patch (0xE454,0x60);
    patch (0xE45A,0x60);

    /* replace C: with D: */
    addr = 0xE400;
    while (addr<0xFFF0)
        {
        qch = mem+addr++;
        if (*qch=='C' && *(qch+3)=='E' && *(qch+6)=='S')
            *qch = 'D';
        }

    /* create a RTS vector */
    qch=mem+(unsigned)0xE44CL;
    *qch++ = 76;   /* JMP */
    *qch++ = 0x4F;
    *qch++ = 0xE4;
    *qch   = 96;   /* RTS */

    /* take out JSR disk boot - this is a ROM B specific address!!!!*/
    qch=mem+55296L+6652L;
    *qch++ = 234;    *qch++ = 234;    *qch++ = 234;

    /* check if we have Fastchip loaded, if so, patch in special opcode */
    qch=mem+55296L+507L;  /* $D9FB */
    if (*qch==(char)0xD8)
        {
        *qch = 0x02;   /* patch in our special opcode for normalization */
        qch=mem+55296L+614L;  /* $DA66 */
    /*    *qch = 0x12;   opcode for floating point add, not debugged */
        }
    }

 /* quick routine to create 16 bit wide bytes */
  for (num8=0 ; num8<256; num8++)
      {
      num16 = 0 ;
      old=num8 ;
      if (old&1)
          num16 |= 3 ;
      if (old&2)
         num16 |= 12 ;
      if (old&4)
         num16 |= 48 ;
      if (old&8)
         num16 |= 192 ;
      if (old&16)
         num16 |= 768 ;
      if (old&32)
         num16 |= 3072 ;
      if (old&64)
         num16 |= 12288 ;
      if (old&128)
         num16 |= 0xC000 ;
      wide_byte[num8] = num16 ;
   }

  for (num8=0; num8<200; num8++)
     {
     mul40[num8]=num8*40;
     mul80[num8]=num8*80;
     mul160[num8]=num8*160;
     }

  for (ea=0; ea<8; DOS_hand[ea++]=-1); /* clear out DOS handles */

  for (ea=0; ea; stat[ea++]=0) ;   /* clear out stat array */

  stat[0x022F] = 1 ;  /* DMA control */

  if (fCartA)
      for (ea=40960; ea<49152; ea++)           /* BASIC and OS are ROM */
          stat[ea]=2 ;

  if (fCartB)
      for (ea=32768; ea<40960; ea++)
          stat[ea]=2 ;

  for (ea=49152; ea<53248; ea++)
      stat[ea]=2 ;

  for (ea=53248; ea<55296; ea++)
      stat[ea]=2 ;

  for (ea=55296; ea<65535; ea++)
      stat[ea]=2 ;

 /* For some functions, support the shadow, not the hardware location. */
 /* This is because it's unlikely anyone will do them on the fly. */
 /* Possibly in a DLI routine, but those aren't supported anyway. */

  stat[0x0230] = 4 ;  /* start of display RAM */
  stat[0x0231] = 4 ;  /* not supporting hardware location */

  for (ea=0xD200; ea<=0xD209; ea++)
     stat[ea]=5 ;     /* sound registers */

  for (ea=704; ea<=712; ea++)
     stat[ea]=6;      /* shadow color registers */

  for (ea=53270; ea<=53274; ea++)
     stat[ea]=7 ;     /* hardware color registers */

  stat[623] = 8 ;     /* GTIA mode, not supporing hardware location */
  stat[756] = 14 ;    /* chset base page, not supporting hardware loc. */

  stat[53248] = 32;   /* player horizontal */
  stat[53252] = 33;   /* missle horizontal */

  stat[53261] = 34;   /* player data */
  stat[53265] = 35;   /* missle data */

  stat[53277] = 39;   /* enables DMA PMG */

  stat[54279] = 47;   /* positions PMG data pages */

 /* These are memory locations that return special values on a read. */
 /* They also cause writes to be trapped and ignored (usually). */

  stat[53279] = 129 ; /* console */
  stat[53770] = 130 ; /* random */
  stat[54283] = 131 ; /* vcount */

  dlBlocks[0].mode=-1;

  } /* END OF INIT */

IntOn()
    {
  asm
    {                           ; save A4 where we can find it later */
    lea     RegA4(PC),A0
    move.l  A4,(A0)
    }

    JoyOn();       /* initialize joystick vector */
    Supexec(VBIon);  /* init VBI routine */
    Install_Key();
    fSTART = fSELECT = fOPTION = FALSE;
    }

IntOff()
    {
    JoyOff();                 /* disconnect joystick handler */
    Remove_Key();              /* disconnect keyboard handler patch */
    Supexec(VBIoff);
    }


foo() {    /* This function is never called.
              It's purpose is to allow the 68000 routines to pop into
              C once in a while.
              Therefore they must be inside a C function.   */


 /* emul_serv is called whenever a read/write access is attempted
    to non-RAM memory locations, such as ROM or hardware registers.

    when status bytes are > $80  (read and write)
    REGEA points to memory to read with D0
    this routine ends with DISPATCH when writing
    and RTS when reading

    when status bytes are <>=0 (write-only)
    REGEA points to memory to write with D0
    byte to poke is in high byte of DBUS
    this routine ends with DISPATCH
  */
 asm {

  emul_serv:
    ANDI.W  #0x00FF,IR              ; clear out bits 8..15
    ADD.W   IR,IR
    ADD.W   IR,IR                   ; calculate offset
    LEA     serv_hrdw(GLOBAL),REGMEA ; get start of vector table
    MOVE.L  0(REGMEA,IR.W),REGMEA   ; calculate correct vector
    JMP     (REGMEA)                ; jump through it


 /* The following routine is most of the system vertical blank re-written */
 /* in 68000 so that it can be executed much faster. */

 sysvbl:
    SAVEREGS
    lea     emul(PC),A0
    tst.b   fTrace(GLOBAL)
    beq.s   nt
    lea     exit_emul(PC),A0
  nt:
    lea     pemul(PC),A1
    move.l  A0,(A1)         ; change dispatch vector to normal

    move.l  mem(GLOBAL),REGMEA          ; get pointer to byte 0

  ; the incrementing of the clocks is not done here. see VBI

  sysvb1:
    move.b  #0xFE,REGA
    clr.b   REGX
    move.b  77(REGMEA),REGY
    bpl.s   vbatra
    move.b  REGA,77(REGMEA)
    move.b  19(REGMEA),REGX
    move.b  #0xF6,REGA
  vbatra:
    move.b  REGA,78(REGMEA)         ; drkmsk
    move.b  REGX,79(REGMEA)         ; colrsh

    lea     rainbow(GLOBAL),A0      ; pointer to rainbow[128]
    lea     rgPalette(GLOBAL),A1
    lea     32(A1),A1               ; pointer to ST colors
    lea     0x8240,A2               ; pointer to ST colors regs
    lea     shadows(GLOBAL),A3      ; pointer to 8 bit colors
    move.w  #15,REGY
  sysvb2:
    clr.l   D0
    move.b  (A3)+,D0
    eor.b   REGX,D0
    and.b   REGA,D0
    andi.w  #~1,D0
    move.w  0(A0,D0.L),D0
    move.w  D0,(A1)+
    move.w  D0,(A2)+
    dbf     REGY,sysvb2
    }
    {
    long scan_code ;
    int scan, shift ;
    int fSHIFT,fCTRL;
    static int fBreakEnable=TRUE;

    if (Kbshift(-1)&8)         /* ALT key is used as the BREAK key */
        {
        if (fBreakEnable)
            {
            *(mem+17)=0;
            fBreakEnable=FALSE;
            }
        }
    else
        {
        fBreakEnable=TRUE;
        *(mem+17)=1;
        }

    if (Bconstat(2) != 0)
        {
        *(mem+77)=0;     /* clear attract mode */
        keyboard = scan_code = Bconin(2) ;    /* get ASCII */
        shift=Kbshift(-1);
        fSHIFT=(shift&3)?64:0;
        fCTRL =(shift&4)?128:0;

        switch(scan_code>>16)
            {
        case  1:
            *(mem+764)=28+fSHIFT+fCTRL ; /* ESCape */
            break ;

        case  3:
            *(mem+764) =30+(fSHIFT?87:0)+fCTRL ;  /* 2 */
            break ;

        case  4:
            *(mem+764) =26+fSHIFT+fCTRL ;       /* 3 */
            break ;

        case 14:
            *(mem+764)=52+fSHIFT+fCTRL ;       /* BS */
            break ;

        case 83:
            *(mem+764)=180-fSHIFT;       /* delete BS */
            break ;

        case 15:
            *(mem+764) =44+fSHIFT+fCTRL ;       /* TAB */
            break ;

        case 114:
        case 28:
            *(mem+764) =12+fSHIFT+fCTRL ;       /* CR */
            break ;

        case 72:
            *(mem+764) = 142 ;       /* CTRL up arrow */
            break ;

        case 80:
            *(mem+764) = 143 ;       /* CTRL dn arrow */
            break ;

        case 75:
            *(mem+764) = 134 ;       /* CTRL lt arrow */
           break ;

        case 77:
            *(mem+764) = 135 ;       /* CTRL rt arrow */
            break ;

        case 119:
        case 71:
            *(mem+764) = 118+(fCTRL?64:0);     /* shift CLR */
            break ;

        case 82:
            *(mem+764) = 55+128-fSHIFT;    /* CTRL insert */
            break ;

        case 88:
        case 63:
            *(mem+764) = 39 ;        /* F5 = /|\ */
            break ;

        case 62:
            *(mem+764)=fCTRL+60; /* F4 = caps */
            break ;

        case 87:
            *(mem+764) = 60+64 ;     /* F4 = shift caps */
            break ;

        case 68:
  asm
    {                    /* F10 = RESET */
    LOADREGS
    clr.w    dma(GLOBAL)     ; shut screen off
    move.b  #0x224,REGEA
    move.l  REGEA,REGMEA
    clr.w   (REGMEA)         ; clear VVBLKD
    MOVE.W   #0xE474,REGPC   ; stuff warmstart vector
    MOVE.L   REGPC,REGMPC    ; into PC
    DISPATCH
    }
            break ;

        case 59:
  asm
    {                    /* F1 = force break */
    LOADREGS
    bra     op00
    }
        case 60:        /* F2 = redraw */
            clear_disp();
            do_display();
            break;

        default:
            if (keyboard)                    /* if regular character */
                for (scan=0 ; scan<192 ; scan ++)  /* to internal */
                    if (*(mem+0xFEFE+scan) == keyboard)
                          *(mem+764)=scan;

              } /* switch */

        *(mem + 0x0000D209L) = mem[764];
        if (mem[764]==255)
               *(mem+0x0D20F) = 255;
        else
               *(mem+0x0D20F) = 251;
        *(mem+0x0D21F) = *(mem+0x0D20F) ;   /* this pleases AtariWriter */
        } /* while */

    if (fRedraw)
        {
        clear_disp();
        do_display();
        }
    }
 asm
    {
    LOADREGS

  ; Now we want to call the deferred vertical blank routine at VVBLKD ($224).
  ; It ends in an RTI so we not only push the PC to the stack, but also the
  ; status register. Don't bother encoding it to 6502 format.

    btst    #5,REGST                ; get out if interrupts disabled
    bne.s   noVVBLKD

    move.w  #0x225,REGEA            ; just for grins, make sure it is non-0
    move.l  REGEA,REGMEA
    tst.b   (REGMEA)
    beq.s   noVVBLKD                ; it is, must be in a warmstart

  ; push the PC and status register, then push A,X and Y to the stack
    subq.B  #6,REGSP
    move.W  REGSP,REGEA
    move.L  REGEA,REGMEA
    move.B  REGST,6(REGMEA)         ; push status register
    move.W  REGMPC,REGPC
    move.B  REGPC,4(REGMEA)         ; push PClo
    move.W  REGPC,-(SP)
    move.B  (SP)+,5(REGMEA)         ; push PChi
    move.B  REGA,3(REGMEA)          ; PHA
    move.B  REGX,2(REGMEA)          ; PHX
    move.B  REGY,1(REGMEA)          ; PHY

  ; do a JMP ($224)
    move.w  #0x224,REGEA
    move.L  REGEA,REGMEA
    move.B  1(REGMEA),-(SP)
    move.W  (SP)+,REGPC
    move.B  (REGMEA),REGPC
    move.L  REGPC,REGMPC

  noVVBLKD:
    DISPATCH


  nul:       /* should never execute! but just in case... */
    SWAP    DBUS
  do_write:
    MOVE.L  REGEA,REGMEA
    MOVE.B  DBUS,(REGMEA)    /* do the actual write to memory */
    DISPATCH

  w_dl:
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    move.b  (REGMEA),x(GLOBAL)  ; get old value
    MOVE.B  DBUS,(REGMEA)       ; do the actual write to memory */
    move.b  DBUS,a(GLOBAL)
    SAVEREGS
    }
    if (dma && a!=x)
        fRedraw=TRUE;
   asm
    {
    LOADREGS
    DISPATCH

  w_0230:
    move.w  dl(GLOBAL),ea(GLOBAL)   ; save old display list pointer
    move.l  REGEA,REGMEA
    btst    #0,REGEA                ; check address to poke to
    BNE     w_0231
    SWAP    DBUS
    MOVE.B  DBUS,dl+1(GLOBAL)       ; if 230, then low byte of dl
    move.b  (REGMEA),REGEA
    cmp.b   REGEA,DBUS              ; are we changing value?
    beq.s   w_0230_exit
    move.b  DBUS,(REGMEA)
    BRA     w_0230_2
  w_0231:
    SWAP    DBUS        ; if 231, then high byte of dl
    MOVE.B  DBUS,dl(GLOBAL)
    move.b  (REGMEA),REGEA
    cmp.b   REGEA,DBUS              ; are we changing value?
    beq.s   w_0230_exit
    move.b  DBUS,(REGMEA)           ; write new value
  w_0230_2:
    SAVEREGS
    }
    if (dma)
        {
        fRedraw=TRUE;     /* screen must be redrawn, so release display list */
        while (*(mem+ea)!=65 && (ea!=0xD000))
            {
            if (stat[ea]&64) stat[ea]=0;
            ea++;
            }
        }
  asm {
    LOADREGS
  w_0230_exit:
    DISPATCH

  w_022F:
    SWAP    DBUS
    move.l  REGEA,REGMEA
    move.b  DBUS,(REGMEA)
    MOVE.W  DBUS,-(SP)                  ; save value
    andi.w  #3,DBUS                     ; get playfield width
    move.w  DBUS,mdWidth(GLOBAL)        ; store it
    lsl.w   #5,DBUS
    lea     rghor_bytes(GLOBAL),REGMEA
    adda.w  DBUS,REGMEA
    move.l  REGMEA,phor_bytes(GLOBAL)   ; phor_bytes = rghorbytes[mdWidth]

    MOVE.W  (SP)+,DBUS
    andi.w  #0x20,DBUS
    BNE     DMA_on
  DMA_off:                              ; if DMA is off, blank screen
    SAVEREGS
       }
       plot_0 (0,200) ;
       ea=dl;
       while (*(mem+ea)!=65 && (ea!=0xD000))
           {
           if (stat[ea]&64) stat[ea]=0;
           ea++;
           }
       clear_disp();
       dma=0;
   asm {
    LOADREGS
    BRA     w_022Fexit
  DMA_on:
    SAVEREGS
       }
       if (dma)
           {
           if (mdWidth!=2)
               plot_0 (0,200) ;
           clear_disp();
           }
       dma=1;
       do_display() ;

   asm {
    LOADREGS
  w_022Fexit:
    DISPATCH

  w_710:                   /* color register */
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    MOVE.B  DBUS,(REGMEA)    /* do the actual write to memory */
    MOVE.B  DBUS,a(GLOBAL)
    MOVE.W  REGEA,ea(GLOBAL)
    SAVEREGS
    }
        do_colors (ea,a) ;
 asm
    {
    LOADREGS
    DISPATCH

  w_D012:                   /* color register */
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    MOVE.B  DBUS,(REGMEA)    /* do the actual write to memory */
    MOVE.B  DBUS,a(GLOBAL)
    MOVE.W  REGEA,ea(GLOBAL)
    SAVEREGS
    }
        do_color (ea,a) ;
 asm
    {
    LOADREGS
    DISPATCH

  w_GTIA:                   /* GTIA register */
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    MOVE.B  DBUS,(REGMEA)      /* do the actual write to memory */
    ANDI.w  #0xC0,DBUS     /* bits 6 and 7 control GTIA mode */
    move.w  DBUS,gtia(GLOBAL)  /* store in gtia */
    SAVEREGS
    }
       {
        int i;
        for (i=704; i<=712; i++)
            do_colors(i,mem[i]);
        if (dma)
            fRedraw=TRUE;
       }
   asm {
        LOADREGS
        DISPATCH

  w_D200:                  /* sound registers */
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    MOVE.B  DBUS,(REGMEA)    /* do the actual write to memory */
    MOVE.B  DBUS,a(GLOBAL)
    MOVE.W  REGEA,ea(GLOBAL)
    SAVEREGS
    }
        {
        register char tmp;

        switch (ea)
            {
        default:
            break;
        case 0xD200:
        case 0xD202:
        case 0xD204:
        case 0xD206:
            tmp = *(mem+ea+1);
            Sound ((ea-0xD200)>>1,a,tmp>>4,tmp&15);
            break;

        case 0xD201:
        case 0xD203:
        case 0xD205:
        case 0xD207:
            tmp = *(mem+ea-1);
            Sound ((ea-0xD200)>>1,tmp,a>>4,a&15);
            break;
            }
        }
  asm
    {
    LOADREGS
    DISPATCH

  w_02F4:                  /* character set */
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    move.b  (REGMEA),REGEA
    cmp.b   DBUS,REGEA
    beq.s   w_02F4_exit
    MOVE.B  DBUS,(REGMEA)
    SAVEREGS
    }
        do_chset() ;
 asm
    {
    LOADREGS
  w_02F4_exit:
    DISPATCH

  screen:                      ; handler for screen plots
    swap    DBUS               ; get byte we want to plot
    MOVE.L  REGEA,REGMEA

    move.b  (REGMEA),REGEA     ; get old value
    cmp.b   REGEA,DBUS         ; are we writing what's already there?
    beq.s   skipscr            ; Sure are, skip the plot, save time

    MOVE.B  DBUS,(REGMEA)      ; do the actual write to memory
    tst.w   dma(GLOBAL)
    beq.s   skipscr            ; if dma is off, get out

    SAVEREGS                   ; save 6502 enviornment
    move.w  REGMEA,-(SP)       ; push memory location
    }
    do_byte();                 /* address already on stack */
  asm
    {
    addq.l  #2,SP
    LOADREGS                   ; restore 6502 enviornment
  skipscr:
    DISPATCH

  s_brk:
    TESTWRITE
    beq     nul
    SAVEREGS
       }
        {
        *(mem+17)=(char)(1-fBREAK&1);
        }
  asm {
    LOADREGS
    RTS

  s_con:
    TESTWRITE
    beq.s   w_con
    SAVEREGS
       }
        {
        *(mem+53279)=(fSTART?0:1) | (fSELECT?0:2) | (fOPTION?0:4);
        }
  asm {
    LOADREGS
    RTS

  w_con:
    move.w   cBeep(GLOBAL),DBUS    ; only click every 128th access to
    add.w    #1,DBUS               ; compensate for speed slowdown
    andi.w   #127,DBUS
    move.w   DBUS,cBeep(GLOBAL)
    tst.w    DBUS
    bne.s    w_con_exit
    swap     DBUS
    cmpi.w   #8,DBUS               ; also get out if clearing console keys
    beq.s    w_con_exit
    SAVEREGS
    }
        Sound (2,20,10,15);      /* click a little */
        Sound (2,0,0,0);
  asm
    {
    LOADREGS
  w_con_exit:
    DISPATCH

  s_rnd:
    TESTWRITE
    beq     nul
    SAVEREGS
    }
        *(mem+53770L)=(char)((Random()>>3)^x^(a&y));
  asm
    {
    LOADREGS
    RTS

  s_vcount:
    TESTWRITE
    beq      nul
    move.b   0x8207,-(SP)
    move.w   (SP)+,D0
    move.b   0x8209,D0
    divu     #20,D0
    andi.w   #254,D0
    MOVE.L  REGEA,REGMEA
    MOVE.B  DBUS,(REGMEA)
    RTS

  w_ROM:
        DISPATCH


 ; handler for P: putchar

  op6F:

    SAVEREGS
    MOVE.B   REGA,a(GLOBAL)     ; character to print */
  }
    {
    int timeout = 1000;

    do
      {
      if (Cprnos())
        {                       /* if printer is ready */
        timeout=0;
        if (a!=155)
            Cprnout (a) ;       /* then check for CR and print */
        else
            {
            Cprnout(13) ;       /* if CR then send CRLF */
            Cprnout(10) ;
            }
        y = 1 ;                 /* set status = good */
        }
      else y = 0x8A ;           /* else status = timeout error */
      } while (timeout--);
    }
 asm {
    LOADREGS
    MOVE.b  y(GLOBAL),REGY     ; return status
    FLAGS
    BRA     op60

 ; handler for all other P: calls
op7F:
    MOVE.w  #1,REGY            ; return good status
    FLAGS
    BRA     op60


  op0F: /* handler for open D: call */
        SAVEREGS
        MOVE.B  REGX,x(GLOBAL)
      }
     do_open();
  asm {
        LOADREGS
        MOVE.B  y(GLOBAL),REGY     /* return status */
        FLAGS
        BRA     op60

  op2F: /* handler for get D: call */
        SAVEREGS
        MOVE.B  REGX,x(GLOBAL)
      }
        do_get();
  asm {
        LOADREGS
        MOVE.B  a(GLOBAL),REGA
        MOVE.B  y(GLOBAL),REGY     /* return status */
        FLAGS
        BRA     op60

  op3F: /* handler for put D: call */
        SAVEREGS
        MOVE.B  REGX,x(GLOBAL)
        MOVE.B  REGA,a(GLOBAL)
      }
        do_put();
    asm {
        LOADREGS
        MOVE.B  y(GLOBAL),REGY     /* return status */
        FLAGS
        BRA     op60

op1F:
op4F:
op5F:   /* handler for close D: calls */
        SAVEREGS
        MOVE.B  REGX,x(GLOBAL)
      }
      do_close();
  asm {
        LOADREGS
        MOVE.B  y(GLOBAL),REGY     /* return status */
        FLAGS
        BRA     op60

  op0C: /* handler for E: */
/*
        SAVEREGS
        MOVE.B  REGA,a(GLOBAL)
        MOVE.B  REGX,x(GLOBAL)
        MOVE.B  REGY,y(GLOBAL)
        FLAGS
      }
      do_Eput();
  asm {
        LOADREGS
        MOVE.B  a(GLOBAL),REGA
        MOVE.B  x(GLOBAL),REGX
        MOVE.B  y(GLOBAL),REGY
        FLAGS
*/
        BRA     op60


 /* Player missle graphics routines. ouch */

  w_xP:   /* horizontal player positions write */
  w_xM:   /* horizontal missle positions write */
  w_gM:   /* graphics data for missle */
  w_sP:   /* size of player */
  w_sM:   /* size of missle */
  w_P0:   /* writing to player 0 data array */
  w_P1:   /* writing to player 1 data array */
  w_P2:   /* writing to player 2 data array */
  w_P3:   /* writing to player 3 data array */
  w_M:    /* writing to missle data array */
  w_PMG:  /* writing to DMACTL */
    DISPATCH

  /**** opcode $02 is used to simulate the Fastchip normalize ****/

  /* FNORM - $D9FB normalize FR0 and terminate with an RTS */

  op02:
    move.w  #0,REGEA
    move.l  REGEA,REGMEA    ; REGMEA = mem

    andi.b  #~BITD,REGST
    lea     vec_6502(GLOBAL),REGOPS   ; CLD

    move.w  #5,REGY         ; LDY #5

  fnml:
    move.b  0xD5(REGMEA),REGA       ; LDA FR0+1
    beq.s   fnm2            ; BEQ FNM2

    andi.b  #~BITX,REGST    ; CLC
    bra     op60            ; RTS

  fnm2:
    clr.b   0xDA(REGMEA)    ; STA FR0+FPREC (A=0)
    subi.b  #1,0xD4(REGMEA) ; DEC FR0

  fnm3:
    move.w  #0x00FB,REGX    ; LDX #1-FPREC

  fnm4:
    move.b  0xDB(REGMEA,REGX.w),0xDA(REGMEA,REGX.w) ; LDA FRO+FPREC+1,X
                                ; STA FRO+FPREC,X

    add.b   #1,REGX         ; INX
    bne.s   fnm4            ; BNE FNM4

    sub.b   #1,REGY         ; DEY
    bne.s   fnml            ; BNE FNML

    move.w  #0xDA43,REGPC
    move.l  REGPC,REGMPC
    DISPATCH                ; BEQ RZERO ($DA43) unconditinal

  /**** opcode $12 is used to simulate the Fastchip add, a bit buggy  ****/

  /* FAAD - $DA66 - add FR0 and FR1 and exit to FNME ($D9E7) */

  op12:
    clr.w   REGA
    clr.w   REGX
    clr.w   REGY
    move.w  #0x100,REGEA
    move.l  REGEA,REGMEA    ; REGMEA = mem[100]

    move.w  #5,REGX         ; LDX #5
    move.b  0xFFE0(REGMEA),DBUS   ; LDA FR1
    andi.w  #0x7F,DBUS

    move.b  0xFFD4(REGMEA),REGA   ; LDA FR0
    andi.w  #0x7F,REGA

    sub.w   DBUS,REGA
    bpl     frobig

    addi.w  #5,REGA
    move.b  REGA,REGY

    ori.w   #BITX,REGST
    move.b  REGST,CCR           ; SEC
    ori.w   #BITD,REGST         ; SED

    move.b  0xFFE0(REGMEA),DBUS
    move.b  0xFFD4(REGMEA),REGA
    eor.w   DBUS,REGA
    bmi     fdif0

    andi.w  #~BITX,REGST
    move.b  REGST,CCR           ; CLC

    subi.w  #1,REGY             ; DEY
    bmi     fadd1

  fadd0:
    move.b  0xD5(REGMEA,REGY.w),REGA ; LDA FR0+1,Y
    move.b  0xE0(REGMEA,REGX.w),DBUS ; ADC FR1,X
    abcd    DBUS,REGA
    move.w  SR,REGST
    move.b  REGA,0xD4(REGMEA,REGX.w) ; STA FR0,X

    sub.b   #1,REGX             ; DEX
    sub.b   #1,REGY             ; DEY
    bpl.s   fadd0

  fadd1:
    move.b  0xE0(REGMEA,REGX.w),REGA ; LDA FR1,X
    clr.w   DBUS
    abcd    DBUS,REGA
    move.w  SR,REGST
    move.b  REGA,0xD4(REGMEA,REGX.w) ; STA FR0,X

    sub.b   #1,REGX             ; DEX
    bne.s   fadd1               ; BNE FADD1

    move.b  0xFFE0(REGMEA),0xFFD4(REGMEA) ; LDA FR1  STA FRO

  fhtst:
    move.b  REGST,CCR
    bcc     faddx            ; BCC FADDX

  fadd2:
    move.b  0xFFD8(REGMEA),0xFFD9(REGMEA)
    move.b  0xFFD7(REGMEA),0xFFD8(REGMEA)
    move.b  0xFFD6(REGMEA),0xFFD7(REGMEA)
    move.b  0xFFD5(REGMEA),0xFFD6(REGMEA)

    move.b  #1,0xFFD5(REGMEA)
    move.b  0xFFD4(REGMEA),REGA

    move.b  REGA,DBUS
    add.b   #1,DBUS
    move.b  DBUS,0xFFD4(REGMEA)
    eor.b   DBUS,REGA
    bmi     faddx            ; C is set
    andi.w  #~BITX,REGST     ; CLC

  faddx:
    andi.w  #~BITD,REGST     ; CLD
    bra     op60

  frobig:
    not.b   REGA        ; EOR #$FF
    addi.b  #5,REGA
    bcc     fnml

    ori.w   #BITX,REGST
    move.b  REGST,CCR            ; SEC

    move.b  REGA,REGY   ; TAY
    ori.w   #BITD,REGST         ; SED
    move.b  0xFFE0(REGMEA),DBUS
    move.b  0xFFD4(REGMEA),REGA
    eor.b   DBUS,REGA
    bmi     fdif5

    andi.w  #~BITX,REGST
    move.b  REGST,CCR            ; CLC

  fadd5:
    move.b  0xD4(REGMEA,REGX.w),REGA    ; LDA FRO,X
    move.b  0xE1(REGMEA,REGY.w),DBUS    ; ADC FR1+1,Y
    abcd    DBUS,REGA
    move.w  SR,REGST
    move.b  REGA,0xD4(REGMEA,REGX.w)    ; STA FR0,X
    subi.b  #1,REGX         ; DEX
    subi.b  #1,REGY         ; DEY
    bpl.s   fadd5

  fadd6:
    subi.b  #1,REGX         ; DEX
    bmi     fhtst
    move.b  0xD5(REGMEA,REGX.w),REGA    ; LDA FRO+1,X
    clr.w   DBUS
    abcd    DBUS,REGA
    move.w  SR,REGST
    move.b  REGA,0xD5(REGMEA,REGX.w)    ; STA FR0+1,X
    move.b  REGST,SR
    bcs     fadd6
    bra     faddx

  fdif0:
    move.w  #0xDAB5,REGPC
    move.l  REGPC,REGMPC
    DISPATCH

  fdif5:
    move.w  #0xD9BA,REGPC
    move.l  REGPC,REGMPC
    DISPATCH


  op22:
  op32:
  op42:

  /* unused opcodes which can be put to good use as patches */

  op80:
  op52:
  op62:
  op72:
  op82:
  op92:
  opB2:
  opC2:
  opD2:
  opE2:
  opF2:
  op03:
  op13:
  op23:
  op33:
  op43:
  op53:
  op63:
  op73:
  op83:
  op93:
  opA3:
  opB3:
  opC3:
  opD3:
  opE3:
  opF3:
  op04:
  op14:
  op34:
  op44:
  op54:
  op64:
  op74:
  opD4:
  opF4:
  op07:
  op17:
  op27:
  op37:
  op47:
  op57:
  op67:
  op77:
  op87:
  op97:
  opA7:
  opB7:
  opC7:
  opD7:
  opE7:
  opF7:
  op89:
  op1A:
  op3A:
  op5A:
  op7A:
  opDA:
  opEA:
  opFA:
  op0B:
  op1B:
  op2B:
  op3B:
  op4B:
  op5B:
  op6B:
  op7B:
  op8B:
  op9B:
  opAB:
  opBB:
  opCB:
  opDB:
  opEB:
  opFB:
  op1C:
  op3C:
  op5C:
  op7C:
  op9C:
  opDC:
  opFC:
  op9E:
  op8F:
  op9F:
  opAF:
  opBF:
  opCF:
  opDF:
  opEF:
  opFF: DISPATCH

  }
 }


plot_0 (scan, height)          /* clear scan lines */
register int scan, height ; {  /* height black scan lines */

  register long *loc;
  register int clong;

  loc = (long *)scr_emul + (long)((scan<<5)+(scan<<3));
  clong=(height<<3)+height+height;   /* height * 10 */

  for (;clong--; *loc++ = *loc++ = *loc++ = *loc++ = 0L) ;
 }


plot_1 (scan, height)          /* clear bit planes 2 & 3  */
register int scan, height ;    /* height black scan lines */
  {
  register long *loc;
  register int clong;

  loc = (long *)scr_emul + (long)mul40[scan] ;
  clong= (height<<4)+(height<<2);     /* multiply * 20 bit planes per line */

  for (;clong--; loc++, *loc++ = 0L) ;
 }

                        /* plot a 40 column character using ROM B font */
plot_2 (data,scry, scrx,count)
register char *data;
register int scry, scrx, count ;
   {
  register int text;
  register char *newscr;
  char *newfont ;        /* unused - use A1 */

  if (gtia) return;

  asm {
; scry=mul160[scry];       /* since we won't change y co-ordinate */
       LEA     mul160(GLOBAL),A0
       ADD.W   scry,scry
       ADDA.W  scry,A0
       MOVE.W  (A0),scry

; while (count--)
  loop_2:
;      text = *data++ *8;
       MOVE.W  #0,text
       MOVE.B  (data)+,text
       ADD.W   text,text
       ADD.W   text,text
       ADD.W   text,text
;      newfont = &norm_font[text^0x400] ;
       EORI.W  #0x400,text
       LEA     norm_font(GLOBAL),Rnewfont
       ADDA.W  text,Rnewfont
;      newscr = scr_emul + scry + (scrx&1) + ((scrx&~1)<<2) ;
       MOVE.W  scrx,D0
       ANDI.W  #1,D0
       MOVE.W  scrx,D1
       ANDI.W  #~1,D1
       ADD.W   D1,D1
       ADD.W   D1,D1
       ADD.W   D1,D0
       ADD.W   scry,D0
       MOVE.L  scr_emul(GLOBAL),newscr
       ADDA.W  D0,newscr

       MOVE.B  #~0,D0
       MOVE.B  (Rnewfont)+,(newscr)
       MOVE.B  D0,2(newscr)
       MOVE.B  (Rnewfont)+,160(newscr)
       MOVE.B  D0,162(newscr)
       MOVE.B  (Rnewfont)+,320(newscr)
       MOVE.B  D0,322(newscr)
       MOVE.B  (Rnewfont)+,480(newscr)
       MOVE.B  D0,482(newscr)
       MOVE.B  (Rnewfont)+,640(newscr)
       MOVE.B  D0,642(newscr)
       MOVE.B  (Rnewfont)+,800(newscr)
       MOVE.B  D0,802(newscr)
       MOVE.B  (Rnewfont)+,960(newscr)
       MOVE.B  D0,962(newscr)
       MOVE.B  (Rnewfont)+,1120(newscr)
       MOVE.B  D0,1122(newscr)
       ADDQ.W  #1,scrx        ; scrx++ ;
       SUB.W   #1,count
       BNE     loop_2
       }
 }


                        /* plot a 40 column character in 10 pixels */

plot_3 (data,scry, scrx,count)
char *data;
register int scry, scrx, count ;
   {
  register int text;
  register char *newscr;
  register char *newfont ;

  if (gtia) return;

  while (count--)
    {
      text = *data++;
      text &= 0xFF ;     /* character was signed, so unsign it */

  asm {
   ADD.W   text,text
   ADD.W   text,text
   ADD.W   text,text   /* text *= 8 */
   }

        newscr=scr_emul+mul160[scry]+(scrx&1)+((scrx&~1)<<2) ;
        newfont = &norm_font[text^0x400] ;

        newscr[1282]=newscr[1442]=
        newscr[002]= newscr[162]= newscr[322]= newscr[482]=
        newscr[642]= newscr[802]= newscr[962]= newscr[1122]=~0;
        newscr[000]=*newfont++;
        newscr[160]=*newfont++;
        newscr[320]=*newfont++;
        newscr[480]=*newfont++;
        newscr[640]=*newfont++;
        newscr[800]=*newfont++;
        newscr[960]=*newfont++;
        newscr[1120]=*newfont;
        newscr[1280]=newscr[1440]=~0;
        scrx++ ;
   }
 }

  /* 4 color text modes */

plot_4(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
    {
  register int text;
  register char *newscr;
  char *newfont ;        /* unused - use A1 */

    if (gtia) return;
    while (count--)
        {
        text = *data++;
        text &= 0x7F ;     /* ignore hi bit */

    asm {
        ADD.W   text,text
        ADD.W   text,text
        ADD.W   text,text   /* text *= 8 */
        }

    newscr=scr_emul+mul160[scry]+(scrx&1)+((scrx&~1)<<2) ;
    newfont = &norm_font[text] ;

  asm
    {
    move.l   newfont(LOCAL),Rnewfont
    move.w   #7,D2                  ; 8 scan lines
  loop_4:
    move.b   (Rnewfont)+,text
    move.b   text,D1
    andi.w   #0x55,D1
    move.w   D1,D0
    add.w    D0,D0
    or.w     D1,D0
    move.b   D0,(newscr)

    andi.w   #0xAA,text
    move.w   text,D0
    lsr.w    #1,D0
    or.w     text,D0
    move.b   D0,2(newscr)

    lea      160(newscr),newscr
    dbf      D2,loop_4
    }
        scrx++ ;
        }
    }

plot_5(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
    {
  register int text;
  register char *newscr;
  char *newfont ;        /* unused - use A1 */

    if (gtia) return;
    while (count--)
        {
        text = *data++;
        text &= 0x7F ;     /* ignore hi bit */

    asm {
        ADD.W   text,text
        ADD.W   text,text
        ADD.W   text,text   /* text *= 8 */
        }

        newscr=scr_emul+mul160[scry]+(scrx&1)+((scrx&~1)<<2) ;
        newfont = &norm_font[text] ;

  asm
    {
    move.l   newfont(LOCAL),Rnewfont
    move.w   #7,D2                  ; 8 unique scan lines
  loop_5:
    move.b   (Rnewfont)+,text
    move.b   text,D1
    andi.w   #0x55,D1
    move.w   D1,D0
    add.w    D0,D0
    or.w     D1,D0
    move.b   D0,(newscr)
    move.b   D0,160(newscr)

    andi.w   #0xAA,text
    move.w   text,D0
    lsr.w    #1,D0
    or.w     text,D0
    move.b   D0,2(newscr)           ; do 2 scan lines at once
    move.b   D0,162(newscr)

    lea      320(newscr),newscr     ; skip 2 lines
    dbf      D2,loop_5
    }
        scrx++ ;
        }
    }


  /* plot a 20 column character */

plot_6(data, scry, scrx, count)
char *data;
register int scry, scrx, count ;
   {
  register int text;
  register int *newscr ;
  register int *newfont ;

  if (gtia) return;

  while (count--) {
  asm
        {
;  text = *data++ + 64; /* add 64 to select colours 1-4, not 0-3 */
        clr.w   text
        move.l  data(LOCAL),A0
        move.b  (A0)+,text
        move.l  A0,data(LOCAL)
        add.w   #64,text
        ADD.W   text,text
        ADD.W   text,text
        ADD.W   text,text   /* text *= 8 */
        }

  newscr = (int *) scr_emul + mul80[scry] + (scrx<<2) ;
  newfont = &wide_font[(text&0x01F8)];  /* ignore color bits */

  if (text&0x200)
  asm {
    move.l  newfont,A0
    move.w  (A0)+,(newscr)
    move.w  (A0)+,160(newscr)
    move.w  (A0)+,320(newscr)
    move.w  (A0)+,480(newscr)
    move.w  (A0)+,640(newscr)
    move.w  (A0)+,800(newscr)
    move.w  (A0)+,960(newscr)
    move.w  (A0),1120(newscr)
    }
  else
  asm {
    clr.w   (newscr)
    clr.w   160(newscr)
    clr.w   320(newscr)
    clr.w   480(newscr)
    clr.w   640(newscr)
    clr.w   800(newscr)
    clr.w   960(newscr)
    clr.w   1120(newscr)
    }

  if (text&0x400)
   asm {
    move.l  newfont,A0
    move.w  (A0)+,2(newscr)
    move.w  (A0)+,162(newscr)
    move.w  (A0)+,322(newscr)
    move.w  (A0)+,482(newscr)
    move.w  (A0)+,642(newscr)
    move.w  (A0)+,802(newscr)
    move.w  (A0)+,962(newscr)
    move.w  (A0),1122(newscr)
    }
  else
   asm {
    clr.w   2(newscr)
    clr.w   162(newscr)
    clr.w   322(newscr)
    clr.w   482(newscr)
    clr.w   642(newscr)
    clr.w   802(newscr)
    clr.w   962(newscr)
    clr.w   1122(newscr)
    }

  if (text&0x800)
   asm {
    move.l  newfont,A0
    move.w  (A0)+,4(newscr)
    move.w  (A0)+,164(newscr)
    move.w  (A0)+,324(newscr)
    move.w  (A0)+,484(newscr)
    move.w  (A0)+,644(newscr)
    move.w  (A0)+,804(newscr)
    move.w  (A0)+,964(newscr)
    move.w  (A0),1124(newscr)
    }
  else
   asm {
    clr.w   4(newscr)
    clr.w   164(newscr)
    clr.w   324(newscr)
    clr.w   484(newscr)
    clr.w   644(newscr)
    clr.w   804(newscr)
    clr.w   964(newscr)
    clr.w   1124(newscr)
    }

            /* clear out bit plane 3 */
  asm {
    clr.w   6(newscr)
    clr.w   166(newscr)
    clr.w   326(newscr)
    clr.w   486(newscr)
    clr.w   646(newscr)
    clr.w   806(newscr)
    clr.w   966(newscr)
    clr.w   1126(newscr)
    }
   scrx++ ;
   }
 }

plot_7(data, scry, scrx, count)
char *data;
register int scry, scrx, count ;
   {
  register int text;
  register int *newscr ;
  register int *newfont ;

  if (gtia) return;

  while (count--)
      {
  asm
    {
;  text = *data++ + 64; /* add 64 to select colours 1-4, not 0-3 */
    clr.w   text
    move.l  data(LOCAL),A0
    move.b  (A0)+,text
    move.l  A0,data(LOCAL)
    add.w   #64,text
    ADD.W   text,text
    ADD.W   text,text
    ADD.W   text,text   /* text *= 8 */
    }

  newscr = (int *) scr_emul + mul80[scry] + (scrx<<2) ;
  newfont = &wide_font[(text&0x01F8)];  /* ignore color bits */

  if (text&0x200)
     {
     newfont = &wide_font[(text&0x01F8)];     /* ignore color bits */
     newscr[000]= newscr[80]=*newfont++;
     newscr[160]= newscr[240]=*newfont++;
     newscr[320]= newscr[400]=*newfont++;
     newscr[480]= newscr[560]=*newfont++;
     newscr[640]= newscr[720]=*newfont++;
     newscr[800]= newscr[880]=*newfont++;
     newscr[960]= newscr[1040]=*newfont++;
     newscr[1120]= newscr[1200]=*newfont;
     }
  else
  asm
    {
    clr.w   0(newscr)
    clr.w   160(newscr)
    clr.w   320(newscr)
    clr.w   480(newscr)
    clr.w   640(newscr)
    clr.w   800(newscr)
    clr.w   960(newscr)
    clr.w   1120(newscr)
    clr.w   1280(newscr)
    clr.w   1440(newscr)
    clr.w   1600(newscr)
    clr.w   1760(newscr)
    clr.w   1920(newscr)
    clr.w   2080(newscr)
    clr.w   2240(newscr)
    clr.w   2400(newscr)
    }

  if (text&0x400)
     {
     newfont = &wide_font[(text&0x01F8)];     /* ignore color bits */
     newscr[001]= newscr[81]=*newfont++;
     newscr[161]= newscr[241]=*newfont++;
     newscr[321]= newscr[401]=*newfont++;
     newscr[481]= newscr[561]=*newfont++;
     newscr[641]= newscr[721]=*newfont++;
     newscr[801]= newscr[881]=*newfont++;
     newscr[961]= newscr[1041]=*newfont++;
     newscr[1121]= newscr[1201]=*newfont;
     }
  else
  asm
    {
    clr.w   2(newscr)
    clr.w   162(newscr)
    clr.w   322(newscr)
    clr.w   482(newscr)
    clr.w   642(newscr)
    clr.w   802(newscr)
    clr.w   962(newscr)
    clr.w   1122(newscr)
    clr.w   1282(newscr)
    clr.w   1442(newscr)
    clr.w   1602(newscr)
    clr.w   1762(newscr)
    clr.w   1922(newscr)
    clr.w   2082(newscr)
    clr.w   2242(newscr)
    clr.w   2402(newscr)
    }

  if (text&0x800)
     {
     newfont = &wide_font[(text&0x01F8)];     /* ignore color bits */
     newscr[002]= newscr[82]=*newfont++;
     newscr[162]= newscr[242]=*newfont++;
     newscr[322]= newscr[402]=*newfont++;
     newscr[482]= newscr[562]=*newfont++;
     newscr[642]= newscr[722]=*newfont++;
     newscr[802]= newscr[882]=*newfont++;
     newscr[962]= newscr[1042]=*newfont++;
     newscr[1122]= newscr[1202]=*newfont;
     }
  else
  asm
    {
    clr.w   4(newscr)
    clr.w   164(newscr)
    clr.w   324(newscr)
    clr.w   484(newscr)
    clr.w   644(newscr)
    clr.w   804(newscr)
    clr.w   964(newscr)
    clr.w   1124(newscr)
    clr.w   1284(newscr)
    clr.w   1444(newscr)
    clr.w   1604(newscr)
    clr.w   1764(newscr)
    clr.w   1924(newscr)
    clr.w   2084(newscr)
    clr.w   2244(newscr)
    clr.w   2404(newscr)
    }
            /* clear out bit plane 3 */
  asm
    {
    clr.w   6(newscr)
    clr.w   166(newscr)
    clr.w   326(newscr)
    clr.w   486(newscr)
    clr.w   646(newscr)
    clr.w   806(newscr)
    clr.w   966(newscr)
    clr.w   1126(newscr)
    clr.w   1286(newscr)
    clr.w   1446(newscr)
    clr.w   1606(newscr)
    clr.w   1766(newscr)
    clr.w   1926(newscr)
    clr.w   2086(newscr)
    clr.w   2246(newscr)
    clr.w   2406(newscr)
    }
   scrx++ ;
   }
 }

/* for mode 8 (GR.3), each byte is 4 pixels, which appear as 4 8 pixel boxes */
/* Therefore 2 pixels are stored as 2 long words, with planes 0 and 1 in the */
/* first, and planes 2 and 3 in the seconds. The following lookup table has */
/* the masks for the 16 color combinations of 2 pixels */

long mode8_planes[16] = {
    0x00000000L, 0x00FF0000L, 0x000000FFL, 0x00FF00FFL,
    0xFF000000L, 0xFFFF0000L, 0xFF0000FFL, 0xFFFF00FFL,
    0x0000FF00L, 0x00FFFF00L, 0x0000FFFFL, 0x00FFFFFFL,
    0xFF00FF00L, 0xFFFFFF00L, 0xFF00FFFFL, 0xFFFFFFFFL } ;

plot_8(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
 {
  register int text;
  register long *newscr;

  if (gtia) return;

  while (count--) {
        text = *data++;
        newscr = (long *)scr_emul + mul40[scry] + (scrx<<2) ;
                                           /* do left 2 pixels */
        newscr[0] = newscr[40] = newscr[80] = newscr[120] =
        newscr[160] = newscr[200] = newscr[240] = newscr[280] =
        mode8_planes[(text>>4)&0x0F] ;
                                          /* do right two pixels */
        newscr[2] = newscr[42] = newscr[82] = newscr[122] =
        newscr[162] = newscr[202] = newscr[242] = newscr[282] =
        mode8_planes[text&0x0F] ;

        scrx++ ;
   }
 }

plot_9(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
   {
   register long *newscr;

   if (gtia) return;
   while (count--)
       {
       newscr = (long *)scr_emul + mul40[scry] + (scrx<<2) ;
  asm
    {
; since GR.4 and GR.5 have the same horizontal resolution as GTIA, use the same
; brute force routine to plot the pixels

    clr.l    4(newscr)          ; clear bit planes 2 & 3
    clr.l    12(newscr)
    clr.l    164(newscr)
    clr.l    172(newscr)
    clr.l    324(newscr)
    clr.l    332(newscr)
    clr.l    484(newscr)
    clr.l    492(newscr)
    move.b   (data)+,D0

    clr.l    D1
    btst     #0,D0
    beq.s    p91
    move.l   #0x000F0000,D1
  p91:
    btst     #1,D0
    beq.s    p92
    ori.l    #0x00F00000,D1
  p92:
    btst     #2,D0
    beq.s    p94
    ori.l    #0x0F000000,D1
  p94:
    btst     #3,D0
    beq.s    p98
    ori.l    #0xF0000000,D1
  p98:
    move.l   D1,8(newscr)
    move.l   D1,168(newscr)
    move.l   D1,328(newscr)
    move.l   D1,488(newscr)
    clr.l    D1
    btst     #4,D0
    beq.s    p910
    move.l   #0x000F0000,D1
  p910:
    btst     #5,D0
    beq.s    p920
    ori.l    #0x00F00000,D1
  p920:
    btst     #6,D0
    beq.s    p940
    ori.l    #0x0F000000,D1
  p940:
    btst     #7,D0
    beq.s    p9
    ori.l    #0xF0000000,D1
  p9:
    move.l   D1,(newscr)
    move.l   D1,160(newscr)
    move.l   D1,320(newscr)
    move.l   D1,480(newscr)
    add.w    #1,scrx
    }
        }
    }

plot_A(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
   {
   register long *newscr;

   if (gtia) return;
   while (count--)
       {
       newscr = (long *)scr_emul + mul40[scry] + (scrx<<1) ;
  asm
    {
    clr.l    4(newscr)          ; clear bit planes 2 & 3
    clr.l    12(newscr)
    clr.l    164(newscr)
    clr.l    172(newscr)
    clr.l    324(newscr)
    clr.l    332(newscr)
    clr.l    484(newscr)
    clr.l    492(newscr)
    move.b   (data)+,D0

    clr.l    D1
    btst     #0,D0
    beq.s    pA1
    move.l   #0x000F0000,D1
  pA1:
    btst     #1,D0
    beq.s    pA2
    ori.l    #0x0000000F,D1
  pA2:
    btst     #2,D0
    beq.s    pA4
    ori.l    #0x00F00000,D1
  pA4:
    btst     #3,D0
    beq.s    pA8
    ori.l    #0x000000F0,D1
  pA8:
    btst     #4,D0
    beq.s    pA10
    ori.l    #0x0F000000,D1
  pA10:
    btst     #5,D0
    beq.s    pA20
    ori.l    #0x00000F00,D1
  pA20:
    btst     #6,D0
    beq.s    pA40
    ori.l    #0xF0000000,D1
  pA40:
    btst     #7,D0
    beq.s    pA
    ori.l    #0x0000F000,D1
  pA:
    move.l   D1,(newscr)
    move.l   D1,160(newscr)
    move.l   D1,320(newscr)
    move.l   D1,480(newscr)
    add.w    #1,scrx
    }
        }
    }

                          /* plot a GR.6 byte - just do two 6+ plots */
plot_B(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
   {
   if (gtia) return;
     plot_C (data,scry,scrx,count) ;
     plot_C (data,++scry,scrx,count) ;
  }
                                         /* plot a GR.6+ byte */
/* for mode C (GR.6), each byte is 8 pixels, which appear as 8 2 pixel boxes */
/* Therefore 8 pixels are stored as 4 ints, with planes 0 and 1 in the */
/* first 2, and planes 2 and 3 in last 2. Since it is mono, planes 1 & 2 & 3 */
/* are clear and plane 0 gets the value of the byte stretched to a wide_byte */

plot_C(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
 {
  register int text;
  register int *newscr;

   if (gtia) return;
  while (count--) {
        text = *data++;
        newscr = (int *) scr_emul +  mul80[scry] + (scrx<<2) ;
        *newscr++ = wide_byte[text&0xFF] ;
        *newscr = 0 ;
        scrx++ ;
   }

 }

plot_D(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
 {
  register int text;
  register char *newscr;

   if (gtia) return;
  while (count--) {
        newscr = scr_emul + mul160[scry] + (scrx&1) + ((scrx&~1)<<2) ;
        asm
                {
                move.b   (data)+,text
                move.b   text,D1
                andi.w   #0x55,D1
                move.w   D1,D0
                add.w    D0,D0
                or.w     D1,D0
                move.b   D0,(newscr)
                move.b   D0,160(newscr)

                andi.w   #0xAA,text
                move.w   text,D0
                lsr.w    #1,D0
                or.w     text,D0
                move.b   D0,2(newscr)
                move.b   D0,162(newscr)

                add.w    #1,scrx
                }
   }
 }

plot_E(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
 {
  register int text;
  register char *newscr;

   if (gtia) return;
  while (count--) {
        newscr = scr_emul + mul160[scry] + (scrx&1) + ((scrx&~1)<<2) ;
        asm
                {
                move.b   (data)+,text
                move.b   text,D1
                andi.w   #0x55,D1
                move.w   D1,D0
                add.w    D0,D0
                or.w     D1,D0
                move.b   D0,(newscr)

                andi.w   #0xAA,text
                move.w   text,D0
                lsr.w    #1,D0
                or.w     text,D0
                move.b   D0,2(newscr)

                add.w    #1,scrx
                }
   }
 }

                             /* plot a GR.8 byte */

plot_F(data, scry, scrx, count)
register char *data;
register int scry, scrx, count ;
  {
  register char *newscr;

  if (gtia)
      {
      while (count--)
          {
          newscr = scr_emul + mul160[scry] + (scrx&1) + ((scrx&~1)<<2) ;
          asm
            {
            clr.b    (newscr)
            clr.b    2(newscr)
            clr.b    4(newscr)
            clr.b    6(newscr)
            move.b   (data)+,D0
            beq.s    gtia0

            btst     #0,D0
            beq.s    gtia01
            move.b   #15,(newscr)
  gtia01:
            btst     #1,D0
            beq.s    gtia02
            move.b   #15,2(newscr)
  gtia02:
            btst     #2,D0
            beq.s    gtia04
            move.b   #15,4(newscr)
  gtia04:
            btst     #3,D0
            beq.s    gtia08
            move.b   #15,6(newscr)
  gtia08:
            btst     #4,D0
            beq.s    gtia10
            ori.b    #0xF0,(newscr)
  gtia10:
            btst     #5,D0
            beq.s    gtia20
            ori.b    #0xF0,2(newscr)
  gtia20:
            btst     #6,D0
            beq.s    gtia40
            ori.b    #0xF0,4(newscr)
  gtia40:
            btst     #7,D0
            beq.s    gtia0
            ori.b    #0xF0,6(newscr)
  gtia0:
            add.w    #1,scrx
            }
          } /* while */
      }
  else
      {
      while (count--) {
          newscr = scr_emul + mul160[scry] + (scrx&1) + ((scrx&~1)<<2) ;
          asm
            {
            move.b   (data)+,D0
            not.w    D0
            move.b   D0,(newscr)
            move.w   #~0,D0
            move.b   D0,2(newscr)
            clr.b    4(newscr)
            clr.b    6(newscr)
            add.w    #1,scrx
            }
          } /* while */
      } /* if gtia */
 }

int (*do_plot[16])() = {
  plot_0, plot_1, plot_2, plot_3, plot_4, plot_5, plot_6, plot_7,
  plot_8, plot_9, plot_A, plot_B, plot_C, plot_D, plot_E, plot_F } ;


do_display()
  {
  /* redraw the entire screen - does not clear status bytes - just sets them */

  register char *mdlptr ;  /* pointer to current byte in dlist */
  register char *pstat;
  DL *qdl=dlBlocks;
  int old_mode=-1;
  unsigned d_loc = 0 ;     /* address of start of scan line */
  register  int opc,       /* current byte of dl */
  h_byt,
  scan_line = 0,     /* current scan line */
  antic_mode ;

  if (!gtia)
      plot_1 (0,200);   /* clear any garbage out of bit planes 2 and 3 */

  qdl->mode=-1;

  mdlptr = mem+dl;

  do
    {
    opc = *mdlptr++ & 0x7F ;     /* skip first 24 lines */
    } while (opc==112) ;

  mdlptr-- ;

  do {
      stat[(int)(mdlptr-mem)] = 64;    /* set status byte of dl byte */

      antic_mode = (opc = *mdlptr++ & 0x4F) & 0x0F ;

      if (antic_mode>1)
          {
          if (opc&64)
              {
              d_loc=(unsigned)(*mdlptr)+((unsigned)(*(mdlptr+1))<<8) ;
              stat[(int)(mdlptr++ -mem)] = 64;
              stat[(int)(mdlptr++ -mem)] = 64;
              if (antic_mode==old_mode)
                  old_mode=999;              /* force a new DL */
              }
          (*do_plot[antic_mode])(mem+d_loc,scan_line,0,phor_bytes[antic_mode]);
          h_byt=phor_bytes[antic_mode]-1;
          pstat=&stat[d_loc];
            {
            asm {
  loop_DD:
    move.b   (pstat)+,D0
    bne.s    no_stat
    move.b   #65,-1(pstat)
no_stat:
    dbf      h_byt,loop_DD
                }
             } /* for loop */
          if (antic_mode!=old_mode)
             {
             if (old_mode!=-1)
                 qdl++;
             old_mode=antic_mode;
             qdl->mode = antic_mode;
             qdl->height = scan_table[antic_mode];
             qdl->width = phor_bytes[antic_mode];
             qdl->block_size = 0;
             qdl->start=d_loc;
             qdl->scan=scan_line;
             }
          qdl->block_size += phor_bytes[antic_mode];
          d_loc += phor_bytes[antic_mode] ;

          scan_line += scan_table[antic_mode] ;
          }
      else if (antic_mode==1)
          plot_0 (scan_line++,1) ;
      else
          {
          plot_0(scan_line,(opc>>4)+1) ;
          if (old_mode!=0)
             {
             if (old_mode!=-1)
                 qdl++;
             old_mode=0;
             qdl->mode = 0;
             }
          scan_line += (opc>>4)+1 ;
          }
   } while (opc != 65 && scan_line<196) ;

   if (scan_line<199)
        plot_0(scan_line,200-scan_line);

   (++qdl)->mode=-1;
   fRedraw=FALSE;
 }


do_byte(loc)       /* redraw one byte on the screen */
register unsigned loc ;
    {
    register int antic_mode ;
    register unsigned int offset;
    register int scan_line;     /* current scan line */
    register DL *qdl=dlBlocks;

    while ((antic_mode = qdl->mode) != -1)
        {
        if (antic_mode!=0)
        if (((offset=loc-(unsigned)(qdl->start))<qdl->block_size))
            {
            scan_line = qdl->scan + ((offset)/qdl->width)*qdl->height;
            (*do_plot[antic_mode])(mem+loc,scan_line,offset%qdl->width,1);
            }
        ++qdl;
        }
    }

/* Clear out all status bytes that refer to the screen. About to redraw */
/* It works by traversing the DL structures and clearing the status bytes */
/* of all the blocks. A lot faster than the following code: */
/*    for (ea=0; ++ea;) if (stat[ea]&64) stat[ea]=0; */

clear_disp()
    {
    register int cb;
    register DL *qdl=dlBlocks;
    register char *pstat;

    while (qdl->mode != -1)
        {
        if (qdl->mode==0)
            {
            qdl++;
            continue;
            }
        cb = qdl->block_size -1;
        pstat = &stat[qdl->start];
  asm
    {
  loop_clear:
    move.b  (pstat)+,D0         ; get a status byte
    cmpi.b  #65,D0              ; is it a screen status byte
    bne.s   no_clear            ; no
    clr.b   -1(pstat)           ; otherwise clear it
  no_clear:
    dbf     cb,loop_clear       ; while cb--
    }
        qdl++;
        }
    dlBlocks[0].mode=-1;
    }


do_color (ea, byt) unsigned int ea, byt ;
  {
  register int temp=*(rainbow+(byt&~1));

  if (ea==53274)
      *(int *)0xFFFF8240L=temp;
  else
      *(int *)(0xFFFF8240L + (long)((ea-53269)<<1))=temp;
  }

do_colors (ea, byt) register unsigned int ea, byt ;
  {
  register char *rgch = shadows;
  register int i;

  byt &= 254;

  switch (gtia)
      {
  default:                   /* normal mode */
      if (ea==712)
          *rgch=byt;
      else if (ea>707)
          rgch[ea-707]=byt;
      break;

  case 0x80:                 /* GR.10 mode */
      rgch[ea-704]= byt;
      break;

  case 0x40:                   /* GR.9 (16 shades) */
      if (ea==712)
          {
          byt &= 0xF0;
          for (i=0; i<16; i++)
              {
              *rgch++ = byt++;
              }
          }
      break;

  case 0xC0:                   /* GR.11 (16 colors) */
      if (ea==712)
          {
          byt &= 0x0F;
          for (i=0; i<16; i++)
              {
              *rgch++ = byt;
              byt += 16;
              }
          }
      break;
      }
  }

do_chset() {

  register int num8, old ;
  register char *pchset ;

  pchset = mem + (unsigned)(*(mem+756))*256 ;

  for (num8=0 ; num8<1024; num8++) {
      old = *pchset++ ;

      norm_font[num8] = old ;
      norm_font[num8+1024] = ~old ;
      wide_font[num8] = wide_byte[old] ;
      wide_font[num8+1024] = ~wide_byte[old] ;
   }
  if (dma) fRedraw=TRUE;
 }

/* these two routines nuked when put as inline code. WHY??????? arghhh */

do_open()
      {
        char stat;
        int cch, iocb, iocb16, hand;
        char ch, aux1, aux2;
        unsigned int vector;

        iocb16 = (unsigned) x ;
        iocb = iocb16/16;
        vector = (unsigned)mem[0x344+iocb16] + (unsigned)mem[0x345+iocb16]*256;
        aux1 = mem[0x34A+iocb16];

        stat=146 ;
        cch=0;

/* Parse over the "Dn:" which leaves just the filename */
        while (*(mem+vector++)!=':')
           {
           if (++cch>2)
               goto Dopen_exit;
           }

        cch=0;
        do {
           ch = *(mem+vector++);
           filename[cch++]=ch;
         } while (cch<15 && ch>32 && ch<91) ;
        filename[--cch]=0;

 /* Now check for the special case where the use wants a disk directory. */
 /* Open a file _.DIR and stuff a DOS 2.0 type directory listing into it. */

        if (aux1==6)
            {
            hand = Fcreate("_.DIR",0);
            Directory(filename,hand);
            Fclose(hand);
            hand = Fopen("_.DIR",0);
            }
        else if (aux1&4)
            hand = Fopen(filename,0);
        else
            hand = Fcreate(filename,0);

        if (hand<0) {
            if (hand==-33) stat = 170 ;
            else stat=165;
           }
        else {
            stat = 1 ;
            DOS_hand[iocb]=hand;
            DOS_mode[iocb]=aux1;
          }
  Dopen_exit:
        mem[0x4c]=stat;
        y=stat;
      }

do_put()
      {
        char stat;
        int iocb, iocb16, hand;
        char ch;
        unsigned cch, vector;

        ch=a;
        iocb16 = (unsigned) x ;
        iocb = iocb16/16;

        vector = (unsigned)mem[0x24] + (unsigned)mem[0x25]*256;
        cch = (unsigned)mem[0x28] + (unsigned)mem[0x29]*256;

        stat=135 ;
        if (DOS_mode[iocb]&4) goto Dput_exit;   /* read only */
        hand=Fwrite (DOS_hand[iocb],(long)cch,mem+vector) ;
        if (hand<0)
            stat=163;
        else
            {
            mem[0x24]+=mem[0x28];     /* increment buffer pointer */
            mem[0x25]+=mem[0x29];
            mem[0x28]=1;    /* decrement buffer length */
            mem[0x29]=0;    /* decrement buffer length */
            stat = 1 ;
            }
  Dput_exit:
        mem[0x4c]=stat;
        y=stat;
      }

do_get()
      {
        char stat;
        int iocb, iocb16, hand;
        char ch;
        unsigned cch, vector;
        int fTEXT;

        iocb16 = (unsigned) x ;
        iocb = iocb16/16;

        vector = (unsigned)mem[0x24] + (unsigned)mem[0x25]*256;
        cch = (unsigned)mem[0x28] + (unsigned)mem[0x29]*256;
        if (cch==0) cch=1;

        stat=131 ;
        if (DOS_mode[iocb]&8)
            goto Dget_exit;   /* write only */

        fTEXT = (mem[0x22]&2)?0:1;

        if (fTEXT)
            {
            while (cch)
                {
                hand=Fread (DOS_hand[iocb],1L,mem+vector) ;
                ch = *(mem+vector++);
                if (hand<0)
                    stat=163;
                else if (hand==0)    /* EOF */
                    stat=136;
                else
                    {
                    if (mem[0x24]++ ==0)   /* increment buffer pointer */
                        mem[0x25]++;
                    if (mem[0x28]-- == (char)255)
                        mem[0x29]--;       /* decrement buffer length */
                    stat = 1 ;
                    }
                if (hand<=0 || (ch == (char)155))
                    goto Dget_exit;
                }
            stat = 137;   /* truncated record error */
            }
        else
            {
            hand=Fread (DOS_hand[iocb],(long)cch,mem+vector) ;
            ch = *(mem+vector+cch-1);

            if (hand<0)
                stat=163;
            else if (hand==0)    /* EOF */
                stat=136;
            else
                {
                mem[0x24]+=mem[0x28];     /* increment buffer pointer */
                mem[0x25]+=mem[0x29];
                mem[0x28]=1;    /* decrement buffer length */
                mem[0x29]=0;    /* decrement buffer length */
                stat = 1 ;
                }
            }
  Dget_exit:
        mem[0x4c]=stat;
        y=stat;
        a=ch;
      }

do_close()
      {
        char stat;
        int iocb16, iocb;

        iocb16 = (unsigned) x ;
        iocb = iocb16/16;
        Fclose(DOS_hand[iocb]);
        DOS_hand[iocb] = -1 ;
        stat = 1 ;
  Dclose_exit:
        mem[0x4c]=stat;
        y=stat;
      }

#ifdef NEVER

do_Eput()
     {
     register char *rmem = mem;
     register int crs_r=rmem[84];
     register int crs_c=rmem[85];
     register unsigned addr;
     register unsigned addr1;

     rmem[763]=a;

     /* if ESC flag is off, go handle special keys, else handle as text */

     addr = (addr1 = (unsigned)(rmem[88]) + (((unsigned)(rmem[89]))<<8))
               + crs_c + (crs_r<<3) + (crs_r<<5);

     if (a==155)
        {
        if (rmem[752]==0)
            {
            *(rmem+addr) ^= 128;
            do_byte(addr);
            }
        goto cr;
        }
     else     /* normal char */
        {
        switch (a&96)
             {
        case  0: a |= 64;
                 break;
        case 32: a &= ~32;
                 break;
        case 64: a ^= 96;
             }

        if ((stat[addr] & 79)==66)
            {
            *(rmem+addr) = a;
            do_byte(addr);
            }
        if (++crs_c >mem[83])
            {
  cr:
            crs_c = mem[82];
            if (++crs_r>23)
                crs_r = 0;
            }
        }
     rmem[84]=crs_r;
     rmem[85]=crs_c;
     rmem[86]=0;
     if (rmem[752]==0)
         {
         addr = addr1 + crs_c + (crs_r<<3) + (crs_r<<5);
         *(rmem+addr) ^= 128;
         do_byte(addr);
         }

     rmem[0x4C] = y = 1;
     }

#endif

/******** Sound routines  *************************************************/

int NoiseOn[]={0xF7,0xEF,0xDF};
int NoiseOff[]={0x8,0x10,0x20};
int ToneOn[]={0xFE,0xFD,0xFB};
int ToneOff[]={0x01,0x02,0x04};

/* This routine emulates the Atari 800 SOUND 0,0,0,0 command */

Sound(channel,freq,dist,vol)
register int channel,freq,vol;
int dist;
    {
    register int old7;
    channel %= 3;           /* mask all values to make them legal */
    freq &= 0xFF;
    dist &= 0x0E;
    vol &= 0xF;

/*  ST uses 12 bits. The 800's 8 bits maps to bits 10..3 xxxx0ffffffff000 */

    Giaccess(freq<<2,0x80+channel+channel); /* fine tune */
    Giaccess(freq>>6,0x81+channel+channel); /* coarse tune */

/* stuff volume */

    Giaccess(vol,0x88+channel);

/* do distortion */

    old7=Giaccess(0,0x7);

    if(freq)
       {

       if ((dist&10)==10)
           {         /* pure tones */
           old7 |= NoiseOff[channel];
           old7 &= ToneOn[channel];
           }
       else
           {                          /* noise */
           old7 |= ToneOff[channel];
           old7 &= NoiseOn[channel];
           Giaccess(dist<<4,0x86);
           }
       }
    else
       {  /* if freq==0, shut down channel */
       old7 |= NoiseOff[channel];
       old7 |= ToneOff[channel];
       }
    Giaccess(old7,0x87);
    }


/************ joystick handling routines ************************************/

anotherdummy()   /* a dummy routine. Should never be called */
    {
    asm
        {
JoyOn:
        move.w  #0x12,-(A7)
        move.w  #4,-(A7)
        move.w  #3,-(A7)
        trap    #13
        addq.l  #6,A7

        lea     Joy0(PC),A3
        move.w  #0,(A3)         ; clear both sticks
        move.w  #34,-(A7)
        trap    #14             ; Kbdvase call
        addq.l  #2,A7
        move.l  D0,A0
        lea     SaveStick(PC),A3
        move.l  24(A0),(A3)     ; joystick is the 7th vector
        lea     Stick(PC),A3
        move.l  A3,24(A0)       ; install our handler

        move.w  #0x14,-(A7)
        move.w  #4,-(A7)
        move.w  #3,-(A7)
        trap    #13
        addq.l  #6,A7

        rts

Stick:
        move.l  A1,-(A7)        ; skip the formalities, just read both sticks
        lea     Joy0(PC),A1
        move.b  1(A0),(A1)+
        move.b  2(A0),(A1)
        move.l  (A7)+,A1
        rts

JoyOff:
        move.w  #0x1a,-(A7)
        move.w  #4,-(A7)
        move.w  #3,-(A7)
        trap    #13
        addq.l  #6,A7           ; disable Joysticks

        move.w  #34,-(A7)
        trap    #14
        addq.l  #2,A7
        move.l  D0,A0
        move.l  SaveStick(PC),24(A0) ; restore the old vector

        move.w  #0x8,-(A7)
        move.w  #4,-(A7)
        move.w  #3,-(A7)
        trap    #13
        addq.l  #6,A7
        rts

SaveStick:
        dc.l    0
Joy0:   dc.b    0
Joy1:   dc.b    0

   /*********spill over into VBI stuff ******************************/

  VBI:
    move.l  RegA4(PC),A4    ; now we can access C globals
    lea     RegA7(PC),A0    ; this saves the stack for sure
    move.l  A7,(A0)
                
    move.l  mem(GLOBAL),A0  ; get pointer to byte 0
    move.l  A0,A1
    adda.l  #65536L,A1      ; A1 points to end of memory
    addq.b  #1,20(A0)
    bne     check_critic
    addq.b  #1,77(A0)       ; attract mode
    addq.b  #1,19(A0)
    bne.s   check_critic
    addq.b  #1,18(A0)

  check_critic:
    tst.b   66(A0)          ; did someone set the critical flag?
    bne     exitVBI

  do_stick:
    move.b  Joy1(PC),D0     ; joystick-only port is stick 0
    move.b  D0,D1
    not.w   D0
    andi.w  #15,D0
    move.b  D0,632(A0)      ; stick(0) shadow
    move.b  D0,D2
    lsl.w   #8,D2
    move.b  D0,634(A0)      ; stick(2) shadow
    btst    #7,D1
    seq     D0
    andi.w  #1,D0
    move.b  D0,644(A0)      ; strig(0) shadow
    move.b  D0,646(A0)      ; strig(2)
    move.b  D0,53264(A1)    ; strig(0) hardware
    move.b  D0,53266(A1)
    move.b  Joy0(PC),D0     ; mouse port is really stick 1, not 0
    move.b  D0,D1
    not.w   D0
    andi.w  #15,D0
    move.b  D0,633(A0)      ; stick(1)
    move.b  D0,635(A0)      ; stick(3)
    move.b  D0,D2
    move.w  D2,54016(A1)    ; stick(0) and stick(1) hardware
    move.w  D2,54018(A1)    ; stick(2) and stick(3) hardware
    btst    #7,D1
    seq     D0
    andi.w  #1,D0
    move.b  D0,645(A0)      ; strig(1)
    move.b  D0,647(A0)      ; strig(3)
    move.b  D0,53265(A1)    ; strig(1) hardware
    move.b  D0,53267(A1)

  ; decrement system timers and set flags

  do_timers:
    move.w  #4,D1       ; 5 system timers
  dt1:
    move.w  536(A0),D0
    beq.s   dt3
    subi.w  #0x0100,D0      ; decrement lo byte
    cmp.w   #255,D0
    bgt.s   dt2
    subi.w  #1,D0           ; decrement hi byte
  dt2:
    move.w  D0,(A0)+
  dt3:
    dbf     D1,dt1

  exitVBI:
    lea     sysvbl(PC),A0
    lea     pemul(PC),A1
    move.l  A0,(A1)         ; change dispatch vector to point to VBI

    move.l  RegA7(PC),A7    ; restore the stack pointer before
    rts                     ; we leave from the vbi

RegA4:  dc.l    0
RegA7:  dc.l    0
    }
    }

VBIon()
    {
    int queue,i;

  asm
    {
    lea     RegA4(PC),A0
    move.l  A4,(A0)

    move.l  #0x456,A0
    move.l  (A0),IntrptPtr(A4)
    }
    queue=*(int *)0x454L;
    IRet=0;

    for(i=0;i<queue;i++)
        {
        if(*IntrptPtr==0L)
            {
            asm
                {
                move.l  IntrptPtr(A4),A0
                lea     VBI(PC),A1
                move.l  A1,(A0)
                }
            i=queue;
            IRet=1;
            }
        else
            IntrptPtr++;
        }
    }

VBIoff()
    {
    *IntrptPtr=0L;
    }


/**************** keyboard handler stuff ***********************/

Install_Key()
    {
    register long *oldvec;

    oldvec = (long *) Kbdvbase();

    asm {
        lea     32(oldvec),oldvec      ; system IKBD vector
        lea     oldKey(PC),A0
        move.l  (oldvec),(A0)          ; put it away in safe storage
        lea     KeyPatch(PC),A1        ; and now play with fire and
        move.l  A1,(oldvec)            ; patch in our routine
        }
    return;

    asm {

; this is a patch to the keyboard input routine to allows us to tell if
; the keys F7, F8, and F9 are being held down
; Note that we do NOT check the keys before the OS does. This is because as
; soon as the key is checked, the interrupt is cleared and the OS would not
; see the keypress. So jsr to the code in ROM then check the key, since WE know
; it's there.

KeyPatch:
        movem.l D0/A0/A4,-(SP)

        move.l  oldKey(PC),A0   ; call the old keyboard routine
        jsr     (A0)

        move.l  RegA4(PC),A4

        lea     0xFFFFC00L,A0   ; address of keyboard ACIA

        move.b  2(A0),D0        ; get the byte

        cmpi.b  #0xC1,D0        ; is F7 being released?
        bne.s   kp2
        clr.w   fSTART(GLOBAL)
        bra     kp_exit         ; get out of interrupt
  kp2:
        cmpi.b  #0x41,D0        ; is F7 being pressed?
        bne.s   kp3
        move.w  #-1,fSTART(GLOBAL)
        bra     kp_exit         ; get out of interrupt
  kp3:
        cmpi.b  #0xC2,D0        ; F8
        bne.s   kp4
        clr.w   fSELECT(GLOBAL)
        bra     kp_exit         ; get out of interrupt
  kp4:
        cmpi.b  #0x42,D0
        bne.s   kp5
        move.w  #1,fSELECT(GLOBAL)
        bra     kp_exit         ; get out of interrupt
  kp5:
        cmpi.b  #0xC3,D0        ; F9
        bne.s   kp6
        clr.w   fOPTION(GLOBAL)
        bra     kp_exit         ; get out of interrupt
  kp6:
        cmpi.b  #0x43,D0
        bne.s   kp_exit
        move.w  #1,fOPTION(GLOBAL)
  kp_exit:
        movem.l (SP)+,D0/A0/A4
        rts

oldKey: dc.l    0
        }
    }

Remove_Key()
    {
    register long *oldvec;

    oldvec = (long *)Kbdvbase();

    asm {
        lea     32(oldvec),oldvec   ; system IKBD vector
        lea     oldKey(PC),A0
        move.l  (A0),(oldvec)       ; recover the old vector
        }
    }


/************* Player Missle Graphics Stuff ************************/
/*                                                                 */

drawPlayer(ip)
register int ip;
    {
    register char *page,*spriteptr;
    register int clip,bits,xcoord;
    int plane0=((ip&1)?0:4);
    int plane1=((ip&2)?2:4);
    int byte = grafP[ip];

/* First check to see if sprite is even visible.  If not, exit routine */

   page=(char *)scr_emul;
   xcoord=hposP[ip];
   if((xcoord>42) && (xcoord<=207) ) {
        spriteptr=qP[ip]+32;            /* start=32, first 31 lines not used */
        bits = (xcoord & 7)<<1;         /* xbit, only even */
        asm {       /*
    lea     wide_byte(A4),A1 ; pointer to double-size bytes
     move.w  mdPMG(GLOBAL),D2 ; type of PMG display
    beq     exit_PMG
    move.w  byte(LOCAL),D1  ; graphics data

    moveq   #0,clip         ; default: no clipping
    move.w  xcoord,D0
    add.w   D0,D0           ; double for 2-pixel movement
    sub.w   #96,D0          ; trim off excess
    bpl.s   positive        ; if positive, no min x clipping
    moveq   #-1,clip        ; mark clipping on x
    moveq   #-8,D0          ; make x coord minimum of zero
    bra.s   out1            ; and skip this other stuff
  positive:
    cmpi.w  #200,xcoord     ; see if off the right edge
    blt.s   fixxcoord       ; no, so modify x for lookup
    moveq   #1,clip         ; yes, so set clipping flag
  fixxcoord:
    lsr.w   #1,D0           ; divide by 2 to get byte address
    andi.w  #0xFFF8,D0      ; and make sure it is even words
  out1:
    adda.w  D0,page         ; add x offset to screen

    move.l  page,A0         ; A0 is pointer to 2nd plane
    adda.w  plane0(LOCAL),page
    adda.w  plane1(LOCAL),A0

    move.w  #199,D3         ; counter: 200 lines
  loop:         moveq   #0,D0
    move.b  D1,D0
    btst    #2,D2
    beq.s   loop2
    move.b  (spriteptr)+,D0 ; get image byte
  loop2:
    beq.s   noplot          ; don't plot empty bytes

    add.w   D0,D0           ; double it to access tables
    move.w  0(A1,D0),D0     ; D0 now holds proper image byte
    swap    D0              ; move image into high word
    lsr.l   bits,D0         ; now shift image to proper position
    cmpi.w  #1,clip         ; clipping right edge?
    beq.s   lowword         ; if yes, then branch over this
    or.w    D0,8(page)      ; runoff image to 2nd word, plane 0
    or.w    D0,8(A0)        ; and also plane 1
  lowword:      cmpi    #-1,clip        ; clipping left edge?
    beq.s   noplot          ; if yes, then branch over this
    swap    D0              ; get original image, also shifted
    or.w    D0,(page)       ; stuff that in position, plane 0
    or.w    D0,(A0)         ; and plane 1

  noplot:
    lea     160(page),page  ; no matter what, point to next line
    lea     160(A0),A0
    dbf     D3,loop         ; count down all 200 lines
  exit_PMG:
    nop           */
                }
        }
 return;

 asm {

  w_PMB:                        ; location 54279
    SWAP    DBUS
    MOVE.L  REGEA,REGMEA
    move.b  (REGMEA),REGEA
    cmp.b   DBUS,REGEA
    beq     w_PMB_exit
    move.b  DBUS,pmbase(GLOBAL)     ; write to high byte
    SAVEREGS
    }
    {
    int i;

    pmbase &= ~255;          /* clear out low byte */
    if (mem[559] & 16)
        {
        qM = mem + 768L + (unsigned)pmbase;
        qP[0] = qM + 256L;
        qP[1] = qM + 512L;
        qP[2] = qM + 768L;
        qP[3] = qM + 1024L;
        }
    else
        {
        qM = mem + 384L + (unsigned)pmbase;
        qP[0] = qM + 128L;
        qP[1] = qM + 256L;
        qP[2] = qM + 384L;
        qP[3] = qM + 512L;
        }
    for (i=0; i<4; i++)
        hposM[i] = hposP[i] = grafP[i] = 0;
    grafM = 0;
    }
  asm
    {
    LOADREGS
  w_PMB_exit:
    DISPATCH

  w_gP:                 ; location 53261
    SWAP    DBUS
    MOVE.b  DBUS,a(GLOBAL)
    andi.w  #3,REGEA
    MOVE.w  REGEA,ea(GLOBAL)
    SAVEREGS
    }
    {
    int i=ea;

    if (grafP[i] != a)
        {
        grafP[i] = a;
        if (mdPMG)
            drawPlayer(i);
        }
    }
 asm
    {
    LOADREGS
    DISPATCH
    }
    }

/* end of _XATARI.C */

