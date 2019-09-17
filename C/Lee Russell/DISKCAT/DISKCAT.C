/***************************************************/
/* Program  : DISKCAT.C                            */	
/* Author   : Lee Russell                          */
/* Written  : 25/12/92                             */
/* Revised  : 02/03/93                             */
/* Language : HiSoft Lattice C 5.5                 */
/* Version  : 2.0                                  */
/* Purpose  : To Allow Quick Location Of Programs  */
/*            Held On Disk.                        */
/***************************************************/

#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stddef.h>
#include <math.h>
#include <dcat1.h>

/**********************************************************************/
/* Define The Macros And Global Variables Required To Make The GEM    */
/* Interface.                                                         */
/**********************************************************************/

#define ROOT 0
#define rsc_name "DCAT1.RSC"

OBJECT *menu_tree;                /* The Address Of The Resource File */
short treex, treey, treew, treeh; /* The Tree Clipping Rectangle      */
short default_button_state;       /* Used To Store Default ob_state   */
short normal_button_state;        /* Used To Store Normal ob_state    */

int ap_id ;                       /* The AES Application Code         */

short xdesk, ydesk, wdesk, hdesk; /* Desktop Dimensions               */
short *xd, *yd, *wd, *hd;         /* Pointers To Desktop Dimensions   */
short xwork, ywork, wwork, hwork; /* Window Dimensions                */
short *xw, *yw, *ww, *hw;         /* Pointers To Window Dimensions    */
int mousex, mousey;               /* Where Was the Mouse Clicked ?    */

int event;                        /* Which Event Occurred ?           */
int dummy;                        /* Dummy Parameter                  */

int wi_handle;                    /* AES Window Handle                */

/* Define temporary variables to hold data entry from TEDINFO fields */
     
char tedit_diskno[3];
char tedit_dsrce[30];
char tedit_dcode[2];
char tedit_fname[13];
char tedit_pname[13];
char tedit_descr[41];

/**********************************************************************/
/* Now Define The Macros & Storage Requirements For DISKCAT.          */
/**********************************************************************/

/* The array which will hold the catalogue information has been limited   */
/* to 300 records. This ceiling is defined by the MAXRECORD macro so that */
/* the code may be adapted to suit other installations.                   */

#define MAXRECORD 300

/* Define The Disk Record Data Type */

/* All operations on this data type are performed in RAM, */
/* NOT from disk. This is, however, the record format in  */
/* the disk file.                                         */

struct d_record
       {
       int disk_no;            /* Disk identifier                        */
       int next_rcd;           /* Next logical record for this subject   */
       char disk_source[30];   /* Source, ie PD Company, Magazine etc    */
       int subject;            /* Numeric subject code (Maximum of 25)   */
       char prg_folder[13];    /* The folder where the program is stored */
       char prg_name[13];      /* The name of the program                */
       char description[41];   /* A 41 character narrative field         */
       };

/* Define a global array of d_record MAXRECORD long */

static struct d_record disk_record[MAXRECORD];

/* free_rcd points to the next empty slot in disk_record.  */
/* last_used_rcd is an array of the last record allocated  */
/* to each of the 25 available subject categories.         */
/* The 25 subject categories are logically associated with */
/* user-defined topics.                                    */

int free_rcd;
int last_used_rcd[25];

/* Define The Subject Code Data Record */

static struct subj_code
              {
              int subj;
              char subjtxt[25];
              };

/* Define a global array of subj_code to hold the 25 subject categories. */

struct subj_code subtext[25];

char outstr[5]; /* Used to store int to char[] conversions in cvtitos()  */

/*************************************************************************/
/* Now Define The Function Prototypes.                                   */
/*************************************************************************/

void main(void);

/* GEM Control Functions */

void open_station(void);
void close_station(void);
void open_window(void);
void close_window(void);
void load_rsc(void);
void disp_rsc(int);
void disp_find(int);
void set_mouse(int);
void set_default_button(void);
void get_tedinfo(OBJECT *, int, char *);
void set_tedinfo(OBJECT *, int, char *); 
void reset_form1(void);
void reset_form2(void);
void reset_form3(void);
void reset_form4(void);
void reset_form5(void);
void reset_form6(void);
void reset_form7(void);
void reset_form8(void);
void quit_sys(void);

/* New User Defined Functions */

char *cvtitos(int);
void str_invert(char *);
void error_bell(void);
int print_string(char *, int);

/* DISKCAT Control Functions */

void initialise(void);
int find_choice(void);
void do_choice(int);
void add(void);
void add_rec(void);
void amend(void);
void amend_rec(void);
void amend_it(int);
void delete(void);
void del_rec(void);
void del(int);
int f_rec(char [13]);
void find_subj(void);
void find_subject(void);
void find_fold(void);
void find_folder(void);
void find_prog(void);
void find_program(void);
void list_data(void);
void l_data(void);
void load_file(void);
void load_f(void);
void load_f(void);
void read_error_msg(void);
char * read_file(char *, FILE *);
void remove_del_recs(void);
void save_file(void);
void save_f(void);

/* End Of Function Prototype Definitions                              */

/**********************************************************************/
/* The Main Program Begins Here                                       */
/**********************************************************************/

