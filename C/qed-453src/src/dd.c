#include <limits.h>

#include "global.h"
#include "comm.h"
#include "dd.h"
#include "edit.h"
#include "file.h"
#include "find.h"
#include "icon.h"
#include "memory.h"
#include "projekt.h"
#include "rsc.h"
#include "text.h"
#include "window.h"


/* exportierte Variablen *****************************************************/
PATH	drag_filename;		/* Dateiname/Pfad wurde gedragged */
char	*drag_data;			/* Daten wurden gedragged */
long	drag_data_size;	/* Die L„nge der Daten */


/* DD Empfang ****************************************************************/

static int parse_ARGS(char *str)
{
	int		cnt = 1;
	char 	*c = str;
	bool	in_quote = FALSE;

	while (*c)
	{
		switch (*c)
		{
			case ' ' :
				if (!in_quote)
				{
					*c = '\0';
					cnt++;
				}
				break;
			case '\'' :
				strcpy(c, c + 1);
				if (!in_quote)
					in_quote = TRUE;
				else
				{
					if (*c != '\'')
					{
						in_quote = FALSE;
						*c = 0;
						if (c[1])
							cnt++;
					}
				}
				break;
			default:
				break;
		} /* switch */
		c += 1;
	} /* while */
	return cnt;
}


static int rel_path(char *path, bool cs, char *sub_path)
{
	int	l;
	char	p1[256];
	
	split_filename(path, p1, NULL);
	l = (int)strlen(p1);
	if (cs)
	{
		if (strncmp(p1, sub_path, l) == 0)
			return l;
	}
	else
	{
		if (strnicmp(p1, sub_path, l) == 0)
			return l;
	}
	return 0;
}

/* Werte vom Popup */
#define DRAG_PATHNAME	0
#define DRAG_PATH			1
#define DRAG_NAME			2
#define DRAG_RELPATH		3
#define DRAG_INHALT		4

static void insert(WINDOWP w, int mode, bool shift, char *filename)
{
	int	icon;

	make_normalpath(filename);

	if (w->class == CLASS_PROJEKT)
	{
		strcpy(drag_filename, filename);
		if (filename[strlen(filename) - 1] == '\\')			/* Pfad */
			icon_drag(w->handle, DRAGDROP_PATH);				/*  -> Datei suchen */
		else																/* Datei */
			icon_drag(w->handle, DRAGDROP_FILE);				/*  -> einfgen */
	}
	else
	{
		if (filename[strlen(filename) - 1] == '\\')			/* Pfad */
			mode = DRAG_PATHNAME;

		if (mode == DRAGDROP_PATH)
		{
			if (!shift && filematch(filename, "*.QPJ", -1))
				icon = load_projekt(filename);
			else
				icon = load_edit(filename, FALSE);
			if (icon > 0)
				send_dhst(filename);
		}
		else
		{
			TEXTP	t_ptr;
			int	i;

			switch (mode)
			{
				case DRAG_PATHNAME :
					strcpy(drag_filename, filename);
					icon_drag(w->handle, DRAGDROP_PATH);
					break;
	
				case DRAG_PATH :
					split_filename(filename, drag_filename, NULL);
					icon_drag(w->handle, DRAGDROP_PATH);
					break;
					
				case DRAG_NAME :
					split_filename(filename, NULL, drag_filename);
					icon_drag(w->handle, DRAGDROP_PATH);
					break;
	
				case DRAG_RELPATH :
					t_ptr = get_text(w->handle);
					if (t_ptr && !t_ptr->namenlos)
					{
						i = rel_path(t_ptr->filename, (t_ptr->filesys == FULL_CASE), filename);
						strcpy(drag_filename, filename + i);
						icon_drag(w->handle, DRAGDROP_PATH);
					}
					break;
					
				case DRAG_INHALT :
					strcpy(drag_filename, filename);
					icon_drag(w->handle, DRAGDROP_FILE);
					break;

				default:
					debug("dd.c,insert: unbekanter mode %d\n", mode);
					break;
			}
		}
	}
}


