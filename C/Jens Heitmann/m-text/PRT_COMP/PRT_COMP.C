/* 

	Beschreibung:			Drucker-Source-Compiler fÅr M-Text
	Autor:						Jens Heitmann
	Programmiert vom: 14.5.1990 -
*/

#include <gemdefs.h>
#include <string.h>
#include <osbind.h>
#include <stdio.h>

#define TRUE 1
#define FALSE 0

#include "pc_alert.h"

char path1[80];

char *NAME_TXT[3] = {"DRUCKERNAME",
										 "PRINTERNAME",
										 "F: DRUCKERNAME"};

char *TYP_TXT[3] = {"DRUCKERTYP",
									 	"PRINTERTYPE",
										"F: DRUCKERTYP"};

char *TYP_ANSW[3][5] = { {"9 NADEL",
													"24 NADEL", 
													"48 NADEL",
												 	"LASERDRUCKER",	
													"TYPENRAD"}, 
												 {"GB: 9 NADEL", 
													"GB: 24 NADEL",
													"GB: 48 NADEL",
													"GB: LASERDRUCKER", 
													"GB: TYPENRAD"},
												 {"F: 9 NADEL", 
													"F: 24 NADEL",
													"F: 48 NADEL",
													"F: LASERDRUCKER", 
													"F: TYPENRAD"} };

char *PAPERTYPE[3] = {"PAPIERART", 
											"PAPERTYPE", 
											"F: PAPIERART"};

char *PAPER_ANSW[3][2] = { {"ENDLOS", 
														"EINZELBLATT"},
													{"ENDLESS", 
													 "SINGLE"},
													{"F: ENDLOS",
												 	 "F: EINZELBLATT"}};

#define DEFNUM 4
char *PRT_POINTS[04][3] = {{"FETTDRUCK AN",
													 	"BOLD ON",
													 	"F: FETTDRUCK AN"},
													 {"FETTDRUCK AUS",
														"BOLD OFF",
														"F: FETTDRUCK AUS"},
													 {"KURSIV AN",
														"ITALIC ON",
														"F: KURSIV AN"},
													 {"KURSIV AUS",
														"ITALIC OFF",
														"F: KURSIV AUS"}};

int lens[08];
unsigned char *code_mem;

/* ---------------- */
/* | Hauptroutine | */
/* ---------------- */
main()
{
char path2[80];
long code_len;

appl_init();

path1[0] = Dgetdrv();
path1[1] = ':';
Dgetpath(path1 + 2, path1[0] + 1);
path1[0] += 'A';
strcat(path1, "\\*.PRT");

code_len = (long)Malloc(-1L) - 75000;
code_mem = (unsigned char *)Malloc(code_len);

graf_mouse(ARROW, 0L);

do
	{
	if (!fsel(path1, "PRT", "Druckersource wÑhlen!"))
		break;

	strcpy(path2, path1);
	if (rindex(path2, '.') > rindex(path2, '\\'))
		strcpy(rindex(path2, '.'), ".PRC");

	if (fsel(path2, "PRC", "Treiberdatei wÑhlen!"))
		comp_source(path1, path2);

	}while(TRUE);

appl_exit();
}

/* ---------------- */
/* | Dateiauswahl | */
/* ---------------- */
fsel(st_path, ext, title)
char *st_path, *ext, *title;
{
char path[80], file[13];
int button, st;
long savessp;
unsigned tos_version;

strcpy(path, st_path);
strcpy(rindex(path, '\\') + 1, "*.");
strcat(path, ext);

if (*(rindex(st_path, '\\') + 1) == '*')
	file[0] = 0;
else
	strcpy(file, rindex(st_path, '\\') + 1);

savessp = Super(0L);
tos_version = *(unsigned int *)(*(long *)(0x4f2) + 2);
Super(savessp);

if (tos_version < 0x104)
	st = fsel_input(path, file, &button);
else
	st = fsel_exinput(path, file, &button, title);

if (st >= 0 && button)
	{
	strcpy(st_path, path);
	strcpy(rindex(st_path, '\\') + 1, file);
	return(TRUE);
	}

return(FALSE);
}

/* -------------------------------- */
/* | Wandel Source in Druckerfile | */
/* -------------------------------- */
comp_source(src, des)
char *src, *des;
{
register int i;
FILE *src_f;
char line[258];

for (i = 0; i < DEFNUM * 2; lens[i++] = -1);

src_f = fopen(src, "br");
if (src_f)
	{
	while(fgets(line, 256, src_f))
		{
		if (index(line, '\r'))
			*index(line, '\r') = 0;

		if (remark(line))
			continue;

		if (header(line))
			continue;

		if (control(line))
			continue;

		if (translate(line))
			continue;

		form_alert(1, SRC_ERR);
		fclose(src_f);
		return;
		}

	fclose(src_f);
	}
else
	form_alert(1, SRC_OPNERR);
}

/* -------------------------------------------------- */
/* | Gibt True zurÅck wenn Zeile eine Bemerkung ist | */
/* -------------------------------------------------- */
remark(line)
{
}

/* --------------------------- */
/* | Verarbeitet Headerzeile | */
/* --------------------------- */
header(line)
{
}

/* ----------------------------- */
/* | Verarbeitet Kontrollzeile | */
/* ----------------------------- */
control(line)
{
}

/* -------------------------------- */
/* | Verarbeitet Translationtable | */
/* -------------------------------- */
translate(line)
{
}
