*-----------------------------------------------------------------------*
*       Apex program-text.       Dated: 1/9/94                          *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*       Rules for translation: (set tabs to 6)                          *
*-----------------------------------------------------------------------*
*       Each chunk of text will start with a guide contained in a starry*
*       box like this one. The part named 'Approximate layout' shows    *
*       shich bits of the text (denoted by stars) can be changed        *
*       Generally, everything INSIDE quotes "" is alterable, while all  *
*       else is part of the program and is not to be changed.           *
*-----------------------------------------------------------------------*


*-----------------------------------------------------------------------*
*       General single-letter abbreviations (these may not need changed)*
*-----------------------------------------------------------------------*
*       These messages are limited to 1 character                       *
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       Label   =       "*"                                             *
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

WID_abbrev      =       "W"             ; WIDTH         (for cutting blocks)
HIG_abbrev      =       "H"             ; HEIGHT

*-----------------------------------------------------------------------*
*       On-line help messages                                           *
*-----------------------------------------------------------------------*
*       These messages are limited to 23 characters (including shortcut)*
*       Do not change the single character enclosed within [ ]          *
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       Label:          dc.b    "********************[*]",0             *
*-----------------------------------------------------------------------*

*-----------------------------------*
*       #1 - Workstation tools      *
*-----------------------------------*

Swap_draw_help:         dc.b    "Outils de dessin",0
Swap_cell_help:         dc.b    "Manipulation de Cellules",0
Swap_colour_help:       dc.b    "Station de couleurs",0
Swap_video_help:        dc.b    "Interface Num‚risation",0

                ifnd    preview
Swap_pro_help:          dc.b    "Outils non-lin‚aires",0
Swap_aproc_help:        dc.b    "Filtres: Films & images",0
Swap_morph_help:        dc.b    "Morphing & distorsion",0
Swap_text_help:         dc.b    "Interface Texte",0
Swap_none_help:         dc.b    "R‚serv‚...",0
                elseif
Swap_pro_help:          dc.b    "R‚serv‚...",0
Swap_aproc_help:        dc.b    "R‚serv‚...",0
Swap_morph_help:        dc.b    "R‚serv‚...",0
Swap_text_help:         dc.b    "R‚serv‚...",0
Swap_none_help:         dc.b    "R‚serv‚...",0
                endc

*-----------------------------------*
*       #2 - Drawing tools          *
*-----------------------------------*

Draw_brush_help:        dc.b    "Dessin … main lev‚e [D]",0
Draw_line_help:         dc.b    "Ligne [L]",0
Draw_curve_help:        dc.b    "Courbe [K]",0
Draw_polygon_help:      dc.b    "Polygone [W]",0
Draw_circle_help:       dc.b    "Cercle [O]",0
Draw_box_help:          dc.b    "BoŒte [B]",0
Draw_fill_help:         dc.b    "Remplissage [F]",0
Draw_airbrush_help:     dc.b    "A‚rosol [A]",0
Draw_grid_help:         dc.b    "Taille Grille",0
Draw_exchange_help:     dc.b    "Echange couleur [E]",0

*-----------------------------------*
*       #3 - Cell/block tools       *
*-----------------------------------*

Cell_cut_help:          dc.b    "Couper manuel [ESC]",0
Cell_autocut_help:      dc.b    "Couper Automatique[TAB]",0
Cell_paste_help:        dc.b    "Coller sur l'image [P]",0
Cell_under_help:        dc.b    "Coller sous l'image [U]",0
Cell_move_help:         dc.b    "Relocate block [M]",0
Cell_invert_help:       dc.b    "Inverser axes X/Y [I]",0
Cell_rotate_help:       dc.b    "Rotation bloc [R]",0
Cell_distort_help:      dc.b    "Bloc en Perspective [Y]",0
Cell_rescale_help:      dc.b    "Redimensionner bloc [S]",0
Cell_remap_help:        dc.b    "R‚organiser Couleurs [N]",0

*-----------------------------------*
*       #4 - Palette tools          *
*-----------------------------------*

Colour_cut_help:        dc.b    "Couper couleurs [[]",0
Colour_paste_help:      dc.b    "Coller couleurs []]",0
Colour_exchange_help:   dc.b    "Echanger Fond/Encre [T]",0
Colour_spread_help:     dc.b    "R‚pandre couleurs [-]",0
Colour_flip_help:       dc.b    "Inverser gamme coul [H]",0
Colour_sort_help:       dc.b    "Trier les couleurs [J]",0
Colour_grey_help:       dc.b    "Filtre gris [G]",0

*-----------------------------------*
*       #5 - Video tools            *
*-----------------------------------*

