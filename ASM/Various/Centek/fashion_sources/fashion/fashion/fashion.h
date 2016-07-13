/* Indice du ressource pour FASHION */

#define MENU     0   /* Arbre menu */
#define M_INFO   9   /* STRING dans l'arbre MENU */
#define M_Z_LIB  18  /* STRING dans l'arbre MENU */
#define M_NEW    20  /* STRING dans l'arbre MENU */
#define M_OPEN   21  /* STRING dans l'arbre MENU */
#define M_SAUVE  22  /* STRING dans l'arbre MENU */
#define M_EXPORT 25  /* STRING dans l'arbre MENU */
#define M_QUIT   27  /* STRING dans l'arbre MENU */
#define M_DELETE 31  /* STRING dans l'arbre MENU */
#define M_ARBRE  33  /* STRING dans l'arbre MENU */
#define M_OGRILLE 35  /* STRING dans l'arbre MENU */
#define M_GRILLE 36  /* STRING dans l'arbre MENU */
#define M_HELP   39  /* STRING dans l'arbre MENU */
#define M_MAIN   40  /* STRING dans l'arbre MENU */
#define M_TOOLBOX 41  /* STRING dans l'arbre MENU */
#define M_PREF   42  /* STRING dans l'arbre MENU */

#define INFO     1   /* Formulaire/Dialogue */

#define MAIN     2   /* Formulaire/Dialogue */
#define MAIN_FLAG 1   /* USERDEF dans l'arbre MAIN */
#define MAIN_COLOR 2   /* USERDEF dans l'arbre MAIN */
#define MAIN_FONTE 3   /* USERDEF dans l'arbre MAIN */
#define MAIN_FLECHE 4   /* USERDEF dans l'arbre MAIN */
#define MAIN_CORDS 7   /* IBOX dans l'arbre MAIN */
#define MAIN_XPOSROOT 8   /* STRING dans l'arbre MAIN */
#define MAIN_WPOS 9   /* STRING dans l'arbre MAIN */
#define MAIN_YPOSROOT 11  /* STRING dans l'arbre MAIN */
#define MAIN_HPOS 12  /* STRING dans l'arbre MAIN */
#define MAIN_XPOSREL 13  /* STRING dans l'arbre MAIN */
#define MAIN_YPOSREL 14  /* STRING dans l'arbre MAIN */
#define MAIN_NUMOBJ 17  /* STRING dans l'arbre MAIN */
#define MAIN_OBTYPE 19  /* STRING dans l'arbre MAIN */

#define ENTER_NAME 3   /* Formulaire/Dialogue */
#define RB_DIALOG 2   /* USERDEF dans l'arbre ENTER_NAME */
#define RB_MENU  3   /* USERDEF dans l'arbre ENTER_NAME */
#define RB_ALERT 4   /* USERDEF dans l'arbre ENTER_NAME */
#define RB_STRING 5   /* USERDEF dans l'arbre ENTER_NAME */
#define RB_IMAGE 6   /* USERDEF dans l'arbre ENTER_NAME */
#define ENTER_NAME_OK 7   /* BUTTON dans l'arbre ENTER_NAME */
#define ED_ARBRE_LABEL 8   /* FTEXT dans l'arbre ENTER_NAME */

#define FLAG     4   /* Formulaire/Dialogue */
#define FLAG_0   3   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_1   4   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_2   5   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_3   6   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_4   7   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_5   8   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_6   9   /* BOXTEXT dans l'arbre FLAG */
#define FLAG_7   10  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_8   11  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_9   12  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_10  13  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_11  14  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_12  15  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_13  16  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_14  17  /* BOXTEXT dans l'arbre FLAG */
#define FLAG_15  18  /* BOXTEXT dans l'arbre FLAG */
#define STATE_0  21  /* BOXTEXT dans l'arbre FLAG */
#define STATE_1  22  /* BOXTEXT dans l'arbre FLAG */
#define STATE_2  23  /* BOXTEXT dans l'arbre FLAG */
#define STATE_3  24  /* BOXTEXT dans l'arbre FLAG */
#define STATE_4  25  /* BOXTEXT dans l'arbre FLAG */
#define STATE_5  26  /* BOXTEXT dans l'arbre FLAG */
#define STATE_6  27  /* BOXTEXT dans l'arbre FLAG */
#define STATE_7  28  /* BOXTEXT dans l'arbre FLAG */
#define STATE_8  29  /* BOXTEXT dans l'arbre FLAG */
#define STATE_9  30  /* BOXTEXT dans l'arbre FLAG */
#define STATE_10 31  /* BOXTEXT dans l'arbre FLAG */
#define STATE_11 32  /* BOXTEXT dans l'arbre FLAG */
#define STATE_12 33  /* BOXTEXT dans l'arbre FLAG */
#define STATE_13 34  /* BOXTEXT dans l'arbre FLAG */
#define STATE_14 35  /* BOXTEXT dans l'arbre FLAG */
#define STATE_15 36  /* BOXTEXT dans l'arbre FLAG */

