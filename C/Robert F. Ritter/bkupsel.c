/* public domain; all rights reserved by: Robert F. Ritter (c) 1986 */
#include "osbind.h"



#define ARC "\\bin\\arc"  /* where is your arc situated? */


struct dta {
                char  reserved[21];
                char  fab;
                unsigned time;
                unsigned date;
                long  size;
                char  name[];
           };

struct dta *dta_ptr;

unsigned sys_time, sys_date;

int     contrl[ 12 ],
        intin[ 256 ], ptsin[ 256 ],
        intout[ 256 ], ptsout[ 256 ],
        workin[]={ 1,1,1,1,1,1,1,1,1,1,2 }, workout[ 57 ],
        handle,
        i, j,
        x, y, w, h,
        xdial, ydial, wdial, hdial,
        k = 0,
        file_handle, myfile, oldfile,
        button,
        ret;

long    space,
        box_adr;

char    path[50],
        volume[50],
        name[50],
        drive[3],
        crlf[2],
        today[10],
        totime[10],
        realdta[44],
        out_filename[12],
        disk_no[4];

long strlen(string)
  char *string;
  {
        char *string_pointer = string;

        while ( *string_pointer )
           ++string_pointer;

        return ((long) string_pointer - string );

  }

char * strcat(s, t)
  char s[], t[];
{
        int i, j;
        i = j = 0;
        while(s[i] != '\0')          /* find end of s */
           i++;
        while((s[i++] = t[j++]) != '\0');   /* copy t */
}

char strcpy(s, t)
  char *s, *t;
{
        while(*s++ = *t++);
}

strequ ( str1, str2 )
  char str1[], str2[];
    {
        int i = 0, answer;
        while( str1[i] == str2[i] && str1[i] != '\0'
                                  && str2[i] != '\0' )
          ++i;
        if( str1[i] == '\0' && str2[i] == '\0' )
          answer = 1;
        else
          answer = 0;
        return( answer );
    }

itoa (n, s)
  char s[];
  int n;
    {
        int i;
        i = 2;
        strcpy(s, "000");
        do {
            s[i--] = (n % 10) + '0';
            } while ((n /= 10) > 0);
    }

ltoa (n, s)
  char s[10];
  long n;
    {
        long n2;
        int i;
        n2 = n;
        i = 9;
        do {
            s[i--] = n2 - ((n2 / 10) * 10) + '0';
            } while ((n2 /= 10) > 0);
    }

itodate (idate, date)
  unsigned idate;
  char date[10];
  {
        unsigned yy, mm, dd;

        yy = (idate >> 9 & 0x7F) + 80;
        mm = idate >> 5 & 0xF;
        dd = idate & 0x1F;

        date[0] = (dd/10) + '\060';
        date[1] = (dd%10) + '\060';
        date[2] = '/';
        date[3] = (mm/10) + '\060';
        date[4] = (mm%10) + '\060';
        date[5] = '/';
        date[6] = (yy/10) + '\060';
        date[7] = (yy%10) + '\060';
  }

itotime (itime, time)
   unsigned itime;
   char time[10];
  {
        unsigned hrs, mins, secs;

        hrs = itime >> 11 & 0x1F;
        mins = itime >> 5 & 0x3F;
        secs = (itime & 0x1F) << 1;

        time[0] = (hrs/10) + '\060';
        time[1] = (hrs%10) + '\060';
        time[2] = ':';
        time[3] = (mins/10) + '\060';
        time[4] = (mins%10) + '\060';
        time[5] = ':';
        time[6] = (secs/10) + '\060';
        time[7] = (secs%10) + '\060';
  }

int stoi(string)
char string[];
{
        int i, int_val, result=0;
        for (i=0; string[i] >= '0' && string[i] <= '9'; ++i){
                int_val = string[i] - '0';
                result = result * 10 + int_val;
        }
        return(result);
}


