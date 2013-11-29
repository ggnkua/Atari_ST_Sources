/*************************************/
/* SND_TOOL.RSC - Include-File for C */
/*************************************/

#define MMENU 0         /* MENU-Tree */
#define AB_INFO 11        /* G_STRING-Object in Tree MMENU */
#define LOAD_SMP 20       /* G_STRING-Object in Tree MMENU */
#define SAVE_SMP 21       /* G_STRING-Object in Tree MMENU */
#define BATCH 23          /* G_STRING-Object in Tree MMENU */
#define DIR_WORK 24       /* G_STRING-Object in Tree MMENU */
#define QUIT_PRG 26       /* G_STRING-Object in Tree MMENU */
#define DO_LOUD 28        /* G_STRING-Object in Tree MMENU */
#define DO_FILT 29        /* G_STRING-Object in Tree MMENU */
#define DO_OVSM 30        /* G_STRING-Object in Tree MMENU */
#define DO_PACK 31        /* G_STRING-Object in Tree MMENU */
#define DO_CONV 32        /* G_STRING-Object in Tree MMENU */
#define DO_PLAY 34        /* G_STRING-Object in Tree MMENU */
#define OVSM_FRQ 37       /* G_STRING-Object in Tree MMENU */
#define BAD_FRQ 38        /* G_STRING-Object in Tree MMENU */
#define SINK_MAX 39       /* G_STRING-Object in Tree MMENU */
#define FRQ_FLAT 40       /* G_STRING-Object in Tree MMENU */
#define OVSM2 42          /* G_STRING-Object in Tree MMENU */
#define OVSM3 43          /* G_STRING-Object in Tree MMENU */
#define SET_KORR 45       /* G_STRING-Object in Tree MMENU */
#define PCK_FILT 46       /* G_STRING-Object in Tree MMENU */
#define BIT4_P 47         /* G_STRING-Object in Tree MMENU */
#define BIT4 48           /* G_STRING-Object in Tree MMENU */
#define AUSWEICH 49       /* G_STRING-Object in Tree MMENU */
#define RATE 51           /* G_STRING-Object in Tree MMENU */
#define PLY_OVSM 52       /* G_STRING-Object in Tree MMENU */
#define SEL_OUTP 53       /* G_STRING-Object in Tree MMENU */
#define SET_MW 54         /* G_STRING-Object in Tree MMENU */
#define DO_SEQ 56         /* G_STRING-Object in Tree MMENU */
#define AUTOSORT 57       /* G_STRING-Object in Tree MMENU */
#define TST_SEQ 58        /* G_STRING-Object in Tree MMENU */
#define EXT_CMP 60        /* G_STRING-Object in Tree MMENU */
#define EDIT_LST 62       /* G_STRING-Object in Tree MMENU */
#define LOADLIST 63       /* G_STRING-Object in Tree MMENU */
#define SEQ_DB 65         /* G_STRING-Object in Tree MMENU */
#define SAVE_SEQ 66       /* G_STRING-Object in Tree MMENU */

#define SND_INFO 1      /* DIALOG-Tree */
#define DO_STAT 7         /* G_IBOX-Object in Tree SND_INFO */

#define FLT_INFO 2      /* DIALOG-Tree */
#define SLD_BKG 3         /* G_BOX-Object in Tree FLT_INFO */
#define FLT_SLD 4         /* G_BOX-Object in Tree FLT_INFO */
#define SMP_BYTS 7        /* G_STRING-Object in Tree FLT_INFO */
#define FLT_BYTS 8        /* G_STRING-Object in Tree FLT_INFO */
#define CALCTM 9          /* G_STRING-Object in Tree FLT_INFO */

#define AUSG_SEL 3      /* DIALOG-Tree */
#define OT_PSG 4          /* G_STRING-Object in Tree AUSG_SEL */
#define OT_DMA 5          /* G_STRING-Object in Tree AUSG_SEL */
#define OT_DSP 6          /* G_STRING-Object in Tree AUSG_SEL */
#define OP_OK 7           /* G_BUTTON-Object in Tree AUSG_SEL */
#define OP_PSG 8          /* G_BOX-Object in Tree AUSG_SEL */
#define OP_DMA 9          /* G_BOX-Object in Tree AUSG_SEL */
#define OP_DSP 10         /* G_BOX-Object in Tree AUSG_SEL */

