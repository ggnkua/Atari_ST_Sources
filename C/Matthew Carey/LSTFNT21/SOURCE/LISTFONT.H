unsigned char *memsearch(unsigned char *targ,
                unsigned char *model,
                size_t len,
                unsigned char *end);
unsigned long intel_long(unsigned char array[4]);
int ttfList(char *fontname, char *node, size_t size, FILE *fpList, short mode);
int postList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int ghostList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int calamusList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int speedoList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int GEMList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int caligList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int dmfList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int cgList(char *fontname,char *node,size_t size,FILE *fpList, short mode);
int post3List(char *fontname,char *node,size_t size,FILE *fpList, short mode);
void
print_to_list(FILE *fp, char *fullname, char *node, char *font_name, short mode);

