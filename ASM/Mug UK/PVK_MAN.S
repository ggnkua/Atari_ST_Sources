*
buffer_size     EQU     80000  ;Size of largest UNcompressed text file
pic_buff_size   EQU     20000   ;Size of largest TNY file
cmp_size        EQU     80000   ;Size of largest COMPRESSED text file
lines_per_page  EQU     54      ;Lines printed on paper.
max_pages       EQU     99      ;No of SCREEN pages in biggest text file
*
ESCAPE  EQU     $0001
UNDO    EQU     $0061           ;Undo scan code
F1      EQU     $003B           ;F1 scan code
F2      EQU     $003C
F3      EQU     $003D
F4      EQU     $003E
F9      EQU     $0043           ;F9 scan code
F10     EQU     $0044           ;F10 scan code.
UP      EQU     $0048           ;Up arrow
DOWN    EQU     $0050           ;Down arrow
HELP    EQU     $0062           ;Help
*
        SECTION TEXT
*=======================================
        BRA     start
*

head1   DC.B    27,'Y',32+0,32+1
        DC.B    '    Professional Virus Killer v2.0 (c)1991, Floppyshop & Mike Mee',0        
dsp_page
        DC.B    27,'Y',32+0,32+72
        DC.B    'Page '
digit1  DC.B    0
digit2  DC.B    0
        DC.B    0
        EVEN
find_txt        DC.B    27,'Y',32+24,32+0,27,'e'
                DC.B    'Input String to Search :',0
curs_off        DC.B    27,'f',0
clr_line        DC.B    27,'Y',32+24,32+0
                DC.B    '                                        '
                DC.B    '                                       ',0
notfound        DC.B    27,'Y',32+24,32+0
                DC.B    'String not Found before End of File',0
        EVEN
reset_txt
        DC.B    27,'Y',32+24,32+0
        DC.B    'Top of Page has been Reset - Set your printer to Top of Page                  ',0
        EVEN
prt_txt
        DC.B    27,'Y',32+24,32+0
        DC.B    ' PRINTING - PLEASE WAIT .............................. PRINTING - PLEASE WAIT',0
        EVEN

help_txt
        DC.B    27,'Y',32+24,32+0
        DC.B    'F1-Find F2-Next F3-Find/Print F9-Print Page F10-Print All T-Top B-Bottom      ',0
        EVEN
print_headings  DC.B    'Professional Virus Killer v2.0 (c)1991, Floppyshop & Mike Mee',13,0
        EVEN

msg_frst
        DC.B    27,'Y',32+24,32+0,0
msg_cnt DC.B    0
no_of_messages  EQU     9
msg_txt DC.L    msg_1,msg_2,msg_3,msg_4,msg_1,msg_3,msg_4,msg_1,msg_3
msg_1   DC.B    '   Display Program by Marc Young, 84 Hopgarden Rd, Tonbridge, Kent  TN10 4QU   ',0
msg_2   DC.B    '      PVK is the followup to the Public Domain program, Super Virus Killer     ',0
msg_3   DC.B    '    Why not get your PD software from Floppyshop?  We have over 2200 disks     ',0
msg_4   DC.B    '       Same day despatch on PD orders.  All PD disks are only œ2.75 each       ',0
        EVEN

start
        OPT     O+,OW-          *Optimise, but no warnings.
go      MOVE.L  A7,A5           *Save stack pointer
        MOVE.L  4(A5),A5                *and get basepage address.
        MOVE.L  12(A5),D0
        ADD.L   20(A5),D0
        ADD.L   28(A5),D0
        ADD.L   #$100,D0                ;Add basepage size
        ADD.L   #$100,D0                *Add sufficient space for my stack.
        LEA     stack,A7                *Need my own stack
*
        MOVE.L  D0,-(SP)                * Tell O/S we need
        MOVE.L  A5,-(SP)                *this much memory please
        CLR.W   -(SP)
        MOVE.W  #$4A,-(SP)
        TRAP    #1
        LEA     12(SP),SP
*
        BSR     startup         ;Initialize everything.
*
        BSR     main            ;Do the program
*
.quit   BSR     closedown
*

        CLR.W   -(SP)           *Terminate program.
        MOVE.W  #$4C,-(SP)
        TRAP    #1
