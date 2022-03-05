;   ************************************************
;   *           Express BBS File Transfer  v1.26   *
;   *            Writen By  Jay L. Bray            *
;   *              Oct 16,1990  6:30pm             *
;   ************************************************
;
     text

Timeout =    -1
Nul     =     0              ; Ctrl - ,
Soh     =     1              ; Ctrl - A
Stx     =     2              ; Ctrl - B
Eot     =     4              ; Ctrl - D
Ack     =     6              ; Ctrl - F
Nak     =     21             ; Ctrl - U
Can     =     24             ; Ctrl - X
Dc1     =     17             ; Ctrl - Q
Dc3     =     19             ; Ctrl - S
Bksp    =     8
Cr      =     13
Lf      =     10
Esc     =     27
Bell    =     7

Modem   =     1
Console =     2

     text
     bra.s    Run

BasePage:     dc.l  0
Cur_Dir_Adr:  dc.l  0
Phys_Base:    dc.l  0
Sys_Op:       dc.w  0
Sig_Op:       dc.w  0
High_Access:  dc.w  0
User_Adr:     dc.l  0
Sig_Path_Adr: dc.l  0
Mesg_Area:    dc.l  0

Run:
     move.l   a7,a5            ; Save Stack Pointer in a5
     movea.l  $4(a5),a5        ; a5 points to the base-page start
     move.l   $c(a5),d0
     add.l    $14(a5),d0
     add.l    $1c(a5),d0
     add.l    #$100,d0
     move.l   #Usr_Stack,a7
     bsr      Mshrink
     bsr      Get_Bp_Adr
     move.w   #0,Credit_Time
     MOVE.L   #MSG_Line,MESG_AREA
     bsr      Main
     JSR      CRLF

Prg_Xit:
     move.w   Temp_Width,Video_Width
     JSR      PUT_SCREEN
     clr.l    d0
     move.l   Cur_Dir_Adr,a4
     move.b   (a4),d0
     sub.w    #"A",d0
     move.w   d0,Drive
     jsr      SetDrv
     add.l    #2,a4
     move.l   a4,Sig_Path_Adr
     jsr      Chdir
     move.l   Downloads,a0
     move.w   Downlds,(a0)
     move.l   Uploads,a0
     move.w   Uplds,(a0)
     move.l   BasePage,a0
     add.l    #$2ad00,a0
     clr.l    d0
     move.w   (a0),d0
     add.w    Credit_Time,d0
     move.w   d0,(a0)
     move.w   Credit_Time,d0

     clr.w    -(a7)            ; Return to BBS...
     trap     #1
     addq.l   #2,a7
     rts

Mshrink:
     movem.l  a1-a6/d1-d6,-(a7) ; MShrink
     move.l   d0,-(a7)          ; Length of area to reserve
     move.l   a5,-(a7)          ; Address of area
     move.w   #0,-(a7)          ; Dummy word
     move.w   #$4a,-(a7)
     trap     #1
     add.l    #12,a7
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Get_Bp_Adr:
     move.l   #Mod_Mem,-(a7)
     move.w   #38,-(a7)
     trap     #14
     addq.l   #6,a7
     rts

Mod_Mem:
     move.l   #$426,a0
     move.l   (a0),a0
     move.l   #BasePage,a1
     move.l   #3,d5
MM_2:
     move.l   (a0)+,(a1)+
     dbra     d5,MM_2
     rts

About:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "  Express BBS File Transfer Utility  ",Cr,Lf
     dc.b     "      ½ Copyright 1989,1990      ",Cr,Lf
     dc.b     "      Written by Jay L. Bray     ",Cr,Lf
     dc.b     "      Version  1.26  Oct 16, 1990    ",Cr,Lf,Cr,Lf
     dc.b     "    ___This Program is Shareware___  ",Cr,Lf
     dc.b     "          Send $15.00 (US) To:       ",Cr,Lf,Cr,Lf
     dc.b     "              Jay L. Bray            ",Cr,Lf
     dc.b     "          1002 Apt E, First Ave      ",Cr,Lf
     dc.b     "          Dover, DE.  19901          ",Cr,Lf,Cr,Lf,0
     align.w

Supexec:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   a0,-(a7)         ; a0 points to routine
     move.w   #38,-(a7)
     trap     #14
     addq.l   #6,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Line_5:       dc.b  Esc,"Y",32+4,32,Esc,"b0",Esc,"c3"                                          ;
     dc.b     " Md: Loc  St: Usr  Lvl: 0000  Bd: 9999  MSig:99  Dn: 0000  Up: 0000  Rt: 0010:1 "
     dc.b     Esc,"b3",Esc,"c0",0,0
     align.w

Inverse:      dc.b  Esc,"b0",Esc,"c3",0,0
Normal:       dc.b  Esc,"b3",Esc,"c0",0,0
Mode_0:       dc.b  Esc,"Y",32+4,32+5,"Loc",0
Mode_1:       dc.b  Esc,"Y",32+4,32+5,"Rmt",0
Stat3:        dc.b  Esc,"Y",32+4,32+14,"Sys",0
Stat2:        dc.b  Esc,"Y",32+4,32+14,"Sig",0
Stat1:        dc.b  Esc,"Y",32+4,32+14,"Usr",0
Lvl3:         dc.b  Esc,"Y",32+4,32+24,"Sysp",0,0
Lvl2:         dc.b  Esc,"Y",32+4,32+24,"High",0,0
Lvl1:         dc.b  Esc,"Y",32+4,32+24,"Norm",0,0
Baud_300:     dc.b  Esc,"Y",32+4,32+34,"300 ",0,0
Baud_1200:    dc.b  Esc,"Y",32+4,32+34,"1200",0,0
Baud_2400:    dc.b  Esc,"Y",32+4,32+34,"2400",0,0
Baud_4800:    dc.b  Esc,"Y",32+4,32+34,"4800",0,0
Baud_9600:    dc.b  Esc,"Y",32+4,32+34,"9600",0,0
Rto1:         dc.b  Esc,"Y",32+4,32+73
Rto2:         dc.b  "9999",0,0

Main:
     bsr      Do_Stuff
     move.w   #1,WW_Toggle
     move.w   #0,Word_Pending
     move.w   #0,Bm_Num
     move.w   #0,Lin_Count
     move.w   #0,Local
     move.w   #0,Sys_Op
     move.w   #0,Sig_Op
     bsr      Get_Sysdata
     bsr      Get_Userdata
     bsr      Get_Levels
     bsr      Get_Max_Sig
     bsr      Show_Msig
     move.w   Video_Width,Temp_Width
     move.l   #Line_5,Text_Adr
     JSR      SEND_CONSOLE
     move.l   #Inverse,Text_Adr
     JSR      SEND_CONSOLE
     cmp.w    #0,Sys_Op
     beq      Maina
     move.l   #Stat3,Text_Adr
     bra.s    Mainc
Maina:
     cmp.w    #0,Sig_Op
     beq      Mainb
     move.l   #Stat2,Text_Adr
     bra.s    Mainc
Mainb:
     move.l   #Stat1,Text_Adr
Mainc:
     JSR      SEND_CONSOLE
     cmp.w    #0,Sys_Op
     beq      Maind
     move.l   #Lvl3,Text_Adr
     bra.s    Mainf
Maind:
     cmp.w    #0,High_Access
     beq      Maine
     move.l   #Lvl2,Text_Adr
     bra.s    Mainf
Maine:
     move.l   #Lvl1,Text_Adr
Mainf:
     JSR      SEND_CONSOLE
     move.l   #Rto1,Text_Adr
     JSR      SEND_CONSOLE
     cmp.w    #9600,BAUD1
     bne      main1
     move.l   #Baud_9600,Text_Adr
     bra.s    Main5
Main1:
     cmp.w    #4800,BAUD1
     bne      main2
     move.l   #Baud_4800,Text_Adr
     bra.s    Main5
Main2:
     cmp.w    #2400,BAUD1
     bne      main3
     move.l   #Baud_2400,Text_Adr
     bra.s    Main5
Main3:
     cmp.w    #1200,BAUD1
     bne      main4
     move.l   #Baud_1200,Text_Adr
     bra.s    Main5
Main4:
     move.l   #Baud_300,Text_Adr
Main5:
     jsr      Send_Console
     jsr      Chk_CARRIER      ; CHECK FOR CARRIER
     cmp.w    #1,Carrier       ; If we have a carrier - not local
     beq      Cmnd_4
     move.w   #1,Local
     move.w   #1,Carrier
     move.l   #Mode_0,Text_Adr
     jsr      Send_Console
     bra.s    Cmnd_5
Cmnd_4:
     move.l   #Mode_1,Text_Adr
     jsr      Send_Console
Cmnd_5:
     move.l   #Normal,Text_Adr
     jsr      Send_Console
     bsr      Cvrt_Dl_Stats
     jsr      Zero_Timer
     jsr      Get_Timer
     move.l   Timer,Time_Up    ; Timer Value at entry
     jsr      Clear_Screen
     jsr      Get_Screen
     move.l   #About,Text_Adr
     JSR      LINE_OUT
     bsr      Wait_Rtrn
     bsr      Menu
Cmnd_7:
     rts

Mnu_Ent:
     dc.b     Cr,Lf
     dc.b     "Enter Which File Area?",Cr,Lf
     dc.b     "('/r0/b' For List, '/g?/b' For Help):> ",0
     align.w

Mnu1:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "[/rL/b] List New Files",Cr,Lf
     dc.b     "[/rS/b] Scan New Files",Cr,Lf
     dc.b     "[/rD/b] Download Marked Files",Cr,Lf
     dc.b     "[/rY/b] Your D/L Stats",Cr,Lf
     dc.b     "[/r!/b] Quick Log-Off",Cr,Lf
     dc.b     "[/gX/b] eXit back to BBS",0
     align.w

Mnu2:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "/r*** SysOp Functions ***/b",Cr,Lf,Cr,Lf
     dc.b     "   [/rT/b] Terminal Mode",Cr,Lf
     dc.b     Cr,Lf,0
     align.w

Menu:
     cmp.w    #0,Carrier
     beq      Mu7
     move.l   #Dis_Cur,Text_Adr
     jsr      Send_Console
     jsr      Clear_Screen
     jsr      flush_inp
     jsr      Check_TimeOn
     jSR      CRLF
     jSR      CRLF
Mnu0a:
     jsr      Check_TimeOn
     move.l   #Mnu_Ent,Text_Adr
     JSR      STRING_OUT
     move.w   #1,Caps
     move.w   #1,Echo
     JSR      GET_CHAR
     cmp.w    #0,Carrier
     beq      Mu7
     cmp.w    #"?",d0
     bne      Mnu01
     move.l   #Help_Msg,Text_Adr
     JSR      LINE_OUT
     move.l   #Mnu1,Text_Adr
     jsr      Line_out
     cmp.w    #1,Local
     bne      Mnu0b
     move.l   #Mnu2,Text_Adr
     JSR      STRING_OUT
Mnu0b:
     bra.s    Mnu0a
Mnu01:
     cmp.w    #Cr,d0           ; Hit Return or "0"
     beq      Mnu01a           ; and you see the file sig list...
     cmp.w    #"0",d0
     bne      Mnu02
Mnu01a:
     bsr      Show_Sigs
     BRA      MNU0A

Mnu02:
     cmp.w    #"!",d0
     bne      Mu3
     bsr      Disconnect
     move.w   #0,Carrier
     BRA      MU7

Mu3:
     cmp.w    #"D",d0          ; Download Marked Files
     bne      Mu4
     cmp.w    #0,Bm_Num
     beq      Mu3a
     JSR      BACK_SPACE
     move.l   #Download_Marked_Msg,Text_Adr
     jsr      Line_Out
     bsr      Send_YBatch
Mu3a:
     BRA      MENU
Mu4:
     cmp.w    #"Y",d0
     bne      Mu4b
     jsr      Back_Space
     move.l   #Your_Stats_Msg,Text_Adr
     jsr      Line_Out
     bsr      Show_User_Stats
     bra      Menu
Mu4b:
     cmp.w    #1,Local
     beq      Mu5
Mu4c:
     cmp.w    #1,Sig_Op
     bne      Mu5c
     bra.s    Mu5a
Mu5:
     cmp.w    #"T",d0          ; Terminal Mode?
     bne      Mu5a
     jsr      Back_Space
     move.l   #Terminal_Mode_Msg,Text_Adr
     jsr      Line_Out
     bsr      Terminal_Mode
     cmp.w    #0,Carrier
     beq      Mu7
     bra      Menu
Mu5a:
     cmp.w    #"Z",d0          ; Special Stuff
     bne      Mu5c
;     bsr      TEXTSIX
;     bsr      Wait_Rtrn
     bra      Menu
Mu5c:
     cmp.w    #"L",d0          ; List New Files
     bne      Mu5d
     jsr      Back_Space
     move.l   #List_New_Msg,Text_Adr
     jsr      Line_Out
     bsr      List_New
     bra      Menu
Mu5d:
     cmp.w    #"S",d0          ; Scan New Files
     bne      Mu6
     jsr      Back_Space
     move.l   #Scan_New_Msg,Text_Adr
     bsr      Line_Out
     bsr      Scan_New
     bra      Menu
Mu6:
     cmp.w    #"X",d0          ; eXit to BBS
     bne      Mu6a
     jsr      Back_Space
     move.l   #Exit_Msg,Text_Adr
     bsr      Line_Out
     bra      Mu7
Mu6a:
     cmp.w    #"1",d0
     bcs      Menu
     cmp.w    #"9",d0
     bhi      Menu
     sub.w    #$30,d0
     move.w   d0,d1
     move.w   #1,Caps
     move.w   #1,Echo
     jsr     Get_Char
     cmp.w    #0,Carrier
     beq      Mu7
     cmp.w    #Cr,d0
     bne      Mu6b
     move.w   d1,d0
     bra.s    Mu6d
Mu6b:
     mulu     #10,d1
     cmp.w    #"0",d0
     bcs      Menu
     cmp.w    #"9",d0
     bhi      Menu
     sub.w    #$30,d0
     add.w    d1,d0
     cmp.w    #1,d0
     blt      Menu
Mu6d:
     move.w   Max_Sig,d1
     cmp.w    #0,d1
     beq      Mu8
     cmp.w    d0,d1
     blt      Menu
     move.w   d0,Sig_Num
     bra      Do_Sigs
Mu7: rts
Mu8: move.l   #No_Sig_Msg,Text_Adr
     bsr      String_Out
     bra      Menu

No_Sig_Msg:
     dc.b     Cr,Lf,"There Are No File Sigs Available!!!",Cr,Lf,0
     align.w

Get_Max_Sig:
     movem.l  a0/a5/d0/d4,-(a7)
     move.w   #0,Sig_Num
GMS_1:
     move.w   Sig_Num,Max_Sig
     add.w    #1,Sig_Num
     clr.l    d0
     move.w   Sig_Num,d0
     move.l   #File_A,a5
     sub.w    #1,d0
     mulu     #2,d0
     add.l    d0,a5
     clr.l    d4
     move.w   (a5),d4          ; Get Actuall Sig Number
     cmp.w    #$e5e5,d4        ; End of Sigs???
     beq      GMS_3
     sub.w    #1,d4
     move.l   #FileSigName,a0
     muls     #32,d4
     add.w    d4,a0            ; Get Offset of Sig Name
     cmp.b    #0,(a0)          ; Does It Really Exist?
     bne      GMS_1
GMS_2:
     move.w   #$e5e5,(a5)
GMS_3:
     sub.w    #1,Sig_Num
     move.w   Sig_Num,Max_Sig
     movem.l  (a7)+,a0/a5/d0/d4
     rts

Show_Sigs:
     movem.l  a0-a5/d4-d5,-(a7)
     jsr      Clear_Screen
     JSR      CRLF
     cmp.w    #0,Max_Sig
     beq      Shw_Sig_Xit
     move.w   #0,Flip
     move.w   #0,Sig_Num
     clr.l    d5
Shw_S1:
     move.w   #0,No_Color
     add.w    #1,Sig_Num
     clr.l    d0
     move.w   Sig_Num,d0
     move.l   #Space1,a3
     bsr      Pdec4            ; Convert D0 to Dec#
     move.l   #Space1,a3
     move.b   #" ",(a3)+
     move.b   #"[",(a3)+
     cmp.b    #"0",(a3)
     bne      Shw_S2
     move.b   #" ",(a3)
Shw_S2:
     move.l   #Space1,Text_Adr
     clr.l    d0
     move.w   Sig_Num,d0
     move.l   #File_A,a5
     sub.w    #1,d0
     mulu     #2,d0
     add.l    d0,a5
     move.w   (a5),d4          ; Get Actuall Sig Number
     cmp.w    #$e5e5,d4
     beq      Shw_S4
     sub.w    #1,d4
     move.l   #FileSigName,a0
     muls     #32,d4
     Add.w    d4,a0            ; Get Offset of Sig Name
Shw_S2a:
     move.l   a0,-(a7)
     move.w   #1,No_Color
     bsr      String_Out       ; Print Masked Sig Number
     move.l   (a7)+,a0
     bsr      buildname
     move.l   #Space2,Text_Adr ; Print File Sig Name
     cmp.w    #0,Flip
     bne      Shw_S3
     cmp.w    #40,Video_Width
     bne      Shw_S2b
     bsr      Line_Out
     bra.s    Shw_S2c
Shw_S2b:
     bsr      String_Out
Shw_S2c:
     move.w   #1,Flip
     bra      Shw_S1
Shw_S3:
     bsr      Line_Out
     move.w   #0,Flip
     bra      Shw_S1
Shw_S4:
     cmp.w    #1,Flip
     bne      Shw_Sig_Xit
     JSR      CRLF
Shw_Sig_Xit:
     bsr      Show_Msig
     movem.l  (a7)+,a0-a5/d4-d5
     rts

Buildname:
     movem.l  a0-a1,-(a7)
     move.l   #Space2,a1
     move.l   #32,d6
bl1: move.b   #" ",(a1)+      ; Clear out Temp Name Area
     dbra     d6,bl1
     move.l   #Space2,a1
     clr.l    d7
bl2: move.b   (a0)+,d7
     cmp.b    #0,d7
     beq      bl3
     move.b   d7,(a1)+
     bra.s    bl2
bl3:
     movem.l  (a7)+,a0-a1
     rts

Drv_St1:      dc.b  Esc,"Y",32+4,32+45
Drv_St2:      dc.b  "00",0,0

Show_Msig:
     move.l   d0,-(a7)
     move.l   #Save_Cur,Text_Adr
     jsr      Send_Console
     move.l   #Inverse,Text_Adr
     jsr      Send_Console
     clr.l    d0
     move.w   Max_Sig,d0
     move.l   #10,d1
     move.l   Drv_St2,a3
     bsr      Dec1
     move.l   #Drv_St1,Text_Adr
     Jsr      Send_Console
     move.l   #Normal,Text_Adr
     jsr      Send_Console
     move.l   #Set_Cur,Text_Adr
     jsr      Send_Console
     move.l   (a7)+,d0
     rts

Checking_Msg: dc.b  "Checking -> ",0
     align.w

Scan_New:
     cmp.w    #0,Max_Sig
     beq      Scnn2
     jsr      CrLf
     jsr      CrLf
     move.w   #0,Srch_Kywrd
     move.w   #0,Find_Date
     move.w   #1,NewFiles
     move.w   #1,Sig_Num
Scnn1:
     bsr      Get_Sig_Path     ; Get Sig Name too...
     move.l   #Checking_Msg,Text_Adr
     bsr      String_Out
     move.l   #Sig_Name,Text_Adr
     bsr      String_Out
     bsr      Do_Scan
     add.w    #1,Sig_Num
     move.w   Sig_Num,d0
     cmp.w    Max_Sig,d0
     bgt      Scnn2
     bra.s    Scnn1
Scnn2:
     rts

List_New:
     cmp.w    #0,Max_Sig
     beq      Lstn2
     jsr      CrLf
     jsr      CrLf
     move.w   #0,Find_Date
     move.w   #0,Srch_Kywrd
     move.w   #1,NewFiles
     move.w   #1,Sig_Num
Lstn1:
     bsr      Get_Sig_Path     ; Get Sig Name too...
     move.l   #Checking_Msg,Text_Adr
     bsr      String_Out
     move.l   #Sig_Name,Text_Adr
     bsr      String_Out
     bsr      Do_List
     add.w    #1,Sig_Num
     move.w   Sig_Num,d0
     cmp.w    Max_Sig,d0
     bgt      Lstn2
     bra.s    Lstn1
Lstn2:
     rts

Do_Sigs:
     bsr      Get_Sig_Path     ; Get Sig Name too...
Do_S0:
     jsr      CrLf
     jsr      CrLf
Do_S0a:
     bsr      Show_TimeLeft
     move.l   #Sig_Name,Text_Adr
     bsr      String_Out
Do_S1:
     move.w   #0,Echo
     move.w   #1,Caps
     jsr      Get_Char
     cmp.w    #0,Carrier
     beq      Do_S11
     cmp.w    #"/",d0
     bne      Do_S1a
     move.l   #Change_Sig_Msg,Text_Adr
     bsr      Line_Out
     add.w    #1,Sig_Num
     move.w   Sig_Num,d1
     cmp.w    Max_Sig,d1
     bgt      Do_S1a
     bra.s    Do_Sigs
Do_S1a:
     cmp.w    #"?",d0
     bne      Do_S2
     move.l   #Help_Msg,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bsr      CrLf
     move.l   #List_Scan,Text_Adr
     bsr      String_Out
     bra.s    Do_S1
Do_S2:
     cmp.w    #"L",d0
     bne      Do_S3
     move.l   #List_Files_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,Find_Date
     move.w   #0,Srch_Kywrd
     move.w   #0,NewFiles
     bsr      do_List
     cmp.w    #0,Num_Files
     beq      Do_S0a
     bra      Do_S0
Do_S3:
     cmp.w    #"S",d0
     bne      Do_S3a
     move.l   #Scan_Files_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,NewFiles
     move.w   #0,Find_Date
     move.w   #0,Srch_Kywrd
     bsr      Do_Scan
     bra      Do_S0
Do_S3a:
     cmp.w    #"*",d0
     bne      Do_S3b
     bsr      Show_Sigs
     bra      Do_S0
Do_S3b:
     cmp.w    #"=",d0
     bne      Do_S4
     bra      Menu
Do_S4:
     cmp.w    #"X",d0
     bne      Do_S4a
     move.l   #Exit_Msg,Text_Adr
     bsr      Line_Out
     bra      Do_S11
Do_S4a:
     cmp.w    #"N",d0
     bne      Do_S4b
     move.l   #New_Files_Msg,Text_Adr
     bsr      Line_Out
     move.w   #1,NewFiles
     bsr      Do_Scan
     bra      Do_S0
Do_S4b:
     cmp.w    #"!",d0
     bne      Do_S4c
     bsr      Disconnect
     move.w   #0,Carrier
     bra      Do_S11
Do_S4c:
     cmp.w    #"D",d0
     bne      Do_S5
     move.l   #Download_Msg,Text_Adr
     bsr      Line_Out
     bsr      Do_Download
     bra      Do_S0
Do_S5:
     cmp.w    #"U",d0
     bne      Do_S5a
     move.l   #Upload_Msg,Text_Adr
     bsr      Line_Out
     bsr      Do_Upload
     bra      Do_S0
Do_S5a:
     cmp.w    #"F",d0          ; Find File(s) By Date...
     bne      Do_S5b
     move.l   #Find_Files_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,NewFiles
     move.w   #1,Find_Date
     move.w   #0,Srch_Kywrd
     bsr      Do_List
     bra      Do_S0
Do_S5b:
     cmp.w    #"K",d0          ; Keyword Search of description
     bne      Do_S6
     move.l   #Keyword_Search_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,NewFiles
     move.w   #0,Find_Date
     move.w   #1,Srch_Kywrd
     bsr      Do_List
     bra      Do_S0
Do_S6:
     cmp.w    #"B",d0          ; Mark a File for Batch Transfer
     bne      Do_S7
     move.l   #Batch_Mark_Msg,Text_Adr
     bsr      Line_Out
     bsr      Batch_File_Mark
     bra      Do_S0
Do_S7:
     cmp.w    #"R",d0          ; Review Marked Files
     bne      Do_S7a
     move.l   #Review_Marked_Msg,Text_Adr
     bsr      Line_Out
     bsr      Show_Marked
     bra      Do_S0
Do_S7a:
     cmp.w    #"W",d0
     bne      Do_S8
     move.l   #Wipe_Files_Msg,Text_Adr
     bsr      Line_Out
     bsr      Wipe_Marked
     bra      Do_S0
Do_S8:
     cmp.w    #"Y",d0
     bne      Do_S9
     cmp.w    #0,Bm_Num
     beq      Do_S12
     move.l   #YBatch_Send_Msg,Text_Adr
     bsr      Line_Out
     bsr      Send_Ybatch
     bra      Do_S0
Do_S9:
     cmp.w    #"C",d0
     bne      Do_S10
     JSR      CALL_CHAT
     bra      Do_S0
Do_S10:
     bsr      Show_Wrong_Key
     bra      Do_S0a
Do_S11:
     bra      Menu
Do_S12:
     move.l   #Not_Marked,Text_Adr
     bsr      Line_Out
     bra      Do_S0a

List_Scan:
     dc.b     "[/rL/b] List Files                    ",160
     dc.b     "[/rS/b] Scan Files                    ",Cr,Lf
     dc.b     "[/rF/b] Find File(s) by Date          ",160
     dc.b     "[/rK/b] Keyword Search of Description ",Cr,Lf
     dc.b     "[/rN/b] New Files Since Last Call     ",160
     dc.b     "[/rU/b] Upload A File                 ",Cr,Lf
     dc.b     "[/rD/b] Download A File               ",160
     dc.b     "[/rB/b] Mark a File for Batch Transfer",Cr,Lf
     dc.b     "[/rR/b] Review Marked Files           ",160
     dc.b     "[/rW/b] Wipe File(s) From Marked List ",Cr,Lf
     dc.b     "[/rY/b] Download Marked Files         ",160
     dc.b     "[/rC/b] Call SysOp For Chat           ",Cr,Lf
     dc.b     Cr,Lf
     dc.b     "[/r//b] Goto Next File Sig            ",160
     dc.b     "[/r*/b] Show Available File Sigs      ",Cr,Lf
     dc.b     "[/r=/b] Change File Sig               ",160
     dc.b     "[/r?/b] This Menu                     ",Cr,Lf
     dc.b     "[/r!/b] Quick Log-Off                 ",160
     dc.b     Cr,Lf,"[/rX/b] eXit to File Menu",Cr,Lf,Cr,Lf
     dc.b     "Choice -> ",0,0
     align.w

Not_Marked:   dc.b  Cr,Lf,Cr,Lf," You Don't Have Anything Marked!!!",Cr,Lf,0
              align.w

Show_Wrong_Key:
     move.l   #Wrong_Key,Text_Adr
     bsr      Line_Out
     rts

Wrong_Key:    dc.b  Cr,Lf,Cr,Lf," Wrong Key! Press '?' For Help",Cr,Lf,0
              align.w

Scan_Title:   dc.b  "Filename       Size    Mins  Count  Description",Cr,Lf
              dc.b  "--------      -------  ----  -----  -----------",0
              align.w

Do_Scan:
     move.w   #0,File_Count
     move.w   #0,Eod
     move.w   #0,Num_Files
     bsr      Get_Search_Spec
     move.l   #DirPath,SFirst1+2
     bsr      SFirst
     cmp.w    #0,d0
     beq      Do_C2
     bra      Do_C7
Do_C1:
     bsr      SNext
     cmp.w    #0,d0            ; Find Another File?
     beq      Do_C2            ;  Yep, So Show The Info...
     move.w   #1,Eod
     cmp.w    #0,Num_Files
     bhi      Do_C3
     bra      Do_C7
Do_C2:
     bsr      Get_FileInfo
     cmp.w    #0,F_Attrib      ; If Attribute is normal then all can see.
     beq      Do_Ca2
     cmp.w    #$20,F_Attrib    ; If Attribute is 'Arc' then it's
     bne      Do_Ca1           ;   for the SysOp's Eyes Only...
     cmp.w    #1,User_No
     beq      Do_Ca2
     bra.s    Do_C1
Do_Ca1:
     cmp.w    #1,High_Access
     bne      Do_C1
Do_Ca2:
     cmp.w    #1,NewFiles      ; Should We Check For New Files?
     bne      Do_C2b           ; No - Show File As Normal
     bsr      Compare_Dates
     cmp.w    #1,d0            ; Is It A New File?
     bne      Do_C1            ; No
Do_C2b:
     bsr      Get_Description
     cmp.w    #0,File_Count
     bne      Do_C2c
     bsr      CrLf
     move.l   #Scan_Title,Text_Adr
     bsr      Line_Out
Do_C2c:
     add.w    #1,Num_Files
     bsr      Show_File1
     add.w    #1,File_Count
     cmp.w    #15,File_Count
     bne      Do_C1
     move.w   #0,File_Count
Do_C3:
     bsr      CrLf
     move.l   #Opt_D,Text_Adr
     bsr      String_Out
     cmp.w    #1,Eod
     beq      Do_C4
     move.l   #Opt_N,Text_Adr
     bsr      String_Out
Do_C4:
     move.l   #Opt_Q,Text_Adr
     bsr      String_Out
Do_C5:
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Do_C8
     cmp.w    #Cr,d0
     beq      Do_C5a
     cmp.w    #"N",d0          ; If Char = "N"
     bne      Do_C6            ; And We're at the
Do_C5a:
     cmp.w    #1,Eod           ; End of the Directory
     beq      Do_C6            ; Ignore Char
     move.l   #Next_Page_Msg,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bra      Do_C1            ; Else go get another file
Do_C6:
     cmp.w    #Cr,d0
     beq      Do_C7
     cmp.w    #"Q",d0
     bne      Do_C6a
     move.l   #Quit_Msg,Text_Adr
     bsr      Line_Out
     bra.s    Do_C7
Do_C6a:
     cmp.w    #"D",d0
     bne      Do_C1
     move.l   #Download_Msg,Text_Adr
     bsr      Line_Out
     bsr      Do_Download
     bra      Do_C1
Do_C7:
     bsr      CrLf
Do_C8:
     rts

Num_Files:    dc.w  0

Do_List:
     bsr      CrLf
     move.w   #0,Num_Files
     move.w   #0,Eod
     cmp.w    #1,Srch_Kywrd
     bne      Do_Lst1
     move.l   #Srch_Wrd_Msg1,Text_Adr  ; Search Entry #1
     bsr      String_Out
     move.l   #32,Length
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Do_Lst_Xit
     move.l   #32,d0
     clr.l    d1
     move.w   Count,d1
     sub.w    d1,d0
     move.w   d0,Srch_Ln
     move.l   a0,-(a7)
     move.l   #LineIn,a0
     move.b   (a0),d0
     move.l   (a7)+,a0
     cmp.b    #Cr,d0
     beq      Do_B10
     MOVEM.L  A0-A1,-(a7)      ; one + ...
     move.l   #Srch_Wrd,a1
     move.l   #LineIn,a0
     clr.l    d5
     move.w   Srch_Ln,d5
Do_Lst0:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      Do_Lst0a
     cmp.b    #Cr,d0
     beq      Do_Lst0a
     move.b   d0,(a1)+
     dbra     d5,Do_Lst0
Do_Lst0a:
     clr.l    d5
     move.w   Count,d5
Do_Lst0b:
     move.b   #0,(a1)+
     dbra     d5,Do_Lst0b
     movem.l  (a7)+,a0-a1      ; one - ...
     bra.s    Do_B0            ; Search - Exit #1
Do_Lst1:
     cmp.w    #1,Find_Date
     bne      Do_B0
Fnd_Dt0:
     move.l   #Fnd_Dt_Msg1,Text_Adr  ; Find - Entry #1
     bsr      String_Out
     move.l   #8,Length
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Do_Lst_Xit
     cmp.w    #0,Count
     beq      Fnd_Dt1
     move.l   #Fnd_Dt_Msg2,Text_Adr
     bsr      String_Out
     bra.s    Fnd_Dt0
Fnd_Dt1:
     movem.l  a0-a1/d5,-(a7)   ; two + ...
     move.l   #LineIn,a0
     move.l   #Find_Dt,a1
     move.l   #7,d5
Fnd_Dt2:
     move.b   (a0)+,(a1)+
     dbra     d5,Fnd_Dt2
     movem.l  (a7)+,a0-a1/d5   ; two - ...
Do_B0:
     bsr      Get_Search_Spec
;     bsr      Clear_Screen
     move.l   #DirPath,SFirst1+2
     bsr      SFirst
     cmp.w    #0,d0
     beq      Do_B2
     bra.s    Do_B1a
Do_B1:
     bsr      SNext
     cmp.w    #0,d0
     beq      Do_B2
Do_B1a:
     move.w   #1,Eod
     bra      Do_B10
Do_B2:
     bsr      Get_FileInfo
     cmp.w    #0,F_Attrib      ; If Attribute is normal then all can see.
     beq      Do_Ba2
     cmp.w    #$20,F_Attrib    ; If Attribute is 'Arc' then it's
     bne      Do_Ba1           ;   for the SysOp's Eyes Only...
     cmp.w    #1,User_No
     beq      Do_Ba2
     bra.s    Do_B1
Do_Ba1:
     cmp.w    #1,High_Access
     bne      Do_B1
Do_Ba2:
     cmp.w    #1,Find_Date
     bne      Do_Ba3
     movem.l  a0-a1,-(a7)        ; three + ... Find - Entry #2
     move.l   #Find_Dt,a0
     move.l   #F_Date,a1
     clr.l    d0
     clr.l    d1
     clr.l    d2
     bsr      Cmp_D1
     movem.l  (a7)+,a0-a1        ; Three -
     cmp.w    #1,d0            ; Is It Since The Search Date?
     bne      Do_B1            ; No
     bra.s    Do_B2a