static void parse(char *cmdline, WINDOWP w, int kstate)
{
	int	comps = parse_ARGS(cmdline);
	char	*c = cmdline;
	int	i, mode = DRAGDROP_PATH;
	bool	shift;
	
	shift = (kstate & (K_LSHIFT|K_RSHIFT));
	
	if (w->class == CLASS_EDIT && (kstate & K_ALT))
	{
		i = handle_popup(NULL, 0, popups, DRAGPOP, POP_OPEN);
		switch (i)
		{
			case DPALL :
				mode = DRAG_PATHNAME;
				break;

			case DPPATH :
				mode = DRAG_PATH;
				break;
				
			case DPNAME :
				mode = DRAG_NAME;
				break;

			case DPRELPATH :
				mode = DRAG_RELPATH;
				break;

			case DPINHALT :
				mode = DRAG_INHALT;
				break;

			default:
				Bconout(2, 7);
				return;
		}
	}

	drag_data_size = comps;			/* Anzahl der ARGS merken */
	while (comps - 1)
	{
		insert(w, mode, shift, c);
		c += strlen(c) +1;
		comps--;
	}
	insert(w, mode, shift, c);
}

void	handle_dd(int *msg)
{
	WINDOWP 	w_dest = get_window(msg[3]);
	int		fd;
	long		size;
	char 		ext[5],
				fname[PATH_MAX],
				ourexts[DD_EXTSIZE] = "ARGS.TXT";

	if (w_dest != NULL)
	{
		fd = (int)dd_open(msg[7], ourexts);
		if (fd < 0)
			return ;

		do
		{
			if (!dd_rtry(fd, fname, ext, &size))
			{
				dd_close(fd);
				return;
			}
			if (!strncmp(ext, "ARGS", 4))
			{
				char	*cmdline = malloc(size +1);

				if (!cmdline)
				{
					dd_reply(fd, DD_LEN);
					continue;
				}
				dd_reply(fd, DD_OK);
				Fread((int) fd, size, cmdline);
				dd_close(fd);
				cmdline[size] = 0;
				parse(cmdline, w_dest, msg[6]);
				free(cmdline);
				drag_data_size = 0;
				return ;
			}
			if (strncmp(ext, ".TXT", 4) == 0 )
			{
#if 0
				drag_data = malloc(size + 1);
				/* ^^ wird nach dem Einfgen in edit.c wieder freigegeben! */
				drag_data_size = size;
				if (drag_data == NULL)
				{
					dd_reply(fd, DD_LEN);
					continue;
				}
				dd_reply(fd, DD_OK);
				Fread((int) fd, drag_data_size, drag_data);
				dd_close(fd);
				drag_data[drag_data_size] = 0;
#else
				RING	t;
				
				init_textring(&t);
				dd_reply(fd, DD_OK);
				load_from_fd(fd, "", &t, FALSE, NULL, size);			
				dd_close(fd);
				drag_data_size = DDS_RINGP;
				drag_data = (char *)&t;
/*				kill_textring(&t); wird in edit.c wieder freigegeben! */
#endif
				icon_drag(w_dest->handle, DRAGDROP_DATA);
				return ;
			}
		}
		while (dd_reply(fd, DD_EXT));
	}
}


void	handle_avdd(int win_handle, int kstate, char *arg)
{
	WINDOWP 	w_dest = get_window(win_handle);
	char		*cmdline;
	
	if (w_dest != NULL)
	{
		cmdline = (char *) malloc(strlen(arg));
		strcpy(cmdline, arg);
		parse(cmdline, w_dest, kstate);
		free(cmdline);
	}
}


/* DD Senden *****************************************************************/

void send_dd(int win_id, int m_x, int m_y, int kstate, RINGP t)
{
	int	i, d;
	
	/* gibts WF_OWNER? */
	if ((appl_xgetinfo(11, &i, &d, &d, &d)) && (i & 16)) 
	{
		int	pipe, app_id;
		char	ext[33];
		
		wind_get(win_id, WF_OWNER, &app_id, &d, &d, &d);
	
		pipe = dd_create(app_id, win_id, m_x, m_y, kstate, ext);
		if (pipe > 0)
		{
			long	len;
	
			len = textring_bytes(t);
			d = dd_stry(pipe, ".TXT", "Text", len);
			if (d == DD_OK)
				save_to_fd(pipe, "", t, FALSE);
			dd_close(pipe);
		}
	}
	else
		note(1, 0, WFOWNERR);
}
