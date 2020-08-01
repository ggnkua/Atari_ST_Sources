                OPT O+,W+
                OUTPUT 'D:\F68K\KERN_TA.IMG'

version         EQU $19920401


                TEXT

magic:          DC.W 'JP'
iscodelen:      DC.L HERE-sys
isdatalen:      DC.L dataHERE-datas
                DS.W 9          ;yet unused

*************************************************************************
*                                                                       *
*                                                                       *
*                               F68K                                    *
*                       a portable FORTHsystem                          *
*                                                                       *
*                            Version 1.0                                *
*                                                                       *
*                                by                                     *
*                             Joerg Plewe                               *
*                          Grossenbaumerstr. 27                         *
*                        4330 Muelheim a.d. Ruhr                        *
*                                                                       *
*                       started 5-2-1990 at 2.00pm                      *
*                                                                       *
*                       assembled with TurboAss                         *
*                                                                       *
*                                                                       *
* last changed: 04-01-92                                                *
*************************************************************************

*****************************************************************
                >PART 'comments'
*************************************************************************
*       usage of registers:                                             *
*                                                                       *
* us       equr     d5      ;userarea                                   *
* seg      equr     a2      ;pointer to actual segment                  *
* DT       equr     a3      ;pointer to data segment                    *
* fs       equr     a4      ;Floatingpointstack                         *
* SB       equr     a5      ;pointer to start of system                 *
* ds       equr     a6      ;data-stackpointer                          *
* rp       equr     a7      ;returnstackpointer                         *
*       d6,d7 are used for DO...LOOP                                    *
*                                                                       *
*       a0-a2,d0-d4 are for common use                                  *
*       BE CAREFULL!    not all words save theire registers!!!          *
*************************************************************************
*                                                                       *
*       HEADER                                                          *
*                                                                       *
*       $0      controlword, see below                                  *
*       $4      CFA, the CodeFieldAddress, points to code               *
*       $8      linkfield, words of ONE vocabulary                      *
*       $C      countWORD, gives length of the name                     *
*       $10...  the name                                                *
*                                                                       *
*************************************************************************
*                                                                       *
*       CODE                                                            *
*                                                                       *
*       -$4     VIEW, contains a number of a block                      *
*       $0      the code itself, see CFA above                          *
*                                                                       *
*************************************************************************
*                                                                       *
*       Bitusage in the controlword:                                    *
*                                                                       *
*       Bit0    smudge, word cannot be found                            *
*       Bit1    immediate, word will execute during compilation         *
*       Bit2    restrict, word may only be used in compiletime          *
*       Bit3    macro, word is a macro                                  *
*                                                                       *
*************************************************************************
                ENDPART

*****************************************************************
                >PART 'EQU'

*       for codegeneration during runtime:
jmp_code        EQU $4EFC
jsr_code        EQU $4EAA       ;jsr    off(seg)
jsrSB_code      EQU $4EAD       ;jsr    off(SB)
move_seg_code   EQU $246B       ;move.l off(DT),seg
rts_code        EQU $4E75
bsr_code        EQU $6100
bsrb_code       EQU $61
movesp_anull    EQU $205F
moveimm_sp      EQU $2D3C

BKSP            EQU $08
CR              EQU 13

headsize        EQU 10
of              EQU $8000       ;half a code segment
bytesperblock   EQU 2000

*************************************************************************
*       offset into user-table                                          *
*************************************************************************
ounext          EQU $00
ornull          EQU $04
osnull          EQU $08
ofnull          EQU $0C
ostate          EQU $10
onumber_quest   EQU $14
obase           EQU $18
odpl            EQU $1C
ohld            EQU $20
odp             EQU $24
odata           EQU $28
ototib          EQU $28+4
o_tib           EQU $2C+4
otoin           EQU $30+4
ospan           EQU $34+4
ocurrent        EQU $38+4
ovoc_link       EQU $3C+4
ovocpa          EQU $40+4
olast           EQU $44+4
;ofence          EQU $48+4
oerror          EQU $4C         ;+4
okey            EQU $50         ;+4
oemit           EQU $54         ;+4
okey_quest      EQU $58         ;+4
or_w            EQU $60-4
oreadsys        EQU $64-4
owritesys       EQU $68-4
olkey           EQU $6C-4
olemit          EQU $70-4
olkey_quest     EQU $74-4
olr_w           EQU $78-4
olreadsys       EQU $7C-4
olwritesys      EQU $80-4
oexpect         EQU $6C+20
otype           EQU $70+20
omacro          EQU $74+20
ois_macro       EQU $78+20
owarning        EQU $7C+20
oout            EQU $80+20
ofwidth         EQU $84+20
oliteral        EQU $88+20
ofliteral       EQU $8C+20
oblk            EQU $88+8+20
orootblk        EQU $8C+8+20
oprev           EQU $90+8+20
ouserbufs       EQU $94+8+20
ocaps           EQU $98+8+20
oudp            EQU $9C+8+20

                ENDPART

*****************************************************************
                >PART 'initialising'
*********************************************************************
*       initialising the system
*********************************************************************
*On the returnstack there will come only one pointer to a structure,
*which contains all necessary data to run F68K which are
;registers:    DS.L 16         ;d0,d1,d2,d3.......,a5,a6,a7
;forthregs:    DS.L 4          ;a3,a5,a6,a7
;TIBptr        DS.L 1
;codelen:      DS.L 1
;datalen:      DS.L 1
;emittable:    DS.L 1
;keytable:     DS.L 1
;keyqtable:    DS.L 1
;r_wtable:     DS.L 1
;readsystable: DS.L 1
;writesystable:DS.L 1
;roottable:    DS.L 1



forthregs       EQU 16*4
TIBptr          EQU forthregs+(4*4)
codelen         EQU TIBptr+4
datalen         EQU codelen+4
emittable       EQU datalen+4
keytable        EQU emittable+4
keyqtable       EQU keytable+4
r_wtable        EQU keyqtable+4
readsystable    EQU r_wtable+4
writesystable   EQU readsystable+4
roottbl         EQU writesystable+4


;; A0 is important during initialisation!!!

sys:
init:           move.l  A0,-(SP)
                addq.l  #8,SP           ;A7 to returnheigth
                movea.l (SP),A0         ;Pointer to parastruc
                movem.l D0-A7,(A0)      ;save all registers
                move.l  -8(SP),8*4(A0)  ;save old A0, too
                movea.l -4(SP),A1       ;get returnaddress
                movem.l forthregs(A0),A3/A5-A7 ;load forth registers

                adda.l  #of,A5          ;points to the middle of first segment
                move.l  A0,D0
                sub.l   A3,D0
                move.l  D0,(tforthparas-datas)(A3)
                move.l  A1,(bootsys-datas)(A3) ;remember exit
                move.l  (15*4)(A0),(saveret-datas)(A3) ;remember loaders SP

* relocate the segment table
                lea     (table-datas)(A3),A1 ;pointer to the table
                move.l  A5,D1           ;0.th segment pointer
                move.l  #(tablesize-1),D0
relo_loop:
                move.l  D1,(A1)+
                addi.l  #$010000,D1
                dbra    D0,relo_loop


                move.l  (bootuser-datas)(A3),D5 ;USER-Pointer

                move.l  codelen(A0),D0  ;fetch length of code
                add.l   A5,D0           ;calculate systop
                sub.l   A3,D0           ;make ist rel. to DT
                subi.l  #of,D0          ;substract offset
                move.l  D0,(tsystop-datas)(A3) ;set systop

                move.l  datalen(A0),D0  ;fetch length of data
                move.l  D0,(tdatatop-datas)(A3) ;set datatop
                move.l  #0,(tdatabot-datas)(A3) ;because all rel. to DT
                lea     -of(A5),A1
                suba.l  A3,A1           ;calculate offset of segm.
                move.l  A1,(tsysbot-datas)(A3) ;set it


* fetch stackbases
                move.l  D5,D0
                addi.l  #ototib,D0
                move.l  TIBptr(A0),D1
                sub.l   A3,D1           ;make pointer relativ
                move.l  D1,0(A3,D0.w)   ;set >TIB

* now fetch I/O-addresses
                move.l  D5,D0
                addi.l  #olemit,D0
                move.l  emittable(A0),D1
                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,(temits-datas)(A3) ;EMITs
                move.l  4(A3,D1.l),D1
                move.l  D1,0(A3,D0.l)   ;set EMIT

                move.l  D5,D0
                addi.l  #olkey,D0
                move.l  keytable(A0),D1
                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,(tkeys-datas)(A3) ;KEYs
                move.l  4(A3,D1.l),D1
                move.l  D1,0(A3,D0.l)   ;set KEY

                move.l  D5,D0
                addi.l  #olkey_quest,D0
                move.l  keyqtable(A0),D1
                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,(tkey_quests-datas)(A3) ;KEY?s
                move.l  4(A3,D1.l),D1
                move.l  D1,0(A3,D0.l)   ;set KEY?

                move.l  D5,D0
                addi.l  #olr_w,D0
                move.l  r_wtable(A0),D1
                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,(tr_ws-datas)(A3) ;R/Ws
                move.l  4(A3,D1.l),D1
                move.l  D1,0(A3,D0.l)   ;set R/W

                move.l  D5,D0
                addi.l  #olreadsys,D0
                move.l  readsystable(A0),D1
                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,(treadsyses-datas)(A3) ;R/Ws
                move.l  4(A3,D1.l),D1
                move.l  D1,0(A3,D0.l)   ;set R/W

                move.l  D5,D0
                addi.l  #olwritesys,D0
                move.l  writesystable(A0),D1
                sub.l   A3,D1           ;make pointer relativ to SB
                move.l  D1,(twritesyses-datas)(A3) ;R/Ws
                move.l  4(A3,D1.l),D1
                move.l  D1,0(A3,D0.l)   ;set R/W

                movea.l roottbl(A0),A1  ;pointer to roottable
                beq.s   mark_roottable  ;is there a device?
                move.l  D5,D0           ;mark first device in
                addi.l  #orootblk,D0    ;table as ROOTBLK
                move.l  4(A1),0(A3,D0.l)
mark_roottable:
                suba.l  A3,A1
                move.l  A1,(troot-datas)(A3)


* now initialise with given pointers

                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  A6,D1
                sub.l   A3,D1           ;make pointer relativ
                move.l  D1,0(A3,D0.l)   ;set data-stackbase

                move.l  D5,D0
                addi.l  #ornull,D0
                move.l  SP,D1
                sub.l   A3,D1           ;make pointer relativ
                move.l  D1,0(A3,D0.l)   ;set returnstack

                move.l  #(hello-datas),-(A6)
                move.l  #47,-(A6)
                bsr     type

                jmp     (cold-(sys+of))(A5) ;jump into the system


*************************************************************************
                ENDPART

*****************************************************************
                >PART 'vocabularies'

dovoca:         move.l  D5,D0           ;get user-pointer
                addi.l  #ovocpa,D0      ;add offset
                movea.l 0(A3,D0.l),A0   ;fetch address of voc-stack base
                adda.l  A3,A0           ;calc. abs. address
                adda.l  (A0),A0         ;fetch height of voc-stack
                movea.l (SP)+,A1        ;fetch address of voc-pointer
                move.l  (A1),D0
                move.l  D0,(A0)         ;save it on voc-stack
                rts

onlyvoc:        move.l  D5,D0
                addi.l  #ovocpa,D0
                move.l  0(A3,D0.l),D0
                move.l  #8,0(A3,D0.l)
                move.l  #(last_only-datas),4(A3,D0.l)
                bra.s   dovoca


*------------------------------------------------
                DC.L 0
only:           jsr     (onlyvoc-sys-of)(A5) ;only becomes transient context
                DC.L (last_only-datas) ;ptr to ptr to last lfa
only_link:      DC.L 0


*------------------------------------------------
                DC.L 0          ;view
forth:          jsr     (dovoca-sys-of)(A5) ;makes forth transient context
                DC.L (last_forth-datas) ;ptr to ptr to last lfa
forth_link:     DC.L (only_link-sys-of) ;voc-link, addr of this field of last voc.


*------------------------------------------------
first:          rts

                ENDPART

*****************************************************************
                >PART 'DEFER primitive and PAUSE'
*****************************************************************
* DEFER-runtime primitive                                       *
*****************************************************************
dodefer:        movea.l (SP)+,A0
                move.l  (A0),D0         ;fetch pointer to pointer to code
                movea.l 0(A3,D0.l),A0   ;fetch pointer to code
                adda.l  A5,A0           ;make it absolute
                jmp     (A0)            ;and branch


                DC.L 0
pause:          jsr     (dodefer-sys-of)(A5) ;s.u.
                DC.L (pauseptr-datas) ; ' unknown IS notfound
*                rts

                ENDPART

*****************************************************************
                >PART 'I/O-words'
*****************************************************************
                DC.L 0          ;VIEW
osexpect:       move.l  D5,D0
                addi.l  #ospan,D0
                clr.l   0(A3,D0.l)      ;clear span
                move.l  (A6)+,D2        ;get count
                move.l  (A6)+,D1        ;get address(offset)
                dbra    D2,osexp_loop
osexp_loop:     bsr     key

                move.l  D5,D0
                addi.l  #ospan,D0
                addq.l  #1,0(A3,D0.l)   ;increase span
                cmpi.b  #CR,3(A6)       ;is character a cr?
                beq.s   abort_osexp     ;then exit
                cmpi.b  #BKSP,3(A6)     ;maybe a backspace?
                bne.s   osexp_emit      ;if not, then EMIT the character
                addq.l  #1,D2           ;increase counter
                clr.b   0(A3,D1.l)      ;clear character
                subq.l  #1,0(A3,D0.l)   ;SPAN--
                beq.s   osexp_noemit    ;then there's nothing to emit
                movem.l D1-D2,-(SP)     ;save registers
                move.l  #BKSP,-(A6)     ;we want to emit backspace
                bsr     emit            ;do the emit
                move.l  #$20,-(A6)      ;we want to emit space
                bsr     emit            ;do the emit
                bsr     emit            ;second BKSP
                movem.l (SP)+,D1-D2     ;restore registers

                subq.l  #1,D1           ;decrease pointer
                clr.b   0(A3,D1.l)      ;clear character
                move.l  D5,D0
                addi.l  #ospan,D0
                subq.l  #1,0(A3,D0.l)   ;decrease span
                bra.s   osexp_loop

osexp_emit:     move.b  3(A6),0(A3,D1.l)
                addq.l  #1,D1
                movem.l D1-D2,-(SP)
                bsr     emit
                movem.l (SP)+,D1-D2
osexp_noemit:   dbra    D2,osexp_loop
osexp_end:      rts
abort_osexp:    subq.l  #1,D1           ;decrease pointer

                move.l  D5,D0
                addi.l  #ospan,D0
                subq.l  #1,0(A3,D0.l)   ;decrease span
                addq.l  #4,A6           ;DROP
                rts


*-------------------------------------------------------
                DC.L 0
ostype:         move.l  (A6)+,D2        ;count
                move.l  (A6)+,D1        ;address
                dbra    D2,ostype_loop
                bra.s   ostype_end
ostype_loop:    tst.b   0(A3,D1.l)
                beq.s   ostype_end
                clr.l   -(A6)
                move.b  0(A3,D1.l),3(A6)
                addq.l  #1,D1
                movem.l D1-D2,-(SP)
                bsr     emit
                movem.l (SP)+,D1-D2
                dbra    D2,ostype_loop
ostype_end:     rts

                ENDPART

*****************************************************************
                >PART 'some system words'
*-------------------------------------------------------
                DC.L 0
bye:            movea.l (saveret-datas)(A3),SP
                move.l  (bootsys-datas)(A3),-(SP)
                rts


*-------------------------------------------------------
                DC.L 0
b_cold:         move.l  #(tcold-datas),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
systop:         move.l  (tsystop-datas)(A3),-(A6)
                rts


*-------------------------------------------------------
                DC.L 0
sysbot:         move.l  (tsysbot-datas)(A3),-(A6)
                rts


*-------------------------------------------------------
                DC.L 0
datatop:        move.l  (tdatatop-datas)(A3),-(A6)
                rts


*-------------------------------------------------------
                DC.L 0