#define WAIT     5   /* Formulaire/Dialogue */
#define WAIT_BOX 1   /* BOX dans l'arbre WAIT */
#define WAIT_BAR 2   /* BOX dans l'arbre WAIT */
#define WAIT_TXT1 3   /* TEXT dans l'arbre WAIT */
#define WAIT_TXT2 4   /* TEXT dans l'arbre WAIT */
#define WAIT_TXT3 5   /* TEXT dans l'arbre WAIT */

#define Z_LIB_INFO 6   /* Formulaire/Dialogue */

#define EDIT     7   /* Formulaire/Dialogue */
#define EDIT_EDIT 1   /* FTEXT dans l'arbre EDIT */

#define NEW_DIAL_DEFAULT 8   /* Formulaire/Dialogue */

#define ARBRE    9   /* Formulaire/Dialogue */

#define PREF     10  /* Formulaire/Dialogue */
#define PREF_B_ASM 3   /* USERDEF dans l'arbre PREF */
#define PREF_T_ASM 4   /* TEXT dans l'arbre PREF */
#define PREF_B_C 5   /* USERDEF dans l'arbre PREF */
#define PREF_T_C 6   /* TEXT dans l'arbre PREF */
#define PREF_B_GFA 7   /* USERDEF dans l'arbre PREF */
#define PREF_T_GFA 8   /* TEXT dans l'arbre PREF */
#define PREF_B_PBASIC 9   /* USERDEF dans l'arbre PREF */
#define PREF_T_PBASIC 10  /* TEXT dans l'arbre PREF */
#define PREF_B_HRD 11  /* USERDEF dans l'arbre PREF */
#define PREF_T_HRD 12  /* TEXT dans l'arbre PREF */
#define PREF_B_CUSTOM 13  /* USERDEF dans l'arbre PREF */
#define PREF_T1_COPY 17  /* TEXT dans l'arbre PREF */
#define PREF_T2_COPY 18  /* TEXT dans l'arbre PREF */
#define PREF_GRIDX 28  /* FBOXTEXT dans l'arbre PREF */
#define PREF_GRIDY 31  /* FBOXTEXT dans l'arbre PREF */
#define PREF_CUS_FRMT 49  /* FBOXTEXT dans l'arbre PREF */
#define PREF_CUS_EXT 52  /* FBOXTEXT dans l'arbre PREF */

#define TEDINFO_EDIT 11  /* Formulaire/Dialogue */
#define TED_PETIT 2   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_GRAND 3   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_MOYEN 4   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_GDOS 5   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_SIZE 6   /* BUTTON dans l'arbre TEDINFO_EDIT */
#define TED_GAUCHE 9   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_CENTRE 10  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_DROITE 11  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_JUSTIF 12  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_FONTLIST 14  /* BOX dans l'arbre TEDINFO_EDIT */
#define TED_UP   15  /* BOXCHAR dans l'arbre TEDINFO_EDIT */
#define TED_DOWN 16  /* BOXCHAR dans l'arbre TEDINFO_EDIT */
#define TED_SLIDEBOX 17  /* BOX dans l'arbre TEDINFO_EDIT */
#define TED_SLIDE 18  /* BOXCHAR dans l'arbre TEDINFO_EDIT */
#define TED_GRAS 21  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_LIGHT 23  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_SOULIGNE 25  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_DETOURE 27  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_ITALIC 30  /* BOXTEXT dans l'arbre TEDINFO_EDIT */
#define TED_OMBRE 32  /* BOXTEXT dans l'arbre TEDINFO_EDIT */

#define OBJC_COLOR_WORD 12  /* Formulaire/Dialogue */
#define CW_TXTBOX 4   /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT0  5   /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT1  6   /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT2  7   /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT3  8   /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT4  9   /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT5  10  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT6  11  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT7  12  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT8  13  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT9  14  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT10 15  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT11 16  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT12 17  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT13 18  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT14 19  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TXT15 20  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_CADREBOX 21  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_CADRE0 22  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_CADRE15 37  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_FONDBOX 38  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_FOND0 39  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_FOND15 54  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_OPAQUE 56  /* BOXTEXT dans l'arbre OBJC_COLOR_WORD */
#define CW_TRAMEBOX 57  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TRAME0 58  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_TRAME7 65  /* BOX dans l'arbre OBJC_COLOR_WORD */
#define CW_PLUS  67  /* BOXTEXT dans l'arbre OBJC_COLOR_WORD */
#define CW_MOINS 69  /* BOXTEXT dans l'arbre OBJC_COLOR_WORD */

