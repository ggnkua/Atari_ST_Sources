#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif


/* crunch.c */
long fsize P((FILE *f));
void *myalloc P((size_t sp ));
char *skip_blanks P((char *string ));
char *skip_to_blank P((char *string ));
char *ctl_string P((char *string ));
char *ctl_path P((char *string ));
int init_conf P((void ));
void init P((int argc , char *argv []));
int main P((int argc , char *argv []));
void sprintb(char *b, char *f, char *n);

#undef P
