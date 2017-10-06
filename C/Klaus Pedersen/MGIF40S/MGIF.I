/* Prototypes for functions defined in C:\TMP\MGIF.LC\MGIF.C */
int main(int argc,
         char **argv);
int usage(int excode);
int draw_image(char *fname);
int cmaptoint(uchar_t *pras,
              int w,
              int h,
              uchar_t (*map)[3],
              int useNTSC);
int showfl(int *s0);
void title(int b);
void conv_menu(int opt);
void info(char *fname);
void do_help(void);
