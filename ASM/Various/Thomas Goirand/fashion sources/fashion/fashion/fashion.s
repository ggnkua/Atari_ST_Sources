;	/* Indice du ressource pour FASHION */

MENU	equ	0	;    /* Arbre menu */
M_INFO	equ	9	;    /* STRING dans l'arbre MENU */
M_Z_LIB	equ	18	;   /* STRING dans l'arbre MENU */
M_NEW	equ	20	;   /* STRING dans l'arbre MENU */
M_OPEN	equ	21	;   /* STRING dans l'arbre MENU */
M_SAUVE	equ	22	;   /* STRING dans l'arbre MENU */
M_EXPORT	equ	25	;   /* STRING dans l'arbre MENU */
M_QUIT	equ	27	;   /* STRING dans l'arbre MENU */
M_DELETE	equ	31	;   /* STRING dans l'arbre MENU */
M_ARBRE	equ	33	;   /* STRING dans l'arbre MENU */
M_OGRILLE	equ	35	;   /* STRING dans l'arbre MENU */
M_GRILLE	equ	36	;   /* STRING dans l'arbre MENU */
M_HELP	equ	39	;   /* STRING dans l'arbre MENU */
M_MAIN	equ	40	;   /* STRING dans l'arbre MENU */
M_TOOLBOX	equ	41	;   /* STRING dans l'arbre MENU */
M_PREF	equ	42	;   /* STRING dans l'arbre MENU */

INFO	equ	1	;    /* Formulaire/Dialogue */

MAIN	equ	2	;    /* Formulaire/Dialogue */
MAIN_FLAG	equ	1	;    /* USERDEF dans l'arbre MAIN */
MAIN_COLOR	equ	2	;    /* USERDEF dans l'arbre MAIN */
MAIN_FONTE	equ	3	;    /* USERDEF dans l'arbre MAIN */
MAIN_FLECHE	equ	4	;    /* USERDEF dans l'arbre MAIN */
MAIN_CORDS	equ	7	;    /* IBOX dans l'arbre MAIN */
MAIN_XPOSROOT	equ	8	;    /* STRING dans l'arbre MAIN */
MAIN_WPOS	equ	9	;    /* STRING dans l'arbre MAIN */
MAIN_YPOSROOT	equ	11	;   /* STRING dans l'arbre MAIN */
MAIN_HPOS	equ	12	;   /* STRING dans l'arbre MAIN */
MAIN_XPOSREL	equ	13	;   /* STRING dans l'arbre MAIN */
MAIN_YPOSREL	equ	14	;   /* STRING dans l'arbre MAIN */
MAIN_NUMOBJ	equ	17	;   /* STRING dans l'arbre MAIN */
MAIN_OBTYPE	equ	19	;   /* STRING dans l'arbre MAIN */

ENTER_NAME	equ	3	;    /* Formulaire/Dialogue */
RB_DIALOG	equ	2	;    /* USERDEF dans l'arbre ENTER_NAME */
RB_MENU	equ	3	;    /* USERDEF dans l'arbre ENTER_NAME */
RB_ALERT	equ	4	;    /* USERDEF dans l'arbre ENTER_NAME */
RB_STRING	equ	5	;    /* USERDEF dans l'arbre ENTER_NAME */
RB_IMAGE	equ	6	;    /* USERDEF dans l'arbre ENTER_NAME */
ENTER_NAME_OK	equ	7	;    /* BUTTON dans l'arbre ENTER_NAME */
ED_ARBRE_LABEL	equ	8	;    /* FTEXT dans l'arbre ENTER_NAME */

