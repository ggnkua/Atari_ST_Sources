{

     COMPUTE!'S Atari ST Disk & Magazine
     February 1987 - Volume 2, No. 1
     Copyright 1987 COMPUTE! Publications/ABC

     Mouse Editor was written by Guy Davis using Personal Pascal.
     Portions of this product are Copyright (c) 1986, OSS and CCD.
     Used by Permission of OSS.

}

PROGRAM Mouse_Edit ;

  CONST
    {$I GEMCONST.PAS}
    Desk_Title = 3 ;
    Mask_On = 1 ;
    Mouse_On = 2 ;
    Empty = 0 ;
    Move_Up = 2 ;
    Move_Down = 3 ;
    Move_Left = 6 ;
    Move_Right = 7 ;

  TYPE
    {$I gemtype.pas}

  VAR
    dummy,
    file_title, load_item, save_item, quit_item,
    edit_title, reverse_item, flip_item, rotater_item,
                rotatel_item, clear_item, arrow_item,
                test_item,
    data_title, hot_item, mask_item, data_item,
    mx, my,
    x_hot, y_hot,
    box_width, box_height, up_coord, down_coord,
    right_coord, left_coord: integer ;

    mouse_array: Array [ 0..15, 0..15 ] OF integer ;

    Draw_Select: (Hot, Data, Mask) ;

    Mouse_Menu: Menu_Ptr;

    editor_window, ex, ey, ew, eh: integer ;
    editor_title: Window_Title ;

    About_ME: Dialog_Ptr;
    AMEln1,AMEln2,AMEln3,AMEln4,AMEln5,AMEln6,
    AMEln7,AMEln8,AMEok_button: integer ;

    File_Error: Dialog_Ptr;
    EMGln1, EMGok_button: integer ;

  {$I gemsubs.pas}

PROCEDURE IO_Check( b:BOOLEAN );
           External;

FUNCTION IO_Result : INTEGER;
          External;

{this function returns an integer indicating current screen resolution:
 0 = low resulution
 1 = medium resolution
 2 = high resolution monochrome                                             }

FUNCTION Screen_Res : integer;
  XBIOS($4);

{   This function when called with the integer value (i) returns
     the value of 2 raised to the ith power.                       }

FUNCTION power2(i: integer) :Integer ;

VAR j, res: integer ;

  BEGIN
    res := 1 ;
    IF i>0 THEN
      FOR j := 1 TO i DO
        res := res * 2 ;
    power2 := res ;
  END ;

PROCEDURE Reset_Color ;
   BEGIN
        Set_Color(White,875,875,875 ) ;
        Set_Color(Red, 500, 0, 0 ) ;
        Set_Color(Black, 0, 0, 0 ) ;
        Set_Color(Green, 0, 500, 0 ) ;
   END ;

{   This procedure takes a mouse form and converts it to the array
     format used to store screen information.                         }

PROCEDURE Get_Mouse( VAR mform: Mouse_Form ) ;

VAR i, j: integer ;

  BEGIN
    FOR j := 0 TO 15 DO
      BEGIN
        mform.data [ j ] := 0 ;
        mform.mask [ j ] := 0 ;
        FOR i := 0 TO 15 DO
          BEGIN
            IF mouse_array [ i, j ] = Mouse_On THEN
              mform.data [ j ] := mform.data [ j ] + power2(15-i)
            ELSE
              IF mouse_array [ i, j ] = Mask_On THEN
                mform.mask [ j ] := mform.mask [ j ] + power2(15-i);
          END ;
      END ;
  END ;

{   This procedure takes the array format currently holding the screen
     information and converts it to mouse form.                          }

PROCEDURE Put_Mouse( mform: Mouse_Form ) ;

VAR i, j: integer ;

  BEGIN
    FOR j := 0 TO 15 DO
        FOR i := 0 TO 15 DO
          BEGIN
            mouse_array [ i, j ] := Empty ;
            IF (mform.data [ j ] & power2(15-i)) <> 0 THEN
              mouse_array [ i, j ] := Mouse_On
            ELSE
              IF (mform.mask [ j ] & power2(15-i)) <> 0 THEN
                mouse_array [ i, j ] := Mask_On
          END ;
  END ;

{   This procedure initializes the mouse grid to be empty. The
    mouse grid being the array which contains the screen information.   }

