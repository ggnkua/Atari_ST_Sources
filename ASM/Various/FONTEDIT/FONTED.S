*****************************************************
*     PROGRAMMERS 8x8 CHARACTER EDITOR PROGRAM.     *
*****************************************************
*      Copyright 1990 -Andrew Younger, this is      *
*                  PUBLIC DOMAIN                    *
* Spread the program about (Include source & exec!) *
*****************************************************

        section text

shrink:
        move.l  a7,a5           ; store stack in a5
        move.l  #ustk,a7        ; allocate a new stack
        move.l  4(a5),a5        ; basepage address
        move.l  $c(a5),d0       ; length of text
        add.l   $14(a5),d0      ; length of data
        add.l   $1c(a5),d0      ; length of bss
        add.l   #256,d0         ; basepage size
        move.l  d0,-(sp)        ; retained memory length
        move.l  a5,-(sp)        ; memory to modify
        move.w  d0,-(sp)        ; dummy word
        move.w  #$4a,-(sp)
        trap    #1
        add.l   #12,sp          ; call Memory shrink

        move.w  #$2f,-(sp)      ; get data pointer
        trap    #1
        addq.l  #2,sp
        move.l  d0,disk_buffer  ; and store away for later

        move.w  #0,current_char
        move.w  #3,y
        move.w  #0,x
        move.w  #80,width
        bsr     copy_char_set
        move.w  #4,-(sp)
        trap    #14             ; Get resolution
        addq.l  #2,sp
        move.w  d0,rez
        cmp.w   #1,rez
        beq     start
        cmp.w   #2,rez
        beq     rez_error
        move.w  #40,width

start:  bsr     display_screen
        bsr     display_grid
        bsr     char_counter
get:
; flash cursor and then get key press
        move.w  x,d5
        move.w  y,d6
        move.l  #filled,a1
        bsr     create_at
        move.l  #grid,a1
        bsr     create_at
        move.w  #$ff,-(sp)
        move.w  #6,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.w   d0
        beq     get     ; no keypress
        swap    d0
        move.w  d0,-(sp)
        bsr     display_grid
        move.w  (sp)+,d0
        cmp.w   #$4e,d0 ; + key
        beq     plus
        cmp.w   #$4a,d0 ; - key
        beq     minus
        cmp.w   #$01,d0 ; escape
        beq     exit
        cmp.w   #$18,d0
        beq     left
        cmp.w   #$19,d0
        beq     right
        cmp.w   #$10,d0
        beq     up
        cmp.w   #$1e,d0
        beq     down
        cmp.w   #$02,d0
        beq     on
        cmp.w   #$03,d0
        beq     off
        cmp.w   #$1f,d0
        beq     save
        cmp.w   #$26,d0
        beq     load
        cmp.w   #$11,d0
        beq     clear
        cmp.w   #$17,d0
        beq     __invert
        cmp.w   #$2d,d0
        beq     x_flip
        cmp.w   #$15,d0
        beq     y_flip
        cmp.w   #$2e,d0
        beq     copy
        cmp.w   #$04,d0
        beq     k3
        cmp.w   #$05,d0
        beq     k4
        cmp.w   #$06,d0
        beq     k5
        cmp.w   #$07,d0
        beq     k6
        cmp.w   #$13,d0
        beq     return
bell:   move.w  #7,-(sp)        ; bell
        move.w  #2,-(sp)
        trap    #1
        addq.w  #4,sp
        jmp     get
                
exit:   clr.w   -(sp)           ; exit
        trap    #1              ; bye bye


*************
* Rez error *
*************

rez_error:
        pea     wrong_rez
        move.w  #9,-(sp)
        trap    #1      ; display error
        addq.l  #6,sp

        move.w  #7,-(sp)
        trap    #1      ; wait any key
        addq.l  #2,sp

        clr.w   -(sp)
        trap    #1      ; Terminate

*****************
* Plus keypress *
*****************

plus:   cmp.w   #255,current_char
        beq     bell
        addq.w  #1,current_char
        bsr     display_grid
        jmp     get