void main(void)
     {
     int choice;
     
     open_station();
     load_rsc();     
     initialise();
     set_default_button();     
     while (1==1)
           {
           open_window();
           disp_rsc(FORM1);
           wind_title(wi_handle, " SELECT OPTION ");
           reset_form1();
           set_mouse(POINT_HAND);
           form_do(menu_tree,0);
           set_mouse(ARROW);
           choice = find_choice();
           do_choice(choice);
           }
     }
    
/**********************************************************************/
/* Define The GEM Interface Control Functions                         */
/**********************************************************************/

void open_station(void)
     {
     ap_id = appl_init();         /* Set Up AES Global Arrays, Get Application Code */
     if (ap_id == -1)
        {
        error_bell();
        exit(EXIT_FAILURE);
        }
     }
    
void close_station(void)
     {
     appl_exit();
     }
     
void open_window(void)
     {
     int res;
     int wi_kind;                 /* Define Window Attributes */
     
     wi_kind = NAME;    
     xw = &xwork;
     yw = &ywork;
     ww = &wwork;
     hw = &hwork;
     
     res = wind_get(DESK, WF_WORKXYWH, xw, yw, ww, hw);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[1][Can't Get Window Detail For Desk][QUIT]");
        close_station();
        exit(EXIT_FAILURE);
        }
        
     wi_handle = wind_create(wi_kind, xwork, ywork, wwork, hwork);
     if (wi_handle <0)
        {
        error_bell();
        form_alert(1,"[3][Too Many Active Windows][QUIT]");
        close_station();
        exit(EXIT_FAILURE);
        }
        
     res = wind_open(wi_handle, xwork, ywork, wwork, hwork);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Open Window][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }
        
     res = wind_get(wi_handle, WF_WORKXYWH, xw, yw, ww, hw);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Get Info For New Window][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }        
     }
  
void close_window(void)
     {
     int res;
     
     res = wind_close(wi_handle);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Close Window][QUIT]");
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }
        
     res = wind_delete(wi_handle);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Delete Window][QUIT]");
        close_station();
        exit(EXIT_FAILURE);
        }        
     }
     
void load_rsc(void)
     {
     int res;
     
     res = rsrc_load(rsc_name);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Load Resource File][QUIT]");
        close_station();
        exit(EXIT_FAILURE);
        }
     }
           
void disp_rsc(int choice)
     {
     int res;
     
     res = rsrc_gaddr(R_TREE, choice, &menu_tree);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Find New Tree][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }
        
     form_center(menu_tree, &treex, &treey, &treew, &treeh);
     res = objc_draw(menu_tree, ROOT, MAX_DEPTH, treex, treey, treew, treeh);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Draw New Tree][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }
     }

void disp_find(int cntr)
     {
     int ptr;
     char d_no[5];
     char d_sub[5];
     
     strcpy(d_no, "     \0");
     strcpy(d_sub, "     \0");     
     strcpy(outstr, "     \0");

     cvtitos(disk_record[cntr].disk_no);
     strcpy(d_no, outstr);
     strcpy(outstr, "     \0");
     cvtitos(disk_record[cntr].subject);
     strcpy(d_sub, outstr);
     
     set_tedinfo(menu_tree, DISKNO8, d_no);
     set_tedinfo(menu_tree, SOURCE8, disk_record[cntr].disk_source);
     set_tedinfo(menu_tree, SUBJCODE8, d_sub);
     ptr = disk_record[cntr].subject;
     set_tedinfo(menu_tree, SUBJDESCR8, subtext[ptr].subjtxt);
     set_tedinfo(menu_tree, FOLDNAME8, disk_record[cntr].prg_folder);
     set_tedinfo(menu_tree, PROGNAME8, disk_record[cntr].prg_name);
     set_tedinfo(menu_tree, DESCRIPT8, disk_record[cntr].description);
     }

void set_mouse(int type)
     {
     graf_mouse(type, NULL);
     }

void set_default_button(void)
     {
     int res;
     
     res = rsrc_gaddr(R_TREE, FORM1, &menu_tree);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Find FORM1 Tree][QUIT]");
        close_station();
        exit(EXIT_FAILURE);
        }     
     
     default_button_state = menu_tree[OK1].ob_state;

     res = rsrc_gaddr(R_TREE, FORM8, &menu_tree);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Find FORM8 Tree][QUIT]");
        close_station();
        exit(EXIT_FAILURE);
        }
        
     normal_button_state = menu_tree[PEXIT].ob_state;
     }

void get_tedinfo(OBJECT *tree, int obj, char *dest)
     {
     char *source;
     
     source = ((TEDINFO *)tree[obj].ob_spec)->te_ptext; /* Extract address */
     strcpy(dest, source);
     return;
     }
     
void set_tedinfo(OBJECT *tree, int obj, char *source)
     {
     char *dest;
     
     dest = ((TEDINFO *)menu_tree[obj].ob_spec)->te_ptext; /* Set address for copy to TEDINFO */
     strcpy(dest, source);
     return;
     }

void reset_form1(void)
     {     
     objc_change(menu_tree, OK1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ADD1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, AMEND1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, DELETE1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, LISTDATA1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, FINDSUBJ1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, FINDFOLD1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, FINDPROG1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, LOADFILE1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, SAVEFILE1, 0, treex, treey, treew, treeh, default_button_state, 1);
     }

