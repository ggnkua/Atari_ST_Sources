;-------------------------------------------------------------------------------
; Checkpoint presents: ---### BumpBoot ###---
;
; written in 2006/2007 by Defjam/Checkpoint
; defjam_cp@gmx.net  http://checkpoint.atari.org
;-------------------------------------------------------------------------------
;
; this is a speed optimized version - not such a slow bumper like in 4ster...
; could be faster replacing the movep.w reads.. but it would require
; more memory - and the lightsource has to be smaller
;
; attempt for a bootsector bumpmapper
; seems not that easy to do..
; WITH movement, stack correction, key check & erase on start !
; AND color palette save & restore !
; AND screen clear + text on exit !
; WORKS on F030 !!!
;
; for testing, MEM_START is the start of the BSS space (set to $140000 !)
; otherwise the BSS space start is at $30000  (2 bytes shorter)
;
; free bytes: 512-2-32 = 478
;
; bytes needed: 474  (including double lines)
;               466  (without double lines)
;
;
;-------------------------------------------------------------------------------
; DONT CHANGE THE COLORS !!! THEY ARE USED FOR SYSCALLS (function number)
; AS WELL AS OFFSETS!
;-------------------------------------------------------------------------------
; height: 96   (6*16)
; width:  160
;-------------------------------------------------------------------------------
                OUTPUT 'BUMPBOOT.PRG'
;-------------------------------------------------------------------------------
                OPT D+
                OPT W-
;-------------------------------------------------------------------------------
TEST            SET 0
;-------------------------------------------------------------------------------
                IFNE TEST
WRITE           SET 0           ; write bootsector
SWITCH__        SET 1           ; 1 testing
MEM_START       SET $00140000   ; use that for testing
BYTEGEIZ_ALLOC  SET 0           ; final:  BSS space at 0x30000
;-------------------------------------------------------------------------------
                ELSE
WRITE           SET 1           ; write bootsector
SWITCH__        SET 0           ; 1 testing
MEM_START       SET $00140000   ; use that for testing
BYTEGEIZ_ALLOC  SET 1           ; final:  BSS space at 0x30000
                ENDC
;-------------------------------------------------------------------------------

                IFNE WRITE
                move.l  #boot_end-boot_start,D0
                bra     write_bootsector
                ENDC

                IFNE SWITCH__
                move.l  #boot_end-boot_start,D0

                lea     (SP),A6
                move.w  #0,-(SP)        ; rez
                move.l  #-1,-(SP)
                move.l  (SP),-(SP)
                move.w  #5,-(SP)
                trap    #14
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                lea     (A6),SP
                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
boot_start:
                BASE A6,START_POINTERS
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,-(SP)     ; save colors

                lea     colors(PC),A6
                movem.l (A6)+,D2-A1
                bsr     write_colors

                pea     (A6)            ;    text(PC)
                move.w  D2,-(SP)        ; #9
                trap    #1
;Stack
; 6
                move.w  D3,-(SP)        ; #2  physbase
                trap    #14             ;
; 8
                lea     START_POINTERS(PC),A6

                >PART ' init checkpoint texture '
                move.l  D0,screen0(A6)
                movea.l D0,A0

                IF BYTEGEIZ_ALLOC
                clr.w   D4              ; 0x30000
                movea.l D4,A1
                ELSE
                lea     MEM_START,A1
                ENDC

; clear some lines in the start
                moveq   #2*160/4-1,D0
clr1st:
                clr.l   (A1)+
                dbra    D0,clr1st

                lea     (A1),A5

                moveq   #2*8-1,D0
rtex_y:
                move.l  #$00070001,D5
                moveq   #5-1,D6
rtex_xx:
                moveq   #8-1,D7
rtex_x:
                moveq   #6-1,D1
rtex_fxy:
                moveq   #4-1,D3
rtex_fx:
                addq.l  #1,D2           ; |noise
                rol.l   D2,D2           ; |function

