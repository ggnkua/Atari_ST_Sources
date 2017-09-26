/*------------------------------------------------------------------------*/
/* Optionen bearbeiten																										*/

#include <cflib.h>
#include <stdlib.h>
#include <string.h>

#include "types.h"
#include "event.h"
#include "global.h"
#include "online.h"
#include "itime.h"
#include "setup.h"
#include "version.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

#define CFGNAME	"itime.cnf"
#define MAX_LINE_LEN 1023

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

static char			buffer[MAX_LINE_LEN];
static PATH			cfg = "";
static FILENAME	dsp_name;			/* Name der Display-Datei */
static FILE			*fd;

/*------------------------------------------------------------------------*/
/* Pfad der cfg-Datei ermitteln																						*/

static bool get_cfg_path(void)
{
	bool	found = FALSE;
	PATH	env, p_for_save = "";
	
	if (path_from_env("ITIME", cfg))
	{
		strcat(cfg, CFGNAME);
		strcpy(p_for_save, cfg);
		found = file_exists(cfg);
	}

	if (!gl_debug)
	if (!found && path_from_env("HOME", env))	/* 2. $HOME */
	{
		bool	h = FALSE;
		
		strcpy(cfg, env);
		strcat(cfg, CFGNAME);
		if (p_for_save[0] == EOS)
		{
			h = TRUE;
			strcpy(p_for_save, cfg);
		}
		found = file_exists(cfg);
		if (!found)										/* 2a. $HOME/defaults */
		{
			strcpy(cfg, env);
			strcat(cfg, "defaults\\");
			if (path_exists(cfg))
			{
				strcat(cfg, CFGNAME);
				if (p_for_save[0] == EOS || h)
					strcpy(p_for_save, cfg);
				found = file_exists(cfg);
			}
		}		
	}

	if (!found && gl_appdir[0] != EOS)			/* 3. Startverzeichnis */
	{
		strcpy(cfg, gl_appdir);
		strcat(cfg, CFGNAME);
		if (p_for_save[0] == EOS)
			strcpy(p_for_save, cfg);
		found = file_exists(cfg);
	}

	if (!found && file_exists(CFGNAME))			/* 4. aktuelles Verzeichnis */
	{
		get_path(cfg, 0);
		strcat(cfg, CFGNAME);
		if (p_for_save[0] == EOS)
			strcpy(p_for_save, cfg);
		found = TRUE;
	}

	if (!found)
		strcpy(cfg, p_for_save);

	sprintf(dsp_name, "%04d%04d.iti", gl_desk.g_x + gl_desk.g_w, gl_desk.g_y + gl_desk.g_h);

	return found;
}

/*------------------------------------------------------------------------*/
/******************************************************************************/
/* Dateioperation: Laden																		*/
/******************************************************************************/
void read_cfg_bool(char *str, bool *val)
{
	if (stricmp(str, "TRUE") == 0)
		*val = TRUE;
	if (stricmp(str, "FALSE") == 0)
		*val = FALSE;
}

/*------------------------------------------------------------------------*/

void read_cfg_str(char *str, char *val)
{
	val[0] = EOS;
	if ((str[0] == '"') && (str[1] == '"'))	/* nur "" -> leer */
		return;
	else
	{
		int	len, i, j;
		
		if (str[0] == '"')
		{
			len = (int)strlen(str);
			j = 0;
			i = 1;
			while ((str[i] != '\"') && (i < len))
			{
				if ((str[i] == '\\') && (str[i+1] == '"'))
					i++;
				val[j++] = str[i++];
			}
			val[j] = EOS;
		}
	}
}


/*------------------------------------------------------------------------*/

static void parse_line(char *zeile)
{
	char	var[30], *p;
					
	p = strchr(zeile, '=');
	if (p != NULL)
	{
		strncpy(var, zeile, p-zeile);
		var[p-zeile] = EOS;
		strcpy(buffer, p+1);

		/* Autosave */
		if (strcmp(var, "OnlineX") == 0)
			x_pos=atoi(buffer);
		else if(strcmp(var, "OnlineY") == 0)
			y_pos=atoi(buffer);
		else if(strcmp(var, "RechterRand") == 0)
			rechterRand=atoi(buffer);
		else if(strcmp(var, "Intervall") == 0)
			intervall=atoi(buffer);
		else if(strcmp(var, "Hintergrund") == 0)
			read_cfg_bool(buffer,&hintergrund);


		/* Unbekannte Zeile */
		else
		{
			if (strlen(var) > 28)
				var[28] = EOS;
			snote(1, 0, WRONGINF, var);
		}
	}
	else
	{
		if (strlen(zeile) > 28)
			zeile[28] = EOS;
		snote(1, 0, WRONGINF, zeile);
	}
}

