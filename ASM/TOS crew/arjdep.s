;=======================================================================
; arj depacker with minimal archiv functionality
;
; depackcode: mr.ni / Toscrew
;
; archiv functionality: ultra / cream
;
;
; thx to defjam for his c source to find the correct position
; to depack the data
;
; keep in mind this depacker works only with arj mode 4 !
;
; how to use:
; in a0: arj data
; in a1: depack data
; out return code
;
; there is must be an offset between the a0 and a1 ...you can not
; depack at the same place...
; but anyway its really small...use the offset tool which is mostly
; included in atari arj releases to get the correct offset...
;
; this source is only to depack the first file of an arj file...!
;
; ultra/cream 2003
;=======================================================================

ARJ_INVAL_MHEADER EQU -1
ARJ_INVAL_MODE  EQU -2
ARJ_INVAL_LHEADER EQU -3

ARJ_LOC_MODE    EQU 9
ARJ_LOC_CSIZE   EQU 16
ARJ_LOC_OSIZE   EQU 20

;                LEA     PACK,A0
;                LEA     DEPACK,A1
;-> d0 = returncode
ARJ_DEPACK:
                MOVEA.L A1,A6
                MOVE.W  #ARJ_INVAL_LHEADER,D2 ;check local header
                CMPI.B  #$60,(A0)+
                BNE     ARJ_FAILED
                CMPI.B  #$EA,(A0)+
                BNE     ARJ_FAILED

                BSR.S   ARJ_GETW        ;mainheader size
                ADDA.L  D0,A0
                LEA     4(A0),A0        ;skip crc

                BSR     ARJ_GETW        ;exheader size
                TST.W   D0
                BEQ.S   ARJ_NOMEXHEADER
                ADDA.L  D0,A0
                LEA     4(A0),A0        ;skip crc

ARJ_NOMEXHEADER:

                LEA     (A0),A1         ;START OF LOCAL HEADER
                MOVE.W  #ARJ_INVAL_LHEADER,D2 ;check local header
                CMPI.B  #$60,(A0)+
                BNE     ARJ_FAILED
                CMPI.B  #$EA,(A0)+
                BNE     ARJ_FAILED

                MOVE.W  #ARJ_INVAL_MODE,D2 ;check if its mode 4
                CMPI.B  #$04,ARJ_LOC_MODE(A1)
                BNE.S   ARJ_FAILED


                LEA     ARJ_LOC_CSIZE(A1),A0 ;GET COMPRESSED SIZE
                BSR     ARJ_GETL
                MOVE.L  D0,D6

                LEA     ARJ_LOC_OSIZE(A1),A0 ;GET ORIG SIZE
                BSR     ARJ_GETL
                MOVE.L  D0,D7

                LEA     2(A1),A0        ;get back to local header
                BSR.S   ARJ_GETW        ;local header size
                ADDA.L  D0,A0
                LEA     4(A0),A0        ;skip crc

                BSR     ARJ_GETW        ;exheader size
                TST.W   D0
                BEQ.S   ARJ_NOLEXHEADER
                ADDA.L  D0,A0
                LEA     4(A0),A0        ;skip crc
ARJ_NOLEXHEADER:
                BSR     DO_ARJ
                MOVEQ   #0,D0
                RTS


ARJ_FAILED:
                MOVE.W  D2,D0
                RTS
ARJ_GETW:
                MOVEQ   #0,D0
                MOVE.B  1(A0),D0
                LSL.W   #8,D0
                OR.B    (A0),D0
                LEA     2(A0),A0
                RTS
ARJ_GETL:
                MOVEQ   #0,D0
                MOVE.B  3(A0),D0
                LSL.W   #8,D0
                OR.B    2(A0),D0
                LSL.L   #8,D0
                OR.B    1(A0),D0
                LSL.L   #8,D0
                OR.B    (A0),D0
                LEA     4(A0),A0
                RTS

;
; ARJ mode4 depacking(for packed files with simple header)
;   Motorola 68000
;   (for ruling machines like: ATARI ST!/STE!/FALCON!  AMIGA!)
;
DO_ARJ:
;                MOVE.L  (A0)+,D0                  ;Ori size
;                ADDQ.L  #4,A0                     ;Packed size not needed
                MOVE.L  D7,D0
                MOVEA.L A6,A1
                EXG     A0,A1

