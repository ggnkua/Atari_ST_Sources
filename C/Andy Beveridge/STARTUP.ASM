;
; Startup code for Lattice C on the Atari
;
; (c) Metacomco 1985
;
space   EQU     $20                     ; space character
tab     EQU     $09                     ; tab character
newline EQU     $0a                     ; newline
;
ERR_BP  EQU     -15                     ; bad parameter
;
nam_siz EQU     32                      ; max size of name
Min_Mem EQU     $0800                   ; 2k default memory allocation
Min_Stk EQU     $0400                   ; 1k minimum stack
Sys_Mem EQU     $1000                   ; 4k left for TOS
;
GEM_Shrink EQU  $4A                     ; TOS shrink memory function
GEM_Term EQU    $4C                     ; Terminate process fn
;
;
        XREF    _main
        XREF    _stack
        XREF    _mneed
        XREF    rbrk
;
        text
;
;       Enter here with address of base page on stack above return address.
;
;
scan    move.l  4(a7),a3                ; get address of base page in A3
        move.l  a3,_BasePage            ; save this for later reference
        lea     $80(a3),a0              ; get address of command line
        clr.l   d2
        move.b  (a0)+,d2                ; get length of string
        move.l  a0,a4                   ;
        subq.w  #1,d2                   ; for dbra
        move.l  a0,a2
;
scan05:
        CMPI.B  #newline,(A0)           ; end of line?
        BEQ     end_line
        CMPI.B  #space,(A0)             ; space?
        BEQ     scan10
        CMPI.B  #tab,(A0)               ; tab?
        BNE     scan04                  ; no, try others
scan10  ADDQ.L  #1,A0
        SUBQ.W  #1,D2
        BPL.S   scan05
        BRA     end_line                ; end of line
;
scan04  CMPI.B  #'<',(A0)               ; start of input file name?
        BEQ     inp_nam
        CMPI.B  #'>',(A0)               ; start of output file name?
        BEQ     out_nam
        CMPI.B  #'=',(A0)               ; stack size specification?
        BEQ.S   set_stk
        cmp.b   #'%',(a0)               ; workspace specification ?
        beq.s   set_wrk                 
        BRA     end_line
;
;set stack function
;
set_stk ADDQ.L  #1,A0                   ; move past '='
        MOVEQ   #0,D0                   ; clear accumulator
stk_02  MOVEQ   #0,D1
        MOVE.B  (A0),D1                 ; get digit
        CMP.W   #$39,D1                 ; check for numeric
        BGT.S   end_stk
        SUB.W   #$30,D1
        BLT.S   end_stk
        ASL.L   #1,D0                   ; x2
        MOVE.L  D0,-(A7)
        ASL.L   #2,D0                   ; x8
        ADD.L   (A7)+,D0                ; x10
        ADD.L   D1,D0                   ; add in new digit
        ADDQ.L  #1,A0                   ; move to next digit
        SUBQ.W  #1,D2
        BMI     error
        BRA.S   stk_02
;
end_stk TST.L   D0
        BEQ     error                   ; if stack specification error
        CMP.L   #Min_Stk,D0
        BGT.S   stk_10
        MOVE.L  #Min_Stk,D0
stk_10  MOVE.L  D0,_stack               ; set memory allocate size
        BRA     scan05
;
;set workspace function
;
set_wrk ADDQ.L  #1,A0                   ; move past '%'
        MOVEQ   #0,D0                   ; clear accumulator
wrk_02  MOVEQ   #0,D1
        MOVE.B  (A0),D1                 ; get digit
        CMP.W   #$39,D1                 ; check for numeric
        BGT.S   end_wrk
        SUB.W   #$30,D1
        BLT.S   end_wrk
        ASL.L   #1,D0                   ; x2
        MOVE.L  D0,-(A7)
        ASL.L   #2,D0                   ; x8
        ADD.L   (A7)+,D0                ; x10
        ADD.L   D1,D0                   ; add in new digit
        ADDQ.L  #1,A0                   ; move to next digit
        SUBQ.W  #1,D2
        BMI.S   error
        BRA.S   wrk_02
;
end_wrk TST.L   D0
        BEQ.S   error                   ; if stack specification error
        CMP.L   #Min_Mem,D0
        BGT.S   wrk_10
        MOVE.L  #Min_Mem,D0
