/* Indice du ressource pour FRACTAL */

#define FORM_INFO 0   /* Formulaire/Dialogue */
#define INFO_NOM 3   /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_TYPE 5   /* BOXTEXT dans l'arbre FORM_INFO */
#define INFO_INITX 7   /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_INITY 8   /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_ITER 10  /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_ALGO 11  /* BOXTEXT dans l'arbre FORM_INFO */
#define INFO_X1  14  /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_Y1  15  /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_X2  16  /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_Y2  17  /* FBOXTEXT dans l'arbre FORM_INFO */
#define INFO_MOINS 19  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_PLUS 20  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_TAILLE 21  /* BOXTEXT dans l'arbre FORM_INFO */
#define INFO_PIXEL 22  /* BOXTEXT dans l'arbre FORM_INFO */
#define INFO_CENTRE 23  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_FENETRE 24  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_RAZ 25  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_OK  26  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_REPORT 27  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_AIDE 28  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_ANNULE 29  /* BUTTON dans l'arbre FORM_INFO */
#define INFO_KEEPNB 30  /* BOX dans l'arbre FORM_INFO */

#define FORM_AIDE 1   /* Formulaire/Dialogue */
#define AIDE_OK  3   /* BUTTON dans l'arbre FORM_AIDE */

#define FORM_BARATIN 2   /* Formulaire/Dialogue */
#define BARATIN_CLICK 7   /* IMAGE dans l'arbre FORM_BARATIN */

#define AIDE_FICHIERS 3   /* Formulaire/Dialogue */
#define AIDE_FIC_OK 18  /* BUTTON dans l'arbre AIDE_FICHIERS */

#define AIDE_OPTIONS 4   /* Formulaire/Dialogue */
#define AIDE_OPT_OK 17  /* BUTTON dans l'arbre AIDE_OPTIONS */

#define AIDE_ANIMATION 5   /* Formulaire/Dialogue */
#define AIDE_ANIM_OK 15  /* BUTTON dans l'arbre AIDE_ANIMATION */

#define FORM_PARANIM 6   /* Formulaire/Dialogue */
#define PARANIM_TMEM 2   /* TEXT dans l'arbre FORM_PARANIM */
#define PARANIM_TDISQUE 3   /* TEXT dans l'arbre FORM_PARANIM */
#define PARANIM_MEM 4   /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_DISQUE 5   /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_VBL14 7   /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_VBL13 8   /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_VBL12 9   /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_VBL11 10  /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_OK 15  /* BUTTON dans l'arbre FORM_PARANIM */
#define PARANIM_CANCEL 16  /* BUTTON dans l'arbre FORM_PARANIM */
#define PARANIM_PP 20  /* BUTTON dans l'arbre FORM_PARANIM */
#define PARANIM_BCL 21  /* BUTTON dans l'arbre FORM_PARANIM */
#define PARANIM_ECR2 23  /* BOX dans l'arbre FORM_PARANIM */
#define PARANIM_TTR 24  /* TEXT dans l'arbre FORM_PARANIM */
#define PARANIM_TR 25  /* BOX dans l'arbre FORM_PARANIM */

