#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif


/* pack.c */
char *skip_blanks P((char *string ));
char *skip_to_blank P((char *string ));
char *myalloc P((size_t sp ));
char *ctl_string P((char *string ));
char *ctl_path P((char *str ));
char *ctl_file P((char *str ));
int init_conf P((void ));
void parsekey P((char *p ));
int getint P((char **p , int *i ));
int getaddress P((char *str , int *zone , int *net , int *node , int *point ));
int getalias P((int zone , int net , int node , int point ));
void get_passw P((int zone , int net , int node , int point ));
void Init P((int argc , char *argv []));
void OpenMail P((void ));
void CloseMail P((void ));
void InitPackets P((void ));
void ClosePacket P((int nr ));
void DeInitPackets P((void ));
int OurMessage P((int from ));
int ReadMessage P((void ));
void SaveMessage P((void ));
void Destination P((int *zone , int *net , int *node , int *type ));
void OpenPacket P((int nr , int zone , int net , int node , int type ));
int MakeMsg P((int nr ));
void PackTo P((int zone , int net , int node , int type ));
void ArcMail P((void ));
void ReDirect P((void ));
void Hold P((void ));
void UnHold P((void ));
void MakePoll P((void ));
void DeInit P((void ));
#ifdef LINN
int CallArc P((char *archiver, char *comline, int zone, int net, int node, int type));
void binkbox P((void));
void boxbink P((void));
#endif

#undef P