; this way we free D0 ...
                btst    D7,(A0)
                seq     D4
                lsr.b   #2,D4

                move.b  D2,(A1)
                andi.b  #3,(A1)
                add.b   D4,(A1)+
                dbra    D3,rtex_fx

                lea     160-4(A1),A1
                dbra    D1,rtex_fxy

                lea     -6*160+4(A1),A1

                dbra    D7,rtex_x

                moveq   #0,D1           ; clear
                movep.l D1,0(A0)        ; text

                adda.w  D5,A0
                swap    D5
                dbra    D6,rtex_xx

                lea     -$00000011+160(A0),A0
                lea     5*160(A1),A1
                dbra    D0,rtex_y
; width:
; 5*8 = 40
; 160/40 = 4
;
; height:
; 96 / 2*8 = 6
                ENDPART

                >PART ' blur'

; D0 is $FFFF

;-moveq   #4-1,D4         ; blur passes
; counter replaced by bitshifting D0 by 4 bits until zero - 2 bytes shorter.

blur_passes:
                lea     (A5),A3
; D7 is -1
;-  moveq   #-1,D7
blur_xy:
                move.b  -160(A3),D1
                add.b   -1(A3),D1
                add.b   1(A3),D1
                add.b   160(A3),D1
                lsr.b   #2,D1
                move.b  D1,(A3)+
                subq.w  #4,D7
                bcc.s   blur_xy

;-dbra    D4,blur_passes
                lsr.w   #4,D0           ; 4 iterations if D0 = $FFFF !
                bne.s   blur_passes

                ENDPART

; A6 ... START == c2p_adr !!!

                >PART ' init c2p '

                moveq   #1,D1
                swap    D1              ; 0x10000

                lea     -2*160(A5),A1   ; adjust to 64k boundary !
                adda.l  D1,A1

                move.l  A1,(A6)+        ; c2p_adr0

                move.l  A1,(A6)         ;shorter than lea 0(a0,d1.l),a1
                add.l   D1,(A6)+        ;             move.l a1,(a6)+

                moveq   #16-1,D7
c2pm_1:
                moveq   #16-1,D6
c2pm_2:
                moveq   #4-1,D4         ; 4 planes
c2p_planes:
                btst    D4,D7
                seq     D2
                lsl.b   #6,D2           ; #%11000000
                btst    D4,D6
                seq     D3
                and.b   #%00110000,D3

                or.b    D3,D2
                ror.l   #8,D2
                dbra    D4,c2p_planes

                move.l  D2,(A1)+
                lsr.l   #4,D2
                move.l  D2,-4(A1,D1.l)  ; table 2

                dbra    D6,c2pm_2
                lea     $0400-$0040(A1),A1
                dbra    D7,c2pm_1

                ENDPART
; D1 is 0x10000
                >PART ' make lightsource '

                adda.l  D1,A1
                move.l  A1,(A6)+        ; lightsource_adr
; D7 = -1
ls_xy:
                move.w  D7,D2
                sub.w   #$7F7F,D2       ; center x & y
                move.b  D2,D0
                ext.w   D0
                asr.w   #8,D2

                muls    D0,D0
                muls    D2,D2
                add.l   D2,D0
                lsr.l   #8,D0
                moveq   #15,D3
                sub.w   D0,D3
                bpl.s   *+2
                moveq   #0,D3
                lsl.b   #2,D3
                move.b  D3,(A1)+
                dbra    D7,ls_xy
                ENDPART
make_bump_code:
                >PART ' make bumpvectors & code '

                move.l  A1,(A6)+        ; bump_code

                movea.l #$0BCE0000+4*160,A3 ;movep.l d5,0(a6)
                lea     bump_code_table(PC),A2

; D5 is $00010007
                moveq   #96-3-1,D7
bm_y:
                moveq   #160-1,D6
