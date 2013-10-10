/*
 * Dieses Modul basiert auf einem Modula2-Quelltext von Uwe Mindrup @ LB
*/
#include <string.h>
#include <osbind.h>
#include <time.h>

#include "global.h"
#include "wp-print.h"


#define MAX_SEQUENCE		0x4F
#define MAXTRANSLATIONS 0xFF
/* es folgen die Konstanten fÅr den Tabelleneingang der Funktionen: */
#define VERTPOS			5
#define BOLD				6
#define ITALIC 			0xA
#define LIGHT				0xE
#define SUPERSCRIPT		0x12
#define SUBSCRIPT 		0x16
#define _UNDERLINE 		0x1A
#define HORZINIT			0x1F
#define VERTINIT			0x20
#define PRINTERINIT		0x21

#define _1STTYPE			0x28
#define _1STCOLOR 		0x30
#define PROP				0x35
#define FORMFEED			0x1E
#define WRITELN			1
#define TAB 				0x09

typedef struct
{
	int	len;
	int	pos;
} TABLEENTRY;


/*
 * lokale Variablen
*/
static TABLEENTRY	seq_table[MAX_SEQUENCE + 1],
				 		trans_table[MAXTRANSLATIONS + 1];
static char 		*cfg_ptr;
static int			prn_hdl,
						char_pos, 					/* Position des Zeichens in der aktuellen Zeile */
						nr_spaces,					/* Anzahl Leerzeichen */
						nlq_set,						/* [0..2] */
						akt_mode, akt_color,
						tab_size,
						prop_size;
static bool			proportional,
						config_read = FALSE;
static char			cfg_name[256];

/*
 * lokale Prozeduren
*/
static void init_tables(void)						/* Tabellen initialisieren */
{
	int	i;

	for (i = 0; i <= MAX_SEQUENCE; i++)
		seq_table[i].len = 0;
	for (i = 0; i <= MAXTRANSLATIONS; i++)
		trans_table[i].len = 0;
	char_pos = 0;
}

static bool out(char ch)
{
	if (prn_hdl == -2)
		Cauxout(ch);
	else if (prn_hdl == -3)
		Cprnout(ch);
	else
		Fwrite(prn_hdl, 1, &ch);
	return TRUE;
}


static bool print_seq(int which)
{
	int		i;
	bool	ok;

	for (i = seq_table[which].pos; i <= seq_table[which].pos + seq_table[which].len - 1; i++)
	{
		ok = out(cfg_ptr[i]);
		if (!ok)
			break;
	}
	return ok;
}


static bool print(int entry, bool set)		/* Ausgabe der angewÑhlten Steuersequenz */
{
	if (!set)
		entry++;
	return print_seq(entry + nlq_set);
}


static bool write_char(char ch)
{
	int		i;
	bool	ok;

	if (trans_table[ch].len > 0)
	{
		for (i = trans_table[ch].pos; i <= trans_table[ch].pos + trans_table[ch].len - 1; i++)
		{
			ok = out(cfg_ptr[i]);
			if (!ok)
				break;
		}
		char_pos++;
	}
	else
	{
		ok = out(ch);
		char_pos++;
	}
	return ok;
}


static bool set_head(void)							/*  Druckkopf neu positionieren */
{
	int		i, len, pos;
	bool	ok;

	len = seq_table[VERTPOS].len;
	pos = seq_table[VERTPOS].pos;
	for (i = pos; i <= pos + len - 1; i++)
	{
		if (cfg_ptr[i] == 0x80)
			ok = out((char_pos * 60 / prop_size) % 256);
		else if (cfg_ptr[i] == 0x81)
			ok = out((char_pos * 60 / prop_size) / 256);
		else
			ok = out(cfg_ptr[i]);
		if (!ok)
			break;
	}
	nr_spaces = 0;
	return ok;
}


/*
 * exportierte Prozeduren
*/
bool wp_load_cfgfile(char *name)
{
	long	length, err;
	int	f, i, j, Pos, Len;

	if ((strcmp(name, cfg_name) == 0) && config_read)	/* Config bereits geladen */
		return TRUE;
	else
	{
		strcpy(cfg_name, name);
		config_read = FALSE;
	}

	err = Fopen(name, 0);
	if (err < 0)
		return FALSE;
	f = (int)err;

	if (cfg_ptr != NULL)
		Mfree(cfg_ptr);

	length = Fseek(0, f, 2);						/* ganz ans Ende */

	cfg_ptr = Malloc(length);
	if (cfg_ptr == NULL)
	{
		Fclose(f);
		return FALSE;
	}

	Fseek(0, f, 0);									/* zurÅck zum Anfang */
	err = Fread(f, length, cfg_ptr);
	Fclose(f);

	init_tables();

	/* Kennung ÅberprÅfen: */
	if (strncmp(cfg_ptr, "GST-CFG:", 8) != 0)
		return FALSE;									/* keine GST-CFG-Datei !!! */

	/* Jetzt mÅssen die Tabellen aufgebaut werden: */
	i = 8;												/* Druckernamen Åberspringen */
	while (cfg_ptr[i] != '\0')
		i++;
	i += 7;												/* Druckeranpassungen interessieren nicht.  */

	/* zunÑchst die Tabelle der Druckerbesonderheiten:  */
	while (cfg_ptr[i] != '\0')						/* Tabelle wird mit einem NUL-Byte beendet */
	{
		Len = cfg_ptr[i];
		Pos = cfg_ptr[i+1];							/* Tabelleneintrag */
		seq_table[Pos].len = Len - 2;
		seq_table[Pos].pos = i + 2;
		i += Len;
	}
	i++;													/* Tabellenende Åberspringen */

	/* jetzt die öbersetzungsTabelle:	*/
	while (cfg_ptr[i] != '\0')						/* Tabelle wird mit einem NUL-Byte beendet */
	{
		Len = cfg_ptr[i];
		Pos = cfg_ptr[i+1];
		trans_table[Pos].len = Len - 2;
		trans_table[Pos].pos = i + 2;
		i += Len;
	}

	/* Optimierung der Druckercharakteristik-Tabelle: */
	/* 1. die Texteffekte: */
	for (i = BOLD; i <= _UNDERLINE; i+=4)
		for (j = i; j <= i+1; j++)
		{
			if ((seq_table[j].len == 0) && (seq_table[j+2].len != 0))
				seq_table[j] = seq_table[j+2];
			if ((seq_table[j+2].len == 0) && (seq_table[j].len != 0))
				seq_table[j+2] = seq_table[j];
		}

	/* 2. die Schriftarten: */
	for (i = _1STTYPE; i <= _1STTYPE + 6; i+=2)
	{
		if ((seq_table[i].len == 0) && (seq_table[i+1].len != 0))
			seq_table[i] = seq_table[i+1];
		if ((seq_table[i+1].len == 0) && (seq_table[i].len != 0))
			seq_table[i+1] = seq_table[i];
	}
	config_read = TRUE;
	return TRUE;
}


