;----------------------------------------------------------------------------
;File name:	RA_STRUC.I			Revision date:	2000.07.17
;Created by:	Ulf Ronald Andersson		Creation date:	1996.08.10
;(c)1996 by:	Ulf Ronald Andersson		Released as FREEWARE (not PD)
;----------------------------------------------------------------------------
; Purpose:	Header file included in assembly sources to define
;		macros that declare data structures, similar to C.
;----------------------------------------------------------------------------
	ifnd	RA_STRUC_defined
RA_STRUC_defined	set	1
;----------------------------------------------------------------------------
;Macro definitions for general data structure definitions
;----------------------------------------------------------------------------
d_start	MACRO	name,base
st__pos	SET	base
\1	=	st__pos
	ENDM	;d_start
;------------------------------------
struct	MACRO	name
st__pos	SET	0
\1	=	st__pos
	ENDM	;struct
;------------------------------------
d__s	MACRO	name,count
	IFNE	(NARG>2)
	FAIL	Extra arg in: d__s.\0 \1,\2,\3
	MEXIT
	ENDC
	IFNE	(NARG<1)
	FAIL	Missing args in: d__s.\0
	MEXIT
	ENDC
\1	=	st__pos
;
	IFNE	(NARG=1)
st__cnt	SET	1
	ELSEIF
	IFC	'','\2'
st__cnt	SET	1
	ELSEIF
st__cnt	SET	\2
	ENDC
	ENDC
;
st__typ	set	'\0'
	IFNE	(st__typ>'Z')
st__typ	set	st__typ-32
	ENDC
	IFNE	(st__typ='B')
st__exp	set	0
	ELSEIF
	IFNE	(st__typ='W')
st__exp	set	1
	ELSEIF
	IFNE	(st__typ='L')
st__exp	set	2
	ELSEIF
	FAIL	Unknown type used in: d__s.\0 \1,\2
	MEXIT
	ENDC
	ENDC
	ENDC
st__pos	SET	(st__pos+(st__cnt<<st__exp))
	ENDM	;d__s
;------------------------------------
d_even	MACRO
	IFNE	(st__pos&1)
st__pos	SET	st__pos+1
	ENDC
	ENDM	;d_even
;------------------------------------
d_phase	MACRO	pos
	IFNE	((\1)>=st__pos)
st__pos	SET	\1
	MEXIT
	ENDC
st__tmp	SET	\1
	FAIL	"d_phase \1" called to set pos \{st__tmp} at pos \{st__pos}
	ENDM	;d_phase
;------------------------------------
d_s	MACRO	name,count
	d__s.b	\1,\2
	ENDM	;d_b
;------------------------------------
d_b	MACRO	name,count
	d__s.b	\1,\2
	ENDM	;d_b
;------------------------------------
d_w	MACRO	name,count
	d_even
	d__s.w	\1,\2
	ENDM	;d_w
;------------------------------------
d_ow	MACRO	name,count
	d__s.b	\1,\2
	ENDM	;d_pw
;------------------------------------
d_l	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM	;d_l
;------------------------------------
d_ol	MACRO	name,count
	d__s.l	\1,\2
	ENDM	;d_pl
;------------------------------------
d_field	MACRO	name,len
	IFNE	(NARG>2)
	FAIL	Extra arg in: d_field \1,\2,\3
	MEXIT
	ENDC
	IFNE	(NARG<2)
	FAIL	Missing args in: d_field \1
	MEXIT
	ENDC
\1	=	st__pos
st__pos	set	st__pos+((\2)+7)/8
st__bix	set	\2
	ENDM	;d_field
;------------------------------------
d_bits	MACRO	name,len
st__bix		set	st__bix-(\2)
\1		=	st__bix
mask_\1		=	(1<<(\2))-1
amask_\1	=	mask_\1<<st__bix
	IFNE	(st__bix<0)
	FAIL	Bad bit field definition: d_bits \1,\2
	ENDC
	ENDM
;------------------------------------
;NB: The 'd_bits' macro should only be used after using 'd_field'
;    and will then assign 'name' the bit number of its LSB and
;    ensure that the next field element has an MSB below that.
;    Thus the element ordering is compatible to C, although more
;    work is needed to access elements in assembler.  The 'mask_'
;    and 'amask_' prefixed names are bit masks that can be used
;    to isolate elements. 'amask_...' is aligned to the position
;    of the element in the field, and can be used to isolate it.
;    'mask_...' is unaligned, and can be used to limit a value
;    to element size during calculations.
;------------------------------------
d_alias	MACRO	name
\1	=	st__pos
	ENDM	;d_alias
;------------------------------------
d_end	MACRO	name
sizeof_\1	=	st__pos
	ENDM	;d_end
;----------------------------------------------------------------------------
;Macros for various data types
;----------------------------------------------------------------------------
byte	MACRO	name,count
	d__s.b	\1,\2
	ENDM
;
char	MACRO	name,count
	d__s.b	\1,\2
	ENDM
;
uint8	MACRO	name,count
	d__s.b	\1,\2
	ENDM
;
int8	MACRO	name,count
	d__s.b	\1,\2
	ENDM
;
word	MACRO	name,count
	d_even
	d__s.w	\1,\2
	ENDM
;
uint16	MACRO	name,count
	d_even
	d__s.w	\1,\2
	ENDM
;
int16	MACRO	name,count
	d_even
	d__s.w	\1,\2
	ENDM
;
uint32	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
int32	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
uint8_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
int8_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
uint16_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
int16_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
long	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
uint32_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
int32_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
void_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
char_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
char_pp	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
byte_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
word_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
long_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
func_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
struct_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
struc_p	MACRO	name,count
	d_even
	d__s.l	\1,\2
	ENDM
;
s_struc	MACRO	name,struct_name
	IFC	'','\2'
	FAIL	s_struc \1,\2: missing substructure name.
	ENDC
	d__s.b	\1,sizeof_\2
	ENDM
;----------------------------------------------------------------------------
	endc	;RA_STRUC_defined
;----------------------------------------------------------------------------
;End of file:	RA_STRUC.I
;----------------------------------------------------------------------------