Video_size_help:        dc.b    "Options des Signaux [J]",0
Video_photo_help:       dc.b    "Capture Photo [G]",0
Video_film_help:        dc.b    "Capture Cin‚ma [H]",0
Video_pip_help:         dc.b    "PiP Cam‚ra ON/OFF",0

*-----------------------------------*
*       #6 - Professional tools     *
*-----------------------------------*

Pro_go_help:            dc.b    "Ex‚cuter travaux [G]",0
Pro_area_help:          dc.b    "D‚finir surface [A]",0
Pro_mask_help:          dc.b    "Masque Analogique [M]",0
Pro_options_help:       dc.b    "Options d'encre [O]",0
Pro_fill_help:          dc.b    "Remplir (ink+mask) [F]",0
Pro_brush_help:         dc.b    "Dessin (ink+mask) [D]",0
Pro_airbrush_help:      dc.b    "A‚rosol R‚aliste [R]",0

*-----------------------------------*
*       #7 - Anim processing tools  *
*-----------------------------------*

Aproc_go_help:          dc.b    "Ex‚cuter travaux [G]",0
Aproc_area_help:        dc.b    "D‚finir surface [A]",0
Aproc_dolby_help:       dc.b    "Suppression Bruit [N]",0
Aproc_defocus_help:     dc.b    "Suppression Mvt [D]",0
Aproc_mblur_help:       dc.b    "Flou de mouvement [B]",0
Aproc_dejag_help:       dc.b    "Image dejag [J]",0

*-----------------------------------*
*       #8 - Morphing tools         *
*-----------------------------------*

Morph_line_help:        dc.b    "Ajoute warpline [L]",0
Morph_drag_help:        dc.b    "D‚place warpline [D]",0
Morph_del_l_help:       dc.b    "EnlŠve warpline [BS]",0
Morph_del_a_help:       dc.b    "Supprime tts lignes [K]",0
Morph_area_help:        dc.b    "D‚finir Surface [A]",0
Morph_options_help:     dc.b    "Options de Morphing [O]",0
Morph_go_help:          dc.b    "Ex‚cuter travaux [G]",0

*-----------------------------------*
*       #9 - Calamus CFN tools      *
*-----------------------------------*

Text_type_help:         dc.b    "Curseur Texte [T]",0
Text_options_help:      dc.b    "Options Polices [O]",0
Text_clear_help:        dc.b    "Effacer Police [E]",0

*-----------------------------------*
*       #10 - Standard (fixed) icons*
*-----------------------------------*

Apex_info_help:         dc.b    "Information & prefs",0
Apex_disk_help:         dc.b    "Fonctions Fichiers[RET]",0
Apex_brush_help:        dc.b    "S‚lection Brosse [#]",0
Apex_video_help:        dc.b    "Options Mode Vid‚o [V]",0
Apex_quit_help:         dc.b    "Quitter [Q] / Bureau",0
Apex_sys_help:          dc.b    "Informations SystŠme",0

*-----------------------------------*
*       #11 - Animation control     *
*-----------------------------------*

Frame_start_help:       dc.b    "Saute au D‚but [,]",0
Frame_end_help:         dc.b    "Saute en Fin [.]",0
Frame_left_help:        dc.b    "Retour [] / Jouer []",0
Frame_right_help:       dc.b    "Avance [] / Jouer []",0
Frame_bar_help:         dc.b    "Ascenceur Animation",0
Frame_left_ins_help:    dc.b    "Ins‚rer … Gauche",0
Frame_right_ins_help:   dc.b    "Ins‚rer … Droite [INS]",0
Frames_delete_help:     dc.b    "Eff. [CLR] / Supp. [DEL]",0
Frame_none_help:        dc.b    "Barre d'animation",0

*-----------------------------------*
*       #12 - Extra functions       *
*-----------------------------------*

Time_bar_help:          dc.b    "Vitesse de Reproduction",0
Palette_colours_help:   dc.b    "Zone Couleur",0
Tween_menu_help:        dc.b    "AMR & Animation",0
Check_draw_window_help: dc.b    "Image Courante",0

*-----------------------------------------------------------------------*
*       Additional help messages                                        *
*-----------------------------------------------------------------------*
*       These messages are limited to 34 characters                     * 
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       dc.b  27,"Y",0,Tx,Ty+Tg*??,"[*]          *********************" *
*-----------------------------------------------------------------------*

