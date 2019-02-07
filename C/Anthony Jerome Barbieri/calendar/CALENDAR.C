/*   Pro Calendar                    by Anthony Jerome Barbieri           */
/*                                      C.S.I.D #71451,550                */
/*  (c) 1988 Antic Publishing, Inc.                                       */
/*  A full featured calendar/appointment desk accessory which:            */
/*    (1)  Generates calendars from 1786 to 32767                         */
/*    (2)  Inserts major holidays                                         */
/*    (3)  Allows for entry of lists or appointments for specific days    */
/*    (4)  Saves or loads a given month from disk                         */
/*    (5)  Saves calendars in picture file format                         */
/*    (6)  Sounds alarms at specified times                               */

#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <string.h>
#include <stdio.h>

#define BASEYEAR 1786    /* a non-leap year with Jan 1st on Sunday */
#define MAXYEAR  32767   /* maxint for most systems                */
#define FALSE 0
#define TRUE 1
/*=======external variables===============================================*/
extern int      gl_apid;
/*==*/
 
/*                         GLOBAL DECLARATION                      */
int curmonth,curyear;              /* the current value of month and year */
int off;                           /* offset of current month */
int     menu_id ;                  /* our menu id */
OBJECT cal_dial[224];              /* storage for dialog box object tree */
int event[8];                         
int gl_wchar,gl_hchar,gl_wbox,gl_hbox; /* system sizes  */
int resolution;                    /* screen resolution */
char *days_text[32]={"  "," 1"," 2"," 3"," 4"," 5"," 6"," 7"," 8"," 9","10",
"11","12","13","14","15","16","17","18","19","20","21","22","23","24","25",
"26","27","28","29","30","31"};    /* text for inside calendar days */
                /***  text for inside buttons   ***/
char  *but_text[10]={"  PRIOR YEAR   ","  NEXT YEAR    ",
"  PRIOR MONTH  ","  NEXT MONTH   ","  SET DATE     ",
"  EDIT DAY     ","  SAVE CALENDAR","  LOAD CALENDAR","  PROGRAM INFO ",
"  QUIT PROGRAM "};    
                /***   text  for top of calendar     ***/
char *days_title={"  SUN     MON     TUE     WED     THU     FRI     SAT  "};
                 /***   text for holidays           */
char *hol_text[23]={"       ","NEW YR.","LINCOLN","ST. VAL","WASHTON",
"ST. PAT","INDEPEN","HALOWEN","VET DAY"," XMAS  ","MLK DAY","MOM DAY",
"MEMOR D","DAD DAY","LABOR D","COLMBUS"," ELECTN"," THANKS"," EASTER",
"ASH WED","GOOD FR","HANUKAH","PASSOVR"};
TEDINFO hol_ted[42];           /* structures pointing  to holiday fields*/
TEDINFO day_info[42][2];       /* structures pointing to info fields */
char edit_text[42][2][11];     /* text storage for INFO fields    */
typedef char appt_type[9][26];
appt_type *appt_info[42];      /* pointers to dynamically allocated memory*/
TEDINFO d_title;
                 /***   text for Calendar Title box   ***/
char *date_text[12]={" JANUARY "," FEBRUARY "," MARCH "," APRIL "," MAY ",
" JUNE "," JULY "," AUGUST "," SEPTEMBER "," OCTOBER "," NOVEMBER ",
" DECEMBER "};
char act_title[17];   /*** storage for the actual title  ***/
TEDINFO date;  
char *proceed={"[1][ If you change calendars you | will lose all the current | information. ][Continue|Cancel]"};
int first_time=TRUE,edited=FALSE;


/*==*/

leap(year)
register int year;        /* returns 0 if year is not leap, 1 if it is */
{
    if ((year%4)!=0)
       return(FALSE);
    else if ((year%100)!=0)
            return(TRUE);
    else if ((year%400)!=0)
            return(FALSE);
    else return(TRUE);
}

/*==*/

n_month(month,year)  /*given a month from 1 to 12, return the next month*/
int *month,*year;    /* if month is twelve then advance to next year    */
{
  if (*month==12){
     if (*year<MAXYEAR) ++*year;
     *month=1;
     }
     else ++*month;
   
}

/*==*/

p_month(month,year)  /* given a month from 1 to 12, returns the previous */
int *month,*year;    /* if month is 1, then decrease year                */
{
    if (*month==1){
     if (*year>BASEYEAR) --*year;
      *month=12;
      }
      else --*month;
}

/*==*/

get_date(month,year)  /*extracts month and year from system clock*/
int *month,*year;     /* defaults to January, 2028 on most systems  */
{
  long date;
  int temp;
  date=Gettime();
  temp=((date>>21) & 0xf);
  if (temp>0 && temp<13)
     *month=temp;
     else *month=1;        
  *year=(((date>>25) & 0x3f)+1980);
}

/*==*/

OBJECT obj_fields(next,head,tail,type,flags,state,spec,x,y,w,h)
int next,head,tail;
unsigned type,flags,state;
char *spec;
int x,y,w,h;
{                       /* fills out the characteristics of a graphic obj*/
    OBJECT temp;
    temp.ob_next=next;
    temp.ob_head=head;
    temp.ob_tail=tail;
    temp.ob_type=type;
    temp.ob_flags=flags;
    temp.ob_state=state;
    temp.ob_spec=spec;
    temp.ob_x=x;
    temp.ob_y=y;
    temp.ob_width=w;
    temp.ob_height=h;
    return(temp);
}

/*==*/

