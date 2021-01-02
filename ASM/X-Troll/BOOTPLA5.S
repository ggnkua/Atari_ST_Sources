;
; Plasma Bootsector by Cyclone / X-Troll
;
; Coded for Outline Bootsector Compo 2006
;
;------------------------------------------
tv              EQU 0
scrollamp       EQU 160
distamp         EQU 80
;------------------------------------------
                >PART 'Definitions'
;------------------------------------------
; System Vars
;------------------------------------------
_v_bas_ad       EQU $044E
_vbclock        EQU $0462
_frclock        EQU $0466
_membot         EQU $0432
;------------------------------------------
; Hardware Regs
;------------------------------------------
VAC_low         EQU $FFFF8209
COL0            EQU $FFFF8240
PSG             EQU $FFFF8801
;------------------------------------------
; DATA Structures
;------------------------------------------
                RSRESET
x:              RS.L 1
x0:             RS.L 1
xvec:           RS.L 1
nextx:          RS.B 0
; - - - - - - - - - - - - - - - - - - - - -
                RSRESET
vars:           RS.B 4*nextx            ; variables for movement
xofftab:        RS.W 200                ; distorter tab 200 rows
empty:          RS.W 2*96               ; just some buffer for black colours
coltab:         RS.W 1                  ; colours will be generated here
;------------------------------------------
                ENDPART
                >PART 'Switches'
;------------------------------------------
                IF tv
                OPT D+,O+,W+
                DEFAULT 1
                ELSE
                OPT D-,O-,W+
                DEFAULT 5
                ENDC
;------------------------------------------
                ENDPART
;==========================================
                TEXT
;==========================================
                PART 'Init'
;------------------------------------------
                IF tv
                lea     bss(PC),A6         ; base address for test mode
                ELSE
                movea.l _membot.w,A6       ; base address for bootsector mode
                ENDC

                movea.l _v_bas_ad.w,A0     ; get video base address
                lea     112+160*108(A0),A1 ; bottom right half address
                move.w  #160/4*90,D0       ; number of longs to copy

                move.l  (A0),(A1)+         ; copy fuji to bottom right corner
                clr.l   (A0)+              ; clear original position
                dbra    D0,*-6

                move.b  #$12,$FFFFFC02.w   ; kill mouse

                lea     vars(A6),A0        ; clear vars and a bit more ;)
                bsr.s   clr_sub0

                move.w  #scrollamp,vars+x0(A6) ; big scroll amplitude
                move.w  #-distamp,vars+nextx+x(A6)

                lea     $FFFF8801.w,A0     ; sound init
                lea     zak(PC),A1         ; this is actually the same stuff
                bra.s   snd0               ; i used in last years bootsector
snd:            movep.w D0,0(A0)
snd0:           move.w  (A1)+,D0
                bne.s   snd

;------------------------------------------
col_init:       lea     coltab(A6),A0
                moveq   #$00,D0            ; R
                moveq   #$00,D1            ; G
                moveq   #$00,D2            ; B

                bsr.s   col_init0          ; generate the colours 3 times
                bsr.s   col_init0
                pea     main(PC)           ; return to main routine
col_init0:
                lea     col_vectors(PC),A1
again:
                move.b  (A1)+,D3
                move.b  (A1)+,D4
                move.b  (A1)+,D5
                ext.w   D3
                ext.w   D4
                ext.w   D5

                moveq   #15-1,D7
loop:
                move.w  D0,D6              ; combine RGB and write to coltab
                lsl.w   #4,D6
                or.w    D1,D6
                lsl.w   #4,D6
                or.w    D2,D6
                swap    D7                 ; save d7
                move.w  D6,D7              ; STE change
                and.w   #$0111,D7          ; LSb only
                lsl.w   #3,D7
                lsr.w   #1,D6              ; HSbits only
                and.w   #$0777,D6
                or.w    D7,D6
                move.w  D6,(A0)+
                swap    D7                 ; return d7

                add.w   D3,D0              ; add RGB deltas
                add.w   D4,D1
                add.w   D5,D2

                dbra    D7,loop
                cmpi.b  #"E",(A1)          ; end of table
                bne.s   again
                rts
;------------------------------------------
*cls:            movea.l _v_bas_ad.w,A0     ; get video base address
clr_sub0:       move.w  #32000/4-1,D0      ; clear 32k
clr_sub:        clr.l   (A0)+
                dbra    D0,*-4
                rts