wrk_10  MOVE.L  D0,_mneed               ; set memory allocate size
        BRA     scan05
;
;
out_nam LEA     _oname,A1
        BRA     inp01
;
inp_nam LEA     _iname,A1
inp01   MOVEQ   #nam_siz-1,D1           ; set size of name field
        ADDQ.L  #1,A0                   ; get past "<" or ">"
inp02   SUBQ.W  #1,D2
        BMI.S   end_line
        CMPI.B  #space,(A0)             ; end of field?
        BEQ     scan05
        CMPI.B  #tab,(A0)
        BEQ     scan05
        CMPI.B  #newline,(A0)
        BEQ     scan05
        MOVE.B  (A0)+,(A1)+
        DBF     D1,inp02
;
error   MOVEQ   #ERR_BP,D0              ; set "bad parameter"
        BRA     Abort                   ; exit
;
end_line:
;
;       compress command line
;
        TST.W   D2
        BMI.S   end10                   ; if nothing to compress
end05   MOVE.B  (A0)+,(A2)+
        DBF     D2,end05
end10   CLR.B   (A2)+
;
;
; allocate space for memory allocation and stack
;
        move.l  $18(a3),d1              ; base of BSS
        add.l   $1c(a3),d1              ; add size of BSS for base of free memory
        move.l  a7,d0                   ; d0 = top of memory
        sub.l   _stack,d0               ; allow for declared stack size
        sub.l   d1,d0                   ; d0 = size of free memory
        move.l  _mneed,d2               ; d2 = requested memory
        bne.s   mem1                    ; if zero
        move.l  d0,d2
        sub.l   #Sys_Mem,d2             ; then leave some for TOS
        bra.s   mem3
mem1:
        bgt.s   mem2                    ; if > 0 get that much
        add.l   d0,d2                   ; if < 0 leave that much for TOS
mem2:
        cmp.l   #Min_Mem,d2             ; make sure we get at least the minimum
        bgt.s   mem3
        move.l  #Min_Mem,d2             ; set minimum memory size
mem3:
        move.l  d1,d3                   ; d3 = base of free memory
        sub.l   a3,d3                   ; d3 = size of program
        add.l   d2,d3                   ; add heap requirements
        add.l   _stack,d3               ; add stack requirements
        move.l  d3,-(sp)                ; length of retained memory
        move.l  a3,-(sp)                ; base of retained memory
        clr.w   -(sp)                   ; filler
        move.w  #GEM_Shrink,-(sp)       ; function code
        trap    #1                      ; Memory now shrunk
        tst.l   d0                      ; check it worked
        beq.s   mem4
        move.w  #-39,d0                 ; set no memory error
        bra.s   Abort
mem4:
        move.l  d2,d0                   ; d0 = size of heap
        move.l  d1,a7                   ; set up stack
        add.l   d2,a7                   ; add heap size
        add.l   _stack,a7               ; add stack size for new sp
        move.l  d1,_mbase               ; set base of memory
        move.l  d1,_mnext               ; set next pointer
        move.l  d0,_msize               ; set size
        jsr     rbrk

        move.l  a4,-(a7)                ; move command line address to stack

        lea.l   DataStart+$8000,a5      ; set up A5 and A6 for position...
        move.l  a5,a6                   ; ...independent code
;
        jsr     _main
;
        moveq   #0,d0
Abort:
        move.w  d0,-(sp)                ; set return code
        move.w  #GEM_Term,-(sp)         ; GEMDOS terminate function
Abort1:
        TRAP    #1                      ; should not return
        bra.s   Abort1
;
        XDEF    XCEXIT
XCEXIT:
        move.l  4(a7),d0                ; save return status
        bra.s   Abort
;
        DATA
        XDEF    _dos,_iname,_oname
        XDEF    _mbase,_mnext,_msize,_tsize,_oserr
        XDEF    _BasePage
;
DataStart:
NULL    DC.L    0
_dos    DC.L    0                       ; DOS version number
_iname  DS.B    32                      ; input file name
_oname  DS.B    32                      ; output file name
_mbase  DC.L    0                       ; base of memory pool
_mnext  DC.L    0                       ; next available memory location
_msize  DC.L    0                       ; size of memory pool
_tsize  DC.L    0                       ; total size?
_oserr  DC.L    0
_BasePage DC.L    0                     ; pointer to base page
;
        end
