; GLOBALS.S: ForST macros, version 1.13
; Copyright <C> John Redmond 1989,1990
; Public domain for non-commercial use.
;
        section	text
;
	opt	A+	;PC-rel
;
; Bit flags for stack expectations and results of macros:
;
;
none_none = 0		;0 args expected, 0 results returned
none_one = $20
one_none = $80
one_one = $a0
one_two = $b0
;
two_none = $c0		; 2 args expected, 0 results returned
two_one = $e0
two_two = $f0
;
two_result = $e8	; 2 args expected, boolean result returned
one_result = $a8

exp_d0 = (one_none<<24)!$2d00
ret1_any = (none_one<<24)!$ffff
;
push:   macro   $\1
        move.l  \1,-(a6)
        endm
pop:    macro   $\1
        move.l  (a6)+,\1
        endm
rpush:  macro   $\1
        move.l  \1,-(a7)
        endm
rpop:   macro   $\1
        move.l  (a7)+,\1
        endm
offs:   macro  \1
        dc.l    \1-index
        endm
len:	macro	\1
	dc.w	(\1-*-2)/2
	endm
;
ptrs:   macro   \1
        dc.l    0
        dc.l    \1-index,\1-index
        dc.w	\2
        endm
lptrs:	macro   \1			;word with length for copying
        dc.w    \2			;length
        dc.w	0
        dc.l    \1-index,\1-index
        dc.w	\3
        endm
mptrs:  macro   			;macro words
        dc.b    \4,\3                   ;macro length
       ifc	'\2','noedge'
        dc.w    -1
       elseif
        move.l  \2,-(a6)                ;macro flag
       endc
        dc.l    \1-index,\1-index
        dc.w	\5
        endm
;
vptrs:  macro   \1                      ;variables
        dc.l    0
        dc.l    _var-index,\1-index
        dc.w	\2
        endm
;
cptrs:  macro   \1                      ;constants
        dc.l    0
        dc.l    _const-index,\1
        dc.w	\2
        endm
;
dptrs:  macro   \1                      ;deferred words
        dc.l    0
        dc.l    _def-index,\1-index
        dc.w	\2
        endm
;
vectptrs: macro   \1                    ;vectored words
        dc.l    0
        dc.l    _vect-index,\1-index
        dc.w	\2
        endm
;
vect:  macro   \1,$\2,%\3,%\4		;compile-time vectoring
        dc.b    \4,\3                   ;macro length
       ifc	'\2','noedge'
        dc.w    -1
       elseif
        move.l  \2,-(a6)                ;macro flag
       endc
        dc.l    _vect-index,\1-index
        dc.w	\5
        endm
;
decide:	macro   \1,$\2,%\3,%\4,\5,\6	;compile-time vectoring
        dc.b    \4,\3                   ;macro length
       ifc	'\2','noedge'
        dc.w    -1
       elseif
        move.l  \2,-(a6)                ;macro flag
       endc
        dc.l    \6-index,\1-index
        dc.w	\5
        endm
;
fetch:  macro   \1,\2,\3,\4,\5		;compile-time vectoring
	decide	\1,\2,\3,\4,\5,_fetchopt
	endm
;
store:  macro   \1,\2,\3,\4,\5		;compile-time vectoring
	decide	\1,\2,\3,\4,\5,_storeopt
        endm
;
invert:  macro  \1,\2,\3,\4,\5		;compile-time vectoring
	decide	\1,\2,\3,\4,\5,_notopt
        endm
;
; system constants to be set before assembly
;
wspace = $10000		;space for code and buffers
rspace = $2000		;space for return stack
hspace = $8000		;space for headers
kbuffsiz = 80		;keyboard input buffer
bsize = 24		;size of file structure
nobuffs = 8		;# system iobuffers
maxsize = $3ff		;max # words in a macro
