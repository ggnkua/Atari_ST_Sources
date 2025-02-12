********************************************************************************
*
*  Project name : NORMALIZED KEY CODE CONVERTER (NKCC)
*  Module name  : Main module
*  Symbol prefix: nkc
*
*  Author       : Harald Siegmund (HS)
*  Co-Authors   : -
*  Write access : HS
*
*  Notes        : The symbol NKCGEM will have to be defined on the assembler's
*                 command line when translating the source of NKCC. Set its
*                 value to 1 if you like to create the complete version. A value
*                 of 0 will supress inclusion of the GEM part, making NKCC a few
*                 KBytes smaller. Some functions and the GEM parameter arrays
*                 are not available then.
*
*                 Translate this source with the MadMac assembler:
*                 mac -dNKCGEM=1 -onkcc.o nkcc.s
*                 mac -dNKCGEM=0 -onkcc_tos.o nkcc.s
*
*-------------------------------------------------------------------------------
*  NKCC was developed with Atari's MadMac assembler. It should be possible to
*  adapt the source to different assemblers with minor effort. Here's an
*  overview of all MadMac-specific assembly directives used in this source file:
*
*  .globl         declares a symbol to be imported from another module
*                  respectively exported from the current source (depending if
*                  the symbol is defined in the source or not)
*  .if <expr>     conditional assembly; <expr> is tested to be non-zero (true)
*                 or zero (false)
*  .else
*  .endif
*  =              equate
*  .abs           absolute section; is usually used to defined structure
*                  offsets. Labels in the absolute section get a constant
*                  value and usually have a .ds directive in their opcode
*                  field incrementing the value for the next label
*  .macro         introduces a macro definition
*  .endm          ends a macro definition
*
*  Macros:
*   .macro name [argument,argument,...]
*   Arguments accesses inside the macro must have a backslash character
*    (e.g. move   \argument1,d0)
*   The expression  \?{argument}  tests if an argument is defined or not.
*
*  Symbols:
*   MadMac supports local symbols with a limited scope. Their name starts with
*   a period (.) and their scope ends at the next global symbol (in both
*   directions).
*
*-------------------------------------------------------------------------------
*  Things to do :
*
*  -  NKCC will support additional (and more complex) deadkeys some time, such
*     like Arabian ones. A communication interface between NKCC and a text
*     editor will be built in for that purpose (Arabian languages' deadkeys can
*     affect existing text!).
*
*-------------------------------------------------------------------------------
*  History:
*
*  1989:
*     May 14: creation of file (NKCC 1.00)
*     Jun 07/15-16/19/21/Jul 11: improvements, changes, debugging
*  1990:
*     Jan 13: global functions now available in two versions:
*             parameters passed via registers (e.g. for Turbo C)
*             parameters passed via stack (underscore before label name)
*
*     May 23-24/26-28: creation of NKCC 2.00 (almost every function rewritten)
*     Jun 16/27: assembler-entry added by Gerd Knops
*     Jun 30/Jul 02: return shift key flags in nkc_multi()/amulti() as NKF?_...
*     Jul 09: nkc_kstate()
*     Aug 03: nkc_cmp()
*     Aug 18: fatal bug in nkc_kstate() fixed
*     Sep 15: nkc_timer()
*     Sep 15-17/30: own button event handler
*     Oct 03: debugging
*             nkc_vlink()/vunlink()
*             documentation syntax changed (LRef/XRef removed; Reg: changed)
*     Oct 05: debugging mouse button handler (problems with menu bar)
*     Oct 07: Control/Alternate + character always returns capital characters
*             changing key code comparism rules in nkc_cmp()
*     Oct 22: debugging nkc_cmp() (did sometimes recognize unique key codes)
*             debugging ASCII code input in nkc_amulti()
*     Dec 11/15/17: MU_XTIMER
*  1991:
*     Jan 11: don't call AES with set MU_XTIMER flag
*     Mar 31: ensure that evnt_multi() parameters are restored when being
*             corrupted by a bug in AES!!
*     Apr 01: debugging
*     Apr 13: nkc_conv() renamed to nkc_tconv()
*     Apr 13-14: nkc_gconv()
*     May 10: debugging (nk_beend())
*     May 29: debugging (double shift key compare)
*             export nkc_toupper and nkc_tolower
*     Jul 05: completing history
*     Jul 31: version number before XBRA header
*     Aug 06: " is now a deadkey!
*     Aug 07: more deadkeys...
*     Aug 22: deadkeys can now be enabled/disabled separately
*             nkc_set() changed
*             nkc_init() returns version #
*             bug fixed: nkc_cmp() corrupted high words of D3 and D4
*     Sep 07/14: nkc_cmp() improved; NKF?_RESVD now in use
*     Nov 05: adjustments to ASCII input feature of TOS 3.06
*     Nov 16: bug fixed in nkc_cmp() mechanism
*             Control key emulation
*     Dec 29: small corrections and extensions of the documentation
*             source documentation syntax now in extra file
*  1992:
*     Jan 03: changing documentation of nkc_init()
*             revising info lines in function headers
*     Jan 12: adjusting nkc_init() to its new documentation!
*             appending .b respectively .l to all instructions with a default
*              operand size which is not .w
*             changing macro XBRA_HD
*     Feb 11: adjusting button event handler to MINT
*     Feb 28: NKCOWNPB switch
*  1993:
*     Dec 11: merging the two existing NKCC versions to one source:
*             - version number set to $0290
*             - NKCNOGEM/NKCOWNPB keys replaced by NKCGEM key
*             - NKCC uses its own AES/VDI parameter arrays now
*             - nkc_init() gets one more parameter: ^AES global array
*             - nkc_toupper and nkc_tolower are functions now
*             - dynamic double click time
*             - MU_MESAG occured -> don't create self-made button events
*     Dec 12: GEM keyboard events: try to get original shift flags from the
*              Iorec buffer
*             new functions: nkc_n2tos() and nkc_n2gem()
*     Dec 13: debugging: ! operator changed to ~ in nk_bestart
*             implementing nkc_n2tos()
*             size of GEM parameter arrays changed to 32 (larger than required
*              but better too big than too small!)
*     Dec 16: debugging nkc_n2tos()
*     Dec 19: improving nkc_gconv() (scan code translation table)
*             debugging nkc_n2tos()
*             cosmetic changes
*     Dec 23: debugging nkc_vunlink(): return status was garbage!
*  1994:
*     May 19: release 2.91:
*             don't restore conterm (it may be changed by another process in
*              the meantime)
*             new deadkeys (/2 /4)
*             adding overview of used MadMac directives in the note section of
*              the file header
*     Jun 27: release 2.92:
*             check for illegal scan codes (e.g. $ff under Mag!x)
*
********************************************************************************
*KEY _NAME="NKCC"
*END

VERSION        =     $0292                   ; NKCC's version #


*START
****************************************************************************
*                         ASSEMBLER CONTROL SECTION                        *
****************************************************************************

*KEY &NKCGEM
*     define this symbol on the assembler's command line
*     =0    create TOS-version of NKCC (without GEM part)
*     =1    create GEM-version of NKCC

               .include "nkcc.sh"            ; NKCC definitions
*END
*KEY _END



*START
****************************************************************************
*                                  EXPORT                                  *
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
*END



****************************************************************************
*                                  EQUATES                                 *
****************************************************************************

                                             ; AES event mask bits
MU_KEYBD       =        $0001                ; keyboard
MU_BUTTON      =        $0002                ; mouse button clicks
MU_M1          =        $0004                ; mouse movement #1
MU_M2          =        $0008                ; mouse movement #2
MU_MESAG       =        $0010                ; message
MU_TIMER       =        $0020                ; timer

conterm        =        $484                 ; .B: system key flags
_hz_200        =        $4ba                 ; .L: 200 Hz system clock
_sysbase       =        $4f2                 ; .L: ^OS header

TIME_ADD       =        20                   ; wait time to add on each click
                                             ;  in 1/200 s (-> 100 ms)


****************************************************************************
*                             ABSOLUTE SECTION                             *
****************************************************************************

               .abs                          ; button event info block

BI_BSTATE:     .ds.w    1                    ; requested button state
BI_BMASK:      .ds.w    1                    ; requested button mask
BI_REVCOND:    .ds.w    1                    ; event condition reverse flag
BI_MAXCLICKS:  .ds.w    1                    ; max # of clicks to wait for
BI_DCLTIME:    .ds.w    1                    ; AES double click time
BI_BMODE:      .ds.w    1                    ; button handler mode (see
                                             ;  function nk_butvec)
BI_SBSTATE:    .ds.w    1                    ; button state at start of event
BI_PRVBSTATE:  .ds.w    1                    ; previous button state
BI_NCLICKS:    .ds.w    1                    ; # of mouse clicks
BI_DCBUT:      .ds.w    1                    ; double click button mask
BI_DCSTATE:    .ds.w    1                    ; double click button state
BI_BENDTIME:   .ds.l    1                    ; button event timer end value
BI_BEVALID:    .ds.b    1                    ; flag: button event valid
BI_CVALID:     .ds.b    1                    ; flag: button condition valid
BI_LOCK:       .ds.b    1                    ; flag: button event locked
               .even
BI:                                          ; size


               .abs                          ; IOREC structure

IBUF:          .ds.l    1                    ; ^base of I/O buffer
IBUFSIZ:       .ds.w    1                    ; size of buffer in bytes
IBUFHD:        .ds.w    1                    ; head-pointer (offset to last
                                             ;  used read position
IBUFTL:        .ds.w    1                    ; tail-pointer (offset to last
                                             ;  used write position
IBUFLO:        .ds.w    1                    ; low water mark
IBUFHI:        .ds.w    1                    ; high water mark
IOREC:                                       ; size



****************************************************************************
*                                  MACROS                                  *
****************************************************************************

****************************************************************************
*
* LWDIVU: divide long value <da> by word value <db>, use <dt> for temp storage
*
* - the result will be stored as LONGword in <da>
* - <db> stays unchanged
* - <da> and <dt> must be data registers
*
****************************************************************************

               .macro   LWDIVU .db,.da,.dt

               move.l   \.da,\.dt            ; copy long-value
               clr      \.dt                 ; clear its low word
               swap     \.dt                 ; dt.w = high word of long-value
               divu     \.db,\.dt            ; high word / word-value
               swap     \.da                 ; long-value, low and high swapped
               move     \.dt,\.da            ; da.w = result of high/word-value
               swap     \.da                 ; da.w = low word of long-value
               move     \.da,\.dt            ; remainder and low-word
               divu     \.db,\.dt            ; divide by word-value
               move     \.dt,\.da            ; so we get low word of result

               .endm



****************************************************************************
*
* XBRA_HD: XBRA header for NKCC functions
*
* The following structure is stored at the current memory location:
*
* VERSION.L       NKCC's version # (actually not a part of a standard XBRA
*                 header; may be checked in future versions)
* "XBRA".L        magic longword
* "NKCC".L        NKCC's XBRA-ID
* oldvec.L        initial value of buffer for old vector content (passed as
*                 macro parameter); if not defined, the default 0 is used
*
****************************************************************************

               .macro   XBRA_HD .oldvec

               .dc.l    VERSION              ; version number
               .dc.b    "XBRA"               ; XBRA header
               .dc.b    "NKCC"               ; ID

               .if      \?{.oldvec}          ; oldvec defined?

               .dc.l    \.oldvec             ; use it

               .else                         ; else:

               .dc.l    0                    ; use default

               .endif

               .endm



****************************************************************************
*                            LOCAL TEXT SECTION                            *
****************************************************************************

               .text

****************************************************************************
*
*  nk_gci: GEMDOS console character input
*  #
*
*  This function returns when
*
*     a) either any key is pressed or
*     b) the Alternate key is released
*
*  The Alternate check can be suppressed by setting the input parameter in
*  D0.W to zero. The routine works then just as a "get key" function.
*
*  In:   D0.W           Alternate key check flag:
*                       zero = don't check it
*                       non-zero = do Alternate check
*
*  Out:  D0.W           key code in normalized format
*                       for details see nkc_tconv()
*        D1.W           flag:
*                       zero = D0.W not valid; Alternate was released
*                       non-zero = D1.W valid; Alternate still pressed
*                          (also returned when Alternate check supressed)
*        CCR            set according content of D1.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U***....     ****....   =D1.W
*
****************************************************************************

nk_gci:        move     d0,d3                ; Alternate check flag
               beq.s    .getkey              ; no check? just get key

               move.l   pshift,a3            ; ^shift key state

.loop:         btst.b   #3,(a3)              ; Alternate still pressed?
               beq.s    .abort               ; no->

               move     #11,-(sp)            ; Cconis: get key input status
               trap     #1                   ; Gemdos
               addq     #2,sp                ; clean stack

               tst      d0                   ; any key pressed?
               beq.s    .loop                ; no->

.getkey:       move     #7,-(sp)             ; Crawcin: get key
               trap     #1                   ; Gemdos
               addq     #2,sp                ; clean stack
               bsr      nkc_tconv            ; convert key code
               moveq.l  #-1,d1               ; flag: key code valid
               rts                           ; bye

.abort:        moveq.l  #0,d1                ; flag: key code not valid
               rts                           ; bye



****************************************************************************
*
*  nk_spec: special key code handling
*  #
*
*  nk_spec() performs the special key handling defined by <sflags> (deadkey
*  management, ASCII code input, Control key emulation).
*
*  In:   D0.W           key code in normalized format
*                       for details see nkc_tconv()
*        A0.L           ^function which gets new key codes and checks
*                       the Alternate key state
*                       For the calling conventions consult nk_gci() or
*                       nk_mci(). The function MUST NOT modify the CPU
*                       registers D5-D7 and A5-A6.
*
*  Out:  D0.W           (new) key code in normalized format
*        CCR            set according contents of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U*******     *******.   =D0.W
*
****************************************************************************

nk_spec:       move.l   a0,a6                ; save ^function
               btst.b   #NKSb_ALTNUM,sflags + 3 ; ASCII input enabled?
               beq.s    .ctrlkey             ; no->


*------------- ASCII input

               moveq.l  #0,d6                ; reset digit counter
               moveq.l  #0,d5                ; reset ASCII code
               bra.s    .isdigit             ; check if valid key

.notvalid:     tst      d6                   ; key not valid; first one?
               beq.s    .ctrlkey             ; yes-> exit

.getkey:       move     d0,d7                ; save previous key code
               moveq.l  #-1,d0               ; check Alternate
               jsr      (a6)                 ; get key
               beq.s    .makeascii           ; Alternate released? abort loop

.isdigit:      move     d0,d1                ; key code
               and      #NKFf_NUM | NKFf_ALT,d1 ; isolate flags
               cmp      #NKFf_NUM | NKFf_ALT,d1 ; with Alternate and numeric?
               bne.s    .notvalid            ; no->

               cmp.b    #'0',d0              ; must be in range from 0 ...
               blo.s    .notvalid

               cmp.b    #'9',d0              ; ... to 9
               bhi.s    .notvalid

               mulu     #10,d5               ; new digit in ASCII code
               sub      #'0',d0              ; ASCII->number
               add      d0,d5                ; add new digit
               addq     #1,d6                ; count digits
               cmp      #3,d6                ; 3rd digit added?
               bne.s    .getkey              ; no-> next key