PROCEDURE initgrid ;

VAR i, j: integer ;

  BEGIN
    FOR i := 0 TO 15 DO
      FOR j := 0 TO 15 DO
        mouse_array [ i, j ] := Empty ;
  END ;

{   This procedure determines box size and width for the current
     window.  This procedure must be called if any change is made to
     the window.  The box size and width determine how the grid appears
     on the screen.                                                      }

PROCEDURE initRes ;

VAR width_off, height_off: integer ;

  BEGIN
    Work_Rect( editor_window, ex, ey, ew, eh ) ;
    box_height := eh DIV 16 ;
    box_width := ew DIV 16 ;
    width_off := (ew MOD 16) DIV 2 ;
    height_off := (eh MOD 16) DIV 2 ;
    up_coord := height_off - 1  ;
    down_coord := height_off + (box_height * 16) + 1 ;
    left_coord := width_off - 1 ;
    right_coord := width_off + (box_width * 16) + 1 ;
  END ;

{   This procedure is called at the beginning of the program.  Within
     this procedure the windows, menu and dialog boxes are initialized.
     A welcoming message is also displayed using a dialog box.         }

PROCEDURE Initialize;

VAR i: integer ;

{   This procedure sets up the menu for this application.  }

PROCEDURE InitMenu ;

  BEGIN
    mouse_menu := New_Menu(27 , ' About Mouse Edit ') ;

    file_title := Add_MTitle( mouse_menu, ' File ') ;
    edit_title := Add_MTitle( mouse_menu, ' Edit ') ;
    data_title := Add_MTitle( mouse_menu, ' Data ' ) ;

    load_item := Add_MItem( mouse_menu, file_title,
                          '  Load Mouse  ') ;
    save_item := Add_MItem( mouse_menu, file_title,
                          '  Save Mouse  ') ;
    quit_item := Add_MItem( mouse_menu, file_title,
                          '  Quit        ') ;

    reverse_item := Add_MItem( mouse_menu, edit_title,
                          '  Reverse Image  ') ;
    flip_item := Add_MItem( mouse_menu, edit_title,
                          '  Flip Image     ') ;
    rotater_item := Add_MItem( mouse_menu, edit_title,
                          '  Rotate Right   ') ;
    rotatel_item := Add_MItem( mouse_menu, edit_title,
                          '  Rotate Left    ') ;
    clear_item := Add_MItem( mouse_menu, edit_title,
                          '  Clear Mouse    ') ;
    arrow_item := Add_MItem( mouse_menu, edit_title,
                          '  Set Arrow      ') ;
    test_item := Add_MItem( mouse_menu, edit_title,
                          '  Test Mouse     ') ;

    hot_item := Add_MItem( mouse_menu, data_title,
                          '  Hot Spot  ') ;
    mask_item := Add_MItem( mouse_menu, data_title,
                          '  Mask      ') ;
    data_item := Add_MItem( mouse_menu, data_title,
                          '  Data      ') ;

    Draw_Menu( mouse_menu ) ;
  END ;

{   This procedure initializes the mouse editor window for this
     application.  This is the only window used within the application.   }

PROCEDURE InitWindows ;

  BEGIN
    editor_title := '   Mouse Editor   ' ;
    editor_window := New_Window( G_Name | G_Full | G_Move |
                                 G_Size | G_UpArrow | G_DnArrow |
                                 G_LArrow | G_RArrow ,
                                 editor_title, 0, 0, 0, 0 ) ;
    Open_Window( editor_window, 0, 0, 0, 0 ) ;
    Set_Window( editor_window ) ;
  END ;

{   This procedure initializes the dialog box that appears after
     selecting the first item from 'DESK' in the desk accessory menu.  }

