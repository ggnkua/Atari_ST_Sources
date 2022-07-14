|
| Nomenclature
|
| Regular assembly labels are prefixed with an underscore. All labels without
| a leading underscore are execution tokens for the inner interpreter. This
| convention is useful because execution tokens are the common case.
|
| Glossary
|
|   TOS  -  top element of stack (value cached in register)
|   XT   -  execution token
|   IP   -  interpreter pointer (points at XT to execute next)
|   TIB  -  terminal-input buffer
|   CP   -  compile pointer (where a new XT or dict entry goes)
|
| Register use
|
| d4   TOS (top stack element)
| d5   data stack position
| d6   return stack position
| a4   IP (interpreter pointer)
| a5   current XTA
| a6   data stack base pointer
|
| The data and return stacks grow upwards. The stack position is not a pointer
| but an offset relative to respective start address. This simplifies bounds
| checking. The first two cells at '_dstack_lo' remain zero because the TOS is
| cached in r11, and elements are pushed with pre increment.
|

CELL_BYTES = 4   | length of a single cell in bytes
XTA_BYTES  = 4   | length of execution-token address in bytes

| data and return stack offsets relative to BSS base
RSTACK_REL = _rstack_lo - _dstack_lo


||
|| Utility macros
||

|
| Print immediate value as hex at a separate line (for debugging)
|
.macro DBG_HEX imm
	move.l \imm,d0
	bsr    _emit_hex
	move.l #0xd,d0
	bsr    _emit_char
	move.l #0xa,d0
	bsr    _emit_char
.endm

|
| Compile a list of execution-token addresses
|
.macro .. elements:vararg
.irp element,\elements
	.dc.l \element
.endr
.endm


||
|| Main program
||

.text

_start:
	movea.l sp,a6       | sp: base page
	move.l  4(a6),a5
	move.l  0xc(a5),d0  | text length
	add.l   0x14(a5),d0 | data length
	add.l   0x1c(a5),d0 | bass length
	addi.l  #0x1100,d0  | stack + basepage

	move.l  d0,d1       | setup stack pointer
	add.l   a5,d1
	bclr.l  #1,d1
	movea.l d1,sp

	move.l  d0,-(sp)    | release unused memory
	move.l  a5,-(sp)
	clr.w   -(sp)
	move.w  #0x4a,-(sp) | mshrink
	trap    #1
	lea 12(sp),sp

_recover:
	lea     _main,a4       | initial interpreter pointer
	movea.l #0,a5
	lea     _dstack_lo,a6  | data stack base address

	clr.l d4
	clr.l d5
	clr.l d6

	bra _next

_main:
	.. xtalit interpret_one_word eval_xt store
	.. xtalit do_console mainloop_xt store
	.. xtalit pterm bye_xt store
	.. xtalit emit_console emit_xt store
	.. current_init current store
	.. cp_init cp store
	.. app_start app_bytes evaluate
	.. cr
	.. reset_tib
1:	.. mainloop_xt at execute branch 1b


||
|| Inner interpreter
||

.macro NEXT
	move.l (a4)+,a5         | fetch current XTA, advance IP
	move.l (a5),a0
	jmp    (a0)             | jump to routine pointed by the code field
.endm

_next:
	NEXT

_dolist:                                        | a5: current XTA
	addq.l #CELL_BYTES,d6
	move.l a4,RSTACK_REL(a6,d6.w)   | push IP to return stack
	lea    4(a5),a4                 | set IP to first list item
	NEXT


||
|| Primitives
||

.macro CODE_XT label
\label :
	.dc.l . + 4  | point to the following instruction
.endm

.macro CHECK_DSTACK_OVERFLOW
.endm

.macro CHECK_DSTACK_ONE_ITEM
.endm

.macro CHECK_DSTACK_TWO_ITEMS
.endm

.macro PUSHD reg
	CHECK_DSTACK_OVERFLOW
	addq.w  #CELL_BYTES,d5          | advance data-stack position
	move.l  d4,(a6,d5.w)            | push TOS to data stack
	move.l  \reg,d4                 | update TOS
.endm

.macro POPD
	CHECK_DSTACK_ONE_ITEM
	move.l  (a6,d5.w),d4            | fetch stack element to TOS
	subq.w  #CELL_BYTES,d5          | decrease data-stack position
.endm

.macro POPD_NEXT
	POPD
	NEXT
.endm

|
| Data-stack primitives
|

CODE_XT drop   | ( w -- )
	POPD_NEXT

CODE_XT dup   | ( w -- w w )
	CHECK_DSTACK_ONE_ITEM
	PUSHD   d4
	NEXT

CODE_XT swap   | ( w1 w2 -- w2 w1 )
	CHECK_DSTACK_TWO_ITEMS
	move.l (a6,d5.w),d0
	move.l d4,(a6,d5.w)
	move.l d0,d4
	NEXT

CODE_XT over   | ( w1 w2 -- w1 w2 w1 )
	CHECK_DSTACK_TWO_ITEMS
	move.l (a6,d5.w),d0
	PUSHD  d0
	NEXT

CODE_XT qdup   | dup top of stack if its is not zero
	CHECK_DSTACK_ONE_ITEM
	tst.l  d4
	beq    1f
	PUSHD  d4
1:	NEXT

|
| Return stack
|

.macro CHECK_RSTACK_OVERFLOW
.endm

.macro CHECK_RSTACK_ONE_ITEM
.endm