******************
* Minus keypress *
******************

minus:  cmp.w   #0,current_char
        beq     bell
        subq.w  #1,current_char
        bsr     display_grid
        jmp     get



*****************
* Go directions *
*****************

left:
        cmp.w   #0,x
        beq     bell
        subq.w  #1,x
        jmp     get
right:
        cmp.w   #7,x
        beq     bell
        addq.w  #1,x
        jmp     get
up:
        cmp.w   #3,y
        beq     bell
        subq.w  #1,y
        jmp     get
down:
        cmp.w   #10,y
        beq     bell
        addq.w  #1,y
        jmp     get

off:
        move.l  where_char,a0
        add.w   y,a0
        sub.w   #3,a0
        move.w  #7,d0
        sub.w   x,d0
        bclr    d0,(a0)
        bsr     display_grid
        jmp     get

on:
        move.l  where_char,a0
        add.w   y,a0
        sub.w   #3,a0
        move.w  #7,d0
        sub.w   x,d0
        bset    d0,(a0)
        bsr     display_grid
        jmp     get

clear:
        move.l  where_char,a0
        move.w  #7,d7
_clear: move.b  #0,(a0)+
        dbra    d7,_clear
        bsr     display_grid
        jmp     get

__invert:
        move.l  where_char,a0
        move.w  #7,d7
_invert:
        not.b   (a0)+
        dbra    d7,_invert
        bsr     display_grid
        jmp     get

        

**************************************************
*                SELECTED LOAD                   *
**************************************************

load:
        move.l  #load_mess,-(sp)        ; point to helpful message
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp                   ; print it out

        bsr     show_directory   ; display directory
        tst.l   d0               ; any files there?
        bne     none             ; nope none!
        move.l  #buffer+13,d7
        bsr     get_input           ; Yes so ask for filename

        cmp.b   #0,buffer
        beq     zaga

;  alter input

        move.l  #buffer,a6
round:  move.b  (a6)+,d7
        cmp.b   #0,d7
        beq     nodot
        cmp.b   #46,d7
        bne     round

nodot:
        subq.l  #1,a6
        move.b  #46,(a6)+
        move.b  #102,(a6)+
        move.b  #110,(a6)+
        move.b  #116,(a6)+
        move.b  #0,(a6)

        move.w  #$0,-(sp)
        move.l  #buffer,-(sp)   ; point at filename
        move.w  #$3d,-(sp)
        trap    #1              ; open file
        addq.l  #8,sp
        tst.l   d0              ; error?
        bmi     disk_error
        move.w  d0,d7
        move.l  #font,-(sp)
        move.l  #256*8,-(sp)
        move.w  d7,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        tst.l   d0
        bmi     disk_error
        move.w  d7,-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.l   disk_error
zaga:   
        jmp     start
        
disk_error:
        move.l  #disk_error_mess,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp   ; display it
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp   ; wait for any key
        jmp     start

none:
        move.l  #error_no_files,-(sp)   ; point to mess
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp                   ; display it
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp                   ; wait for any key
        jmp     start                   ; return to menu

       

**************************************************
*                SELECTED SAVE                   *
**************************************************

save:
        move.l  #save_mess,-(sp)        ; point to helpful message
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp                   ; display it

        bsr     show_directory          ; display directory
        move.l  #buffer+13,d7           ; max
        bsr     get_input               ; ask for filename

        cmp.b   #0,buffer
        beq     zaga


;  alter input

        move.l    #buffer,a6
_round:
        move.b  (a6)+,d7
        cmp.b   #0,d7
        beq     _nodot
        cmp.b   #46,d7
        bne     _round