Apex_help_text:
 dc.b   27,"Y",0,Tx,Ty+Tg*01,"[,]/[.]      Aller en D‚but/Fin"
 dc.b   27,"Y",0,Tx,Ty+Tg*02,"[C]          Couleur sous souris"
 dc.b   27,"Y",0,Tx,Ty+Tg*03,"[X]          Bloc X-Ray On/Off"
 dc.b   27,"Y",0,Tx,Ty+Tg*04,"[Z]          Zoom in"
 dc.b   27,"Y",0,Tx,Ty+Tg*05,"[\]          Zoom out"
 dc.b   27,"Y",0,Tx,Ty+Tg*06,"[SPACE]      Centrer image/souris"
 dc.b   27,"Y",0,Tx,Ty+Tg*07,"[UNDO]       Annule changements"
 dc.b   27,"Y",0,Tx,Ty+Tg*08,"[BACKSPACE]  Restaure pr‚c‚dente"
 dc.b   27,"Y",0,Tx,Ty+Tg*09,"Keypad [.]   Reset tous graphiques"
 dc.b   27,"Y",0,Tx,Ty+Tg*10,"Keypad [*]   Met menus en palette"
 dc.b   27,"Y",0,Tx,Ty+Tg*11,"Keypad [0-9] D‚place l'image"
 dc.b   0

*-----------------------------------------------------------------------*
*       Warning and confirmation dialog text                            *
*-----------------------------------------------------------------------*
*       These messages are limited to 26 characters (maybe 27)          * 
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       dc.b            27,"Y",0,84,091,"**************************"    *
*       dc.b            27,"Y",0,84,099,"**************************"    *
*-----------------------------------------------------------------------*

OPEN_ERROR_TEXT:
    dc.b            27,"Y",0,84,091,"Erreur ouverture fichier!"
    dc.b            27,"Y",0,84,099,"Cause incertaine."
    dc.b            0

READ_ERROR_TEXT:
    dc.b            27,"Y",0,84,091,"Erreur lecture fichier!"
    dc.b            27,"Y",0,84,099,"Disque endommag‚."
    dc.b            0

WRIT_ERROR_TEXT:
    dc.b            27,"Y",0,84,091,"Erreur ‚criture fichier!"
    dc.b            27,"Y",0,84,099,"Disque plein."
    dc.b            0

MODE_ERROR_TEXT:
    dc.b            27,"Y",0,84,091,"Format de fichier non"
    dc.b            27,"Y",0,84,099,"compatible avec mode vid‚o"
    dc.b            0

TYPE_ERROR_TEXT:
    dc.b            27,"Y",0,84,091,"Ce fichier n'est pas dans"
    dc.b            27,"Y",0,84,099,"le bon format."
    dc.b            0

SIZE_ERROR_TEXT:
    dc.b            27,"Y",0,84,091,"Les caract‚ristiques sont"
    dc.b            27,"Y",0,84,099,"inhabituelles. Essayer?"
    dc.b            0

NCM_ALERT_TEXT:
    dc.b            27,"Y",0,84,091,"Vous avez besoin d'une"
    dc.b            27,"Y",0,84,099,"couleur pour l'op‚ration."
    dc.b            0

NTC_ALERT_TEXT:
    dc.b            27,"Y",0,84,091,"Cette option n‚cessite le"
    dc.b            27,"Y",0,84,099,"mode TrueColour."
    dc.b            0

NBP_ALERT_TEXT:
    dc.b            27,"Y",0,84,091,"Ne peut ˆtre r‚alis‚ en"
    dc.b            27,"Y",0,84,099,"TrueColour. Passez en 256."
    dc.b            0

RAM_ALERT_TEXT:
    dc.b            27,"Y",0,84,091,"Pas assez de m‚moire pour"
    dc.b            27,"Y",0,84,099,"r‚aliser cette op‚ration."
    dc.b            0

DLT_ALERT_TEXT:
    dc.b            27,"Y",0,84,091,"Impossible de d‚passer"
    dc.b            27,"Y",0,84,099,"la limite des 40 images."
    dc.b            0

CFG_ALERT_TEXT:
    dc.b            27,"Y",0,84,091,"Quelque chose n'a pas ‚t‚"
    dc.b            27,"Y",0,84,099,"d‚fini. Cf Manuel."
    dc.b            0

