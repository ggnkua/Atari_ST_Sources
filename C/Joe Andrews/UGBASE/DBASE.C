

/************************************************************************/
/*                                                                      */
/*         This is a program to keep track of STar members              */
/*         and their equipment.                                         */
/*                                                                      */
/************************************************************************/
/* Include our necessary files...  */

#include <dbase.h>
#include <osbind.h>
#include <stdio.h>
#include <gemdefs.h>

/* The usual required GEM arrays   */

int work_in[11],
    work_out[57],
    pxyarray[10],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

/*  Global variables  */
 
int handle,dum,event, rnum,rez;
int dial_x,vdial_x,tdial_x,rdial_x; /*  Dialog x coordinate     */
    dial_y,vdial_y,tdial_y,rdial_y; /*  Dialog y coordinate     */
    dial_w,vdial_w,tdial_w,rdial_w; /*  Dialog width            */
    dial_h;vdial_h,tdial_h,rdial_h; /*  Dialog height           */

int msgbuf[8];  /*   Event message buffer   */

char pathname[50],filename[13];   /*   file name buffers   */

/*   Structure to hold an object's description    */

typedef struct object
{
   int          ob_next;
   int          ob_head;
   int          ob_tail;
   unsigned int ob_type;
   unsigned int ob_flags;
   unsigned int ob_state;
   char         *ob_spec;
   int          ob_x;
   int          ob_y;
   int          ob_w;
   int          ob_h;
} OBJECT;

OBJECT *tree_addr,*menu_addr,
       *prnt_addr,*srch_addr,  /*  Pointers to our object structures */
       *kudo_addr;

FILE *prt;   /*  pointer to printer ID   */

/*  Structure to hold object text information    */

typedef struct text_edinfo
{
   char *te_ptext;
   char *te_ptmplt;
   char *te_pvalid;
   int  te_font;
   int  te_junk1;
   int  te_color;
   int  te_junk2;
   int  te_thickness;
   int  te_txtlen;
   int  te_tmplen;
} TEDINFO;

/*   Structure to hold all data base information   */

struct RECORD
{
	char lname[16];    /*  Last name       */   
        char fname[21];    /*  First name      */
	char addr[31];     /*  Address         */
	char city[21];     /*  City            */
	char state[3];     /*  State           */
	char zip[6];       /*  Zip code        */
	char phone[15];    /*  Phone #         */
        char status[11];   /*  Dues Status     */
	char comp[7];      /*  Computer type   */
	char drive[12];    /*  Drive(s) type   */
	char modem[16];    /*  Modem type      */
        char prnt[16];     /*  Printer type    */
	char other[26];    /*  Other stuff     */
	char intr1[26];    /*  Interests pt. 1 */
	char intr2[26];    /*  Interests pt. 2 */
};

struct RECORD dbase[100];
char *find_str();	 

/*  All strings for our alert boxes....   */

static char sure[] =  "[2][|Are you sure you want to quit?|][QUIT|CANCEL]";
static char cantopen[]="[1][| Can't open that file! |][SORRY]";
static char wrngfrmt[]="[1][| This file is not in| UGbase format!|][Crud!!]";
static char delete[]="[2][|  Are you sure you want|  to delete this entry?|][DELETE|CANCEL]";
static char clear[]="[2][CAUTION!|This will erase |any data in memory|Are you sure?][OK|CANCEL]";
static char full[]="[1][|Data base is full! you can't|add any more records!|][NUTS!!]";
static char empty[]="[1][|There are no records to delete!|][NUTS!!]";

/*  Printer codes for various functions. For Gemini 10X & compats only.
    Change these to fit your printer                                      */

char ffeed[2]={12,0};
char condensed[3]={27,15,0};
char expanded[4]={27,87,1,0};
char nrml[3]={27,64,0};

/*  Miscellaneous strings.....    */

char sepr2[136],title[30];

/*************************************************************************/