#define PLY_SPD 4       /* DIALOG-Tree */
#define KH625 3           /* G_BOX-Object in Tree PLY_SPD */
#define T_625 4           /* G_STRING-Object in Tree PLY_SPD */
#define KH125 5           /* G_BOX-Object in Tree PLY_SPD */
#define T_125 6           /* G_STRING-Object in Tree PLY_SPD */
#define KH25 7            /* G_BOX-Object in Tree PLY_SPD */
#define T_25 8            /* G_STRING-Object in Tree PLY_SPD */
#define KH50 9            /* G_BOX-Object in Tree PLY_SPD */
#define T_50 10           /* G_STRING-Object in Tree PLY_SPD */
#define MAN_SPD 11        /* G_BOX-Object in Tree PLY_SPD */
#define SPD_VAL 12        /* G_FTEXT-Object in Tree PLY_SPD */
#define OV_SEL 15         /* G_BOX-Object in Tree PLY_SPD */

#define PCK_INFO 5      /* DIALOG-Tree */
#define PSLD_BKG 3        /* G_BOX-Object in Tree PCK_INFO */
#define PCK_SLD 4         /* G_BOX-Object in Tree PCK_INFO */
#define PCK_SLEN 6        /* G_STRING-Object in Tree PCK_INFO */
#define PCK_DLEN 7        /* G_STRING-Object in Tree PCK_INFO */
#define PCK_RATE 8        /* G_STRING-Object in Tree PCK_INFO */

#define KORR_SEL 6      /* DIALOG-Tree */
#define KORR_8 4          /* G_BOX-Object in Tree KORR_SEL */
#define KORR_16 5         /* G_BOX-Object in Tree KORR_SEL */
#define KORR_32 6         /* G_BOX-Object in Tree KORR_SEL */
#define KORR_64 10        /* G_BOX-Object in Tree KORR_SEL */
#define KORR_OFF 11       /* G_BOX-Object in Tree KORR_SEL */

#define UPCK_INF 7      /* DIALOG-Tree */

#define ASK_LOAD 8      /* DIALOG-Tree */
#define STE_SND 8         /* G_BOX-Object in Tree ASK_LOAD */
#define ST_SND 10         /* G_BOX-Object in Tree ASK_LOAD */
#define PK_SND 12         /* G_BOX-Object in Tree ASK_LOAD */

#define MIC_WIRE 9      /* DIALOG-Tree */
#define MV_SBKG 8         /* G_BOX-Object in Tree MIC_WIRE */
#define LV_SBKG 11        /* G_BOX-Object in Tree MIC_WIRE */
#define RV_SBKG 15        /* G_BOX-Object in Tree MIC_WIRE */
#define TR_SBKG 17        /* G_BOX-Object in Tree MIC_WIRE */
#define BA_SBKG 20        /* G_BOX-Object in Tree MIC_WIRE */
#define MVOL_SLD 23       /* G_BOXTEXT-Object in Tree MIC_WIRE */
#define LVOL_SLD 24       /* G_BOXTEXT-Object in Tree MIC_WIRE */
#define RVOL_SLD 25       /* G_BOXTEXT-Object in Tree MIC_WIRE */
#define TRB_SLD 26        /* G_BOXTEXT-Object in Tree MIC_WIRE */
#define BASS_SLD 27       /* G_BOXTEXT-Object in Tree MIC_WIRE */
#define MW_OKAY 28        /* G_BUTTON-Object in Tree MIC_WIRE */
#define MW_PLAY 29        /* G_BUTTON-Object in Tree MIC_WIRE */

#define ERROR 10        /* DIALOG-Tree */
#define ERR_1 3           /* G_STRING-Object in Tree ERROR */
#define ERR_2 4           /* G_STRING-Object in Tree ERROR */
#define ERR_OK 5          /* G_BUTTON-Object in Tree ERROR */
#define ERR_CNC 6         /* G_BUTTON-Object in Tree ERROR */

#define DIR_EDIT 11     /* DIALOG-Tree */
#define SEL_PATH 3        /* G_BUTTON-Object in Tree DIR_EDIT */
#define DIR_PATH 4        /* G_STRING-Object in Tree DIR_EDIT */
#define LOAD_TYP 5        /* G_FTEXT-Object in Tree DIR_EDIT */
#define DIR_FILT 7        /* G_BOX-Object in Tree DIR_EDIT */
#define DIR_OVSM 9        /* G_BOX-Object in Tree DIR_EDIT */
#define DIR_PCK 11        /* G_BOX-Object in Tree DIR_EDIT */
#define SAVE_TYP 13       /* G_FTEXT-Object in Tree DIR_EDIT */
#define DIR_CNC 14        /* G_BUTTON-Object in Tree DIR_EDIT */
#define DIR_STRT 15       /* G_BUTTON-Object in Tree DIR_EDIT */