void reset_form2(void)
     {
     objc_change(menu_tree, OK1, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ABORT2, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }
    
void reset_form3(void)
     {
     objc_change(menu_tree, OK3, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ABORT3, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }
     
void reset_form4(void)
     {     
     objc_change(menu_tree, OK4, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ABORT4, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }

void reset_form5(void)
     {     
     objc_change(menu_tree, OK5, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ABORT5, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }

void reset_form6(void)
     {     
     objc_change(menu_tree, OK6, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ABORT6, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }

void reset_form7(void)
     {     
     objc_change(menu_tree, OK7, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, ABORT7, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }

void reset_form8(void)
     {     
     objc_change(menu_tree, NEXT, 0, treex, treey, treew, treeh, default_button_state, 1);
     objc_change(menu_tree, PEXIT, 0, treex, treey, treew, treeh, normal_button_state, 1);
     }

void quit_sys(void)
     {
     close_window();
     close_station();
     exit(EXIT_FAILURE);
     }
     
/**********************************************************************/
/* New User Defined Functions                                         */
/**********************************************************************/     

char *cvtitos(int x)
     {

     /* Convert Integers To Strings */
     
     static int i;
     static div_t ans;
     
     ans.quot = 0;
     ans.rem = 0;
     i = 0;
     
     if (x < 0)
        {
        *(outstr + i++) = '-';
        x = 0-x;
        }
        
     ans.quot = x;
     
     do
       {
       ans = div(ans.quot, 10);
       *(outstr + i++) = ans.rem + 48;
       }
       while (ans.quot >= 10);
    
     if (ans.quot > 0)
        {
        *(outstr + i++) = ans.quot + 48;
        }
       
     *(outstr + i) = '\0';
     if (*outstr == '-')
        {
        str_invert((outstr + 1));
        }
     else
        {
        str_invert(outstr);
        return (outstr);
        }
     }

void str_invert(char *s)
     {

     /* Reverse The Order Of A String */
     
     static char *p;
     
     if (!*s)
        {
        return;
        }
        
     p = s;
     while (*p) p++; p--;
     while (s < p) *s ^= *p, *p ^= *s, *s++ ^= *p--;
     }

void error_bell(void)
     {
     putchar(7);
     putchar(7);
     putchar(7);
     }

int print_string(char *s, int count)
    {

    /* List A String To The Parrallel Printer Port */
    
    int cntr;
    int wait_count;
    short prn_status;
    short out_char;
    
    out_char = 0;
    cntr = 0;    
    wait_count = 0;

    while (wait_count < 4)
          {
          prn_status = Cprnos(); /* Is The Printer Ready ? */
          if (prn_status == -1)
             {
             break;
             }
         wait_count++;
         sleep(1);
         }
          
    if (wait_count == 4)
       {
       error_bell();
       form_alert(1,"[3][Printer Not Ready][OK]");
       return -1;
       }
             
    while (cntr < count)
          {
          out_char = *s;
          prn_status = Cprnout(out_char);
          if (prn_status == 0)
             {
             error_bell();
             form_alert(1,"[3][Printer Error !][OK]");
             return -1;
             }
            
          cntr++;
          s++;
          } 
    return 0;
    }
                       
/**********************************************************************/
/* DISKCAT Control Functions                                          */
/**********************************************************************/

void initialise(void)
{
int cntr;

/* Ensure there is no type-ahead buffer for the keyboard */

setbuf(stdin,NULL);

/* The system will assume that the value -1 indicates both the   */
/* end of the disk_record linked list and the null situation     */
/* in last_used_rcd if a category has no records assigned to it. */

for(cntr=0; cntr<25; cntr++)
   {
   last_used_rcd[cntr]=-1;
   }

cntr = 0;
while (cntr < MAXRECORD)
      {
      disk_record[cntr].next_rcd = -1;
      cntr++;
      }

free_rcd = 0;

cntr = 0;
while (cntr <25)
      {
      subtext[cntr].subj = cntr;
      subtext[cntr].subjtxt[0] = '\0';
      cntr++;
      }
}

int find_choice(void)
    {

    /* Scan the FORM1 resource Tree to see which objects were selected */
    
    int ret_val;
    
    if (menu_tree[QUIT1].ob_state & 0x1)
       {
       ret_val = 10; /* QUIT */
       return ret_val;
       }
       
    if (menu_tree[OK1].ob_state & 0x1)
       {
       if (menu_tree[ADD1].ob_state & 0x1)
          {
          ret_val = 1;  /* ADD */
          return ret_val;
          }  
       if (menu_tree[AMEND1].ob_state & 0x1)
          {
          ret_val = 2;  /* AMEND */
          return ret_val;
          }
       if (menu_tree[DELETE1].ob_state & 0x1)
          {
          ret_val = 3;  /* DELETE */
          return ret_val;
          }
       if (menu_tree[LOADFILE1].ob_state & 0x1)
          {
          ret_val = 4;  /* LOAD FILE */
          return ret_val;
          }
       if (menu_tree[SAVEFILE1].ob_state & 0x1)
          {
          ret_val = 5;  /* SAVE FILE */
          return ret_val;
          }
       if (menu_tree[FINDSUBJ1].ob_state & 0x1)
          {
          ret_val = 6;  /* FIND SUBJECT */
          return ret_val;
          }
       if (menu_tree[FINDFOLD1].ob_state & 0x1)
          {
          ret_val = 7;  /* FIND FOLDER */
          return ret_val;
          }
       if (menu_tree[FINDPROG1].ob_state & 0x1)
          {
          ret_val = 8;  /* FIND PROGRAM */
          return ret_val;
          }
       if (menu_tree[LISTDATA1].ob_state & 0x1)
          {
          ret_val = 9;  /* LIST DATA FILE */
          return ret_val;
          }
       }
    ret_val = -1;  /* TAG ERROR CONDITION */
    return ret_val;
    }
    
void do_choice(int choice)
     {
     switch (choice)
            {
            case -1: error_bell();
                     form_alert(1,"[3][Nothing To Do !][OK]");
                     break;
            case  1: add();
                     break;
            case  2: amend();
                     break;
            case  3: delete();
                     break;
            case  4: load_file();
                     break;
            case  5: save_file();
                     break;
            case  6: find_subj();
                     break;
            case  7: find_fold();
                     break;
            case  8: find_prog();
                     break;
            case  9: list_data();
                     break;
            case 10: quit_sys();
                     break;
            default: form_alert(1,"[3][Selection Error][QUIT]");
                     quit_sys();
                     break;
            }
     }
     
void add(void)
     {
     char reset_ted[2]; /* Used to reset the TEDINFO fields of FORM2 */     
     int res;
     
     res = 0;
     reset_ted[0] = '\0';
     reset_ted[1] = '\0';
     
     close_window();              
     open_window();
     while (1 == 1)
           {
           res = rsrc_gaddr(R_TREE, FORM2, &menu_tree);
           if (res == 0)
              {
              error_bell();
              form_alert(1,"[3][Can't Find FORM2][QUIT]");
              wind_close(wi_handle);
              wind_delete(wi_handle);
              close_station();
              exit(EXIT_FAILURE);
              }

           set_tedinfo(menu_tree, DISKNO2, reset_ted);
           set_tedinfo(menu_tree, DISKSOURCE2, reset_ted);
           set_tedinfo(menu_tree, SUBJECTCODE2, reset_ted);
           set_tedinfo(menu_tree, FOLDERNAME2, reset_ted);
           set_tedinfo(menu_tree, PROGRAMNAME2, reset_ted);
           set_tedinfo(menu_tree, DESCRIPTION2, reset_ted);
           disp_rsc(FORM2);           
           set_mouse(POINT_HAND);
           wind_title(wi_handle, " ENTER DETAILS, ABORT TO EXIT ");
           form_do(menu_tree, DISKNO2);
           set_mouse(ARROW);
           if (menu_tree[ABORT2].ob_state & 0x1) /* Store this record ? */
              {
              break;
              }
           reset_form2();
           add_rec();
           }
     reset_form2();
     close_window();
     }
     
void add_rec(void)
     {
     get_tedinfo(menu_tree, DISKNO2, tedit_diskno);
     get_tedinfo(menu_tree, DISKSOURCE2, tedit_dsrce);
     get_tedinfo(menu_tree, SUBJECTCODE2,tedit_dcode);
     get_tedinfo(menu_tree, FOLDERNAME2, tedit_fname);
     get_tedinfo(menu_tree, PROGRAMNAME2,tedit_pname);
     get_tedinfo(menu_tree, DESCRIPTION2,tedit_descr);
     
     disk_record[free_rcd].disk_no = atoi(tedit_diskno);
     strcpy(disk_record[free_rcd].disk_source, tedit_dsrce);
     disk_record[free_rcd].subject = atoi(tedit_dcode);
     strcpy(disk_record[free_rcd].prg_folder,tedit_fname);
     strcpy(disk_record[free_rcd].prg_name, tedit_pname);
     strcpy(disk_record[free_rcd].description, tedit_descr);

     if (last_used_rcd[atoi(tedit_dcode)] >-1)
        {
        /* Update the linked list for this subject code */

        disk_record[last_used_rcd[atoi(tedit_dcode)]].next_rcd = free_rcd;
        }

     /* Store the array indice of this record to allow the record to be   */
     /* pointed to the next record for this subject code upon data entry. */

     last_used_rcd[atoi(tedit_dcode)] = free_rcd;

     free_rcd++;
     }

void amend(void)
     {
     close_window();
     open_window();
     disp_rsc(FORM3);
     set_mouse(POINT_HAND);
     wind_title(wi_handle, " ENTER NAME OF PROGRAM TO AMEND ");
     form_do(menu_tree, PROGRAMNAME3);
     set_mouse(ARROW);
     if (menu_tree[ABORT3].ob_state &0x1) /* Does the user want to Abort ? */
        {
        reset_form3();
        close_window();
        return;
        }
     reset_form3();
     amend_rec();
     }
     
void amend_rec(void)
     {
     int cntr;
     char d_no[5];
     char d_sub[5];
          
     /* Select Record To Amend */

     get_tedinfo(menu_tree, PROGRAMNAME3, tedit_pname);

     cntr = 0;
     cntr = f_rec(tedit_pname); /* Search DISK_RECORD for the name input */
     if (cntr == -1)
        {
        error_bell();
        form_alert(1,"[3][Program Does Not Exist In Table][OK]");
        close_window();
        }
       else
       {     
       strcpy(d_no, "     \0");
       strcpy(d_sub, "     \0");     
       strcpy(outstr, "     \0");

       cvtitos(disk_record[cntr].disk_no);
       strcpy(d_no, outstr);
       strcpy(outstr, "     \0");
       cvtitos(disk_record[cntr].subject);
       strcpy(d_sub, outstr);

       set_tedinfo(menu_tree, DISKNUMBER3, d_no);
       set_tedinfo(menu_tree, DISKSOURCE3, disk_record[cntr].disk_source);
       set_tedinfo(menu_tree, SUBJECTCODE3, d_sub);
       set_tedinfo(menu_tree, FOLDERNAME3, disk_record[cntr].prg_folder);
       set_tedinfo(menu_tree, DESCRIPTION3, disk_record[cntr].description);
       disp_rsc(FORM3);
       wind_title(wi_handle, " AMEND DETAILS AS REQUIRED ");
       form_do(menu_tree, PROGRAMNAME3);
       amend_it(cntr);
       }
     }

void amend_it(int cntr)
     {
     /* Now update the record */

     get_tedinfo(menu_tree, DISKNUMBER3, tedit_diskno);
     get_tedinfo(menu_tree, DISKSOURCE3, tedit_dsrce);
     get_tedinfo(menu_tree, SUBJECTCODE3,tedit_dcode);
     get_tedinfo(menu_tree, FOLDERNAME3, tedit_fname);
     get_tedinfo(menu_tree, PROGRAMNAME3, tedit_pname);
     get_tedinfo(menu_tree, DESCRIPTION3, tedit_descr);

     disk_record[cntr].disk_no = atoi(tedit_diskno);
     strcpy(disk_record[cntr].disk_source, tedit_dsrce);
     disk_record[cntr].subject = atoi(tedit_dcode);
     strcpy(disk_record[cntr].prg_folder, tedit_fname);
     strcpy(disk_record[cntr].prg_name, tedit_pname);
     strcpy(disk_record[cntr].description, tedit_descr);
     close_window();
     }

void delete(void)
     {
     close_window();
     open_window();
     disp_rsc(FORM4);
     set_mouse(POINT_HAND);
     wind_title(wi_handle, " ENTER NAME OF PROGRAM TO DELETE ");
     form_do(menu_tree, PROGRAMNAME4);
     set_mouse(ARROW);
     if (menu_tree[ABORT4].ob_state &0x1) /* Does the user want to Abort ? */
        {
        reset_form4();
        close_window();
        return;
        }
     reset_form4();
     close_window();
     del_rec();
     }
     
void del_rec(void)
     {
     int cntr;

     cntr = 0;

     get_tedinfo(menu_tree, PROGRAMNAME4, tedit_pname);
     cntr = f_rec(tedit_pname); /* Scan DISK_RECORD for the name input */
     if (cntr == -1)
        {
        error_bell();
        form_alert(1,"[3][Program Does Not Exist][OK]");
        }
     else
        {
        del(cntr);
        }
     }

void del(int cntr)
     {
     int pntr;
     int last_rec;
     int code;

     pntr = 0;
     last_rec = -1;
     code = disk_record[cntr].subject;

     /* Locate the previous record with this subject code which is not deleted */

     while (pntr < cntr)
           {
           if (disk_record[pntr].subject == code && disk_record[pntr].subject !=99)
              {
              last_rec = pntr;
              }
           pntr++;
           }

     if (last_rec >-1)
        {
        disk_record[last_rec].next_rcd = disk_record[cntr].next_rcd;
        }

     /* Logically a value of 99 indicates a deleted record */
     /* because there are only 25 valid subject categories */

     disk_record[cntr].subject = 99;
     }

int f_rec(char name[13])
    {
    int test;
    int cntr;
    int found;

    test = 0;
    cntr = 0;
    found = -1; /* found == -1 will indicate that the name was not found */

    while (cntr <= free_rcd)
          {
          test = strcmp(disk_record[cntr].prg_name, name);
          if (test == 0 && disk_record[cntr].subject != 99)
             {
             found = 0;
             break;
             }
          else
             {
             cntr++;
             }
    }

    if (found == -1)
       {
       cntr = -1;
       }

    return cntr;
    }

void find_subj(void)
     {
     close_window();
     open_window();
     disp_rsc(FORM5);
     set_mouse(POINT_HAND);
     wind_title(wi_handle, " ENTER SUBJECT CODE (1 25) TO SEARCH FOR ");
     form_do(menu_tree, SUBJECTCODE5);
     if (menu_tree[ABORT5].ob_state &0x1)
        {
        reset_form5();
        close_window();
        return;
        }
     find_subject();
     set_mouse(ARROW);
     close_window();
     }

void find_subject(void)
     {
     int cntr, res;

     cntr = 0;
     res = 0;

     get_tedinfo(menu_tree, SUBJECTCODE5, tedit_dcode);

     close_window();
     reset_form5();
     open_window();
     
     res = rsrc_gaddr(R_TREE, FORM8, &menu_tree);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Find FORM8][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }
      
     if (atoi(tedit_dcode) >-1 && atoi(tedit_dcode) <26)
        {
        while (cntr < free_rcd)
              {
              if (disk_record[cntr].subject != atoi(tedit_dcode))
                 {
                 cntr++;
                 }
              if (disk_record[cntr].subject == atoi(tedit_dcode))
                 {            
                 disp_find(cntr);
                 disp_rsc(FORM8);
                 wind_title(wi_handle, " NEXT for next record, EXIT to quit ");
                 form_do(menu_tree, 0);
                 if (menu_tree[PEXIT].ob_state & 0x1)
                    {
                    break;
                    }
                 if (disk_record[cntr].next_rcd != -1)
                    {
                    cntr = disk_record[cntr].next_rcd;
                    }
                    else
                    {
                    break;
                    }
            }
         }
     reset_form8();
     }

     if (atoi(tedit_dcode) <0 || atoi(tedit_dcode) >25)
        {
        error_bell();
        form_alert(1,"[3][Invalid Subject Code][OK]");
        }
}

void find_fold(void)
     {
     close_window();
     open_window();
     disp_rsc(FORM6);
     set_mouse(POINT_HAND);
     wind_title(wi_handle, " ENTER FOLDER NAME TO SEARCH FOR ");
     form_do(menu_tree, FOLDERNAME6);
     if (menu_tree[ABORT6].ob_state &0x1)
        {
        reset_form6();
        close_window();
        return;
        }
     find_folder();
     set_mouse(ARROW);
     close_window();
     }

void find_folder(void)
     {
     int cntr, test, res;

     test = -1;
     cntr = 0;
     res = 0;

     get_tedinfo(menu_tree, FOLDERNAME6, tedit_fname);

     close_window();
     reset_form6();
     open_window();

     res = rsrc_gaddr(R_TREE, FORM8, &menu_tree);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Find FORM8][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }

     while (cntr < free_rcd)
           {
           test = strcmp(disk_record[cntr].prg_folder, tedit_fname);
           if (test == 0 && disk_record[cntr].subject !=99)
              {
              disp_find(cntr);
              disp_rsc(FORM8);
              wind_title(wi_handle, " EXIT to quit ");
              objc_change(menu_tree, NEXT, 0, treex, treey, treew, treeh, DISABLED, 1);
              form_do(menu_tree, 0);
              reset_form8();
              return;
              }
           else
              {
              cntr++;
              }
           }

     error_bell();
     form_alert(1,"[3][Folder Not Found][OK]");
     reset_form8();
     }

void find_prog(void)
     {
     close_window();
     open_window();
     disp_rsc(FORM7);
     set_mouse(POINT_HAND);
     wind_title(wi_handle, " ENTER PROGRAM NAME TO SEARCH FOR ");
     form_do(menu_tree, PROGRAMNAME7);
     if (menu_tree[ABORT7].ob_state &0x1)
        {
        reset_form7();
        close_window();
        return;
        }
     find_program();
     set_mouse(ARROW);
     close_window();
     }

void find_program(void)
     {
     int cntr, test, res;

     cntr = 0;
     test =1;
     res = 0;
     
     get_tedinfo(menu_tree, PROGRAMNAME7, tedit_pname);

     close_window();
     reset_form7();
     open_window();

     res = rsrc_gaddr(R_TREE, FORM8, &menu_tree);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[3][Can't Find FORM8][QUIT]");
        wind_close(wi_handle);
        wind_delete(wi_handle);
        close_station();
        exit(EXIT_FAILURE);
        }

     while (cntr < free_rcd)
           {
           test = strcmp(disk_record[cntr].prg_name, tedit_pname);
           if (test  == 0 && disk_record[cntr].subject != 99)
              {
              disp_find(cntr);
              disp_rsc(FORM8);
              wind_title(wi_handle, " EXIT to quit ");
              objc_change(menu_tree, NEXT, 0, treex, treey, treew, treeh, DISABLED, 1);
              form_do(menu_tree, 0);
              reset_form8();
              return;
              }
           cntr++;
           }

     error_bell();
     form_alert(1,"[3][Program Not Found][OK]");
     reset_form8();
     }

void list_data(void)
     {
     close_window();
     l_data();
     }

void l_data(void)
     {
     int cntr, del_recs;
     char prn_out[45];
     int prn_len;
     int prn_status;
     char *s;

     del_recs = 0;

     cntr = vq_gdos();
     if (cntr == 0)
        {
        error_bell();
        form_alert(1,"[3][You Must Have GDOS Loaded|To Be Able To Print|Sorry!][OK]");
        return;
        }
   
     cntr = 0;

     strcpy (prn_out, "DISK CATALOGUE SYSTEM\r\n");
     s = prn_out;
     prn_len = strlen(prn_out);
     prn_status = print_string(s, prn_len);
     if (prn_status !=0)
        {
        return;
        }
    
     strcpy (prn_out, "=====================\r\n\n");
     s = prn_out;
     prn_len = strlen(prn_out);
     prn_status = print_string(s, prn_len);
     if (prn_status !=0)
        {
        return;
        }

     while (cntr < free_rcd)
           {
           if (disk_record[cntr].subject != 99)
              {
              cvtitos(cntr);
              strcpy(prn_out,"Record Number :- ");
              strcat(prn_out, outstr);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status !=0)
                 {
                 return;
                 }
                    
              cvtitos(disk_record[cntr].disk_no);
              strcpy(prn_out,"Disk Number   :- ");
              strcat(prn_out, outstr);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status !=0)
                 {
                 return;
                 }

              strcpy(prn_out, "Disk Source   :- ");
              strcat(prn_out, disk_record[cntr].disk_source);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status != 0)
                 {
                 return;
                 }
            
              strcpy(prn_out, "Subject       :- ");
              strcat(prn_out, subtext[disk_record[cntr].subject].subjtxt);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status != 0)
                 {
                 return;
                 }

              cvtitos(disk_record[cntr].subject);
              strcpy(prn_out,"Subject Code  :- ");
              strcat(prn_out, outstr);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status !=0)
                 {
                 return;
                 }

              strcpy(prn_out, "Folder        :- ");
              strcat(prn_out, disk_record[cntr].prg_folder);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status != 0)
                 {
                 return;
                 }

              strcpy(prn_out, "Program       :- ");
              strcat(prn_out, disk_record[cntr].prg_name);
              strcat(prn_out, "\r\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status != 0)
                 {
                 return;
                 }

              strcpy(prn_out, "Description   :- ");
              strcat(prn_out, disk_record[cntr].description);
              strcat(prn_out, "\r\n\n");
              s = prn_out;
              prn_len = strlen(prn_out);
              prn_status = print_string(s, prn_len);
              if (prn_status != 0)
                 {
                 return;
                 }
              }
           else
              {
              del_recs++;
              }
           cntr++;
           }

     if (del_recs >0)
        {
        error_bell();
        form_alert(1,"[3][File Contains Deleted Records.|You May Wish To Compress][OK]");
        }

     strcpy(prn_out, "The File Contains ");
     cvtitos(del_recs);
     strcat(prn_out, outstr);
     strcat(prn_out, " Deleted Records.\r\n");
     s = prn_out;
     prn_len = strlen(prn_out);
     prn_status = print_string(s, prn_len);
     if (prn_status != 0)
        {
        return;
        }
   
     if (del_recs > 0)
        {
        strcpy(prn_out, "You may wish to compress the database.\r\n");
        s = prn_out;
        prn_len = strlen(prn_out);
        prn_status = print_string(s, prn_len);
        }   
     }

