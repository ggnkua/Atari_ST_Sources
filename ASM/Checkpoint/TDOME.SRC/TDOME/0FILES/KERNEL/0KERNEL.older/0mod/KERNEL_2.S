;-------------------------------------------------------------------------------
;
; Thunderdome - The Demo                      (w)2013,2014 defjam,lsl/checkpoint
;
; KERNEL
;
; D0-D6/A0-A3
;
; FDC-Statusregister
; SR = $2600
;
;-------------------------------------------------------------------------------
TEST            EQU 1
                OUTPUT 'KERNEL.BIN'
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
sectors         EQU 10          ; 9
tracks          EQU 80          ; 79
;-------------------------------------------------------------------------------
PRINT_HEX8      EQU 0
PRINT_HEX2      EQU $00000018
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' *** music struct *** '

                RSSET $00000038
music_vbl:      RS.L 1
music_start:    RS.L 1
;----------------------------------------------------------
                RSSET 0
Init__:         RS.L 1          ;  +0
Exit__:         RS.L 1          ;  +4
Replay__:       RS.L 1          ;  +8
Set_SID_flags__:RS.L 1          ; +12   D0: %00000ABC
Get_PlayPos__:  RS.L 1          ; +16
Set_PlayPos__:  RS.L 1          ; +20
Get_SID_state__:RS.L 1          ; +24
Get_Speed__:    RS.L 1          ;
Set_Speed__:    RS.L 1          ;

use_MFP__:      RS.B 1
                RSEVEN

                ENDPART
;-------------------------------------------------------------------------------
                >PART ' kernel data '
;-------------------------------------------------------------------------------
                RSSET 0
load_depack__:  RS.B 1          ;A0.fname, A1.buffer | D0.depacked_size
load__:         RS.B 1          ;A0.fname, A1.buffer | D0.loaded_size
depack__:       RS.B 1          ;A0.src  , A1.dest
relocate__:     RS.B 1          ;A0.prg
get_kernel_space__:RS.B 1       ;A0.kernel start D0.size
START_MAIN__:   RS.B 1          ;
Init_Kernel__:  RS.B 1          ;
wait_load_ready:RS.B 1          ;
start_main_music:RS.B 1         ;
Init_Kernel_ALL:RS.B 1          ;
Get_timeline_list:RS.B 1
Get_timeline_next:RS.B 1
;-------------------------------
lbuffer_size    EQU 2048        ; 8192

                RSSET $00000038
music_vbl_:     RS.L 1          ; $38
MUSIC_START:    RS.L 1          ; $3C

                RSSET $00000040
KERNEL_ADR:     RS.L 1
bytes_avail:    RS.L 1
load_pos:       RS.L 1
depack_pos:     RS.L 1
lbuffer_end:    RS.L 1
DEPACK_PTR:     RS.L 1          ; current depacked position

total_time:     RS.L 1

_d7:            RS.B 1
;-------------------------------
RTE_            EQU $00000030
RTS_            EQU $00000032
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
                RSSET $000004CE
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
res0:           RS.B 1
res1:           RS.B 1
res2:           RS.B 1
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                OPT D-
                IFNE TEST
                OPT D+
                bra.s   __start__
save_mfp:       >PART
                movem.l D0-A6,-(SP)
                move    #$2700,SR
                lea     mfp_regslist(PC),A0
                lea     mfp_save(PC),A1
sml:
                move.w  (A0)+,D0
                beq.s   smle
                movea.w D0,A2
                move.b  (A2),(A1)+
                bra.s   sml
smle:
                move    #$2300,SR
                movem.l (SP)+,D0-A6
                rts
                ENDPART
restore_mfp:    >PART
                movem.l D0-A6,-(SP)
                move    #$2700,SR
                lea     mfp_regslist(PC),A0
                lea     mfp_save(PC),A1
rml:
                move.w  (A0)+,D0
                beq.s   rmle
                movea.w D0,A2
                move.b  (A1)+,(A2)
                bra.s   rml
rmle:
                move    #$2300,SR
                movem.l (SP)+,D0-A6
                rts

mfp_save:       DS.B 16

mfp_regslist:
                DC.W $FA1F      ; td a
                DC.W $FA23      ; td c
                DC.W $FA25      ; td d

                DC.W $FA19      ; tc a
                DC.W $FA1D      ; tc cd

                DC.W $FA07
                DC.W $FA09
                DC.W $FA13
                DC.W $FA15

                DC.W 0
                ENDPART
                ENDC
__start__:
                IFNE TEST
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1

                >PART ' init machine  '
                move    #$2700,SR
                lea     stack,SP

                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                lea     $00000034.w,A0
                move.l  #$4E734E75,(A0) ; rte, rts
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w
                move.l  A0,$00000070.w
                move.l  A0,$00000110.w
                move.l  A0,$00000134.w
                move.l  A0,$00000114.w
                move.l  A0,$00000120.w

                lea     $FFFF8800.w,A0
                move.l  #$08000000,(A0)
                move.l  #$09000000,(A0)
                move.l  #$0A000000,(A0)
                move.l  #$0700FF00,(A0)

                move.l  #cnt_vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl
                bsr     wait_vbl
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                movem.l black,D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

                ENDPART

                move.l  #screen_ram,D0
                clr.b   D0
                lea     screen0(PC),A0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w


*   jsr     ARJ_TEST        *********************

                move.l  #vbl,$00000070.w

                bsr     timer_b_test

*   DC.L $4AFC4E71

                movem.l regs,D0-A6

                lea     fname,A0
                lea     output,A1