**************************************************************
**              Initialize the program.         **
**************************************************************
startup 
*
*

        DC.W    $A00A           ;Hide the mouse

        LEA     click(PC),A0
        MOVE.L  #$A00064,(A0)
        MOVE.W  #34,-(SP)
        TRAP    #14
        ADDQ.L  #2,SP   ;D0 contains address of IKBD routine addresses
        MOVE.L  D0,A0   ;Save it
        MOVE.L  16(A0),old_mouse
        LEA     our_mouse(PC),A1
        MOVE.L  A1,16(A0)
*
        MOVE.W  #4,-(SP)                ;Get old screen rez
        TRAP    #14
        ADDQ.L  #2,SP
        MOVE.W  D0,old_rez      ;For recall on exit.
*
        CMP.W   #2,D0
        BNE     .med
        MOVE.L  #80,l_bytes_p_line
        BRA     .ok
.med
        MOVE.L  #160,l_bytes_p_line
        MOVE.W  #1,-(SP)
        MOVE.L  #-1,-(SP)
        MOVE.L  #-1,-(SP)
        MOVE.W  #5,-(SP)
        TRAP    #14
        LEA     12(SP),SP
*
.ok     MOVE.W  #3,-(SP)        *Find screen address
        TRAP    #14
        ADDQ.L  #2,SP

        MOVE.L  D0,screen1      *Store as screen 1 (master)
        SUB.L   #32000,D0       *Calc screen2
        MOVE.L  D0,screen2      *And store it
*
        DC.W    $A000           ;Get A-line addresses.
        MOVE.L  -46+24(A0),sys_font     ;Store system font address.
*
        MOVE.L  #supercode,-(SP)
        MOVE.W  #38,-(SP)
        TRAP    #14
        ADDQ.L  #6,SP

*
.exit   RTS
**************************************************************
**              Close down the program          **
**************************************************************
*
closedown
        DC.W    $A009           #A Line show mouse.
*
*
* Reset mouse vector
        MOVE.W  #34,-(SP)       
        TRAP    #14
        ADDQ.L  #2,SP
        MOVE.L  D0,A0
        MOVE.L  old_mouse,16(A0)
*
        MOVE.W  old_rez,-(SP)   ;Reset screen to correct address.
        MOVE.L  screen1,-(SP)
        MOVE.L  screen1,-(SP)
        MOVE.W  #5,-(SP)
        TRAP    #14
        ADD.L   #12,SP
*
        PEA     old_palette     ;Reset palette
        MOVE.W  #6,-(SP)
        TRAP    #14
        ADDQ.L  #6,Sp
*
        RTS
*****************************************
*        The program proper             *
*****************************************
main    
*
*
main_loop
        LEA     text_buff,A0
        BSR     display
*
end     RTS
******************************
supercode
        AND.B   #%11111101,$484
        movem.l	$ff8240,d0-d7
        movem.l	d0-d7,old_palette
        RTS

palette_off
        PEA     zero_palette
        MOVE.W  #6,-(SP)
        TRAP    #14
        ADDQ.L  #6,SP
        RTS
****************************************
cls     *Clears the current text screen.
        MOVEM.L A0/A6/D0-D7,-(SP)
        MOVE.L  screen1,A0
        MOVE.L  #999,D0
        CLR.L   D1
        MOVE.L  D1,D2
        MOVE.L  D1,D3
        MOVE.L  D1,D4
        MOVE.L  D1,D5
        MOVE.L  D1,D6
        MOVE.L  D1,D7
        MOVE.L  D1,A6

.loop   MOVEM.L D1-D7/A6,(A0)
        ADD.L   #32,A0
        DBF     D0,.loop
*
* Print Headings
        PEA     head1
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
*
        MOVE.W  page_no,D0
        ADD.W   #1,D0
        MOVE.W  D0,D1
        DIVU    #10,D1
        MOVE.W  D1,D2
        MULU    #10,D2
        SUB.W   D2,D0
        ADD.B   #'0',D0
        ADD.B   #'0',D1
        MOVE.B  D1,digit1
        MOVe.B  D0,digit2
*
        PEA     dsp_page
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
*

        MOVEM.L (SP)+,A0/A6/D0-D7
        RTS
*
***************************************
wait_key
        BSR     get_key
        TST.L   D0
        BEQ.S   wait_key
        RTS
****************************************
get_key 
        MOVE.W  #$B,-(SP)               ;Has a key been pressed?
        TRAP    #1
        ADDQ.L  #2,SP
        TST.W   D0
        BNE.S   .ok
        CLR.L   D1
        BRA.S   .exit

