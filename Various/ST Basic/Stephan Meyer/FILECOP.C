/*     Filecopy Version 3.11
       15.03.85
       A.Hoepfner & D.Herklotz                     */

extern long gemdos();

/* zuerst ein paar betriebsystemaufrufe definieren */

#define setdta(a)       gemdos(0x1a,a)
#define getfree(a,b)    gemdos(0x36,a,b)
#define alloc(a)        gemdos(0x48,a)
#define freemem(a)      gemdos(0x49,a)
#define first(a,b)      (int) gemdos(0x4e,a,b)
#define next()          (int) gemdos(0x4f)
#define getchr()        gemdos(0x08)
#define putchar(a)      gemdos(0x02,a)
#define constat()       gemdos(0x0b)
#define open(a)         gemdos(0x3d,a,0)
#define reopen(a)       gemdos(0x3d,a,2)
#define seek(a,b)       gemdos(0x42,a,b,0)
#define create(a)       gemdos(0x3c,a,0)
#define read(a,b,c)     gemdos(0x3f,a,b,c)
#define write(a,b,c)    gemdos(0x40,a,b,c)
#define prt_line(a)     gemdos(0x09,a)
#define close(a)        gemdos(0x3e,a)
#define reset_disk()    gemdos(0x0d)
#define Super(a)        gemdos(0x20,a)
#define dsetdrv(a)      gemdos(0x0e,a)

/* Ein bischen Bildschirmsteuerung brauchen wir auch */

#define goto_xy(x,y)    printf("\033Y%c%c",(x+32),(y+32))
#define cur_on    printf("\033e")    /* Esc e */
#define cur_off   printf("\033f")    /* Esc f */
#define inv_on    printf("\033p")    /* Esc p */
#define inv_off   printf("\033q")    /* Esc q */
#define cur_up    printf("\033A")    /* Esc A */
#define cur_down  printf("\033B")    /* Esc B */
#define cur_right printf("\033C")    /* Esc C */
#define cur_left  printf("\033D")    /* Esc D */
#define mark      { int i; cur_left; inv_on; putchar('>');\
                           for(i = 0; i < 12; i++) cur_right; putchar('<');\
                           for(i = 0; i < 13; i++) cur_left;\
                           inv_off; }

#define unmark    { int i; cur_left; putchar(' ');\
                           for(i = 0; i < 12; i++) cur_right; putchar(' ');\
                           for(i = 0; i < 13; i++) cur_left; }
                        

/* Die Tastatur duerfen wir natuerlich auch nicht vergessen */

#define UNDO 0x61
#define CURUP 0x48
#define CURDOWN 0x50
#define CURRIGHT 0x4d
#define CURLEFT 0x4b

/* ein paar konstanten sind auch von noeten */

#define MAXFILES   90  /* maximal kopierbare anzahl von files */
#define MAXDIRECT 150  /* maximale anzahl von files die in ein dir passen */
#define LENGTH     14  /* angenommene filenamenlaenge */

/* die DTA = Disk Transfer Adress muss natuerlich auch noch definiert werden */

typedef struct {
                 char internal[21]; /* nur fuer os benutzung */
                 char att;          /* file attributes */
             unsigned time;         /* zeite der erstellung */
             unsigned date;         /* datum der erstellung */
             unsigned sizel;        /* low word of filesize */
             unsigned sizeh;        /* high word of filesize (8088 komp. */
                 char name[14];     /* das was wir brauchen der filename */
               } DTA; /* DTA ist ein typ wie int, long .... */

static char *message[] =
 {
  "\033w\033E\r",
  "\t*******************************************************************\n\r",
  "\t******               FILECOPY VERSION 3.11                   ******\n\r",
  "\t******  copyright 1986   Detlef Herklotz & Andreas Hoepfner  ******\n\r",
  "\t*******************************************************************"
  };

extern int strcmp();            /* fuer die fkt 'qsort' noetig */
                                /* ohne sortieren nicht erforderlich */
long getchar();
int  drives,*drvaddress,A,B;    /* Wieviele Drives */
int dummy;
long old_supervisor;            /* alter Supervisorstackpointer */

