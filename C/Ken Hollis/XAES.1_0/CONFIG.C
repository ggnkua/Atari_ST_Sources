/********************************************************************
 *																1.20*
 *	XAES: Configuration loader from GUI_DEFS.SYS					*
 *	Code by Ken Hollis												*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	These routines are more efficient in that they don't store the	*
 *	text like APP_DEFS does.  GUI_DEFS simply reads the file, parses*
 *	the information, checks information using strcmp, and sets the	*
 *	internal typedef.  The file equation in fscanf is likely to be	*
 *	either optimized or redesigned altogether.						*
 *																	*
 ********************************************************************/

#include <stdio.h>
#include <string.h>

#include "xaes.h"

#define	GUIDEFS	".\\GUI_DEFS.SYS"

typedef struct {
	char	*str;	/* String variable name in GUI_DEFS parsing */
	int		val;	/* Variable name value */
} GUI_DEFS_STRINGS;

LOCAL int Color_length = 17;
LOCAL GUI_DEFS_STRINGS Colors[] = {
	"WHITE",	WHITE,
	"BLACK", 	BLACK,
	"RED", 		RED,
	"GREEN",	GREEN,
	"BLUE",		BLUE,
	"CYAN",		CYAN,
	"YELLOW",	YELLOW,
	"MAGENTA",	MAGENTA,
	"LWHITE",	LWHITE,
	"LBLACK",	LBLACK,
	"GREY",		LBLACK,		/* A little something I added myself */
	"LRED",		LRED,
	"LGREEN",	LGREEN,
	"LBLUE",	LBLUE,
	"LCYAN",	LCYAN,
	"LYELLOW",	LYELLOW,
	"LMAGENTA",	LMAGENTA };

LOCAL int Centers_length = 3;
LOCAL GUI_DEFS_STRINGS Centers[] = {
	"MOUSE_CENTER",		XW_MOUSECENTER,
	"SCREEN_CENTER",	XW_SCREENCENTER,
	"PHYSICAL_SCREEN",	XW_PHYSICCENTER };

LOCAL int Draws_length = 7;
LOCAL GUI_DEFS_STRINGS Draws[] = {
	"Standard",	DRAW_STANDARD,
	"MultiTOS",	DRAW_MULTITOS,
	"Geneva",	DRAW_GENEVA,
	"Zoom",		DRAW_ZOOM,
	"Motif",	DRAW_MOTIF,
	"LTMF",		DRAW_LTMF,
	"XAES",		DRAW_XAES };

CONFIG xaes;

/*
 *	This is the routine to read in the configuration file.  I'm a
 *	little reluctant to even think of writing a WriteConfig routine
 *	since the fscanf routine gave me nightmares.
 */