#define POPUP    13  /* Formulaire/Dialogue */
#define POPUP_CADRE_SIZE 1   /* BOX dans l'arbre POPUP */
#define POP_M16  2   /* STRING dans l'arbre POPUP */
#define POP_M15  3   /* STRING dans l'arbre POPUP */
#define POP_M14  4   /* STRING dans l'arbre POPUP */
#define POP_M13  5   /* STRING dans l'arbre POPUP */
#define POP_M12  6   /* STRING dans l'arbre POPUP */
#define POP_M11  7   /* STRING dans l'arbre POPUP */
#define POP_M10  8   /* STRING dans l'arbre POPUP */
#define POP_M9   9   /* STRING dans l'arbre POPUP */
#define POP_M8   10  /* STRING dans l'arbre POPUP */
#define POP_M7   11  /* STRING dans l'arbre POPUP */
#define POP_M6   12  /* STRING dans l'arbre POPUP */
#define POP_M5   13  /* STRING dans l'arbre POPUP */
#define POP_M4   14  /* STRING dans l'arbre POPUP */
#define POP_M3   15  /* STRING dans l'arbre POPUP */
#define POP_M2   16  /* STRING dans l'arbre POPUP */
#define POP_M1   17  /* STRING dans l'arbre POPUP */
#define POP_0    18  /* STRING dans l'arbre POPUP */
#define POP_P1   19  /* STRING dans l'arbre POPUP */
#define POP_P2   20  /* STRING dans l'arbre POPUP */
#define POP_P3   21  /* STRING dans l'arbre POPUP */
#define POP_P4   22  /* STRING dans l'arbre POPUP */
#define POP_P5   23  /* STRING dans l'arbre POPUP */
#define POP_P6   24  /* STRING dans l'arbre POPUP */
#define POP_P7   25  /* STRING dans l'arbre POPUP */
#define POP_P8   26  /* STRING dans l'arbre POPUP */
#define POP_P9   27  /* STRING dans l'arbre POPUP */
#define POP_P10  28  /* STRING dans l'arbre POPUP */
#define POP_P11  29  /* STRING dans l'arbre POPUP */
#define POP_P12  30  /* STRING dans l'arbre POPUP */
#define POP_P13  31  /* STRING dans l'arbre POPUP */
#define POP_P14  32  /* STRING dans l'arbre POPUP */
#define POP_P15  33  /* STRING dans l'arbre POPUP */
#define POP_P16  34  /* STRING dans l'arbre POPUP */
#define POPUP_FNTSIZE 53  /* BUTTON dans l'arbre POPUP */
#define POPUP_OBTYPE 105 /* BOX dans l'arbre POPUP */
#define PP_G_BOX 106 /* STRING dans l'arbre POPUP */
#define PP_G_TEXT 107 /* STRING dans l'arbre POPUP */
#define PP_G_BOXTEXT 108 /* STRING dans l'arbre POPUP */
#define PP_G_IMAGE 109 /* STRING dans l'arbre POPUP */
#define PP_G_PROGDEF 110 /* STRING dans l'arbre POPUP */
#define PP_G_IBOX 111 /* STRING dans l'arbre POPUP */
#define PP_G_BUTTON 112 /* STRING dans l'arbre POPUP */
#define PP_G_BOXCHAR 113 /* STRING dans l'arbre POPUP */
#define PP_G_STRING 114 /* STRING dans l'arbre POPUP */
#define PP_G_FTEXT 115 /* STRING dans l'arbre POPUP */
#define PP_G_FBOXTEXT 116 /* STRING dans l'arbre POPUP */
#define PP_G_ICON 117 /* STRING dans l'arbre POPUP */
#define PP_G_TITTLE 118 /* STRING dans l'arbre POPUP */
#define PP_G_CICON 119 /* STRING dans l'arbre POPUP */
#define PP_G_BOUNDING 120 /* STRING dans l'arbre POPUP */
#define PP_G_BOUNDED 121 /* STRING dans l'arbre POPUP */
#define PP_G_PIX 122 /* STRING dans l'arbre POPUP */
#define PP_G_LINE 123 /* STRING dans l'arbre POPUP */

#define COLOR_ICN 14  /* Formulaire/Dialogue */

