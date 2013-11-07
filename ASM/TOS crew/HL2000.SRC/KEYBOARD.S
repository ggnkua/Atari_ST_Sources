;
; keyboard interrupt handler
; vbl interrupt handler
; timer d music player
; (c) 1997 Mr Ni! the Great
;
; Geeft de volgende informatie:
; joy0:     dc.b   0     ;  volatile byte joy0;
; joy1:     dc.b   0     ;  volatile byte joy1;
; joy2:     dc.b   0     ;  volatile byte joy2; /* cursor joystick */
; last_key: dc.b   0     ;  volatile byte last_key;
;

EXPORT vbl_code, timer_d_code
EXPORT key_info, key_interrupt

IMPORT game, work_space;

include "hland.mac"

MUS_LEN equ 75250

                TEXT

JOY_UP    equ 1
JOY_LEFT  equ 4
JOY_RIGHT equ 8
JOY_DOWN  equ 2
JOY_FIRE  equ $80

;/* key handeler info */
;struct key_handler_info_struct

key_info:
joy0:     dc.b   0     ;  volatile byte joy0;
joy1:     dc.b   0     ;  volatile byte joy1;
joy2:     dc.b   0     ;  volatile byte joy2; /* cursor joystick */
last_key: dc.b   0     ;  volatile byte last_key;

.even

key_interrupt:
     move.l    d0,-(sp)          ;
     moveq     #0,d0             ; clear register
     move.b    $fffffc02.w,d0    ; get scancode
     add.w     d0,d0             ; verdubbel keycode
     move.w    .table_start(pc,d0.w),d0; get jump offset
     jmp       .table_start(pc,d0.w)

