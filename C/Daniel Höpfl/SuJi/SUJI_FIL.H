#ifndef __DH_SUJI_FIL_H_
#define __DH_SUJI_FIL_H_

typedef struct file_info{	struct file_info *next;	struct file_info *prev;	int selected;	unsigned long read_nr;	unsigned int time;	unsigned int date;	unsigned long size;	char attrib;	char *name;	char *pfad;} FILE_INFO;extern FILE_INFO first_fi;extern FILE_INFO *last_fi;extern unsigned long finfos;extern double fsize;int durchsuche_alle(char **pfad,int pfade);int durchsuche(char *pfad);int wildchar(char *mask,char *test,int big_is_small);int test_maske(char *maske);
#endif
