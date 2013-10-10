#include "global.h"
#include "edit.h"
#include "comm.h"
#include "file.h"
#include "icon.h"
#include "menu.h"
#include "rsc.h"
#include "text.h"
#include "window.h"
#include "se.h"

/* exprortierte Variablem *****************************************************/
SHELLENTRY se_shells[SHELLANZ];	/* 0 - 4 : qed sucht Shell */
											/* 5		: Shell sucht qed */

bool 	se_activ;				/* haben wir Kontakt zur Shell? */
bool	se_autosave,
		se_autosearch;


/* lokale Variablem **********************************************************/
typedef struct _separm
{
	int	id;
	int	shellCmd;
	int	editCmd;
	int	se_version;
	char	prog_name[25];
} SEPARMS;

static SEPARMS	shell_parm,
					edit_parm;
static int		aktiv;				/* Nummer der aktiven Shell (0..SHELLANZ - 1) */
static int		menu_len;
static long		timer;				/* wird hochgezÑhlt */
static bool		wait_for_answer;	/* TRUE, wenn auf SE_OK/_ACK gewartet wird */
static char		org_menu[8][25];

/*****************************************************************************/
#define WAITTIME	2000				/* Zeit in ms, die qed auf ein SE_ACK wartet */

/* lokale Prototypen */
static void	send_ok(void);
static void	send_ack(bool ok);
static void	send_cmd(int cmd, int bit);
static void	send_esquit(void);


static void	setup_makefile(void)
{
	FILENAME n = "";

	if (se_shells[aktiv].makefile[0] == EOS)
		menu_text(menu, MSMAKEFILE, org_menu[0]);
	else
	{
		file_name(se_shells[aktiv].makefile, n, FALSE);
		fillup_menu(MSMAKEFILE, n, 2);
	}
}


static void set_titel(char *titel)
{
	char str[25] = " ";

	strcat(str, titel);
	strcat(str, " ");
	menu_bar(menu, 0);
	menu[2].ob_width = menu_len + (int)strlen(str) * sys_wbox;
	menu[TSHELL].ob_width = (int)strlen(str) * sys_wbox;
	strcpy(menu[TSHELL].ob_spec.free_string, str);
	menu_bar(menu, 1);
	update_menu();
}

void setup_semenu(void)
{
	int	i;

	if (se_activ)
	{
		setup_makefile();
		set_menu(MSQUIT, TRUE);
		set_menu(MSMAKEFILE, (shell_parm.editCmd & _ESMAKE));
		set_menu(MSCOMP, (shell_parm.editCmd & _ESCOMPILE));
		set_menu(MSMAKE, (shell_parm.editCmd & _ESMAKE));
		set_menu(MSMAKEALL, (shell_parm.editCmd & _ESMAKEALL));
		set_menu(MSLINK, (shell_parm.editCmd & _ESLINK));
		set_menu(MSEXEC, (shell_parm.editCmd & _ESEXEC));
		set_menu(MSMAKEEXEC, (shell_parm.editCmd & _ESMAKEEXEC));
		set_menu(MSSHELL, (shell_parm.editCmd & _ESSHLCTRL));
	}
	else
	{
		for (i = MSQUIT; i <= MSSHELL; i++)
			set_menu(i, FALSE);
	}
}


static void reset_shell_menu(void)
{
	int	i;

	set_titel("Shell");
	menu_text(menu, MSMAKEFILE, org_menu[0]);
	for (i = MSCOMP; i <= MSSHELL; i++)
		menu_text(menu, i, org_menu[i - MSCOMP + 1]);
}


void	timer_se(void)
{
	if (wait_for_answer)
	{
		timer += TIMER_INTERVALL;
		if (timer > WAITTIME)
		{
			timer = 0;
			wait_for_answer = FALSE;
			if (note(2, 0, SENOANS) == 1)
			{
				se_activ = FALSE;
				set_titel("Shell");
			}
		}
	}
}


static void set_timer(void)
{
	timer = 0;
	wait_for_answer = TRUE;
}


static void reset_timer(void)
{
	timer = 0;
	wait_for_answer = FALSE;
}

/* Shell -> Editor ************************************************************/