Do_Ba3:
     cmp.w    #1,NewFiles      ; Should We Check For New Files
     bne      Do_B2a           ; No - Show File As Normal
     bsr      Compare_Dates
     cmp.w    #1,d0            ; Is It A New File
     bne      Do_B1            ; No
Do_B2a:
     bsr      Get_Description
     cmp.w    #$Fade,File_Ok
     bne      Do_B2_a1
     cmp.w    #1,Access_V
     bne      Do_B1
Do_B2_a1:
     cmp.w    #1,Srch_Kywrd    ; Do we want to search for a key word?
     bne      Do_B2b           ; Nope!
     cmp.w    #1,No_Desc       ; does this file have a description?
     beq      Do_B1            ; Nope, so look for another file...
     bsr      Search           ; Search for key word
     cmp.w    #1,Found         ; did we find it?
     beq      Do_B2b           ; Yep...
     bra      Do_B1
Do_B2b:
;     bsr      Clear_Screen
     add.w    #1,Num_Files
     bsr      Show_File2
     bsr      CrLf
     cmp.w    #1,No_Desc
     beq      Do_B2e
     bsr      Show_Msg
     bra.s    Do_B2f
Do_B2e:
     move.l   #NoDesc_Msg,Text_Adr
     bsr      Line_Out
Do_B2f:
     bsr      CrLf
     bsr      CrLf
     move.w   #0,No_Color
     move.l   #Opt_C,Text_Adr
     bsr      String_Out
     move.l   #Opt_D,Text_Adr
     bsr      String_Out
     move.l   #Opt_M,Text_Adr
     bsr      String_Out
     cmp.l    #$41524300,F_Ext    ; ARC File???
     bne      Do_B2f1a
     bra.s    Do_B2f2
Do_B2f1a:
     cmp.l    #$4C5A4800,F_Ext    ; LZH File???
     bne      Do_B2f1b
     bra.s    Do_B2f2
Do_B2f1b:
     cmp.l    #$53495400,F_Ext    ; SIT File???
     bne      Do_B2f1c
     bra.s    Do_B2f2
Do_B2f1c:
     cmp.l    #$5A495000,F_Ext    ; Zip File???
     bne      Do_B2g
Do_B2f2:
     move.l   #Opt_U,Text_Adr
     bsr      String_Out
     bra.s    Do_B2h
Do_B2g:
     move.l   #Opt_R,Text_Adr
     bsr      String_Out
Do_B2h:
     move.l   #Opt_Q,Text_Adr
     bsr      String_Out
     cmp.w    #1,Access_V      ; does the user have access
     bne      Do_B2i
     cmp.w    #$Fade,File_Ok
     bne      Do_B2h1
     move.l   #Opt_V,Text_Adr
     bsr      String_Out
     bra.s    Do_B2i
Do_B2h1:
     move.l   #Opt_H,Text_Adr
     bsr      String_Out
Do_B2i:
     cmp.w    #1,Access_E
     bne      Do_B2j
     move.l   #Opt_E,Text_Adr
     bsr      String_Out
     add.w    #1,File_Buf
Do_B2j:
     cmp.w    #1,Access_D
     bne      Do_B2k
     move.l   #Opt_K,Text_Adr
     bsr      String_Out
     add.w    #1,File_Buf
Do_B2k:
Do_B3:
     bsr      Flush_Inp
     move.w   #1,Caps
     move.w   #0,Echo
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Do_Lst_Xit
     cmp.w    #Cr,d0
     bne      Do_B_3
     move.w   #"C",d0
     move.w   d0,Char
Do_B_3:
     cmp.w    #"Q",d0          ; Quit
     bne      Do_B3a
     MOVE.L   #QUIT_MSG,TEXT_ADR
     bsr      Line_Out
     bra      Do_B10
Do_B3a:
     cmp.l    #$41524300,F_Ext ; Arc???
     beq      Do_B3za
     cmp.l    #$4C5A4800,F_Ext ; Lzh???
     beq      Do_B3za
     cmp.l    #$5A495000,F_Ext ; Zip???
     beq      Do_B3za
     cmp.l    #$53495400,F_Ext ; Sit???
     bne      Do_B3zb
Do_B3za:
     cmp.w    #"U",d0          ; Un-Arc
     beq      Do_B6
     bra.s    Do_B3zc
Do_B3zb:
     cmp.w    #"R",d0          ; Read
     beq      Do_B7
Do_B3zc:
     cmp.w    #"C",d0          ; Continue
     beq      Do_B4
     cmp.w    #"M",d0          ; Batch Mark
     beq      Do_B5
     cmp.w    #"V",d0          ; Validate
     beq      Do_B4_V
     cmp.w    #"H",d0          ; Hide
     beq      Do_B4_H
     cmp.w    #"E",d0          ; Edit
     beq      Do_B4_E
     cmp.w    #"K",d0          ; Kill (Delete) File
     beq      Do_B4_K
     cmp.w    #"D",d0          ; Download
     bne      Do_B3
     move.l   #Download_Msg,Text_Adr
     bsr      Line_Out
     bsr      Do_Down
Do_B4:
     move.l   #Cont_Msg,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bsr      CrLf
     bra      Do_B1
Do_B4_E:
     cmp.w    #1,Access_E
     bne      Do_B1
     bsr      Edit_This_File
     bra      Do_B1
Do_B4_K:
     cmp.w    #1,Access_D
     bne      Do_B1
     bsr      Kill_This_File
     bra      Do_B1
Do_B4_V:
     cmp.w    #1,Access_V
     bne      Do_B1
     bsr      Validate_This_File
     bra      Do_B1
Do_B4_H:
     cmp.w    #1,Access_V
     bne      Do_B1
     bsr      Hide_This_File
     bra      Do_B1
Do_B5:
     move.l   #Batch_Mark_Msg,Text_Adr
     bsr      Line_Out
     bsr      Batch_Mark
     bra      Do_B1
Do_B6:
     move.l   #UnArc_Msg,Text_Adr
     bsr      Line_Out
     cmp.l    #$41524300,F_Ext ; "ARC"
     bne      Do_B6a
     bsr      Arc_Listing
     bsr      Wait_Rtrn
     bra      Do_B2a
Do_B6a:
     cmp.l    #$4C5A4800,F_Ext ; "LZH"
     bne      Do_B6b
     bsr      Lzh_Listing
     bsr      Wait_Rtrn
     bra      Do_B2a
Do_B6b:
     cmp.l    #$5A495000,F_Ext ; "ZIP"
     bne      Do_B6c
     bsr      Zip_Listing
     bsr      Wait_Rtrn
     bra      Do_B2a
Do_B6c:
     cmp.l    #$53495400,F_Ext ; "SIT"
     bne      Do_B2a
     bsr      Sit_Listing
     bsr      Wait_Rtrn
     bra      Do_B2a
Do_B7:
     move.l   #F_PName2,Fo1+2
     bsr      View_File
     bra      Do_B1
Do_B10:
     cmp.w    #1,NewFiles
     beq      Do_Lst_Xit
     move.l   #Eof_Dir_Msg,Text_Adr
     cmp.w    #0,Num_Files
     bne      Do_B12
Do_B11:
     move.l   #No_Files_Msg,Text_Adr
Do_B12:
     bsr      Line_Out
Do_Lst_Xit:
     rts

No_Files_Msg: dc.b  Cr,Lf,"This Sig Doesn't Have Any Files!",Cr,Lf,0
              align.w

EOf_Dir_Msg:  dc.b  Cr,Lf,"No More Files...",Cr,Lf,0
              align.w

No_Edit:      dc.w  0

Edit_This_File:
     move.w   #1,No_Edit
     move.w   #0,NSv
ETF_1:
     move.l   #Edit_msg1,Text_Adr
     bsr      String_Out
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      ETF_Xit
     cmp.w    #"1",Char        ; Access Level
     bne      ETF_2
     bsr      Edit_Access_Level
     bra.s    ETF_Mod
ETF_2:
     cmp.w    #"2",Char        ; Description
     bne      ETF_3
     bsr      Edit_Description
     bra.s    ETF_Mod
ETF_3:
     cmp.w    #"3",Char        ; Uploader
     bne      ETF_4
     bsr      Edit_Uploader
     bra.s    ETF_Mod
ETF_4:
     cmp.w    #"4",Char        ; Access Count
     bne      ETF_5
     bsr      Edit_Access_Count
     bra.s    ETF_Mod
ETF_5:
     cmp.w    #"5",Char        ; Last Date D/L'd
     bne      ETF_S
     bsr      Edit_Last_Dl
     bra.s    ETF_Mod
ETF_S:
     cmp.w    #"S",Char        ; Save this Description?
     beq      ETF_Xit
ETF_A:
     cmp.w    #"A",Char        ; Abort Edit?
     beq.s    ETF_Xit2
ETF_Mod:
     bsr      Show_File2
     bra      ETF_1
ETF_Xit:
     cmp.w    #1,No_Edit
     beq      ETF_Xit2
     move.w   #$Bead,File_Ok
     bsr      Write_Description
ETF_Xit2:
     rts

Edit_msg1:
     dc.b  Cr,Lf,Cr,Lf,"      /r>>> Edit Which Option <<</b",Cr,Lf,Cr,Lf
     dc.b  "[/r1/b] Access Level  [/r2/b] Description    ",160
     dc.b  "[/r3/b] Uploader      [/r4/b] Access Count   ",Cr,Lf
     dc.b  "[/r5/b] Date Last D/L                    ",160
     dc.b  "[/rS/b] Save Changes  [/rA/b] Abort Changes  ",Cr,Lf

     dc.b  Cr,Lf,"Enter Choice :> ",0
     align.w

Edit_Access_Level:
     move.l   #Access_Level_Msg,Text_Adr
     bsr      Line_Out
     bsr      Ask4_Level
     bsr      Change_Mode
     rts

Edit_Description:
     move.l   #Description_Msg,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bsr      Enter_Msg2
     move.w   #0,No_Edit
     rts

Edit_Uploader:
     move.l   #Uploader_Msg,Text_Adr
     bsr      Line_Out
     move.l   #F_Mnt_Emsg2,Text_Adr
     bsr      String_Out
     move.l   #15,Length
     move.w   #0,Caps
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Ed_Ul_Xit
     move.l   #LineIn,a0
     move.b   (a0),d0
     cmp.b    #Cr,d0
     beq      Ed_Ul_Xit
     move.l   #Uploader,a1
     move.l   #15,d5
Ed_Ul1:
     move.b   (a0)+,d0
     cmp.b    #Cr,d0
     beq      Ed_Ul2
     cmp.b    #0,d0
     beq      Ed_Ul2
     move.b   d0,(a1)+
     dbra     d5,Ed_Ul1
Ed_Ul2:
     move.b   #0,(a1)+
     move.w   #0,No_Edit
Ed_Ul_Xit:
     rts

Edit_Access_Count:
     move.l   #Access_Count_Msg,Text_Adr
     bsr      Line_Out
Ed_Al1:
     move.l   #Edt_Cnt_Msg,Text_Adr
     bsr      String_Out
     move.l   #4,Length
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Ed_Al_Xit
     move.l   #LineIn,a0
     cmp.b    #Cr,(a0)
     beq      Ed_Al_Xit
     move.l   a0,a1
     move.l   #4,d5
Ed_Al2:
     move.b   (a1)+,d0
     cmp.b    #0,d0
     beq      Ed_Al3
     cmp.b    #Cr,d0
     beq      Ed_Al3
     cmp.b    #"0",d0
     bcs      Ed_Al4
     cmp.b    #"9",d0
     bhi      Ed_Al4
     dbra     d5,Ed_Al2
Ed_Al3:
     bsr      Asc2Bin
     cmp.w    #0,Binary_Word
     bcs      Ed_Al4
     cmp.w    #9999,Binary_Word
     bhi      Ed_Al4
     move.w   Binary_Word,Accs_Cntr
Ed_Al4:
     move.w   #0,No_Edit
     bsr      CrLf
Ed_Al_Xit:
     rts

Edt_Cnt_Msg:
     dc.b     Cr,Lf,"Enter New Access Count > ",0
     align.w

Edit_Last_Dl:
     move.l   #Date_Last_Dl_Msg,Text_Adr
     bsr      Line_Out
     move.l   #Edt_Lst_Dl_Msg,Text_Adr
     bsr      String_Out
     move.l   #8,Length
     move.w   #0,Caps
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Ed_Ldl_Xit
     move.l   #LineIn,a0
     cmp.b    #Cr,(a0)
     beq      Ed_Ldl_Xit
     move.l   #Lst_Dl,a1
     move.l   #7,d5
Ed_Ldl1:
     move.b   (a0)+,(a1)+
     dbra     d5,Ed_Ldl1
     move.w   #0,No_Edit
Ed_Ldl_Xit:
     rts

Edt_Lst_Dl_Msg:
     dc.b     Cr,Lf,"Enter New Date > ",0
     align.w

Kill_This_File:
     move.l   #Delete_Msg,Text_Adr
     bsr      Line_Out
     move.l   #Kill_Fil_Msg,Text_Adr
     bsr      String_Out
DTF_1:
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      DTF_Xit
     cmp.w    #"Y",Char
     beq      DTF_2
     cmp.w    #"N",Char
     beq      DTF_Xit
     bra.s    DTF_1
DTF_2:
     move.l   #Desc_Path,FK_Addr
     bsr      FKill
     move.l   #F_Pname2,FK_Addr
     bsr      FKill
     tst.w    d0
     bmi      DTF_3
     move.l   #F_kill_Msg1,Text_Adr
     bra.s    DTF_4
DTF_3:
     move.l   #F_Kill_Msg2,Text_Adr
DTF_4:
     bsr      String_Out
DTF_Xit:
     rts

Kill_Fil_Msg: dc.b  Cr,Lf,Cr,Lf,"/rDelete File?/b Are You Sure??? ",0
              align.w

F_Kill_Msg1:  dc.b  Cr,Lf,Cr,Lf,"File Successfully Deleted...",Cr,Lf,Cr,Lf,0
              align.w

F_Kill_Msg2:  dc.b  Cr,Lf,Cr,Lf,"/rError!/b File Was Not Deleted!!!",Cr,Lf,Cr,Lf,0
              align.w

Rename_This_File:
     move.l   #Rename_Msg,Text_Adr
     bsr      Line_Out
     move.l   #F_Mnt_Msg4,Text_Adr
     bsr      String_Out
     move.l   #12,Length
     move.w   #1,Caps
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      RTF_Xit
     move.l   #LineIn,a0
     move.l   #F_Pname2,d0
     move.l   F_Pname_Adr,d5
     sub.l    d0,d5
     sub.l    #1,d5
     move.l   #New_Name,a1
     move.l   #F_Pname2,a2
RTF_1:
     move.b   (a2)+,(a1)+
     dbra     d5,RTF_1
     move.l   #12,d5
RTF_2:
     move.b   (a0)+,d0
     cmp.b    #Cr,d0
     beq      RTF_3
     cmp.b    #0,d0
     beq      RTF_3
     move.b   d0,(a1)+
     dbra     d5,RTF_2
RTF_3:
     move.b   #0,(a1)+
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #New_Name,-(a7)
     move.l   #F_Pname2,-(a7)
     move.w   #0,-(a7)
     move.w   #$56,-(a7)
     trap     #1
     add.l    #12,sp
     movem.l  (a7)+,a1-a6/d1-d6
RTF_Xit:
     rts

New_Name:     dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


F_Mnt_Msg4:   dc.b  Cr,Lf,Cr,Lf,"Enter New Filename or <Return> to Abort > ",0
              align.w

F_Mnt_Emsg2:  dc.b  Cr,Lf,Cr,Lf,"Enter New Name or /g<Return>/b to Abort >",0
              align.w

Validate_This_File:
     move.w   #$Bead,File_Ok
     bsr      Write_Description
     rts

Hide_This_File:
     move.w   #$Fade,File_Ok
     bsr      Write_Description
     rts

Find_Date:    dc.w  0
Find_Dt:      dc.b  "00/00/00"
Fnd_Dt_Msg1:  dc.b  Cr,Lf,Cr,Lf,"Find File(s) Since What Date? (ex: MM/DD/YY) :> ",0
              align.w
Fnd_Dt_Msg2:  dc.b  Cr,Lf,Cr,Lf,"Please Enter Date As -> MM/DD/YY <-",0
              align.w
Fnd_Dt_Msg3:  dc.b  Cr,Lf,"Press Any Key For More ",0
              align.w

Found:        dc.w  0
Srch_Ln:      dc.w  0
Srch_Kywrd:   dc.w  0
Srch_Wrd:     dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Srch_Wrd_Msg1:  dc.b  Cr,Lf,Cr,Lf,"Enter String to Search :> ",0
              align.w

Search:
     movem.l  a0-a3/d1/d5,-(a7)
     move.l   #Msg_Line,a0
     move.l   #Srch_Wrd,a1
     move.l   a0,a2            ; Copy Mem_Adr
Srch_1:
     move.l   a1,a3            ; Copy Look_up word
     clr.l    d5
     move.w   Srch_Ln,d5
     move.b   (a3)+,d0         ; get a byte from look_up word
Srch_2:
     clr.l    d1
     move.b   (a2)+,d1         ; Get a byte from Mem_Adr
     cmp.b    #200,d1          ; See if we are at the end of the Msg
     beq      Srch_5
     cmp.b    #"a",d1          ; Convert Upper to Lower
     blt      Srch_2a
     cmp.b    #"z",d1
     bgt      Srch_2a
     sub.b    #32,d1
Srch_2a:
     cmp.b    d0,d1            ; Are They the same?
     bne      Srch_2           ; Loop if not...
     sub.w    #1,d5            ; Subtract 1 from counter
     cmp.w    #0,d5            ; Is it zero yet?
     beq      Srch_4
Srch_3:
     move.b   (a3)+,d0         ; Get another byte from Look_Up word
     move.b   (a2)+,d1         ; and another from Mem_Adr
     cmp.b    #200,d1          ; See if we are at the end of the Msg
     beq      Srch_5
     cmp.b    #"a",d1
     blt      Srch_3a
     cmp.b    #"z",d1
     bgt      Srch_3a
     sub.b    #32,d1
Srch_3a:
     cmp.b    d0,d1            ; Do they match?
     bne      Srch_1           ; If not try another address...
     sub.w    #1,d5            ; Subtract 1 from counter
     cmp.w    #0,d5            ; Is it zero yet?
     bne      Srch_3           ; Nope...
Srch_4:
     move.w   #1,Found
     bra.s    Srch_6
Srch_5:
     move.w   #0,Found
Srch_6:
     movem.l  (a7)+,a0-a3/d1/d5
     rts

Do_Stuff:
     movem.l  a0-a2,-(a7)
     move.l   BasePage,a0
     move.l   a0,a1
     add.l    #$306e,a1
     move.l   (a1),a2
     move.l   a2,Td1+2
     move.l   a2,Td2+2
     movem.l  (a7)+,a0-a2
     rts

Show_TD:
     MOVEM.L  A0-A7/D0-D7,-(A7)
     move.w   #3,-(a7)
     move.w   #1,-(a7)
TD1: JSR      $DEADBEEF
     move.w   #11,-(a7)
     move.w   #1,-(a7)
TD2: JSR      $DEADBEEF
     movem.l  (a7)+,a0-a7/d0-d7
     rts

New_Edit:
     movem.l  a0-a7/d0-d7,-(a7)
     move.l   BasePage,a0
     add.l    #$14652,a0
     move.l   (a0),NE1+2
Ne1: Jsr      $DeadBeef
     movem.l  (a7)+,a0-a7/d0-d7
     rts

Opt_C:        dc.b  "</rC/b>ont  ",0,0
Opt_E:        dc.b  "[/rE/b]dit  ",0,0
Opt_K:        dc.b  "[/rK/b]ill  ",0,0
Opt_M:        dc.b  "[/rM/b]ark  ",0,0
Opt_H:        dc.b  "[/rH/b]ide  ",0,0
Opt_Q:        dc.b  "[/gQ/b]uit  ",0,0
Opt_R:        dc.b  "[/rR/b]ead  ",160,0
Opt_V:        dc.b  "[/rV/b]alid  ",0
Opt_U:        dc.b  "[/rU/b]n-Arc  ",160,0
Opt_D:        dc.b  "[/rD/b]ownload  ",0,0
Opt_N:        dc.b  "[/rN/b]ext Page  ",0

Get_Description:
     movem.l  a0-a5/d5-d6,-(a7)
     move.l   #880,d5
     move.l   #File_Ok,a0
Zrodsc:
     move.b   #0,(a0)+
     dbra     d5,Zrodsc
     move.w   #0,No_Desc
     move.l   #F_Name,a0       ; Copy Filename to
     move.l   F_DName_Adr,a1   ; Description Path
     move.l   F_Pname_Adr,a2   ; and File Path name
Gt_Dsc0:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     move.b   d0,(a2)+
     cmp.b    #0,d0
     bne      Gt_Dsc0
Gt_Dsc1:
     move.b   #0,(a1)+
     move.l   #Desc_Path,Fo1+2
     move.w   #0,Shw_Error
     move.w   #0,File_Mode
     bsr      Fopen
     cmp.w    #0,d0
     bgt      Gt_Dsc2
     move.w   #1,No_Desc
     bra      Gt_Dsc_Xit
Gt_Dsc2:
     bsr      Get_File_Size    ; Read in File...
     move.l   d0,Num_bytes
     move.w   #0,Where
     move.l   #0,How_Many
     bsr      Lseek
     bsr      Fread
     move.l   d0,d5            ; # of Bytes Read
     move.l   d5,d6
     bsr      FClose
     move.l   #File_Buf,a5
     cmp.w    #0,68(a5)
     bne      Get_Dsc2a
     move.w   #$2020,68(a5)
Get_Dsc2a:
     move.w   (a5),d0
     cmp.w    #$fade,d0
     beq      Gt_Dsc2a
     cmp.w    #$Bead,d0        ; Is it already in converted form??
     bne      Gt_Dsc4          ;  Bypass if not.
Gt_Dsc2a:
     move.l   a5,a0
     add.l    #68,a0
Gt_Dsc2b:
     move.b   (a0)+,d0         ; Check Description Area
     cmp.b    #Cr,d0           ; for Cr's
     beq      Gt_Dsc2c         ; If found Convert Like Regular text...
     dbra     d5,Gt_Dsc2b
     bra.s    Gt_Dsc2e
Gt_Dsc2c:
     move.l   a5,a0
     move.l   #File_Ok,a1      ; Copy File Buff
     move.l   #67,d5           ;      To
Gt_Dsc2d:                      ; Message Area...
     move.b   (a0)+,(a1)+
     dbra     d5,Gt_Dsc2d
     move.l   a5,a0
     add.l    #68,a0
     move.l   #Msg_Line,a5
     move.l   d6,d5
     move.l   a5,a4
     move.w   #0,Line_No
     bra.s    Gt_Dsc5
Gt_Dsc2e:
     move.l   a5,a0
     move.l   #File_Ok,a1      ; Copy File Buff
     move.l   #880,d5          ;      To
Gt_Dsc3:                       ; Message Area...
     move.b   (a0)+,(a1)+
     dbra     d5,Gt_Dsc3
     bra      Gt_Dsc_Xit
Gt_Dsc4:
     move.l   #File_Buf,a0
     move.l   #Msg_Line,a5
     move.l   a5,a4
     move.w   #0,Line_No
Gt_Dsc5:
     move.b   (a0)+,d0         ; Clear out any Cr's or Lf's
     sub.w    #1,d5
     cmp.b    #Cr,d0           ; in the beginning of file...
     beq      Gt_Dsc5
     cmp.b    #Lf,d0
     beq      Gt_Dsc5
     bra.s    Gt_Dsc7a
Gt_Dsc6:
     clr.l    d1               ; Find offset to current line
     move.w   Line_No,d1
     mulu     #80,d1
     move.l   a5,a4
     add.l    d1,a4
Gt_Dsc7:
     move.b   (a0)+,d0         ; Copy a Char into current line
     sub.w    #1,d5
     cmp.w    #0,d5
     beq      Gt_Dsc9
     cmp.b    #0,d0            ; exit if it's a "Zero"
     beq      Gt_Dsc9
     cmp.b    #Cr,d0
     bne      Gt_Dsc7a
     move.b   (a0)+,d0
     sub.w    #1,d5
     cmp.w    #0,d5
     beq      Gt_Dsc9
     bra.s    Gt_Dsc8
Gt_Dsc7a:
     move.b   d0,(a4)+
     bra.s    Gt_Dsc7
Gt_Dsc8:
     add.w    #1,Line_No       ; Increment Line Number
     cmp.w    #10,Line_No       ; if it's greater then 9 then exit
     beq      Gt_Dsc_Xit
     bra.s    Gt_Dsc6
Gt_Dsc9:
     add.w    #1,Line_No
     move.b   #0,(a4)+
     move.b   #0,(a4)+
Gt_Dsc_Xit:
     movem.l  (a7)+,a0-a5/d5-d6
     rts

No_Desc:      dc.w  0

Update_Description:
     movem.l  a0-a1/d5,-(a7)
     bsr      Get_Description
     add.w    #1,Accs_Cntr        ; increase access count
     cmp.w    #0,File_Ok
     bne      Up_Ds1
     move.w   #$Bead,File_Ok
Up_Ds1:
     move.l   #Date,a0
     move.l   #Lst_Dl,a1
     move.l   #7,d5
Up_Ds2:
     move.b   (a0)+,(a1)+
     dbra     d5,Up_Ds2
     bsr      Write_Description
     movem.l  (a7)+,a0-a1/d5
     rts

Write_Description:
     movem.l  a0-a1,-(a7)
     move.l   #Desc_Path,Fo1+2 ; Create the file
     move.w   #0,F_Attrib      ; erase if already exists...
     bsr      FCreate
     move.l   #File_Ok,a0
     move.l   #File_Buf,a1
     MOVE.L   #880,D5
     move.l   d5,Num_Bytes
Wrt_Dsc1:
     move.b   (a0)+,(a1)+
     dbra     d5,Wrt_Dsc1
     bsr      FWrite
     bsr      FClose
     movem.l  (a7)+,a0-a1
     rts

Get_Search_Spec:
     movem.l  a0-a1/d5,-(a7)
     cmp.w    #1,NewFiles
     beq      Gss0
     move.l   #SrchSpec_Msg,Text_Adr
     bsr      String_Out
     move.l   #12,Length
     move.w   #1,Caps
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Gss8
     move.l   #LineIn,a0
     move.b   (a0),d0
     cmp.b    #Cr,d0
     bne      Gss1
Gss0:
     move.l   #Search_Spec,a1
     move.b   #"*",(a1)+
     move.b   #".",(a1)+
     move.b   #"*",(a1)+
     move.b   #0,(a1)+
     bra.s    Gss3
Gss1:
     move.l   #11,d5
     move.l   #Search_Spec,a1
Gss2:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      Gss2a
     cmp.b    #Cr,d0
     beq      Gss2a
     move.b   d0,(a1)+
     dbra     d5,Gss2
Gss2a:
     move.b   #0,(a1)+
Gss3:
     move.l   DirPath_Adr,a1
     move.l   #Search_Spec,a0
Gss6:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      Gss7
     cmp.b    #Cr,d0
     beq      Gss7
     move.b   d0,(a1)+
     bra.s    Gss6
Gss7:
     move.b   #0,(a1)+
     cmp.w    #1,NewFiles
     beq      Gss8
     bsr      CrLf
     bsr      CrLf
Gss8:
     movem.l  (a7)+,a0-a1/d5
     rts

SrchSpec_Msg:
     dc.b     Cr,Lf,"Enter Search Spec or (Return for '*.*')",0
Search_Spec:
     dc.l     0,0,0,0,0,0,0,0

; ----------  Directory Area Stuff  ---------------

Max_Sig:      dc.w  0
File_Count:   dc.w  0
Eod:          dc.w  0
File_Size:    dc.l  0
Fil_Sizt:     dc.l  0

Dta:          dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

F_DName_Adr:  dc.l  0          ; Address of \Desc\ path
Desc_Path:    dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DirPath_Adr:  dc.l  0          ; Address of \Sig\ Path
DirPath:      dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

F_PName_Adr:  dc.l  0          ; Address of FilePath name

F_PName1:     dc.b  Esc,"Y",32+9,32+17
F_PName2:     dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Batch_File_Mark:
     movem.l  a0-a1/d5,-(a7)
     bsr      CrLf
     bsr      CrLf
     move.l   #Ask_Bm_Fname,Text_Adr
     bsr      String_Out
     bsr      Fname_Parse
     Cmp.w    #0,Carrier
     beq      Bm5
     cmp.b    #0,FName_Ok
     beq      Bm5
     bsr      Copy_FName
     bsr      See_Exist
     cmp.w    #1,Exist
     beq      Do_Batchm
;     bsr      Not_Exist
     bra      Bm5

Batch_Mark:
     movem.l  a0-a1/d5,-(a7)
     bsr      Check_Dl_Ratio
     cmp.w    #1,Need_Uploads
     beq      Bm5
     clr.l    d0
     move.w   Min_Needed,d0
     cmp.l    TimeLeft,d0
     blt      Do_Bm1
     move.l   #Need_Time_Msg,Text_Adr
     bsr      Line_Out
     bra      Bm5
Do_Bm1:
     bsr      CrLf
     bsr      CrLf
Do_Batchm:
     cmp.w    #10,Bm_Num
     bne      Bm0
     move.l   #Bm1_Msg,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bra      Bm5
Bm0:
     clr.l    d0
     move.w   Bm_Num,d0
     mulu     #26,d0
     move.l   #Bm_File,a1
     add.l    d0,a1
     move.w   Sig_Num,(a1)+
     move.l   Fil_Sizt,(a1)+
     move.w   Min_Needed,(a1)+
     move.l   #File_Name,a0
     move.l   #13,d5
Bm1:
     move.b   (a0)+,(a1)+      ; Copy Filename to Batch Mark Area
     dbra     d5,BM1
     add.w    #1,Bm_Num
Bm5:
     movem.l  (a7)+,a0-a1/d5
     rts

Wipe_Marked:
     movem.l  a0-a3/d1-d5,-(a7)
     bsr      CrLf
     bsr      CrLf
     cmp.w    #0,Bm_Num
     bne      Wip_M0
     move.l   #Not_Marked,Text_Adr
     bsr      Line_Out
     bra      Wip_M9
Wip_M0:
     bsr      Show_Marked
     move.l   #Wipe_Mrk_Msg,Text_Adr
     bsr      String_Out

     move.w   #1,Caps
     move.l   #2,Length
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      Wip_M9
     move.l   #LineIn,a0
     move.l   a0,a1
     move.b   (a0),d0
     cmp.b    #Cr,d0           ; Exit if user just pressed return
     beq      Wip_M9
     cmp.b    #"A",d0          ; Do they want all of 'em cleared?
     bne      Wip_M1
     bsr      Back_Space
     move.l   #All_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,Bm_Num        ; Yep - so exit!
     bra      Wip_M9
Wip_M1:
     move.l   #LineIn,a0
     bsr      Asc2Bin          ; Convert Ascii Numbers to Binary
     cmp.w    #0,Binary_Word   ; holds binary number
     bcs      Wip_M9
     clr.l    d2
     move.w   Binary_Word,d2
     move.w   Bm_Num,d1
     cmp.w    d1,d2
     bhi      Wip_M9
     sub.l    #1,d2

     move.l   d2,d0            ; d2 = number of file to get rid of...
     mulu     #26,d0
     move.l   #Bm_File,a1
     move.l   a1,a3
     add.l    #260,a3          ; a3 = end address of batch mark area...
     add.l    d0,a1            ; a1 points to address of file...
     move.l   a1,a2
     add.l    #26,a2           ; a2 paoints to next file address
     sub.l    a2,a3
     move.l   a3,d5
Wip_M7:
     move.b   (a2)+,(a1)+
     dbra       D5,WIP_M7
     sub.w    #1,Bm_Num
Wip_M9:
     movem.l  (a7)+,a0-a3/d1-d5
     rts

Show_Marked:
     movem.l  a0-a4/d5-d7,-(a7)
     cmp.w    #0,Bm_Num
     beq      Shw_M5
     move.l   #0,B_S_Tot
     move.l   #0,B_M_Tot
     bsr      CrLf
     bsr      CrLf
     move.l   #Files_Mrk,Text_Adr
     bsr      Line_Out
     move.l   #Batch_Info,Text_Adr
     bsr      String_Out
     clr.l    d7
     clr.l    d6
Shw_M1:
     move.l   d6,d7
     mulu     #26,d7
     move.w   #"[",Char
     bsr      Put_Char
     move.w   d6,d0
     cmp.w    #9,d0
     bne      Shw_M2
     move.w   #"1",Char
     bsr      Put_Char
     move.w   #"0",Char
     bsr      Put_Char
     bra.s    Shw_M3
Shw_M2:
     add.w    #$31,d0
     move.w   d0,-(a7)
     move.w   #" ",Char
     bsr      Put_Char
     move.w   (a7)+,d0
     move.w   d0,Char
     bsr      Put_Char
Shw_M3:
     move.w   #"]",Char
     bsr      Put_Char
     move.w   #" ",Char
     bsr      Put_Char
     bsr      Put_Char
     move.l   #Bm_File,a4
     add.l    d7,a4
     move.w   (a4)+,Dummy      ; Sig #...
     move.l   (a4)+,d0         ; File_Size
     add.l    d0,B_S_Tot
     move.l   #Batch_Finf2,a3
     bsr      Pdec8
     move.l   #Batch_Finf2,a0
     bsr      Zero_2_Space
     clr.l    d0
     move.w   (a4)+,d0         ; Time to D/L File
     add.l    d0,B_M_Tot
     move.l   #Batch_Finf3,a3
     bsr      Pdec4
     move.l   #Batch_Finf3,a0
     bsr      Zero_2_Space
     move.l   #12,d5
     move.l   #Batch_Finf1,a0