#define LABEL    15  /* Formulaire/Dialogue */
#define LABEL_HIDALLTXT 1   /* BOX dans l'arbre LABEL */
#define LABEL_PVALID 4   /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_PTMPLT 7   /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_PVALID_TTL 8   /* BOXTEXT dans l'arbre LABEL */
#define LABEL_PTMPLT_TTL 9   /* BOXTEXT dans l'arbre LABEL */
#define LABEL_PTEXT 12  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_PTEXT_TTL 13  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_LABEL_TTL 15  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_LABEL 18  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_COMMENT_TT 19  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_COMMENT 22  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_OBTYPE 25  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_POP_OBTYPE 27  /* BUTTON dans l'arbre LABEL */
#define LABEL_APPLIQUER 35  /* BUTTON dans l'arbre LABEL */
#define LABEL_OK 36  /* BUTTON dans l'arbre LABEL */
#define LABEL_HIDCHAR 37  /* IBOX dans l'arbre LABEL */
#define LABEL_CHAR_TTL 38  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_CHAR 41  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_HIDPIXFLAG 42  /* IBOX dans l'arbre LABEL */
#define LABEL_ALTERNE 44  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_MOSAIC 46  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_LOAD_PIX 47  /* BOXTEXT dans l'arbre LABEL */
#define LABEL_X  51  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_Y  55  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_W  59  /* FBOXTEXT dans l'arbre LABEL */
#define LABEL_H  62  /* FBOXTEXT dans l'arbre LABEL */

#define NEW_MENU_DEFAULT 16  /* Arbre menu */

#define EDIT_MENU 17  /* Formulaire/Dialogue */
#define EM_MARQUE 4   /* BOXTEXT dans l'arbre EDIT_MENU */
#define EM_GRISE 5   /* BOXTEXT dans l'arbre EDIT_MENU */
#define EM_ADD_TITRE 7   /* BUTTON dans l'arbre EDIT_MENU */
#define EM_ADD_ENTREE 8   /* BUTTON dans l'arbre EDIT_MENU */
#define EM_UP    9   /* BUTTON dans l'arbre EDIT_MENU */
#define EM_DOWN  10  /* BUTTON dans l'arbre EDIT_MENU */
#define EM_EFFACE 11  /* BUTTON dans l'arbre EDIT_MENU */
#define EM_SEPAR 12  /* BUTTON dans l'arbre EDIT_MENU */

#define MENU_INTEMS 18  /* Arbre menu */
#define ITEM_TITRE 3   /* TITLE dans l'arbre MENU_INTEMS */
#define ITEM_ENTREE 6   /* STRING dans l'arbre MENU_INTEMS */

#define LINE_EDITOR 19  /* Formulaire/Dialogue */
#define LINE_POS000 4   /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS001 5   /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS010 6   /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS011 7   /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS100 8   /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS101 9   /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS110 10  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_POS111 11  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_DEB00 14  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_DEB01 15  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_DEB10 16  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_SENS0 19  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_SENS1 20  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF000 23  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF001 24  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF010 25  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF011 26  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF100 27  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF101 28  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF110 29  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_MOTIF111 30  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_FIN00 33  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_FIN01 34  /* BOXTEXT dans l'arbre LINE_EDITOR */
#define LINE_FIN10 35  /* BOXTEXT dans l'arbre LINE_EDITOR */

#define HELP     20  /* Formulaire/Dialogue */

#define TYPES    21  /* Formulaire/Dialogue */
#define TYPES_GTEXT 1   /* TEXT dans l'arbre TYPES */
#define TYPES_GFTEXT 2   /* FTEXT dans l'arbre TYPES */
#define TYPES_GFBOXTEXT 3   /* FBOXTEXT dans l'arbre TYPES */
#define TYPES_GIMAGE 4   /* IMAGE dans l'arbre TYPES */
#define TYPES_GCICON 5   /* USERDEF dans l'arbre TYPES */
#define TYPES_GICON 6   /* ICON dans l'arbre TYPES */
#define TYPES_GBOXTEXT 7   /* BOXTEXT dans l'arbre TYPES */
#define TYPES_GBUTTON 8   /* BUTTON dans l'arbre TYPES */
#define TYPES_GSTRING 9   /* STRING dans l'arbre TYPES */
#define TYPES_IBOX 10  /* IBOX dans l'arbre TYPES */

#define G_GOURAUD_EDIT 22  /* Formulaire/Dialogue */

#define FORM_ALERT 23  /* Formulaire/Dialogue */
#define FA_LINE1 3   /* FTEXT dans l'arbre FORM_ALERT */
#define FA_LINE5 7   /* FTEXT dans l'arbre FORM_ALERT */
#define FA_IC1   9   /* TEXT dans l'arbre FORM_ALERT */
#define FA_IC6   14  /* TEXT dans l'arbre FORM_ALERT */
#define FA_BT1   16  /* FTEXT dans l'arbre FORM_ALERT */
#define FA_BT2   17  /* FTEXT dans l'arbre FORM_ALERT */
#define FA_BT3   18  /* FTEXT dans l'arbre FORM_ALERT */
#define FA_OK    19  /* BUTTON dans l'arbre FORM_ALERT */
#define FA_TEST  20  /* BUTTON dans l'arbre FORM_ALERT */

#define RSC_NOT_FIND 0   /* Chaine d'alerte */