.ok     MOVE.W  #7,-(SP)                ;Get the key
        TRAP    #1
        ADDQ.L  #2,SP
        MOVE.L  D0,D1
        SWAP    D1      ;D1.W contains f-Keys etc. D0.W has Ascii
*
.exit   RTS
******************************************
vblank  MOVE.W  #37,-(SP)       * Wait for vblank 
        TRAP    #14
        ADDQ.L  #2,SP
        RTS

****************************************
********************************************
*===============================================================*
* Display routines (including printing to printer).         *
*===============================================================*
*
                
find_buff       DS.B    25
        EVEN
pr_dsp_ind      DC.W    0       ;0=print -1=display
find    PEA     clr_line
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP

        PEA     find_txt
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
*
        MOVE.B  #20,find_buff
        pea     find_buff
        move.W  #$A,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
*
        PEA     curs_off
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
*

*
        CMP.B   #0,find_buff+1
        BEQ.S   fexit
*
        MOVE.W  page_no,search_page
findnxt LEA     page_addr,A2    ;Address of table containing pointers to start of each page
        MOVE.W  search_page,D1  ;Current page number.
        ASL.W   #2,D1           ;*4 to give address offset.
        MOVE.L  (A2,D1.W),A6    ;Store this top of page pointer.
        CMP.L   #0,A6
        BEQ     fexit
        CLR.W   eop             ;Clear End of Page indicator.
        MOVE.L  #0,D6   ;Store pointer.


        BSR     findit
*
fexit   RTS
***********************************************************
findit  ;Find text in find_buff from (A6,D6) to end of text
        CLR.W   D5      ;D5 = Found indicator
        LEA     find_buff,A0
        ADD.L   #1,A0
        CLR.W   D0
        MOVE.B  (A0)+,D0        ;Length of string in D0
loop    MOVE.B  (A6,D6.L),D1    ;Char in D1
        TST.B   D1
        BEQ     eof
        CMP.B   #1,D1
        BEQ     topopage
        CMP.B   #13,D1
        BEQ     cont
        CMP.B   #10,D1
        BEQ     cont
        AND.B   #%11011111,D1
        BRA     ok1
topopage
; Found top of page - do what's necessary
        TST.W   D5      ;Found any yet?
        BNE     showem  ;Yes - highlight them 
        ADD.W   #1,search_page
        BRA     cont
eof     TST.W   D5      ;Found any yet?
        BEQ     endf    ;No - exit 
showem  MOVE.W  search_page,page_no
        SUB.W   #1,page_no
        TST.W   pr_dsp_ind
        BEQ     prt_it
        BSR     cls
        BSR     disp_page
        BSR     unset_page      ;Unset hi bits!
        BRA     endf
prt_it  BSR     unset_page
        BSR     print_page
        BRA     findnxt
ok1     MOVE.B  (A0),D7
        AND.B   #%11011111,D7
        CMP.B   D7,D1
        BNE     cont
; First char matches!
        MOVE.L  A6,A5
        ADD.L   D6,A5
        MOVE.L  A0,A1
        MOVE.W  D0,D1
        SUB.W   #1,D1
loop1   MOVE.B  (A1)+,D2
        MOVE.B  (A5)+,D3
        AND.B   #%11011111,D2
        AND.B   #%11011111,D3
        CMP.B   D2,D3
        BNE.S   cont
        DBF     D1,loop1
; FOUND!!!!!!
        BRA     found
cont    ADD.L   #1,D6
        BRA     loop
found
        BCLR    #7,D4
        MOVE.W  D0,D1
        SUB.W   #1,D1
foundl
        OR.B    #%10000000,(A6,D6.L)
        ADD.L   #1,D6
        Dbra    D1,foundl
        ADD.W   #1,D5   ;Found indicator
        BRA     cont
endf    TST.W   D5
        BNE     endf1

        PEA     clr_line
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP

        PEA     notfound
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        BRA     endfind
endf1   PEA     clr_line
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
endfind RTS
**************************************
unset_page      ;unset all hi bits on current page
        LEA     page_addr,A2    ;Address of table containing pointers to start of each page
        MOVE.W  page_no,D1      ;Current page number.
        ASL.W   #2,D1           ;*4 to give address offset.
        MOVE.L  (A2,D1.W),A6    ;Store this top of page pointer.
        MOVE.L  #0,D6   ;Store pointer. 
        MOVE.W  #1,D2   ;Need to find two 'top of page' or one and 'end of text'