Shw_M4:
     move.b   (a4)+,(a0)+
     dbra     d5,SHW_M4
     move.l   #Batch_Finf1,Text_Adr
     bsr      Line_Out
     add.w    #1,d6
     cmp.w    Bm_Num,d6
     blt      Shw_M1
     move.l   B_S_Tot,d0
     move.l   #Batch_Stot,a3
     bsr      Pdec8
     move.l   #Batch_Stot,a0
     bsr      Zero_2_Space
     move.l   B_M_Tot,d0
     move.l   #Batch_Mtot,a3
     bsr      Pdec4
     move.l   #Batch_Mtot,a0
     bsr      Zero_2_Space
     move.l   #Batch_Tots,Text_Adr
     bsr      Line_Out
Shw_M5:
     movem.l  (a7)+,a0-a4/d5-d7
     rts

B_S_Tot:      dc.l  0
B_M_Tot:      dc.l  0

Batch_Info:   dc.b "Nbr   Filename      Size      Mins",Cr,Lf
              dc.b "----  ------------  --------  ----",Cr,Lf,0
              align.w

Batch_tots:   dc.b "      ------------  --------  ----",Cr,Lf
              dc.b "      Totals:       "
Batch_Stot:   dc.b "          "
Batch_Mtot:   dc.b "    ",0,0

Batch_Finf1:  dc.b "              "
Batch_Finf2:  dc.b "          "
Batch_Finf3:  dc.b "    ",0,0

Files_Mrk:
     dc.b     "Files Currently Marked For Transfer:",Cr,Lf,0,0
     align.w

Wipe_Mrk_Msg:
     dc.b     Cr,Lf,"[/rA/b]ll Files",Cr,Lf
     dc.b     "or Enter Number Of File To Wipe From List",Cr,Lf
     dc.b     Cr,Lf,"Choice ? ",0
     align.w

Do_Upload:
     bsr      CrLf
     bsr      CrLf
     move.l   #Ask_Ul_Fname,Text_Adr
     bsr      String_Out
     bsr      Fname_Parse
     cmp.w    #0,Carrier
     beq      Do_U7
     cmp.w    #0,FName_Ok
     beq      Do_U7
     bsr      Copy_FName
     move.w   #0,Shw_Error
     bsr      See_Exist
     cmp.w    #1,Exist
     bne      Do_U0
     bsr      It_Exists
     bra      Do_U7

Up_Protocols:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "[/rX/b] Xmodem",Cr,lf
     dc.b     "[/rC/b] Xmodem Crc",Cr,lf
     dc.b     "[/rK/b] Ymodem (Xmodem 1k)",Cr,lf
     dc.b     "[/rY/b] Ymodem Batch",Cr,Lf
     dc.b     "[/rZ/b] Zmodem",Cr,Lf
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "Enter Transfer Protocol ->",0
     align.w

Do_U0:
     bsr      Ask4_Level
     Move.l   #Up_Protocols,Text_Adr
     bsr      String_Out
Do_U1:
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Do_U7
     cmp.w    #Cr,d0
     beq      Do_U7
     cmp.w    #"X",d0
     bne      Do_U2
     move.l   #Xmodem_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,Use_Crc
     bra      Do_U6
Do_U2:
     cmp.w    #"C",d0
     bne      Do_U3
     move.l   #Xmodem_Crc_Msg,Text_Adr
     bsr      Line_Out
     move.w   #1,Use_Crc
     bra      Do_U6
Do_U3:
     cmp.w    #"K",d0
     bne      Do_U4
     move.l   #Ymodem_Msg,Text_Adr
     bsr      Line_Out
     move.w   #2,Use_Crc
     bra      Do_U6
Do_U4:
     cmp.w    #"Y",d0
     bne      Do_U5
     move.l   #Ymodem_Batch_Msg,Text_Adr
     bsr      Line_Out
     move.w   #3,Use_Crc
     bra.s    Do_U6
Do_U5:
     cmp.w    #"Z",d0
     bne      Do_U1
     move.l   #Zmodem_Msg,Text_Adr
     bsr      Line_Out
     move.w   #4,Use_Crc
Do_U6:
     move.l   #Start_Xfer_Msg,Text_Adr
     bsr      Line_Out
     bsr      Check_TimeOn
     move.l   TimeLeft,Tim_At_Upld
;     bsr      Show_Regs
     bsr      Rcv_File
;     bsr      Show_Regs
     cmp.w    #2,Use_Crc       ; Are we using Y-Batch or Z-Batch
     bgt      Do_U6a
     bsr      Copy_Fname
     bsr      See_Exist        ; See if we got it..
     cmp.w    #1,Exist
     bne      Do_U7
     bra.s    Do_U6b
Do_U6a:
     move.l   #Check_New_Msg,Text_Adr
     bsr      Send_Console
     bsr      Check_New_Uploads
     bra.s    Do_U6c
Do_U6b:
     bsr      Update_NewFiles
;     bsr      Show_Regs
     bsr      Get_Save_Desc
     cmp.w    #0,Carrier
     beq      Do_U7
Do_U6c:
     bsr      Give_Upload_Credit
Do_U7:
     rts

Check_New_Msg:  dc.b  Cr,Lf,"Checking for New Files...",Cr,Lf,0
                align.w

Check_New_Uploads:
     move.l   DirPath_Adr,a1
     move.b   #"*",(a1)+
     move.b   #".",(a1)+
     move.b   #"*",(a1)+
     move.b   #0,(a1)+
     move.l   #DirPath,SFirst1+2
     bsr      Sfirst
     cmp.w    #0,d0
     blt      CNU_9            ; Exit if no entries...
CNU_0:
     bsr      Get_FileInfo
     move.w   Cur_Date,d0      ; Is the date the same or grater
     cmp.w    File_Date,d0     ; than date we started the upload?
     bgt      CNU_1            ; -- Try another if not...
     move.w   Cur_Time,d0      ; Is the Time greater than
     cmp.w    File_Time,d0     ; THE TIME WE STARTED THE UPLOAD?
     blt      CNU_2            ; -- If it is then continue
CNU_1:
     bsr      SNext            ; Get another file...
     cmp.w    #0,d0
     blt      CNU_9
     bra.s    CNU_0
CNU_2:                         ; if we made it here, it's new...
     bsr      Update_NewFiles
     bsr      Get_Save_Desc
     bra.s    CNU_1
CNU_9:
     rts

Update_NewFiles:
     bsr      Show_Upload_Status
     bsr      Write_Upld_Ok
     move.l   #Fil_Rcvd_Msg1,Text_Adr
     bsr      String_Out
     move.l   F_Pname_Adr,Text_Adr
     bsr      String_Out
     move.l   #Fil_Rcvd_Msg2,Text_Adr
     bsr      Line_Out
     add.w    #1,Uplds
     bsr      Cvrt_Dl_Stats
     rts

Get_Save_Desc:
     bsr      Get_Description
     bsr      Enter_Msg
     move.l   #User_Name,a0
     move.l   #Uploader,a1
     move.l   #15,d5
GS_D1:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      GS_D2
     move.b   d0,(a1)+
     dbra     d5,GS_D1
GS_D2:
     move.w   #$Fade,File_Ok
     bsr      Write_Description
     rts

Tim_At_Upld:  dc.l  0
Credit_Time:  dc.w  0

Give_Upload_Credit:
     movem.l  a3/d0-d3,-(a7)
     bsr      Check_TimeOn
     move.l   TimeLeft,d0
     move.l   Tim_At_Upld,d1
     sub.l    d0,d1            ; d1 = the time taken to upload file...
     add.w    d1,Credit_Time
     move.w   Time_on,d2
     add.w    d1,d2
     move.w   d2,Time_On
     clr.l    d0
     move.w   Credit_Time,d0
     move.l   #Up_Crdt_Msg2,a3
     bsr      PDec4
     move.l   #Up_Crdt_Msg1,Text_Adr
     bsr      Line_Out
     movem.l  (a7)+,a3/d0-d3
     rts

Up_Crdt_Msg1: dc.b  Cr,Lf," You Now Have "
Up_Crdt_Msg2: dc.b  "0000 Minutes of Upload Credit!",Cr,Lf,0
              align.w

Show_Upload_Status:
     move.l   BasePage,a0
     ADD.L    #$3169A,A0
     move.w   #1,(a0)
     rts

Fil_Rcvd_Msg1:
     dc.b     "File Received -> ",0
     align.w

Fil_Rcvd_Msg2:
     dc.b     " <- , Thanks!",Cr,Lf,Cr,Lf
     dc.b     "Now Please Tell Me Something About This File!",Cr,Lf,0
     align.w

; ----------  Exec File Area Stuff  ---------------

Xfer_Path:    dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Cmnd_Line:    dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Environment:  dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Rcv_File:                      ; Receive A File....
     movem.l  a0-a1/d5,-(a7)
     move.l   #Cmnd_Line,a0
     move.l   a0,a1
     move.l   #83,d5
Rcv_F0:                        ; Clear out Command Line
     move.b   #0,(a0)+
     dbra     d5,Rcv_F0
     move.b   #0,(a1)+         ; dummy byte - will hold length of
                               ; the command line...
     cmp.w    #0,Use_Crc
     bne      Rcv_F2
     move.b   #"-",(a1)+       ; Receive file with xmodem-checksum
     move.b   #"X",(a1)+
     move.b   #" ",(a1)+
     move.b   #"-",(a1)+
     move.b   #"C",(a1)+
     move.b   #" ",(a1)+
     bsr      Copy_Filename
     bra      Rcv_F10

Rcv_F2:
     cmp.w    #1,Use_Crc
     bne      Rcv_F4
     move.b   #"-",(a1)+       ; Receive file with Xmodem-Crc
     move.b   #"X",(a1)+
     move.b   #" ",(a1)+
     bsr      Copy_Filename
     bra      Rcv_F10

Rcv_F4:
     cmp.w    #2,Use_Crc
     bne      Rcv_F6
     move.b   #"-",(a1)+       ; Receive file with Ymodem
     move.b   #"X",(a1)+
     move.b   #" ",(a1)+
     bsr      Copy_Filename
     bra      Rcv_F10

Rcv_F6:
     cmp.w    #3,Use_Crc
     bne      Rcv_F8
     move.b   #"-",(a1)+       ; Receive file with Ymodem Batch
     move.b   #"Y",(a1)+
     move.b   #" ",(a1)+
     move.b   #"-",(a1)+
     move.b   #"A",(a1)+
     move.b   #" ",(a1)+
     move.b   #"-",(a1)+
     move.b   #"T",(a1)+
     move.b   #" ",(a1)+
;     move.b   #"-",(a1)+
;     move.b   #"V",(a1)+
;     move.b   #" ",(a1)+
     bsr      Copy_Pathname
     move.b   #0,-(a1)
     bra      Rcv_F10

Rcv_F8:                        ; Receive file with Zmodem
     move.b   #"-",(a1)+
     move.b   #"Z",(a1)+
     move.b   #" ",(a1)+
     move.b   #"-",(a1)+
     move.b   #"A",(a1)+
     move.b   #" ",(a1)+
     move.b   #"-",(a1)+
     move.b   #"T",(a1)+
     move.b   #" ",(a1)+
;     move.b   #"-",(a1)+
;     move.b   #"V",(a1)+
;     move.b   #" ",(a1)+
     bsr      Copy_Pathname
     move.b   #0,-(a1)

Rcv_F10:
     move.l   #Cmnd_Line,a0    ; Compute the length of the
     move.l   a0,a1            ; Command Line, then insert it
     add.l    #1,a1
     move.l   #0,d5
Rcv_F11:
     move.b   (a1)+,d0
     cmp.b    #0,d0
     beq      Rcv_F12
     add.b    #1,d5
     bra.s    Rcv_F11
Rcv_F12:
     move.b   d5,(a0)
     move.l   Cur_Dir_Adr,a0
     move.l   #Xfer_Path,a1
     move.l   #70,d5
Rcv_F13:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      Rcv_F14
     move.b   d0,(a1)+
     bra.s    Rcv_F13
Rcv_F14:
     move.l   #XYZ_TTP,a0
Rcv_F15:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     cmp.b    #0,d0
     beq      Rcv_F16
     bra.s    Rcv_F15
Rcv_F16:
     movem.l  (a7)+,a0-a1/d5
     bsr      CrLf
     move.l   #Xfer_Path,Text_Adr
     bsr      Send_Console
     bsr      CrLf
     move.l   #Cmnd_Line,Text_Adr
     bsr      Send_Console
     bsr      CrLf
     move.l   #Xfer_Path,Fo1+2
     movem.l  a0-a6/d1-d7,-(a7)
     move.l   #Environment,-(a7)
     move.l   #Cmnd_Line,-(a7)
     move.l   #Xfer_Path,-(a7)
     move.w   #0,-(a7)         ; 0 = Load & Start, 3 = Load Only...
     move.w   #$4b,-(a7)
     trap     #1               ; Execute Xyz.ttp
     add.l    #16,sp
     bsr      Show_Error
     bsr      Put_Screen
     movem.l  (a7)+,a0-a6/d1-d7
     rts

XYZ_TTP:
     dc.b     "XYZ.TTP",0,0,0
     align.w

Copy_Filename:
     bsr      Copy_Pathname
     move.l   #LineIn,a0
Copy_Fn1:
     move.b   (a0)+,d1
     cmp.b    #Cr,d1
     beq      Copy_Fn2
     move.b   d1,(a1)+
     bra.s    Copy_Fn1
Copy_Fn2:
     move.b   #0,(a1)+
     rts

Copy_Pathname:
     bsr      Get_Sig_Path
     move.l   #F_PName2,a0
     move.l   #79,d5
Copy_Path1:
     move.b   (a0)+,d1
     cmp.b    #0,d1
     beq      Copy_Path2
     move.b   d1,(a1)+
     dbra     d5,Copy_Path1
Copy_Path2:
     rts

Do_Download:
     bsr      CrLf
     bsr      CrLf
     move.l   #Ask_Dl_Fname,Text_Adr
     bsr      String_Out
     bsr      FName_Parse
     cmp.w    #0,Carrier
     beq      Do_D8
     cmp.w    #0,FName_Ok
     beq      Do_D8
     bsr      Copy_FName
     bsr      See_Exist
     cmp.w    #1,Exist
     beq      Do_Down
     bra      Do_D8

Do_Down:
     bsr      Check_DL_Ratio
     cmp.w    #1,Need_Uploads
     beq      Do_D7
     clr.l    d0
     move.w   Min_Needed,d0
     cmp.l    TimeLeft,d0
     blt      Do_D0
     move.l   #Need_Time_Msg,Text_Adr
     bsr      Line_Out
     bra      Do_D8

Need_Time_Msg:
     dc.b     Cr,Lf,Cr,Lf,"  You Do NOT Have Enough Time Remaining",Cr,Lf
     dc.b     " To Download This File!!!",Cr,Lf,0
     align.w

Dwn_Protocols:
     dc.b     Cr,Lf,Cr,Lf,"[/rA/b] Ascii",Cr,Lf
     dc.b     "[/rX/b] Xmodem",Cr,Lf
     dc.b     "[/rC/b] Xmodem Crc",Cr,Lf
     dc.b     "[/rK/b] Ymodem (Xmodem 1k)",Cr,Lf
     dc.b     "[/rY/b] Ymodem Batch",Cr,Lf
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "Enter Transfer Protocol ->",0
     align.w

Do_D0:
     Move.l   #Dwn_Protocols,Text_Adr
     bsr      String_Out
Do_D1:
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Do_D8
Do_D1b:
     cmp.w    #Cr,d0
     beq      Do_D8
     cmp.w    #"A",d0
     bne      Do_D2
     move.l   #Ascii_Msg,Text_Adr
     bsr      Line_Out
     move.l   #F_PName2,Fo1+2
     bsr      View_File
     bra      Do_D7

Do_D2:
     cmp.w    #"X",d0
     bne      Do_D3
     move.l   #Xmodem_Msg,Text_Adr
     bsr      Line_Out
     move.l   #F_PName2,Fo1+2
     bsr      Send_Xmodem
     bra      Do_D7

Do_D3:
     cmp.w    #"C",d0
     bne      Do_D4
     move.l   #Xmodem_Crc_Msg,Text_Adr
     bsr      Line_Out
     move.l   #F_PName2,Fo1+2
     bsr      Send_Xmodem_Crc
     bra      Do_D7

Do_D4:
     cmp.w    #"K",d0
     bne      Do_D5
     move.l   #Ymodem_Msg,Text_Adr
     bsr      Line_Out
     move.l   #F_PName2,Fo1+2
     bsr      Send_Ymodem
     bra.s    Do_D7

Do_D5:
     cmp.w    #"Y",d0
     bne      Do_D6
     move.l   #Ymodem_Batch_Msg,Text_Adr
     bsr      Line_Out
     bsr      Send_Ybatch
     bra.s    Do_D7
Do_D6:
     bra      Do_D1
Do_D7:
     bsr      Clear_Screen
     move.l   #Xfer_Cmplt,Text_Adr
     bsr      Line_Out
Do_D8:
     rts

Xfer_Cmplt:   dc.b  Cr,Lf,"Transfer Completed...",Cr,Lf,0
              align.w

Send_Xmodem:
     bsr      Ask_HangUp
     move.l   #Start_Xfer_Msg,Text_Adr
     bsr      Line_Out
     move.l   #Transfer_Screen,Text_Adr
     bsr      Send_Console
     move.l   #Prot_Msg1,Text_Adr
     bsr      Send_Console
     move.w   #0,Use_Crc
     move.w   #Soh,Header_Ch
     move.w   #128,Block_Size
     bsr      Send_File
     cmp.w    #1,Hang_Up
     bne      Snd_X1
     bsr      Disconnect
Snd_X1:
     rts

Send_Xmodem_Crc:
     bsr      Ask_HangUp
     move.l   #Start_Xfer_Msg,Text_Adr
     bsr      Line_Out
     move.l   #Transfer_Screen,Text_Adr
     bsr      Send_Console
     move.l   #Prot_Msg1,Text_Adr
     bsr      Send_Console
     move.w   #1,Use_Crc
     move.w   #Soh,Header_Ch
     move.w   #128,Block_Size
     bsr      Send_File
     cmp.w    #1,Hang_Up
     bne      Snd_Xc1
     bsr      Disconnect
Snd_Xc1:
     rts

Send_Ymodem:
     bsr      Ask_HangUp
     move.l   #Start_Xfer_Msg,Text_Adr
     bsr      Line_Out
     move.l   #Transfer_Screen,Text_Adr
     bsr      Send_Console
     move.l   #Prot_Msg2,Text_Adr
     bsr      Send_Console
     move.w   #1,Use_Crc
     move.w   #Stx,Header_Ch
     move.w   #1024,Block_Size
     bsr      Send_File
     cmp.w    #1,Hang_Up
     bne      Snd_Y1
     bsr      Disconnect
Snd_Y1:
     rts

Send_YBatch:
     movem.l  a2-a6,-(a7)
     bsr      Ask_HangUp
     move.l   #Start_Xfer_Msg,Text_Adr
     bsr      Line_Out
     move.l   #Transfer_Screen,Text_Adr
     bsr      Send_Console
     move.l   #Prot_Msg3,Text_Adr
     bsr      Send_Console
     move.w   #0,Bm_Cntr
     move.w   Bm_Num,Bm_Temp
     cmp.w    #0,Bm_Num
     bne      Snd_Yb1
     bra      Snd_Yb4
Snd_Yb1:
     clr.l    d0
     move.w   Bm_Cntr,d0
     mulu     #26,d0
     move.l   #Bm_File,a6
     add.l    d0,a6
     move.w   0(a6),Sig_Num    ; Sig Number
     move.l   2(a6),YB_Siz     ; File Size
     add.l    #8,a6
     bsr      Get_Sig_Path
     move.l   F_PName_Adr,a4
     move.l   #69,d5
Snd_Yb2:
     move.b   #0,(a4)+         ; Clear Out
     dbra     d5,Snd_Yb2       ;  Filename Area...
     move.l   #129,d5
     move.l   #Block_Data,a4
Mky1:
     move.b   #0,(a4)+         ; Clear out Data Buff
     dbra     d5,Mky1

     move.l   F_PName_Adr,a2
     move.l   #Block_Data,a3
Snd_Yb3:
     move.b   (a6)+,d0         ; Copy Batch
     cmp.b    #" ",d0          ;  Filename
     bne      Snd_Yb3a
     move.b   #0,(a2)+
     move.b   #0,(a3)+
     bra.s    Snd_Yb3b
Snd_Yb3a:
     move.b   d0,(a2)+
     move.b   d0,(a3)+
     bra.s    Snd_Yb3
Snd_Yb3b:
     move.l   #YB_Size,a3
     move.l   YB_Siz,d0
     bsr      PDec8
     move.l   #YB_Size,a0
     move.l   #7,d5
     bsr      Left_Just
     move.l   #YB_Size,a0
     move.l   #7,d5
Snd_Yb3c:
     move.b   (a0),d0
     cmp.b    #" ",d0
     beq      Snd_Yb3d
     dbra     d5,Snd_Yb3c
Snd_Yb3d:
     move.b   #0,(a2)+
     move.b   #0,(a3)+
Snd_Yb4:
     bsr      Show_Filename
     bsr      Flush_Inp
     bsr      Init_Handshake
     cmp.w    #0,Carrier
     beq      Snd_Yb9
     cmp.w    #"C",Char        ; If Char was a "C" then Continue
     beq      Snd_Yb5
     bra      Snd_Yb9          ; Otherwise Stop the Transfer...

Snd_Yb5:
     move.w   #1,Use_Crc
     move.w   #128,Block_Size  ; Send
     move.w   #Soh,Header_Ch   ;  Ymodem
     move.w   #0,Block_Number  ;   Batch
     bsr      Send_Block       ;    Header
     cmp.w    #0,Carrier
     beq      Snd_Yb9

     cmp.w    #Ack,Char
     beq      Snd_Yb6
     bra      Snd_Yb9
Snd_Yb6:
     move.w   #1,Use_Crc
     move.w   #Stx,Header_Ch
     move.w   #1024,Block_Size
     move.l   #F_PName2,Fo1+2
     bsr      Send_File
     cmp.w    #0,Carrier
     beq      Snd_Yb9
     add.w    #1,Bm_Cntr
     sub.w    #1,Bm_Temp
     cmp.w    #0,Bm_Temp
     bgt      Snd_Yb1
Snd_Yb7:
     move.w   #Eot,Char
     bsr      Put_Modem
     bsr      Handle_Ack_Nak   ; Wait for response
     cmp.w    #0,Carrier
     beq      Snd_Yb9
     cmp.w    #Ack,Char        ; If it wasn't an "ACK" then Repeat
     beq      Snd_Yb8
     cmp.w    #Can,Char
     beq      Snd_Yb9
     cmp.w    #"C",Char
     beq      Snd_Yb8c
Snd_Yb8:
     bsr      Handle_Ack_Nak
     cmp.w    #0,Carrier
     beq      Snd_Yb9
     cmp.w    #"C",Char
     beq      Snd_Yb8c
     cmp.w    #Ack,Char
     beq      Snd_Yb7
     cmp.w    #Can,Char
     beq      Snd_Yb9
     bra.s    Snd_Yb7
Snd_Yb8c:
     bsr      Send_NullName
     move.w   #0,Bm_Num
     cmp.w    #1,Hang_Up
     bne      Snd_Yb8d
     bsr      Disconnect
Snd_Yb8d:
     bsr      Clear_Screen
     move.l   #Xfer_Cmplt,Text_Adr
     bsr      Line_Out
Snd_Yb9:
     movem.l  (a7)+,a2-a6
     rts

YB_Siz:       dc.l  0
YB_Size:      dc.b  "00000000  ",0,0

Ask_Hangup:
     move.w   #0,Hang_Up
     move.l   #HangUp_Msg,Text_Adr
     bsr      String_Out
     move.w   #1,Caps
     move.w   #0,Echo
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Ask_H2
     cmp.w    #"Y",Char
     bne      Ask_H1
     move.w   #1,Hang_Up
Ask_H1:
     bsr      CrLf
     bsr      CrLf
Ask_H2:
     rts

Send_File:
     move.l   #Dis_Cur,Text_Adr
     bsr      Send_Console
     move.l   #0,Tot_Bytes
     move.l   #F_PName2,SFirst1+2
     bsr      SFirst
     bsr      Get_FileInfo
SF_0:
     bsr      Show_Filename
     cmp.w    #128,Block_Size
     bne      SF_1
     move.l   #F_XBlks1,Text_Adr
     bra.s    SF_2
SF_1:
     move.l   #F_YBlks1,Text_Adr
SF_2:
     bsr      Send_Console
     move.w   #0,Block_Count
     move.w   #0,Block_Number
     move.w   #0,Send_Errs
     move.w   #0,Eof_Xfile
     move.w   Header_Ch,New_Header_Ch
     move.w   #0,File_Mode
     bsr      FOpen
     move.l   Fil_Sizt,Xfile_Size  ; Size of File...
     bsr      Flush_Inp
     bsr      Init_Handshake
     cmp.w    #0,Carrier
     beq      Snd_F21
     cmp.w    #Timeout,Char
     beq      Snd_F20
     cmp.w    #Can,Char
     beq      Snd_F20
Snd_F0:
     cmp.w    #1,Stop_Send
     bne      Snd_F1
     bra      Snd_F7

Snd_F1:
     add.w    #1,Block_Count
     bsr      Chk_Kybrd
     bsr      Chk_Carrier
     cmp.w    #0,Carrier
     beq      Snd_F21
Snd_F1a:
     Cmp.w    #1,Stop_Send
     bne      Snd_F2
     bra      Snd_F7

Snd_F2:
     bsr      Fill_Block       ; Fill Block with Ctrl-Z's
     move.w   New_Header_Ch,Header_Ch
     clr.l    d1
     move.w   Block_Size,d1
     move.l   d1,Num_Bytes
     bsr      FRead            ; Read in Part of File...
     cmp.w    #0,d0            ;
     bgt      Snd_F3           ;

     move.w   #1,Eof_XFile     ; We're at the end of file...
     bra      Snd_F7
Snd_F3:
     move.l   #File_Buf,a0
     move.l   #Block_Data,a1
     move.l   N_Read,d5
     sub.w    #1,d5
Snd_F3a:
     move.b   (a0)+,(a1)+
     dbra     d5,Snd_F3a
     move.w   Block_Number,d0
     add.w    #1,d0
     and.w    #$ff,d0
     move.w   d0,Block_Number
     bsr      Send_Block       ; Send This Block
     cmp.w    #0,Carrier
     beq      Snd_F21
     Cmp.w    #Ack,Char        ; Did Receiver Get it Ok?
     bne      Snd_F4           ; No,
     clr.l    d0
     move.w   Block_Size,d0
     add.l    d0,Tot_Bytes
     bsr      Show_FBytes
     bra      Snd_F6
Snd_F4:
     add.w    #1,Send_Errs
     bsr      Show_Errs_Msg

Snd_F5:
     move.w   #1,Where
     move.l   N_Read,d0
     move.l   d0,How_Many
     bsr      Lseek
     move.l   XFile_Size,d0
     add.l    N_Read,d0
     move.l   d0,XFile_Size
Snd_F6:
     move.l   XFile_Size,d0
     sub.l    N_Read,d0
     move.l   d0,XFile_Size
     cmp.w    #128,Block_Size
     beq      Snd_F6a
     cmp.l    #1024,XFile_Size
     bge      Snd_F6a
     move.w   #Soh,New_Header_Ch
     move.w   #128,Block_Size
Snd_F6a:
     cmp.w    #1,Eof_Xfile     ;
     beq      Snd_F7
     cmp.w    #Can,Char        ;
     beq      Snd_F7
     cmp.w    #10,Tries        ;
     bgt      Snd_F7
     cmp.w    #1,Stop_Send     ;
     beq      Snd_F7
     bra      Snd_F1

Snd_F7:
     cmp.w    #1,Stop_Send
     bne      Snd_F8
     bsr      Show_SysAbrt_Msg
     bra.s    Snd_F11
Snd_F8:
     cmp.w    #Can,Char
     bne      Snd_F9
     move.l   #Send_Msg4,Text_Adr
     bsr      Send_Console
     bra.s    Snd_F11
Snd_F9:
     cmp.w    #10,Tries
     bgt      Snd_F20
     move.l   #Send_Msg3,Text_Adr
     bsr      Send_Console
     bra.s    Snd_F11
Snd_F10:
     cmp.w    #0,Carrier
     bne      Snd_F11
     move.l   #Send_Msg2,Text_Adr
     bsr      Send_Console
Snd_F11:
     cmp.w    #0,Stop_Send
     bne      Snd_F20
Snd_F12:
     move.w   #Eot,Char
     bsr      Put_Modem
     move.w   #6,Seconds
     bsr      Wait_Ch
     cmp.w    #0,Carrier
     beq      Snd_F21
     bsr      Chk_Kybrd
     cmp.w    #Ack,Char        ; Wait until we get an Ack,
     beq      Snd_F13          ; Tries>Max Tries, Can or Stop Send
     cmp.w    #11,Tries
     beq      Snd_F13
     cmp.w    #Can,Char
     beq      Snd_F13
     cmp.w    #1,Stop_Send
     beq      Snd_F13
     bra.s    Snd_F12           ; Not What We Want, So Try Again
Snd_F13:
     cmp.w    #11,Tries
     bne      Snd_F17
     move.l   #Send_Msg5,Text_Adr
     bsr      Send_Console
     bra      Snd_F20
Snd_F17:
     cmp.w    #Can,Char
     bne      Snd_F18
     move.l   #Send_Msg4,Text_Adr
     bsr      Send_Console
     bsr      WRITE_DWNLD_ABRT
     bra.s    Snd_F20
Snd_F18:
     cmp.w    #1,Stop_Send
     bne      Snd_F19
     bsr      Show_SysAbrt_Msg
     bra.s    Snd_F20
Snd_F19:
     bsr      FClose
     move.l   #Send_Msg6,Text_Adr ; Receiver Got the File Ok, So
     bsr      Send_Console        ; increment downloads by one...
     add.w    #1,Downlds
     bsr      Cvrt_Dl_Stats
     bsr      WRITE_DWNLD_OK      ; ANd WRITE INFO TO LOG FILE
     bsr      Update_Description
     bra.s    Snd_F21
Snd_F20:
     bsr      FClose
Snd_F21:
     move.l   #Ena_Cur,Text_Adr
     bsr      Send_Console
Snd_F30:
     rts

Ena_Cur:      dc.b  Esc,"e",0,0
Dis_Cur:      dc.b  Esc,"f",0,0    ; Disable Cursor

Send_Block:
     movem.l  a3-a5/d4-d5,-(a7)
     move.w   #1,Tries
     move.w   #0,Stop_Send
Snd_Blk1:
     bsr      Show_Snd_Msg
     bsr      Show_Tries
     clr.l    d0
     move.w   Block_Count,d0
     move.l   #Blck_Num1b,a3
     bsr      Pdec4
     move.l   #Blck_Num1a,Text_Adr
     bsr      Send_Console
     move.w   Header_Ch,Char    ; Send Header <Soh,Stx>
     bsr      Put_Modem
     move.w   Block_Number,Char ; Send Block Number
     bsr      Put_Modem
     move.w   #255,d0
     sub.w    Block_Number,d0
     move.w   d0,Char
     bsr      Put_Modem         ; Send One's Compliment of Block#
     cmp.w    #1,Use_Crc
     bne      Snd_Blk3

     move.w   #0,Crc           ; This Routine Calculates the CRC
     move.l   #Block_Data,a5    ; Checksum Bytes ...
     move.w   Block_Size,d1
     add.w    #1,d1
     add.w    d1,a5
     move.b   #0,(a5)+
     move.b   #0,(a5)+
     move.l   #Block_Data,a5
     clr.l    d5
     move.w   Block_Size,d5
     sub.l    #1,d5
Snd_Blk2:
     clr.l    d0
     move.b   (a5)+,d0
     move.l   d0,d1
     move.w   d0,c             ; Get Byte From Block
     bsr      UpdateCrc        ; And add it to CRC Val
     move.w   d1,Char
     bsr      Put_Modem        ; Send a Byte From Block
     dbra     d5,Snd_Blk2      ; Continue Till all are sent

     move.l   #Block_Data,a5
     move.w   Block_Size,d1
     add.w    #1,d1
     add.w    d1,a5
     clr.l    d4
     move.b   (a5)+,d4
     move.w   d4,c
     bsr      UpdateCrc
     move.b   (a5)+,d4
     move.w   d4,c
     bsr      UpdateCrc
     move.w   Crc,d0
     move.b   d0,LoCrc
     lsr.w    #8,d0
     move.b   d0,HiCrc
     clr.l    d0
     move.b   HiCrc,d0
     move.w   d0,Char
     bsr      Put_Modem
     clr.l    d0
     move.b   LoCrc,d0
     move.w   d0,Char
     bsr      Put_Modem
     bra.s    Snd_Blk5
Snd_Blk3:
     move.w   #0,CheckSum
     move.l   #Block_Data,a5
     clr.l    d1
     clr.l    d2
     clr.l    d5
     move.w   Block_Size,d5
     sub.l    #1,d5
Snd_Blk4:
     move.b   (a5)+,d1
     move.w   d1,Char
     bsr      Put_Modem
     add.b    d1,d2
     dbra     d5,Snd_Blk4
     and.w    #$ff,d2
     move.w   d2,Char
     bsr      Put_Modem
Snd_Blk5:
     bsr      Flush_Inp
     add.w    #1,Tries
     bsr      Show_Wait_Msg

     bsr      Handle_Ack_Nak
     cmp.w    #0,Carrier
     beq      Snd_Blk6
     cmp.w    #Ack,Char        ; Did Receiver Get it ok?
     beq      Snd_Blk6
     cmp.w    #Can,Char        ;
     beq      Snd_Blk6
     cmp.w    #11,Tries        ;
     beq      Snd_Blk6
     cmp.w    #1,Stop_Send     ;
     beq      Snd_Blk6
     bra      Snd_Blk1
Snd_Blk6:
     movem.l  (a7)+,a3-a5/d4-d5
     rts