/* Antwort auf SE_INIT */
static void	send_ok(void)
{
	if (shell_parm.editCmd & _ESOK)
	{
		if (debug_level & DBG_SE)
			debug("sendOK -> %d\n", shell_parm.id);
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = ES_OK;
		msgbuff[1] = edit_parm.id;
		msgbuff[3] = edit_parm.shellCmd;
		msgbuff[5] = edit_parm.editCmd;
		msgbuff[6] = SEPROTOVERSION;
		msgbuff[7] = shell_parm.id;
		send_msg(shell_parm.id);
	}
}


static void	send_ack(bool ok)
{
	if (shell_parm.editCmd & _ESACK)
	{
		if (debug_level & DBG_SE)
			debug("sendAck -> %d\n", shell_parm.id);
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = ES_ACK;
		msgbuff[1] = edit_parm.id;
		msgbuff[3] = ok;
		send_msg(shell_parm.id);
	}
}


void handle_se(int *msg)
{
	PATH 			datei, fehler;
	char			str[9], *p, *p2;
	int			icon, i, d, x;
	long			y;
	ERRINFO		*error;
	SEMENUINFO	*pmenu;

	switch (msg[0])
	{
		case SE_INIT :
			if (debug_level & DBG_SE)
			{
				debug("SE_INIT von %d\n", msg[1]);
				debug("      shellCmd = %d\n", msg[3]);
				debug("      editCmd  = %d\n", msg[5]);
				debug("      version  = 0x%X\n", msg[6]);
			}
			if (se_activ)
				send_esquit();
			shell_parm.id = msg[1];
			shell_parm.shellCmd = msg[3];
			shell_parm.editCmd  = msg[5];
			shell_parm.se_version = msg[6];
			send_ok();
			se_activ = TRUE;

			/* Wir versuchen den GEM-Namen des Senders zu ermitteln */
			if (gl_magx)
			{
				/* MagiC-Special, funkt auch, wenn es kein appl_search gibt */
				sprintf(str, "? %cXXXXX", (char) shell_parm.id);
				str[1] = '\0';
				appl_find(str);
			}
			else
			if ((appl_xgetinfo(4, &d, &d, &i, &d)) && (i == 1))	/* gibts appl_search? */
			{
				int	type, id;

				i = appl_search( 0, str, &type, &id);
				while (i != 0)
				{
					if (type == 2 && id == shell_parm.id)
						break;
					i = appl_search( 1, str, &type, &id);
				}
			}
			else
				strcpy(str, "Shell");

			aktiv = SHELLANZ - 1;
			if ((p = strchr(str, ' ')) != NULL)		/* Blanks am Ende abschneiden */
				*p = EOS;
			for (i = 0; i < SHELLANZ - 1; i++)		/* Shell eine der angemeldeten? -> Makefile */
			{
				if (strcmp(str, se_shells[i].name) == 0)
					aktiv = i;
			}
			if (aktiv == SHELLANZ - 1)					/* Shell nicht angemeldet */
			{
				strcpy(se_shells[aktiv].name, str);
				strcpy(se_shells[aktiv].makefile, "");
			}
			set_titel(se_shells[aktiv].name);
			break;
		case SE_OK		:
			reset_timer();
			if (debug_level & DBG_SE)
			{
				debug("SE_OK von %d\n", msg[1]);
				debug("      shellCmd = %d\n", msg[3]);
				debug("      editCmd  = %d\n", msg[5]);
				debug("      version  = 0x%X\n", msg[6]);
			}
			shell_parm.id		 = msg[1];
			shell_parm.shellCmd = msg[3];
			shell_parm.editCmd  = msg[5];
			shell_parm.se_version = msg[6];
			se_activ = TRUE;
			set_titel(se_shells[aktiv].name);
			break;
		case SE_ACK 	:
			reset_timer();
			if (debug_level & DBG_SE)
				debug("SE_ACK von %d\n", msg[1]);
			break;
		case SE_OPEN	:
			p = *(char **)(msg + 3);
			if (p != NULL)
				strcpy(datei, p);
			if (debug_level & DBG_SE)
			{
				debug("SE_OPEN von %d\n", msg[1]);
				debug("      name = %s\n", datei);
			}
			if (shell_parm.se_version >= 0x102)
			{
				x = msg[7];
				y = (*(long *)(msg + 5));
				if (debug_level & DBG_SE)
				{
					debug("      zeile = %ld\n", y);
					debug("      spalte = %d\n", x);
				}
			}
			send_ack(TRUE);
			if ((strlen(datei) > 0) && file_exists(datei))
			{
				icon = load_edit(datei, FALSE);
				if ((shell_parm.se_version >= 0x102) && (icon > 0) &&
				    (x >= 1) && (y >= 1))
				{
					desire_x = x - 1;
					desire_y = y - 1;
					icon_edit(icon, DO_GOTO);
				}
			}
			break;
		case SE_ERROR :
			error = *(ERRINFO **)(msg + 3);
			if (error != NULL)
			{
				if (debug_level & DBG_SE)
					debug("SE_ERROR von %d\n", msg[1]);
				strcpy(datei, error->errFile);
				strcpy(fehler, error->errMess);
				x = error->errRow;
				y = error->errLine;
			}
			send_ack(TRUE);
			if ((strlen(datei) > 0) && file_exists(datei))
			{
				icon = load_edit(datei, FALSE);
				if (icon > 0)
				{
					char	str[256];

					strcpy(str, rsc_string(ERRORSTR));
					strcat(str, fehler);
					set_info(get_text(icon), str);
					if ((x >= 1) && (y >= 1))
					{
						desire_x = x - 1;
						desire_y = y - 1;
						icon_edit(icon, DO_GOTO);
					}
				}
			}
			break;
		case SE_ERRFILE :
			p = *(char **)(msg + 5);
			p2 = *(char **)(msg + 3);
			if ((p != NULL) && (p2 != NULL))
			{
				strcpy(datei, p);
				strcpy(fehler, p2);
				if (debug_level & DBG_SE)
				{
					debug("SE_ERRFILE von %d\n", msg[1]);
					debug("      name   = %s\n", datei);
					debug("      fehler = %s\n", fehler);
				}
			}
			send_ack(TRUE);
			if ((strlen(datei) > 0) && file_exists(datei))
				icon = load_edit(datei, FALSE);
			if ((strlen(fehler) > 0) && file_exists(fehler))
			{
				icon = load_edit(fehler, FALSE);
				if (icon > 0)
				{
					do_icon(icon, DO_ABAND);
					desire_x = 0;
					desire_y = 0;
					icon_edit(icon, DO_GOTO);
				}
			}
			break;
		case SE_PROJECT :
			p = *(char **)(msg + 3);
			if (p != NULL)
				strcpy(datei, p);
			else
				strcpy(datei, "");
			if (debug_level & DBG_SE)
			{
				debug("SE_PROJECT von %d\n", msg[1]);
				debug("      name = %s\n", datei);
			}
		 	send_ack(TRUE);
			if (file_exists(datei))
			{
				strcpy(se_shells[aktiv].makefile, datei);
				setup_makefile();
			}
		 	break;
		case SE_QUIT :
			if (debug_level & DBG_SE)
				debug("SE_QUIT von %d\n", msg[1]);
			se_activ = FALSE;
			reset_shell_menu();
			break;
		case SE_CLOSE :
			if (shell_parm.se_version >= 0x101)
			{
				p = *(char **)(msg + 3);
				if ((p != NULL) && (strlen(p) > 0))
				{
					strcpy(datei, p);
				 	send_ack(TRUE);
/*
					if (debug_level & DBG_SE)
*/
						debug("SE_CLOSE von %d, Datei: %s, Flag: %d\n", msg[1], datei, msg[5]);
					close_edit(datei, msg[5]);
				}
			}
			else
			{
			 	send_ack(TRUE);
				close_edit("*.*", 1);
			}
		 	break;
		case SE_MENU :
			pmenu = *(SEMENUINFO **)(msg + 3);
			if (pmenu != NULL)
			{
				if (debug_level & DBG_SE)
					debug("SE_MENU von %d\n", msg[1]);

				if ((pmenu->compStr != NULL) && (strlen(pmenu->compStr) > 0))
					fillup_menu(MSCOMP, pmenu->compStr, 2);
				if ((pmenu->makeStr != NULL) && (strlen(pmenu->makeStr) > 0))
					fillup_menu(MSMAKE, pmenu->makeStr, 2);
				if ((pmenu->makeAllStr != NULL) && (strlen(pmenu->makeAllStr) > 0))
					fillup_menu(MSMAKEALL, pmenu->makeAllStr, 2);
				if ((pmenu->linkStr != NULL) && (strlen(pmenu->linkStr) > 0))
					fillup_menu(MSLINK, pmenu->linkStr, 2);
				if ((pmenu->execStr != NULL) && (strlen(pmenu->execStr) > 0))
					fillup_menu(MSEXEC, pmenu->execStr, 2);
				if ((pmenu->makeExecStr != NULL) && (strlen(pmenu->makeExecStr) > 0))
					fillup_menu(MSMAKEEXEC, pmenu->makeExecStr, 2);
				
				if (shell_parm.se_version >= 0x104)
					if ((pmenu->progName != NULL) && (strlen(pmenu->progName) > 0))
						set_titel(pmenu->progName);

				if (shell_parm.se_version >= 0x105)
					if ((pmenu->shellCtrlStr != NULL) && (strlen(pmenu->shellCtrlStr) > 0))
						fillup_menu(MSSHELL, pmenu->shellCtrlStr, 2);

			 	send_ack(TRUE);
			}
			break;
		default:
			break;
	} /* switch */
}


