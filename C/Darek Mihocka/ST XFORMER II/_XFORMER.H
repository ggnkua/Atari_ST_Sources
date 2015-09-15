
/****************************************************************************

  _XFORMER.H  by Darek Mihocka  (CIS: 73657,2714   GEnie: DAREKM)

  include file which declares all global variables used by the _X*.C files

  Last update: June 14, 1987  19:45

****************************************************************************/

#define DISPMODE0 0
#define DISPMODE1 1

#define TRUE     1
#define FALSE    0

  /* status bits of the P register: (6502)  NV_BDIZC */

#define NBIT 0x80
#define VBIT 0x40
#define BBIT 0x10
#define DBIT 0x08
#define IBIT 0x04
#define ZBIT 0x02
#define CBIT 0x01

  /* status bits of the CCR register: (68000)  BDIXNZVC */

#define BITN 0x08
#define BITV 0x02
#define BITB 0x80
#define BITD 0x40
#define BITI 0x20
#define BITZ 0x04
#define BITC 0x01
#define BITX 0x10

#define DBUS    D0
#define IR      D0
#define REGA    D1
#define REGX    D2
#define REGY    D3
#define REGSP   D4
#define REGPC   D5
#define REGST   D6
#define REGEA   D7

/* pointer to mem[ea] and otherwise all purpose register*/
#define REGMEA  A0

/* constant pointer to vector table */
#define REGOPS  A1

/* pointer to mem[pc] */
#define REGMPC  A2

/* pointer to stat[0] */
#define REGSTAT A3

/* pointer to global C variables */
#define GLOBAL  A4

/* A5 no longer used. I found out the hard way (bombs) that Megamax uses it! */

/* pointer to the frame (local variables) */
#define LOCAL   A6

/* the stack pointer, for some reason, not defined by Megamax */
#define SP      A7


#define SETREAD   addq.w #1,isread(A4)
#define SETWRITE  clr.w  isread(A4)
#define TESTWRITE tst.W  isread(A4)

/* quickly save and restore 6502 variables */
#define SAVEREGS  movem.l D1-D7/A0-A3,-(SP)
#define LOADREGS  movem.l (SP)+,D1-D7/A0-A3

/* set the flags right after a register is loaded */
#define FLAGS     move.w  SR,DBUS \
                  and.b   #(BITN|BITZ),DBUS \
                  and.b   #~(BITN|BITZ),REGST \
                  or.b    DBUS,REGST

/* finished executing an opcode, check VBI flag and go to dispatch routine */
#define DISPATCH move.l pemul(PC),REGMEA \
                 jmp (REGMEA)

/* some not too incredibly useful macros */
#define LOOP while(1)
#define put(x) outchar(x)
#define CR print(strCR)
#define BEL '\007'
#define print(x) put_line(x)

extern int
    isread,          /* read/write flag for special opcodes */
    mdRez;           /* screen resolution */

extern char
    *mem,            /* 65536 bytes to simulate 6502 memory */
    *stat,           /* status bits for each byte of 6502 memory */
    *scr,            /* pointer to start of title/debugger screen */
    *scr_emul;       /* pointer to start of emulation screen */

extern unsigned int
    pc,              /* 6502 program counter (16 bits) */
    ea;              /* used for effective address calculations */

extern unsigned char
    a,x,y,sp,ir,p,   /* 6502 registers */
    fTrace ;         /* trace flag */

extern int fVBI;                /* set when a 6502 VBI should occur */
extern int rainbow[128];        /* 8 bit color translation table */
extern int fCartA,fCartB;       /* flags set if cartriges loaded */

extern rgPalette[2][16];

extern int
    (*vec_6502[256])(),         /* pointer to 256 opcode routines  D flag =0 */
    (*dec_6502[256])();         /* pointer to 256 opcode routines  D flag =1 */

