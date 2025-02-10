*-----------------------------------------------------------------------*
*       Apex program-text.       Dated: 1/9/94               *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*       Rules for translation: (set tabs to 6)               *
*-----------------------------------------------------------------------*
*       Each chunk of text will start with a guide contained in a starry        *
*       box like this one. The part named 'Approximate layout' shows    *
*       shich bits of the text (denoted by stars) can be changed               *
*       Generally, everything INSIDE quotes "" is alterable, while all  *
*       else is part of the program and is not to be changed.               *
*-----------------------------------------------------------------------*


*-----------------------------------------------------------------------*
*       General single-letter abbreviations (these may not need changed)        *
*-----------------------------------------------------------------------*
*       These messages are limited to 1 character                       *
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       Label   =       "*"                               *
*-----------------------------------------------------------------------*

RED_abbrev      =       "R"             ; RED                   (used on slider bars)
GRN_abbrev      =       "G"             ; GREEN
BLU_abbrev      =       "B"             ; BLUE

CYN_abbrev      =       "C"             ; CYAN
MAG_abbrev      =       "M"             ; MAGENTA
YEL_abbrev      =       "Y"             ; YELLOW

HUE_abbrev      =       "H"             ; HUE                   (an alternative is HLS
SAT_abbrev      =       "S"             ; SATURATION     or HUE,SATuration &
BRI_abbrev      =       "B"             ; BRIGHTNESS     LUMinance)

FRM_abbrev      =       "F"             ; FRAME operator        (used with animation)
SEG_abbrev      =       "S"             ; SEGMENT operator
ALL_abbrev      =       "A"             ; ALL operator

WID_abbrev      =       "B"             ; WIDTH, Breite         (for cutting blocks)
HIG_abbrev      =       "H"             ; HEIGHT

*-----------------------------------------------------------------------*
*       On-line help messages                       *
*-----------------------------------------------------------------------*
*       These messages are limited to 23 characters (including shortcut)        *
*       Do not change the single character enclosed within [ ]
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       Label:          dc.b    "********************[*]",0               *
*-----------------------------------------------------------------------*

*-----------------------------------*
*       #1 - Workstation tools          *
*-----------------------------------*

Swap_draw_help:         dc.b    "Stand. Zeichenwerkz.",0
Swap_cell_help:         dc.b    "Block-Workstation",0
Swap_colour_help:               dc.b    "Farb-Workstation",0
Swap_video_help:                dc.b    "Digitizer Interface",0

				ifnd    preview
Swap_pro_help:          dc.b    "Nichtlin. Z.-Werkz.",0
Swap_aproc_help:                dc.b    "Film & Bild Filter",0
Swap_morph_help:                dc.b    "Morphen & Verzerren",0
Swap_text_help:         dc.b    "Text Interface",0
Swap_none_help:         dc.b    "Reserved...",0
				elseif
Swap_pro_help:          dc.b    "Reserved...",0
Swap_aproc_help:                dc.b    "Reserved...",0
Swap_morph_help:                dc.b    "Reserved...",0
Swap_text_help:         dc.b    "Reserved...",0
Swap_none_help:         dc.b    "Reserved...",0
				endc

*-----------------------------------*
*       #2 - Drawing tools              *
*-----------------------------------*

Draw_brush_help:                dc.b    "Freihand-Zeichnen [D]",0
Draw_line_help:         dc.b    "Linien [L]",0
Draw_curve_help:                dc.b    "Kurven [K]",0
Draw_polygon_help:      dc.b    "Polygon [W]",0
Draw_circle_help:               dc.b    "Circle [O]",0
Draw_box_help:          dc.b    "Box [B]",0
Draw_fill_help:         dc.b    "FÅll Werkzeug [F]",0
Draw_airbrush_help:     dc.b    "Airbrush (tÅpfeln) [A]",0
Draw_grid_help:         dc.b    "Gittergrîûe",0
Draw_exchange_help:     dc.b    "Farben austauschen [E]",0

*-----------------------------------*
*       #3 - Cell/block tools           *
*-----------------------------------*