.macro CHECK_RSTACK_TWO_ITEMS
.endm

CODE_XT tor   | ( w -- )  push TOS to return stack
	CHECK_RSTACK_OVERFLOW
	addq.w #CELL_BYTES,d6
	move.l d4,RSTACK_REL(a6,d6.w)
	POPD_NEXT

CODE_XT rat   | ( -- w )  copy top of return stack to data stack
	CHECK_RSTACK_ONE_ITEM
	move.l RSTACK_REL(a6,d6.w),d0
	PUSHD  d0
	NEXT

CODE_XT tworat   | ( -- w w )  copy top two items of return stack to data stack
	CHECK_RSTACK_TWO_ITEMS
	move.l RSTACK_REL(a6,d6.w),d0
	PUSHD  d0
	move.l RSTACK_REL-CELL_BYTES(a6,d6.w),d0
	PUSHD  d0
	NEXT

CODE_XT rfrom   | ( -- w )  move top of return stack to the data stack
	CHECK_RSTACK_ONE_ITEM
	move.l RSTACK_REL(a6,d6.w),d0
	PUSHD  d0
	subq.w #CELL_BYTES,d6
	NEXT

|
| Comparison
|

CODE_XT zless   | ( n -- f )  return true if n is negative
	CHECK_DSTACK_ONE_ITEM
	tst.l   d4
	blt     1f
	moveq.l #0,d4
	NEXT
1:	moveq.l #-1,d4
	NEXT

.macro CODE_XT_CMP label op  | ( a b -- f )  compare top-most stack elements
CODE_XT \label
	CHECK_DSTACK_TWO_ITEMS
	move.l  d4,d0
	POPD
	cmp.l   d0,d4
	\op     1f
	moveq.l #0,d4
	NEXT
1:	moveq.l #-1,d4
	NEXT
.endm

CODE_XT_CMP equal beq.s  | true if a = b
CODE_XT_CMP ult   bcs.s  | true if unsigned a < b
CODE_XT_CMP slt   blt.s  | true if signed a < b

|
| Literals embedded in XT lists
|
| Number literals and XT address literals are 32-bit values.
|

CODE_XT dolit   | fetch 32-bit number literal following the execution token
	move.l (a4)+,d0
	PUSHD d0
	NEXT

CODE_XT xtalit   | fetch 32-bit XTA literal following the execution token
	clr.l  d0
	move.l (a4)+,d0
	PUSHD  d0
	NEXT

CODE_XT branch
	move.l (a4),a5        | a4 points at address literal of branch target
	move.l a5,a4
	NEXT

CODE_XT qbranch   | ( f -- ) branch if flag is zero
	CHECK_DSTACK_ONE_ITEM
	tst.l  d4
	bne    1f
	move.l (a4),a5        | a4 points at address literal of branch target
	move.l a5,a4
	POPD_NEXT
1:	addq.l #XTA_BYTES,a4  | next IP if branch not taken (skip XT address literal)
	POPD_NEXT

CODE_XT next   | ( -- ) decrement top of return stack, branch if not below zero
	CHECK_RSTACK_ONE_ITEM
	tst.l  RSTACK_REL(a6,d6.w)
	beq    1f                      | exit loop if counter is zero
	subi.l #1,RSTACK_REL(a6,d6.w)  | decrement counter
	move.l (a4),a5                 | take branch
	move.l a5,a4
	NEXT
1:	addq.l #XTA_BYTES,a4           | skip branch-target literal
	subq.w #CELL_BYTES,d6          | drop counter from return stack
	NEXT

|
| Arithmetics and logical operations
|

CODE_XT umplus   | ( w w -- w cy )
	CHECK_DSTACK_TWO_ITEMS
	add.l  d4,(a6,d5.w)
	scs    d4
	moveq.l #1,d0
	and.l  d0,d4
	NEXT

.macro CODE_XT_BITWISE label op
CODE_XT \label
	CHECK_DSTACK_TWO_ITEMS
	move.l (a6,d5.w),d0
	\op    d0,d4
	subq.w #CELL_BYTES,d5
	NEXT
.endm

CODE_XT_BITWISE and and.l
CODE_XT_BITWISE or  or.l
CODE_XT_BITWISE xor eor.l

.macro CODE_XT_BITMOD label op
CODE_XT \label
	CHECK_DSTACK_ONE_ITEM
	\op    d4
	NEXT
.endm

CODE_XT_BITMOD negate neg.l
CODE_XT_BITMOD not    not.l

.macro CODE_XT_OP label op
CODE_XT \label
	CHECK_DSTACK_TWO_ITEMS
	move.l d4,d0
	POPD
	\op    d0,d4
	NEXT
.endm

CODE_XT_OP lshift  lsl.l  | ( w u -- w ) shift w by u bits to the left
CODE_XT_OP rshift  lsr.l  | ( w u -- w ) shift w by u bits to the right
CODE_XT_OP arshift asr.l  | ( w u -- w ) shift w by u bits to the right
CODE_XT_OP mul     mulu.l | ( u u -- u ) product of two unsigned numbers
CODE_XT_OP div     divs.l | ( s s -- u ) quotient of two signed numbers
CODE_XT_OP plus    add.l  | ( u u -- u ) sum of two numbers

|
| Memory access
|

CODE_XT store   | ( w a -- ) store 'w' to address 'a'
	CHECK_DSTACK_TWO_ITEMS
	move.l d4,a0
	move.l (a6,d5.w),(a0)
	POPD
	POPD_NEXT