main()
{
char files[MAXFILES][14], c;
int i, j, no_files;
A = 0; B = 1;                   /* Bezeichnung der Drives */
 
 do
 {
  drvaddress = 0x4a6;
  cur_off;
  drives = 1;
  for (i = 0; i < 5; i++)                /* Kopf ausgeben */
      prt_line(message[i]);

  old_supervisor = Super(0l);
  drives = *drvaddress;                  /*  wieviel Drives angeschlossen ? */
  old_supervisor = Super(old_supervisor);

  if((drives & 0x0f) >= 2)
      {
      drives = 2;
      printf("\n\r\n\r\t Bitte Quell- in A und  Zieldiskette in B einlegen....");
      }
   else
      printf("\n\r\n\r\t Bitte Quelldiskette einlegen.....");
  dummy = drive(A);
  c = getchar();    
  goto_xy(4,0); printf("\033J"); goto_xy(5,0);
  no_files = getinput(files);
  if(no_files)
   copy_files(files,no_files);
  printf("\n\r\n\r\tNoch andere Files kopieren ? (J/N)              ");
 }
 while((c = getchar()) != 'N' && c != 'n');
 cur_on;
 exit(0);
}

drive(dev)             /* spricht die vorhandenen Drives an */
int dev;
{
 int error;
 error = dsetdrv(dev);
 return(error);
}

getinput(array) /* laesst das directory einlesen und macht die BS-steuerung */
char *array;    /* kommt mit der anzahl der angewaehlten files zurueck */
{
char dir[MAXDIRECT][14];
int i, j, index, files[MAXFILES], current;

 for(i = 0; i < MAXFILES; i++)
  for(j = 0; j < 14; dir[i][j++] = 0);
 i = j = 0;
 getdir(dir);
 printf(" Bitte mit mit Cursortasten und \033pSPACE\033q");
 printf(" die files auswaehlen Ende mit \033pUNDO\033q\n\r");
 while(dir[i][0]) /* solange noch files vorhanden auf bildschirm ausdrucken */
  if(!(j++ % 5)) printf("\n\r %-15s",dir[i++]); /* jedes 5. mit neuer zeile */
   else printf(" %-15s",dir[i++]);
 for(i = 0; i < MAXFILES; files[i++] = 0);
 edit_files(dir,files);
 i = 0;
 index = 0;
 while((current = *(files + i) - 1) >= 0)
 {
  for(j = 0; j < 14; j++)
   *(array + index++) = dir[current][j];
  i++;
 }
 return(i);
}

getdir(array)
char *array;
{
int i = 0, index = 0;
DTA new_dta;

 setdta(&new_dta);
 if(!first("*.*",0x07))
 do
  for(i = 0; i < 14; *(array + index++) = new_dta.name[i++]);
 while(!next());
 qsort(array,index/14,14,strcmp); /* filenamen sortieren (kann entfallen) */
}

edit_files(dir,ret)
char dir[][14];
int *ret;
{
long chr;
int i, j, current, max, entrys;
char c;

 goto_xy(7,1);                              /* an den anfang marke setzen    */
 mark;
 cur_off;                                   /* cursor stoert fuerchterlich   */
 i = j = current = max = entrys = 0;        /* erst mal alles initialisieren */
 while(dir[i++][0]) max++;                  /* dann die eintraege zaehlen    */
 while((c = (chr = getchar()) >> 16) != UNDO && entrys < MAXFILES)
 {
  switch(c)
  {
   case CURUP   : if(current - 5 >= 0)
                  {
                   unmark;
                   current -= 5;
                   cur_up;
                   mark;
                  }
                  break;
   case CURDOWN : if(current + 5 < max)
                  {
                   unmark;
                   current += 5;
                   cur_down;
                   mark;
                  }; break;
   case CURRIGHT: if(current + 1 < max)
                  {
                   unmark;
                   if(!((current + 1) % 5))
                    printf("\n\r");
                   else
                    for(i = 0; i < 16; i++) cur_right;
                   current++;
                   mark;
                  }
                  break;
   case CURLEFT : if(current - 1 >= 0)
                   if(current-- % 5)
                   {
                    unmark;
                    for(i = 0; i < 16; i++)
                     cur_left;
                   }
                   else
                   {
                    unmark;
                    cur_up;
                    for(i = 0; i < 64; i++)
                     cur_right;
                   }
                  mark;

  }
  if(chr & 0xff)        /* falls irgendeine andere taste dann select/deselct */
  {
   j = 0;
   for(i = 0; i < entrys; i++)
    j |= (current == *(ret + i) - 1);
   if(!(j))    /* file schon selected gewesen ? */
   {     /* nein dann select file (inversdarstellung und in liste aufnehmen) */
    inv_on; printf("%-12s\b\b\b\b\b\b\b\b\b\b\b\b",dir[current]);
    inv_off;
    *(ret + entrys++) = current + 1;
   }
   else
   {     /* file wieder deselect (normaladrstellen und aus liste entfernen */
    printf("%-12s\b\b\b\b\b\b\b\b\b\b\b\b",dir[current]);
    i = 0;
    while(*(ret + i) != current + 1) i++;
    while(i++ < entrys)
     *(ret + i - 1) = *(ret + i);
    entrys--;
   }
  }
 }
 cur_on;
 *(ret + entrys) = 0;
 goto_xy(5,1);
 printf("\033J");
}


