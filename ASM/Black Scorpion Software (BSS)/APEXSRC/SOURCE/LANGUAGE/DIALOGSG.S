*-----------------------------------------------------------------------*
*       Generally speaking, try to keep the number of characters down to        *
*       a minimum. Everything inside bracketed quuotes <"*****"> is to  *
*       be translated. Touch absolutely nothing else!               *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*       Drawing tools (WorkStation #1)               *
*-----------------------------------------------------------------------*

WIN_Apex_brush:
 D_miniframe    96-32-16,68-32-8,128+64+32,64+64+16,<"Zeichen-Stifte & -Pinsel">
bit_num         set     0
 D_panbutton    BmenX+22*0,BmenY+22*0,20,20,WIN,BRUSH,B1
 D_panbutton    BmenX+22*1,BmenY+22*0,20,20,WIN,BRUSH,B2
 D_panbutton    BmenX+22*2,BmenY+22*0,20,20,WIN,BRUSH,B3
 D_panbutton    BmenX+22*3,BmenY+22*0,20,20,WIN,BRUSH,B4
 D_panbutton    BmenX+22*4,BmenY+22*0,20,20,WIN,BRUSH,B5
 D_panbutton    BmenX+22*5,BmenY+22*0,20,20,WIN,BRUSH,B6
 D_panbutton    BmenX+22*6,BmenY+22*0,20,20,WIN,BRUSH,B7
 D_panbutton    BmenX+22*7,BmenY+22*0,20,20,WIN,BRUSH,B8
 D_panbutton    BmenX+22*0,BmenY+22*1,20,20,WIN,BRUSH,B9
 D_panbutton    BmenX+22*1,BmenY+22*1,20,20,WIN,BRUSH,B10
 D_panbutton    BmenX+22*2,BmenY+22*1,20,20,WIN,BRUSH,B11
 D_panbutton    BmenX+22*3,BmenY+22*1,20,20,WIN,BRUSH,B12
 D_panbutton    BmenX+22*4,BmenY+22*1,20,20,WIN,BRUSH,B13
 D_panbutton    BmenX+22*5,BmenY+22*1,20,20,WIN,BRUSH,B14
 D_panbutton    BmenX+22*6,BmenY+22*1,20,20,WIN,BRUSH,B15
 D_panbutton    BmenX+22*7,BmenY+22*1,20,20,WIN,BRUSH,B16
bit_num         set     0
 D_panbutton    BmenX+22*6,BmenY+22*3-12,20,20,WIN,BRUSH2,C1,<"#1">
 D_panbutton    BmenX+22*7,BmenY+22*3-12,20,20,WIN,BRUSH2,C2,<"#2">
 D_panbutton    BmenX+22*6,BmenY+22*4-12,20,20,WIN,BRUSH2,C3,<"#3">
 D_panbutton    BmenX+22*7,BmenY+22*4-12,20,20,WIN,BRUSH2,C4,<"#4">
 D_routine              print_brush_menu
bit_num         set     0
 D_radbutton    BmenX+22*0,BmenY+22*3-4,10,6,WIN,BTYPE,NORM,<"Benutze Stift">
 D_radbutton    BmenX+22*0,BmenY+22*4-4,10,6,WIN,BTYPE,CUST,<"Block als Stift">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*

WIN_Draw_brush:
 D_miniframe    96,68,128,64,<"Pinsel">
bit_num         set     0
 D_radbutton    118,85,10,6,TOOL,DRAW,NORM,<"Verbunden">
 D_radbutton    118,97,10,6,TOOL,DRAW,STREAK,<"Unverbunden">
 D_radbutton    118,109,10,6,TOOL,DRAW,LASSOO,<"Als Fl„che">
 both_jump              WIN_Quit

WIN_Draw_line:
 D_miniframe    96,68,128,64,<"Linie">
bit_num         set     0
 D_radbutton    111,85,10,6,TOOL,LINE,NORM,<"Normal">
 D_radbutton    111,97,10,6,TOOL,LINE,GRAD,<"Verlauf">
 D_radbutton    111,109,10,6,TOOL,LINE,INT,<"Interpolierend">
 both_jump              WIN_Quit

WIN_Draw_curve:
 D_miniframe    96,60,128,80,<"Kurve">
bit_num         set     0
 D_radbutton    118,79,10,06,TOOL,CURVE,BEZIER,<"Bezier">
 D_radbutton    118,91,10,06,TOOL,CURVE,BETAC,<"B Curve">
 D_radbutton    118,103,10,06,TOOL,CURVE,BETAS,<"B Spline">
 D_radbutton    118,115,10,06,TOOL,CURVE,BETAG,<"Polyspline">
 both_jump              WIN_Quit

WIN_Draw_polygon:
 D_miniframe    92,68,136,64,<"Polygon">
bit_num         set     0
 D_radbutton    114,85,10,6,TOOL,POLY,WIRE,<"Leer">
 D_radbutton    114,97,10,6,TOOL,POLY,SOLID,<"Gefllt">
 D_radbutton    114,109,10,6,TOOL,POLY,TRIP,<"Interpolierend">
 both_jump              WIN_Quit

WIN_Draw_circle:
 D_miniframe    96,68,128,64,<"Kreis">
bit_num         set     0
 D_radbutton    118,85,10,6,TOOL,CIRCLE,WIRE,<"Leer">
 D_radbutton    118,97,10,6,TOOL,CIRCLE,SOLID,<"Gefllt">
 D_radbutton    118,109,10,6,TOOL,CIRCLE,SPHERE,<"Kugelf”rmig">
 both_jump              WIN_Quit

WIN_Draw_box:
 D_miniframe    92,54,136,92,<"Box">
bit_num         set     0
 D_radbutton    114,97,10,6,TOOL,BOX1,SQUARE,<"Quadratisch">
bit_num         set     0
 D_radbutton    114,73,10,6,TOOL,BOX2,WIRE,<"Leer">
 D_radbutton    114,85,10,6,TOOL,BOX2,SOLID,<"Gefllt">
 D_radbutton    114,109,10,6,TOOL,BOX2,GRAD,<"Verlauf">
 D_radbutton    114,121,10,6,TOOL,BOX2,QUAD,<"Interpolierend">
 both_jump              WIN_Quit

WIN_Draw_fill:
 D_miniframe    96,68,128,64,<"Fl„chenfllen">
bit_num         set     0
 D_radbutton    112,85,10,6,TOOL,FILL,SOLID,<"Benutze Farbe">
 D_radbutton    112,97,10,6,TOOL,FILL,BRUSH,<"Benutze Pinsel">
 D_radbutton    112,109,10,6,TOOL,FILL,GRAD,<"Verlauf">
 both_jump              WIN_Quit

WIN_Draw_airbrush:
 D_mainframe    48,45,224,120,<"Airbrush">
bit_num         set     0
 D_zone         AirSizBarXmin,AirSizBarYmin,AirSizBarXmax-AirSizBarXmin,4,air_size
 D_zone         AirFloBarXmin,AirFloBarYmin,AirFloBarXmax-AirFloBarXmin,4,air_flow
 D_outline              AirSizBarXmin-8,AirSizBarYmin-8,AirSizBarXmax-AirSizBarXmin+16,20,<"Radius">
 D_outline              AirFloBarXmin-8,AirFloBarYmin-8,AirFloBarXmax-AirFloBarXmin+16,20,<"Menge">
 D_radbutton    69,64,10,6,TOOL,AIR,FREE,<"Feste Menge">
 D_radbutton    160,64,10,6,TOOL,AIR,CTRL,<"Automatisch">
 D_routine              Update_air_sliders
 both_jump              WIN_Quit

WIN_Draw_grid:
 D_miniframe    96,78,128,44,<"Fang-Gitter">
bit_num         set     0
 D_radbutton    118,97,10,6,FUNCT,GRID,USE,<"Gitter ein">
 both_jump              WIN_Quit

WIN_Draw_exchange:
 D_miniframe    96,74,128,52,<"Ersetzten">
bit_num         set     0
 D_radbutton    118,91,10,6,BLOCK,REPL,NRM,<"Inklusiv">
 D_radbutton    118,103,10,6,BLOCK,REPL,INV,<"Exklusiv">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Block/Cell tools (WorkStation #2)                       *
*-----------------------------------------------------------------------*

WIN_Cell_cut:
 D_miniframe    96,74,128,52,<"Ausschneiden">
bit_num         set     0
 D_radbutton    118,91,10,6,BLOCK,CUT,RECT,<"Rechteck">
 D_radbutton    118,103,10,6,BLOCK,CUT,JACK,<"Klinge">
 both_jump              WIN_Quit

WIN_Cell_paste:
WIN_Cell_move:
 D_miniframe    96,74,128,52,<"Block-Typ">
bit_num         set     0
 D_radbutton    118,91,10,6,BLOCK,PASTE,SOLI,<"Deckend">
 D_radbutton    118,103,10,6,BLOCK,PASTE,XRAY,<"Transparent">
 both_jump              WIN_Quit

WIN_Tool_remap:
 D_miniframe    92-10,74,136+20,52,<"Farbpalette anpassen">
bit_num         set     0
 D_radbutton    118,91,10,6,TOOL,REMAP,BLOCK,<"Block = Bild">
 D_radbutton    118,103,10,6,TOOL,REMAP,IMAGE,<"Bild = Block">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Palette tools (WorkStation #3)               *
*-----------------------------------------------------------------------*

WIN_Colour_sort:
 D_miniframe    92,54,136,92,<"Farben sortieren">
bit_num         set     0
 D_radbutton    118,73,10,6,RGB,SORT,LUM,<"Intensit„t">
 D_radbutton    118,85,10,6,RGB,SORT,CHR,<"Farbton">
 D_radbutton    118,97,10,6,RGB,SORT,RED,<"Rot">
 D_radbutton    118,109,10,6,RGB,SORT,GRN,<"Grn">
 D_radbutton    118,121,10,6,RGB,SORT,BLU,<"Blau">
 both_jump              WIN_Quit

WIN_Colour_sort2:
 D_miniframe    92,74,136,52,<"Ergebnis">
bit_num         set     0
 D_radbutton    118,91,10,6,RGB,SORT2,REV,<"verwerfen">
 D_radbutton    118,103,10,6,RGB,SORT2,PER,<"bernehmen">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Video tools (WorkStation #4)                       *
*-----------------------------------------------------------------------*

WIN_Video_size:
 D_miniframe    96,68,128,64,<"Signal-Optionen">
bit_num         set     0
 D_radbutton    118,85,10,6,WIN,DSIZE,N256,<"Non-laced">
 D_radbutton    118,97,10,6,WIN,DSIZE,N512,<"Interlaced">
 D_radbutton    118,109,10,6,WIN,DSIZE,WIDE,<"Breitformat">
 both_jump              WIN_Quit

WIN_PIP_options:
 D_miniframe    96,78,128,44,<"PiP-Kamera">
bit_num         set     0
 D_radbutton    118,97,10,6,BLOCK,PIP,ENAB,<"Video ein">
 both_jump              WIN_Quit

WIN_Video_photo:
 D_miniframe    92,54,136,92,<"Belichtung">
bit_num         set     0
 D_radbutton    118,73,10,6,WIN,EXP,FAST,<"kurze Blende">
 D_radbutton    118,85,10,6,WIN,EXP,X2,<"Blende x2">
 D_radbutton    118,97,10,6,WIN,EXP,X4,<"Blende x4">
 D_radbutton    118,109,10,6,WIN,EXP,X8,<"Blende x8">
 D_radbutton    118,121,10,6,WIN,EXP,X16,<"Blende x16">
 both_jump              WIN_Quit

WIN_Video_film:
 D_miniframe    96,60,128,80,<"Filmg”že">
bit_num         set     0
 D_radbutton    118,79,10,6,WIN,ANI,A512,<"Grož">
 D_radbutton    118,91,10,6,WIN,ANI,A256,<"Mittel">
 D_radbutton    118,103,10,6,WIN,ANI,A128,<"Klein">
bit_num         set     0
 D_radbutton    118,115,10,6,WIN,FILM,WRAP,<"Durchgehend">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Professional tools (WorkStation #5)                       *
*-----------------------------------------------------------------------*

WIN_Mask_sliders:
 D_mainframe    160-112,100-32,224,64,<"Analoge Maske">
 D_zone         Hue1BarXmin,Hue1BarYmin,Hue1BarXmax-Hue1BarXmin,Hue1BarYmax-Hue1BarYmin,hue1_slider
 D_zone         Sat1BarXmin,Sat1BarYmin,Sat1BarXmax-Sat1BarXmin,Sat1BarYmax-Sat1BarYmin,sat1_slider
 D_zone         Bri1BarXmin,Bri1BarYmin,Bri1BarXmax-Bri1BarXmin,Bri1BarYmax-Bri1BarYmin,bri1_slider
 D_grovzone             Hue1BarXmin-15,Hue1BarYmin+1,7,7,hue1_dn
 D_grovzone             Sat1BarXmin-15,Sat1BarYmin+1,7,7,sat1_dn
 D_grovzone             Bri1BarXmin-15,Bri1BarYmin+1,7,7,bri1_dn
 D_grovzone             Hue1BarXmax+8,Hue1BarYmin+1,7,7,hue1_up
 D_grovzone             Sat1BarXmax+8,Sat1BarYmin+1,7,7,sat1_up
 D_grovzone             Bri1BarXmax+8,Bri1BarYmin+1,7,7,bri1_up
bit_num         set     0
 D_panbutton    Hue1BarXmax+21,Hue1BarYmin,027,8,WIN,VIEW,HUE
 D_panbutton    Sat1BarXmax+21,Sat1BarYmin,027,8,WIN,VIEW,SAT
 D_panbutton    Bri1BarXmax+21,Bri1BarYmin,027,8,WIN,VIEW,BRI
 D_grovzone             Sat1BarXmax+72-17,Hue1BarYmin+1,021,035,pick_hsv1
 D_routine              Update_source_sliders
 D_routine              Draw_hsv1_zone
 D_text         mask_text
 icon_jump              PALETTE_BAR_ICONS
 end_gadget

WIN_CONV_sliders:
 D_mainframe    160-112,100-64-4,224,128+8,<"Farb-Optionen">
 D_zone         ValBarXmin,ValBarYmin,ValBarXmax-ValBarXmin,ValBarYmax-ValBarYmin,val_slider
 D_zone         Hue2BarXmin,Hue2BarYmin,Hue2BarXmax-Hue2BarXmin,Hue2BarYmax-Hue2BarYmin,hue2_slider
 D_zone         Sat2BarXmin,Sat2BarYmin,Sat2BarXmax-Sat2BarXmin,Sat2BarYmax-Sat2BarYmin,sat2_slider
 D_zone         Bri2BarXmin,Bri2BarYmin,Bri2BarXmax-Bri2BarXmin,Bri2BarYmax-Bri2BarYmin,bri2_slider
 D_grovzone             ValBarXmin-15,ValBarYmin+1,7,7,val_dn
 D_grovzone             Hue2BarXmin-15,Hue2BarYmin+1,7,7,hue2_dn
 D_grovzone             Sat2BarXmin-15,Sat2BarYmin+1,7,7,sat2_dn
 D_grovzone             Bri2BarXmin-15,Bri2BarYmin+1,7,7,bri2_dn
 D_grovzone             ValBarXmax+8,ValBarYmin+1,7,7,val_up
 D_grovzone             Hue2BarXmax+8,Hue2BarYmin+1,7,7,hue2_up
 D_grovzone             Sat2BarXmax+8,Sat2BarYmin+1,7,7,sat2_up
 D_grovzone             Bri2BarXmax+8,Bri2BarYmin+1,7,7,bri2_up
bit_num         set     0
 D_radbutton    44+24+10,51+12*0,8,6,WIN,OPER,LGHT,<"Heller">
 D_radbutton    43+24+6*18,51+12*0,8,6,WIN,OPER,DARK,<"Dunkler">
 D_radbutton    44+24+10,51+12*1,8,6,WIN,OPER,SAT,<"S„ttigen">
 D_radbutton    43+24+6*18,51+12*1,8,6,WIN,OPER,FADE,<"Bleichen">
 D_radbutton    44+24+10,51+12*2,8,6,WIN,OPER,WASH,<"Wasserfarbe">
 D_radbutton    43+24+6*18,51+12*2,8,6,WIN,OPER,MAT,<"Filter">
 D_panbutton    205,100-6,052,8,WIN,OPER,COMP,<"Schicht">
bit_num         set     0
 D_panbutton    Bri2BarXmax+21,Bri2BarYmin,021,8,WIN,ENAB,BRI
 D_panbutton    Sat2BarXmax+21,Sat2BarYmin,021,8,WIN,ENAB,SAT
 D_panbutton    Hue2BarXmax+21,Hue2BarYmin,021,8,WIN,ENAB,HUE
 D_grovzone             Hue2BarXmax+72-20,Hue2BarYmin+1,021,035,pick_hsv2
 D_routine              Update_dest_sliders
 D_routine              Update_val_slider
 D_text         inking_text
 icon_jump              PALETTE_BAR_ICONS
 end_gadget

*-----------------------------------------------------------------------*
*       Processing tools (WorkStation #6)                       *
*-----------------------------------------------------------------------*

WIN_Aproc_motion:
 D_miniframe    96,68,128,64,<"Bewegungs-Filter">
bit_num         set     0
 D_zone         FilterBarXmin,FilterBarYmin,FilterBarXmax-FilterBarXmin,4,m_thresh
 D_outline      FilterBarXmin-8,FilterBarYmin-8,FilterBarXmax-FilterBarXmin+16,20,<"Schwellwert">
 D_routine              Update_motion_bar
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Morphing tools (WorkStation #7)               *
*-----------------------------------------------------------------------*

WIN_Setup_morph:
 D_miniframe    96-8,60,128+16,80,<"Morph-Optionen">
bit_num         set     0
 D_radbutton    106,79,10,06,WIN,MORPH1,PICTURE,<"Bild behalten">
 D_radbutton    106,91,10,06,WIN,MORPH1,PREVIEW,<"Bilder verwerfen">
bit_num         set     0
 D_radbutton    106,103,10,06,WIN,MORPH2,DISTORT,<"Verzerrung">
 D_radbutton    106,115,10,06,WIN,MORPH2,MORPH,<"Metamorphose">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Text tools (WorkStation #8)                       *
*-----------------------------------------------------------------------*

WIN_Text_options:
 D_miniframe    89-10-8,59-14+32-10,141+20+16,91+20-60+20,<"Font Optionen">
 D_editbutton   188+6,84+14*0,34,8,TEXT,SIZE,50,4,256
 D_editbutton   188+6,84+14*1,34,8,TEXT,SPACE,100,0,200
 D_editbutton   188+6,84+14*2,34,8,TEXT,SMOOTH,20,1,64
 D_text         font_text
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Colour-picker & palette tools                       *
*-----------------------------------------------------------------------*

WIN_Colourstation:
 D_microframe   32,16,320-32,80-32,<"Farb Station">
bit_num         set     0
 D_panbutton    8+30,041+2+rgby,022,8,WIN,RGB,RGB,<"RGB">
 D_panbutton    8+30,055+2+rgby,022,8,WIN,RGB,CMY,<"CMY">
 D_panbutton    8+30,069+2+rgby,022,8,WIN,RGB,HSV,<"HSB">
bit_num         set     0
 D_panbutton    247+uv_x+y_x+8+8+14,042+2+rgby,5,13,WIN,PCK,HSV
 D_panbutton    247+uv_x+y_x+8+8+14,056+2+rgby+6,5,13,WIN,PCK,YUV
 D_zone         RedBarXmin,RedBarYmin,RedBarXmax-RedBarXmin,RedBarYmax-RedBarYmin,red_slider
 D_zone         GrnBarXmin,GrnBarYmin,GrnBarXmax-GrnBarXmin,GrnBarYmax-GrnBarYmin,grn_slider
 D_zone         BluBarXmin,BluBarYmin,BluBarXmax-BluBarXmin,BluBarYmax-BluBarYmin,blu_slider
 D_grovzone             069,044+rgby,7,7,red_dn
 D_grovzone             069,058+rgby,7,7,grn_dn
 D_grovzone             069,072+rgby,7,7,blu_dn
 D_grovzone             198,044+rgby,7,7,red_up
 D_grovzone             198,058+rgby,7,7,grn_up
 D_grovzone             198,072+rgby,7,7,blu_up
 D_grovzone             247+uv_x,38+rgby+uv_y,32,32,pick_uv
 D_grovzone             247+uv_x+y_x,38+rgby+uv_y,8,32,pick_y
 D_grovzone             247+uv_x+y_x+16,38+rgby+uv_y,8,32,pick_c
 D_groove               064,038+rgby,173,046
 D_groove               212,044+rgby,20,7
 D_groove               212,058+rgby,20,7
 D_groove               212,072+rgby,20,7
 D_text         rgb_text
 D_routine              Update_rgb_sliders
 D_routine              Draw_YUV_zones
 D_zone         32,16,320-32,80-32,dummy
 icon_jump              COLOURSTATION_ICONS
 end_gadget

*-----------------------------------------------------------------------*
*       Tweening & animation                       *
*-----------------------------------------------------------------------*

WIN_Tween_menu:
 D_microframe   32,200-33,320-32,17
 D_routine              Update_tween_combo
bit_num         set     0
 D_panbutton    112-86+14,170,064,10,FUNCT,TWEEN,PING,<"Pendeln">
 D_frmbutton    163,170,30,10,FUNCT,TWEEN,START,<"Von">
 D_frmbutton    163+63+16,170,30,10,FUNCT,TWEEN,END,<"Bis">
 icon_jump              FRAME_CTRL_ICONS
 end_gadget

*-----------------------------------------------------------------------*
*       Information dialogs                       *
*-----------------------------------------------------------------------*

WIN_Apex_info:
 D_miniframe	89-10,59-10,141+20,91+20,<"Apex Animator v",version1,".",version2,version3>
 D_frame_up		89-10+12,59-10+12,141+20-24,91+20-24
 IFD                    INTRO
 D_routine              introduction
 ENDC
 both_jump              WIN_Quit

WIN_Apex_help:
 D_miniframe    79-32-4,49-4,161+64+8,91+28,<"Weitere Shortcuts">
 D_text         Apex_help_text
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Disk-option dialogs                       *
*-----------------------------------------------------------------------*

WIN_Apex_disk:
 D_mainframe    36,23,251,154,<"Disk-Optionen">
 D_outline              49,36,108,60,<"Format">
 D_outline              166,36,108,60,<"Palette">
 D_outline              49,104,108,60,<"Operation">
 D_outline              166,104,108,60,<"Command">
bit_num         set     0
 D_panbutton    166+8,112+12*2,92,8,FUNCT,DISKFLAG,MIPMAP,<"Supersampling">
 D_radbutton    166+8,43+8*1,8,4,FUNCT,DISKFLAG,MAKECOL,<"Pixel scannen">
 D_radbutton    166+8,43+8*0,8,4,FUNCT,DISKFLAG,NEWCOL,<"Bildpalette">
 D_radbutton    166+8,43+8*2,8,4,FUNCT,DISKFLAG,KEEPCOL,<"Fixfarben">
 D_panbutton    57+24*2,111+13*0,44,8,FUNCT,DISKFLAG,WRAP,<"Loop">
bit_num         set     0
 D_panbutton    57+24*0,111+13*0,44,8,FUNCT,DISKOP,REPLACE,<"Normal">
 D_panbutton    57+24*0,112+13*1,44,8,FUNCT,DISKOP,PRECEDE,<"Start">
 D_panbutton    57+24*2,112+13*1,44,8,FUNCT,DISKOP,PATCH,<"Edit">
 D_panbutton    57+24*0,111+13*2,44,8,FUNCT,DISKOP,INSERT,<"Mitte">
 D_panbutton    57+24*2,111+13*2,44,8,FUNCT,DISKOP,ABOVE,<"šber">
 D_panbutton    57+24*0,110+13*3,44,8,FUNCT,DISKOP,APPEND,<"Ende">
 D_panbutton    57+24*2,110+13*3,44,8,FUNCT,DISKOP,BELOW,<"Unter">
 D_editbutton   166+8+58,112+12*3,34,8,COLOUR,REDUCE,256,2,256
bit_num         set     0
 D_radbutton    166+8,44+8*3,8,4,FUNCT,REDUCE,GREY,<"Graustufen">
 D_panbutton    166+8,112+12*3,54,8,FUNCT,REDUCE,DITHER,<"Rastern">
 D_radbutton    166+8,45+8*4,8,4,FUNCT,REDUCE,FREQ,<"Frequenz">
 D_radbutton    166+8,45+8*5,8,4,FUNCT,REDUCE,SPAC,<"R„umlich">
bit_num         set     0
 D_frmbutton    166+8,111+12*0,44,8,FUNCT,DISKFUNC,LOAD,<"Laden">
 D_frmbutton    166+56,111+12*0,44,8,FUNCT,DISKFUNC,SAVE,<"Sichern">
 D_frmbutton	166+8,111+12*1,44,8,FUNCT,DISKFUNC,EDIT,<"Paste">
 D_frmbutton	166+56,111+12*1,44,8,FUNCT,DISKFUNC,CUT,<"Cut">
bit_num         set     0
 D_panbutton    57+24*0,43+12*0,20,8,FUNCT,DISKTYP1,PC1,<"PC1">
 D_panbutton    57+24*1,43+12*0,20,8,FUNCT,DISKTYP1,LBM,<"IFF">
 D_panbutton    57+24*2,43+12*0,20,8,FUNCT,DISKTYP1,SPU,<"SPU">
 D_panbutton    57+24*3,43+12*0,20,8,FUNCT,DISKTYP1,PCS,<"PCS">
 D_panbutton    57+24*0,43+12*1,20,8,FUNCT,DISKTYP1,TGA,<"TGA">
 D_panbutton    57+24*1,43+12*1,20,8,FUNCT,DISKTYP1,MTV,<"MTV">
 ifd preview
 both_jump              _x1
 endc
 D_panbutton    57+24*2,43+12*1,20,8,FUNCT,DISKTYP1,JPG,<"JPG">
 D_panbutton    57+24*3,43+12*1,20,8,FUNCT,DISKTYP1,GIF,<"GIF">
_x1
 D_panbutton    57+24*0,43+12*2,20,8,FUNCT,DISKTYP1,FLI,<"FLC">
 D_panbutton    57+24*1,43+12*2,20,8,FUNCT,DISKTYP1,SEQ,<"SEQ">
 D_panbutton    57+24*2,43+12*2,20,8,FUNCT,DISKTYP1,ANM,<"ANM">
 D_panbutton    57+24*3,43+12*2,20,8,FUNCT,DISKTYP1,BLK,<"APX">
 ifd preview
 both_jump              _x2
 endc
 D_panbutton    57+24*0,45+12*3,20,8,FUNCT,DISKTYP1,CFN,<"CFN">
_x2
 D_panbutton    57+24*1,45+12*3,20,8,FUNCT,DISKTYP1,DAC,<"DAC">
 ifd preview
 both_jump              WIN_Quit
 endc
 D_panbutton    57+24*2,45+12*3,20,8,FUNCT,DISKTYP1,CTL,<"FWR">
 D_frmbutton    57+24*3,45+12*3,20,8,FUNCT,DISKTYP1,CFG,<"CFG">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Video-option dialogs                       *
*-----------------------------------------------------------------------*
	
WIN_Setup_video:
 D_mainframe    36,23,251,154,<"Video-Optionen">
 D_outline              49,36,108,60,<"Aufl”sung">
 D_outline              166,36,108,60,<"Video-modus">
 D_outline              49,104,108,60,<"Seitengr”že">
 D_outline              166,104,108,60,<"DAC-Modus">
bit_num         set     0
 D_radbutton    65,45,10,6,WIN,RES,LOW,<"320 x 200">
 D_radbutton    65,57,10,6,WIN,RES,MED1,<"640 x 200">
 D_radbutton    65,69,10,6,WIN,RES,MED2,<"320 x 400">
 D_radbutton    65,81,10,6,WIN,RES,HIGH,<"640 x 400">
bit_num         set     0
 D_radbutton    182,45,10,6,WIN,VCOL,TRUE,<"True Color">
 D_radbutton    182,57,10,6,WIN,VCOL,COL256,<"256 Farben">
 D_radbutton    182,69,10,6,WIN,VCOL,GREY,<"Graustufen">
bit_num         set     0
 D_radbutton    182,81,10,6,WIN,VIDEO,PAL,<"PAL">
 D_radbutton    224,81,10,6,WIN,VIDEO,NTSC,<"NTSC">
 D_editbutton   83,121,38,10,VIDEO,CANWID,320,320,4096
 D_frmbutton    57,121,22,10,WIN,VIDEO,CANWIDd,<"®-">
 D_frmbutton    125,121,22,10,WIN,VIDEO,CANWIDu,<"-¯">
 D_editbutton   83,147,38,10,VIDEO,CANHIG,200,200,3072
 D_frmbutton    57,147,22,10,WIN,VIDEO,CANHIGd,<"®-">
 D_frmbutton    125,147,22,10,WIN,VIDEO,CANHIGu,<"-¯">
bit_num         set     0
 D_radbutton    182,113,10,6,WIN,BCOL,BIT9,<"512 Farb.">
 D_radbutton    182,125,10,6,WIN,BCOL,BIT12,<"4096 Farb.">
 D_radbutton    182,137,10,6,WIN,BCOL,BIT18,<"262144 Farb.">
 D_radbutton    182,149,10,6,WIN,BCOL,BIT24,<"16.7M Farb.">
 D_text         video_text
 D_routine              Update_video_combo
 both_jump              WIN_Quit
			
*-----------------------------------------------------------------------*

WIN_Prefs:
 D_miniframe    96-8-24-16-10,60-38,128+16+48+32+20,80+80,<"Voreinstellungen">
bit_num         set     0
 D_frmbutton    160-96-6,41+14*0,88+12,8,APEX,DIAL,CYB,<"Cyber-Dialoge">
 D_frmbutton    160+08-6,41+14*0,88+12,8,APEX,DIAL,FAST,<"Schnelle Dialoge">
bit_num         set     0
 D_frmbutton    160-96-6,41+14*1,88+12,8,APEX,IFACE,PROT,<"Seite schtzen">
 D_frmbutton    160+08-6,41+14*1,88+12,8,APEX,IFACE,FREE,<"Nicht schtzen">
bit_num         set     0
 D_frmbutton    160-96-6,41+14*2,88+12,8,APEX,HANDLE,LARGE,<"Kreis-Griffe">
 D_frmbutton    160+08-6,41+14*2,88+12,8,APEX,HANDLE,SMALL,<"Punkt-Griffe">
bit_num         set     0
 D_frmbutton    160-96-6,41+14*3,88+12,8,APEX,PROC,STD,<"Normal CPU">
 D_frmbutton    160+08-6,41+14*3,88+12,8,APEX,PROC,FAST,<"Andere CPU">
bit_num         set     0
 D_frmbutton    160-96-6,41+14*4,88+12,8,APEX,GEN,OFF,<"Genlock aus">
 D_frmbutton    160+08-6,41+14*4,88+12,8,APEX,GEN,ON,<"Genlock an">
bit_num         set     0
 D_panbutton    160-96-6,41+14*5,88+12,8,APEX,SCALER,FINE,<"Fein Skalieren">
 D_panbutton    160+08-6,41+14*5,88+12,8,APEX,SCALER,CHOP,<"Grobe Skalierung">
bit_num         set     0
 D_panbutton    160-96-6,41+14*6,88+12,8,APEX,SCALER2,KEEP,<"Aspekt behalten">
 D_panbutton    160+08-6,41+14*6,88+12,8,APEX,SCALER2,FIT,<"Aspekt verwerfen">
bit_num         set     0
 D_panbutton    160-96-6,41+14*7,88+12,8,APEX,COMP,SKIP,<"Delta-Packing">
 D_panbutton    160+08-6,41+14*7,88+12,8,APEX,COMP,RLE,<"Run-Packing">
bit_num         set     0
 D_panbutton    160-96-6,41+14*8,88+12,8,APEX,FLAG,BYTEPIXEL,<"APX = BPP">
 D_panbutton    160+08-6,41+14*8,88+12,8,APEX,FLAG,BITPLANES,<"APX = BPL">
 both_jump              WIN_Quit

WIN_Apex_sys:
 D_miniframe    62-8,72,196+16,64,<"Status Informationen">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         status_text
 D_routine              ram_info
 both_jump              WIN_Ok
	
*-----------------------------------------------------------------------*
*       Standard error messages                       *
*-----------------------------------------------------------------------*

WIN_OPEN_Error:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #0">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         OPEN_ERROR_TEXT
 both_jump              WIN_Ok

WIN_READ_Error:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #1">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         READ_ERROR_TEXT
 both_jump              WIN_Ok

WIN_WRIT_Error:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #2">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         WRIT_ERROR_TEXT
 both_jump              WIN_Ok

WIN_TYPE_Error:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #3">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         TYPE_ERROR_TEXT
 both_jump              WIN_Ok

WIN_MODE_Error:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #4">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         MODE_ERROR_TEXT
 both_jump              WIN_Ok

WIN_SIZE_Error:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #5">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         SIZE_ERROR_TEXT
 both_jump              WIN_Funct_resume

*-----------------------------------------------------------------------*
*       Standard warnings                               *
*-----------------------------------------------------------------------*

WIN_CFG_Alert:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #6">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         CFG_ALERT_TEXT
 both_jump              WIN_Ok

WIN_NCM_Alert:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #7">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         NCM_ALERT_TEXT
 both_jump              WIN_Ok

WIN_NTC_Alert:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #8">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         NTC_ALERT_TEXT
 both_jump              WIN_Ok

WIN_NBP_Alert:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #9">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         NBP_ALERT_TEXT
 both_jump              WIN_Ok

WIN_RAM_Alert:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #10">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Print_RAM_Alert
 both_jump              WIN_Ok

WIN_DLT_Alert:
 D_miniframe    62-8,72,196+16,64,<"System-Meldung #11">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         DLT_ALERT_TEXT
 both_jump              WIN_Ok

*-----------------------------------------------------------------------*
*       Anomalous event messages (bug reports)               *
*-----------------------------------------------------------------------*

WIN_RBR_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #1">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         RBR_ALERT_TEXT
 both_jump              WIN_Ok

WIN_RBP_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #2">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         RBP_ALERT_TEXT
 both_jump              WIN_Ok

WIN_DBR_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #3">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         DBR_ALERT_TEXT
 both_jump              WIN_Ok

WIN_DBP_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #4">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         DBP_ALERT_TEXT
 both_jump              WIN_Ok

WIN_FBR_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #5">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         FBR_ALERT_TEXT
 both_jump              WIN_Ok

WIN_FBP_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #6">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         FBP_ALERT_TEXT
 both_jump              WIN_Ok

WIN_DFR_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #7">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         DFR_ALERT_TEXT
 both_jump              WIN_Ok

WIN_BAF_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #8">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         BAF_ALERT_TEXT
 both_jump              WIN_Ok

WIN_DBZ_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #9">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         DBZ_ALERT_TEXT
 both_jump              WIN_Ok

WIN_RBZ_Alert:
 D_miniframe    62-8,72,196+16,64,<"Aužergew”hnlicher Vorfall #10">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         RBZ_ALERT_TEXT
 both_jump              WIN_Ok

WIN_INTRO_Alert:
 D_miniframe    62-8,72,196+16,64,<"Benutzerhinweis:">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_text         INTRO_TEXT
 both_jump              WIN_Ok

*-----------------------------------------------------------------------*
*       System-request messages                       *
*-----------------------------------------------------------------------*

WIN_Funct_abort:
 D_miniframe    62-8,72,196+16,64,<"Unterbrechung">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_aboask_menu
 both_jump              WIN_Funct_resume

WIN_Funct_all:
 D_miniframe    62-8,72,196+16,64,<"Best„tigung">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_allask_menu
 both_jump              WIN_Funct_accept

WIN_Funct_seg:
 D_miniframe    62-8,72,196+16,64,<"Best„tigung">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_segask_menu
 both_jump              WIN_Funct_accept

WIN_Apex_quit:
 D_miniframe    62-8,72,196+16,64,<"WICHTIG">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_quitask_menu
 both_jump              WIN_Funct_accept

WIN_Apex_sleep:
 D_miniframe    62-8,72,196+16,64,<"Benuter-Prompt">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_sleepask_menu
 both_jump              WIN_Funct_accept

WIN_Apex_video:
 D_miniframe    62-8,72,196+16,64,<"WICHTIG">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_vidask_menu
 both_jump              WIN_Funct_accept

WIN_Extra_reset:
 D_miniframe    62-8,72,196+16,64,<"WICHTIG">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_resask_menu
 both_jump              WIN_Funct_accept

WIN_buserr:
 D_miniframe    62-8,72,196+16,64,<"Du liebes bischen...">
 D_frame_up             64-8+32-20-1,72+24-16+5,192-64+40+2+16,62-48+8
 D_routine              Draw_buserr
 both_jump              WIN_Funct_accept

*-----------------------------------------------------------------------*

WIN_Funct_accept:
bit_num         set     0
 D_frmbutton    160-64-8,112,048,10,WIN,ASK,YES,<"OK">
 D_frmbutton    160+16+8,112,048,10,WIN,ASK,NO,<"Abbruch">
 both_jump              WIN_Quit

WIN_Funct_resume:
 D_frmbutton    160-64-8-8,112,048+16,10,WIN,ASK,GO,<"Fortfahren">
 D_frmbutton    160+16+8-8,112,048+16,10,WIN,ASK,ABORT,<"Abbrechen">
 both_jump              WIN_Quit

*-----------------------------------------------------------------------*
*       Dialog terminators                       *
*-----------------------------------------------------------------------*
	
WIN_Ok:
bit_num         set     0
 D_frmbutton    160-24-4,112,56,12,WIN,DIALOG,QUIT,<"Weiter">
WIN_Quit:
 icon_jump              PALETTE_BAR_ICONS
 end_gadget