.table_start:
     dc.w      .default-.table_start ;00
     dc.w      .default-.table_start ;01
     dc.w      .default-.table_start ;02
     dc.w      .default-.table_start ;03
     dc.w      .default-.table_start ;04
     dc.w      .default-.table_start ;05
     dc.w      .default-.table_start ;06
     dc.w      .default-.table_start ;07
     dc.w      .default-.table_start ;08
     dc.w      .default-.table_start ;09
     dc.w      .default-.table_start ;0a
     dc.w      .default-.table_start ;0b
     dc.w      .default-.table_start ;0c
     dc.w      .default-.table_start ;0d
     dc.w      .default-.table_start ;0e
     dc.w      .default-.table_start ;0f
     dc.w      .default-.table_start ;10
     dc.w      .default-.table_start ;11
     dc.w      .default-.table_start ;12
     dc.w      .default-.table_start ;13
     dc.w      .default-.table_start ;14
     dc.w      .default-.table_start ;15
     dc.w      .default-.table_start ;16
     dc.w      .default-.table_start ;17
     dc.w      .default-.table_start ;18
     dc.w      .default-.table_start ;19
     dc.w      .default-.table_start ;1a
     dc.w      .default-.table_start ;1b
     dc.w      .default-.table_start ;1c
     dc.w      .default-.table_start ;1d
     dc.w      .default-.table_start ;1e
     dc.w      .default-.table_start ;1f
     dc.w      .default-.table_start ;20
     dc.w      .default-.table_start ;21
     dc.w      .default-.table_start ;22
     dc.w      .default-.table_start ;23
     dc.w      .default-.table_start ;24
     dc.w      .default-.table_start ;25
     dc.w      .default-.table_start ;26
     dc.w      .default-.table_start ;27
     dc.w      .default-.table_start ;28
     dc.w      .default-.table_start ;29
     dc.w      .default-.table_start ;2a
     dc.w      .default-.table_start ;2b
     dc.w      .default-.table_start ;2c
     dc.w      .default-.table_start ;2d
     dc.w      .default-.table_start ;2e
     dc.w      .default-.table_start ;2f
     dc.w      .default-.table_start ;30
     dc.w      .default-.table_start ;31
     dc.w      .default-.table_start ;32
     dc.w      .default-.table_start ;33
     dc.w      .default-.table_start ;34
     dc.w      .default-.table_start ;35
     dc.w      .default-.table_start ;36
     dc.w      .default-.table_start ;37
     dc.w      .default-.table_start ;38
     dc.w      .cur_fire_p-.table_start ;39
     dc.w      .default-.table_start ;3a
     dc.w      .default-.table_start ;3b
     dc.w      .default-.table_start ;3c
     dc.w      .default-.table_start ;3d
     dc.w      .default-.table_start ;3e
     dc.w      .default-.table_start ;3f
     dc.w      .default-.table_start ;40
     dc.w      .default-.table_start ;41
     dc.w      .default-.table_start ;42
     dc.w      .default-.table_start ;43
     dc.w      .default-.table_start ;44
     dc.w      .default-.table_start ;45
     dc.w      .default-.table_start ;46
     dc.w      .default-.table_start ;47
     dc.w      .cur_up_p-.table_start ;48
     dc.w      .default-.table_start ;49
     dc.w      .default-.table_start ;4a
     dc.w      .cur_left_p-.table_start ;4b
     dc.w      .default-.table_start ;4c
     dc.w      .cur_right_p-.table_start ;4d
     dc.w      .default-.table_start ;4e
     dc.w      .default-.table_start ;4f
     dc.w      .cur_down_p-.table_start ;50
     dc.w      .default-.table_start ;51
     dc.w      .default-.table_start ;52
     dc.w      .default-.table_start ;53
     dc.w      .default-.table_start ;54
     dc.w      .default-.table_start ;55
     dc.w      .default-.table_start ;56
     dc.w      .default-.table_start ;57
     dc.w      .default-.table_start ;58
     dc.w      .default-.table_start ;59
     dc.w      .default-.table_start ;5a
     dc.w      .default-.table_start ;5b
     dc.w      .default-.table_start ;5c
     dc.w      .default-.table_start ;5d
     dc.w      .default-.table_start ;5e
     dc.w      .default-.table_start ;5f
     dc.w      .default-.table_start ;60
     dc.w      .default-.table_start ;61
     dc.w      .default-.table_start ;62
     dc.w      .default-.table_start ;63
     dc.w      .default-.table_start ;64
     dc.w      .default-.table_start ;65
     dc.w      .default-.table_start ;66
     dc.w      .default-.table_start ;67
     dc.w      .default-.table_start ;68
     dc.w      .default-.table_start ;69
     dc.w      .default-.table_start ;6a
     dc.w      .default-.table_start ;6b
     dc.w      .default-.table_start ;6c
     dc.w      .default-.table_start ;6d
     dc.w      .default-.table_start ;6e
     dc.w      .default-.table_start ;6f
     dc.w      .default-.table_start ;70
     dc.w      .default-.table_start ;71
     dc.w      .default-.table_start ;72
     dc.w      .default-.table_start ;73
     dc.w      .default-.table_start ;74
     dc.w      .default-.table_start ;75
     dc.w      .default-.table_start ;76
     dc.w      .default-.table_start ;77
     dc.w      .default-.table_start ;78
     dc.w      .default-.table_start ;79
     dc.w      .default-.table_start ;7a
     dc.w      .default-.table_start ;7b
     dc.w      .default-.table_start ;7c
     dc.w      .default-.table_start ;7d
     dc.w      .default-.table_start ;7e
     dc.w      .default-.table_start ;7f
     dc.w      .default-.table_start ;80
     dc.w      .default-.table_start ;81
     dc.w      .default-.table_start ;82
     dc.w      .default-.table_start ;83
     dc.w      .default-.table_start ;84
     dc.w      .default-.table_start ;85
     dc.w      .default-.table_start ;86
     dc.w      .default-.table_start ;87
     dc.w      .default-.table_start ;88
     dc.w      .default-.table_start ;89
     dc.w      .default-.table_start ;8a
     dc.w      .default-.table_start ;8b
     dc.w      .default-.table_start ;8c
     dc.w      .default-.table_start ;8d
     dc.w      .default-.table_start ;8e
     dc.w      .default-.table_start ;8f
     dc.w      .default-.table_start ;90
     dc.w      .default-.table_start ;91
     dc.w      .default-.table_start ;92
     dc.w      .default-.table_start ;93
     dc.w      .default-.table_start ;94
     dc.w      .default-.table_start ;95
     dc.w      .default-.table_start ;96
     dc.w      .default-.table_start ;97
     dc.w      .default-.table_start ;98
     dc.w      .default-.table_start ;99
     dc.w      .default-.table_start ;9a
     dc.w      .default-.table_start ;9b
     dc.w      .default-.table_start ;9c
     dc.w      .default-.table_start ;9d
     dc.w      .default-.table_start ;9e
     dc.w      .default-.table_start ;9f
     dc.w      .default-.table_start ;a0
     dc.w      .default-.table_start ;a1
     dc.w      .default-.table_start ;a2
     dc.w      .default-.table_start ;a3
     dc.w      .default-.table_start ;a4
     dc.w      .default-.table_start ;a5
     dc.w      .default-.table_start ;a6
     dc.w      .default-.table_start ;a7
     dc.w      .default-.table_start ;a8
     dc.w      .default-.table_start ;a9
     dc.w      .default-.table_start ;aa
     dc.w      .default-.table_start ;ab
     dc.w      .default-.table_start ;ac
     dc.w      .default-.table_start ;ad
     dc.w      .default-.table_start ;ae
     dc.w      .default-.table_start ;af
     dc.w      .default-.table_start ;b0
     dc.w      .default-.table_start ;b1
     dc.w      .default-.table_start ;b2
     dc.w      .default-.table_start ;b3
     dc.w      .default-.table_start ;b4
     dc.w      .default-.table_start ;b5
     dc.w      .default-.table_start ;b6
     dc.w      .default-.table_start ;b7
     dc.w      .default-.table_start ;b8
     dc.w      .cur_fire_r-.table_start ;b9
     dc.w      .default-.table_start ;ba
     dc.w      .default-.table_start ;bb
     dc.w      .default-.table_start ;bc
     dc.w      .default-.table_start ;bd
     dc.w      .default-.table_start ;be
     dc.w      .default-.table_start ;bf
     dc.w      .default-.table_start ;c0
     dc.w      .default-.table_start ;c1
     dc.w      .default-.table_start ;c2
     dc.w      .default-.table_start ;c3
     dc.w      .default-.table_start ;c4
     dc.w      .default-.table_start ;c5
     dc.w      .default-.table_start ;c6
     dc.w      .default-.table_start ;c7
     dc.w      .cur_up_r-.table_start ;c8
     dc.w      .default-.table_start ;c9
     dc.w      .default-.table_start ;ca
     dc.w      .cur_left_r-.table_start ;cb
     dc.w      .default-.table_start ;cc
     dc.w      .cur_right_r-.table_start ;cd
     dc.w      .default-.table_start ;ce
     dc.w      .default-.table_start ;cf
     dc.w      .cur_down_r-.table_start ;d0
     dc.w      .default-.table_start ;d1
     dc.w      .default-.table_start ;d2
     dc.w      .default-.table_start ;d3
     dc.w      .default-.table_start ;d4
     dc.w      .default-.table_start ;5d
     dc.w      .default-.table_start ;d6
     dc.w      .default-.table_start ;d7
     dc.w      .default-.table_start ;d8
     dc.w      .default-.table_start ;d9
     dc.w      .default-.table_start ;da
     dc.w      .default-.table_start ;db
     dc.w      .default-.table_start ;dc
     dc.w      .default-.table_start ;dd
     dc.w      .default-.table_start ;de
     dc.w      .default-.table_start ;df
     dc.w      .default-.table_start ;e0
     dc.w      .default-.table_start ;e1
     dc.w      .default-.table_start ;e2
     dc.w      .default-.table_start ;e3
     dc.w      .default-.table_start ;e4
     dc.w      .default-.table_start ;e5
     dc.w      .default-.table_start ;e6
     dc.w      .default-.table_start ;e7
     dc.w      .default-.table_start ;e8
     dc.w      .default-.table_start ;e9
     dc.w      .default-.table_start ;ea
     dc.w      .default-.table_start ;eb
     dc.w      .default-.table_start ;ec
     dc.w      .default-.table_start ;ed
     dc.w      .default-.table_start ;ee
     dc.w      .default-.table_start ;ef
     dc.w      .default-.table_start ;f0
     dc.w      .default-.table_start ;f1
     dc.w      .default-.table_start ;f2
     dc.w      .default-.table_start ;f3
     dc.w      .default-.table_start ;f4
     dc.w      .default-.table_start ;f5
     dc.w      .default-.table_start ;f6
     dc.w      .default-.table_start ;f7
     dc.w      .default-.table_start ;f8
     dc.w      .default-.table_start ;f9
     dc.w      .default-.table_start ;fa
     dc.w      .default-.table_start ;fb
     dc.w      .default-.table_start ;fc
     dc.w      .default-.table_start ;fd
     dc.w      .new_joy0-.table_start ;fe
     dc.w      .new_joy1-.table_start ;ff