TEDINFO text_fields(txt,tmp,val,fnt,jnk,just,color,jnk2,thk,txtlen,tmplen)
char *txt,*tmp,*val;
int fnt,jnk,just,color,jnk2,thk,txtlen,tmplen;
{
   TEDINFO temp;
   temp.te_ptext=txt;     /* fills out the characteristics of text object*/
   temp.te_ptmplt=tmp;
   temp.te_pvalid=val;
   temp.te_font=fnt;
   temp.te_junk1=jnk;
   temp.te_just=just;
   temp.te_color=color;
   temp.te_junk2=jnk2;
   temp.te_thickness=thk;
   temp.te_txtlen=txtlen;
   temp.te_tmplen=tmplen;
   return(temp);
}

/*==*/

edit_day(edit_flag,day_rem,hol_rem,rem_lines,m_name,box_num,pntrs,year)
    /*** the main procedure which edits and prints appointments ***/
int *edit_flag,       /* Whether or not day has been edited */
    box_num,          /* 0-41, the number of the box being edited */
    year;             /* the year, for printing purposes  */
char *day_rem,        /* a pointer to the day, in text form */
     *hol_rem,        /* a pointer to the text of holiday line */
     rem_lines[][11], /* the matrix of reminder lines */
     *m_name;         /* the month name, for printout */
appt_type *pntrs[];   /* an array of pointers to appointments */
{
  extern char *calloc();
  static char *boxes[6]={"APPOINTMENTS AND THINGS TO DO","REMINDERS","PRINT",
  "CLEAR ALL","Cancel","OK"};
  OBJECT edit_info[22];
  TEDINFO temp_lines[9],reminders[2],hol_disp;
  int x,y,w,h,ob_count,pushed,cleared;
  appt_type temp_appt;             /* temporary storage of appointments */
  char temp_rem[2][11];            /* temporary storage of reminders */
  strcpy(temp_rem[0],rem_lines[0]);
  strcpy(temp_rem[1],rem_lines[1]);/* copy reminders into temp reminders */
  for(ob_count=0;ob_count<9;++ob_count)
      temp_appt[ob_count][0]='\0';      /* clear temporary array*/
  if (pntrs[box_num]!=NULL)             /* if there is a block, copy it */
     copy_appt(temp_appt,pntrs[box_num]);

          /*** SET UP OBJECT TREE ***/
  edit_info[0]=obj_fields(-1,-1,-1,G_BOX,NONE,OUTLINED,((resolution==2) ?
  (char *)0x21051:(char *) 0x11073),7*gl_wchar,7*gl_hchar,48*gl_wchar,15*gl_hchar);
  edit_info[1]=obj_fields(-1,-1,-1,G_BUTTON,NONE,SHADOWED,boxes[0],
  3*gl_wchar,gl_hchar,29*gl_wchar,gl_hchar);
  objc_add(edit_info,0,1);
  edit_info[2]=obj_fields(-1,-1,-1,G_BUTTON,NONE,SHADOWED,boxes[1],
  35*gl_wchar,gl_hchar,11*gl_wchar,gl_hchar);
  objc_add(edit_info,0,2);
  edit_info[3]=obj_fields(-1,-1,-1,G_BOX,NONE,SELECTED|SHADOWED,(char *)0xFF1042,
  3*gl_wchar,3*gl_hchar,29*gl_wchar,11*gl_hchar);
  objc_add(edit_info,0,3);
  for(ob_count=4;ob_count<=12;++ob_count){
     edit_info[ob_count]=obj_fields(((ob_count==12)?3:-1),-1,-1,G_FTEXT,
     EDITABLE,NORMAL,(char *)&temp_lines[ob_count-4],gl_wchar,
     (ob_count-3)*gl_hchar,27*gl_wchar,gl_hchar);
     objc_add(edit_info,3,ob_count);
     temp_lines[ob_count-4]=text_fields(temp_appt[ob_count-4],
     "->_________________________","XXXXXXXXXXXXXXXXXXXXXXXXX",3,0,0,
     0x180,0,0,26,28);
     }
  edit_info[13]=obj_fields(-1,-1,-1,G_BOX,NONE,SHADOWED,(char *)0xFF1000,
  35*gl_wchar,3*gl_hchar,11*gl_wchar,3*gl_hchar);
  objc_add(edit_info,0,13);
  edit_info[14]=obj_fields(-1,-1,-1,G_STRING,NONE,NORMAL,day_rem,0,0,
  2*gl_wchar,gl_hchar);
  objc_add(edit_info,13,14);
  edit_info[15]=obj_fields(-1,-1,-1,G_TEXT,NONE,NORMAL,(char *)&hol_disp,
  4*gl_wchar,0,6*gl_wchar,gl_hchar);
  objc_add(edit_info,13,15);
  hol_disp=text_fields(hol_rem,(char *)NULL,(char *)NULL,5,0,2,0x280,0,0,8,0);
  for(ob_count=16;ob_count<=17;++ob_count){
      edit_info[ob_count]=obj_fields(((ob_count==17)?13:-1),-1,-1,G_FTEXT,
      EDITABLE,NORMAL,(char *)&reminders[ob_count-16],0,(ob_count-15)*gl_hchar,
      11*gl_wchar,gl_hchar);
      objc_add(edit_info,13,ob_count);
      reminders[ob_count-16]=text_fields(temp_rem[ob_count-16],"__________",
      "XXXXXXXXXX",3,0,2,0x180,0,0,11,11);
      }
  for(ob_count=18;ob_count<22;++ob_count){
     edit_info[ob_count]=obj_fields(((ob_count==21)?0:-1),-1,-1,G_BUTTON,
     ((ob_count==21)?(SELECTABLE|EXIT|LASTOB):(SELECTABLE|EXIT)),
     NORMAL,boxes[ob_count-16],35*gl_wchar,(2*(ob_count-18)+7)*gl_hchar,
     11*gl_wchar,gl_hchar);
     objc_add(edit_info,0,ob_count);
    }
/*=========END OF TREE DECLARATION==================*/
  x=7*gl_wchar-3;y=7*gl_hchar-3;w=48*gl_wchar+6;h=15*gl_hchar+6;
  form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
  objc_draw(edit_info,0,2,x,y,w,h);
  pushed=form_do(edit_info,4);
  while(pushed!=20 && pushed!=21){ /* NOT CANCEL OR OK */
     if (pushed==19){   /* clear all */
        if (form_alert(1,"[1][ Are you sure you want to | clear all the appointments? ][Yes|Cancel]")==1){
            for(ob_count=0;ob_count<9;++ob_count)
               temp_appt[ob_count][0]='\0';
            objc_draw(edit_info,3,1,x,y,w,h);
        }
     }
     else if (pushed==18)     /* PRINT APPOINTMENTS */
             print_appt(temp_appt,m_name,day_rem,year);
     objc_change(edit_info,pushed,0,0,0,0,0,NORMAL,1);
     pushed=form_do(edit_info,4);
  }
  if (pushed==21){                 /* clicked on OK */
     *edit_flag=TRUE; /* this calendar has been edited */
     strcpy(rem_lines[0],temp_rem[0]);
     strcpy(rem_lines[1],temp_rem[1]); /* copy reminders to permanent */
     for(cleared=TRUE,ob_count=0;ob_count<9;++ob_count)
        if (temp_appt[ob_count][0]!='\0')
           cleared=FALSE;
     if (cleared){   /* IF appointments present */
        if(pntrs[box_num]!=NULL){  /* if memory already allocated */
            free(pntrs[box_num]);  /* free the memory */
            pntrs[box_num]=NULL;
            }
           else ;
         }
      else if(pntrs[box_num]==NULL){/* if no memory allocced yet */
             if ((pntrs[box_num]=(appt_type *)calloc(234,1))!=NULL)
                copy_appt(pntrs[box_num],temp_appt);
                else if (form_alert(1,"[1][ There is no memory to store | your appointments. Would you | at least like a printout of | them?][Yes|No]")==1)
                     print_appt(temp_appt,m_name,day_rem,year);
                     else ;
            }
           else copy_appt(pntrs[box_num],temp_appt);          
   }
  form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
}