_nodot:
        subq.l  #1,a6
        move.b  #46,(a6)+
        move.b  #102,(a6)+
        move.b  #110,(a6)+
        move.b  #116,(a6)+
        move.b  #0,(a6)

        move.w  #$0,-(sp)
        move.l  #buffer,-(sp)    ; point at filename
        move.w  #$3c,-(sp)
        trap    #1
        addq.l  #8,sp
        tst.l   d0                  ; error?
        bmi     disk_error
        move.w  d0,d7
        move.l  #font,-(sp)
        move.l  #256*8,-(sp)
        move.w  d7,-(sp)
        move.w  #$40,-(sp)
        trap    #1
        add.l   #12,sp
        tst.l   d0
        bmi     disk_error
        move.w  d7,-(sp)
        move.w  #$3e,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.l   disk_error
        jmp     start



**************************************************
*      SHOW CURRENT DIRECTORY - LIST FILES       *
**************************************************

show_directory:
        move.w  #0,-(sp)                ; all read/write files
        move.l  #filename,-(sp)         ; search for all files
        move.w  #$4e,-(sp)
        trap    #1
        addq.l  #8,sp
        tst.l   d0                      ; ?
        bne     no_files                ; no
        move.w  #4,d6                   ; 4 down
        move.w  #0,d7                   ; 0 across
        bsr     display_info            ; print out filename
next_file:
        move.w  #$4f,-(sp)
        trap    #1
        addq.l  #2,sp                   ; are there more files
        tst.l   d0                      ; ?
        bne     finish                  ; No
        add.w   #14,d7  ; increase pointer
        cmp.w   width,d7 ; is it at maximum
        blt     displ   ; no so display it
        add.w   #1,d6   ; yes so increase down coord
        cmp.w   #23,d6  ; Am I at bottom ?
        beq     finish
        clr.w   d7      ; reset x coord
displ:
        bsr     display_info    ; print out filename
        jmp     next_file       ; carry on until all files found

finish:
        move.l  #0,d0
        rts
no_files:
        move.l  #1,d0       ; I found no files!
        rts


display_info:
        move.b  d6,print_at+2
        add.b   #32,print_at+2
        move.b  d7,print_at+3
        add.b   #32,print_at+3
        move.l  #print_at,-(sp) ; point to print at string
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp           ; display it


        move.l  disk_buffer,a6  ; point to buffer
        add.l   #30,a6          ; get to filename in buffer
        move.l  a6,-(sp)        ; pointer for print out
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp           ; display it
        rts


get_input:
        move.b  #56,print_at+2  ; move to 24 down
        move.b  #32,print_at+3  ; 0 across
        move.l  #print_at,-(sp) ; point to print_at string
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp           ; display it
        move.l  #buffer,a6      ; point to buffer
curse:
        move.l  #cursor_txt,-(sp)       ; point to cursor
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp                   ; display it
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp                   ; get key
        cmp.w   #13,d0                  ; return pressed
        beq     return_press            ; Yes
        cmp.w   #8,d0                   ; backspace pressed
        beq     backspace_press         ; Yes
        cmp.w   #33,d0
        blt     curse
        cmp.w   #127,d0
        bgt     curse
        cmp.l   d7,a6
        beq     curse
        move.b  d0,(a6)+
        move.w  d0,-(sp)
        move.w  #2,-(sp)
        trap    #1
        addq.l  #4,sp
        jmp     curse

return_press:
        move.w  #32,-(sp)
        move.w  #2,-(sp)
        trap    #1
        addq.l  #4,sp
        move.b  #0,(a6)
        rts

backspace_press:
        cmp.l   #buffer,a6
        beq     curse
        move.l  #backspace_txt,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        subq.l  #1,a6
        jmp     curse



****************************************
* Copy the system char set into memory *
****************************************


copy_char_set:
        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,screen

        move.l  #cls,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        
        move.l  #font,a5
        move.l  #font2,a4
        move.w  #0,d7
loop:   
        move.l  #display,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        move.w  d7,-(sp)
        move.w  #5,-(sp)
        move.w  #3,-(sp)
        trap    #13
        addq.l  #6,sp

        move.l  screen,a6
        move.w  #7,d0
loop2:  move.b  (a6),(a5)+
        move.b  (a6),(a4)+
        add.l   #160,a6
        dbra    d0,loop2
        move.l  screen,a6
        addq.l  #1,d7
        cmp.l   #256,d7
        bne     loop
        rts