;------------------------------------------
zak:            DC.W $20EE,$030E,$0910,$0BEF,$0C00,$0D0C,$07FD,0
;------------------------------------------
                ENDPART
                >PART 'Main'
;------------------------------------------
vbl:
                lea     xofftab(A6),A4     ; distorter tab
                lea     PSG.w,A5           ; soundchip hardware address

                lea     _frclock.w,A0      ; wait for vbl
                clr.l   (A0)
wvbl:           tst.l   (A0)
                beq.s   wvbl

                moveq   #29,D1             ; synchronize with beam
                lea     VAC_low.w,A0
                move    #$2700,SR          ; disallow IRQs
wVAC:           move.b  (A0),D0
                beq.s   wVAC
                sub.w   D0,D1
                lsr.w   D1,D1

                move.w  #26-1,D0           ; fill the gap to next line
                dbra    D0,*-2

                lea     coltab+scrollamp(A6),A3 ; colourtab + some room
                lea     0(A3,D7.w),A3      ; add scrolloffset
                lea     COL0.w,A1          ; Hardware Colour Register 0
                move.w  #200-1,D0          ; Number of lines to go

line_loop:
                move.w  (A4)+,D3           ; get line offset for distort
                lea     0(A3,D3.w),A0      ; calculate line address

                REPT 33
                move.w  (A0)+,(A1)         ; write colours to screen
                ENDR

                and.b   #$10,D3            ; synced sound
                move.b  #10,(A5)
                move.b  D3,2(A5)
                and.b   #7,D3
                move.b  #13,(A5)
                move.b  D3,2(A5)

                dbra    D0,line_loop
                clr.w   (A1)               ; set black background
                move    #$2300,SR          ; allow IRQs

main:
;- - - - - - - - - - - - - - - - - - - - - -
                lea     vars(A6),A5        ; calculate current scroll position
                moveq   #11,D2             ; pre-divider for scroll-vector
                bsr.s   calc_swing
                swap    D0                 ; get only INTEGER part
                move.w  D0,D7              ; x-position
                add.w   D7,D7              ; into an offset
;- - - - - - - - - - - - - - - - - - - - - -
                lea     nextx(A5),A5
                bsr.s   calc_swing
                swap    D0
;- - - - - - - - - - - - - - - - - - - - - -
                lea     nextx(A5),A5       ; calculate distorter x-pos
                clr.w   x(A5)
                move.w  D0,x0(A5)
                moveq   #9,D2              ; set predivider
                lea     xofftab(A6),A0     ; table position
                move.w  #100-1,D6          ; 100 values * 2
mk_xofftab:
                bsr.s   calc_swing
                swap    D0
                add.w   D0,D0
                REPT 2
                move.w  D0,(A0)+
                ENDR
                dbra    D6,mk_xofftab

;- - - - - - - - - - - - - - - - - - - - - -
                cmpi.b  #$39,$FFFFFC02.w   ; wait for space
                bne     vbl                ; if not pressed back to loop
                IF tv
                illegal                    ; testmode exit to debugger
                ELSE
                rts                        ; bootmode exit
                ENDC
;------------------------------------------
calc_swing:     move.l  x(A5),D0           ; get old x
                add.l   xvec(A5),D0        ; add old xvec
                move.l  D0,x(A5)           ; write back

                move.l  x0(A5),D1          ; get target value
                sub.l   D0,D1              ; calc delta x
                asr.l   D2,D1              ; /16
                add.l   D1,xvec(A5)        ; add to xvec

                rts
;------------------------------------------
                ENDPART
                >PART 'Colours'
;------------------------------------------
col_vectors:
                DC.B 0,0,1
                DC.B 0,1,0              ; blue to cyan
                DC.B 0,0,-1             ; cyan to green
                DC.B 1,0,0              ; green to yellow
                DC.B 0,0,1
                DC.B 0,0,0
                DC.B 0,0,-1
                DC.B 0,-1,0             ; yellow to red
                DC.B 0,0,1              ; red to magenta
                DC.B -1,0,0             ; magenta to blue
                DC.B 0,0,-1

                DC.B "E"
                EVEN
;------------------------------------------
                ENDPART
                IF tv
;==========================================
                BSS
;==========================================
bss:            DS.L 64000
;==========================================
                ENDC
                END