PROCEDURE InitDialogs ;

  BEGIN
    About_Me := New_Dialog( 7,0,0,45,13) ;

    AMEln1 := Add_DItem( About_Me,G_String,None,16,2,0,1,0,0) ;
    AMEln2 := Add_DItem( About_Me,G_String,None,6,4,0,1,0,0) ;
    AMEln3 := Add_DItem( About_Me,G_String,None,9,5,0,1,0,0) ;
    AMEln4 := Add_DItem( About_Me,G_String,None,2,6,0,1,0,0) ;
    AMEln5 := Add_DItem( About_Me,G_String,None,3,8,0,1,0,0) ;
    AMEok_button := Add_DItem( About_Me,G_Button,Selectable|Exit_btn,
                            21,10,4,2,0,0) ;

    Set_Dtext( About_ME,AMEln1,'Mouse Editor',
               System_Font,TE_Left) ;
    Set_Dtext( About_ME,AMEln2,'COMPUTE!''s Atari ST Disk & Magazine',
               System_Font,TE_Left) ;
    Set_Dtext( About_ME,AMEln3,'Feb. 1987 - Vol. 2, No. 1',
               System_Font,TE_Left) ;
    Set_Dtext( About_ME,AMEln4,'Copyright 1987 COMPUTE! Publications/ABC',
               System_Font,TE_Left) ;
    Set_Dtext( About_Me,AMEln5,'Written in Personal Pascal by Guy Davis',
               System_Font,TE_Left) ;
    Set_Dtext( About_ME,AMEok_button,' OK ',
               System_Font,TE_Center) ;

{   This is the Dialog box which opens after a disk I/O error. }

    File_Error := New_Dialog( 2,0,0,32,6) ;

    EMGln1 := Add_DItem( File_Error,G_String,None,2,1,0,1,0,0) ;
    EMGok_button := Add_DItem( File_Error,G_Button,Selectable|Exit_btn,
                            14,3,4,2,0,0) ;

    Set_Dtext( File_Error,EMGln1,'SYSTEM ERROR: File not found.',
               System_Font,TE_Left) ;
    Set_Dtext( File_Error,EMGok_button,' OK ',
               System_Font,TE_Left) ;
  END ;

{   This procedure displays a dialog box to the user welcoming he/she
     to the Mouse Editor environment.  It is then deleted from memory.   }

PROCEDURE Welcome ;

VAR dummy_Dialog: Dialog_Ptr;
    ln1,ln2,ln3,ln4,ln5,ok_button: integer;

  BEGIN
    dummy_Dialog := New_Dialog( 7,0,0,45,13) ;

    ln1 := Add_DItem( dummy_dialog,G_String,None,16,2,0,1,0,0) ;
    ln2 := Add_DItem( dummy_dialog,G_String,None,6,4,0,1,0,0) ;
    ln3 := Add_DItem( dummy_dialog,G_String,None,9,5,0,1,0,0) ;
    ln4 := Add_DItem( dummy_dialog,G_String,None,2,6,0,1,0,0) ;
    ln5 := Add_DItem( dummy_dialog,G_String,None,3,8,0,1,0,0) ;
    ok_button := Add_DItem( dummy_dialog,G_Button,Selectable|Exit_btn,
                            21,10,4,2,0,0) ;

    Set_Dtext( dummy_dialog,ln1,'Mouse Editor',
               System_Font,TE_Left) ;
    Set_Dtext( dummy_dialog,ln2,'COMPUTE!''s Atari ST Disk & Magazine',
               System_Font,TE_Left) ;
    Set_Dtext( dummy_dialog,ln3,'Feb. 1987 - Volume 2, No. 1',
               System_Font,TE_Left) ;
    Set_Dtext( dummy_dialog,ln4,'Copyright 1987 COMPUTE! Publications/ABC',
               System_Font,TE_Left) ;
    Set_Dtext( dummy_dialog,ln5,'Written in Personal Pascal by Guy Davis',
               System_Font,TE_Left) ;
    Set_Dtext( dummy_dialog,ok_button,' OK ',
               System_Font,TE_Center) ;

    Center_Dialog( dummy_dialog ) ;
    dummy := Do_Dialog( dummy_dialog, 0 ) ;

    End_Dialog( dummy_dialog ) ;
    Delete_Dialog( dummy_dialog ) ;
  END ;

  BEGIN
    Init_Mouse ;
    Set_Color(White,875,875,875 ) ;
    Set_Color(Red, 500, 0, 0 ) ;
    Set_Color(Black, 0, 0, 0 ) ;
    Set_Color(Green, 0, 500, 0 ) ;

    InitDialogs ;
    InitMenu ;
    Welcome ;
    initgrid ;
    Draw_Select := Data ;
    x_hot := 0 ;   { hot spot initialized to upper }
    y_hot := 0 ;   { left hand corner of grid.     }
    InitWindows ;
    InitRes ;
  END;