********************************************************
*      HANDLE CREATE AT ROUTINES: LOW AND MEDIUM       *
********************************************************

create_at:
        cmp.w   #0,rez
        beq     create_at_low

********************************************************
*       MEDIUM CREATE AT - FAST GRAPHIC ROUTINE        *
********************************************************

create_at_med:
        move.w  d6,d0           ; copy Y coordinate to d0
        mulu.w  #1280,d0        ; move down to correct screen row
        lea.l   y_offmed,a4     ; get pointer to correct space in table
        add.b   0(a4,d5),d0     ; got correct screen offset now
        move.l  screen,a3
        add.l   d0,a3           ; got correct screen position
        move.l  #1,d0           ; all planes
write:
        move.b  0(a1),0(a3)     ; fill correct plane of character
        move.b  1(a1),160(a3)   ; fill correct plane of character
        move.b  2(a1),320(a3)   ; fill correct plane of character
        move.b  3(a1),480(a3)   ; fill correct plane of character
        move.b  4(a1),640(a3)   ; fill correct plane of character
        move.b  5(a1),800(a3)   ; fill correct plane of character
        move.b  6(a1),960(a3)   ; fill correct plane of character
        move.b  7(a1),1120(a3)  ; fill correct plane of character
        addq.l  #2,a3
        dbra    d0,write
        rts                     ; end the routine


********************************************************
*       LOW REZ CREATE AT -FAST GRAPHIC ROUTINE        *
********************************************************

create_at_low:
        move.w  d6,d0           ; copy Y coordinate to d0
        mulu.w  #1280,d0        ; move down to correct screen row
        lea.l   y_offlow,a4     ; get pointer to correct space in table
        add.b   0(a4,d5),d0     ; got correct screen offset now
        move.l  screen,a3
        add.l   d0,a3           ; got correct screen position
        move.l  #3,d0           ; all planes
write2:
        move.b  0(a1),0(a3)     ; fill correct plane of character
        move.b  1(a1),160(a3)   ; fill correct plane of character
        move.b  2(a1),320(a3)   ; fill correct plane of character
        move.b  3(a1),480(a3)   ; fill correct plane of character
        move.b  4(a1),640(a3)   ; fill correct plane of character
        move.b  5(a1),800(a3)   ; fill correct plane of character
        move.b  6(a1),960(a3)   ; fill correct plane of character
        move.b  7(a1),1120(a3)  ; fill correct plane of character
        addq.l  #2,a3
        dbra    d0,write2
        rts                     ; end the routine



****************************
*  Display editing screen  *
****************************

display_screen:
        move.l  #the_screen,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

;       display char set and border around char set

display_chars:
        move.w  #18,d6  ; down
        move.w  #0,d5   ; across
        move.l  #font,a1 ; point to font set
        move.w  #255,d7 ; character counter
_display_loop:
        bsr     create_at ; display char
        addq.w  #8,a1
        addq.w  #1,d5
        cmp.w   width,d5
        beq     reset_x
here:   dbra    d7,_display_loop
        rts
reset_x:
        addq.l  #1,d6
        move.w  #0,d5
        jmp     here
        


********************************
* Draw enlarged character grid *
********************************

display_grid:
; get area of memory
        move.w  current_char,d0
        mulu.w  #8,d0
        add.l   #font,d0
        move.l  d0,a0   ; pointer to character
        move.l  d0,where_char ; store for later

; position x & y
        move.w  #3,d6 ; up
        move.w  #0,d5 ; along
disp:   move.w  #7,d7 ; bit number
        move.b  (a0)+,d1
disp2:  btst    d7,d1
        beq     empty
full:   move.l  #filled,a1
here2:  bsr     create_at
        addq.w  #1,d5
        dbra    d7,disp2
        move.w  #0,d5
        addq.w  #1,d6
        cmp.w   #11,d6
        bne     disp