.makeascii:    move     d7,d0                ; previous key code
               and      #NKFf_CAPS,d0        ; isolate CapsLock flag
               move.b   d5,d0                ; add key code (ASCII)


*------------- Control key emulation

.ctrlkey:      btst.b   #NKSb_CTRL,sflags + 3   ; enabled?
               beq.s    .deadkey             ; no ->

               btst.l   #NKFb_CTRL,d0        ; Control flag set?
               beq.s    .deadkey             ; no ->

               btst.l   #NKFb_ALT,d0         ; Alternate flag set?
               bne.s    .deadkey             ; yes ->

               cmp.b    #$40,d0              ; check ASCII code
               blo.s    .deadkey             ; too low ->

               cmp.b    #$5f,d0              ; check again
               bhi.s    .deadkey             ; too high ->

                                             ; clear function and Control flags
               and      #~(NKFf_FUNC|NKFf_CTRL),d0
               sub.b    #$40,d0              ; new ASCII code


*------------- check if key = deadkey

.deadkey:      tst      d0                   ; function key?
               bmi.s    .ret                 ; yes-> no deadkey

               lea      deadtab,a0           ; ^deadkey table
               move     sflags,d4            ; deadkey flags
               beq.s    .exit                ; no deadkeys at all->

.finddead:     move     (a0)+,d2             ; get option flag mask
               beq.s    .exit                ; end of table-> no deadkey

               move     (a0)+,d1             ; get key code
               addq     #4,a0                ; skip ^match table
               and      d4,d2                ; is this deadkey enabled?
               beq.s    .finddead            ; no ->

               cmp.b    d0,d1                ; deadkey found?
               bne.s    .finddead            ; no->


*------------- key is dead key, get second key and merge them

               move.l   -4(a0),a5            ; ^deadkey match table
               move     d0,-(sp)             ; save key code
               clr      d0                   ; no Alternate check
               jsr      (a6)                 ; get second key
               move     sflags,-(sp)         ; save deadkey flags
               clr      sflags               ; disable deadkeys temporary
               move.l   a6,a0                ; do ASCII input/ctrl key check
               bsr      nk_spec              ; by calling myself!

               move     (sp)+,sflags         ; restore deadkey flags
               move     (sp)+,d7             ; restore first key code
               tst      d0                   ; function key?
               bmi.s    .nomatch             ; yes-> doesn't match with deadkey

.findmatch:    move     (a5)+,d1             ; merged and second key code
               beq.s    .nomatch             ; end of table->

               cmp.b    d0,d1                ; second key code found?
               bne.s    .findmatch           ; no->

               lsr      #8,d1                ; yes: merged code in .B
               and      #NKFf_CAPS,d0        ; clear all except CapsLock
               move.b   d1,d0                ; CapsLock flag + merged key
               bra.s    .exit                ; exit

.nomatch:      move     d0,prvkey            ; save second key
               st.b     prvvalid             ; set validation flag
               move     d7,d0                ; return first key

.ret:          rts                           ; bye

.exit:         tst      d0                   ; set CCR
               rts                           ; bye



****************************************************************************
*
*  nk_ascmatch: check if ASCII code matches with one from the key code tables
*  # R
*
*  This functions proofs, if D0.B equals to D4.B, D5.B or D6.B. An according
*  flag is returned. The flag bytes in the TOS key code D0.L are modified
*  depending on which code matches.
*
*  In:   D0.L           key code in TOS format
*        D4.B           ASCII code from unshifted key table
*        D5.B           ASCII code from shifted key table
*        D6.B           ASCII code from CapsLock key table
*
*  Out:  D0.L           key code in TOS format
*                       (updated flags in upper byte)
*
*        CCR            EQ: ASCII code was found
*                       NE: ASCII code wan't found
*
*  Reg:  D:01234567   A:01234567   CCR
*          U......*     ........   flag (see above)
*
****************************************************************************

nk_ascmatch:   tst.b    d0                   ; zero?
               bne.s    .comp                ; no ->

               move.l   d0,d7                ; copy key code
                                             ; Alt/Control already found out?
               and.l    #(NKFf_ALT|NKFf_CTRL)<<16,d7
               bne.s    .unknown             ; yes ->

.comp:         cmp.b    d4,d0                ; unshifted?
               bne.s    .shftst              ; no ->

               cmp.b    d6,d0                ; in CapsLock table, too?
               beq.s    .exit                ; yes ->

               bclr.l   #NKFb_CAPS+16,d0     ; no: cannot be CapsLock
               bra.s    .exit                ; ->

.shftst:       cmp.b    d5,d0                ; shifted?
               bne.s    .cpstst              ; no ->

               cmp.b    d6,d0                ; in CapsLock table, too?
               bne.s    .shifted             ; no ->

               btst.l   #NKFb_CAPS+16,d0     ; CapsLock active?
               bne.s    .exit                ; yes -> it COULD be generated
                                             ;  by pressing Shift, but we
                                             ;  assume CapsLock

.shifted:      or.l     #NKFf_SHIFT<<16,d0   ; shifted: set both shift flags
               bra.s    .exit                ; ->

.cpstst:       cmp.b    d6,d0                ; in CapsLock table?
               bne.s    .unknown             ; no ->

               bset.l   #NKFb_CAPS+16,d0     ; yes: set CapsLock flag

.exit:         moveq.l  #0,d7                ; found
               rts

.unknown:      moveq.l  #1,d7                ; not found
               rts



****************************************************************************
*
*  nk_findscan: find scan code
*  # R
*
*  The
*
*  In:   D0.W           normalized key code
*        A0.L           ^base of system's key code table
*
*  Out:  D1.W           found scan code (0 = not found)
*        CCR            set according contents of D1.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          .W......     *.......   =D1
*
****************************************************************************

nk_findscan:   btst.l   #NKFb_NUM,d0         ; on numeric keypad?
               beq.s    .search              ; no ->

               move     #$4a,d1              ; yes: try all numeric keypad
               cmp.b    (a0,d1),d0           ;  scan codes first
               beq.s    .found               ; it matches ->

               move     #$4e,d1
               cmp.b    (a0,d1),d0
               beq.s    .found

               move     #$63,d1              ; block starts at $63

.numsearch:    cmp.b    (a0,d1),d0           ; match?
               beq.s    .found               ; yes ->

               addq     #1,d1                ; next scan code
               cmp      #$73,d1              ; block end at $72
               blo.s    .numsearch           ; continue search ->

.search:       move     #1,d1                ; start with first valid scan code

.mainsearch:   cmp.b    (a0,d1),d0           ; match?
               beq.s    .found               ; yes ->

               addq.b   #1,d1                ; next scan code
               cmp.b    #$78,d1              ; $78 = last valid scan code
               blo.s    .mainsearch          ; continue search ->

               moveq.l  #0,d1                ; not found
               rts

.found:        tst      d1                   ; found; set CCR
               rts



               .if      NKCGEM=1

****************************************************************************
*
*  nk_bioscode: convert GEM key code to GEMDOS/BIOS format
*  # R
*
*  This is a simple converter which takes key codes in AES format (two
*  words) and transforms them to the BIOS key format (one longword).
*
*  In:   D0.W           key code
*                       high byte = scan code, low byte = ASCII code
*        D1.W           shift key state flags
*                       Bit 0: right Shift
*                       Bit 1: left Shift
*                       Bit 2: Control
*                       Bit 3: Alternate
*
*  Out:  D0.L           key code in BIOS format
*                       for details see nkc_tconv()
*
*  Reg:  D:01234567   A:01234567   CCR
*          U*......     *.......    *
*
****************************************************************************

nk_bioscode:   swap     d0                   ; key code in high word
               move     d1,d0                ; shift key state
               move.l   pshift,a0            ; ^shift key state system variable
               move.b   (a0),d1              ; get it
               and      #~NKFf_CAPS,d1       ; isolate CapsLock flag
               or       d1,d0                ; merge with other shift flags
               swap     d0                   ; shift state in high word
               lsl.l    #8,d0                ; move 'em up
               lsr      #8,d0                ; now key code in BIOS format
               rts                           ; bye



****************************************************************************
*
*  nk_real_shift: try to get original shift flags of a key code
*  #
*
*  This function uses the contents of the Iorec keyboard ring buffer to
*  restore the original shift flag byte of a key code which has been
*  transported through AES' event manager and thus stripped off its
*  flag byte.
*
*  In:   D0.L           key code in TOS format
*                       for details see nkc_tconv()
*
*  Out:  D0.L           updated key code in TOS format
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     *.......    *
*
****************************************************************************

nk_real_shift: move.l   kbdiorec,a0          ; ^keyboard's I/O record
               movem.l  d3/d4,-(sp)          ; save registers
               move     IBUFHD(a0),d1        ; head pointer
               move     IBUFTL(a0),d2        ; tail pointer
               move     iohead,d3            ; NKCC's head pointer


*------------- check if tail pointer has overrun NKCC's head pointer

               cmp      d1,d2                ; tail < head?
               blo.s    .tlwrap              ; yes -> it has been wrapped around

               cmp      d3,d1                ; my tail between record's
               bhs.s    .search              ;  head and tail?

               cmp      d2,d3                ; if so, tail has overrun my
               blo.s    .reset               ;  head -> reset

               bra.s    .search              ; no overrun ->

.tlwrap:       cmp      d2,d3                ; my tail below wrapped record's
               blo.s    .reset               ;  tail pointer or above head?

               cmp      d3,d1                ; then tail has overrun my
               blo.s    .reset               ;  head -> reset


*------------- find key code in ring buffer

.search:       move     IBUFSIZ(a0),d2       ; buffer size
               move.l   IBUF(a0),a0          ; ^base of buffer
               move.l   d0,d4                ; copy key code
               swap     d4                   ; scan code in low byte of d4
               bra.s    .find2               ; ->

.find:         addq     #4,d3                ; advance to next read-position
               cmp      d2,d3                ; wrap around?
               blo.s    .getkey              ; no ->

               moveq.l  #0,d3                ; yes: wrap

.getkey:       cmp.b    3(a0,d3),d0          ; compare ASCII code
               bne.s    .find2               ; doesn't match ->

               cmp.b    1(a0,d3),d4          ; compare scan code
               bne.s    .find2               ; doesn't match ->

               move.l   (a0,d3),d0           ; found: get complete key code
               bra.s    .exit                ; ->

.find2:        cmp      d1,d3                ; my head has reached buffer's head
               bne.s    .find                ; no ->

.reset:        move     d1,d3                ; reset head pointer

.exit:         move     d3,iohead            ; save new head pointer
               movem.l  (sp)+,d3/d4          ; restore registers
               rts                           ; bye



****************************************************************************
*
*  nk_mci: multi event console character input
*  # U
*
*  This function returns when
*
*     a) either any key is pressed or
*     b) the Alternate key is released
*
*  The Alternate check can be suppressed by setting the input parameter in
*  D0.W to zero. The routine works then just as a "get key" function.
*
*  In:   D0.W           Alternate key check flag:
*                       zero = don't check it
*                       non-zero = do Alternate check
*
*  Out:  D0.W           key code in normalized format
*                       for details see nkc_tconv()
*        D1.W           flag:
*                       zero = D0.W not valid; Alternate was released
*                       non-zero = D1.W valid; Alternate still pressed
*                          (also returned when Alternate check supressed)
*        CCR            set according content of D1.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U***....     ****....   =D1.W
*
****************************************************************************

nk_mci:        move     d0,d3                ; save Alternate check flag
               move.l   pshift,a3            ; ^shift key state variable

.loop:         lea      nkc_contrl,a0        ; ^control array
               move     #25,(a0)+            ; opcode
               move     #16,(a0)+            ; size of intin
               move     #7,(a0)+             ; size of intout
               move     #1,(a0)+             ; size of addrin
               clr      (a0)                 ; size of addrout

               lea      nkc_intin,a0         ; ^intin array
               move     #MU_TIMER|MU_KEYBD,(a0) ; wait for timer and key strokes
               clr.l    7*4(a0)              ; waiting time: 0 ms = minimum!

               move     #200,d0              ; opcode for AES
               move.l   #aespb,d1            ; ^AES parameter block
               trap     #2                   ; call GEM

               lea      nkc_intout,a0        ; ^intout array
               move     (a0),d0              ; event mask
               move.b   (a3),d1              ; shift key state
               and      #$f,d1               ; clear unused bits
               move     #MU_KEYBD,d2         ; did keyboard event occur?
               and      d0,d2                ; check bit
               bne.s    .keybd               ; yes->

               move.l   kbdiorec,a1          ; ^keyboard's I/O record
               move     IBUFHD(a1),iohead    ; reset NKCC's head pointer
               tst      d3                   ; do Alternate check?
               beq.s    .loop                ; no->

               btst.l   #3,d1                ; Alternate still pressed?
               bne.s    .loop                ; yes->

               moveq.l  #0,d1                ; Alternate released: abort
               rts

.keybd:        move     10(a0),d0            ; key code
               bsr      nk_bioscode          ; convert to BIOS keycode
               bsr      nk_real_shift        ; try to get original shift flags
               bsr      nkc_tconv            ; convert to normalized format
               moveq.l  #1,d1                ; key code is valid
               rts                           ; bye



****************************************************************************
*
*  nk_gemtrap: GEM trap handler
*  # S T2
*
*  This function is linked to the GEM trap vector at initialization time.
*  It waits for evnt_dclick() calls (get/set double click time) and saves
*  new click times in an own buffer.
*
*  In:   D0.W           opcode:
*                       115 = VDI
*                       200 = AES
*        A0.L           AES/VDI parameter block
*
*  Out:  -
*
*  Reg:  D:01234567   A:01234567   CCR
*          ..*.....     **......    *
*
****************************************************************************

               XBRA_HD                       ; XBRA header

nk_gemtrap:    cmp      #200,d0              ; AES?
               bne.s    .exit                ; no ->

               move.l   d1,a0                ; ^parameter block
               move.l   (a0),a1              ; ^contrl array
               cmp      #26,(a1)             ; opcode for evnt_dclick?
               bne.s    .exit                ; no ->

               move.l   8(a0),a1             ; ^intin array
               tst      2(a1)                ; set new time?
               beq.s    .exit                ; no ->

               move     (a1),d2              ; yes: get new time
               cmp      #4,d2                ; limit check
               bls.s    .save                ; ok: save new value

               moveq.l  #4,d2                ; out of range: use maximum

.save:         move     d2,bvar+BI_DCLTIME   ; save it

.exit:         move.l   nk_gemtrap-4(pc),-(sp)  ; old vector address
               rts                           ; jump to old routine



****************************************************************************
*
*  nk_butvec: VDI mouse button change handler
*  # I S
*
*  This function handles changes of the mouse button state. It is used
*  for NKCC's own button event handler, which consists mainly of this
*  interrupt and the functions nk_bestart() and nk_beend().
*
*  The handler knows several modes (stored in bvar+BU_BMODE.w):
*
*  0     standby mode: no button event in process, waiting for first click
*  1     wait mode: button event in process, but not yet finished: waiting
*        for a possible second, third ... click
*  2     hold mode: button event was generated, condition still true (buttons
*        are still pressed): repeat button event
*
*  In:   D0.W           current state of mouse buttons
*
*  Out:  D0.W           current state of mouse buttons (unchanged)
*
*  Reg:  D:01234567   A:01234567   CCR
*          ........     ........    *
*
****************************************************************************

               XBRA_HD  nk_bvret             ; XBRA header

