/* Indice du ressource pour LOOK */

#define FORMULAIRE_S 0   /* Formulaire/Dialogue */
#define FS_REDRAW_OBJ_1 1   /* IBOX dans l'arbre FORMULAIRE_S */
#define FS_TXT_NAME 3   /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_TXT_LGTH_HEX 5   /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_TXT_LGTH_DEC 6   /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_REDRAW_OBJ_2 7   /* IBOX dans l'arbre FORMULAIRE_S */
#define FS_OFFSET_BYTE 8   /* TEXT dans l'arbre FORMULAIRE_S */
#define FS_DONNEES_BYTE 16  /* FTEXT dans l'arbre FORMULAIRE_S */
#define FS_ASCII_BYTE 24  /* TEXT dans l'arbre FORMULAIRE_S */
#define FS_REDRAW_OBJ_3 32  /* IBOX dans l'arbre FORMULAIRE_S */
#define FS_TXT_BLK_S 34  /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_TXT_BLK_E 36  /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_BTON_F_REW 38  /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_SLIDE_FATHER 39  /* BOX dans l'arbre FORMULAIRE_S */
#define FS_SLIDE_SON 40  /* BOX dans l'arbre FORMULAIRE_S */
#define FS_BTON_F_FOR 41  /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_BTON_REW 42  /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_BTON_FOR 43  /* BOXTEXT dans l'arbre FORMULAIRE_S */
#define FS_BTON_BIG 45  /* BUTTON dans l'arbre FORMULAIRE_S */
#define FS_BTON_GO_OF 46  /* BUTTON dans l'arbre FORMULAIRE_S */
#define FS_BTON_SEARCH 48  /* BUTTON dans l'arbre FORMULAIRE_S */
#define FS_BTON_LOAD 50  /* BUTTON dans l'arbre FORMULAIRE_S */
#define FS_BTON_UPDATE 52  /* BUTTON dans l'arbre FORMULAIRE_S */
#define FS_BTON_INFO 54  /* BUTTON dans l'arbre FORMULAIRE_S */

#define POPUPS   1   /* Formulaire/Dialogue */
#define POPUP_BASE 1   /* BOX dans l'arbre POPUPS */
#define POPUP_BIN 2   /* STRING dans l'arbre POPUPS */
#define POPUP_DECI 3   /* STRING dans l'arbre POPUPS */
#define POPUP_HEXA 4   /* STRING dans l'arbre POPUPS */

#define FORM_ASK_OFFSET 2   /* Formulaire/Dialogue */
#define FAO_RBTON_MOVE 1   /* IBOX dans l'arbre FORM_ASK_OFFSET */
#define FAO_RBTON_ABS 2   /* TEXT dans l'arbre FORM_ASK_OFFSET */
#define FAO_RBTON_RELAT 3   /* TEXT dans l'arbre FORM_ASK_OFFSET */
#define FAO_RBTON_BASE 4   /* IBOX dans l'arbre FORM_ASK_OFFSET */
#define FAO_RBTON_H 5   /* FTEXT dans l'arbre FORM_ASK_OFFSET */
#define FAO_RBTON_D 6   /* FTEXT dans l'arbre FORM_ASK_OFFSET */
#define FAO_TXT_H 7   /* FBOXTEXT dans l'arbre FORM_ASK_OFFSET */
#define FAO_TXT_D 8   /* FBOXTEXT dans l'arbre FORM_ASK_OFFSET */
#define FAO_BTON_GO 9   /* BUTTON dans l'arbre FORM_ASK_OFFSET */
#define FAO_BTON_CANCEL 11  /* BUTTON dans l'arbre FORM_ASK_OFFSET */