{   This procedure contains several subprocedures which handle any
     events that may occur during the running of this application.  This
     includes redraws, window movement, and mouse button messages.       }

PROCEDURE Event_Loop ;

  VAR
    event : integer ;
    msg : Message_Buffer ;


PROCEDURE drawgrid ;

VAR i, j, mode: Integer ;

  BEGIN
    mode := Screen_Res;
    Paint_Style( 1 ) ;
    Line_Style( 1 ) ;
    FOR i := 0 TO 15 DO
      FOR j := 0 TO 15 DO
        BEGIN
          IF mouse_array [ i, j ] = Mouse_On
            THEN
            BEGIN
              IF mode = 2 THEN Paint_Style( 1 ) ;
              Paint_Color( Black ) ;
            END
          ELSE
            IF mouse_array [ i, j ] = Mask_On
            THEN Paint_Color( White )
          ELSE
             BEGIN
               IF mode = 2 THEN Paint_Style( 5 ) ;
               Paint_Color( Green ) ;
             END ;
        Paint_Rect(i * box_width + left_coord + 2,
                     j * box_height + up_coord + 2,
                     box_width - 2, box_height - 2 ) ;
        IF (x_hot = i) AND (y_hot = j) THEN
            BEGIN
              Line_Color( White ) ;
              Frame_Rect(i * box_width + left_coord + 1,
                         j * box_height + up_coord + 1,
                         box_width, box_height  ) ;
            END ;
        END ;
  END ;

{   This procedure performs redraw logic.  Depending on the Boolean
     variable passed to it... this procedure may or may not redraw the
     actual mouse grid.  Although re_window is passed to it, which sig-
     nifies the window to be redrawn... we could just as well have left
     out this variable as there is only one (1) window being used in this
     application.  Therefore the only window that can be redrawn is the
     mouse editor window.                                                 }

PROCEDURE Do_Redraw ( re_window, x, y, w, h: integer; full_redraw: Boolean) ;

VAR i ,j,
    fx, fy, fw, fh,
    wx, wy: integer ;

  BEGIN
    Paint_Style ( 1 ) ;
    Hide_Mouse ;
    Begin_Update ;
    First_Rect( re_window, fx, fy, fw, fh ) ;
    WHILE (fw<>0) AND (fh<>0) DO
      BEGIN
        IF Rect_Intersect( x, y, w, h, fx, fy, fw, fh) THEN
        BEGIN
          Set_Clip( fx, fy, fw, fh ) ;
            IF full_redraw THEN
            BEGIN
              Paint_Style( 1 ) ;
              Paint_Outline( False ) ;
              Paint_Color( White ) ;
              Work_Rect(  re_window, wx, wy, dummy, dummy ) ;
              Paint_Rect( fx - wx, fy - wy, fw, fh ) ;
              BEGIN
                For i := 0 TO 15 DO
                  For j := 0 TO 15 DO
                    BEGIN
                      Line_Color( Black ) ;
                      Frame_Rect(i * box_width + left_coord + 1,
                                 j * box_height + up_coord + 1,
                                 box_width, box_height ) ;
                    END ;
              END ;
            END ;
            drawgrid ;
        END ;
        Next_Rect( re_window, fx, fy, fw, fh ) ;
      END ;
    End_Update ;
    Show_Mouse ;
  END ;

{   This procedure is called any time a window is resized.   }

PROCEDURE Do_Sized ( re_window, x, y, w, h: integer) ;

  BEGIN
    Set_WSize( re_window, x, y, w, h ) ;
    Initres ;
    Set_Window( re_window ) ;
    event := Get_Event( E_Message|E_Timer, 1, 1, 1, 0,
            false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
            dummy, dummy, dummy, mx, my, dummy ) ;
    Work_Rect( editor_window, ex, ey, ew, eh ) ;
    Do_Redraw( editor_window, ex, ey, ew, eh , TRUE) ;
  END ;

{   This procedure is called any time a window is moved.   }

PROCEDURE Do_Moved (re_window, x, y, w, h: integer) ;

  BEGIN
    Set_WSize( re_window, x, y, w, h ) ;
    Initres ;
    Set_Window( editor_window ) ;
  END ;