/* Editor -> Shell ************************************************************/


static void	send_esquit(void)
{
	if (debug_level & DBG_SE)
		debug("sendESQUIT -> %d\n", shell_parm.id);
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = ES_QUIT;
	msgbuff[1] = edit_parm.id;
	(void) send_msg(shell_parm.id);
	se_activ = FALSE;
}


static void	send_esinit(int app)
{
	if (debug_level & DBG_SE)
		debug("sendESINIT -> %d\n", app);
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = ES_INIT;
	msgbuff[1] = edit_parm.id;
	msgbuff[3] = edit_parm.shellCmd;
	msgbuff[5] = edit_parm.editCmd;
	msgbuff[6] = SEPROTOVERSION;
	send_msg(app);
}


static void	send_esshlctrl(int flag)
{
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = ES_SHLCTRL;
	msgbuff[1] = edit_parm.id;
	if (global_str1[0] != EOS)
		*(char **) &msgbuff[3] = global_str1;
	else
		*(char **) &msgbuff[3] = NULL;
	msgbuff[5] = flag;
	send_msg(shell_parm.id);
}


static void	send_cmd(int cmd, int bit)
{
	if (shell_parm.editCmd & bit)
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = cmd;
		msgbuff[1] = edit_parm.id;
		if (global_str1[0] != EOS)
			*(char **) &msgbuff[3] = global_str1;
		else
			*(char **) &msgbuff[3] = NULL;
		if (!send_msg(shell_parm.id))
		{
			se_activ = FALSE;
			set_titel("Shell");
			note(1, 2, SENOANS);
			return;
		}
		set_timer();
	}
}