CODE_XT at   | ( a -- w ) load 'w' from address 'a'
	CHECK_DSTACK_ONE_ITEM
	move.l d4,a0
	move.l (a0),d4
	NEXT

CODE_XT cstore   | ( c b -- ) store char 'c' to byt address 'b'
	CHECK_DSTACK_TWO_ITEMS
	move.l d4,a0
	move.b 3(a6,d5.w),(a0)
	POPD
	POPD_NEXT

CODE_XT cat   | ( b -- c ) load char 'c' from byte address 'b'
	CHECK_DSTACK_ONE_ITEM
	move.l d4,a0
	clr.l  d4
	move.b (a0),d4
	NEXT

CODE_XT xtastore   | ( xt a -- ) store XTA at 'a'
	CHECK_DSTACK_TWO_ITEMS
	move.l d4,a0
	move.l (a6,d5.w),(a0)
	POPD
	POPD_NEXT

CODE_XT xtaat   | ( a -- xta ) load XTA from address 'a'
	CHECK_DSTACK_ONE_ITEM
	move.l d4,a0
	move.l (a0),d4
	NEXT

|
| Input / output
|

| d0: ASCII value of character to print
_emit_char:
	movem.l d0-a6,-(sp)
	move.w  d0,-(sp)
	move.w  #2,-(sp)
	trap    #1
	addq.l  #4,sp
	movem.l (sp)+,d0-a6
	rts

| d0: 32-bit value to print as hexadecimal number
_emit_hex:
	movem.l d0-d4,-(sp)
	move.l  d0,d1     | keep original value in d1
	move.w  #32-4,d2  | shift value
	move.w  #8-1,d4   | loop count
1:	move.l  d1,d0
	lsr.l   d2,d0
	andi.l  #0xf,d0
	move.w  #'0',d3
	cmpi.w  #9,d0
	ble     2f
	move.w  #'A'-10,d3
2:	add.w   d3,d0
	bsr     _emit_char
	subq.w  #4,d2
	dbf     d4,1b
	movem.l (sp)+,d0-d4
	rts

CODE_XT ask_key   | ( -- false | c true )
	moveq.l #0,d3       | d3: returned flag
	move.w  #0xb,-(sp)  | C_CONIS checks if key is pending
	trap    #1
	addq.l  #2,sp
	tst.l   d0
	beq     1f
	moveq.l #-1,d3      | true
	move.w  #7,-(sp)    | C_RAWCIN retrieves key code
	trap    #1
	addq.l  #2,sp
	andi.l  #0xff,d0    | keep ASCII value only
	PUSHD   d0
1:	PUSHD   d3
	NEXT

CODE_XT rawdot  | print top stack element as hex number
	CHECK_DSTACK_ONE_ITEM
	move.l d4,d0
	bsr    _emit_hex
	POPD_NEXT

CODE_XT emit_console  | ( w -- ) output ASCII value
	CHECK_DSTACK_ONE_ITEM
	move.l d4,d0
	bsr    _emit_char
	POPD_NEXT

|
| Utilities
|

CODE_XT depth   | return number of stack elements
	clr.l d0
	move.w d5,d0
	lsr.w #2,d0
	PUSHD d0
	NEXT

CODE_XT exit  | counterpart of _dolist
	move.l  RSTACK_REL(a6,d6.w),a4  | fetch return IP from rstack
	subq.w  #CELL_BYTES,d6
	NEXT

CODE_XT execute   | execute XT found at TOS
	CHECK_DSTACK_ONE_ITEM
	move.l  d4,a5          | d1: current XTA, expected by _dolist
	POPD
	move.l  (a5),a0
	jmp     (a0)           | jump to routine pointed by the code field

CODE_XT reset
	bra _recover

CODE_XT aligned   | ( a n -- a ) align 'a' to an address multiple of 'n'
	CHECK_DSTACK_TWO_ITEMS
	move.l d4,d0
	subq.l #1,d0
	POPD
	add.l  d0,d4
	not.l  d0   | align mask is !(n - 1)
	and.l  d0,d4
	NEXT


||
|| Numeric constant execution tokens
||

.macro CONST_XT label value
	.align CELL_BYTES
\label :
	.dc.l  _dolist
	..     dolit
	.long  \value
	..     exit
.endm

CONST_XT zero         0
CONST_XT one          1
CONST_XT two          2
CONST_XT nine         9
CONST_XT ten          10
CONST_XT sixteen      16
CONST_XT thirty_one   31
CONST_XT neg_one      "-1"
CONST_XT true         "-1"
CONST_XT false        0
CONST_XT bl_char      ' '
CONST_XT a_char       'a'
CONST_XT z_char       'z'
CONST_XT tab_char     9
CONST_XT cr_char      13
CONST_XT nl_char      '\n'
CONST_XT bs_char      8          | backspace
CONST_XT del_char     127        | del
CONST_XT reset_char   18         | control-r
CONST_XT bye_char     4          | control-d
CONST_XT zero_char    '0'
CONST_XT nine_char    '9'
CONST_XT minus_char   '-'
CONST_XT offset_9_a   'a'-'9'-1  | offset between ASCII codes for '0' and 'a'
CONST_XT pad          _pad_hi
CONST_XT cell         CELL_BYTES
CONST_XT xta          XTA_BYTES
CONST_XT stack_start  _dstack_lo + 2*CELL_BYTES
CONST_XT app_start    _app_lo
CONST_XT app_bytes    _app_hi - _app_lo
CONST_XT cp_init      _bss_end
CONST_XT dolist_ptr   _dolist