*  bsr     load_depack
                bsr     __load__

                bsr     verify

loop:
                bsr     wait_vbl

                move.b  $FFFFFC02.w,D0
                cmpi.b  #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop

fname:
*  DC.B "RANIM.ARJ",0
                DC.B "RANIM.ENC",0
                EVEN

regs:
                DS.L 16,$12345678

timer_b_test:
                bsr     init_timer_b
                move.l  #tb_vbl,$00000070.w
                rts
tbt_l:
                bsr     wait_vbl
                cmpi.b  #$39,$FFFFFC02.w
                bne.s   tbt_l
                DC.L $4AFC4E71
                rts

init_timer_b:   >PART
                move.l  #rte,$00000120.w
                clr.b   $FFFFFA1B.w
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B
                rts
                ENDPART
tb_vbl:         >PART
                move    #$2700,SR
                move.b  #0,$FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #timer_b,$00000120.w

*   move.w  #$0000,$FFFF8240.w

                move    #$2400,SR

                movem.l D0-A6,-(SP)

                move.w  #150,D0
*  bsr     wait_d0_scanlines

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

                ENDPART
timer_b:        PART

                rte

                addi.w  #$0123,$FFFF8240.w
                rte
                ENDPART

wait_d0_scanlines:>PART
                DS.W 128-3,$00004E71
                dbra    D0,wait_d0_scanlines
                rts
                ENDPART

;----------------------------------------------------------------------------------

ARJ_TEST:       >PART

                DC.L $4AFC4E71

                move.l  #$AAAAAAAA,D7
                movea.l D7,A4
                movea.l D7,A5
                movea.l D7,A6


                lea     arj_pak,A0
                lea     output,A1
                bsr     depack

                bsr     verify

                DC.L $4AFC4E71
                DC.L $4AFC4E71
                DC.L $4AFC4E71
                ENDPART

verify:         >PART

                lea     orig,A0
                lea     output,A1
                move.l  #orig_end-orig,D7
vl:
                cmpm.b  (A0)+,(A1)+
                beq.s   vok
                subq.l  #1,A0
                subq.l  #1,A1
                move.w  #$0700,$FFFF8240.w
                DC.L $4AFC4E71
vok:
                subq.l  #1,D7
                bne.s   vl
                rts
                ENDPART

;-------------------------------------------------------------------------------
cnt_vbl:        >PART
                addq.l  #1,$00000466.w
rte:            rte
                ENDPART
vbl:            >PART
                addq.l  #1,$00000466.w
                rte
                ENDPART
swap_screens:   >PART

                move.l  screen1,D0
                move.l  screen0,screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

                ENDPART
;-------------------------------------------------------------------------------
screen0:        DC.L 0
screen1:        DC.L 0
draw_screen:    DC.L 0
                ENDC

;-------------------------------------------------------------------------------
                IFNE TEST
;-------------------------------------------------------------------------------
instr_cycle:    >PART
                move.l  #svbl,$00000070.w
                move    #$2300,SR
sloop:
                lea     stack,SP
                move    #$2300,SR
                clr.b   $FFFF8201.w
                clr.b   $FFFF8203.w

                jsr     wait_vbl
                move    #$2700,SR

                moveq   #0,D0
                moveq   #0,D1
                movea.l screen1,A0
                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                move.l  A0,$00000168.w


                lea     $FFFF8800.w,A5


                lea     $FFFF8209.w,A3
;get synced
sts:            move.b  (A3),D0
                beq.s   sts
                not.w   D0
                lsl.l   D0,D0

;sync to $0 - $A0 Position!
w:              move.b  (A3),D0
                bne.s   w
                DS.W 40,$00004E71
;Sync_Pos should be Zero now!!   (1 nop before --> Sync_pos=2 !)
                move.b  $FFFF8209.w,_1st_+3 ;3


*  movea.w (A6)+,A4        ;2
*  move.l  (A4)+,D7        ;3
*  movep.l D7,0(A5)        ;7
*  move.l  (A4)+,(A5)      ;6 ... 18

*  move.l  (A4)+,D7        ;3
*  movea.l (A4)+,A4        ;3

*  movem.l (A4),D7/A4      ; 7

                move.l  (A4)+,$FFFF8800.w ;7


                move.b  $FFFF8209.w,_2nd_+3 ;3            move.b (a3),d4 [2]

;Maximum_Count_Cycles = (160 - 6)/2 = 77 Nops!

_2nd_:          move.b  #0,D0
_1st_:          sub.b   #0,D0
                sub.b   #12,D0
                lsr.b   #1,D0           ;/2 = nop's

                lea     stack,SP
                DC.L $4AFC4E71

                move.w  #$0700,$FFFF8240.w
                move.w  #$0000,$FFFF8240.w
                jmp     sloop
svbl:           addq.l  #1,$00000466.w
                rte

bla:
                rts

                ENDPART
;-------------------------------------------------------------------------------
                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; ************************
; ******** KERNEL ********
; ************************
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
kernal_crt0:    >PART

                asl.w   #2,D0
                bmi.s   crt0_init
                jmp     kernel_routs(PC,D0.w)
kernel_routs:
                OPT O-,W-
                bra     __load_depack__ ; 0  OUT: D0.l depacked size
                bra     __load__        ; 1
                bra     __depack__      ; 2  A0->A1
                bra     __relocate__    ; 3  A0
                bra     __get_kernel_space__ ; 4  A0.kernel start D0.size
                bra     __START_MAIN__  ; 5
                bra     __Init_Kernel__ ; 6
                bra     __wait_load_ready ; 7
                bra     __start_main_music ; 8
                bra     __Init_Kernel_ALL ; 9
                bra     __Get_timeline_list ; 10
                bra     __Get_timeline_next ; 11
                OPT O+,W+
                ENDPART
