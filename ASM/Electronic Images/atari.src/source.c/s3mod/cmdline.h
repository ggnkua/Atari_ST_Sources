/* CMDLINE.H */

#ifndef NULL
#define NULL 0
#endif

int parm_setup(int argc,char **argv,char *str_prms,char *flag_prms,
		char *num_prms);

/* My own favorite GETOPT substitute */
/* letter <= 32 means get non-flagged regular parameter # letter */
/* num_types  = letters that take numerical parameters */
/* str_types  = letters that take string parameters */
/* flag_types = letters that take no parameters */
/* str_value  = returned string value */
/* num_value  = returned numerical value */
/* argv/argc  = parameter list / parameter count */

int read_next_parm(char letter,
                   char *num_types, char *str_types, char *flag_types,
                   char **str_value, long int *num_value,
                   int argc, char **argv);

int read_parm(char letter, char **str_value, long int *num_value);
#define NON_FLAGGED 1




