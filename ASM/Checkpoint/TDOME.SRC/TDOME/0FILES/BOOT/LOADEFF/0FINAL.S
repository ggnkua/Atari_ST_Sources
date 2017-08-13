;-------------------------------------------------------------------------------
TEST            EQU 0
                OUTPUT 'LOAD1.PRG'
;-------------------------------------------------------------------------------
; Loadereffect
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
                RSSET $00000200
load1_ipc:      RS.L 1
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
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
__start_main_music:RS.B 1       ;
Init_Kernel_ALL:RS.B 1          ;
Get_timeline_list:RS.B 1
Get_timeline_next:RS.B 1

load__noReadyWait__:RS.B 1
get__loaderstate__:RS.B 1
load__sectors__:RS.B 1

;-------------------------------
lbuffer_size    EQU 2048        ; 8192

**  RSSET $00000040
                RSSET $00000300
KERNEL_ADR:     RS.L 1
bytes_avail:    RS.L 1
load_pos:       RS.L 1
depack_pos:     RS.L 1
depacked_ptr:   RS.L 1          ; pointer to next memory location depack

current_loadStart:RS.L 1
current_loadAddress:RS.L 1

;-------------------------------
RTE_            EQU $00000030
RTS_            EQU $00000032
;-------------------------------------------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFNE TEST
                bra     skip_kernel
                >PART
__KernelCall:
                movea.l KERNEL_ADR.w,A3
                jsr     (A3)
                rts
                DS.B 1024       ; kernel stack
KERNEL_INC:
                PATH 'C:\0NEW\TDOME\0FILES\KERNEL\'
                IBYTES 'KERNEL.PRG'
                EVEN

                moveq   #-1,D0          ; init kernel
                moveq   #-1,D1
                bsr     KERNEL_INC

                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall
                ENDPART
                ENDC
skip_kernel:
;-------------------------------------------------------------------------------
                OPT D-
                IFNE TEST
                OPT D+
                >PART ' init '

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                move.l  #vbl_count,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl

                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                ENDPART
                ENDC

                IFNE TEST
                moveq   #-1,D0          ; init kernel
                moveq   #-1,D1
                bsr     KERNEL_INC

                bsr     init_loader_part

                lea     fname(PC),A0
                lea     buffer,A1
                moveq   #load_depack__,D0 ;A0.fname, A1.buffer | D0.depacked_size
                bsr     __KernelCall

loop:
                bsr     wait_vbl

*     bsr     loader_impuls

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop

fname:
                DC.B "VIDSTR_0.NRV",0
*  DC.B "VQST_1.NRV",0
                EVEN

                ENDC

init_loader_part:
                bsr     wait_vbl

                clr.l   load1_ipc.w

                clr.l   last_position
                clr.l   current_loadStart.w
                clr.l   current_loadAddress.w

                lea     BSS_START(PC),A0
                lea     BSS_END,A1
                bsr     memclr_a0_a1

                bsr     wait_vbl

                move.l  #vbl_loader,$00000070.w

                move.l  #screen_ram,D0
                clr.b   D0
                move.l  D0,screen1
                movea.l D0,A1
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w

                lea     164*160(A1),A1

                lea     loading_gfx+32(PC),A0
                move.w  #(36*160)/4-1,D0
c00:            move.l  (A0)+,(A1)+
                dbra    D0,c00

                bsr     wait_vbl

                lea     loading_gfx(PC),A0
                movem.l (A0),D0-D6/A3
                movem.l D0-D6/A3,$FFFF8240.w

                bsr     set_blocks_col1
                rts


YW              SET 32
Y_Next          SET 64

CenterX         SET 5*8
CenterY         SET 0*160

speed:          DC.W 0

screenlist_ptr: DC.L screenlist_blocks
current_color:  DC.W 1
delay:          DC.W 0
LI_ALL_DONE_FLAG:DC.W 0

loader_impuls:  >PART

*   DC.L $4AFC4E71

                lea     delay(PC),A3
                subq.w  #1,(A3)
                bpl.s   li_wait
                move.w  speed(PC),(A3)

                movea.l screenlist_ptr(PC),A3
                move.w  current_color(PC),D0

                addq.w  #1,D0
                cmp.w   #16,D0
                ble.s   li_more_colors
                moveq   #1,D0
                addq.l  #4,A3
                tst.l   (A3)
                bne.s   li_listnotend
                subq.l  #4,A3
                st      LI_ALL_DONE_FLAG
                moveq   #15,D0
