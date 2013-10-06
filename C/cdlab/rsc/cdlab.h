/*
 * cdlab.h - Indice du ressource pour CDLAB
 *
 * Copyright 2004 Francois Galea
 *
 * This file is part of CDLab.
 *
 * CDLab is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CDLab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#define MENU1    0   /* Arbre menu */
#define M_INFO   10  /* STRING dans l'arbre MENU1 */
#define M_ERASE  19  /* STRING dans l'arbre MENU1 */
#define M_COPY   20  /* STRING dans l'arbre MENU1 */
#define M_MASTER 21  /* STRING dans l'arbre MENU1 */
#define M_TOCREAD 22  /* STRING dans l'arbre MENU1 */
#define M_RESCAN 24  /* STRING dans l'arbre MENU1 */
#define M_QUIT   26  /* STRING dans l'arbre MENU1 */
#define M_DEVICES 28  /* STRING dans l'arbre MENU1 */
#define M_PREFS  29  /* STRING dans l'arbre MENU1 */
#define M_CLOSE  31  /* STRING dans l'arbre MENU1 */
#define M_UNTOP  32  /* STRING dans l'arbre MENU1 */
#define M_HELP_CDLAB 34  /* STRING dans l'arbre MENU1 */
#define M_HELP_CONTEXT 35  /* STRING dans l'arbre MENU1 */
#define M_HELP_INDEX 37  /* STRING dans l'arbre MENU1 */

#define INFO_BOX 1   /* Formulaire/Dialogue */
#define IB_REGTXT 7   /* TEXT dans l'arbre INFO_BOX */
#define IB_INFO  8   /* BUTTON dans l'arbre INFO_BOX */
#define IB_REG   9   /* BUTTON dans l'arbre INFO_BOX */
#define IB_OK    10  /* BUTTON dans l'arbre INFO_BOX */

#define INFO2_BOX 2   /* Formulaire/Dialogue */
#define I2B_OK   10  /* BUTTON dans l'arbre INFO2_BOX */

#define COPY_BOX 3   /* Formulaire/Dialogue */
#define CB_FD1   1   /* BUTTON dans l'arbre COPY_BOX */
#define CB_SRCTXT 2   /* STRING dans l'arbre COPY_BOX */
#define CB_SOURCE 3   /* BUTTON dans l'arbre COPY_BOX */
#define CB_SRCCYC 4   /* BOXCHAR dans l'arbre COPY_BOX */
#define CB_DSTTXT 5   /* STRING dans l'arbre COPY_BOX */
#define CB_DEST  6   /* BUTTON dans l'arbre COPY_BOX */
#define CB_DSTCYC 7   /* BOXCHAR dans l'arbre COPY_BOX */
#define CB_WSTXT 8   /* STRING dans l'arbre COPY_BOX */
#define CB_SPEED 9   /* BUTTON dans l'arbre COPY_BOX */
#define CB_SPDCYC 10  /* BOXCHAR dans l'arbre COPY_BOX */
#define CB_ACTTXT 11  /* STRING dans l'arbre COPY_BOX */
#define CB_SIMUL 12  /* BUTTON dans l'arbre COPY_BOX */
#define CB_WR    13  /* BUTTON dans l'arbre COPY_BOX */
#define CB_FD2   14  /* BUTTON dans l'arbre COPY_BOX */
#define CB_USEHD 15  /* BUTTON dans l'arbre COPY_BOX */
#define CB_INTTEXT 16  /* STRING dans l'arbre COPY_BOX */
#define CB_INTFILE 17  /* BUTTON dans l'arbre COPY_BOX */
#define CB_INTDEL 18  /* BUTTON dans l'arbre COPY_BOX */
#define CB_ONG1  19  /* BUTTON dans l'arbre COPY_BOX */
#define CB_ONG2  20  /* BUTTON dans l'arbre COPY_BOX */
#define CB_CANCEL 21  /* BUTTON dans l'arbre COPY_BOX */
#define CB_OK    22  /* BUTTON dans l'arbre COPY_BOX */
#define CB_COPY  23  /* BUTTON dans l'arbre COPY_BOX */