.loop   
        MOVE.B  (A6,D6.L),D0    ;Byte in D0
        CMP.B   #'œ',D0
        BEQ     .pound
        AND.B   #%01111111,D0
        MOVE.B  D0,(A6,D6.L)
.pound  ADD.L   #1,D6
        TST.B   D0
        BEQ     .end
        CMP.B   #1,D0
        BNE.S   .loop
        DBF     D2,.loop
.end    RTS
*
***************************************
** Display the text pointed at by A0 **
***************************************
display 
*
        LEA     text_buff,A6    ;Address of text
        LEA     page_addr,A2    ;Address of table containing pointers to start of each page
        MOVE.L  #0,D6           ;Current position in text.
        MOVE.W  #0,D1           ;Current page number.
*
        MOVE.W  #-1,last_page
.buildl MOVE.B  (A6,D6.L),D7    ;Next byte
        TST.B   D7
        BEQ.S   .cont
        CMP.B   #1,D7
        BEQ.S   .newpage
.nextch ADD.L   #1,D6
        BRA.S   .buildl
.newpage
        MOVE.W  D1,D2
        ADD.W   #1,D1
*
        ASL.W   #2,D2           ;*4 to give address offset.
        MOVE.L  A6,(A2,D2.W)    ;Store this top of page pointer.
        ADD.L   D6,(A2,D2.W)
        ADD.W   #1,last_page
        BRA     .nextch

*
.cont   ASL.W   #2,D1           ;Last Page
        MOVE.L  #0,(A2,D1.W)    ;Set to ZERO
        MOVE.B  #0,disp_style   ;Re-set style indicator.
*
dsp     MOVE.W  #0,eot          ;End of text marker = 0
        MOVE.L  #0,textptr      ;Text pointer = 0
        MOVE.W  #0,page_no      ;Page number = 0
dsp_loop
        BSR     cls
        BSR     disp_page       ;display one page
*

*
key     MOVE.W  #17,-(SP)
        TRAP    #14
        ADDQ.L  #2,SP
        CMP.W   #2,D0
        BCC     .cont
        BSR     msg_dsp
.cont
        BSR     get_key
        TST.L   D0
        BNE     .keyp
        TST.L   D1
        BNE     .keyp
        BRA     .mouse
*
.keyp
        CMP.W   #ESCAPE,D1      ;Esc. hit?
        BEQ     done
        CMP.W   #UNDO,D1        ;Undo?
        BEQ     done
*
        CMP.W   #UP,D1  ;Up arrow?
        BEQ     .back
*
        CMP.W   #DOWN,D1        ;Down arrow
        BEQ     forward
*
        CMP.W   #F1,D1          ;F1?
        BNE.S   .cont1
        MOVE.W  #-1,pr_dsp_ind
        BSR     find
        BRA     key
.cont1
        CMP.W   #F2,D1          ;F2?
        BNE.S   .cont2
        MOVE.W  page_no,search_page
        ADD.W   #1,search_page
        BSR     findnxt
        BRA     key
.cont2
        CMP.W   #HELP,D1
        BEQ     .help
        CMP.W   #'T',D0
        BEQ     .top
        CMP.W   #'t',D0
        BEQ     .top
        CMP.W   #'B',D0
        BEQ     .bottom
        CMP.W   #'b',D0
        BEQ     .bottom
        BRA     .cont3
.top
        MOVE.W  #0,page_no
        MOVE.W  #0,eot
        BRA     dsp_loop
.bottom
        MOVE.W  last_page,page_no
        MOVE.W  #-1,eot
        BRA     dsp_loop
.help   PEA     help_txt
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        BRA     key
.cont3
        CMP.W   #'?',D0
        BNE     .cont4
        BSR     msg_dsp
.cont4
        CMP.W   #F3,D1
        BNE     .cont5
* Print/Find
        CLR.W   pr_dsp_ind
        BSR     find
        BRA     key
.cont5
        CMP.W   #F10,D1
        BNE     .cont6
* Print whole document
        MOVE.W  #99,print_line
        MOVE.W  page_no,-(SP)
        MOVE.W  #0,page_no
.okpr   BSR     print_page
        ADD.W   #1,page_no
        MOVE.W  page_no,D0
        CMP.W   last_page,D0
        BLE     .okpr
        MOVE.W  (SP)+,page_no
        BRA     key
