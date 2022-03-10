#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif


/* scan.c */
void *myalloc P((size_t sp ));
char *skip_blanks P((char *string ));
char *skip_to_blank P((char *string ));
char *ctl_string P((char *string ));
char *ctl_path P((char *string ));
int init_conf P((void ));
void parsekey P((char *p ));
int getint P((char **p , int *i ));
int getaddress P((char *str , int *zone , int *net , int *node , int *point ));
int getalias P((int zone , int net , int node , int point ));
void get_passw P((int zone , int net , int node , int point ));
void init P((int argc , char *argv []));
void Aopen P((void ));
char *next_str P((char *p , char *lookfor));
void GetThem P((char *msg , char *str , int szones [], int snets [], int snodes [], int spoints [], int *tseen ));
void AddOrigin P((void ));
void SortThem P((int zones [], int nets [], int nodes [], int points [], int *nr , int chpoints ));
void CheckSeen P((void ));
void PurgeBlanks P((void ));
void CheckEcho P((void ));
int readmessage P((void ));
void add P((char *p ));
void AddThem P((char *addstr , int zones [], int nets [], int nodes [], int points [], int nr , int dopoints , int dozones ));
void AddSeen P((int what ));
void AddPath P((int add ));
void OpenPacket P((int zone , int net , int node , int point ));
void ClosePacket P((void ));
void MakeHdr P((struct Hdr *Mhdr ));
void PktWrite P((char *str , int len ));
void writehdr P((void ));
void writemessage P((int where , int what , int zone , int net , int node , int point ));
void cleanEcho P((void ));
void Aclose P((void ));
void deinitialize P((void ));
int main P((int argc , char *argv []));

#undef P