void load_file(void)
     {
     close_window();
     load_f();
     }
     
void load_f(void)
     {
     int close_error;
     int cntr;
     char tmpvar[50];
     char *tmpvar_addr;
     int del;
     FILE *data_file;
     FILE *sub_file;

     close_error = 0;
     cntr = 0;
     del = 0;
     tmpvar_addr = tmpvar;

     data_file = fopen("dcat.dta","r");

     /* If fopen() has not returned a NULL pointer the file open operation */
     /* has been successful and the data can be read in.                   */

     if (data_file != NULL)
        {
        tmpvar_addr = read_file(tmpvar_addr, data_file);
        if (tmpvar_addr == NULL)
           {
           fclose(data_file);
           return;
           }
      free_rcd = atoi(tmpvar_addr);
      tmpvar_addr = tmpvar;

      while (cntr < 25)
            {
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            last_used_rcd[cntr] = atoi(tmpvar_addr);
            cntr++;
            }

      cntr = 0;
      while (cntr < free_rcd)
            {
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            disk_record[cntr].disk_no = atoi(tmpvar);
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            disk_record[cntr].next_rcd = atoi(tmpvar);
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            close_error = strlen(tmpvar);
            strncpy(disk_record[cntr].disk_source,tmpvar, close_error-1);
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            disk_record[cntr].subject = atoi(tmpvar);
            close_error = atoi(tmpvar);
            if (close_error == 99)
               {
               del++;
               }
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            close_error = strlen(tmpvar);
            strncpy(disk_record[cntr].prg_folder,tmpvar,close_error-1);
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            close_error = strlen(tmpvar);
            strncpy(disk_record[cntr].prg_name,tmpvar,close_error-1);
            strcpy(tmpvar,"                                                  ");
            tmpvar_addr = tmpvar;
            tmpvar_addr = read_file(tmpvar_addr, data_file);
            if (tmpvar_addr == NULL)
               {
               fclose(data_file);
               return;
               }
            close_error = strlen(tmpvar);
            strncpy(disk_record[cntr].description,tmpvar,close_error-1);

            cntr++;
            }

      close_error = fclose(data_file);

      /* Check whether the file close operation was successful. If it was not */
      /* then there is the possibility that the computer will still register  */
      /* the data file as being open.                                         */

      if (close_error == EOF)
         {
         error_bell();
         form_alert(1,"[3][Error Closing Input File.|File May Still Be Open.][OK]");                    
         }

      }

     /* If the pointer returned by fopen() is NULL the file open operation */
     /* was unsuccessful and an error message is given.                    */

    if (data_file == NULL)
       {
       error_bell();
       form_alert(1,"[3][The Data File Could Not Be Opened For Reading.][OK]");
       }

    /* Now read in the subject category descriptions. */

    sub_file = fopen("subdata.dta","r");

    if (sub_file != NULL)
       {
       cntr = 0;
       while (cntr < 25)
             {
             strcpy(tmpvar,"                                                  ");
             fgets(tmpvar,50,data_file);
             if (feof(data_file) == 0)
                {
                close_error = strlen(tmpvar);
                strncpy(subtext[cntr].subjtxt,tmpvar,close_error-1);
                }
             else
                {
                read_error_msg();
                fclose(sub_file);
                return;
                }
             cntr++;
             }
       }
       else
       {
       error_bell();
       form_alert(1,"[3][Subject Description File|Could Not Be Opened.][OK]");
       return;
       }

     form_alert(1,"[3][The Data Has Been Read.][OK]");

    fclose(sub_file);

    if (del != 0)
       {
       close_error = form_alert(1,"[3][Remove Deleted Records ?][YES|NO]");
       if (close_error == 1)
          {
          remove_del_recs();
          }
       }
    }