{   This procedure is called any time the window 'full' box is clicked.  }

PROCEDURE Do_Full ;

  BEGIN
    Wind_Get( editor_window, WF_FullXYWH, ex, ey, ew, eh ) ;
    Set_WSize( editor_window, ex, ey, ew, eh ) ;
    Initres ;
    Set_Window( editor_window ) ;
  END ;

{   This procedure performs any necessary action based on which arrow
     on the window that the user clicked.                                }

PROCEDURE Do_Arrow ( re_window, action: integer) ;

{   This procedure is called if the user selects the move left arrow.
     The mouse grid is moved 1 section to the left.                       }

PROCEDURE Shift_Left ;

VAR i, j, hold: integer ;

  BEGIN
    FOR j := 0 TO 15 DO
      BEGIN
        FOR i := 0 TO 14 DO
          BEGIN
            IF i = 0 THEN
              hold := mouse_array [i, j] ;
            mouse_array [ i, j] := mouse_array [ i+1, j] ;
          END ;
        mouse_array [ 15, j ] := hold ;
      END ;
      Work_Rect( editor_window, ex, ey, ew, eh ) ;
      Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
  END ;

{   This procedure is called if the user selects the move right arrow.
     The mouse grid is moved 1 section to the right.                    }

PROCEDURE Shift_Right ;

VAR i, j, hold: integer ;

  BEGIN
    FOR j := 0 TO 15 DO
      BEGIN
        FOR i := 15 Downto 1 DO
          BEGIN
            IF i = 15 THEN
              hold := mouse_array [i, j] ;
            mouse_array [ i, j] := mouse_array [ i-1, j] ;
          END ;
        mouse_array [ 0, j ] := hold ;
      END ;
      Work_Rect( editor_window, ex, ey, ew, eh ) ;
      Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
  END ;

{   This procedure is called if the user selects the move up arrow.
     The mouse grid is moved 1 section to the up.                    }

PROCEDURE Shift_Up ;

VAR i, j, hold: integer ;

  BEGIN
    FOR i := 0 TO 15 DO
      BEGIN
        FOR j := 0 TO 14 DO
          BEGIN
            IF j = 0 THEN
              hold := mouse_array [i, j] ;
            mouse_array [ i, j] := mouse_array [ i, j+1] ;
          END ;
        mouse_array [ i, 15 ] := hold ;
      END ;
      Work_Rect( editor_window, ex, ey, ew, eh ) ;
      Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
  END ;

{   This procedure is called if the user selects the move down arrow.
     The mouse grid is moved 1 section to the down.                    }

PROCEDURE Shift_Down ;

VAR i, j, hold: integer ;

  BEGIN
    FOR i := 0 TO 15 DO
      BEGIN
        FOR j := 15 Downto 1 DO
          BEGIN
            IF j = 15 THEN
              hold := mouse_array [i, j] ;
            mouse_array [ i, j] := mouse_array [ i, j-1] ;
          END ;
        mouse_array [ i, 0 ] := hold ;
      END ;
      Work_Rect( editor_window, ex, ey, ew, eh ) ;
      Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
  END ;

  BEGIN
    IF action = Move_Up THEN
      Shift_Up
    ELSE
      IF action = Move_Down THEN
        Shift_Down
      ELSE
        IF action = Move_Left THEN
          Shift_Left
        ELSE
          IF action = Move_Right THEN
            Shift_Right ;
  END ;

{   This procedure is called whenever a user selects a menu item.   }

PROCEDURE Do_Menu( menu_title, menu_item:integer ) ;

{   This procedure is called whenever a user selects the file menu item.  }

PROCEDURE Do_file ;

{   This procedure is called whenever a user requests that the current
     mouse grid be saved.                                                }

PROCEDURE Do_Save ;

VAR output_file: Path_Name ;
    int_file: FILE OF integer ;
    i: integer ;
    mform: Mouse_Form ;

  BEGIN
    output_file := 'A:\IMAGE.MSE';
    IF Get_Out_File( 'Enter output file (.MSE) ', output_file ) THEN
      BEGIN
        Get_Mouse( mform ) ;
        Rewrite( int_file, output_file ) ;
        int_file^ := x_hot ;
        put(int_file) ;
        int_file^ := y_hot ;
        put(int_file) ;
        FOR i := 0 TO 15 DO
          BEGIN
            int_file^ := mform.mask [ i ] ;
            put(int_file) ;
            int_file^ := mform.data [ i ] ;
            put(int_file) ;
          END ;
        Close(int_file) ;
      END ;
  END ;

