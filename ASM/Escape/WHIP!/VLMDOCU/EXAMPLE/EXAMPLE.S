;
; VLM EXAMPLE MODULE                                             NO/Escape'98
;

                OUTPUT 'E:\VOODOO\VLM\EXAMPLE.VLM'
                TEXT

                >PART 'vlm module structure'
*** VLM STRUCTURE **************************************************************

                DC.B "VLM2"     ;vlm module type
                DC.L infotext   ;pointer to infotext
                DC.L settings   ;pointer to settings-structure
                DC.L init       ;pointer to init routine
                DC.L deinit     ;pointer to deinit routine
                DC.L main       ;pointer to mainloop routine

;SERVICE ROUTINES PROVIDED BY THE CALLING PROGRAM

set_vblrout:
;a0: new vbl subroutine
                movea.l service_struct,A1
                movea.l (A1),A1
                jsr     (A1)
                rts

wait_vbl:
                movea.l service_struct,A1
                movea.l 4(A1),A1
                jsr     (A1)
                rts

set_scradr:
;a0: new screen adress
                movea.l service_struct,A1
                movea.l 8(A1),A1
                jsr     (A1)
                rts

set_resolution:
;d0: number of the wanted resolution
                movea.l service_struct,A1
                movea.l 12(A1),A1
                jsr     (A1)
                rts

get_left_spec:
                movea.l service_struct,A1
                movea.l 16(A1),A1
                jsr     (A1)            ;returns in a0 the adress of left spec
                rts

get_right_spec:
                movea.l service_struct,A1
                movea.l 20(A1),A1
                jsr     (A1)            ;returns in a0 the adress of right spec
                rts

get_left_volume:
                movea.l service_struct,A1
                movea.l 24(A1),A1
                jsr     (A1)            ;returns in d0 the left volume value
                rts

get_right_volume:
                movea.l service_struct,A1
                movea.l 28(A1),A1
                jsr     (A1)            ;returns in d0 the right volume value
                rts

get_left_osci:
                movea.l service_struct,A1
                movea.l 32(A1),A1
                jsr     (A1)            ;returns in a0 the adress of osci data
                rts

get_right_osci:
                movea.l service_struct,A1
                movea.l 36(A1),A1
                jsr     (A1)            ;returns in a0 the adress of osci data
                rts

service_struct: DC.L 0          ;must be set in 'init'

********************************************************************************
                ENDPART
infotext:       >PART
                DC.B 'PROGRAMMING EXAMPLE',0
                DC.B 'author:  NO/Escape',0
                DC.B 'version: 1.0',0
                DC.B 'date:    02.06.99',0
                DC.B 0
                EVEN
                ENDPART
settings:       >PART
                DC.L 3

                DC.L parname1
                DC.L 1          ;parameter type = activator
show_osci:      DC.L 1          ;parametervalue (1...activated)
                DC.L 0

                DC.L parname2
                DC.L 1
show_volumes:   DC.L 1
                DC.L 0

                DC.L parname3
                DC.L 1
show_spec:      DC.L 1
                DC.L 0

parname1:       DC.B "SHOW OSCILLOSCOPE",0
parname2:       DC.B "SHOW MAINVOLUMES",0
parname3:       DC.B "SHOW SPECTRE",0
                EVEN
                ENDPART
init:           >PART
;a0: service structure
                move.l  A0,service_struct

                movea.l scradr2,A0      ;set new screen adress
                bsr     set_scradr

                move.l  #2,D0           ;set resolution to 320x100
                bsr     set_resolution
                rts
                ENDPART
deinit:         >PART
                rts
                ENDPART
main:           PART

                bsr     wait_vbl
                bsr     switch_screens
                bsr     clrscr

;DRAW SPECTRES
                tst.l   show_spec       ;test spec activator
                beq     draw_no_spectres
                bsr     get_left_spec
                movea.l A0,A6
                movea.l scradr1,A0
                lea     (60+99*2*320.l,ZA0,A0.l),A0
                bsr     draw_spectre

                bsr     get_right_spec
                movea.l A0,A6
                movea.l scradr1,A0
                lea     (60+99*2*320+2*128.l,ZA0,A0.l),A0
                bsr     draw_spectre
draw_no_spectres:


;DRAW OSCILLOSCOPES (ONLY WHEN PARAMETER SET)
                tst.l   show_osci       ;test osci activator
                beq     draw_no_osci
                bsr     get_left_osci
                movea.l A0,A6           ;osci data
                movea.l scradr1,A0
                adda.l  #640*32+60,A0   ;screenposition
                move.w  #%1111,D6       ;color
                bsr     draw_oscilloscope

                bsr     get_right_osci
                movea.l A0,A6           ;osci data
                movea.l scradr1,A0
                adda.l  #640*32+60,A0   ;screenposition
                move.w  #%111100000000000,D6 ;color
                bsr     draw_oscilloscope
draw_no_osci:

;DRAW VOLUMES (ONLY WHEN PARAMETER SET)
                tst.l   show_volumes    ;test volume activator
                beq     draw_no_volumes
                bsr     get_left_volume ;returns left volume in d0
                lsr.l   #8,D0
                andi.w  #255,D0
                movea.l scradr1,A0
                adda.l  #640*50+60,A0
draw_left_volume_loop:
                move.w  #-1,(A0)+
                dbra    D0,draw_left_volume_loop

                bsr     get_right_volume ;returns right volume in d0
                lsr.l   #8,D0
                andi.w  #255,D0
                movea.l scradr1,A0
                adda.l  #640*60+60,A0
draw_right_volume_loop:
                move.w  #-1,(A0)+
                dbra    D0,draw_right_volume_loop
draw_no_volumes:

                rts                     ;end of the mainroutine



;FUNCTION DRAWS A SPECTRE ON THE SPECIFIED SCREENPOSITION
draw_spectre:
;a6: buffer with spec values
;a0: first screenadress
                lea     zshade_epp,A3
                move.w  #128-1,D2
receive_spectrum:
                moveq   #0,D0           ;get spec value from buffer
                move.w  (A6)+,D0        ;and scale it a bit
                lsl.l   #7,D0
                swap    D0
                andi.l  #$7F,D0

                cmpi.l  #99,D0          ;clip to high values
                blt     spec_value_ok
                move.l  #100,D0
spec_value_ok:
                movea.l A0,A1

                move.l  #100,D1         ;choose color (depends on spec value)
                sub.l   D0,D1
                lsr.l   #1,D1
                move.w  10(A3,D1.w*2),D1
draw_yloop:
                move.w  D1,(A1)
                lea     -640(A1),A1
                dbra    D0,draw_yloop
                addq.l  #2,A0           ;go on with next vertical line
                dbra    D2,receive_spectrum
                rts


;DRAWS AN OSCILLOSCOPE
draw_oscilloscope:
;a0: scradr
;d6: color
;a6: buffer with osci values
                lea     zshade_epp+32,A1
                move.w  #256-1,D7
get_left_osci_loop:
                move.w  (A6)+,D0        ;get value from left osci buffer
                ext.l   D0
                asl.l   #5,D0           ;scale value to range (-32..32)
                swap    D0
                move.w  D0,D1
                muls    #640,D0
                add.w   D6,0(A0,D0.w)
                addq.l  #2,A0
                dbra    D7,get_left_osci_loop
                rts


clrscr:
;clear screen
                movea.l scradr1,A0
                adda.l  #60+640*0,A0
                move.l  #%11110111110111101111011111011110,D5
                move.w  #100,D7
clrscr_yloop:
                move.w  #128-1,D6
clrscr_xloop:
                move.l  (A0),D0
                and.l   D5,D0
                lsr.l   #1,D0
                move.l  D0,(A0)+
                dbra    D6,clrscr_xloop
                adda.l  #128,A0
                dbra    D7,clrscr_yloop
                rts


;ROUTINE SWITCHES VISIBLE SCREEN AND CYCLES THE SCREENADRESSES
switch_screens:
                move.l  scradr3,D0
                move.l  scradr2,scradr3
                move.l  scradr1,scradr2
                move.l  D0,scradr1
                movea.l scradr2,A0
                bsr     set_scradr
                rts

                ENDPART

scradr1:        DC.L scr1+256
scradr2:        DC.L scr2+256
scradr3:        DC.L scr3+256
zshade_epp:     IBYTES 'ZSHADE.EPP'

                BSS

scr1:           DS.W 320*100
scr2:           DS.W 320*100
scr3:           DS.W 320*100

                END