Cell_cut_help:          dc.b    "Man. Ausschneiden [ESC]",0
Cell_autocut_help:      dc.b    "Auto. Ausschneiden[TAB]",0
Cell_paste_help:                dc.b    "Deckend einfÅgen [P]",0
Cell_under_help:                dc.b    "Unter Bild einfÅgen [U]",0
Cell_move_help:         dc.b    "Block verschieben [M]",0
Cell_invert_help:               dc.b    "X/Y-Achse invert. [I]",0
Cell_rotate_help:               dc.b    "Block rotieren [R]",0
Cell_distort_help:      dc.b    "Block-Perspekive [Y]",0
Cell_rescale_help:      dc.b    "Block skalieren [S]",0
Cell_remap_help:                dc.b    "Farbpalette anpassen[N]",0

*-----------------------------------*
*       #4 - Palette tools              *
*-----------------------------------*

Colour_cut_help:                dc.b    "Farben ausschneiden [[]",0
Colour_paste_help:      dc.b    "Farben einfÅgen []]",0
Colour_exchange_help:   dc.b    "VG&HG-Farbe tauschen[T]",0
Colour_spread_help:     dc.b    "Farbverlauf erst. [-]",0
Colour_flip_help:               dc.b    "Farbbereich umkehren[H]",0
Colour_sort_help:               dc.b    "Farben sortieren [J]",0
Colour_grey_help:               dc.b    "Grau-Filter [G]",0

*-----------------------------------*
*       #5 - Video tools                        *
*-----------------------------------*

Video_size_help:                dc.b    "Signal-Optionen [J]",0
Video_photo_help:               dc.b    "Photo aufnehmen [G]",0
Video_film_help:                dc.b    "Film aufnehmen [H]",0
Video_pip_help:         dc.b    "PiP ein-/ ausschalten",0

*-----------------------------------*
*       #6 - Professional tools         *
*-----------------------------------*

Pro_go_help:            dc.b    "Start mit neuen Opt.[G]",0
Pro_area_help:          dc.b    "ArbeitsflÑche def. [A]",0
Pro_mask_help:          dc.b    "Masken-Optionen [M]",0
Pro_options_help:               dc.b    "Farb-Options [O]",0
Pro_fill_help:          dc.b    "FÅllen [F]",0
Pro_brush_help:         dc.b    "Zeichnen [D]",0
Pro_airbrush_help:      dc.b    "Realist. Airbrush [R]",0

*-----------------------------------*
*       #7 - Anim processing tools      *
*-----------------------------------*

Aproc_go_help:          dc.b    "Start mit neuen Opt.[G]",0
Aproc_area_help:                dc.b    "ArbeitsflÑche festl.[A]",0
Aproc_dolby_help:               dc.b    "RauschunterdrÅckung [N]",0
Aproc_defocus_help:     dc.b    "Bewegungs-Unterdr.[D]",0
Aproc_mblur_help:               dc.b    "UnschÑrfe-Filter [B]",0
Aproc_dejag_help:               dc.b    "KantenglÑttung [J]",0

*-----------------------------------*
*       #8 - Morphing tools             *
*-----------------------------------*

Morph_line_help:                dc.b    "neue Warp-Linien [L]",0
Morph_drag_help:                dc.b    "Warp-L. verschieben [D]",0
Morph_del_l_help:               dc.b    "Warp-L. entfernen [BS]",0
Morph_del_a_help:               dc.b    "Alle Warp-L. entf. [K]",0
Morph_area_help:                dc.b    "ArbeitsflÑche def. [A]",0
Morph_options_help:     dc.b    "Morph-Options [O]",0
Morph_go_help:          dc.b    "Start mit neuen Opt. [G]",0

*-----------------------------------*
*       #9 - Calamus CFN tools          *
*-----------------------------------*

Text_type_help:         dc.b    "Text Cursor [T]",0
Text_options_help:      dc.b    "Font Options [O]",0
Text_clear_help:                dc.b    "Font lîschen [E]",0

*-----------------------------------*
*       #10 - Standard (fixed) icons    *
*-----------------------------------*

Apex_info_help:         dc.b    "Info & Voreinstellung",0
Apex_disk_help:         dc.b    "Datei Operationen [RET]",0
Apex_brush_help:                dc.b    "Pinsel-Optionen [#]",0
Apex_video_help:                dc.b    "Video Optionen [V]",0
Apex_quit_help:         dc.b    "Beenden [Q]",0
Apex_sys_help:          dc.b    "System Information",0

*-----------------------------------*
*       #11 - Animation control         *
*-----------------------------------*

