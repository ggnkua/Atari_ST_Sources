#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif


/* route.c */
int isok P((char *string ));
int yyparse P((void ));
void parse P((void ));
#ifdef LINN
void arcmail P((int archiveur));
#else
void arcmail P((void ));
#endif
void addroute P((int flags ));
void route_to P((void ));
void no_route P((void ));
void add_hold P((void ));
void add_poll P((void ));
void forward P((void ));
void if_ok P((void ));
void redirect P((void ));
int parse_route P((void ));
#ifdef LINN
void add_nohold P((void));
#endif
int ArcOk P((int zone , int net , int node ));
int HoldOk P((int zone , int net , int node ));
int ForwardOk P((int fromzone , int fromnet , int fromnode , int frompoint , int tozone , int tonet , int tonode , int topoint , int crash , int file ));
int match P((char *raw , char *pat ));
int match1 P((char *raw , char *pat , int level ));
void getid P((int nr , int *zone , int *net , int *node ));
void ToWhere P((int *zone , int *net , int *node , int dzone , int dnet , int dnode , int dpoint , int crash , int file ));
void ReDirectTo P((int *zone , int *net , int *node , int dzone , int dnet , int dnode , int crash ));
char *PollNode P((int *start ));

#undef P
