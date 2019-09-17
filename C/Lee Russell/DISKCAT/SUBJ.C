/******************************************************************/
/* PROGRAM : SUBJ.C                                               */
/* AUTHOR  : Lee Russell                                          */
/* VERSION : 2.0                                                  */
/* WRITTEN : 06/04/92                                             */
/* REVISED : 01/03/93                                             */
/* PURPOSE : To Maintain The Subject Code Data File For DISKCAT.C */
/******************************************************************/

#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stddef.h>
#include <subj.h>

/*******************************************************************/
/* Define the Macros And Global Variables Required To Make The GEM */
/* Interface.                                                      */
/*******************************************************************/

#define ROOT 0
#define rsc_name "SUBJ.RSC"

OBJECT *menu_tree;
short treex, treey, treew, treeh;
short default_button_state;
short normal_button_state;

int ap_id;

short xdesk, ydesk, wdesk, hdesk;
short *xd, *yd, *wd, *hd;
short xwork, ywork, wwork, hwork;
short *xw, *yw, *ww, *hw;
int mousex, mousey;

int event;
int dummy;

int wi_handle;

/* Define Temporary Variables To Hold Data Entry From TEDINFO Fields */

char tedit_dcode[2];
char tedit_descr[25];

/* DEFINE THE SUBJECT CODE DATA RECORD */

struct subj_code
       {
       int subj;
       char subjtxt[25];
       };

/* Define a global array of subj_code to hold the 25 subject categories. */

struct subj_code subtext[25];

/**************************************/
/* Now Define The Function Prototypes */
/**************************************/

void main(void);

/* GEM Control Functions */

void open_station(void);
void close_station(void);
void open_window(void);
void close_window(void);
void load_rsc(void);
void disp_rsc(int);
void set_mouse(int);
void set_default_button(void);
void get_tedinfo(OBJECT*, int, char*);
void set_tedinfo(OBJECT*, int, char*);
void reset_form1(void);
void quit_sys(void);

/* New User Defined Functions */

void error_bell(void);

/* SUBJ Control Functions */

void initialise(void);
int find_choice(void);
void do_choice(int);
void modi_subj(void);
void load_data(void);
void save_data(void);

/* End Of Function Prototype Definitions */

/*********************************/
/* THE MAIN FUNCTION BEGINS HERE */
/*********************************/

void main(void)
     {
     int option;

     open_station();
     load_rsc();
     initialise();
     set_default_button();
     open_window();

     while (1==1)
           {
           reset_form1();
           disp_rsc(FORM1);
           wind_title(wi_handle, " Use Buttons To Select Action ");
           reset_form1();
           set_mouse(POINT_HAND);
           form_do(menu_tree, 0);
           set_mouse(ARROW);
           option = find_choice();
           do_choice(option);
           }
     }

/*******************************/
/* THE MAIN FUNCTION ENDS HERE */
/*******************************/