/*=*/

print_appt(text_lns,m_name,d_name,year)
int year;
appt_type text_lns;  /* the lines of appointments */
char *m_name,*d_name;/* the month and day strings */
{
  int count,count2;
  char *line="\n*********************************";
  char tempbuff[14][35];
  if (Bcostat(0)){
  	   graf_mouse(2,0);   /* turn on busy signal */
  	   sprintf(tempbuff[0],line);
  	   sprintf(tempbuff[1],"\n* APPOINTMENTS AND THINGS TO DO *");
  	   sprintf(tempbuff[2],"\n*     %11s%2s, %-5d      *",m_name,d_name,year);
  	   sprintf(tempbuff[3],line);
  	   for(count=0;count<9;++count)
  	      sprintf(tempbuff[count+4],"\n*  ->%-25s  *",text_lns[count]);
  	   sprintf(tempbuff[13],"%s\n",line);
       for(count=0;count<14;++count)
          for(count2=0;count2<35;++count2)      /* send matrix to printer*/
             Bconout(0,tempbuff[count][count2]);
       graf_mouse(0,0); /* turn off busy signal */      
      }
  else form_alert(1,"[1][ Printer is not on. | Try again when it is. ][OK]");
}

/*=*/

copy_appt(array1,array2)
     /*** misc. procedure to copy arrays ***/ 
appt_type array1,array2;
{
   int x;
   for(x=0;x<9;++x)
      strcpy(array1[x],array2[x]);
}

/*=*/

set_date(month,year)    /* allows user to explicitly set date for calendar*/
int *month,*year;
{  
        OBJECT info_dial[17];       /* storage for dialog box objects   */
        char t_entry[6];            /* text entry string  */
        long temp_year;             /* temporary year entry integer  */
        TEDINFO year_input;         
        int x,y,w,h,ob_count,pushed;

    /** object tree declaration ***/

        info_dial[0]=obj_fields(-1,-1,-1,G_BOX,NONE,OUTLINED,(resolution==2) ? 
        (char *) 0x11041: (char *) 0x11073,4*gl_wchar,7*gl_hchar,54*gl_wchar,15*gl_hchar);
        info_dial[16]=obj_fields(-1,-1,-1,G_IBOX,NONE,NORMAL,(char *)0,0,0,
        54*gl_wchar,8*gl_hchar);
        objc_add(info_dial,0,16);
        for(ob_count=1;ob_count<13;++ob_count){  /* month buttons */
           info_dial[ob_count]=obj_fields(-1,-1,-1,G_BUTTON,SELECTABLE|RBUTTON,
       NORMAL,date_text[ob_count-1],2*gl_wchar+((ob_count-1)%4)*13*gl_wchar,
           2*gl_hchar+((ob_count+3)/4-1)*2*gl_hchar,11*gl_wchar,gl_hchar);
           objc_add(info_dial,16,ob_count);
        }
                     /*      text entry field      */     
        objc_change(info_dial,*month,0,0,0,0,0,SELECTED,0);/*color cur. month*/
        info_dial[13]=obj_fields(-1,-1,-1,G_FTEXT,EDITABLE,NORMAL,
        (char *)&year_input,19*gl_wchar,9*gl_hchar,16*gl_wchar,gl_hbox);
        objc_add(info_dial,0,13);
        sprintf(t_entry,"%-5d",*year);
        year_input=text_fields(t_entry,"ENTER YEAR:_____","99999",3,0,2,0x180,
                               0,0,6,17);
                    /*       exit buttons          */
        info_dial[14]=obj_fields(-1,-1,-1,G_BUTTON,SELECTABLE|EXIT|DEFAULT,
        NORMAL,"OK",18*gl_wchar,12*gl_hchar,8*gl_wchar,gl_hbox);
        objc_add(info_dial,0,14);
        info_dial[15]=obj_fields(0,-1,-1,G_BUTTON,SELECTABLE|EXIT|LASTOB,NORMAL,
        "Cancel",28*gl_wchar,12*gl_hchar,8*gl_wchar,gl_hbox);
        objc_add(info_dial,0,15);
        x=4*gl_wchar-3;y=7*gl_hchar-3;w=54*gl_wchar+6;h=15*gl_hchar+6;
        form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
        objc_draw(info_dial,0,2,x,y,w,h);
        pushed=form_do(info_dial,13);           /* draw dialog and get input*/
        if (pushed==14){
        if (strlen(t_entry)!=0){
        temp_year=strtol(t_entry,(char **)NULL,10);  /* error traps*/
        if (temp_year>=BASEYEAR && temp_year<=MAXYEAR)
        *year=(int) temp_year;
        }
        for(ob_count=1;ob_count<13;++ob_count)
        if (info_dial[ob_count].ob_state&SELECTED)  /* which month?*/
        *month=ob_count;
        }
        form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
        if (pushed==15) return(0);
           else return(1);  
}