static void get_filename(int icon)
{
	TEXTP 	t_ptr;

	if (icon != -1)
	{
		t_ptr = get_text(icon);
		strcpy(global_str1, t_ptr->filename);
	}
	else
		strcpy(global_str1, "");
}

static bool such_shell(void)
{
	int	i, j;
	char	name[9];

	for (i = 0; i < SHELLANZ - 1; i++)
	{
		strcpy(name, se_shells[i].name);
		if (name[0])
		{
			for (j = (int) strlen(name); j < 8; j++)
				strcat(name, " ");
			j = appl_find(name);
			if (j > 0)
			{
				aktiv = i;
				send_esinit(j);
				set_timer();
				return TRUE;
			}
		}
	}
	return FALSE;
}

static void se_options(void)
{
	int	i, antw;
	char	tmp[30];

	if (se_activ)
	{
		sprintf(tmp, "%s, SE-Version %x", se_shells[aktiv].name, shell_parm.se_version);
		set_string(seoptions, SESTATUS, tmp);
	}
	else
		set_string(seoptions, SESTATUS, "--");
	
	for (i = 0; i < SHELLANZ - 1; i++)
		set_string(seoptions, SENAME1 + i, se_shells[i].name);

	set_state(seoptions, SESAVE, SELECTED, se_autosave);
	set_state(seoptions, SESEARCH, SELECTED, se_autosearch);

	set_flag(seoptions, SEOK, DEFAULT, se_activ);
	set_flag(seoptions, SESUCH, DEFAULT, !se_activ);
	
	antw = simple_mdial(seoptions, SENAME1) & 0x7fff;
	if ((antw == SEOK) || (antw == SESUCH))
	{
		for (i = 0; i < SHELLANZ - 1; i++)
		{
			get_string(seoptions, SENAME1 + i, se_shells[i].name);
			str_toupper(se_shells[i].name);
		}

		se_autosave = get_state(seoptions, SESAVE, SELECTED);
		se_autosearch = get_state(seoptions, SESEARCH, SELECTED);

		if (antw == SESUCH)
		{
			if (se_activ)
			{
				antw = note(2, 0, SEONLINE);
				if (antw == 2)
					return;
				else
				{
					send_esquit();
					set_titel("Shell");
				}
			}
			if (!such_shell())
				note(1, 0, SENOTFOUND);
		}
	}
}