{   This procedure is called whenever a user requests that a mouse
     grid be loaded into memory.                                       }

PROCEDURE Do_Load ;

VAR input_file, path_to_file: Path_Name ;
    int_file: FILE OF integer ;
    i: integer ;
    mform: Mouse_Form ;

  BEGIN
    IO_Check( FALSE );
    path_to_file := 'A:\*.MSE' ;
    input_file := '' ;
    IF Get_In_File( path_to_file, input_file ) THEN
      BEGIN
        Reset( int_file, input_file ) ;
        IF ( IO_Result  = 0 ) THEN
          BEGIN
            x_hot := int_file^ ;
            get(int_file) ;
            y_hot := int_file^ ;
            get(int_file) ;
            FOR i := 0 TO 15 DO
              BEGIN
                mform.mask [ i ] := int_file^ ;
                get(int_file) ;
                mform.data [ i ] := int_file^ ;
                get(int_file) ;
              END ;
            Close(int_file) ;
            Put_Mouse( mform ) ;
          END ;

        {Work_Rect( editor_window, ex, ey, ew, eh ) ;
        Do_Redraw( editor_window, ex, ey, ew, eh, TRUE ) ;
         }
        IF ( IO_Result <> 0 ) THEN
          BEGIN
            Center_Dialog( File_Error ) ;
            dummy := Do_Dialog( File_Error, 0) ;
            End_Dialog( File_Error ) ;
            Obj_SetState( File_Error, EMGok_button, Normal, False) ;
          END ;

        { Force a redraw of entire screen.
          First get redraw... then send redraw routine
          full screen to redraw and editor window as handle. }

        event := Get_Event( E_Message, 0, 0, 0, 0,
              false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
              dummy, dummy, dummy, dummy, dummy, dummy ) ;

        Work_Rect( editor_window, ex, ey, ew, eh ) ;
        Do_Redraw( editor_window, ex, ey, ew, eh, TRUE ) ;

      END ;
  END ;

  BEGIN
    IF menu_item = load_item THEN
      Do_Load
    ELSE
      IF menu_item = save_item THEN
        Do_Save ;
  END ;

{  This procedure is called whenever the user selects the edit item
    from the menu.                                                   }

PROCEDURE Do_Edit ;

{   This procedure is called when the user wishes to 'reverse' the image
     on the screen.                                                  }

PROCEDURE Do_Reverse ;

VAR i, j, hold: integer ;

  BEGIN
    Begin_Update ;
    Hide_Mouse ;
    FOR j := 0 TO 15 DO
      FOR i := 0 TO 7 DO
          BEGIN
            hold := mouse_array [ i, j ] ;
            mouse_array [ i, j ] := mouse_array [ 15 - i, j ] ;
            mouse_array [ 15 - i, j ] := hold ;
          END ;
    Work_Rect( editor_window, ex, ey, ew, eh ) ;
    Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
    Show_Mouse ;
    End_Update ;
  END ;

{   This procedure is called when the user wishes to 'flip' the
     current screen image.                                       }

PROCEDURE Do_Flip ;

VAR i, j, hold: integer ;

  BEGIN
    Begin_Update ;
    Hide_Mouse ;
    FOR i := 0 TO 15 DO
      FOR j := 0 TO 7 DO
          BEGIN
            hold := mouse_array [ i, j ] ;
            mouse_array [ i, j ] := mouse_array [ i, 15 - j ] ;
            mouse_array [ i, 15 - j ] := hold ;
          END ;
    Work_Rect( editor_window, ex, ey, ew, eh ) ;
    Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
    Show_Mouse ;
    End_Update ;
  END ;

{   This procedure will rotate the screen image 90 degrees to the right.  }

PROCEDURE Do_RotateR ;