void wp_get_prnname(char *Printername, int max_len)
{
	int	i;

	if (cfg_ptr != NULL)
	{
		i = 8;
		while ((cfg_ptr[i] != '\0') && (i < (max_len + 8)))
		{
			Printername[i-8] = cfg_ptr[i];
			i++;
		}
		Printername[i - 8] = '\0';
	}
	else
		Printername[0] = '\0';
}

bool wp_send_init(bool use_nlq)
{
	bool	ok;

	if (use_nlq)
		nlq_set = 2;
	else
		nlq_set = 0;
	ok = print_seq(PRINTERINIT);		/* allgemeiner Init */
	if (ok)
	{
		print_seq(HORZINIT);					/* Horizontale Initialisierung */
		print_seq(VERTINIT);					/* Vertikale Initialisierung	*/
		print(BOLD, FALSE);					/* Fettschrift aus.				*/
		print(ITALIC, FALSE);				/* Kursivschrift aus. 			*/
		print(LIGHT, FALSE);					/* Light aus.						*/
		print(SUPERSCRIPT, FALSE);			/* Superscript aus.				*/
		print(SUBSCRIPT, FALSE);			/* Subscript aus.					*/
		print(_UNDERLINE, FALSE);			/* Unterstreichung aus.			*/
	  	akt_mode = -1;
	 	print_seq(_1STTYPE);					/* PICA (10 CPI)					*/
		akt_color = -1;
		print_seq(_1STCOLOR);				/* Color-Einstellung: Black.	*/
		proportional = FALSE;
		print_seq(PROP + 1);					/* proportional-Schrift aus.	*/
	}
	return ok;
}


bool wp_send_exit(void)
{
	return print_seq(PRINTERINIT);
}


bool wp_set_mode(int mode)
{
	bool	ok = TRUE;

	if ((mode >= PICA) && (mode <= EXPANDED))
	{
		if (mode != akt_mode)
		{
			ok = print_seq(2 * mode + _1STTYPE + (nlq_set / 2));
			akt_mode = mode;
		}
	}
	return ok;
}


bool wp_formfeed(void)
{
	return print_seq(FORMFEED);
}


void wp_set_tabsize(int tab)
{
	tab_size = tab;
}


bool wp_write_ln(void)
{
	bool	ok;

	ok = print_seq(WRITELN);
	char_pos = 0;
	return ok;
}


bool wp_write(char ch)
{
	int		i;
	bool	ok;

	if ((ch == TAB) || (ch == ' '))
	{
		if (proportional)
		{
			if  (ch == ' ')
			{
				char_pos++;
				nr_spaces++;
			}
			else
			{
				char_pos += tab_size;
				nr_spaces += tab_size;
			}
		}
		else
		{
		  	if (ch == ' ')
				ok = write_char(' ');
			else
			 	for (i = 1; i <= tab_size; i++)
					ok = write_char(' ');
		}
	}
	else
	{
		if (nr_spaces > 1)
			ok = set_head();
		else if (nr_spaces == 1)
		{
			ok = write_char(' ');
			nr_spaces = 0;
		}
		ok = write_char(ch);
	}
	return ok;
}


bool wp_write_string(char *Str)
{
	int		i;
	bool	ok = TRUE;

	i = 0;
	while ((Str[i] != '\0') && ok)
	{
		ok = wp_write(Str[i]);
		i++;
	}
	return ok;
}


bool wp_open(char *name)
{
	long	err;

	if (strcmp(name, "PRN:") == 0)
		prn_hdl = -3;
	else if (strcmp(name, "AUX:") == 0)
		prn_hdl = -2;
	else
	{
		err = Fopen(name, 1);
		if (err == -33)
			err = Fcreate(name, 0);
		else if (err > 0)
		{
			prn_hdl = (int) err;
			Fseek(0, prn_hdl, 2);
		}
	}
	return (prn_hdl > -31);
}


void wp_close(void)
{
	Fclose(prn_hdl);
}