||
|| Higher-level execution tokens
||

|
| Header of list execution token
|
.macro LIST_XT label
	.align XTA_BYTES
\label :
	.dc.l _dolist
.endm

|
| Shorthand for simple list execution tokens without branches,
| exiting at the end
|
.macro XT label tokens:vararg
LIST_XT \label
	.. \tokens exit
.endm

XT xta_aligned_store  store

XT twodrop  drop drop
XT twodup   over over
XT rot      tor swap rfrom swap
XT nip      swap drop
XT inc      one plus
XT sub      negate plus
XT incvar   dup at inc swap store
XT varplus  dup at rot plus swap store

XT cellinc       cell plus
XT celldec       cell sub
XT cells         dup plus dup plus
XT cell_aligned  cell aligned
XT xta_aligned   xta  aligned


| ( s -- b n ) return byte address 'b' and length 'n' for counted string 's'
XT count   dup inc swap cat

|
| The algorithms for umdiv_mod and ummul are transcribed from "eForth and Zen",
| pages 53 and 55.
|

| ( udl udh u -- ur uq )  divide double unsigned number, return remainder and quotient
LIST_XT umdiv_mod
	.. twodup ult
	.. qbranch 1f
	..   negate
	..   thirty_one tor
	     | for
2:	..     tor
	..     dup umplus
	..     tor tor dup umplus
	..     rfrom plus dup
	..     rfrom rat swap
	..     tor umplus
	..     rfrom or
	..     qbranch 3f
	..       tor drop
	..       inc rfrom
	..       branch 4f
	       | else
3:	..       drop
	       | then
4:	..     rfrom
	..   next 2b
	..   drop swap exit
1:	.. drop twodrop neg_one dup
	.. exit

| ( u1 u2 -- udl udh ) return double product of two unsigned numbers
LIST_XT ummul
	.. zero swap
	.. thirty_one tor
1:	..   dup umplus tor tor
	..   dup umplus
	..   rfrom plus
	..   rfrom
	..   qbranch 2f
	..     tor over umplus rfrom plus
2:	.. next 1b
	.. rot drop exit

| ( u ul uh -- f ) true if u is within ul (inclusive) and uh (exclusive)
XT within  over sub tor sub rfrom ult

| ( n - n ) absolute value of 'n'
LIST_XT abs
	.. dup zless qbranch 1f negate
1:	.. exit

| ( a1 a2 u -- ) copy u bytes from a1 to a2
CODE_XT cmove
	move.l d4,d7 ; POPD
	move.l d4,a2 ; POPD
	move.l d4,a1 ; POPD
	subq.w #1,d7
	blt    2f
1:	move.b (a1)+,(a2)+
	dbf    d7,1b
2:	NEXT


|
| Variables
|

XT dovar   rfrom cell_aligned

.macro VAR_XT label, value
	.align XTA_BYTES
\label :
	.dc.l  _dolist
	..     dovar
	.dc.l  \value
.endm

VAR_XT cp    0   | current pointer to end of dictionary
VAR_XT base  10  | radix for input and output of numbers
VAR_XT hld   0   | pointer into _pad buffer

VAR_XT latest_dentry 0   | pointer to dictionary entry under construction
VAR_XT eval_xt       0   | interpret_one_word or compile_one_word
VAR_XT emit_xt       0   | XT used to output one character
VAR_XT mainloop_xt   0   | XT repeatedly called in main loop
VAR_XT bye_xt        0   | XT called at exit

XT state_compile    xtalit compile_one_word   eval_xt store
XT state_interpret  xtalit interpret_one_word eval_xt store


||
|| Outer interpreter
||

XT emit     emit_xt at execute
XT space    bl_char emit
XT cr       nl_char emit cr_char emit
XT hex      sixteen base, store
XT decimal  ten base store

| ( u -- c ) convert digit 'u' to ASCII character
XT digit  nine over ult offset_9_a and plus zero_char plus

| ( n base -- n/base c ) extract least significant digit from 'n'
XT extract  zero swap umdiv_mod swap digit

| ( -- ) prepare output of a number, reset HLD to end of pad
XT fmt_start  pad hld store

| ( c -- ) insert character into the pad buffer
XT hold  hld at one sub dup hld store cstore

| ( u -- u/base ) extract one digit from 'u' into pad buffer
XT fmt_digit  base at extract hold

| ( u -- 0 ) convert 'u' into digits in the pad buffer
LIST_XT fmt_number
1:	.. fmt_digit dup
	.. qbranch 2f
	.. branch 1b
2:	.. exit

| ( n -- ) prepend sign to the pad buffer if 'n' is negative
LIST_XT fmt_sign
	.. zless qbranch 1f
	.. minus_char hold
1:	.. exit

| ( w -- b u ) prepare the output string for 'type'
XT fmt_end  drop hld at pad over sub

| ( b u -- ) output 'u' characters starting at byte address 'b'
LIST_XT type
	.. dup qbranch 2f    | skip loop if u = 0
	.. one sub tor       | init for-loop counter at return stack
1:	..   dup cat emit    | emit character
	..   inc             | increment b
	.. next 1b
	.. drop exit
2:	.. twodrop exit

