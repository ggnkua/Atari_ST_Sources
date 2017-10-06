********************************************************************************
*
*  Project name : NORMALIZED KEY CODE CONVERTER (NKCC)
*  Header name  : Global definitions
*  Symbol prefix: nkc
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : -
*-------------------------------------------------------------------------------
*  Things to do : -
*
*-------------------------------------------------------------------------------
*  History:
*
*  1990:
*     May 23-24/26: creation of file
*     Jul 09: nkc_kstate()
*     Aug 03: nkc_cmp();NK_MASK
*     Sep 15: BE_...
*     Sep 16: nkc_timer()
*     Oct 03: nkc_vlink()/vunlink(); NKXM_...
*     Oct 07: removing NK_MASK (use nkc_cmp() for key code comparism!)
*     Oct 13: NK_LEFT and NK_RIGHT exchanged
*     Dec 11: MU_XTIMER
*  1991:
*     Apr 13: nkc_conv() renamed to nkc_tconv()
*             nkc_gconv()
*     May 29: nkc_toupper, nkc_tolower
*     Aug 22: NKS_DEADKEY changed
*             NKS_D_...
*     Aug 26: NK_INVALID
*     Sep 07: NK_TERM
*     Sep 14: NKF?_IGNUM
*     Nov 16: NKS?_CTRL
*     Dec 29: NK_RVD...
*             source documentation syntax now in extra file
*  1992:
*     Jan 03: redefining BE_...
*             NKI_...
*             first parameter of nkc_init() is now of type 'unsigned long'
*     Feb 28: NKCOWNPB switch
*  1993:
*     Dec 11: new file header
*             keys NKCNOGEM and NKCOWNPB replaced by key NKCGEM
*     Dec 12: new: nkc_n2tos, nkc_n2gem
*  1995:
*     Nov 09: some of the reserved key codes are defined now; they are used for
*              the additional keys on the Macintosh keyboard
*
********************************************************************************
*KEY _NAME="Global NKCC definitions (assembly language)"
*END



*START
****************************************************************************
*                         ASSEMBLER CONTROL SECTION                        *
****************************************************************************

*KEY &NKCGEM
*     define this symbol on the assembler's command line
*     =0    create TOS-version of NKCC (without GEM part)
*     =1    create GEM-version of NKCC
*
* For details consult the header of the file NKCC.S

*END
*KEY _END



****************************************************************************
*                                  IMPORT                                  *
****************************************************************************

                                             ; functions
               .globl   nkc_init             ; init NKCC
               .globl   nkc_exit             ; exit NKCC
               .globl   nkc_set              ; set special key flags
               .globl   nkc_conin            ; NKCC key input via GEMDOS
               .globl   nkc_cstat            ; console input status via GEMDOS
               .globl   nkc_tconv            ; TOS key code converter
               .globl   nkc_gconv            ; GEM key code converter
               .globl   nkc_n2tos            ; NKC to TOS key code converter
               .globl   nkc_n2gem            ; NKC to GEM key code converter
               .globl   nkc_kstate           ; return shift key state
               .globl   nkc_timer            ; return 200 Hz system clock
               .globl   nkc_cmp              ; compare two key codes
               .globl   nkc_vlink            ; link function to XBRA vector list
               .globl   nkc_vunlink          ; unlink function from XBRA list
               .globl   nkc_toupper          ; convert character to upper case
               .globl   nkc_tolower          ; convert character to lower case

               .if      NKCGEM=1

                .globl  nkc_multi            ; NKCC multi event handler
                .globl  nkc_amulti           ; multi event, assembler binding
                .globl  nkc_contrl           ; GEM parameter arrays
                .globl  nkc_intin
                .globl  nkc_intout
                .globl  nkc_adrin
                .globl  nkc_adrout
                .globl  nkc_ptsin
                .globl  nkc_ptsout

               .endif   ; .if NKCGEM=1



****************************************************************************
*                                 EQUATES                                  *
****************************************************************************

*              flags for NKCC initialization

NKIb_BUTHND    =        0                    ; install button event handler
NKIb_BHTOS     =        1                    ; additional flag: only if TOS has
                                             ;  mouse click bug
NKIb_NO200HZ   =        2                    ; don't install 200 Hz clock
                                             ;  interrupt (this flag is ignored
                                             ;  if the button event handler is
                                             ;  being activated)

NKIf_BUTHND    =        $00000001
NKIf_BHTOS     =        $00000002
NKIf_NO200HZ   =        $00000004



*              flag combinations for compatibility with old versions of NKCC

BE_ON          =        NKIf_BUTHND
BE_OFF         =        0
BE_TOS         =        (NKIf_BUTHND|NKIf_BHTOS)



*              flags for special key code handling

NKSb_ALTNUM    =        0                    ; Alt + numeric pad -> ASCII
NKSb_CTRL      =        1                    ; Control key emulation
                                             ; deadkey management:
NKSb_D_CIRCUM  =        16                   ; ^  accent circumflex
NKSb_D_TILDE   =        17                   ; ~  accent tilde
NKSb_D_AGUI    =        18                   ; '  accent agui
NKSb_D_GRAVE   =        19                   ; `  accent grave
NKSb_D_UMLAUT  =        20                   ; ¹  umlaut
NKSb_D_QUOTE   =        21                   ; "  quote, synonym for umlaut
NKSb_D_SMOERE  =        22                   ; ø  smoerebroed
NKSb_D_CEDIL   =        23                   ; ,  cedil
NKSb_D_SLASH   =        24                   ; /  slash, for scandinavian chars

NKSf_ALTNUM    =        $00000001
NKSf_CTRL      =        $00000002
NKSf_D_CIRCUM  =        $00010000
NKSf_D_TILDE   =        $00020000
NKSf_D_AGUI    =        $00040000
NKSf_D_GRAVE   =        $00080000
NKSf_D_UMLAUT  =        $00100000
NKSf_D_QUOTE   =        $00200000
NKSf_D_SMOERE  =        $00400000
NKSf_D_CEDIL   =        $00800000
NKSf_D_SLASH   =        $01000000

NKSf_DEADKEY   =        $ffff0000            ; all deadkeys



*              NKCC key flags

NKFb_FUNC      =        15                   ; function
NKFb_RESVD     =        14                   ; reserved, ignore it!
NKFb_NUM       =        13                   ; numeric pad
NKFb_CAPS      =        12                   ; CapsLock
NKFb_ALT       =        11                   ; Alternate
NKFb_CTRL      =        10                   ; Control
NKFb_LSH       =        9                    ; left Shift key
NKFb_RSH       =        8                    ; right Shift key

NKFb_IGNUM     =        NKFb_RESVD           ; special flag for nkc_cmp()

NKFf_FUNC      =        $8000
NKFf_RESVD     =        $4000
NKFf_NUM       =        $2000
NKFf_CAPS      =        $1000
NKFf_ALT       =        $0800
NKFf_CTRL      =        $0400
NKFf_LSH       =        $0200
NKFf_RSH       =        $0100

NKFf_IGNUM     =        NKFf_RESVD

NKFf_SHIFT     =        $0300                ; both shift keys



* Special key codes for keys performing a function

NK_INVALID     =        $00                  ; invalid key code
NK_UP          =        $01                  ; cursor up
NK_DOWN        =        $02                  ; cursor down
NK_RIGHT       =        $03                  ; cursor right
NK_LEFT        =        $04                  ; cursor left
NK_M_PGUP      =        $05                  ; Mac: page up
NK_M_PGDOWN    =        $06                  ; Mac: page down
NK_M_END       =        $07                  ; Mac: end
NK_BS          =        $08                  ; Backspace
NK_TAB         =        $09                  ; Tab
NK_ENTER       =        $0a                  ; Enter
NK_INS         =        $0b                  ; Insert
NK_CLRHOME     =        $0c                  ; Clr/Home
NK_RET         =        $0d                  ; Return
NK_HELP        =        $0e                  ; Help
NK_UNDO        =        $0f                  ; Undo
NK_F1          =        $10                  ; function key #1
NK_F2          =        $11                  ; function key #2
NK_F3          =        $12                  ; function key #3
NK_F4          =        $13                  ; function key #4
NK_F5          =        $14                  ; function key #5
NK_F6          =        $15                  ; function key #6
NK_F7          =        $16                  ; function key #7
NK_F8          =        $17                  ; function key #8
NK_F9          =        $18                  ; function key #9
NK_F10         =        $19                  ; function key #10
NK_M_F11       =        $1a                  ; Mac: function key #11
NK_ESC         =        $1b                  ; Esc
NK_M_F12       =        $1c                  ; Mac: function key #12
NK_M_F14       =        $1d                  ; Mac: function key #14
NK_RVD1E       =        $1e                  ; reserved!
NK_DEL         =        $1f                  ; Delete

                                             ; terminator for key code tables
NK_TERM        =        (NKFf_FUNC|NK_INVALID)



* ASCII codes less than 32

NUL            =        $00                  ; Null
SOH            =        $01                  ; Start Of Header
STX            =        $02                  ; Start Of Text
ETX            =        $03                  ; End Of Text
EOT            =        $04                  ; End Of Transmission
ENQ            =        $05                  ; Enquiry
ACK            =        $06                  ; positive Acknowledgement
BEL            =        $07                  ; Bell
BS             =        $08                  ; BackSpace
HT             =        $09                  ; Horizontal Tab
LF             =        $0a                  ; Line Feed
VT             =        $0b                  ; Vertical Tab
FF             =        $0c                  ; Form Feed
CR             =        $0d                  ; Carriage Return
SO             =        $0e                  ; Shift Out
SI             =        $0f                  ; Shift In
DLE            =        $10                  ; Data Link Escape
DC1            =        $11                  ; Device Control 1
XON            =        $11                  ; XON: same as DC1
DC2            =        $12                  ; Device Control 2
DC3            =        $13                  ; Device Control 3
XOFF           =        $13                  ; XOFF: same as DC3
DC4            =        $14                  ; Device Control 4
NAK            =        $15                  ; Negative Acknowledgement
SYN            =        $16                  ; Synchronize
ETB            =        $17                  ; End of Transmission Block
CAN            =        $18                  ; Cancel
EM             =        $19                  ; End of Medium
SUB            =        $1a                  ; Substitute
ESC            =        $1b                  ; Escape
FS             =        $1c                  ; Form Separator
GS             =        $1d                  ; Group Separator
RS             =        $1e                  ; Record Separator
US             =        $1f                  ; Unit Separator



* XBRA vector link/unlink modes

NKXM_NUM       =        0                    ; by vector number
NKXM_ADR       =        1                    ; by vector address



* additional flag in event mask

MU_XTIMER      =        $100


* End Of File
