/* resource set indices for C_GEN */

#define BUREAU             0 /* free form */

#define ICONIFY            1 /* form/dialog */

#define MENU               2 /* menu */
#define MEN_INFO           8 /* STRING in tree MENU */
#define MEN_NOUVEAU       17 /* STRING in tree MENU */
#define MEN_CHARGER       18 /* STRING in tree MENU */
#define MEN_SAUVER        20 /* STRING in tree MENU */
#define MEN_INFO_SYS      22 /* STRING in tree MENU */
#define MEN_QUIT          24 /* STRING in tree MENU */
#define MEN_TOOL_BOX      26 /* STRING in tree MENU */
#define MEN_SUIVANTE      27 /* STRING in tree MENU */

#define MESSAGE            3 /* form/dialog */
#define MES_W_INFO         1 /* STRING in tree MESSAGE */
#define MES_QUIT           2 /* STRING in tree MESSAGE */
#define MES_NO_ALERTE      3 /* STRING in tree MESSAGE */
#define MES_W_TBX          4 /* STRING in tree MESSAGE */
#define MES_W_SYSTEM       5 /* STRING in tree MESSAGE */
#define MES_W_PROG         6 /* STRING in tree MESSAGE */
#define MES_W_DONNEE       7 /* STRING in tree MESSAGE */
#define MES_W_TYPE         8 /* STRING in tree MESSAGE */
#define MES_W_AUTRE_TYPE   9 /* STRING in tree MESSAGE */
#define MES_W_FCT         10 /* STRING in tree MESSAGE */
#define MES_W_EXPR        11 /* STRING in tree MESSAGE */

#define INFORMA            4 /* form/dialog */

#define TOOL_BOX           5 /* form/dialog */
#define TBX_DE             2 /* IMAGE in tree TOOL_BOX */
#define TBX_DATA           4 /* IMAGE in tree TOOL_BOX */
#define TBX_FCT            6 /* IMAGE in tree TOOL_BOX */
#define TBX_NTYPE          8 /* IMAGE in tree TOOL_BOX */
#define TBX_EFFACE        10 /* IMAGE in tree TOOL_BOX */
#define TBX_AFFECT        12 /* IMAGE in tree TOOL_BOX */

#define SYSTEM             6 /* form/dialog */
#define SYS_ACTU           1 /* BUTTON in tree SYSTEM */
#define SYS_N_OBJ          4 /* STRING in tree SYSTEM */
#define SYS_MEM            8 /* STRING in tree SYSTEM */

#define F_DONNEE           7 /* form/dialog */
#define DON_NOM            2 /* FTEXT in tree F_DONNEE */
#define DON_COM            3 /* FTEXT in tree F_DONNEE */
#define DON_VI             4 /* FTEXT in tree F_DONNEE */
#define DON_EXTERN         6 /* BUTTON in tree F_DONNEE */
#define DON_UNSIGNED       7 /* BUTTON in tree F_DONNEE */
#define DON_LONG           8 /* BUTTON in tree F_DONNEE */
#define DON_POINTER        9 /* BUTTON in tree F_DONNEE */
#define DON_TAB           10 /* FTEXT in tree F_DONNEE */
#define DON_POP           11 /* Laisser 4 caractäres dans le masque */
#define DON_APP           12 /* BUTTON in tree F_DONNEE */
#define DON_CONF          13 /* BUTTON in tree F_DONNEE */

#define PP_TYPE            8 /* form/dialog */
#define PPT_INT            1 /* STRING in tree PP_TYPE */
#define PPT_CHAR           2 /* STRING in tree PP_TYPE */
#define PPT_REEL           3 /* STRING in tree PP_TYPE */
#define PPT_STRUC          4 /* STRING in tree PP_TYPE */
#define PPT_ENUM           5 /* STRING in tree PP_TYPE */
#define PPT_UNION          6 /* STRING in tree PP_TYPE */
#define PPT_NUL            7 /* STRING in tree PP_TYPE */
#define PPT_AUTRE          8 /* STRING in tree PP_TYPE */