; key action code
.default:
     move.b    $fffffc02.w,last_key; store last key
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.new_joy0:
     move.l    #.get_joy0,$118.w
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.new_joy1:
     move.l    #.get_joy1,$118.w
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done

.get_joy0:
     move.b    $fffffc02.w,joy0  ; get joy0 status
     move.l    #key_interrupt,$118.w
     rte                         ; done
     
.get_joy1:
     move.b    $fffffc02.w,joy1  ; get joy1 status
     move.l    #key_interrupt,$118.w
     rte                         ; done

.cur_up_p:
     or.b      #JOY_UP,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_up_r:
     and.b     #!JOY_UP,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_left_p:
     or.b      #JOY_LEFT,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_left_r:
     and.b     #!JOY_LEFT,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_right_p:
     or.b      #JOY_RIGHT,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_right_r:
     and.b     #!JOY_RIGHT,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_down_p:
     or.b      #JOY_DOWN,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_down_r:
     and.b     #!JOY_DOWN,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_fire_p:
     or.b      #JOY_FIRE,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done
.cur_fire_r:
     and.b     #$7f,joy2
     move.l    (sp)+,d0          ; restore registers
     rte                         ; done

vbl_code:
     subq.w    #1,game+vbl_count ; decrement vbl counter
     rte                         ; done