static void do_sesave(WINDOWP window)
{
	if (window != NULL)
	{
		TEXTP	t_ptr;
		
		t_ptr = get_text(window->handle);
		if ((t_ptr!= NULL) && (t_ptr->moved != 0))
			do_icon(window->handle, DO_SAVE);
	}
}

void handle_es(int item)
{
	WINDOWP	window;
	int		top_icon = -1;
	
	if (item == MSOPT)
		se_options();

	if (!se_activ)
		return ;

	window = winlist_top();
	if (window != NULL && window->class == CLASS_EDIT)
		top_icon = window->handle;

	switch (item)
	{
		case MSQUIT :
			send_esquit();
			reset_shell_menu();
			break;

		case MSMAKEFILE:
			if (shift_pressed() && se_shells[aktiv].makefile[0] != EOS)	/* Makefile lîschen */
			{
				se_shells[aktiv].makefile[0] = EOS;
				update_menu();
				if (shell_parm.se_version >= 0x101)
				{
					strcpy(global_str1, "");
					send_cmd(ES_PROJECT, _ESPROJECT);
				}
				break;
			}
			if (select_single(se_shells[aktiv].makefile, "", rsc_string(FINDMKSTR)))
			{
				setup_makefile();
				strcpy(global_str1, se_shells[aktiv].makefile);
				send_cmd(ES_PROJECT, _ESPROJECT);
			}
			break;

		case MSCOMP :
			if (se_autosave)
				do_sesave(window);
			get_filename(top_icon);
			if ((global_str1[0] != EOS) || (shell_parm.se_version >= 0x103))
				send_cmd(ES_COMPILE, _ESCOMPILE);
			break;

		case MSMAKE :
			if (se_autosave)
				do_all_window(CLASS_EDIT, do_sesave);
			strcpy(global_str1, se_shells[aktiv].makefile);
			send_cmd(ES_MAKE, _ESMAKE);
			break;

		case MSMAKEALL :
			if (se_autosave)
				do_all_window(CLASS_EDIT, do_sesave);
			strcpy(global_str1, se_shells[aktiv].makefile);
			send_cmd(ES_MAKEALL, _ESMAKEALL);
			break;

		case MSLINK :
			get_filename(top_icon);
			send_cmd(ES_LINK, _ESLINK);
			break;

		case MSEXEC :
			get_filename(top_icon);
			send_cmd(ES_EXEC, _ESEXEC);
			break;

		case MSMAKEEXEC :
			if (se_autosave)
				do_all_window(CLASS_EDIT, do_sesave);
			strcpy(global_str1, se_shells[aktiv].makefile);
			send_cmd(ES_MAKEEXEC, _ESMAKEEXEC);
			break;

		case MSSHELL :
			if (se_autosave)
				do_sesave(window);
			get_filename(top_icon);
			send_esshlctrl(0);			/* Shell toppen */
			break;

	} /* switch */
}

void	init_se(void)
{
	int	i;

	se_activ = FALSE;
	menu_len = menu[2].ob_width - menu[TSHELL].ob_width;
	set_titel("Shell");

	/* MenÅeintrÑge sichern */
	strcpy(org_menu[0], (char *)get_obspec(menu, MSMAKEFILE));
	for (i = MSCOMP; i <= MSSHELL; i++)
		get_string(menu, i, org_menu[i - MSCOMP + 1]);

	shell_parm.id		 = -1;
	shell_parm.shellCmd = 0;
	shell_parm.editCmd  = 0;

	edit_parm.id 		 = gl_apid;
	edit_parm.shellCmd  = (_SEINIT|_SEOK|_SEACK|_SEQUIT|_SEOPEN|_SEERROR|_SEERRFILE|_SEPROJECT|_SECLOSE|_SEMENU);
	edit_parm.editCmd	 = (_ESINIT|_ESOK|_ESACK|_ESQUIT|_ESCOMPILE|_ESMAKE|_ESMAKEALL|_ESLINK|_ESEXEC|_ESMAKEEXEC|_ESPROJECT|_ESSHLCTRL);

	setup_makefile();

	if (se_autosearch)
		such_shell();
}

void term_se(void)
{
	if (se_activ && (shell_parm.editCmd & _ESQUIT))
		send_esquit();
}