/*  This is the main routine   */

main ()
{
   appl_init ();
   
   rez=Getrez();
   if(rez)   /*  Check for high or med. rez and continue if OK   */
   {
     open_vwork ();
     do_kudos();              /*  List credits...    */
     menu_bar (menu_addr,1);  /*  Install our menu   */
     do_menu ();              /*  Monitors menu      */
     menu_bar(menu_addr,0);   /*  Turn off our menu  */
     graf_mouse(ARROW,&dum);  /*  Fix mouse pointer  */
     v_clsvwk (handle);       /*  Outta here!        */
   }
   else form_alert(1,"[1][|UGBase only works in|low or medium rez!|][@%&!*^%]");

   appl_exit ();
}

/*************************************************************************/

open_vwork ()
{
   int i;

/*  Get handle of work station and open it up!    */

   handle = graf_handle (&dum,&dum,&dum,&dum);
   for (i=0;i<10;work_in[i++]=1);
   work_in[10]=2;
   v_opnvwk (work_in,&handle,work_out);

/* Fills our separator string with dashes   */

   for(i=0;i<132;i++)
      sepr2[i]='-';

/*  Load in Resource file and assign addresses to each object    */

   rsrc_load("\dbase.rsc");
   rsrc_gaddr (R_TREE,DBMENU,&menu_addr);
   rsrc_gaddr (R_TREE,DBASE,&tree_addr);
   rsrc_gaddr (R_TREE,OUTPUT,&prnt_addr);
   rsrc_gaddr (R_TREE,KUDOS,&kudo_addr);
/*   rsrc_gaddr (R_TREE,DBSEARCH,&srch_addr);   */

   rnum=0;         /*  Sets our record counter to zero   */

   graf_mouse(POINT_HAND,&dum);  /* turns mouse into pointing hand  */

   
/*  Finds offsets to two data boxes in data base dialog box  */
/*  This will make updating the box smoother (hopefully!)    */

   vdial_w=528;
   tdial_w=528;
   vdial_h=96;
   tdial_h=80;
   rdial_w=176;
   rdial_h=80;

}

/*************************************************************************/

do_menu()
{
int check,quitflag,i,type;

   do
   {
        quitflag=0;   	/* Flag for telling when to exit this routine   */

/*  This monitors menu and lets us know when user has selected an item  */

        event = evnt_multi (MU_MESAG,1,1,1,0,0,0,0,0,0,0,0,0,0,msgbuf,
                            0,0,&dum,&dum,&dum,&dum,&dum,&dum);
         
        if(event==MU_MESAG)
        {

/*  Find out what user selected    */

            switch (msgbuf[0])
            {
                 case MN_SELECTED:
            
                     switch (msgbuf[3])
                     {
                     	case DESK:  /* it was credits option, so do credits */

                          if(msgbuf[4]==CREDITS)
                            do_kudos();
                            menu_tnormal(menu_addr,DESK,1); /* fix menu item */

                        break;
                        
                        case NFILE:  /*  File selected, now which option in
                                                file was selected?          */
  			  switch (msgbuf[4])
                          {
			      case NEW: /*  Clear out data base & start fresh */
                                check=form_alert(2,clear);
                                if(check==1)
                                {
                                    for(i=0;i<=rnum;i++)
                                      clear_dbase(i);
                                      rnum=0;           	
                                      do_dialog(0); 
                                }
                               break;

                               case OPEN:  /*  Open a new file  */
                                 if(sel_file())
                                 {
                                   check=form_alert(2,clear);
                                   if(check==1)
                                   {
                                    for(i=0;i<100;i++)
                                      clear_dbase(i);
                                    rnum=0;           	
                                     if(read_file())
                                       do_dialog(0);
                                   }
                                 }
                               break;

                               case SAVE:  /* Save file with current name  */
                                 write_file();
                               break;
 
                               case SAVEAS:  /*  Gets new name to save under */
                                 if(sel_file())
                                 {
                                    if(make_file())   
                                    write_file();
                                  }
			       break;
			       	
                               case ERASE:  /*  Erases data without entering
						dialog box                 */
                                 check=form_alert(2,clear);
                                 if(check==1)
                                 {
                                    for(i=0;i<=rnum;i++)
                                      clear_dbase(i);
                                    rnum=0;           	
                                 }
                               break;
                               
                               case EDIT: /* opens box for editing   */
                                 do_dialog(0);
                               break;
                                                 
                               case QUIT:  /* Exits program   */
                                 check=form_alert(2,sure);
                                 if(check==1) quitflag=1;
                                 else quitflag=0;
                               break;

                         }
                         menu_tnormal(menu_addr,NFILE,1); /* fix menu item */
                        break;
                         
                        case OPTIONS:  /* Options chose, find which item  */

                            switch (msgbuf[4])
                          {
                             case PRINT:  /* Wants to print, eh?   */
                                 print_data();
                             break;
                                    
                             case SORT:  /* Sorts data by last name  */
                               do_sort();
                             break;

                             case SEARCH:
                             /*   do_search();   */
                             break;
                              
                          }
                          menu_tnormal(menu_addr,OPTIONS,1); /* you know  */
                        break;            
                     } 
    
                 break;             
            }
        }
   }
   while (quitflag==0);
   
}