Frame_start_help:               dc.b    "Zum Anfang [,]",0
Frame_end_help:         dc.b    "Zum Ende [.]",0
Frame_left_help:                dc.b    "ZurÅck []/Abspielen []",0
Frame_right_help:               dc.b    "VorwÑrts[]/Abspielen[]",0
Frame_bar_help:         dc.b    "Frame-Position Regler",0
Frame_left_ins_help:    dc.b    "links einfÅgen",0
Frame_right_ins_help:   dc.b    "rechts einfÅgen [INS]",0
Frames_delete_help:     dc.b    "leeren[CLR]/entf.[DEL]",0
Frame_none_help:                dc.b    "Frame-Positions-Balken",0

*-----------------------------------*
*       #12 - Extra functions           *
*-----------------------------------*

Time_bar_help:          dc.b    "Abspielgeschwindigkeit",0
Palette_colours_help:   dc.b    "Farb-Palette",0
Tween_menu_help:                dc.b    "AMR & Animation",0
Check_draw_window_help: dc.b    "aktuelles Bild",0

*-----------------------------------------------------------------------*
*       Additional help messages                       *
*-----------------------------------------------------------------------*
*       These messages are limited to 34 characters               * 
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       dc.b    27,"Y",0,Tx,Ty+Tg*??,"[*]          *********************"       *
*-----------------------------------------------------------------------*

Apex_help_text:
 dc.b   27,"Y",0,Tx,Ty+Tg*01,"[,]/[.]      Zum Start oder Anfang"
 dc.b   27,"Y",0,Tx,Ty+Tg*02,"[C]          Farbe Picken"
 dc.b   27,"Y",0,Tx,Ty+Tg*03,"[X]          In Rontgen-Modus"
 dc.b   27,"Y",0,Tx,Ty+Tg*04,"[Z]          hereinzoomen"
 dc.b   27,"Y",0,Tx,Ty+Tg*05,"[\]          herauszoomen"
 dc.b   27,"Y",0,Tx,Ty+Tg*06,"[SPACE]      Mit Maus scrollen"
 dc.b   27,"Y",0,Tx,Ty+Tg*07,"[UNDO]       énderung rÅckgangig"
 dc.b   27,"Y",0,Tx,Ty+Tg*08,"[BACKSPACE]  Bild wiederherstellen"
 dc.b   27,"Y",0,Tx,Ty+Tg*09,"Keypad [.]   Speicher lîschen"
 dc.b   27,"Y",0,Tx,Ty+Tg*10,"Keypad [*]   MenÅfarben anpassen"
 dc.b   27,"Y",0,Tx,Ty+Tg*11,"Keypad [0-9] Bild scrollen"
 dc.b   0

*-----------------------------------------------------------------------*
*       Warning and confirmation dialog text               *
*-----------------------------------------------------------------------*
*       These messages are limited to 26 characters (maybe 27)       * 
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       dc.b            27,"Y",0,84,091,"**************************"            *
*       dc.b            27,"Y",0,84,099,"**************************"            *
*-----------------------------------------------------------------------*

OPEN_ERROR_TEXT:
	dc.b            27,"Y",0,84,091,"Dateifehler beim ôffnen!"
	dc.b            27,"Y",0,84,099,"Ursache unbekannt."
	dc.b            0

READ_ERROR_TEXT:
	dc.b            27,"Y",0,84,091,"Dateifehler beim Lesen!"
	dc.b            27,"Y",0,84,099,"Evtl. Diskette beschÑgt."
	dc.b            0

WRIT_ERROR_TEXT:
	dc.b            27,"Y",0,84,091,"Dateifehler beim Schreiben!"
	dc.b            27,"Y",0,84,099,"Evtl. Diskette voll."
	dc.b            0

MODE_ERROR_TEXT:
	dc.b            27,"Y",0,84,091,"Dateiformat wird in diesem"
	dc.b            27,"Y",0,84,099,"Videomod. nicht unterstÅtzt"
	dc.b            0

TYPE_ERROR_TEXT:
	dc.b            27,"Y",0,84,091,"Datei ist nicht im richtigen"
	dc.b            27,"Y",0,84,099,"Format."
	dc.b            0

SIZE_ERROR_TEXT:
	dc.b            27,"Y",0,84,091,"Dateiformat ungewîhlich."
	dc.b            27,"Y",0,84,099,"Fortfahren?"
	dc.b            0

