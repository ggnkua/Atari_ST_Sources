/*
   MagicTypes (M_TYPES.H)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MAGICTYP_
#define _MAGICTYP_

#if defined(__MINT__) && defined(__TURBOC__)
  #include <aes.h>
  #include <vdi.h>
  #include <osbind.h>
  #include <mintbind.h>
#else
#if !defined(__MINT__) && defined(__TURBOC__)
  #include <aes.h>
  #include <vdi.h>
  #include <tos.h>
#else
#if defined(__GNUC__)
  #define __TCC_COMPAT__
  #define cdecl __CDECL
  #include <aesbind.h>
  #include <vdibind.h>
  #include <osbind.h>
  #include <mintbind.h>
#else
#if defined(__MINT__) && defined(SOZOBON)
  #define  cdecl
  #include <xgemfast.h>
  /* #include <magic\m_colicn.h> */
  #include <osbind.h>
  #include <mintbind.h>
#else
#if !defined(__MINT__) && defined(SOZOBON)
  #define  cdecl
  #include <xgemfast.h>
  /* #include <magic\m_colicn.h> */
  #include <atari.h>
#endif
#endif
#endif
#endif
#endif

#define  MAXHANDLER     64
#define  MAXDIALS       16
#define  MAXVALUES      10

#ifdef __GNUC__
#define  CookieName     0x4D50524FL
#else
#define  CookieName     'MPRO'
#endif

#define  lBit0          1UL
#define  lBit1          (1UL << 1)
#define  lBit2          (1UL << 2)
#define  lBit3          (1UL << 3)
#define  lBit4          (1UL << 4)
#define  lBit5          (1UL << 5)
#define  lBit6          (1UL << 6)
#define  lBit7          (1UL << 7)
#define  lBit8          (1UL << 8)
#define  lBit9          (1UL << 9)
#define  lBit10         (1UL << 10)
#define  lBit11         (1UL << 11)
#define  lBit12         (1UL << 12)
#define  lBit13         (1UL << 13)
#define  lBit14         (1UL << 14)
#define  lBit15         (1UL << 15)
#define  lBit16         (1UL << 16)
#define  lBit17         (1UL << 17)
#define  lBit18         (1UL << 18)
#define  lBit19         (1UL << 19)
#define  lBit20         (1UL << 20)
#define  lBit21         (1UL << 21)
#define  lBit22         (1UL << 22)
#define  lBit23         (1UL << 23)
#define  lBit24         (1UL << 24)
#define  lBit25         (1UL << 25)
#define  lBit26         (1UL << 26)
#define  lBit27         (1UL << 27)
#define  lBit28         (1UL << 28)
#define  lBit29         (1UL << 29)
#define  lBit30         (1UL << 30)
#define  lBit31         (1UL << 31)

#define  EXCLUDE(Set,Bit) Set &= ~Bit
#define  INCLUDE(Set,Bit) Set |= Bit 

#define  BITSET         unsigned int
#define  LONGBITSET     unsigned long

#ifndef __BOOLEAN__
   typedef int BOOLEAN;
   #define __BOOLEAN__
#endif /* BOOLEAN */

#ifndef FALSE
   #define FALSE 0
   #define TRUE  1
#endif /* FALSE */

#ifndef MIN
   #define  MIN(x,y) ((x<y)?x:y)
   #define  MAX(x,y) ((x>y)?x:y)
#endif /* MIN */