;
; register gebruik
;
; D0 = werk
;
; A0 = game
; A1 = $ffff8800
; A2 = $ffff8802
; A3 = play data

timer_d_code:
     movem.l   d0/a0-a3,-(sp)    ; save rigisters
     move      #$2300,sr         ; enable interrupts (esp keyboard)
     move.l    #game,a0          ; game struct
     lea       $ffff8800.w,a1    ; soundchip register 1
     lea       $ffff8802.w,a2    ; soundchip register 2
     move.l    ridel(a0),d0      ; game.ridel
     bne       .play_ridel       ; play the ridel
     cmp.w     #2,music(a0)      ; chip music?
     bne.s     .play_silent      ; play silent data
     move.l    musp(a0),a3       ; music
     cmp.l     #work_space+MUS_LEN,a3 ; musp>muse?
     bcs.s     .play_music       ; nope
     lea       work_space,a3         ; start music again
.play_music:
     move.b    d0,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #0
     move.b    #1,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #1
     move.b    #2,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #2
     move.b    #3,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #3
     move.b    #4,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #4
     move.b    #5,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #5
     move.b    #6,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #6
     move.b    #7,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #7
     move.b    #8,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #8
     move.b    #9,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #9
     move.b    #10,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #10
     move.b    #11,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #11
     move.b    #12,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #12
     move.b    #13,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #13
     move.l    a3,musp(a0)       ; store musp
     movem.l   (sp)+,d0/a0-a3    ; restore rigisters
     rte
.kill_ridel:                     ; play no ridel
     moveq     #0,d0             ; clear d0
     move.l    d0,ridel(a0)      ; game.ridel=NULL
.play_silent:
     move.b    #8,(a1)           ; volume a
     move.b    d0,(a2)           ; off
     move.b    #9,(a1)           ; volume b
     move.b    d0,(a2)           ; off
     move.b    #10,(a1)          ; volume c
     move.b    d0,(a2)           ; off
     movem.l   (sp)+,d0/a0-a3    ; restore rigisters
     rte
.play_ridel:
     tst.w     music(a0)         ;
     beq.s     .kill_ridel       ; kill ridel pointer
     move.l    d0,a3             ; ridel data
     move.b    #0,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #0
     move.b    #1,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #1
     move.b    #2,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #2
     move.b    #3,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #3
     move.b    #4,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #4
     move.b    #5,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #5
     move.b    #6,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #6
     move.b    #7,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #7
     move.b    #8,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #8
     move.b    #9,(a1)           ; select register
     move.b    (a3)+,(a2)        ; write data #9
     move.b    #10,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #10
     move.b    #11,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #11
     move.b    #12,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #12
     move.b    #13,(a1)          ; select register
     move.b    (a3)+,(a2)        ; write data #13
     moveq     #14,d0            ; schuif music data op
     add.l     d0,musp(a0)       ; game.musp+=14
     cmp.l     ridelend(a0),a3   ; zijn we bij ridel end?
     bcs.s     .store_ridel      ; yep
     clr.l     a3                ; clear a3
.store_ridel:
     move.l    a3,ridel(a0)      ; store ridel
     movem.l   (sp)+,d0/a0-a3    ; restore rigisters
     rte