.cont6
        CMP.W   #F9,D1
        BNE     .cont7
* Print current page
        BSR     print_page
        BRA     key
.cont7
        CMP.W   #F4,D1
        BNE     .cont8
* Re-set top of page
        MOVE.W  #0,print_line
        PEA     reset_txt
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        BRA     key
.cont8
.mouse
        BTST.B  #1,click
        BEQ.S   .ok1
        BTST.B  #0,click
        BNE.S   done
        BRA.S   .back
.ok1
        BTST.B  #0,click
        BNE.S   forward 
        BRA     key
.back   TST.W   page_no
        BEQ     key
        SUB.W   #1,page_no
        CLR.W   eot
        BRA     dsp_loop
forward
        TST.W   eot
        BMI     key
        ADD.W   #1,page_no
        BRA     dsp_loop
        
done    MOVE.L  #-1,D0
        RTS
**************************************************
msg_dsp PEA     msg_frst
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
*
*       MOVE.W  #17,-(SP)
*       TRAP    #14
*       ADDQ.L  #2,SP
        MOVE.B  msg_cnt,D0
        ADD.B   #1,msg_cnt
        AND.L   #$FF,D0
.tbl    CMP.W   #no_of_messages,D0
        BCS     .ok
        MOVE.B  #0,D0
        MOVE.B  #0,msg_cnt
.ok     LSL.W   #2,D0

        LEA     msg_txt,A0
        MOVE.L  (A0,D0.W),A0
        MOVE.L  A0,-(SP)
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        RTS
*********************************************
disp_page
        MOVE.L  sys_font,D4     ;Set system font
        MOVE.L  D4,disp_font
        MOVE.W  #0,mode_ind

        MOVE.W  #0,ch_x         ;Start pos of text.
        MOVE.W  #17,ch_y
        CMP.W   #2,old_rez
        BEQ     .ok
        MOVE.W  #9,ch_y
*
.ok     LEA     page_addr,A2    ;Address of table containing pointers to start of each page
        MOVE.W  page_no,D1      ;Current page number.
        ASL.W   #2,D1           ;*4 to give address offset.
        MOVE.L  (A2,D1.W),A6    ;Store this top of page pointer.
        CLR.W   eop             ;Clear End of Page indicator.
        MOVE.L  #0,D6   ;Store pointer.
.lp     BSR.S   disp_line       ;Print one line.
        TST.W   eop             ;Loop until all lines done.
        BEQ.S   .lp
.end    MOVE.L  screen1,A0
*
        ADD.L   #8*160,A0
        MOVE.W  #39,D0
.lpe    EOR.L   #%11111111111111111111111111111111,(A0)+
        DBF     D0,.lpe

        MOVE.L  screen1,A0
*
        ADD.L   #191*160,A0
        MOVE.W  #39,D0
.lpa    EOR.L   #%11111111111111111111111111111111,(A0)+
        DBF     D0,.lpa

        RTS
**************************************************
disp_line       ;display a line of data
*
        CLR.W   D4
        MOVE.B  (A6,D6.L),D4    ;Char in D4.

        CMP.B   #$20,D4         ;char >= 32 ?
        BCC     print_ch                ;Yes -print it.
*
* Must be a control char of some description...
*
not_space       
        LEA     disp_addr(PC),A3        ;Addresses of routines
        LSL.W   #2,D4           ;Char=char*4 (Long addresses).
        MOVE.L  (A3,D4.W),A3    ;Address of routine in A3
        JMP     (A3)            ;Go to it!
******
disp_addr
        DC.L    d_end,rez_ch,d_ignore,d_ignore
        DC.L    d_ignore,d_ignore,d_ignore,d_ignore
        DC.L    d_ignore,d_ignore,d_ignore,d_ignore
        DC.L    d_ignore,d_newline,d_pound,d_ignore
        DC.L    d_font_0,d_font_1,d_font_2,d_font_3
        DC.L    d_bold,d_double,d_italic,d_undline
        DC.L    d_ignore,d_fx_off,d_ignore,d_ignore
******
d_end   MOVE.W  #-1,eop
        MOVE.W  #-1,eot
        RTS
*
d_ignore        ADD.L   #1,D6
        BRA     disp_line
*
rez_ch
        TST.W   mode_ind
        BNE     second
        MOVE.W  #-1,mode_ind
        ADD.L   #1,D6   ;Skip LF after mode change.
        BRA     d_ignore