| ( n -- b u ) convert signed integer to string in pad
XT signed_str  dup tor abs fmt_start fmt_number rfrom fmt_sign fmt_end

| ( w -- ) display unsigned number preceded by a space
XT udot  fmt_start fmt_number fmt_end space type

| ( w -- ) display integer preceded by a space
LIST_XT dot
	.. base at ten xor qbranch 1f
	.. udot exit
1:	.. signed_str space type exit

LIST_XT show_stack
	.. depth qbranch 3f             | check depth 0
	.. depth two ult not qbranch 2f | check depth 1
	.. depth two sub tor            | for-loop counter
	.. stack_start zero             | ( base offset )
1:	..   twodup plus at dot         | print stack element
	..   cell plus                  | increment byte offset
	.. next 1b
	.. twodrop                      | drop ( base offset )
2:	.. dup dot                      | print TOS
3:	.. exit

XT domsg   rfrom count type

.macro MSG_XT label text
LIST_XT \label
	.. domsg
	.dc.b  2f - 1f
1:	.ascii "\text"
2:	.align CELL_BYTES
.endm

MSG_XT msg_prompt  "> "
MSG_XT msg_reset   "reset!"
MSG_XT msg_hyphen  "-"
MSG_XT msg_quote   "'"
MSG_XT msg_colon   ":"

.macro MSG_XT_WORDS words:vararg
.irp word,\words
MSG_XT msg_\word "\word"
.endr
.endm

MSG_XT_WORDS data stack underflow overflow invalid bus access unaligned return
MSG_XT_WORDS unknown word missing token after tick
MSG_XT_WORDS variable create name


||
|| Dictionary
||

LAST_DENTRY = 0

IMMEDIATE = 1  | flag word to be interpreted in compile state

|
| Create static dictionary entry
|
.macro DENTRY name xta immediate=0
	.dc.l  LAST_DENTRY            | pointer to previous dictionary entry
LAST_DENTRY = . - 4
	.dc.l  (\xta + \immediate)    | XTA, bit 0 holds immediate flag
	.dc.b  2f - 1f                | length of name
1:	.ascii "\name"
2:	.align CELL_BYTES
.endm

.macro DENTRIES names:vararg
.irp name,\names
DENTRY \name \name
.endr
.endm

| utilities
DENTRIES depth words execute reset
DENTRY "'"       tick

| stack operations
DENTRIES drop dup swap over nip rot
DENTRY "2drop"   twodrop
DENTRY "2dup"    twodup
DENTRY "?dup"    qdup
DENTRY ">r"      tor
DENTRY "r@"      rat
DENTRY "r>"      rfrom

| arithmetic and logic operations
DENTRIES negate abs not and or xor lshift rshift arshift
DENTRY "um+"     umplus
DENTRY "+"       plus
DENTRY "-"       sub
DENTRY "um/mod"  umdiv_mod
DENTRY "um*"     ummul
DENTRY "*"       mul
DENTRY "/"       div
DENTRY "1+"      inc

| output
DENTRIES base decimal hex emit space cr count type hold
DENTRY "."       dot
DENTRY "u."      udot
DENTRY "<#"      fmt_start
DENTRY "#>"      fmt_end
DENTRY "#"       fmt_digit
DENTRY "#s"      fmt_number
DENTRY "sign"    fmt_sign
DENTRY ".s"      show_stack

| comparison
DENTRIES within
DENTRY "0<"      zless
DENTRY "u<"      ult
DENTRY "<"       slt
DENTRY "="       equal

| memory access
DENTRIES cell cells cmove aligned
DENTRY "!"       store
DENTRY "@"       at
DENTRY "c!"      cstore
DENTRY "c@"      cat
DENTRY "+!"      varplus
DENTRY "cell+"   cellinc
DENTRY "cell-"   celldec

| compiler
DENTRIES here exit variable create dolit xtalit allot
DENTRY ":"        colon
DENTRY ";"        semicolon       IMMEDIATE
DENTRY "["        state_interpret IMMEDIATE
DENTRY "]"        state_compile   IMMEDIATE
DENTRY ","        compile_cell    IMMEDIATE
DENTRY "c,"       compile_byte    IMMEDIATE
DENTRY "COMPILE," compile_xta     IMMEDIATE

| interpreter
DENTRIES evaluate do_console emit_console reset_tib pterm bye
DENTRY "'mainloop"  mainloop_xt
DENTRY "'bye"       bye_xt
DENTRY "'emit"      emit_xt

| control structures
DENTRY "IF"      compile_if    IMMEDIATE
DENTRY "THEN"    compile_then  IMMEDIATE
DENTRY "BEGIN"   compile_begin IMMEDIATE
DENTRY "AGAIN"   compile_again IMMEDIATE
DENTRY "UNTIL"   compile_until IMMEDIATE
DENTRY "FOR"     compile_for   IMMEDIATE
DENTRY "NEXT"    compile_next  IMMEDIATE
DENTRY "AFT"     compile_aft   IMMEDIATE

| system functions
DENTRIES bye supenter supreturn getrez cconin

XT dentry_name      cellinc cellinc           | return name ptr (counted string)
XT dentry_xta       cellinc xtaat one not and | return XTA without immediate flag
XT dentry_immediate cellinc xtaat one and     | return immediate flag

| ( -- ) list dictionary content
LIST_XT words
	.. current at
1:	.. dup qbranch 2f
	.. dup dentry_name count space type  | print word
	.. at                                | traverse list
	.. branch 1b