/*==*/

/* returns the length of a month + special leap year case */
length(month,year)
register int month,year;
{
    switch (month) {
    case 1:case 3:case 5:case 7:case 8:case 10:case 12:
         return(31);
    case 4:case 6:case 9:case 11:
         return(30);
    case 2:
         if (leap(year))
            return(29);
            else return(28);
    }
}

/*==*/

char *name(month)    /* returns a pointer to name of month   */
int month;
{
   return(date_text[month-1]); 
}

/*==*/

 offset(month,year)  /*determines what day 1st of month falls on */
 int month,year;
 {
    register int tempoff,tempmonth,tempyear;
    for(tempoff=0,tempyear=BASEYEAR;tempyear<year;++tempyear) {
       if (leap(tempyear))
          tempoff+=2;
          else ++tempoff;
       tempoff%=7;
     }
    for(tempmonth=1;tempmonth<month;++tempmonth) {
       tempoff+=(length(tempmonth,tempyear)%7);
     }
    return(tempoff%7);   
 }

/*==*/

main()
{
   int what_hap,      /* event return variable */
       dummy,         
       ryear,rmonth,rday,rhour,rmin;     /* the real year,month, etc */
   char *al_text;      /* alarm text pointer */
   appl_init();
   menu_id=menu_register(gl_apid,"  Pro Calendar");/* put name in menu */
   graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);/* get char sizes */
   get_date(&curmonth,&curyear);                /* get date from clock */
   resolution=Getrez();
   build_tree();    /* set up main object tree */
   while (TRUE) {  /* loop forever */
      what_hap=evnt_multi(MU_TIMER|MU_MESAG,0,0,0,0,0,0,0,0,0,0,0,0,0,
      event,0xDEA8,0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
      if(what_hap&MU_MESAG)/* accessory was called */
         if ((event[0]==40) && (event[4]==menu_id))
            if (!resolution)   /* if in low resolution */
              form_alert(1,"[3][ | Only works in MEDIUM RES | or HIGH RES ][Abort]");
              else {wind_update(BEG_UPDATE);
                    startup();
                    wind_update(END_UPDATE);
                   }
      if(what_hap&MU_TIMER){      /* time to check alarms */
        get_rtime(&ryear,&rmonth,&rday,&rhour,&rmin);
        if(!first_time && ryear==curyear && rmonth==curmonth)
          if(alarm(rday,rhour,rmin,&al_text))
            display_alarm(al_text);
      } /* end of alarm check */  
   }/* END OF WHILE LOOP */
}   

/*==*/

int alarm(day,hour,min,textp)
/* if there is an alarm in this day, textp returns a pointer to it */
int day,hour,min;
char **textp;
{
   int count,thour,tmin;
   if(appt_info[off+day-1]==NULL)
     return(0); /* not even any appointments yet */
   for(count=0;count<9;++count)
       if(sscanf(((*appt_info[off+day-1])[count]),"#%d:%d",&thour,&tmin)==2)
          if(hour==thour && min==tmin){
             *textp=(*appt_info[off+day-1])[count];
             return(1);
           }
   return(0);/* no alarm found */
}

/*==*/

display_alarm(al_line)
/* displays already found alarm */
char *al_line;
{   char alert_str[80];
    strcpy(alert_str,"[3][    IT'S TIME TO....    | ");
    strcat(alert_str,al_line);
    strcat(alert_str," | ][OK]");
    Bconout(2,7);  /* ring the bell */
    form_alert(1,alert_str);  /* display alarm */
}

/*==*/

get_rtime(year,month,day,hour,min) /* gets the current system time */
int *year,*month,*day,*hour,*min;
{
  unsigned int date,time;
  date=Tgetdate();/* get system date */
  time=Tgettime();/* get system time */
  *year=((date>>9)&0x7F)+1980;
  *month=(date>>5)&0x0F;
  *day=date&0x1F;
  *hour=(time>>11)&0x1F;
  *min=(time>>5)&0x3F;
}  

/*==*/