void open_station(void)
     {
     ap_id = appl_init();
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
     int wi_kind;
     
     wi_kind = NAME;
     xw = &xwork;
     yw = &ywork;
     ww = &wwork;
     hw = &hwork;
     
     res = wind_get(DESK, WF_WORKXYWH, xw, yw, ww, hw);
     if (res == 0)
        {
        error_bell();
        form_alert(1,"[1][Can't Get Window Detail For DESK][QUIT]");
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
     
     default_button_state = menu_tree[OK].ob_state;
     normal_button_state = menu_tree[QUIT].ob_state;
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
        objc_change(menu_tree, OK, 0, treex, treey, treew, treeh, default_button_state, 1);
        objc_change(menu_tree, LOADFILE, 0, treex, treey, treew, treeh, normal_button_state, 1);
        objc_change(menu_tree, SAVEFILE, 0, treex, treey, treew, treeh, normal_button_state, 1);
        objc_change(menu_tree, EDIT, 0, treex, treey, treew, treeh, normal_button_state, 1);
        objc_change(menu_tree, QUIT, 0, treex, treey, treew, treeh, normal_button_state, 1);
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

void error_bell(void)
     {
     putchar(7);
     putchar(7);
     putchar(7);
     }

/**************************/
/* SUBJ Control Functions */
/**************************/

void initialise(void)
     {
     int cntr;

     /* Ensure there is no type-ahead buffer for the keyboard */

     setbuf(stdin,NULL);

     for (cntr=0; cntr<25; cntr++)
         {
         subtext[cntr].subj = cntr;
         subtext[cntr].subjtxt[0] = '\0';
         }
     }

int find_choice(void)
    {

    /* Scan The FORM1 Resource File Tree To See Which Objects Were Selected */
    
    int ret_val;
    
    if (menu_tree[LOADFILE].ob_state & 0x1)
       {
       ret_val = 1; /* Load Subject Code Description File */
       return ret_val;
       }
    if (menu_tree[SAVEFILE].ob_state & 0x1)
       {
       ret_val = 2; /* Save Subject Code Description File */
       return ret_val;
       }
    if (menu_tree[EDIT].ob_state & 0x1)
       {
       ret_val = 3; /* Edit A Subject Code Description */
       return ret_val;
       }
    if (menu_tree[QUIT].ob_state & 0x1)
       {
       ret_val = 4; /* QUIT */
       return ret_val;
       }
    ret_val = -1; /* Tag Error Condition */
    return ret_val;
    }
    
void do_choice(int option)
     {

     /* In theory the default condition should not be reached */
     /* due to data entry validation in get_choice(); it is   */
     /* included simply for completeness and peace of mind.   */

switch(option)
      {
      case 1: load_data();
              break;
      case 2: save_data();
              break;
      case 3: modi_subj();
              break;
      case 4: quit_sys();
              break;
     case -1: error_bell();
              form_alert(1,"[3][Nothing To Do !][OK]");
              break;
    default : error_bell();
              form_alert(1,"[3][Logic Control Error][QUIT]");
              quit_sys();
              break;
      }

     }

void modi_subj(void)
     {
     /* Only the subject code description can be altered. The file */
     /* MUST run in ascending numerical sequence.                  */

     int code_int;
     
     reset_form1();
     wind_title(wi_handle, " Enter Subject Code To Alter ");
     objc_change(menu_tree, LOADFILE, 0, treex, treey, treew, treeh, DISABLED, 1);
     objc_change(menu_tree, SAVEFILE, 0, treex, treey, treew, treeh, DISABLED, 1);
     objc_change(menu_tree, EDIT, 0, treex, treey, treew, treeh, DISABLED, 1);
     objc_change(menu_tree, QUIT, 0, treex, treey, treew, treeh, DISABLED, 1);

     disp_rsc(FORM1);
     form_do(menu_tree, 0);

     get_tedinfo(menu_tree, SUBCODE, tedit_dcode);

     code_int = atoi(tedit_dcode);

     /* code_int should range between 0 and 25 */

     if (code_int >=0 && code_int <=25)
        {
        objc_change(menu_tree, OK, 0, treex, treey, treew, treeh, default_button_state, 1);
        set_tedinfo(menu_tree, SUBDESCR, subtext[code_int].subjtxt);
        disp_rsc(FORM1);
        wind_title(wi_handle, " Edit Subject Code Description ");
        form_do(menu_tree, SUBDESCR);
        get_tedinfo(menu_tree, SUBDESCR, tedit_descr);
        strcpy(subtext[code_int].subjtxt, tedit_descr);
        reset_form1();
        return;
        }
     else
        {
        error_bell();
        form_alert(1,"[3][Invalid Code][OK]");
        reset_form1();
        return;
        }
     }

void load_data(void)
     {

     int close_error;
     int cntr;
     FILE *sub_file;
     char tmpvar[30];
     char *tmpvar_addr;

     cntr = 0;
     close_error = 0;
     tmpvar_addr = tmpvar;

     sub_file = fopen("subdata.dta","r");

     /* If fopen() returns a NULL pointer the file could not be opened. */

     if (sub_file == NULL)
        {
        error_bell();
        form_alert(1,"[3][Couldn't Open File][OK]");
        return;
        }

     for (cntr = 0; cntr <=25; cntr++)
         {
         if (feof(sub_file) == 0)
            {
            tmpvar_addr = fgets(tmpvar_addr, 30, sub_file);
            if (tmpvar_addr != NULL)
               {
               close_error = strlen(tmpvar);
               if (close_error < 25)
                  {
                  strncpy(subtext[cntr].subjtxt, tmpvar, close_error -1);
                  tmpvar_addr = tmpvar;
                  }
               else
                  {
                  error_bell();
                  form_alert(1,"[3][Data Too Long][OK]");
                  break;
                  }
               }
            if (tmpvar_addr == NULL)
               {
               error_bell();
               form_alert(1,"[3][Disk I/O Error][OK]");
               break;
               }
            }
         else
            {
            error_bell();
            form_alert(1,"[3][EOF Error][OK]");
            break;
            }
         }

     close_error = fclose(sub_file);

     /* If fclose() returns the value EOF the file could not be closed, */
     /* I presume therefore that the buffer may not be flushed.         */

     if (close_error != EOF)
        {
        form_alert(1,"[3][File Has Been Read][OK]");
        }
     else
        {
        error_bell();
        form_alert(1,"[3][Error Closing File|File May Be Open][OK]");
        }
     }

void save_data(void)
     {

     FILE *sub_file;
     int cntr;
     int close_error;

     sub_file = fopen("subdata.dta","w");

     /* If fopen() returns a NULL pointer the file could not be opened. */

     if (sub_file == NULL)
        {
        error_bell();
        form_alert(1,"[3][Couldn't Open File][OK]");
        return;
        }

     for (cntr = 0; cntr <=25; cntr++)
         {
         fprintf(sub_file,"%s\n",subtext[cntr].subjtxt);
         }

     close_error = fclose(sub_file);

     /* If fclose() returns the value EOF the file could not be closed, */
     /* I presume therefore that the buffer may not be flushed.         */

     if (close_error != EOF)
        {
        form_alert(1,"[3][File Has Been Updated][OK]");
        }
     else
        {
        error_bell();
        form_alert(1,"[3][Error Closing File|Data May Be Lost][OK]");
        }
     }

/***************************************************/
/* End-Of-File : SUBJ.C       (c) L. Russell, 1992 */
/***************************************************/