databot:        move.l  (tdatabot-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
forthparas:     move.l  (tforthparas-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
roottable:      move.l  (troot-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
keys:           move.l  (tkeys-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
key_quests:     move.l  (tkey_quests-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
emits:          move.l  (temits-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
r_ws:           move.l  (tr_ws-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
readsyses:      move.l  (treadsyses-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
writesyses:     move.l  (twritesyses-datas)(A3),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
fence:          move.l  #(tfence-datas),-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
b_front_opt:    move.l  #(twritesyses-datas),-(A6)
                rts


*-------------------------------------------------------
                DC.L 0
b_end_opt:      move.l  #(tend_opt-datas),-(A6)
                rts


*-------------------------------------------------------
                DC.L 0
noop:           rts

*-------------------------------------------------------

                DC.L 0
ver:            move.l  #version,-(A6)
                rts


                ENDPART

*****************************************************************
                >PART 'USER variables'

                DC.L 0
nextuser:       move.l  D5,-(A6)        ;2 Bytes
                addi.l  #ounext,(A6)    ;6
                rts                     ;--------
;8 Bytes = 4 words
                DC.L 0
r_null:         move.l  D5,-(A6)
                addi.l  #ornull,(A6)
                rts

                DC.L 0
s_null:         move.l  D5,-(A6)
                addi.l  #osnull,(A6)
                rts

                DC.L 0
f_null:         move.l  D5,-(A6)
                addi.l  #ofnull,(A6)
                rts

                DC.L 0
state:          move.l  D5,-(A6)
                addi.l  #ostate,(A6)
                rts

                DC.L 0
b_number_quest: move.l  D5,-(A6)
                addi.l  #onumber_quest,(A6)
                rts

                DC.L 0
base:           move.l  D5,-(A6)
                addi.l  #obase,(A6)
                rts

                DC.L 0
dpl:            move.l  D5,-(A6)
                addi.l  #odpl,(A6)
                rts

                DC.L 0
hld:            move.l  D5,-(A6)
                addi.l  #ohld,(A6)
                rts

                DC.L 0
cp:             move.l  D5,-(A6)
                addi.l  #odp,(A6)
                rts

                DC.L 0
dp:             move.l  D5,-(A6)

                addi.l  #odata,(A6)
                rts

                DC.L 0
totib:          move.l  D5,-(A6)
                addi.l  #ototib,(A6)
                rts

                DC.L 0
_tib:           move.l  D5,-(A6)
                addi.l  #o_tib,(A6)
                rts

                DC.L 0
toin:           move.l  D5,-(A6)
                addi.l  #otoin,(A6)
                rts

                DC.L 0
span:           move.l  D5,-(A6)
                addi.l  #ospan,(A6)
                rts

                DC.L 0
current:        move.l  D5,-(A6)
                addi.l  #ocurrent,(A6)
                rts

                DC.L 0
voc_link:       move.l  D5,-(A6)
                addi.l  #ovoc_link,(A6)
                rts

                DC.L 0
vocpa:          move.l  D5,-(A6)
                addi.l  #ovocpa,(A6)
                rts

                DC.L 0
last:           move.l  D5,-(A6)
                addi.l  #olast,(A6)
                rts

;                DC.L 0
;fence:          move.l  D5,-(A6)
;                addi.l  #ofence,(A6)
;                rts

                DC.L 0
b_error:        move.l  D5,-(A6)
                addi.l  #oerror,(A6)
                rts

                DC.L 0
b_key:          move.l  D5,-(A6)
                addi.l  #okey,(A6)
                rts

                DC.L 0
b_emit:         move.l  D5,-(A6)
                addi.l  #oemit,(A6)
                rts

                DC.L 0
b_key_quest:    move.l  D5,-(A6)
                addi.l  #okey_quest,(A6)
                rts

                DC.L 0
b_r_w:          move.l  D5,-(A6)
                addi.l  #or_w,(A6)
                rts

                DC.L 0
b_readsys:      move.l  D5,-(A6)
                addi.l  #oreadsys,(A6)
                rts

                DC.L 0
b_writesys:     move.l  D5,-(A6)
                addi.l  #owritesys,(A6)
                rts

                DC.L 0
t_key:          move.l  D5,-(A6)
                addi.l  #olkey,(A6)
                rts

                DC.L 0
t_emit:         move.l  D5,-(A6)
                addi.l  #olemit,(A6)
                rts

                DC.L 0
t_key_quest:    move.l  D5,-(A6)
                addi.l  #olkey_quest,(A6)
                rts

                DC.L 0
t_r_w:          move.l  D5,-(A6)
                addi.l  #olr_w,(A6)
                rts

                DC.L 0
t_readsys:      move.l  D5,-(A6)
                addi.l  #olreadsys,(A6)
                rts

                DC.L 0
t_writesys:     move.l  D5,-(A6)
                addi.l  #olwritesys,(A6)
                rts


                DC.L 0
b_expect:       move.l  D5,-(A6)
                addi.l  #oexpect,(A6)
                rts

                DC.L 0
b_type:         move.l  D5,-(A6)
                addi.l  #otype,(A6)
                rts

                DC.L 0
b_literal:      move.l  D5,-(A6)
                addi.l  #oliteral,(A6)
                rts

                DC.L 0
b_fliteral:     move.l  D5,-(A6)
                addi.l  #ofliteral,(A6)
                rts

                DC.L 0
macro:          move.l  D5,-(A6)
                addi.l  #omacro,(A6)
                rts

                DC.L 0
is_macro:       move.l  D5,-(A6)
                addi.l  #ois_macro,(A6)
                rts

                DC.L 0
warning:        move.l  D5,-(A6)
                addi.l  #owarning,(A6)
                rts

                DC.L 0
fwidth:         move.l  D5,-(A6)
                addi.l  #ofwidth,(A6)
                rts

                DC.L 0
blk:            move.l  D5,-(A6)
                addi.l  #oblk,(A6)
                rts


                DC.L 0
rootblk:        move.l  D5,-(A6)
                addi.l  #orootblk,(A6)
                rts


                DC.L 0
prev:           move.l  D5,-(A6)
                addi.l  #oprev,(A6)
                rts


                DC.L 0
userbufs:       move.l  D5,-(A6)
                addi.l  #ouserbufs,(A6)
                rts

                DC.L 0
caps:           move.l  D5,-(A6)
                addi.l  #ocaps,(A6)
                rts

                DC.L 0
udp:            move.l  D5,-(A6)
                addi.l  #oudp,(A6)
                rts

                DC.L 0
out:            move.l  D5,-(A6)
                addi.l  #oout,(A6)
                rts

*-----------------------------------------------------------
                DC.L 0
pad:            move.l  D5,D0           ;2
                addi.l  #odata,D0       ;6
                move.l  0(A3,D0.l),D0   ;2
                move.l  D0,D1
                andi.l  #1,D0
                add.l   D1,D0
                addi.l  #$0100,D0
                move.l  D0,-(A6)        ;6
                rts


                DC.L 0
here:           move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
                rts

                ENDPART

*****************************************************************
                >PART 'executing the words in vectors'
*-----------------------------------------------------------
                DC.L 0
number_quest:   move.l  D5,D0           ;2
                addi.l  #onumber_quest,D0 ;6
                move.l  0(A3,D0.l),D0   ;2
                jsr     0(A5,D0.l)      ;2
                rts

*-----------------------------------------------------------
                DC.L 0
loaderkey:                              * jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  D5,D0
                addi.l  #olkey,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                addq.l  #4,SP
                movem.l (SP)+,D1-A6
                move.l  D0,-(A6)
                rts

*-----------------------------------------------------------
                DC.L 0          ;( char -- )
loaderemit:                             *jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  (A6),-(SP)
                move.l  D5,D0
                addi.l  #olemit,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                addq.l  #8,SP
                movem.l (SP)+,D1-A6
                addq.l  #4,A6
                move.l  D5,D0
                addi.l  #oout,D0
                addq.l  #1,0(A3,D0.l)   ;increase OUT
                rts

*-----------------------------------------------------------
                DC.L 0
loaderkey_quest:                        *jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  D5,D0
                addi.l  #olkey_quest,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                addq.l  #4,SP
                movem.l (SP)+,D1-A6
                move.l  D0,-(A6)
                rts

*-----------------------------------------------------------
                DC.L 0
loaderr_w:                              *jsr     (pause-sys-of)(A5)
                movem.l D1-A6,-(SP)
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  8(A6),D0
                add.l   A3,D0
                move.l  D0,8(A6)        ;make addr abs.
                move.l  (A6)+,-(SP)
                move.l  (A6)+,-(SP)
                move.l  (A6)+,-(SP)
                move.l  D5,D0           ;( addr block flag -- flag )
                addi.l  #olr_w,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                lea     $10(SP),SP
                movem.l (SP)+,D1-A6
                lea     $0C(A6),A6
                move.l  D0,-(A6)
                rts
*
* flag = 0:     read
* flag > 0:     write
* flag < 0:     now write, may be changed in future


                DC.L 0
loaderwritesys: movem.l D1-A6,-(SP)     ;( addr count -- flag )
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  A3,D0
                add.l   D0,4(A6)        ;make pointer absolute
                move.l  (A6)+,-(SP)
                move.l  (A6)+,-(SP)
                move.l  D5,D0
                addi.l  #olwritesys,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                lea     $0C(SP),SP
                movem.l (SP)+,D1-A6
                addq.l  #8,A6
                move.l  D0,-(A6)
                rts

*-------------------------------------------------------
                DC.L 0
loaderreadsys:  movem.l D1-A6,-(SP)     ;( addr count -- flag )
                move.l  (tforthparas-datas)(A3),D0
                pea     0(A3,D0.l)
                move.l  A3,D0
                add.l   D0,4(A6)        ;make pointer absolute
                move.l  (A6)+,-(SP)
                move.l  (A6)+,-(SP)
                move.l  D5,D0
                addi.l  #olreadsys,D0
                movea.l 0(A3,D0.l),A0
                jsr     (A0)
                lea     $0C(SP),SP
                movem.l (SP)+,D1-A6
                addq.l  #8,A6
                move.l  D0,-(A6)
                rts


*-----------------------------------------------------------
                DC.L 0
key:            bsr     pause
                move.l  D5,D0
                addi.l  #okey,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)


                DC.L 0
key_quest:      bsr     pause
                move.l  D5,D0
                addi.l  #okey_quest,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)


                DC.L 0
emit:           bsr     pause
                move.l  D5,D0
                addi.l  #oemit,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)


                DC.L 0
r_w:            bsr     pause
                move.l  D5,D0
                addi.l  #or_w,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)



                DC.L 0
expect:         bsr     pause
                move.l  D5,D0
                addi.l  #oexpect,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)


*-----------------------------------------------------------
                DC.L 0
type:           bsr     pause
                move.l  D5,D0
                addi.l  #otype,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)

*-------------------------------------------------------


                DC.L 0
readsys:        bsr     pause
                move.l  D5,D0
                addi.l  #oreadsys,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)


                DC.L 0
writesys:       bsr     pause
                move.l  D5,D0
                addi.l  #owritesys,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)



*---------------------------------------------------------------



                ENDPART

*****************************************************************
                >PART 'Compiler stuff'
*                                                               *
*****************************************************************
                DC.L 0
komma:          move.l  D5,D0           ;( value -- )
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                move.l  (A6)+,0(A3,D1.l) ;32b
                addq.l  #4,D1           ;increment
                move.l  D1,0(A3,D0.l)   ;new DP
                rts


get_segment:    movem.l D0-D2,-(SP)     ;( addr -- codeoff segtableoff )
                move.l  #-1,D0          ;init segment counter
                move.l  (A6)+,D1        ;get addr
                addi.l  #of,D1          ;make addr positiv
g_s_loop:       addq.l  #1,D0           ;increase segment counter
                move.l  D1,D2
                subi.l  #$010000,D1     ;decrease address by 64k
                andi.l  #$FFFF0000,D2   ;is it < 64k
                bne.s   g_s_loop        ;no? then try next segment
                addi.l  #($010000-of),D1 ;take back last decrement
                move.l  D1,-(A6)        ;push codeoffset
                move.l  #(table-datas),D1 ;table base
                lsl.l   #2,D0           ;*4, pointer to LONGs
                add.l   D1,D0           ;rel. tableaddress
                move.l  D0,-(A6)        ;push pointer to segment (in data)
                movem.l (SP)+,D0-D2
                rts

                ENDPART

*****************************************************************
                >PART 'JSR, creates code'
*                     of defined length (8 bytes)               *
*                                                               *
*       movea.l segoff(DT),seg          ( seg = A2 )            *
*       jsr     codeoff(seg)                                    *
*                                                               *
*****************************************************************
                DC.L 0
jsr_komma:      movem.l D1-D2,-(SP)
                move.l  D5,D0           ;( addr -- )
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                lea     0(A5,D1.l),A0   ;calculate absolute address
                bsr.s   get_segment     ;calculate seg & off
                move.w  #move_seg_code,0(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l) ;... with it's argument
                move.w  #jsr_code,4(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,6(A5,D1.l) ;... with it's argument
                addq.l  #8,D1
                move.l  D1,0(A3,D0.l)   ;new DP
                movem.l (SP)+,D1-D2
                rts

                ENDPART

*****************************************************************
                >PART 'THE COMPILER'
*                                                                       *
*************************************************************************
                DC.L 0
com_komma:      movem.l D0-D2/A0-A1,-(SP) ;( CFA -- )
                move.l  (tfront_opt-datas)(A3),D0 ;front_OPT
                jsr     0(A5,D0.l)      ;execute
                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even

                move.l  D5,D0
                addi.l  #omacro,D0
                tst.l   0(A3,D0.l)      ;soll ein Macro kompiliert werden?
                beq.s   com_no_macro    ;dann eben nicht
                move.l  (A6),D0         ;cfa to d0
                btst    #3,-1(A3,D0.l)  ;Macrobit gesetzt?
                beq.s   com_no_macro    ;wenn nicht, dann normal kompilieren
                addq.l  #4,A6           ;drop cfa
                move.b  -2(A3,D0.l),D2  ;CodelÑnge holen (#Worte)
                and.l   #$FF,D2         ;maskieren
                movea.l A5,A0
                adda.l  0(A3,D0.l),A0   ;fetch pfa = cfa @       > abs. address
                dbra    D2,com_macro_loop
                bra     com_kom_end
com_macro_loop: move.w  (A0)+,0(A5,D1.l) ;Code wortweise Åbertragen
                addq.l  #2,D1
                dbra    D2,com_macro_loop
                bra     com_kom_end
com_no_macro:   move.l  (A6),D0         ;cfa
                move.l  0(A3,D0.l),(A6) ;@
                move.l  D5,D0
                addi.l  #ois_macro,D0
                tst.l   0(A3,D0.l)      ;soll es ein Macro werden?
                bne.s   com_no_bsr      ;dann darf kein BSR kompiliert werden
                move.l  D1,D0
                addq.l  #2,D0
                sub.l   (A6),D0         ;rel. Adressdistanz
                cmp.l   #$80,D0         ;>128 Byte
                bpl.s   no_bsr_word
                neg.b   D0
                addq.l  #4,A6
                move.b  #bsrb_code,0(A5,D1.l)
                move.b  D0,1(A5,D1.l)
                addq.l  #2,D1
                bra.s   com_kom_end
no_bsr_word:    cmp.l   #$8000,D0       ;>32k?
                bpl.s   com_no_bsr      ;dann kompiliere direkten Sprung
                neg.w   D0              ;Sprung soll zurÅck fÅhren
                addq.l  #4,A6           ;drop adr
                move.w  #bsr_code,0(A5,D1.l)
                move.w  D0,2(A5,D1.l)
                addq.l  #4,D1
                bra.s   com_kom_end

com_no_bsr:     bsr     get_segment
                move.l  (A6)+,D0        ;get pointer to segment
                cmpi.l  #(table-datas),D0 ;segment = rootsegment?
                beq.s   com_jsr_SB
                move.w  #move_seg_code,0(A5,D1.l) ;create opcode ...
                move.w  D0,2(A5,D1.l)   ;... with it's argument
                addq.l  #4,D1
com_jsr_seg:    move.w  #jsr_code,0(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l) ;... with it's argument
                addq.l  #4,D1
                bra.s   com_kom_end
com_jsr_SB:     move.w  #jsrSB_code,0(A5,D1.l) ;create opcode ...
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l) ;... with it's argument
                addq.l  #4,D1
com_kom_end:    move.l  D5,D0
                addi.l  #odp,D0
                move.l  D1,0(A3,D0.l)
                move.l  (tend_opt-datas)(A3),D0 ;front_OPT
                jsr     0(A5,D0.l)      ;execute
                movem.l (SP)+,D0-D2/A0-A1
                rts

                ENDPART

*****************************************************************
                >PART 'compiler utilities, used later'
*                                                               *
*****************************************************************
                DC.L 0
code_komma:     move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.l  (A6)+,0(A5,D1.l)
*                addq.l  #4,d1
                addi.l  #4,0(A3,D0.l)
                rts

                DC.L 0
code_wkomma:    move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                addq.l  #2,A6
                move.w  (A6)+,0(A5,D1.l)
                addq.l  #2,D1
                move.l  D1,0(A3,D0.l)
                rts


                DC.L 0
jsrSB_komma:    move.l  D5,D0           ;( codeaddr -- )
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.w  #jsrSB_code,0(A5,D1.l)
                addq.l  #2,A6
                move.w  (A6)+,2(A5,D1.l)
                addq.l  #4,D1
                move.l  D1,0(A3,D0.l)
                rts




                DC.L 0
wkomma:         move.l  D5,D0           ;( value16 -- )
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                addq.l  #2,A6           ;stack: long>word
                move.w  (A6)+,0(A3,D1.l) ;16b
                addq.l  #2,D1           ;increment
                move.l  D1,0(A3,D0.l)   ;new DP
                rts


                DC.L 0
ckomma:         move.l  D5,D0           ;( value8 -- )
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                addq.l  #3,A6           ;
                move.b  (A6)+,0(A3,D1.l) ;8b
                addq.l  #1,D1           ;increment
                move.l  D1,0(A3,D0.l)   ;new DP
                rts

                DC.L 0
fkomma:         move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even
                move.l  D5,D0
                addi.l  #ofwidth,D0
                move.l  0(A3,D0.l),D0
                lsr.l   #2,D0
                subq.l  #1,D0
f_komma_loop:   move.l  (A4)+,0(A3,D1.l)
                addq.l  #4,D1
                dbra    D0,f_komma_loop
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  D1,0(A3,D0.l)
                rts

                ENDPART

*****************************************************************
                >PART 'Arithmetic'
*****************************************************************
                DC.L 0
plus_store:     move.l  (A6)+,D1
                move.l  0(A3,D1.l),D0
                add.l   (A6)+,D0
                move.l  D0,0(A3,D1.l)
                rts

                DC.L 0
plus:           move.l  (A6)+,D0
                add.l   D0,(A6)
                rts

                DC.L 0
minus:          move.l  (A6)+,D0
                sub.l   D0,(A6)
                rts

                DC.L 0
mult:           move.l  (A6)+,D0
                move.l  (A6),D1
                move.l  D0,D2
                move.l  D0,D3
                swap    D3
                move.l  D1,D4
                swap    D4
                mulu    D1,D0
                mulu    D3,D1
                mulu    D4,D2
                swap    D0
                add.w   D1,D0
                add.w   D2,D0
                swap    D0
                move.l  D0,(A6)
                rts

                DC.L 0
udivmod:        move.l  (A6)+,D0        ;Divisor
                move.l  (A6),D1         ;Divident
                tst.l   D0
                bne.s   udi_noerr
*                divu    #0,d0           ;force trap
                move.l  #$FFFFFFFF,-(A6)
                rts
udi_noerr:      cmp.l   D0,D1
                bhi.s   dent_gt_isor
                beq.s   dent_eq_isor
dent_ls_isor:   clr.l   -(A6)
                rts
dent_eq_isor:   clr.l   (A6)
                move.l  #1,-(A6)
                rts
dent_gt_isor:   moveq   #31,D2          ;BitzÑhler
                moveq   #0,D3           ;darin wird geschoben
                moveq   #0,D4           ;fÅr das Ergebnis
udivmod0:       add.l   D3,D3           ;2*
                add.l   D4,D4
                btst    D2,D1           ;Bit gesetzt?
                beq.s   udivmod1
                bset    #0,D3
udivmod1:       cmp.l   D3,D0           ;d3<d0?
                bgt.s   udivmod2        ;dann nichts machen
                sub.l   D0,D3           ;abziehen
                bset    #0,D4
udivmod2:       subq.l  #1,D2
                bpl.s   udivmod0
                move.l  D3,(A6)
                move.l  D4,-(A6)
                rts


                DC.L 0
divmod:         moveq   #0,D0
                move.l  (A6),D1
                bpl.s   divmod1         ;wenn nicht dann weiter
                bset    #0,D0
                bset    #1,D0           ;sonst Flag setzen ...
                neg.l   (A6)            ;und negieren
                neg.l   D1
divmod1:        tst.l   4(A6)           ;das gleiche fÅr Dividenden
                bpl.s   divmod2
                bchg    #1,D0
                neg.l   4(A6)
divmod2:        movem.l D0-D1,-(SP)     ;Flag merken
                bsr.s   udivmod
                movem.l (SP)+,D0-D1
                btst    #1,D0           ;bei ungleichen Vorzeichen ...
                beq.s   divmod3
                tst.l   4(A6)
                beq.s   divmod5
                addq.l  #1,(A6)         ;Betrag d. Quotienten erhîhen ...
                sub.l   4(A6),D1        ;Divisor-Rest
                move.l  D1,4(A6)
                neg.l   (A6)
divmod3:        btst    #0,D0           ;Divisor negativ? (Bit NICHT gesetzt)
                beq.s   divmod4
                neg.l   4(A6)           ;Rest --> -Rest
divmod4:        rts
divmod5:        neg.l   (A6)            ;Quotient negieren
                rts

                DC.L 0
div:            bsr.s   divmod
                move.l  (A6)+,(A6)
                rts

                DC.L 0
muldivmod:      move.l  (A6)+,-(SP)
                bsr     mult
                move.l  (SP)+,-(A6)
                bsr.s   divmod
                rts

                DC.L 0
muldiv:         bsr.s   muldivmod
                move.l  (A6)+,(A6)
                rts

                DC.L 0
and:            move.l  (A6)+,D0
                and.l   D0,(A6)
                rts

                DC.L 0
or:             move.l  (A6)+,D0
                or.l    D0,(A6)
                rts

                DC.L 0
xor:            move.l  (A6)+,D0
                eor.l   D0,(A6)
                rts

                DC.L 0
not:            not.l   (A6)
                rts

                DC.L 0
negate:         neg.l   (A6)
                rts

                DC.L 0
abs:            tst.l   (A6)
                bpl.s   abs_end
                neg.l   (A6)
abs_end:        rts


                ENDPART

*****************************************************************
                >PART 'ALLOT, EXIT, EXECUTE'
*----------------------------------------------------------------------
                DC.L 0
allot:          move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                add.l   (A6)+,D1
                move.l  D1,0(A3,D0.l)
                rts

                DC.L 0
exit:           move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.w  #rts_code,0(A5,D1.l)
                addq.l  #2,D1
                move.l  D1,0(A3,D0.l)
                rts


                DC.L 0
execute:        move.l  (A6)+,D0
                jmp     0(A5,D0.l)

                ENDPART

*****************************************************************
                >PART 'basic stack manipulations'
*****************************************************************
                DC.L 0
sp_fetch:       move.l  A6,D0           ;get stackpointer
                sub.l   A3,D0           ;make it relativ in DT
                move.l  D0,-(A6)        ;push it on the stack
                rts


                DC.L 0
sp_store:       move.l  (A6)+,D0
                add.l   A3,D0
                movea.l D0,A6
                rts


                DC.L 0
to_r:           movea.l (SP),A0         ;RÅcksprung sichern
                move.l  (A6)+,D0
                add.l   A5,D0           ;calculate abs. address
                move.l  D0,(SP)
                jmp     (A0)            ;statt RTS

                DC.L 0
r_from:         movea.l (SP)+,A0        ;RÅcksprung sichern
                move.l  (SP)+,D0
                sub.l   A5,D0           ;make pointer relativ
                move.l  D0,-(A6)
                jmp     (A0)            ;statt RTS

                DC.L 0
r_fetch:        move.l  4(SP),D0
                sub.l   A5,D0
                move.l  D0,-(A6)
                rts

                ENDPART

*****************************************************************
                >PART 'I/O basics'
*****************************************************************
                DC.L 0
cr:             move.l  #$0D,-(A6)
                bsr     emit
                move.l  #$0A,-(A6)
                bsr     emit
                move.l  D5,D0
                addi.l  #oout,D0
                clr.l   0(A3,D0.l)
                rts


                DC.L 0
space:          move.l  #$20,-(A6)
                bsr     emit
                rts

                ENDPART

*****************************************************************
                >PART 'compiling numbers'
*****************************************************************
                DC.L 0
lit:            move.l  D5,D0           ;( number -- )
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ; CP @
                move.w  #moveimm_sp,0(A5,D1.l) ; codew,
                move.l  (A6)+,2(A5,D1.l) ; code,
                addq.l  #6,D1           ;increment CP
                move.l  D1,0(A3,D0.l)   ;write it back
                rts


                DC.L 0
literal:        move.l  D5,D0
                addi.l  #oliteral,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)



                DC.L 0
floatlit:       move.l  D5,D0
                addi.l  #ofwidth,D0
                move.l  0(A3,D0.l),D0
                move.l  D0,D1
                lsr.l   #2,D0
                subq.l  #1,D0
                movea.l (SP)+,A0
                movea.l A0,A1           ;save a0 for return
                movea.l (A0),A0         ;fetch pointer in  DT
                adda.l  A3,A0           ;calculate abs. address
                adda.l  D1,A0           ;point to end of float
flit_loop:      move.l  -(A0),-(A4)
                dbra    D0,flit_loop
                jmp     4(A1)


                DC.L 0
flit:           move.l  #(floatlit-sys-of),-(A6) ;floatlit
                bsr     jsrSB_komma     ;compile
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6) ;data @
                bsr     code_komma
*                move.l  d5,d0
*                addi.l  #odp,d0
*                move.l  (a3,d0.l),d1
*                move.l  d2,(a5,d1.l)
*                addi.l  #4,(a3,d0.l)    ; ',' in code segment
                bsr     fkomma          ;compile number in data segment
                rts


                DC.L 0
fliteral:       move.l  D5,D0
                addi.l  #ofliteral,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)


                ENDPART

*****************************************************************
                >PART 'runtimes for strings and error'
*****************************************************************

                DC.L 0
b_str_quote:    movem.l D0/A0,-(A6)
                movea.l (SP)+,A0        ;get pointer to stringaddress
                move.l  (A0),D0         ;get string address
                adda.l  #4,A0           ;increace return pointer
                move.l  A0,-(SP)        ;push it back on the stack
                move.l  D0,-(SP)        ;save ptr to text there, too
                movem.l (A6)+,D0/A0     ;restore registers
                move.l  (SP)+,-(A6)     ;move result
                rts


                DC.L 0
b_string_emit:  movem.l D0/A0,-(A6)
                movea.l (SP)+,A0        ;get pointer to stringaddress
                move.l  (A0),D0         ;get string address
                adda.l  #4,A0           ;increace return pointer
                move.l  A0,-(SP)        ;pd5h it back on the stack
                move.l  D0,-(A6)        ;push strings address
                addq.l  #1,(A6)         ;for countbyte
                clr.l   -(A6)           ;prepare stack for byte op.
                move.b  0(A3,D0.l),3(A6) ;push countbyte
                bsr     type            ;emit the string
                movem.l (A6)+,D0/A0     ;restore registers
                rts


                DC.L 0
b_error_quote:  tst.l   (A6)+           ;Flag testen
                beq.s   end_b_error_quote ;Fehlerbehandlung nicht ausfÅhren
                move.l  (A6)+,D1        ;Stringadresse
                moveq   #0,D0
                move.b  0(A3,D1.l),D0   ;LÑnge
                addq.l  #1,D1
                move.l  D1,-(A6)        ;Adresse
                move.l  D0,-(A6)        ;count
                bsr     type            ;String, der Fehler erzeugt hat, ausgeben
                movea.l (SP)+,A0        ;Stringadresse holen
                move.l  (A0),D1         ;fetch rel. pointer
                moveq   #0,D0
                move.b  0(A3,D1.l),D0   ;get length
                addq.l  #1,D1
                move.l  D1,-(A6)
                move.l  D0,-(A6)
                bsr     type            ;Fehlermeldung ausgeben
                bsr     space
                move.l  D5,D0
                addi.l  #oerror,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)      ;Åber Fehlervektor raus
end_b_error_quote:
                addi.l  #4,(SP)
                rts


                DC.L 0
b_abort_quote:  tst.l   (A6)+           ;Flag testen
                beq.s   end_b_abort_quote ;Fehlerbehandlung nicht ausfÅhren
                movea.l (SP)+,A0        ;Stringadresse holen
                move.l  (A0),D1         ;fetch rel. pointer
                moveq   #0,D0
                move.b  0(A3,D1.l),D0   ;get length
                addq.l  #1,D1
                move.l  D1,-(A6)
                move.l  D0,-(A6)
                bsr     type            ;Fehlermeldung ausgeben
                bsr     space
                move.l  D5,D0
                addi.l  #oerror,D0
                move.l  0(A3,D0.l),D0
                jmp     0(A5,D0.l)      ;Åber Fehlervektor raus
end_b_abort_quote:
                addi.l  #4,(SP)
                rts

                ENDPART

*****************************************************************
                >PART 'mass storage interface'
*                                                               *
*****************************************************************
*                                                               *
*       structure of a buffer:                                  *
*                                                               *
*       1.      bufheader (14 bytes) RAM only                   *
*       2.      bufheader (48 bytes) on disk too                *
*       3.      data      (2000 bytes) on disk	                  *
*                                                               *
*                                                               *
*       1.)                                                     *
*               pointer to next buffer (cyclic)                 *
*               phys. blocknumber                               *
*               log. blocknumber (yet unused)                   *
*               UPDATE  flag                                    *
*                                                               *
*       2.)                                                     *
*               yet unused                                      *
*                                                               *
*****************************************************************

                DC.L 0
quest_core:     move.l  D5,D1           ;( blk -- bufaddr|ff )
                addi.l  #oprev,D1
                move.l  0(A3,D1.l),D1
                move.l  D1,D0
                move.l  (A6)+,D2        ;blk
q_core_loop:    cmp.l   4(A3,D0.l),D2   ;aktiv?
                beq.s   q_core_found
                move.l  0(A3,D0.l),D0   ;link to next buffer
                cmp.l   D1,D0           ;first buffer again?
                beq.s   q_core_notfound
                bra.s   q_core_loop
q_core_found:   move.l  D0,-(A6)        ;push address of buffer
                rts
q_core_notfound:clr.l   -(A6)           ;FALSE
                rts


                DC.L 0
lastblk:        move.l  #(lastblkptr-datas),-(A6)
                rts


                DC.L 0
lastbuf:        move.l  #(lastbufptr-datas),-(A6)
                rts


                DC.L 0
b_buffer:       move.l  (A6),-(SP)      ;( blk -- addr )
                bsr.s   quest_core
                tst.l   (A6)            ;block already in memory?
                bne.s   buf_ok
                move.l  D5,D1
                addi.l  #oprev,D1
                move.l  0(A3,D1.l),D0   ; PREV @
                move.l  0(A3,D0.l),D0   ; latest used buffer
                tst.w   $0C(A3,D0.l)    ; UPDATE ?
                beq.s   nosave
                move.l  D0,-(SP)
                move.l  D0,-(A6)        ;address
                addi.l  #$0E,(A6)       ;pointer to block
                move.l  4(A3,D0.l),-(A6) ;phys. block
                move.l  #1,-(A6)        ;flag: write
                bsr     r_w
                move.l  (SP)+,D0
                clr.w   $0C(A3,D0.l)    ;clear UPDATE
                tst.l   (A6)+
                beq.s   buffer_err
nosave:         move.l  D0,(A6)
buf_ok:         move.l  (SP)+,4(A3,D0.l) ;new (or old) phys. block
                move.l  D5,D0
                addi.l  #oprev,D0
                move.l  (A6),0(A3,D0.l) ;mark new PREV
                addi.l  #(14+48),(A6)   ;pointer to data
                rts
buffer_err:     addq.l  #4,SP
                addq.l  #4,A6
                move.l  #-1,-(A6)
                bsr     b_abort_quote
                DC.L (buferrmess-datas)

                DC.L 0
buffer:         jsr     (dodefer-sys-of)(A5)
                DC.L (bufferptr-datas)
*                rts



                DC.L 0          ;( blk -- addr )
b_block:        move.l  D5,D0
                addi.l  #orootblk,D0
                move.l  0(A3,D0.l),D0
                add.l   D0,(A6)         ;blk + rootblk
*                move.l  (lastblkptr-datas)(A3),D0 ;get last blocknumber
*                cmp.l   (A6),D0         ;try to get the same?
*                bne     bb_block        ;no?, then do full procedure
*                move.l  (lastbufptr-datas)(A3),(A6) ;or return last buffer
*                rts
bb_block:       move.l  (A6),(lastblkptr-datas)(A3)
                move.l  (A6),-(SP)      ;save blk
                bsr     quest_core      ;already in memory
                tst.l   (A6)
                bne.s   blk_ok
                move.l  (SP),(A6)
                bsr     b_buffer        ;( blk -- addr )
                move.l  (A6),-(A6)
                subi.l  #48,(A6)        ;to start of block
                move.l  (SP)+,-(A6)
                clr.l   -(A6)
                bsr     r_w
                tst.l   (A6)+
                beq.s   block_err
                move.l  (A6),(lastbufptr-datas)(A3)
                rts
blk_ok:         addi.l  #(14+48),(A6)
                addq.l  #4,SP
                move.l  (A6),(lastbufptr-datas)(A3)
                rts
block_err:      move.l  D5,D0
                addi.l  #oprev,D0
                move.l  0(A3,D0.l),D0   ;pointer to buffer
                move.l  #-1,4(A3,D0.l)  ;mark buffer as unused
                move.l  #-1,(A6)
                bsr     b_abort_quote
                DC.L (blkerrmess-datas)


                DC.L 0          ;( block -- adr )
block:          jsr     (dodefer-sys-of)(A5)
                DC.L (blockptr-datas)
*                rts

                ENDPART

*****************************************************************
                >PART 'interpreter words'
*****************************************************************
                DC.L 0
tib:            move.l  D5,D0           ;( -- tib )
                addi.l  #ototib,D0
                move.l  0(A3,D0.l),-(A6)
                rts

                DC.L 0
query:          move.l  D5,D0           ;( -- )
                addi.l  #ototib,D0
                move.l  0(A3,D0.l),-(A6)
                move.l  #255,-(A6)
                bsr     expect
                move.l  D5,D0
                addi.l  #otoin,D0
                clr.l   0(A3,D0.l)      ;>IN to 0
                move.l  D5,D0
                addi.l  #oblk,D0
                clr.l   0(A3,D0.l)      ;BLK to 0
                move.l  D5,D0
                move.l  D5,D1
                addi.l  #ospan,D0
                addi.l  #o_tib,D1
                move.l  0(A3,D0.l),0(A3,D1.l) ;SPAN to #TIB
                bsr     space
                rts


                DC.L 0
skip:           movem.l D0-D2,-(SP)     ;( ad1 n1 char -- ad2 n2 )
                move.l  (A6)+,D0        ;char
                tst.l   (A6)
                ble.s   no_skip         ;n1<=0?
                move.l  (A6)+,D1        ;n1
                move.l  (A6)+,D2        ;ad1
skip_loop:      cmp.b   0(A3,D2.l),D0   ;Zeichen vergleichen und weiterzÑhlen
                bne.s   skip_end        ;Zeichen ungleich dann raus
                addq.l  #1,D2           ;increase pointer
                subq.w  #1,D1           ;ZÑhler dekrementieren
                bne.s   skip_loop       ;bis auf 0 runtergezÑhlt
skip_end:       move.l  D2,-(A6)        ;ad2
                move.l  D1,-(A6)        ;n2
no_skip:        movem.l (SP)+,D0-D2
                rts


                DC.L 0
scan:           movem.l D0-D2,-(SP)     ;( ad1 n1 char -- ad2 n2 )
                move.l  (A6)+,D0        ;char
                tst.l   (A6)
                ble.s   no_scan         ;n1<=0?
                move.l  (A6)+,D1        ;n1
                move.l  (A6)+,D2        ;ad1
scan_loop:      cmp.b   0(A3,D2.l),D0   ;Zeichen vergleichen und weiterzÑhlen
                beq.s   scan_end        ;Zeichen gleich dann raus
                addq.l  #1,D2           ;increase pointer
                subq.l  #1,D1           ;ZÑhler dekrementieren
                bne.s   scan_loop       ;bis auf 0 runtergezÑhlt
scan_end:       move.l  D2,-(A6)        ;ad2
                move.l  D1,-(A6)        ;n2
no_scan:        movem.l (SP)+,D0-D2
                rts


                DC.L 0
source:         move.l  D5,D0           ;( -- addr len )
                addi.l  #oblk,D0
                move.l  0(A3,D0.l),D0
                beq.s   src_is_tib
                movem.l D1-D2,-(SP)
                move.l  D0,-(A6)
                bsr     b_block
                movem.l (SP)+,D1-D2
                move.l  #bytesperblock,-(A6)
                rts
src_is_tib:     move.l  D5,D0
                addi.l  #ototib,D0
                move.l  0(A3,D0.l),-(A6)
                move.l  D5,D0
                addi.l  #o_tib,D0
                move.l  0(A3,D0.l),-(A6)
                rts


                DC.L 0
word:           movem.l D0-D4/A0,-(SP)  ;( char -- addr )
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D2,D1           ;make DP even, DP in d1

                bsr.s   source
                move.l  (A6)+,D3        ;len of source
                add.l   (A6),D3         ;calculate end of source
                move.l  (A6)+,D2
                move.l  D2,-(SP)
                move.l  D5,D0
                addi.l  #otoin,D0
                add.l   0(A3,D0.l),D2   ;actual pointer in the source

                move.l  (A6)+,D0        ;char as delimiter in d0
                sub.l   D2,D3           ;length of rest of source in d3

                move.l  D2,-(A6)
                move.l  D3,-(A6)
                move.l  D0,-(A6)
                bsr     skip
                move.l  4(A6),-(SP)     ;save startaddress on stack
                move.l  D0,-(A6)
                bsr     scan
                move.l  (SP),D4         ;startaddress of string

                move.l  4(A6),D3        ;endaddress
                sub.l   D4,D3           ;end-start
                move.b  D3,0(A3,D1.l)   ;mark length at HERE
                addq.l  #1,D1           ;increase dest. pointer

                movea.l (SP)+,A0        ;get back startaddr.
                adda.l  A3,A0           ;calc. abs. address

                move.l  (SP)+,D2        ;
                sub.l   4(A6),D2        ;end - >WORD = >IN
                neg.l   D2
                addq.l  #1,D2
                move.l  D5,D0
                addi.l  #otoin,D0
                move.l  D2,0(A3,D0.l)   ;set new >IN

                dbra    D3,word_loop    ;startaddr. in A0
                bra.s   word_end
word_loop:      move.b  (A0)+,0(A3,D1.l)
                addq.l  #1,D1
                dbra    D3,word_loop
                move.b  #0,0(A3,D1.l)
word_end:       addq.l  #8,A6           ;2DROP
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1   ;fetch DP
                move.l  D1,D0
                andi.l  #1,D0
                add.l   D0,D1           ;make it even s.a.
                move.l  D1,-(A6)        ;here's the string now
                movem.l (SP)+,D0-D4/A0
                rts


                DC.L 0
char:           move.l  #$20,-(A6)
                bsr     word
                move.l  (A6),D0
                clr.l   (A6)
                move.b  1(A3,D0.l),3(A6)
                rts


                DC.L 0
b_char:         bsr.s   char
                bsr     literal
                rts


                DC.L 0
capital:        cmpi.l  #'a',(A6)
                blt.s   capital_end
                cmpi.l  #'z',(A6)
                bgt.s   capital_end
                subi.l  #$20,(A6)
capital_end:    rts


                DC.L 0
capitalize:     movea.l (A6),A0         ;adr
                adda.l  A3,A0           ;calculate abs. pointer
                moveq   #0,D0
                move.b  (A0)+,D0        ;count
                beq.s   cap_end
                moveq   #0,D1
cap_loop:       move.b  (A0),D1         ;fetch character
                cmp.b   #'a',D1
                blt.s   no_cap
                cmp.b   #'z',D1
                bgt.s   no_cap
                subi.b  #$20,D1
no_cap:         move.b  D1,(A0)+        ;restore converted character
                subq.l  #1,D0
                bne.s   cap_loop
cap_end:        rts


                DC.L 0
name:           move.l  #$20,-(A6)      ;BL on the stack
                bsr     word
                move.l  D5,D0
                addi.l  #ocaps,D0
                tst.l   0(A3,D0.l)
                beq.s   nocap
                bsr.s   capitalize
nocap:          rts


* preparations for FIND
                DC.L 0
vocsearch:      movem.l D0/A0-A2,-(SP)  ;( str voc -- cfa controlword / str -1 )
                move.l  (A6)+,D0        ;pointer to vocabulary
                lea     0(A3,D0.l),A0   ;pointer to header of last word
                movea.l (A6),A1         ;str in a1
                adda.l  A3,A1
vocsearch_loop: movea.l (A0),A0         ;link to next LFA
                adda.l  A3,A0           ;make pointer absolute
                tst.l   (A0)            ;das 0-Linkfeld?
                beq.s   vocsearch_false ;-> das Ende des Voc.
                movea.l A0,A2           ;und in a2
                addq.l  #4,A2           ;Zeiger auf String
                move.w  (A2),D1
                cmp.w   (A1),D1         ;gleich ?
                bne.s   vocsearch_loop
                moveq   #0,D0
                move.b  (A2)+,D0        ;LÑnge
                addq.l  #1,A1
                subq.b  #1,D0
exef_str_cmp:   cmpm.b  (A2)+,(A1)+     ;Zeichen vergleichen
                dbne    D0,exef_str_cmp
                movea.l (A6),A1
                adda.l  A3,A1
                bne.s   vocsearch_loop
vocsearch_true: move.l  A0,D0           ;for rel. addressing
                sub.l   A3,D0
                subq.l  #4,D0           ;lfa > cfa
                btst    #0,-1(A3,D0.l)  ;smudge?
                bne.s   vocsearch_loop  ;then go on searching
                move.l  D0,(A6)         ;cfa > stack
                move.w  -2(A3,D0.l),-(A6) ;fetch control word
                clr.w   -(A6)
                movem.l (SP)+,D0/A0-A2
                rts                     ;and ready ...
vocsearch_false:move.l  #-1,-(A6)       ;the TRUE-flag for "not found"
                movem.l (SP)+,D0/A0-A2
                rts


                DC.L 0          ;( addr -- cfa controlword | addr -1 )
b_find:         move.l  #-1,-(A6)       ;ein Dummy-Flag ( str -1 )
                move.l  D5,D0
                addi.l  #ovocpa,D0
                movea.l 0(A3,D0.l),A0   ;Basis des Vocabularstacks
                adda.l  A3,A0           ;convert to abs. pointer
                move.l  (A0)+,D0        ;Hîhe dieses Stacks
find_loop:      subq.w  #4,D0
                bmi.s   find_false      ;Vocabulare alle durch?
                move.l  0(A0,D0.w),(A6) ;( str *name ) 'CONTEXT @'
                bsr.s   vocsearch       ;search vocabulary
                cmpi.l  #-1,(A6)        ;gefunden?
                beq.s   find_loop       ;nein, dann nÑchstes Vocabular
                rts                     ;sonst mit Freudenschrei zurÅck
find_false:     move.l  #-1,(A6)        ;das widersinnige TRUE-Flag
                rts                     ;und nach Hause


                DC.L 0
find:           jsr     (dodefer-sys-of)(A5)
                DC.L (findptr-datas)



                DC.L 0          ;( addr -- addr false | true )
nulst_quest:    move.l  (A6),D0
                tst.b   0(A3,D0.l)      ;Countbyte=0?
                beq.s   nulst_true
                clr.l   -(A6)           ;additional falseflag
                rts
nulst_true:     move.l  #-1,(A6)        ;trueflag
                rts


                DC.L 0
notfound:       jsr     (dodefer-sys-of)(A5) ;s.u.
                DC.L (notfndptr-datas) ; ' unknown IS notfound
*                rts


                DC.L 0
unknown:        move.l  #-1,-(A6)       ;TRUE-Flag
                bsr     b_error_quote   ;error"
                DC.L (unknownmess-datas) ;9,' unknown!'
                rts


                DC.L 0
h_tick:         bsr     name
                bsr.s   find
                cmpi.l  #-1,(A6)+
                beq.s   h_tick_err
                rts
h_tick_err:     bsr.s   notfound
                rts


                DC.L 0
tick:           bsr.s   h_tick
                move.l  (A6)+,D0
                move.l  0(A3,D0.l),-(A6) ;fetch pfa
                rts


                DC.L 0
b_tick:         bsr.s   tick
                bsr     literal
                rts


                DC.L 0
quest_stack:    movem.l D0-D1,-(SP)
                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  0(A3,D0.l),D1
                add.l   A3,D1
                cmpa.l  D1,A6
                ble.s   quest_stck1
                movea.l 0(A3,D0.l),A6
                adda.l  A3,A6
                move.l  #-1,-(A6)
                bsr     b_abort_quote
                DC.L (stkundermess-datas) ;
quest_stck1:    move.l  D5,D0
                addi.l  #ofnull,D0
                move.l  0(A3,D0.l),D1
                add.l   A3,D1
                cmpa.l  D1,A4
                ble.s   stack_ok
                movea.l 0(A3,D0.l),A4
                adda.l  A3,A4
                move.l  #-1,-(A6)
                bsr     b_abort_quote
                DC.L (fltundermess-datas) ;
stack_ok:       movem.l (SP)+,D0-D1
                rts



                DC.L 0          ;( addr -- )
compiler:       bsr     find
                cmpi.l  #-1,(A6)
                beq.s   cnot_found
                btst    #1,3(A6)        ;immediate?
                beq.s   cnot_immediate
cnorestrict:    addq.l  #4,A6           ;drop Kontrollwort
                move.l  (A6)+,D0        ;execute
                move.l  0(A3,D0.l),D0
                jsr     0(A5,D0.l)
                rts                     ;success
cnot_immediate: addq.l  #4,A6           ;drop controlword
                bsr     com_komma       ;com,
                rts                     ;success
cnot_found:     addq.l  #4,A6           ;drop controlword
                bsr     number_quest    ;number? ( adr -- string false/Zahl #longs )
                tst.l   (A6)            ;test flag
                beq.s   cno_number      ;no number
                move.l  (A6)+,D1        ;d1<0 => number on floatstack
                bpl.s   comp_num
comp_fnum:      bsr     fliteral
                rts
comp_num:       bsr     literal         ;compile number
                rts                     ;UFF!!!!
cno_number:     addq.l  #4,A6           ;drop falseflag
                bra     notfound        ;neither word nor number



                DC.L 0          ;( addr -- )
interpreter:    bsr     find
                cmpi.l  #-1,(A6)
                beq.s   inot_found
                btst    #2,3(A6)        ;restrict?
                beq.s   inorestrict
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),4(A6) ;string is at HERE
                bsr     b_error_quote   ;error"        ( str flag -- )
                DC.L (restrmess-datas)
inorestrict:    addq.l  #4,A6           ;drop Kontrollwort
                move.l  (A6)+,D0        ;execute
                move.l  0(A3,D0.l),D0
                jsr     0(A5,D0.l)
                rts                     ;success
inot_found:     addq.l  #4,A6           ;drop controlword
                bsr     number_quest    ;number? ( adr -- string false/n #longs )
                tst.l   (A6)+           ;test flag
                beq.s   ino_number      ;no_number?
                rts
ino_number:     bra     notfound        ;no success



                DC.L 0
parser:         jsr     (dodefer-sys-of)(A5)
                DC.L (parserptr-datas)
*                rts


                DC.L 0
interpret:      bsr     name            ;nÑchstes Wort suchen
                bsr     nulst_quest     ;Ende des Eingabestroms?
                tst.l   (A6)+
                bne.s   end_interpret
                bsr.s   parser
                bra.s   interpret
end_interpret:  rts

                ENDPART

*****************************************************************
                >PART 'PUSH and EVALUATE'

repush:         movea.l (SP)+,A0
                move.l  (SP)+,(A0)
                rts


                DC.L 0          ;( addr -- )
push:           movea.l (SP)+,A0        ;get return
                movea.l (A6)+,A1        ;addr in A1
                adda.l  A3,A1           ;make it absolute
                move.l  (A1),-(SP)      ;push variable on stack
                move.l  A1,-(SP)        ;push addr on stack
                move.l  #(repush-sys-of),D0
                add.l   A5,D0
                move.l  D0,-(SP)        ;push runtimecode
                jmp     (A0)            ;return


poparea:        movea.l (SP)+,A0        ;get back addr
                move.l  (SP)+,D0        ;get back count
poparealoop:    move.w  (SP)+,-(A0)
                dbra    D0,poparealoop
                rts


                DC.L 0          ;( addr count -- )
savearea:       movea.l (SP)+,A1
                move.l  (A6)+,D0        ;get count
                lsr.l   #1,D0           ;only words are moved
                move.l  D0,D1           ;save in D1
                movea.l (A6)+,A0        ;get addr
                adda.l  A3,A0           ;make it absolute
savearealoop:   move.w  (A0)+,-(SP)
                dbra    D1,savearealoop
                move.l  D0,-(SP)
                move.l  A0,-(SP)
                move.l  #(poparea-sys-of),D0
                add.l   A5,D0
                move.l  D0,-(SP)        ;push runtimecode
                jmp     (A1)


                DC.L 0          ;( c-addr u -- )
evaluate:       move.l  D5,D0
                addi.l  #ototib,D0
                move.l  0(A3,D0.l),-(A6)
                move.l  4(A6),-(A6)
                bsr.s   savearea        ;save TIB
                move.l  D5,D0
                addi.l  #o_tib,-(A6)
                bsr.s   push            ;save #TIB
                move.l  D5,D0
                addi.l  #otoin,-(A6)
                bsr.s   push            ;save >IN
                move.l  D5,D0
                addi.l  #oblk,-(A6)
                bsr.s   push            ;save BLK
                move.l  D5,D0
                addi.l  #oblk,D0
                clr.l   0(A3,D0.l)      ;BLK off
                move.l  (A6),D0         ;get count u
                movea.l 4(A6),A0        ;get c-addr
                adda.l  A3,A0           ;make it absolute
                move.l  D5,D1
                addi.l  #ototib,D1
                movea.l 0(A3,D1.l),A1   ;get TIB
                adda.l  A3,A1           ;make it absolute
                lsr.l   #1,D0           ;move word-wise
evalloop:       move.w  (A0)+,(A1)+     ;move string
                dbra    D0,evalloop
                move.l  D5,D0
                addi.l  #o_tib,D0
                move.l  (A6)+,0(A3,D0.l) ;count #TIB !
                move.l  D5,D0
                addi.l  #otoin,D0
                clr.l   0(A3,D0.l)      ;0 >IN !
                addq.l  #4,A6           ;drop c-addr
                bsr     interpret
                rts
                ENDPART

*****************************************************************
                >PART 'convert number --> string'
*****************************************************************
                DC.L 0
less_sharp:     move.l  D5,D0
                move.l  D5,D1
                addi.l  #odata,D0
                addi.l  #ohld,D1
                move.l  0(A3,D0.l),0(A3,D1.l)
                addi.l  #$0100,0(A3,D1.l) ;PAD
                rts


                DC.L 0
sharp_greater:  addq.l  #4,A6           ;drop
                move.l  D5,D0
                move.l  D5,D1
                addi.l  #odata,D0
                addi.l  #ohld,D1
                move.l  0(A3,D0.l),D0
                addi.l  #$0100,D0       ;PAD in d0
                move.l  0(A3,D1.l),D1   ;HLD in d1
                sub.l   D1,D0           ;LÑnge
                move.l  D1,-(A6)        ;addr
                move.l  D0,-(A6)
                rts


                DC.L 0
hold:           move.l  D5,D0
                addi.l  #ohld,D0
                move.l  0(A3,D0.l),D1   ;fetch HLD
                subq.l  #1,D1           ;predecrement
                addq.l  #3,A6
                move.b  (A6)+,0(A3,D1.l)
                move.l  D1,0(A3,D0.l)
                rts


                DC.L 0
sign:           tst.l   (A6)+
                bpl.s   sign_end
                move.l  #'-',-(A6)
                bsr.s   hold
sign_end:       rts


                DC.L 0
sharp:          move.l  D5,D0
                addi.l  #obase,D0
                move.l  0(A3,D0.l),-(A6)
                bsr     udivmod         ;( mod / )
                move.l  (A6)+,-(SP)     ;Quotient retten
                cmpi.l  #10,(A6)        ;Rest > 9
                bmi.s   sharp1
                addi.l  #7,(A6)
sharp1:         addi.l  #'0',(A6)
                bsr.s   hold
                move.l  (SP)+,-(A6)     ;Quotient zurÅck
                rts


                DC.L 0
sharp_s:        bsr.s   sharp
                tst.l   (A6)
                bne.s   sharp_s
                rts


                DC.L 0
udot:           bsr     less_sharp      ;<#
                bsr.s   sharp_s         ;#s
                bsr     sharp_greater   ;#>
                bsr     type            ;type
                bsr     space
                rts


                DC.L 0
dot:            move.l  (A6),-(A6)      ;dup
                bpl.s   dot_pos
                move.l  #-1,4(A6)       ;-1 unterschieben
                neg.l   (A6)            ;negieren
dot_pos:        bsr     less_sharp
                bsr.s   sharp_s
                move.l  4(A6),(A6)
                bsr.s   sign
                bsr     sharp_greater
                bsr     type
                bsr     space
                rts


                DC.L 0
prompt:         move.l  D5,D0
                addi.l  #ostate,D0
                tst.l   0(A3,D0.l)
                bne.s   prompt_end
                bsr     space
                move.l  #'o',-(A6)
                bsr     emit
                move.l  #'k',-(A6)
                bsr     emit
prompt_end:     rts

                ENDPART

*****************************************************************
                >PART 'compiler words'
*                                                               *
*****************************************************************
                DC.L 0
left_brack:     move.l  D5,D0
                addi.l  #ostate,D0
                clr.l   0(A3,D0.l)
                move.l  #(interpreter-sys-of),parserptr-datas(A3)
                rts

                DC.L 0
right_brack:    move.l  D5,D0
                addi.l  #ostate,D0
                move.l  #-1,0(A3,D0.l)
                move.l  #(compiler-sys-of),parserptr-datas(A3)
                rts


                DC.L 0
align:          move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),D1
                move.l  D1,D2
                andi.l  #1,D2
                add.l   D1,D2
                move.l  D2,0(A3,D0.l)
                rts

                ENDPART

*****************************************************************
                >PART 'the main loop'
*                                                               *
*****************************************************************
                DC.L 0
quit:           move.l  D5,D0
                addi.l  #ornull,D0
                move.l  0(A3,D0.l),D0
                lea     0(A3,D0.l),SP   ;set returnstack

                move.l  D5,D0
                addi.l  #ostate,D0
                clr.l   0(A3,D0.l)      ;State auf NULL
                move.l  #(interpreter-sys-of),parserptr-datas(A3)

                move.l  D5,D0
                addi.l  #osnull,D0
                move.l  0(A3,D0.l),D0
                add.l   A3,D0
                cmpa.l  D0,A6           ;datastack underflow?
                ble.s   test_fstack
                movea.l D0,A6           ;reset datastack
test_fstack:    move.l  D5,D0
                addi.l  #ofnull,D0
                move.l  0(A3,D0.l),D0
                add.l   A3,D0
                cmpa.l  D0,A4           ;floatstack underflow?
                ble.s   quit_loop
                movea.l D0,A4           ;reset floatstack
quit_loop:      bsr     prompt
                bsr     cr
                bsr     query
                bsr     interpret
                bsr     quest_stack
                bra.s   quit_loop


                DC.L 0
cold:           move.l  (tcold-datas)(A3),D0
                jsr     0(A5,D0.l)
                rts

                ENDPART

*****************************************************************
                >PART 'convert string --> number'
*****************************************************************
                DC.L 0
digit_quest:    movem.l D0-D1,-(SP)
                move.l  (A6),D0         ;Zeichen nach d0
                sub.b   #'0',D0         ;Zeichen -> Zahl
                bmi.s   digit_false     ;<0? dann keine Ziffer
                cmp.b   #16,D0          ;vergl. Ziffer mit 15
                bgt.s   dig_quest1      ;Ziffer>15?, dann mach weiter
                cmp.b   #10,D0          ;10<=Ziffer<=15?, dann keine Ziffer
                bge.s   digit_false
                bra.s   dig_quest2
dig_quest1:     sub.b   #7,D0           ;'A' -> 10
dig_quest2:     move.l  D5,D1
                addi.l  #obase,D1
                cmp.l   0(A3,D1.l),D0
                bmi.s   digit_true
digit_false:    clr.l   (A6)            ;FALSE
                movem.l (SP)+,D0-D1
                rts
digit_true:     move.l  D0,(A6)         ;Digit
                move.l  #-1,-(A6)       ;TRUE
                movem.l (SP)+,D0-D1
                rts


                DC.L 0
accumulate:     move.l  (A6)+,-(SP)     ;digit retten
                move.l  (A6),-(SP)      ;adr retten
                move.l  D5,D0
                addi.l  #obase,D0
                move.l  0(A3,D0.l),(A6)
                bsr     mult            ;n1*BASE
                move.l  4(SP),D0
                add.l   D0,(A6)         ;+digit
                move.l  (SP)+,-(A6)     ;adr zurÅck
                addq.l  #4,SP           ;rdrop digit
                rts


                DC.L 0
count:          move.l  (A6),D1
                moveq   #0,D0
                move.b  0(A3,D1.l),D0
                addq.l  #1,D1
                move.l  D1,(A6)
                move.l  D0,-(A6)
                rts


                DC.L 0
convert:        bsr.s   count           ;( akku adr [digit true / false] )
                bsr     digit_quest
                tst.l   (A6)+
                beq.s   convert_end
                bsr.s   accumulate
                bra.s   convert
convert_end:    subq.l  #1,(A6)
                rts


                DC.L 0
n_number_quest: move.l  D5,D0           ;( adr -- n #longs )
                addi.l  #obase,D0
                move.l  0(A3,D0.l),-(SP) ;save BASE
                move.l  (A6),-(SP)      ;save address
                moveq   #0,D1
                movea.l (A6)+,A0        ;address to a0
                adda.l  A3,A0           ;calculate abs. address
                movea.l A0,A1           ;copy for error handling
                addq.l  #1,A0           ;countbyte
                clr.l   -(A6)           ;0 on the stack
check_char:     addq.l  #4,A6           ;DROP
                moveq   #0,D0
                move.b  (A0)+,D0        ;fetch first character
                move.l  D0,-(A6)        ;push it on the stack
                move.l  D0,-(A6)        ;DUP
                bsr     digit_quest     ;a valid numbercharacter?
                tst.l   (A6)+           ;( char1 digit )/ ( char )
                beq.s   nnum1           ;no numeral? possible: -,$,&,.
                move.l  (A6)+,(A6)      ;( digit ) is accumulator
                move.l  A0,-(A6)        ;( akku adr )
                bra.s   do_conversion
nnum1:          cmpi.l  #'-',(A6)       ;is it negative
                bne.s   not_neg
                bset    #0,D1           ;set a flag
                bra.s   check_char
not_neg:        cmpi.l  #'$',(A6)       ;is it HEX
                bne.s   not_hex
                move.l  D5,D0
                addi.l  #obase,D0
                move.l  #16,0(A3,D0.l)  ;set BASE to hex
                bra.s   check_char
not_hex:        cmpi.l  #'&',(A6)       ;is it decimal
                bne.s   not_dec
                move.l  D5,D0
                addi.l  #obase,D0
                move.l  #10,0(A3,D0.l)  ;set BASE to decimal
                bra.s   check_char
not_dec:        cmpi.l  #'.',(A6)       ;is it a dot?
                bne.s   number_err      ;no?, then it isn't a number
                clr.l   (A6)
                move.l  A0,-(A6)        ;( akku adr )
                bra.s   do_conv_after_dot
number_err:     move.l  (SP)+,(A6)      ;restore address
                clr.l   -(A6)           ;FALSE
                bra     nnum_out
do_conversion:  move.l  D5,D0
                addi.l  #odpl,D0
                move.l  #-1,0(A3,D0.l)  ;clear DPL
                move.l  D1,-(SP)        ;save d1
                move.l  (A6),D0
                sub.l   A3,D0           ;make pointer rel. again
                move.l  D0,(A6)
                bsr     convert         ;do conversion
                move.l  (SP)+,D1
                movea.l (A6),A0         ;address of first not-numeral
                adda.l  A3,A0           ;make it absolut
                moveq   #0,D0
                move.b  (A0)+,D0        ;fetch not-numeral
                move.l  A0,(A6)         ;abs. address remains on stack
                tst.b   D0              ;end of string?
                beq.s   nnum3           ;then leave succuessfully
                cmp.b   #32,D0          ;is it a blank
                beq.s   nnum3           ;then, end of string, too
                cmp.b   #'.',D0         ;is it a dot?
                beq.s   do_conv_after_dot ;then there's something to do
                bra.s   nnum_err        ;otherwise error
nnum3:          move.l  #1,(A6)         ;it is ONE long
                btst    #0,D1           ;did we find a '-'?
                beq.s   nnum2
                neg.l   4(A6)           ;then negate the number
nnum2:          addq.l  #4,SP           ;drop saved address
                bra.s   nnum_out        ;and finish
nnum_err:       clr.l   (A6)            ;FALSE
                move.l  (SP)+,4(A6)     ;put back address
                bra.s   nnum_out        ;and finish
do_conv_after_dot:
                move.l  A0,-(SP)        ;remember actual address
                move.l  D1,-(SP)        ;save d1
                move.l  (A6),D0
                sub.l   A3,D0           ;make pointer rel. again
                move.l  D0,(A6)
                bsr     convert
                move.l  (A6),D0
                add.l   A3,D0           ;make pointer rel. again
                move.l  D0,(A6)
                move.l  (SP)+,D1        ;restore d1
                movea.l (SP)+,A1        ;addr of dot
                moveq   #0,D0
                movea.l (A6),A0         ;fetch actual address
                move.b  (A0),D0         ;fetch first character
                beq.s   nnum5           ;end of string
                cmp.b   #32,D0          ;when blank, too
                bne.s   nnum_err        ;otherwise error
nnum5:          suba.l  A1,A0           ;calculate position of dot
                move.l  D5,D0
                addi.l  #odpl,D0
                move.l  A0,0(A3,D0.l)   ;set DPL
                move.l  #1,(A6)         ;there was ONe long
                btst    #0,D1           ;did we find a '-'??
                beq.s   nnum4           ;no
                neg.l   4(A6)           ;negate
nnum4:          addq.l  #4,SP           ;drop saved address
nnum_out:       move.l  D5,D0
                addi.l  #obase,D0
                move.l  (SP)+,0(A3,D0.l) ;restore base
                rts                     ;finish

                ENDPART

*****************************************************************
                >PART 'memory manipulation'
*                                                               *
*****************************************************************
                DC.L 0
fetch:          move.l  (A6),D0         ;( adr -- value )
                move.l  0(A3,D0.l),(A6)
                rts

                DC.L 0
cfetch:         move.l  (A6),D0
                clr.l   (A6)
                move.b  0(A3,D0.l),3(A6)
                rts

                DC.L 0
wfetch:         move.l  (A6),D0
                clr.l   (A6)
                move.w  0(A3,D0.l),2(A6)
                rts

                DC.L 0
store:          move.l  (A6)+,D0        ;( value adr -- )
                move.l  (A6)+,0(A3,D0.l)
                rts

                DC.L 0
cstore:         move.l  (A6)+,D0
                addq.l  #3,A6
                move.b  (A6)+,0(A3,D0.l)
                rts

                DC.L 0
wstore:         move.l  (A6)+,D0
                addq.l  #2,A6
                move.w  (A6)+,0(A3,D0.l)
                rts

                ENDPART

*****************************************************************
                >PART 'BASE settings'
*****************************************************************
                DC.L 0
hex:            move.l  D5,D0
                addi.l  #obase,D0
                move.l  #16,0(A3,D0.l)
                rts


                DC.L 0
decimal:        move.l  D5,D0
                addi.l  #obase,D0
                move.l  #10,0(A3,D0.l)
                rts

                ENDPART

*****************************************************************
                >PART 'creating a header'
*****************************************************************
                DC.L 0
header_colon:   bsr     align
                move.l  #headsize,-(A6)
                bsr     allot           ;for header fields
                bsr     name            ;get name
                bsr     nulst_quest     ;is there a name?
                tst.l   (A6)+
                bne     hd_col_err

                move.l  D5,D0
                addi.l  #owarning,D0
                tst.l   0(A3,D0.l)      ;WARNING ?
                beq.s   do_head_col
                move.l  (A6),-(A6)      ;dup name
                move.l  D5,D0
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),-(A6) ;CURRENT @
                bsr     vocsearch
                move.l  (A6)+,(A6)      ;NIP, CFA of no interest
                tst.l   (A6)+
                bmi.s   do_head_col     ;not found
                move.l  (A6),-(A6)
                bsr     count
                bsr     type
                bsr     b_str_quote
                DC.L (notuniquemess-datas)
                bsr     count
                bsr     type

do_head_col:    move.l  (A6),D0         ;fetch address of name
                clr.l   -(A6)
                move.b  0(A3,D0.l),3(A6) ;countbyte on stack
                addi.l  #1,(A6)         ;string incl. countbyte
                bsr     allot           ;allocate memory
                move.l  (A6)+,D0        ;address of name again
                subi.l  #headsize,D0    ;to start of header
                move.l  D5,D1
                addi.l  #olast,D1
                move.l  D0,0(A3,D1.l)   ;mark new LAST
                move.w  #1,0(A3,D0.l)   ;controlword = smudge
                move.l  D5,D2
                addi.l  #ocurrent,D2
                move.l  0(A3,D2.l),D2   ;pointer to pointer to last link
                move.l  0(A3,D2.l),D1   ;LFA of last word
                move.l  D1,6(A3,D0.l)   ;link in voc.
                addi.l  #6,D0
                move.l  D0,0(A3,D2.l)   ;notate new link

                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1   ;CP @
                addq.l  #4,0(A3,D0.l)   ;make room for view-field
                move.l  D5,D0
                addi.l  #oblk,D0
                move.l  0(A3,D0.l),0(A5,D1.l) ;save BLK@ in view-field
                move.l  D5,D2
                addi.l  #orootblk,D2
                move.l  0(A3,D2.l),D2
                add.l   D2,0(A5,D1.l)   ;add ROOTBLK in VIEW field
                addq.l  #4,D1
                move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0
                move.l  D1,2(A3,D0.l)   ;set CFA in header
                bsr     align           ;make DP even again
                rts
hd_col_err:     move.l  #-1,-(A6)
                bsr     b_abort_quote
                DC.L (noheadermess-datas)

                ENDPART

*****************************************************************
                >PART 'the ':' compiler'
*                                                               *
*****************************************************************
                DC.L 0
colon:          bsr     header_colon    ;create header
                bsr     right_brack     ;switch compiler on
                rts

                DC.L 0
m_colon:        bsr.s   colon
                move.l  D5,D0
                addi.l  #ois_macro,D0
                move.l  #-1,0(A3,D0.l)
                rts

                DC.L 0
reveal:         move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;pointer to last header
                andi.w  #$FFFE,0(A3,D0.l) ;delete SMUDGE-Bit
                rts


                DC.L 0
semi_colon:     move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D1
                move.w  #rts_code,0(A5,D1.l)
                addq.l  #2,D1
                move.l  D1,0(A3,D0.l)
                bsr.s   reveal
                bsr     left_brack

                tst.l   (was_local-datas)(A3)
                beq.s   tst_macro

forget_locals:  clr.l   (was_local-datas)(A3)
                move.l  D5,D0
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),D0
                move.l  (save_cur-datas)(A3),0(A3,D0.l)
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  (save_dp-datas)(A3),0(A3,D0.l)

tst_macro:      move.l  D5,D0
                addi.l  #ois_macro,D0
                tst.l   0(A3,D0.l)
                bne.s   semi_col_m
                rts
semi_col_m:     move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D1   ;fetch LAST
                move.l  2(A3,D1.l),D0   ;fetch CFA
                lea     0(A5,D0.l),A0   ;address of code (abs.)

                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D0   ;fetch CP
                add.l   A5,D0           ;calc. abs. address

                sub.l   A0,D0           ;length of code
                subq.l  #2,D0           ;-2 for the RTS
                lsr.l   #1,D0           ;length in words
                mulu    #$0100,D0       ;shift 8 bit
                bset    #3,D0           ;set macrobit
                or.w    D0,0(A3,D1.l)   ;mark in control word
                move.l  D5,D0
                addi.l  #ois_macro,D0
                clr.l   0(A3,D0.l)      ;clear IS_MACRO
                rts

                ENDPART

*****************************************************************
                >PART 'simple stack words'
*                                                               *
*****************************************************************
                DC.L 0
dup:            move.l  (A6),-(A6)
                rts


                DC.L 0
drop:           addq.l  #4,A6
                rts


                DC.L 0
swap:           movea.l (A6)+,A0        ;2
                movea.l (A6),A1         ;2
                move.l  A0,(A6)         ;2
                move.l  A1,-(A6)        ;2
                rts


                DC.L 0
rot:            move.l  (A6)+,D0
                movea.l (A6)+,A1
                movea.l (A6),A0
                move.l  A1,(A6)
                move.l  D0,-(A6)
                move.l  A0,-(A6)
                rts


                DC.L 0
quest_dup:      tst.l   (A6)
                beq.s   quest_dup_end
                move.l  (A6),-(A6)
quest_dup_end:  rts


                DC.L 0
over:           move.l  4(A6),-(A6)
                rts


                DC.L 0
_2drop:         addq.l  #8,(A6)
                rts


                DC.L 0
_2dup:          move.l  4(A6),-(A6)
                move.l  4(A6),-(A6)
                rts


                DC.L 0
_2over:         move.l  8(A6),-(A6)
                move.l  8(A6),-(A6)
                rts


                DC.L 0
_2swap:         move.l  (A6)+,D0
                move.l  (A6)+,D1
                move.l  4(A6),-(A6)
                move.l  4(A6),-(A6)
                move.l  D0,8(A6)
                move.l  D1,$0C(A6)
                rts

                ENDPART

*****************************************************************
                >PART 'moving memory byte by byte'
*                                                               *
*****************************************************************
                DC.L 0
cmove:          move.l  (A6)+,D0        ;( from to count -- )
                movea.l (A6)+,A0        ;to
                adda.l  A3,A0           ;convert to abs. address
                movea.l (A6)+,A1        ;from
                adda.l  A3,A1           ;dto.
                tst.l   D0
                beq.s   cmove_end
cmove_loop:     move.b  (A1)+,(A0)+
                subq.l  #1,D0
                bne.s   cmove_loop
cmove_end:      rts


                DC.L 0
cmove_up:       move.l  (A6)+,D0        ;( from to count -- )
                movea.l (A6)+,A0        ;to
                adda.l  A3,A0           ;convert to abs. address
                movea.l (A6)+,A1        ;from
                adda.l  A3,A1           ;dto.
                tst.l   D0
                beq.s   cmove_up_end
                adda.l  D0,A0
                adda.l  D0,A1
cmove_up_loop:  move.b  -(A1),-(A0)
                subq.l  #1,D0
                bpl.s   cmove_up_loop
cmove_up_end:   rts

                ENDPART

*****************************************************************
                >PART 'the CREATE ... DOES> structure'
*                                                               *
*****************************************************************
* CREATE <name>  produces the following structure:              *
*       in data segment:        header                          *
*       in code segment:        move.l  seg(DT),seg             *
*                               jsr (dodoes-sys-of)(seg)        *
*                               HERE ,                          *
*****************************************************************
dodoes:         movea.l (SP)+,A0
                move.l  (A0),-(A6)
                rts

                DC.L 0
create:         bsr     header_colon
                bsr     reveal
                move.l  #(dodoes-sys-of),-(A6) ;rel. address of dodoes
                bsr     jsr_komma
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
                bsr     code_komma
                rts
* remark:  jsrSB_komma would be possible for CREATE, too, but DOES> needs
*          jsr_komma, because the address of the DOES>-code does not have
*          to be within the first codesegment


b_code:         move.l  (SP)+,D0        ;fetch address of code
                sub.l   A5,D0           ;make it relative
                move.l  D0,-(A6)        ;push it for JSR,
                move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;address of last header
                move.l  2(A3,D0.l),D0   ;address of code
                move.l  D5,D1
                addi.l  #odp,D1
                move.l  0(A3,D1.l),-(SP) ;save CP
                move.l  D0,0(A3,D1.l)   ;set CP to codeaddress
                bsr     jsr_komma
                move.l  (SP)+,0(A3,D1.l) ;restore CP
                rts

does_code:      movea.l (SP)+,A0        ;save return vector
                movea.l (SP)+,A1        ;get pointer to pointer to data
                move.l  (A1),-(A6)      ;push pointer to data
                jmp     (A0)            ;jump thru saved vector


                DC.L 0
does:           move.l  #(b_code-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while definition
                move.l  #(does_code-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while execution
                rts


codedoes:       movea.l (SP)+,A1
                movea.l (SP)+,A0        ;pointer to pointer to data
                move.l  (A0),D0         ;pointer to data in A0
                jmp     (A1)

                DC.L 0
semcl_code:     move.l  #(b_code-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while definition
                move.l  #(codedoes-sys-of),-(A6)
                bsr     jsrSB_komma     ;this runs while execution
                rts

                ENDPART

*****************************************************************
                >PART 'creating deferred words'
*                                                               *
*****************************************************************

defercrash:     move.l  #-1,-(A6)
                bsr     b_abort_quote
                DC.L (defercrashmess-datas)
                rts

                DC.L 0
defer:          bsr     header_colon
                bsr     reveal
                move.l  #(dodefer-sys-of),-(A6)
                bsr     jsrSB_komma
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
                bsr     code_komma      ;create pointer to pointer to code
                move.l  #(defercrash-sys-of),-(A6)
                bra     komma

                ENDPART

*****************************************************************
                >PART 'variables and constants'
*                                                               *
*****************************************************************

                DC.L 0
variable:       bsr     create
                clr.l   -(A6)
                bra     komma


                DC.L 0
constant:       bsr     header_colon
                bsr     reveal
                move.l  #moveimm_sp,-(A6) ;instead of LIT,
                bsr     code_wkomma     ;real code
                bsr     code_komma      ;is generated
                move.l  #rts_code,-(A6)
                bra     code_wkomma


                DC.L 0
bl:             move.l  #$20,-(A6)
                rts


                ENDPART

*****************************************************************
                >PART 'values and locals'
*                                                               *
*****************************************************************
*
* VALUEs and LOCALs generate the same kind of code and access it
* in a very similar manner:
*
*       Call Fetcher
*       Address of Data
*       Call Storer
*
* The fetcher expects the address of data as an in-line address
* behind his call, whereas the storer expects it in front of it's
* call.
* Fetcher and storer are compiled using 'JSR,', because a defined
* length of code (8 bytes, worst case) is important for 'TO'.

* writing access using 'TO'
                DC.L 0
to:             bsr     tick            ;get address of code
                addi.l  #$0C,(A6)       ;> address of storer
                move.l  D5,D0
                addi.l  #ostate,D0
                tst.l   0(A3,D0.l)      ;test STATE
                bne.s   comp_val
                move.l  (A6)+,D0
                jmp     0(A5,D0.l)      ;execute ...
comp_val:       bra     jsr_komma       ;... or compile


val_fetch:      movea.l (SP)+,A0        ;get pointer to in-line
                move.l  (A0),D0
                move.l  0(A3,D0.l),-(A6)
                rts

val_store:      movea.l (SP)+,A0
                move.l  -8(A0),D0
                move.l  (A6)+,0(A3,D0.l)
                rts

                DC.L 0
value:          bsr     header_colon
                bsr     reveal
                move.l  #(val_fetch-sys-of),-(A6)
                bsr     jsr_komma
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),-(A6)
                bsr     code_komma
                move.l  #(val_store-sys-of),-(A6)
                bsr     jsrSB_komma
                bra     komma



free_loc:       addq.l  #4,SP
                rts

loc_init:       movea.l (SP),A0         ;get pointer to the fetcher
                move.l  (A6)+,(SP)      ;put value on the stack
                move.l  8(A0),D0        ;fetch datapointer
                move.l  SP,0(A3,D0.l)   ;set address of data on stack
                move.l  #(free_loc-sys-of),D0 ;address of free_loc for later use
                pea     0(A5,D0.l)
                jmp     $10(A0)         ;jump behind storer

loc_fetch:      movea.l (SP)+,A0        ;get inline pointer
                move.l  (A0),D0         ;get offset into data segment
                movea.l 0(A3,D0.l),A0   ;get the pointer to the data
                move.l  (A0),-(A6)      ;fetch the data
                rts

loc_store:      movea.l (SP)+,A0
                move.l  -8(A0),D0
                movea.l 0(A3,D0.l),A0
                move.l  (A6)+,(A0)
                rts

                DC.L 0
local:          tst.l   (was_local-datas)(A3) ;first local?
                bne.s   no_save         ;not?, nothing has to be saved
                move.l  D5,D0           ;otherwise save CURRENT@@ und HERE
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),D0   ;CURRENT @
                move.l  0(A3,D0.l),(save_cur-datas)(A3) ;@ SAVE_CUR !
                move.l  D5,D0
                addi.l  #odata,D0
                move.l  0(A3,D0.l),(save_dp-datas)(A3) ;HERE SAVE_DP !
                move.l  #-1,(was_local-datas)(A3) ;WAS_LOCAL ON
no_save:        move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),-(SP) ;LAST PUSH
                bsr     header_colon    ;HEADER:
                bsr     reveal          ;create a header
                move.l  D5,D0
                addi.l  #odp,D0
                subi.l  #4,0(A3,D0.l)   ;-4 CP +!    remove VIEW-field
                move.l  #(loc_init-sys-of),-(A6)
                bsr     jsrSB_komma     ;compile loc_init
                move.l  D5,D0
                addi.l  #odp,D0
                move.l  D5,D1
                addi.l  #olast,D1
                move.l  0(A3,D1.l),D1   ;LAST @
                move.l  0(A3,D0.l),2(A3,D1.l) ;CP @ SWAP 2+ !
*                                       ;set pointer in header to loc_init

                move.l  #(loc_fetch-sys-of),-(A6)
                bsr     jsr_komma       ;compile fetcher
                move.l  save_dp-datas(A3),-(A6)
                addq.l  #4,save_dp-datas(A3) ;allocate space in data segment
                bsr     code_komma      ;compile pointer to it
                move.l  #(loc_store-sys-of),-(A6)
                bsr     jsrSB_komma     ;compile storer

                move.l  D5,D0
                addi.l  #olast,D0
                move.l  (SP)+,0(A3,D0.l) ;restore LAST
                rts

                ENDPART

*****************************************************************
*                                                               *
*       structures controlling program flow                     *
*                                                               *
*****************************************************************

*****************************************************************
                >PART 'a.) LOOPs   and general stuff'
*****************************************************************
                DC.L 0
b_do:           movea.l (SP)+,A0        ;return pointer
                movem.l D6-D7,-(SP)
                addq.l  #4,A0           ;behind (DO is a pointer to behind LOOP
                move.l  A0,-(SP)
                move.l  (A6)+,D7        ;initial value
                move.l  (A6)+,D6
                sub.l   D6,D7           ;start-limit    (<0)
                jmp     (A0)            ;


                DC.L 0
b_quest_do:     movea.l (SP)+,A0        ;return pointer
                move.l  (A6),D0
                cmp.l   4(A6),D0
                beq.s   no_do
                movem.l D6-D7,-(SP)
                addq.l  #4,A0           ;behind (DO is a pointer to behind LOOP
                move.l  A0,-(SP)
                move.l  (A6)+,D7        ;initial value
                move.l  (A6)+,D6
                sub.l   D6,D7           ;start-limit    (<0)
                jmp     (A0)            ;
no_do:          addq.l  #8,A6           ;drop limits
                move.l  (A0),D0         ;fetch pointer to behind LOOP
                jmp     0(A5,D0.l)


                DC.L 0
b_loop:         addq.l  #1,D7           ;increase index
                bcs.s   no_more_loop    ;enough?
                addq.l  #4,SP           ;drop return address
                movea.l (SP),A0         ;fetch pointer to (DO
                jmp     (A0)            ;and jump back
no_more_loop:   movea.l (SP)+,A0        ;get return pointer
                addq.l  #4,SP           ;drop pointer to (DO
                movem.l (SP)+,D6-D7     ;restore registers
                jmp     (A0)            ;and LOOP has finished


                DC.L 0
b_plus_loop:    tst.l   (A6)
                bpl.s   incr
                neg.l   (A6)
                sub.l   (A6)+,D7
                bls.s   no_more_pl_lp
                addq.l  #4,SP
                movea.l (SP),A0
                jmp     (A0)
incr:           add.l   (A6)+,D7
                bcs.s   no_more_pl_lp
                addq.l  #4,SP
                movea.l (SP),A0
                jmp     (A0)
no_more_pl_lp:  movea.l (SP)+,A0
                addq.l  #4,SP
                movem.l (SP)+,D6-D7
                jmp     (A0)


                DC.L 0
i:              move.l  D6,-(A6)        ;limit
                add.l   D7,(A6)         ;+index (<0)
                rts


                DC.L 0
j:              movea.l (SP)+,A0
                move.l  8(SP),D0
                add.l   4(SP),D0
                move.l  D0,-(A6)
                jmp     (A0)


                DC.L 0
unloop:         movea.l (SP)+,A1
                movea.l (SP)+,A0
                movem.l (SP)+,D6-D7
*                lea     $0C(SP),SP
                jmp     (A1)


                DC.L 0
to_mark:        move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),-(A6) ;CP @
                clr.l   -(A6)           ;0
                jmp     (code_komma-sys-of)(A5) ; CODE,


                DC.L 0
to_resolve:     move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),D0   ;CP @
                movea.l (A6)+,A0
                adda.l  A5,A0
                move.l  D0,(A0)         ;SWAP !
                rts

                DC.L 0
