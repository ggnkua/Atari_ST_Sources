/*
 Copyright 2007 Benjamin Gandon

 This file is part of Builder Tool for Adebug Reloaded.

 Adebug is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 Adebug is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Adebug; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

/* This Builder helps building Adebug Reloaded sources */
/* (because the tools Brainstorm guys were using have not been found back yet) */

/* Target control */
enum targets {
	RELEASE	= 0,
	DEBUG	= 1,
	RESIDENT= 2
};

#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* functions listed here */
void assembl(char *filename, char *args);	/* Assemble with "Assemble" assembler */
void call_binary(char *filename, char *compiler, char *args_template);

/* Bconin() define used in main() */
#define DEV_CONSOLE 2
/* Dgetpath() define used in main() */
#define DEFAULT_DRIVE 0
#define E_OK 0

char *default_assembler = "c:\\asm\\asm.ttp";
char assembler[256] = "";
char *config_file = "builder.cnf";

char *aargs_template_release = "-v -n -d=debug=0 -o=adebug.prg %s";
char *aargs_template_debug = "-v -n -d=debug=1 -o=debug.prg -o -x -y -o1- %s";
char *aargs_template_resid = "-v -n -d=debug=0 -d=residant=1 -o=rdebug.prg %s";

char *release_ver = "release version (without any debug symbol)";
char *debug_ver = "debug version (with debug symbols)";
char *resid_ver = "resident version (usefull in your AUTO folder)";

char *src_path = "..\\src";

int main(int argc, const char *argv[]) {
	int ret, target;
	char path[256];
	FILE* config;

	printf("%cE%cv", 27, 27);
	printf("Builer tool for Adebug Reloaded.\n");
	printf("Written by Benjamin Gandon (2007-01-18)\n");

	if (argc <= 1) {
		printf("Syntax: BUILDER <version>\n"
				"	Version can be of:\n");
		printf("		%d [default]: %s\n", (int)RELEASE,	release_ver);
		printf("		%d: %s\n",			 (int)DEBUG,	debug_ver);
		printf("		%d: %s\n",			 (int)RESIDENT,	resid_ver);
		Bconin(DEV_CONSOLE);
		return 2;
	} else {
		config = fopen(config_file, "r");
		if (config == NULL) {
			strcpy(assembler, default_assembler);
			printf("Using default assembler: <%s>\n", assembler);
		} else if (NULL == fgets(assembler, 255, config)) {
			printf("Error while reading config file <%s>. "
					"Aborting.\n", config_file);
			Bconin(DEV_CONSOLE);
			return 1;
		} else {
			assembler[255] = '\0'; /* for sanity */
			printf("Using configured assembler: <%s>\n", assembler);
		}
		Dgetpath(path, DEFAULT_DRIVE); path[255] = '\0'; /* for sanity */
		ret = Dsetpath(src_path);
		if (ret != E_OK) {
			printf("Error(%d): can't set path to <%s>. Aborting.\n", ret, src_path);
			printf("Path was: %s\n", path);
			Dgetpath(path, DEFAULT_DRIVE); path[255] = '\0'; /* for sanity */
			printf("Path now is: %s\n", path);
			Bconin(DEV_CONSOLE);
			return 1;
		}
		Dgetpath(path, DEFAULT_DRIVE); path[255] = '\0'; /* for sanity */
		printf("Path set to: %s\n", path);

		target = atoi(argv[1]);
		printf("Building target #%d: ", target);
		switch (target) {
		case DEBUG:
			printf("%s\n\n", debug_ver);
			assembl("adebug.s", aargs_template_debug);
			break;
		case RESIDENT:
			printf("%s\n\n", resid_ver);
			assembl("adebug.s", aargs_template_resid);
			break;
		case RELEASE:
		default:
			printf("%s\n\n", release_ver);
			assembl("adebug.s", aargs_template_release);
			break;
		}
	}


	printf("\nJob's done!\n");
	Bconin(DEV_CONSOLE);
	return 0;
}

#define SWM_LAUNCHNOW 1
#define TOSAPP 0
#define CL_NORMAL 0
/* Pexec() define */
#define PE_LOADGO 0


void assembl(char *filename, char *args) {
	call_binary(filename, assembler, args);
}

void call_binary(char *filename, char *compiler, char *args_template) {
	char args[255];
	char cmdline[255];
	int ret;
	
	sprintf(args, args_template, filename);
	printf("%s %s\n", compiler, args);

	if (strlen(args) < 125) {
		sprintf(cmdline, "%c%s", (char)strlen(args), args);
		ret = Pexec(PE_LOADGO, compiler, cmdline, NULL);
	} else {
		printf("Error: command line arguments are too long (>=125 bytes)\n");
	}
	if (ret != 0) {
		printf("Error returned: %i\n\n", ret);
	}
}