extern
    pemul(),         /* pointer to emul() */
    emul(),          /* main dispatch routine */
    exit_emul(),     /* exit routine to go back to C */
    emul_serv(),     /* dispatch routine for non-zero status bytes */
    sysvbl();        /* 8-bit system VBI emulation routine */

/* Joystick variables and routines */
extern Joy0(),Joy1(),JoyOn(),JoyOff(),oldStick(),Stick();

/* vertical blank interrupt variables and routines */
extern VBIon(),VBIoff(),RegA4(),VBI();

/* pointer to the keyboard routine in TOS */
extern oldKey();

/* tell Megamax that the emulation routines will be found in inline code: */
extern
 op00(), op01(), op02(), op03(), op04(), op05(), op06(), op07(), op08(),
 op09(),op0A(),op0B(), op0C(), op0D(), op0E(), op0F(), op10(), op11(), op12(),
 op13(), op14(), op15(), op16(), op17(), op18(), op19(), op1A(), op1B(),
 op1C(), op1D(), op1E(), op1F(), op20(), op21(), op22(), op23(), op24(),
 op25(), op26(), op27(), op28(), op29(), op2A(), op2B(), op2C(), op2D(),
 op2E(), op2F(), op30(), op31(), op32(), op33(), op34(), op35(), op36(),
 op37(), op38(), op39(), op3A(), op3B(), op3C(), op3D(), op3E(), op3F(),
 op40(), op41(), op42(), op43(), op44(), op45(), op46(), op47(), op48(),
 op49(), op4A(), op4B(), op4C(), op4D(), op4E(), op4F(), op50(), op51(),
 op52(), op53(), op54(), op55(), op56(), op57(), op58(), op59(), op5A(),
 op5B(), op5C(), op5D(), op5E(), op5F(), op60(), op61(), op62(), op63(),
 op64(), op65(), op66(), op67(), op68(), op69(), op6A(), op6B(), op6C(),
 op6D(), op6E(), op6F(), op70(), op71(), op72(), op73(), op74(), op75(),
 op76(), op77(), op78(), op79(), op7A(), op7B(), op7C(), op7D(), op7E(),
 op7F(), op80(), op81(), op82(), op83(), op84(), op85(), op86(), op87(),
 op88(), op89(), op8A(), op8B(), op8C(), op8D(), op8E(), op8F(), op90(),
 op91(), op92(), op93(), op94(), op95(), op96(), op97(), op98(), op99(),
 op9A(), op9B(), op9C(), op9D(), op9E(), op9F(), opA0(), opA1(), opA2(),
 opA3(), opA4(), opA5(), opA6(), opA7(), opA8(), opA9(), opAA(), opAB(),
 opAC(), opAD(), opAE(), opAF(), opB0(), opB1(), opB2(), opB3(), opB4(),
 opB5(), opB6(), opB7(), opB8(), opB9(), opBA(), opBB(), opBC(), opBD(),
 opBE(), opBF(), opC0(), opC1(), opC2(), opC3(), opC4(), opC5(), opC6(),
 opC7(), opC8(), opC9(), opCA(), opCB(), opCC(), opCD(), opCE(), opCF(),
 opD0(), opD1(), opD2(), opD3(), opD4(), opD5(), opD6(), opD7(), opD8(),
 opD9(), opDA(), opDB(), opDC(), opDD(), opDE(), opDF(), opE0(), opE1(),
 opE2(), opE3(), opE4(), opE5(), opE6(), opE7(), opE8(), opE9(), opEA(),
 opEB(), opEC(), opED(), opEE(), opEF(), opF0(), opF1(), opF2(), opF3(),
 opF4(), opF5(), opF6(), opF7(), opF8(), opF9(), opFA(), opFB(), opFC(),
 opFD(), opFE(), opFF(), op61dec(), op65dec(), op69dec(), op6Ddec(),
 op71dec(), op75dec(), op79dec(), op7Ddec(), opE1dec(), opE5dec(), opE9dec(),
 opEDdec(), opF1dec(), opF5dec(), opF9dec(), opFDdec() ;