* Some milliseconds after the installation of this function, the old vector
* address is not set (VDI has to return first). A mouse click during this
* time would lead to a system crash because the new handler jumps through
* this vector. This is the reason why it's initial content points to a
* RTS instruction. (I know, this is a very very improbable situation, but
* it IS possible! And that's reason enough to prepare for it and write
* some silly lines of comment about it!)

nk_butvec:     movem.l  d5-d7/a0-a1,-(sp)    ; save registers
               lea      bvar,a1              ; ^button event info block
               move     d0,d7                ; new button mask
               move     BI_BSTATE(a1),d6     ; requested button state
               eor      d6,d7                ; XOR 'em
               move     BI_BMASK(a1),d6      ; button mask
               and      d6,d7                ; isolate valid bits
               tst      BI_REVCOND(a1)       ; condition reverse flag
               bne.s    .rev                 ; reverse ->

               tst      d7                   ; 0-> all button conditions true
               seq.b    d6                   ; if so, the set d6 to $ff
               bra.s    .chkmode             ; ->

.rev:          eor      d6,d7                ; invert condition flags
               cmp      d6,d7                ; at least one condition true?
               sne.b    d6                   ; yes -> set d6 to $ff

* the registers contain now:
*
* d6.b = button condition flag (0=condition false, $ff=condition true)
* d7.w = button condition mask (bits with value 0 indicate true condition)

.chkmode:      move.b   d6,BI_CVALID(a1)     ; save flag
               move     BI_BMODE(a1),d5      ; check current mode
               beq.s    .standby             ; standby mode ->

               subq     #1,d5                ; check if wait mode
               beq.s    .wait                ; wait mode ->


*------------- handler is in HOLD mode

.hold:         tst.b    d6                   ; hold mode: button condition true?
               beq.s    .reset               ; no ->

               move     #1,BI_NCLICKS(a1)    ; 1 mouse click
               move     d0,BI_SBSTATE(a1)    ; use current button state
               st.b     BI_BEVALID(a1)       ; generate mouse click
               bra      .exit

.reset:        clr      BI_BMODE(a1)         ; switch to standby mode
               bra.s    .exit


*------------- handler is in STANDBY mode

.standby:      tst.b    BI_BEVALID(a1)       ; old click still in buffer?
               bne.s    .exit                ; yes ->

               tst.b    d6                   ; button condition true?
               beq.s    .exit                ; no ->

               move     d0,BI_SBSTATE(a1)    ; save button state
               moveq.l  #1,d5
               move     d5,BI_BMODE(a1)      ; change to wait mode
               move     d5,BI_NCLICKS(a1)    ; init # of clicks

               lea      timetab,a0           ; ^double click time table
               move     BI_DCLTIME(a1),d5    ; double click time
               add      d5,d5                ; *4 for index
               add      d5,d5
               move.l   (a0,d5),d5           ; get double click time
               add.l    sysclock,d5          ; add current timer value
               move.l   d5,BI_BENDTIME(a1)   ; save as end time

               moveq.l  #1,d5                ; find first button

.findbut:      add      d5,d5                ; next button
               lsr      d7                   ; check next bit
               bcs.s    .findbut             ; condition not true ->

               lsr      d5                   ; first found changed button

.dcbut:        move     d5,BI_DCBUT(a1)      ; save double click button mask
               and      d0,d5                ; get 'active' state
               move     d5,BI_DCSTATE(a1)    ; save it

               bra.s    .exit                ; ->


*------------- handler is in WAIT mode

.wait:         tst.b    BI_BEVALID(a1)       ; old click still in buffer?
               bne.s    .exit                ; yes ->

               move     BI_DCBUT(a1),d5      ; double click button mask
               move     BI_PRVBSTATE(a1),d7  ; previous button state
               eor      d0,d7                ; get button state changes
               and      d5,d7                ; did dclick button state change?
               beq.s    .exit                ; no ->

               and      d0,d5                ; isolate state of dclick button
               cmp      BI_DCSTATE(a1),d5    ; changed it to 'active' state?
               bne.s    .exit                ; no ->

               moveq.l  #1,d7                ; yes: add 1 to # of clicks
               add      BI_NCLICKS(a1),d7
               cmp      BI_MAXCLICKS(a1),d7  ; > max # of clicks to wait for?
               bhi.s    .exit                ; yes ->

               move     d7,BI_NCLICKS(a1)    ; no: save new # of clicks
               add.l    #TIME_ADD,BI_BENDTIME(a1)  ; let user more time to click


*------------- leave interrupt

.exit:         move     d0,BI_PRVBSTATE(a1)  ; save button state
               movem.l  (sp)+,d5-d7/a0-a1    ; restore registers
               move.l   nk_butvec-4(pc),-(sp)   ; old vector address

nk_bvret:      rts                           ; jump to old routine




****************************************************************************
*
*  nk_bestart: start special handling of button event
*  #
*
*  In:   -
*
*  Out:  D7.W           handler mode (used in nk_beend)
*
*  Reg:  D:01234567   A:01234567   CCR
*          **.....W     **......    *
*
****************************************************************************

nk_bestart:    moveq.l  #0,d7                ; default: no special handling
               tst.b    buthnd               ; our handler installed?
               beq      .exit                ; no ->

               lea      nkc_intin,a0         ; ^event mask
               moveq.l  #MU_BUTTON,d0        ; request for button event?
               and      (a0),d0
               beq      .exit                ; no ->


*------------- configure timer event

               lea      bvar,a1              ; ^button event variables
               move     2(a0),d7             ; nclicks + reverse flag
               move.b   d7,BI_MAXCLICKS+1(a1)   ; isolate and save nclicks
               clr.b    d7                   ; isolate reverse flag
               move     d7,BI_REVCOND(a1)    ; save reverse flag
               move     4(a0),BI_BMASK(a1)   ; save button mask
               move     6(a0),BI_BSTATE(a1)  ; save button state
                                             ; new mouse button parameters:
               clr      4(a0)                ; mask = 0
               clr      6(a0)                ; state = 0
               moveq.l  #1,d7                ; new handler mode
               move     d7,2(a0)             ; also used for new nclicks
                                             ; -> button condition always true

*------------- configure timer event

               moveq.l  #MU_TIMER,d0         ; request for timer event?
               and      (a0),d0
               beq.s    .no_timer            ; no ->

               moveq.l  #2,d7                ; new mode
               move.l   28(a0),d0            ; time = 0 ms?
               beq.s    .exit                ; yes: fine, exactly what we need

               moveq.l  #3,d7                ; new mode
               swap     d0                   ; time in Motorola format
               cmp.l    prvtime,d0           ; identical to previous time?
               beq.s    .nulltime            ; yes ->

               move.l   d0,prvtime           ; no: save timer event value
               LWDIVU   #5,d0,d1             ; convert to 200 Hz resolution
               add.l    sysclock,d0          ; + current timer value
               move.l   d0,tendtime          ; this is our timer end value

               bra.s    .nulltime            ; and set own one


*------------- user doesn't want timer events - but we need them!

.no_timer:     moveq.l  #-1,d0               ; reset previous timer event value
               move.l   d0,prvtime
               or       #MU_TIMER,(a0)       ; set bit: check timer events

.nulltime:     clr.l    28(a0)               ; time: 0 ms

.exit:         rts                           ; bye




****************************************************************************
*
*  nk_beend: end special handling of button event
*  #
*
*  In:   D7.W           handler mode:
*                       0     button event handler inactive
*                       1     user did not check timer events
*                       2     user did check timer events with time = 0 ms
*                       3     user did check timer events with time > 0 ms
*
*  Out:  nkc_intout.W[]:updated mouse event information
*
*  Reg:  D:01234567   A:01234567   CCR
*          **......     **......    *
*
****************************************************************************

nk_beend:      lea      nkc_intout,a0        ; ^event mask
               move     d7,d0                ; which mode?
               beq      .exit                ; no special handling

               lea      bvar,a1              ; ^button event info block
               move     BI_PRVBSTATE(a1),6(a0)  ; return button state


*------------- analyze which events have occured

               moveq.l  #MU_MESAG,d1         ; did message event occur?
               and      (a0),d1              ; and with event mask
               beq.s    .chkflag             ; no message event ->

               and      #~MU_BUTTON,(a0)     ; no button event

.chkflag:      moveq.l  #MU_BUTTON,d1        ; did button event occur?
               and      (a0),d1              ; (if not: just moving a window
                                             ;  or something like that)
               beq.s    .lock                ; no -> lock mouse button event


*------------- application has mouse under its control; what now?

               tst.b    BI_LOCK(a1)          ; is button event locked?
               bne      .unlock              ; yes -> unlock it

               tst.b    BI_BEVALID(a1)       ; event valid?
               bne.s    .butev               ; yes ->


*------------- mouse click isn't finished, yet; wait

               move     BI_BMODE(a1),d1      ; no: get handler mode
               beq.s    .nombut              ; standby mode ->

               subq     #1,d1                ; wait mode?
               beq.s    .wait                ; yes ->

.hold:         clr      12(a0)               ; # of clicks = 0
               bra.s    .evtimer

.wait:         move.l   BI_BENDTIME(a1),d1   ; button event end time
               cmp.l    sysclock,d1          ; end of time reached?
               bhi.s    .nombut              ; no ->

               addq     #1,BI_BMODE(a1)      ; change to hold mode
               tst.b    BI_CVALID(a1)        ; was last button condition valid?
               bne.s    .butev               ; yes ->

               clr      BI_BMODE(a1)         ; no: standby mode

.butev:        move     BI_NCLICKS(a1),12(a0)   ; return # of clicks
               move     BI_SBSTATE(a1),6(a0)    ; return start button state
               sf.b     BI_BEVALID(a1)       ; button event fetched
               bra.s    .evtimer

.nombut:       and      #~MU_BUTTON,(a0)     ; no mouse button event


*------------- timer event handling

.evtimer:      subq     #1,d0                ; timer event checked by us?
               beq.s    .nktimer             ; yes ->

               subq     #1,d0                ; 0 ms timer checked by user?
               beq.s    .exit                ; yes ->

.user0:        move.l   tendtime,d1          ; timer event end time
               cmp.l    sysclock,d1          ; end of waiting time reached?
               bls.s    .exit                ; yes ->

.nktimer:      and      #~MU_TIMER,(a0)      ; no timer event occured

.exit:         move     (a0),d0              ; event mask
               and      #MU_TIMER,d0         ; did a timer event occur?
               beq.s    .exit2               ; no ->

.treset:       moveq.l  #-1,d0               ; yes: reset previous timer
               move.l   d0,prvtime           ;  event value

.exit2:        rts


*------------- AES didn't return MU_BUTTON -> screen manager has taken mouse
*              control: don't create MU_BUTTON events

.lock:         st.b     BI_LOCK(a1)          ; lock mouse button event
               move     #MU_XTIMER,d1        ; lock timer events, too?
               and      nkc_intin,d1         ; check this flag
               beq.s    .evtimer             ; don't lock ->

               bra.s    .nktimer             ; lock ->


*------------- AES did return MU_BUTTON (applications has mouse under its
*              control) but the button events were locked previously: unlock
*              them

.unlock:       sf.b     BI_LOCK(a1)          ; unlock mouse button event
               clr      BI_BMODE(a1)         ; reset mode
               sf.b     BI_BEVALID(a1)       ; reset button event flag
               bra.s    .nombut



****************************************************************************
*
*  nk_mctrl: set control array for multi event
*  #
*
*  In:   -
*
*  Out:  nkc_contrl.W[]: control parameters configured for evnt_multi() call
*
*  Reg:  D:01234567   A:01234567   CCR
*          ........     *.......    *
*
****************************************************************************

nk_mctrl:      lea      nkc_contrl,a0        ; ^control array
               move     #25,(a0)+            ; opcode
               move     #16,(a0)+            ; size of intin
               move     #7,(a0)+             ; size of intout
               move     #1,(a0)+             ; size of addrin
               clr      (a0)                 ; size of addrout
               rts                           ; bye




****************************************************************************
*
*  nk_msave: save input parameters for evnt_multi() call in buffer
*  #
*
*  In:   -
*
*  Out:  multibuf.W[]:  first 16 words of nkc_intin and first long of
*                          nkc_adrin
*
*  Reg:  D:01234567   A:01234567   CCR
*          *******.     **......    *
*
****************************************************************************

nk_msave:      lea      nkc_intin,a0         ; ^intin array
               lea      multibuf,a1          ; ^save buffer
               movem.l  (a0)+,d0-d6          ; get first 14 words of nkc_intin
               movem.l  d0-d6,(a1)           ; save 'em in buffer
               move.l   (a0),7*4(a1)         ; save last two words
               move.l   nkc_adrin,8*4(a1)    ; save contents of addrin
               rts




****************************************************************************
*
*  nk_mrestore: restore evnt_multi() input parameters corrupted by AES(!)
*  #
*
*  In:   -
*
*  Out:  nkc_contrl.w[]: restored data (5 words)
*        nkc_intin.w[] : restored data (16 words)
*        nkc_adrin.L[] : restored data (1 longword)
*
*  Reg:  D:01234567   A:01234567   CCR
*          *******.     **......    *
*
****************************************************************************

nk_mrestore:   lea      multibuf,a0          ; ^save buffer
               lea      nkc_intin,a1         ; ^intin array
               movem.l  (a0)+,d0-d6          ; first 14 words of nkc_intin
               movem.l  d0-d6,(a1)           ; put them in nkc_intin array
               move.l   (a0)+,7*4(a1)        ; last two words
               move.l   (a0),nkc_adrin       ; restore addrin array
               bra.s    nk_mctrl             ; restore contrl array

               .endif   ; .if NKCGEM=1




****************************************************************************
*
*  nk_200hz: 200 Hz system clock interrupt
*  # I S
*
*  In:   -
*
*  Out:  -
*
*  Reg:  D:01234567   A:01234567   CCR
*          ........     ........    *
*
****************************************************************************

               XBRA_HD                       ; XBRA header

nk_200hz:      move.l   _hz_200,sysclock     ; just transfer value
               move.l   nk_200hz-4(pc),-(sp) ; old vector address
               rts                           ; jump to old routine



*START
****************************************************************************
*                            GLOBAL TEXT SECTION                           *
****************************************************************************
*END

               .text