typedef enum
{
/* Escape     */  Esc,      ShEsc,      CtrlEsc,      ShCtrlEsc,      AltEsc,      ShAltEsc,      CtrlAltEsc,      ShCtrlAltEsc,
/* 1 !        */  Char1,    Sh1,        Ctrl1,        ShCtrl1,        Alt1,        ShAlt1,        CtrlAlt1,        ShCtrlAlt1,
/* 2 "        */  Char2,    Sh2,        Ctrl2,        ShCtrl2,        Alt2,        ShAlt2,        CtrlAlt2,        ShCtrlAlt2,
/* 3 ›        */  Char3,    Sh3,        Ctrl3,        ShCtrl3,        Alt3,        ShAlt3,        CtrlAlt3,        ShCtrlAlt3,
/* 4 $        */  Char4,    Sh4,        Ctrl4,        ShCtrl4,        Alt4,        ShAlt4,        CtrlAlt4,        ShCtrlAlt4,
/* 5 %        */  Char5,    Sh5,        Ctrl5,        ShCtrl5,        Alt5,        ShAlt5,        CtrlAlt5,        ShCtrlAlt5,
/* 6 &        */  Char6,    Sh6,        Ctrl6,        ShCtrl6,        Alt6,        ShAlt6,        CtrlAlt6,        ShCtrlAlt6,
/* 7 /        */  Char7,    Sh7,        Ctrl7,        ShCtrl7,        Alt7,        ShAlt7,        CtrlAlt7,        ShCtrlAlt7,
/* 8 (        */  Char8,    Sh8,        Ctrl8,        ShCtrl8,        Alt8,        ShAlt8,        CtrlAlt8,        ShCtrlAlt8,
/* 9 )        */  Char9,    Sh9,        Ctrl9,        ShCtrl9,        Alt9,        ShAlt9,        CtrlAlt9,        ShCtrlAlt9,
/* 0 =        */  Char0,    Sh0,        Ctrl0,        ShCtrl0,        Alt0,        ShAlt0,        CtrlAlt0,        ShCtrlAlt0,
/* û ?        */  CharSS,   ShSS,       CtrlSS,       ShCtrlSS,       AltSS,       ShAltSS,       CtrlAltSS,       ShCtrlAltSS,
/* ' `        */  Quote,    ShQuote,    CtrlQuote,    ShCtrlQuote,    AltQuote,    ShAltQuote,    CtrlAltQuote,    ShCtrlAltQuote,
/* Backspace  */  Bs,       ShBs,       CtrlBs,       ShCtrlBs,       AltBs,       ShAltBs,       CtrlAltBs,       ShCtrlAltBs,
/* Tab        */  Tab,      ShTab,      CtrlTab,      ShCtrlTab,      AltTab,      ShAltTab,      CtrlAltTab,      ShCtrlAltTab,
/* q Q        */  CharQ,    ShQ,        CtrlQ,        ShCtrlQ,        AltQ,        ShAltQ,        CtrlAltQ,        ShCtrlAltQ,
/* w W        */  CharW,    ShW,        CtrlW,        ShCtrlW,        AltW,        ShAltW,        CtrlAltW,        ShCtrlAltW,
/* e E        */  CharE,    ShE,        CtrlE,        ShCtrlE,        AltE,        ShAltE,        CtrlAltE,        ShCtrlAltE,
/* r R        */  CharR,    Sh_R,       CtrlR,        ShCtrlR,        AltR,        ShAltR,        CtrlAltR,        ShCtrlAltR,
/* t T        */  CharT,    ShT,        CtrlT,        ShCtrlT,        AltT,        ShAltT,        CtrlAltT,        ShCtrlAltT,
/* z Z        */  CharZ,    ShZ,        CtrlZ,        ShCtrlZ,        AltZ,        ShAltZ,        CtrlAltZ,        ShCtrlAltZ,
/* u U        */  CharU,    ShU,        CtrlU,        ShCtrlU,        AltU,        ShAltU,        CtrlAltU,        ShCtrlAltU,
/* i I        */  CharI,    ShI,        CtrlI,        ShCtrlI,        AltI,        ShAltI,        CtrlAltI,        ShCtrlAltI,
/* o O        */  CharO,    ShO,        CtrlO,        ShCtrlO,        AltO,        ShAltO,        CtrlAltO,        ShCtrlAltO,
/* p P        */  CharP,    ShP,        CtrlP,        ShCtrlP,        AltP,        ShAltP,        CtrlAltP,        ShCtrlAltP,
/* Å ö   @ \  */  CharUE,   ShUE,       CtrlUE,       ShCtrlUE,       AltUE,       ShAltUE,       CtrlAltUE,       ShCtrlAltUE,
/* + *        */  Plus,     ShPlus,     CtrlPlus,     ShCtrlPlus,     AltPlus,     ShAltPlus,     CtrlAltPlus,     ShCtrlAltPlus,
/* Return     */  Return,   ShReturn,   CtrlReturn,   ShCtrlReturn,   AltReturn,   ShAltReturn,   CtrlAltReturn,   ShCtrlAltReturn,
/* Control    */  Scan29,   ShScan29,   CtrlScan29,   ShCtrlScan29,   AltScan29,   ShAltScan29,   CtrlAltScan29,   ShCtrlAltScan29,
/* a A        */  CharA,    ShA,        CtrlA,        ShCtrlA,        AltA,        ShAltA,        CtrlAltA,        ShCtrlAltA,
/* s S        */  CharS,    ShS,        CtrlS,        ShCtrlS,        AltS,        ShAltS,        CtrlAltS,        ShCtrlAltS,
/* d D        */  CharD,    ShD,        CtrlD,        ShCtrlD,        AltD,        ShAltD,        CtrlAltD,        ShCtrlAltD,
/* f F        */  CharF,    ShF,        CtrlF,        ShCtrlF,        AltF,        ShAltF,        CtrlAltF,        ShCtrlAltF,
/* g G        */  CharG,    ShG,        CtrlG,        ShCtrlG,        AltG,        ShAltG,        CtrlAltG,        ShCtrlAltG,
/* h H        */  CharH,    ShH,        CtrlH,        ShCtrlH,        AltH,        ShAltH,        CtrlAltH,        ShCtrlAltH,
/* j J        */  CharJ,    ShJ,        CtrlJ,        ShCtrlJ,        AltJ,        ShAltJ,        CtrlAltJ,        ShCtrlAltJ,
/* k K        */  CharK,    ShK,        CtrlK,        ShCtrlK,        AltK,        ShAltK,        CtrlAltK,        ShCtrlAltK,
/* l L        */  CharL,    Sh_L,       CtrlL,        ShCtrlL,        AltL,        ShAltL,        CtrlAltL,        ShCtrlAltL,
/* î ô   [ {  */  CharOE,   ShOE,       CtrlOE,       ShCtrlOE,       AltOE,       ShAltOE,       CtrlAltOE,       ShCtrlAltOE,
/* Ñ é   ] .  */  CharAE,   ShAE,       CtrlAE,       ShCtrlAE,       AltAE,       ShAltAE,       CtrlAltAE,       ShCtrlAltAE,
/* # ^        */  Number,   ShNumber,   CtrlNumber,   ShCtrlNumber,   AltNumber,   ShAltNumber,   CtrlAltNumber,   ShCtrlAltNumber,
/* L-Shift    */  Scan42,   ShScan42,   CtrlScan42,   ShCtrlScan42,   AltScan42,   ShAltScan42,   CtrlAltScan42,   ShCtrlAltScan42,
/* ~ |        */  Tilde,    ShTilde,    CtrlTilde,    ShCtrlTilde,    AltTilde,    ShAltTilde,    CtrlAltTilde,    ShCtrlAltTilde,
/* y Y        */  CharY,    ShY,        CtrlY,        ShCtrlY,        AltY,        ShAltY,        CtrlAltY,        ShCtrlAltY,
/* x X        */  CharX,    ShX,        CtrlX,        ShCtrlX,        AltX,        ShAltX,        CtrlAltX,        ShCtrlAltX,
/* c C        */  CharC,    ShC,        CtrlC,        ShCtrlC,        AltC,        ShAltC,        CtrlAltC,        ShCtrlAltC,
/* v V        */  CharV,    ShV,        CtrlV,        ShCtrlV,        AltV,        ShAltV,        CtrlAltV,        ShCtrlAltV,
/* b B        */  CharB,    ShB,        CtrlB,        ShCtrlB,        AltB,        ShAltB,        CtrlAltB,        ShCtrlAltB,
/* n N        */  CharN,    ShN,        CtrlN,        ShCtrlN,        AltN,        ShAltN,        CtrlAltN,        ShCtrlAltN,
/* m M        */  CharM,    ShM,        CtrlM,        ShCtrlM,        AltM,        ShAltM,        CtrlAltM,        ShCtrlAltM,
/* , ;        */  Colon,    ShColon,    CtrlColon,    ShCtrlColon,    AltColon,    ShAltColon,    CtrlAltColon,    ShCtrlAltColon,
/* . :        */  Point,    ShPoint,    CtrlPoint,    ShCtrlPoint,    AltPoint,    ShAltPoint,    CtrlAltPoint,    ShCtrlAltPoint,
/* - _        */  Minus,    ShMinus,    CtrlMinus,    ShCtrlMinus,    AltMinus,    ShAltMinus,    CtrlAltMinus,    ShCtrlAltMinus,
/* R-Shift    */  Scan54,   ShScan54,   CtrlScan54,   ShCtrlScan54,   AltScan54,   ShAltScan54,   CtrlAltScan54,   ShCtrlAltScan54,
/*  nicht da  */  Scan55,   ShScan55,   CtrlScan55,   ShCtrlScan55,   AltScan55,   ShAltScan55,   CtrlAltScan55,   ShCtrlAltScan55,
/* Alternate  */  Scan56,   ShScan56,   CtrlScan56,   ShCtrlScan56,   AltScan56,   ShAltScan56,   CtrlAltScan56,   ShCtrlAltScan56,
/*            */  Space,    ShSpace,    CtrlSpace,    ShCtrlSpace,    AltSpace,    ShAltSpace,    CtrlAltSpace,    ShCtrlAltSpace,
/* Capslock   */  Scan58,   ShScan58,   CtrlScan58,   ShCtrlScan58,   AltScan58,   ShAltScan58,   CtrlAltScan58,   ShCtrlAltScan58,
/* F1         */  F1,       ShF1,       CtrlF1,       ShCtrlF1,       AltF1,       ShAltF1,       CtrlAltF1,       ShCtrlAltF1,
/* F2         */  F2,       ShF2,       CtrlF2,       ShCtrlF2,       AltF2,       ShAltF2,       CtrlAltF2,       ShCtrlAltF2,
/* F3         */  F3,       ShF3,       CtrlF3,       ShCtrlF3,       AltF3,       ShAltF3,       CtrlAltF3,       ShCtrlAltF3,
/* F4         */  F4,       ShF4,       CtrlF4,       ShCtrlF4,       AltF4,       ShAltF4,       CtrlAltF4,       ShCtrlAltF4,
/* F5         */  F5,       ShF5,       CtrlF5,       ShCtrlF5,       AltF5,       ShAltF5,       CtrlAltF5,       ShCtrlAltF5,
/* F6         */  F6,       ShF6,       CtrlF6,       ShCtrlF6,       AltF6,       ShAltF6,       CtrlAltF6,       ShCtrlAltF6,
/* F7         */  F7,       ShF7,       CtrlF7,       ShCtrlF7,       AltF7,       ShAltF7,       CtrlAltF7,       ShCtrlAltF7,
/* F8         */  F8,       ShF8,       CtrlF8,       ShCtrlF8,       AltF8,       ShAltF8,       CtrlAltF8,       ShCtrlAltF8,
/* F9         */  F9,       ShF9,       CtrlF9,       ShCtrlF9,       AltF9,       ShAltF9,       CtrlAltF9,       ShCtrlAltF9,
/* F10        */  F10,      ShF10,      CtrlF10,      ShCtrlF10,      AltF10,      ShAltF10,      CtrlAltF10,      ShCtrlAltF10,
/*  nicht da  */  Scan69,   ShScan69,   CtrlScan69,   ShCtrlScan69,   AltScan69,   ShAltScan69,   CtrlAltScan69,   ShCtrlAltScan69,
/*  nicht da  */  Scan70,   ShScan70,   CtrlScan70,   ShCtrlScan70,   AltScan70,   ShAltScan70,   CtrlAltScan70,   ShCtrlAltScan70,
/* Clr/Home   */  Clr,      ShClr,      CtrlClr,      ShCtrlClr,      AltClr,      ShAltClr,      CtrlAltClr,      ShCtrlAltClr,
/* Cursor Up  */  Up,       ShUp,       CtrlUp,       ShCtrlUp,       AltUp,       ShAltUp,       CtrlAltUp,       ShCtrlAltUp,
/*  nicht da  */  Scan73,   ShScan73,   CtrlScan73,   ShCtrlScan73,   AltScan73,   ShAltScan73,   CtrlAltScan73,   ShCtrlAltScan73,

/* NumBlock - */  NumMinus, ShNumMinus, CtrlNumMinus, ShCtrlNumMinus, AltNumMinus, ShAltNumMinus, CtrlAltNumMinus, ShCtrlAltNumMinus,
/* Curs Left  */  Left,     ShLeft,     CtrlLeft,     ShCtrlLeft,     AltLeft,     ShAltLeft,     CtrlAltLeft,     ShCtrlAltLeft,
/*  nicht da  */  Scan76,   ShScan76,   CtrlScan76,   ShCtrlScan76,   AltScan76,   ShAltScan76,   CtrlAltScan76,   ShCtrlAltScan76,
/* Curs Right */  Right,    ShRight,    CtrlRight,    ShCtrlRight,    AltRight,    ShAltRight,    CtrlAltRight,    ShCtrlAltRight,
/* NumBlock + */  NumPlus,  ShNumPlus,  CtrlNumPlus,  ShCtrlNumPlus,  AltNumPlus,  ShAltNumPlus,  CtrlAltNumPlus,  ShCtrlAltNumPlus,
/*  nicht da  */  Scan79,   ShScan79,   CtrlScan79,   ShCtrlScan79,   AltScan79,   ShAltScan79,   CtrlAltScan79,   ShCtrlAltScan79,
/* Curs  Down */  Down,     ShDown,     CtrlDown,     ShCtrlDown,     AltDown,     ShAltDown,     CtrlAltDown,     ShCtrlAltDown,
/*  nicht da  */  Scan81,   ShScan81,   CtrlScan81,   ShCtrlScan81,   AltScan81,   ShAltScan81,   CtrlAltScan81,   ShCtrlAltScan81,
/* Insert     */  Ins,      ShIns,      CtrlIns,      ShCtrlIns,      AltIns,      ShAltIns,      CtrlAltIns,      ShCtrlAltIns,
/* Delete     */  Del,      ShDel,      CtrlDel,      ShCtrlDel,      AltDel,      ShAltDel,      CtrlAltDel,      ShCtrlAltDel,
/* Shift-F1   */  Scan84,   ShScan84,   CtrlScan84,   ShCtrlScan84,   AltScan84,   ShAltScan84,   CtrlAltScan84,   ShCtrlAltScan84,
/* Shift-F2   */  Scan85,   ShScan85,   CtrlScan85,   ShCtrlScan85,   AltScan85,   ShAltScan85,   CtrlAltScan85,   ShCtrlAltScan85,
/* Shift-F3   */  Scan86,   ShScan86,   CtrlScan86,   ShCtrlScan86,   AltScan86,   ShAltScan86,   CtrlAltScan86,   ShCtrlAltScan86,
/* Shift-F4   */  Scan87,   ShScan87,   CtrlScan87,   ShCtrlScan87,   AltScan87,   ShAltScan87,   CtrlAltScan87,   ShCtrlAltScan87,
/* Shift-F5   */  Scan88,   ShScan88,   CtrlScan88,   ShCtrlScan88,   AltScan88,   ShAltScan88,   CtrlAltScan88,   ShCtrlAltScan88,
/* Shift-F6   */  Scan89,   ShScan89,   CtrlScan89,   ShCtrlScan89,   AltScan89,   ShAltScan89,   CtrlAltScan89,   ShCtrlAltScan89,
/* Shift-F7   */  Scan90,   ShScan90,   CtrlScan90,   ShCtrlScan90,   AltScan90,   ShAltScan90,   CtrlAltScan90,   ShCtrlAltScan90,
/* Shift-F8   */  Scan91,   ShScan91,   CtrlScan91,   ShCtrlScan91,   AltScan91,   ShAltScan91,   CtrlAltScan91,   ShCtrlAltScan91,
/* Shift-F9   */  Scan92,   ShScan92,   CtrlScan92,   ShCtrlScan92,   AltScan92,   ShAltScan92,   CtrlAltScan92,   ShCtrlAltScan92,
/* Shift-F10  */  Scan93,   ShScan93,   CtrlScan93,   ShCtrlScan93,   AltScan93,   ShAltScan93,   CtrlAltScan93,   ShCtrlAltScan93,
/*  nicht da  */  Scan94,   ShScan94,   CtrlScan94,   ShCtrlScan94,   AltScan94,   ShAltScan94,   CtrlAltScan94,   ShCtrlAltScan94,
/*  nicht da  */  Scan95,   ShScan95,   CtrlScan95,   ShCtrlScan95,   AltScan95,   ShAltScan95,   CtrlAltScan95,   ShCtrlAltScan95,
/* < >        */  Small,    ShSmall,    CtrlSmall,    ShCtrlSmall,    AltSmall,    ShAltSmall,    CtrlAltSmall,    ShCtrlAltSmall,
/* Undo       */  Undo,     ShUndo,     CtrlUndo,     ShCtrlUndo,     AltUndo,     ShAltUndo,     CtrlAltUndo,     ShCtrlAltUndo,
/* Help       */  Help,     ShHelp,     CtrlHelp,     ShCtrlHelp,     AltHelp,     ShAltHelp,     CtrlAltHelp,     ShCtrlAltHelp,
/* NumBlock ( */  LBracket, ShLBracket, CtrlLBracket, ShCtrlLBracket, AltLBracket, ShAltLBracket, CtrlAltLBracket, ShCtrlAltLBracket,
/* NumBlock ) */  RBracket, ShRBracket, CtrlRBracket, ShCtrlRBracket, AltRBracket, ShAltRBracket, CtrlAltRBracket, ShCtrlAltRBracket,
/* NumBlock / */  Slash,    ShSlash,    CtrlSlash,    ShCtrlSlash,    AltSlash,    ShAltSlash,    CtrlAltSlash,    ShCtrlAltSlaSh,
/* NumBlock * */  Asteric,  ShAsteric,  CtrlAsteric,  ShCtrlAsteric,  AltAsteric,  ShAltAsteric,  CtrlAltAsteric,  ShCtrlAltAsteric,
/* NumBlock 7 */  Num7,     ShNum7,     CtrlNum7,     ShCtrlNum7,     AltNum7,     ShAltNum7,     CtrlAltNum7,     ShCtrlAltNum7,
/* NumBlock 8 */  Num8,     ShNum8,     CtrlNum8,     ShCtrlNum8,     AltNum8,     ShAltNum8,     CtrlAltNum8,     ShCtrlAltNum8,
/* NumBlock 9 */  Num9,     ShNum9,     CtrlNum9,     ShCtrlNum9,     AltNum9,     ShAltNum9,     CtrlAltNum9,     ShCtrlAltNum9,
/* NumBlock 4 */  Num4,     ShNum4,     CtrlNum4,     ShCtrlNum4,     AltNum4,     ShAltNum4,     CtrlAltNum4,     ShCtrlAltNum4,
/* NumBlock 5 */  Num5,     ShNum5,     CtrlNum5,     ShCtrlNum5,     AltNum5,     ShAltNum5,     CtrlAltNum5,     ShCtrlAltNum5,
/* NumBlock 6 */  Num6,     ShNum6,     CtrlNum6,     ShCtrlNum6,     AltNum6,     ShAltNum6,     CtrlAltNum6,     ShCtrlAltNum6,
/* NumBlock 1 */  Num1,     ShNum1,     CtrlNum1,     ShCtrlNum1,     AltNum1,     ShAltNum1,     CtrlAltNum1,     ShCtrlAltNum1,
/* NumBlock 2 */  Num2,     ShNum2,     CtrlNum2,     ShCtrlNum2,     AltNum2,     ShAltNum2,     CtrlAltNum2,     ShCtrlAltNum2,
/* NumBlock 3 */  Num3,     ShNum3,     CtrlNum3,     ShCtrlNum3,     AltNum3,     ShAltNum3,     CtrlAltNum3,     ShCtrlAltNum3,
/* NumBlock 0 */  Num0,     ShNum0,     CtrlNum0,     ShCtrlNum0,     AltNum0,     ShAltNum0,     CtrlAltNum0,     ShCtrlAltNum0,
/* NumBlock . */  NumPoint, ShNumPoint, CtrlNumPoint, ShCtrlNumPoint, AltNumPoint, ShAltNumPoint, CtrlAltNumPoint, ShCtrlAltNumPoint,
/* Enter      */  Enter,    ShEnter,    CtrlEnter,    ShCtrlEnter,    AltEnter,    ShAltEnter,    CtrlAltEnter,    ShCtrlAltEnter,
/*  nicht da  */  Scan115,  ShScan115,  CtrlScan115,  ShCtrlScan115,  AltScan115,  ShAltScan115,  CtrlAltScan115,  ShCtrlAltScan115,
/*  nicht da  */  Scan116,  ShScan116,  CtrlScan116,  ShCtrlScan116,  AltScan116,  ShAltScan116,  CtrlAltScan116,  ShCtrlAltScan116,
/*  nicht da  */  Scan117,  ShScan117,  CtrlScan117,  ShCtrlScan117,  AltScan117,  ShAltScan117,  CtrlAltScan117,  ShCtrlAltScan117,
/*  nicht da  */  Scan118,  ShScan118,  CtrlScan118,  ShCtrlScan118,  AltScan118,  ShAltScan118,  CtrlAltScan118,  ShCtrlAltScan118,
/*  nicht da  */  Scan119,  ShScan119,  CtrlScan119,  ShCtrlScan119,  AltScan119,  ShAltScan119,  CtrlAltScan119,  ShCtrlAltScan119,
/* Alt-1      */  Scan120,  ShScan120,  CtrlScan120,  ShCtrlScan120,  AltScan120,  ShAltScan120,  CtrlAltScan120,  ShCtrlAltScan120,
/* Alt-2      */  Scan121,  ShScan121,  CtrlScan121,  ShCtrlScan121,  AltScan121,  ShAltScan121,  CtrlAltScan121,  ShCtrlAltScan121,
/* Alt-3      */  Scan122,  ShScan122,  CtrlScan122,  ShCtrlScan122,  AltScan122,  ShAltScan122,  CtrlAltScan122,  ShCtrlAltScan122,
/* Alt-4      */  Scan123,  ShScan123,  CtrlScan123,  ShCtrlScan123,  AltScan123,  ShAltScan123,  CtrlAltScan123,  ShCtrlAltScan123,
/* Alt-5      */  Scan124,  ShScan124,  CtrlScan124,  ShCtrlScan124,  AltScan124,  ShAltScan124,  CtrlAltScan124,  ShCtrlAltScan124,
/* Alt-6      */  Scan125,  ShScan125,  CtrlScan125,  ShCtrlScan125,  AltScan125,  ShAltScan125,  CtrlAltScan125,  ShCtrlAltScan125,
/* Alt-7      */  Scan126,  ShScan126,  CtrlScan126,  ShCtrlScan126,  AltScan126,  ShAltScan126,  CtrlAltScan126,  ShCtrlAltScan126,
/* Alt-8      */  Scan127,  ShScan127,  CtrlScan127,  ShCtrlScan127,  AltScan127,  ShAltScan127,  CtrlAltScan127,  ShCtrlAltScan127,
/* Alt-9      */  Scan128,  ShScan128,  CtrlScan128,  ShCtrlScan128,  AltScan128,  ShAltScan128,  CtrlAltScan128,  ShCtrlAltScan128,
/* Alt-0      */  Scan129,  ShScan129,  CtrlScan129,  ShCtrlScan129,  AltScan129,  ShAltScan129,  CtrlAltScan129,  ShCtrlAltScan129,
/* Alt-û      */  Scan130,  ShScan130,  CtrlScan130,  ShCtrlScan130,  AltScan130,  ShAltScan130,  CtrlAltScan130,  ShCtrlAltScan130,
/* Alt-'      */  Scan131,  ShScan131,  CtrlScan131,  ShCtrlScan131,  AltScan131,  ShAltScan131,  CtrlAltScan131,  ShCtrlAltScan131,
/*  nicht da  */  Scan132,  ShScan132,  CtrlScan132,  ShCtrlScan132,  AltScan132,  ShAltScan132,  CtrlAltScan132,  ShCtrlAltScan132,
/* Nada       */  NullChar
} tKey;