#define FORM_PREF 7   /* Formulaire/Dialogue */
#define PREF_FRACTALS 2   /* FBOXTEXT dans l'arbre FORM_PREF */
#define PREF_ANI 3   /* FBOXTEXT dans l'arbre FORM_PREF */
#define PREF_ENTIER 5   /* BUTTON dans l'arbre FORM_PREF */
#define PREF_REEL 7   /* BUTTON dans l'arbre FORM_PREF */
#define PREF_DSP 8   /* BOX dans l'arbre FORM_PREF */
#define PREF_TSET1 10  /* TEXT dans l'arbre FORM_PREF */
#define PREF_SET 11  /* BOX dans l'arbre FORM_PREF */
#define PREF_TSET2 12  /* TEXT dans l'arbre FORM_PREF */
#define PREF_TDSP 13  /* TEXT dans l'arbre FORM_PREF */
#define PREF_OK  22  /* BUTTON dans l'arbre FORM_PREF */
#define PREF_SAUVE 23  /* BUTTON dans l'arbre FORM_PREF */
#define PREF_CANCEL 24  /* BUTTON dans l'arbre FORM_PREF */
#define PREF_RTX 26  /* TEXT dans l'arbre FORM_PREF */
#define PREF_RTY 28  /* TEXT dans l'arbre FORM_PREF */
#define PREF_RTMOINS 29  /* BUTTON dans l'arbre FORM_PREF */
#define PREF_RTPLUS 30  /* BUTTON dans l'arbre FORM_PREF */
#define PREF_RTMAXITER 32  /* FTEXT dans l'arbre FORM_PREF */
#define PREF_USESTDVDI 34  /* BOX dans l'arbre FORM_PREF */
#define PREF_LZWSAVE 36  /* BOX dans l'arbre FORM_PREF */

#define FORM_REPORT 8   /* Formulaire/Dialogue */
#define REPORT_NAME 3   /* BOXTEXT dans l'arbre FORM_REPORT */
#define REPORT_TIME 4   /* BOXTEXT dans l'arbre FORM_REPORT */
#define REPORT_CPU 9   /* BOXTEXT dans l'arbre FORM_REPORT */
#define REPORT_FPU 10  /* BOXTEXT dans l'arbre FORM_REPORT */
#define REPORT_DSP 11  /* BOXTEXT dans l'arbre FORM_REPORT */

#define M_FRAC   9   /* Arbre menu */
#define M_INFO   10  /* STRING dans l'arbre M_FRAC */
#define M_NOUVEAU 19  /* STRING dans l'arbre M_FRAC */
#define M_CHARGE 20  /* STRING dans l'arbre M_FRAC */
#define M_FERME  22  /* STRING dans l'arbre M_FRAC */
#define M_SAUVE  23  /* STRING dans l'arbre M_FRAC */
#define M_SAUVES 24  /* STRING dans l'arbre M_FRAC */
#define M_COPIER 26  /* STRING dans l'arbre M_FRAC */
#define M_EXPORT 27  /* STRING dans l'arbre M_FRAC */
#define M_IMPRIMER 28  /* STRING dans l'arbre M_FRAC */
#define M_QUITTE 30  /* STRING dans l'arbre M_FRAC */
#define M_ZOOMC  33  /* STRING dans l'arbre M_FRAC */
#define M_ZOOMF  34  /* STRING dans l'arbre M_FRAC */
#define M_INFOF  36  /* STRING dans l'arbre M_FRAC */
#define M_REPORT 37  /* STRING dans l'arbre M_FRAC */
#define M_LOADINIT 38  /* STRING dans l'arbre M_FRAC */
#define M_INIT   39  /* STRING dans l'arbre M_FRAC */
#define M_CALCUL 40  /* STRING dans l'arbre M_FRAC */
#define M_DUPLIQUE 41  /* STRING dans l'arbre M_FRAC */
#define M_TAILLE 42  /* STRING dans l'arbre M_FRAC */
#define M_PALETTE 43  /* STRING dans l'arbre M_FRAC */
#define M_PREFS  45  /* STRING dans l'arbre M_FRAC */
#define M_ANIMD  48  /* STRING dans l'arbre M_FRAC */
#define M_ANIMF  49  /* STRING dans l'arbre M_FRAC */
#define M_ANIMGO 50  /* STRING dans l'arbre M_FRAC */
#define M_ANIM_CHARGE 52  /* STRING dans l'arbre M_FRAC */
#define M_ANIM_RESUME 53  /* STRING dans l'arbre M_FRAC */
#define M_ANIMATE 55  /* STRING dans l'arbre M_FRAC */
#define M_ANIM_PARA 57  /* STRING dans l'arbre M_FRAC */
#define M_CYCLING1 59  /* STRING dans l'arbre M_FRAC */
#define M_CYCLING2 60  /* STRING dans l'arbre M_FRAC */
#define M_FICHIERS 62  /* STRING dans l'arbre M_FRAC */
#define M_OPTIONS 63  /* STRING dans l'arbre M_FRAC */
#define M_ANIMATION 64  /* STRING dans l'arbre M_FRAC */