Say_GoodBye:  dc.b  Cr,Lf,Cr,Lf,"  Thanks For Calling",Cr,Lf
              dc.b  "Please Call Back Again...",Cr,Lf,0
              align.w

Disconnect:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Say_GoodBye,Text_Adr
     bsr      Line_Out
     move.w   #16,-(a7)
     move.w   #30,-(a7)
     trap     #14              ; Drop DTR Line...
     addq.l   #4,sp
Dscn1:
     move.w   #5,Seconds
     bsr      Pause
     move.w   #6,-(a7)
     move.w   #29,-(a7)
     trap     #14              ; Raise DTR Line...
     addq.l   #4,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Fill_Block:
     clr.l    d5
     move.w   Block_Size,d5
     sub.w    #1,d5
     move.l   #Block_Data,a0
Fill_B1:
     move.b   #26,(a0)+        ; Fill Block with Ctrl-Z
     dbra     d5,Fill_B1
     rts

Send_NullName:
Snd_Nul0:
     move.w   #Soh,Char
     bsr      Put_Modem
     move.w   #0,Char
     bsr      Put_Modem
     move.w   #255,Char
     bsr      Put_Modem
     move.l   #129,d5
Snd_Nul1:
     move.w   #0,Char
     bsr      Put_Modem
     dbra     d5,Snd_Nul1
     move.w   #10,Seconds
     bsr      Wait_Ch
     cmp.w    #0,Carrier
     beq      Snd_Nul3
     cmp.w    #Ack,Char
     bne      Snd_Nul0
     move.l   #EobAck_Msg,Text_Adr
     bsr      Send_Console
     bra.s    Snd_Nul3
Snd_Nul2:
     move.l   #EobNak_Msg,Text_Adr
     bsr      Send_Console
Snd_Nul3:
     rts

Init_HandShake:
     bsr      Show_Wait_Msg
     move.w   #0,Tries
     move.w   #10,Seconds
Int_H1:
     bsr      Show_Tries
     bsr      Wait_Ch
     cmp.w    #0,Carrier
     beq      Int_H6
     cmp.w    #Can,Char        ; If it was a 'CAN' Insist apon another
     bne      Int_H1a
     bsr      Wait_Ch
     cmp.w    #0,Carrier
     BEQ      INT_H6
Int_H1a:
     move.w   Char,Char_Tmp
     add.w    #1,Tries
     cmp.w    #11,Tries
     beq      Int_H2
     cmp.w    #Nak,Char
     beq      Int_H2
     cmp.w    #Can,Char
     beq      Int_H2
     cmp.w    #"C",Char
     beq      Int_H2
     cmp.w    #1,Stop_Send
     bne      Int_H1
Int_H2:
     cmp.w    #Nak,Char
     bne      Int_H3
     move.w   #0,Use_Crc
     move.l   #Crc_Msg2,Text_Adr
     bsr      Send_Console
     bra.s    Int_H5
Int_H3:
     cmp.w    #"C",Char
     bne      Int_H4
     move.w   #1,Use_Crc
     move.l   #Crc_Msg1,Text_Adr
     bsr      Send_Console
     bra.s    Int_H5
Int_H4:
     move.l   #RcvTimout_Msg,Text_Adr
     bsr      Send_Console
Int_H5:
     move.w   Char_Tmp,Char
Int_H6:
     rts

Handle_Ack_Nak:
     move.w   #10,Seconds
     bsr      Wait_Ch
     cmp.w    #0,Carrier
     beq      H_an9
     move.w   Char,Char_Tmp
     cmp.w    #Can,Char
     bne      H_an1
     bsr      Show_Can_Msg
     bsr      Wait_Ch
     cmp.w    #0,Carrier
     beq      H_an9
H_an1:
     cmp.w    #Ack,Char
     bne      H_an2
     bsr      Show_Ack_Msg
     bra.s    H_an3
H_an2:
     cmp.w    #Nak,Char
     bne      H_an3
     bsr      Show_Nak_Msg
H_an3:
     cmp.w    #Can,Char
     bne      H_an4
     bsr      Show_Can_Msg
H_an4:
     cmp.w    #"C",Char
     bne      H_an5
     move.l   #Crci_Msg,Text_Adr
     bsr      Send_Console
H_an5:
     cmp.w    #Eot,Char
     bne      H_an6
     move.l   #Eot_Msg,Text_Adr
     bsr      Send_Console
H_an6:
     cmp.w    #Soh,Char
     bne      H_an7
     move.l   #Soh_Msg,Text_Adr
     bsr      Send_Console
H_an7:
     cmp.w    #Stx,Char
     bne      H_an8
     move.l   #Stx_Msg,Text_Adr
     bsr      Send_Console
H_an8:
     move.w   Char_Tmp,Char
H_an9:
     rts

Show_SysAbrt_Msg:
     move.l   #Send_Msg1,Text_Adr
     bsr      Send_Console
     rts

Show_Can_Msg:
     move.l   #Can_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Ack_Msg:
     move.l   #Ack_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Nak_Msg:
     move.l   #Nak_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Eot_Msg:
     move.l   #Eot_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Snd_Msg:
     move.l   #Msg1_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Rcv_Msg:
     move.l   #Msg2_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Wait_Msg:
     move.l   #Msg3_Msg,Text_Adr
     bsr      Send_Console
     rts

Show_Errs_Msg:
     clr.l    d0
     move.w   Send_Errs,d0
     move.l   #Errs2_Msg,a3
     bsr      Pdec4
     move.l   #Errs1_Msg,Text_Adr
     bsr      Send_Console
     rts

Pause:
     bsr      Get_Timer
     move.l   Timer,d0
     clr.l    d1
     cmp.w    #0,Seconds
     bne      Pause0
     move.w   #50,d1
     bra.s    Pause1
Pause0:
     move.w   Seconds,d1
     mulu     #222,d1
Pause1:
     add.l    d1,d0
     move.l   d0,Max_Time
Pause2:
     bsr      Get_Timer
     move.l   Timer,d0
     cmp.l    Max_Time,d0
     blt.s    Pause2
     rts

Wait_Ch:
     move.w   #0,Stop_Send
     bsr      Get_Timer
     move.l   Timer,d0
     clr.l    d1
     move.w   Seconds,d1
     mulu     #222,d1
     add.l    d1,d0
     move.l   d0,Max_Time
Wt_Ch1:
     bsr      Chk_Kybrd
     cmp.w    #1,Stop_Send
     beq.s    Wt_Ch5           ; Sysop Terminated Transfer
     bsr      Scan_Modem
     cmp.w    #0,Char          ; Anything Comming From Modem
     beq.s    Wt_Ch2           ; Nope ->
     bra.s    Wt_Ch5           ; Yep, So Exit
Wt_Ch2:
     bsr      Get_Timer
     move.l   Timer,d0
     cmp.l    Max_Time,d0
     bgt.s    Wt_Ch4
     bsr      Chk_Carrier      ; Check For Carrier, Quit if lost
     cmp.w    #0,Carrier
     beq      Wt_Ch4
Wt_Ch3:
     bra.s    Wt_Ch1
Wt_Ch4:
     move.w   #TimeOut,Char    ; TimeOut From Modem
Wt_Ch5:
     rts

Chk_Kybrd:
     bsr      Scan_Console
     cmp.w    #0,d0
     beq      Chk_Kyb1
     cmp.w    #Can,Char
     bne      Chk_Kyb1
     move.w   #1,Stop_Send
Chk_Kyb1:
     rts

Sig_Empty_Msg:  dc.b  Cr,Lf,Cr,Lf,"This Sig Doesn't Have Any Files!!!",Cr,Lf,Cr,Lf,0
                align.w

Sig_Last_Msg: dc.b  Cr,Lf,Cr,Lf,"No More Files In This Sig!!!",Cr,Lf,0
              align.w

Max_Lin_Msg:  dc.b  Cr,Lf,"Enter Description (10 Lines Max!)",Cr,Lf,0
              align.w
Edt_Md:       dc.w  0

Enter_Msg:
;     movem.l  a4/d5,-(a7)
;     move.l   #File_Ok,a4
;     move.l   #880,d5
En_M0:
;     move.b   #0,(a4)+
;     dbra     d5,E_M0
     move.w   #0,Line_No
     move.l   #Max_Lin_Msg,Text_Adr
     bsr      Line_Out
;     movem.l  (a7)+,a4/d5

Enter_Msg2:
     movem.l  a0-a6/d0-d6,-(a7)
E_M0:
     move.w   #0,No_Color
     move.l   #Red_Inv,Text_Adr
     bsr      String_Out
     move.w   #1,No_Color
     move.l   #Msg_Edit,Text_Adr ; Show Main Commands
     bsr      String_Out
     move.w   #0,No_Color
     move.l   #Inv_Red,Text_Adr
     bsr      Line_Out
E_M1:
     move.w   #0,Edt_Md
     move.l   Mesg_Area,a4
     clr.l    d0
     move.w   Line_No,d0
     mulu     #80,d0
     add.l    d0,a4            ; a4 points to line offset
E_M2:
     move.l   a4,Lst_Line
;     bsr      Show_Regs
     bsr      Enter_Line       ;Go Get a Line
;     bsr      Show_Regs
     cmp.w    #"/",Char
     beq      E_M3
     cmp.w    #0,Carrier
     beq      E_Mxit
     bsr      CrLf
     cmp.w    #9,Line_No
     bhi      E_M3
     cmp.w    #1,Edt_Md
     beq      E_M1
     add.w    #1,Line_No
     cmp.w    #11,Line_No
     blt      E_M1

E_M3:
     bsr      Back_Space
     bsr      Back_Space
     move.w   #0,No_Color
     move.l   #Msg_Prompt,Text_Adr
     bsr      String_Out
E_M4:
     move.w   #1,Caps
     move.w   #0,Echo
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      E_Mxit
     cmp.w    #"D",Char          ; Delete a Line
     bne      E_M5
     cmp.w    #0,Line_No
     beq      E_M1
     move.l   #Del_Msg1,Text_Adr
     bsr      String_Out
     bsr      Get_Lin_Info
     cmp.w    #0,Strt
     beq      E_M1
     bsr      Delete_A_Line
     bra      E_M1
E_M5:
     cmp.w    #"A",Char        ; Abort Message?
     bne      E_M6
     cmp.w    #1,Local
     bne      E_M1
     move.l   #Abrt_Msg1,Text_Adr
     bsr      String_Out
E_M5a:
     move.w   #1,Caps
     move.w   #0,Echo
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      E_Mxit
     cmp.w    #"Y",Char
     bne      E_M5b
     move.l   #Yes_Msg,Text_Adr
     bsr      Line_Out
     move.w   #1,Nsv
     bra      E_Mxit
Nsv: dc.w     0
E_M5b:
     cmp.w    #"N",Char
     bne      E_M5a
     MOVE.L   #NO_MSG,TEXT_ADR
     bsr      Line_Out
     bra      E_M1

E_M6:
     cmp.w    #"E",Char        ; Edit Message?
     bne      E_M8
     bsr      Back_Space
     bsr      Back_Space
     bsr      Back_Space
     cmp.w    #0,Line_No
     beq      E_M2
     move.l   #EM_Msg2,Text_Adr ; Edit Which Line (1-
     bsr      String_Out
     clr.l    d0
     move.w   Line_No,d0
     move.l   #D_L_Num,a3
     bsr      Pdec4
     move.l   #D_L_Num,a0
     bsr      Prt_Num           ; Last Line#
     move.l   #EM_Msg3,Text_Adr ; ") ?"
     bsr      String_Out
E_M7:
     move.w   Line_No,d6
     add.w    #"0",d6
     move.w   #0,Echo
     bsr      Get_Char         ; Get Line # to Edit
     cmp.w    #0,Carrier
     beq      E_Mxit
     move.w   Char,d4
     cmp.w    #"1",d4
     blt      E_M1              ; Exit if less than "1"
     cmp.w    d6,d4
     bgt      E_M7a             ; Exit if Greater Than Last Line#
     bsr      Put_Char
     move.l   Mesg_Area,a4
     clr.l    d0
     move.w   d4,d0
     sub.w    #$31,d0
     mulu     #80,d0
     add.l    d0,a4
     move.l   #EM_Msg4,Text_Adr  ; Old Line Reads
     bsr      Line_Out
     move.l   a4,Text_adr        ; Print Old Line
     bsr      Line_Out
     move.w   #1,Edt_Md
     bra      E_M2
E_M7a:
     bsr      Back_Space
     bra      E_M7
E_M8:
     cmp.w    #"S",Char          ; Save Text?
     bne      E_M10
     move.l   #Save_Msg,Text_Adr
     bsr      Line_Out
     cmp.w    #0,Line_No
     bne      E_M9
     move.l   #Not_Ent_Msg,Text_Adr
     bsr      Line_Out
     bra      En_M0
E_M9:
     bsr      Save_Message
     move.w   #0,No_Edit
     bsr      CrLf
     bra      E_Mxit
E_M10:
     cmp.w    #"B",Char
     bne      E_M11
     move.l   #Bgn_Ovr_Msg,Text_Adr
     bsr      String_Out
E_M10a:
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #"N",Char
     bne      E_M10b
     move.l   #No_Msg,Text_Adr
     bsr      Line_Out
     bra      E_M1
E_M10b:
     cmp.w    #"Y",Char
     bne.s    E_M10a
     move.l   #Yes_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,Line_No
     bra      E_M1
E_M11:
     cmp.w    #"C",Char
     bne      E_M12
     bsr      Back_Space
     bsr      Back_Space
     bsr      Back_Space
     move.l   #Column_Bar,Text_Adr
     bsr      Line_Out
     bra      E_M1
E_M12:
     cmp.w    #"F",Char
     bne      E_M13
     move.w   #0,Shw_Typ
     bsr      Clear_Screen
     bsr      Show_Msg
     bra      E_M1
E_M13:
     cmp.w    #"I",Char
     bne      E_M14
     move.l   #Ins_Msg1,Text_Adr     ; print "Insert Before (1-"
     bsr      String_Out
     clr.l    d0
     move.w   Line_No,d0
     move.l   #D_L_Num,a3
     bsr      Pdec4
     move.l   #D_L_Num,a0
     bsr      Prt_Num                 ; Print Last Line #
     move.l   #Ins_Msg2,Text_Adr      ; print ") Line ["
     bsr      String_Out
     move.l   #D_L_Num,a0
     bsr      Prt_Num                 ; Print Last Line # again
     move.l   #Ins_Msg3,Text_Adr
     bsr      String_Out              ; Print "]: "...
E_M13a:
     move.w   Line_No,Strt     ; Default...
     move.l   #2,Length
     bsr      Line_In          ; Get Line number
     cmp.w    #0,Carrier
     beq      E_MXit
     move.l   #LineIn,a0
     move.b   (a0),d0
     cmp.b    #Cr,d0
     beq      E_M13c
E_M13b:
     bsr      Asc2Bin
     cmp.w    #1,Binary_Word   ; was it less than 1?
     bcs      E_M1             ; yep,
     move.w   Binary_Word,d0
     cmp.w    Line_No,d0       ; or greater than Last Line# ?
     bhi      E_M13a           ; yep, so try again
     move.w   Binary_Word,Strt ; Store Starting line#
E_M13c:
     cmp.w    #10,Strt
     beq      E_M1
     clr.l    d0
     move.w   Strt,d0
     sub.w    #1,d0
     mulu     #80,d0
     move.l   Mesg_Area,a4
     add.l    d0,a4            ; a4 = Address Of New Line To Edit...
     move.l   a4,a1
     clr.l    d0
     move.w   Line_No,d0
     mulu     #80,d0
     sub.l    #1,d0
     add.l    d0,a1            ; a1 = Points to last byte of last line..
     move.l   a1,a0
     sub.l    #80,a0           ; a0 = Destn Address
     move.l   a0,d5
     sub.l    a4,d5
     sub.l    #1,d5            ; d5 = # of Bytes to Copy
E_M13e:
     move.b   -(a0),-(a1)      ; Copy lines...
     dbra     d5,E_M13e
     bsr      CrLf
     move.w   #0,No_Color
     move.l   #I_Prompt,Text_Adr
     bsr      String_Out
     bsr      Ent_Lin
     bsr      CrLf
     add.w    #1,Line_No
     bra      E_M1
E_M14:
     cmp.w    #"P",Char
     bne      E_M15
     move.w   Line_No,Char
     move.w   #1,Strt
E_M14a:
     move.l   Mesg_Area,a0
     clr.l    d0
     move.w   Strt,d0
     sub.w    #1,d0
     mulu     #80,d0
     add.l    d0,a0
     cmp.b    #0,(a0)
     beq      E_M14c
     move.l   a0,a1
     move.l   #79,d5
E_M14b:
     move.b   (a1)+,d0         ; check line to see if all spaces exist!
     cmp.b    #0,d0
     beq      E_M14c
     cmp.b    #" ",d0
     bne.s    E_M14d
     dbra     d5,E_M14b
E_M14c:
     move.w   Strt,Lst
     bsr      Delete_A_Line
     bra.s    E_M14d0
E_M14d:
     add.w    #1,Strt
E_M14d0:
     sub.w    #1,Char
     cmp.w    #0,Char
     bhi      E_M14a
E_M14e:
     move.l   #Packing_Msg,Text_Adr
     bsr      Line_Out
     bra      E_M1
E_M15:
     cmp.w    #"/",Char        ; Clear Screen
     bne      E_M16
     bsr      Clear_Screen
     bra      E_M1
E_M16:
     cmp.w    #"V",Char
     bne      E_M17
     cmp.w    #40,Video_Width
     bne      E_M16a
     move.w   #80,Video_Width
     move.l   #VW_Msg1,Text_Adr
     bra.s    E_M16b
E_M16a:
     move.w   #40,Video_Width
     move.l   #VW_Msg2,Text_Adr
E_M16b:
     bsr      Line_Out
     bra      E_M1

VW_Msg1:      dc.b  "Video Width Is Now 80",0
VW_Msg2:      dc.b  "Video Width Is Now 40",0

E_M17:
     cmp.w    #"W",Char
     bne      E_M20
     cmp.w    #0,WW_Toggle
     bne      E_M17a
     move.w   #1,WW_Toggle
     move.l   #WW_Tgl1_Msg,Text_Adr
     bra.s    E_M17b
E_M17a:
     move.w   #0,WW_Toggle
     move.l   #WW_Tgl2_Msg,Text_Adr
E_M17b:
     bsr      Line_Out
     bra      E_M1

WW_Tgl1_Msg:  dc.b  "Word Wrap Is Now On",0
WW_Tgl2_Msg:  dc.b  "Word Wrap Is Now Off",0,0

E_M20:
     cmp.w    #"L",Char          ; List Lines?
     bne      E_M25
     cmp.w    #0,Line_No
     bne      E_M20a
     move.l   #Not_Ent_Msg,Text_Adr
     bsr      Line_Out
     bra      E_M1
E_M20a:
     move.l   #Lst_Msg1,Text_Adr
     bsr      String_Out
     bsr      Get_Lin_Info
     move.w   #1,Shw_Typ
     move.w   #1,Line_Md
     bsr      Show_Msg
     move.l   Lst_Line,a4
     bra      E_M1
E_M25:
     cmp.w    #"N",Char        ; List Lines w/numbers ?
     bne      E_M30
     cmp.w    #0,Line_No
     beq      E_M2
     move.l   #Lst_Msg1,Text_Adr
     bsr      String_Out
     bsr      Get_Lin_Info
     move.w   #2,Shw_Typ
     move.w   #1,Line_Md
     bsr      Show_Msg
     move.l   Lst_Line,a4
     bra      E_M1
E_M30:
     cmp.w    #"?",Char
     bne      E_M40
     move.w   #0,No_Color
     move.l   #EM_Help,Text_Adr
     bsr      Line_Out
     bra      E_M1
E_M40:
     bra      E_M4
E_Mxit:
;     bsr      Show_Regs
;     move.w   #80,Seconds
;     bsr      Pause
     movem.l  (a7)+,a0-a6/d0-d6
     rts

Enter_Line:
     move.w   #0,No_Color
     move.l   #E_Prompt,Text_Adr
     bsr      String_Out
     cmp.w    #1,Word_Pending
     bne      Ent_Lin
     move.l   #Word_Temp,Text_Adr
     bsr      String_Out
     move.w   #0,Word_Pending
     move.l   #Word_Temp,a5
     move.w   Ky_Cnt,Char_No
     move.l   a5,a0
     clr.l    d5
     move.w   Ky_Cnt,d5
     sub.w    #1,d5
Cpy_Wrd0:
     move.b   (a0)+,(a4)+
     dbra     d5,Cpy_Wrd0
     bra.s    Ent_Ln_0
Ent_Lin:
     move.l   #Word_Temp,a5
     move.w   #0,Ky_Cnt        ; # of Chars in Word
     move.w   #0,Char_No       ; # of Chars in Line
Ent_Ln_0:
     move.w   #0,Caps
     move.w   #0,Echo
     bsr      Get_Char
     cmp.w    #"?",Char
     bne      Ent_Lin0
     bsr      Print_Lin_Info
     BRA      ENTER_LINE
Ent_Lin0:
     cmp.w    #"/",Char
     bne      Ent_Ln1
     bra      Ent_Ln6
Ent_Ln0:
     move.w   #0,Echo
     bsr      Get_Char
Ent_Ln1:
     cmp.w    #0,Carrier
     beq      Ent_Ln6
     cmp.w    #Cr,Char
     beq      Ent_Ln4
     cmp.w    #Bksp,Char
     bne      Ent_Ln2
     cmp.w    #0,Char_No
     beq      Ent_Lin
Ent_Ln1a:
     bsr      Back_Space
     sub.w    #1,Char_No
     sub.l    #1,a4
     sub.l    #1,a5
     sub.w    #1,Ky_Cnt
     bra.s    Ent_Ln0
Ent_Ln2:
     cmp.w    #" ",Char
     bne      Ent_Ln2a
     move.w   #0,Ky_Cnt
     move.l   #Word_Temp,a5
Ent_Ln2a:
     move.b   Char+1,(a5)
     add.l    #1,a5
     add.w    #1,Ky_Cnt
     add.w    #1,Char_No
     move.w   Video_Width,d0
     sub.w    #1,d0
     cmp.w    Ky_Cnt,d0
     beq      Ent_Ln2b
     cmp.w    Char_No,d0
     beq      Ent_Ln3
     move.b   Char+1,(a4)+
     bsr      Put_Char
     bra      Ent_Ln0
Ent_Ln2b:
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Ent_Ln6
     cmp.w    #Cr,Char
     beq      Ent_Ln4
     cmp.w    #Bksp,Char
     bne.s    Ent_Ln2b
     bra      Ent_Ln1a
Ent_Ln3:
;     cmp.w    #0,WW_Toggle
;     beq      Ent_Ln3
     move.b   #0,(a5)
     clr.l    d6
     move.w   Ky_Cnt,d6
     sub.l    d6,a4
     sub.w    #1,d6
Ent_Ln3a:
     bsr      Back_Space
     dbra     d6,Ent_Ln3a
     move.w   #1,Word_Pending
Ent_Ln4:
     move.b   #0,(a4)+
Ent_Ln6:
     rts

Delete_A_Line:
     movem.l  a0-a2/d0-d5,-(a7)
     clr.l    d0
     clr.l    d1
     move.w   Strt,d0
     sub.w    #1,d0
     move.w   Lst,d1
     mulu     #80,d0
     mulu     #80,d1
     move.l   Mesg_Area,a0
     move.l   a0,a1
     move.l   a0,a2
     add.l    #799,a2          ; a2 point to last byte in message area.
     add.l    d0,a0            ; a0 points to 1st line to be deleted
     add.l    d1,a1            ; a1 points to 1st line to be moved...
     sub.l    a1,a2
     move.l   a2,d5
E_M4c:
     move.b   (a1)+,(a0)+      ; Copy lines that won't be deleted
     dbra     d5,E_M4c
     move.l   #799,a1
     sub.l    a2,a1
     move.l   a1,d5
E_M4d:
     move.b   #0,(a0)+         ; Clear out rest of message area
     dbra     d5,E_M4d
     move.w   Strt,d0
     move.w   Lst,d1
     cmp.w    d0,d1
     bne      E_M4e
     move.w   #1,d1
     bra.s    E_M4f
E_M4e:
     sub.w    d0,d1
E_M4f:
     move.w   Line_No,d0
     sub.w    d1,d0
     move.w   d0,Line_No
     movem.l  (a7)+,a0-a2/d0-d5
     rts

E_Prompt:     dc.b  "/r>/b",0
I_Prompt:     dc.b  "]",0

Word_Pending: dc.w  0

Print_Lin_Info:
     movem.l  a0-a3/d0-d1,-(a7)
     move.l   #Ln_Lft_Msg,Text_Adr
     bsr      String_Out
     move.l   #10,d0
     sub.w    Line_No,d0
     move.l   #Ln_Byts,a3
     bsr      Pdec4
     move.l   #Ln_Byts,a0
     bsr      Prt_Num
     move.l   #Bt_Lft_Msg,Text_Adr
     bsr      String_Out
     move.l   #800,d0
     clr.l    d1
     move.w   Line_No,d1
     mulu     #80,d1
     sub.l    d1,d0
     move.l   #Ln_Byts,a3
     bsr      Pdec4
     move.l   #Ln_Byts,a0
     bsr      Prt_Num
     bsr      CrLf
     movem.l  (a7)+,a0-a3/d0-d1
     rts

Ln_Lft_Msg:   dc.b  " Lines Left: ",0
Bt_Lft_Msg:   dc.b  ", Bytes Left: ",0,0
Ln_Byts:      dc.b  "0000",0,0
Line_Md:      dc.w  0

Get_Lin_Info:
     move.w   #1,Binary_Word
     move.w   #1,Strt
     clr.l    d0
     move.w   Line_No,d0
     move.l   #D_L_Num,a3
     bsr      Pdec4
     move.l   #D_L_Num,a0
     bsr      Prt_Num
     move.l   #D_L_Msg2,Text_Adr
     bsr      String_Out
Gt_Li1:
     move.l   #2,Length
     bsr      Line_In          ; Get 'From' number
     cmp.w    #0,Carrier
     beq      Gt_LI_Xit
     move.l   #LineIn,a0
     move.b   (a0),d0
     cmp.b    #Cr,d0
     beq      Gt_Li3
Gt_Li2:
     bsr      Asc2Bin
     cmp.w    #0,Binary_Word   ; was it 0?
     beq      Gt_Li_Xit        ; yep, so exit
     move.w   Binary_Word,d0
     cmp.w    Line_No,d0       ; or greater than Last Line# ?
     bhi      Gt_Li2a          ; yep, so try again
     move.w   Binary_Word,Strt ; Store Starting line#
     bra.s    Gt_Li3
Gt_Li2a:
     cmp.w    #1,Count
     beq      Gt_Li2b
     bsr      Back_Space
Gt_Li2b:
     bsr      Back_Space
     bra      Gt_Li1
Gt_Li3:
     cmp.w    #1,Line_Md
     bne      Gt_Li3a
     move.w   Line_No,Binary_Word
Gt_Li3a:
     move.l   #D_L_Msg3,Text_Adr
     bsr      String_Out
     clr.l    d0
     move.w   Binary_Word,d0
     move.l   #D_L_Num,a3
     bsr      Pdec4
     move.l   #D_L_Num,a0
     bsr      Prt_Num
     move.l   #D_L_Msg4,Text_Adr
     bsr      String_Out
Gt_Li4:
     move.l   #2,Length
     bsr      Line_In         ; Get 'To' number
     cmp.w    #0,Carrier
     beq      E_Mxit
     move.l   #LineIn,a0
     move.b   (a0),d0
     cmp.b    #Cr,d0
     bne      Gt_Li5
     move.w   Binary_Word,Lst
     bra      Gt_Li6
Gt_Li5:
     bsr      Asc2Bin
     move.w   Binary_Word,d0
     cmp.w    Strt,d0          ; WAS IT LESS THAN THE FROM# ?
     bcs      Gt_Li5a          ; yep, so try again
     move.w   Binary_Word,d0
     cmp.w    Line_No,d0       ; or greater than the Last Line# ?
     bhi      Gt_Li5a          ; yep, so try again
     move.w   Binary_Word,Lst  ; Store Last line#
     bra.s    Gt_Li6
Gt_Li5a:
     cmp.w    #1,Count
     beq      Gt_Li5b
     bsr      Back_Space
Gt_Li5b:
     bsr      Back_Space
     bra      Gt_Li4
Gt_Li6:
     bsr      CrLf
Gt_LI_Xit:
     move.w   #0,Line_Md
     rts

Save_Message:
     movem.l  a0-a2/d0-d4,-(a7)
;     bsr      Show_Regs
     move.l   #1,d4
     move.l   Mesg_Area,a0
     move.l   #Msg_Line,a2
Sv_Msg0:
     move.w   Line_No,Count
Sv_Msg1:
     move.l   a0,a1            ; Copy pointer to Msg Text Area
     move.l   d4,d0            ; copy current line counter
     sub.w    #1,d0
     mulu     #80,d0
     add.l    d0,a1            ; point to a line
     cmp.b    #0,(a1)          ; exit if the 1st byte is a zero
     beq      Sv_Msg2
Sv_Msg1a:
     move.b   (a1)+,d0         ; copy a char...
     cmp.b    #0,d0
     beq      Sv_Msg1b
     move.b   d0,(a2)+
     bra.s    Sv_Msg1a
Sv_Msg1b:
     move.b   #Cr,(a2)+
     move.b   #Lf,(a2)+
     sub.w    #1,Count
     cmp.w    #0,Count
     beq      Sv_Msg2
     add.w    #1,d4
     cmp.w    #11,d4
     beq.s    Sv_Msg2
     bra.s    Sv_Msg1
Sv_Msg2:
     move.b   #0,(a2)+
;     bsr      Show_Regs
;     move.w   #80,Seconds
;     bsr      Pause
     movem.l  (a7)+,a0-a2/d0-d4
     rts

Prt_Num:
     movem.l  a0-a1,-(a7)
     move.w   #0,Zero
     clr.l    d0
     move.l   a0,a1
Prnm_1:
     move.b   (a1)+,d0
     cmp.b    #0,d0
     beq.s    Prnm_4
     cmp.b    #Cr,d0
     beq.s    Prnm_4
     cmp.w    #1,Zero
     beq.s    Prnm_2
     cmp.b    #"0",d0
     beq.s    Prnm_1
Prnm_2:
     move.w   d0,Char
     bsr      Put_Char
     move.w   #1,Zero
     bra.s    Prnm_1
Prnm_4:
     cmp.w    #0,Zero
     bne      Prnm_Exit
     move.w   #"0",Char
     bsr      Put_Char
Prnm_Exit:
     movem.l  (a7)+,a0-a1
     rts

Zero:         dc.w  0

Show_Msg:
     movem.l  a0-a4/d4,-(a7)
     cmp.w    #0,Line_No
     bne      Shw_Msg0
     move.w   #1,No_Desc
     bra      Shw_Msg2
Shw_Msg0:
     cmp.w    #0,Shw_Typ
     bne      Shw_Msg0a
     move.w   #1,Strt
     move.w   Line_No,Lst
Shw_Msg0a:
     clr.l    d4
     move.w   Strt,d4
Shw_Msg1:
     move.l   Mesg_Area,a4
     move.l   d4,d0
     sub.w    #1,d0
     mulu     #80,d0
     add.l    d0,a4
     cmp.w    #2,Shw_Typ
     bne      Shw_Msg1a
     move.l   d4,d0
     move.l   #D_L_Num,a3
     bsr      Pdec4
     move.l   #D_L_Num,a0
     bsr      Prt_Num
     move.w   #":",Char
     bsr      Put_Char
     move.w   #" ",Char
     bsr      Put_Char
Shw_Msg1a:
     cmp.b    #0,(a4)
     bne      Shw_Msg1b
     bsr      CrLf
     bra.s    Shw_Msg1c
Shw_Msg1b:
     move.l   a4,Text_adr        ; Print a Line
     move.w   #1,Mesg_Type
     move.w   #1,No_Color
     bsr      Word_Wrap
Shw_Msg1c:
     move.w   #0,Mesg_Type
     cmp.w    Lst,d4
     beq      Shw_Msg2
     add.w    #1,d4
     bra      Shw_Msg1
Shw_Msg2:
     move.w   #0,Shw_Typ
     move.w   #1,No_Color
     movem.l  (a7)+,a0-a4/d4
     rts

Temp_Width:   dc.w  0
WW_Toggle:    dc.w  0
Mesg_Type:    dc.w  0
Shw_Typ:      dc.w  0
; -------------------  Message Editor Stuff  -----------------

Red_Inv:      dc.b  "/r/i",0,0
Inv_Red:      dc.b  "/w /i",0
Msg_Edit:     dc.b  " / To Enter Edit Mode     /? For Help     ? For Current Line #     /S to Save ",Cr,Lf,0
              align.w

EM_Help:      dc.b  Cr,Lf,Cr,Lf
              dc.b  "  Message Editor Commands:",Cr,Lf,Cr,Lf
              dc.b  " [/rA/b]bort Message  [/rB/b]egin Over     ",160
              dc.b  " [/rC/b]olumn Bar     [/rD/b]elete A Line  ",Cr,Lf
              dc.b  " [/rE/b]dit A Line    [/rF/b]ormatted List ",160
              dc.b  " [/rI/b]nsert A Line  [/rL/b]ist Line(s)   ",Cr,Lf
              dc.b  " [/rN/b]umbered List  [/rP/b]ack Message   ",160
              dc.b  " [/rS/b]ave Message   [/rV/b]ideo Width Chg",Cr,Lf
              dc.b  " [/rW/b]ord Wrap Tgl  [/r//b] Clear Screen ",Cr,Lf
              dc.b  Cr,Lf,0
     align.w

Msg_Prompt:   dc.b  "/r(E>/b",0

Column_Bar:   dc.b  " ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+---",0
              align.w

Bgn_Ovr_Msg:  dc.b  "Begin Over...Are You Sure? ",0
              align.w

Packing_Msg:  dc.b  "Packing...Done",Cr,Lf,0
              align.w