typedef  unsigned char  KeyMap[NullChar + 1];
typedef  KeyMap*  PtrKeyMap;

typedef struct _EventParameter
{
   int      id;
   BITSET   mstatus;    /* Maustastenstatus         */
   int      mx,
            my,         /* Mausposition             */
            mklicks;    /* Anzahl Klicks            */

   tKey     kcode;      /* mpKeyboard-Tastenkode    */
   int      ktaste,     /* AES-Tastenkode           */
            kscan;      /* Scancode                 */
   char     kascii;     /* Ascii-Kode               */
   BITSET   kstatus;    /* Sondertastenstatus       */
   int      mesag[8];   /* Messagebuffer            */
   int      stepin;     /* TRUE = Rechteck betreten */
   int      ready;
   void     *app;
   BITSET   res1;
   BITSET   res2;
   int      res3;
} EventParameter;

typedef EventParameter* PtrEP;

typedef  void  (*HandleEvent)(PtrEP);

typedef  struct {
   int   x1,y1,
         x2,y2,
         x3,y3,
         x4,y4,
         x5,y5,
         x6,y6,
         x7,y7,
         x8,y8;
} tPxyRect;

typedef struct
{
   void  (*proc)(void *p);
   int   used;
} HdlStruc;

typedef struct
{
   void  (*proc)(void *p);
   long  time;
   long  elapsed;
   int   used;
} TimerStruc;