second  MOVE.W  #-1,eop

        BRA     endit
*
d_font_0        MOVE.L  sys_font,D4
d_font  MOVE.L  D4,disp_font
        ADD.L   #1,D6
        BRA     disp_line
*
d_font_1
        MOVE.L  sys_font+4,D4
        BRA.S   d_font
d_font_2
        MOVE.L  sys_font+8,D4
        BRA.S   d_font
d_font_3
        MOVE.L  sys_font+12,D4
        BRA.S   d_font
*
d_double        BSET.B  #1,disp_style
        BRA     set_style
*
d_italic        BSET.B  #2,disp_style
        BRA     set_style
*
d_bold  BSET.B  #0,disp_style
        BRA     set_style
*
d_undline       BSET.B  #3,disp_style
set_style       ADD.L   #1,D6
        BRA     disp_line
*
d_fx_off        MOVE.B  #0,disp_style
        ADD.L   #1,D6
        BRA     disp_line
*
d_pound MOVE.B  #'œ',D4
        BRA     print_ch
*
d_newline
        ADD.W   #8,ch_y
        CMP.W   #2,old_rez      ;Hi rez?
        BNE     .ok
        ADD.W   #8,ch_y
.ok     MOVE.W  #0,ch_x
        ADD.L   #1,D6

endit   MOVE.L  D6,textptr
        RTS
*
print_ch
        AND.L   #$FF,D4
*
        CLR.W   double_h
        MOVE.L  disp_font,A0
*
        CMP.W   #2,old_rez
        BNE     .internal
        CMP.L   sys_font,A0
        BNE     .internal
        MOVE.W  #15,D7
        BRA     .ok1
.internal
        MOVE.W  #7,D7   ;8 lines per char
        CMP.W   #2,old_rez
        BNE     .ok1
        MOVE.W  #-1,double_h
.ok1
*       
        MOVE.L  D4,D0
        CMP.B   #'œ',D0
        BEQ     .pnd
        BCLR    #7,D0
.pnd    ADD.L   D0,A0
        CLR.L   D0
        CLR.L   D1
        MOVE.W  ch_x,D0
        MOVE.L  D0,D2
        MOVE.W  ch_y,D1
        MULU.W  bytes_p_line,D1
        AND.L   #$FE,D0
        LEA     screen1,A1
        MOVE.W  scr_work,D3
        MOVE.L  (A1,D3.W),A1
        CMP.W   #2,old_rez
        BEQ.S   .hi1
        LSL.L   #1,D0
.hi1    ADD.L   D0,A1
        AND.L   #1,D2
        ADD.L   D2,A1
        ADD.L   D1,A1
.chloop
        CLR.W   D3
.oka    tst.W   double_h
        BMI     .chdoub
        BTST.B  #1,disp_style
        BEQ.S   .chsingle
.chdoub MOVE.W  #1,D3
.chsingle
        MOVE.B  (A0),D0
*
        BTST    #7,D4   ;Bit 7 set if 'FIND' string.
        BEQ.S   .chok1
        CMP.B   #'œ',D4
        BEQ     .chok1
        EOR.B   #$FF,D0
*
.chok1  BTST.B  #2,disp_style
        BEQ.S   .choka
        CMP.W   #4,D7
        BCS     .choka
        LSR.B   #1,D0
.choka  BTST.B  #0,disp_style
        BEQ.S   .chok
        MOVE.B  D0,D1
        LSR.B   #1,D1
        CMP.W   #2,old_rez
        BEQ.S   .HI1
        OR.B    D1,2(A1)
.HI1    OR.B    D1,0(A1)
.chok
        CMP.W   #2,old_rez
        BEQ.S   .HI2
        OR.B    D0,2(A1)
.HI2    OR.B    D0,0(A1)
*
        ADD.L   l_bytes_p_line,A1
        DBF     D3,.chsingle
        ADD.L   #$100,A0
        DBF     D7,.chloop
        BTST.B  #3,disp_style
        BEQ     .ok
        SUB.L   l_bytes_p_line,A1
        MOVE.B  #$FF,D0
        CMP.W   #2,old_rez
        BEQ.S   .HI3
        OR.B    D0,2(A1)
.HI3    OR.B    D0,0(A1)
.ok     ADD.W   #1,ch_x 
next    ADD.L   #1,D6
        BRA     disp_line
