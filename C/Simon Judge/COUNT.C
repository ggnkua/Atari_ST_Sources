/******************************
 * Word Count for 1st. Word   *
 *----------------------------*
 * by Simon Judge             *
 * (c) Atari ST User          *
 *     July 1987              *
 ******************************/
 
/******************************
 * Include files              *
 ******************************/

#include <gemdefs.h> /* GEM declarations */
#include <stdio.h>   /* Standard I/O functions */
#include <string.h>  /* String functions */

/******************************
 * Contants                   *
 ******************************/

#define TRUE    1 /* Boolean values */
#define FALSE   0

#define  tab    9 /* 1st Word Reserved Codes */
#define  line_feed 10
#define  page_break 11
#define  form_feed 12
#define  carriage_return 13
#define  style_change 27
#define  stretch_space 28
#define  indent_space 29
#define  variable_space 30
#define  format_line 31
#define  fixed_space 32             

/******************************
 * External Variables         *
 ******************************/

extern int gl_apid; /* AES Application identification */

/******************************
 * Global Variables           *
 ******************************/
  
int phys_handle; /* physical workstation handle */
int vdi_handle;  /* virtual workstation handle */
int msgbuff[8];  /* event message buffer */
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];  /* storage for bindings */
int work_in[11];  /* Input to GSX parameter array */
int work_out[57]; /* Output from GSX parameter array */
int dummy;        /* dummy return variable */
int menu_id;      /* accessory identification */

FILE *fp; /* file pointer */

/*******************************
 * Main Routine                *
 *******************************/
 
main()
{
appl_init(); /* Initialise the AES */
if(gl_apid == -1) exit(1); /* exit if init failed */
phys_handle = graf_handle(&dummy, &dummy, &dummy, &dummy); /* Get physical device handle */
menu_id = menu_register(gl_apid, "  1st Count");/* Place accessory on menu */
do_accessory(); /* Perform the accessory */       
}

/*******************************
 * Perform Accessory Tasks     *
 *******************************/

do_accessory()
{
int event;

do 
{
event = evnt_mesag(&msgbuff);   /* Wait for message event */
wind_update(BEG_UPDATE);        /* Disable AES user interaction */
if ((msgbuff[0] == AC_OPEN) && (msgbuff[4] == menu_id))
{
open_vwork(); /* Open workstation */
word_count(); /* Perform word count */
v_clsvwk(vdi_handle); /* Close workstation */
}
wind_update(END_UPDATE); /* Enable AES user interaction */
} while(TRUE); /* Repeat forever */
}
  
/*******************************
 * Open Virtual Workstation    *
 *******************************/

open_vwork()
{
int i;
  
for(i=0; i<10; i++) work_in[i] = 1; /* initialise work array */
work_in[10]=2;
vdi_handle = phys_handle;
v_opnvwk(work_in, &vdi_handle, work_out);
if (!vdi_handle) exit(1); /* exit if call failed */
}

/*******************************
 * Do the Word Count           *
 *******************************/
 
word_count()
{     
int fs_iexbutton;
char fs_iinpath[30], fs_iinsel[30], filename [60], message[50], number[8];
int error;
    
strcpy(fs_iinpath, "A:\*.DOC");  /* set pathname */
strcpy(fs_iinsel, "");   /* set default filename */
fsel_input(&fs_iinpath, &fs_iinsel, &fs_iexbutton); /* Call file selector */
if (fs_iexbutton)                /* if correct button pressed */
{
strcpy(filename, fs_iinpath);  /* copy selected path to filename */
strcpy(rindex(filename, '\\') + 1, fs_iinsel); /* append selected filename */
fp = fopen(filename, "r");     /* open file for reading */
if (fp == NULL)                /* if fopen unsuccessful */
{
strcpy(message, "[1][");     /* create alert */
strcat(message, filename);
strcat(message, " cannot be found.");
strcat(message, "][Exit]");
form_alert(1, message);      /* display alert */
}
else        /* fopen was successful */
{
skip_over_ruler(&error); /* skip over 1st. Word ruler */
if (error) /* if not a 1st Word file, indicate so*/                                  
form_alert(1, "[1][This is not a FORMATTED|1st. Word file.][Exit]");
else      /* if it is a 1st. Word file */
{
strcpy(message, "[1][This file has "); /* create alert message */
sprintf(number, "%u", count());
strcat(message, number); /* include word count */      
strcat(message, " words][ O.K. ]");
form_alert(1, message);  /* display alert */
}
fclose(fp); /* close file */
}
}
}
 
/********************************
 * Skip over 1st. Word ruler    *
 ********************************/
 
skip_over_ruler(error) int *error;
{
int ch;
  
*error = (getc(fp) != format_line); /* check for format code */
while ((ch != ']') && (ch != EOF)) ch = getc(fp); /* pass over ruler */
}
   
/********************************
 * Get count                    *
 ********************************/

count()
{
int finish;
int temp_count = 0;

  
do
{
skip_space(&finish); /* jump over 'space' */
if (!finish) /* if not end of file */
{
skip_word(&finish); /* skip word */
temp_count = temp_count + 1; /* increment count */
}
} while (!finish); /* while not end of file */
return temp_count; /* function returns word count */
}
  
/*******************************
 * Skip space between words    *
 *******************************/
 
skip_space(finish) int *finish;
{
int ch;
  
ch = getc(fp); /* get character */
  
/* if it is a control code and not end of the file */
while (isctrlcode(ch) && !feof(fp)) 
{
/* if page break or style change then read over next data character */
if (((ch == page_break)||(ch == style_change)) && (!feof(fp))) ch = getc(fp);
ch = getc(fp); /* get a character */
}
*finish = (feof(fp)); /* end of file ? */
}
       
/*******************************
 * Skip over word              *
 *******************************/
  
skip_word(finish) int *finish;
{
int ch;
  
ch = getc(fp); /* get character */
  
/* if it is not a control code and not end of the file */
while (!isctrlcode(ch) && !feof(fp)) 
    {
    /* if style change then read over next data character */
    if ((ch == style_change) && (!feof(fp))) ch = getc(fp);
    ch = getc(fp);   /* get character */
    }
  *finish = (feof(fp));
  }
  
 /*********************************
  * Function to test if character *
  * is a control code             *
  *********************************/
  
int isctrlcode(ch) int ch;
  {
  return ((ch == tab)||(ch == page_break)||(ch == style_change)||
         (ch == stretch_space)||(ch == indent_space)||(ch == variable_space)||
         (ch == fixed_space)||(ch == line_feed)||(ch == form_feed)||
         (ch == carriage_return));
  }
