
(*      Include-Datei:
 *
 *      Konstantendefinitionen fÅr die Megamax Modula-2 GEM-Library
 *)


CONST
                (*  A E S - Opcodes  *)
                (*  ===============  *)
                
        (*  Application Manager
         *)
        APPL_INIT               = 10;
        APPL_READ               = 11;
        APPL_WRITE              = 12;
        APPL_FIND               = 13;
        APPL_TPLAY              = 14;
        APPL_TRECORD            = 15;
        APPL_EXIT               = 19;
        
        (*  Event Manager
          *)
        EVNT_KEYBD              = 20;
        EVNT_BUTTON             = 21;
        EVNT_MOUSE              = 22;
        EVNT_MESAG              = 23;
        EVNT_TIMER              = 24;
        EVNT_MULTI              = 25;
        EVNT_DCLICK             = 26;
        
        (*  Menu Manager
         *)
        MENU_BAR                = 30;
        MENU_ICHECK             = 31;
        MENU_IENABLE            = 32;
        MENU_TNORMAL            = 33;
        MENU_TEXT               = 34;
        MENU_REGISTER           = 35;
        
        (*  Object Manager
         *)
        OBJC_ADD                = 40;
        OBJC_DELETE             = 41;
        OBJC_DRAW               = 42;
        OBJC_FIND               = 43;
        OBJC_OFFSET             = 44;
        OBJC_ORDER              = 45;
        OBJC_EDIT               = 46;
        OBJC_CHANGE             = 47;
        
        (*  Form Manager
         *)
        FORM_DO                 = 50;
        FORM_DIAL               = 51;
        FORM_ALERT              = 52;
        FORM_ERROR              = 53;
        FORM_CENTER             = 54;
        FORM_KEYBD              = 55;
        FORM_BUTTON             = 56;
        
        (*  Graphics Manager
         *)
        GRAF_RUBBOX             = 70;
        GRAF_DRAGBOX            = 71;
        GRAF_MBOX               = 72;
        GRAF_GROWBOX            = 73;
        GRAF_SHRINKBOX          = 74;
        GRAF_WATCHBOX           = 75;
        GRAF_SLIDEBOX           = 76;
        GRAF_HANDLE             = 77;
        GRAF_MOUSE              = 78;
        GRAF_MKSTATE            = 79;
        
        (*  Scrap Manager
         *)
        SCRP_READ               = 80;
        SCRP_WRITE              = 81;
        
        (*  File Selector Manager
         *)
        FSEL_INPUT              = 90;
        FSEL_EX_INPUT           = 91;   (*  Ab TOS 1.4  *)
        
        (*  Window Manager
         *)
        WIND_CREATE             = 100;
        WIND_OPEN               = 101;
        WIND_CLOSE              = 102;
        WIND_DELETE             = 103;
        WIND_GET                = 104;
        WIND_SET                = 105;
        WIND_FIND               = 106;
        WIND_UPDATE             = 107;
        WIND_CALC               = 108;
        WIND_NEW                = 109;   (*  Ab TOS 1.4  *)
        
        (*  Resource Manager
         *)
        RSRC_LOAD               = 110;
        RSRC_FREE               = 111;
        RSRC_GADDR              = 112;
        RSRC_SADDR              = 113;
        RSRC_OBFIX              = 114;
        
        (*  Shell Manager
         *)
        SHEL_READ               = 120;
        SHEL_WRITE              = 121;
        SHEL_GET                = 122;
        SHEL_PUT                = 123;
        SHEL_FIND               = 124;
        SHEL_ENVRN              = 125;
        
        
                (*  V D I - Opcodes  *)
                (*  ===============  *)
    
        V_OPNWK                 = 1;
        V_CLSWK                 = 2;
        CLEAR_WORKSTATION       = 3;
        UPDATE_WORKSTATION      = 4;
        ESCAPE                  = 5;
        POLYLINE                = 6;
        POLYMARKER              = 7;
        GRAF_TEXT               = 8;
        FILLED_AREA             = 9;
    
        CELL_ARRAY              = 10;
        GRAF_STANDARD           = 11;
        SET_TEXT_HEIGHT_ABS     = 12;
        SET_TEXT_BASELINE       = 13;
        SET_COLOR_REP           = 14;
        SET_LINE_TYPE           = 15;
        SET_LINE_WIDTH          = 16;
        SET_LINE_COLOR          = 17;
        SET_MARKER_TYPE         = 18;
        SET_MARKER_HEIGHT       = 19;
        
        SET_MARKER_COLOR        = 20;
        SET_TEXT_FACE           = 21;
        SET_TEXT_COLOR          = 22;
        SET_FILL_INTERIOR       = 23;
        SET_FILL_INDEX          = 24;
        SET_FILL_COLOR          = 25;
        INQUIRE_COLOR           = 26;
        VQ_CELLARRAY            = 27;
        INPUT_LOCATOR           = 28;
        INPUT_VALUATOR          = 29;
        
        INPUT_CHOICE            = 30;
        INPUT_STRING            = 31;
        SET_WRITING_MODE        = 32;
        SET_INPUT_MODE          = 33;
        INQUIRE_LINE            = 35;
        INQUIRE_MARKER          = 36;
        INQUIRE_FILL            = 37;
        INQUIRE_TEXT            = 38;
        SET_TEXT_ALIG           = 39;
    
        OPEN_V_WORK             = 100;
        CLOSE_V_WORK            = 101;
        EXTENDED_INQUIRE        = 102;
        CONTOUR_FILL            = 103;
        SET_FILL_PERIMETER      = 104;
        GET_PIXEL               = 105;
        SET_TEXT_EFFECT         = 106;
        SET_TEXT_HEIGHT_PTS     = 107;
        SET_LINE_END            = 108;
        COPY_RASTER_OPAQUE      = 109;
        
        TRANSFORM_FORM          = 110;
        SET_MOUSE_FORM          = 111;
        SET_FILL_USER           = 112;
        SET_LINE_USER           = 113;
        FILL_RECTANGLE          = 114;
        INQUIRE_INPUT           = 115;
        TEXT_EXTENT             = 116;
        INQUIRE_CELL            = 117;
        EX_TIMER_INTER          = 118;
        LOAD_FONTS              = 119;
        
        UNLOAD_FONTS            = 120;
        COPY_RASTER_TRANSP      = 121;
        SHOW_CURSOR             = 122;
        HIDE_CURSOR             = 123;
        MOUSE_BUTTONS           = 124;
        EX_BUT_CHANGE           = 125;
        EX_MOUSE_MOVE           = 126;
        EX_MOUSE_CHANGE         = 127;
        KEY_STATE               = 128;
        SET_CLIPPING            = 129;
        
        VQT_NAME                = 130;
        VQT_FONTINFO            = 131;
        
        (*  ESCAPE SubCmds
         *)
                
        VQ_CHCELLS              = 1;
        V_EXIT_CUR              = 2;
        V_ENTER_CUR             = 3;
        V_CURUP                 = 4;
        V_CURDOWN               = 5;
        V_CURRIGHT              = 6;
        V_CURLEFT               = 7;
        V_CURHOME               = 8;
        V_EEOS                  = 9;
        V_EEOL                  = 10;
        VS_CURADDRESS           = 11;
        V_CURTEXT               = 12;
        V_RVON                  = 13;
        V_RVOFF                 = 14;
        VQ_CURADDRESS           = 15;
        VQ_TABSTATUS            = 16;
        V_HARDCOPY              = 17;
        V_DSPCUR                = 18;
        V_RMCUR                 = 19;
        V_FORM_ADV              = 20;
        V_OUTPUT_WINDOW         = 21;
        V_CLEAR_DISP_LIST       = 22;
        V_BIT_IMAGE             = 23;
        VS_PALETTE              = 60;
        VQP_FILMS               = 91;
        VQP_STATE               = 92;
        VSP_STATE               = 93;
        VSP_SAVE                = 94;
        VSP_MESSAGE             = 95;
        VSP_ERROR               = 96;
        V_META_EXTENTS          = 98;
        V_WRITE_META            = 99;
        VM_FILENAME             = 100;
        V_OFFSET                = 101;
        V_FONTINIT              = 102;
        
        
        (*  GRAF_STANDARD SubCmds
         *)
                
        BAR                     = 1;
        ARC                     = 2;
        PIE                     = 3;
        CIRCLE                  = 4;
        ELLIPSE                 = 5;
        ELLIPTICAL_ARC          = 6;
        ELLIPTICAL_PIE          = 7;
        ROUNDED_RECT            = 8;
        FILL_ROUND_RECT         = 9;
        JUST_TEXT               = 10;
        
        
                (*  Misc. Codes  *)
                (*  ===========  *)
                
        GEMTrap                 = 2;
        VDICode                 = 115;
        AESCode                 = 200;
        

(* $FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFB9C50$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCB$FFFA6CCBÅ$000009F8T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00001F0F$00000026$00000BD0$000009F8$00000BD0$00000087$00000097$000000BF$000000AC$00000E5B$00000E18$00000E2A$000020EA$000020F7$0000211F$0000196EîÄÅ*)