#define OPT_BOX  4   /* Formulaire/Dialogue */
#define OB_FD1   1   /* BUTTON dans l'arbre OPT_BOX */
#define OB_INFO_NONE 3   /* BUTTON dans l'arbre OPT_BOX */
#define OB_INFO_RBUT 4   /* BUTTON dans l'arbre OPT_BOX */
#define OB_INFO_TEMP 5   /* BUTTON dans l'arbre OPT_BOX */
#define OB_VALUE_TEMP 6   /* FTEXT dans l'arbre OPT_BOX */
#define OB_PREEMP 7   /* BUTTON dans l'arbre OPT_BOX */
#define OB_FD2   8   /* BUTTON dans l'arbre OPT_BOX */
#define OB_IGNERR 9   /* BUTTON dans l'arbre OPT_BOX */
#define OB_INTERR 10  /* BUTTON dans l'arbre OPT_BOX */
#define OB_RELECVALS 11  /* STRING dans l'arbre OPT_BOX */
#define OB_RELECVAL 12  /* FTEXT dans l'arbre OPT_BOX */
#define OB_FD3   13  /* BUTTON dans l'arbre OPT_BOX */
#define OB_LOG   14  /* BUTTON dans l'arbre OPT_BOX */
#define OB_LOG_TEXT 15  /* STRING dans l'arbre OPT_BOX */
#define OB_LOGFILE 16  /* BUTTON dans l'arbre OPT_BOX */
#define OB_FLUSHLOG 17  /* BUTTON dans l'arbre OPT_BOX */
#define OB_FD4   18  /* BUTTON dans l'arbre OPT_BOX */
#define OB_EJECTSRC 19  /* BUTTON dans l'arbre OPT_BOX */
#define OB_EJECTDST 20  /* BUTTON dans l'arbre OPT_BOX */
#define OB_TIMEOUTS 21  /* STRING dans l'arbre OPT_BOX */
#define OB_TIMEOUT 22  /* FTEXT dans l'arbre OPT_BOX */
#define OB_ONG1  23  /* BUTTON dans l'arbre OPT_BOX */
#define OB_ONG2  24  /* BUTTON dans l'arbre OPT_BOX */
#define OB_ONG3  25  /* BUTTON dans l'arbre OPT_BOX */
#define OB_ONG4  26  /* BUTTON dans l'arbre OPT_BOX */
#define OB_CANCEL 27  /* BUTTON dans l'arbre OPT_BOX */
#define OB_OK    28  /* BUTTON dans l'arbre OPT_BOX */

#define PROC_BOX 5   /* Formulaire/Dialogue */
#define PB_STATUS 1   /* STRING dans l'arbre PROC_BOX */
#define PB_PROGBACK 2   /* BOX dans l'arbre PROC_BOX */
#define PB_PROGBAR 3   /* BOX dans l'arbre PROC_BOX */
#define PB_ELATIME 5   /* STRING dans l'arbre PROC_BOX */
#define PB_REMTIME 7   /* STRING dans l'arbre PROC_BOX */
#define PB_ESC   8   /* TEXT dans l'arbre PROC_BOX */
#define PB_CANCEL 9   /* BUTTON dans l'arbre PROC_BOX */

#define ERASE_BOX 6   /* Formulaire/Dialogue */
#define EB_ERASE 2   /* BUTTON dans l'arbre ERASE_BOX */
#define EB_COMP  4   /* BUTTON dans l'arbre ERASE_BOX */
#define EB_CANCEL 5   /* BUTTON dans l'arbre ERASE_BOX */
#define EB_MINI  6   /* BUTTON dans l'arbre ERASE_BOX */
#define EB_OK    7   /* BUTTON dans l'arbre ERASE_BOX */

#define REG_BOX  7   /* Formulaire/Dialogue */
#define RB_NAME  3   /* FTEXT dans l'arbre REG_BOX */
#define RB_KEY   5   /* FTEXT dans l'arbre REG_BOX */
#define RB_REGINFO 6   /* STRING dans l'arbre REG_BOX */
#define RB_CANCEL 7   /* BUTTON dans l'arbre REG_BOX */
#define RB_OK    8   /* BUTTON dans l'arbre REG_BOX */