#define CHECK_FM 12     /* DIALOG-Tree */
#define SMP_MAX 4         /* G_STRING-Object in Tree CHECK_FM */
#define SMP_LEN 6         /* G_STRING-Object in Tree CHECK_FM */
#define SMP_FOLL 8        /* G_STRING-Object in Tree CHECK_FM */

#define SEQ_INFO 13     /* DIALOG-Tree */
#define SEQ_BKG 3         /* G_BOX-Object in Tree SEQ_INFO */
#define SEQ_SLD 4         /* G_BOX-Object in Tree SEQ_INFO */
#define SEQ_SMP 6         /* G_STRING-Object in Tree SEQ_INFO */
#define SEQ_DONE 7        /* G_STRING-Object in Tree SEQ_INFO */
#define SEQ_NUM 8         /* G_STRING-Object in Tree SEQ_INFO */

#define SEQ_LST 14      /* DIALOG-Tree */
#define SEQ_1 1           /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_2 2           /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_3 3           /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_4 4           /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_5 5           /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_6 6           /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_SHOW 9        /* G_STRING-Object in Tree SEQ_LST */
#define DEL_SEQ 11        /* G_STRING-Object in Tree SEQ_LST */
#define SEQ_RDW 13        /* G_BOX-Object in Tree SEQ_LST */
#define SEQ_UP 15         /* G_TEXT-Object in Tree SEQ_LST */
#define SEQ_DWN 16        /* G_TEXT-Object in Tree SEQ_LST */
#define SEQ_HEAR 18       /* G_STRING-Object in Tree SEQ_LST */
#define LOAD_PLN 19       /* G_STRING-Object in Tree SEQ_LST */
#define KEEP_SEQ 20       /* G_STRING-Object in Tree SEQ_LST */
#define ADD_LST 23        /* G_STRING-Object in Tree SEQ_LST */
#define DEL_LST 25        /* G_STRING-Object in Tree SEQ_LST */
#define PLAY_LST 27       /* G_STRING-Object in Tree SEQ_LST */
#define LST_RDW 28        /* G_BOX-Object in Tree SEQ_LST */
#define LST_6 29          /* G_STRING-Object in Tree SEQ_LST */
#define LST_5 30          /* G_STRING-Object in Tree SEQ_LST */
#define LST_4 31          /* G_STRING-Object in Tree SEQ_LST */
#define LST_3 32          /* G_STRING-Object in Tree SEQ_LST */
#define LST_2 33          /* G_STRING-Object in Tree SEQ_LST */
#define LST_1 34          /* G_STRING-Object in Tree SEQ_LST */
#define LST_UP 37         /* G_TEXT-Object in Tree SEQ_LST */
#define LST_DWN 38        /* G_TEXT-Object in Tree SEQ_LST */
#define KEEP_PLN 41       /* G_STRING-Object in Tree SEQ_LST */

#define SET_VAL 15      /* DIALOG-Tree */
#define LOUD_VAL 3        /* G_FTEXT-Object in Tree SET_VAL */
#define LOUD_OK 5         /* G_BUTTON-Object in Tree SET_VAL */
#define LOUD_CNC 6        /* G_BUTTON-Object in Tree SET_VAL */

#define SEQ_EDIT 16     /* DIALOG-Tree */
#define SEQ_CNC 1         /* G_BUTTON-Object in Tree SEQ_EDIT */
#define SEQ_OKAY 2        /* G_BUTTON-Object in Tree SEQ_EDIT */
#define SEQ_FILE 4        /* G_FTEXT-Object in Tree SEQ_EDIT */
#define SEQ_NAME 5        /* G_FTEXT-Object in Tree SEQ_EDIT */
#define SEQ_POS 8         /* G_STRING-Object in Tree SEQ_EDIT */
#define SEQ_LEN 9         /* G_STRING-Object in Tree SEQ_EDIT */
#define SEQ_TIME 11       /* G_STRING-Object in Tree SEQ_EDIT */