void read_error_msg(void)
     {
     error_bell();
     form_alert(1,"[3][Error When Reading Data File.|File May Be Corrupt][OK]");
     }

char * read_file(char *tmpvar, FILE *data_file)
     {
     char *tmpvar_addr; /* Temporary File Read Buffer */
     tmpvar_addr = tmpvar;
     
     tmpvar_addr = fgets(tmpvar,50,data_file);
     if (tmpvar_addr == NULL)
        {
        read_error_msg();
        }
     return tmpvar_addr;
     }

void remove_del_recs(void)
     {
     int cntr;
     int del;
     int rec_pntr;
     int temp_rec_pntr;

     del = 0;
     cntr = 0;

     /* Re-initialise the array of last used record */
     /* per subject code to allow the subject code  */
     /* linked list to be rebuilt.                  */

     for (cntr =0; cntr < 25; cntr++)
         {
         last_used_rcd[cntr] = -1;
         }

     /* Physically remove deleted entries */

     cntr = 0;

     while (cntr <free_rcd)
           {
           if (disk_record[cntr].subject == 99)
              {
              temp_rec_pntr = cntr;
              del++;
              while (temp_rec_pntr < free_rcd)
                    {
                    disk_record[temp_rec_pntr] = disk_record[temp_rec_pntr+1];
                    temp_rec_pntr++;
                    }
              }
           cntr++;
           }

     /* Logically free_rcd is now free_rcd-the number of deleted records. */

     free_rcd = free_rcd-del;

     /* Now rebuild the subject code linked list */

     cntr = 0;

     while (cntr < free_rcd)
           {
           rec_pntr = last_used_rcd[disk_record[cntr].subject];
           if (rec_pntr >-1)
              {
              disk_record[rec_pntr].next_rcd = cntr;
              last_used_rcd[disk_record[cntr].subject] = cntr;
              }
           else
              {
              last_used_rcd[disk_record[cntr].subject] = cntr;
              }
           cntr++;
           }
     }