/*************************************************/
main(argc, argv)
char **argv;
int    argc;
   {
        int x;
        int i, j, k;
        char  cc[20], xx[20];
        unsigned hrs=0, mins=0, secs=0, yy=80, mm=0, dd=0;
        int counter;

    crlf[0] = 0x0d;
    crlf[1] = 0x0a;

    oldfile = Fopen( "bkuptime", 0);
    myfile = Fcreate("newtime", 0);

    if (argc < 2) {
        Fwrite(0, 41L, "usage: BKUPSEL path <dd/mm/yy> <hh:mm:ss>");
        Fwrite(0, 2L, crlf);
        exit(-1);
        }
    else {
	strcpy(cc, "00/00/80");
        if (argc >= 3)
           strcpy(cc, argv[2]); /* the date to select by */
        else Fread(oldfile, 10L, cc);

        Fwrite(0, 38L, "Preparing backup list of files since: ");
        Fwrite(0, 8L, cc);
        Fwrite(0, 2L, "  ");

        i = strlen(cc);

        counter = 0;
        k = 0;
        for (j=0; j<=i;++j){
                if (cc[j] >= '0' && cc[j] <= '9'){
                        xx[k] = cc[j];
                        ++k;
                        }
                else {
                        xx[k] = '\0';
                        x = stoi(xx);
                        k = 0;
                        ++counter;
                        switch(counter){
                           case 1:
                                if (x <= 31 && x > 0) dd = x;
                                break;
                           case 2:
                                if (x <= 12 && x > 0) mm = x;
                                break;
                           case 3:
                                if (x >= 80) yy = x;
                                break;
                           } /* switch */
                        } /* else */
                } /* for */

	strcpy(cc, "00:00:00");
        if (argc >= 4)
           strcpy(cc, argv[3]); /* the time to select by */
        else Fread(oldfile, 8L, cc);

        Fwrite(0, 8L, cc);

        i = strlen(cc);

        counter = 0;
        k = 0;
        for (j=0; j<=i; j++){
                if (cc[j] >= '0' && cc[j] <= '9'){
                        xx[k] = cc[j];
                        ++k;
                        }
                else {
                        xx[k] = '\0';
                        x = stoi(xx);
                        k = 0;
                        ++counter;
                        switch(counter){
                           case 1:
                                if (i!= 0 && x <= 23 && x >= 0) hrs=x;
                                break;
                           case 2:
                                if (x <= 59 && x >= 0) mins = x;
                                break;
                           case 3:
                                if (x <= 59 && x >= 0) secs = x;
                                break;
                           }
                        }
                }
        sys_time = (hrs << 11) + (mins << 5) + (secs >> 1);
        sys_date = ((yy - 80) << 9) + (mm << 5) + dd;

        strcpy(out_filename, "thisbkup.sh");
        file_handle = Fcreate(out_filename, 0);

        dta_ptr = (struct dta *) realdta;
        Fsetdta(dta_ptr);

        Fwrite(0, 2L, crlf);

        strcpy( drive, argv[1]);
        read_the_directory();

        sys_time = Tgettime();
        sys_date = Tgetdate();
        itotime(sys_time, totime);
        itodate(sys_date, today);
        Fwrite(myfile, 8L, today);
        Fwrite(myfile, 2L, crlf);
        Fwrite(myfile, 8L, totime);
        Fwrite(myfile, 2L, crlf);
        }
   }
/*************************************************/


/*************************************************/
read_the_directory()
   {
     char thispath[50], cur_dir[50], charspace[10], totals[50];
        strcpy(path, drive);
        strcpy( thispath, path );
        strcat( thispath, "\\*.*" );
        ret = Fsfirst(thispath,0x10); /* get the first item on the volume   */
        while (ret == 0)
          {
            if (dta_ptr->fab == 0x10)               /* found a directory     */
               {if (   (!strequ( dta_ptr->name, "." ))
                    && (!strequ( dta_ptr->name, ".." )) )
                 {
                   strcpy(cur_dir,dta_ptr->name);
                   dir_write(path,cur_dir);        /* follow the directory */
                   ret = Fsfirst(thispath,0x10);
                     /*return to start of previous path */
                   while ((ret == 0) && (!strequ(dta_ptr->name, cur_dir)))
                      ret = Fsnext();
                 }
               }
              else dta_write(drive);                /* write the filename    */

            ret = Fsnext();           /* now walk the rest of the structure  */
           }
   }
/*************************************************/



/*************************************************/
dta_write(path)
 char *path;
  {
    char command[100];
    
    if ((dta_ptr->date > sys_date) || 
	(dta_ptr->date == sys_date && dta_ptr->time >= sys_time)) {
        strcpy(name, path);
        strcat(name, "\\");
        strcat(name, dta_ptr->name);

	strcpy(command, ARC);

	strcat(command, " u $1 ");
        Fwrite(file_handle, (long) strlen(command), command);
        Fwrite(file_handle, strlen(name), name);
        Fwrite(file_handle, 2L, crlf);
        }
   }
/*************************************************/


/*************************************************/
dir_write(cur_path,directory)
  char *cur_path, *directory;
    {
    auto char new_path[50], thispath[50], cur_dir[50];
        strcpy( new_path, cur_path );
        strcat( new_path, "\\" );
        strcat( new_path, directory );
        strcpy( thispath, new_path);
        strcat( thispath, "\\*.*");
        ret = Fsfirst(thispath,0x10);  /* get this new path started */
        while (ret == 0)
          {
            if (dta_ptr->fab == 0x10)              /* found a directory     */
               {if (   (!strequ( dta_ptr->name, "." ))
                    && (!strequ( dta_ptr->name, ".." )) )
                 {
                   strcpy(cur_dir,dta_ptr->name);
                   dir_write(new_path,cur_dir);     /* follow the directory */
                   ret = Fsfirst(thispath,0x10);
                     /*return to start of previous path */
                   while ((ret == 0) && (!strequ(dta_ptr->name, cur_dir)))
                      ret = Fsnext();
                 }
               }
            else dta_write(new_path);              /* write the filename    */

            ret = Fsnext();           /* now walk the rest of the structure  */
           }
    }
/*************************************************/
