#include <stdio.h>
#include <stdlib.h>

#ifdef __PUREC__
#include <ext.h>
#include <ctype.h>
#include <string.h>
#define MAX_NAME_LENGTH 8
#define EXT_LENGTH 3
#define EDITOR_NAME "me"
#endif

#ifdef IBMPC
#include <io.h>
#include <ctype.h>
#include <dos.h>
#define MAX_NAME_LENGTH 8
#define EXT_LENGTH 3
#define EDITOR_NAME "me"
#endif

#ifdef AMIGA
#define MAX_NAME_LENGTH 40
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#define EXT_LENGTH 3
#define EDITOR_NAME "ed"
#endif

#ifdef UNIX
#define MAX_NAME_LENGTH 8
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#define EXT_LENGTH 3
#define EDITOR_NAME "me"
#endif

/* All default values */

#define TRUE 1
#define FALSE 0
#define DEF_SCRIPT_NAME "script"     /* Default name for new script file */
#define DEF_SCRIPT_EXT "bat"         /* Default extension for script file */
#define DEF_NEW_SCRIPT_EXT "new"     /* Default extension for new script file */
#define DEF_ARRAY_NAME "tulos"       /* Default array filename */
#define DEF_OUTPUT_EXT "tga"         /* Default extension for picture file */
#define DEF_DATA_EXT "dat"           /* Default extension for data file */

#define DEF_OUTPUT_NAME "output"     /* Default name for new datafile */
#define DEF_ARR_EXT "arr"            /* Default extension for array file */
#define REPLACE_MARK '#'             /* Default REPLACE MARK */
#define MAX_VAR_LENGTH 20            /* Maximum length of variable name */


#define DEF_COMMENT_START "{"        /* Default comment start character */
#define DEF_COMMENT_END   "}"        /* Default comment end character */
#define DKB_COMMENT_START "{"        /* DKB/QRT comment start character */
#define DKB_COMMENT_END   "}"        /* DKB/QRT comment end character */
#define VORT_COMMENT_START "/*"      /* VORT comment start character */
#define VORT_COMMENT_END   "*/"      /* VORT comment end character */

FILE  *stream;
char  *buffer;                       /* Contents of .dat file */
char  *array;                        /* Contents of .arr file */
char  *modified;                     /* Modified buffer for output-file */
char  *names;                        /* Contains variable names */
float *values;                       /* Contains values */

char *error_str;

char script[256];                    /* Contents of .script file */

char scene_number[4];                /* Current scene number */
char string[40];                     /* Temp. string for all use */
char comment_start[3];               /* Comment start mark */
char comment_end[3];                 /* Comment end mark */

char arr_name[MAX_NAME_LENGTH+EXT_LENGTH+1];
char dat_name[MAX_NAME_LENGTH+EXT_LENGTH+1];
char script_name[MAX_NAME_LENGTH+EXT_LENGTH+1];
char output_name[MAX_NAME_LENGTH+EXT_LENGTH+1];
char file_name[ MAX_NAME_LENGTH + EXT_LENGTH +2 ];


int index,index2,index3;             /* for all use */

unsigned data;                       /* Points to argv[], which has name for output */
unsigned var_count;                  /* Number of variables */
unsigned add_null;                   /* Name type,1=name001,2=name1 */

int data_size;       /* Filelength of datafile, needed when building new scene */
int arr_size;        /* Filelength of array-file */
int error;           /* File-errors etc. */
int count;           /* How many scenes required */

int max_values;      /* Maximum number of values each variable can have */
int script_gen;      /* if 1, generate script, if 0 no script */
int comment;         /* Replace/no replace inside comments */