*-----------------------------------------------------------------------*
*       Fault reports (these are for bugs and should never occur anyway *
*-----------------------------------------------------------------------*
*       These messages are limited to 26 characters                     * 
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       dc.b            27,"Y",0,84,091,"**************************"    *
*       dc.b            27,"Y",0,84,099,"**************************"    *
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
*       These messages are limited to 27 characters                     * 
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       dc.b            27,"Y",0,80,89+2,"***************************"  *
*       dc.b            27,"Y",0,80,97+2,"***************************"  *
*-----------------------------------------------------------------------*

vidask_text:   	dc.b    27,"Y",0,80,89+2,"Le changement de r‚solution"
            	dc.b    27,"Y",0,80,97+2,"d‚truira TOUS les travaux!"
            	dc.b    0
resask_text:    	dc.b    27,"Y",0,80,89+2,"Cette op‚ration efface"
           		dc.b    27,"Y",0,80,97+2,"les graphismes en m‚moire!"
           		dc.b    0
sleepask_text: 	dc.b    27,"Y",0,80,89+2,"V‚rifiez que le CPX M‚moire"
            	dc.b    27,"Y",0,80,97+2,"est bien configur‚!"
            	dc.b    0
quitask_text:	dc.b    27,"Y",0,80,93+2,"Voulez-vous QUITTER?"
            	dc.b    0
aboask_text:	dc.b    27,"Y",0,80,89+2,"Processus interrompu... "
           		dc.b    27,"Y",0,80,97+2,"Voulez-vous STOPPER?"
           		dc.b    0
segask_text:	dc.b    27,"Y",0,80,89+2,"R‚percuter la fonction"
         		dc.b    27,"Y",0,80,97+2,"sur le groupe d'images?"
          		dc.b    0
allask_text:   	dc.b    27,"Y",0,80,89+2,"R‚percuter la fonction"
            	dc.b    27,"Y",0,80,97+2,"sur toutes les images?  "
            	dc.b    0
buserr_text:	dc.b    27,"Y",0,80,89+2,"Apex vient de vivre un"
            	dc.b    27,"Y",0,80,97+2,"CRASH. Sauvez et QUITTEZ!"
            	dc.b    0

*-----------------------------------------------------------------------*
*       General spot-messages (covers various areas)                    *
*-----------------------------------------------------------------------*
*       These are very specific, and limits will be noted individually  *
*-----------------------------------------------------------------------*
*       Approximate layout:                                             *
*-----------------------------------------------------------------------*
*       You will have to use your own judgement!                        *
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*       Try to keep these under 28 characters!                          *
*-----------------------------------------------------------------------*

readfile_text:
    dc.b            "LECTURE FICHIER:",0
writefile_text:
    dc.b            "ECRITURE FICHIER:",0
rescale_text:
    dc.b            "REDIMENSIONNEMENT:",0
dither_text:
    dc.b            "TRAMAGE PIXELS:",0
remap_text:
    dc.b            "TRANSFORME TAILLE & FORMAT:",0
mipmap_text:
    dc.b            "SUPERSAMPLING:",0
extract_text:
    dc.b            "EXTRAIT NOUVELLE PALETTE:",0
    even

*-----------------------------------------------------------------------*
*       Try to keep these very short.                                   *
*-----------------------------------------------------------------------*

KBYTES:     dc.b    'K Octets.',0
FTEXT:      dc.b    'Image',0
SEPARATOR:      dc.b    ' de ',0
            even
            
*-----------------------------------------------------------------------*
*       Try to keep these under 20 characters.                          *
*-----------------------------------------------------------------------*

SELECTOR_MLOAD: dc.b    "Charge fichier...",0
SELECTOR_MSAVE: dc.b    "Sauver fichier...",0
            even

*-----------------------------------------------------------------------*
*       Keep these under 18 characters.                                 *
*-----------------------------------------------------------------------*

font_text:      dc.b    27,"Y",0,86,88+14*0,"Taille Relative"
            dc.b    27,"Y",0,86,88+14*1,"Espace caractŠres"
            dc.b    27,"Y",0,86,88+14*2,"Douceur Courbes"
            dc.b    0

status_text:    dc.b    27,"Y",0,80,89+2,"Utilis‚e:"
            dc.b    27,"Y",0,80,97+2,"Libre:"
            dc.b    0

*-----------------------------------------------------------------------*
*       Keep this under 9 characters.                                   *
*-----------------------------------------------------------------------*

video_text:     dc.b    27,"Y",0,48+3+32-22-2,140-34+16-6-7+5,"Largeur:"
            dc.b    27,"Y",0,48+3+32-22-2,154-34+16+6-7+5,"Hauteur:"
            dc.b    0

*-----------------------------------------------------------------------*
*       This appears on the TOS screen, just keep it under 40 characters*
*       per line, with each line ending in 13,10 for a line-feed...     *
*-----------------------------------------------------------------------*

merr_text:      dc.b    27,'E',27,'f',13,10
            dc.b    " Vous avez besoin de plus de RAM!",13,10,13,10
            dc.b    " Espace pour sortir...",0
            even

*-----------------------------------------------------------------------*
*       Probably best not to edit these - just supply a translation!    *
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
	dc.b    "|","  pour l' Atari Falcon030  "
	dc.b    "| "
	dc.b    "|","  (C) 1995 Black Scorpion   "
	dc.b    " ]"
	dc.b    "[ Ok ]",0
_s0	dc.b    " GEM ",0
_s1	dc.b    " Apex ",0
_s2	dc.b    "  Informations...  ",0
_s10	dc.b    " Retour … Apex ",0
      even
        
*-----------------------------------------------------------------------*