/*************************************************************************/
   
do_dialog (ent) 
int ent;
{

   int choice,check;

/* gets all good info on dialog box and draws growing box   */

      form_center (tree_addr,&dial_x,&dial_y,&dial_w,&dial_h);
      objc_offset(tree_addr,VITALS,&vdial_x,&vdial_y);
      objc_offset(tree_addr,TOYS,&tdial_x,&tdial_y);
      form_dial (FMD_START,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
      form_dial (FMD_GROW,0,0,10,10,dial_x,dial_y,dial_w,dial_h);  
      objc_draw(tree_addr,DBASE,2,dial_x,dial_y,dial_w,dial_h);

/* This loop monitors box and acts on user input     */
       do {
         get_data(ent);  /*  Gets current record for display  */
         choice = form_do (tree_addr,LNAME); /* Monitor box   */

         switch(choice)
         {

            case NEXT:  /*  Gets next record in file   */
              ent=ent+1;   
              if(ent>rnum) ent=rnum;
            break;

            case PREV:  /*  Gets previous record in file */
              ent=ent-1;
              if(ent<0) ent=0;
            break;

            case START:  /*  Goes to start of file   */
              ent=0;
            break;

            case END:  /*  Goes to end of file      */
              ent=rnum;
            break;

            case ADD: /*  Adds record to end of file  */
              save_data(ent++);
              rnum=rnum+1;
              if(rnum>100)
              {  
                  rnum=100;
                  form_alert(1,full);
                  ent=rnum;
              }
            break;

            case DELETE:  /* Deletes record from file  */
              if(rnum>0)
              {
                 check=form_alert(2,delete);
                 if(check==1)
                 {
                      del_rec(ent--);
                      if(ent<0) ent=0;
                      rnum--;
                      if(rnum<0) rnum=0;
                 }
              }
              else form_alert(1,empty);
            break;
        
            case UPDATE:  /* Updates current record   */
              save_data(ent);
            break;
         }
       }     
       while (choice != EXIT);

/*  Close box and go back to menu   */

/*      form_dial (FMD_SHRINK,0,0,10,10,dial_x,dial_y,dial_w,dial_h);  */
      form_dial (FMD_FINISH,0,0,10,10,dial_x,dial_y,dial_w,dial_h);

}

/*************************************************************************/

/*  This routine takes the data from the dialog box and saves it into its
    respective place in the file					*/

save_data(ent)
int ent;
{
 OBJECT *tree;

    find_str(tree_addr,LNAME,dbase[ent].lname);
    find_str(tree_addr,FNAME,dbase[ent].fname);
    find_str(tree_addr,ADDR,dbase[ent].addr);
    find_str(tree_addr,CITY,dbase[ent].city);
    find_str(tree_addr,STATE,dbase[ent].state);
    find_str(tree_addr,ZIP,dbase[ent].zip);
    find_str(tree_addr,PHONE,dbase[ent].phone);
    find_str(tree_addr,STATUS,dbase[ent].status);
    find_str(tree_addr,COMP,dbase[ent].comp);
    find_str(tree_addr,DRIVE,dbase[ent].drive);
    find_str(tree_addr,MODEM,dbase[ent].modem);
    find_str(tree_addr,PRNT,dbase[ent].prnt);
    find_str(tree_addr,OTHER,dbase[ent].other);
    find_str(tree_addr,INTR1,dbase[ent].intr1);
    find_str(tree_addr,INTR2,dbase[ent].intr2);

}

/*************************************************************************/

/* Used by above routine to get each item and save it   */

char *find_str(tree,obj,string)
int obj;
char *string;
OBJECT *tree;
{
        char *temp;
	TEDINFO *ob_tedinfo;
	
        ob_tedinfo=(TEDINFO *)tree[obj].ob_spec;
        temp=ob_tedinfo->te_ptext;
        strcpy(string,temp);
}

/*************************************************************************/

/*  Routine to find length of a given string   */

find_len(tree,obj)
int obj;
OBJECT *tree;
{
        int temp;
	TEDINFO *ob_tedinfo;
	
        ob_tedinfo=(TEDINFO *)tree[obj].ob_spec;
        temp=ob_tedinfo->te_txtlen;
        return(temp);
}

/*************************************************************************/

/* Reverse of find_str... writes each item back to dialog box   */

wrt_str(objnum,string)
int objnum;
char *string;
{
    TEDINFO *ob_tedinfo;
    
    ob_tedinfo = (TEDINFO *)tree_addr[objnum].ob_spec;
    ob_tedinfo->te_ptext=string;
}

/*************************************************************************/

/*  This routine gets a record from the file and places it in the dialog box */

get_data(ent)
int ent;

{
   wrt_str(LNAME,dbase[ent].lname);
   wrt_str(FNAME,dbase[ent].fname);
   wrt_str(ADDR,dbase[ent].addr);
   wrt_str(CITY,dbase[ent].city);
   wrt_str(STATE,dbase[ent].state);
   wrt_str(ZIP,dbase[ent].zip);
   wrt_str(PHONE,dbase[ent].phone);
   wrt_str(STATUS,dbase[ent].status);
   wrt_str(COMP,dbase[ent].comp);
   wrt_str(DRIVE,dbase[ent].drive);
   wrt_str(MODEM,dbase[ent].modem);
   wrt_str(PRNT,dbase[ent].prnt);
   wrt_str(OTHER,dbase[ent].other);
   wrt_str(INTR1,dbase[ent].intr1);
   wrt_str(INTR2,dbase[ent].intr2);
   objc_draw(tree_addr,VITALS,7,vdial_x,vdial_y,vdial_w,vdial_h);
   objc_draw(tree_addr,TOYS,7,tdial_x,tdial_y,tdial_w,tdial_h);
}

/*************************************************************************/

/*  Deletes a record and moves remaining records up to fill gap.    */

del_rec(num)
int num;
{
    int i;
    
    for(i=num;i<rnum;i++)
    {
        strcpy(dbase[i].lname,dbase[i+1].lname);
        strcpy(dbase[i].fname,dbase[i+1].fname);
        strcpy(dbase[i].addr,dbase[i+1].addr);
        strcpy(dbase[i].city,dbase[i+1].city);
        strcpy(dbase[i].state,dbase[i+1].state);
        strcpy(dbase[i].zip,dbase[i+1].zip);
        strcpy(dbase[i].phone,dbase[i+1].phone);
        strcpy(dbase[i].status,dbase[i+1].status);
        strcpy(dbase[i].comp,dbase[i+1].comp);
        strcpy(dbase[i].drive,dbase[i+1].drive);
        strcpy(dbase[i].modem,dbase[i+1].modem);
        strcpy(dbase[i].prnt,dbase[i+1].prnt);
        strcpy(dbase[i].other,dbase[i+1].other);
        strcpy(dbase[i].intr1,dbase[i+1].intr1);
        strcpy(dbase[i].intr2,dbase[i+1].intr2);
     }
      clear_dbase(i);
}

/*************************************************************************/

/*  Opens a file selector box and gets name and path of file to load   */

sel_file()
{
	int button;
	
        pathname[0]=Dgetdrv()+'A';
        strcpy(&pathname[1],":\*.*");
        fsel_input(pathname,filename,&button);
        strcpy(&pathname[strlen(pathname)-3],filename);
        if(button==1) return(1);
        else return(0);    
}

/*************************************************************************/

/*  Reads in file. If an error occurs, a flag is returned and alert box is
    shown. If all's OK, file is loaded and returns to menu         */
read_file()
{
       int i,fhand,magicnum;;

        fhand=Fopen(pathname,0);
        if(fhand>=0)
	{
                Fread(fhand,2L,&magicnum);
                if(magicnum!=0xBEAD)
                {
                    form_alert(1,wrngfrmt);
                    Fclose(fhand);
                    return(0); 
                }
                else {
         		Fread(fhand,2L,&rnum);
	        	for(i=0;i<=rnum;i++)
		          Fread(fhand,253L,dbase[i].lname);
                        Fclose(fhand);
                        return(1); 
                }  
         }
         else
         { 
            form_alert(1,cantopen);
            Fclose(fhand);
            return(0);
         }
 } 

/*************************************************************************/

/*  Writes info to specified file. If an error occurs, a flag is returned 
    and an alert box is printed.  */

write_file()
{
        int i,fhand,magicnum=0xBEAD;

	fhand=Fopen(pathname,1);
        if(fhand>=0)
	{
                Fwrite(fhand,2L,&magicnum);
		Fwrite(fhand,2L,&rnum);
		for(i=0;i<=rnum;i++)
		   Fwrite(fhand,253L,dbase[i].lname);
	}
	else form_alert(1,cantopen);
	Fclose(fhand);
}

/*************************************************************************/

/*  Creates a file for first time saves. Uses filename and path found in
    Sel_file() .  */

make_file()
{
	int fhand;
	fhand=Fcreate(pathname,0);
        if(fhand<0)
        {
           form_alert(1,cantopen);
           Fclose(fhand);
           return(0);
        }
        else
        { 
  	Fclose(fhand);
        return(1);
        }                           
}   
	
/*************************************************************************/

/* Used by delete_rec()and file clearing options, this routine clears a 
   record from memory.    */

clear_dbase(i)
int i;
{
   int ctr;
   for(ctr=0;ctr<253;ctr++)
     dbase[i].lname[ctr]='\0';

}

/*************************************************************************/

/* Selects a button in specified dialog box.  */

sel_btn(tree,which)
OBJECT *tree;
int which;
{
    int value;
    
    value=tree[which].ob_state;
    tree[which].ob_state=value|0x0001;
}

/*************************************************************************/

/* Deselects a button in specified dialog box   */

desel_btn(tree,which)
OBJECT *tree;
int which;
{
    int value;
    
    value=tree[which].ob_state;
    tree[which].ob_state=value&0xFFFE;
}

/*************************************************************************/

/*  Disables an object in the specified object tree.   */

dsable_btn(tree,which)
OBJECT *tree;
int which;
{
    int value;
    
    value=tree[which].ob_state;
    tree[which].ob_state=value|0x0008;
}

/*************************************************************************/

/*  Enables an object in a specified tree   */

enable_btn(tree,which)
OBJECT *tree;
int which;
{
    int value;
    value=tree[which].ob_state;
    tree[which].ob_state=value & 0xFFF7;
}

/*************************************************************************/

/*  This routine opens the printer box and monitors it for user input.
    It then calls the appropriate printout routine and returns to menu. */

print_data()
{
int type,style,choice;

/*  Sets up initial values for printer box buttons.    */

   enable_btn(prnt_addr,REGULAR);
   desel_btn(prnt_addr,REGULAR);
   desel_btn(prnt_addr,LABEL);
   dsable_btn(prnt_addr,PALL);
   dsable_btn(prnt_addr,PSOME);
   desel_btn(prnt_addr,SKINNY);
   desel_btn(prnt_addr,COLUMN);

/*  Open printer box  */

        form_center (prnt_addr,&dial_x,&dial_y,&dial_w,&dial_h);
        objc_offset(prnt_addr,STYLES,&rdial_x,&rdial_y);
        form_dial (FMD_START,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
        form_dial (FMD_GROW,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
     
        objc_draw(prnt_addr,0,2,dial_x,dial_y,dial_w,dial_h);
      
        do
        {
           choice=form_do(prnt_addr,PRTITLE);

           switch (choice)
           {
        	case LABEL:  /* Label selected, set flags and 
                                enable both print types  */
             	enable_btn(prnt_addr,REGULAR);
                objc_draw(prnt_addr,STYLES,2,rdial_x,rdial_y,rdial_w,rdial_h);
                type=1;
        	break;
        	
                case COLUMN:  /* Column selected. set flag and disable normal
                                 print. (Won't fit on a page!  )  */
                dsable_btn(prnt_addr,REGULAR);
                desel_btn(prnt_addr,REGULAR);
                sel_btn(prnt_addr,SKINNY);
                objc_draw(prnt_addr,STYLES,2,rdial_x,rdial_y,rdial_w,rdial_h);
                type=0;
                break;
                
                case REGULAR: /* Selects normal printing..  */
                style=1;
                break;
                
                case SKINNY:  /* Selects condensed printing  */
                style=0;
                break;
         
                case PALL:
                break;

                case PSOME:
                break;

                case PRINTIT: /*  Prints out records      */
                find_str(prnt_addr,PRTITLE,title);
                if(type) print_label(style,title);
                else print_column(title);
                break;
           } 
        }   
        while(choice!=CANCEL & choice !=PRINTIT);
        
/*  Close box and exit  */

        form_dial (FMD_SHRINK,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
        form_dial (FMD_FINISH,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
}

/*************************************************************************/

/* Prints title entered in printer box in double width  */

print_title(title)
char *title;
{
        int len;
        char spacestr[40];
        for(len=0;len<(40-strlen(title))>>1;spacestr[len++]=' ');
        spacestr[len]='\0';
        prt=fopen("PRT:","w");

        fprintf(prt,"%s",nrml);        
        fprintf(prt,"%s",expanded);

        fprintf(prt,"\n\n%s%s\n\n\n",spacestr,title);
}

/*************************************************************************/

/*  Routine to print columnar output   */

print_column(title)
char *title;

{
        int i,cnt;
        char tempstr[40];

        print_title(title);
        fprintf(prt,"%s",nrml); 
        fprintf(prt,"%s",condensed);        
        fprintf(prt,"  Name                                Dues Status");
        fprintf(prt,"         Phone");
        fprintf(prt,"        Computer    Printer             Modem");
        fprintf(prt,"            Drives\n");
        fprintf(prt,"%-132.132s\n",sepr2);
        cnt=0;
        for(i=0;i<=rnum;i++)
        {
           strcpy(tempstr,dbase[i].lname);
           strcat(tempstr,", ");
           strcat(tempstr,dbase[i].fname);
           fprintf(prt,"%-39.35s",tempstr);
           fprintf(prt,"%-15.10s",dbase[i].status);
           fprintf(prt,"%-18.14s",dbase[i].phone);
           fprintf(prt,"%-10.6s",dbase[i].comp);
           fprintf(prt,"%-19.15s",dbase[i].prnt);
           fprintf(prt,"%-19.15s",dbase[i].modem);
           fprintf(prt,"%-11.11s\n",dbase[i].drive);
           cnt++;
            if(cnt==50)
            {
                fprintf(prt,"%s",ffeed);
                cnt=0;
             }          
        }
        fprintf(prt,"%s",ffeed);
        fclose(prt);
}                
/*************************************************************************/

/*  Routine to print label type output. Gives every part of record  */

print_label(style,title)
int style;
char *title;
{
	int i,cnt;
        char *tempstr[40];
        print_title(title);

        fprintf(prt,"%s",nrml); 
        if(!style)
          fprintf(prt,"%s",condensed);        

        cnt=0; 
        for(i=0;i<=rnum;i++)
        {
          cnt++;        	
          strcpy(tempstr,dbase[i].lname);
          strcat(tempstr,", ");
          strcat(tempstr,dbase[i].fname);
          fprintf(prt,"%-50.35s%-10.10s\n",tempstr,dbase[i].status);
          fprintf(prt,"%s, %s, ",dbase[i].addr,dbase[i].city);
          fprintf(prt,"%-2.2s, %-5.5s\n",dbase[i].state,dbase[i].zip);
          fprintf(prt,"%-14.14s\n",dbase[i].phone);
          fprintf(prt,"Computer: %-6.6s     Drive(s): %-11.11s   Modem: %-15.15s\n",
           dbase[i].comp,dbase[i].drive,dbase[i].modem);
          fprintf(prt,"Printer: %-20.20s Other: %-25.25s\n",dbase[i].prnt,dbase[i].other);
          fprintf(prt,"Interests: %-25.25s%-25s\n",dbase[i].intr1,dbase[i].intr2);
          fprintf(prt,"%-79.79s\n",sepr2);
          if(cnt==8)
          {
             fprintf(prt,"%s",ffeed);
             cnt=0;
          } 
        }
        fprintf(prt,"%s",ffeed);
        fclose(prt);

}            
/*************************************************************************/

/*  This routine sorts all records by last name. It uses the bubble sort  */

do_sort()
{
  int i,chkflg;

  do
  {
      chkflg=0;
      for(i=0;i<rnum;i++)
      {
         if(strcmp(dbase[i+1].lname,dbase[i].lname)<0)
         {
             do_swap(i);
             chkflg=1;
         }
      }
  }
  while (chkflg==1);
}

/*************************************************************************/

/*  Swaps places with two adjacent records. Used by above routine  */

do_swap(which)
int which;

{
  int i,cnt;
  char temp;

  for(i=0;i<253;i++)
  {
     temp=dbase[which].lname[i];
     dbase[which].lname[i]=dbase[which+1].lname[i];
     dbase[which+1].lname[i]=temp;
  }
}  
/*************************************************************************/

/*  The search routine is not yet implemented. I am working on it and should 
    be finished shortly. The routine opens a dialog box with most of the
    fields and the user enters data into the fields he/she wants searched.
    The program will then search each field data was entered into and 
    marks each matching entry. 
*/
do_search()
{
}

/*************************************************************************/

/*  This routine gives credit where credit is due....(:-)   */

do_kudos()
{

        form_center (kudo_addr,&dial_x,&dial_y,&dial_w,&dial_h);
        form_dial (FMD_START,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
     
        objc_draw(kudo_addr,0,2,dial_x,dial_y,dial_w,dial_h);

        form_do(kudo_addr,0);

        form_dial (FMD_SHRINK,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
        form_dial (FMD_FINISH,0,0,10,10,dial_x,dial_y,dial_w,dial_h);
}

/*************************************************************************/