2:	.. drop exit

| ( a n -- a | f )
CODE_XT dentry_by_name
	move.l  d4,d0 ; POPD           | d0: number of characters
	move.l  d4,a0                  | a0: pointer to first character
	moveq.l #0,d4                  | d4: result, false by default
	lea     current+8,a1           | a1: pointer to head pointer of dentry list

1:	| loop over dentries

	move.l  (a1),a1                | traverse list
	tst.l   a1                     | detect end of list
	beq     3f

	| check if lengths differ
	cmp.b   8(a1),d0
	bne     1b                     | mismatch, continue with next entry

	| compare characters
	move.l  a0,a2                  | a2: first character of search string
	lea     9(a1),a3               | a3: first character of dentry name
	move.w  d0,d7                  | d7: loop counter
	subq.w  #1,d7
	blt     5f                     | match if both strings are empty
2:	move.b  (a2)+,d2
	cmp.b   (a3)+,d2
	dbne    d7,2b
	bne     1b                     | mismatch, continue with next entry

	| match
	move.l  a1,d4                  | return dentry pointer
	NEXT

3:	moveq.l #0,d4                  | return false
	NEXT


||
|| Parser and interpreter
||

XT ask_newline         dup nl_char equal swap cr_char equal or
XT ask_space           bl_char equal
XT ask_tab             tab_char equal
XT ask_whitespace      dup ask_space  over ask_tab or  swap ask_newline or
XT ask_non_whitespace  ask_whitespace not

| ( a n xta -- count ) return number of matching characters
LIST_XT scan
	.. swap                           | ( a xta n )
	.. qdup qbranch 1f                | handle n = 0
	..   one sub tor                  | ( a xta )
	..   zero swap                    | ( a count xta )
	     | for
2:	..     tor                        | save xta at return stack
	..     twodup plus cat            | access character at a + count
	..     rat execute not qbranch 3f | evaluate match function xta
	..       rfrom drop               | drop xta
	..       swap drop                | drop a
	..       rfrom drop exit          | drop for-loop index
3:	..     inc                        | increment count
	..     rfrom                      | ( a count xta )
	..   next 2b
	..   drop                         | drop xta
	..   swap drop exit
1:	.. drop drop zero exit

| ( a n -- count ) return up to 'n' number of whitespace characters at 'a'
XT num_whitespace  xtalit ask_whitespace scan

| ( a n -- count ) return up to 'n' number of non-whitespace characters at 'a'
XT num_non_whitespace  xtalit ask_non_whitespace scan

| ( a n count -- a+count n-count )
XT advance  dup tor sub swap rfrom plus swap

XT skip_whitespace  twodup num_whitespace advance

| ( c -- false | n true )
LIST_XT ask_digit
	.. dup zero_char nine_char inc within over a_char z_char inc within or qbranch 1f
	.. dup a_char ult not offset_9_a and sub
	.. zero_char sub
	.. dup base at ult qbranch 1f   | bound check against base
	.. true exit
1:	.. drop false exit

| ( a n -- false | n true )
LIST_XT ask_number
	.. qdup qbranch 4f              | check n = 0
	.. one sub tor                  | for-loop counter
	.. zero                         | ( a result )
1:	..   swap dup cat               | ( result a c )
	..   ask_digit qdup qbranch 3f
	..     drop                     | drop true flag -> ( result a digit )
	..     rot                      | ( a digit result )
	..     base at ummul
	..     zero equal qbranch 2f    | check for multiply overflow
	..     plus                     | result*base + digit
	..     tor inc rfrom            | increment a -> ( a result )
	.. next 1b
	.. swap drop                    | drop a, keep result
	.. true exit
2:	.. drop
3:	.. rfrom twodrop
4:	.. drop
	.. false exit


VAR_XT parse_ptr 0   | current parse pointer
VAR_XT parse_len 0   | number of present bytes at 'parse_ptr'

| ( -- a wordlen ) | ( -- false )
LIST_XT scan_one_word
	.. parse_ptr at parse_len at     | ( a n )
	.. twodup num_whitespace advance
	.. qdup qbranch 1f
	.. twodup                        | ( a n a n )
	.. num_non_whitespace            | ( a n wordlen )
	.. tor over swap rat             | ( a a n wordlen )
	.. advance                       | ( a a+wordlen n-wordlen )
	.. parse_len store
	.. parse_ptr store
	.. rfrom exit                    | ( a wordlen )
1:	.. false exit                    | ( false )

|
| Interpret 'parse_len' bytes in buffer at 'parse_ptr'
|
| Both variables are updated while interpreting the buffer.
|
LIST_XT interpret_one_word   | ( -- f )
	.. scan_one_word
	.. qdup qbranch 2f               | end of buffer
	.. twodup                        | remember word for error message
	   | try to parse word as number
	.. twodup ask_number qdup qbranch 1f
	..   drop                        | drop true flag returned by ask_number
	..   tor twodrop twodrop rfrom   | keep number on stack
	..   true exit
1:	   | try to lookup word in dictionary
	.. dentry_by_name                | ( ... xta | f )
	.. qdup qbranch 3f
	.. rot rot twodrop               | no error, drop word info
	.. try_exec_dentry
	.. true exit
2:	.. drop false exit
3:	.. cr msg_unknown space msg_word space msg_quote type msg_quote cr
	.. false exit

