#include "global.h"
#include "av.h"
#include "comm.h"
#include "dd.h"
#include "options.h"
#include "poslist.h"
#include "rsc.h"
#include "window.h"

/* exportierte Variablen *****************************************************/
int	av_shell_id = -1,				/* ID des Desktops */
		av_shell_status = 0;			/* Welche AV_* kann Desktop */

/* lokale Variablen **********************************************************/

/* Hilfe-System **************************************************************/

#ifndef AC_HELP
#define AC_HELP		1025
#endif

/*
 * Generiert aus einem Pfadnamen den GEM-Namen (max. acht Zeichen, ggf.
 * mit ' ' aufgefÅllt) und ÅberprÅft ihn auf ST-GUIDE.
*/
static bool make_name(char *longname, char *shortname, bool must_stg)
{
	int	len, i;
	char	*p;

	if (longname[0] == EOS)
	{
		note(1, 0, NOHELP);
		strcpy(shortname, "");
		return FALSE;
	}
	else
	{
		file_name(longname, shortname, FALSE);
		str_toupper(shortname);
		p = strrchr(shortname, '.');				/* Extension abschneiden */
		*p = '\0';
		len = (int) strlen(shortname);
		for (i = len; i < 8; i++)
			strcat(shortname, " ");
		if (must_stg && (strcmp(shortname, "ST-GUIDE") != 0))
		{
			note(1, 0, NOSTG);
			return FALSE;
		}
		else
			return TRUE;
	}
}


/*
 * Liefert die app_id des Åbergebenen Programmes zurÅck. Falls es noch
 * nicht lÑuft, wird es mit arg gestartet.
*/
static int get_id(char* name, char *path, char *arg, bool *started)
{
	int		ret = -1;
	char		*p, help[128] = "";
	bool	s = FALSE;

	if (name[0] != EOS)
	{
		ret = appl_find(name);
		if (ret < 0)							/* ggf. als Programm nachstarten */
		{
			if (arg != NULL)
			{
				strcpy(help, " ");
				strcat(help, arg);
				help[0] = (char)strlen(help);
			}
			p = strrchr(path, '.');
			if (file_exists(path) && (strnicmp(p, ".app", 3) == 0 || strncmp(p, ".prg", 3) == 0))
			{
				if (gl_gem >= 0x400)
				{
					ret = shel_write(1, 1, 1, path, help);
					s = (ret > 0);
				}
				else if (gl_magx)
				{
					ret = shel_write(1, 1, 100, path, help);
					s = (ret > 0);
				}
				else
				{
					note(1, 0, HELPSTART);
					ret = -1;
				}
			}
			else
			{
				snote(1, 0, HELPNOTF, helpprog);
				ret = - 1;
			}
		}
	}
	if (started != NULL)
		*started = s;
	return ret;
}

static void send_help(int id, char *str)
{
	if (debug_level & DBG_AV)
		debug("send_help: '%s' to %d\n", str, id);
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = AC_HELP;
	msgbuff[1] = gl_apid;
	strcpy(global_str1, str);
	*(char **)(msgbuff + 3) = global_str1;
	send_msg(id);
}

bool call_help(char *str)
{
	int		help_id;
	FILENAME	name;

	wake_mouse();
	if (make_name(helpprog, name, FALSE))
	{
		help_id = get_id(name, helpprog, NULL, NULL);
		if (help_id > 0)
		{
			send_help(help_id, str);
			return TRUE;
		}
	}
	return FALSE;
}

bool call_hyp(char *data)
{
	int		stg_id;
	char 		help[80];
	FILENAME name;
	bool		started;

	if (helpprog[0] == EOS)
	{
		note(1, 0, NOHELP);
		return FALSE;
	}
	wake_mouse();
	if (make_name(helpprog, name, TRUE))
	{
		strcpy(help, "*:\\qed.hyp ");
		strcat(help, data);

		stg_id = get_id(name, helpprog, help, &started);
		if (debug_level & DBG_AV)
			debug("call_hyp: '%s' to %d\n", data, stg_id);
		if (stg_id > 0 && !started)			/* nicht gestartet, da es bereits lief! */
			send_vastart(stg_id, help);		/* -> also Message schicken */
		return (stg_id > 0);
	}
	return FALSE;
}