#define DEV_BOX  8   /* Formulaire/Dialogue */
#define DB_FD1   1   /* BUTTON dans l'arbre DEV_BOX */
#define DB_RDUNIT 3   /* BUTTON dans l'arbre DEV_BOX */
#define DB_RDUCYC 4   /* BOXCHAR dans l'arbre DEV_BOX */
#define DB_RDREV 6   /* STRING dans l'arbre DEV_BOX */
#define DB_RDDATE 8   /* STRING dans l'arbre DEV_BOX */
#define DB_RDCDRW 9   /* BUTTON dans l'arbre DEV_BOX */
#define DB_REDETECT 10  /* BUTTON dans l'arbre DEV_BOX */
#define DB_OPEN  11  /* BUTTON dans l'arbre DEV_BOX */
#define DB_AUDIOSTR 12  /* STRING dans l'arbre DEV_BOX */
#define DB_CLOSE 13  /* BUTTON dans l'arbre DEV_BOX */
#define DB_RDSPEED 15  /* STRING dans l'arbre DEV_BOX */
#define DB_FD2   16  /* BUTTON dans l'arbre DEV_BOX */
#define DB_WRUNIT 18  /* BUTTON dans l'arbre DEV_BOX */
#define DB_WRUCYC 19  /* BOXCHAR dans l'arbre DEV_BOX */
#define DB_WRTYPE 21  /* STRING dans l'arbre DEV_BOX */
#define DB_WRTAO 22  /* BUTTON dans l'arbre DEV_BOX */
#define DB_WRDAO 23  /* BUTTON dans l'arbre DEV_BOX */
#define DB_WRCDRW 24  /* BUTTON dans l'arbre DEV_BOX */
#define DB_WRSPEED 26  /* STRING dans l'arbre DEV_BOX */
#define DB_WRRAW 28  /* BUTTON dans l'arbre DEV_BOX */
#define DB_ONG1  29  /* BUTTON dans l'arbre DEV_BOX */
#define DB_ONG2  30  /* BUTTON dans l'arbre DEV_BOX */
#define DB_CANCEL 31  /* BUTTON dans l'arbre DEV_BOX */
#define DB_OK    32  /* BUTTON dans l'arbre DEV_BOX */

#define TRACK_FR 9   /* Formulaire/Dialogue */
#define TF_CK    1   /* BUTTON dans l'arbre TRACK_FR */
#define TF_TNO   3   /* STRING dans l'arbre TRACK_FR */
#define TF_TYPE  5   /* STRING dans l'arbre TRACK_FR */
#define TF_BEGIN 7   /* FTEXT dans l'arbre TRACK_FR */
#define TF_END   9   /* FTEXT dans l'arbre TRACK_FR */

#define TRACK_TB 10  /* Formulaire/Dialogue */
#define TTB_SRCTXT 1   /* STRING dans l'arbre TRACK_TB */
#define TTB_SOURCE 2   /* BUTTON dans l'arbre TRACK_TB */
#define TTB_SRCCYC 3   /* BOXCHAR dans l'arbre TRACK_TB */
#define TTB_EXTRACT 4   /* BUTTON dans l'arbre TRACK_TB */
#define TTB_FORMAT 6   /* BUTTON dans l'arbre TRACK_TB */
#define TTB_FRMTCYC 7   /* BOXCHAR dans l'arbre TRACK_TB */
#define TTB_LOAD 8   /* BUTTON dans l'arbre TRACK_TB */
#define TTB_EJECT 9   /* BUTTON dans l'arbre TRACK_TB */
#define TTB_READTOC 10  /* BUTTON dans l'arbre TRACK_TB */
#define TTB_CANCEL 11  /* BUTTON dans l'arbre TRACK_TB */

#define TAO_BOX  11  /* Formulaire/Dialogue */
#define TB_SRC_TEXT 1   /* STRING dans l'arbre TAO_BOX */
#define TB_SRC_FILE 2   /* BUTTON dans l'arbre TAO_BOX */
#define TB_DEST_TEXT 3   /* STRING dans l'arbre TAO_BOX */
#define TB_DEST  4   /* BUTTON dans l'arbre TAO_BOX */
#define TB_DSTCYC 5   /* BOXCHAR dans l'arbre TAO_BOX */
#define TB_WSTXT 6   /* STRING dans l'arbre TAO_BOX */
#define TB_SPEED 7   /* BUTTON dans l'arbre TAO_BOX */
#define TB_SPDCYC 8   /* BOXCHAR dans l'arbre TAO_BOX */
#define TB_ACTTXT 9   /* STRING dans l'arbre TAO_BOX */
#define TB_SIMUL 10  /* BUTTON dans l'arbre TAO_BOX */
#define TB_WR    11  /* BUTTON dans l'arbre TAO_BOX */
#define TB_CANCEL 12  /* BUTTON dans l'arbre TAO_BOX */
#define TB_OK    13  /* BUTTON dans l'arbre TAO_BOX */
#define TB_START 14  /* BUTTON dans l'arbre TAO_BOX */