EM_Msg2:      dc.b  "Edit Which Line (1-",0
     align.w

EM_Msg3:      dc.b  ") ?",0

EM_Msg4:      dc.b  Cr,Lf," Old Line Reads:",0
     align.w

Char_No:      dc.w  0
Lst_Line:     dc.l  0
Ins_Msg1:     dc.b  "Insert Before (1-",0
Ins_Msg2:     dc.b  ") Line [",0,0
Ins_Msg3:     dc.b  "]: ",0

Del_Msg1:     dc.b  "Delete (1-",0,0
Lst_Msg1:     dc.b  "List (1-",0,0
D_L_Msg2:     dc.b  ") From [1]: ",0,0
D_L_Msg3:     dc.b  " To [",0
D_L_Msg4:     dc.b  "]: ",0
D_L_Num:      dc.b  "0000",0,0
Strt:         dc.w  0
Lst:          dc.w  0
Abrt_Msg1:    dc.b  "Abort... Are You Sure ? ",0
     align.w

Yes_Msg:      dc.b  "Yes",0
No_Msg:       dc.b  "No ",0
Not_Ent_Msg:  dc.b  "You Haven't Entered Any Lines...",Cr,Lf,0
              align.w

Show_Regs:
     movem.l  a0-a7/d0-d7,-(a7)
     move.l   d0,Sav_D0
     move.l   a3,Sav_A3
     move.l   a0,d0
     move.l   #Reg_A0,a3
     bsr      Hex_Long
     move.l   Sav_D0,d0
     move.l   #Reg_D0,a3
     bsr      Hex_Long
     move.l   a1,d0
     move.l   #Reg_A1,a3
     bsr      Hex_Long
     move.l   d1,d0
     move.l   #Reg_D1,a3
     bsr      Hex_Long
     move.l   a2,d0
     move.l   #Reg_A2,a3
     bsr      Hex_Long
     move.l   d2,d0
     move.l   #Reg_D2,a3
     bsr      Hex_Long
     move.l   Sav_A3,d0
     move.l   #Reg_A3,a3
     bsr      Hex_Long
     move.l   d3,d0
     move.l   #Reg_D3,a3
     bsr      Hex_Long
     move.l   a4,d0
     move.l   #Reg_A4,a3
     bsr      Hex_Long
     move.l   d4,d0
     move.l   #Reg_D4,a3
     bsr      Hex_Long
     move.l   a5,d0
     move.l   #Reg_A5,a3
     bsr      Hex_Long
     move.l   d5,d0
     move.l   #Reg_D5,a3
     bsr      Hex_Long
     move.l   a6,d0
     move.l   #Reg_A6,a3
     bsr      Hex_Long
     move.l   d6,d0
     move.l   #Reg_D6,a3
     bsr      Hex_Long
     move.l   a7,d0
     move.l   #Reg_A7,a3
     bsr      Hex_Long
     move.l   d7,d0
     move.l   #Reg_D7,a3
     bsr      Hex_Long
     move.l   #Registers,Text_Adr
     bsr      Line_Out
     movem.l  (a7)+,a0-a7/d0-d7
     rts
Sav_D0:       dc.l  0
Sav_A3:       dc.l  0

RegisTers:    dc.b  "A0 = "
Reg_A0:       dc.b  "00000000"
              dc.b  "  D0 = "
Reg_D0:       dc.b  "00000000",Cr,Lf
              dc.b  "A1 = "
Reg_A1:       dc.b  "00000000"
              dc.b  "  D1 = "
Reg_D1:       dc.b  "00000000",Cr,Lf
              dc.b  "A2 = "
Reg_A2:       dc.b  "00000000"
              dc.b  "  D2 = "
Reg_D2:       dc.b  "00000000",Cr,Lf
              dc.b  "A3 = "
Reg_A3:       dc.b  "00000000"
              dc.b  "  D3 = "
Reg_D3:       dc.b  "00000000",Cr,Lf
              dc.b  "A4 = "
Reg_A4:       dc.b  "00000000"
              dc.b  "  D4 = "
Reg_D4:       dc.b  "00000000",Cr,Lf
              dc.b  "A5 = "
Reg_A5:       dc.b  "00000000"
              dc.b  "  D5 = "
Reg_D5:       dc.b  "00000000",Cr,Lf
              dc.b  "A6 = "
Reg_A6:       dc.b  "00000000"
              dc.b  "  D6 = "
Reg_D6:       dc.b  "00000000",Cr,Lf
              dc.b  "A7 = "
Reg_A7:       dc.b  "00000000"
              dc.b  "  D7 = "
Reg_D7:       dc.b  "00000000",Cr,Lf

File_Ok:      dc.w  $Beef      ; Flag to determine Desc Type!!!
Accs_Cntr:    dc.w  0          ; Access Counter
Attr_3:       dc.w  0          ; Application?
Attr_4:       dc.w  0          ; File Type?
Attr_5:       dc.w  0          ;
Attr_6:       dc.w  0          ;
Attr_7:       dc.w  0          ;
Attr_8:       dc.w  0          ;
Attr_9:       dc.w  0          ;
Attr_A:       dc.w  0          ;

Lst_Dl:       dc.w  0,0,0,0,0,0 ; Last Download Date

Line_No:      dc.w  0          ; Number of lines in message

Uploader:     dc.w  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Msg_Line:     ; holds 20 lines of text...

       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       dc.w  200,200,200,200,0,0,0,0

FName_Ok:     dc.w  0
Dots:         dc.w  0
F_Len:        dc.w  0

FName_Parse:
     movem.l  a0-a2/d0/d5,-(a7)
     move.w   #0,FName_Ok
F_P_1:
     move.w   #0,F_Len
     move.w   #0,Dots
     move.w   #1,Caps
     move.l   #13,Length
     bsr      Line_In
     cmp.w    #0,Carrier
     beq      F_P_Xit
     move.l   #LineIn,a0
     cmp.b    #Cr,(a0)
     beq      F_P_Xit
     move.l   #12,d5
F_P_2:
     move.b   (a0)+,d0
     cmp.b    #Cr,d0
     beq      F_P_6
     cmp.b    #0,d0
     beq      F_P_6
     cmp.b    #" ",d0
     beq      F_P_10
     cmp.b    #".",d0
     bne      F_P_3
     add.w    #1,Dots
     cmp.w    #1,Dots
     bgt      F_P_10
     bra.s    F_P_5
F_P_3:
     cmp.b    #"_",d0
     beq      F_P_5
     cmp.b    #"0",d0
     bcs      F_P_10
     cmp.b    #"Z",d0
     bhi      F_P_10
     cmp.b    #";",d0
     bcs      F_P_5
     cmp.b    #"@",d0
     bhi      F_P_5
     bra.s    F_P_10
F_P_5:
     add.w    #1,F_Len
     dbra     d5,F_P_2
F_P_6:
     cmp.w    #13,F_Len        ; Try again if 13 chars in filename
     beq      F_P_10
     cmp.w    #0,Dots          ; Check to if filename has a period (.)
     bne      F_P_7            ; if not then make sure that filename
     cmp.w    #8,F_Len         ; has less than 9 characters...
     bgt      F_P_10
F_P_7:
     move.w   #1,FName_Ok
     bra.s    F_P_Xit
F_P_10:
     move.l   #Bad_Filename,Text_Adr
     bsr      String_Out
     bra      F_P_1
F_P_Xit:
     movem.l  (a7)+,a0-a2/d0/d5
     rts

Bad_Filename: dc.b  Cr,Lf,Cr,Lf,"*** Illegal Filename ***",cr,Lf,Cr,Lf
              dc.b  "Re-Enter Filename -> ",0
              align.w

End_Of_Arc:   dc.w 0
FAtrb_Tmp:    dc.w 0

Arc_Listing:
     movem.l  a0-a3/d5,-(a7)
     move.w   #0,End_Of_Arc
     move.l   #0,Arc_Ntot
     move.l   #0,Arc_Otot
     move.l   #Arc_Msg1,Text_Adr
     bsr      String_Out
     move.l   #F_Pname2,a0
     move.l   #Arc_Path,a1
Arc_L0:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     cmp.b    #0,d0
     bne      Arc_L0
     move.l   #Arc_Path,Fo1+2
     move.w   #0,File_Mode
     bsr      FOpen
     tst.w    d0
     bpl      Arc_0
     bra      Arc_20
Arc_0:
     move.l   #File_Buf,a0
     move.l   #8,d5
Arc_0a:
     move.l   #0,(a0)+
     dbra     d5,Arc_0a
     move.l   #29,Num_Bytes
     bsr      Fread
     bmi      Arc_19
     cmp.w    #0,File_Buf
     beq      Arc_19
     cmp.w    #$1a00,File_Buf
     beq      Arc_19
     cmp.w    #$1a1a,File_Buf
     beq      Arc_19
     cmp.b    #31,File_Buf+1
     bhi      Arc_19
     move.b   File_Buf+23,Dummy+1  ; Crc high
     move.b   File_Buf+24,Dummy    ; Crc low
     move.l   #File_Buf+2,a1
     move.l   #Arc_Name,a2
     move.l   #12,d5
Arc_01:
     move.b   #" ",(a2)+
     dbra     d5,Arc_01
     move.l   #Arc_Name,a2
     move.l   #11,d5
Arc_1:
     move.b   (a1)+,d0
     cmp.b    #0,d0
     beq      Arc_2
     move.b   d0,(a2)+
     dbra     d5,Arc_1
Arc_2:
     move.l   #File_Buf+15,a1   ; Compressed File Size
     bsr      H8_2_H16
     add.l    d2,Arc_Ntot
     move.l   d2,How_Many
     move.l   #Arc_Nsiz,a3
     bsr      Pdec8
     move.l   #Arc_NSiz,a0
     bsr      Zero_2_Space

     move.l   #File_Buf+25,a1   ; Original File Size
     bsr      H8_2_H16
     add.l    d2,Arc_Otot
     move.l   #Arc_Osiz,a3
     bsr      Pdec8
     move.l   #Arc_OSiz,a0
     bsr      Zero_2_Space

     move.l   #Arc_Name,Text_Adr
     bsr      String_out
     move.l   #Arc_OSiz,Text_Adr
     bsr      String_Out

     move.b   File_Buf+1,d0
     cmp.b    #2,d0
     bhi      Arc_3
     move.l   #Arc_Type1,Text_Adr
     bra      Arc_10
Arc_3:
     cmp.b    #3,d0
     bhi      Arc_4
     move.l   #Arc_Type2,Text_Adr
     bra      Arc_10
Arc_4:
     cmp.b    #4,d0
     bhi      Arc_5
     move.l   #Arc_Type3,Text_Adr
     bra.s    Arc_10
Arc_5:
     cmp.b    #8,d0
     bhi      Arc_6
     move.l   #Arc_Type4,Text_Adr
     bra.s    Arc_10
Arc_6:
     cmp.b    #9,d0
     bne      Arc_7
     move.l   #Arc_Type5,Text_Adr
     bra.s    Arc_10
Arc_7:
     cmp.b    #$1f,d0          ; End of Subdir?
     bhi      Arc_8
     cmp.b    #$1e,d0
     bne      Arc_8
     move.l   #Arc_Type9,Text_Adr
     bra.s    Arc_10
Arc_8:
     move.l   #Arc_Type6,Text_Adr
Arc_10:
     bsr      String_Out
     move.l   #Arc_Nsiz,Text_Adr
     bsr      String_Out
     clr.l    d0
     move.w   Dummy,d0
     move.l   #Arc_Crc,a3
     bsr      Hex_Word
     move.l   #Arc_Crc,Text_Adr
     bsr      Line_Out
     move.w   #1,Where
     bsr      Lseek
     bra      Arc_0

Arc_19:
     move.l   #Arc_Msg2,Text_Adr
     bsr      String_Out
     move.l   #Arc_Ntot,a3
     move.l   Arc_Ntot,d0
     bsr      Pdec8
     move.l   #Arc_Ntot,a0
     bsr      Zero_2_Space
     move.l   Arc_Otot,d0
     move.l   #Arc_Otot,a3
     bsr      Pdec8
     move.l   #Arc_Otot,a0
     bsr      Zero_2_Space
     move.l   #Arc_Otot,Text_Adr
     bsr      String_out
     move.l   #Arc_Type7,Text_Adr
     bsr      String_Out
     move.l   #Arc_Ntot,Text_Adr
     bsr      Line_Out
Arc_20:
     bsr      CrLf
     bsr      FClose
Arc_30:
     movem.l  (a7)+,a0-a3/d5
     rts

Lzh_Listing:
     movem.l  a0-a3/d5,-(a7)
     move.w   #0,End_Of_Arc
     move.l   #0,Arc_Ntot      ; Clear New File Size
     move.l   #0,Arc_Otot      ; Clear Old File Size
     move.l   #Lzh_Msg1,Text_Adr
     bsr      String_Out
     move.l   #F_Pname2,a0
     move.l   #Arc_Path,a1
Lzh_0:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     cmp.b    #0,d0
     bne      Lzh_0
     move.l   #Arc_Path,Fo1+2
     move.w   #0,File_Mode
     bsr      FOpen
     tst.w    d0
     bmi      Lzh_1
     bra.s    Lzh_2
Lzh_1:
     bra      Lzh_20
Lzh_2:
     move.l   #1,Num_Bytes     ; Read 1st Byte - Length of Header
     bsr      FRead
     tst.w    d0
     bmi      Lzh_19
     clr.l    d1
     move.b   File_Buf,d1
     cmp.b    #0,d1
     beq      Lzh_19
     cmp.b    #$1a,d1
     beq      Lzh_19
     add.l    #1,d1
     move.l   d1,Num_Bytes     ; Read 'nn'Rest of Header Bytes
     move.l   #File_Buf,a0
     move.l   #4,d5
Lzh_2a:
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     dbra     d5,Lzh_2a
     bsr      Fread
     tst.w    d0
     bmi      Lzh_19
     move.l   #File_Buf+6,a1
     bsr      H8_2_H16
     add.l    d2,Arc_Ntot
     move.l   d2,How_Many
     move.w   #1,Where
     bsr      Lseek
     tst.w    d0
     bpl      Lzh_2b
     move.w   #1,End_Of_Arc
Lzh_2b:
     move.l   How_Many,d0
     move.l   #Arc_Nsiz,a3
     bsr      Pdec8
     move.l   #Arc_NSiz,a0
     bsr      Zero_2_Space

     move.l   #File_Buf+10,a1
     bsr      H8_2_H16
     add.l    d2,Arc_Otot
     move.l   #Arc_Osiz,a3
     bsr      Pdec8
     move.l   #Arc_OSiz,a0
     bsr      Zero_2_Space

     move.l   #Arc_Name,a2      ; Clear Out Filename in Arc
     move.l   #12,d5
Lzh_3:
     move.b   #" ",(a2)+
     dbra     d5,Lzh_3

     clr.l    d5
     move.b   File_Buf+20,d5   ; Length of Filename
     sub.b    #1,d5
     move.l   #File_Buf+21,a1
     move.l   #Arc_Name,a2
Lzh_4:
     move.b   (a1)+,(a2)+
     dbra     d5,Lzh_4

     move.b   (a1)+,Dummy+1    ; Crc low
     move.b   (a1)+,Dummy      ; Crc high

     move.l   #Arc_Name,Text_Adr
     bsr      String_out
     move.l   #Arc_OSiz,Text_Adr
     bsr      String_Out
     move.l   #Arc_Nsiz,Text_Adr
     bsr      String_Out
     move.w   #" ",Char
     bsr      Put_Char
     move.l   #File_Buf+1,a1
     move.l   #4,d5
Lzh_5:
     clr.l    d0
     move.b   (a1)+,d0
     move.w   d0,Char
     bsr      Put_Char
     dbra     D5,LZH_5
     move.w   #" ",Char
     bsr      Put_Char
     clr.l    d0
     move.w   Dummy,d0
     move.l   #Arc_Crc,a3
     bsr      Hex_Word
     move.l   #Arc_Crc,Text_Adr
     bsr      Line_Out
     cmp.w    #1,End_Of_Arc
     beq      Lzh_19
     bra      Lzh_2

Lzh_19:
     move.l   #Lzh_Msg2,Text_Adr
     bsr      String_Out
     move.l   #Arc_Otot,a3
     move.l   Arc_Otot,d0
     bsr      Pdec8
     move.l   #Arc_Otot,a0
     bsr      Zero_2_Space
     move.l   #Arc_Otot,Text_Adr
     bsr      String_out

     move.l   #Arc_Ntot,a3
     move.l   Arc_Ntot,d0
     bsr      Pdec8
     move.l   #Arc_Ntot,a0
     bsr      Zero_2_Space
     move.l   #Arc_Ntot,Text_Adr
     bsr      Line_Out
     bsr      CrLf
Lzh_20:
     bsr      FClose
Lzh_30:
     movem.l  (a7)+,a0-a3/d5
     rts

Z_Header:     dc.w  0,0,0
Z_Version     dc.w  0,0
Z_Comp:       dc.w  0,0
Z_Crc32:      dc.w  0,0,0
ZComp_Size:   dc.w  0,0,0
ZUncomp_Size: dc.w  0,0,0
ZFile_Size:   dc.w  0,0

Zip_Listing:
     movem.l  a0-a3/d5,-(a7)
     move.l   #0,Arc_Ntot      ; Clear New File Size
     move.l   #0,Arc_Otot      ; Clear Old File Size
     move.l   #Zip_Msg1,Text_Adr
     bsr      String_Out
     move.l   #F_Pname2,a0
     move.l   #Arc_Path,a1
Zip_0:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     cmp.b    #0,d0
     bne      Zip_0
     move.l   #Arc_Path,Fo1+2
     move.w   #0,File_Mode
     bsr      FOpen
     tst.w    d0
     bmi      Zip_1
     bra.s    Zip_2
Zip_1:
     bra      Zip_20
Zip_2:
     move.l   #File_Buf,a0
     move.l   #4,d5
Zip_2a:
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     dbra     d5,Zip_2a
     move.l   #30,Num_Bytes    ; Read Header Bytes
     bsr      FRead
     move.l   #File_Buf,a0
     move.l   0(a0),Z_Header
     cmp.l    #$504b0304,Z_Header
     bne      Zip_19
     move.w   4(a0),Z_Version
     move.w   8(a0),Z_Comp
     move.l   14(a0),Z_Crc32
     move.l   18(a0),ZComp_Size
     move.l   22(a0),ZUncomp_Size
     move.w   26(a0),ZFile_Size

     move.l   #Z_Version,a3
     bsr      Intel_Word
     move.w   Intel,Z_Version

     move.l   #Z_Comp,a3
     bsr      Intel_Word
     move.w   Intel,Z_Comp

     move.l   #Z_Crc32,a3
     bsr      Intel_Long
     move.l   Intel,Z_Crc32

     move.l   #ZComp_Size,a3
     bsr      Intel_Long
     move.l   Intel,ZComp_Size

     move.l   #ZUncomp_Size,a3
     bsr      Intel_Long
     move.l   Intel,ZUncomp_Size

     move.l   #ZFile_Size,a3
     bsr      Intel_Word
     move.w   Intel,ZFile_Size

     clr.l    d1
     move.w   ZFile_Size,d1
     move.l   d1,Num_Bytes     ; Read in File Name
     bsr      Fread
     move.l   #Arc_Name,a2      ; Clear Out Filename in Arc
     move.l   #12,d5
Zip_3:
     move.b   #" ",(a2)+
     dbra     d5,Zip_3
     clr.l    d5
     move.w   ZFile_Size,d5   ; Length of Filename
     sub.w    #1,d5
     move.l   #File_Buf,a1
     move.l   #Arc_Name,a2
Zip_4:
     move.b   (a1)+,(a2)+
     dbra     d5,Zip_4
     move.l   ZComp_Size,d2
     add.l    d2,Arc_Ntot
     move.l   d2,How_Many
     move.w   #1,Where
     bsr      Lseek
Zip_5:
     move.l   How_Many,d0
     move.l   #Arc_Nsiz,a3
     bsr      Pdec8
     move.l   #Arc_NSiz,a0
     bsr      Zero_2_Space

     move.l   ZUncomp_Size,d2
     add.l    d2,Arc_Otot
     move.l   d2,d0
     move.l   #Arc_Osiz,a3
     bsr      Pdec8
     move.l   #Arc_OSiz,a0
     bsr      Zero_2_Space

     move.l   #Arc_Name,Text_Adr
     bsr      String_out
     move.l   #Arc_OSiz,Text_Adr
     bsr      String_Out
     move.l   #Arc_Nsiz,Text_Adr
     bsr      String_Out
     move.w   #" ",Char
     bsr      Put_Char
     CMP.W    #0,Z_COMP
     bne      Zip_6a
     move.l   #Zip_Type0,Text_Adr
     bra      Zip_7
Zip_6a:
     CMP.W    #1,Z_COMP
     bne      Zip_6b
     move.l   #Zip_Type1,Text_Adr
     bra      Zip_7
Zip_6b:
     CMP.W    #2,Z_COMP
     bne      Zip_6c
     move.l   #Zip_Type2,Text_Adr
     bra      Zip_7
Zip_6c:
     CMP.W    #3,Z_COMP
     bne      Zip_6d
     move.l   #Zip_Type3,Text_Adr
     bra      Zip_7
Zip_6d:
     CMP.W    #4,Z_COMP
     bne      Zip_6e
     move.l   #Zip_Type4,Text_Adr
     bra.s    Zip_7
Zip_6e:
     CMP.W    #5,Z_COMP
     bne      Zip_6f
     move.l   #Zip_Type5,Text_Adr
     bra.s    Zip_7
Zip_6f:
     CMP.W    #6,Z_COMP
     bne      Zip_6g
     move.l   #Zip_Type6,Text_Adr
     bra.s    Zip_7
Zip_6g:
     CMP.W    #7,Z_COMP
     bne      Zip_6h
     move.l   #Zip_Type7,Text_Adr
     bra.s    Zip_7
Zip_6h:
     move.l   #Zip_Type8,Text_Adr
Zip_7:
     bsr      String_Out
     move.l   Z_Crc32,d0
     move.l   #Zip_Crc,a3
     bsr      Hex_Long
     move.l   #Zip_Crc,Text_Adr
     bsr      Line_Out
     cmp.w    #1,End_Of_Arc
     beq      Zip_19
     bra      Zip_2

Zip_19:
     move.l   #Zip_Msg2,Text_Adr
     bsr      String_Out
     move.l   #Arc_Otot,a3
     move.l   Arc_Otot,d0
     bsr      Pdec8
     move.l   #Arc_Otot,a0
     bsr      Zero_2_Space
     move.l   #Arc_Otot,Text_Adr
     bsr      String_out

     move.l   #Arc_Ntot,a3
     move.l   Arc_Ntot,d0
     bsr      Pdec8
     move.l   #Arc_Ntot,a0
     bsr      Zero_2_Space
     move.l   #Arc_Ntot,Text_Adr
     bsr      Line_Out
     bsr      CrLf
Zip_20:
     bsr      FClose
Zip_30:
     movem.l  (a7)+,a0-a3/d5
     rts

Zip_Crc:      dc.b  "00000000",0,0
Sit_Size:     dc.l  1

Sit_Listing:
     movem.l  a0-a5/d2/d5,-(a7)
Sit_L00:
     move.l   #0,Arc_Ntot      ; Clear New File Size
     move.l   #0,Arc_Otot      ; Clear Old File Size
     move.l   #Sit_Msg1,Text_Adr
     bsr      String_Out
     move.l   #F_Pname2,a0
     move.l   #Arc_Path,a1
Sit_0:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     cmp.b    #0,d0
     bne      Sit_0
     move.l   #Arc_Path,Fo1+2
     move.w   #0,File_Mode
     bsr      FOpen
     tst.w    d0
     bmi      Sit_1
     bra.s    Sit_2
Sit_1:
;     bsr      Not_Exist
     bra      Sit_20
Sit_2:
     move.l   #File_Buf,a0
     move.l   #4,d5
Sit_2a:
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     move.l   #0,(a0)+
     dbra     d5,Sit_2a
     move.l   #150,Num_Bytes   ; Read Mac Header Bytes
     bsr      FRead
     cmp.l    #0,File_Buf
     beq      Sit_19
     move.l   #File_Buf,a0
     move.b   65(a0),Z_Header
     move.b   66(a0),Z_Header+1
     move.b   67(a0),Z_Header+2
     move.b   68(a0),Z_Header+3
     cmp.l    #$53495421,Z_Header ; "Sit!" ???
     bne      Sit_19
     clr.l    d0
Sit_3:
     tst.w    d0               ; an error from LSeek?
     bmi      Sit_19
     move.l   #0,Sit_Size
     move.l   #112,Num_Bytes   ; Read in File Stuff
     bsr      Fread
;     tst.w    d0
;     bmi      Sit_19
     cmp.w    #0,File_Buf      ; End of File ?
     bne      Sit_3aa
     cmp.b    #0,File_Buf+2
     beq      Sit_19
Sit_3aa:
     move.l   #Sit_Name,a2     ; Clear Out Filename in Arc
     move.l   #46,d5
Sit_3a:
     move.b   #" ",(a2)+
     dbra     d5,Sit_3a
     move.l   #File_Buf,a5
     move.b   0(a5),R_Comp     ; Rsrc Comp Type
     move.b   1(a5),D_Comp     ; Data  "    "
     clr.l    d5
     move.b   2(a5),d5         ; Length of Filename
     sub.w    #1,d5
     cmp.b    #62,d5
     bhi      Sit_19
     cmp.b    #45,d5
     blt      Sit_3b
     move.w   #44,d5
Sit_3b:
     move.l   #File_Buf+3,a1
     move.l   #Sit_Name,a2
Sit_4:
     move.b   (a1)+,(a2)+
     dbra     d5,Sit_4

     move.l   66(a5),Sit_Type  ; Get "Type"
     move.l   70(a5),Sit_Crea  ; Get "Creator"

     move.l   84(a5),d0        ; Rsrc Original Size
     add.l    d0,Arc_Otot
     move.l   #Ro_Siz,a3
     bsr      Pdec8
     move.l   #Ro_Siz,a2
     move.l   #7,d5
     bsr      Left_Just

     move.l   88(a5),d0        ; Data Original Size
     add.l    d0,Arc_Otot
     move.l   #Do_Siz,a3
     bsr      Pdec8
     move.l   #Do_Siz,a2
     move.l   #7,d5
     bsr      Left_Just

     move.l   92(a5),d0        ; Rsrc New Size
     add.l    d0,Arc_Ntot
     add.l    d0,Sit_Size
     move.l   #Rn_Siz,a3
     bsr      Pdec8
     move.l   #Rn_Siz,a2
     move.l   #7,d5
     bsr      Left_Just

     move.l   96(a5),d0        ; Data New Size
     add.l    d0,Arc_Ntot
     add.l    d0,Sit_Size
     move.l   #Dn_Siz,a3
     bsr      Pdec8
     move.l   #Dn_Siz,a2
     move.l   #7,d5
     bsr      Left_Just

     move.l   #Sit_Name,Text_Adr
     bsr      String_out
     move.l   #Sit_Type,Text_Adr
     bsr      String_Out
     move.w   #" ",char
     bsr      Put_Char
     bsr      Put_Char
     move.l   #Sit_Crea,Text_Adr
     bsr      Line_Out

     move.l   #Rsrc_Msg,Text_Adr
     bsr      String_Out
     move.l   #Ro_Siz,Text_adr
     bsr      String_out

     cmp.b    #0,R_Comp
     bne      Sit_6a
     move.l   #Sit_Type0,Text_Adr
     bra      Sit_7
Sit_6a:
     cmp.b    #1,R_Comp
     bne      Sit_6b
     move.l   #Sit_Type1,Text_Adr
     bra      Sit_7
Sit_6b:
     cmp.b    #2,R_COMP
     bne      Sit_6c
     move.l   #Sit_Type2,Text_Adr
     bra      Sit_7
Sit_6c:
     CMP.b    #3,R_COMP
     bne      Sit_6d
     move.l   #Sit_Type3,Text_Adr
     bra      Sit_7
Sit_6d:
     CMP.b    #16,R_COMP
     bne      Sit_6f
     move.l   #Sit_Type4,Text_Adr
     bra.s    Sit_7
Sit_6f:
     CMP.b    #17,R_COMP
     bne      Sit_6g
     move.l   #Sit_Type5,Text_Adr
     bra.s    Sit_7
Sit_6g:
     CMP.b    #18,R_COMP
     bne      Sit_6h
     move.l   #Sit_Type6,Text_Adr
     bra.s    Sit_7
Sit_6h:
     cmp.b    #19,R_Comp
     bne      Sit_6i
     move.l   #Sit_Type7,Text_Adr
     bra.s    Sit_7
Sit_6i:
     cmp.b    #32,R_Comp
     bne      Sit_6j
     move.l   #Sit_Type10,Text_Adr
     bra.s    Sit_7
Sit_6j:
     move.l   #Sit_Type9,Text_Adr
Sit_7:
     bsr      String_Out
     move.l   #Rn_Siz,Text_Adr
     bsr      Line_Out

     move.l   #Data_Msg,Text_Adr
     bsr      String_Out
     move.l   #Do_Siz,Text_adr
     bsr      String_out

     cmp.b    #0,D_Comp
     bne      Sit_7a
     move.l   #Sit_Type0,Text_Adr
     bra      Sit_8
Sit_7a:
     cmp.b    #1,D_Comp
     bne      Sit_7b
     move.l   #Sit_Type1,Text_Adr
     bra      Sit_8
Sit_7b:
     cmp.b    #2,D_COMP
     bne      Sit_7c
     move.l   #Sit_Type2,Text_Adr
     bra      Sit_8
Sit_7c:
     CMP.b    #3,D_COMP
     bne      Sit_7d
     move.l   #Sit_Type3,Text_Adr
     bra      Sit_8
Sit_7d:
     CMP.b    #16,D_COMP
     bne      Sit_7f
     move.l   #Sit_Type4,Text_Adr
     bra.s    Sit_8
Sit_7f:
     CMP.b    #17,D_COMP
     bne      Sit_7g
     move.l   #Sit_Type5,Text_Adr
     bra.s    Sit_8
Sit_7g:
     CMP.b    #18,D_COMP
     bne      Sit_7h
     move.l   #Sit_Type6,Text_Adr
     bra.s    Sit_8
Sit_7h:
     cmp.b    #19,D_Comp
     bne      Sit_7i
     move.l   #Sit_Type7,Text_Adr
     bra.s    Sit_8
Sit_7i:
     cmp.b    #32,D_Comp
     bne      Sit_7j
     move.l   #Sit_Type10,Text_Adr
     bra.s    Sit_8
Sit_7j:
     move.l   #Sit_Type9,Text_Adr
Sit_8:
     bsr      String_Out
     move.l   #Dn_Siz,Text_Adr
     bsr      Line_Out
     cmp.w    #1,End_Of_Arc
     beq      Sit_19

     move.l   Sit_Size,How_Many
     move.w   #1,Where
     bsr      Lseek
     bra      Sit_3

Sit_19:
     move.l   #Sit_Msg2,Text_Adr
     bsr      String_Out
     move.l   #Arc_Otot,a3
     move.l   Arc_Otot,d0
     bsr      Pdec8
     move.l   #Arc_Otot,a2
     move.l   #7,d5
     bsr      Left_Just
     move.l   #Arc_Otot,Text_Adr
     bsr      String_out
     move.l   #Sit_Type20,Text_Adr
     bsr      String_Out
     move.l   #Arc_Ntot,a3
     move.l   Arc_Ntot,d0
     bsr      Pdec8
     move.l   #Arc_Ntot,a2
     move.l   #7,d5
     bsr      Left_Just
     move.l   #Arc_Ntot,Text_Adr
     bsr      Line_Out
     bsr      CrLf
Sit_20:
     bsr      FClose
     movem.l  (a7)+,a0-a5/d2/d5
     rts

Sit_Name:
     dc.b     "12345678901234567890123456789012345678901234567",0
              align.w

Sit_Msg1:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "Filename      Actual    Compression  Size Now  Type  Crea",Cr,Lf
     dc.b     "------------  --------  -----------  --------  ----  ----",Cr,Lf,0
     align.w

Sit_Msg2:
     dc.b     "------------  --------  -----------  --------  ----  ----",Cr,Lf
     dc.b     "Total         ",0
     align.w

Sit_Type0:    dc.b  "  None         ",0
Sit_Type1:    dc.b  "  RLE          ",0
Sit_Type2:    dc.b  "  LZW          ",0
Sit_Type3:    dc.b  "  Huffman      ",0
Sit_Type4:    dc.b  "  Encr. None   ",0
Sit_Type5:    dc.b  "  Encr. RLE    ",0
Sit_Type6:    dc.b  "  Encr. LZW    ",0
Sit_Type7:    dc.b  "  Encr. Huff   ",0
Sit_Type8:    dc.b  "  Unknown      ",0
Sit_Type9:    dc.b  "  Unknown      ",0
Sit_Type10:   dc.b  "  Folder       ",0
Sit_Type20:   dc.b  "               ",0
              align.w

Ro_Siz:       dc.b  "00000000",0,0
Do_Siz:       dc.b  "00000000",0,0
Rn_Siz:       dc.b  "00000000",0,0
Dn_Siz:       dc.b  "00000000",0,0
Sit_Type:     dc.b  "    ",0,0
Sit_Crea:     dc.b  "    ",0,0
Rsrc_Msg:     dc.b  "        Rsrc  ",0,0
Data_Msg:     dc.b  "        Data  ",0,0
R_Comp:       dc.b  0
D_Comp:       dc.b  0

Intel_Long:
     movem.l  a0/a3/d5,-(a7)
     move.l   #4,d5
     bra.s    Intel_Cnv
Intel_Word:
     movem.l  a0/a3/d5,-(a7)
     move.l   #2,d5
Intel_Cnv:
     move.l   #Intel,a0
     add.l    d5,a0
Intel_1:
     move.b   (a3)+,-(a0)
     dbra     d5,Intel_1
     movem.l  (a7)+,a0/a3/d5
     rts

              dc.l  0,0