static void get_my_name(char *my_name)
{
	char	str[12];
	int	d, i, id;

	if ((appl_xgetinfo(4, &d, &d, &i, &d)) && (i == 1))	/* gibts appl_search? */
	{
		i = appl_search(0, str, &d, &id);
		while (i != 0)
		{
			if (id == gl_apid)
				break;
			i = appl_search( 1, str, &d, &id);
		}
	}
	if (i != 0)
	{
		strcpy(my_name, str);
		for (i = (int)strlen(my_name); i < 8; i++)
			strcat(my_name, " ");
	}
	else
		strcpy(my_name, "");
	if	(debug_level & DBG_AV)
		debug("get_my_name()= %s.\n", my_name);
}

/* AV-Protokoll **************************************************************/

static char	*glob_data = NULL;

static void send_avprot(void)
{
	if (av_shell_id >= 0)
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_PROTOKOLL;
		msgbuff[1] = gl_apid;
		msgbuff[3] = (2|16);		/* VA_START, Quoting */
		get_my_name(global_str1);
		*(char **) (msgbuff + 6) = global_str1;
		send_msg(av_shell_id);
		if (debug_level & DBG_AV)
			debug("AV_PROTOKOLL\n");
	}
}

static void send_avexit(void)
{
	if ((av_shell_id >= 0) && (av_shell_status & 1024))
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_EXIT;
		msgbuff[1] = gl_apid;
		msgbuff[3] = gl_apid;
		send_msg(av_shell_id);
		if (debug_level & DBG_AV)
			debug("AV_EXIT\n");
	}
}

bool send_avkey(int ks, int kr)
{
	bool	b = FALSE;

	if ((av_shell_id >= 0) && (av_shell_status & 1))
	{
		wake_mouse();
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_SENDKEY;
		msgbuff[1] = gl_apid;
		msgbuff[3] = ks;
		msgbuff[4] = kr;
		b = send_msg(av_shell_id);
		if (debug_level & DBG_AV)
			debug("AV_SENDKEY (%d,%d)\n", ks, kr);
	}
	return b;
}

void send_avwinopen(int handle)
{
	if ((av_shell_id >= 0) && (wind_cycle))	/* Fensterwechsel global */
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_ACCWINDOPEN;
		msgbuff[1] = gl_apid;
		msgbuff[3] = handle;
		send_msg(av_shell_id);
		if (debug_level & DBG_AV)
			debug("AV_ACCWINDOPEN (%d)\n", handle);
	}
}

void send_avwinclose(int handle)
{
	if ((av_shell_id >= 0) && (wind_cycle))	/* Fensterwechsel global */
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_ACCWINDCLOSED;
		msgbuff[1] = gl_apid;
		msgbuff[3] = handle;
		send_msg(av_shell_id);
		if (debug_level & DBG_AV)
			debug("AV_ACCWINDCLOSED (%d)\n", handle);
	}
}

void send_avdrag(int wh, int m_x, int m_y, int kstate, int data_type)
{
	if ((av_shell_id >= 0) && (av_shell_status & 512))
	{
		int	app, d;
		
		wind_get(wh, WF_OWNER, &app, &d, &d, &d);
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_DRAG_ON_WINDOW;
		msgbuff[1] = gl_apid;
		msgbuff[3] = m_x;
		msgbuff[4] = m_y;
		msgbuff[5] = kstate;

		switch (data_type)
		{
			case DRAGDROP_PATH :		/* ein Name */
				if (debug_level & DBG_AV)
					debug("AV_DRAG_TO_WIN single file\n");
				strcpy(global_str1, drag_filename);
				*(char **) (msgbuff + 6) = global_str1;
				break;

			case DRAGDROP_DATA :		/* mehrere Namen */
				if (debug_level & DBG_AV)
					debug("AV_DRAG_TO_WIN multible files\n");
				glob_data = malloc_global(drag_data_size + 1);
				if (glob_data != NULL)
				{
					strcpy(glob_data, drag_data);
					*(char **) (msgbuff + 6) = glob_data;
				}
				break;
		}
		send_msg(av_shell_id);
	}
}

int check_avobj(int x, int y)
{
	int	ret = 0;
		
	if (av_shell_id >= 0)
	{
		memset(msgbuff, 0, (int)sizeof(msgbuff));
		msgbuff[0] = AV_WHAT_IZIT;
		msgbuff[3] = x;
		msgbuff[4] = y;
		
		send_msg(av_shell_id);
		evnt_mesag(msgbuff);
		if (msgbuff[0] == VA_THAT_IZIT)
		{
			ret = msgbuff[4];
			if (debug_level & DBG_AV)
				debug("VA_THAT_IZIT(%d, %d): %d\n", x, y, ret);
		}
	}
	return ret;
}

