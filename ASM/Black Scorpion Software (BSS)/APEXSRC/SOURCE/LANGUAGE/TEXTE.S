*-----------------------------------------------------------------------*
*	Apex program-text.	 Dated: 1/9/94					*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*	Rules for translation: (set tabs to 6)					*
*-----------------------------------------------------------------------*
*	Each chunk of text will start with a guide contained in a starry	*
*	box like this one. The part named 'Approximate layout' shows	*
*	shich bits of the text (denoted by stars) can be changed		*
*	Generally, everything INSIDE quotes "" is alterable, while all	*
*	else is part of the program and is not to be changed.			*
*-----------------------------------------------------------------------*


*-----------------------------------------------------------------------*
*	General single-letter abbreviations (these may not need changed)	*
*-----------------------------------------------------------------------*
*	These messages are limited to 1 character					*
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
* 	Label	=	"*"									*
*-----------------------------------------------------------------------*

RED_abbrev	=	"R"		; RED			(used on slider bars)
GRN_abbrev	=	"G"		; GREEN
BLU_abbrev	=	"B"		; BLUE

CYN_abbrev	=	"C"		; CYAN
MAG_abbrev	=	"M"		; MAGENTA
YEL_abbrev	=	"Y"		; YELLOW

HUE_abbrev	=	"H"		; HUE			(an alternative is HLS
SAT_abbrev	=	"S"		; SATURATION	 or HUE,SATuration &
BRI_abbrev	=	"B"		; BRIGHTNESS	 LUMinance)

FRM_abbrev	=	"F"		; FRAME operator	(used with animation)
SEG_abbrev	=	"S"		; SEGMENT operator
ALL_abbrev	=	"A"		; ALL operator

WID_abbrev	=	"W"		; WIDTH		(for cutting blocks)
HIG_abbrev	=	"H"		; HEIGHT

*-----------------------------------------------------------------------*
*	On-line help messages								*
*-----------------------------------------------------------------------*
*	These messages are limited to 23 characters (including shortcut)	*
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
* 	Label:		dc.b	"********************[*]",0			*
*-----------------------------------------------------------------------*

*-----------------------------------*
*	#1 - Workstation tools		*
*-----------------------------------*

Swap_draw_help:		dc.b	"Standard drawing tools",0
Swap_cell_help:		dc.b	"Cell manipulation tools",0
Swap_colour_help:		dc.b	"Colour workstation",0
Swap_video_help:		dc.b	"Digitising interface",0

				ifnd	preview
Swap_pro_help:		dc.b	"Nonlinear drawing tools",0
Swap_aproc_help:		dc.b	"Film & image filters",0
Swap_morph_help:		dc.b	"Morphing & distortion",0
Swap_text_help:		dc.b	"Text interface",0
Swap_none_help:		dc.b	"Reserved...",0
				elseif
Swap_pro_help:		dc.b	"Reserved...",0
Swap_aproc_help:		dc.b	"Reserved...",0
Swap_morph_help:		dc.b	"Reserved...",0
Swap_text_help:		dc.b	"Reserved...",0
Swap_none_help:		dc.b	"Reserved...",0
				endc

*-----------------------------------*
*	#2 - Drawing tools		*
*-----------------------------------*

Draw_brush_help:		dc.b	"Freehand Draw [D]",0
Draw_line_help:		dc.b	"Line [L]",0
Draw_curve_help:		dc.b	"Curve [K]",0
Draw_polygon_help:	dc.b	"Polygon [W]",0
Draw_circle_help:		dc.b	"Circle [O]",0
Draw_box_help:		dc.b	"Box [B]",0
Draw_fill_help:		dc.b	"Fill tool [F]",0
Draw_airbrush_help:	dc.b	"Airbrush (stipple) [A]",0
Draw_grid_help:		dc.b	"Grid size",0
Draw_exchange_help:	dc.b	"Exchange colour [E]",0

*-----------------------------------*
*	#3 - Cell/block tools		*
*-----------------------------------*

