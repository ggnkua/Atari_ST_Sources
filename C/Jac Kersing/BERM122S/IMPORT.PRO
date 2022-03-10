#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif


/* import.c */
char *skip_blanks P((char *string ));
char *skip_to_blank P((char *string ));
char *myalloc P((size_t sp ));
char *ctl_string P((char *string ));
char *ctl_path P((char *str ));
char *ctl_file P((char *str ));
int init_conf P((void ));
void parsekey P((char *p ));
int getint P((char **p , unsigned *i ));
int getaddress P((char *str , unsigned *zone , unsigned *net ,
                  unsigned *node , unsigned *point ));
int getalias P((unsigned zone , unsigned net , unsigned node , unsigned point ));
void get_passw P((unsigned zone , unsigned net , unsigned node , unsigned point ));
void init P((int argc , char *argv []));
void mv_pkt P((void ));
int open_pack P((void ));
void open_area P((int area ));
void close_area P((void ));
int read_hdr P((void ));
void conv_hdr P((void ));
int ourmessage P((void ));
int read_line P((void ));
void Iadress P((char *str , short *zone , short *net , short *node ));
int line_type P((char *line ));
char *next_str P((char *p , char *lookfor ));
char *GetArea P((void ));
int read_msg P((void ));
void GetThem P((char *msg , char *str , unsigned szones [],
                unsigned snets [], unsigned snodes [], unsigned spoints [],
                int *tseen ));
void AddOrigin P((void ));
void SortThem P((unsigned zones [], unsigned nets [], unsigned nodes [],
                 unsigned points [], int *nr , int chpoints ));
void CheckSeen P((void ));
void PurgeBlanks P((void ));
int CheckEcho P((void ));
void add P((char *p ));
void AddThem P((char *addstr , unsigned zones [], unsigned nets [],
                unsigned nodes [], unsigned points [], int nr ,
                int dopoints , int dozones ));
void AddSeen P((int what ));
void AddPath P((int add ));
void OpenPacket P((int nr , unsigned zone , unsigned net , unsigned node ,
        unsigned point ));
void ClosePacket P((int nr ));
void MakeHdr P((int nr , struct Hdr *Mhdr ));
void PktWrite P((int nr , char *str , int len ));
void writemessage P((int where , int what , unsigned zone , unsigned net ,
        unsigned node , unsigned point ));
void savemessage P((int where , int what ));
void display_results P((void ));
void process_packets P((void ));
int process_arc P((void ));
void SaveSize P((void ));
#ifdef LINN
int extract P((char *archive));
#endif

#if STTC
void main P((int argc , char *argv [], char *envir ));
#else
void main P((int argc , char *argv []));
#endif

#undef P