*
double_h        DC.W    0
print_line      DC.W    0       ;Current line no on page.
****************************************
* print_text - Prints document in text *
* buffer to the printer.               *
****************************************
print_page
        PEA     prt_txt
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        MOVE.L  #0,D7   ;Left margin default.
        MOVE.W  print_line,D5   ;Line_count
        TST.W   D5
        BNE.S   .aok1
        BSR     headings
.aok1   LEA     page_addr,A2    ;Address of table containing pointers to start of each page
        MOVE.W  page_no,D1      ;Current page number.
        ASL.W   #2,D1           ;*4 to give address offset.
        MOVE.L  (A2,D1.W),A6    ;Store this top of page pointer.
        ADD.L   #1,A6           ;Move pointer over top of page pointer.
.chloop
*
        BSR     get_key
        TST.L   D0
        BEQ.S   .nokey
*
        CMP.L   #UNDO,D0        ;UNDO?
        BEQ.S   .end

*
.nokey  CLR.L   D0
        MOVE.B  (A6)+,D0
        BNE.S   .ok1
.end    MOVE.W  D5,print_line
        PEA     clr_line
        MOVE.W  #9,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        RTS             ;Zero = end of text.
.ok1    CMP.B   #31,D0
        BGT     .print
* Got a char < space, see whether to ignore, or what).
        CMP.B   #1,D0
        BNE.S   .ok1a
        BRA.S   .end
.ok1a   CMP.B   #4,D0
        BLT     .chloop
        BNE.S   .ok2
*Char is 4
        ADD.L   #3,A6
        BRA.S   .chloop
.ok2    CMP.B   #5,D0
        BNE.S   .ok3
        ADD.L   #18,A6
        BRA.S   .chloop
.ok3    CMP.B   #7,D0
        BNE.S   .ok4
        ADD.L   #3,A6
        BRA.S   .chloop
.ok4    CMP.B   #13,D0
        BNE.S   .ok5
        BSR.S   new_line
        BRA.S   .chloop
.ok5    CMP.B   #10,D0
        BEQ.S   .chloop
        CMP.B   #6,D0
        BNE.S   .ok6
        MOVE.W  #99,D5  ;Force page_throw
        BSR.S   new_line
        BRA     .chloop
.ok6    CMP.B   #14,D0
        BNE     .chloop
        MOVE.B  #'œ',D0
.print  BSR.S   print_char
        TST.W   D0
        BNE     .chloop
*Printer error!
        RTS
******************************************
* Print a new line, and the margin. Also *
* prints headings if new page reached.   *
******************************************
new_line
        CMP.W   #lines_per_page,D5
        BLT     .ok1
        BSR.S   new_page
.ok1    TST.W   D5
        BNE     .ok2
        BSR     headings
.ok2    ADD.W   #1,D5
        MOVE.L  D7,D6
        MOVE.W  #13,D0
        BSR.S   print_char
        MOVE.W  #10,D0
        BSR.S   print_char
.ploop  MOVE.W  #32,D0
        BSR.S   print_char
        DBF     D6,.ploop
        RTS
*
*****************************************
* New page - prints page headings.      *
*****************************************
new_page
        CLR.W   D5      ;Line count = 0
        MOVE.W  #13,D0
        BSR.S   print_char
        MOVE.W  #12,D0  ;Page throw.
        BSR.S   print_char
        RTS
****************************************
headings
        BSR     print_head
        BSR     print_head
        MOVE.W  #10,D0
        BSR.S   print_char
        MOVE.W  #10,D0
        BSR.S   print_char
        MOVE.W  #2,D5
        RTS
print_head
        MOVE.W  #13,D0
        BSR.S   print_char
        LEA     print_headings,A5
.loop   MOVE.B  (A5)+,D0
        EXT.W   D0
        BEQ.S   .exit
        BSR.S   print_char
        BRA.S   .loop
.exit
        RTS
*****************************************
print_char
        CMP.W   #14,D0
        BNE.S   .ok
        MOVE.W  #'œ',D0
.ok     MOVE.W  D0,-(SP)
        MOVE.W  #5,-(SP)
        TRAP    #1
        ADDQ.L  #4,SP
        RTS