FLAG	equ	4	;    /* Formulaire/Dialogue */
FLAG_0	equ	3	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_1	equ	4	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_2	equ	5	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_3	equ	6	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_4	equ	7	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_5	equ	8	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_6	equ	9	;    /* BOXTEXT dans l'arbre FLAG */
FLAG_7	equ	10	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_8	equ	11	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_9	equ	12	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_10	equ	13	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_11	equ	14	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_12	equ	15	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_13	equ	16	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_14	equ	17	;   /* BOXTEXT dans l'arbre FLAG */
FLAG_15	equ	18	;   /* BOXTEXT dans l'arbre FLAG */
STATE_0	equ	21	;   /* BOXTEXT dans l'arbre FLAG */
STATE_1	equ	22	;   /* BOXTEXT dans l'arbre FLAG */
STATE_2	equ	23	;   /* BOXTEXT dans l'arbre FLAG */
STATE_3	equ	24	;   /* BOXTEXT dans l'arbre FLAG */
STATE_4	equ	25	;   /* BOXTEXT dans l'arbre FLAG */
STATE_5	equ	26	;   /* BOXTEXT dans l'arbre FLAG */
STATE_6	equ	27	;   /* BOXTEXT dans l'arbre FLAG */
STATE_7	equ	28	;   /* BOXTEXT dans l'arbre FLAG */
STATE_8	equ	29	;   /* BOXTEXT dans l'arbre FLAG */
STATE_9	equ	30	;   /* BOXTEXT dans l'arbre FLAG */
STATE_10	equ	31	;   /* BOXTEXT dans l'arbre FLAG */
STATE_11	equ	32	;   /* BOXTEXT dans l'arbre FLAG */
STATE_12	equ	33	;   /* BOXTEXT dans l'arbre FLAG */
STATE_13	equ	34	;   /* BOXTEXT dans l'arbre FLAG */
STATE_14	equ	35	;   /* BOXTEXT dans l'arbre FLAG */
STATE_15	equ	36	;   /* BOXTEXT dans l'arbre FLAG */

WAIT	equ	5	;    /* Formulaire/Dialogue */
WAIT_BOX	equ	1	;    /* BOX dans l'arbre WAIT */
WAIT_BAR	equ	2	;    /* BOX dans l'arbre WAIT */
WAIT_TXT1	equ	3	;    /* TEXT dans l'arbre WAIT */
WAIT_TXT2	equ	4	;    /* TEXT dans l'arbre WAIT */
WAIT_TXT3	equ	5	;    /* TEXT dans l'arbre WAIT */

Z_LIB_INFO	equ	6	;    /* Formulaire/Dialogue */

EDIT	equ	7	;    /* Formulaire/Dialogue */
EDIT_EDIT	equ	1	;    /* FTEXT dans l'arbre EDIT */

NEW_DIAL_DEFAULT	equ	8	;    /* Formulaire/Dialogue */

ARBRE	equ	9	;    /* Formulaire/Dialogue */

PREF	equ	10	;   /* Formulaire/Dialogue */
PREF_B_ASM	equ	3	;    /* USERDEF dans l'arbre PREF */
PREF_T_ASM	equ	4	;    /* TEXT dans l'arbre PREF */
PREF_B_C	equ	5	;    /* USERDEF dans l'arbre PREF */
PREF_T_C	equ	6	;    /* TEXT dans l'arbre PREF */
PREF_B_GFA	equ	7	;    /* USERDEF dans l'arbre PREF */
PREF_T_GFA	equ	8	;    /* TEXT dans l'arbre PREF */
PREF_B_PBASIC	equ	9	;    /* USERDEF dans l'arbre PREF */
PREF_T_PBASIC	equ	10	;   /* TEXT dans l'arbre PREF */
PREF_B_HRD	equ	11	;   /* USERDEF dans l'arbre PREF */
PREF_T_HRD	equ	12	;   /* TEXT dans l'arbre PREF */
PREF_B_CUSTOM	equ	13	;   /* USERDEF dans l'arbre PREF */
PREF_T1_COPY	equ	17	;   /* TEXT dans l'arbre PREF */
PREF_T2_COPY	equ	18	;   /* TEXT dans l'arbre PREF */
PREF_GRIDX	equ	28	;   /* FBOXTEXT dans l'arbre PREF */
PREF_GRIDY	equ	31	;   /* FBOXTEXT dans l'arbre PREF */
PREF_CUS_FRMT	equ	49	;   /* FBOXTEXT dans l'arbre PREF */
PREF_CUS_EXT	equ	52	;   /* FBOXTEXT dans l'arbre PREF */