startup()
{
int pushed,x,y,w,h;
static int cur_day=96;
char *credit={"[0][       Pro Calendar | written by Anthony Barbieri |   ½ 1988 Antic Publishing   | ][OK]"};
    graf_mouse(0,0);
    objc_change(cal_dial,11,0,0,0,0,0,NORMAL,0);  /* TURN OFF QUIT BUTTON*/
    if (first_time){
           for(pushed=0;pushed<42;++pushed)
              appt_info[pushed]=NULL;
           do_cal(curmonth,curyear,&edited);
        }    
 	first_time=FALSE;
 	form_center(cal_dial,&x,&y,&w,&h);
 	form_dial(FMD_START,x,y,w,h,0,0,0,0);
 	form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
 	objc_draw(cal_dial,0,3,x,y,w,h);
 	pushed=form_do(cal_dial,0);
 	while (pushed != 11 ){/* start of while */
       if(pushed<=10){ /* start of if #1*/
        if(pushed<7){ /* start of if #2 */
         if(!edited || form_alert(1,proceed)==1){/* start of if #3*/
          switch (pushed){
/* prev year*/case 2:do_cal(curmonth,((curyear==BASEYEAR) ? curyear :--curyear),&edited);
                     break;
/* next year*/case 3:do_cal(curmonth,((curyear==MAXYEAR) ? curyear :++curyear),&edited);
                     break;
              case 4:p_month(&curmonth,&curyear);/*prev month*/  
                     do_cal(curmonth,curyear,&edited);
                     break;
              case 5:n_month(&curmonth,&curyear);/*next month*/  
                     do_cal(curmonth,curyear,&edited);
                     break;
              case 6:if (set_date(&curmonth,&curyear))
                        do_cal(curmonth,curyear,&edited);
                     break;
          } /* end of switch */
          objc_draw(cal_dial,223,2,x,y,59*gl_wchar,23*gl_hchar);
        }  /* end of if #3*/
        }  /* end of if #2 */   
          else if(pushed==7){
           if(cal_dial[cur_day].ob_state&SELECTED){
               edit_day(&edited,cal_dial[cur_day].ob_spec,hol_ted[cur_day-55].te_ptext,
               edit_text[cur_day-55][0],name(curmonth),cur_day-55,appt_info,curyear);
               objc_draw(cal_dial,223,2,x,y,59*gl_wchar,23*gl_hchar);
               }
             else form_alert(1,"[1][ You must first select a day | by clicking on the date | before you can edit it. ][OK]");
          }
            else if(pushed==8){ /* SAVE CALENDAR */
                   if(form_alert(1,"[2][ Would you like to save | your calendar as DATA or a  | PICTURE? ][Data|Picture]")==1)
                      save_cal(curmonth,curyear,edit_text,appt_info);
                      else save_pic(curmonth,curyear);
                   }
            else if(pushed==9){
                   if(!edited || form_alert(1,proceed)==1) /* LOAD CALENDAR*/
                      load_cal(&curmonth,&curyear,edit_text,appt_info,&edited);
                   }        
            else if(pushed==10) form_alert(1,credit);/* program info */
          objc_change(cal_dial,pushed,0,0,0,0,0,NORMAL,1);
      } /* end of if #1*/
      else if(pushed>=55 && pushed<=96){
           objc_change(cal_dial,cur_day,0,0,0,0,0,NORMAL,1);
           if(cur_day!=pushed || cur_day==pushed && !cal_dial[cur_day].ob_state)
             objc_change(cal_dial,pushed,0,0,0,0,0,SELECTED,1);
           cur_day=pushed;
         }
        pushed=form_do(cal_dial,0);
      }  /* end of the while */
      form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
      form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
 }

/*==*/

save_cal(month,year,reminders,appointments)/* saves calendar data to disk*/
int month,year;
char reminders[][2][11];  /* the two line daily reminders */
appt_type *appointments[];
{  int count,fd,nothing=NULL,something=1;
   char item[40];/* output file name */
   char *de="[1][ DISK WRITING ERROR. ][OK]";
   sprintf(item,"%.3s%d.CAL\00",name(month)+1,year);/* default filename*/
   if(get_out_file(item)==1){/* clicked on OK */
     graf_mouse(2,0) ;/* turn on busy signal */
     if((fd=Fcreate(item,0))>=0)
       if(Fwrite(fd,2L,(char *)&month)==2L)
         if(Fwrite(fd,2L,(char *)&year)==2L)
           if(Fwrite(fd,924L,&reminders[0][0][0])==924L)
             for(count=0;count<42;++count){
                if(appointments[count]==NULL)
                  if(Fwrite(fd,2L,(char *)&nothing)==2L)
                    ;
                    else {Fclose(fd);Fdelete(item);form_alert(1,de);break;}
                  else{if(Fwrite(fd,2L,(char *)&something)==2L)
                         if(Fwrite(fd,234L,&((*appointments[count])[0][0]))==234L)
                            ;
                           else{Fclose(fd);Fdelete(item);form_alert(1,de);break;}
                         else {Fclose(fd);Fdelete(item);form_alert(1,de);break;}
                      }
                  if(count==41) Fclose(fd);
              }/* end of for Loop*/ 
           else {Fclose(fd);Fdelete(item);form_alert(1,de);}
         else {Fclose(fd);Fdelete(item);form_alert(1,de);}
       else {Fclose(fd);Fdelete(item);form_alert(1,de);}
     else form_alert(1,"[1][ CAN'T OPEN DISK FILE. ][OK]");
     graf_mouse(0,0);
   }
}  

/*==*/

