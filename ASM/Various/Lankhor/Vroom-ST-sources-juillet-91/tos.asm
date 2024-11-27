            NOLIST
*
* TOS TRAPS (19 Sep 87)
*
* TRAP #1  = GEMDOS
* TRAP #13 = BIOS
* TRAP #14 = XBIOS
*
* TOS TRAP #1 Calls
*
TERM        EQU      $00         Terminate Program
CREATE      EQU      $3C
OPEN        EQU      $3D         Open File
CLOSE       EQU      $3E         Close File
READ        EQU      $3F         Read File
WRITE       EQU      $40         Write File
*
* BIOS TRAP #13 Calls
*
*
* XBIOS TRAP #14 Calls
*
SETSCREEN   EQU      $5          Set Screen Address
SETPALETTE  EQU      $6          Set Palette
IKBDWS      EQU      $19         Xmit KB Command
JDISINT     EQU      $1A         MFT Disable Interrupt
KBDVBASE    EQU      $22         Get KB Vector Base
WVBL        EQU      $25         Wait Next VBL
*
* Generic TOS Call
*
TOS         MACRO                Tos TRAP #1
            MOVE     #\1,-(A7)
            TRAP     #\2
            ENDM
*
            LIST