; display inverted char moveable counter
char_counter:
        move.l  where_char,a1
        bsr     invert
        bsr     display_chars
        move.l  where_char,a1
        bsr     invert
        rts
invert: move.l  #7,d0
_inv:   not.b   (a1)+
        dbra    d0,_inv
        rts
empty:  move.l  #grid,a1
        jmp     here2

******************
* Flip character *
******************

y_flip:
        move.l  where_char,a0
        move.l  a0,a1
        addq.l  #8,a1
        move.w  #3,d0
_y_flip:
        move.b  (a0),d1
        move.b  -(a1),(a0)+
        move.b  d1,(a1)
        dbra    d0,_y_flip
        bsr     display_grid
        jmp     get


x_flip:
        move.l  where_char,a0
        move.w  #7,d0
xfp1:   move.b  (a0),d7
        clr.l   d6
        move.w  #7,d5
        move.w  #0,d4
xfp2:   btst    d5,d7
        bne     set
        bclr    d4,d6
here3:  addq.l  #1,d4
        dbra    d5,xfp2
        move.b  d6,(a0)+
        dbra    d0,xfp1
        bsr     display_grid
        jmp     get
set:    bset    d4,d6
        jmp     here3



********
* Copy *
********

copy:   
        move.l  #copy_mess,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  where_char,where_char2
getkey: move.w  #$ff,-(sp)
        move.w  #6,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.w   d0
        beq     getkey  ; no keypress
        swap    d0
        cmp.w   #$4e,d0 ; + key
        beq     __plus
        cmp.w   #$4a,d0 ; - key
        beq     __minus
        cmp.w   #$1c,d0 ; return
        beq     __return
bleepy: move.w  #7,-(sp)
        move.w  #2,-(sp)
        trap    #1
        addq.l  #4,sp
        jmp     getkey

__return:
        move.l  where_char,a0
        move.l  where_char2,a1
        move.w  #7,d0
__loop: move.b (a1)+,(a0)+
        dbra d0,__loop
        jmp     start

*****************
* Plus keypress *
*****************

__plus: cmp.w   #255,current_char
        beq     bleepy
        addq.w  #1,current_char
        bsr     display_grid
        jmp     getkey



******************
* Minus keypress *
******************

__minus:
        cmp.w   #0,current_char
        beq     bleepy
        subq.w  #1,current_char
        bsr     display_grid
        jmp     getkey

******************
* Wrap character *
******************

k3:     move.l  where_char,a0
        move.b  (a0),d0
        move.b  1(a0),(a0)
        move.b  2(a0),1(a0)
        move.b  3(a0),2(a0)
        move.b  4(a0),3(a0)
        move.b  5(a0),4(a0)
        move.b  6(a0),5(a0)
        move.b  7(a0),6(a0)
        move.b  d0,7(a0)
        bsr     display_grid
        jmp     get
k4:     move.l  where_char,a0
        move.b  7(a0),d0
        move.b  6(a0),7(a0)
        move.b  5(a0),6(a0)
        move.b  4(a0),5(a0)
        move.b  3(a0),4(a0)
        move.b  2(a0),3(a0)
        move.b  1(a0),2(a0)
        move.b  0(a0),1(a0)
        move.b  d0,0(a0)
        bsr     display_grid
        jmp     get

k5:     move.l  where_char,a0
        move.l  #7,d1
loop_2: move.b  (a0),d0
        lsl.b   #1,d0
        bcc     next2
        or.b    #1,d0
next2:  move.b  d0,(a0)+
        dbra    d1,loop_2
        bsr     display_grid
        jmp     get

k6:     move.l  where_char,a0
        move.l  #7,d1
loop_1: move.b  (a0),d0
        lsr.b   #1,d0
        bcc     next
        or.b    #128,d0
next:   move.b  d0,(a0)+
        dbra    d1,loop_1
        bsr     display_grid
        jmp     get

return: move.l  #2047,d0
        move.l  #font,a4
        move.l  #font2,a5
lopy:   move.b  (a5)+,(a4)+
        dbra    d0,lopy
        bsr     display_grid
        jmp     get


        section data

        even