| ( -- xta ) lookup XTA for next word in parse buffer
LIST_XT tick
1:	.. scan_one_word                 | ( a n ) | ( false )
	.. qdup qbranch 2f               | end of buffer
	.. twodup                        | remember word for error message
	   | try to lookup word in dictionary
	.. dentry_by_name dentry_xta     | ( xta | f )
	.. qdup qbranch 3f               | check for unexpected end of buffer
	.. rot rot twodrop               | no error, drop word info
	.. exit                          | ( xta )
2:	.. cr msg_missing space msg_token space msg_after space msg_tick cr exit
3:	.. cr msg_unknown space msg_word space msg_quote type msg_quote cr exit

XT incr_one   dup at inc swap store
XT incr_cell  dup at cell plus swap store

XT xta_align_cp   cp at xta_aligned cp store
XT cell_align_cp  cp at cell_aligned cp store
XT advance_cp     cp at plus cp store

| ( n -- ) append cell-sized value at CP
XT compile_cell  cp at xta_aligned_store  cp incr_cell

| ( n -- ) append XT address at CP
XT compile_xta  cp at xtastore  xta advance_cp

| ( b -- ) append byte at CP
XT compile_byte  cp at cstore  cp incr_one

| ( a n -- ) append counted string at CP
LIST_XT compile_string
	.. dup compile_byte      | marshal count byte
	.. tor cp at rat cmove   | copy characters ( n )
	.. rfrom advance_cp      | advance CP by string length
	.. exit

XT compile_exit  xtalit exit compile_xta

| ( xta -- ) set XT field of latest dictionary entry
XT update_latest_dentry_xta      latest_dentry at cell plus xtastore
XT mark_latest_dentry_immediate  latest_dentry at cell plus dup xtaat one or xtastore
XT commit_latest_dentry          latest_dentry at current store

XT allot  cell_aligned advance_cp

| ( -- xta ) XTA matching the current CP
XT here  cp at

| ( a n -- ) create dictionary entry for word ( a n )
LIST_XT create_dentry
	.. cell_align_cp
	.. cp at latest_dentry store     | remember dictionary under construction
	.. current at compile_cell       | set next-entry pointer
	.. zero compile_xta              | XTA field will be filled out below
	.. compile_string
	.. cell_align_cp                 | align start of LIST_XT
	.. here
	.. update_latest_dentry_xta
	.. dolist_ptr compile_xta        | compile XT header
	.. exit

| ( a n -- ) create dictionary entry ( a n )
LIST_XT create
	.. scan_one_word                 | ( a n ) | ( false )
	.. qdup qbranch 2f               | end of buffer
	.. create_dentry
	.. xtalit dovar compile_xta
	.. cell_align_cp
	.. commit_latest_dentry
	.. exit
2:	.. cr msg_missing space msg_create space msg_name cr exit

| ( a n -- ) create dictionary entry for variable ( a n )
LIST_XT variable
	.. scan_one_word                 | ( a n ) | ( false )
	.. qdup qbranch 2f               | end of buffer
	.. create_dentry
	.. xtalit dovar compile_xta
	.. cell_align_cp
	.. zero compile_cell
	.. commit_latest_dentry
	.. exit
2:	.. cr msg_missing space msg_variable space msg_name cr exit

| ( -- ) create new dictionary entry for next word in parse buffer
LIST_XT colon
	.. scan_one_word                 | ( a n ) | ( false )
	.. qdup qbranch 2f               | end of buffer
	.. create_dentry
	.. state_compile
	.. exit
2:	.. cr msg_missing space msg_token space msg_after space msg_colon cr exit

LIST_XT semicolon
	.. compile_exit
	.. commit_latest_dentry
	.. state_interpret
	.. exit

LIST_XT compile_one_word
	.. scan_one_word
	.. qdup qbranch 2f               | end of buffer
	.. twodup                        | remember word for error message
	   | try to parse word as number
	.. twodup ask_number qdup qbranch 1f
	..   drop                        | drop true flag returned by ask_number
	..   xtalit dolit compile_xta    | compile dolit
	..   compile_cell                | ...followed by number
	..   twodrop twodrop
	..   true exit
1:	   | try to lookup word in dictionary
	.. dentry_by_name                | ( ... xta | f )
	.. qdup qbranch 3f
	.. rot rot twodrop               | no error, drop word info
	.. dup dentry_immediate qbranch 5f
	..   try_exec_dentry             | execute word if marked as immediate
	..   true exit
5:	.. dentry_xta
	.. compile_xta
	.. true exit
2:	.. drop false exit
3:	.. cr msg_unknown space msg_word space msg_quote type msg_quote cr
	.. false exit

XT compile_qbranch  xtalit qbranch compile_xta
XT compile_branch   xtalit branch  compile_xta

| ( -- a ) compile conditional branch
LIST_XT compile_if
	.. compile_qbranch
	.. here              | leave pointer to branch target on stack, consumed by 'then'
	.. zero compile_xta  | placeholder for branch target
	.. exit

| ( a -- ) resolve target address of conditional branch
XT compile_then  here swap xtastore

| ( -- a ) return branch target of begin-again loop
XT compile_begin  here

| ( a -- ) compile unconditional branch to 'a'
XT compile_again  compile_branch compile_xta

| ( a -- ) compile conditional branch to 'a'
XT compile_until  compile_qbranch compile_xta

| ( -- a ) compile start of for loop, leave branch target in stack
XT compile_for  xtalit tor compile_xta here