TEDINFO_EDIT	equ	11	;   /* Formulaire/Dialogue */
TED_PETIT	equ	2	;    /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_GRAND	equ	3	;    /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_MOYEN	equ	4	;    /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_GDOS	equ	5	;    /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_SIZE	equ	6	;    /* BUTTON dans l'arbre TEDINFO_EDIT */
TED_GAUCHE	equ	9	;    /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_CENTRE	equ	10	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_DROITE	equ	11	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_JUSTIF	equ	12	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_FONTLIST	equ	14	;   /* BOX dans l'arbre TEDINFO_EDIT */
TED_UP	equ	15	;   /* BOXCHAR dans l'arbre TEDINFO_EDIT */
TED_DOWN	equ	16	;   /* BOXCHAR dans l'arbre TEDINFO_EDIT */
TED_SLIDEBOX	equ	17	;   /* BOX dans l'arbre TEDINFO_EDIT */
TED_SLIDE	equ	18	;   /* BOXCHAR dans l'arbre TEDINFO_EDIT */
TED_GRAS	equ	21	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_LIGHT	equ	23	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_SOULIGNE	equ	25	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_DETOURE	equ	27	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_ITALIC	equ	30	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */
TED_OMBRE	equ	32	;   /* BOXTEXT dans l'arbre TEDINFO_EDIT */

OBJC_COLOR_WORD	equ	12	;   /* Formulaire/Dialogue */
CW_TXTBOX	equ	4	;    /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT0	equ	5	;    /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT1	equ	6	;    /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT2	equ	7	;    /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT3	equ	8	;    /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT4	equ	9	;    /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT5	equ	10	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT6	equ	11	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT7	equ	12	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT8	equ	13	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT9	equ	14	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT10	equ	15	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT11	equ	16	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT12	equ	17	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT13	equ	18	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT14	equ	19	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TXT15	equ	20	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_CADREBOX	equ	21	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_CADRE0	equ	22	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_CADRE15	equ	37	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_FONDBOX	equ	38	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_FOND0	equ	39	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_FOND15	equ	54	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_OPAQUE	equ	56	;   /* BOXTEXT dans l'arbre OBJC_COLOR_WORD */
CW_TRAMEBOX	equ	57	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TRAME0	equ	58	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_TRAME7	equ	65	;   /* BOX dans l'arbre OBJC_COLOR_WORD */
CW_PLUS	equ	67	;   /* BOXTEXT dans l'arbre OBJC_COLOR_WORD */
CW_MOINS	equ	69	;   /* BOXTEXT dans l'arbre OBJC_COLOR_WORD */