typedef struct
{
   void  (*proc)(void *p);
   GRECT rect;
   int   drin;
   int   used;
} RectStruc;

typedef struct
{
   int   *contrl;
   int   *intin;
   int   *ptsin;
   int   *intout;
   int   *ptsout;
} VdiPB;

typedef struct
{
   int   *cb_pcontrol;
   int   *cb_pglobal;
   int   *cb_pintin;
   int   *cb_pintout;
   long  *cb_paddrin;
   long  *cb_paddrout;
} AesPB;

typedef struct
{
   int   IntIn[17];
   long  LongIn[16];
   void* AddrIn[16];
   int   IntOut[17];
   long  LongOut[16];
   void* AddrOut[16];
} MagicPB;

typedef struct _DialStack
{
   int      stackptr;
   int      max;
   OBJECT   *dials[MAXDIALS];
} DialStack;

typedef DialStack* PtrDialstack;

/* Konstanten fÅr flags in dem Typ 'Application' */
#define  AppGesperrt    1L
#define  EndDispatch    2L
#define ScreenLocked 4L
#define  ScreenControl  8L
#define  MapNblock      16L

/*--- Struktur des Cookies -----------------------------------------*/
typedef  void  cdecl (*tDispatcher)(long f,void *p);

typedef  int   ColorTable[6][2][6];