*START
****************************************************************************
*
*  nkc_init: initialize NKCC
*  # G U
*
*  This function initializes NKCC. It must be called once before any other
*  NKCC routine. It performs some tasks that may be important for you to
*  know:
*
*  - bit 3 of the system variable <conterm> ($484.B) is set
*  - a 200 Hz clock interrupt is installed, using the XBRA method (ID is
*    "NKCC")
*
*  nkc_init() gets some flags which configure NKCC and enable some special
*  functions:
*
*  NKI?_BUTHND       install NKCC's button event handler (see documentation
*                    NKCC.DOC for details)
*  NKI?_BHTOS        additional flag: install only, if TOS has mouse click bug
*  NKI?_NO200HZ      don't install the 200 Hz timer interrupt
*
*  Notes:
*
*  - if NKCC is assembled as TOS-only version (symbol NKCGEM set to 0),
*    both NKI?_BUTHND and NKI?_BHTOS flags are ignored.
*
*  - if the button event handler is installed, the NKI?_NO200HZ flag is
*    ignored (because the 200 Hz clock is needed by the handler). Besides,
*    the initialization continues:
*
*    - an own GEM trap handler (trap #2) is installed, using the XBRA method
*      (to be up to date when a new double click time is set via the AES
*      function evnt_dclick())
*
*    - a vex_butv() call (VDI) is made to install a mouse button exchange
*      handler
*
*  In:   D0.L           miscellaneous flags (NKI?_...); see above
*        D1.W           handle of an open VDI workstation
*                       (must only be valid if the button handler is
*                       installed)
*        A0.L           ^applications GLOBAL array (from GEM parameter block)
*                       not used in the TOS version of NKCC
*
*  Out:  D0.W           NKCC's version number as 4 digit BCD
*                       (main # in high byte, sub # in low byte)
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......    *
*
****************************************************************************
*END

nkc_init:      move.l   a2,-(sp)             ; save a2 for Turbo C/Pure C

               movem.l  d0-d1,-(sp)          ; save flags and VDI handle
               subq.l   #2,sp                ; one word local stack space

               .if      NKCGEM=1

                move.l  a0,aespb+4           ; keep ^global array

                move    #1,-(sp)             ; device: keyboard
                move    #14,-(sp)            ; function opcode: Iorec
                trap    #14                  ; XBIOS
                addq.l  #4,sp                ; clean stack
                move.l  d0,kbdiorec          ; keep ^IOREC structure
                move.l  d0,a0                ; load into address register
                move    IBUFHD(a0),iohead    ; keep current head pointer

               .endif   ; .if NKCGEM=1


*------------- switch to Supervisor mode to have access to system variables

               clr.l    -(sp)                ; use usp as ssp
               move     #$20,-(sp)           ; Super
               trap     #1                   ; GEMDOS
               move.l   d0,2(sp)             ; save old sp
               move     #$20,(sp)            ; Super opcode for next call


*------------- enable auto return of shift/ctrl/alt status

               bset.b   #3,conterm.w         ; set bit for auto shift return


*------------- locate shift state system variable

               move.l   _sysbase.w,a0        ; ^OS header
               move     2(a0),d0             ; get TOS version
               move     d0,6(sp)             ; save it in local stack space
               cmp      #$0100,d0            ; TOS 1.0?
               beq.s    .tos10               ; yes ->

               move.l   $24(a0),pshift       ; get ^shift state variable
               bra.s    .user                ; ->

.tos10:        move.l   #$e1b,pshift         ; this is the location in TOS 1.0


*------------- switch back to user mode

.user:         trap     #1                   ; GEMDOS
               addq     #6,sp                ; clean stack


*------------- fetch addresses of TOS' key scan code translation tables

               moveq.l  #-1,d0               ; the function is also used to
               move.l   d0,-(sp)             ;  change the addresses; values
               move.l   d0,-(sp)             ;  of -1 as new addresses tell
               move.l   d0,-(sp)             ;  XBIOS not to change them
               move     #$10,-(sp)           ; Keytbl
               trap     #14                  ; XBIOS
               lea      $e(sp),sp            ; clean stack

               move.l   d0,a0                ; ^key table structure
               move.l   (a0)+,pkey_unshift   ; get ^unshifted table
               move.l   (a0)+,pkey_shift     ; get ^shift table
               move.l   (a0),pkey_caps       ; get ^CapsLock table


*------------- do some other initialization stuff

               clr.l    sflags               ; reset special key flags
               clr.b    prvvalid             ; no previous key code


*------------- install the mouse button handler

               move     (sp)+,d0             ; TOS version
               movem.l  (sp),d1-d2           ; restore flags and VDI handle

               .if      NKCGEM=1

                clr.b   buthnd               ; default: set flag: not installed
                btst.l  #NKIb_BUTHND,d1      ; install it?
                beq     .timer               ; no ->

                btst.l  #NKIb_BHTOS,d1       ; check TOS version number?
                beq.s   .butev               ; no ->

                cmp     #$0104,d0            ; bug appeared in TOS 1.04!
                blo     .timer               ; TOS is ok ->

                cmp     #$0306,d0            ; bug is solved since TOS 3.06!
                bhs     .timer               ; TOS is ok ->

.butev:         bclr.l  #NKIb_NO200HZ,d1     ; must install timer interrupt
                st.b    buthnd               ; set flag: handler installed
                move    d2,vdihnd            ; save VDI handle

                moveq.l #0,d0                ; do some initializations
                lea     bvar,a1              ; ^button event info block
                move    d0,BI_BMODE(a1)      ; init interrupt mode
                move.b  d0,BI_BEVALID(a1)    ; mouse click info not valid
                move    d0,BI_PRVBSTATE(a1)  ; init previous button state
                move    d0,BI_BMASK(a1)      ; don't check any button
                move.b  d0,BI_LOCK(a1)       ; mouse button event isn't locked
                subq.l  #1,d0                ; d0.l = -1
                move    d0,BI_REVCOND(a1)    ; reverse button condition
                                             ; -> no mouse click is checked
                move.l  d0,prvtime           ; previous timer event value

                lea     nkc_contrl,a0        ; set parameter array for vex_butv
                move    #125,(a0)+           ; opcode
                clr.l   (a0)+                ; no ptsin/ptsout entries
                clr.l   (a0)+                ; no intin/intout entries
                addq    #2,a0                ; entry #5 is unused
                move    d2,(a0)+             ; handle of workstation
                lea     nk_butvec(pc),a1     ; ^our handler
                move.l  a1,(a0)
                moveq.l #115,d0              ; opcode: VDI
                move.l  #vdipb,d1            ; ^parameter block
                trap    #2                   ; execute VDI
                move.l  nkc_contrl+18,nk_butvec-4  ; save old handler address

                lea     nkc_contrl,a0        ; set parameter for evnt_dclick
                move    #26,(a0)+            ; opcode
                move    #2,(a0)+             ; # of entries in intin
                move    #1,(a0)+             ; # of entries in intout
                clr.l   (a0)+                ; no entries in addrin/addrout
                clr     nkc_intin+2          ; get/set flag: get value
                move    #200,d0              ; opcode for AES
                move.l  #aespb,d1            ; ^parameter block
                trap    #2                   ; execute AES
                move    nkc_intout,bvar+BI_DCLTIME    ; save double click time

                                             ; install trap #2 handler
                moveq.l #34,d0               ; vector number
                moveq.l #NKXM_NUM,d1         ; mode: vector number
                lea     nk_gemtrap(pc),a0    ; ^function to install
                bsr     nkc_vlink            ; install it

               .endif   ; .if NKCGEM=1


*------------- install 200 Hz clock interrupt

.timer:        clr.l    sysclock             ; init 200 Hz clock for the case
                                             ; that the timer won't be installed
               movem.l  (sp)+,d1-d2          ; restore flags and VDI handle
               btst.l   #NKIb_NO200HZ,d1     ; install interrupt?
               seq.b    timerflag            ; $00 = no, $ff = yes
               bne.s    .exit                ; no ->

               moveq.l  #69,d0               ; vector number
               moveq.l  #NKXM_NUM,d1         ; mode: vector number
               lea      nk_200hz(pc),a0      ; ^function to install
               bsr      nkc_vlink            ; install it


*------------- restore saved register and exit

.exit:         move.l   (sp)+,a2             ; restore register
               move     #VERSION,d0          ; load version #
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_exit: exit NKCC
*  # G U
*
*  nkc_exit() must be called before the program is quit. It removes all
*  handlers installed in the system.
*
*  In:   -
*
*  Out:  D0.W           status flag:
*                       0     OK
*                       -1    can't remove 200 Hz clock interrupt
*                       -2    can't remove trap #2 handler
*                       -3    can't remove both handlers
*                       An error can happen if somebody corrupted the
*                       XBRA vector list. This is fatal!
*
*  Reg:  D:01234567   A:01234567   CCR
*          ***.....     **......   =D0.W
*
****************************************************************************
*END

nkc_exit:      move.l   a2,-(sp)             ; save register


*------------- remove 200 Hz system clock interrupt

               clr      -(sp)                ; default remove status for
                                             ;  timer interrupt
               tst.b    timerflag            ; installed?
               beq.s    .buthnd              ; no ->

               moveq.l  #69,d0               ; vector number
               moveq.l  #NKXM_NUM,d1         ; mode: vector number
               lea      nk_200hz(pc),a0      ; ^function to remove
               bsr      nkc_vunlink          ; remove it
               move     d0,(sp)              ; save remove status


*------------- remove own button event handler

.buthnd:       clr      -(sp)                ; default remove status for
                                             ;  button event handler

               .if      NKCGEM=1

               tst.b    buthnd               ; handler installed?
               beq.s    .exit                ; no ->

               lea      nkc_contrl,a0        ; set paremeter array for vex_butv
               move     #125,(a0)+           ; opcode
               clr.l    (a0)+                ; no ptsin/ptsout entries
               clr.l    (a0)+                ; no intin/intout entries
               addq     #2,a0                ; entry #5 is unused
               move     vdihnd,(a0)+         ; handle of workstation
               lea      nk_butvec(pc),a1     ; ^our handler
               move.l   -4(a1),(a0)          ; ^old routine
               moveq.l  #115,d0              ; opcode: VDI
               move.l   #vdipb,d1            ; ^parameter block
               trap     #2                   ; execute VDI

                                             ; remove trap #2 handler
               moveq.l  #34,d0               ; vector number
               moveq.l  #NKXM_NUM,d1         ; mode: vector number
               lea      nk_gemtrap(pc),a0    ; ^function to remove
               bsr      nkc_vunlink          ; remove it
               move     d0,(sp)              ; save status

               .endif   ; .if NKCGEM=1


*------------- restore saved registers and exit

.exit:         move     (sp)+,d0             ; trap #2 remove error?
               beq.s    .stat0               ; no ->

               move     (sp)+,d0             ; 200 Hz clock remove error?
               beq.s    .stat1               ; no ->

               moveq.l  #-3,d0               ; both failed!
               bra.s    .ret

.stat0:        move     (sp)+,d0             ; 200 Hz clock remove error?
               beq.s    .ret                 ; no ->

               moveq.l  #-1,d0               ; "only" 200 Hz clock failure?
               bra.s    .ret

.stat1:        moveq.l  #-2,d0               ; "only" trap #2 remove failure?

.ret:          move.l   (sp)+,a2             ; restore register
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_set: set special key flags
*  # G
*
*  This function is used to enable/disable special key handling procedures.
*  The features which can be set are:
*
*  - direct input of ASCII codes; when switched on, pressing the Alternate
*    key plus one of the numbers on the numeric keypad will start the input
*    of a decimal ASCII number. The input is finished either when 3 digits
*    are typed in or the Alternate key is released. NKCC will return the
*    corresponding character with the entered ASCII code. This feature makes
*    it possible to use the whole range of the character set (from 0 ... 255).
*
*  - deadkey management; when switched on, NKCC will combine some combi-
*    nations of two key strokes to one character. This is used to generate
*    characters with accents which are not on the keyboard. The supported
*    deadkeys are:
*
*    ^   +   aeiou      =  Éàåìñ       (NKS?_D_CIRCUM)
*    ~   +   nNaoAo     =  §•∞±∑∏      (NKS?_D_TILDE)
*    '   +   eEaiou     =  Çê†°¢£      (NKS?_D_AGUI)
*    `   +   aeiouA     =  Öäçïó∂      (NKS?_D_GRAVE)
*    π   +   aeiouyAOU  =  ÑâãîÅòéôö   (NKS?_D_UMLAUT)
*    "   +   aeiouyAOU  =  ÑâãîÅòéôö   (NKS?_D_QUOTE)
*    ¯   +   aA         =  Üè          (NKS?_D_SMOERE)
*    ,   +   cC         =  áÄ          (NKS?_D_CEDIL)
*    /   +   oO24       =  ≥≤´¨        (NKS?_D_SLASH)
*
*    The quote character as synonym for umlaut is e.g. needed on the Dutch
*    keyboard, where neither umlaut characters nor the umlaut itself are
*    available.
*
*    Each deadkey can be enabled/disabled separately.
*
*  - Control key emulation: Control plus an ASCII code in the range of
*    $40...$5F (characters @, A...Z, [, \, ], ^ and _) is converted
*    to an ASCII code of $00...$1F.
*
*
*  In:   D0.L           new key flags (bit set = feature on):
*                       NKS?_ALTNUM       ASCII input
*                       NKS?_D_...        deadkey ...
*                                         (NKSf_DEADKEY: all deadkeys)
*                       NKS?_CTRL         control key emulation
*
*  Out:  -
*
*  Reg:  D:01234567   A:01234567   CCR
*          ***.....     **......    *
*
****************************************************************************
*END

nkc_set:       move.l   d0,sflags            ; just save flags
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_conin: raw console character input
*  # G
*
*  This routine replaces the Gemdos function Crawcin. However, it returns
*  a WORD with the key code in normalized format rather than a LONG with
*  the key code in the language dependend TOS format.
*
*  In:   -
*
*  Out:  D0.W           key code in normalized format
*                       for details see nkc_tconv()
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          W**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_conin:     tst.b    prvvalid             ; previous character in buffer?
               beq.s    .getkey              ; no->

               clr.b    prvvalid             ; remove key code from buffer
               move     prvkey,d0            ; get key code
               rts                           ; bye


.getkey:       movem.l  d3-d7/a2-a6,-(sp)    ; save registers
               clr      d0                   ; don't check Alternate state
               bsr      nk_gci               ; get key code
               lea      nk_gci(pc),a0        ; ^function to execute
               bsr      nk_spec              ; special key handling
               movem.l  (sp)+,d3-d7/a2-a6    ; restore registers
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_cstat: return console character input status
*  # G
*
*  This function checks, if a key is in the key input buffer or not.
*
*  In:   -
*
*  Out:  D0.W           flag:
*                       0     no key in buffer
*                       -1    at least one key in buffer
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          W**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_cstat:     tst.b    prvvalid             ; previous character in buffer?
               sne.b    d0                   ; $ff = yes, $00 = no
               ext      d0                   ; as word
               bne.s    .exit                ; char available: exit

               move.l   a2,-(sp)             ; save register for Turbo C/Pure C

               move     #11,-(sp)            ; Cconis
               trap     #1                   ; Gemdos
               addq     #2,sp                ; clean stack

               move.l   (sp)+,a2             ; restore register
               tst      d0                   ; set CCR

.exit:         rts                           ; bye



               .if      NKCGEM=1

*START
****************************************************************************
*
*  nkc_multi: NKCC multi event
*  # G U
*
*  nkc_multi() is a binding function to the AES multi event handler. The
*  only differences are the keyboard events and the shift key state: the key
*  codes are returned in normalized format (see nkc_tconv()), the shift key
*  state is compatible to the NKF?_... flags. For a detailed description of
*  the whole mass of parameters consult your AES manual or compiler handbook!
*
*  In:    4(SP).w       event mask (MU_...)
*         6(SP).w       MU_BUTTON: max # of clicks to wait for
*         8(SP).w       MU_BUTTON: mask of buttons to check
*        10(SP).w       MU_BUTTON: button states to wait for
*        12(SP).w       MU_M1: area enter/leave flag
*        14(SP).w       MU_M1: x position of area
*        16(SP).w       MU_M1: y position of area
*        18(SP).w       MU_M1: width of area
*        20(SP).w       MU_M1: height of area
*        22(SP).w       MU_M2: area enter/leave flag
*        24(SP).w       MU_M2: x position of area
*        26(SP).w       MU_M2: y position of area
*        28(SP).w       MU_M2: width of area
*        30(SP).w       MU_M2: height of area
*        32(SP).L       MU_MESAG: ^8 words of message buffer
*        36(SP).w       MU_TIMER: low word of time to wait
*        38(SP).w       MU_TIMER: high word of time to wait
*        40(SP).L       MU_BUTTON/M1/M2: ^word for mouse x
*        44(SP).L       MU_BUTTON/M1/M2: ^word for mouse y
*        48(SP).L       MU_BUTTON/M1/M2: ^word for button state
*        52(SP).L       MU_BUTTON/M1/M2: ^word for shift state
*        56(SP).L       MU_KEYBD: ^word for key code in normalized format
*        60(SP).L       MU_BUTTON: ^word for # of mouse clicks
*
*  Out:  D0.W           mask of occured events (MU_...)
*
*  Reg:  D:01234567   A:01234567   CCR
*          W**.....     **......    *
*
****************************************************************************
*END

nkc_multi:     tst.b    prvvalid             ; previous character in buffer?
               beq.s    .mevent              ; no ->

               clr.b    prvvalid             ; remove key code from buffer
               move.l   56(sp),a0            ; ^buffer for key code
               move     prvkey,(a0)          ; return key code
               moveq.l  #MU_KEYBD,d0         ; a keyboard event occured
               rts                           ; bye

.mevent:       movem.l  d3-d7/a2-a6,-(sp)    ; save registers


*------------- transfer stack arguments to GEM parameter arrays

               lea      10*4+4(sp),a0        ; ^first parameter
               lea      nkc_intin,a1         ; ^integer in array
               movem.l  (a0)+,d1-d7          ; get the first 14 words
               movem.l  d1-d7,(a1)           ; place them in intin
               move.l   (a0)+,nkc_adrin      ; ^message buffer in addrin
               move.l   (a0),7*4(a1)         ; timer event lo and hi count

               bsr      nk_mctrl             ; setup control array


*------------- execute multi event

               bsr      nk_bestart           ; start handling for button event
               bsr      nk_msave             ; save multi event parameters

.wait:         cmp      #25,nkc_contrl       ; still evnt_multi() opcode?!?
               beq.s    .aes                 ; yes ->

               bsr      nk_mrestore          ; NO! AES corrupted it! restore

.aes:          lea      nkc_intin,a0         ; ^intin
               move     (a0),-(sp)           ; save event mask
               and      #~MU_XTIMER,(a0)     ; clear x-timer flag
               move     #200,d0              ; opcode for AES
               move.l   #aespb,d1            ; ^AES parameter block
               trap     #2                   ; call GEM
               move     (sp)+,nkc_intin      ; restore event mask

               move     nkc_intout,d0        ; mask of occured events
               and      #MU_KEYBD,d0         ; keyboard event?
               bne.s    .buthnd              ; yes ->

               move.l   kbdiorec,a0          ; no: get ^keyboard's I/O record
               move     IBUFHD(a0),iohead    ; reset NKCC's head pointer

.buthnd:       bsr      nk_beend             ; end handling of button event
               tst      nkc_intout           ; did any event occur?
               beq.s    .wait                ; no ->


*------------- return intout parameters via pointers

               movem.l  10*4+40(sp),a0-a5    ; get return pointers
               lea      nkc_intout,a6        ; ^intout array
               move     (a6)+,d0             ; mask of occured events
               move     (a6)+,(a0)           ; mouse x
               move     (a6)+,(a1)           ; mouse y
               move     (a6)+,(a2)           ; mouse button state
               move.b   1(a6),(a3)           ; shift key state (NKC flag
                                             ;  compatible!)
               clr.b    1(a3)                ; clear low byte of shift state
               move.l   a6,a3                ; ^shift state in intout
               move     4(a6),(a5)           ; # of mouse clicks
               move     2(a6),(a4)           ; key code

* You wonder why (a4) is written as last one and (a3) points to intout
* instead of the original return location? This is for the case that
* the caller isn't interested in one or some of the return values and
* let them point to ONE dummy variable.


*------------- check if keyboard event occured and convert key code, if so

               moveq.l  #MU_KEYBD,d1         ; the flag to test
               and      d0,d1                ; is it set?
               beq.s    .exit                ; no-> exit

               move     d0,-(sp)             ; save event mask
               move.l   a4,-(sp)             ; save ^key code

               move     (a4),d0              ; scan code + ASCII code
               moveq.l  #MU_BUTTON|MU_M1|MU_M2,d1  ; any of the events checked
               and      10*4+4+6(a7),d1      ; which return shift state?
               bne.s    .useiout             ; yes->

               move.l   pshift,a3            ; no: get shift state directly
               move.b   (a3),d1              ; get it
               and      #$f,d1               ; isolate valid bits
               bra.s    .conv

.useiout:      move     (a3),d1              ; get shift state from intout

.conv:         bsr      nk_bioscode          ; convert to BIOS format
               bsr      nk_real_shift        ; try to get original shift flags
               bsr      nkc_tconv            ; convert to normalized format
               lea      nk_mci(pc),a0        ; ^function to execute
               bsr      nk_spec              ; special key code handling

               move.l   (sp)+,a0             ; restore ^key code
               move     d0,(a0)              ; return key code

               move     (sp)+,d0             ; restore event mask
               move     d0,nkc_intout        ; and intout (changed by nk_spec)

.exit:         movem.l  (sp)+,d3-d7/a2-a6    ; restore registers
               rts                           ; bye




*START
****************************************************************************
*
*  nkc_amulti: NKCC multi event called by Assembler  *** added by Gerd Knops
*  # G U
*
*  See description of nkc_multi()!
*
*  usage: instead of    move.l   #aespb,d1
*                       move  #$c8,d0
*                       trap  #2
*
*         do            jsr   nkc_amulti
*
*  In:   all parameters for evnt_multi in the AES parameter arrays
*
*  Out:  values in intout and message buffer
*
*  Reg:  D:01234567   A:01234567   CCR
*          ***.....     **......    *
*
****************************************************************************
*END

nkc_amulti:    tst.b    prvvalid             ; previous character in buffer?
               beq.s    .mevent              ; no->

               clr.b    prvvalid             ; remove key code from buffer
               clr      nkc_intout+8         ; no SHIFT etc.
               move     prvkey,nkc_intout+10 ; return key code
               move     #MU_KEYBD,nkc_intout ; a keyboard event occured
               rts                           ; bye

.mevent:       movem.l  d3-d7/a2-a6,-(sp)    ; save registers

               move     nkc_intin,-(sp)      ; events to get


*------------- execute multi event

               bsr      nk_bestart           ; start handling for button event
               bsr      nk_msave             ; save multi event parameters

.wait:         cmp      #25,nkc_contrl       ; still evnt_multi() opcode?!?
               beq.s    .aes                 ; yes ->

               bsr      nk_mrestore          ; NO! AES corrupted it! restore

.aes:          lea      nkc_intin,a0         ; ^intin
               move     (a0),-(sp)           ; save event mask
               and      #~MU_XTIMER,(a0)     ; clear x-timer flag
               move     #200,d0              ; opcode for AES
               move.l   #aespb,d1            ; ^AES parameter block
               trap     #2                   ; call GEM
               move     (sp)+,nkc_intin      ; restore event mask

               move     nkc_intout,d0        ; mask of occured events
               and      #MU_KEYBD,d0         ; keyboard event?
               bne.s    .buthnd              ; yes ->

               move.l   kbdiorec,a0          ; no: get ^keyboard's I/O record
               move     IBUFHD(a0),iohead    ; reset NKCC's head pointer

.buthnd:       bsr      nk_beend             ; end handling of button event
               tst      nkc_intout           ; did any event occur?
               beq.s    .wait                ; no ->

               move     (sp)+,d2             ; events to get


*------------- check if keyboard event occured and convert key code, if so

               lea      nkc_intout+8,a3      ; ^shift key state
               move     (a3),d0              ; make in NKF?_... compatible
               move.b   d0,(a3)
               clr.b    1(a3)

               move     nkc_intout,d0        ; mask of received events
               moveq.l  #MU_KEYBD,d1         ; the flag to test
               and      d0,d1                ; is it set?
               beq.s    .exit                ; no-> exit

               move     d0,-(sp)             ; save event mask

               move     nkc_intout+10,d0     ; scan code + ASCII code
               moveq.l  #MU_BUTTON|MU_M1|MU_M2,d1  ; any of the events checked
               and      d2,d1                ; which return shift state?
               bne.s    .useiout             ; yes->

               move.l   pshift,a3            ; no: get shift state directly
               move.b   (a3),d1              ; get it
               and      #$f,d1               ; isolate valid bits
               bra.s    .conv

.useiout:      move     nkc_intout+8,d1      ; get shift state from intout
               lsr      #8,d1                ; in TOS format

.conv:         bsr      nk_bioscode          ; convert to BIOS format
               bsr      nk_real_shift        ; try to get original shift flags
               bsr.s    nkc_tconv            ; convert to normalized format
               lea      nk_mci(pc),a0        ; ^function to execute
               bsr      nk_spec              ; special key code handling

               move     d0,nkc_intout+10     ; save keycode
               move     (sp)+,d0             ; restore event mask
               move     d0,nkc_intout        ; and intout (changed by nk_spec)

.exit:         movem.l  (sp)+,d3-d7/a2-a6    ; restore registers
               rts                           ; bye

               .endif   ; .if NKCGEM=1



*START
****************************************************************************
*
*  nkc_tconv: TOS key code converter
*  # G R
*
*  This is the most important function within NKCC: it takes a key code
*  returned by TOS and converts it to the sophisticated normalized format.
*
*  Note: the raw converter does no deadkey handling, ASCII input or
*        Control key emulation.
*
*  In:   D0.L           key code in TOS format:
*                                   0                    1
*                       bit 31:     ignored              ignored
*                       bit 30:     ignored              ignored
*                       bit 29:     ignored              ignored
*                       bit 28:     no CapsLock          CapsLock
*                       bit 27:     no Alternate         Alternate pressed
*                       bit 26:     no Control           Control pressed
*                       bit 25:     no left Shift key    left Shift pressed
*                       bit 24:     no right Shift key   right Shift pressed
*
*                       bits 23...16: scan code
*                       bits 15...08: ignored
*                       bits 07...00: ASCII code (or rubbish in most cases
*                          when Control or Alternate is pressed ...)
*
*  Out:  D0.W           normalized key code:
*                       bits 15...08: flags:
*                                   0                    1
*                       NKF?_FUNC   printable char       "function key"
*                       NKF?_RESVD  ignore it            ignore it
*                       NKF?_NUM    main keypad          numeric keypad
*                       NKF?_CAPS   no CapsLock          CapsLock
*                       NKF?_ALT    no Alternate         Alternate pressed
*                       NKF?_CTRL   no Control           Control pressed
*                       NKF?_LSH    no left Shift key    left Shift pressed
*                       NKF?_RSH    no right Shift key   right Shift pressed
*
*                       bits 07...00: key code
*                       function (NKF?_FUNC set):
*                          < 32: special key (NK_...)
*                          >=32: printable char + Control and/or Alternate
*                       no function (NKF?_FUNC not set):
*                          printable character (0...255!!!)
*
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......   =D0.W
*
****************************************************************************
*END
*
* Usage of the NKF?_RESVD flag:
*
* If the flag is set, the function nkc_cmp(), which evaluates the flag,
* has to check the state of the shift keys when comparing two key codes.
*
* Don't use the flag outside NKCC! Its content and meaning may change
* in future versions without notice!
*
****************************************************************************

nkc_tconv:     movem.l  d3/d4,-(sp)          ; save registers


*------------- separate TOS key code

               move.l   d0,d1                ; TOS key code
               swap     d1                   ; .W = scan code and flags
               move     d1,d2                ; copy
               move     #$ff,d3              ; and-mask
               and      d3,d0                ; .B = ASCII code
               and      d3,d1                ; .B = scan code
               beq      .tos306              ; scancode=zero (key code created
                                             ;  by ASCII input of TOS 3.06)? ->
               and      #$1f00,d2            ; .W = key flags (in high byte)


*------------- decide which translation table to use

               move     d2,d3                ; key flags
               and      #NKFf_SHIFT,d3       ; isolate bits for shift keys
               beq.s    .ktab1               ; shift key pressed? no->

               move.l   pkey_shift,a0        ; yes: use shift table
               bra.s    .ktab3               ; ->

.ktab1:        btst.l   #NKFb_CAPS,d2        ; CapsLock?
               beq.s    .ktab2               ; no->

               move.l   pkey_caps,a0         ; yes: use CapsLock table
               bra.s    .ktab3               ; ->

.ktab2:        move.l   pkey_unshift,a0      ; use unshifted table


*------------- check if scan code is out of range
*
* Illegal scancodes can be used to produce 'macro key codes'. Their format is:
*
* - the scancode must be $84 or larger (should be $ff to work properly with old
*   versions of Mag!x)
* - the ASCII code must be in the range $20...$ff (values below are set to $20
*   by NKCC)
* - Alternate and Control are not used for the normalized key code. However,
*   if at least one of them is non-zero, then the numeric keypad flag will be
*   set in the resulting key code.
*

.ktab3:        cmp.b    #$84,d1              ; illegal scan code?
               blo.s    .ktab4               ; no ->

               move     d2,d1                ; flags
               and      #NKFf_ALT|NKFf_CTRL,d1  ; Alternate or Control?
               beq.s    .special             ; no ->

               or       #NKFf_NUM,d0         ; yes: set numeric keypad flag
               and      #NKFf_CAPS|NKFf_SHIFT,d2   ; mask off both flags

.special:      or       d2,d0                ; combine with ASCII code
               or       #NKFf_FUNC|NKFf_RESVD,d0   ; set function and resvd
               cmp.b    #$20,d0              ; ASCII code in range?
               bhs      .exit                ; yes ->

               move.b   #$20,d0              ; no: use minimum
               bra      .exit                ; ->


*------------- check if Alternate + number: they have simulated scan codes

.ktab4:        cmp.b    #$78,d1              ; scan code of Alt + number?
               blo.s    .scan1               ; no->

               sub.b    #$76,d1              ; yes: calculate REAL scan code
               move.b   (a0,d1),d0           ; fetch ASCII code
               or       #NKFf_ALT,d2         ; set Alternate flag
               bra      .cat_codes           ; -> add flag byte and exit


*------------- check if exception scan code from cursor keypad

.scan1:        lea      xscantab,a1          ; ^exception scan code table

.search_scan:  move     (a1)+,d3             ; NKC and scan code
               bmi.s    .tabend              ; <0? end of table reached ->

               cmp.b    d1,d3                ; scan code found?
               bne.s    .search_scan         ; no: continue search ->

               lsr      #8,d3                ; .B = NKC
               moveq.l  #0,d0                ; mark: key code found
               bra.s    .scan2               ; ->

.tabend:       moveq.l  #0,d3                ; no NKC found yet


*------------- check if rubbish ASCII code and erase it, if so

.scan2:        move.b   (a0,d1),d4           ; ASCII code from translation table
               cmp.b    #32,d0               ; ASCII returned by TOS < 32?
               bhs.s    .scan3               ; no -> can't be rubbish

               cmp.b    d4,d0                ; yes: compare with table entry
               beq.s    .scan3               ; equal: that's ok ->

               moveq.l  #0,d0                ; not equal: rubbish! clear it


*------------- check if ASCII code could only be produced via Alternate key
*              combination

.scan3:        tst.b    d0                   ; ASCII code valid?
               beq.s    .scan4               ; no ->

               cmp.b    d4,d0                ; compare with table entry
               beq.s    .scan4               ; equal: normal key ->

               and      #~NKFf_ALT,d2        ; no: clear Alternate flag


*------------- check if ASCII code found yet, and set it, if not

.scan4:        tst.b    d0                   ; found?
               bne.s    .scan5               ; yes ->

               move.b   d3,d0                ; no: use code from exception table
               bne.s    .scan5               ; now valid? yes ->

               move.b   d4,d0                ; no: use code from transl. table


*------------- check special case: delete key

.scan5:        cmp.b    #127,d0              ; ASCII code of Delete?
               bne.s    .scan6               ; no ->

               move.b   #NK_DEL,d0           ; yes: set according NKC


*------------- check if key is on numeric keypad (via scan code)

.scan6:        cmp.b    #$4a,d1              ; numeric pad scan code range?
               beq.s    .numeric             ; yes ->

               cmp.b    #$4e,d1
               beq.s    .numeric             ; yes ->

               cmp.b    #$63,d1
               blo.s    .scan7               ; no ->

               cmp.b    #$72,d1
               bhi.s    .scan7               ; no ->

.numeric:      or       #NKFf_NUM,d2         ; yes: set numeric bit


*------------- check if "function key" and set bit accordingly

.scan7:        cmp.b    #32,d0               ; ASCII code less than 32?
               bhs.s    .scan8               ; no ->

               or       #NKFf_FUNC,d2        ; yes: set function bit


*------------- check special case: Return or Enter key

               cmp.b    #13,d0               ; Return or Enter key?
               bne.s    .scan8               ; no ->

               btst.l   #NKFb_NUM,d2         ; yes: from the numeric pad?
               beq.s    .scan8               ; no -> it's Return, keep code

               moveq.l  #NK_ENTER,d0         ; yes: it's Enter; new code


*------------- check if function key (F1-F10) via scan code

.scan8:        cmp.b    #$54,d1              ; shift + function key?
               blo.s    .scan9               ; no ->

               cmp.b    #$5d,d1
               bhi.s    .scan9               ; no ->

               sub.b    #$54-$3b,d1          ; yes: scan code for unshifted key
               move     d2,d3                ; shift flags
               and      #NKFf_SHIFT,d3       ; any shift key flag set?
               bne.s    .scan9               ; yes ->
               or       #NKFf_SHIFT,d2       ; no: set both flags

.scan9:        cmp.b    #$3b,d1              ; (unshifted) function key?
               blo.s    .cat_codes           ; no ->

               cmp.b    #$44,d1
               bhi.s    .cat_codes           ; no ->

               move.b   d1,d0                ; yes: calc NKC
               sub.b    #$2b,d0


*------------- final flag handling; mix key code (low byte) and flag byte

.cat_codes:    move.l   pkey_shift,a0        ; ^shifted table
               move.b   (a0,d1),d3           ; get shifted ASCII code
               or       d2,d0                ; mix flags with key code
               bmi.s    .scan10              ; result is "function key"? ->

               and      #NKFf_CTRL+NKFf_ALT,d2  ; Control or Alternate pressed?
               bne.s    .scan11              ; yes ->

.scan10:       move.l   pkey_unshift,a0      ; ^unshifted table
               cmp.b    (a0,d1),d3           ; shifted ASCII = unshifted ASCII?
               beq.s    .scan12              ; yes ->

               bra.s    .exit                ; no ->

.scan11:       or       #NKFf_FUNC,d0        ; Alt/Ctrl + char: set function bit
               move.l   pkey_caps,a0         ; ^CapsLock table
               cmp.b    (a0,d1),d3           ; shifted ASCII = CapsLocked ASCII?
               bne.s    .exit                ; no ->

               move.b   d3,d0                ; yes: use shifted ASCII code

.scan12:       or       #NKFf_RESVD,d0       ; yes: nkc_cmp() has to check
                                             ;  the Shift keys

*------------- restore registers and exit

.exit:         tst      d0                   ; set CCR
               movem.l  (sp)+,d3/d4          ; restore registers
               rts                           ; bye


*------------- special handling for key codes created by TOS' 3.06 ASCII input

.tos306:       and      #NKFf_CAPS,d2        ; isolate CapsLock flag
               or       d2,d0                ; merge with ASCII code
               movem.l  (sp)+,d3/d4          ; restore registers
               rts                           ; bye




*START
****************************************************************************
*
*  nkc_gconv: GEM key code converter
*  # G R
*
*  Why a second key code converter, you ask? Well, in some cases it might
*  happen that the key status byte of the original key code (with states
*  of both Shift keys, Control, Alternate and CapsLock) is lost. Then
*  this converter function must be called, which uses another algorithm
*  to construct the normalized key code.
*
*  Notes:
*  -  the raw converter does no deadkey handling, ASCII input or Control
*     key emulation.
*  -  NKCC does not use this function at all for its own purposes!
*  -  some key combinations cannot be distinguished without the flag byte!
*     For example, "Alternate A" and "Shift Alternate A" produce the same
*     result. Whenever possible, use nkc_tconv()!
*
*  In:   D0.W           key code in GEM format:
*                       bits 15...08: scan code
*                       bits 07...00: ASCII code
*
*  Out:  D0.W           normalized key code (see nkc_tconv() for details)
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_gconv:     movem.l  d4-d7,-(sp)          ; save registers


*------------- find out "real" scan code and convert to TOS key code format

               move     d0,d1                ; copy key code
               lsr      #8,d1                ; scan code in d1.w
               swap     d0                   ; move key code to high word
               move.l   pshift,a0            ; ^key state flags
               move.b   (a0),d0              ; get 'em
               and      #NKFf_CAPS>>8,d0     ; isolate CapsLock flag
               lea      scan_trans,a0        ; ^scan code translation table

.trans:        move.l   (a0)+,d2             ; get next entry
               beq.s    .endtrans            ; end of table? ->

               cmp.b    d1,d2                ; scan code found?
               bne.s    .trans               ; no ->

               lsr      #8,d2                ; "real" scan code
               move.b   d2,d1                ; use it
               swap     d2                   ; flags to set
               or       d2,d0                ; set them

.endtrans:     swap     d0                   ; move flags up and key code down
               moveq.l  #0,d7                ; clear for word operation
               move.b   d0,d7                ; copy ASCII code
               lsl.l    #8,d0                ; shift flags and scan code up
               move     d7,d0                ; restore ASCII code


*------------- try to restore some of the key flags (shift/control/alternate)

               move.l   pkey_unshift,a0      ; ^unshifted key table
               move.b   (a0,d1),d4           ; get unshifted code
               move.l   pkey_shift,a0        ; ^shifted key table
               move.b   (a0,d1),d5           ; get shifted code
               move.l   pkey_caps,a0         ; ^CapsLock key table
               move.b   (a0,d1),d6           ; get CapsLock code

               bsr      nk_ascmatch          ; try to find ASCII code
               beq.s    .conv                ; found ->

               move.b   #$1f,d2              ; maybe modified by Control key...
               and.b    d2,d4                ; change ASCII code accordingly
               and.b    d2,d5
               and.b    d2,d6
               bsr      nk_ascmatch          ; and try again
               bne.s    .notfnd              ; no match ->

.setctrl:      or.l     #(NKFf_FUNC|NKFf_CTRL)<<16,d0    ; Control was pressed
               bra.s    .conv                ; ->

.notfnd:       move.l   pkey_unshift,a0      ; not found: restore all three
               move.b   (a0,d1),d2           ;  ASCII codes
               move.l   pkey_shift,a0
               move.b   (a0,d1),d5
               move.l   pkey_caps,a0
               move.b   (a0,d1),d6
               bsr.s    .translate           ; translate unshifted code

               move.b   d2,d4                ; use translated code
               move.b   d5,d2                ; translate shifted code
               bsr.s    .translate

               move.b   d2,d5                ; use translated code
               move.b   d6,d2                ; translate shifted code
               bsr.s    .translate

               move.b   d2,d6                ; use translated code
               bsr      nk_ascmatch          ; last try to locate ASCII code
               beq.s    .setctrl             ; found ->

               tst.b    d0                   ; not found: ASCII code is 0?
               bne.s    .conv                ; no ->

               btst.l   #NKFb_CTRL+16,d0     ; Control key flag already set?
               bne.s    .conv                ; yes ->

                                             ; no: must be Alternate
               or.l     #(NKFf_FUNC|NKFf_ALT)<<16,d0


*------------- do conversion to normalized format

.conv:         bsr      nkc_tconv            ; do TOS key code conversion

               movem.l  (sp)+,d4-d7          ; restore registers
               tst      d0                   ; set CCR
               rts                           ; bye


*  This small sub function changes the ASCII code in D2.B due to the
*  ASCII code translation table asc_trans. The result is returned in D2.B,
*  registers D7 and A0 are corrupted.

.translate:    lea      asc_trans,a0         ; ^translation table

.transloop:    move     (a0)+,d7             ; get both codes
               beq.s    .ret                 ; end of table? ->

               cmp.b    d2,d7                ; found?
               bne.s    .transloop           ; no ->

               lsr      #8,d7                ; yes: get translated code
               move.b   d7,d2                ; and use it

.ret:          rts                           ; bye



*START
****************************************************************************
*
*  nkc_n2tos: convert normalized key codes back to TOS format
*  # G R
*
*  In some cases you might have to have key codes in the original TOS format
*  again, as returned by the GEMDOS functions Cconin(), Crawcin() or the BIOS
*  function Bconin(). Use nkc_n2tos() to convert them. For a detailed
*  description of the returned format consult the header of the function
*  nkc_tconv().
*
*  In:   D0.W           key code in normalized format
*
*  Out:  D0.L           key code in TOS format:
*                       bits 24...31: shift key flags
*                       bits 23...16: scan code
*                       bits 08...15: reserved (0)
*                       bits 00...07: ASCII code
*        CCR            set according content of D0.L
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......   =D0.L
*
****************************************************************************
*END


nkc_n2tos:     move     d0,d1                ; normalized key code
               and      #NKFf_FUNC|NKFf_ALT|NKFf_CTRL,d1 ; isolate flags
               cmp      #NKFf_FUNC,d1        ; only function flag set?
               bne.s    .ktab0               ; no ->

               cmp.b    #$20,d0              ; ASCII code >= $20?
               blo.s    .ktab0               ; no ->


*------------- macro key

               move     d0,d1                ; keep normalized key code
               and.l    #NKFf_CAPS|NKFf_SHIFT,d0   ; isolate usable flags
               btst.l   #NKFb_NUM,d1         ; numeric keypad flag set?
               beq.s    .mackey              ; no ->

               or       #NKFf_ALT|NKFf_CTRL,d0  ; yes: set Alternate + Control

.mackey:       or.b     #$ff,d0              ; scan code always $ff
               swap     d0                   ; flags and scan code in upper word
               move.b   d1,d0                ; ASCII code
               bra      .exit                ; ->


*------------- select system key table to use

.ktab0:        move     d0,d1                ; normalized key code
               and      #NKFf_SHIFT,d1       ; isolate bits for shift keys
               beq.s    .ktab1               ; shift key pressed? no->

               lea      n_to_scan_s,a1       ; ^default translation table
               move.l   pkey_shift,a0        ; yes: use shift table
               bra.s    .ktab3               ; ->

.ktab1:        lea      n_to_scan_u,a1       ; ^unshifted translation table
               btst.l   #NKFb_CAPS,d0        ; CapsLock?
               beq.s    .ktab2               ; no->

               move.l   pkey_caps,a0         ; yes: use CapsLock table
               bra.s    .ktab3               ; ->

.ktab2:        move.l   pkey_unshift,a0      ; use unshifted table


*------------- handling for ASCII codes >= 32

.ktab3:        cmp.b    #32,d0               ; ASCII code < 32?
               blo.s    .lowascii            ; yes ->

               bsr      nk_findscan          ; find scan code
               bne.s    .found               ; found ->

               btst.l   #NKFb_FUNC,d0        ; function flag set?
               beq.s    .notfound            ; no ->

               move.l   a0,d1                ; save a0
               lea      tolower,a0           ; ^upper->lower case table
               moveq.l  #0,d2                ; clear for word operation
               move.b   d0,d2                ; ASCII code
               move.b   (a0,d2),d0           ; get lowercased ASCII code
               move.l   d1,a0                ; restore a0
               bsr      nk_findscan          ; try to find scan code again
               bne.s    .found               ; found ->


*------------- unknown source: treat key code as it was entered using the
*              TOS 3.06 direct ASCII input

.notfound:     moveq.l  #0,d1                ; not found: clear for word op.
               move.b   d0,d1                ; unchanged ASCII code
               and      #$1f00,d0            ; keep shift flags only
               swap     d0                   ; -> high word (scan code = 0)
               move     d1,d0                ; low word: ASCII code
               bra      .exit                ; ->


*------------- handling for ASCII codes < 32

.lowascii:     btst.l   #NKFb_FUNC,d0        ; function key?
               bne.s    .func                ; yes ->

               and      #$10ff,d0            ; clear all flags except CapsLock
               bra.s    .notfound            ; ->

.func:         moveq.l  #0,d1                ; clear for word operation
               move.b   d0,d1                ; ASCII code (0...$1f)
               move     d1,d2                ; copy
               move.b   (a1,d1),d1           ; get scan code
               bne.s    .getascii            ; valid? ->

               moveq    #0,d0                ; invalid key code!! return 0
               bra      .exit                ; ->

.getascii:     lea      n_to_scan_u,a1       ; ^unshifted translation table
               move.b   (a1,d2),d2           ; get scan code from unshifted tab.
               move.b   (a0,d2),d0           ; get ASCII from system's table


* register contents:
*
* d0.b         ASCII code
* d1.b         scan code
* d0.hb        NKCC flags
*

.found:        move     d0,d2                ; flags and ASCII code
               and      #$1f00,d0            ; isolate shift flags
               move.b   d1,d0                ; merge with scan code
               swap     d0                   ; -> high byte
               clr      d0                   ; erase low word
               move.b   d2,d0                ; restore ASCII code


*------------- handling for Control key flag

               btst.l   #NKFb_CTRL,d2        ; control key flag set?
               beq.s    .alternate           ; no ->

               cmp.b    #$4b,d1              ; scan code = "cursor left"?
               bne.s    .scanchk2            ; no ->

               add.l    #$280000,d0          ; change scan code to $73
               clr.b    d0                   ; erase ASCII code
               bra.s    .exit                ; ->

.scanchk2:     cmp.b    #$4d,d1              ; scan code = "cursor right"?
               bne.s    .scanchk3            ; no ->

               add.l    #$270000,d0          ; change scan code to $74
               clr.b    d0                   ; erase ASCII code
               bra.s    .exit                ; ->

.scanchk3:     cmp.b    #$47,d1              ; scan code = "ClrHome"?
               bne.s    .ascchk              ; no ->

               add.l    #$300000,d0          ; change scan code to $77
; keep ASCII code in this case! What a mess...
               bra.s    .exit                ; ->

.ascchk:       lea      asc_trans,a0         ; ^ASCII translation table

.ascloop:      move     (a0)+,d1             ; get next entry
               beq.s    .noctrlasc           ; end of table ->

               cmp.b    d0,d1                ; ASCII code found?
               bne.s    .ascloop             ; no -> continue search

               lsr      #8,d1                ; yes: get translated code
               move.b   d1,d0                ; use it
               bra.s    .exit                ; ->

.noctrlasc:    and.b    #$1f,d0              ; mask off upper 3 bits
               bra.s    .exit                ; ->


*------------- handling for Alternate key flag

.alternate:    btst.l   #NKFb_ALT,d2         ; alternate key flag set?
               beq.s    .exit                ; no ->

               cmp.b    #2,d1                ; top row on main keyboard?
               blo.s    .alphachk            ; no ->

               cmp.b    #$d,d1
               bhi.s    .alphachk            ; no ->

               add.l    #$760000,d0          ; yes: change scan code
               clr.b    d0                   ; and erase ASCII code
               bra.s    .exit                ; ->

.alphachk:     cmp.b    #'A',d0              ; alpha-characters?
               blo.s    .exit                ; no ->

               cmp.b    #'z',d0
               bhi.s    .exit                ; no ->

               cmp.b    #'Z',d0
               bls.s    .ascii0              ; yes ->

               cmp.b    #'a',d0
               blo.s    .exit                ; no ->

.ascii0:       clr.b    d0                   ; alpha-character: clear ASCII code

.exit:         tst.l    d0                   ; set CCR
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_n2gem: convert normalized key codes back to GEM format
*  # G R
*
*  Similar to nkc_n2tos(), this function converts normalized key codes back
*  to the operating system's format. The result is a key code as returned
*  by the AES functions evnt_keybd() respectively evnt_multi().
*
*  In:   D0.W           key code in normalized format
*
*  Out:  D0.W           key code in GEM format:
*                       bits 08...15: scan code
*                       bits 00...07: ASCII code
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_n2gem:     bsr      nkc_n2tos            ; convert
               moveq.l  #0,d1                ; clear for word operation
               move.b   d0,d1                ; ASCII code
               ror.l    #8,d0                ; scan code now in high byte
               move.b   d1,d0                ; put ASCII into low byte
               tst      d0                   ; set CCR
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_kstate: return state of Shift/Control/Alternate/CapsLock in
*              normalized format
*  # G R
*
*  This is a very *FAST* function which returns the state of the Shift/
*  Control/Alternate and CapsLock keys in normalized format.
*
*  In:   -
*
*  Out:  D0.W           normalized key flags:
*                                   0                    1
*                       NKF?_CAPS   no CapsLock          CapsLock
*                       NKF?_ALT    no Alternate         Alternate pressed
*                       NKF?_CTRL   no Control           Control pressed
*                       NKF?_LSH    no left Shift key    left Shift pressed
*                       NKF?_RSH    no right Shift key   right Shift pressed
*
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          w**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_kstate:    move.l   pshift,a0            ; ^shift state variable
               move.b   (a0),d0              ; get its contents
               and      #$1f,d0              ; isolate valid bits
               lsl      #8,d0                ; make it NKC compatible
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_timer: return current value of 200 Hz system clock
*  # G R
*
*  This is a very *FAST* function which returns the content of the 200 Hz
*  system clock.
*
*  In:   -
*
*  Out:  D0.L           current 200 HZ system clock value
*
*  Reg:  D:01234567   A:01234567   CCR
*          w**.....     **......    *
*
****************************************************************************
*END

nkc_timer:     move.l   sysclock,d0          ; just get value
               rts                           ; bye bye



*START
****************************************************************************
*
*  nkc_cmp: compare two key codes
*  # G R
*
*  nkc_cmp() compares key codes. What for, you ask? A simple "if key_code1
*  = key_code2" would also do it? No! This function follows some specific
*  rules, which improve the flexibility of key code comparism.
*
*  One of the key codes passed to nkc_cmp() is called the "reference key
*  code". The other is the "test key code", which is got from nkc_conin()
*  or nkc_multi(). Some flags of the reference code are treated a special
*  way:
*
*  NKF?_IGNUM (same as NKF?_RESVD)
*     if set, the numeric keypad flag doesn't matter
*
*  NKF?_CAPS (CapsLock)
*     if set, the case of the ASCII code doesn't matter
*
*  NKFf_SHIFT (both Shift key flags)
*     if BOTH shift flags are set, the combination of shift key flags in
*     the test key code doesn't matter: only one shift flag has to be set,
*     no matter which one.
*
*  In:   D0.W           reference key code
*        D1.W           key code to test
*
*  Out:  D0.W           flag: 1 = key codes match
*                             0 = key codes don't match
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          u**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_cmp:       movem.l  d3-d4,-(sp)          ; save registers
               move     d0,d2                ; reference key code
               eor      d1,d2                ; XORed with test key code
               beq      .match               ; identical: key codes match

               bmi.s    .nomatch             ; func flag differs -> don't match

               tst      d0                   ; "function" key?
               bmi.s    .rfunc               ; yes ->


*------------- printable character

               btst.l   #NKFb_IGNUM,d0       ; ignore numeric keypad flag?
               bne.s    .chkn1               ; yes ->

               btst.l   #NKFb_NUM,d2         ; numeric key flags equal?
               bne.s    .nomatch             ; no ->

.chkn1:        lea      toupper,a0           ; ^upper case conversion table
               moveq.l  #0,d3                ; clear for word operation
               move.b   d0,d3                ; ASCII code of ref key code
               move.b   (a0,d3),d4           ; get CapsLocked reference key code

               cmp.b    d0,d1                ; ASCII code equal?
               beq.s    .stest               ; yes ->

               btst.l   #NKFb_CAPS,d0        ; no: ignore case?
               beq.s    .nomatch             ; no -> codes don't match

               move.b   d1,d3                ; ASCII of test key code
               cmp.b    (a0,d3),d4           ; CapsLocked comparism
               beq.s    .match               ; equal ->

               bra.s    .nomatch             ; not equal ->

.stest:        btst.l   #NKFb_RESVD,d1       ; check Shift keys?
               beq.s    .match               ; no ->

.stest2:       move     #NKFf_SHIFT,d4       ; Shift key flags
               move     d2,d3                ; XORed key codes
               and      d4,d3                ; shift flags equal?
               beq.s    .match               ; yes ->

               move     d0,d3                ; reference key code
               and      d4,d3                ; isolate Shift flags
               cmp      d3,d4                ; both set?
               bne.s    .nomatch             ; no -> codes don't match

               move     d1,d3                ; check if any pressed in test code
               and      d4,d3
               bne.s    .match               ; yes ->

               bra.s    .nomatch             ; no ->


*------------- "function key"

.rfunc:        move     d2,d3                ; XORed key codes
               and      #NKFf_ALT|NKFf_CTRL,d3  ; check Alternate and Control
               bne.s    .nomatch             ; different -> codes don't match

               cmp.b    #32,d0               ; special key or character?
               bhs.s    .rchar               ; character->

               cmp.b    d0,d1                ; special key codes equal?
               beq.s    .stest2              ; yes ->

               bra.s    .nomatch             ; no ->

.rchar:        btst.l   #NKFb_IGNUM,d0       ; ignore numeric keypad flag?
               bne.s    .chkn2               ; yes ->

               btst.l   #NKFb_NUM,d2         ; numeric key flags equal?
               bne.s    .nomatch             ; no ->

.chkn2:        cmp.b    d0,d1                ; ASCII codes equal?
               beq.s    .stest               ; yes ->

.nomatch:      movem.l  (sp)+,d3-d4          ; restore registers
               moveq.l  #0,d0                ; codes don't match
               rts                           ; bye

.match:        movem.l  (sp)+,d3-d4          ; restore registers
               moveq.l  #1,d0                ; codes match
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_vlink: link function to XBRA vector list
*  # G U
*
*  This function can be used to change system vectors and let them point
*  to own functions, using a standard method. The vector, which should be
*  changed, is described by the contents of D0.L and D1.W. It can be
*  either a standard vector number, e.g. 2 for the bus error exception
*  vector, or the absolute address of the vector, e.g. $502 for the screen
*  dump vector. The function to install must have the following header:
*
*  .dc.b    "XBRA"         magic longword
*  .dc.b    "myID"         four ASCII character ID of the function
*                          (NKCC uses "NKCC", for example)
*  .dc.l    0              buffer for the old vector content
*  function: ...           start of the function code
*
*  The function should end with:
*
*  move.l   function-4(pc),-(sp)
*  rts
*
*
*  Note: in NKXM_ADR mode, this function automatically switches (temporary)
*        to Supervisor mode to prevent bus errors
*
*
*  In:   D0.L           vector descriptor
*        D1.W           mode:
*                       NKXM_NUM = D0.L contains a vector number
*                       NKXM_ADR = D0.L contains a vector address
*        A0.L           ^function to install (NOT ^XBRA header!)
*
*  Out:  -4(A0.L).L     old content of vector
*
*  Reg:  D:01234567   A:01234567   CCR
*          ***.....     **......    *
*
****************************************************************************
*END


nkc_vlink:     tst      d1                   ; which mode?
               bne.s    .adr                 ; address ->


*------------- install function by vector number

               move.l   a2,-(sp)             ; save register

               move.l   a0,-(sp)             ; ^function
               move     d0,-(sp)             ; vector number
               move     #5,-(sp)             ; Setexc

               moveq.l  #-1,d1               ; ^function: don't change
               move.l   d1,-(sp)             ;  vector
               move     d0,-(sp)             ; vector number
               move     #5,-(sp)             ; Setexc

               trap     #13                  ; BIOS: get old vector
               addq     #8,sp                ; clean stack

               move.l   4(sp),a0             ; ^function
               move.l   d0,-4(a0)            ; save old vector
               trap     #13                  ; BIOS: install routine
               addq     #8,sp                ; clean stack

               move.l   (sp)+,a2             ; restore register
               rts                           ; bye


*------------- install function by vector address

.adr:          movem.l  a2-a4,-(sp)          ; save registers

               move.l   a0,a3                ; ^function
               move.l   d0,a4                ; ^vector

               clr.l    -(sp)                ; use usp as ssp
               move     #$20,-(sp)           ; Super
               trap     #1                   ; GEMDOS
               move.l   d0,2(sp)             ; save old sp
               move     #$20,(sp)            ; Super opcode for next call

               move.l   (a4),-4(a3)          ; save old vector content
               move.l   a3,(a4)              ; install function

               trap     #1                   ; GEMDOS (back to User mode)
               addq     #6,sp                ; clean stack

               movem.l  (sp)+,a2-a4          ; restore registers
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_vunlink: unlink function from XBRA vector list
*  # G U
*
*  nkc_vunlink() removes a function which was installed using the XBRA method.
*  For details see nkc_link(). If the XBRA list was corrupted, the function
*  aborts with an error code. This happens, when a non-XBRA routine is
*  installed on the same vector after the nkc_vlink() call of the function
*  to remove.
*
*  Note: the function automatically switches (temporary) to Supervisor mode
*        to prevent bus errors
*
*  In:   D0.L           vector descriptor
*        D1.W           mode:
*                       NKXM_NUM = D0.L contains a vector number
*                       NKXM_ADR = D0.L contains a vector address
*        A0.L           ^function to remove (NOT ^XBRA header!)
*
*  Out:  D0.W           status:
*                       0 = OK
*                       -1 = can't remove (XBRA list corrupted)
*        CCR            set according content of D0.W
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......   =D0.W
*
****************************************************************************
*END

nkc_vunlink:   movem.l  d6-d7/a2/a6,-(sp)    ; save registers

               move.l   d0,d7                ; save vector descriptor
               move.l   a0,a6                ; save function address
               move     d1,d6                ; save mode
               bne.s    .adr                 ; address mode ->


*------------- check vector content by number

               moveq.l  #-1,d0               ; get current vector
               move.l   d0,-(sp)
               move     d7,-(sp)             ; vector number
               move     #5,-(sp)             ; Setexc
               trap     #13                  ; BIOS
               addq     #8,sp                ; clean stack

               cmp.l    d0,a6                ; function still on top?
               bne.s    .search              ; no ->

.restore:      move.l   -4(a6),-(sp)         ; restore old vector
               move     d7,-(sp)             ; vector number
               move     #5,-(sp)             ; Setexc
               trap     #13                  ; BIOS
               addq     #8,sp                ; clean stack
               bra.s    .okstat              ; exit


*------------- check vector content by address

.adr:          clr.l    -(sp)                ; use usp as ssp
               move     #$20,-(sp)           ; Super
               trap     #1                   ; GEMDOS
               move.l   d0,2(sp)             ; save old sp
               move     #$20,(sp)            ; Super opcode for next call

               move.l   d7,a0                ; vector address
               move.l   (a0),d0              ; vector content
               cmp.l    d0,a6                ; function still on top?
               bne.s    .search              ; no ->

               move.l   -4(a6),(a0)          ; yes: remove it
               bra.s    .okstat              ; exit


*------------- somebody installed a handler (hope he used XBRA ...)

.search:       move.l   d0,a0                ; ^current handler
               move.l   #'XBRA',d0           ; XBRA ID

.find_hnd:     cmp.l    -12(a0),d0           ; XBRA ID before routine?
               bne.s    .error               ; no!!! can't remove function!!

               move.l   -4(a0),a1            ; ^next entry in XBRA list
               cmp.l    a1,a6                ; next entry in list our function?
               beq.s    .found               ; yes ->

               move.l   a1,a0                ; no
               bra.s    .find_hnd            ; continue search

.found:        move.l   -4(a6),-4(a0)        ; yes: remove function

.okstat:       moveq.l  #0,d7                ; no error
               bra.s    .exit

.error:        moveq.l  #-1,d7               ; error! can't unlink function!

.exit:         tst      d6                   ; address mode?
               beq.s    .exit2               ; no ->

               trap     #1                   ; yes: switch to user mode first
               addq     #6,sp                ; with a GEMDOS Super() call

.exit2:        move     d7,d0                ; status code
               movem.l  (sp)+,d6-d7/a2/a6    ; restore registers
               rts                           ; bye




*START
****************************************************************************
*
*  nkc_toupper: convert character to upper case
*  # G
*
*  A character is converted to upper case. Examples:
*
*  'a'   ->   'A'          (converted)
*  '/'   ->   '/'          (unchanged; there's no upper case version for this)
*  'A'   ->   'A'          (unchanged; already converted)
*
*
*  In:   D0.B           any character
*
*  Out:  D0.B           character converted to upper case
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......    *
*
****************************************************************************
*END

nkc_toupper:   lea      toupper,a0           ; ^upper case translation table
               and      #$ff,d0              ; high byte = 0 for word operation
               move.b   (a0,d0),d0           ; convert
               rts                           ; bye



*START
****************************************************************************
*
*  nkc_tolower: convert character to lower case
*  # G
*
*  The counterpart of nkc_toupper(). A character is converted to lower case.
*
*  In:   D0.B           any character
*
*  Out:  D0.B           character converted to lower case
*
*  Reg:  D:01234567   A:01234567   CCR
*          U**.....     **......    *
*
****************************************************************************
*END

nkc_tolower:   lea      tolower,a0           ; ^lower case translation table
               and      #$ff,d0              ; high byte = 0 for word operation
               move.b   (a0,d0),d0           ; convert
               rts                           ; bye



****************************************************************************
*                            LOCAL DATA SECTION                            *
****************************************************************************

               .data

*  exception scan code table for cursor block keys
*
*  first entry.B:  NKCC key code
*  second entry.B: scan code returned by TOS
*
*  the table is terminated with both entries -1

xscantab:      .dc.b    NK_UP       ,  $48   ; cursor up
               .dc.b    NK_DOWN     ,  $50   ; cursor down
               .dc.b    NK_LEFT     ,  $4b   ; cursor left
               .dc.b    NK_LEFT     ,  $73   ; Control cursor left
               .dc.b    NK_RIGHT    ,  $4d   ; cursor right
               .dc.b    NK_RIGHT    ,  $74   ; Control cursor right
               .dc.b    NK_INS      ,  $52   ; Insert
               .dc.b    NK_CLRHOME  ,  $47   ; ClrHome
               .dc.b    NK_CLRHOME  ,  $77   ; Control ClrHome
               .dc.b    NK_HELP     ,  $62   ; Help
               .dc.b    NK_UNDO     ,  $61   ; Undo
               .dc.w    -1



*  deadkey table
*
*  first entry.B:  deadkey option mask (NKSf_D_...), 16 bits shifted down
*  second entry.W: ASCII code of deadkey
*  third entry.L:  ^deadkey match table
*
*  the table is terminated with an option mask of 0

deadtab:       .dc.w    NKSf_D_CIRCUM >> 16
               .dc.w    '^'
               .dc.l    d_circum

               .dc.w    NKSf_D_TILDE >> 16
               .dc.w    '~'
               .dc.l    d_tilde

               .dc.w    NKSf_D_AGUI >> 16
               .dc.w    '\''
               .dc.l    d_agui

               .dc.w    NKSf_D_GRAVE >> 16
               .dc.w    '`'
               .dc.l    d_grave

               .dc.w    NKSf_D_UMLAUT >> 16
               .dc.w    'π'
               .dc.l    d_umlaut

               .dc.w    NKSf_D_QUOTE >> 16
               .dc.w    '\"'
               .dc.l    d_umlaut

               .dc.w    NKSf_D_SMOERE >> 16
               .dc.w    '¯'
               .dc.l    d_smoere

               .dc.w    NKSf_D_CEDIL >> 16
               .dc.w    ','
               .dc.l    d_cedil

               .dc.w    NKSf_D_SLASH >> 16
               .dc.w    '/'
               .dc.l    d_slash

               .dc.w    0



*  deadkey match tables
*
*  first entry.B:  ASCII code generated by pressing deadkey and key code
*  second entry.B: key code (of the key which must be pressed directly after
*                  the deadkey)
*
*  the tables are terminated with both entries 0

d_circum:      .dc.b    '^','^'
               .dc.b    'É','a'
               .dc.b    'à','e'
               .dc.b    'å','i'
               .dc.b    'ì','o'
               .dc.b    'ñ','u'
               .dc.w    0

d_tilde:       .dc.b    '~','~'
               .dc.b    '§','n'
               .dc.b    '•','N'
               .dc.b    '∞','a'
               .dc.b    '±','o'
               .dc.b    '∑','A'
               .dc.b    '∏','O'
               .dc.w    0

d_agui:        .dc.b    $27,$27              ; ' characters
               .dc.b    'Ç','e'
               .dc.b    'ê','E'
               .dc.b    '†','a'
               .dc.b    '°','i'
               .dc.b    '¢','o'
               .dc.b    '£','u'
               .dc.w    0

d_grave:       .dc.b    '`','`'
               .dc.b    'Ö','a'
               .dc.b    'ä','e'
               .dc.b    'ç','i'
               .dc.b    'ï','o'
               .dc.b    'ó','u'
               .dc.b    '∂','A'
               .dc.w    0

d_umlaut:      .dc.b    'π','π'
               .dc.b    $22,$22              ; " characters
               .dc.b    'Ñ','a'
               .dc.b    'â','e'
               .dc.b    'ã','i'
               .dc.b    'î','o'
               .dc.b    'Å','u'
               .dc.b    'ò','y'
               .dc.b    'é','A'
               .dc.b    'ô','O'
               .dc.b    'ö','U'
               .dc.w    0

d_smoere:      .dc.b    '¯','¯'
               .dc.b    'Ü','a'
               .dc.b    'è','A'
               .dc.w    0

d_cedil:       .dc.b    ',',','
               .dc.b    'á','c'
               .dc.b    'Ä','C'
               .dc.w    0

d_slash:       .dc.b    '/','/'
               .dc.b    '≥','o'
               .dc.b    '≤','O'
               .dc.b    '´','2'
               .dc.b    '¨','4'
               .dc.w    0



               .if      NKCGEM=1

*  AES parameter block

aespb:          .dc.l   nkc_contrl
                .dc.l   0                    ; set by nkc_init()
                .dc.l   nkc_intin
                .dc.l   nkc_intout
                .dc.l   nkc_adrin
                .dc.l   nkc_adrout

*  VDI parameter block

vdipb:          .dc.l   nkc_contrl
                .dc.l   nkc_intin
                .dc.l   nkc_ptsin
                .dc.l   nkc_intout
                .dc.l   nkc_ptsout


*  double click time table (values given in 1/200 s)

timetab:        .dc.l   85                   ; 0.425 s
                .dc.l   63                   ; 0.315 s
                .dc.l   49                   ; 0.245 s
                .dc.l   42                   ; 0.210 s
                .dc.l   30                   ; 0.150 s

               .endif   ;  .if NKCGEM=1



*  lower case to upper case conversion table
*  (array of 256 unsigned bytes)

toupper:
               .dc.b    $00,$01,$02,$03,$04,$05,$06,$07
               .dc.b    $08,$09,$0a,$0b,$0c,$0d,$0e,$0f
               .dc.b    $10,$11,$12,$13,$14,$15,$16,$17
               .dc.b    $18,$19,$1a,$1b,$1c,$1d,$1e,$1f
               .dc.b    " !",$22,"#$%&",$27,"()*+,-./0123456789:;<=>?"
               .dc.b    "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[",$5c,"]^_"
               .dc.b    "`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~"
               .dc.b    "ÄöêÉé∂èÄàâäãåçéèêííìôïñóòôöõúùûü"
               .dc.b    "†°¢£••¶ß®©™´¨≠ÆØ∑∏≤≤µµ∂∑∏π∫ªºΩæø"
               .dc.b    "¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ"
               .dc.b    "‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛ˇ"


*  upper case to lower case conversion table
*  (array of 256 unsigned bytes)

tolower:
               .dc.b    $00,$01,$02,$03,$04,$05,$06,$07
               .dc.b    $08,$09,$0a,$0b,$0c,$0d,$0e,$0f
               .dc.b    $10,$11,$12,$13,$14,$15,$16,$17
               .dc.b    $18,$19,$1a,$1b,$1c,$1d,$1e,$1f
               .dc.b    " !",$22,"#$%&",$27,"()*+,-./0123456789:;<=>?"
               .dc.b    "@abcdefghijklmnopqrstuvwxyz[",$5c,"]^_"
               .dc.b    "`abcdefghijklmnopqrstuvwxyz{|}~"
               .dc.b    "áÅÇÉÑÖÜáàâäãåçÑÜÇëëìîïñóòîÅõúùûü"
               .dc.b    "†°¢£§§¶ß®©™´¨≠ÆØ∞±≥≥¥¥Ö∞±π∫ªºΩæø"
               .dc.b    "¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ"
               .dc.b    "‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛ˇ"

* note for both tables:
*
* $22 = " character
* $27 = ' character
* $5c = \ character (used as escape by the MadMac assembler)


*  scan code translation table
*
*  first entry.W : shift flags (NKFf_CTRL/SHIFT/ALT/FUNC), 8 bits shifted down
*  second entry.B: real scan code (index into key table)
*  third entry.B : simulated scan code (set by OS when the flags specified
*                  above are set)
*
*  The table is terminated with all entries 0.

scan_trans:    .dc.w    NKFf_SHIFT>>8        ; Shift F1
               .dc.b    $3b,$54
               .dc.w    NKFf_SHIFT>>8        ; Shift F2
               .dc.b    $3c,$55
               .dc.w    NKFf_SHIFT>>8        ; Shift F3
               .dc.b    $3d,$56
               .dc.w    NKFf_SHIFT>>8        ; Shift F4
               .dc.b    $3e,$57
               .dc.w    NKFf_SHIFT>>8        ; Shift F5
               .dc.b    $3f,$58
               .dc.w    NKFf_SHIFT>>8        ; Shift F6
               .dc.b    $40,$59
               .dc.w    NKFf_SHIFT>>8        ; Shift F7
               .dc.b    $41,$5a
               .dc.w    NKFf_SHIFT>>8        ; Shift F8
               .dc.b    $42,$5b
               .dc.w    NKFf_SHIFT>>8        ; Shift F9
               .dc.b    $43,$5c
               .dc.w    NKFf_SHIFT>>8        ; Shift F10
               .dc.b    $44,$5d
               .dc.w    (NKFf_FUNC|NKFf_CTRL)>>8   ; Control cursor left
               .dc.b    $4b,$73
               .dc.w    (NKFf_FUNC|NKFf_CTRL)>>8   ; Control cursor right
               .dc.b    $4d,$74
               .dc.w    (NKFf_FUNC|NKFf_CTRL)>>8   ; Control ClrHome
               .dc.b    $47,$77
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #1
               .dc.b    $02,$78
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #2
               .dc.b    $03,$79
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #3
               .dc.b    $04,$7a
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #4
               .dc.b    $05,$7b
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #5
               .dc.b    $06,$7c
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #6
               .dc.b    $07,$7d
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #7
               .dc.b    $08,$7e
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #8
               .dc.b    $09,$7f
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #9
               .dc.b    $0a,$80
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #10
               .dc.b    $0b,$81
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #11
               .dc.b    $0c,$82
               .dc.w    (NKFf_FUNC|NKFf_ALT)>>8    ; Alternate top row #12
               .dc.b    $0d,$83
               .dc.l    0                    ; terminator


*  ASCII code translation table for Control key
*
*  first entry.B:  modified ASCII code returned by TOS
*  second entry.B: original ASCII code as stored in key table
*
*  The table is terminated with both entries 0

asc_trans:     .dc.b    0,'2'                ; Control '2' becomes ASCII 0
               .dc.b    $1e,'6'              ; Control '6' becomes ASCII $1e
               .dc.b    $1f,'-'              ; Control '-' becomes ASCII $1f
               .dc.b    $a,$d                ; Control Return/Enter: $d -> $a
               .dc.w    0                    ; terminator


*  normalized key code -> scan code translation table
*  for unshifted key codes
*  indexed by function code (NK_...)

n_to_scan_u:   .dc.b    $00                  ; invalid key code
               .dc.b    $48                  ; cursor up
               .dc.b    $50                  ; cursor down
               .dc.b    $4d                  ; cursor right
               .dc.b    $4b                  ; cursor left
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $0e                  ; Backspace
               .dc.b    $0f                  ; Tab
               .dc.b    $72                  ; Enter
               .dc.b    $52                  ; Insert
               .dc.b    $47                  ; ClrHome
               .dc.b    $1c                  ; Return
               .dc.b    $62                  ; Help
               .dc.b    $61                  ; Undo
               .dc.b    $3b                  ; function key #1
               .dc.b    $3c                  ; function key #2
               .dc.b    $3d                  ; function key #3
               .dc.b    $3e                  ; function key #4
               .dc.b    $3f                  ; function key #5
               .dc.b    $40                  ; function key #6
               .dc.b    $41                  ; function key #7
               .dc.b    $42                  ; function key #8
               .dc.b    $43                  ; function key #9
               .dc.b    $44                  ; function key #10
               .dc.b    $00                  ; reserved!
               .dc.b    $01                  ; Esc
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $53                  ; Delete

*  normalized key code -> scan code translation table
*  for shifted key codes
*  indexed by function code (NK_...)

n_to_scan_s:   .dc.b    $00                  ; invalid key code
               .dc.b    $48                  ; cursor up
               .dc.b    $50                  ; cursor down
               .dc.b    $4d                  ; cursor right
               .dc.b    $4b                  ; cursor left
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $0e                  ; Backspace
               .dc.b    $0f                  ; Tab
               .dc.b    $72                  ; Enter
               .dc.b    $52                  ; Insert
               .dc.b    $47                  ; ClrHome
               .dc.b    $1c                  ; Return
               .dc.b    $62                  ; Help
               .dc.b    $61                  ; Undo
               .dc.b    $54                  ; function key #1
               .dc.b    $55                  ; function key #2
               .dc.b    $56                  ; function key #3
               .dc.b    $57                  ; function key #4
               .dc.b    $58                  ; function key #5
               .dc.b    $59                  ; function key #6
               .dc.b    $5a                  ; function key #7
               .dc.b    $5b                  ; function key #8
               .dc.b    $5c                  ; function key #9
               .dc.b    $5d                  ; function key #10
               .dc.b    $00                  ; reserved!
               .dc.b    $01                  ; Esc
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $00                  ; reserved!
               .dc.b    $53                  ; Delete



****************************************************************************
*                             LOCAL BSS SECTION                            *
****************************************************************************

               .bss


*              key code handler

pkey_unshift:  .ds.l    1                    ; ^unshifted key table
pkey_shift:    .ds.l    1                    ; ^shift key table
pkey_caps:     .ds.l    1                    ; ^CapsLock table
pshift:        .ds.l    1                    ; ^shift state system variable
sflags:        .ds.l    1                    ; special key flags
prvkey:        .ds.w    1                    ; previous key code
prvvalid:      .ds.b    1                    ; non-zero: prvkey is valid
               .even


*              button event handler

               .if      NKCGEM=1

bvar:           .ds.b   BI                   ; button event info block
tendtime:       .ds.l   1                    ; timer event end value
prvtime:        .ds.l   1                    ; previous timer event value
vdihnd:         .ds.w   1                    ; handle of VDI workstation
multibuf:       .ds.w   16+2                 ; buffer for evnt_multi parameters
buthnd:         .ds.b   1                    ; non-zero:button handler installed
                .even



*              other stuff

kbdiorec:       .ds.l   1                    ; ^keyboard Iorec structure
iohead:         .ds.w   1                    ; NKCC's head pointer

               .endif   ; .if NKCGEM=1

sysclock:      .ds.l    1                    ; copy of 200 Hz system clock
timerflag:     .ds.b    1                    ; non-zero:200 Hz timer installed
               .even



*START
****************************************************************************
*                            GLOBAL BSS SECTION                            *
****************************************************************************
*END

               .bss

*START
*  GEM parameter arrays
*  (needed if using nkc_amulti())

               .if      NKCGEM=1

nkc_contrl:     .ds.w   32                   ; control array
nkc_intin:      .ds.w   32                   ; integer input array
nkc_intout:     .ds.w   32                   ; integer output array
nkc_adrin:      .ds.l   32                   ; address input array
nkc_adrout:     .ds.l   32                   ; address output array
nkc_ptsin:      .ds.l   32                   ; pointers input array
nkc_ptsout:     .ds.l   32                   ; pointers output array

               .endif   ; .if NKCGEM=1
*END

*START
* End Of File
*END