#define FORM_SEQUENCE 10  /* Formulaire/Dialogue */
#define SEQD_H   5   /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQD_C   6   /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQD_I   9   /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_DMAX 12  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQF_H   16  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQF_C   17  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQF_I   19  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_FMAX 23  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_TYPE 27  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_ALGO 28  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_OK   29  /* BUTTON dans l'arbre FORM_SEQUENCE */
#define SEQ_CANCEL 30  /* BUTTON dans l'arbre FORM_SEQUENCE */
#define SEQ_NAME 32  /* FTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_PACK 33  /* BOXTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_NBIMG 35  /* FTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_TISOL 36  /* TEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_ISOL 37  /* BOXTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_CENTRE 38  /* BOXTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_ROTATION 40  /* FTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_INVROT 42  /* BOXTEXT dans l'arbre FORM_SEQUENCE */
#define SEQ_SAVGIF 43  /* BOXTEXT dans l'arbre FORM_SEQUENCE */

#define FORM_CALCUL 11  /* Formulaire/Dialogue */
#define CALC_BOX 0   /* BOX dans l'arbre FORM_CALCUL */
#define CALCUL_TEXT 2   /* BOX dans l'arbre FORM_CALCUL */
#define CALC_DSP 3   /* BOXTEXT dans l'arbre FORM_CALCUL */
#define CALC_FPU 4   /* BOXTEXT dans l'arbre FORM_CALCUL */
#define CALC_CPU 5   /* BOXTEXT dans l'arbre FORM_CALCUL */

#define FORM_CANIM 12  /* Formulaire/Dialogue */
#define CANIM_CUR 3   /* BOX dans l'arbre FORM_CANIM */
#define CANIM_GLO 5   /* BOX dans l'arbre FORM_CANIM */
#define CALCA_CPU 7   /* BOXTEXT dans l'arbre FORM_CANIM */
#define CALCA_FPU 8   /* BOXTEXT dans l'arbre FORM_CANIM */
#define CALCA_DSP 9   /* BOXTEXT dans l'arbre FORM_CANIM */
#define CANIM_TPROG 10  /* TEXT dans l'arbre FORM_CANIM */

#define FORM_IANIM 13  /* Formulaire/Dialogue */
#define IANIM_CPU 3   /* BOX dans l'arbre FORM_IANIM */
#define IANIM_PCCPU 4   /* BOX dans l'arbre FORM_IANIM */
#define IANIM_FPU 5   /* BOX dans l'arbre FORM_IANIM */
#define IANIM_DSP 6   /* BOX dans l'arbre FORM_IANIM */
#define IANIM_PCDSP 7   /* BOX dans l'arbre FORM_IANIM */
#define IANIM_PCFPU 11  /* BOX dans l'arbre FORM_IANIM */
#define IANIM_DDATE 14  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_DTIME 15  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_FDATE 17  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_FTIME 18  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_TCALC 21  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_TCONV 23  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_TYPE 25  /* TEXT dans l'arbre FORM_IANIM */
#define IANIM_NBIMG 27  /* TEXT dans l'arbre FORM_IANIM */

#define FORM_TAILLE 14  /* Formulaire/Dialogue */
#define TAILLE_XYA 4   /* TEXT dans l'arbre FORM_TAILLE */
#define TAILLE_OCTA 5   /* TEXT dans l'arbre FORM_TAILLE */
#define TAILLE_PCA 6   /* BOXTEXT dans l'arbre FORM_TAILLE */
#define TAILLE_MOINS 7   /* BUTTON dans l'arbre FORM_TAILLE */
#define TAILLE_PCS 8   /* BOXTEXT dans l'arbre FORM_TAILLE */
#define TAILLE_PLUS 9   /* BUTTON dans l'arbre FORM_TAILLE */
#define TAILLE_XYS 10  /* TEXT dans l'arbre FORM_TAILLE */
#define TAILLE_OCTS 11  /* TEXT dans l'arbre FORM_TAILLE */
#define TAILLE_OK 12  /* BUTTON dans l'arbre FORM_TAILLE */
#define TAILLE_CANCEL 13  /* BUTTON dans l'arbre FORM_TAILLE */