;-------------------------------------------------------------------------------
SR_LOADER:      DC.W $2400
;-------------------------------------------------------------------------------
crt0_init:      >PART

                move    #$2700,SR

                bsr     irqs_mfp_off
                bsr     ym_off

                move.l  #RTS_,music_vbl.w

                moveq   #3,D0
                bsr     wait_d0_vbls

                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                rts

                ENDPART

__START_MAIN__:                         ; 5
                rts

__Init_Kernel__:>PART
                lea     kernal_crt0(PC),A0
                move.l  A0,KERNEL_ADR.w
                rts
                ENDPART

__Init_Kernel_ALL:>PART
                bsr.s   __Init_Kernel__
                move.l  #RTS_,music_vbl.w
                bsr     irqs_mfp_off
                lea     vbl_music(PC),A0
                move.l  A0,$00000070.w
                rts
                ENDPART

__Get_timeline_list:>PART
                lea     timeline(PC),A0
                lea     timeline_pos(PC),A1
                move.l  A0,(A1)
                rts
                ENDPART

__Get_timeline_next:>PART
                lea     timeline_pos(PC),A1
                movea.l (A1),A0
                moveq   #0,D0
                move.w  (A0)+,D0
                move.l  A0,(A1)
                rts
                ENDPART

timeline_pos:   DC.L 0
timeline:
                DS.W 32

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
__start_main_music:>PART        ; 8

                rts

                ENDPART

music_vbl_hook: >PART

; bsr     music+8                   ; replay music

music_vbl_call: jsr     0

                bsr     timer_output

                rts

                ENDPART
;-------------------------------------------------------------------------------
wait_d0_vbls:   >PART
                bsr.s   wait_vbl
                dbra    D0,wait_d0_vbls
                rts
                ENDPART
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
__load_depack__:>PART
                bra     load_depack
                ENDPART
__load__:       >PART

                bsr     load_normal

                bsr.s   __wait_load_ready

                move.l  load_size(PC),D0
                bsr     align_d0

                rts
                ENDPART
__depack__:     >PART           ; A0->A1
                bra     depack          ; A0->A1
                ENDPART
__relocate__:   >PART
                bra     relocate
                ENDPART
__get_kernel_space__:>PART      ; 4  A0.kernel start D0.size
                rts
                ENDPART

__wait_load_ready:>PART
                move.l  D0,-(SP)

wl2:            bsr     wait_load_ready_K
                tst.b   D0
                beq.s   wl2

                move.l  (SP)+,D0
                rts
                ENDPART

;-------------------------------------------------------------------------------
irqs_mfp_off:   >PART

                move    #$2700,SR

                lea     RTE_.w,A0
                move.l  #$4E734E75,(A0) ; rte rts
                lea     $00000060.w,A1
                moveq   #($0140-$0060)/4-1,D0
srte:
                move.l  A0,(A1)+
                dbra    D0,srte

                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w

                bclr    #3,$FFFFFA17.w  ; auto eoi

                lea     kernal_crt0(PC),A0
                move.l  A0,KERNEL_ADR.w

                lea     vbl0(PC),A0
                move.l  A0,$00000070.w

                move    #$2300,SR
                rts
                ENDPART
ym_off:         >PART
                lea     $FFFF8800.w,A6
                move.l  #$0700FF00,(A6)
                move.l  #$08000000,(A6)
                move.l  #$09000000,(A6)
                move.l  #$0A000000,(A6)
                rts
                ENDPART
;-------------------------------------------------------------------------------
STOP_LOADER:    >PART
                lea     LOADER_DATA(PC),A0
                st      stop_loader(A0)
wait_stop:
                tst.b   stop_loader_done(A0)
                beq.s   wait_stop
                rts
                ENDPART
;-------------------------------------------------------------------------------
vbl0:
                addq.l  #1,$00000466.w
                rte

vbl_music:      >PART
                movem.l D0-A6,-(SP)

                movea.l music_vbl.w,A0
                jsr     (A0)

                movem.l (SP)+,D0-A6
                bra.s   vbl0
                ENDPART
;-------------------------------------------------------------------------------
; A0-->A1 , D0 length
memcpy:         >PART

                movem.l D0-D6/A0-A3,-(SP)

                divu    #4*32,D0
                bra.s   mcpy0_