Intel:        dc.l  0

H8_2_H16:
     clr.l    d2
     clr.l    d0
     move.b   (a1)+,d0
     add.b    d0,d2
     clr.l    d0
     move.b   (a1)+,d0
     muls     #256,d0
     add.l    d0,d2
     clr.l    d0
     move.b   (a1)+,d0
     muls     #256,d0
     muls     #256,d0
     add.l    d0,d2
     clr.l    d0
     move.b   (a1)+,d0
     muls     #256,d0
     muls     #256,d0
     muls     #256,d0
     add.l    d0,d2
     move.l   d2,d0
     rts

Show_Tries:
     clr.l    d0
     move.w   Tries,d0
     move.l   #10,d1
     move.l   #Tries2,a3
     bsr      Dec1
     move.l   #Tries1,Text_Adr
     bsr      Send_Console
     rts

Show_FBytes:
     move.l   Tot_Bytes,d0
     move.l   #Tot_Bytes2,a3
     bsr      Pdec8
     move.l   #Tot_Bytes1,Text_Adr
     bsr      Send_Console
     move.l   #Tot_Bytes2,Text_Adr
     bsr      Send_Console
     rts

Show_Filename:
     move.l   #F_Pname1,Text_Adr
     bsr      Send_Console
     move.l   #F_Filler,Text_Adr
     bsr      Send_Console
     rts

F_Filler:     dc.b  "    ",0,0

Check_Dl_Ratio:
     movem.l  d2-d4,-(a7)
     move.w   #0,Need_Uploads
     clr.l    d2
     clr.l    d3
     clr.l    d4
     move.w   Downlds,d2       ; # of Downloads
     move.w   Uplds,d3         ; # of Uploads
     add.w    #1,d3
     move.w   Dl_Ratio,d4      ; Download Ratio  'xx' to 1
     muls     d3,d4            ; Uploads * D/L Ratio
     cmp.l    d4,d2            ; is U/L's*Ratio >= Downloads
     ble      Chk_Dlr1         ; Exit if so!!!
     move.w   #1,Need_Uploads
     move.l   #Need_Uplds_Msg,Text_Adr
     bsr      Line_Out
     bsr      SHOW_User_STATS
Chk_Dlr1:
     movem.l  (a7)+,d2-d4
     rts

Need_Uplds_Msg:
     dc.b     Cr,Lf,Cr,Lf,"  You Need to Upload Some Files Before",Cr,Lf
     dc.b     "You Can Download Any More Files!!!",Cr,Lf,0
     align.w

Show_User_Stats:
     bsr      CrLf
     clr.l    d0
     move.l   #UserNo1,a3
     move.w   User_No,d0
     bsr      Pdec4
     bsr      Cvrt_Dl_Stats
     bsr      CrLf
     move.l   #User_No_Msg,Text_Adr
     bsr      String_Out
     move.l   #UserNo1,Text_Adr
     bsr      Line_Out
     move.l   #Downlds_Msg,Text_Adr
     bsr      String_Out
     move.l   #Downs,Text_Adr
     bsr      Line_Out
     move.l   #Uploads_Msg,Text_Adr
     bsr      String_Out
     move.l   #Ups,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bsr      Wait_Rtrn
     rts

Cvrt_Dl_Stats:
     clr.l    d0
     move.l   #Downs,a3
     move.w   Downlds,d0
     bsr      Pdec4
     clr.l    d0
     move.l   #Ups,a3
     move.w   Uplds,d0
     bsr      Pdec4
     move.l   #Save_Cur,Text_Adr
     bsr      Send_Console
     move.l   #Inverse,Text_Adr
     bsr      Send_Console
     move.l   #Downz,Text_Adr
     bsr      Send_Console
     move.l   #Upz,Text_Adr
     bsr      Send_Console
     move.l   #Normal,Text_Adr
     bsr      Send_Console
     move.l   #Set_Cur,Text_Adr
     bsr      Send_Console
     rts

User_No_Msg:  dc.b  "User No  : ",0
Downlds_Msg:  dc.b  "Downloads: ",0
Uploads_Msg:  dc.b  "Uploads  : ",0
Downz:        dc.b  Esc,"Y",32+4,32+53
Downs:        dc.b  "0000",0,0
Upz:          dc.b  Esc,"Y",32+4,32+63
Ups:          dc.b  "0000",0,0
UserNo1:      dc.b  "0000",0,0

Compare_Dates:
     movem.l  a0-a1/d1-d2,-(a7)
     clr.l    d0
     clr.l    d1
     clr.l    d2
     move.l   #Last_Call,a0     ; Date user was last on
     move.l   #F_Date,a1        ; Date of file creation
     bra.s    Cmp_D1a
Cmp_D1:
     movem.l  a0-a1/d1-d2,-(a7)
Cmp_D1a:
     bsr      Cvrt_Dates       ; Convert Months
     move.b   d0,M_1
     move.b   d1,M_2
     move.b   (a0)+,d0         ; Garbage Chars
     move.b   (a1)+,d1         ;   "      "
     bsr      Cvrt_Dates       ; Convert Days
     move.b   d0,D_1
     move.b   d1,D_2
     move.b   (a0)+,d0         ; Garbage Chars
     move.b   (a1)+,d1         ;    "      "
     bsr      Cvrt_Dates       ; Convert Years
     move.b   d0,Y_1
     move.b   d1,Y_2

     clr.l    d1
     clr.l    d2
     move.b   Y_1,d1
     lsl.l    #8,d1
     move.b   M_1,d1
     lsl.l    #8,d1
     move.b   D_1,d1

     move.b   Y_2,d2
     lsl.l    #8,d2
     move.b   M_2,d2
     lsl.l    #8,d2
     move.b   D_2,d2

     move.w   #0,d0
     cmp.l    d1,d2
     bhs      Cmp_D2
     bra.s    Cmp_D3
Cmp_D2:
     move.w   #1,d0
Cmp_D3:
     movem.l  (a7)+,a0-a1/d1-d2
     rts

M_1:          dc.b  0
M_2:          dc.b  0
D_1:          dc.b  0
D_2:          dc.b  0
Y_1:          dc.b  0
Y_2:          dc.b  0

Cvrt_Dates:
     move.b   (a0)+,d2
     sub.b    #$30,d2
     mulu     #10,d2
     move.b   (a0)+,d0
     sub.b    #$30,d2
     add.b    d2,d0

     move.b   (a1)+,d2
     sub.b    #$30,d2
     mulu     #10,d2
     move.b   (a1)+,d1
     sub.b    #$30,d1
     add.b    d2,d1
     rts

Ask4_Level:
     move.l   #File_Lvl,Text_Adr
     bsr      String_Out
Ask4_L1:
     move.w   #0,Echo
     move.w   #1,Caps
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Ask4_L4
     cmp.w    #"A",Char
     bne      Ask4_L2
     move.l   #All_Msg,Text_Adr
     bsr      Line_Out
     move.w   #0,F_Attrib      ; Everyone    - Normal
     bra.s    Ask4_L4
Ask4_L2:
     cmp.w    #"H",Char
     bne      Ask4_L3
     move.l   #High_Msg,Text_Adr
     bsr      Line_Out
     move.w   #1,F_Attrib      ; High Access - Read Only
     bra.s    Ask4_L4
Ask4_L3:
     cmp.w    #"S",Char
     bne      Ask4_L1
     move.l   #SysOp_Msg,Text_Adr
     bsr      Line_Out
     move.w   #32,F_Attrib     ; Sysop Only  - Archived
Ask4_L4:
     rts

View_File:
     movem.l  a5/d4-d5,-(a7)
     bsr      CrLf
     bsr      CrLf
     move.l   #F_Pname2,Fo1+2
     bsr      See0
     cmp.w    #1,Exist
     bne      Vw_F4
Vw_F0:
     move.w   #0,File_Mode
     bsr      FOpen
     bsr      Get_File_Size
     bsr      FClose
     move.w   #0,File_Mode
     bsr      FOpen
     move.l   File_Size,d4
Vw_F0a:
     cmp.l    #2048,d4
     ble      Vw_F0b
     move.l   #2048,Num_Bytes
     sub.l    #2048,d4
     bra.s    Vw_F0c
Vw_F0b:
     move.l   d4,Num_Bytes
     sub.l    d4,d4
Vw_F0c:
     bsr      FRead            ; Read in Part of File...
     cmp.w    #0,d0
     beq      Vw_F4
Vw_F1:
     move.l   #File_Buf,a5
     move.l   a5,Text_Adr
     move.l   Num_Bytes,d5
     add.l    d5,a5
     move.b   #0,(a5)+
     move.b   #0,(a5)+
     movem.l  a5/d4-d5,-(a7)
     bsr      Word_Wrap        ;
     MOVEM.L  (a7)+,A5/D4-D5
     cmp.w    #3,Ctrl          ; Do we want to abort?
     beq      Vw_F5            ; Yep, so close file and exit...

     cmp.l    #0,d4
     bne      Vw_F0a
Vw_F4:
     bsr      FClose
     bsr      Wait_Rtrn
     add.w    #1,Downlds
     bsr      Cvrt_Dl_Stats
     bsr      WRITE_DWNLD_OK      ; ANd WRITE INFO TO LOG FILE
     bsr      Update_Description
     bra.s    Vw_F6
Vw_F5:
     bsr      FClose
Vw_F6:
     MOVEM.L  (a7)+,A5/D4-D5
     rts

See_Exist:
     move.l   #F_PName2,Fo1+2
See0:
     move.w   #0,File_Mode
     bsr      FOpen
     tst.w    d0
     bmi      See1
     bsr      FClose
     move.w   #1,Exist
     bra.s    See2
See1:
     move.w   #0,Exist
See2:
     rts

Exist:        dc.w  0

Term_Mode_Msg:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     " *** Terminal Mode ***",Cr,Lf,Cr,Lf,0
     align.w

Terminal_Mode:
     move.l   #Term_Mode_Msg,Text_Adr
     bsr      Send_Console
     bsr      Flush_Inp
Term_0:
     bsr      Scan_Console
     cmp.l    #0,d0
     beq      Term_2
     swap     d0
     cmp.w    #$44,d0          ; Function Key F-10
     bne      Term_1
     bsr      Term_Funct
     cmp.w    #"X",Char
     beq      Term_3
     cmp.w    #0,Carrier
     beq      Term_3
     bra.s    Terminal_Mode
Term_1:
     cmp.w    #Bksp,Char
     bne      Term_1a
     bsr      Put_Console
     bsr      Put_Modem
     move.w   #" ",Char
     bsr      Put_Console
     bsr      Put_Modem
     move.w   #8,Char
     bsr      Put_Console
     bsr      Put_Modem
     bra.s    Term_2
Term_1a:
     bsr      Put_Modem
Term_2:
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq      Term_0
     bsr      Put_Console
     bra.s    Term_0
Term_3:
     rts

Term_Funct:
     bsr      Flush_Inp
     move.l   #Term_Menu,Text_Adr
     bsr      Send_Console
Trm_F0:
     bsr      Get_Console
     and.w    #$df,d0
     move.w   d0,Char
     cmp.w    #"S",Char        ; Send a file
     bne      Trm_F1
     move.l   #Send_File_Msg,Text_Adr
     bsr      Line_Out
     bsr      Do_Download
     bra.s    Term_Funct
Trm_F1:
     cmp.w    #"R",Char        ; Receive a File
     bne      Trm_F1a
     move.l   #Recv_File_Msg,Text_Adr
     bsr      Line_Out
     bsr      Do_Upload
     bra.s    Term_Funct
Trm_F1a:
     cmp.w    #"Y",Char
     bne      Trm_F2
     move.l   #YBatch_Send_Msg,Text_Adr
     bsr      Line_Out
     bsr      Send_YBatch
     bra.s    Term_Funct
Trm_F2:
     cmp.w    #"T",Char        ; Go back to Terminal Mode
     bne      Trm_F3
     move.l   #Terminal_Mode_Msg,Text_Adr
     bsr      Line_Out
     bsr      CrLf
     bra.s    Trm_F7
Trm_F3:
     cmp.w    #"Q",Char        ; Quit to BBS
     bne      Trm_F4
     move.l   #Quit_Msg,Text_Adr
     bsr      Line_Out
     bsr      Disconnect
     move.w   #0,Carrier
     bra.s    Trm_F7
Trm_F4:
     cmp.w    #"B",Char        ; Baud Rate Change
     bne      Trm_F5
     move.l   #Change_Baud_Msg,Text_Adr
     bsr      Line_Out
     bsr      Change_Baud
     bra      Term_Funct
Trm_F5:
     cmp.w    #"X",Char        ; Exit to Transfer Utility
     bne      Trm_F6
     move.l   #Exit_Msg,Text_Adr
     bsr      Line_Out
     move.w   #"X",Char
     bra.s    Trm_F7
Trm_F6:
     bsr      Back_Space
     bra      Trm_F0
Trm_F7:
     rts

Term_Menu:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "[S] Send A File",Cr,Lf
     dc.b     "[R] Recv A File",Cr,Lf
     dc.b     "[B] Baud Rate Change",Cr,Lf
     dc.b     "[Y] Ymodem Batch Send",Cr,Lf
     dc.b     "[T] Terminal Mode",Cr,Lf
     dc.b     "[Q] Quit to BBS",Cr,Lf
     dc.b     "[X] eXit to Transfer Utility",Cr,Lf
     dc.b     Cr,Lf,"Choice >",0
     align.w

Change_Baud:
     move.l   #Baud_Msg,Text_Adr ; Show user the baudrates available
     bsr      Send_Console
     bsr      Flush_Inp
     bsr      Get_Console        ; Get a choice
     cmp.b    #Esc,d0            ; Escape..?
     beq      Chg_BdXit          ; If either, then exit!
     and.w    #$df,d0            ; Mask out Lower Case
     move.w   d0,Char
     bsr      Put_Console
     move.w   Char,d0
     sub.w    #65,d0             ; Convert to numeric from ascii
     cmp.w    #9,d0              ; Too big?
     bgt      Change_Baud        ; Repeat it for the hard of hearing!
     bsr      Set_Baud           ; Set the baud rate!
Chg_BdXit:
     rts

Baud_Msg:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "[A] 19200",Cr,Lf
     dc.b     "[B]  9600",Cr,Lf
     dc.b     "[C]  4800",Cr,Lf
     dc.b     "[D]  3600",Cr,Lf
     dc.b     "[E]  2400",Cr,Lf
     dc.b     "[F]  2000",Cr,Lf
     dc.b     "[G]  1800",Cr,Lf
     dc.b     "[H]  1200",Cr,Lf
     dc.b     "[I]   600",Cr,Lf
     dc.b     "[J]   300",Cr,Lf,Cr,Lf
     dc.b     "Please Select Desired Baud Rate Or",Cr,Lf
     dc.b     "Press ESCAPE To Return To Menu >",0
     align.w

Set_Baud:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   #-1,-(a7)        ; Scr
     move.w   #-1,-(a7)        ; Tsr
     move.w   #-1,-(a7)        ; Rsr
     move.w   #-1,-(a7)        ; Ucr
     move.w   #-1,-(a7)        ; Flowctrl
     move.w   d0,-(a7)         ; Baud Rate
     move.w   #15,-(a7)
     trap     #14
     add.w    #14,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Copy_FName:
     movem.l  a0-a2/d5,-(a7)
     move.l   #LineIn,a0
     move.l   F_PName_Adr,a1
     move.l   #F_Name,a2
     move.l   #11,d5
Cpy_Fn1:
     move.b   (a0)+,d0
     cmp.b    #Cr,d0
     beq      Cpy_Fn2
     cmp.b    #0,d0
     beq      Cpy_Fn2
     move.b   d0,(a1)+
     move.b   d0,(a2)+
     dbra     d5,Cpy_Fn1
Cpy_Fn2:
     move.b   #0,(a1)+
     move.b   #0,(a2)+
     move.b   #0,(a1)+
     move.b   #0,(a2)+
     movem.l  (a7)+,a0-a2/d5
     rts

Get_FileInfo:
     movem.l  a0-a4/d1-d6,-(a7)
     clr.l    d2
     move.l   #F_Name,a0
     move.l   #12,d5
GFi: move.b   #0,(a0)+
     dbra     d5,GFI

     move.l   #Dta,a4
     move.l   #Dta+30,a0
     move.l   #F_Name,a1
     move.l   F_PName_Adr,a2
     move.l   #12,d5
Gfi1:
     move.b   (a0)+,d2         ; Copy File Name
     cmp.b    #0,d2            ; from Dta to f_name area
     beq      Gfi2
     move.b   d2,(a1)+
     move.b   d2,(a2)+
     dbra     d5,Gfi1
     move.b   #0,(a1)+
     move.b   #0,(a2)+
     bra.s    Gfi2a
Gfi2:
     move.b   #0,(a1)+       ; Pad rest of area with spaces
     dbra     d5,Gfi2
Gfi2a:
     move.l   #F_Name,a1       ; copy file extension to
     move.l   #F_Ext,a2        ; F_Ext area
Gfi2b:
     move.b   (a1)+,d0
     cmp.b    #".",d0
     bne      Gfi2b
Gfi2c:
     move.b   (a1)+,d0
     cmp.b    #0,d0
     beq      Gfi2d
     move.b   d0,(a2)+
     bra.s    Gfi2c
Gfi2d:
     move.b   #0,F_Ext+3

     move.l   #14,d5
     move.l   #F_Name,a0
     move.l   #File_Name,a1
Sf2c:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      Sf2d
     move.b   d0,(a1)+
     sub.w    #1,d5
     bra.s    Sf2c
Sf2d:
     move.b   #" ",(a1)+
     dbra     d5,Sf2d

Gfi3:
     move.w   #0,F_Attrib
     move.b   21(a4),F_Attrib+1 ; Get File Attribute
     move.l   26(a4),d0
     move.l   d0,Fil_Sizt
     move.l   #F_Size,a3       ; Get File Size
     bsr      Pdec8            ; convert long to dec
     move.l   #F_Size,a0
     bsr      Zero_2_Space

     move.l   #F_Date,a3
     move.w   24(a4),d0       ; Date File Was Modified
     move.w   d0,File_Date
     move.l   d0,d1
     and.l    #%0000000111100000,d1
     lsr      #5,d1
     move.l   #Mnth,a2
     bsr      Set2b            ; Month
     move.b   #"/",(a3)+
     move.l   d0,d1
     and.l    #%0000000000011111,d1
     move.l   #Day,a2
     bsr      Set2b            ; Day
     move.b   #"/",(a3)+
     move.l   d0,d1
     and.l    #%1111111000000000,D1
     lsr      #8,d1
     lsr      #1,d1
     add      #80,d1
     move.l   #Yr,a2
     bsr      Set2b            ; Year

     move.l   #F_Time,a3
     clr.l    d0
     move.w   22(a4),d0       ; Time File Was Modified
     move.w   d0,File_Time
     move.l   d0,d1
     and.l    #%1111100000000000,D1
     lsr      #8,d1
     lsr      #3,d1
     cmp.w    #12,d1
     bgt      Gfi7_a
     move.b   #"a",F_Time+8
     bra.s    Gfi7_b
Gfi7_a:
     sub.w    #12,d1
     move.b   #"p",F_Time+8
Gfi7_b:
     move.l   #Hour,a2
     bsr      Set2b            ; Hour
     move.b   #":",(a3)+
     move.l   d0,d1
     and.l    #%0000011111100000,d1
     lsr      #5,d1
     move.l   #Min,a2
     bsr      Set2b            ; Min
     move.b   #":",(a3)+
     move.l   d0,d1
     and.l    #%0000000000011111,d1
     move.w   #" ",d6
     move.l   #Sec,a2
     bsr      Set2b            ; Sec
Gfi8:
     cmp.w    #9600,Baud1
     bne      G_Cps1
     move.w   #880,Cps
     bra.s    G_Cps5
G_Cps1:
     cmp.w    #4800,Baud1
     bne      G_Cps2
     move.w   #440,Cps
     bra.s    G_Cps5
G_Cps2:
     cmp.w    #2400,Baud1
     bne      G_Cps3
     move.w   #220,Cps
     bra.s    G_Cps5
G_Cps3:
     cmp.w    #1200,Baud1
     bne      G_Cps4
     move.w   #110,Cps
     bra.s    G_Cps5
G_Cps4:
     move.w   #30,Cps

G_Cps5:
     move.l   Fil_Sizt,d0
     divu     Cps,d0
     swap     d0
     clr.w    d0
     swap     d0
     divu     #60,d0
     swap     d0
     clr.w    d0
     swap     d0
     add.w    #2,d0
     move.w   d0,Min_Needed
     move.l   #F_Dltim,a3
     bsr      Pdec4
     move.l   #F_Dltim,a0
     bsr      Zero_2_Space

     move.l   Fil_Sizt,d0
     add.l    #1023,d0
     divu     #1024,d0
     swap     d0
     clr.w    d0
     swap     d0
     move.l   #F_YBlks,a3
     bsr      Pdec4
     move.l   #F_YBlks,a0
     bsr      Zero_2_Space
     move.l   Fil_Sizt,d0
     add.l    #127,d0
     divu     #128,d0
     swap     d0
     clr.w    d0
     swap     d0
     move.l   #F_XBlks,a3
     bsr      Pdec4
     move.l   #F_XBlks,a0
     bsr      Zero_2_Space
     movem.l  (a7)+,a0-a4/d1-d6
     rts

Mnth:         dc.w  0
Day:          dc.w  0
Yr:           dc.w  0
Hour:         dc.w  0
Min:          dc.w  0
Sec:          dc.w  0
File_Time:    dc.w  0
File_Date:    dc.w  0

Set2b:
     divu     #10,d1
     add.l    #$300030,d1
     move.b   d1,(a3)+
     move.b   d1,(a2)+
     swap     d1
     move.b   d1,(a3)+
     move.b   d1,(a2)+
     rts

Zero_2_Space:
     move.l   a0,a1
Z_2Sp1:
     move.b   (a0)+,d0
     cmp.b    #"0",d0
     bne      Z_2Sp2
     move.b   #" ",(a1)+
     bra.s    Z_2Sp1
Z_2Sp2:
     rts

Left_Just:
     movem.l  a2-a4/d0-d5,-(a7)
     move.l   a2,a3
     move.l   a2,a4
     clr.l    d4
Lft_J1:
     move.b   (a2)+,d0
     cmp.b    #"0",d0
     bne      Lft_J2a
     add.w    #1,d4
     dbra     d5,Lft_J1
     bra.s    Lft_J2b
Lft_J2:
     move.b   (a2)+,d0
Lft_J2a:
     move.b   d0,(a3)+
     dbra     d5,Lft_J2
Lft_J2b:
     cmp.l    #0,d4
     beq      Lft_J3a
     sub.l    #1,d4
Lft_J3:
     move.b   #" ",(a3)+
     dbra     d4,Lft_J3
Lft_J3a:
     cmp.b    #" ",(a4)
     bne      Lft_J4
     move.b   #"0",(a4)
Lft_J4:
     movem.l  (a7)+,a2-a4/d0-d5
     rts

Get_File_Size:
     move.w   #2,Where
     move.l   #0,How_Many
     bsr      lseek            ; Get Length of file
     move.l   d0,File_Size
     rts

Show_File1:
     move.l   d5,-(a7)
     bsr      Copy_Access
     bsr      Copy_Lastdl
     bsr      Copy_Dl_Count
     move.l   #13,d5
     move.l   #File_Name,Text_Adr
     bsr      Show_String
     move.l   #8,d5
     move.l   #F_Size,Text_Adr
     bsr      Show_String
     move.l   #4,d5
     move.l   #F_DlTim,Text_Adr
     bsr      Show_String
     move.w   #" ",Char
     bsr      Put_Char
     move.l   #6,d5
     move.l   #F_Dl_Count,Text_Adr
     bsr      Show_String
     move.l   #42,d5
     move.l   #Msg_Line,Text_Adr
     bsr      Show_String
     bsr      CrLf
     move.l   (a7)+,d5
     rts

Show_String:
     movem.l  a6/d5,-(a7)
     move.l   Text_Adr,a6
Shw_Str1:
     move.w   #0,Char
     move.b   (a6)+,Char+1
     cmp.w    #0,Char
     beq      Shw_Str2
     cmp.w    #Cr,Char
     beq      Shw_Str2
     cmp.w    #Lf,Char
     bne      Shw_Str3
Shw_Str2:
     move.w   #" ",Char
Shw_Str3:
     bsr      Put_Char
     dbra     d5,Shw_Str1
     movem.l  (a7)+,a6/d5
     rts

Show_File2:
     movem.l  a0-a1/d5,-(a7)
     move.l   #F_YBlks,a0
     MOVE.L   #F_YZMBLKS,A1
     move.l   #3,d5
Sf2a:
     move.b   (a0)+,(a1)+
     dbra     d5,Sf2a
     move.l   #F_XBlks,a0
     move.l   #F_Xmblks,a1
     move.l   #3,d5
Sf2b:
     move.b   (a0)+,(a1)+
     dbra     d5,Sf2b
     bsr      Copy_Access
     bsr      Copy_Uploader
     bsr      Copy_Lastdl
     bsr      Copy_Dl_Count
     clr.l    d5
     move.l   #File_Info,Text_Adr
     move.w   #1,No_Color
     bsr      Word_Wrap
     move.w   #0,No_Color
     movem.l  (a7)+,a0-a1/d5
     rts

Copy_Access:
     movem.l  a0-a1/d5,-(a7)
     cmp.w    #1,F_Attrib
     bne      C_a1
     move.l   #High_A,a0
     bra.s    C_a3
C_a1:
     cmp.w    #32,F_Attrib
     bne      C_a2
     move.l   #SysOp_A,a0
     bra.s    C_a3
C_a2:
     move.l   #Normal_A,a0
C_a3:
     move.l   #14,d5
     move.l   #F_Access,a1
C_a4:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      C_a5
     move.b   d0,(a1)+
     sub.w    #1,d5
     cmp.w    #0,d5
     beq      C_a5
     bra.s    C_a4
C_a5:
     move.b   #" ",(a1)+
     dbra     d5,C_a5
     movem.l  (a7)+,a0-a1/d5
     rts

Copy_Uploader:
     movem.l  a0-a1/d5,-(a7)
     move.l   #Uploader,a0
     move.l   #F_Uploader,a1
     move.l   #21,d5
C_u1:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      C_u2
     move.b   d0,(a1)+
     sub.w    #1,d5
     cmp.w    #0,d5
     beq      C_u2
     bra.s    C_u1
C_u2:
     move.b   #" ",(a1)+
     dbra     d5,C_u2
     movem.l  (a7)+,a0-a1/d5
     rts

Copy_Lastdl:
     movem.l  a0-a1/d5,-(a7)
     move.l   #Lst_dl,a0
     move.l   #F_Lst_Dl,a1
     move.l   #15,d5
C_Ld1:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      C_Ld2
     move.b   d0,(a1)+
     sub.w    #1,d5
     cmp.w    #0,d5
     beq      C_Ld2
     bra.s    C_Ld1
C_Ld2:
     move.b   #" ",(a1)+
     dbra     d5,C_Ld2
     movem.l  (a7)+,a0-a1/d5
     rts

Copy_Dl_Count:
     move.l   a3,-(a7)
     clr.l    d0
     move.w   Accs_Cntr,d0
     move.l   #F_Dl_Count,a3
     bsr      Pdec4
     move.l   #F_Dl_Count,a0
     bsr      Zero_2_Space
     move.l   (a7)+,a3
     rts

Normal_A:     dc.b  "Normal",0,0
High_A:       dc.b  "High",0,0
SysOp_A:      dc.b  "SysOp Only",0,0

File_Info:    dc.b  Cr,Lf,Cr,Lf
              dc.b  "Filename      : "
File_Name:    dc.b  "                      ",160
              dc.b  "Download Time : "
F_DlTim       dc.b  "0000 Mins             ",Cr,Lf
              dc.b  "File Size     : "
F_Size:       dc.b  "                      ",160
              dc.b  "Access Level  : "
F_Access:     dc.b  "                      ",Cr,Lf
              dc.b  "Uploaded By   : "
F_Uploader:   dc.b  "                      ",160
              dc.b  "Download Count: "
F_DL_Count:   dc.b  "                      ",Cr,Lf
              dc.b  "Uploaded On   : "
F_Date:       dc.b  "00/00/00              ",160
              dc.b  "Last Download : "
F_Lst_Dl:     dc.b  "00/00/00              ",Cr,Lf
              dc.b  "Uploaded at   : "
F_Time:       dc.b  "00:00:00pm            ",160
              dc.b  "                "
              dc.b  "                      ",Cr,Lf
              dc.b  "Blocks:  Ymodem/Zmodem-"
F_YZmblks:    dc.b  "0000"
              DC.B  160,", Xmodem-"
F_Xmblks:     dc.b  "0000             ",Cr,Lf
              dc.b  Cr,Lf,"Description:",Cr,Lf,0,0,0
              align.w


              dc.l  0
F_Name:       dc.l  0,0,0,0
              dc.l  0
F_Ext:        dc.l  0,0
F_Attrib:     dc.w  0
              dc.w  0

Get_Sig_Path:                  ; And Sig Name Too...
     MOVEM.L  A0-A4/D2-D7,-(a7)
     clr.l    d4
     move.w   Sig_Num,d4
     move.l   #File_A,a5
     sub.w    #1,d4
     mulu     #2,d4
     add.l    d4,a5
     move.w   (a5)+,d4
     move.w   d4,Real_Sig_Num
     move.l   d4,d2
     sub.w    #1,d4
     muls     #62,d4
     move.l   #FileSigPath,a0
     Add.w    d4,a0            ; Get Offset of Sig Path

     move.l   #F_Pname2,a1
     move.l   a1,Sig_Path_Adr
     move.l   #DirPath,a2
     move.l   #Desc_Path,a3
     move.l   #79,d6
Bp1: move.b   #0,(a1)+         ; Clear out Dir Path Area
     move.b   #0,(a2)+
     move.b   #0,(a3)+
     dbra     d6,bp1

     move.l   #F_Pname2,a1
     move.l   #DirPath,a2
     move.l   #Desc_Path,a3
     clr.l    d7
Bp2: move.b   (a0)+,d7
     cmp.b    #0,d7
     beq      bp3
     move.b   d7,(a1)+
     move.b   d7,(a2)+
     move.b   d7,(a3)+
     bra.s    bp2
Bp3:
     move.l   a1,F_PName_Adr   ; Where to Store the Actual Filename
     move.l   a2,DirPath_Adr
     move.b   #"D",(a3)+
     move.b   #"E",(a3)+
     move.b   #"S",(a3)+
     move.b   #"C",(a3)+
     move.b   #"\",(a3)+
     move.l   a3,F_DName_Adr

     move.l   d2,d4
     sub.w    #1,d4
     move.l   #FileSigName,a0
     muls     #32,d4
     Add.w    d4,a0            ; Get Offset of Sig Name

     move.l   #Sig_Name,a1
     move.l   #62,d6
Bp4: move.b   #0,(a1)+         ; Clear out Sig Name Area
     dbra     d6,bp4

     move.l   #Sig_Name,a2
     clr.l    d7
Bp5: move.b   (a0)+,d7
     cmp.b    #0,d7
     beq      bp6
     move.b   d7,(a2)+
     bra.s    bp5
Bp6:
     move.b   #" ",(a2)+
     move.b   #":",(a2)+
     move.l   Sig_Path_Adr,a0
     clr.l    d0
     move.b   (a0),d0
     sub.w    #65,d0
     move.w   d0,Drive
     bsr      SetDrv
     bsr      ChDir
     bsr      Get_Sig_Access_Lvl
     movem.l  (a7)+,a0-a4/d2-d7
     rts

Get_Sysdata:
     movem.l  a0-a4/d5/d7,-(a7)
     move.l   BasePage,a0
     add.l    #$27084,a0       ; a0 now points to Sysdata Area...
     move.l   a0,a1
     add.l    #3,a1            ; Get System Date
     move.l   #7,d5
     move.l   #Date,a2
Get_Sd1:
     move.b   (a1)+,d0
     cmp.b    #" ",d0
     bne      Get_Sd1a
     move.b   #"0",d0
Get_Sd1a:
     move.b   d0,(a2)+
     dbra     d5,Get_Sd1
Get_Sd2:
     move.l   a0,a1
     add.l    #102,a1          ; Get User Log Path
     clr.l    d5
     move.b   (a1)+,d5
     sub.w    #1,d5
     and.w    #$ff,d5
     move.l   #UserLog,a2
Get_Usr1:
     move.b   (a1)+,(a2)+
     dbra     d5,Get_Usr1

     move.l   a0,a1
     add.l    #288,a1          ; Get Log File Path
     clr.l    d5
     move.b   (a1)+,d5
     move.l   #LogFile,a2
     sub.w    #1,d5
     and.w    #$ff,d5
Get_Log1:
     move.b   (a1)+,(a2)+
     dbra     d5,Get_Log1

     move.l   a0,a1
     add.l    #382,a1          ; Get # of File Sigs
     move.w   (a1),FileSigNum

     move.l   a0,a1
     add.l    #384,a1          ; Get File Sig Names
     move.l   #FileSigName,a3  ; a3 = destination address
     clr.l    d7
     move.w   FileSigNum,d7
     sub.w    #1,d7
     and.w    #$ff,d7
Ss1:
     move.l   a1,a2
     move.l   a3,a4
     clr.l    d5
     move.b   (a2)+,d5         ; Length of File Sig Name
     cmp.b    #0,d5
     beq      Get_fsn2
     sub.l    #1,d5
     and.w    #$ff,d5
Get_Fsn:
     move.b   (a2)+,(a4)+      ; Copy the File Sig Name
     dbra     d5,Get_Fsn
Get_Fsn2:
     add.l    #32,a1
     add.l    #32,a3
     dbra     d7,Ss1

     move.l   a0,a1
     add.l    #1408,a1         ; Get File Sig Paths
     MOVE.L   #FILESIGPATH,A3  ; A3 = DSTINATION ADDRESS
     clr.l    d7
     move.w   FileSigNum,d7
     sub.w    #1,d7
     and.w    #$ff,d7