load_cal(monthp,yearp,reminders,appointments,edp)
int *monthp,*yearp,*edp;
char reminders[][2][11];
appt_type *appointments[];
{
  extern char *calloc();
  int tmonth,tyear;  /* temporary holders of load month and year */
  char *inv="[1][ Invalid File Format. | No data Loaded. | ][OK]";
  char *re_err="[1][ Error Reading Disk. | No data Loaded. ][OK]";
  char *no_file="[1][ File not found. ][OK]",
       *no_open="[1][ Can't open file. ][OK]",
       *no_mem="[1][ Insufficient memory | to load calendar. | No data Loaded. ][OK]";
  int fd,     /* file descriptor */
      pushed, /* Ok or Cancel */
      count,
      t_test; /* temporary test variable for file loading */
  static char path[80]="A:\*.CAL";              /* current path */
  char   item[15],  /* filename to open for loading */
         actpath[80], /* actual path specification(without wildcard or device */
         *buf,*p,*ls,*act;
  static int first_time=TRUE; /* For setting Default Drive 7.18.88 */
  if (first_time){
     path[0]=(char)Dgetdrv()+'A';
     first_time=FALSE;
     }
  item[0]='\0';
  fsel_input(path,item,&pushed);
  objc_draw(cal_dial,0,2,0,0,0,0);/* redraw all but inside of calendar */
  if(pushed){
  buf=path;
  while(*buf!='\0'){
     if (*buf++==':'){
        int dr;
        dr=buf[-2];
        dr-='A';       
        if(dr>=0 && dr<=15)
          Dsetdrv(dr);
        p=buf;   /* p points to beginning of path specification */
        break;
        }
  }
  ls=rindex(path,'\\');    /* point to last backslash character */
  act=actpath;
  while(p!=ls+1)
    *act++=*p++;
  *act='\0';               /* null terminate the path */
  Dsetpath(actpath);
  graf_mouse(2,0);/* turn on busy signal */
  if((fd=Fopen(item,0))<0){
    if ((fd&0xffff)==-33)
       form_alert(1,no_file);    /* open File for reading */
       else form_alert(1,no_open);
    }   
  else if(Fread(fd,2L,(char *)&tmonth)!=2L)
         {Fclose(fd);form_alert(1,re_err);}/* error reading month */
  else if(tmonth<1 || tmonth>12)
         {Fclose(fd);form_alert(1,inv);} /* invalid month */
  else if(Fread(fd,2L,(char *)&tyear)!=2L)
         {Fclose(fd);form_alert(1,re_err);}/* error reading year */
  else if(tyear<BASEYEAR || tyear>MAXYEAR)
         {Fclose(fd);form_alert(1,inv);}/* invalid year */
  else{
        do_cal(tmonth,tyear,edp);/* clear all old data */
        if(Fread(fd,924L,&reminders[0][0][0])!=924L)
          {Fclose(fd);form_alert(1,re_err);do_cal(*monthp,*yearp,edp);}
        else {
               for(count=0;count<42;++count)
                  if(Fread(fd,2L,(char *)&t_test)!=2L)
                    {Fclose(fd);form_alert(1,re_err);do_cal(*monthp,*yearp,edp);break;}
                  else if(t_test==1)
                         if((appointments[count]=(appt_type *)calloc(234,1))==NULL)
                           {Fclose(fd);form_alert(1,no_mem);do_cal(*monthp,*yearp,edp);break;}
                         else if(Fread(fd,234L,&((*appointments[count])[0][0]))!=234L)
                                {Fclose(fd);form_alert(1,re_err);do_cal(*monthp,*yearp,edp);break;}
               if(count==42)
                {Fclose(fd);*monthp=tmonth;*yearp=tyear;*edp=TRUE;}/* if perfect load */
        }
         } /* end of else after loading mo and ye */
  graf_mouse(0,0);	/* turn off busy signal */
  }/* end of clicked on OK */
  objc_draw(cal_dial,223,2,0,0,0,0); /* redraw inside of calendar */
}

/*==*/

get_out_file(fi_name)/* get path and file name for output to disk */
char *fi_name;
{
  OBJECT sel_dial[5];
  TEDINFO path_ted;
  char tempath[40],*p;
  int x,y,w,h,drv,pushed;
  sel_dial[0]=obj_fields(-1,-1,-1,G_BOX,NONE,OUTLINED,(char *)0x11180,
  7*gl_wchar,10*gl_hchar,48*gl_wchar,7*gl_hchar);
  sel_dial[1]=obj_fields(-1,-1,-1,G_STRING,NONE,NORMAL,"Enter output path and filename:",
  8*gl_wchar,gl_hchar,31*gl_wchar,gl_hchar);
  objc_add(sel_dial,0,1);
  sel_dial[2]=obj_fields(-1,-1,-1,G_FTEXT,EDITABLE,NORMAL,(char *)&path_ted,
  2*gl_wchar,3*gl_hchar,44*gl_wchar,gl_hchar);
  objc_add(sel_dial,0,2);
  path_ted=text_fields(tempath,"Name:_______________________________________",
  "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",3,0,0,0x180,0,0,40,45);
  sel_dial[3]=obj_fields(-1,-1,-1,G_BUTTON,SELECTABLE|EXIT|DEFAULT,NORMAL,
  "OK",2*gl_wchar,5*gl_hchar,8*gl_wchar,gl_hchar);
  objc_add(sel_dial,0,3);
  sel_dial[4]=obj_fields(0,-1,-1,G_BUTTON,SELECTABLE|EXIT|LASTOB,NORMAL,
  "Cancel",38*gl_wchar,5*gl_hchar,8*gl_wchar,gl_hchar);
  objc_add(sel_dial,0,4);
  /* end of tree declaration */
  /* GET CURRENT Drive */
  p=tempath;
  *p++=(drv=Dgetdrv())+'A';
  *p++=':';
  *p++='\0';
  strcat(tempath,fi_name);
  x=7*gl_wchar-3;y=10*gl_hchar-3;w=48*gl_wchar+6;h=7*gl_hchar+6; 
  form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
  objc_draw(sel_dial,0,1,x,y,w,h);
  pushed=form_do(sel_dial,2);
  form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
  objc_draw(cal_dial,223,2,0,0,0,0);
  if (pushed==3){
     strcpy(fi_name,tempath);
     return(1);
     }
     else return(0);
}

/*==*/