VAR i, j: integer ;
    temp: ARRAY [ 0..15, 0..15] OF integer ;

  BEGIN
    Begin_Update ;
    Hide_Mouse ;
    FOR i := 0 TO 15 DO
      FOR j := 0 TO 15 DO
          temp [ 15 - j, i ] := mouse_array [ i, j ] ;

    FOR i := 0 TO 15 DO
      FOR j := 0 TO 15 DO
          mouse_array [ i, j ] := temp [ i, j ] ;

    Work_Rect( editor_window, ex, ey, ew, eh ) ;
    Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
    Show_Mouse ;
    End_Update ;
  END ;

{   This procedure rotates the screen image 90 degrees to the left.   }

PROCEDURE Do_RotateL ;

VAR i, j: integer ;
    temp: ARRAY [ 0..15, 0..15] OF integer ;

  BEGIN
    Begin_Update ;
    Hide_Mouse ;
    FOR i := 0 TO 15 DO
      FOR j := 0 TO 15 DO
          temp [ j, 15 - i ] := mouse_array [ i, j ] ;

    FOR i := 0 TO 15 DO
      FOR j := 0 TO 15 DO
          mouse_array [ i, j ] := temp [ i, j ] ;

    Work_Rect( editor_window, ex, ey, ew, eh ) ;
    Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
    Show_Mouse ;
    End_Update ;
  END ;

{   This procedure clears the image from the screen only if the user
     first replies 'yes' to the alert box choice.                     }

PROCEDURE Do_Clear ;

VAR choice : integer ;

  BEGIN
    choice := Do_Alert('[2][ Are you sure? ][ Yes | No ]',2) ;
    IF choice = 1 THEN
      BEGIN
        Begin_Update ;
        Hide_Mouse ;
        initgrid ;
        Work_Rect( editor_window, ex, ey, ew, eh ) ;
        Do_Redraw( editor_window, ex, ey, ew, eh , FALSE) ;
        Show_Mouse ;
        End_Update ;
      END ;
  END ;

{   This procedure takes the mouse grid and converts the current
     screen mouse to the grid representation created by the user.   }

PROCEDURE Do_Test ;

VAR mform: Mouse_form ;
    i, j: integer ;

  BEGIN
    mform.hot_x := x_hot ;
    mform.hot_y := y_hot ;
    mform.res := 1 ;
    mform.mask_color := White ;
    mform.data_color := Black ;
    Get_Mouse( mform ) ;
    Set_MForm( mform ) ;
  END ;

  BEGIN
    IF menu_item = reverse_item THEN
      Do_Reverse
    ELSE
      IF menu_item = flip_item THEN
        Do_Flip
      ELSE
        IF menu_item = rotater_item THEN
          Do_RotateR
        ELSE
          IF menu_item = rotatel_item THEN
            Do_RotateL
          ELSE
            IF menu_item = arrow_item THEN
              Set_Mouse( M_Arrow )
            ELSE
              IF menu_item = test_item THEN
                Do_Test
              ELSE
                Do_Clear ;
  END ;

{   This procedure sets a flag which indicates which selection the
     user made from the data item in the menu.                      }

PROCEDURE Do_Data ;

  BEGIN
    IF menu_item = hot_item THEN
      Draw_Select := Hot
    ELSE
      IF menu_item = mask_item THEN
        Draw_Select := Mask
      ELSE
        Draw_Select := Data ;
  END ;


  BEGIN
    IF menu_title = Desk_Title THEN
      BEGIN
        Center_Dialog( About_ME ) ;
        dummy := Do_Dialog( About_ME, 0) ;
        End_Dialog( About_ME ) ;
        Obj_SetState( About_ME, AMEok_button, Normal, False) ;
      END
    ELSE
      IF menu_title = file_title THEN
        Do_File
      ELSE
        IF menu_title = edit_title THEN
          Do_Edit
        ELSE
          Do_Data;

 {  make the menu bar selected normal }
    Menu_Normal( mouse_menu, menu_title) ;

 {  wait for button up event before returning to event loop }
    event := Get_Event( E_Button, 1, 0, 1, 0,
              false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
              dummy, dummy, dummy, mx, my, dummy ) ;
  END ;

{  This procedure is called if the mouse button has been clicked
    and if the editor window is the front window.                  }

PROCEDURE Do_Button ;

VAR i,j: integer ;

{   This procedure is called if the user clicks the mouse
     on the grid trying to fill a square with data. (black)   }

