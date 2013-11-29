/* variables declared in ezp.c...............................................*/

extern int  abortp,ahite,bitln,bm,bmarg,bufsz,bytln;
extern int  eb,ep,lastb,lastp,lm,lmarg;
extern int  rasys,rm,rmarg,sb,sp;
extern int  stasys,sysmax,sysrec,tm,tmarg,visys,voff;
#if DEBUG
extern int  dbug;
#endif
extern int  *measnum,*staffy;
extern char *s_image,*cancan,*set_1_216,*set_22_216,*set_8_72,*reset_1_6;
extern char *fmode,*dmode;
extern GRECT   desk;
extern LBRACE  *braces;
extern LBRACK  *brackets;
extern SYSDOM  *systems,*liney;
extern PRINTER *printer;

/* Tom's globals.............................................................*/

extern int bytesperline,gr_clipx1,gr_clipy1,gr_clipx2,gr_clipy2,gr_device,rez;
extern int maxnsymb,nsymbonscr,rehearw,x_left,x_right;
extern int *Mousex,*Mousey,*currscreen,*matptr;
extern int symbfamily[],staff_y[],staffview[];
extern long scrsave,scrbase;
extern char domainflgs[],w_symb[],printers[];
extern char *Mstate,*dataptr,*envirptr,*headptr,*pageptr,*staffptr;
extern FONTFORM font_info[];
extern OBJECT *pageaddr,*poptaddr,*prinaddr;
extern char nof_endg,skip_lrehr,skip_rehr,gr_clip;

/* Symbols...................................................................*/

extern PSYM staff,brackt,brackm,brackb;
extern PSYM bracei[];
extern int staffi(),brackit(),brackim(),brackib();
extern int brace056i(), brace066i(), brace081i(), brace096i(), brace111i(),
           brace126i(), brace141i(), brace156i(), brace171i(), brace186i(),
           brace201i(), brace216i(), brace231i(), brace246i();

/* EOF */
