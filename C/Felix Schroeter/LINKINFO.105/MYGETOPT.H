extern int Optind;
extern char *Optarg;

#if __STDC__ == 1 || defined (__TURBOC__)
int my_getopt (int argc, char **argv, char *optstr);
#else
int my_getopt ();
#endif