our_mouse       MOVEM.L D0-D2/A0-A2,-(SP)
        MOVE.B  (A0)+,D0        ;First byte of ikbd
        MOVE.B  D0,D1   ;Save it
        AND.B   #$FC,D1
        CMP.B   #$F8,D1 ;Rel mouse package?
        BNE.S   .done
        AND.B   #%11,D0 ;Mask off button bits.
        LEA     click(PC),A1
        MOVE.B  (A0),D1 ;Moved?
        OR.B    1(A0),D1
        BEQ.S   .button_done
        BSET    #7,D0
;
        LEA     xy_limits(PC),A2
        MOVE.W  2(A1),D1        ;Old X
        MOVE.B  (A0)+,D2        ;Second ikbd byte
        EXT     D2
        ADD     D2,D1
        CMP.W   (A2),D1 ;Min X
        BGE.S   .pos_x
        MOVE.W  (A2),D1
        BRA     .upd_x
*
.pos_x  CMP.W   4(A2),D1        ;Max X
        BLE.S   .upd_x
        MOVE.W  4(A2),D1
.upd_x  MOVE.W  D1,2(A1)
* Now do Y coord
        MOVE.W  4(A1),D1        ;Old Y
        MOVE.B  (A0),D2 3rd ikbd byte
        EXT     D2
        ADD.W   D2,D1
        CMP.W   2(a2),D1        ;Min Y
        BGE.S   .pos_y
        MOVE.W  2(A2),D1
        BRA.S   .upd_y
.pos_y  CMP.W   6(A2),D1        ;Max Y
        BLE.S   .upd_y
        MOVE.W  6(A2),D1
.upd_y  MOVE.W  D1,4(A1)        ;New Y
.button_done
        MOVE.B  D0,(A1)+
        OR.B    D0,(A1)
.done
        MOVEM.L (A7)+,D0-D2/A0-A2
        RTS

*-+
*========================================================================
* Data contained within the program
        SECTION DATA
old_mouse       DC.L    0
xy_limits       
        DC.W    0,0             ;Mouse min
        DC.W    639-18,199-13   ;Mouse max
click   DC.B    0       ;Status Byte
        DC.B    0
mouse_x DC.W    0
mouse_y DC.W    0       
*
l_bytes_p_line  DC.W    0
bytes_p_line    DC.W    0
*
scr_shown               DC.W    0       *Which screen is visible * 4
scr_work                DC.W    0       *Which is work screen * 4
*
old_palette     ds.w 16
zero_palette    DC.W    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
text_palette    DC.W    $000,$777,$700,$007,$700,$077,$770,$777
*                       ^border ^BK  ^FG        (Med rez).
                DC.W    $000,$777,$000,$070,$700,$077,$770,$777
*                               ^BK                   ^Fg (low rez)
*
font_addr
sys_font        DC.L    0
        DC.L    font_1,font_2,font_3
**
** Every issue needs the following files.
**
        EVEN
font_1  *INCBIN  "FONT1.FON"
        EVEN
font_2  *INCBIN  "FONT2.FON"
        EVEN
font_3  *INCBIN  "FONT3.FON"
        EVEN
* 
*       The picture files all follow...
*
        DC.W    0       ;SPARE WORD
palette_data    ;This will point to the palette data in the TNY file
                ;when it has been moved down by 1 byte.
        DC.L    0
        EVEN
*****
        SECTION BSS
                DS.L    $100
stack           DS.L    1
screen1         DS.L    1       *address of master screen.
screen2         DS.L    1       *address of work/shown screen.
disp_font               DS.L    1
mode_ind                DS.W    1
disp_style              DS.B    1
                EVEN
graf_mode               DS.B    1

                EVEN
*
txt_style       DS.W    1       ;Bit mask for underline/italic etc.
*
pic_pal_addr    DS.L    1       ;Address of pictures palette
textptr         DS.L    1
page_no         DS.W    1
search_page     DS.W    1
last_page       DS.W    1
eop             DS.W    1
eot             DS.W    1
ch_x            DS.W    1
ch_y            DS.W    1
*
old_rez         DS.W    1
save_ssp                DS.L    1
w_workarea      DS.W    4000
page_addr       DS.L    max_pages       ;No of pages allowed
buffer          DS.W    40
*
        EVEN
        DS.B    1
pic_buff        DS.B    pic_buff_size
        EVEN
TNY_WRK1                DS.B    2
        EVEN
tny_work_area   DS.B    30000   ;Work area to expand tiny files (could
                                ;use a lot less?)
        EVEN
        
        section data
text_buff       incbin 'pvkill.doc'
end_of_prog
