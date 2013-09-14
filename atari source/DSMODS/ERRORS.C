/**********************************************************************/
/* ERRORS.C							      */
/* DATE CREATED: 04/14/88					      */
/* DATE MODIFIED: 02/06/89					      */
/**********************************************************************/ 
#include "alert.h"

char	*txterr[] =
{
   0L,
   "Character has no flash position!",
   "Double floating accent found    ",
   "Double space char found         ",
   "Line measure too short          ",
   "Line break error                ",
   "Text buffer full                ",
   "Text output memory error"
};

char notxt[] = "Out of text            ";
char iconstr[] = "[2][";
char okstr[] = "][OK]";
char alertstr[50];

char *alert_txt[] = 
{
	0L,
        "[3][ Unable to Locate Resource! ][OK]                   ",
        "[3][ Preview Functions Disabled. ][OK]                  ",
        "[1][ Printing Functions Disabled. ][OK]                 ",
        "[3][ Delete all regions? ][OK|CANCEL]                   ",
        "[3][ This Region is already| linked to an article. ][OK]",
        "[3][ Delete Page? ][OK|CANCEL]				 ",
        "[3][ Delete Region? ][OK|CANCEL]			 ",
        "[1][ File Not Found! ][OK]				 ",
        "[2][ Commence Printing? ][OK|CANCEL]			 ",
        "[3][ Unable to Open|Scanner Workstation! ][EXIT DESKSET]",
        "[3][ Unable to Open|Preview Workstation! ][EXIT DESKSET]",
	"[1][ Memory Allocation Error! ][OK] 		         ",
	"[1][ Memory Allocation Error! ][OK]			 ",
	"[3][ Critical Memory| Allocation Error! ][EXIT DESKSET]  ",
	"[3][ Memory Shortage Error! ][OK]			 ",
	"[1][ Disk Error!| - Cannot Open File... ][OK   ]         ",
	"[1][ Disk READ Error:| I/O Cancelled ][OK]	         ",
	"[1][ Disk Error!| - Cannot Close File... ][OK]   	 ",
	"[3][ Disk Error!| - Unable to Create File ][OK]  	 ",
	"[3][ Disk WRITE Error:| I/O Cancelled ][OK]		 ",
	"[3][ Disk Error!| - Unable to Delete File...][OK]        ",
	"[3][  File I/O Error!|Unable to Continue...][OK]        ",
	"[3][ Memory Shortage!|Cancelling Operation...][OK]      ",
	"[1][ File not found. Create new |file in editor?][OK|CANCEL]",
	"[1][ Close article before |entering editor!][OK]",
	"[1][ Clipboard is already full.][OK]",
        "[3][ Erase Current Base Page? ][OK|CANCEL]",
	"[3][  Delete Both|  Base Pages? ][OK|CANCEL]",
	"[3][ Not a Deskset file!][OK]",
 	"[3][ Not enough memory|for rulers!][OK]",
	"[3][ Not enough memory|to repel images!][OK]",
	"[3][ Not enough memory|to show image!][OK]",
	"[3][ Not enough memory|for dpi requested!][OK]",
	"[3][ Save Current Parameters? ][OK|CANCEL]",
	"[3][ Deskset will not run|in this resolution!][OK]",
	"[3][ GDOS Not Installed.|Please Install GDOS.][EXIT]",
	"[3][ File Already Exists!|Overwrite File? ][OK|CANCEL]",
	"[3][ Picture must be loaded| from default path.][OK]",
        "[3][ This File Is Empty!|Please Check Your File][SORRY]",
        "[3][ Delete Primitive? ][OK|CANCEL]",
	"[3][ Printer Not Responding|Please Check Your Printer.][CANCEL]",
	"[3][ Not Enough Memory|   Printing Disabled.][CANCEL]",
	"[3][ Paper Size Error|Please Check Paper Tray.][CANCEL]"
};

		
do_txterr(value)
char value;
{
   int index;
   strcpy(alertstr,iconstr);
   if(value > 0 && value <= 7)
   {
	index = (int)value;
	strcat(alertstr,txterr[index]);
   	strcat(alertstr,okstr);
   	form_alert(1,alertstr);

   }
}


alert_cntre(error_num)
int error_num;
{
       return(form_alert(1,alert_txt[error_num]));
}