less_mark:      move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),-(A6) ;CP @
                rts


                DC.L 0
less_resolve:   bsr     code_komma
                rts


                DC.L 0
do:             move.l  #(b_do-sys-of),-(A6)
                bsr     jsrSB_komma     ;compile (do
                bsr.s   to_mark         ;>mark
                move.l  D5,D0
                addi.l  #ois_macro,D0
                clr.l   0(A3,D0.l)
                rts


                DC.L 0
loop:           move.l  #(b_loop-sys-of),-(A6)
                bsr     jsrSB_komma
                bra.s   to_resolve


                DC.L 0
quest_do:       move.l  #(b_quest_do-sys-of),-(A6)
                bsr     jsrSB_komma     ;compile (?do
                bsr     to_mark         ;>mark
                move.l  D5,D0
                addi.l  #ois_macro,D0
                clr.l   0(A3,D0.l)
                rts


                DC.L 0
p_loop:         move.l  #(b_plus_loop-sys-of),-(A6)
                bsr     jsrSB_komma
                bra     to_resolve


                DC.L 0
leave:          addq.l  #4,SP           ;drop retrun address
                movea.l (SP)+,A0        ;get LOOP-pointer
                move.l  -4(A0),D0       ;fetch address, that points after LOOP
                movem.l (SP)+,D6-D7     ;restore registers
                jmp     0(A5,D0.l)      ;jump behind loop

                ENDPART

*****************************************************************
                >PART 'b.) decisions'
*****************************************************************
* IF-Code for high-level branches, see ?BRANCH
if_code:        movea.l (SP)+,A0
                tst.l   (A6)+
                beq.s   if_false
                addq.l  #4,A0           ;adr öberbrÅcken
                jmp     (A0)
if_false:       move.l  (A0),D0
                jmp     0(A5,D0.l)


                DC.L 0
quest_branch:   move.l  #(if_code-sys-of),-(A6)
                bsr     jsrSB_komma
                rts



                DC.L 0
if:             bsr.s   quest_branch    ;: IF ?branch >mark ;
                jmp     (to_mark-sys-of)(A5)


                DC.L 0
then:           bra     to_resolve


* ELSE-Code for high-level branches, s. BRANCH
else_code:      movea.l (SP)+,A0
                move.l  (A0),D0
                jmp     0(A5,D0.l)

                DC.L 0
branch:         move.l  #(else_code-sys-of),-(A6)
                jmp     (jsrSB_komma-sys-of)(A5)


* else_cd:      bra     #$12345678

                DC.L 0
else:           bsr.s   branch
                bsr     to_mark
                bsr     swap
                bra     to_resolve

*               move.l  d5,d0
*               addi.l  #odp,d0
*               move.l  (a3,d0.l),d1            ;CP @
*               move.l  #(else_cd-sys-of),a0
*               adda.l  a5,a0
*               move.l  (a0)+,(a5,d1.l)         ;copy code
*               addq.l  #4,d1
*               move.l  d1,(a3,d0.l)            ;CP !
*               subq.l  #2,d1
*               move.l  (a6)+,d2                ;position of IF
*               move.l  d1,-(a6)                ;something like >MARK
*               addq.l  #2,d1
*               sub.l   d2,d1                   ;distance
*               move.w  d1,(a5,d2.l)            ;fix offset
*               rts

                ENDPART

*****************************************************************
                >PART 'c.) conditional loops'
*****************************************************************
                DC.L 0
begin:          bsr     less_mark
                move.l  D5,D0
                addi.l  #ois_macro,D0
                clr.l   0(A3,D0.l)
                rts

                DC.L 0
until:          bsr.s   quest_branch    ;?BRANCH
                bra     code_komma      ;CODE,

                DC.L 0
again:          bsr.s   branch          ;BRANCH
                bra     code_komma      ;CODE,


                DC.L 0
repeat:         bsr.s   branch          ;BRANCH
                bsr     code_komma      ;CODE,
                bra     to_resolve      ;THEN

                DC.L 0
while:          bsr     quest_branch    ;?BRANCH
                bsr     to_mark         ;>MARK
                bra     swap            ;SWAP

                ENDPART

*****************************************************************
                >PART 'comparisons'
*                                                               *
*****************************************************************


                DC.L 0
null_gleich:    tst.l   (A6)
                seq     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts

                DC.L 0
null_greater:   tst.l   (A6)
                sgt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts

                DC.L 0
null_less:      tst.l   (A6)
                slt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts

                DC.L 0
null_grgl:      tst.l   (A6)
                sge     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts

                DC.L 0
null_legl:      tst.l   (A6)
                sle     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts

                DC.L 0
gleich:         move.l  (A6)+,D0
                cmp.l   (A6),D0
                seq     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts


                DC.L 0
ungleich:       move.l  (A6)+,D0
                cmp.l   (A6),D0
                sne     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts


                DC.L 0
less:           move.l  (A6)+,D0
                cmp.l   (A6),D0
                sgt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts


                DC.L 0
greater:        move.l  (A6)+,D0
                cmp.l   (A6),D0
                slt     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts

                DC.L 0
grgl:           move.l  (A6)+,D0
                cmp.l   (A6),D0
                sle     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts


                DC.L 0
legl:           move.l  (A6)+,D0
                cmp.l   (A6),D0
                sge     D0
                ext.w   D0
                ext.l   D0
                move.l  D0,(A6)
                rts




                DC.L 0
min:            move.l  (A6)+,D0
                cmp.l   (A6),D0
                bpl.s   min_end
                move.l  D0,(A6)
min_end:        rts

                DC.L 0
max:            move.l  (A6)+,D0
                cmp.l   (A6),D0
                bmi.s   max_end
                move.l  D0,(A6)
max_end:        rts




                ENDPART

*****************************************************************
                >PART 'forgeting words'
*                                                               *
*****************************************************************
forget_words:   movem.l D0-D2,-(SP)     ;( to_pfa voc -- )
                move.l  (A6)+,D1
                move.l  0(A5,D1.l),D1   ;ptr to ptr to last header
                move.l  0(A3,D1.l),D0   ;fetch address of last header
frgt_wds_loop:  move.l  -4(A3,D0.l),D2  ;fetch  PFA
                cmp.l   (A6),D2         ;> to_pfa
                bmi.s   frgt_wds_end    ;no? , then stop

                move.l  D5,D2
                addi.l  #odata,D2
                move.l  D0,0(A3,D2.l)   ;new DP
                subi.l  #6,0(A3,D2.l)   ;for control word and CFA

                move.l  0(A3,D0.l),D0   ;next LFA
                move.l  D0,0(A3,D1.l)   ;new entry in voc.

                bra.s   frgt_wds_loop
frgt_wds_end:   addq.l  #4,A6           ;drop to_pfa
                movem.l (SP)+,D0-D2
                rts


voc_remove:     move.l  D5,D0           ;( to_pfa -- )
                addi.l  #ovocpa,D0
                movea.l 0(A3,D0.l),A1   ;base of vocstack
                adda.l  A3,A1           ;calc. abs. address
                move.l  (A1)+,D0        ;VOCPA stack heigth
                addq.l  #4,A1
                subq.l  #4,D0           ;ONLY cannot be forgotten
vc_rm_loop:     move.l  (A1)+,D1        ;fetch first vocabulary
                move.l  4(A3,D1.l),D1   ;link back to code
                cmp.l   (A6),D1         ;< to_addr?
                ble.s   vc_rm1
                move.l  -8(A1),-4(A1)   ;replace voc by the last
vc_rm1:         subq.l  #4,D0           ;no more vocabulary?
                bne.s   vc_rm_loop      ;do the others

                move.l  D5,D0
                addi.l  #ocurrent,D0
                move.l  0(A3,D0.l),D1
                move.l  4(A3,D1.l),D1   ;link back to code
                cmp.l   (A6),D1         ;forget current?
                blt.s   vc_rm2
                move.l  -8(A1),0(A3,D0.l) ;new current

* now all vocs, which had to be forgotten, all removed from search order
* they have to be unlinked:
vc_rm2:         move.l  D5,D0
                addi.l  #ovoc_link,D0
                move.l  0(A3,D0.l),D1   ;VOC-LINK @
                movea.l D1,A0
                subq.l  #8,A0           ;pointer to pfa
vc_rm_unlink:   tst.l   D1              ;end of Voc-Link?
                beq.s   vc_rm_end
                cmpa.l  (A6),A0         ;> to_pfa?
                bge.s   vc_rm3          ;then next voc
                move.l  D1,0(A3,D0.l)   ;otherwise shorten linklist
                bra.s   vc_rm_end
vc_rm3:         move.l  0(A5,D1.l),D1   ; next Voc.
                movea.l D1,A0
                subq.l  #8,A0           ;pointer to pfa
                bra.s   vc_rm_unlink
vc_rm_end:      addq.l  #4,A6           ;drop to_pfa
                rts


                DC.L 0
b_forget:       move.l  (A6)+,-(SP)     ;( to_pfa -- ) save to_pfa
                move.l  D5,D0
                addi.l  #ovoc_link,D0
                move.l  0(A3,D0.l),D0   ;VOC-LINK @
b_frgt_loop:    tst.l   D0
                beq.s   b_forget_vocs   ;last voc?
                move.l  D0,D1
                subi.l  #4,D1
                move.l  (SP),-(A6)      ;DUP to_pfa
                move.l  D1,-(A6)
                bsr     forget_words
                move.l  0(A5,D0.l),D0
                bra.s   b_frgt_loop
b_forget_vocs:  move.l  (SP),-(A6)      ;DUP to_pfa
                bsr     voc_remove      ;remove vocabularies
                move.l  D5,D0
                addi.l  #odp,D0
                move.l  (SP)+,0(A3,D0.l) ;new CP
                subq.l  #4,0(A3,D0.l)   ;kill VIEW-field, too
                move.l  D5,D0
                addi.l  #olast,D0
                clr.l   0(A3,D0.l)      ; 0 LAST !
                rts


                DC.L 0
forget:         bsr     name
                bsr     find
                cmpi.l  #-1,(A6)+
                bne.s   frgt_weiter
                bra     notfound
frgt_weiter:    move.l  (A6),D0
                move.l  0(A3,D0.l),D0   ;fetch pfa
;                move.l  D5,D1
;                addi.l  #ofence,D1
;                cmp.l   0(A3,D1.l),D0
                cmp.l   (tfence-datas)(A3),D0
                bmi.s   cannot_frgt
                move.l  D0,(A6)
                bra.s   b_forget
cannot_frgt:    addi.l  #8,(A6)
                move.l  #-1,-(A6)       ;TRUE-Flag
                bsr     b_error_quote
                DC.L (fencemess-datas)
                rts

                ENDPART

*****************************************************************
                >PART 'words using existing runtimes'
*                                                               *
*****************************************************************
                DC.L 0
string_komma:   move.l  #'"',-(A6)
                bsr     word
                moveq   #0,D0
                move.l  (A6)+,D0
                moveq   #0,D1
                move.b  0(A3,D0.l),D1   ;fetch count
                addq.b  #1,D1           ;count byte
                move.l  D1,-(A6)
                bsr     allot
                rts


                DC.L 0
string_emit:    move.l  #(b_string_emit-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bsr.s   string_komma
                rts


                DC.L 0
dot_brack:      move.l  #')',-(A6)
                bsr     word
                bsr     count
                bsr     type
                rts


                DC.L 0
comment_brack:  move.l  #')',-(A6)
                bsr     word
                addq.l  #4,A6
                rts


                DC.L 0
error_quote:    move.l  #(b_error_quote-sys-of),-(A6) ;cfa
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bsr     string_komma
                rts


                DC.L 0
abort:          move.l  D5,D0
                addi.l  #oerror,D0
                move.l  0(A3,D0.l),D0
                jsr     0(A5,D0.l)
                rts


                DC.L 0
abort_quote:    move.l  #(b_abort_quote-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bsr     string_komma
                rts


                DC.L 0
quote:          move.l  D5,D0
                addi.l  #ostate,D0
                tst.l   0(A3,D0.l)      ;STATE @ IF
                beq.s   quote1
                move.l  #(b_str_quote-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     align
                bsr     here
                bsr     code_komma
                bra     string_komma
quote1:         move.l  #'"',-(A6)      ;ELSE ASCII " WORD
                bsr     word
                bsr     pad
                move.l  4(A6),D0        ;COUNT 1+
                clr.l   -(A6)
                move.b  0(A3,D0.l),3(A6) ;PAD    SWAP CMOVE
                addq.l  #1,(A6)
                bsr     cmove
                bra     pad             ;PAD

******************************************************************
                DC.L 0
postpone:       bsr     name
                bsr     find
                move.l  (A6)+,D0
                cmp.l   #-1,D0
                beq.s   post_err
                btst    #1,D0           ;immediate?
                bne.s   compile         ;then compile it
                bsr     literal
                move.l  #(__com_komma-datas-4),-(A6) ;pfa of COM,
compile:        bra     com_komma
post_err:       bra     notfound


                DC.L 0
immediate:      move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;header of last word
                ori.w   #2,0(A3,D0.l)   ;set immediate bit
                rts

                DC.L 0
restrict:       move.l  D5,D0
                addi.l  #olast,D0
                move.l  0(A3,D0.l),D0   ;header of last word
                ori.w   #4,0(A3,D0.l)   ;set restrict bit
                rts

                ENDPART

*****************************************************************
                >PART 'creating vocabularies'
*                                                               *
*****************************************************************

                DC.L 0
vocabulary:     bsr     header_colon
                move.l  #(dovoca-sys-of),-(A6)
                bsr     jsrSB_komma
                bsr     here
                bsr     code_komma
                move.l  #(__first-datas),-(A6)
                bsr     komma
                move.l  D5,D0
                addi.l  #odp,D0
                move.l  0(A3,D0.l),-(A6) ;CP @
                move.l  (A6),-(A6)      ;DUP
                subq.l  #4,(A6)
                bsr     komma

                move.l  D5,D0
                addi.l  #ovoc_link,D0
                move.l  0(A3,D0.l),-(A6)
                move.l  D0,-(SP)
                bsr     code_komma
                move.l  (SP)+,D0
                move.l  (A6)+,0(A3,D0.l)
                bra     reveal

                ENDPART

*****************************************************************
                >PART 'FILL, ERASE'

                DC.L 0
fill:           move.l  (A6)+,D0
                move.l  (A6)+,D1
                movea.l (A6)+,A0
                adda.l  A3,A0
                subq.l  #1,D1
fill_loop:      move.b  D0,(A0)+
                dbra    D1,fill_loop
                rts


                DC.L 0
erase:          move.l  (A6)+,D0
                movea.l (A6)+,A0
                adda.l  A3,A0
                subq.l  #1,D0
eraseloop:      clr.b   (A0)+
                dbra    D0,eraseloop
                rts

                ENDPART

*****************************************************************
                >PART '1+, CELL+, etc.'

                DC.L 0
one_plus:       addq.l  #1,(A6)
                rts


                DC.L 0
one_minus:      subq.l  #1,(A6)
                rts

                DC.L 0
two_plus:       addq.l  #2,(A6)
                rts

                DC.L 0
two_minus:      subq.l  #2,(A6)
                rts

                DC.L 0
two_mult:       move.l  (A6),D0
                add.l   D0,D0
                move.l  D0,(A6)
                rts

                DC.L 0
two_div:        move.l  (A6),D0
                asr.l   #1,D0
                move.l  D0,(A6)
                rts


                DC.L 0
cell_plus:      addq.l  #4,(A6)
                rts


                DC.L 0          ;( n -- n*4 )
cells:          move.l  (A6),D0
                asl.l   #2,D0
                move.l  D0,(A6)
                rts


                DC.L 0          ;( n -- n+1 )
char_plus:      addq.l  #1,(A6)
                rts


                DC.L 0          ; ( n -- n ) * this is ANSI
chars:          rts


                ENDPART

*****************************************************************
                >PART 'other mass storage words'
*                                                               *
*****************************************************************

                DC.L 0
update:         move.l  D5,D0
                addi.l  #oprev,D0
                move.l  0(A3,D0.l),D0
                move.w  #1,$0C(A3,D0.l)
                rts


                DC.L 0          ;( blk -- )
b_load:         move.l  D5,D0
                addi.l  #oblk,D0
                move.l  0(A3,D0.l),-(SP) ;save BLK on stack
                move.l  (A6)+,0(A3,D0.l) ;set BLK
                move.l  D5,D0
                addi.l  #otoin,D0
                move.l  0(A3,D0.l),-(SP) ;save >IN on stack
                clr.l   0(A3,D0.l)      ;clear >IN
                bsr     interpret
                move.l  D5,D0
                addi.l  #otoin,D0
                move.l  (SP)+,0(A3,D0.l)
                move.l  D5,D0
                addi.l  #oblk,D0
                move.l  (SP)+,0(A3,D0.l)
                rts


                DC.L 0          ;( blk -- )
load:           jsr     (dodefer-sys-of)(A5)
                DC.L (loadptr-datas)
*                rts

                ENDPART

HERE:



*****************************************************************
*                                                               *
*                                                               *
*                                                               *
*               End of Code, Start of Data                      *
*                                                               *
*                                                               *
*                                                               *
*****************************************************************

                DATA
                EVEN
datas:
*****************************************************************
                >PART 'System tables and variables'

tablesize       EQU 10
table:          DS.L tablesize  ;table of segment pointers
*               SB
*               SB + $10000
*               SB + $20000
*               .
*               .
*               .
*               SB + (tablesize * $10000)

hello:          DC.B '*** F68K  Ver. 1.0, Copyright by J. Plewe ***',13,10
                EVEN

*************************************************************************
*       system variables                                                *
*************************************************************************
mtable:
tcold:          DC.L (quit-sys-of) ;vector for cold
tsystop:        DS.L 1          ;highest possible address
tsysbot:        DS.L 1
tdatatop:       DS.L 1
tdatabot:       DS.L 1
tforthparas:    DC.L 0
bootsys:        DC.L 0          ;return to loader
saveret:        DC.L 0          ;SP of loader
bootuser:       DC.L (usertable-datas) ;
troot:          DS.L 1          ;pointer to table of devices
tkeys:          DS.L 1
tkey_quests:    DS.L 1
temits:         DS.L 1
tr_ws:          DS.L 1
treadsyses:     DS.L 1
twritesyses:    DS.L 1
tfence:         DC.L (HERE-sys-of)
tfront_opt:     DC.L (noop-sys-of) ;for an optimizer
tend_opt:       DC.L (noop-sys-of) ;dto.
                EVEN

                ENDPART

*****************************************************************
                >PART 'USER variables'
*****************************************************************
*       USER variables                                          *
*****************************************************************
                DS.L (16+24+10) ;room to save registers in multitasking
usertable:
tnextuser:      DC.L (usertable-datas) ;points to usertable of next task
trnull:         DC.L 0          ;r0 -- returnstackbase
tsnull:         DC.L 0          ;s0 -- datastackbase
tfnull:         DC.L 0          ;f0 -- floatstackbase
tstate:         DC.L 0          ;compiler on/off
tnumber_qu:     DC.L (n_number_quest-sys-of) ;numberconversion
tbase:          DC.L 10         ;base
tdpl:           DC.L -1         ;decimalpoint?
thld:           DC.L 0          ;temporary for numberconversion
tdp:            DC.L (HERE-sys-of) ;dictionary pointer (code)
tdata:          DC.L (dataHERE-datas) ;dictionary pointer (data)
ttotib:         DC.L 0          ;>tib, maybe as s0
t_tib:          DC.L 0          ;number of characters in tib
ttoin:          DC.L 0          ;>in
tspan:          DC.L 0          ;number of characters caught by expect
tcurrent:       DC.L (last_forth-datas) ;current (pfa)
tvoc_link:      DC.L (forth_link-sys-of) ;voc-link
tvocpa:         DC.L (VOCPA-datas) ;points to vocabularystack
tlast:          DC.L (lasthead-datas) ;address of last header
;tfence:         DC.L (HERE-sys-of+4) ;pfa of first unprotected word
terror:         DC.L (quit-sys-of) ;vector for errorhandling
tkey:           DC.L (loaderkey-sys-of)
temit:          DC.L (loaderemit-sys-of)
tkey_quest:     DC.L (loaderkey_quest-sys-of)
tr_w:           DC.L (loaderr_w-sys-of)
treadsys:       DC.L (loaderreadsys-sys-of)
twritesys:      DC.L (loaderwritesys-sys-of)
tlkey:          DC.L 0
tlemit:         DC.L 0
tlkey_quest:    DC.L 0
tlr_w:          DC.L 0
tlreadsys:      DC.L 0
tlwritesys:     DC.L 0
texpect:        DC.L (osexpect-sys-of)
ttype:          DC.L (ostype-sys-of)
tmacro:         DC.L 0          ;should macros be used?
tis_macro:      DC.L 0          ;shall the new word be a macro?
twarning:       DC.L 0          ;give out warnings?
tout:           DC.L 0          ;counts characters emitted
tfwidth:        DC.L 8          ;bytes per float
tliteral:       DC.L (lit-sys-of) ;routine for numbercompilation
tfliteral:      DC.L (flit-sys-of) ;routine for floatcompilation
tblk:           DC.L 0          ;number of actual block
trootblk:       DC.L 0          ;log. block 0
tprev:          DC.L (buf-datas) ;start of buffers list
tuserbufs:      DC.L (VOCPA-datas-8) ;pointer to list of buffers
tcaps:          DC.L -1         ;use uppercase only?
tudp:           DC.L oudp+4

                DS.B ($0800-oudp+4) ;room for the rest
                EVEN

                ENDPART

*****************************************************************
                >PART 'vocabulary stack'

*************************************************************************
*       vocabulary stack                                                *
*************************************************************************
                DC.L 0          ;last    user's buffer
                DC.L 96         ;length is 96 bytes
VOCPA:          DC.L 12         ;height of voc-stacks
                DC.L (last_only-datas) ;context (pfa)
                DC.L (last_forth-datas) ;context (pfa)
                DC.L (last_forth-datas) ;transient (pfa)
                DS.L 21         ;room for another 20
                EVEN

                ENDPART

*****************************************************************
                >PART 'header'

*************************************************************************
*       header                                                          *
*************************************************************************

dummy:          DC.L 0

                DC.W 0
                DC.L (only-sys-of)
__only:         DC.L (dummy-datas)
                DC.B 4,'ONLY'
                EVEN
last_only:      DC.L (__forth-datas)
                DC.L (only-sys-of+4) ;link back to code


                DC.W 0
                DC.L (forth-sys-of)
__forth:        DC.L (__only-datas)
                DC.B 5,'FORTH'
                EVEN
last_forth:     DC.L (lastword-datas)
                DC.L (forth-sys-of+4) ;link back to code

                DC.W 0
                DC.L (first-sys-of)
__first:        DC.L (dummy-datas)
                DC.B 0
                EVEN

                DC.W $0408      ;macro
                DC.L (pause-sys-of)
__pause:        DC.L (__first-datas)
                DC.B 5,'PAUSE'
                EVEN
pauseptr:       DC.L (first-sys-of)

                DC.W 0
                DC.L (osexpect-sys-of)
__osexpect:     DC.L (__pause-datas)
                DC.B 8,'OSEXPECT'
                EVEN


                DC.W 0
                DC.L (ostype-sys-of)
__ostype:       DC.L (__osexpect-datas)
                DC.B 6,'OSTYPE'
                EVEN

                DC.W 0
                DC.L (bye-sys-of)
__bye:          DC.L (__ostype-datas)
                DC.B 3,'BYE'
                EVEN


                DC.W 0
                DC.L (b_cold-sys-of)
__b_cold:       DC.L (__bye-datas)
                DC.B 6,'(COLD)'
                EVEN


                DC.W $0208
                DC.L (systop-sys-of)
__systop:       DC.L (__b_cold-datas)
                DC.B 6,'SYSTOP'
                EVEN


                DC.W $0208
                DC.L (sysbot-sys-of)
__sysbot:       DC.L (__systop-datas)
                DC.B 6,'SYSBOT'
                EVEN


                DC.W $0208
                DC.L (datatop-sys-of)
__datatop:      DC.L (__sysbot-datas)
                DC.B 7,'DATATOP'
                EVEN


                DC.W $0208
                DC.L (databot-sys-of)
__databot:      DC.L (__datatop-datas)
                DC.B 7,'DATABOT'
                EVEN


                DC.W 0
                DC.L (forthparas-sys-of)
__forthparas:   DC.L (__databot-datas)
                DC.B 10,'FORTHPARAS'
                EVEN


                DC.W 0
                DC.L (roottable-sys-of)
__roottable:    DC.L (__forthparas-datas)
                DC.B 9,'ROOTTABLE'
                EVEN


                DC.W 0
                DC.L (keys-sys-of)
__keys:         DC.L (__roottable-datas)
                DC.B 4,'KEYS'
                EVEN


                DC.W 0
                DC.L (emits-sys-of)
__emits:        DC.L (__keys-datas)
                DC.B 5,'EMITS'
                EVEN


                DC.W 0
                DC.L (key_quests-sys-of)
__key_quests:   DC.L (__emits-datas)
                DC.B 5,'KEY?S'
                EVEN

                DC.W 0
                DC.L (r_ws-sys-of)
__r_ws:         DC.L (__key_quests-datas)
                DC.B 4,'R/WS'
                EVEN

                DC.W 0
                DC.L (readsyses-sys-of)
__readsyses:    DC.L (__r_ws-datas)
                DC.B 9,'READSYSES'
                EVEN

                DC.W 0
                DC.L (writesyses-sys-of)
__writesyses:   DC.L (__readsyses-datas)
                DC.B 10,'WRITESYSES'
                EVEN


                DC.W $0308
                DC.L (fence-sys-of)
__fence:        DC.L (__writesyses-datas)
                DC.B 5,'FENCE'
                EVEN


                DC.W 0
                DC.L (b_front_opt-sys-of)
__b_front_opt:  DC.L (__fence-datas)
                DC.B 11,'(FRONT_OPT)'
                EVEN


                DC.W 0
                DC.L (b_end_opt-sys-of)
__b_end_opt:    DC.L (__b_front_opt-datas)
                DC.B 9,'(END_OPT)'
                EVEN


                DC.W $08
                DC.L (noop-sys-of)
__noop:         DC.L (__b_end_opt-datas)
                DC.B 4,'NOOP'
                EVEN


                DC.W 0
                DC.L (ver-sys-of)
__ver:          DC.L (__noop-datas)
                DC.B 3,'VER'
                EVEN


                DC.W $0408
                DC.L (nextuser-sys-of)
__nextuser:     DC.L (__ver-datas)
                DC.B 8,'NEXTUSER'
                EVEN


                DC.W $0408
                DC.L (r_null-sys-of)
__r_null:       DC.L (__nextuser-datas)
                DC.B 2,'R0'
                EVEN


                DC.W $0408
                DC.L (s_null-sys-of)
__s_null:       DC.L (__r_null-datas)
                DC.B 2,'S0'
                EVEN


                DC.W $0408
                DC.L (f_null-sys-of)
__f_null:       DC.L (__s_null-datas)
                DC.B 2,'F0'
                EVEN


                DC.W $0408
                DC.L (state-sys-of)
__state:        DC.L (__f_null-datas)
                DC.B 5,'STATE'
                EVEN


                DC.W $0408
                DC.L (b_number_quest-sys-of)
__b_number_quest:DC.L (__state-datas)
                DC.B 9,'(NUMBER?)'
                EVEN


                DC.W $0408
                DC.L (base-sys-of)
__base:         DC.L (__b_number_quest-datas)
                DC.B 4,'BASE'
                EVEN


                DC.W $0408
                DC.L (dpl-sys-of)
__dpl:          DC.L (__base-datas)
                DC.B 3,'DPL'
                EVEN


                DC.W $0408
                DC.L (hld-sys-of)
__hld:          DC.L (__dpl-datas)
                DC.B 3,'HLD'
                EVEN


                DC.W $0408
                DC.L (cp-sys-of)
__cp:           DC.L (__hld-datas)
                DC.B 2,'CP'
                EVEN


                DC.W $0408
                DC.L (dp-sys-of)
__dp:           DC.L (__cp-datas)
                DC.B 2,'DP'
                EVEN


                DC.W $0408
                DC.L (totib-sys-of)
__totib:        DC.L (__dp-datas)
                DC.B 4,'>TIB'
                EVEN


                DC.W $0408
                DC.L (_tib-sys-of)
___tib:         DC.L (__totib-datas)
                DC.B 4,'#TIB'
                EVEN


                DC.W $0408
                DC.L (toin-sys-of)
__toin:         DC.L (___tib-datas)
                DC.B 3,'>IN'
                EVEN


                DC.W $0408
                DC.L (span-sys-of)
__span:         DC.L (__toin-datas)
                DC.B 4,'SPAN'
                EVEN


                DC.W $0408
                DC.L (current-sys-of)
__current:      DC.L (__span-datas)
                DC.B 7,'CURRENT'
                EVEN


                DC.W $0408
                DC.L (voc_link-sys-of)
__voc_link:     DC.L (__current-datas)
                DC.B 8,'VOC-LINK'
                EVEN


                DC.W $0408
                DC.L (vocpa-sys-of)
__vocpa:        DC.L (__voc_link-datas)
                DC.B 5,'VOCPA'
                EVEN


                DC.W $0408
                DC.L (last-sys-of)
__last:         DC.L (__vocpa-datas)
                DC.B 4,'LAST'
                EVEN




                DC.W $0408
                DC.L (b_error-sys-of)
__b_error:      DC.L (__last-datas)
                DC.B 7,'(ERROR)'
                EVEN


                DC.W $0408
                DC.L (b_key-sys-of)
__b_key:        DC.L (__b_error-datas)
                DC.B 5,'(KEY)'
                EVEN


                DC.W $0408
                DC.L (b_emit-sys-of)
__b_emit:       DC.L (__b_key-datas)
                DC.B 6,'(EMIT)'
                EVEN


                DC.W $0408
                DC.L (b_key_quest-sys-of)
__b_key_quest:  DC.L (__b_emit-datas)
                DC.B 6,'(KEY?)'
                EVEN


                DC.W $0408
                DC.L (b_r_w-sys-of)
__b_r_w:        DC.L (__b_key_quest-datas)
                DC.B 5,'(R/W)'
                EVEN

                DC.W $0408
                DC.L (b_readsys-sys-of)
__b_readsys:    DC.L (__b_r_w-datas)
                DC.B 9,'(READSYS)'
                EVEN

                DC.W $0408
                DC.L (b_writesys-sys-of)
__b_writesys:   DC.L (__b_readsys-datas)
                DC.B 10,'(WRITESYS)'
                EVEN


                DC.W $0408
                DC.L (t_key-sys-of)
__t_key:        DC.L (__b_writesys-datas)
                DC.B 4,'^KEY'
                EVEN


                DC.W $0408
                DC.L (t_emit-sys-of)
__t_emit:       DC.L (__t_key-datas)
                DC.B 5,'^EMIT'
                EVEN


                DC.W $0408
                DC.L (t_key_quest-sys-of)
__t_key_quest:  DC.L (__t_emit-datas)
                DC.B 5,'^KEY?'
                EVEN


                DC.W $0408
                DC.L (t_r_w-sys-of)
__t_r_w:        DC.L (__t_key_quest-datas)
                DC.B 4,'^R/W'
                EVEN

                DC.W $0408
                DC.L (t_readsys-sys-of)
__t_readsys:    DC.L (__t_r_w-datas)
                DC.B 8,'^READSYS'
                EVEN

                DC.W $0408
                DC.L (t_writesys-sys-of)
__t_writesys:   DC.L (__t_readsys-datas)
                DC.B 9,'^WRITESYS'
                EVEN


                DC.W $0408
                DC.L (b_expect-sys-of)
__b_expect:     DC.L (__t_writesys-datas)
                DC.B 8,'(EXPECT)'
                EVEN


                DC.W $0408
                DC.L (b_type-sys-of)
__b_type:       DC.L (__b_expect-datas)
                DC.B 6,'(TYPE)'
                EVEN


                DC.W $0408
                DC.L (b_literal-sys-of)
__b_literal:    DC.L (__b_type-datas)
                DC.B 9,'(LITERAL)'
                EVEN


                DC.W $0408
                DC.L (b_fliteral-sys-of)
__b_fliteral:   DC.L (__b_literal-datas)
                DC.B 10,'(FLITERAL)'
                EVEN


                DC.W $0408
                DC.L (macro-sys-of)
__macro:        DC.L (__b_fliteral-datas)
                DC.B 5,'MACRO'
                EVEN


                DC.W $0408
                DC.L (is_macro-sys-of)
__is_macro:     DC.L (__macro-datas)
                DC.B 8,'IS_MACRO'
                EVEN


                DC.W $0408
                DC.L (warning-sys-of)
__warning:      DC.L (__is_macro-datas)
                DC.B 7,'WARNING'
                EVEN


                DC.W $0408
                DC.L (fwidth-sys-of)
__fwidth:       DC.L (__warning-datas)
                DC.B 6,'FWIDTH'
                EVEN


                DC.W $0408
                DC.L (blk-sys-of)
__blk:          DC.L (__fwidth-datas)
                DC.B 3,'BLK'
                EVEN


                DC.W $0408
                DC.L (rootblk-sys-of)
__rootblk:      DC.L (__blk-datas)
                DC.B 7,'ROOTBLK'
                EVEN


                DC.W $0408
                DC.L (prev-sys-of)
__prev:         DC.L (__rootblk-datas)
                DC.B 4,'PREV'
                EVEN


                DC.W $0408
                DC.L (userbufs-sys-of)
__userbufs:     DC.L (__prev-datas)
                DC.B 8,'USERBUFS'
                EVEN

                DC.W $0408
                DC.L (caps-sys-of)
__caps:         DC.L (__userbufs-datas)
                DC.B 4,'CAPS'
                EVEN

                DC.W $0408
                DC.L (udp-sys-of)
__udp:          DC.L (__caps-datas)
                DC.B 3,'UDP'
                EVEN


                DC.W $0408
                DC.L (out-sys-of)
__out:          DC.L (__udp-datas)
                DC.B 3,'OUT'
                EVEN


                DC.W 0
                DC.L (pad-sys-of)
__pad:          DC.L (__out-datas)
                DC.B 3,'PAD'
                EVEN


                DC.W 0
                DC.L (here-sys-of)
__here:         DC.L (__pad-datas)
                DC.B 4,'HERE'
                EVEN


                DC.W 0
                DC.L (number_quest-sys-of)
__number_quest: DC.L (__here-datas)
                DC.B 7,'NUMBER?'
                EVEN


                DC.W 0
                DC.L (loaderkey-sys-of)
__loaderkey:    DC.L (__number_quest-datas)
                DC.B 9,'LOADERKEY'
                EVEN


                DC.W 0
                DC.L (loaderemit-sys-of)
__loaderemit:   DC.L (__loaderkey-datas)
                DC.B 10,'LOADEREMIT'
                EVEN


                DC.W 0
                DC.L (loaderkey_quest-sys-of)
__loaderkey_quest:DC.L (__loaderemit-datas)
                DC.B 10,'LOADERKEY?'
                EVEN


                DC.W 0
                DC.L (loaderr_w-sys-of)
__loaderr_w:    DC.L (__loaderkey_quest-datas)
                DC.B 9,'LOADERR/W'
                EVEN


                DC.W 0
                DC.L (loaderwritesys-sys-of)
__loaderwritesys:DC.L (__loaderr_w-datas)
                DC.B 14,'LOADERWRITESYS'
                EVEN


                DC.W 0
                DC.L (loaderreadsys-sys-of)
__loaderreadsys:DC.L (__loaderwritesys-datas)
                DC.B 13,'LOADERREADSYS'
                EVEN


                DC.W 0
                DC.L (key-sys-of)
__key:          DC.L (__loaderreadsys-datas)
                DC.B 3,'KEY'
                EVEN


                DC.W 0
                DC.L (emit-sys-of)
__emit:         DC.L (__key-datas)
                DC.B 4,'EMIT'
                EVEN


                DC.W 0
                DC.L (key_quest-sys-of)
__key_quest:    DC.L (__emit-datas)
                DC.B 4,'KEY?'
                EVEN


                DC.W 0
                DC.L (r_w-sys-of)
__r_w:          DC.L (__key_quest-datas)
                DC.B 3,'R/W'
                EVEN


                DC.W 0
                DC.L (writesys-sys-of)
__writesys:     DC.L (__r_w-datas)
                DC.B 8,'WRITESYS'
                EVEN

                DC.W 0
                DC.L (readsys-sys-of)
__readsys:      DC.L (__writesys-datas)
                DC.B 7,'READSYS'
                EVEN


                DC.W 0
                DC.L (expect-sys-of)
__expect:       DC.L (__readsys-datas)
                DC.B 6,'EXPECT'
                EVEN


                DC.W 0
                DC.L (type-sys-of)
__type:         DC.L (__expect-datas)
                DC.B 4,'TYPE'
                EVEN

                DC.W 0
                DC.L (komma-sys-of)
__komma:        DC.L (__type-datas)
                DC.B 1,','
                EVEN


                DC.W 0
                DC.L (jsr_komma-sys-of)
__jsr_komma:    DC.L (__komma-datas)
                DC.B 4,'JSR,'
                EVEN


                DC.W 0
                DC.L (com_komma-sys-of)
__com_komma:    DC.L (__jsr_komma-datas)
                DC.B 4,'COM,'
                EVEN


                DC.W 0
                DC.L (code_komma-sys-of)
__code_komma:   DC.L (__com_komma-datas)
                DC.B 5,'CODE,'
                EVEN


                DC.W 0
                DC.L (code_wkomma-sys-of)
__code_wkomma:  DC.L (__code_komma-datas)
                DC.B 6,'CODEW,'
                EVEN


                DC.W 0
                DC.L (jsrSB_komma-sys-of)
__jsrSB_komma:  DC.L (__code_wkomma-datas)
                DC.B 6,'JSRSB,'
                EVEN


                DC.W 0
                DC.L (wkomma-sys-of)
__wkomma:       DC.L (__jsrSB_komma-datas)
                DC.B 2,'W,'
                EVEN


                DC.W 0
                DC.L (ckomma-sys-of)
__ckomma:       DC.L (__wkomma-datas)
                DC.B 2,'C,'
                EVEN


                DC.W 0
                DC.L (fkomma-sys-of)
__fkomma:       DC.L (__ckomma-datas)
                DC.B 2,'F,'
                EVEN


                DC.W 0
                DC.L (plus_store-sys-of)
__plus_store:   DC.L (__fkomma-datas)
                DC.B 2,'+!'
                EVEN


                DC.W $0208
                DC.L (plus-sys-of)
__plus:         DC.L (__plus_store-datas)
                DC.B 1,'+'
                EVEN


                DC.W $0208
                DC.L (minus-sys-of)
__minus:        DC.L (__plus-datas)
                DC.B 1,'-'
                EVEN


                DC.W 0
                DC.L (mult-sys-of)
__mult:         DC.L (__minus-datas)
                DC.B 1,'*'
                EVEN


                DC.W 0
                DC.L (udivmod-sys-of)
__udivmod:      DC.L (__mult-datas)
                DC.B 5,'U/MOD'
                EVEN


                DC.W 0
                DC.L (divmod-sys-of)
__divmod:       DC.L (__udivmod-datas)
                DC.B 4,'/MOD'
                EVEN


                DC.W 0
                DC.L (div-sys-of)
__div:          DC.L (__divmod-datas)
                DC.B 1,'/'
                EVEN


                DC.W 0
                DC.L (muldivmod-sys-of)

__muldivmod:    DC.L (__div-datas)
                DC.B 5,'*/MOD'
                EVEN


                DC.W $0308
                DC.L (muldiv-sys-of)
__muldiv:       DC.L (__muldivmod-datas)
                DC.B 2,'*/'
                EVEN


                DC.W $0208
                DC.L (and-sys-of)
__and:          DC.L (__muldiv-datas)
                DC.B 3,'AND'
                EVEN


                DC.W $0208
                DC.L (or-sys-of)
__or:           DC.L (__and-datas)
                DC.B 2,'OR'
                EVEN


                DC.W $0208
                DC.L (xor-sys-of)
__xor:          DC.L (__or-datas)
                DC.B 3,'XOR'
                EVEN


                DC.W $0108
                DC.L (not-sys-of)
__not:          DC.L (__xor-datas)
                DC.B 3,'NOT'
                EVEN


                DC.W $0108
                DC.L (negate-sys-of)
__negate:       DC.L (__not-datas)
                DC.B 6,'NEGATE'
                EVEN


                DC.W $0408
                DC.L (abs-sys-of)
__abs:          DC.L (__negate-datas)
                DC.B 3,'ABS'
                EVEN


                DC.W 0
                DC.L (allot-sys-of)
__allot:        DC.L (__abs-datas)
                DC.B 5,'ALLOT'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (exit-sys-of)
__exit:         DC.L (__allot-datas)
                DC.B 4,'EXIT'
                EVEN


                DC.W 0
                DC.L (execute-sys-of)
__execute:      DC.L (__exit-datas)
                DC.B 7,'EXECUTE'
                EVEN


                DC.W 0
                DC.L (sp_fetch-sys-of)
__sp_fetch:     DC.L (__execute-datas)
                DC.B 3,'SP@'
                EVEN


                DC.W 0
                DC.L (sp_store-sys-of)
__sp_store:     DC.L (__sp_fetch-datas)
                DC.B 3,'SP!'
                EVEN


                DC.W 4          ;restrict
                DC.L (to_r-sys-of)
__to_r:         DC.L (__sp_store-datas)
                DC.B 2,'>R'
                EVEN


                DC.W 4          ;restrict
                DC.L (r_from-sys-of)
__r_from:       DC.L (__to_r-datas)
                DC.B 2,'R>'
                EVEN


                DC.W 0
                DC.L (r_fetch-sys-of)
__r_fetch:      DC.L (__r_from-datas)
                DC.B 2,'R@'
                EVEN


                DC.W 0
                DC.L (cr-sys-of)
__cr:           DC.L (__r_fetch-datas)
                DC.B 2,'CR'
                EVEN


                DC.W 0
                DC.L (space-sys-of)
__space:        DC.L (__cr-datas)
                DC.B 5,'SPACE'
                EVEN


                DC.W 4          ;restrict
                DC.L (lit-sys-of)
__lit:          DC.L (__space-datas)
                DC.B 3,'LIT'
                EVEN


                DC.W 2          ;immediate
                DC.L (literal-sys-of)
__literal:      DC.L (__lit-datas)
                DC.B 7,'LITERAL'
                EVEN


                DC.W 4          ;restrict
                DC.L (floatlit-sys-of)
__floatlit:     DC.L (__literal-datas)
                DC.B 8,'FLOATLIT'
                EVEN


                DC.W 4          ;restrict
                DC.L (flit-sys-of)
__flit:         DC.L (__floatlit-datas)
                DC.B 4,'FLIT'
                EVEN


                DC.W 0
                DC.L (fliteral-sys-of)
__fliteral:     DC.L (__flit-datas)
                DC.B 8,'FLITERAL'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_str_quote-sys-of)
__b_str_quote:  DC.L (__fliteral-datas)
                DC.B 3,'(")'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_string_emit-sys-of)
__b_string_emit:DC.L (__b_str_quote-datas)
                DC.B 4,'(.")'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_error_quote-sys-of)
__b_error_quote:DC.L (__b_string_emit-datas)
                DC.B 7,'(ERROR"'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_abort_quote-sys-of)
__b_abort_quote:DC.L (__b_error_quote-datas)
                DC.B 7,'(ABORT"'
                EVEN


                DC.W 0
                DC.L (quest_core-sys-of)
__quest_core:   DC.L (__b_abort_quote-datas)
                DC.B 5,'?CORE'
                EVEN

                DC.W 0
                DC.L (lastblk-sys-of)
__lastblk:      DC.L (__quest_core-datas)
                DC.B 7,'LASTBLK'
                EVEN
lastblkptr:     DC.L 0

                DC.W 0
                DC.L (lastbuf-sys-of)
__lastbuf:      DC.L (__lastblk-datas)
                DC.B 7,'LASTBUF'
                EVEN
lastbufptr:     DC.L 0

                DC.W 0
                DC.L (b_buffer-sys-of)
__b_buffer:     DC.L (__lastbuf-datas)
                DC.B 7,'(BUFFER'
                EVEN
buferrmess:     DC.B 25,'cannot write back buffer!'
                EVEN

                DC.W 0
                DC.L (buffer-sys-of)