bm_x:
                move.w  (A2)+,(A1)+     ; opcode

                moveq   #-160/2,D0      ; position
                add.w   D6,D0
                add.b   (A5)+,D0        ; vector u
                sub.b   (A5),D0

                moveq   #-96/2,D1       ; position
                add.w   D7,D1
                add.b   160-1(A5),D1    ; vector v
                sub.b   -1(A5),D1

                move.b  D1,(A1)+        ; offset y
                move.b  D0,(A1)+        ; offset x

                tst.w   (A2)
                bne.s   bmc_more
                move.l  #$26402A13,(A1)+ ;move.l d0,a3 move.l (a3),d5
                move.l  #$26418A93,(A1)+ ;move.l d1,a3 or.l (a3),d5
                move.l  A3,(A1)+        ; movep.l draw

;- for doublelines:        takes 8 bytes
                move.l  A3,(A1)+
                addi.w  #160,-2(A1)
;-
                swap    D5              ; before increment
                adda.w  D5,A3           ; increment x offset
                subq.l  #8,A2           ; bump_code_table
bmc_more:
                subq.b  #1,D6
                bcc.s   bm_x
                lea     160(A3),A3
                dbra    D7,bm_y
                move.w  #$4E75,(A1)+

                ENDPART
; D7 is -1
; D6 is -1
loop:
                movem.l c2p_adr(PC),D0-D1/A0/A5-A6 ; c2p01 c2p02 lightsource bump_code screen
                lea     $7F80(A0),A0    ; center lightsource
                adda.w  D7,A0
                jsr     (A5)            ; bsr    bump_code

                moveq   #$39,D0
                cmp.b   $FFFFFC02.w,D0
                beq.s   __end__

                add.w   D6,D7
                cmp.w   D0,D7
                bge.s   swap_inc
                cmp.w   #-$0039,D7
                bgt.s   loop
swap_inc:
                neg.w   D6
                bra.s   loop
__end__:
;- clear screen
                addq.l  #2,SP           ;--    physbase stack
                trap    #1              ;--    textout !
                addq.l  #2,SP           ;--
;-
                movem.l (SP)+,D1-A1     ; correct stack & pop colors
write_colors:
                movem.l D2-A1,$FFFF8240.w
                rts

bump_code_table:
                DC.W $0108      ; movep.w 0(a0),d0
                DC.W $1028      ; move.b  0(a0),d0
                DC.W $0308      ; movep.w 0(a0),d1
                DC.W $1228      ; move.b  0(a0),d1
colors:         >PART
                DC.W 0          ; 0  endmarker of bump_code_table ! & color 0 !
                DC.W $0009      ; 1  9 = %1001

                DC.W $0102      ; 2  |
                DC.W $0002      ; 3  | has to be 2 !!

                DC.W $0003      ; 4
                DC.W $0104      ; 5
                DC.W $0205      ; 6
                DC.W $0306      ; 7
                DC.W $0407      ; 8
                DC.W $0517      ; 9
                DC.W $0627      ; 10
                DC.W $0737      ; 11
                DC.W $0747      ; 12
                DC.W $0757      ; 13
                DC.W $0767      ; 14
                DC.W $0777      ; 15
                ENDPART
text:
                DC.B 27,"E"     ; proper screenclear at start  (F030 !)
                DC.B 27,"H"     ;                                 "

                DC.B "ChECK",10,13
                DC.B "POiNt"
                DC.W 0
START_POINTERS:
boot_end:
                DS.L 128,'cpt.' ; filler