void save_file(void)
     {
     close_window();
     save_f(); 
     }
     
void save_f(void)
     {
     int cntr;
     int close_error;
     FILE *data_file;

     close_error = 0;
     cntr = 0;

     data_file = fopen("dcat.dta","w");

     /* If the pointer returned by fopen() is NULL the file open operation */
     /* was unsuccessful and an error message is given.                    */

     if (data_file == NULL)
        {
        error_bell();
        form_alert(1,"[3][File Could Not Be Opened.][OK]");
        return;
        }

     /* A NULL pointer returned by fopen() causes the above 'IF ...' statement */
     /* to 'return' to the menu. The rest of this function applies, therefore, */
     /* only if the operation was successful.                                  */

     fprintf(data_file,"%d\n",free_rcd);
     while (cntr < 25)
           {
           fprintf(data_file,"%d\n",last_used_rcd[cntr]);
           cntr++;
           }
     cntr = 0;
     while (cntr < free_rcd)
           {
           fprintf(data_file,"%d\n",disk_record[cntr].disk_no);
           fprintf(data_file,"%d\n",disk_record[cntr].next_rcd);
           fprintf(data_file,"%s\n",disk_record[cntr].disk_source);
           fprintf(data_file,"%d\n",disk_record[cntr].subject);
           fprintf(data_file,"%s\n",disk_record[cntr].prg_folder);
           fprintf(data_file,"%s\n",disk_record[cntr].prg_name);
           fprintf(data_file,"%s\n",disk_record[cntr].description);
           cntr++;
           }

     close_error = fclose(data_file);

     /* Check whether the file close operation was successfully completed. */
     /* If it was not then it is likely that some data has been lost.      */

     if (close_error != EOF)
        {
        form_alert(1,"[3][Data File Update Completed.][OK]");
        }
     else
        {
        error_bell();
        form_alert(1,"[3][Error When Closing Data File.|File May Be Corrput][OK]");
        }
     }
                    
/**********************************************************************/
/* eof : DISKCAT.C     (c) L.J. Russell, 1993                         */
/**********************************************************************/