#define MENU_PRINCIPAL 3   /* Arbre menu */
#define MNU_INFORMATION 8   /* STRING dans l'arbre MENU_PRINCIPAL */
#define MNU_F_OPEN 17  /* STRING dans l'arbre MENU_PRINCIPAL */
#define MNU_F_QUIT 18  /* STRING dans l'arbre MENU_PRINCIPAL */
#define MNU_E_START 20  /* STRING dans l'arbre MENU_PRINCIPAL */
#define MNU_E_END 21  /* STRING dans l'arbre MENU_PRINCIPAL */
#define MNU_E_SAVE 22  /* STRING dans l'arbre MENU_PRINCIPAL */

#define FORM_INFORMATION 4   /* Formulaire/Dialogue */

#define FORMULAIRE_B 5   /* Formulaire/Dialogue */
#define FB_REDRAW_OBJ_1 1   /* IBOX dans l'arbre FORMULAIRE_B */
#define FB_TXT_NAME 3   /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_TXT_LGTH_HEX 5   /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_TXT_LGTH_DEC 6   /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_REDRAW_OBJ_2 7   /* IBOX dans l'arbre FORMULAIRE_B */
#define FB_OFFSET_BYTE 8   /* TEXT dans l'arbre FORMULAIRE_B */
#define FB_DONNEES_BYTE 24  /* FTEXT dans l'arbre FORMULAIRE_B */
#define FB_ASCII_BYTE 40  /* TEXT dans l'arbre FORMULAIRE_B */
#define FB_REDRAW_OBJ_3 56  /* IBOX dans l'arbre FORMULAIRE_B */
#define FB_TXT_BLK_S 58  /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_TXT_BLK_E 60  /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_BTON_REW 62  /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_BTON_F_REW 63  /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_SLIDE_FATHER 64  /* BOX dans l'arbre FORMULAIRE_B */
#define FB_SLIDE_SON 65  /* BOX dans l'arbre FORMULAIRE_B */
#define FB_BTON_F_FOR 66  /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_BTON_FOR 67  /* BOXTEXT dans l'arbre FORMULAIRE_B */
#define FB_BTON_SMALL 68  /* BUTTON dans l'arbre FORMULAIRE_B */
#define FB_BTON_GO_OF 70  /* BUTTON dans l'arbre FORMULAIRE_B */
#define FB_BTON_SEARCH 72  /* BUTTON dans l'arbre FORMULAIRE_B */
#define FB_BTON_LOAD 74  /* BUTTON dans l'arbre FORMULAIRE_B */
#define FB_BTON_UPDATE 76  /* BUTTON dans l'arbre FORMULAIRE_B */
#define FB_BTON_INFO 78  /* BUTTON dans l'arbre FORMULAIRE_B */

#define FORM_SEARCH 6   /* Formulaire/Dialogue */
#define FSCH_TXT_ITEM 1   /* FBOXTEXT dans l'arbre FORM_SEARCH */
#define FSCH_BTON_SEARCH 2   /* BUTTON dans l'arbre FORM_SEARCH */
#define FSCHG_BTON_STOP 4   /* BUTTON dans l'arbre FORM_SEARCH */
#define FSCH_BTON_CANCEL 6   /* BUTTON dans l'arbre FORM_SEARCH */
#define FSCHG_SLD_FATHER 8   /* BOX dans l'arbre FORM_SEARCH */
#define FSCHG_SLD_SON 9   /* BOX dans l'arbre FORM_SEARCH */
#define FSCH_BTON_CONT 10  /* BUTTON dans l'arbre FORM_SEARCH */

#define ALERT_MEM 0   /* Chaine d'alerte */

#define ALERT_MOD_B 1   /* Chaine d'alerte */

#define ALERT_B_NOTEMPTY 2   /* Chaine d'alerte */

#define ALERT_OPEN_FILE 3   /* Chaine d'alerte */

#define ALERT_READ_FILE 4   /* Chaine d'alerte */

#define ALERT_F_SAVING 5   /* Chaine d'alerte */

#define ALERT_BAD_HEXA 6   /* Chaine d'alerte */

#define ALERT_NO_MATCH 7   /* Chaine d'alerte */