| ( a -- ) compile end of for loop, using branch target of 'compile_for'
XT compile_next  xtalit next compile_xta compile_xta

| ( a -- a-next a-then ) redirect non-first iterations of for loop
LIST_XT compile_aft
	.. drop                                  | drop branch target of 'compile_for'
	.. compile_branch here zero compile_xta  | add unconditionally branch to THEN
	.. here                                  | leave branch target for NEXT
	.. swap exit                             | ( a-next a-then )


||
|| Main loop
||

XT bye  bye_xt at execute

VAR_XT tib_complete 0   | true on carriage return, reset after interpreting

CONST_XT tib          _tib_lo               | counted string
CONST_XT tib_capacity _tib_hi - _tib_lo - 1 | exclude count byte

LIST_XT handle_backspace
	.. tib cat zero equal not qbranch 1f    | don't move below zero
	.. bs_char emit space bs_char emit      | move cursor back
	.. tib cat one sub tib cstore           | decrement TIB count
1:	.. exit

LIST_XT append_to_tib   | ( c -- ) insert character into TIB
	.. tib cat tib_capacity ult qbranch 1f  | check for TIB overflow
	.. dup emit                             | echo to terminal
	.. dup tib inc tib cat plus cstore      | insert char into TIB
	.. tib cat inc tib cstore               | increment TIB count
1:	.. drop exit

XT handle_cr  true tib_complete store

| ( c -- f ) return true if 'c' denotes carriage return
XT matches_cr  dup cr_char equal swap nl_char equal or

| ( c -- f ) return true if 'c' denotes backspace
XT matches_bs  dup bs_char equal swap del_char equal or

| ( c -- f ) return true if 'c' is the shortcut for reset
XT matches_reset  reset_char equal

| ( c -- f ) return true if 'c' is the shortcut for bye
XT matches_bye  bye_char equal

LIST_XT handle_console_char
	.. dup matches_cr    qbranch 1f drop handle_cr        exit; 1:
	.. dup matches_bs    qbranch 1f drop handle_backspace exit; 1:
	.. dup matches_reset qbranch 1f drop reset            exit; 1:
	.. dup matches_bye   qbranch 1f drop cr bye           exit; 1:
	.. append_to_tib
	.. exit

LIST_XT handle_console_input
	.. ask_key qbranch 1f
	.. handle_console_char
1:	.. exit

LIST_XT try_exec_dentry
	.. qdup qbranch 1f dentry_xta execute
1:	.. exit

XT evaluate_one_word  eval_xt at execute

| ( ptr len -- ) evaluate up to 'len' characters starting at 'ptr'
LIST_XT evaluate
	.. parse_len store parse_ptr store
1:	.. evaluate_one_word
	.. not qbranch 1b
	.. exit

LIST_XT interpret_tib
	.. cr
	.. tib count
	.. evaluate
	.. cr
	.. exit

XT show_prompt  depth fmt_start fmt_number fmt_end type msg_prompt
XT reset_tib    zero tib_complete store zero tib cstore show_prompt

LIST_XT try_eval_tib
	.. tib_complete at qbranch 1f interpret_tib reset_tib
1:	.. exit

LIST_XT do_console
	.. handle_console_input
	.. try_eval_tib
	.. exit

CODE_XT pterm
	move.w  #0,-(sp)     | p_term0
	trap    #1

CODE_XT getrez
	move.w  #4,-(sp)
	trap    #14
	addq.l  #2,sp
	PUSHD   d0
	NEXT

| ( -- scancode ascii ) read character from standard input
CODE_XT cconin
	move.w  #1,-(sp)
	trap    #1
	addq.l  #2,sp
	moveq   #0,d1
	move.w  d0,d1  | d1: ASCII value
	clr.w   d0
	swap    d0     | d0: scan code
	PUSHD   d0
	PUSHD   d1
	NEXT

CONST_XT msg_needhirez _msg_needhirez

_msg_needhirez:
	.string "This demo needs a 1280x960 monochrome ECL display."
	.ALIGN 2

DENTRIES msg_needhirez

CODE_XT supenter  | enter supervisor mode
	clr.l   -(sp)
	move.w  #0x20,-(sp)
	trap    #1
	addq.l  #6,sp
	move.l  d0,_saved_ssp
	NEXT

CODE_XT supreturn  | leave supervisor mode
	move.l  _saved_ssp,-(sp)
	move.w  #0x20,-(sp)
	trap    #1
	addq.l  #6,sp
	NEXT

_saved_ssp:	dc.l 0


||
|| Application-specific supplements, may extend LAST_DENTRY
||

.include "app.s"

CONST_XT current_init LAST_DENTRY   | reset value
VAR_XT   current      LAST_DENTRY   | head of dictionary-entry list


||
|| Forth application interpreted before entering the mainloop
||

_app_lo: .incbin "app.f"; _app_hi:


||
|| Memory outside the image
||

.align CELL_BYTES
.bss

_dstack_lo: .ds.l  64; _dstack_hi:   | data stack
_rstack_lo: .ds.l  32; _rstack_hi:   | return stack
_pad_lo:    .ds.b 128; _pad_hi:      | string-formatting buffer
_tib_lo:    .ds.b 128; _tib_hi:      | terminal-input buffer

_bss_end:

|
| Dynamic dictionary grows from here...
|

	.ds.l 2*1024*1024/4      | report space for BSS in binary

| vim: set ts=16:
