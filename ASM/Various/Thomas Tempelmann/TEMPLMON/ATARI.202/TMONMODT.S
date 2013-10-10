                        OPT Y+,X+
; *************************************************************************
; *                                                                       *
; *                     T M O N M O D T . E X E                           *
; *                                                                       *
; *                     ½ 1992 by Johannes Hill                           *
; *                                                                       *
; * This program adds a new address translation table to TempleMon. The   *
; * address translation structur is linear and flat. This table does not  *
; * limit access of TempleMon to any address space!                       *
; *                                                                       *
; *************************************************************************
; *                                                                       *
; * This program requires memory protection state GLOBAL! Set also the    *
; * program flags FASTLOAD, LOAD INTO TT RAM and ALTERNATE MALLOC!        *
; *                                                                       *
; *************************************************************************
; This is a specific optimized PMMU table for TempleMon only!
;   DO NOT USE for TOS! 
;   No guarantee for correct behavior!
;   Only for 68030 CPU's! 
;   DO NOT USE with other PMMU programming programms!
;   If a 'PMMU` cookie jar entry is found this will program abort 
;     (for VRAM and OUTSIDE)!
; This table does only use three stages of address translation! All page 
; descriptors are early termination desriptors!

anfang:         bra     start

; These leading words are necessary to move the table to a quad word beginning
; address! DO NOT remove them!

                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
table_main:     dc.l    $00000002    ; short format table descriptor
                                     ; will point to label table_00_B
                dc.l    $10000001    ; short format early termination
                dc.l    $20000001    ; short format early termination
                dc.l    $30000001    ; short format early termination
                dc.l    $40000001    ; short format early termination
                dc.l    $50000001    ; short format early termination
                dc.l    $60000001    ; short format early termination
                dc.l    $70000001    ; short format early termination
                dc.l    $80000001    ; short format early termination
                dc.l    $90000001    ; short format early termination
                dc.l    $A0000001    ; short format early termination
                dc.l    $B0000001    ; short format early termination
                dc.l    $C0000001    ; short format early termination
                dc.l    $D0000001    ; short format early termination
                dc.l    $E0000001    ; short format early termination
                dc.l    $F0000001    ; short format early termination
                                     ; cache inhibit for I/O and VME via
                                     ; register TT0!

table_00_B:     dc.l    $00000002    ; short format table descriptor
                                     ; will point to label table_00_C
                dc.l    $01000001    ; short format early termination
                dc.l    $02000001    ; short format early termination
                dc.l    $03000001    ; short format early termination
                dc.l    $04000001    ; short format early termination
                dc.l    $05000001    ; short format early termination
                dc.l    $06000001    ; short format early termination
                dc.l    $07000001    ; short format early termination
                dc.l    $08000001    ; short format early termination
                dc.l    $09000001    ; short format early termination
                dc.l    $0A000001    ; short format early termination
                dc.l    $0B000001    ; short format early termination
                dc.l    $0C000001    ; short format early termination
                dc.l    $0D000001    ; short format early termination
                dc.l    $0E000001    ; short format early termination
                dc.l    $0F000001    ; short format early termination

table_00_C:     dc.l    $00000001    ; short format early termination
                dc.l    $00100001    ; short format early termination
                dc.l    $00200001    ; short format early termination
                dc.l    $00300001    ; short format early termination
                dc.l    $00400001    ; short format early termination
                dc.l    $00500001    ; short format early termination
                dc.l    $00600001    ; short format early termination
                dc.l    $00700001    ; short format early termination
                dc.l    $00800001    ; short format early termination
                dc.l    $00900001    ; short format early termination
                dc.l    $00A00001    ; short format early termination
                dc.l    $00B00001    ; short format early termination
                dc.l    $00C00001    ; short format early termination
                dc.l    $00D00001    ; short format early termination
                dc.l    $00E00001    ; short format early termination
                dc.l    $00F00041    ; short format early termination,
                                     ; with cache inhibit

table_end:

start:          move.l  4(SP),A5
                move.l  A5,basepage
                lea     stackhigh,SP
                move.l  SP,A6
                suba.l  A5,A6
                addq.l  #2,A6
                move.l  A6,-(SP)
                move.l  A5,-(SP)
                clr.w   -(SP)
                move.w  #$4A,-(SP)   ; Mshrink
                trap    #1
                lea     $C(SP),SP
                clr.l   -(SP)        ; switch to supervisor mode
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                pea     Mess(PC)     ; print program message
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                movea.l $05A0,A3     ; check Cookie Jar
                movea.l A3,A0
                tst.l   $05A0        ; abort if cookie jar is absent
                beq     no_TMon
search_pmmu:    cmpi.l  #'PMMU',(A0) ; check for 'PMMU' cookie
                beq     PMMU         ; and abort if found
                addq.l  #8,A0
                tst.l   (A0)
                bne     search_pmmu
search:         cmpi.l  #'TMon',(A3) ; check for 'TMon' cookie
                beq     dotmon       ; start building address transl. table
                addq.l  #8,A3
                tst.l   (A3)
                bne     search
PMMU:           pea     PMMU_Mess(PC) ; abort if 'PMMU' cookie found
                bra     prg_abort
no_TMon:        pea     no_TMon_Mess(PC) ; abort if TempleMon not found
                bra     prg_abort
no_68030:       pea     no_68030_Mess(PC) ; abort if no 68030 CPU
prg_abort:      move.w  #9,-(SP)     ; print abort message
                trap    #1
                addq.l  #6,SP
                move.w  #-1,-(SP)
                move.w  #$4C,-(SP)
                trap    #1           ; PTERM(-1)
                bra     no_TMon
dotmon:         move.l  4(A3),A3     ; get TempleMon function handler
                moveq   #0,D0        ; get TempleMon internal stuff
                jsr     (A3)         ; call TempleMon
                andi.b  #$F,D1       ; mask CPU identifier
                cmpi.b  #3,D1        ; is CPU 68030?
                bne     no_68030     ; abort if not
                moveq   #23,D0       ; get/set address translation stuff
                moveq   #0,D1        ; switch off TempleMon address table
                move.l  D1,A0        ; no extra routine for TempleMon to be
                                     ; called from TempleMon just before it
                                     ; switches to its own address tree
                jsr     (A3)         ; call TempleMon
                move.l  A0,A4        ; save pointer to PMMU register structure
                lea     table_main(PC),A0  ; compute quad wird address
                move.l  A0,D0
                andi.w  #$FFF0,D0
                move.l  D0,A1
                move.l  A1,A2
                lea     table_end(PC),A5
loop:           move.l  (A0)+,(A2)+  ; move table to quad word address
                cmpa.l  A5,A0
                bcs     loop
                move.l  #table_00_B-table_main,D0
                add.l   A1,D0        ; install pointer to stage B in table
                or.l    D0,(A1)
                move.l  #table_00_C-table_main,D0
                add.l   A1,D0        ; install pointer to stage C in table
                or.l    D0,table_00_B-table_main(A1)
                move.l  #$80000002,D0
                move.l  D0,(A4)           ; set High-long word of CRP
                move.l  A1,4(A4)          ; set table address of CRP
                move.l  D0,8(A4)          ; set High-long word of SRP
                move.l  A1,12(A4)         ; set table address of SRP
                move.l  #$80F04445,16(A4) ; set TC
                move.l  #$FE018707,20(A4) ; set TT0
                clr.l   24(A4)            ; set TT1
                suba.l  a0,a0             ; no additinal routine for TempleMon
                moveq   #23,D0            ; get/set address translation stuff
                moveq   #-1,D1            ; switch on TempleMon address table
                jsr     (A3)              ; call TempleMon
                pea     installed(PC)     ; print install message
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                clr.w   -(SP)             ; keep only table resident in memory
                lea     table_end(PC),A0
                suba.l  basepage,A0
                move.l  A0,-(SP)
                move.w  #$31,-(SP)
                trap    #1
                bra     no_TMon
Mess:           dc.b   $1B,'p TMONMODT  V1.1  Jun 05 1992',$1B,'q',13,10
                dc.b   ' ½ 1992 by Johannes Hill',13,10,0
no_TMon_Mess:   dc.b   ' TempleMon not found! ',13,10,7,0
no_68030_Mess:  dc.b   ' Sorry, wrong CPU! ',13,10,7,0
PMMU_Mess:      dc.b   ' Sorry, PMMU programming program found! ',13,10,0
installed:      dc.b   ' New PMMU table for TempleMon installed.',13,10,0
                BSS
basepage:       ds.l   1
stack:          ds.b   1024
stackhigh:      ds.b   2
                END