typedef  ColorTable* tColortable;

typedef enum {
   fkHelp,        /* Helpbutton auslîsen       */
   fkUndo,        /* UndoButton auslîsen       */
   fkEscape,      /* EscapeButton auslîsen     */
   fkHistory,     /* History durchlaufen       */
   fkSearch,      /* History durchsuchen       */
   fkCutClip,     /* Zeile ausschneiden        */
   fkCopyClip,    /* Zeile auf Clip kopieren   */
   fkPasteClip,   /* Clipboard lesen           */
   fkSelectAll,   /* Alles selektieren         */
   fkSelectStart, /* Blockstart setzen         */
   fkCycleWin,    /* Fenster cyclen            */
   fkCloseWin,    /* Fenster schliessen        */
   fkFullWin,     /* Fenster auf volle Grîûe   */
   fkLineup,      /* Zeile nach oben rollen    */
   fkPageup,      /* Seite nach oben rollen    */
   fkTopdoc,      /* Zum Anfang des Dokuments  */
   fkLinedown,    /* Zeile nach unten rollen   */
   fkPagedown,    /* Seite nach unten rollen   */
   fkBottomdoc,   /* Zum Ende des Dokuments    */
   fkLineleft,    /* Spalte nach links rollen  */
   fkPageleft,    /* Seite nach links rollen   */
   fkLeftdoc,     /* Zur ersten Spalte.        */
   fkLineright,   /* Spalte nach rechts rollen */
   fkPageright,   /* Seite nach rechts rollen  */
   fkRightdoc     /* Zur letzten Spalte        */
} tFKeys;

typedef  int         FKeytable[22];
typedef  FKeytable*  tFKeytable;

typedef enum {
   vWinsize,    /* Sizearea-Breite                      */
   vPopdelay,   /* Delay bei Popups                     */
   vDropdelay,  /* Delay bei Drop-Circlebuttons         */
   vMintid,     /* ID des Kernels unter MiNT            */
   vMagixTask,  /* Zeit die Magic auf MagiX wartet      */
   vNumTasks,   /* Anzahl der bei Magic gemeldeten Apps */
   vRes7,
   vRes8,
   vRes9,
   vRes10
} tValues;

typedef  int   Valuetable[10];
typedef int*   tValuetable;

typedef struct _TheConfig
{
   int         version;     /* Versionsnummer                */
   BITSET      deadkeys;    /* Daten Åber die DeadKeys       */
   LONGBITSET  flags;       /* Flags siehe unten             */
   tDispatcher dispatcher;  /* Einsprung in MAGIC.PRG        */
   char        *path;       /* Pfad fÅr Magic.PRG            */
   tColortable colortable;  /* Zeiger auf Button-Farbtabelle */
   tFKeytable  fkeytable;   /* Zeiger auf die Standardtasten */
   tValuetable valuetable;  /* Zeiger auf Werte-Tabelle      */
   void        *actapp;     /* Zeiger auf den App-Block      */
   char        *help;       /* Default-Helpprogramm          */
   char        *tlpath;     /* Pfad fÅr MagicTools           */
   void        *res1;
   void        *res2;
   void        *res3;
   void        *res4;
   void        *res5;
} TheConfig;

typedef  TheConfig* PtrConfig;

/* Flags bei WORKSTATION.Flags */

#define wsPhysical     1
#define wsFontsloaded  2
#define wsReserved1    4

typedef struct WORKSTATION
{
   int        Handle;
   LONGBITSET Flags;
   int        MaxWidth;           /* workout[ 0] */
   int        MaxHeight;          /* workout[ 1] */
   int        Devicecoord;        /* workout[ 2] */
   int        PixelWidth;         /* workout[ 3] */
   int        PixelHeight;        /* workout[ 4] */
   int        FontHeights;        /* workout[ 5] */
   int        LineTypes;          /* workout[ 6] */
   int        LineWidth;          /* workout[ 7] */
   int        MarkerTypes;        /* workout[ 8] */
   int        MarkerSize;         /* workout[ 9] */
   int        SystemFonts;        /* workout[10] */
   int        PatternTypes;       /* workout[11] */
   int        HatchTypes;         /* workout[12] */
   int        DefColors;          /* workout[13] */
   int        GDPFunctions;       /* workout[14] */
   int        GDP01;              /* workout[15] */
   int        GDP02;              /* workout[16] */
   int        GDP03;              /* workout[17] */
   int        GDP04;              /* workout[18] */
   int        GDP05;              /* workout[19] */
   int        GDP06;              /* workout[20] */
   int        GDP07;              /* workout[21] */
   int        GDP08;              /* workout[22] */
   int        GDP09;              /* workout[23] */
   int        GDP10;              /* workout[24] */
   int        GDPAttrib01;        /* workout[25] */
   int        GDPAttrib02;        /* workout[26] */
   int        GDPAttrib03;        /* workout[27] */
   int        GDPAttrib04;        /* workout[28] */
   int        GDPAttrib05;        /* workout[29] */
   int        GDPAttrib06;        /* workout[30] */
   int        GDPAttrib07;        /* workout[31] */
   int        GDPAttrib08;        /* workout[32] */
   int        GDPAttrib09;        /* workout[33] */
   int        GDPAttrib10;        /* workout[34] */
   int        ColorPossible;      /* workout[35] */
   int        TextRotPossible;    /* workout[36] */
   int        AreaFillPossible;   /* workout[37] */
   int        CellArrayPossible;  /* workout[38] */
   int        MaxColors;          /* workout[39] */
   int        CursorControl;      /* workout[40] */
   int        ValuatorControl;    /* workout[41] */
   int        ChoiceControl;      /* workout[42] */
   int        AlphaControl;       /* workout[43] */
   int        InOutType;          /* workout[44] */
   int        MinCharWidth;       /* workout[45] */
   int        MinCharHeight;      /* workout[46] */
   int        MaxCharWidth;       /* workout[47] */
   int        MaxCharHeight;      /* workout[48] */
   int        MinLineWidth;       /* workout[49] */
   int        MaxLineWidth;       /* workout[51] */
   int        MinMarkerWidth;     /* workout[53] */
   int        MinMarkerHeight;    /* workout[54] */
   int        MaxMarkerWidth;     /* workout[55] */
   int        MaxMarkerHeight;    /* workout[56] */
    /* Extended Inquire  */
   int        ScreenType;         /* workout[ 0] */
   int        BackgroundColors;   /* workout[ 1] */
   BITSET     Texteffects;        /* workout[ 2] */
   int        Upsizing;           /* workout[ 3] */
   int        Bitplanes;          /* workout[ 4] */
   int        LookupTable;        /* workout[ 5] */
   int        RasterOps;          /* workout[ 6] */
   int        ContourFill;        /* workout[ 7] */
   int        TextRotation;       /* workout[ 8] */
   int        WriteModes;         /* workout[ 9] */
   int        InputModes;         /* workout[10] */
   int        TextJustification;  /* workout[11] */
   int        PencilChange;       /* workout[12] */
   int        ColorChange;        /* workout[13] */
   int        MaxCoordPairs;      /* workout[14] */
   int        MaxIntin;           /* workout[15] */
   int        MaxMouseButtons;    /* workout[16] */
   int        FatLineTypes;       /* workout[17] */
   int        FatLineModes;       /* workout[18] */
   int        Clipping;           /* workout[19] */
   int        ClipLeftX;          /* workout[45] */
   int        ClipLeftY;          /* workout[46] */
   int        ClipRightX;         /* workout[47] */
   int        ClipRightY;         /* workout[48] */
   void       *Reserved1;         /* Nicht benutzen!!!  */
   void       *Reserved2;         /* Nicht benutzen!!!  */
   void       *Reserved3;         /* Nicht benutzen!!!  */
   int        DeviceNum;
   char       Name[256];
} WORKSTATION;

typedef WORKSTATION* PtrWS;

typedef struct {
   int      max;
   long     values[MAXVALUES];
} AppValues;

typedef AppValues* PtrAppValues;

typedef struct
{
   int            max;
   BITSET         events;
   BITSET         disabled;
   int            prioKeybd;
   int            prioButton;
   int            prioMesag;
   int            prioTimer;
   EventParameter parablock;
   HdlStruc       keybd[MAXHANDLER];
   HdlStruc       button[MAXHANDLER];
   HdlStruc       mesag[MAXHANDLER];
   HdlStruc       moved[MAXHANDLER];
   TimerStruc     timer[MAXHANDLER];
   RectStruc      rects[MAXHANDLER];
} tHandlerList;