copy_mess:
        dc.b 27,"Y",32+15,32
        dc.b "Copy character where? Use [+],[-] to",10,13
        dc.b "move and return to copy",0

x_offset        equ     10

the_screen:
        dc.b 27,"f",27,"EThe 8x8 Char Editor V 1.0"
        dc.b 10,13,"Copyright 1990 Andrew Younger"
        dc.b 27,"Y",32+3,32+x_offset
        dc.b "[Q][A][O][P] to around grid."
        dc.b 27,"Y",32+4,32+x_offset
        dc.b "[1][2] - on/off bit"
        dc.b 27,"Y",32+5,32+x_offset
        dc.b "[+][-] to incr\decr char."
        dc.b 27,"Y",32+6,32+x_offset
        dc.b "[S][L] Save & Load"
        dc.b 27,"Y",32+7,32+x_offset
        dc.b "[I] - invert"
        dc.b 27,"Y",32+8,32+x_offset
        dc.b "[W] - wipe char"
        dc.b 27,"Y",32+9,32+x_offset
        dc.b "[X][Y] flip char"
        dc.b 27,"Y",32+10,32+x_offset
        dc.b "[C] to copy"
        dc.b 27,"Y",32+11,32+x_offset
        dc.b "[3][4][5][6] wrap char."
        dc.b 27,"Y",32+12,32+x_offset
        dc.b "[R] - return sys char set."
        dc.b 27,"Y",32+13,32+x_offset
        dc.b "[Esc] to exit...",0
        even
y_offmed:
        dc.b    0,1,4,5,8,9,12,13,16,17,20,21,24,25,28,29,32,33,36,37,40,41
        dc.b    44,45,48,49,52,53,56,57,60,61,64,65,68,69,72,73,76,77
        dc.b    80,81,84,85,88,89,92,93,96,97,100,101,104,105,108,109,112
        dc.b    113,116,117,120,121,124,125,128,129,132,133,136,137,140
        dc.b    141,144,145,148,149,152,153,156,157,160
        even
y_offlow:
        dc.b    0,1,8,9,16,17,24,25,32,33
        dc.b    40,41,48,49,56,57,64,65,72,73
        dc.b    80,81,88,89,96,97,104,105,112,113
        dc.b    120,121,128,129,136,137,144,145,152,153

cls:    dc.b    27,"E     Please wait.....",0
        even

grid:   dc.b    255,129,129,129,129,129,129,255
filled: dc.b    255,255,255,255,255,255,255,255

error_no_files:
        dc.b    10,13,10,13
        dc.b    7,"I can find no fonts here!",10,13,10,13
        dc.b    "Press any key to go back to the menu.",0
        even

disk_error_mess:
        dc.b    10,13,10,13
        dc.b    7,"Error!! "
        dc.b    10,13,10,13,"Press any key...",0
load_mess:
        dc.b 27,"E"
        dc.b "Select the file to be loaded!"
        dc.b 13,10,0

        even

save_mess:
        dc.b 27,"E"
        dc.b "Select the file to be created!"
        dc.b 13,10,0

        even

cursor_txt:
        dc.b 27,"p ",27,"q",27,"D",0

        even

backspace_txt:
        dc.b 27,"D","  ",27,"D",27,"D",0

        even

print_at:
        dc.b 27,"Y00",0

        even

filename:
        dc.b "*.fnt",0

        even

display:
        dc.b    27,"H",0

        even
wrong_rez:
        dc.b    27,"E",7
        dc.b    "This program can only be run on colour monitors!!!",10,13,0

        section bss

where_char2:
        ds.l    1
disk_buffer:
        ds.l    1
font:   ds.b    256*8
font2:  ds.b    256*8

screen: ds.l    1
y:      ds.w    1
x:      ds.w    1
where_char:
        ds.l    1
current_char:
        ds.w    1
buffer:
        ds.b    20

rez:    ds.w    1
width:  ds.w    1

        ds.l    255
ustk:   ds.l    1