Ss2:
     move.l   a1,a2
     move.l   a3,a4
     clr.l    d5
     move.b   (a2)+,d5         ; Length of File Sig Path
     cmp.b    #0,d5
     beq      Get_fsp2
     sub.l    #1,d5
     and.w    #$ff,d5
Get_Fsp:
     move.b   (a2)+,d0         ; Copy the File Sig Path
     cmp.b    #"z",d0          ; and change to UPPER Case...
     bgt      Get_Fsp1
     cmp.b    #"a",d0
     blt      Get_Fsp1
     sub.b    #32,d0
Get_Fsp1:
     move.b   d0,(a4)+
     dbra     d5,Get_Fsp
Get_Fsp2:
     add.l    #62,a1
     add.l    #62,a3
     dbra     d7,Ss2
     movem.l  (a7)+,a0-a4/d5/d7
     rts

Last_Call:    dc.b  "08/01/89"
              dc.l  0
Get_UserData:
     movem.l  a0-a3/d5,-(a7)
     move.l   BasePage,a0
     add.l    #$26ae4,a0       ; Where User data is located.
     move.l   a0,User_Adr
     move.l   a0,a1
     add.l    #2,a1
     move.l   #User_Name,a2
     clr.l    d5
     move.b   (a1)+,d5         ; Copy Users' Name...
     sub.l    #1,d5
     and.w    #$ff,d5
Usr0:
     move.b   (a1)+,(a2)+
     dbra     d5,Usr0
     move.b   #0,(a2)+
     move.b   #0,(a2)+
     move.l   a0,a1
     add.l    #200,a1          ; Point to last call date
     move.b   (a1)+,d5
     move.l   #Last_Call,a2
     move.l   #7,d5
Usr1:
     cmp.b    #" ",(a1)
     bne      Usr2
     move.b   #"0",(a1)
Usr2:
     move.b   (a1)+,(a2)+      ; Copy Last Call Date
     dbra     d5,Usr2

     move.l   a0,a1
     move.w   210(a1),Time_On
     move.w   218(a1),Dl_Ratio
     move.w   230(a1),Video_Width ;  40 or 80
     move.w   240(a1),Translation ; 0-Ascii, 1-Atascii, 2-VT52
     add.l    #220,a0
     move.l   a0,Downloads
     move.w   (a0),Downlds
     add.l    #2,a0
     move.l   a0,Uploads
     move.w   (a0),Uplds
     move.l   196(a1),Cmnd_Lvl
     move.l   272(a1),File_Access
     move.l   276(a1),FIle_Valid
     move.l   280(a1),File_Edit
     move.l   284(a1),File_Delete

     clr.l    d0
     move.w   Dl_Ratio,d0
     move.l   #Rto2,a3
     bsr      PDec4

     move.l   Basepage,a0
     add.l    #$2ad24,a0
     move.w   (a0)+,d0

     cmp.w    #0,d0
     bne      Chk_Bd1
     move.w   #300,Baud1
     bra.s    Chk_Bd4
Chk_Bd1:
     cmp.w    #1,d0
     bne      Chk_Bd2
     move.w   #1200,Baud1
     bra.s    Chk_Bd4
Chk_Bd2:
     cmp.w    #2,d0
     bne      Chk_Bd3
     move.w   #2400,Baud1
     bra.s    Chk_Bd4
Chk_Bd3:
     move.w   #9600,Baud1
Chk_Bd4:

     move.l   Basepage,a0
     add.l    #$2acfc,a0
     move.w   0(a0),Hi_Msg_No
     move.w   2(a0),User_No
     move.w   4(a0),T_P_C

     move.l   BasePage,a0
     add.l    #$3cf04,a0
     move.w   (a0),a0          ; a0.w holds Current time on Sys...
     move.w   a0,Time_at_Load
     move.l   #0,a1
     move.w   Time_On,a1       ; Time_On is time allowed per call
     sub.w    a0,a1
     move.w   a1,Time_On
     movem.l  (a7)+,a0-a3/d5
     rts

Tal:          dc.w  0,0,0
Time_at_load: dc.w  0
Dl_Ratio:     dc.w  0          ; Download Ratio
Downloads:    dc.l  0          ; Address of Download Counter
Downlds:      dc.w  0          ; Download Counter
Uploads:      dc.l  0          ; Address of Upload Counter
Uplds:        dc.w  0          ; Upload Counter
Video_Width:  dc.w  0          ; Video Width
Translation:  dc.w  0          ; Translation

User_Name:    dc.l  0,0,0,0,0,0,0,0,0,0
User_No:      dc.w  0

Baud1:        dc.w  0,0
T_P_C:        dc.w  0          ; Time per Call
Hi_Msg_No:    dc.w  0
Time_On:      dc.w  0,0
Timer:        dc.l  0      ; Current Timer Value
Time_Up:      dc.l  0      ; Timer Val At Init Run Time
TimeLeft:     dc.l  0      ; Time That User Has Left
Type:         dc.l  0
Max_Time:     dc.l  0
Minutes:      dc.w  0
Seconds:      dc.w  0
Mins:         dc.b  "000 Mins Left) ",0
     align.w

Get_Levels:
     MOVEM.L  A1/D0-D2/D5,-(a7)
     move.l   Cmnd_Lvl,Dummy
     move.l   #Cmnd_L,a1
     bsr      G_lvl

     move.l   File_Access,Dummy
     move.l   #File_A,a1
     bsr      G_lvl

     move.l   File_Delete,Dummy
     move.l   #File_D,a1
     bsr      G_lvl

     move.l   File_Edit,Dummy
     move.l   #File_E,a1
     bsr      G_lvl

     move.l   File_Valid,Dummy
     move.l   #File_V,a1
     bsr      G_lvl

     Move.l   #Cmnd_L,a1
     move.w   #0,High_Access
     move.w   #0,Sig_Op
     move.w   #0,Sys_Op
     move.l   #31,d5
     clr.l    d1
Chk_H1:
     move.w   (a1)+,d1
     cmp.w    #30,d1
     bne      Chk_H1a
     move.w   #1,High_Access
     bra.s    Chk_H1c
Chk_H1a:
     cmp.w    #31,d1
     bne      Chk_H1b
     move.w   #1,Sig_Op
     bra.s    Chk_H1d
Chk_H1b:
     cmp.w    #32,d1
     bne      Chk_H1c
     move.w   #1,Sys_Op
     bra.s    Chk_H1d
Chk_H1c:
     cmp.w    #$e5e5,d1
     beq      Chk_H3
Chk_H1d:
     dbra     d5,Chk_H1
;     bra.s    Chk_H3
Chk_H3:
     movem.l  (a7)+,a1/d0-d2/d5
     rts

Get_Sig_Access_Lvl:
     movem.l  a1-a3/d1-d4,-(a7)
     move.l   #Access_D,a1
     move.w   #0,(a1)+
     move.w   #0,(a1)+
     move.w   #0,(a1)+
     clr.l    d1
     move.w   Real_Sig_Num,d1
     move.l   #File_D,a1
     move.l   #31,d3
     move.l   d3,d4
Gsal_1:
     move.w   (a1)+,d0
     CMP.W    REAL_SIG_NUM,d0
     beq      Gsal_1a
     dbra     d4,Gsal_1
     bra.s    Gsal_1b
Gsal_1a:
     move.w   #1,Access_D
Gsal_1b:
     move.l   #File_E,a1
     move.l   d3,d4
Gsal_2:
     move.w   (a1)+,d0
     CMP.W    REAL_SIG_NUM,d0
     beq      Gsal_2a
     dbra     d4,Gsal_2
     bra.s    Gsal_2b
Gsal_2a:
     move.w   #1,Access_E
Gsal_2b:
     move.l   #File_V,a1
     move.l   d3,d4
Gsal_3:
     move.w   (a1)+,d0
     CMP.W    REAL_SIG_NUM,d0
     beq      Gsal_3a
     dbra     d4,Gsal_3
     bra.s    Gsal_3b
Gsal_3a:
     move.w   #1,Access_V
Gsal_3b:
     movem.l  (a7)+,a1-a3/d1-d4
     rts

Real_Sig_Num: ds.w  1
Access_D:     ds.w  1
Access_E:     ds.w  1
Access_V:     ds.w  1

G_Lvl:
     Move.l   Dummy,d1         ; d1 = Total Levels value
     move.l   #1,d5
     move.l   d5,d6
Gl1: move.l   d1,d2
     and.l    d6,d2
     cmp.l    #0,d2
     beq      Gl2
     move.w   d5,(a1)+
Gl2: add.l    d6,d6
     add.w    #1,d5
     cmp.w    #33,d5
     bne      Gl1
Gl3: move.w   (a1),d0
     cmp.w    #$Dead,d0
     beq      Gl4
     move.w   #$e5e5,(a1)+
     bra.s   Gl3
Gl4: 
     rts

Wait_Rtrn:
     bsr      Flush_Inp
     Move.l   #Return,Text_Adr
     bsr      String_Out
     move.w   #0,Echo
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Wt_Rt1
     bsr      CrLf
     bsr      CrLf
Wt_Rt1:
     rts

Return:
     dc.b     Cr,Lf,Cr,Lf,"Press RETURN to Continue >",0,0
     align.w

Pdec8:
     divu     #10000,d0
     swap     d0
     move     d0,-(a7)
     swap     d0
     and.l    #$ffff,d0
     move.l   #1000,d1
     bsr      Dec1
     move     (a7)+,d0
Pdec4:
     move.l   #1000,d1
Dec1:
     divu     d1,d0
     move.l   d0,Dec2
     add.b    #"0",d0
     move.b   d0,(a3)+
     move.l   Dec2,d0
     swap     d0
     and.l    #$ffff,d0
     divu     #10,d1
     bne      dec1
     rts

Hex_Long:                      ; display d0 as Hex LOng
     moveq    #7,d1            ; with a3 holding hex string address
     bra.s    Hex_WL1
Hex_Word:
     swap     d0
     moveq    #3,d1
     bra.s    Hex_WL1
Hex_Byte:
     moveq    #1,d1
     ror.l    #8,d0
Hex_WL1:
     rol.l    #4,d0
     move.l   d0,-(a7)
     move.l   d1,-(a7)
     bsr      Hex_Nibble
     move.l   (a7)+,d1
     move.l   (a7)+,d0
     dbra     d1,Hex_WL1
     rts

Hex_Nibble:
     and.l    #15,d0
     add.b    #$30,d0
     cmp.b    #$3a,d0
     bcs      Hex_Nib1
     add.b    #7,d0
Hex_Nib1:
     move.b   d0,(a3)+
     rts

Word_Wrap:
     movem.l  a4-a5/d5,-(a7)
     move.w   #0,Ctrl
     move.l   Text_Adr,a4
Word_Wrap0:
     move.l   #Word_Temp,a5
     move.w   #0,Ky_Cnt        ; # of Chars in word
     move.w   #0,Char_Cnt      ; # of Chars in Line
Wrd_Wrp0:
     bsr      Check_Control
     move.w   Video_Width,d0
     sub.w    #1,d0
     cmp.w    Char_Cnt,d0      ; are we at end of line?
     beq      Wrd_Wrp1
Wrd_Wrp0a:
     move.w   #0,Char
     move.b   (a4)+,Char+1
     cmp.w    #0,Char
     beq      Wrd_Wrp3
     cmp.w    #160,Char
     bne      Wrd_Wrp0b
     cmp.w    #40,Video_Width
     beq      Wrd_Wrp1
     bra.s    Wrd_Wrp0a
Wrd_Wrp0b:
     cmp.w    #Cr,Char         ; Is it a Cr?
     bne      Wrd_Wrp0c
     move.b   (a4)+,d0         ; Clear out Lf
     cmp.w    #0,Char_Cnt
     bne      Wrd_Wrp0b1
     bsr      CrLf
     BRA      WORD_WRAP0
Wrd_Wrp0b1:
     move.b   #0,(a5)+
     move.l   #Word_Temp,Text_Adr
     bsr      Wrd_Wrp30
     bra      Word_Wrap0
Wrd_Wrp0c:
     cmp.w    #Lf,Char
     beq      Wrd_Wrp0a
     move.b   Char+1,(a5)+
     add.w    #1,Ky_Cnt
     add.w    #1,Char_Cnt
     cmp.w    #" ",Char
     beq      Wrd_Wrp2
     bra      Wrd_Wrp0
Wrd_Wrp1:
     move.b   #0,(a5)+
     bsr      CrLf
     move.l   #Word_Temp,Text_Adr
     bsr      Wrd_Wrp20
     bra      Word_Wrap0
Wrd_Wrp2:
     move.b   #0,(a5)+
     move.l   #Word_Temp,Text_Adr
     bsr      Wrd_Wrp20
     move.l   #Word_Temp,a5
     move.w   #0,Ky_Cnt
     bra      Wrd_Wrp0
Wrd_wrp3:
     cmp.w    #1,Mesg_Type
     bne      Wrd_Wrp5
     move.b   #0,(a5)+
     move.l   #Word_Temp,Text_Adr
     bsr      Wrd_Wrp30
Wrd_Wrp5:
     movem.l  (a7)+,a4-a5/d5
     rts

Wrd_Wrp20:
     movem.l  a4-a5,-(a7)
     bsr      String_Out
     movem.l  (a7)+,a4-a5
     rts

Wrd_Wrp30:
     movem.l  a4-a5,-(a7)
     bsr      Line_Out
     movem.l  (a7)+,a4-a5
     rts

Msg_Abort:    dc.b  Cr,Lf,Cr,Lf," **** Message Aborted **** ",Cr,Lf,0
     align.w

Check_Control:
     bsr      Scan_Console
     cmp.w    #0,d0            ; Any Chars from Console?
     bne      Ctrl_S3
     bsr      Scan_Modem
     cmp.w    #0,d0            ; Any Chars From Modem?
     beq      Ctrl_Xit         ; None from either, So Continue on
Ctrl_S3:
     cmp.w    #3,Char          ; Ctrl-C Abort?
     bne      Ctrl_S4
     move.w   #3,Ctrl
     move.l   #Msg_Abort,Text_Adr
     bsr      String_Out
     bra.s    Ctrl_Xit
Ctrl_S4:
     cmp.w    #Dc3,Char        ; Ctrl-S Pause?
     bne      Ctrl_Xit
Ctrl_S5:
     bsr      Scan_Console
     cmp.w    #0,d0
     bne      Ctrl_S6
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq      Ctrl_S5
Ctrl_S6:
     cmp.w    #Dc1,Char        ; Ctrl-Q Resume?
     bne      Ctrl_S5
Ctrl_Xit:
     rts

Ctrl:         dc.w  0
Char_Cnt:     dc.w  0
Ky_Cnt:       dc.w  0
Word_Temp:    dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
S_Tmp1:       dc.l  0

Line_Out:
     bsr      String_Out
     bsr      CrLf
     rts

String_Out:
     movem.l  a1/a6/d5,-(a7)
     move.l   Text_Adr,a6
So1: move.w   #0,Char
     move.b   (a6)+,Char+1
     move.l   a6,S_Tmp1
     cmp.w    #Cr,Char
     bne      So2
     bsr      CrLf
     move.l   S_Tmp1,a6
     move.b   (a6)+,d0         ; Get rid of Lf
     bra.s    So1
So2:
     cmp.w    #160,Char
     bne      So2a
     cmp.w    #40,Video_Width
     bne      So2a
     bsr      CrLf
     bra.s    So1
So2a:
     cmp.w    #Lf,Char
     beq      So1
     cmp.w    #0,Char
     beq      So_Xit
     cmp.w    #1,No_Color
     beq      So3
     cmp.w    #"/",Char        ; do we wan't color text?
     bne      So3
     clr.l    d0
     move.b   (a6)+,d0
     cmp.w    #0,d0
     beq      So_Xit
     move.w   d0,Vt52_Char
     move.w   d0,Char
     cmp.w    #"b",Char        ; Black Text?
     bne      Vt52_1
     cmp.w    #2,Translation   ; can the user display color?
     bne      So1
     move.l   #2,d5
     move.l   #Black_Text,a1
     bra      Vt52_7
Vt52_1:
     cmp.w    #"g",Char        ; Green Text?
     bne      Vt52_2
     cmp.w    #2,Translation   ; can the user display color?
     bne      So1
     move.l   #2,d5
     move.l   #Green_Text,a1
     bra      Vt52_7
Vt52_2:
     cmp.w    #"r",Char        ; Red Text?
     bne      Vt52_3
     cmp.w    #2,Translation   ; can the user display color?
     bne      So1
     move.l   #2,d5
     move.l   #Red_Text,a1
     bra      Vt52_7
Vt52_3:
     cmp.w    #"w",Char        ; White Text?
     bne      Vt52_4
     cmp.w    #2,Translation   ; can the user display color?
     bne      So1
     move.l   #2,d5
     move.l   #White_Text,a1
     bra.s    Vt52_7
Vt52_4:
     cmp.w    #"i",Char        ; Invert Text?
     bne      Vt52_8
     cmp.w    #2,Translation   ; can the user display color?
     bne      So1
     move.l   #1,d5
     move.l   #Invert_Text,a1
Vt52_7:
     move.w   #0,Char
     move.b   (a1)+,Char+1
     bsr      Put_Char
     dbra     d5,Vt52_7
     bra      So1
Vt52_8:
     move.w   #"/",Char
     bsr      Put_Char
     sub.l    #1,a6
     bra      So1
So3:
     bsr      Put_Char
     bra      So1
So_Xit:
     movem.l  (a7)+,a1/a6/d5
     rts

White_Text:   dc.b  Esc,"b","0",0
Red_Text:     dc.b  Esc,"b","1",0
Green_Text:   dc.b  Esc,"b","2",0
Black_Text:   dc.b  Esc,"b","3",0
Invert_Text:  dc.b  Esc,"p","0",0

No_Color:     dc.w  0
Vt52_Char:    dc.w  0

Line_In:
     movem.l  a4/a6/d5,-(a7)
     bsr      Flush_Inp
     move.l   #LineIn,a4        ; Clean up Text Area..
     move.l   #20,d5
LI1: move.l   #0,(a4)+
     dbra     d5,LI1

     move.l   #LineIn,a4
     move.l   Length,d5
     move.w   d5,Count
Lin_1:
     move.w   #0,Echo
     move.w   #1,No_Show
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq      Lin_Xit
     cmp.w    #Cr,Char
     bne      Lin_2
     move.b   #Cr,(a4)+
     bra.s    Lin_Xit
Lin_2:
     cmp.w    #Bksp,Char
     bne      Lin_4
     cmp.w    Count,d5
     beq      Lin_1
     cmp.w    #1,Count
     beq      Lin_Xit
     bsr      Back_Space
     sub.l    #1,a4
     add.w    #1,Count
     bra.s    Lin_1
Lin_4:
     cmp.w    #" ",Char
     bcs      Lin_1
     cmp.w    #"~",Char
     bhi      Lin_1
     bsr      Put_Char
     move.b   Char+1,(a4)+
     sub.w    #1,count
     cmp.w    #0,Count
     bne      Lin_1
Lin_Xit:
     move.w   #0,No_Show
     movem.l  (a7)+,a4/a6/d5
     rts

Back_Space:
     move.w   #Bksp,Char
     bsr      Put_Char
     move.w   #32,Char
     bsr      Put_Char
     move.w   #Bksp,Char
     bsr      Put_Char
     rts

Chk_carrier:
     movem.l  a1/d1,-(a7)
     clr.l    d1
     move.w   d1,Carrier
     cmp.w    #1,Local         ; If We're not in local mode
     bne      Carr_1           ;  We'll test for a carrier
     move.w   #1,Carrier
     bra.s    Carr_3
Carr_1:
     bsr      super_on
     move.l   #$fffa01,a1
     move.b   (a1),d1
     and.b    #2,d1
     cmp.b    #0,d1            ; 0 = Carrier Present
     bne      Carr_2
     move.w   #1,Carrier       ; Say That We Have A Carrier
Carr_2:
     bsr      super_off
Carr_3:
     cmp.w    #1,Carrier
     beq      Carr_4
     move.w   #Can,Char
Carr_4:
     movem.l  (a7)+,a1/d1
     rts

Setdrv:
     movem.l  a0-a2/d0-d4,-(a7)
     move.w   drive,-(a7)
     move.w   #$0e,-(a7)
     trap     #1
     addq.l   #4,a7
     bsr      Show_Error
     movem.l  (a7)+,a0-a2/d0-d4
     rts

Drive:        dc.w  0

Save_Cur:     dc.b  Esc,"j",0,0
Set_Cur:      dc.b  Esc,"k",0,0

Chdir:
     movem.l  a0-a2/d1-d4,-(a7)
     move.l   Sig_Path_Adr,-(a7)
     move.w   #$3b,-(a7)
     trap     #1
     addq.l   #6,a7
     bsr      Show_Error
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Upper_C:
     move.w   Char,d0
     cmp.w    #"z",D0
     bgt      Uc1
     cmp.w    #"a",D0
     blt      Uc1
     sub.w    #32,d0
     move.w   d0,char
Uc1:
     rts

Get_Timer:
     bsr      super_on
     move.l   $4ba,Timer
     bsr      super_off
     rts

Zero_timer:
     bsr      super_on
     move.l   #1,$4ba
     bsr      super_off
     rts

Show_TimeLeft:
     move.w   #"(",Char
     bsr      Put_Char
     bsr      Check_TimeOn
     move.l   #Mins,Text_Adr
     bsr      String_Out
     rts

Check_TimeOn:
     movem.l  a0-a6/d1-d6,-(a7)
     bsr      Get_Timer
     move.l   Timer,d0         ; Get Current Timer Value
     sub.l    Time_Up,d0       ; and subtract value at entry
     divu     #12000,d0        ; -> we only want minutes
     move.w   d0,Minutes       ; Minutes On Since Entry...
     clr.l    d0
     move.w   Time_On,d0       ; Time Used before entry...
     sub.w    Minutes,d0
     move.l   d0,Timeleft      ; Time Left = Minutes Left Online
     move.l   #Space2,a3
     bsr      Pdec4            ; Convert Binary to Dec/Ascii
     move.l   #Space2,a0
     add.l    #1,a0
     move.l   #Mins,a1
     move.l   #2,d5
CHK_T1:
     move.b   (a0)+,(a1)+
     dbra     d5,Chk_T1
     move.w   #$2c,-(a7)
     trap     #1
     addq.l   #2,sp
     move.w   d0,Cur_Time
     move.w   #$2a,-(a7)
     trap     #1
     addq.l   #2,sp
     move.w   d0,Cur_Date
     movem.l  (a7)+,a0-a6/d1-d6
     rts

Cur_Time:     dc.w  0
Cur_Date:     dc.w  0

Check_DownTime:
     bsr      Check_TimeOn
     move.w   Total,d0
     divu     Cps,d0
     divu     #60,d0
     move.w   d0,Min_Needed
     rts

Flush_Inp:
fl1: bsr      Scan_Modem
     cmp.w    #0,d0
     bne      fl1
fl2: bsr      Scan_Console
     cmp.w    #0,d0
     bne      fl2
fl3:
     rts

Lin_Count:    dc.w  0
Del_Line:     dc.b  Esc,"j",Esc,"Y% ",Esc,"M",Esc,"k",Esc,"A",0,0

CrLf:
     movem.l  a6/d5,-(a7)
     cmp.w    #1,Local
     beq      Lf1
Lf0:
     move.w   #Cr,Char
     bsr      Put_Modem
     move.w   #Lf,Char
     bsr      Put_modem
Lf1:
;     cmp.w    #1,Menu_Code
;     bne      Lf2
     add.w    #1,Lin_Count
     cmp.w    #19,Lin_Count
     blt      Lf2
     move.l   #Del_Line,Text_Adr
     bsr      Send_Console
Lf2:
     move.w   #Cr,char
     bsr      Put_Console
     move.w   #Lf,char
     bsr      Put_Console
     movem.l  (a7)+,a6/d5
     rts

Super_On:
     movem.l  a1-a6/d1-d6,-(a7)
     clr.l    -(a7)
     move.w   #$20,-(a7)
     trap     #1
     add.l    #6,sp
     move.l   d0,Old_Supr
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Super_Off:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   Old_Supr,-(a7)
     move.w   #$20,-(a7)
     trap     #1
     add.l    #6,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Get_Screen:
     movem.l  a0-a1/d5,-(a7)
     move.l   Phys_Base,a0
     move.l   #Screen_Data,a1
     move.l   #1599,d5
Gt_Scn:
     move.l   (a0)+,(a1)+
     dbra     d5,Gt_Scn
     movem.l  (a7)+,a0-a1/d5
     rts

Put_Screen:
     movem.l  a0-a1/d5,-(a7)
     move.l   #Screen_Data,a0
     move.l   Phys_Base,a1
     move.l   #1599,d5
Pt_Scn:
     move.l   (a0)+,(a1)+
     dbra     d5,Pt_Scn
     movem.l  (a7)+,a0-a1/d5
     rts

Asc2Bin:
     movem.l  a0-a1/d0-d5,-(a7)
     clr.l    d5
     move.l   a0,a1
Fnd_L1:
     move.b   (a1)+,d0         ; Find the length of input line
     cmp.b    #0,d0
     beq      Fnd_L2
     cmp.b    #Cr,d0
     beq      Fnd_L2
     add.w    #1,d5
     bra.s    Fnd_L1
Fnd_L2:                        ; We Have The Length Here...
     move.l   a0,a1            ; copy pointer to ascii number
     add.l    d5,a1
     sub.l    #1,d5
     clr.l    d2
     move.l   #1,d1            ; Tens Counter
Asc2b1:
     clr.l    d0
     move.b   -(a1),d0         ; get a char (Backwards) from Ascii Num
     sub.b    #$30,d0
     mulu     d1,d0            ; get actual value of Char
     add.l    d0,d2            ; and add it to the result
     mulu     #10,d1           ; multiply 10's counter by 10...
     dbra     d5,Asc2b1        ; continue converting rest of number
Asc2b2:
     move.l   d2,Binary_Long
     move.w   d2,Binary_Word
     movem.l  (a7)+,a0-a1/d0-d5
     rts

Binary_Long:  dc.l  0
Binary_Word:  dc.w  0

Clear_Screen:
     move.l   a6,-(a7)
     move.l   #Clr_Scn2,Text_Adr  ; Clear Local Screen
     bsr      Send_Console
     cmp.w    #0,Translation
     bne      Cls_1
     move.l   #Clr_Scn0,Text_Adr
     bra.s    Cls_2
Cls_1:
     move.l   #Clr_Scn1,Text_Adr
Cls_2:
     bsr      Send_Modem
     move.w   #0,Lin_Count
     move.l   (a7)+,a6
     rts

Clr_Scn0:     dc.b  12,0                    ; Ascii   Clear Screen
Clr_Scn1:     dc.b  Esc,"E",0,0             ; Vt-52   Clear Scren
Clr_Scn2:     dc.b  Esc,"Y% ",Esc,"J",0,0   ; Code for Local Screen

Write_Upld_Ok:
     MOVE.L   #UPLD_OK_MSG,TEXT_ADR
     bsr      Write_Line
     move.l   #F_Name,Text_Adr
     bsr      Write_Line
     move.l   #New_Line,Text_Adr
     bsr      WRITE_LINE
     rts

Upld_Ok_Msg:
     dc.b     "  Uploaded ",0

Write_Upld_Abrt:
     MOVE.L   #UPLD_ABRT_MSG,TEXT_ADR
     bsr      Write_Line
     move.l   #F_Name,Text_Adr
     bsr      Write_Line
     move.l   #New_Line,Text_Adr
     bsr      WRITE_LINE
     rts

Upld_Abrt_Msg:
     dc.b     "Aborted Upload Of ",0,0

Write_Dwnld_Ok:
     MOVE.L   #DWNLD_OK_MSG,TEXT_ADR
     bsr      Write_Line
     move.l   #F_Name,Text_Adr
     bsr      Write_Line
     move.l   #New_Line,Text_Adr
     bsr      WRITE_LINE
     rts

Dwnld_Ok_Msg:
     dc.b     "Downloaded ",0

Write_Dwnld_Abrt:
     MOVE.L   #DWNLD_ABRT_MSG,TEXT_ADR
     bsr      Write_Line
     move.l   #F_Name,Text_Adr
     bsr      Write_Line
     move.l   #New_Line,Text_Adr
     bsr      WRITE_LINE
     rts

Dwnld_Abrt_Msg:
     dc.b     "Aborted Download Of ",0,0

Write_Line:
     movem.l  a2-a3/d1/d5,-(a7)
     move.l   #LogFile,Fo1+2
     move.l   Text_Adr,a2
     move.l   #File_Buf,a3
     clr.l    d5
Wrt_L1:
     move.b   (a2)+,d1
     move.b   d1,(a3)+
     cmp.b    #0,d1
     beq      Wrt_L2
     add.w    #1,d5
     bra.s    Wrt_L1
Wrt_L2:
     move.l   d5,Num_Bytes
     move.w   #1,File_Mode
     bsr      FOpen
     tst.w    d0
     bmi      Wrt_L3
     bsr      Get_File_Size
     bra.s    Wrt_L4
Wrt_L3:
     move.l   #0,F_Attrib
     bsr      FCreate
Wrt_L4:
     bsr      FWrite
     bsr      FClose
     movem.l  (a7)+,a2-a3/d1/d5
     rts

FK_Addr:      dc.l  1

FKill:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Fil_StatK,Text_Adr
     bsr      Send_Console
     move.l   Fk_Addr,File_Adr
     bsr      Show_Cur_File
     move.l   Fk_Addr,-(a7)    ; Kill a File...
     move.w   #$41,-(a7)
     trap     #1
     add.l    #6,sp
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Change_Mode:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   F_Attrib,-(a7)
     move.w   #1,-(a7)
     move.l   #F_Pname2,-(a7)
     move.w   #$43,-(a7)
     trap     #1
     add.l    #10,sp
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Fcreate:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Fil_StatR,Text_Adr
     bsr      Send_Console
     move.l   Fo1+2,File_Adr
     bsr      Show_Cur_File
     move.w   F_Attrib,-(a7)   ; 0 - Normal, 1 - Read Only, 2 - Hidden
     move.l   Fo1+2,-(a7)      ; 4 - System, 8 - Volume, 16 - Folder
     move.w   #$3c,-(a7)       ; 32 - Archived
     trap     #1
     addq.l   #8,sp
     move.w   d0,fhandle
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

File_Mode:    dc.w  0

Fopen:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Fil_StatP,Text_Adr
     bsr      Send_Console
     move.l   Fo1+2,File_Adr
     bsr      Show_Cur_File
     move.w   File_Mode,-(a7)  ; 0=Read Only, 1=Write Only, 2=Read/Write
Fo1: move.l   #F_Name,-(a7)
     move.w   #$3d,-(a7)
     trap     #1
     addq.l   #8,sp
Fo3: move.w   d0,Fhandle
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

It_Exists:
     move.l   a6,-(a7)
     move.l   #Does_Exist,Text_Adr
     bsr      String_Out
     Move.l   Fo1+2,Text_Adr
     bsr      Line_Out
     move.l   (a7)+,a6
     rts

Fclose:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Fil_StatC,Text_Adr
     bsr      Send_Console
     move.l   Fo1+2,File_Adr
     bsr      Show_Cur_File
     move.w   Fhandle,-(a7)
     move.w   #$3e,-(a7)
     trap     #1
     addq.l   #4,sp
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Fread:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Fil_StatI,Text_Adr
     bsr      Send_Console
     move.l   Fo1+2,File_Adr
     bsr      Show_Cur_File
     move.l   #File_Buf,-(a7)
     move.l   Num_Bytes,-(a7)
     move.w   Fhandle,-(a7)
     move.w   #$3f,-(a7)
     trap     #1
     add.l    #12,sp
     move.l   d0,N_Read
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

FWrite:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Fil_StatO,Text_Adr
     bsr      Send_Console
     move.l   Fo1+2,File_Adr
     bsr      Show_Cur_File
     move.l   #File_Buf,-(a7)
     move.l   Num_Bytes,-(a7)
     move.w   Fhandle,-(a7)
     move.w   #$40,-(a7)
     trap     #1
     add.l    #12,sp
     bsr      Show_Error
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Lseek:
     movem.l  a0-a2/d1-d4,-(a7)
     move.l   #Fil_StatS,Text_Adr
     bsr      Send_Console
;     bsr      Show_Handle
     move.w   Where,-(a7)   ; 0 from start, 1 from curr pos, 2 from end
     move.w   Fhandle,-(a7)
     move.l   How_Many,-(a7)
     move.w   #$42,-(a7)
     trap     #1
     add.l    #10,a7
     cmp.w    #-64,d0
     beq      Lseek1
     bsr      Show_Error
Lseek1:
     movem.l  (a7)+,a0-a2/d1-d4
     rts

SFirst:
     movem.l  a1-a6/d1-d6,-(a7)
     move.l   #Dta,-(a7)
     move.w   #$1a,-(a7)
     trap     #1
     addq.l   #6,sp

     move.w   #32,-(a7)
SFirst1:
     move.l   #DirPath,-(a7)
     move.w   #$4e,-(a7)
     trap     #1
     addq.l   #8,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Snext:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   #$4f,-(a7)
     trap     #1
     addq.l   #2,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Show_Cur_File:
     movem.l  a0-a1/d5,-(a7)
     move.l   File_Adr,a0
     move.l   #File_File,a1
     move.l   #38,d5
Scf_1:
     move.b   (a0)+,d0
     cmp.b    #0,d0
     beq      Scf_2
     move.b   d0,(a1)+
     sub.w    #1,d5
     cmp.w    #0,d5
     beq      Scf_3
     bra.s    Scf_1
Scf_2:
     move.b   #" ",(a1)+
     dbra     d5,Scf_2