Cell_cut_help:		dc.b	"Manual cut [ESC]",0
Cell_autocut_help:	dc.b	"Automatic cut [TAB]",0
Cell_paste_help:		dc.b	"Paste above image [P]",0
Cell_under_help:		dc.b	"Paste under image [U]",0
Cell_move_help:		dc.b	"Relocate block [M]",0
Cell_invert_help:		dc.b	"Invert X/Y axis [I]",0
Cell_rotate_help:		dc.b	"Rotate block [R]",0
Cell_distort_help:	dc.b	"Perspect block [Y]",0
Cell_rescale_help:	dc.b	"Rescale block [S]",0
Cell_remap_help:		dc.b	"Remap colours [N]",0

*-----------------------------------*
*	#4 - Palette tools		*
*-----------------------------------*

Colour_cut_help:		dc.b	"Cut colours [[]",0
Colour_paste_help:	dc.b	"Paste colours []]",0
Colour_exchange_help:	dc.b	"Swap BG & FG cols [T]",0
Colour_spread_help:	dc.b	"Spread colours [-]",0
Colour_flip_help:		dc.b	"Flip colour range [H]",0
Colour_sort_help:		dc.b	"Sort colours [J]",0
Colour_grey_help:		dc.b	"Grey filter [G]",0

*-----------------------------------*
*	#5 - Video tools			*
*-----------------------------------*

Video_size_help:		dc.b	"Signal options [J]",0
Video_photo_help:		dc.b	"Photographic grab [G]",0
Video_film_help:		dc.b	"Cinematic grab [H]",0
Video_pip_help:		dc.b	"Toggle PiP camera",0

*-----------------------------------*
*	#6 - Professional tools		*
*-----------------------------------*

Pro_go_help:		dc.b	"Go with new options [G]",0
Pro_area_help:		dc.b	"Define area [A]",0
Pro_mask_help:		dc.b	"Analog mask options [M]",0
Pro_options_help:		dc.b	"Ink options [O]",0
Pro_fill_help:		dc.b	"Fill (ink & mask) [F]",0
Pro_brush_help:		dc.b	"Draw (ink & mask) [D]",0
Pro_airbrush_help:	dc.b	"Realistic Airbrush [R]",0

*-----------------------------------*
*	#7 - Anim processing tools	*
*-----------------------------------*

Aproc_go_help:		dc.b	"Go with new options [G]",0
Aproc_area_help:		dc.b	"Define area [A]",0
Aproc_dolby_help:		dc.b	"Noise suppression [N]",0
Aproc_defocus_help:	dc.b	"Motion suppression [D]",0
Aproc_mblur_help:		dc.b	"Anim motion blur [B]",0
Aproc_dejag_help:		dc.b	"Image dejag [J]",0

*-----------------------------------*
*	#8 - Morphing tools		*
*-----------------------------------*

Morph_line_help:		dc.b	"Add warpline [L]",0
Morph_drag_help:		dc.b	"Drag warpline [D]",0
Morph_del_l_help:		dc.b	"Remove warpline [BS]",0
Morph_del_a_help:		dc.b	"Remove all lines [K]",0
Morph_area_help:		dc.b	"Define area [A]",0
Morph_options_help:	dc.b	"Morphing options [O]",0
Morph_go_help:		dc.b	"Go with new options [G]",0

*-----------------------------------*
*	#9 - Calamus CFN tools		*
*-----------------------------------*

Text_type_help:		dc.b	"Text cursor [T]",0
Text_options_help:	dc.b	"Font options [O]",0
Text_clear_help:		dc.b	"Clear font [E]",0

*-----------------------------------*
*	#10 - Standard (fixed) icons	*
*-----------------------------------*

Apex_info_help:		dc.b	"Information & prefs",0
Apex_disk_help:		dc.b	"File operations [RET]",0
Apex_brush_help:		dc.b	"Brush selection [#]",0
Apex_video_help:		dc.b	"Video mode options [V]",0
Apex_quit_help:		dc.b	"Quit [Q] / Swap-out",0
Apex_sys_help:		dc.b	"System information",0

*-----------------------------------*
*	#11 - Animation control		*
*-----------------------------------*

