
/************************************************************************/
/*   SNAPSHOT.C          Philip I. Nelson              8/20/86          */
/************************************************************************/

/************************************************************************/
/* Snapshot desk accessory for NEOchrome and DEGAS.                     */
/* Adjusts automatically for file type and screen resolution.           */
/* Written in assembly language and Alcyon C. This file must be linked  */
/* with a separate assembly language module. See SNAP.S                 */
/************************************************************************/

/************************************************************************/
/* This batch file compiles and links SNAPSHOT.C and SNAP.S.            */
/************************************************************************/
/*  cp68 %1.c %1.i                                                      */
/*  c068 %1.i %1.1 %1.2 %1.3 -f                                         */
/*  rm %1.i                                                             */
/*  c168 %1.1 %1.2 %1.s                                                 */
/*  rm %1.1                                                             */
/*  rm %1.2                                                             */
/*  as68 -l -u %1.s                                                     */
/*  as68 -l -u snap.s                                                   */
/*  link68 [u] %1.68k=accstart,snap,%1.o,osbind,aesbind                 */
/*  relmod %1.68k %1.acc                                                */
/*  rm %1.68K                                                           */
/*  wait                                                                */
/************************************************************************/

/************************************************************************/
/* Define and include some necessary evils.                             */
/************************************************************************/

#define AC_OPEN  40
#define MU_MESAG 0x0010
#include <osbind.h>

/************************************************************************/
/* Integers and longs.                                                  */
/************************************************************************/

extern int gl_apid, picflag, rez, palbuff[], scrbuff[];
int contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
int msgbuff[8], zerobuff[2];
int drive, drv, dummy, savebutt, choice, menu_id, filehandle, fs_button;
long total,freebuff[4];

/************************************************************************/
/* String things appear here.                                           */
/************************************************************************/

char path[80], fs_inpath[80], fs_insel[80], filename[80];
char neowild[] = "*.NEO";
char degwild[] = "*.PIX";
char pickalert[] = "[1][ COMPUTE!'s Snapshot\275 | Screen image has been saved. | Choose file type:          | ][Cancel|NEO|DEGAS]";
char rezalert[] = "[1][NEOchrome can't load files |in this resolution | ][Cancel|Go ahead]";
char existalert[] = "[1][File exists.|Want to replace it?][Cancel|OK]";
char erroralert[] = "[1][A fatal error has occurred!|Gotta go...][OK]";
char nullalert[] = "[1][Sorry, screen buffer's empty,|so there's nothing to save.|Press Alt-Help to store a|screen, then try again.      ][Cancel]";
char enufalert[] = "[1][Sorry, not enough room|on disk for this file.][Cancel]";
char cyclebuff[] = {
32,32,32,32,32,32,32,32,46,32,32,32,128,30,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0 } ;

/************************************************************************/
/* If you're wondering where the program starts, look no further.       */
/************************************************************************/