typedef tHandlerList* PtrHandlerList;

typedef  void  (*EmergencyProc)(void);

typedef struct _application
{
   AesPB           *AESParaBlk;
   VdiPB           *VDIParaBlk;
   MagicPB         *MAGICParaBlk;
   PtrHandlerList  Handler;
   void            *Dials;
   void            *Alert;
   PtrDialstack    Stack;
   void            *Windows;
   void            *TopWindow;
   void            *TextWindow;
   void            *TopTextwin;
   CICONBLK        *ApplIcon;
   void            *reserved;
   void            *MainMenu;
   void            *Menus;
   void            *Popups;
   void            *Rsc;
   PtrWS           Workstations;
   void            *TermProc;
   void            *Name;
   PtrAppValues    Values;
   PtrKeyMap       Keyboard;
   LONGBITSET      flags;
   long            Ident;
   long            errcode;
   long            wucount;
   void            *Reserved1;
   void            *Reserved2;
   void            *Reserved3;
   void            *Reserved4;
   EmergencyProc   UserEmergency;
   struct _application  *Next;
} Application;

typedef  Application* PtrApp;

typedef enum
{
   Screen,
   Plotter,
   Printer,
   Metafile,
   Camera,
   Tablett,
   Memory,
   dev71_80,
   dev81_90,
   dev91_99
} Device;

/* Flags bei TheCookie.flags: */
#define cfConfig       lBit0   /* Config-Dial zulassen                    */
#define cfSolid        lBit1   /* Solide Verschieben                      */
#define cfClip         lBit2   /* GEM-Clipboard benutzen                  */
#define cfDeadkey      lBit3   /* Deadkeys im Edit benutzen               */
#define cfCenter       lBit4   /* Dialog zentrieren                       */
#define cfMouse        lBit5   /* Dialog an Mouseposition                 */
#define cfPos          lBit6   /* Dialog an letzter Position              */
#define cfGrowbox      lBit7   /* Grow-/Shrinkboxen                       */
#define cf3DButtons    lBit8   /* Buttons im 3D-Look and Feel             */
#define cfWinDials     lBit9   /* Dialog im Fenster gewÅnscht             */
#define cfWinAlerts    lBit10  /* Alle Alerts in Fenstern                 */
#define cfButtonLeft   lBit11  /* Alertbuttons LinksbÅndig                */
#define cfButtonRight  lBit12  /* Alertbuttons RechtsbÅndig               */
#define cfAltIcon      lBit13  /* Alternative Icons verwenden             */
#define cfAllSize      lBit14  /* Fenster an allen Ecken und Kanten sizen */
#define cfAllMove      lBit15  /* Fenster an allen Ecken und Kanten moven */
#define cfPopClick     lBit16  /* Popups durch klicken wÑhlen/verlassen   */
#define cfIconpos      lBit17

typedef enum
{
   DkCircum,      /* ^ */
   DkTilde,       /* ~ */
   DkAgui,        /* ' */
   DkGrave,       /* ` */
   DkQuote,       /* " */
   DkSmoere,      /* ¯ */
   DkCedil,       /* , */
   DkSlash        /* / */
} DeadKeys;

typedef struct _FONTHDR
{
   int      fontId;
   int      point;
   char     name[32];
   int      firstAde;
   int      lastAde;
   int      top;
   int      ascent;
   int      half;
   int      descent;
   int      bottom;
   int      maxCharwidth;
   int      maxCellwidth;
   int      leftOffset;
   int      rightOffset;
   int      thicken;
   int      ulSize;
   int      lighten;
   int      skew;
   BITSET   flags;
   char     *horTable;
   int      *offTable;
   void     *datTable;
   int      formWidth;
   int      formHeight;
   struct   _FONTHDR   *PtrFONTHDR;
} FONTHDR;

typedef  FONTHDR* PtrFONTHDR;

typedef struct
{
   long     RESERVED6;
   FONTHDR  *CURFONT;
   int      RESERVED5[24];
   int      MPOSHX;
   int      MPOSHY;
   int      MPLANES;
   int      MCDBBG;
   int      MCDBFG;
   int      MASKFORM[32];
   int      INQTAB[45];
   int      DEVTAB[45];
   int      GCURX;
   int      GCURY;
   int      MHIDCT;
   int      MOUSEBT;
   int      REQCOL[48];
   int      SIZTAB[15];
   int      RESERVED4[2];
   void     *CURWORK;
   FONTHDR  *DEFFONT;
   void     *(FONTRING[4]);
   int      FONTCOUNT;
   int      RESERVED3[45];
   char     CURMSSTAT;
   char     RESERVED2;
   int      VHIDCNT;
   int      CURX;
   int      CURY;
   char     CURFLAG;
   char     MOUSEFLAG;
   long     RESERVED1;
   int      VSAVXY[2];
   int      SAVELEN;
   void     *SAVEADDR;
   BITSET   SAVESTAT;
   long     SAVEAREA[64];
   void     *USERTIM;
   void     *NEXTTIM;
   void     *USERBUT;
   void     *USERCUR;
   void     *USERMOT;
   int      VCELHT;
   int      VCELMX;
   int      VCELMY;
   int      VCELWR;
   int      VCOLBG;
   int      VCOLFG;
   void     *VCURAD;
   int      VCUROF;
   int      VCURXY[2];
   char     VPERIOD;
   char     VCURCT;
   void     *VFNTAD;
   int      VFNTND;
   int      VFNTST;
   int      VFNTWD;
   int      VREZHZ;
   void     *VOFFAD;
   int      RESERVED;
   int      VREZVT;
   int      BYTESLIN;
} VDIESCVars;

typedef VDIESCVars* PtrVDIESC;

#endif
