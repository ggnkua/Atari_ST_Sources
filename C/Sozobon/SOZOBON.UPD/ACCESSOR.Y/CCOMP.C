#include <ccomp.h>

#define NULL 0L
#define FALSE 0
#define TRUE 1
#define VDI_LIB_NAME "v.a"
#define AES_LIB_NAME "a.a"

#include <gemfast.h>
#include <string.h>
#include <stdio.h>
#include <malloc.h>

char *cfile_ext = "*.C";      /* Dateiname fÅr Vorbelegung der FSEL-Box */
char progpath[128];           /* Programm Name */
char param[128];              /* Paramter mit dem Prog. aufgerufen wird */

typedef struct {
     char src_file[33];
     char out_file[33];
     int  extension;
     int  optimizer;
     int  assembler;
     int  linker;
     int  link_vdi;
     int  link_aes;
     char incl_lib[4][33];
     char defin_val[4][17];
     char undef_val[4][17];
     int  fp_lib;
     int  loadmap;
     int  fullinfo;
     int  symbol_table;
}    mask;

long _BLKSIZ = 4096L;

int process_box()
{
OBJECT *rsc_addr, *obj_addr;
TEDINFO *tinfo_addr;
int exit_button;
register int i;
char buffer[128], fname[128];
FILE *info_file;
int box_x, box_y, box_w, box_h;
int sbox_x, sbox_y, sbox_w, sbox_h;
char *env_ptr, *cmdl;
mask mc;
long env_len;
register char *s, *t;

     getcwd(buffer, 128);          /* Aktuelle Dir. lesen */
     strupr(buffer);               /* in Groûbuchstaben wandeln */
     strcpy(fname, cfile_ext);     /* Vorbelegung fÅr FSEL Datei */
     strcat(buffer, cfile_ext);    /* Vorbelegung fÅr FSEL Pfad */
     fsel_input(buffer, fname, &exit_button);     /* Dateinamen holen */
     if(exit_button==0)            /* Bei ABBRUCH Prozedur verlassen */
          return(-1);
     s=strrpbrk(buffer, ":\\");    /* Pfadende suchen */
     if(s==NULL)
          s=buffer;
     else
          s++;
     strcpy(s, fname);             /* Dateinamen dranhÑngen */
     strlwr(buffer);
     strncpy(mc.src_file, buffer, 32);  /* in Maske Åbertragen */

     s = strchr(buffer, '.');
     *s = '\0';
     strncpy(mc.out_file, buffer, 32);  /* in Maske Åbertragen */

     strcpy(buffer, progpath);
     strcat(buffer, "INF");

     info_file = fopen(buffer, "rb");
     if(info_file != NULL)
     {    /* Masken-Felder aus der Datei lesen */
          mc.extension = getw(info_file);
          mc.optimizer = getw(info_file);
          mc.assembler = getw(info_file);
          mc.linker    = getw(info_file);
          mc.link_vdi  = getw(info_file);
          mc.link_aes  = getw(info_file);
          for(i=0; i<4; i++)
          {    s = mc.incl_lib[i];
               while(*s++=fgetc(info_file));
               s = mc.defin_val[i];
               while(*s++=fgetc(info_file));
               s = mc.undef_val[i];
               while(*s++=fgetc(info_file));
          }
          mc.fp_lib    = getw(info_file);
          mc.loadmap   = getw(info_file);
          mc.fullinfo  = getw(info_file);
          mc.symbol_table = getw(info_file);
          fclose(info_file);
     }
     else
     {    /* Masken-Felder mit Std.-Werten vorbelegen */
          mc.extension = EXTTTP;
          mc.optimizer = TRUE;
          mc.assembler<= TRUE;
          mc.linker    = TRUE;
          mc.link_vdi  = FALSE;
          mc.link_aes  = FALSE;
          for(i=0; i<4; i++)
          {    mc.incl_lib[i][0]  = '\0';
               mc.defin_val[i][0] = '\0';
               mc.undef_val[i][0] = '\0';
          }
          mc.fp_lib    = FALSE;
          mc.loadmap   = FALSE;
          mc.fullinfo  = TRUE;
          mc.symbol_table = FALSE;
     }

     /* RSC-Adresse holen */
     if(!rsrc_gaddr(0, 0, &rsc_addr))
     {    form_alert(1, "[3][Fehler beim Holen|der RSC-Adresse][FEHLER]");
          return(-1);
     }

     /* Dateiname in das Feld SOURCE Åbertragen */
     ((TEDINFO *)(rsc_addr+SOURCE)->ob_spec)->te_ptext = mc.src_file;
     /* Ausgabedatei in Feld OUTFILE Åbertragen */
     ((TEDINFO *)(rsc_addr+OUTFILE)->ob_spec)->te_ptext = mc.out_file;
     /* Include Libs, Define und Undefine Values Åbertragen */
     ((TEDINFO *)(rsc_addr+INCLLIB1)->ob_spec)->te_ptext = mc.incl_lib[0];
     ((TEDINFO *)(rsc_addr+INCLLIB2)->ob_spec)->te_ptext = mc.incl_lib[1];
     ((TEDINFO *)(rsc_addr+INCLLIB3)->ob_spec)->te_ptext = mc.incl_lib[2];
     ((TEDINFO *)(rsc_addr+INCLLIB4)->ob_spec)->te_ptext = mc.incl_lib[3];
     ((TEDINFO *)(rsc_addr+DEFINE1)->ob_spec)->te_ptext  = mc.defin_val[0];
     ((TEDINFO *)(rsc_addr+DEFINE2)->ob_spec)->te_ptext  = mc.defin_val[1];
     ((TEDINFO *)(rsc_addr+DEFINE3)->ob_spec)->te_ptext  = mc.defin_val[2];
     ((TEDINFO *)(rsc_addr+DEFINE4)->ob_spec)->te_ptext  = mc.defin_val[3];
     ((TEDINFO *)(rsc_addr+UNDEF1)->ob_spec)->te_ptext   = mc.undef_val[0];
     ((TEDINFO *)(rsc_addr+UNDEF2)->ob_spec)->te_ptext   = mc.undef_val[1];
     ((TEDINFO *)(rsc_addr+UNDEF3)->ob_spec)->te_ptext   = mc.undef_val[2];
     ((TEDINFO *)(rsc_addr+UNDEF4)->ob_spec)->te_ptext   = mc.undef_val[3];

     /* Masken-Werte, die Flags sind, festlegen */
     (rsc_addr + mc.extension)->ob_state |= SELECTED;
     (rsc_addr + OPTIMIZE)->ob_state     |= (SELECTED & mc.optimizer);
     (rsc_addr + ASSEMBLE)->ob_state     |= (SELECTED & mc.assembler);
     (rsc_addr + LINKER)->ob_state       |= (SELECTED & mc.linker);
     (rsc_addr + LINKVDI)->ob_state      |= (SELECTED & mc.link_vdi);
     (rsc_addr + LINKAES)->ob_state      |= (SELECTED & mc.link_aes);
     (rsc_addr + FPBIB)->ob_state        |= (SELECTED & mc.fp_lib);
     (rsc_addr + LOADMAP)->ob_state      |= (SELECTED & mc.loadmap);
     (rsc_addr + FULLINFO)->ob_state     |= (SELECTED & mc.fullinfo);
     (rsc_addr + SYMBTAB)->ob_state      |= (SELECTED & mc.symbol_table);

     /* Bildschirm reservieren & ausdehnende Box zeichnen */
     form_center(rsc_addr, &box_x, &box_y, &box_w, &box_h);
     form_dial(FMD_START, 0, 0, 0, 0, box_x, box_y, box_w, box_h);

     sbox_w = box_w/10;
     sbox_h = box_h/10;
     sbox_x = box_x + box_w/2 - sbox_w/2;
     sbox_y = box_y + box_h/2 - sbox_h/2;
     form_dial(FMD_GROW, sbox_x, sbox_y, sbox_w, sbox_h, box_x, box_y, box_w, box_h);

     /* Dialogbox darstellen und ausfÅllen */
     objc_draw(rsc_addr, CCOMPILE, 2, box_x, box_y, box_w, box_h);

     exit_button = form_do(rsc_addr, OUTFILE);

     /* Schrumpfende Box darstellen und Bildschirm freigeben */
     form_dial(FMD_SHRINK, sbox_x, sbox_y, sbox_w, sbox_h, box_x, box_y, box_w, box_h);
     form_dial(FMD_FINISH, 0, 0, 0, 0, box_x, box_y, box_w, box_h);

     if(exit_button == ABBRUCH)
     {    return(-1);
     }

     /* Masken-Werte lesen */
     if((rsc_addr + EXTTOS)->ob_state & SELECTED)
          mc.extension = EXTTOS;
     if((rsc_addr + EXTTTP)->ob_state & SELECTED)
          mc.extension = EXTTTP;
     if((rsc_addr + EXTPRG)->ob_state & SELECTED)
          mc.extension = EXTPRG;
     if((rsc_addr + EXTACC)->ob_state & SELECTED)
          mc.extension = EXTACC;

     mc.optimizer = (rsc_addr + OPTIMIZE)->ob_state & SELECTED;
     mc.assembler = (rsc_addr + ASSEMBLE)->ob_state & SELECTED;
     mc.linker    = (rsc_addr + LINKER)->ob_state & SELECTED;
     mc.link_vdi  = (rsc_addr + LINKVDI)->ob_state  & SELECTED;
     mc.link_aes  = (rsc_addr + LINKAES)->ob_state & SELECTED;
     mc.fp_lib    = (rsc_addr + FPBIB)->ob_state & SELECTED;
     mc.loadmap   = (rsc_addr + LOADMAP)->ob_state & SELECTED;
     mc.fullinfo  = (rsc_addr + FULLINFO)->ob_state & SELECTED;
     mc.symbol_table = (rsc_addr + SYMBTAB)->ob_state & SELECTED;

     info_file = fopen(buffer, "wb");
     if(info_file != NULL)
     {    /* Masken-Felder in die Datei schreiben */
          putw(mc.extension, info_file);
          putw(mc.optimizer, info_file);
          putw(mc.assembler, info_file);
          putw(mc.linker, info_file);
          putw(mc.link_vdi, info_file);
          putw(mc.link_aes, info_file);
          for(i=0; i<4; i++)
          {    strlwr(mc.incl_lib[i]);
               s = mc.incl_lib[i];
               while(putc(*s++, info_file));
               s = mc.defin_val[i];
               while(putc(*s++, info_file));
               s = mc.undef_val[i];
               while(putc(*s++, info_file));
          }
          putw(mc.fp_lib, info_file);
          putw(mc.loadmap, info_file);
          putw(mc.fullinfo, info_file);
          putw(mc.symbol_table, info_file);
          fclose(info_file);
     }

     /* Platz fÅr die Kommandozeile reservieren */
     cmdl = malloc(1024);   /* mÅûte reichen ... */
     if(cmdl==NULL)
     {    form_alert(1, "[3][Fehler beim|Speicher fÅr|CMDL anfordern][FEHLER]");
          return(-1);
     }
     /* Kommandozeile aufbereiten */
     *cmdl = '\0';
     if(mc.optimizer)
          strcat(cmdl, " -O");
     if(!mc.assembler)
          strcat(cmdl, " -S");
     if(!mc.linker)
          strcat(cmdl, " -c");
     if(mc.fp_lib)
          strcat(cmdl, " -f");
     if(mc.loadmap)
          strcat(cmdl, " -m");
     if(mc.fullinfo)
          strcat(cmdl, " -v");
     if(mc.symbol_table)
          strcat(cmdl, " -t");
     for(i=0; i<4; i++)
          if(mc.incl_lib[i][0])
          {    strcat(cmdl, " -I");
               strcat(cmdl, mc.incl_lib[i]);
          }
     for(i=0; i<4; i++)
          if(mc.defin_val[i][0])
          {    strcat(cmdl, " -D");
               strcat(cmdl, mc.defin_val[i]);
          }
     for(i=0; i<4; i++)
          if(mc.undef_val[i][0])
          {    strcat(cmdl, " -U");
               strcat(cmdl, mc.undef_val[i]);
          }
     strcat(cmdl, " -o ");
     strcat(cmdl, mc.out_file);
     if(mc.extension == EXTTOS)
          strcat(cmdl, ".tos");
     if(mc.extension == EXTTTP)
          strcat(cmdl, ".ttp");
     if(mc.extension == EXTPRG)
          strcat(cmdl, ".prg");
     if(mc.extension == EXTACC)
          strcat(cmdl, ".acc");

     strcat(cmdl, " ");
     strcat(cmdl, mc.src_file);
     if(mc.link_vdi)
     {    strcat(cmdl, " ");
          strcat(cmdl, VDI_LIB_NAME);
     }
     if(mc.link_aes)
     {    strcat(cmdl, " ");
          strcat(cmdl, AES_LIB_NAME);
     }
     *cmdl = strlen(cmdl) - 1;

     /* PrÅfen, ob die Datei mit den Environment Variablen da ist */
     strcpy(buffer, progpath);
     strcat(buffer, "ENV");
     env_len = fsize(buffer);
     if(env_len == -1L)
     {    form_alert(1, "[3][Environment-Datei|nicht gefunden][FEHLER]");
          free(cmdl);
          return(-1);
     }

     /* Platz fÅr die Environment Variablen reservieren */
     env_ptr = lalloc(env_len);
     if(env_ptr == NULL)
     {    form_alert(1, "[3][Fehler beim|Speicher fÅr|ENV anfordern][FEHLER]");
          free(cmdl);
          return(-1);
     }

     /* Environment Daten einlesen */
     info_file = fopen(buffer, "rt");

     /* Lies Namen und Pfad des Compilers */
     s = buffer;
     while((*s++ = fgetc(info_file)) != '\n');
     *--s = '\0';

     /* Lies die einzelnen Environment Variables ein */
     s = env_ptr;
     while((*s = fgetc(info_file)) != EOF)
     {    if(*s == '\n')
               *s = '\0';
          s++;
     }
     *s = '\0';
     
     fclose(info_file);

     puts("\033E");

     /* Pexec() aufrufen und Compiler starten */
     if(gemdos(75, 0, buffer, cmdl, env_ptr)<0)
     {    form_alert(1, "[3][Fehler beim|Compilerstart][FEHLER]");
     }

     fprintf(stderr, "\n\232bersetzung beendet. Dr\201ck auf irgendeine Taste .....");

     free(env_ptr);
     free(cmdl);

     getch();
     return(0);
}

main(argc, argv)
int argc;
char *argv[];
{
int ap_id;
char rsc_fname[128];
register char *s;

     strcpy(progpath, argv[0]);
     s = progpath;
     while(*s++ != '.');
     *s = '\0';
     if(argc==2)
          strcpy(param, argv[1]);
     else
          param[0] = '\0';

     /* Application anmelden */
     if((ap_id=appl_init())<0)
     {    return(-1);
     }

     /* RSC-Datei laden */
     strcpy(rsc_fname, progpath);
     strcat(rsc_fname, "rsc");
     if(rsrc_load(rsc_fname))
     {    /* Wenn OK, dann Maus als Pfeil darstellen und ins Hauptprogramm */
          graf_mouse(ARROW, 0L);
          process_box();
          /* Platz fÅr RSC wieder freigeben */
          rsrc_free();
     }
     else /* Bei Fehler einfach Meldung ausgeben und Ende */
     {    form_alert(1, "[3][RSC-Datei nicht|gefunden!][FEHLER]");
     }

     /* Application wieder abmelden */
     appl_exit();
}