POPUP	equ	13	;   /* Formulaire/Dialogue */
POPUP_CADRE_SIZE	equ	1	;    /* BOX dans l'arbre POPUP */
POP_M16	equ	2	;    /* STRING dans l'arbre POPUP */
POP_M15	equ	3	;    /* STRING dans l'arbre POPUP */
POP_M14	equ	4	;    /* STRING dans l'arbre POPUP */
POP_M13	equ	5	;    /* STRING dans l'arbre POPUP */
POP_M12	equ	6	;    /* STRING dans l'arbre POPUP */
POP_M11	equ	7	;    /* STRING dans l'arbre POPUP */
POP_M10	equ	8	;    /* STRING dans l'arbre POPUP */
POP_M9	equ	9	;    /* STRING dans l'arbre POPUP */
POP_M8	equ	10	;   /* STRING dans l'arbre POPUP */
POP_M7	equ	11	;   /* STRING dans l'arbre POPUP */
POP_M6	equ	12	;   /* STRING dans l'arbre POPUP */
POP_M5	equ	13	;   /* STRING dans l'arbre POPUP */
POP_M4	equ	14	;   /* STRING dans l'arbre POPUP */
POP_M3	equ	15	;   /* STRING dans l'arbre POPUP */
POP_M2	equ	16	;   /* STRING dans l'arbre POPUP */
POP_M1	equ	17	;   /* STRING dans l'arbre POPUP */
POP_0	equ	18	;   /* STRING dans l'arbre POPUP */
POP_P1	equ	19	;   /* STRING dans l'arbre POPUP */
POP_P2	equ	20	;   /* STRING dans l'arbre POPUP */
POP_P3	equ	21	;   /* STRING dans l'arbre POPUP */
POP_P4	equ	22	;   /* STRING dans l'arbre POPUP */
POP_P5	equ	23	;   /* STRING dans l'arbre POPUP */
POP_P6	equ	24	;   /* STRING dans l'arbre POPUP */
POP_P7	equ	25	;   /* STRING dans l'arbre POPUP */
POP_P8	equ	26	;   /* STRING dans l'arbre POPUP */
POP_P9	equ	27	;   /* STRING dans l'arbre POPUP */
POP_P10	equ	28	;   /* STRING dans l'arbre POPUP */
POP_P11	equ	29	;   /* STRING dans l'arbre POPUP */
POP_P12	equ	30	;   /* STRING dans l'arbre POPUP */
POP_P13	equ	31	;   /* STRING dans l'arbre POPUP */
POP_P14	equ	32	;   /* STRING dans l'arbre POPUP */
POP_P15	equ	33	;   /* STRING dans l'arbre POPUP */
POP_P16	equ	34	;   /* STRING dans l'arbre POPUP */
POPUP_FNTSIZE	equ	53	;   /* BUTTON dans l'arbre POPUP */
POPUP_OBTYPE	equ	105	;  /* BOX dans l'arbre POPUP */
PP_G_BOX	equ	106	;  /* STRING dans l'arbre POPUP */
PP_G_TEXT	equ	107	;  /* STRING dans l'arbre POPUP */
PP_G_BOXTEXT	equ	108	;  /* STRING dans l'arbre POPUP */
PP_G_IMAGE	equ	109	;  /* STRING dans l'arbre POPUP */
PP_G_PROGDEF	equ	110	;  /* STRING dans l'arbre POPUP */
PP_G_IBOX	equ	111	;  /* STRING dans l'arbre POPUP */
PP_G_BUTTON	equ	112	;  /* STRING dans l'arbre POPUP */
PP_G_BOXCHAR	equ	113	;  /* STRING dans l'arbre POPUP */
PP_G_STRING	equ	114	;  /* STRING dans l'arbre POPUP */
PP_G_FTEXT	equ	115	;  /* STRING dans l'arbre POPUP */
PP_G_FBOXTEXT	equ	116	;  /* STRING dans l'arbre POPUP */
PP_G_ICON	equ	117	;  /* STRING dans l'arbre POPUP */
PP_G_TITTLE	equ	118	;  /* STRING dans l'arbre POPUP */
PP_G_CICON	equ	119	;  /* STRING dans l'arbre POPUP */
PP_G_BOUNDING	equ	120	;  /* STRING dans l'arbre POPUP */
PP_G_BOUNDED	equ	121	;  /* STRING dans l'arbre POPUP */
PP_G_PIX	equ	122	;  /* STRING dans l'arbre POPUP */
PP_G_LINE	equ	123	;  /* STRING dans l'arbre POPUP */

COLOR_ICN	equ	14	;   /* Formulaire/Dialogue */

LABEL	equ	15	;   /* Formulaire/Dialogue */
LABEL_HIDALLTXT	equ	1	;    /* BOX dans l'arbre LABEL */
LABEL_PVALID	equ	4	;    /* FBOXTEXT dans l'arbre LABEL */
LABEL_PTMPLT	equ	7	;    /* FBOXTEXT dans l'arbre LABEL */
LABEL_PVALID_TTL	equ	8	;    /* BOXTEXT dans l'arbre LABEL */
LABEL_PTMPLT_TTL	equ	9	;    /* BOXTEXT dans l'arbre LABEL */
LABEL_PTEXT	equ	12	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_PTEXT_TTL	equ	13	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_LABEL_TTL	equ	15	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_LABEL	equ	18	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_COMMENT_TT	equ	19	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_COMMENT	equ	22	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_OBTYPE	equ	25	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_POP_OBTYPE	equ	27	;   /* BUTTON dans l'arbre LABEL */
LABEL_APPLIQUER	equ	35	;   /* BUTTON dans l'arbre LABEL */
LABEL_OK	equ	36	;   /* BUTTON dans l'arbre LABEL */
LABEL_HIDCHAR	equ	37	;   /* IBOX dans l'arbre LABEL */
LABEL_CHAR_TTL	equ	38	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_CHAR	equ	41	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_HIDPIXFLAG	equ	42	;   /* IBOX dans l'arbre LABEL */
LABEL_ALTERNE	equ	44	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_MOSAIC	equ	46	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_LOAD_PIX	equ	47	;   /* BOXTEXT dans l'arbre LABEL */
LABEL_X	equ	51	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_Y	equ	55	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_W	equ	59	;   /* FBOXTEXT dans l'arbre LABEL */
LABEL_H	equ	62	;   /* FBOXTEXT dans l'arbre LABEL */

NEW_MENU_DEFAULT	equ	16	;   /* Arbre menu */