#define FORM_PROG 15  /* Formulaire/Dialogue */
#define PROG_TITRE 1   /* TEXT dans l'arbre FORM_PROG */
#define PROG_PC  2   /* BOX dans l'arbre FORM_PROG */

#define FORM_MKPALETTE 16  /* Formulaire/Dialogue */
#define MKPAL_BOX 2   /* USERDEF dans l'arbre FORM_MKPALETTE */
#define MKPAL_OK 3   /* BUTTON dans l'arbre FORM_MKPALETTE */
#define MKPAL_CANCEL 4   /* BUTTON dans l'arbre FORM_MKPALETTE */
#define MKPAL_PRED 5   /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_PGREEN 6   /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_PBLUE 7   /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_REDBOX 8   /* BOX dans l'arbre FORM_MKPALETTE */
#define MKPAL_RED 9   /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_GREENBOX 10  /* BOX dans l'arbre FORM_MKPALETTE */
#define MKPAL_GREEN 11  /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_BLUEBOX 12  /* BOX dans l'arbre FORM_MKPALETTE */
#define MKPAL_BLUE 13  /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_LOAD 14  /* BUTTON dans l'arbre FORM_MKPALETTE */
#define MKPAL_SAVE 15  /* BUTTON dans l'arbre FORM_MKPALETTE */
#define MKPAL_RGB 16  /* BOX dans l'arbre FORM_MKPALETTE */
#define MKPAL_TBLUE 17  /* FTEXT dans l'arbre FORM_MKPALETTE */
#define MKPAL_TGREEN 18  /* FTEXT dans l'arbre FORM_MKPALETTE */
#define MKPAL_TRED 19  /* FTEXT dans l'arbre FORM_MKPALETTE */
#define MKPAL_MRED 20  /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_MGREEN 21  /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_MBLUE 22  /* BOXCHAR dans l'arbre FORM_MKPALETTE */
#define MKPAL_CURRCOL 24  /* USERDEF dans l'arbre FORM_MKPALETTE */
#define MKPAL_START 26  /* BUTTON dans l'arbre FORM_MKPALETTE */
#define MKPAL_END 27  /* BUTTON dans l'arbre FORM_MKPALETTE */
#define MKPAL_APPLIQUE 30  /* BUTTON dans l'arbre FORM_MKPALETTE */

#define FORM_MESSAGES 17  /* Formulaire/Dialogue */
#define MSG_FILENOTEXIST 1   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_NOMOREWINDOW 2   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_WRITEERROR 3   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_FILEEXISTS 4   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_NOWINDOW 5   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_BADINIT 6   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_INITNOTFOUND 7   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_INITERRMEM 8   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_IMGERRMEM 9   /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_IMGNOTSAME 10  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_CLIPERR 11  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_LODNOTFOUND 12  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DSPCOMERR 13  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_BINCODE 14  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_CALCCANCEL 15  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANICANCEL 16  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIERRWRITE 17  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIERRLOAD 18  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ERRSCREEN 19  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_RESOLERR 20  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ERRTRUECOLOR 21  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ZOOMCERR 22  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ERRZONE 23  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ERRDELTA 24  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_NEEDFPU 25  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DSPBUSY 26  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIISPRESENT 27  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIACRERR1 28  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIACRERR2 29  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIDLTERR1 30  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIDLTERR2 31  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANISAMEW 32  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANISAMEH 33  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANISAME 34  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANINOTSAMET 35  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANISAMEA 36  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_SETCHANGED 37  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_IMGSAVE 38  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANILOADED 39  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_LOADINGANI 40  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ORBCONV 42  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ANIINF 43  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_CALCNOTDONE 44  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_WIDTH 45  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_HEIGHT 46  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_SEEH 47  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_TAILLE 48  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_NOCMP 49  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_CMPDELTA 50  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PNOGDOS 51  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PWRITERR 52  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PTIMEOUT 53  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PNOHANDLE 54  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DITHER 55  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ROTATING 56  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DOGDOSIMG 57  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PRINTING 58  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_LOOKSPDDRV 59  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_TRSFFMTSTD 60  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DECODAGELZW 61  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ENCODAGELZW 62  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DECODAGEPCB 63  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PRINTCOLOR 64  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_PRINTBW 65  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_BCONVDIT 66  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_BCONVCAN 67  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_DSPLOCK 68  /* STRING dans l'arbre FORM_MESSAGES */
#define MSG_ENDLIST 69  /* STRING dans l'arbre FORM_MESSAGES */