mcpy0:
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,1*32(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,2*32(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,3*32(A1)
                lea     4*32(A1),A1
mcpy0_:         dbra    D0,mcpy0

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   mcpy1_
mcpy1:
                move.l  (A0)+,(A1)+
mcpy1_:         dbra    D0,mcpy1

                swap    D0
                bra.s   mcpy2_
mcpy2:
                move.b  (A0)+,(A1)+
mcpy2_:         dbra    D0,mcpy2

                movem.l (SP)+,D0-D6/A0-A3

                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0, D0 length
memclr:         >PART

                movem.l D0-D6/A0-A3,-(SP)

                adda.l  D0,A0

                movem.l zero(PC),D1-D6/A1-A3

                divu    #8*36,D0
                bra.s   _mc0
mc0:
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
_mc0:           dbra    D0,mc0

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   _mcl1
mcl1:
                move.l  D1,-(A0)
_mcl1:          dbra    D0,mcl1

                swap    D0
                bra.s   _mcl2
mcl2:           move.b  D1,-(A0)
_mcl2:          dbra    D0,mcl2

                movem.l (SP)+,D0-D6/A0-A3
                rts
                ENDPART
;-------------------------------------------------------------------------------

black:
zero:           DS.L 16

;-------------------------------------------------------------------------------
; A0...fname OUT: D0...num_sectors
get_sectors_size:>PART

                movem.l D1-A6,-(SP)

                bsr     search_file_in_dir

; A0 Name   RETURN: D0.LogSec D3.LenSec

                moveq   #0,D0
                move.w  D3,D0

                movem.l (SP)+,D1-A6
                rts
                ENDPART

align_d0:       >PART
                moveq   #1,D1
                and.w   D0,D1
                add.l   D1,D0
                rts
                ENDPART

; A0...fname
; A1...buffer
load_normal:    >PART
                lea     filename_pointer(PC),A2
                movem.l A0-A1,(A2)

                lea     LOADER_DATA(PC),A2

                st      normal_load_flag(A2) ; normal loading

                clr.b   stop_loader(A2)
                clr.b   stop_loader_done(A2)

                bsr     init_load_hard

                movea.l filename_pointer(PC),A0
                bsr     load_file_hard

                rts
                ENDPART

; A0...fname
; A1...buffer
load_depack:    >PART

*    DC.L $4AFC4E71

                movem.l D1-A1,-(SP)


                lea     filename_pointer(PC),A2
                movem.l A0-A1,(A2)

                lea     LOADER_DATA(PC),A2

                clr.b   normal_load_flag(A2) ; load & depack

                clr.b   stop_loader(A2)
                clr.b   stop_loader_done(A2)

                bsr     init_load_hard

                movea.l filename_pointer(PC),A0
                bsr     load_file_hard

                movea.l load_address_pointer(PC),A0
                bsr.s   arj_deplo       ; start depacker

                move.l  depacked_size(PC),D0
                bsr.s   align_d0

                movem.l (SP)+,D1-A1

                rts
                ENDPART

; A0...prg
relocate:       >PART

                movem.l D0-D3/A0-A1,-(SP)

                lea     2(A0),A1
                lea     $001C(A0),A0
                move.l  A0,D0

                adda.l  (A1)+,A0        ; text
                adda.l  (A1)+,A0        ; data
                lea     (A0),A3         ; BSS Start
                move.l  (A1)+,D3        ; bss
                adda.l  (A1)+,A0        ; rest  (symboltable)

                move.l  (A0)+,D1        ;relocation info ??
                beq.s   end_relocation  ;nope...
                movea.l D0,A1           ; text start
                adda.l  D1,A1           ;1st adress - long offset
                moveq   #0,D1
                moveq   #1,D2
relo_do:
                add.l   D0,(A1)         ;relocate!
RELO2:
                move.b  (A0)+,D1
                beq.s   end_relocation
                cmp.b   D2,D1
                bne.s   normal_distance
                lea     254(A1),A1
                bra.s   RELO2
normal_distance:
                adda.l  D1,A1
                bra.s   relo_do
end_relocation:
                movem.l (SP)+,D0-D3/A0-A1
                rts
                ENDPART

; A0-->A1
depack:         >PART

                movem.l D1-D6/A0-A3,-(SP)

                lea     $007FFFFF,A2
                move.l  A2,bytes_avail.w ; bytes_avail
                lea     0(A0,A2.l),A2   ;  lbuffer_end
                move.l  A2,lbuffer_end.w
                bsr.s   arj_start

                movem.l (SP)+,D1-D6/A0-A3

                move.l  depacked_size(PC),D0
                rts

                ENDPART
;-------------------------------------------------------------------------------
depacked_size:  DC.L 0

; a0...depack buffer
arj_deplo:      >PART           ; *** D7,A4,A5,A6 FREE DEPACKER ***

                movem.l D1-D6/A0-A3,-(SP)

                bsr.s   arj_deplo_main

                movem.l (SP)+,D1-D6/A0-A3

                move.l  depacked_size(PC),D0
                rts

arj_deplo_main:
                lea     (A0),A1         ; dest

                lea     load_buffer(PC),A0 ; source

                lea     lbuffer_size-1(A0),A2 ; lbuffer_end
                move.l  A2,lbuffer_end.w

lw0:            tst.l   bytes_avail.w   ; bytes_avail
                beq.s   lw0

arj_start:
                cmpi.l  #'ARJ!',(A0)+
                beq.s   do_arj
                rts
do_arj:
                move.l  (A0)+,D0        ;Ori size
                addq.l  #4,A0
                exg     A0,A1

                lea     depacked_size(PC),A2
                move.l  D0,(A2)
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
; d7: #bits in subbitbuf    _d7.w
; a0: depack space
; a1: rbuf_current
; a2: source adres for byte copy
; a3: temporary register
; a4: not used
; a5: not used
; a6: not used
decode_f:
                move.l  D0,D3           ; origsize

                clr.b   _d7.w           ; bitcount = 0

                moveq   #$10,D4         ; push 16 (8) bits into bitbuf

                move.w  (A1)+,D6        ; word in subbitbuf
                lsl.l   D4,D6           ; fill bitbuf

                subi.l  #4+4+4+2,bytes_avail.w
                addi.l  #4+4+4+2,depack_pos.w

                move.l  A0,DEPACK_PTR.w
count_loop:                             ; main depack loop
                move.l  D6,D1           ; evaluate most significant bit bitbuf
                bmi.s   start_sld       ; =1 -> sliding dictionary
                moveq   #9,D0           ; pop bits from bitbuf for literal
                bsr.s   getbits         ;
                move.b  D2,(A0)+        ; push byte in buffer
                move.l  A0,DEPACK_PTR.w
eval_loop:
                subq.l  #1,D3           ;
                bne.s   count_loop      ;
; *DONE*
                rts                     ;
start_sld:
                movea.w #8,A3           ;
                moveq   #0,D2           ; max power
                bsr.s   get_them        ;
                add.w   D2,D5           ; length
                move.w  D5,D4           ;
                move.l  D6,D1           ; bitbuf
                subq.w  #3,A3           ; move.w  #5,a3
                moveq   #9,D2           ; minimum getbits
                bsr.s   get_them        ;
                ror.w   #7,D5           ;
                addq.w  #1,D4           ; increment len by one
                add.w   D5,D2           ; calc pointer
                neg.w   D2              ; pointer offset negatief
                lea     -1(A0,D2.w),A2  ; pointer in dictionary
                sub.l   D4,D3           ; sub 'bytes to copy' from 'bytes to do' (d4 is 1 too less!)
copy_loop_0:
                move.b  (A2)+,(A0)+     ;
                dbra    D4,copy_loop_0  ;
                move.l  A0,DEPACK_PTR.w
                bra.s   eval_loop       ;
get_them:
                moveq   #1,D0           ; minimum fillbits
                moveq   #0,D5           ; value
loop2:
                add.l   D1,D1           ; shift bit outside
                bcc.s   einde           ; if '1' end decode
                addx.w  D5,D5           ; value *2+1
                addq.w  #1,D0           ; extra fill
                addq.w  #1,D2           ; extra get
                cmp.w   A3,D0           ; max bits
                bne.s   loop2           ; nog mal
                subq.w  #1,D0           ; 1 bit less to trash
einde:
                bsr.s   fillbits        ; trash bits
                move.w  D2,D0           ; bits to get
getbits:
                move.l  D6,D2           ;
                clr.w   D2              ;
                rol.l   D0,D2           ;
fillbits:
                sub.b   D0,_d7.w        ; decrease subbitbuf count
                bcc.s   no_fill         ;
                move.b  _d7.w,D1        ;
                add.b   D0,D1           ;
                sub.b   D1,D0           ;
                rol.l   D1,D6           ;

;----------------------------------------------------
; buffer check
lw1:            tst.l   bytes_avail.w   ; bytes_avail
                beq.s   lw1
                subq.l  #2,bytes_avail.w
                addq.l  #2,depack_pos.w

                move.w  (A1)+,D6        ;

* cmpa.l  A1,A5           ; lbuffer_end
* bcc.s   lw_nowrap
                cmpa.l  lbuffer_end.w,A1
                bcs.s   lw_nowrap
                lea     load_buffer(PC),A1
lw_nowrap:
;----------------------------------------------------

                addi.b  #16,_d7.w       ; bits in subbitbuf
no_fill:
                rol.l   D0,D6           ; bits to pop from buffer
                rts                     ;
;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
********************************************************************************
                ENDPART
;-------------------------------------------------------------------------------
filename_pointer:DC.L 0
load_address_pointer:DC.L 0
load_size:      DC.L 0
;-------------------------------------------------------------------------------
wait_load:      >PART
                bsr     wait_load_ready_K
                tst.b   D0
                beq.s   wait_load
                rts
                ENDPART
get_loaded_bytes:>PART
                bsr     loaded_bytes_K
                rts
                ENDPART
;------------------------------------
;-------------------------------------------------------------------------------
init_load_hard: >PART

                lea     dir_read_flag(PC),A2
                tas.b   (A2)
                bne.s   dir_loaded

                lea     normal_load_flag+LOADER_DATA(PC),A2
                move.w  (A2),-(SP)
                pea     (A2)
                st      (A2)

; load directory:
                moveq   #0,D0
                moveq   #2,D1
                moveq   #0,D2
                moveq   #1,D3
                lea     directory(PC),A0
                bsr     load_rout_K

; bsr     WAIT_LOADING
wl_dir:         bsr     wait_load_ready_K
                tst.b   D0
                beq.s   wl_dir

                movea.l (SP)+,A2
                move.w  (SP)+,(A2)
dir_loaded:
                rts
dir_read_flag:  DC.B 0,0
                ENDPART
load_file_hard: >PART           ; A0 Name   A1 Buffer

;      bsr     wait_floppy_fade_end      ;falls noch fade out !!
;      bsr     start_floppy_fade_in
;      bsr     wait_floppy_fade_end

                clr.l   bytes_avail.w
                clr.l   load_pos.w
                clr.l   depack_pos.w

                bsr.s   search_file_in_dir

                movea.l load_address_pointer(PC),A0

                lea     LOADER_DATA+normal_load_flag(PC),A2
                tst.b   (A2)
                bne.s   normal_load2
                lea     load_buffer(PC),A0
normal_load2:
                bsr     load_rout_K
                rts
                ENDPART
search_file_in_dir:>PART        ; A0 Name   RETURN: D0.LogSec D3.LenSec

                lea     conv_file(PC),A2
                move.l  #'    ',D0
                move.l  D0,(A2)+        ;'1234'
                move.l  D0,(A2)+        ;'5678'
                move.l  #'.   ',(A2)+   ;'.123'

                lea     conv_file(PC),A2
lfh_name:
                move.b  (A0)+,D0
                beq.s   end_name
                cmp.b   #'.',D0
                bne.s   no_ext
                lea     8+1+conv_file(PC),A2 ;ext
                bra.s   lfh_name
no_ext:
                move.b  D0,(A2)+
                bra.s   lfh_name
end_name:
                lea     conv_file(PC),A2
                movem.l (A2),D0-D2

                lea     directory+2(PC),A2
                moveq   #64-1,D3
search:
                cmp.l   (A2),D0
                bne.s   next_s
                cmp.l   4(A2),D1
                bne.s   next_s
                cmp.l   8(A2),D2
                bne.s   next_s
;-- FOUND ----------------------------------------------
                movem.w 12(A2),D0/D3    ;Start ; Length

                move.w  D3,D4
                mulu    #512,D4
                lea     load_size(PC),A2
                move.l  D4,(A2)

                bsr     logic_sector_to_physsec
                rts
next_s:
                lea     16(A2),A2
                dbra    D3,search
; FILE NOT FOUND !!
err_lf:
                move.w  #$0700,$FFFF8240.w
                illegal

conv_file:      DC.B "12345678.123"
                EVEN

                ENDPART

load_rout_K:    >PART 'Init IRQ-Loader'

* 11C IRQ-LOADER ... totally PC-relative
;A0 Buffer
;D0 Track  D1 Sector  D2 Side(0/1)  D3 Sectors_to_go

                pea     (A1)
                lea     buffer_start(PC),A1
                move.l  A0,(A1)

                lea     LOADER_DATA(PC),A1
                st      loader_flag(A1)
                move.l  A0,(A1)+        ;adress.w
                subq.w  #1,D3           ;count
                movem.w D0-D3,(A1)      ;track, sector, side, sectors_to_go
                subq.l  #4,A1

                bsr.s   select_diskside

                move    SR,-(SP)
                move    #$2700,SR

                bset    #7,$FFFFFA09.w  ;Enable MFP IRQ
                bset    #7,$FFFFFA15.w

                bclr    #5,$FFFFFA03.w

                bclr    #3,$FFFFFA17.w  ;auto eoi

                pea     start_11c(PC)
                move.l  (SP)+,$0000011C.w
                or.l    D0,D0

                move    (SP)+,SR

                move.w  #$0086,$FFFF8606.w ;DATA Register select
                move.w  D0,$FFFF8604.w  ;  track(A1),$FFFF8604.w
                or.l    D0,D0
                move.w  #$0080,$FFFF8606.w ;CR select
                move.w  #%0000000000010111,$FFFF8604.w ;seek  verify/6ms
                movea.l (SP)+,A1
                rts

                ENDPART


; D2...diskside
select_diskside:>PART
                move    SR,-(SP)
;; select diskside
                move    #$2700,SR
                tst.w   D2              ;    side(A1)
                bne.s   sel_1
                move.l  #$0E0E0505,$FFFF8800.w ;Side 0
                bra.s   end_sel
sel_1:
                move.l  #$0E0E0404,$FFFF8800.w ;Side 1
end_sel:
                move.b  #8,$FFFF8800.w  ; psg select vol A
                move    (SP)+,SR
                rts
                ENDPART
start_11c:
                >PART           ;Track angesteuert!
read_sector_11c:
                move    SR_LOADER(PC),SR ******** SR **********
                pea     (A0)
                lea     LOADER_DATA(PC),A0

read_sector_11c_go:
                move    SR_LOADER(PC),SR ******** SR **********

                move.w  #$0084,$FFFF8606.w ;sector register selektieren
                move.w  sector(A0),$FFFF8604.w ;sektornummer
                or.l    D0,D0
                move.b  adress+3(A0),$FFFF860D.w
                move.b  adress+2(A0),$FFFF860B.w
                move.b  adress+1(A0),$FFFF8609.w
                or.l    D0,D0
                move.w  #$0090,$FFFF8606.w ;Clear Dma Buffer
                move.w  #$0190,$FFFF8606.w ; & Datenrichtung auf Lesen !
                move.w  #$0090,$FFFF8606.w
                or.l    D0,D0
                move.w  #1,$FFFF8604.w  ;1 sector
                or.l    D0,D0

                move.w  #$0080,$FFFF8606.w ;CR selektieren
                move.w  #$0080,$FFFF8604.w ;READ SECTOR --> CR

                lea     sector_done(PC),A0
                move.l  A0,$0000011C.w

                movea.l (SP)+,A0
                rte

sector_read_error:
                move.w  (SP)+,D0
;       eori.w  #$0777,$FFFF8240.w
                bra.s   read_sector_11c ;Try Again!

sector_done:
                move    SR_LOADER(PC),SR ******** SR **********

*  move.w  #$0700,$FFFF8240.w
*  DS.W 16,$00004E71
*  clr.w   $FFFF8240.w

                move.w  D0,-(SP)
                move.w  #$0080,$FFFF8606.w
                move.w  $FFFF8604.w,D0
                and.w   #$0038,D0
                bne.s   sector_read_error
                move.w  (SP)+,D0

                pea     (A0)

                lea     LOADER_DATA(PC),A0

                tst.b   normal_load_flag(A0)
                bne.s   normal_load
;--------------------------------------------------
;--------------------------------------------------
; buffer check
;bytes_avail:    RS.L 1
;load_pos:       RS.L 1
;depack_pos:     RS.L 1
                movem.l D0-D3,-(SP)

                move.l  load_pos.w,D0
                add.l   #512,D0
                move.l  depack_pos.w,D1
                and.l   #lbuffer_size-1,D0
                and.l   #lbuffer_size-1,D1

                move.l  D0,D2
                and.l   #-512,D1
                and.l   #-512,D2

                cmp.l   D1,D2
                bne.s   ladr_ok

                movem.l (SP)+,D0-D3
                bra.s   seek_track
ladr_ok:
                addi.l  #512,bytes_avail.w

                move.l  D0,load_pos.w

                add.l   buffer_start(PC),D0
                move.l  D0,adress(A0)

                movem.l (SP)+,D0-D3
                bra.s   no_normal_load
normal_load:
                addi.l  #512,bytes_avail.w
                addi.l  #512,adress(A0)
                move.l  adress(A0),load_pos.w
no_normal_load:
                addq.w  #1,sectors_loaded(A0)

                subq.w  #1,count(A0)
                bmi.s   end_sectors_load
;--------------------------------------------------
;--------------------------------------------------
                addq.w  #1,sector(A0)   ;inc sector
                cmpi.w  #sectors+1,sector(A0) ;max sector+1 ?
                bne     read_sector_11c_go
goto_next_track:
                move.w  #1,sector(A0)

                addq.w  #1,track(A0)
                cmpi.w  #tracks+1,track(A0) ;max track+1 ?
                beq.s   get_next_side
seek_track:
                tst.b   stop_loader(A0)
                beq.s   load_not_stopped
                st      stop_loader_done(A0)
                movea.l (SP)+,A0
                rte
load_not_stopped:

;___Loader_Restart:
; Mit SEEK - Befehl:  (Ist besser!! ... wrd' ich mal sagen)
                move.w  #$0086,$FFFF8606.w ;DATA Register selektieren ...
                move.w  track(A0),$FFFF8604.w ;Track --> Data
                or.l    D0,D0
                move.w  #$0080,$FFFF8606.w ;CR selektieren ...
                move.w  #$0013,$FFFF8604.w ;Seek mit Verify und Update

                lea     track_done(PC),A0
                move.l  A0,$0000011C.w
                movea.l (SP)+,A0
                rte

get_next_side:
                clr.w   track(A0)
                move.w  #1,side(A0)
                move    #$2700,SR
                move.l  #$0E0E0404,$FFFF8800.w ;Side 2
                move.b  #8,$FFFF8800.w  ;select volA
                move    SR_LOADER(PC),SR ******** SR **********
                bra.s   seek_track
track_done:
                move    SR_LOADER(PC),SR ******** SR **********
                bra     read_sector_11c

end_sectors_load:
                addi.l  #512,bytes_avail.w

                move    #$2700,SR
                clr.w   loader_flag(A0)
                bclr    #7,$FFFFFA09.w
                bclr    #7,$FFFFFA15.w
                move    SR_LOADER(PC),SR ******** SR **********

                lea     end_11C(PC),A0
                move.l  A0,$0000011C.w
                movea.l (SP)+,A0
end_11C:        rte
                ENDPART

Restart_Loader: >PART

                lea     LOADER_DATA(PC),A0
                clr.b   stop_loader(A0)
                clr.b   stop_loader_done(A0)

                move.w  side(A0),D2
                bsr     select_diskside

; Mit SEEK - Befehl:  (Ist besser!! ... wrd' ich mal sagen)
                move.w  #$0086,$FFFF8606.w ;DATA Register selektieren ...
                move.w  track(A0),$FFFF8604.w ;Track --> Data
                or.l    D0,D0
                move.w  #$0080,$FFFF8606.w ;CR selektieren ...
                move.w  #$0013,$FFFF8604.w ;Seek mit Verify und Update

                lea     track_done(PC),A0
                move.l  A0,$0000011C.w
                rts
                ENDPART

logic_sector_to_physsec:>PART
max_secside     SET sectors*(tracks+1)
                and.l   #$0000FFFF,D0
                move.l  D0,D1

                divu    #sectors,D0
                swap    D0
                addq.w  #1,D0           ;Sektor

                divu    #max_secside,D1
                move.w  D1,D2           ;Side

                clr.w   D1
                swap    D1
                divu    #sectors,D1     ;Track

                exg     D0,D1
                rts
                ENDPART

wait_load_ready_K:>PART
                pea     (A0)
                lea     LOADER_DATA+loader_flag(PC),A0
wait_load_:
;           tst.w   (A0)
;           bne.s   wait_load_                ;0 = fertig

                tst.w   (A0)
                seq     D0
                movea.l (SP)+,A0
                rts
                ENDPART

loaded_bytes_K: >PART           ;3
                lea     LOADER_DATA+adress(PC),A0
                move.l  (A0),D0
                sub.l   buffer_start(PC),D0
;      sub.l   #512,D0                   ;always 512 bytes ahead ...
;      bpl.s   *+2
;     moveq   #0,D0
                rts
buffer_start:   DC.L 0
                ENDPART

LOADER_DATA:    >PART

                RSSET 0
adress:         RS.L 1          ;    DC.L 0
track:          RS.W 1          ;    DC.W 0
sector:         RS.W 1          ;    DC.W 0
side:           RS.W 1          ;    DC.W 0
count:          RS.W 1          ;    DC.W 0
loader_flag:    RS.W 1          ;    SET $043E

normal_load_flag:RS.W 1
stop_loader:    RS.W 1
stop_loader_done:RS.W 1

sectors_loaded: RS.W 1

                RS.L 1
LOADER_DATA_SIZE:RS.W 0
                DS.B LOADER_DATA_SIZE
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
timer_output:   >PART

                addq.l  #1,total_time.w

*    bra.s   to_do           ;-------------

                move.b  $FFFFFC02.w,D0
                cmp.b   #$61,D0         ; UNDO
                beq.s   to_do
                cmp.b   #$003B+9,D0     ; F10
                bne.s   to_no_break
                DC.L $4AFC4E71
to_no_break:
                rts
to_do:
                move    SR,-(SP)
                move    #$2700,SR
; movem.l D0-A6,-(SP)
                lea     $FFFF8240.w,A6
                move.l  (A6),-(SP)      ; save color0,1

                move.l  #$00000777,(A6) ; set display colors

                ENDPART
;----------------------------------------------------
to_display:     >PART

; get screen address
                moveq   #0,D0
                lea     $FFFF8201.w,A2
                movep.w 0(A2),D0
                lsl.l   #8,D0
                movea.l D0,A2           ; screen
;----------------------------------------------------
                lea     (A2),A1         ; screen
                moveq   #1,D7           ; reset x_inc
;----------------------------------------------------
; print min:sec:vbl

                move.l  total_time.w,D0
                divu    #50,D0

                move.l  D0,-(SP)        ; save t/50

                ext.l   D0

                divu    #60,D0
                move.l  D0,-(SP)
; D0...minutes
                bsr.s   display_num2    ; display minutes

                move.l  (SP)+,D0
                swap    D0              ; seconds
; D0...seconds
                bsr.s   display_num2    ; display seconds

                move.l  (SP)+,D0        ; t/50
                swap    D0              ; vbl_ticks
                bsr.s   display_num2    ; display vbl_ticks

;----------------------------------------------------
; print total_time ticks

                lea     1*8*160(A2),A1  ; screen
                moveq   #1,D7           ; reset x_inc

                move.l  total_time.w,D2 ; value
                moveq   #PRINT_HEX8,D3
                bsr.s   print_hex       ; hex8
;----------------------------------------------------
; print music position

                lea     2*8*160(A2),A1  ; screen
                moveq   #1,D7           ; reset x_inc

*  move.b  #$F9,D2                   ; value

                movem.l D1-A6,-(SP)
                movea.l MUSIC_START.w,A0
                jsr     Get_PlayPos__(A0)
                movem.l (SP)+,D1-A6

                move.w  D0,D2           ; play_position

                moveq   #PRINT_HEX2,D3
                bsr.s   print_hex       ; hex2
;----------------------------------------------------
                ENDPART
;----------------------------------------------------
to_wait_cont:   >PART
                eori.w  #$0112,(A6)
                cmpi.b  #$3B,$FFFFFC02.w ; F1
                bne.s   to_wait_cont

                move.l  (SP)+,(A6)      ; restore color0,1
; movem.l (SP)+,D0-A6
                move    (SP)+,SR
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; D7...x_inc
; A1...screem
display_num2:   >PART           ; D0,D1, D7,A0,A1

                ext.l   D0
                divu    #10,D0
                bsr.s   display_num1
                swap    D0
                bsr.s   display_num1

; --> separator is following!

                ENDPART
separator:      >PART           ; D0,D1, D7,A1

                lea     (A1),A3         ; screen_pos
                moveq   #8-1,D0
s_y:
                moveq   #%00011100,D1   ; bit pattern
                bsr.s   output_d1_movepl
                dbra    D0,s_y
                bra.s   advance_cursor_x

                ENDPART
display_num1:   >PART           ; D0,D1, D7,A0,A1

                move.l  D0,-(SP)

                mulu    #7,D0
                lea     nums_gfx(PC,D0.w),A0

                lea     (A1),A3         ; screen_pos
                moveq   #7-1,D0         ; 7 lines!
dnt_y:
                moveq   #0,D1
                move.b  (A0)+,D1
                bsr.s   output_d1_movepl
                dbra    D0,dnt_y

                moveq   #0,D1
                bsr.s   output_d1_movepl ; line 8

                move.l  (SP)+,D0
advance_cursor_x:
                adda.w  D7,A1
                eori.w  #6,D7
                rts

                ENDPART
; D1.b, A3 screen
output_d1_movepl:>PART
                ror.l   #8,D1
                movep.l D1,0(A3)
                lea     160(A3),A3
                rts
                ENDPART
;-----------------------------------------------
; D2...digit
; D3...PRINT_HEXx (0...$1C)
;
print_hex:      >PART

                rol.l   D3,D2           ; shift to msb
phl:
                rol.l   #4,D2
                moveq   #$0F,D0
                and.w   D2,D0
                bsr.s   display_num1

                addq.w  #4,D3
                cmp.w   #$0020,D3
                bne.s   phl

                rts

                ENDPART
;-----------------------------------------------
                PATH 'C:\0NEW\TDOME\'
nums_gfx:       IBYTES 'NUMS_7.GFX'
;-------------------------------------------------------------------------------
;---------- BSS ------------------------------
directory:      DS.B 512
load_buffer:    DS.B lbuffer_size
LBE:
;---------------------------------------------
                DC.B "**END OF KERNEL**"
                EVEN
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                DATA

                IFNE TEST

;-------------------------------------------------------------------------------
                PATH 'C:\0NEW\TDOME\'
                PATH '0KERNEL\'
arj_pak:
*     IBYTES 'TD0_2.ARJ'
                EVEN
orig:
*     IBYTES 'TD0_2.PI1'
                IBYTES 'RANIM.ENC'
orig_end:
                ENDC

                BSS


                IFNE TEST

                DS.B 512
stack:          DS.B 2

BSS_START:      DS.B 2

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

BSS_END:        DS.B 2

output:
                DS.L 265536/4

                ENDC

                END