GLOBAL void ReadConfig(void)
{
	FILE *file = fopen(GUIDEFS, "r");

	if (file) {
		while (!feof(file)) {
			char element[80], status[80], option2[80], dummy[80];
			char first = fgetc(file);

			ungetc(first, file);

/* Don't ask me to explain the fscanf routine here.  I'll just bop
   you in the nose. */
			if ((first == '#') || (first == '[') || (first == '*') ||
				(first == '!') || (first == '\'') || (first == ';'))
				fscanf(file, "%[^\n]\n", element);
			else
				fscanf(file, "%[^=]=%[^#[*!\'\t; \n]%[^,\n]%[^\n]\n", element, status, option2, dummy);

			if (!(strcmp(element, "LEFT_BORDER_MOVE")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_LEFTBORDER : 0;
			if (!(strcmp(element, "WINX_COMPATIBILITY")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_WINXCOMPAT : 0;
			if (!(strcmp(element, "CHANGE_MOUSE_ELEMENT")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_MOUSEGADGETS : 0;
			if (!(strcmp(element, "SLIDER_MOUSE_CHANGE")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_MOUSESLIDERS : 0;
			if (!(strcmp(element, "ROUNDED_OBJECTS")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_ROUNDOBJECTS : 0;
			if (!(strcmp(element, "ROUNDED_SHADOW")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_ROUNDSHADOW : 0;
			if (!(strcmp(element, "NICELINE_ENABLED")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_NICELINE : 0;
			if (!(strcmp(element, "GENEVA_COMPATIBILITY")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_GENEVACOMPAT : 0;
			if (!(strcmp(element, "DRAW3D_COMPATIBILITY")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_DRAW3DCOMPAT : 0;
			if (!(strcmp(element, "AUTO_CHANGE_MOUSE")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_AUTOCHANGE : 0;
			if (!(strcmp(element, "ELEMENT_SELECTION")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_ELEMENTSEL : 0;
			if (!(strcmp(element, "MEDIUM_EMULATION")))
				xaes.config1 |= (!(strcmp(status, "TRUE"))) ? X_MEDEMUL : 0;

			if (!(strcmp(element, "ACTIVE_WINDOW_TEXT")))
				xaes.active_text_color = BLACK;
			if (!(strcmp(element, "INACTIVE_WINDOW_TEXT")))
				xaes.inactive_text_color = WHITE;

			if (!(strcmp(element, "WINDOW_CENTER"))) {
				if (!(strcmp(status, "MOUSE_CENTER")))
					xaes.wind_center = XW_MOUSECENTER;
				if (!(strcmp(status, "SCREEN_CENTER")))
					xaes.wind_center = XW_SCREENCENTER;
				if (!(strcmp(status, "PHYSICAL_SCREEN")))
					xaes.wind_center = XW_PHYSICCENTER;
			}

			if (!(strcmp(element, "FORCE_INTERFACE_EMULATION")))
				xaes.config2 |= (!(strcmp(status, "TRUE"))) ? X_INTERFACE : 0;
			if (!(strcmp(element, "ACTIVE_WINDOW_REDRAW")))
				xaes.config2 |= (!(strcmp(status, "TRUE"))) ? X_ACTIVEDRAG : 0;
			if (!(strcmp(element, "BACKGROUNDABILITY")))
				xaes.config2 |= (!(strcmp(status, "TRUE"))) ? X_BACKGROUND : 0;

			if (!(strcmp(element, "3D_DRAW_STYLE"))) {
				if (!(strcmp(status, "Standard")))
					xaes.draw_3d = DRAW_STANDARD;
				if (!(strcmp(status, "MultiTOS")))
					xaes.draw_3d = DRAW_MULTITOS;
				if (!(strcmp(status, "Geneva")))
					xaes.draw_3d = DRAW_GENEVA;
				if (!(strcmp(status, "Zoom")))
					xaes.draw_3d = DRAW_ZOOM;
				if (!(strcmp(status, "Motif")))
					xaes.draw_3d = DRAW_MOTIF;
				if (!(strcmp(status, "LTMF")))
					xaes.draw_3d = DRAW_LTMF;
				if (!(strcmp(status, "XAES")))
					xaes.draw_3d = DRAW_XAES;
			}

			if (!(strcmp(element, "UNDERLINE_COLOR"))) {
				if (!(strcmp(status, "BLACK")))
					xaes.hotkey_color = BLACK;
				if (!(strcmp(status, "RED")))
					xaes.hotkey_color = RED;
				if (!(strcmp(status, "WHITE")))
					xaes.hotkey_color = WHITE;
			}

			if (xaes.config1 & X_MEDEMUL)
				xaes.hotkey_color = BLACK;

			if ((xaes.hotkey_color != BLACK) && (xaes.config1 & X_MEDEMUL))
				xaes.hotkey_color = BLACK;
		}

		fclose(file);
	} else {
 		form_alert(1, "[3][GUI_DEFS file not found!| |Assuming defaults.][ Okay ]");

		/* We're going to add defaults later, after I get all of the
		   settings figured out; that'll probably take a while... */
	}
}