NCM_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"Sie benîtigen eine Farbe"
	dc.b            27,"Y",0,84,099,"fÅr ausgewÑhlte Operation."
	dc.b            0

NTC_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"Diese Option arbeitet nur"
	dc.b            27,"Y",0,84,099,"im True Color Modus."
	dc.b            0

NBP_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"Nur im 256 Farben-Modus"
	dc.b            27,"Y",0,84,099,"mîglich."
	dc.b            0

RAM_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"Nicht genÅgend Speicher"
	dc.b            27,"Y",0,84,099,"fÅr diese Operation."
	dc.b            0

DLT_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"Sie dÅrfen das 40 Frame"
	dc.b            27,"Y",0,84,099,"Limit nicht Åberschreiten"
	dc.b            0

CFG_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"Irgendetwas wurd nicht"
	dc.b            27,"Y",0,84,099,"eingestellet. S. Handbuch."
	dc.b            0

*-----------------------------------------------------------------------*
*       Fault reports (these are for bugs and should never occur anyway *
*-----------------------------------------------------------------------*
*       These messages are limited to 26 characters               * 
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       dc.b            27,"Y",0,84,091,"**************************"            *
*       dc.b            27,"Y",0,84,099,"**************************"            *
*-----------------------------------------------------------------------*

RBR_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*--- Bad handle found ---*"
	dc.b            27,"Y",0,84,099,"*- Resize_block failure -*"
	dc.b            0
RBP_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- Bad pointer found ---*"
	dc.b            27,"Y",0,84,099,"*- Resize_block failure -*"
	dc.b            0

DBR_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*--- Bad handle found ---*"
	dc.b            27,"Y",0,84,099,"*- Delete_block failure -*"
	dc.b            0
DBP_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- Bad pointer found ---*"
	dc.b            27,"Y",0,84,099,"*- Delete_block failure -*"
	dc.b            0

FBR_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*--- Bad handle found ---*"
	dc.b            27,"Y",0,84,099,"*- Locate_block failure -*"
	dc.b            0
FBP_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- Bad pointer found ---*"
	dc.b            27,"Y",0,84,099,"*- Locate_block failure -*"
	dc.b            0

DFR_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- Bad frame ID found --*"
	dc.b            27,"Y",0,84,099,"*- Delete_frame failure -*"
	dc.b            0
BAF_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- No more data slots --*"
	dc.b            27,"Y",0,84,099,"*- RAM Effectively full -*"
	dc.b            0

RBZ_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- Illegal block size --*"
	dc.b            27,"Y",0,84,099,"*- Resize_block failure -*"
	dc.b            0
DBZ_ALERT_TEXT:
	dc.b            27,"Y",0,84,091,"*-- Illegal block size --*"
	dc.b            27,"Y",0,84,099,"*- Delete_block failure -*"
	dc.b            0

*-----------------------------------------------------------------------*
*       Fault reports (these are for bugs and should never occur anyway *
*-----------------------------------------------------------------------*
*       These messages are limited to 27 characters               * 
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       dc.b            27,"Y",0,80,89+2,"***************************"          *
*       dc.b            27,"Y",0,80,97+2,"***************************"          *
*-----------------------------------------------------------------------*

vidask_text:    dc.b    27,"Y",0,80,89+2,"Auflîsungswechsel lîscht"
			dc.b    27,"Y",0,80,97+2,"Grafiken im Speicher..."
			dc.b    0
resask_text:    dc.b    27,"Y",0,80,89+2,"Operation lîscht alle "
			dc.b    27,"Y",0,80,97+2,"Graphiken im Speicher..."
			dc.b    0
sleepask_text:  dc.b    27,"Y",0,80,89+2,"Nur wenn das memory CPX "
			dc.b    27,"Y",0,80,97+2,"richtig konfiguriert ist!"
			dc.b    0
quitask_text:   dc.b    27,"Y",0,80,93+2,"Wirklich beenden?"
			dc.b    0
aboask_text:    dc.b    27,"Y",0,80,89+2,"Operation unterbrochen..."
			dc.b    27,"Y",0,80,97+2,"Wirlich abbrechen?"
			dc.b    0
segask_text:    dc.b    27,"Y",0,80,89+2,"Mîchten Sie dies mit einer"
			dc.b    27,"Y",0,80,97+2,"Frame-Sequenz machen?"
			dc.b    0
allask_text:    dc.b    27,"Y",0,80,89+2,"Mîchten Sie dies mit allen"
			dc.b    27,"Y",0,80,97+2,"Frames machen?  "
			dc.b    0
buserr_text:    dc.b    27,"Y",0,80,89+2,"Apex ist abgestÅrzt!"
			dc.b    27,"Y",0,80,97+2,"Abspeichern und beenden... "
			dc.b    0

*-----------------------------------------------------------------------*
*       General spot-messages (covers various areas)               *
*-----------------------------------------------------------------------*
*       These are very specific, and limits will be noted individually  *
*-----------------------------------------------------------------------*
*       Approximate layout:                       *
*-----------------------------------------------------------------------*
*       You will have to use your own judgement!                       *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*       Try to keep these under 28 characters!               *
*-----------------------------------------------------------------------*

readfile_text:
	dc.b            "LESE DATEI:",0
writefile_text:
	dc.b            "SCHREIBE DATEI:",0
rescale_text:
	dc.b            "BILDGRôûE éNDERN:",0
dither_text:
	dc.b            "PIXEL RASTERN:",0
remap_text:
	dc.b            "GRôûE & FORMAT ANPASSEN:",0
mipmap_text:
	dc.b            "SUPERSAMPLING:",0
extract_text:
	dc.b            "ERRECHNE NEUE PALETTE:",0
	even

*-----------------------------------------------------------------------*
*       Try to keep these very short.                       *
*-----------------------------------------------------------------------*

KBYTES:         dc.b    'K Bytes.',0
FTEXT:          dc.b    'Frame',0
SEPARATOR:              dc.b    ' of ',0
			even
			
*-----------------------------------------------------------------------*
*       Try to keep these under 20 characters.               *
*-----------------------------------------------------------------------*

SELECTOR_MLOAD: dc.b    "Lade Datei...",0
SELECTOR_MSAVE: dc.b    "Sichere Datei...",0
			even

*-----------------------------------------------------------------------*
*       Keep these under 18 characters.               *
*-----------------------------------------------------------------------*

font_text:              dc.b    27,"Y",0,86,88+14*0,"Relative Grîûe"
			dc.b    27,"Y",0,86,88+14*1,"Zeichenabstand"
			dc.b    27,"Y",0,86,88+14*2,"KurvenglÑtte"
			dc.b    0

status_text:    dc.b    27,"Y",0,80,89+2,"Belegter:"
			dc.b    27,"Y",0,80,97+2,"Freier:"
			dc.b    0

*-----------------------------------------------------------------------*
*       Keep this under 9 characters.                       *
*-----------------------------------------------------------------------*

video_text:             dc.b    27,"Y",0,48+3+32-22-2,140-34+16-6-7+5,"Breite:"
			dc.b    27,"Y",0,48+3+32-22-2,154-34+16+6-7+5,"Hîhe:"
			dc.b    0

*-----------------------------------------------------------------------*
*       This appears on the TOS screen, just keep it under 40 characters        *
*       per line, with each line ending in 13,10 for a line-feed...             *
*-----------------------------------------------------------------------*

merr_text:              dc.b    27,'E',27,'f',13,10
			dc.b    " Sie mÅssen mehr RAM freimachen!",13,10,13,10
			dc.b    " DrÅcken Sie SPACE zum verlassen...",0
			even

*-----------------------------------------------------------------------*
*       Probably best not to edit these - just supply a translation!    *
*       TRY THESE CHANGES. IF ANY PROBLEM OCCOURS, IGNORE THEM.
*-----------------------------------------------------------------------*

apex_alert:
		dc.b    "[0][ "
		ifd	cutdown
		dc.b	"|"," Apex Animator Intro "
		elseif
		dc.b  "|","    Apex Animator "
		endc
		version
		dc.b	  "    "
		dc.b    "|","  fÅr den Atari Falcon030  "
		dc.b    "| "
		dc.b    "|","  (C) 1995 Black Scorpion   "
		dc.b    " ]"
		dc.b    "[ Ok ]",0
_s0             dc.b    " Desk ",0
_s1             dc.b    " Program ",0
_s2             dc.b    "  Information...  ",0
_s10            dc.b    " ZurÅck zu Apex ",0
		even
		
*-----------------------------------------------------------------------*