__buffer:       DC.L (__b_buffer-datas)
                DC.B 6,'BUFFER'
                EVEN
bufferptr:      DC.L (b_buffer-sys-of)


                DC.W 0
                DC.L (b_block-sys-of)
__b_block:      DC.L (__buffer-datas)
                DC.B 6,'(BLOCK'
                EVEN
blkerrmess:     DC.B 18,'cannot read block!'
                EVEN

                DC.W 0
                DC.L (block-sys-of)
__block:        DC.L (__b_block-datas)
                DC.B 5,'BLOCK'
                EVEN
blockptr:       DC.L (b_block-sys-of)

                DC.W 0
                DC.L (tib-sys-of)
__htib:         DC.L (__block-datas)
                DC.B 3,'TIB'
                EVEN


                DC.W 0
                DC.L (query-sys-of)
__query:        DC.L (__htib-datas)
                DC.B 5,'QUERY'
                EVEN


                DC.W 0
                DC.L (skip-sys-of)
__skip:         DC.L (__query-datas)
                DC.B 4,'SKIP'
                EVEN


                DC.W 0
                DC.L (scan-sys-of)
__scan:         DC.L (__skip-datas)
                DC.B 4,'SCAN'
                EVEN


                DC.W 0
                DC.L (source-sys-of)
__source:       DC.L (__scan-datas)
                DC.B 6,'SOURCE'
                EVEN


                DC.W 0
                DC.L (word-sys-of)
__word:         DC.L (__source-datas)
                DC.B 4,'WORD'
                EVEN


                DC.W 0
                DC.L (char-sys-of)
__char:         DC.L (__word-datas)
                DC.B 4,'CHAR'
                EVEN


                DC.W 2          ;immediate
                DC.L (b_char-sys-of)
__b_char:       DC.L (__char-datas)
                DC.B 6,'[CHAR]'
                EVEN


                DC.W 0
                DC.L (capital-sys-of)
__captl:        DC.L (__b_char-datas)
                DC.B 7,'CAPITAL'
                EVEN


                DC.W 0
                DC.L (capitalize-sys-of)
__capitalize:   DC.L (__captl-datas)
                DC.B 10,'CAPITALIZE'
                EVEN


                DC.W 0
                DC.L (name-sys-of)
__name:         DC.L (__capitalize-datas)
                DC.B 4,'NAME'
                EVEN

                DC.W 0
                DC.L (vocsearch-sys-of)
__vocsearch:    DC.L (__name-datas)
                DC.B 9,'VOCSEARCH'
                EVEN


                DC.W 0
                DC.L (b_find-sys-of)