#define F_TYPE             9 /* form/dialog */
#define TYP_NOM            2 /* FTEXT in tree F_TYPE */
#define TYP_COM            3 /* FTEXT in tree F_TYPE */
#define TYP_CONF           4 /* BUTTON in tree F_TYPE */
#define TYP_APP            5 /* BUTTON in tree F_TYPE */
#define TYP_POP            7 /* BOXTEXT in tree F_TYPE */
#define TYP_UNSIGNED       8 /* BUTTON in tree F_TYPE */
#define TYP_LONG           9 /* BUTTON in tree F_TYPE */

#define F_FONCTION        10 /* form/dialog */
#define FCT_NOM            2 /* FTEXT in tree F_FONCTION */
#define FCT_COM            3 /* FTEXT in tree F_FONCTION */
#define FCT_EXTERN         5 /* BUTTON in tree F_FONCTION */
#define FCT_UNSIGNED       6 /* BUTTON in tree F_FONCTION */
#define FCT_LONG           7 /* BUTTON in tree F_FONCTION */
#define FCT_POINTER        8 /* BUTTON in tree F_FONCTION */
#define FCT_POP            9 /* Laisser 4 caractäres dans le masque */
#define FCT_CONF          12 /* BUTTON in tree F_FONCTION */

#define F_AUTRE           11 /* form/dialog */
#define AUT_NOM            2 /* FTEXT in tree F_AUTRE */
#define AUT_WIN            3 /* BOX in tree F_AUTRE */
#define AUT_START          4 /* FTEXT in tree F_AUTRE */
#define AUT_END           15 /* FTEXT in tree F_AUTRE */
#define AUT_UP            16 /* BOXCHAR in tree F_AUTRE */
#define AUT_LIFT          17 /* BOX in tree F_AUTRE */
#define AUT_SLID          18 /* BOX in tree F_AUTRE */
#define AUT_DOWN          19 /* BOXCHAR in tree F_AUTRE */
#define AUT_CON           20 /* BUTTON in tree F_AUTRE */

#define F_EXPRESSION      12 /* form/dialog */
#define EXP1_START         2 /* FTEXT in tree F_EXPRESSION */
#define EXP1_END          13 /* FTEXT in tree F_EXPRESSION */
#define EXP1_UP           14 /* BOXCHAR in tree F_EXPRESSION */
#define EXP1_LIFT         15 /* BOX in tree F_EXPRESSION */
#define EXP1_SLID         16 /* BOX in tree F_EXPRESSION */
#define EXP1_DOWN         17 /* BOXCHAR in tree F_EXPRESSION */
#define EXP_CONF          18 /* BUTTON in tree F_EXPRESSION */
#define EXP2_START        20 /* FTEXT in tree F_EXPRESSION */
#define EXP2_END          31 /* FTEXT in tree F_EXPRESSION */
#define EXP2_UP           32 /* BOXCHAR in tree F_EXPRESSION */
#define EXP2_LIFT         33 /* BOX in tree F_EXPRESSION */
#define EXP2_SLID         34 /* BOX in tree F_EXPRESSION */
#define EXP2_DOWN         35 /* BOXCHAR in tree F_EXPRESSION */
#define EXP_POINT         37 /* BUTTON in tree F_EXPRESSION */
#define EXP_TYPE          38 /* BUTTON in tree F_EXPRESSION */
#define EXP_STRUC         39 /* BUTTON in tree F_EXPRESSION */
#define EXP_OPER          40 /* BUTTON in tree F_EXPRESSION */
#define EXP_VARIABLE      41 /* BUTTON in tree F_EXPRESSION */
#define EXP_EFFACE        42 /* BUTTON in tree F_EXPRESSION */
#define EXP_EDIT          43 /* FBOXTEXT in tree F_EXPRESSION */

#define OPERATEUR         13 /* form/dialog */