main()
{
  int event, i, j;

  /* Call the machine language routine, which installs itself.          */

  snap();

  /* Tell GEM that we exist                                             */

  appl_init();

  /* Install program as a desk accessory.                               */
  /* The menu_id will be our own little number.                         */

  menu_id = menu_register(gl_apid," Snapshot NEO/DEGAS ");

  /* If there's no room at the inn, return home without leaving a tip.  */

  if(menu_id < 0) return(0);

  /* Accessories run forever, so this WHILE never ends.                 */

  while(1) {

    /* Watch for our accessory, but let all other applications run.     */

    event = evnt_multi(MU_MESAG,1,1,1,0,0,0,0,0,0,0,0,0,0,
     msgbuff,0,0,&dummy,&dummy,&dummy,&dummy,
     &dummy,&dummy);

    /* Has an event occurred?                                           */

    if(event & MU_MESAG)
      switch (msgbuff[0]) {

      /* Was that event the opening of our accessory?                   */

      case AC_OPEN:
      if(msgbuff[4] == menu_id) {

        /* Yup. Check _picflag to see if the machine language module    */
        /* has saved a screen lately.                                   */

        if(picflag == 0) {
          Cconout(7);
          form_alert(1,nullalert);
          break;
          }

        /* A screen is in the buffer.                                   */

        /* DEGAS palette peculiarity */
        if(rez == 2 && palbuff[0] == 1) palbuff[0] = 0x777;

        /* Choose NEOchrome or DEGAS file format.                       */

        savebutt = form_alert(1, pickalert);

        /* You cancelled from selection dialog.                         */

        if(savebutt == 1) {
          picflag = 0;
          break;
          }

        /* Warn if you choose NEO in medium or high resolution.         */
        /* NEOchrome can only load low resolution screens.              */

        if(savebutt == 2 && rez != 0) {
          choice = form_alert(1,rezalert);
          /* You can cancel from this alert, but it's not mandatory.    */
          if(choice == 1) {
            picflag = 0;
            break;
            }
        }

        /* Clear buffers of possible leftovers from last time...        */

        for(i = 0; i < 40; i++ ) {
          path[i] = 0;
          filename[i] = 0;
          fs_insel[i] = 0;
          fs_inpath[i] = 0;
          }

        /* Discover the current drive and path.                         */
        /* GEMDOS routine Dgetdrv returns 0 for drive A, 1 for B, etc.  */
        /* GEMDOS routine Dgetpath puts current path in the designated  */
        /* buffer (path[] in this program). You must also supply a      */
        /* drive. For no apparent reason, the drive number for Dgetpath */
        /* is different than the drive number for Dgetdrv.              */

        drive = Dgetdrv();
        Dgetpath(path, drive + 1);

        /* Since we know the current drive and path, construct a        */
        /* default path for fsel_input to use. This consists of the     */
        /* drive specifier (A, B, etc.) and the path, if any, plus      */
        /* any wildcard spec that we want to tack onto the end of       */
        /* the default path. In this case we tack on *.NEO if you       */
        /* select NEOchrome, and *.PI plus a 1, 2, or 3 if you          */
        /* select DEGAS, depending on screen resolution.                */

        fs_inpath[0] = drive + 'A';
        fs_inpath[1] = ':';
        j=2;
        i=0;
        while(j<80 && path[i] != 0) {
          fs_inpath[j++] = path[i++];
          }
        fs_inpath[j++] = '\\';

        /* NEOchrome wildcard spec.                                     */

        if(savebutt == 2)
          for(i=0; i<5; i++) {
            fs_inpath[j++] = neowild[i];
          }

        /* DEGAS wildcard spec.                                         */

        if(savebutt == 3) {
          for(i=0;i<5;i++) {
            fs_inpath[j++] = degwild[i];
            }
          /* DEGAS filename ends with screen resolution specifier.      */
          fs_inpath[j-1] = (char *) rez + '1';
          }

        /* You select path and filename. AES routine Fsel_input expects */
        /* buffers containing default path and name. Fs_button tells    */
        /* whether you choose Cancel or OK.                             */

        fsel_input(fs_inpath,fs_insel,&fs_button);

        /* Still another chance to cancel from within Fsel_input.       */

        if(fs_button == 0) {
          picflag = 0;
          break;
          }

        /* Treat null filename as a cancel, too.                        */

        if(fs_insel[0] == 0) {
          picflag = 0;
          break;
          }

        /* Construct the full drive specifier, path and filename.       */

        j = 79;
        while(--j>0 && fs_inpath[j] != '\\') {
          }
        j++;
        i=0;
        while(i<79 && i<j) {
          filename[i] = fs_inpath[i++];
          }
        j = 0;
        while(j<63 && fs_insel[j] != 0) {
          filename[i++] = fs_insel[j++];
          }

        /* See whether the file already exists.                         */
        /* GEMDOS routine Fsfirst seeks the specified file.             */
        /* If file exists, you choose whether to cancel or replace.     */

        if( (i = Fsfirst(filename,0) ) >= 0 ) {
          if( (choice = form_alert(1,existalert) ) == 1) {
            picflag = 0;
            break;
            }
          }

       /* See whether the disk has enough space to hold file. Use       */
       /* active drive if filename doesn't begin with a drive           */
       /* identifier.                                                   */

       drv = 0;
       if(filename[1] == ':') drv = (filename[0] - 64);

       /* GEMDOS routine Dfree returns # of free allocation units.      */

       i = Dfree(freebuff,drv);

       /* Assume we need 32768 bytes, just to be safe.                 */

       if( (total = (freebuff[0] * 1024) ) < 32768L ) {
         form_alert(1,enufalert);
         picflag = 0;
         break;
         }

        /* Should be OK to create/replace the file. GEMDOS routine      */
        /* Fcreate creates a file, replacing anything of the same name  */
        /* that exists already. If successful, it returns a positive    */
        /* filehandle to use in subsequent file operations.             */

        if( (filehandle = Fcreate(filename,0) ) < 0) {
          form_alert(1,erroralert);
          picflag = 0;
          break;
          }

        /* Write the header first, then the screen image.               */
        /* Header is different for NEOchrome and DEGAS.                 */

        /* GEMDOS routine Fwrite writes the specified number of bytes   */
        /* to the file specified by the filehandle, beginning at the    */
        /* buffer area specified in the final parameter.                */

        /* NEO file needs an extra word in front of the resolution      */
        /* word. Just put zeros there.                                  */

        if(savebutt == 2) {
          if( (i = Fwrite(filehandle, 2L, zerobuff) ) <0 ) {
            form_alert(1,erroralert);
            picflag = 0;
            break;
            }
          }

        /* Both files get 1 word showing screen resolution.             */

        if( (i = Fwrite(filehandle, 2L, &rez) ) < 2L) {
          form_alert(1,erroralert);
          picflag = 0;
          break;
          }

        /* Both files get 16 words of palette data, too.                */

        if( (i = Fwrite(filehandle, 32L, palbuff) ) <32L ) {
          form_alert(1,erroralert);
          picflag = 0;
          break;
          }

        /* NEO files get another 46 words for color cycling, etc.  A    */  
        /* screen that's just been captured can't possibly contain      */
        /* valid color-cycling information other than the default       */
        /* stuff that NEOchrome itself sticks in if you save a screen   */
        /* without doing cycling. So we'll just supply the defaults.    */

        if(savebutt == 2) {
          if( (i = Fwrite(filehandle, 92L, cyclebuff) ) <92L) {
            form_alert(1,erroralert);
            picflag = 0;
            break;
            }
          }

        /* Everybody gets a 32000-byte screen image.                    */

        if( (i = Fwrite(filehandle, 32000L, scrbuff) ) <32000L) {
          form_alert(1,erroralert);
          picflag = 0;
          break;
          }

        /* Close the file.                                              */

        if( (i = Fclose(filehandle) ) <0 ) {
          form_alert(1,erroralert);
          picflag = 0;
          break;
          }

        /* Clear the buffer flag.                                       */

        picflag = 0;

        /* We're done. Go home and count your chickens.                 */

        break;

        } /* if(msgbuff..... closes here                                */

    } /* if(event.....    closes here                                   */

  } /* never-ending while closes here                                   */

} /* main closes here                                                   */