;
; ARJ mode4 decode function
; Size optimized
; Copyleft 1993 Mr Ni! (the Great) of the TOS-crew
;
; Note:
; ARJ_OFFS.TTP. This program is an addition to UNARJ_PR. It
; calculates the minimum offset between the source and destination
; address for in memory depacking of files.
; (Depacking A1-referenced data to A0... The calculated 'offset' is
; the minimum amount of bytes required to be reserved before the
; packed data block.)
;
; void decode_f(ulong origsize, char* depack_space, char* packed_data)
; CALL:
; D0 = origsize (long)
; A0 = ptr to depack space
; A1 = ptr to packed data
;
; Register usage:
; d0: temporary register
; d1: temporary register
; d2: temporary register, pointer offset
; d3: bytes to do counter
; d4: #bytes to copy
; d5: klad
; d6: bitbuf,subbitbuf
; d7: #bits in subbitbuf
; a0: depack space
; a1: rbuf_current
; a2: source adres for byte copy
; a3: temporary register
; a4: not used
; a5: not used
; a6: not used
DECODE_F:
                MOVEM.L D3-D7/A2-A3,-(SP) ; save registers
                MOVE.L  D0,D3           ; origsize
                MOVEQ   #0,D7           ; bitcount = 0
                MOVE.W  A1,D0           ; for checking rbuf_current
                BTST    D7,D0           ; does readbuf_current point to an even address?
                BEQ.S   CONT            ; yes
                MOVE.B  (A1)+,D6        ; pop eight  bits
                MOVEQ   #8,D7           ; 8 bits in subbitbuf
                LSL.W   #8,D6           ;
CONT:
                MOVEQ   #$10,D4         ; push 16 (8) bits into bitbuf
                SUB.W   D7,D4           ; subtract still available bits from  d5
                LSL.L   D7,D6           ;
                MOVE.W  (A1)+,D6        ; word in subbitbuf
                LSL.L   D4,D6           ; fill bitbuf
COUNT_LOOP:                             ; main depack loop
                MOVE.L  D6,D1           ; evaluate most significant bit bitbuf
                BMI.S   START_SLD       ; =1 -> sliding dictionary
                MOVEQ   #9,D0           ; pop bits from bitbuf for literal
                BSR.S   GETBITS         ;
                MOVE.B  D2,(A0)+        ; push byte in buffer
EVAL_LOOP:
                SUBQ.L  #1,D3           ;
                BNE.S   COUNT_LOOP      ;
                MOVEM.L (SP)+,D3-D7/A2-A3 ;
                RTS                     ;

START_SLD:
                MOVEA.W #8,A3           ;
                MOVEQ   #0,D2           ; max power
                BSR.S   GET_THEM        ;
                ADD.W   D2,D5           ; length
                MOVE.W  D5,D4           ;
                MOVE.L  D6,D1           ; bitbuf
                SUBQ.W  #3,A3           ; move.w  #5,a3
                MOVEQ   #9,D2           ; minimum getbits
                BSR.S   GET_THEM        ;
                ROR.W   #7,D5           ;
                ADDQ.W  #1,D4           ; increment len by one
                ADD.W   D5,D2           ; calc pointer
                NEG.W   D2              ; pointer offset negatief
                LEA     -1(A0,D2.w),A2  ; pointer in dictionary
                SUB.L   D4,D3           ; sub 'bytes to copy' from 'bytes to do' (d4 is 1 too less!)
COPY_LOOP_0:
                MOVE.B  (A2)+,(A0)+     ;
                DBRA    D4,COPY_LOOP_0  ;
                BRA.S   EVAL_LOOP       ;

GET_THEM:
                MOVEQ   #1,D0           ; minimum fillbits
                MOVEQ   #0,D5           ; value
LOOP:
                ADD.L   D1,D1           ; shift bit outside
                BCC.S   EINDE           ; if '1' end decode
                ADDX.W  D5,D5           ; value *2+1
                ADDQ.W  #1,D0           ; extra fill
                ADDQ.W  #1,D2           ; extra get
                CMP.W   A3,D0           ; max bits
                BNE.S   LOOP            ; nog mal
                SUBQ.W  #1,D0           ; 1 bit less to trash
EINDE:
                BSR.S   FILLBITS        ; trash bits
                MOVE.W  D2,D0           ; bits to get
GETBITS:
                MOVE.L  D6,D2           ;
                CLR.W   D2              ;
                ROL.L   D0,D2           ;
FILLBITS:
                SUB.B   D0,D7           ; decrease subbitbuf count
                BCC.S   NO_FILL         ;
                MOVE.B  D7,D1           ;
                ADD.B   D0,D1           ;
                SUB.B   D1,D0           ;
                ROL.L   D1,D6           ;
                MOVE.W  (A1)+,D6        ;
                ADD.B   #16,D7          ; bits in subbitbuf
NO_FILL:
                ROL.L   D0,D6           ; bits to pop from buffer
                RTS                     ;
;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