Scf_3:
     move.l   #Cur_Fil1,Text_Adr
     bsr      Send_Console
     move.l   #File_File,Text_Adr
     bsr      Send_Console
     move.l   #Cur_Fil2,Text_Adr
     bsr      Send_Console
     movem.l  (a7)+,a0-a1/d5
     rts

Fil_StatI:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27," Input",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatO:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27,"Output",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatU:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27,"Update",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatP:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27,"  Open",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatR:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27,"Create",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatC:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27," Close",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatK:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27,"Delete",Esc,"c0",Esc,"b3",Esc,"k",0,0
Fil_StatS:    dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+27,"  Seek",Esc,"c0",Esc,"b3",Esc,"k",0,0

Cur_FiL1:     dc.b  Esc,"j",Esc,"b0",Esc,"c3",Esc,"Y",32+3,32+40,0,0
Cur_FiL2:     dc.b  Esc,"c0",Esc,"b3",Esc,"k",0,0
File_Adr:     dc.l  0
File_File:    dc.l  0,0,0,0,0,0,0,0,0,0,0,0

Get_Char:                      ; Registers a5-a6 saved...
     movem.l  a5-a6,-(a7)
     bsr      Flush_Inp
     bsr      Get_Timer
     move.l   Timer,a6
     add.l    #36000,a6
Get_Char1:
     bsr      Get_Timer
     move.l   Timer,a5
     cmp.l    a5,a6
     blt      Gc00
     bsr      Chk_Carrier
     cmp.w    #1,Carrier
     beq      Gc0
     bra      Gc9
Gc00:
     bsr      Disconnect       ; Disconnect user if 3 minutes
     move.w   #0,Carrier       ; Has lapsed since last keystroke...
     move.w   #TimeOut,Char
     bra      Gc9
Gc0:
     bsr      Scan_Console
     cmp.w    #0,d0
     bne      Gfc1
     cmp.w    #0,Fnct_Key
     bne      Gfc1
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq      Get_Char1
     bra.s    Gc1
Gfc1:
     cmp.w    #$5d,Fnct_Key    ; Shift - F10
     bne      Gfc2
     bsr      Disconnect
     bra      Gc9
Gfc2:
     cmp.w    #$3f,Fnct_Key    ; F5
     bne      Gc1
     bsr      Chat_Mode
     bra      Gc9
Gc1:
     move.w   d0,Char
     cmp.w    #Cr,d0           ; Carrige Return ?
     beq      Gc1a
     cmp.w    #Lf,d0           ; Linefeed ?
     beq      Gc1a
     cmp.w    #Bksp,d0         ; Back Space
     beq      Gc2
     cmp.w    #Dc1,d0          ; Ctrl - Q
     beq      Gc2
     cmp.w    #Dc3,d0          ; Ctrl - S
     beq      Gc2
     cmp.w    #3,d0            ; Ctrl - C
     beq      Gc2
     cmp.w    #" ",d0
     bcs      Gc2
     cmp.w    #"~",d0
     bhi      Gc2
     cmp.w    #1,Caps          ; Do we want Caps Only?
     bne      Gc1a
     bsr      Upper_C
Gc1a:
     cmp.w    #1,Echo          ; Do we want it echoed?
     bne      Gc1b
     bsr      Put_Char
Gc1b:
     move.w   Char,d0
Gc2:
     move.w   d0,Char
     cmp.w    #1,No_Show
     beq      Gc9
     cmp.w    #" ",d0
     bcs      Gc3
     cmp.w    #"~",d0
     bhi      Gc3
     move.w   Char,d0
Gc3:
     nop
Gc9:
     bsr      Show_TD
     move.w   #0,No_Show
     movem.l  (a7)+,a5-a6
     rts

No_Show:      dc.w  0
Echo:         dc.w  0

Put_Char:
     movem.l  a0-a1/d5,-(a7)
     bsr      Chk_Carrier
     cmp.w    #1,Carrier
     beq      Pc0
     bra.s    Pc5
Pc0:
     move.w   Char,d0
     cmp.b    #"",d0
     beq      Pc3
     cmp.b    #"",d0
     beq      Pc3
     cmp.b    #"",d0
     beq      Pc3
     cmp.b    #"",d0
     beq      Pc3
     cmp.b    #Esc,d0          ; Escape?
     beq      Pc3
     cmp.b    #Bksp,d0         ; Back Space?
     beq      Pc3
     cmp.b    #Cr,d0           ; Carrige Return?
     beq      Pc3
     cmp.b    #Lf,d0           ; Line Feed?
     beq      Pc3
     cmp.b    #Bell,d0         ; Bell?
     beq      Pc3
     cmp.b    #" ",d0          ; less than a space
     bcs      Pc5
     cmp.b    #"~",d0          ; or greater than a '~'
     bhi      Pc5
Pc3:
     cmp.w    #1,Local
     beq      Pc4
     bsr      Put_Modem
Pc4:
     bsr      Put_Console
Pc5:
     MOVEM.L  (a7)+,A0-A1/D5
     rts

Scan_Console:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #0,Fnct_Key
     move.w   #2,-(a7)
     move.w   #1,-(a7)
     trap     #13
     addq.l   #4,a7
     movem.l  (a7)+,a0-a2/d1-d4
     tst.l    d0
     bpl.s    Skip_Con
Get_Console:
     movem.l  a0-a3/d1-d4,-(a7)
     move.w   #2,-(a7)
     move.w   #2,-(a7)
     trap     #13
     addq.l   #4,a7
     swap     d0
     move.w   d0,Fnct_Key
     swap     d0
     move.w   d0,Char
     movem.l  (a7)+,a0-a3/d1-d4
     rts

Fnct_Key:     dc.w  0

Skip_Con:
     move.w   #0,D0
     rts

Line_Tmp:     dc.l  0

Send_Console:
     move.l   a6,-(a7)
     move.l   Text_Adr,a6
Sc1: move.w   #0,Char
     move.b   (a6)+,Char+1
     cmp.w    #0,Char
     beq      Sc2
     bsr      Put_Console
     bra.s    Sc1
Sc2: move.l   (a7)+,a6
     rts

Put_Console:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   Char,-(a7)
     move.w   #2,-(a7)
     move.w   #3,-(a7)
     trap     #13
     addq.l   #6,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Send_Modem:
     move.l   a6,-(a7)
     move.l   Text_Adr,a6
Sm1: move.w   #0,Char
     move.b   (a6)+,Char+1
     cmp.w    #0,Char
     beq      Sm2
     bsr      Put_Modem
     bra.s    Sm1
Sm2: move.l   (a7)+,a6
     rts

Put_Modem:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   Char,-(a7)
     move.w   #1,-(a7)
     move.w   #3,-(a7)
     trap     #13
     addq.l   #6,sp
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Scan_Modem:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   #1,-(a7)
     move.w   #1,-(a7)
     trap     #13
     addq.l   #4,sp
     movem.l  (a7)+,a1-a6/d1-d6
     tst.l    d0
     bpl.s    Skip_Modem
Get_Modem:
     movem.l  a1-a6/d1-d6,-(a7)
     move.w   #1,-(a7)
     move.w   #2,-(a7)
     trap     #13
     addq.l   #4,sp
     move.w   d0,Char
     movem.l  (a7)+,a1-a6/d1-d6
     rts

Skip_Modem:
     move.w   #0,d0
     move.w   d0,Char
     rts

Call_Msg:     dc.b  Cr,Lf,"Paging SysOp ",0
              align.w

No_Ans_Msg:   dc.b  Cr,Lf,"  Sorry! The SysOp Doesn't Answer,",160
              dc.b  "  Please Try Again Later...",0
              align.w

Page_Msg:     dc.b  7,"*",0,0

Call_Chat:
     move.l   d5,-(a7)
     move.l   #Call_Msg,Text_Adr
     bsr      String_Out
     move.l   #25,d5
Cl_Cht1:
     move.l   #Page_Msg,Text_Adr
     bsr      String_Out
     move.w   #0,Seconds
     bsr      Pause
     bsr      Scan_Console
     cmp.w    #$3f,Fnct_Key    ; F5
     bne      Cl_Cht2
     bsr      Chat_Mode
     bra.s    Cl_Cht_Xit
Cl_Cht2:
     dbra     d5,Cl_Cht1
     move.l   #No_Ans_Msg,Text_Adr
     bsr      Line_Out
Cl_Cht_Xit:
     bsr      CrLf
     move.l   (a7)+,d5
     rts

Chat_Mode:
     move.w   #0,Echo
     move.w   #0,Caps
     move.l   #Chat_Entr_Msg,Text_Adr
     bsr      Line_Out
     bsr      Flush_Inp
Chat_0:
     cmp.w    #1,Word_Pending
     bne      Chat_1
     move.l   #Word_Temp,Text_Adr
     bsr      String_Out
     move.w   #0,Word_Pending
     move.w   Ky_Cnt,Char_No
     move.w   #0,Ky_Cnt
     move.l   #Word_Temp,a5
     bra.s    Chat_1a
Chat_1:
     move.l   #Word_Temp,a5
     move.w   #0,Ky_Cnt        ; # of Chars in Word
     move.w   #0,Char_No       ; # of Chars in Line
Chat_1a:
     bsr      Get_Chat_Char
     cmp.w    #0,Carrier
     beq      Chat_Xit
     cmp.w    #$3f,Fnct_Key    ; Norml - F5    Exit Chat
     beq      Chat_Xit
     cmp.w    #$5d,Fnct_Key    ; Shift - F10   Hang Up
     bne      Chat_2
     bsr      Disconnect
     bra      Chat_Xit
Chat_2:
     cmp.w    #0,Carrier
     beq      Chat_Xit
     cmp.w    #Cr,Char
     beq      Chat_9
     cmp.w    #Bksp,Char
     bne      Chat_7
     cmp.w    #0,Char_No
     beq      Chat_1a
Chat_3:
     bsr      Back_Space
     sub.w    #1,Char_No
     sub.l    #1,a5
     sub.w    #1,Ky_Cnt
     bra      Chat_1a
Chat_7:
     cmp.w    #" ",Char
     bne      Chat_7a
     move.w   #0,Ky_Cnt
     move.l   #Word_Temp,a5
Chat_7a:
     move.b   Char+1,(a5)
     add.l    #1,a5
     add.w    #1,Ky_Cnt
     add.w    #1,Char_No
     move.w   Video_Width,d0
     sub.w    #1,d0
     cmp.w    Ky_Cnt,d0
     beq      Chat_7b
     cmp.w    Char_No,d0
     beq      Chat_8
     bsr      Put_Char
     bra      Chat_1a
Chat_7b:
     move.b   #0,(a5)
     bra.s    Chat_9
Chat_8:
     move.b   #0,(a5)
     clr.l    d6
     move.w   Ky_Cnt,d6
     sub.w    #1,d6
Chat_8a:
     bsr      Back_Space
     dbra     d6,Chat_8a
     move.w   #1,Word_Pending
Chat_9:
     bsr      CrLf
     bra      Chat_0
Chat_Xit:
     move.l   #Chat_Exit_Msg,Text_Adr
     bsr      Line_Out
     rts

Get_Chat_Char:
     BSR      CHK_CARRIER
     cmp.w    #0,Carrier
     beq      Gt_CC_Xit
     bsr      Scan_Console
     cmp.w    #0,d0
     bne      Gt_CC_Xit
     cmp.w    #0,Fnct_Key
     bne      Gt_CC_Xit
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq      Get_Chat_Char
Gt_CC_Xit:
     rts

Chat_Entr_Msg:  dc.b  Cr,Lf," SysOp Entering Chat Mode...",Cr,Lf,0
     align.w

Chat_Exit_Msg:  dc.b  " You Are Now Back In Control...",Cr,Lf,0
     align.w

UpdateCrc:
     move.w   #$8,count
     bra.s    L4
L5:
     clr.w    d0
     move.w   crc,d0
     and.w    #$8000,d0
     beq      L6
     lsl      crc
     asl      c
     move.w   c,d0
     and.w    #$100,d0
     bne      L10000
     clr.w    d0
     bra.s    L10001
L10000:
     moveq    #$1,d0
L10001:
     add.w    d0,crc
     eori.w   #$1021,crc
     bra.s    L4
L6:
     lsl      crc
     asl      c
     move.w   c,d0
     and.w    #$100,d0
     bne      L10002
     clr.w    d0
     bra.s    L10003
L10002:
     moveq    #$1,d0
L10003:
     add.w    d0,crc
L4:
     subq.w   #1,count
     bge      L5
L2:
     clr.w    d0
     move.w   crc,d0
L1:
     rts

Show_Error:
     movem.l  a0-a3/d0-d1,-(a7)
     cmp.w    #0,Shw_Error
     beq      Shw_Err_Xit
     swap     d0
     clr.w    d0
     swap     d0
     tst.w    d0
     bmi      Shw_err1
     bra      Shw_Err_Xit
Shw_Err1:
     move.l   #65536,d1
     sub.l    d0,d1
     move.l   d1,d0
     move.w   d0,Error
     cmp.w    #0,d0
     bcs      Shw_Err_Xit
     cmp.w    #100,d0
     bhi      Shw_Err_Xit
Shw_Err2:
     move.l   #Err_Num,a3
     move.l   #10,d1
     bsr      Dec1
     move.l   #Error_Table,a0
     clr.l    d0
     clr.l    d1
Shw_Err3:
     move.w   (a0)+,d0
     move.l   (a0)+,d1
     cmp.w    #-1,d0
     beq      Shw_Err4
     cmp.w    Error,d0
     bne      Shw_Err3
Shw_Err4:
     move.l   d1,a0
     move.l   #Err_Dsc,a1
     move.l   #33,d1
Shw_Err5:
     move.b   (a0)+,d0
     move.b   d0,(a1)+
     cmp.b    #0,d0
     beq      Shw_Err6
     dbra     d1,Shw_Err5
Shw_Err6:
     move.l   #Err_Msg,Text_Adr
     bsr      String_Out
     move.l   Fo1+2,Text_Adr
     bsr      Line_Out
     move.l   #Error_Desc,Text_Adr
     bsr      Line_Out
Shw_Err_Xit:
     move.w   #1,Shw_Error
     movem.l  (a7)+,a0-a3/d0-d1
     rts

Shw_Error:    dc.w  0
Error:        dc.w  0
Err_Msg:      dc.b  Cr,Lf,Cr,Lf
              dc.b  " System Error: -"
Err_Num:      dc.b  "00",Cr,Lf
              dc.b  "    Filename : ",0
              align.w

Error_Desc:   dc.b  " Description : "
Err_Dsc:      dc.b  "                                  ",0
              align.w

Err_100:      dc.b  " Unknown Error",0
Err_1:        dc.b  " General Error",0
Err_2:        dc.b  " Drive Not Ready",0
Err_3:        dc.b  " Unknown Command",0
Err_4:        dc.b  " CRC Error",0
Err_5:        dc.b  " Bad Request",0
Err_6:        dc.b  " Seek Error",0
Err_7:        dc.b  " Unknown Media",0
Err_8:        dc.b  " Sector Not Found",0
Err_9:        dc.b  " No Paper",0
Err_10:       dc.b  " Write Error",0
Err_11:       dc.b  " Read Error",0
Err_12:       dc.b  " General Error",0
Err_13:       dc.b  " Disk Write Protected",0
Err_14:       dc.b  " Disk Was Changed",0
Err_15:       dc.b  " Unknown Device",0
Err_16:       dc.b  " Bad Sector",0
Err_17:       dc.b  " Insert Disk",0
Err_32:       dc.b  " Invalid Function Number",0
Err_33:       dc.b  " File Not Found",0
Err_34:       dc.b  " Pathname Not Found",0
Err_35:       dc.b  " Too Many Files Open",0
Err_36:       dc.b  " Access Not Possible",0
Err_37:       dc.b  " Invalid Handle Number",0
Err_39:       dc.b  " Not Enough Memory",0
Err_40:       dc.b  " Invalid Memory Block Address",0
Err_46:       dc.b  " Invalid Drive Specification",0
Err_49:       dc.b  " No More Files",0
Err_64:       dc.b  " GEMDOS range error, Seek Wrong?",0
Err_65:       dc.b  " GEMDOS internal error",0
Err_66:       dc.b  " Invalid executable file format",0
Err_67:       dc.b  " Memory Block Growth Failure",0
              align.w

Error_Table:  dc.w  1
              dc.l  Err_1
              dc.w  2
              dc.l  Err_2
              dc.w  3
              dc.l  Err_3
              dc.w  4
              dc.l  Err_4
              dc.w  5
              dc.l  Err_5
              dc.w  6
              dc.l  Err_6
              dc.w  7
              dc.l  Err_7
              dc.w  8
              dc.l  Err_8
              dc.w  9
              dc.l  Err_9
              dc.w  10
              dc.l  Err_10
              dc.w  11
              dc.l  Err_11
              dc.w  12
              dc.l  Err_12
              dc.w  13
              dc.l  Err_13
              dc.w  14
              dc.l  Err_14
              dc.w  15
              dc.l  Err_15
              dc.w  16
              dc.l  Err_16
              dc.w  17
              dc.l  Err_17
              dc.w  32
              dc.l  Err_32
              dc.w  33
              dc.l  Err_33
              dc.w  34
              dc.l  Err_34
              dc.w  35
              dc.l  Err_35
              dc.w  36
              dc.l  Err_36
              dc.w  37
              dc.l  Err_37
              dc.w  39
              dc.l  Err_39
              dc.w  40
              dc.l  Err_40
              dc.w  46
              dc.l  Err_46
              dc.w  49
              dc.l  Err_49
              dc.w  64
              dc.l  Err_64
              dc.w  65
              dc.l  Err_65
              dc.w  66
              dc.l  Err_66
              dc.w  67
              dc.l  Err_67
              dc.w  -1
              dc.l  Err_100

     data

; ----------------------------------

Flip:         dc.w  0
Sig_Num:      dc.w  0
F_Temp:       dc.l  0
Dec2:         dc.l  0
Old_Supr:     dc.l  0

; -----------------------------------

c:            dc.w  0
crc:          dc.w  0
count:        dc.w  0
LoCrc:        dc.b  0,0
HiCrc:        dc.b  0,0

; --------------------------


Cmnd_Lvl:     dc.l  $ffffffff
Cmnd_L:       dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5Dead

File_Access:  dc.l  $ffffffff
File_A:       dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5Dead

File_Valid:   dc.l  1
File_V:       dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5Dead

File_Edit:    dc.l  1
File_E:       dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5Dead

File_Delete:  dc.l  1
File_D:       dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5
              dc.l  $e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5e5e5,$e5e5Dead

; ------------------------------------------------------------

Char:         dc.w  0
Char1:        dc.w  0
Char2:        dc.w  0
Char_Tmp:     dc.w  0
Fhandle:      dc.w  0
Where:        dc.w  0
Num_Bytes:    dc.l  0
How_Many:     dc.l  0
Fil_Ptr:      dc.l  0

Attrib:       dc.w  0
Carrier:      dc.w  0
Length:       dc.l  0
Local:        dc.w  0

;-----------------    File Download Vars  -----------------
Min_Needed:   dc.w  0
Total:        dc.w  0
Cps:          dc.w  0
Stop_Send:    dc.w  0
Tries:        dc.w  0
CheckSum:     dc.w  0
OurCksm:      dc.w  0
Send_Errs:    dc.w  0
Block_Count:  dc.w  0
Block_Number: dc.w  0
Blkn1:        dc.w  0
Blkn2:        dc.w  0
Block_Size:   dc.w  0
Header_Ch:    dc.w  0
New_Header_Ch:      dc.w  0
Eof_Xfile:    dc.w  0
XFile_Size:   dc.l  0
N_Read:       dc.l  0
Bm_Cntr:      dc.w  0
Bm_Temp:      dc.w  0
Need_Uploads: dc.w  0
Transfer_Time:      dc.w  0
Effective_Rate:     dc.w  0
Use_Crc:      dc.w  0

Blck_Num1a:   dc.b  Esc,"Y",32+11,32+33

Blck_Num1b:   dc.b  "0000",0,0


Errs1_Msg:
     dc.b     Esc,"Y",32+11,32+16
Errs2_Msg:
     dc.b     "0000",0,0

NewFiles:
     dc.w     0

Caps:         dc.w  0
Text_Adr:     dc.l  0
Dummy:        dc.l  0

Sig_Name:
     dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Errtext:
     dc.b     "A Disk Error Has Occured!!!",Cr,Lf,0
Does_Exist:
     dc.b     Cr,Lf,"File Already Exists -> ",0
Doesnt_Exist:
     dc.b     Cr,Lf,"File Does Not Exist -> ",0
Err_Read:
     dc.b     "Can't Read File -> ",0
Err_Lseek:
     dc.b     "Can't Lseek File -> ",0,0
NoDesc_Msg:
     dc.b     " No Description For This File",Cr,Lf,0
Hangup_Msg:
     dc.b     Cr,Lf,"Hang Up After Downloading (y/N) ?",0
Hang_Up:
     dc.w     0

File_Lvl:
     dc.b     Cr,Lf,Cr,Lf,"  [/rA/b]ll,  [/rH/b]igh Access or [/rS/b]ysOp Only"
     dc.b     Cr,Lf,Cr,Lf," Choice ->",0
     align.w

New_Line:
     dc.b     Cr,Lf,0,0

Tries1:
     dc.b     Esc,"Y",32+11,32+55
Tries2:
     dc.b     "00",0,0

;  ----------------------  ARC/LZH/ZIP DATA STUFF  ----------------


Arc_Msg1:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "Name         Length   Stowage  Size Now  CRC",Cr,Lf
     dc.b     "============ ======== ======== ======== ====",Cr,Lf,0
     align.w

Arc_Msg2:
     dc.b     "============ ======== ======== ======== ====",Cr,Lf
     dc.b     "Total        ",0
     align.w

Lzh_Msg1:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "Name         Actual   Packed   Method  CRC",Cr,Lf
     dc.b     "------------ -------- -------- ------ ----",Cr,Lf,0
     align.w

Lzh_Msg2:
     dc.b     "------------ -------- -------- ------ ----",Cr,Lf
     dc.b     "Total        ",0
     align.w

Zip_Msg1:
     dc.b     Cr,Lf,Cr,Lf
     dc.b     "Filename     Actual   Size Now   Method  CRC-32",Cr,Lf
     dc.b     "------------ -------- --------  -------- --------",Cr,Lf,0
     align.w

Zip_Msg2:
     dc.b     "------------ -------- --------  -------- --------",Cr,Lf
     dc.b     "Total        ",0
     align.w

Arc_Type1:    dc.b  "Stored   ",0
Arc_Type2:    dc.b  "Packed   ",0
Arc_Type3:    dc.b  "Squeezed ",0
Arc_Type4:    dc.b  "Crunched ",0
Arc_Type5:    dc.b  "Squashed ",0
Arc_Type6:    dc.b  "Unknown  ",0
Arc_Type7:    dc.b  "         ",0
Arc_Type9:    dc.b  "Folder   ",0
Arc_NSiz:     dc.b  "         ",0
Arc_OSiz:     dc.b  "         ",0
Arc_Crc:      dc.b  "0000",0,0

Arc_Ntot:     dc.b  "00000000 ",0
Arc_Otot:     dc.b  "00000000 ",0

Zip_Type0:    dc.b  "Stored   ",0
Zip_Type1:    dc.b  "Shrunk   ",0
Zip_Type2:    dc.b  "   2     ",0
Zip_Type3:    dc.b  "   3     ",0
Zip_Type4:    dc.b  "   4     ",0
Zip_Type5:    dc.b  "Reduced4 ",0
Zip_Type6:    dc.b  "Imploded ",0
Zip_Type7:    dc.b  "   7     ",0
Zip_Type8:    dc.b  " Hmmmm   ",0

Blk_Num1:     dc.b  "0000",0,0
Blk_Num2:     dc.b  "0000",0,0

; ------------- X/Y Modem Transfer Messages ---------------

Transfer_Screen:
     dc.b     Esc,"f"          ; Disable Cursor
     dc.b     Esc,"Y% ",Esc,"J",Cr,Lf,Cr,Lf,Cr,Lf
     dc.b     "     ©--------------------------------------------------------------------ª",Cr,Lf
     dc.b     "     | Filename:                                                          |",Cr,Lf
     dc.b     "     |----------------+------------------------+-----------+--------------|",Cr,Lf
     dc.b     "     | Errors : 0000  |  Block # 0000 of 0000  |  Try: 00  | Mode:        |",Cr,Lf
     dc.b     "     |-----------+----+---------+--------------+-+---------+--------------|",Cr,Lf
     dc.b     "     |           | Status:      | Bytes: 0000000 | Prot:                  |",Cr,Lf
     dc.b     "     |-----------+--------------+----------------+----+-------------------|",Cr,Lf
     dc.b     "     | Msg:                                           |                   |",Cr,Lf
     dc.b     "     +------------------------------------------------+-------------------+",Cr,Lf,0
     align.w

EobAck_Msg:
     dc.b     Esc,"Y",32+15,32+12,"End Of Batch Transfer Acknowledged       ",0
EobNak_Msg:
     dc.b     Esc,"Y",32+15,32+12,"End of Batch Transfer Not Acknowledged   ",0
RcvTimOut_Msg:
     dc.b     Esc,"Y",32+15,32+12,"Receiver Timed Out, Didn't Start Transfer",0
SndTimOut_Msg:
     dc.b     Esc,"Y",32+15,32+12,"Sender Didn't Ackowledge Transfer........",0

Send_Msg1:
     dc.b     Esc,"Y",32+15,32+12,"Transfer aborted by SysOp                ",0
Send_Msg2:
     dc.b     Esc,"Y",32+15,32+12,"User Droped Carrier                      ",0
Send_Msg3:
     dc.b     Esc,"Y",32+15,32+12,"No ACK Ever Received                     ",0
Send_Msg4:
     dc.b     Esc,"Y",32+15,32+12,"Receiver Aborted Transmission            ",0
Send_Msg5:
     dc.b     Esc,"Y",32+15,32+12,"No ACK on EOT                            ",0
Send_Msg6:
     dc.b     Esc,"Y",32+15,32+12,"EOT Acknowledged, Send Complete          ",0

Rcv_Msg1:
     dc.b     Esc,"Y",32+15,32+12,"Block Received - Ok!!!                   ",0
Rcv_Msg2:
     dc.b     Esc,"Y",32+15,32+12,"Bad Block - Time Out                     ",0
Rcv_Msg3:
     dc.b     Esc,"Y",32+15,32+12,"Bad Block - Header Info Different        ",0
Rcv_Msg3a:
     dc.b     Esc,"Y",32+15,32+12,"Bad Block - Missing Header Info          ",0
Rcv_Msg4:
     dc.b     Esc,"Y",32+15,32+12,"Bad Block - Missing Block Data           ",0
Rcv_Msg5:
     dc.b     Esc,"Y",32+15,32+12,"Bad Block - Missing Checksum             ",0
Rcv_Msg6:
     dc.b     Esc,"Y",32+15,32+12,"Bad Block - Checksum Different           ",0

Rcv_Msg10:
     dc.b     Esc,"Y",32+15,32+57,0,0
Rcv_Msg11:
     dc.b     Esc,"Y",32+15,32+67,0,0

F_XBlks1:     dc.b  Esc,"Y",32+11,32+41
F_XBlks:      dc.b  "0000",0,0
F_YBlks1:     dc.b  Esc,"Y",32+11,32+41
F_YBlks:      dc.b  "0000",0,0

Tot_Bytes:
     dc.l     0
Tot_Bytes1:
     dc.b     Esc,"Y",32+13,32+41,0,0
Tot_Bytes2:
     dc.b     "00000000",0,0

Prot_Msg1:
     dc.b     Esc,"Y",32+13,32+57,"Xmodem      ",0
Prot_Msg2:
     dc.b     Esc,"Y",32+13,32+57,"Ymodem      ",0
Prot_Msg3:
     dc.b     Esc,"Y",32+13,32+57,"Ymodem Batch",0
Crci_Msg:
     dc.b     Esc,"Y",32+13,32+27,"CRCI",0,0
Nak_Msg:
     dc.b     Esc,"Y",32+13,32+27,"NAK ",0,0
Ack_Msg:
     dc.b     Esc,"Y",32+13,32+27,"ACK ",0,0
Can_Msg:
     dc.b     Esc,"Y",32+13,32+27,"CAN ",0,0
Eot_Msg:
     dc.b     Esc,"Y",32+13,32+27,"EOT ",0,0
Soh_Msg:
     dc.b     Esc,"Y",32+13,32+27,"SOH ",0,0
Stx_Msg:
     dc.b     Esc,"Y",32+13,32+27,"STX ",0,0
Msg1_Msg:
     dc.b     Esc,"Y",32+13,32+7,"Sending  ",0
Msg2_Msg:
     dc.b     Esc,"Y",32+13,32+7,"Receiving",0
Msg3_Msg:
     dc.b     Esc,"Y",32+13,32+7,"Waiting  ",0
Msg4_Msg:
     dc.b     Esc,"Y",32+13,32+7,"Retry    ",0
Crc_Msg1:
     dc.b     Esc,"Y",32+11,32+67,"Crc   ",0
Crc_Msg2:
     dc.b     Esc,"Y",32+11,32+67,"Normal",0

Ask_Dl_Fname:
     dc.b     "Enter Filename to Download >",0,0
Ask_Ul_Fname:
     dc.b     "Enter Filename to Upload >",0,0
Bm1_Msg:
     dc.b     "Sorry, You Can Only Have 10 Files Marked For Transfer",0
Ask_Bm_Fname:
     dc.b     "Enter Filename For Batch Transfer >",0
Start_Xfer_Msg:
     dc.b     Cr,Lf,Cr,Lf,"  Start The Transfer Now...",Cr,Lf,0
     align.w

Space1:
     dc.b     " [ 1] ",0,0
Space2:
     dc.b     "                                ",0,0,0,0,0,0,0,0
Space3:
     dc.b     "   ",0
     align.w

List_New_Msg:        dc.b  "List New",0,0
Scan_New_Msg:        dc.b  "Scan New",0,0
List_Files_Msg:      dc.b  "List Files",0,0
Scan_Files_Msg:      dc.b  "Scan Files",0,0
New_Files_Msg:       dc.b  "New Files",0
Download_Msg:        dc.b  "Download",0,0
Upload_Msg:          dc.b  "Upload",0,0
Download_Marked_Msg: dc.b  "Download Marked",0
Batch_Mark_Msg:      dc.b  "Mark",0,0
Review_Marked_Msg:   dc.b  "Review Marked",0
Wipe_Files_Msg:      dc.b  "Wipe Files",0,0
Your_Stats_Msg:      dc.b  "Your Stats",0,0
UnArc_Msg:           dc.b  "Un-Arc",0,0
Save_Msg:            dc.b  "Save",0,0
List_Msg:            dc.b  "List",0,0
Read_Msg:            dc.b  "Read",0,0
Exit_Msg:            dc.b  "Exit",0,0
Quit_Msg:            dc.b  "Quit",0,0
Help_Msg:            dc.b  "Help",0,0
Cont_Msg:            dc.b  "Cont",0,0
Next_Msg:            dc.b  "Next",0,0
Next_Page_Msg:       dc.b  "Next Page",0
Next_Sig_Msg:        dc.b  "Next Sig",0,0
Change_Sig_Msg:      dc.b  "Change Sig",0,0
Show_Sigs_Msg:       dc.b  "Show Sigs",0
Terminal_Mode_Msg:   dc.b  "Terminal Mode",0
File_Maintenance_Msg: dc.b "File Maintenance",0,0
Find_Files_Msg:      dc.b  "Find Files",0,0
Keyword_Search_Msg:  dc.b  "Keyword Search",0,0
All_Files_Msg:       dc.b  "All Files",0
All_Msg:             dc.b  "All",0
Normal_Msg:          dc.b  "Normal",0,0
High_Msg:            dc.b  "High",0,0
SysOp_Msg:           dc.b  "SysOp",0
Edit_Msg:            dc.b  "Edit",0,0
Delete_Msg:          dc.b  "Delete",0,0
Rename_Msg:          dc.b  "Rename",0,0
Access_Level_Msg:    dc.b  "Access Level",0,0
Access_Count_Msg:    dc.b  "Access Count",0,0
Description_Msg:     dc.b  "Description",0
Uploader_Msg:        dc.b  "Uploader",0,0
Date_Last_Dl_Msg:    dc.b  "Date Last D/L",0
Change_Baud_Msg:     dc.b  "Change Baud",0
YBatch_Send_Msg:     dc.b  "Y-Batch Send",0,0
Send_File_Msg:       dc.b  "Send File",0
Recv_File_Msg:       dc.b  "Recv File",0
Xmodem_Msg:          dc.b  "Xmodem",0,0
Xmodem_Crc_Msg:      dc.b  "Xmodem Crc",0,0
Ymodem_Msg:          dc.b  "Ymodem",0,0
Ymodem_Batch_Msg:    dc.b  "Ymodem Batch",0,0
Zmodem_Msg:          dc.b  "Zmodem",0,0
Ascii_Msg:           dc.b  "Ascii",0
Search_By_Msg:       dc.b  "Serach By Access",0,0

; - - - - - - - - - - - B S S - - - - - - - - - - - - - - - - - - -

     bss

;     **************** SysData.Dat Stuff ***************

Date:         ds.b  22
Userlog:      ds.b  62
LogFile:      ds.b  62

FileSigNum:   ds.w  1          ; Number of Active File Sigs
FileSigName:  ds.b  1024       ; Enough room to hold File Sig Names
FileSigPath:  ds.b  1984       ;   "     "    "  "    "    "  Paths

; ----------  Batch Marked File/Sig Info ----------

Bm_Num:
     ds.w     1
Bm_File:
     ds.b     260              ; Holds Sig#, Filename & Size for 10 files

; ---------------------------------------------------
     ds.b     4

Screen_Data:
     ds.b     6400
Block_Data:
     ds.b     1026
LineIn:
     ds.b     86

     ds.l     256
Usr_Stack:
     ds.l     1

File_Buf:
     ds.b     2080
Arc_Path:
     ds.b     80
Arc_Name:
     ds.b     16

Prog_End:
     End