;-----------------------------
; pointers
c2p_adr         EQU START_POINTERS ;       DS.L 2
lightsource_adr EQU c2p_adr+2*4 ;       DS.L 1
bump_code_adr   EQU lightsource_adr+4 ; DS.L 1
screen0         EQU bump_code_adr+4 ;   DS.L 1
;-----------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFNE WRITE
write_bootsector:>PART
                linea   #$0A [ Hidem ]
                pea     wb_text(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
wb_key:
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                or.b    #$60,D0
                cmp.b   #'y',D0
                beq.s   wb_y
                cmp.b   #'n',D0
                beq.s   wb_end
                bra.s   wb_key
wb_y:
                bsr     wb_do
                tst.l   D0
                bpl.s   wb_write_ok

                pea     wb_prot(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                bra.s   wb_key
wb_write_ok:
wb_end:
                linea   #$09 [ Showm ]
                clr.w   -(SP)
                trap    #1

wb_text:
                DC.B 27,"E",27,"H"
;                     1234567890123456789012345678901234567890

                DC.B 10,13
                DC.B " BumpBoot by Defjam/Checkpoint in 2007  ",10,13
                DC.B 10,13
                DC.B 10,13
                DC.B "        -- bootsector installer --      ",10,13
                DC.B 10,13
                DC.B 10,13
                DC.B "insert write enabled disk in drive and  ",10,13
                DC.B 10,13
                DC.B "   press <y> to WRITE or <n> to EXIT ",10,13
                DC.B 0

wb_prot:
                DC.B 10,13,7,7
;                     1234567890123456789012345678901234567890
                DC.B "***> remove write-protection on disk<***",10,13
                DC.B "   press <y> to WRITE or <n> to EXIT ",10,13
                DC.B 0
                EVEN

wb_do:
                lea     b512(PC),A6
                bsr.s   read_bootsec
                move.w  #$601E,(A6)     ; branch to boot code
;                                         we skip LDMODE,SSECT, etc.
;                                         because it's used only on verrry old
;                                         machines (TOS on disk...)
                lea     boot_start(PC),A0
                lea     $0020(A6),A1
                move.w  #(512-$0020-2)/2-1,D0
wb00:
                move.w  (A0)+,(A1)+
                dbra    D0,wb00

; make valid checksum
                lea     (A6),A1
                moveq   #0,D1
                move.w  #510/2-1,D0
wb01:
                add.w   (A1)+,D1
                dbra    D0,wb01
                neg.w   D1
                add.w   #$1234,D1
                move.w  D1,510(A6)

                bsr.s   write_bootsec
                rts
read_bootsec:
                move.w  #1,-(SP)        ; count
                move.w  #0,-(SP)        ; side
                move.w  #0,-(SP)        ; track
                move.w  #1,-(SP)        ; sector
                move.w  #0,-(SP)        ; devno
                clr.l   -(SP)           ; unused
                pea     (A6)            ; buffer
                move.w  #8,-(SP)
                trap    #14
                lea     $0014(SP),SP
                rts
write_bootsec:
                move.w  #1,-(SP)        ; count
                move.w  #0,-(SP)        ; side
                move.w  #0,-(SP)        ; track
                move.w  #1,-(SP)        ; sector
                move.w  #0,-(SP)        ; devno
                clr.l   -(SP)           ; unused
                pea     (A6)            ; buffer
                move.w  #9,-(SP)
                trap    #14
                lea     $0014(SP),SP
                rts
                ENDPART
                ENDC
;-------------------------------------------------------------------------------

                BSS

; these buffers/addresses arent valid anymore since we allocate the buffers on
; startup and store the addresses in the pointers field (much shorter this way!)
;-texture_checkpoint:DS.B 160*110
;-bump_code:      DS.B 112002*1
;-zero_base:
;-                DS.L 65536/4    ;; FOR A 65536 BOUNDARY!!
;-c2p_table32:    DS.L 65536/4    ;C2P
;-c2p_table10:    DS.L 65536/4    ;C2P
;-                DS.L 65536/4    ;; FOR A 65536 BOUNDARY!!
;-                DS.L 65536/4    ;; FOR A 65536 BOUNDARY!!
;-lightsource:    DS.B 256*256

b512:           DS.B 512
                END