PROCEDURE Data_Logic ;

  BEGIN
    IF mouse_array [ i, j ] <> Mouse_On THEN
      BEGIN
        mouse_array [ i, j ] := Mouse_On ;
        Paint_Color( Black ) ;
        Paint_Rect(i * box_width + left_coord + 2,
                   j * box_height + up_coord + 2,
                    box_width - 2, box_height - 2) ;
      END
    ELSE
      BEGIN
        mouse_array [ i, j ] := Empty ;
        Paint_Color( Green ) ;
        Paint_Rect(i * box_width + left_coord + 2,
                   j * box_height + up_coord + 2,
                    box_width - 2, box_height - 2) ;
      END ;
  END ;

{   This procedure is called if the user clicks the mouse
     on the grid trying to fill a square with mask. (white)   }

PROCEDURE Mask_Logic ;

  BEGIN
    IF mouse_array [ i, j ] <> Mask_On
     THEN
       BEGIN
         mouse_array [ i, j ] := Mask_On ;
         Paint_Color( White ) ;
         Paint_Rect(i * box_width + left_coord + 2,
                   j * box_height + up_coord + 2,
                    box_width - 2, box_height - 2) ;
       END
     ELSE
       BEGIN
         mouse_array [ i, j ] := Empty ;
         Paint_Color( Green ) ;
         Paint_Rect(i * box_width + left_coord + 2,
                    j * box_height + up_coord + 2,
                     box_width - 2, box_height - 2) ;
       END ;
   END ;

{   This procedure is called if the user clicks the mouse
     on the grid trying to change the hot spot location.    }

PROCEDURE Hot_Spot_Logic ;

  BEGIN
    Line_Style( 1 ) ;
    Line_Color( Black ) ;

    Frame_Rect(x_hot * box_width + left_coord + 1,
               y_hot * box_height + up_coord + 1,
               box_width, box_height ) ;
    Line_Color( White ) ;
    x_hot := i ;
    y_hot := j ;
    Frame_Rect(x_hot * box_width + left_coord + 1,
               y_hot * box_height + up_coord + 1,
               box_width, box_height ) ;
  END ;

  BEGIN
    Hide_Mouse ;
    Begin_Update ;
    Work_Rect( editor_window , ex, ey, ew, eh ) ;
    Set_Clip( ex, ey, ew, eh ) ;
    Paint_Style( 1 ) ;
    mx := mx - ex + 1 ;
    my := my - ey + 1 ;
    i := ((mx - left_coord - 2) DIV box_width) ;
    j := ((my - up_coord - 2) DIV box_height) ;
    IF (mx > left_coord)  AND
       (mx < right_coord) AND
       (my > up_coord)    AND
       (my < down_coord) THEN

      IF Draw_Select = Data THEN
        Data_Logic
      ELSE
        IF Draw_Select = Mask THEN
          Mask_Logic
        ELSE
          Hot_Spot_Logic ;

    End_Update ;
    Show_Mouse ;
    event := Get_Event( E_Button, 1, 0, 1, 0,
              false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
              dummy, dummy, dummy, mx, my, dummy ) ;
  END ;

  {   Start of Procedure Event_Loop   }

  BEGIN

    REPEAT
      event := Get_Event( E_Message|E_Button, 1, 1, 1, 0,
              false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
              dummy, dummy, dummy, mx, my, dummy ) ;

      IF (event & E_Message) > 0 THEN
        CASE msg[0] OF
          MN_Selected: Do_Menu( msg[3], msg[4] ) ;
          WM_Redraw: Do_Redraw( msg[3], msg [4], msg [5],
                                msg [6], msg[7], TRUE ) ;
          WM_Sized: Do_Sized( msg[3], msg [4], msg [5],
                                msg [6], msg[7] );
          WM_Moved: Do_Moved( msg[3], msg [4], msg [5],
                                msg [6], msg[7] );
          WM_Arrowed: Do_Arrow( msg[3], msg[4] ) ;
          WM_Fulled: Do_Full ;
          Otherwise: ;
        END
      ELSE
        IF ((event & E_Button)<> 0) AND (editor_window = Front_window) THEN
          Do_button;
    UNTIL (msg[3] = file_title) AND (msg[4] = quit_item) ;

  END ;


  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        Initialize ;
        Event_Loop ;
        Reset_Color ;
        Exit_Gem ;
      END ;

  END.