static void send_avstarted(int id, int m3, int m4)
{
	memset(msgbuff, 0, (int)sizeof(msgbuff));
	msgbuff[0] = AV_STARTED;
	msgbuff[3] = m3;
	msgbuff[4] = m4;
	if (debug_level & DBG_AV)
		debug("AV_STARTED (%d)\n", id);
	send_msg(id);
}

/*
 * Zerlegt VA_START-Arg in einzelne Dateinamen.
 * Quoting wird korrekt ausgewertet ('arg 1', 'arg''s')
*/
static bool parse_vaarg(POSENTRY **list, char *arg)
{
	int		i, j, len;
	PATH		filename;
	bool	in_quote = FALSE;
	
	len = (int)strlen(arg);
	if (len > 0)
	{
		i = 0;
		j = 0;
		strcpy(filename, "");
		while (i < len)
		{
			if (arg[i] == '\'')
			{
				i++;
				if (in_quote)
				{
					if (arg[i] == '\'')					/* Doppeltes ' */
					{
						filename[j++] = '\'';
						i++;
					}
					else
						in_quote = FALSE;
				}
				else
					in_quote = TRUE;
			}
			if ((arg[i] != ' ') || ((arg[i] == ' ' && in_quote)))
				filename[j++] = arg[i++];
			else
			{
				filename[j++] = '\0';
				insert_poslist(list, filename, 0, 0);
				j = 0;
				i++; 
			}
		}
		if (j > 0)
		{
			filename[j++] = '\0';
			insert_poslist(list, filename, 0, 0);
		}
		return TRUE;
	}
	return FALSE;
}


void handle_av(int msgbuff[])
{
	char		*str_p, *arg;
	int		kstate, d;
	POSENTRY	*va_list = NULL;

	switch (msgbuff[0])
	{
		case VA_START :
			if (all_iconified)
				all_uniconify(NULL, NULL);
			str_p = *(char **)(msgbuff + 3);
			if (str_p != NULL)
			{
				arg = strdup(str_p);
				send_avstarted(msgbuff[1], msgbuff[3], msgbuff[4]);

				if ((debug_level & DBG_AV) || (debug_level & DBG_ARG))
					debug("VA_START %s\n", arg);

				if (strlen(arg) > 0 && parse_vaarg(&va_list, arg))
				{
					if (debug_level & DBG_AV)
						debug("va_arg= %s\n", str_p);
					open_poslist(va_list);
					delete_poslist(&va_list);
				}
				free(arg);
			}
			break;

		case VA_PROTOSTATUS :
			if (debug_level & DBG_AV)
				debug("VA_PROTSTATUS %u\n", (unsigned short)msgbuff[3]);
			av_shell_status = msgbuff[3];
			if (wind_cycle && !(av_shell_status & 64))
				wind_cycle = FALSE;			/* glob. Fensterwechsel abschalten */
			break;

		case VA_DRAG_COMPLETE :
			if (debug_level & DBG_AV)
				debug("VA_DRAG_COMPLETE.\n");
			if (glob_data != NULL)
			{
				free(glob_data);
				glob_data = NULL;
			}
			break;

		case VA_DRAGACCWIND :				/* bei D&D mit glob. Fensterwechsel */
			str_p = *(char **)(msgbuff + 6);
			if (str_p != NULL)
			{
				graf_mkstate(&d, &d, &d, &kstate);
				handle_avdd(msgbuff[3], kstate, str_p);
			}
			break;

		case AV_SENDKEY :
			if (debug_level & DBG_AV)
				debug("AV_SENDKEY von %d: %d, %d\n", msgbuff[1], msgbuff[3], msgbuff[4]);
			if ((msgbuff[3] == 4) && (msgbuff[4] == 0x1117))	/* ^W */
				cycle_window();
			break;
			
		default:
			break;
	}
}

void init_av(void)
{
	int	i;
	char	name[9], *p;

	p = getenv("AVSERVER");
	if (p != NULL)
	{
		strncpy(name, p, 8);
		name[8] = EOS;
		for (i = (int)strlen(name); i < 8; i++)
			strcat(name, " ");
		i = appl_find(name);
		if (i >= 0)
			av_shell_id = i;
	}
	if (debug_level & DBG_AV)
		debug("av_shell_id= %d\n", av_shell_id);

	send_avprot();
}

void term_av(void)
{
	send_avexit();
}