Frame_start_help:		dc.b	"Jump to start [,]",0
Frame_end_help:		dc.b	"Jump to end [.]",0
Frame_left_help:		dc.b	"Back [] / Play []",0
Frame_right_help:		dc.b	"Forward [] / Play []",0
Frame_bar_help:		dc.b	"Frame position slider",0
Frame_left_ins_help:	dc.b	"Insert left",0
Frame_right_ins_help:	dc.b	"Insert right [INS]",0
Frames_delete_help:	dc.b	"Clear [CLR] / Del [DEL]",0
Frame_none_help:		dc.b	"Frame position bar",0

*-----------------------------------*
*	#12 - Extra functions		*
*-----------------------------------*

Time_bar_help:		dc.b	"Playback speed",0
Palette_colours_help:	dc.b	"Colour zone",0
Tween_menu_help:		dc.b	"AMR & Animation",0
Check_draw_window_help:	dc.b	"Current image",0

*-----------------------------------------------------------------------*
*	Additional help messages							*
*-----------------------------------------------------------------------*
*	These messages are limited to 34 characters				* 
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
*	dc.b	27,"Y",0,Tx,Ty+Tg*??,"[*]          *********************"	*
*-----------------------------------------------------------------------*

Apex_help_text:
 dc.b	27,"Y",0,Tx,Ty+Tg*01,"[<]/[>]      Move to start or end"
 dc.b	27,"Y",0,Tx,Ty+Tg*02,"[C]          Pick colour at mouse"
 dc.b	27,"Y",0,Tx,Ty+Tg*03,"[X]          Toggle X-Ray block"
 dc.b	27,"Y",0,Tx,Ty+Tg*04,"[Z]          Zoom in"
 dc.b	27,"Y",0,Tx,Ty+Tg*05,"[\]          Zoom out"
 dc.b	27,"Y",0,Tx,Ty+Tg*06,"[SPACE]      Scroll image to mouse"
 dc.b	27,"Y",0,Tx,Ty+Tg*07,"[UNDO]       Undo changes"
 dc.b	27,"Y",0,Tx,Ty+Tg*08,"[BACKSPACE]  Restore last image"
 dc.b	27,"Y",0,Tx,Ty+Tg*09,"Keypad [.]   Reset all graphics"
 dc.b	27,"Y",0,Tx,Ty+Tg*10,"Keypad [*]   Fit menus to palette"
 dc.b	27,"Y",0,Tx,Ty+Tg*11,"Keypad [0-9] Scroll image"
 dc.b	0

*-----------------------------------------------------------------------*
*	Warning and confirmation dialog text					*
*-----------------------------------------------------------------------*
*	These messages are limited to 26 characters (maybe 27)		* 
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
*	dc.b		27,"Y",0,84,091,"**************************"		*
*	dc.b		27,"Y",0,84,099,"**************************"		*
*-----------------------------------------------------------------------*

OPEN_ERROR_TEXT:
	dc.b		27,"Y",0,84,091,"Error opening file!"
	dc.b		27,"Y",0,84,099,"Cause is uncertain."
	dc.b		0

READ_ERROR_TEXT:
	dc.b		27,"Y",0,84,091,"Error reading file!"
	dc.b		27,"Y",0,84,099,"Disk may be damaged."
	dc.b		0

WRIT_ERROR_TEXT:
	dc.b		27,"Y",0,84,091,"Error writing file!"
	dc.b		27,"Y",0,84,099,"Your disk may be full."
	dc.b		0

MODE_ERROR_TEXT:
	dc.b		27,"Y",0,84,091,"This file format can't be "
	dc.b		27,"Y",0,84,099,"used in this video mode."
	dc.b		0

TYPE_ERROR_TEXT:
	dc.b		27,"Y",0,84,091,"This file is not the right"
	dc.b		27,"Y",0,84,099,"format. Try another type. "
	dc.b		0

SIZE_ERROR_TEXT:
	dc.b		27,"Y",0,84,091,"This file has some unusual"
	dc.b		27,"Y",0,84,099,"characteristics. Go ahead?"
	dc.b		0