EDIT_MENU	equ	17	;   /* Formulaire/Dialogue */
EM_MARQUE	equ	4	;    /* BOXTEXT dans l'arbre EDIT_MENU */
EM_GRISE	equ	5	;    /* BOXTEXT dans l'arbre EDIT_MENU */
EM_ADD_TITRE	equ	7	;    /* BUTTON dans l'arbre EDIT_MENU */
EM_ADD_ENTREE	equ	8	;    /* BUTTON dans l'arbre EDIT_MENU */
EM_UP	equ	9	;    /* BUTTON dans l'arbre EDIT_MENU */
EM_DOWN	equ	10	;   /* BUTTON dans l'arbre EDIT_MENU */
EM_EFFACE	equ	11	;   /* BUTTON dans l'arbre EDIT_MENU */
EM_SEPAR	equ	12	;   /* BUTTON dans l'arbre EDIT_MENU */

MENU_INTEMS	equ	18	;   /* Arbre menu */
ITEM_TITRE	equ	3	;    /* TITLE dans l'arbre MENU_INTEMS */
ITEM_ENTREE	equ	6	;    /* STRING dans l'arbre MENU_INTEMS */

LINE_EDITOR	equ	19	;   /* Formulaire/Dialogue */
LINE_POS000	equ	4	;    /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS001	equ	5	;    /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS010	equ	6	;    /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS011	equ	7	;    /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS100	equ	8	;    /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS101	equ	9	;    /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS110	equ	10	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_POS111	equ	11	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_DEB00	equ	14	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_DEB01	equ	15	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_DEB10	equ	16	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_SENS0	equ	19	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_SENS1	equ	20	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF000	equ	23	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF001	equ	24	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF010	equ	25	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF011	equ	26	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF100	equ	27	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF101	equ	28	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF110	equ	29	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_MOTIF111	equ	30	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_FIN00	equ	33	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_FIN01	equ	34	;   /* BOXTEXT dans l'arbre LINE_EDITOR */
LINE_FIN10	equ	35	;   /* BOXTEXT dans l'arbre LINE_EDITOR */

HELP	equ	20	;   /* Formulaire/Dialogue */

TYPES	equ	21	;   /* Formulaire/Dialogue */
TYPES_GTEXT	equ	1	;    /* TEXT dans l'arbre TYPES */
TYPES_GFTEXT	equ	2	;    /* FTEXT dans l'arbre TYPES */
TYPES_GFBOXTEXT	equ	3	;    /* FBOXTEXT dans l'arbre TYPES */
TYPES_GIMAGE	equ	4	;    /* IMAGE dans l'arbre TYPES */
TYPES_GCICON	equ	5	;    /* USERDEF dans l'arbre TYPES */
TYPES_GICON	equ	6	;    /* ICON dans l'arbre TYPES */
TYPES_GBOXTEXT	equ	7	;    /* BOXTEXT dans l'arbre TYPES */
TYPES_GBUTTON	equ	8	;    /* BUTTON dans l'arbre TYPES */
TYPES_GSTRING	equ	9	;    /* STRING dans l'arbre TYPES */
TYPES_IBOX	equ	10	;   /* IBOX dans l'arbre TYPES */

G_GOURAUD_EDIT	equ	22	;   /* Formulaire/Dialogue */

FORM_ALERT	equ	23	;   /* Formulaire/Dialogue */
FA_LINE1	equ	3	;    /* FTEXT dans l'arbre FORM_ALERT */
FA_LINE5	equ	7	;    /* FTEXT dans l'arbre FORM_ALERT */
FA_IC1	equ	9	;    /* TEXT dans l'arbre FORM_ALERT */
FA_IC6	equ	14	;   /* TEXT dans l'arbre FORM_ALERT */
FA_BT1	equ	16	;   /* FTEXT dans l'arbre FORM_ALERT */
FA_BT2	equ	17	;   /* FTEXT dans l'arbre FORM_ALERT */
FA_BT3	equ	18	;   /* FTEXT dans l'arbre FORM_ALERT */
FA_OK	equ	19	;   /* BUTTON dans l'arbre FORM_ALERT */
FA_TEST	equ	20	;   /* BUTTON dans l'arbre FORM_ALERT */

RSC_NOT_FIND	equ	0	;    /* Chaine d'alerte */