__b_find:       DC.L (__vocsearch-datas)
                DC.B 5,'(FIND'
                EVEN


                DC.W 0
                DC.L (find-sys-of)
__find:         DC.L (__b_find-datas)
                DC.B 4,'FIND'
                EVEN
findptr:        DC.L (b_find-sys-of)


                DC.W 0
                DC.L (nulst_quest-sys-of)
__nulst_quest:  DC.L (__find-datas)
                DC.B 8,'NULLSTR?'
                EVEN


                DC.W 0
                DC.L (notfound-sys-of)
__notfound:     DC.L (__nulst_quest-datas)
                DC.B 8,'NOTFOUND'
                EVEN
notfndptr:      DC.L (unknown-sys-of) ; ' unknown IS notfound


                DC.W 0
                DC.L (unknown-sys-of)
__unknown:      DC.L (__notfound-datas)
                DC.B 7,'UNKNOWN'
                EVEN

unknownmess:    DC.B 9," unknown!"
                EVEN


                DC.W 0
                DC.L (h_tick-sys-of)
__h_tick:       DC.L (__unknown-datas)
                DC.B 2,'H',$27  ; '
                EVEN


                DC.W 0
                DC.L (tick-sys-of)
__tick:         DC.L (__h_tick-datas)
                DC.B 1,$27      ; '
                EVEN


                DC.W 2
                DC.L (b_tick-sys-of)
__b_tick:       DC.L (__tick-datas)
                DC.B 3,"[']"
                EVEN


                DC.W 0
                DC.L (quest_stack-sys-of)
__quest_stack:  DC.L (__b_tick-datas)
                DC.B 6,'?STACK'
                EVEN