#define FORM_PRINT 18  /* Formulaire/Dialogue */
#define PRINT_GROUP 1   /* BOX dans l'arbre FORM_PRINT */
#define PRINT_PAGE 2   /* BOX dans l'arbre FORM_PRINT */
#define PRINT_IMAGE 3   /* BOX dans l'arbre FORM_PRINT */
#define PRINT_XPCMOINS 6   /* BUTTON dans l'arbre FORM_PRINT */
#define PRINT_YPCMOINS 7   /* BUTTON dans l'arbre FORM_PRINT */
#define PRINT_XPC 9   /* FBOXTEXT dans l'arbre FORM_PRINT */
#define PRINT_YPC 10  /* FBOXTEXT dans l'arbre FORM_PRINT */
#define PRINT_OK 13  /* BUTTON dans l'arbre FORM_PRINT */
#define PRINT_XPCPLUS 14  /* BUTTON dans l'arbre FORM_PRINT */
#define PRINT_YPCPLUS 15  /* BUTTON dans l'arbre FORM_PRINT */
#define PRINT_SIZEX 16  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_SIZEY 17  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_RESOL 18  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_CANCEL 23  /* BUTTON dans l'arbre FORM_PRINT */
#define PRINT_SIZEPAGEW 24  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_CONFIGPAGE 25  /* BOXTEXT dans l'arbre FORM_PRINT */
#define PRINT_SIZEPAGEH 28  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_ID 29  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_TYPE 32  /* BOXTEXT dans l'arbre FORM_PRINT */
#define PRINT_PRINTER 34  /* BOXTEXT dans l'arbre FORM_PRINT */
#define PRINT_CENTREY 36  /* BOX dans l'arbre FORM_PRINT */
#define PRINT_CENTREX 37  /* BOX dans l'arbre FORM_PRINT */
#define PRINT_R90 38  /* BOX dans l'arbre FORM_PRINT */
#define PRINT_KEEPRATIO 39  /* BOX dans l'arbre FORM_PRINT */
#define PRINT_TKEEPRATIO 40  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_TCENTREY 41  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_TCENTREX 42  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_TR90 43  /* TEXT dans l'arbre FORM_PRINT */
#define PRINT_FILE 45  /* BOXTEXT dans l'arbre FORM_PRINT */

#define FORM_EXPORT 19  /* Formulaire/Dialogue */
#define EXPORT_XIMG 3   /* STRING dans l'arbre FORM_EXPORT */
#define EXPORT_GIF 4   /* STRING dans l'arbre FORM_EXPORT */
#define EXPORT_TIFF 5   /* STRING dans l'arbre FORM_EXPORT */
#define EXPORT_TIFFLZW 6   /* STRING dans l'arbre FORM_EXPORT */
#define EXPORT_OK 8   /* BUTTON dans l'arbre FORM_EXPORT */
#define EXPORT_CANCEL 9   /* BUTTON dans l'arbre FORM_EXPORT */