copy_files(files,no_files)
char files[][14];
int no_files;
{
char *buffer, *pointer,c;
int fd, copagain, index, first_index, i, line_counter;
long length[MAXFILES], free_bytes, used_bytes, last_length, first_length,
     wr_length;

 printf("\r");
 cur_off;
 line_counter = 0;
 if(free_bytes = alloc(-1L)) /* freier speicher da */
 {
  free_bytes -= free_bytes & 0x01;
  printf("\t %u Files zu kopieren mit %ld Bytes als Buffer !\n\r\n\r"
           ,no_files,free_bytes);
  copagain = -1;
  index = used_bytes = last_length = 0L;
  buffer = pointer = alloc(free_bytes);   /* ja dann alles zu mir */
  do
  {
   first_index = index;
   pointer = buffer;
   used_bytes = 0L;
   while(index < no_files && used_bytes != free_bytes)
   {
    if((fd = open(files[index])) >= 0)   /* file korrect geoeffnet ? */
    {
     if(copagain >= 0)
     {
      seek(last_length,fd);
      copagain = -1;
     }
     goto_xy(7 +line_counter++,0);
     printf("\r\tLese File : %-14s  ",files[index]);
     length[index] = read(fd,free_bytes - used_bytes,pointer);
     printf("Laenge : %6ld ",length[index]);
     used_bytes += length[index];
     pointer    += length[index++];
     used_bytes += pointer & 0x01;
     pointer    += pointer & 0x01;
     close(fd);
    }
    if(line_counter == 14)
    {
     line_counter = 0;
     goto_xy(7,0);
     printf("\033J");
    }
   }
   copagain = --index;
   first_length = last_length;
   last_length  = length[index];
   pointer = buffer;
   if (drives == 1)
       {
        printf("\r\n\tBitte Zieldiskette einlegen (Abbruch mit 'Esc')");
        if(0x1b == (char) getchar())
        {
         freemem(buffer);
         return;
        }
       }
   else dummy = drive(B);        /*   ansonsten auf drive B !! */

   line_counter = 0;
   goto_xy(7,0); printf("\033J");
   for(i = first_index; i <= index; i++)
   {
    if(first_length)
    {
     if((fd = reopen(files[i])) >= 0)
      seek(first_length,fd);
     first_length = 0;
    }
    else
     fd = create(files[i]);
    if(fd >= 0)
    {
     goto_xy(7 + line_counter++,0);
     printf("\r\tSchreibe File : %-14s  ",files[i]);
     wr_length = write(fd,length[i],pointer);
     if(wr_length != length[i])
      printf("\r\tFehler beim schreiben         ");
     else
      printf("Laenge : %6ld",wr_length);
     pointer += length[i];
     pointer += pointer & 0x01;
     close(fd);
    }
    if(line_counter == 14)
    {
     line_counter = 0;
     goto_xy(7,0);
     printf("\033J");
    }
   }
   if(used_bytes == free_bytes)
   {
    if (drives == 1)
      {
       printf("\r\n\tBitte Originaldiskette einlegen (Abbruch mit 'Esc')");
       if(0x1b == (char) getchar()) /* mit 'esc' flucht aus kopieren ! */
       {
        freemem(buffer);
        return;
       }
      }
    else dummy = drive(A);    /* wieder zurueck zu drive A !!*/
    goto_xy(7,0);
    printf("\033J");
    line_counter = 0;
   }
  }
  while(used_bytes == free_bytes);
  if(freemem(buffer) != 0)
  {
   printf("Kann buffer nicht wieder freigeben TSCHUESS !");
   exit(1);
  }
 }
 else printf("\n\r\t Kein freier Speicher fuer Buffer !!!!");
 cur_on;
}

long getchar() /* holt genau ein zeichen von der tastatur */
{              /* liest vorher den Tatstaturbuffer aus    */
 while(constat())
  getchr();
 return(getchr());
}