li_listnotend:
li_more_colors:
                move.l  A3,screenlist_ptr
                move.w  D0,current_color
                movea.l (A3),A0         ; screen
                bsr     draw_block
li_wait:
                rts
                ENDPART

set_blocks_col1:PART

                movea.l screen1(PC),A1
                lea     CenterX(A1),A1
                lea     CenterY(A1),A1

                lea     screenlist_blocks,A2

                moveq   #0,D0           ; color 0

                moveq   #3-1,D6
tb_yC:
                lea     (A1),A0
                moveq   #3-1,D5
tb_xC:
                move.l  A0,(A2)+        ; screenlist
                bsr.s   draw_block

                lea     4*8(A0),A0
                dbra    D5,tb_xC

                lea     Y_Next*160(A1),A1
                dbra    D6,tb_yC

                clr.l   (A2)+           ; end of list

                rts
                ENDPART

;-------------------------------------------------------------------------------
; A0.screen
; D0.colorIndex
draw_block:     >PART

                movem.l D0-D6/A0-A3,-(SP)

                tst.w   D0
                bpl.s   *+2
                moveq   #0,D0

                cmp.w   #15,D0
                ble.s   *+2
                moveq   #15,D0

                lsl.w   #3,D0
                movem.l db_colplanes(PC,D0.w),D0-D1

                moveq   #YW-1,D6
dby:
                movem.l D0-D1,(A0)
                movem.l D0-D1,8(A0)
                lea     160(A0),A0
                dbra    D6,dby
                movem.l (SP)+,D0-D6/A0-A3
                rts


                OPT O-,W-
X               SET $FFFF
db_colplanes:
                DC.W 0,0,0,0
                DC.W X,0,0,0
                DC.W 0,X,0,0
                DC.W X,X,0,0
                DC.W 0,0,X,0
                DC.W X,0,X,0
                DC.W 0,X,X,0
                DC.W X,X,X,0
                DC.W 0,0,0,X
                DC.W X,0,0,X
                DC.W 0,X,0,X
                DC.W X,X,0,X
                DC.W 0,0,X,X
                DC.W X,0,X,X
                DC.W 0,X,X,X
                DC.W X,X,X,X
                OPT O+,W+
                ENDPART
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
screen1:        DC.L 0

last_position:  DC.L 0

update_distance:DC.L 4*512

vbl_loader:     >PART

                movem.l D0-A6,-(SP)

                move.l  current_loadAddress.w,D0
                move.l  D0,D6
                beq.s   no_impuls

*    DC.L $4AFC4E71

                lea     last_position(PC),A0
                move.l  (A0),D1
                bne.s   not_first
                move.l  current_loadStart.w,D1
not_first:
                sub.l   D1,D0
                sub.l   update_distance(PC),D0
                bmi.s   no_impuls
                move.l  D6,(A0)         ; last_position = current_loadAddress

*   DC.L $4AFC4E71

                bsr     loader_impuls
no_impuls:
                movem.l (SP)+,D0-A6

vbl_count:      addq.l  #1,$00000466.w
                rte
                ENDPART

wait_vbl:       >PART
                clr.l   $00000466.w
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
memclr_a0_a1:   >PART
                movem.l D0/A0-A1,-(SP)
                move.l  A1,D0           ; end
                sub.l   A0,D0           ; length
                bsr.s   memclr
                movem.l (SP)+,D0/A0-A1
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

                DATA


                PATH 'C:\0NEW\TDOME\0FILES\BOOT\'
                PATH 'LOADEFF\'

loading_gfx:    IBYTES 'LOADING.GFX'

black:
zero:           DS.L 16

;-------------------------------------------------------------------------------
                BSS

screenlist_blocks:DS.L 3*3+1


                IFNE TEST
                DS.B 512
stack:          DS.B 2
                ENDC

BSS_START:
                DS.B 256
screen_ram:
                DS.B 32000
BSS_END:

                IFNE TEST
buffer:
                DS.L 812000/4
                ENDC

                END