save_pic(month,year)  /* saves screen in DEGAS format */
int month,year;
{
long screen;
int count,
    fd,           /* file identifier */
    palet[16];   /* contains the color pallete*/
long status;     /* error condition status */
char f_name[40];   /* file name and path */
char *disk_err="[1][ DISK DRIVE WRITING ERROR. ][OK]";
  sprintf(f_name,"%.3s%d.PI%d\00",name(month)+1,year,resolution+1);
  if(get_out_file(f_name)==1){  /* clicked on OK in file selector */
  	graf_mouse(256,NULL);   /* HIDE MOUSE */
  	for(count=0;count<16;++count)
  	   palet[count]=Setcolor(count,-1);  /* reads the current pallete*/
  	screen=Physbase();                /* get location of image data */
  	if((fd=Fcreate(f_name,0))>=0)
  	  if((status=Fwrite(fd,2L,(char *)&resolution))==2L)
  	    if((status=Fwrite(fd,32L,(char *)palet))==32L)
  	      if((status=Fwrite(fd,32000L,(char *)screen))==32000L)
  	         Fclose(fd);
  	         else {Fclose(fd);
  	               Fdelete(f_name);
  	               form_alert(1,disk_err);}
  	      else {Fclose(fd);
  	            Fdelete(f_name);
  	            form_alert(1,disk_err);}
  	    else {Fclose(fd);
  	          Fdelete(f_name);
  	          form_alert(1,disk_err);}
  	  else form_alert(1,"[1][ Can't open file! ][OK]");
  	  graf_mouse(257,NULL);  /* show mouse */
  }
}

/*==*/

ins_holidays(month,year,off)
register int month,year,off;
{
int count;
static unsigned char
/* Dates of special movable holidays, where lower five bits are the day
 and upper three bits are the month(except for Hannukkah) */
                   easters[24]={147,131,122,143,127,147,139,131,144,135,
                   126,140,132,151,143,127,148,139,123,144,136,119,140,132},
                   ashwed[6]={81,72,92,77,100,88},
/* all in DEC.*/   hanukah[6]={4,23,12,2,20,9},
                   passover[6]={130,148,138,126,146,134},
                   goodfr[6]={129,120,141,125,145,137};
 for(count=0;count<42;++count)       /* clears all holiday fields */
      hol_ted[count].te_ptext=hol_text[0];
   switch (month){
     case 1:hol_ted[off+0].te_ptext=hol_text[1];/* NEW YEAR'S DAY */
            hol_ted[(off>1) ? 22:15].te_ptext=hol_text[10];/* Martin L.K.*/
            break;
     case 2:hol_ted[off+11].te_ptext=hol_text[2];/* LINCOLN'S BDAY*/
            hol_ted[off+13].te_ptext=hol_text[3];/* St. Valentine's Day*/
            hol_ted[(off>1) ? 22:15].te_ptext=hol_text[4];/* Washington's */
            break;
     case 3:hol_ted[off+16].te_ptext=hol_text[5];/* St. Patrick's Day*/
            break;
     case 5:hol_ted[(off>0) ? 14:7].te_ptext=hol_text[11];/* Mother's Day*/
            hol_ted[(off==6) ? 36:29].te_ptext=hol_text[12];/*Memorial Day */
            break;
     case 6:hol_ted[(off>0) ? 21:14].te_ptext=hol_text[13];/* Father's Day */
            break;
     case 7:hol_ted[off+3].te_ptext=hol_text[6];/* 4th of July*/
            break;
     case 9:hol_ted[(off>1) ? 8:1].te_ptext=hol_text[14];/* Labor Day */
            break;
     case 10:hol_ted[off+30].te_ptext=hol_text[7];/* Halloween */
             hol_ted[(off>1) ? 15:8].te_ptext=hol_text[15];/*Columbus Day */
             break;
     case 11:hol_ted[off+10].te_ptext=hol_text[8];/* Veteren's Day */
             hol_ted[(off>1) ? 9:2].te_ptext=hol_text[16];/* Election Day */
             hol_ted[(off>4) ? 32:25].te_ptext=hol_text[17];/*Thanksgiving*/
             break;
     case 12:hol_ted[off+24].te_ptext=hol_text[9];/*CHRISTMAS*/
             break;
     } /* switch */
   lunar_holiday(1987,2010,easters,18,month,year,off);
   lunar_holiday(1988,1993,ashwed,19,month,year,off);
   lunar_holiday(1988,1993,passover,22,month,year,off);
   lunar_holiday(1988,1993,goodfr,20,month,year,off);
   if(year>= 1988 && year<=1993 && month==12)
     hol_ted[off+hanukah[year-1988]-1].te_ptext=hol_text[21]; 
}

/*==*/

lunar_holiday(startyr,endyr,holiday,textp,month,year,off)
        /*** places special movable holidays ***/
int startyr,endyr;
unsigned char holiday[];
int textp,month,year,off;
{
 if(year>=startyr && year<=endyr)
   if(month==(holiday[year-startyr]>>5 & 7))
     hol_ted[off+(holiday[year-startyr] & 0x1F)-1].te_ptext=hol_text[textp];
}        

/*==*/