/*------------------------------------------------------------------------*/

void option_load(void)
{
	PATH	tmp;

	if (!get_cfg_path())					/* keine itime.cnf gefunden */
		return;

	fd = fopen(cfg, "r");
	if (fd != NULL)
	{
		/* 1. Zeile auf ID checken */
		fgets(buffer, (int)sizeof(buffer), fd);
		if (strncmp(buffer, "ID=ITime", 8) == 0)
		{
			while (fgets(buffer, (int)sizeof(buffer), fd) != NULL)
			{
				if (buffer[strlen(buffer) - 1] == '\n')
					buffer[strlen(buffer) - 1] = EOS;
				parse_line(buffer);
			}
		}
		else
		{
			/* Zeile kurzhacken */
			if (strlen(buffer) > 28)
				buffer[28] = EOS;
			snote(1, 0, WRONGINF, buffer);
		}
		fclose(fd);
		fd = NULL;

		/* Bildschirm-abhÑngige Parameter laden */
		split_filename(cfg, tmp, NULL);
		strcat(tmp, dsp_name);
		fd = fopen(tmp, "r");
		if (fd != NULL)
		{
			/* 1. Zeile auf ID checken */
			fgets(buffer, (int)sizeof(buffer), fd);
			if (strncmp(buffer, "ID=ITime Auflîung", 17) == 0)
			{
				while (fgets(buffer, (int)sizeof(buffer), fd) != NULL)
				{
					if (buffer[strlen(buffer) - 1] == '\n')
						buffer[strlen(buffer) - 1] = EOS;
					parse_line(buffer);
				}
			}
			else
			{
				/* Zeile kurzhacken */
				if (strlen(buffer) > 28)
					buffer[28] = EOS;
				snote(1, 0, WRONGINF, buffer);
			}

			fclose(fd);
			fd = NULL;
		}
	}
}


/*------------------------------------------------------------------------*/
/**************************************************************************/
/* Dateioperation: Speichern																							*/
/**************************************************************************/

void write_cfg_str(char *var, char *value)
{
	if (strchr(value, '\"') != NULL)	/* " in value fÅhrt zu \" in der Datei */
	{
		int	len, i;

		fprintf(fd, "%s=\"", var);
		len = (int)strlen(value);
		for (i = 0; i < len; i++)
		{
			if (value[i] == '\"')
				fputc('\\', fd);
			fputc(value[i], fd);
		}
		fprintf(fd, "\"\n");
	}
	else
		fprintf(fd, "%s=\"%s\"\n", var, value);
}

/*------------------------------------------------------------------------*/

void write_cfg_int(char *var, int value)
{
	fprintf(fd, "%s=%d\n", var, value);
}

/*------------------------------------------------------------------------*/

void write_cfg_long(char *var, long value)
{
	fprintf(fd, "%s=%ld\n", var, value);
}

/*------------------------------------------------------------------------*/

void write_cfg_bool(char *var, bool bool)
{
	char	str[6];
	
	if (bool)
		strcpy(str, "TRUE");
	else
		strcpy(str, "FALSE");
	fprintf(fd, "%s=%s\n", var, str);
}

/*------------------------------------------------------------------------*/

void option_save(void)
{
	char		tmp[50];

	fd = fopen(cfg, "w");
	if (fd != NULL)
	{
		/* ID zur identifizierung */
		fprintf(fd, "ID=ITime %s\n", ITIME_VERSION);
		write_cfg_int("Intervall", intervall);
	
		fclose(fd);
		fd = NULL;

		/* Bildschirm-abhÑngige Parameter sichern */
		split_filename(cfg, tmp, NULL);
		strcat(tmp, dsp_name);
		fd = fopen(tmp, "w");
		if (fd != NULL)
		{
			fprintf(fd, "ID=ITime Auflîung\n");

			/* Farb-Infos */
			write_cfg_int("OnlineX", x_pos);
			write_cfg_int("OnlineY", y_pos);
			write_cfg_int("RechterRand", rechterRand);
			write_cfg_bool("Hintergrund", hintergrund);

			fclose(fd);
			fd = NULL;
		}
	}
	else
		note(1, 0, WRITEERR);
}