stkundermess:   DC.B 17,'<stack underflow>'
fltundermess:   DC.B 23,'<floatstack underflow!>'
                EVEN


                DC.W 0
                DC.L (compiler-sys-of)
__compiler:     DC.L (__quest_stack-datas)
                DC.B 8,'COMPILER'
                EVEN

restrmess:      DC.B 14,' compile only!'
                EVEN


                DC.W 0
                DC.L (interpreter-sys-of)
__interpreter:  DC.L (__compiler-datas)
                DC.B 11,'INTERPRETER'
                EVEN


                DC.W 0
                DC.L (parser-sys-of)
__parser:       DC.L (__interpreter-datas)
                DC.B 6,'PARSER'
                EVEN

parserptr:      DC.L (interpreter-sys-of) ; ' interpreter Is parser



                DC.W 0
                DC.L (interpret-sys-of)
__interpret:    DC.L (__parser-datas)
                DC.B 9,'INTERPRET'
                EVEN


                DC.W 4
                DC.L (push-sys-of)
__push:         DC.L (__interpret-datas)
                DC.B 4,'PUSH'
                EVEN


                DC.W 4
                DC.L (savearea-sys-of)
__savearea:     DC.L (__push-datas)
                DC.B 8,'SAVEAREA'
                EVEN


                DC.W 0
                DC.L (evaluate-sys-of)
__evaluate:     DC.L (__savearea-datas)
                DC.B 8,'EVALUATE'
                EVEN


                DC.W 0
                DC.L (less_sharp-sys-of)
__less_sharp:   DC.L (__evaluate-datas)
                DC.B 2,'<#'
                EVEN


                DC.W 0
                DC.L (sharp_greater-sys-of)
__sharp_greater:DC.L (__less_sharp-datas)
                DC.B 2,'#>'
                EVEN


                DC.W 0
                DC.L (hold-sys-of)
__hold:         DC.L (__sharp_greater-datas)
                DC.B 4,'HOLD'
                EVEN


                DC.W 0
                DC.L (sign-sys-of)
__sign:         DC.L (__hold-datas)
                DC.B 4,'SIGN'
                EVEN


                DC.W 0
                DC.L (sharp-sys-of)
__sharp:        DC.L (__sign-datas)
                DC.B 1,'#'
                EVEN


                DC.W 0
                DC.L (sharp_s-sys-of)
__sharp_s:      DC.L (__sharp-datas)
                DC.B 2,'#S'
                EVEN


                DC.W 0
                DC.L (udot-sys-of)
__udot:         DC.L (__sharp_s-datas)
                DC.B 2,'U.'
                EVEN


                DC.W 0
                DC.L (dot-sys-of)
__dot:          DC.L (__udot-datas)
                DC.B 1,'.'
                EVEN


                DC.W 0
                DC.L (prompt-sys-of)
__prompt:       DC.L (__dot-datas)
                DC.B 6,'PROMPT'
                EVEN


                DC.W 2          ;immediate
                DC.L (left_brack-sys-of)
__left_brack:   DC.L (__prompt-datas)
                DC.B 1,'['
                EVEN



                DC.W 0
                DC.L (right_brack-sys-of)
__right_brack:  DC.L (__left_brack-datas)
                DC.B 1,']'
                EVEN


                DC.W 0
                DC.L (align-sys-of)
__align:        DC.L (__right_brack-datas)
                DC.B 5,'ALIGN'
                EVEN


                DC.W 0
                DC.L (quit-sys-of)
__quit:         DC.L (__align-datas)
                DC.B 4,'QUIT'
                EVEN


                DC.W 0
                DC.L (cold-sys-of)
__cold:         DC.L (__quit-datas)
                DC.B 4,'COLD'
                EVEN


                DC.W 0
                DC.L (digit_quest-sys-of)
__digit_quest:  DC.L (__cold-datas)
                DC.B 6,'DIGIT?'
                EVEN


                DC.W 0
                DC.L (accumulate-sys-of)
__accumulate:   DC.L (__digit_quest-datas)
                DC.B 10,'ACCUMULATE'
                EVEN


                DC.W 0
                DC.L (count-sys-of)
__count:        DC.L (__accumulate-datas)
                DC.B 5,'COUNT'
                EVEN


                DC.W 0
                DC.L (convert-sys-of)
__convert:      DC.L (__count-datas)
                DC.B 7,'CONVERT'
                EVEN


                DC.W 0
                DC.L (n_number_quest-sys-of)
__nnumber_quest:DC.L (__convert-datas)
                DC.B 8,'NNUMBER?'
                EVEN


                DC.W $0308
                DC.L (fetch-sys-of)
__fetch:        DC.L (__nnumber_quest-datas)
                DC.B 1,'@'
                EVEN


                DC.W $0508
                DC.L (cfetch-sys-of)
__cfetch:       DC.L (__fetch-datas)
                DC.B 2,'C@'
                EVEN


                DC.W $0508
                DC.L (wfetch-sys-of)
__wfetch:       DC.L (__cfetch-datas)
                DC.B 2,'W@'
                EVEN


                DC.W $0308
                DC.L (store-sys-of)
__store:        DC.L (__wfetch-datas)
                DC.B 1,'!'
                EVEN


                DC.W $0408
                DC.L (cstore-sys-of)
__cstore:       DC.L (__store-datas)
                DC.B 2,'C!'
                EVEN


                DC.W $0408
                DC.L (wstore-sys-of)
__wstore:       DC.L (__cstore-datas)
                DC.B 2,'W!'
                EVEN


                DC.W 0
                DC.L (hex-sys-of)
__hex:          DC.L (__wstore-datas)
                DC.B 3,'HEX'
                EVEN


                DC.W 0
                DC.L (decimal-sys-of)
__decimal:      DC.L (__hex-datas)
                DC.B 7,'DECIMAL'
                EVEN


                DC.W 0
                DC.L (header_colon-sys-of)
__header_colon: DC.L (__decimal-datas)
                DC.B 7,'HEADER:'
                EVEN

noheadermess:   DC.B 21,'<no name for header!>'
notuniquemess:  DC.B 17,' is not unique!',13,10
                EVEN
                DC.W 0
                DC.L (colon-sys-of)
__colon:        DC.L (__header_colon-datas)
                DC.B 1,':'
                EVEN


                DC.W 0
                DC.L (m_colon-sys-of)
__m_colon:      DC.L (__colon-datas)
                DC.B 2,'M:'
                EVEN


                DC.W 0
                DC.L (reveal-sys-of)
__reveal:       DC.L (__m_colon-datas)
                DC.B 6,'REVEAL'
                EVEN



                DC.W 2          ;immediate
                DC.L (semi_colon-sys-of)
__semi_colon:   DC.L (__reveal-datas)
                DC.B 1,';'
                EVEN


                DC.W $0108
                DC.L (dup-sys-of)
__dup:          DC.L (__semi_colon-datas)
                DC.B 3,'DUP'
                EVEN


                DC.W $0108
                DC.L (drop-sys-of)
__drop:         DC.L (__dup-datas)
                DC.B 4,'DROP'
                EVEN


                DC.W $0408
                DC.L (swap-sys-of)
__swap:         DC.L (__drop-datas)
                DC.B 4,'SWAP'
                EVEN


                DC.W $0608
                DC.L (rot-sys-of)
__rot:          DC.L (__swap-datas)
                DC.B 3,'ROT'
                EVEN


                DC.W 0
                DC.L (quest_dup-sys-of)
__quest_dup:    DC.L (__rot-datas)
                DC.B 4,'?DUP'
                EVEN


                DC.W $0208
                DC.L (over-sys-of)
__over:         DC.L (__quest_dup-datas)
                DC.B 4,'OVER'
                EVEN


                DC.W $0108
                DC.L (_2drop-sys-of)
__2drop:        DC.L (__over-datas)
                DC.B 5,'2DROP'
                EVEN


                DC.W $0208
                DC.L (_2dup-sys-of)
__2dup:         DC.L (__2drop-datas)
                DC.B 4,'2DUP'
                EVEN


                DC.W $0208
                DC.L (_2over-sys-of)
__2over:        DC.L (__2dup-datas)
                DC.B 5,'2OVER'
                EVEN


                DC.W 0
                DC.L (_2swap-sys-of)
__2swap:        DC.L (__2over-datas)
                DC.B 5,'2SWAP'
                EVEN


                DC.W 0
                DC.L (cmove-sys-of)
__cmove:        DC.L (__2swap-datas)
                DC.B 5,'CMOVE'
                EVEN


                DC.W 0
                DC.L (cmove_up-sys-of)
__cmove_up:     DC.L (__cmove-datas)
                DC.B 6,'CMOVE>'
                EVEN


                DC.W 0
                DC.L (create-sys-of)
__create:       DC.L (__cmove_up-datas)
                DC.B 6,'CREATE'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (does-sys-of)
__does:         DC.L (__create-datas)
                DC.B 5,'DOES>'
                EVEN


                DC.W 0
                DC.L (semcl_code-sys-of)
__semcl_code:   DC.L (__does-datas)
                DC.B 6,';CODE)'
                EVEN


                DC.W 0
                DC.L (defer-sys-of)
__defer:        DC.L (__semcl_code-datas)
                DC.B 5,'DEFER'
                EVEN
defercrashmess: DC.B 20,'<missing deference!> '
                EVEN


                DC.W 0
                DC.L (variable-sys-of)
__variable:     DC.L (__defer-datas)
                DC.B 8,'VARIABLE'
                EVEN


                DC.W 0
                DC.L (constant-sys-of)
__constant:     DC.L (__variable-datas)
                DC.B 8,'CONSTANT'
                EVEN

                DC.W $0308
                DC.L (bl-sys-of)
__bl:           DC.L (__constant-datas)
                DC.B 2,'BL'
                EVEN


                DC.W 2          ;immediate
                DC.L (to-sys-of)
__to:           DC.L (__bl-datas)
                DC.B 2,'TO'
                EVEN

                DC.W 0
                DC.L (value-sys-of)
__value:        DC.L (__to-datas)
                DC.B 5,'VALUE'
                EVEN


* variables used by LOCAL
was_local:      DC.L 0
save_cur:       DC.L 0
save_dp:        DC.L 0

                DC.W 6
                DC.L (local-sys-of)
__local:        DC.L (__value-datas)
                DC.B 5,'LOCAL'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_do-sys-of)
__b_do:         DC.L (__local-datas)
                DC.B 3,'(DO'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_quest_do-sys-of)
__b_quest_do:   DC.L (__b_do-datas)
                DC.B 4,'(?DO'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_loop-sys-of)
__b_loop:       DC.L (__b_quest_do-datas)
                DC.B 5,'(LOOP'
                EVEN


                DC.W 4          ;restrict
                DC.L (b_plus_loop-sys-of)
__b_plus_loop:  DC.L (__b_loop-datas)
                DC.B 6,'(+LOOP'
                EVEN


                DC.W $020C      ;restrict, macro
                DC.L (i-sys-of)
__i:            DC.L (__b_plus_loop-datas)
                DC.B 1,'I'
                EVEN


                DC.W 4          ;restrict
                DC.L (j-sys-of)
__j:            DC.L (__i-datas)
                DC.B 1,'J'
                EVEN


                DC.W 4          ;restrict
                DC.L (unloop-sys-of)
__unloop:       DC.L (__j-datas)
                DC.B 6,'UNLOOP'
                EVEN


                DC.W 0
                DC.L (to_mark-sys-of)
__to_mark:      DC.L (__unloop-datas)
                DC.B 5,'>MARK'
                EVEN


                DC.W 0
                DC.L (to_resolve-sys-of)
__to_resolve:   DC.L (__to_mark-datas)
                DC.B 8,'>RESOLVE'
                EVEN


                DC.W 0
                DC.L (less_mark-sys-of)
__less_mark:    DC.L (__to_resolve-datas)
                DC.B 5,'<MARK'
                EVEN


                DC.W 0
                DC.L (less_resolve-sys-of)
__less_resolve: DC.L (__less_mark-datas)
                DC.B 8,'<RESOLVE'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (do-sys-of)
__do:           DC.L (__less_resolve-datas)
                DC.B 2,'DO'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (loop-sys-of)
__loop:         DC.L (__do-datas)
                DC.B 4,'LOOP'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (quest_do-sys-of)
__quest_do:     DC.L (__loop-datas)
                DC.B 3,'?DO'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (p_loop-sys-of)
__p_loop:       DC.L (__quest_do-datas)
                DC.B 5,'+LOOP'
                EVEN


                DC.W 4          ;restrict
                DC.L (leave-sys-of)
__leave:        DC.L (__p_loop-datas)
                DC.B 5,'LEAVE'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (quest_branch-sys-of)
__quest_branch: DC.L (__leave-datas)
                DC.B 7,'?BRANCH'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (if-sys-of)
__if:           DC.L (__quest_branch-datas)
                DC.B 2,'IF'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (then-sys-of)
__then:         DC.L (__if-datas)
                DC.B 4,'THEN'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (branch-sys-of)
__branch:       DC.L (__then-datas)
                DC.B 6,'BRANCH'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (else-sys-of)
__else:         DC.L (__branch-datas)
                DC.B 4,'ELSE'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (begin-sys-of)
__begin:        DC.L (__else-datas)
                DC.B 5,'BEGIN'
                EVEN


                DC.W 6
                DC.L (until-sys-of)
__until:        DC.L (__begin-datas)
                DC.B 5,'UNTIL'
                EVEN


                DC.W 6
                DC.L (again-sys-of)
__again:        DC.L (__until-datas)
                DC.B 5,'AGAIN'
                EVEN


                DC.W 6
                DC.L (repeat-sys-of)
__repeat:       DC.L (__again-datas)
                DC.B 6,'REPEAT'
                EVEN


                DC.W 6
                DC.L (while-sys-of)
__while:        DC.L (__repeat-datas)
                DC.B 5,'WHILE'
                EVEN


                DC.W 0
                DC.L (null_gleich-sys-of)
__null_gleich:  DC.L (__while-datas)
                DC.B 2,'0='
                EVEN


                DC.W 0
                DC.L (null_greater-sys-of)
__null_greater: DC.L (__null_gleich-datas)
                DC.B 2,'0>'
                EVEN


                DC.W 0
                DC.L (null_less-sys-of)
__null_less:    DC.L (__null_greater-datas)
                DC.B 2,'0<'
                EVEN


                DC.W 0
                DC.L (null_grgl-sys-of)
__null_grgl:    DC.L (__null_less-datas)
                DC.B 3,'0>='
                EVEN


                DC.W 0
                DC.L (null_legl-sys-of)
__null_legl:    DC.L (__null_grgl-datas)
                DC.B 3,'0<='
                EVEN


                DC.W 0
                DC.L (gleich-sys-of)
__gleich:       DC.L (__null_legl-datas)
                DC.B 1,'='
                EVEN


                DC.W 0
                DC.L (ungleich-sys-of)
__ungleich:     DC.L (__gleich-datas)
                DC.B 2,'<>'
                EVEN


                DC.W 0
                DC.L (less-sys-of)
__less:         DC.L (__ungleich-datas)
                DC.B 1,'<'
                EVEN


                DC.W 0
                DC.L (greater-sys-of)
__greater:      DC.L (__less-datas)
                DC.B 1,'>'
                EVEN


                DC.W 0
                DC.L (grgl-sys-of)
__grgl:         DC.L (__greater-datas)
                DC.B 2,'>='
                EVEN


                DC.W 0
                DC.L (legl-sys-of)
__legl:         DC.L (__grgl-datas)
                DC.B 2,'<='
                EVEN


                DC.W 0
                DC.L (min-sys-of)
__min:          DC.L (__legl-datas)
                DC.B 3,'MIN'
                EVEN


                DC.W 0
                DC.L (max-sys-of)
__max:          DC.L (__min-datas)
                DC.B 3,'MAX'
                EVEN


                DC.W 0
                DC.L (b_forget-sys-of)
__b_forget:     DC.L (__max-datas)
                DC.B 7,'(FORGET'
                EVEN


                DC.W 0
                DC.L (forget-sys-of)
__forget:       DC.L (__b_forget-datas)
                DC.B 6,'FORGET'
                EVEN

fencemess:      DC.B 17,' is beyond fence!'
                EVEN


                DC.W 0
                DC.L (string_komma-sys-of)
__string_komma: DC.L (__forget-datas)
                DC.B 2,',"'
                EVEN


                DC.W 6          ;immediate, restrict
                DC.L (string_emit-sys-of)
__string_emit:  DC.L (__string_komma-datas)
                DC.B 2,'."'
                EVEN


                DC.W 2          ;immediate
                DC.L (dot_brack-sys-of)
__dot_brack:    DC.L (__string_emit-datas)
                DC.B 2,'.('
                EVEN


                DC.W 2          ;immediate
                DC.L (comment_brack-sys-of)
__comment_brack:DC.L (__dot_brack-datas)
                DC.B 1,'('
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (error_quote-sys-of)
__error_quote:  DC.L (__comment_brack-datas)
                DC.B 6,'ERROR"'
                EVEN


                DC.W 0
                DC.L (abort-sys-of)
__abort:        DC.L (__error_quote-datas)
                DC.B 5,'ABORT'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (abort_quote-sys-of)
__abort_quote:  DC.L (__abort-datas)
                DC.B 6,'ABORT"'
                EVEN


                DC.W 2          ;immediate
                DC.L (quote-sys-of)
__quote:        DC.L (__abort_quote-datas)
                DC.B 1,'"'
                EVEN


                DC.W 6          ;immediate restrict
                DC.L (postpone-sys-of)
__postpone:     DC.L (__quote-datas)
                DC.B 8,'POSTPONE'
                EVEN


                DC.W 0
                DC.L (immediate-sys-of)
__immediate:    DC.L (__postpone-datas)
                DC.B 9,'IMMEDIATE'
                EVEN


                DC.W 0
                DC.L (restrict-sys-of)
__restrict:     DC.L (__immediate-datas)
                DC.B 8,'RESTRICT'
                EVEN


                DC.W 0
                DC.L (vocabulary-sys-of)
__vocabulary:   DC.L (__restrict-datas)
                DC.B 10,'VOCABULARY'
                EVEN


                DC.W 0
                DC.L (fill-sys-of)
__fill:         DC.L (__vocabulary-datas)
                DC.B 4,'FILL'
                EVEN


                DC.W 0
                DC.L (erase-sys-of)
__erase:        DC.L (__fill-datas)
                DC.B 5,'ERASE'
                EVEN


                DC.W $0108
                DC.L (one_plus-sys-of)
__one_plus:     DC.L (__erase-datas)
                DC.B 2,'1+'
                EVEN


                DC.W $0108
                DC.L (one_minus-sys-of)
__one_minus:    DC.L (__one_plus-datas)
                DC.B 2,'1-'
                EVEN


                DC.W $0108
                DC.L (two_plus-sys-of)
__two_plus:     DC.L (__one_minus-datas)
                DC.B 2,'2+'
                EVEN


                DC.W $0108
                DC.L (two_minus-sys-of)
__two_minus:    DC.L (__two_plus-datas)
                DC.B 2,'2-'
                EVEN


                DC.W $0308
                DC.L (two_mult-sys-of)
__two_mult:     DC.L (__two_minus-datas)
                DC.B 2,'2*'
                EVEN


                DC.W $0308
                DC.L (two_div-sys-of)
__two_div:      DC.L (__two_mult-datas)
                DC.B 2,'2/'
                EVEN


                DC.W $0108
                DC.L (cell_plus-sys-of)
__cell_plus:    DC.L (__two_div-datas)
                DC.B 5,'CELL+'
                EVEN


                DC.W $0308
                DC.L (cells-sys-of)
__cells:        DC.L (__cell_plus-datas)
                DC.B 5,'CELLS'
                EVEN


                DC.W $0108
                DC.L (char_plus-sys-of)
__char_plus:    DC.L (__cells-datas)
                DC.B 5,'CHAR+'
                EVEN


                DC.W $08
                DC.L (chars-sys-of)
__chars:        DC.L (__char_plus-datas)
                DC.B 5,'CHARS'
                EVEN


                DC.W 0
                DC.L (update-sys-of)
__update:       DC.L (__chars-datas)
                DC.B 6,'UPDATE'
                EVEN

                DC.L -1         ;left free for USERBUFS ...
                DC.L -1         ;... mechanism
buf:            DC.L (buf-datas) ;pointer to next buffer (0)
                DC.L -1         ;phys. block            (4)
                DC.L -1         ;log. block             (8)
                DC.W 0          ;UPDATE                 (C)
                DS.B 48         ;blockheader            (E)
                DS.B 2000       ;data
                EVEN


                DC.W 0
                DC.L (b_load-sys-of)
__b_load:       DC.L (__update-datas)
                DC.B 5,'(LOAD'
                EVEN


lasthead:
                DC.W 0
                DC.L (load-sys-of)
lastword:
__load:         DC.L (__b_load-datas)
                DC.B 4,'LOAD'
                EVEN
loadptr:        DC.L (b_load-sys-of)





*               dc.w    0
*               dc.l    (-sys-of)
*__:    dc.l    (__-datas)
*               dc.b    ,''
* even

                ENDPART

*****************************************************************
dataHERE:
                END
                DC.W 0