do_cal(month,year,edp)    /* MAIN ROUTINE: ACTUALLY CONSTRUCTS CALENDAR */
int month,year,*edp;
{
   int len;
   register int count;
   off=offset(month,year);    /* Position of Jan 1st in the week  */
   len=length(month,year);    /* length of current month   */
   *edp=FALSE;                /* THE CALENDAR IS NOT EDITED YET */
   sprintf(act_title,"%s%d",name(month),year);
   date.te_ptext=act_title;   /* set up month and year title  */
   date.te_txtlen=strlen(date.te_ptext);
   /* Fill appropriate holiday fields  */
   ins_holidays(month,year,off);
   for(count=0;count<42;++count){
      cal_dial[count+55].ob_state&=~SELECTED;   /* DESELECT ALL DATES */
      if (count<off||count>=len+off){
          /* MAKE BLANK DAYS UNSELECTABLE UNEXITABLE */
          cal_dial[count+55].ob_flags&=~(SELECTABLE|EXIT);
          cal_dial[count+55].ob_spec=days_text[0];
          }
      else {      /*MAKES DAY SELECTABLE*/
            cal_dial[count+55].ob_flags|=(SELECTABLE|EXIT);
            cal_dial[count+55].ob_spec=days_text[count-off+1];  
           }
    } /* END OF FOR */
    /* NESTED BLOCK OF LOOPS TO CLEAR INFO FIELDS GO HERE */
    {register int looper;
      for(count=0;count<42;++count)
         for(looper=0;looper<2;++looper)
            edit_text[count][looper][0]='\0';  /* THE NULL STRING */
    }
   /* free AND RESET all allocated memory */
   for(count=0;count<42;++count)
      if(appt_info[count]!=NULL){
        free(appt_info[count]);
        appt_info[count]=NULL;
        }
   
}

/*==*/

build_tree()   /* sets up the characteristics of the dialog box   */
{
/* cal_dial[0]=THE MAIN DIALOG BOX
   cal_dial[1]=THE TOP OF CALENDAR BAR
   cal_dial[2->11]=BUTTONS ON RIGHT SIDE
   cal_dial[12->53]=DAY BOXES
   cal_dial[54]=MONTH AND YEAR TITLE
   cal_dial[55->96]=THE ACTUAL DATES WITHIN DAY BOXES
   cal_dial[97->138]=THE HOLIDAY TEXT BOXES
   cal_dial[139->180]=LINE 1 OF INFORMATION
   cal_dial[181->222]=LINE 2 OF INFORMATION
   cal_dial[223]=AN INVISIBLE BOX AROUND THE DAYS TO ALLOW THEM TO BE 
                 RBUTTONS */

int dummy,ob_count;
  cal_dial[0]=obj_fields(-1,-1,-1,G_BOX,NONE,OUTLINED,(resolution==2) ? 
            (char *) 0x11051: (char *) 0x11072,0,0,78*gl_wchar,23*gl_hchar);
  for(ob_count=2;ob_count<=11;++ob_count){
     cal_dial[ob_count]=obj_fields(-1,-1,-1,G_BUTTON,SELECTABLE|EXIT,NORMAL,
     but_text[ob_count-2],60*gl_wchar,ob_count*gl_hchar*2-gl_hchar,16*gl_wchar,
     gl_hchar);
     objc_add(cal_dial,0,ob_count);
  }
  cal_dial[223]=obj_fields(0,-1,-1,G_IBOX,LASTOB,NORMAL,(char *)0,0,0,
                59*gl_wchar,23*gl_hchar);
  objc_add(cal_dial,0,223);
  cal_dial[54]=obj_fields(-1,-1,-1,G_BOXTEXT,NONE,NORMAL,(char *)&date,
                         22*gl_wchar,gl_hchar-3,17*gl_wchar,gl_hbox);
  objc_add(cal_dial,223,54);
  date=text_fields(date_text[0],(char *)NULL,(char *)NULL,3,0,2,0x1180,0,-1,
                   17,0);
  for(ob_count=12;ob_count<=53;++ob_count){
      cal_dial[ob_count]=obj_fields(-1,-1,-1,G_BOX,NONE,NORMAL,
      (char *)0x11000,2*gl_wchar+((ob_count-12)%7)*8*gl_wchar,
      4*gl_hchar+((ob_count+2)/7-2)*3*gl_hchar,8*gl_wchar,3*gl_hchar);
      objc_add(cal_dial,223,ob_count);
  }                 
  cal_dial[1]=obj_fields(223,-1,-1,G_BOXTEXT,NONE,SHADOWED,(char *)&d_title,
                         2*gl_wchar,3*gl_hchar-3,56*gl_wchar,gl_hchar);
  objc_add(cal_dial,223,1);
  d_title=text_fields(days_title,(char *)NULL,(char *)NULL,3,0,2,0x1180,0,
                      -1,55,0);
  for(ob_count=55;ob_count<=96;++ob_count){
   cal_dial[ob_count]=obj_fields(-1,-1,-1,G_STRING,SELECTABLE|EXIT,NORMAL,
   days_text[0],1,1,2*gl_wchar,gl_hchar);
   objc_add(cal_dial,ob_count-43,ob_count);
   cal_dial[ob_count+42]=obj_fields(-1,-1,-1,G_TEXT,NONE,NORMAL,
           (char *)&hol_ted[ob_count-55],19,2*resolution,42,6);
   objc_add(cal_dial,ob_count-43,ob_count+42);
   hol_ted[ob_count-55]=text_fields(hol_text[0],(char *)NULL,(char *)NULL,
   5,0,0,0x280,0,0,7,0);
   cal_dial[ob_count+84]=obj_fields(-1,-1,-1,G_TEXT,NONE,NORMAL,
            (char *)&day_info[ob_count-55][0],3,(resolution==2)?24:10,8*gl_wchar-2,6);
   objc_add(cal_dial,ob_count-43,ob_count+84);
   cal_dial[ob_count+126]=obj_fields(ob_count-43,-1,-1,G_TEXT,NONE,
    NORMAL,(char *)&day_info[ob_count-55][1],3,(resolution==2)?35:17,8*gl_wchar-2,6);
   objc_add(cal_dial,ob_count-43,ob_count+126);
   for(dummy=0;dummy<2;++dummy)
  day_info[ob_count-55][dummy]=text_fields(&edit_text[ob_count-55][dummy][0]
           ,(char *)NULL,(char *)NULL,5,0,0,0x180,0,0,11,0);
   
   }
}