NCM_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"You need colour to use the"
	dc.b		27,"Y",0,84,099,"selected operation."
	dc.b		0

NTC_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"This option requires true "
	dc.b		27,"Y",0,84,099,"colour mode to work."
	dc.b		0

NBP_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"This can't be done in true"
	dc.b		27,"Y",0,84,099,"colour mode. 256 cols only."
	dc.b		0

RAM_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"There is not enough memory"
	dc.b		27,"Y",0,84,099,"to complete this operation."
	dc.b		0

DLT_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"You cannot exceed the 40"
	dc.b		27,"Y",0,84,099,"frame animation limit."
	dc.b		0

CFG_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"Something has not been set"
	dc.b		27,"Y",0,84,099,"up - check your manual."
	dc.b		0

*-----------------------------------------------------------------------*
*	Fault reports (these are for bugs and should never occur anyway	*
*-----------------------------------------------------------------------*
*	These messages are limited to 26 characters 				* 
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
*	dc.b		27,"Y",0,84,091,"**************************"		*
*	dc.b		27,"Y",0,84,099,"**************************"		*
*-----------------------------------------------------------------------*

RBR_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*--- Bad handle found ---*"
	dc.b		27,"Y",0,84,099,"*- Resize_block failure -*"
	dc.b		0
RBP_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- Bad pointer found ---*"
	dc.b		27,"Y",0,84,099,"*- Resize_block failure -*"
	dc.b		0

DBR_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*--- Bad handle found ---*"
	dc.b		27,"Y",0,84,099,"*- Delete_block failure -*"
	dc.b		0
DBP_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- Bad pointer found ---*"
	dc.b		27,"Y",0,84,099,"*- Delete_block failure -*"
	dc.b		0

FBR_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*--- Bad handle found ---*"
	dc.b		27,"Y",0,84,099,"*- Locate_block failure -*"
	dc.b		0
FBP_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- Bad pointer found ---*"
	dc.b		27,"Y",0,84,099,"*- Locate_block failure -*"
	dc.b		0

DFR_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- Bad frame ID found --*"
	dc.b		27,"Y",0,84,099,"*- Delete_frame failure -*"
	dc.b		0
BAF_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- No more data slots --*"
	dc.b		27,"Y",0,84,099,"*- RAM Effectively full -*"
	dc.b		0

RBZ_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- Illegal block size --*"
	dc.b		27,"Y",0,84,099,"*- Resize_block failure -*"
	dc.b		0
DBZ_ALERT_TEXT:
	dc.b		27,"Y",0,84,091,"*-- Illegal block size --*"
	dc.b		27,"Y",0,84,099,"*- Delete_block failure -*"
	dc.b		0

*-----------------------------------------------------------------------*
*	Fault reports (these are for bugs and should never occur anyway	*
*-----------------------------------------------------------------------*
*	These messages are limited to 27 characters 				* 
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
*	dc.b		27,"Y",0,80,89+2,"***************************"		*
*	dc.b		27,"Y",0,80,97+2,"***************************"		*
*-----------------------------------------------------------------------*

vidask_text:	dc.b	27,"Y",0,80,89+2,"A resolution change will   "
			dc.b	27,"Y",0,80,97+2,"destroy all unsaved work..."
			dc.b	0
resask_text:	dc.b	27,"Y",0,80,89+2,"This operation will remove "
			dc.b	27,"Y",0,80,97+2,"any graphics from memory..."
			dc.b	0
sleepask_text:	dc.b	27,"Y",0,80,89+2,"Ensure that the memory CPX "
			dc.b	27,"Y",0,80,97+2,"is configured before using!"
			dc.b	0
quitask_text:	dc.b	27,"Y",0,80,93+2,"Do you really wish to quit?"
			dc.b	0
aboask_text:	dc.b	27,"Y",0,80,89+2,"Process interrupted... "
			dc.b	27,"Y",0,80,97+2,"Do you really wish to stop?"
			dc.b	0
segask_text:	dc.b	27,"Y",0,80,89+2,"Do you wish to do this over"
			dc.b	27,"Y",0,80,97+2,"a selected group of frames?"
			dc.b	0
allask_text:	dc.b	27,"Y",0,80,89+2,"Do you wish to do this over"
			dc.b	27,"Y",0,80,97+2,"all the available frames?  "
			dc.b	0
buserr_text:	dc.b	27,"Y",0,80,89+2,"Apex has just experienced a"
			dc.b	27,"Y",0,80,97+2,"crash. Save up and exit... "
			dc.b	0

*-----------------------------------------------------------------------*
*	General spot-messages (covers various areas)				*
*-----------------------------------------------------------------------*
*	These are very specific, and limits will be noted individually	*
*-----------------------------------------------------------------------*
*	Approximate layout:								*
*-----------------------------------------------------------------------*
*	You will have to use your own judgement!					*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*	Try to keep these under 28 characters!					*
*-----------------------------------------------------------------------*

readfile_text:
	dc.b		"READING FILE:",0
writefile_text:
	dc.b		"WRITING FILE:",0
rescale_text:
	dc.b		"RESIZING IMAGE:",0
dither_text:
	dc.b		"DITHERING PIXELS:",0
remap_text:
	dc.b		"TRANSFORMING SIZE & FORMAT:",0
mipmap_text:
	dc.b		"SUPERSAMPLING:",0
extract_text:
	dc.b		"EXTRACTING NEW PALETTE:",0
	even

*-----------------------------------------------------------------------*
*	Try to keep these very short.							*
*-----------------------------------------------------------------------*

KBYTES:		dc.b	'K Bytes.',0
FTEXT:		dc.b	'Frame',0
SEPARATOR:		dc.b	' of ',0
			even
			
*-----------------------------------------------------------------------*
*	Try to keep these under 20 characters.					*
*-----------------------------------------------------------------------*

SELECTOR_MLOAD:	dc.b	"Load file...",0
SELECTOR_MSAVE:	dc.b	"Save file...",0
			even

*-----------------------------------------------------------------------*
*	Keep these under 18 characters.						*
*-----------------------------------------------------------------------*

font_text:		dc.b	27,"Y",0,86,88+14*0,"Relative size"
			dc.b	27,"Y",0,86,88+14*1,"Character spacing"
			dc.b	27,"Y",0,86,88+14*2,"Curve smoothness"
			dc.b	0

status_text:	dc.b	27,"Y",0,80,89+2,"Used memory:"
			dc.b	27,"Y",0,80,97+2,"Free memory:"
			dc.b	0

*-----------------------------------------------------------------------*
*	Keep this under 9 characters.							*
*-----------------------------------------------------------------------*

video_text:		dc.b	27,"Y",0,48+3+32-22-2,140-34+16-6-7+5,"Width:"
			dc.b	27,"Y",0,48+3+32-22-2,154-34+16+6-7+5,"Height:"
			dc.b	0

*-----------------------------------------------------------------------*
*	This appears on the TOS screen, just keep it under 40 characters	*
*	per line, with each line ending in 13,10 for a line-feed...		*
*-----------------------------------------------------------------------*

merr_text:		dc.b	27,'E',27,'f',13,10
			dc.b	" You need to release more RAM!",13,10,13,10
			dc.b	" Press space to exit...",0
			even

*-----------------------------------------------------------------------*
*	Probably best not to edit these - just supply a translation!	*
*-----------------------------------------------------------------------*

apex_alert:
		dc.b	"[0][ "
		ifd	cutdown
		dc.b	"|"," Apex Animator Intro "
		elseif
		dc.b  "|","    Apex Animator "
		endc
		version
		dc.b	"    "
		dc.b	"|","  for the Atari Falcon030  "
		dc.b	"| "
		dc.b	"|","  (C) 1995 Black Scorpion   "
		dc.b	" ]"
		dc.b	"[ Ok ]",0
_s0		dc.b	" Desk ",0
_s1		dc.b	" Program ",0
_s2		dc.b	"  Information...  ",0
_s10		dc.b	" Return to Apex ",0
		even
		
*-----------------------------------------------------------------------*
