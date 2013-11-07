#if 1
#include <stdio.h>
#include "sokoban.h"
#if !ATARIST
#include <sys/types.h>
#endif
#include <stat.h>
#include <signal.h>

extern char *username;
extern char map[MAXROW+1][MAXCOL+1];
extern short level, moves, pushes, packets, savepack, rows, cols;
extern POS ppos;
extern soko_state state[];
extern int state_num;

#if ATARIST
int savedbn;
#else
long  savedbn;
#endif

char *sfname;
FILE *savefile;
struct stat sfstat;

short savegame() {

   short ret = 0;

   signal( SIGINT, SIG_IGN);
   sfname = malloc( strlen( SAVEPATH) + strlen( username) + 5);
#if ATARIST
   sprintf( sfname, "%s\\%s.sav", SAVEPATH, username);
#else
   sprintf( sfname, "%s/%s.sav", SAVEPATH, username);
#endif

   if( (savefile = fopen( sfname, "w")) == NULL)
      ret = E_FOPENSAVE;
   else {
      savedbn = fileno( savefile);
      if( write( savedbn, &(map[0][0]), MAXROW*MAXCOL) != MAXROW*MAXCOL)
        ret = E_WRITESAVE;
      else if( write( savedbn, &ppos, sizeof( POS)) != sizeof( POS))
        ret = E_WRITESAVE;
      else if( write( savedbn, &level, 2) != 2)    ret = E_WRITESAVE;
      else if( write( savedbn, &moves, 2) != 2)    ret = E_WRITESAVE;
      else if( write( savedbn, &pushes, 2) != 2)   ret = E_WRITESAVE;
      else if( write( savedbn, &packets, 2) != 2)  ret = E_WRITESAVE;
      else if( write( savedbn, &savepack, 2) != 2) ret = E_WRITESAVE;
      else if( write( savedbn, &rows, 2) != 2)     ret = E_WRITESAVE;
      else if( write( savedbn, &cols, 2) != 2)     ret = E_WRITESAVE;
	else if (write(savedbn, &state_num, sizeof(state_num)) !=
		sizeof(state_num)) ret = E_WRITESAVE;
	else if (write(savedbn, state, state_num * sizeof(soko_state)) !=
		state_num * sizeof(soko_state)) ret = E_WRITESAVE;
      else {
        fclose( savefile);
        if( stat( sfname, &sfstat) != 0) ret = E_STATSAVE;
        else if( (savefile = fopen( sfname, "a")) == NULL)
            ret = E_FOPENSAVE;
         else {
           if( write( savedbn, &sfstat, sizeof( sfstat)) != sizeof( sfstat))
              ret = E_WRITESAVE;
           fclose( savefile);
        }
      }
   }
   if( (ret == E_WRITESAVE) || (ret == E_STATSAVE)) unlink( sfname);
   signal( SIGINT, SIG_DFL);

   return( ret);
}

short restoregame() {

   short ret = 0;
   struct stat oldsfstat;

   signal( SIGINT, SIG_IGN);
   sfname = malloc( strlen( SAVEPATH) + strlen( username) + 5);
#if ATARIST
   sprintf( sfname, "%s\\%s.sav", SAVEPATH, username);
#else
   sprintf( sfname, "%s/%s.sav", SAVEPATH, username);
#endif
   if( stat( sfname, &oldsfstat) < -1)
      ret = E_NOSAVEFILE;
   else {
      if( (savefile = fopen( sfname, "r")) == NULL)
        ret = E_FOPENSAVE;
      else {
         savedbn = fileno( savefile);
         if( read( savedbn, &(map[0][0]), MAXROW*MAXCOL) != MAXROW*MAXCOL)
           ret = E_READSAVE;
         else if( read( savedbn, &ppos, sizeof( POS)) != sizeof( POS))
           ret = E_READSAVE;
         else if( read( savedbn, &level, 2) != 2)    ret = E_READSAVE;
         else if( read( savedbn, &moves, 2) != 2)    ret = E_READSAVE;
         else if( read( savedbn, &pushes, 2) != 2)   ret = E_READSAVE;
         else if( read( savedbn, &packets, 2) != 2)  ret = E_READSAVE;
         else if( read( savedbn, &savepack, 2) != 2) ret = E_READSAVE;
         else if( read( savedbn, &rows, 2) != 2)     ret = E_READSAVE;
         else if( read( savedbn, &cols, 2) != 2)     ret = E_READSAVE;
		else if (read(savedbn, &state_num, sizeof(state_num)) !=
			sizeof(state_num)) ret = E_READSAVE;
		else if (read(savedbn, state, state_num * sizeof(soko_state)) !=
			state_num * sizeof(soko_state)) ret = E_READSAVE;
        else if( read( savedbn, &sfstat, sizeof( sfstat)) != sizeof( sfstat))
           ret = E_READSAVE;

        else if( (sfstat.st_dev != oldsfstat.st_dev) ||
                  (sfstat.st_ino != oldsfstat.st_ino) ||
                  (sfstat.st_nlink != oldsfstat.st_nlink) ||
                  (sfstat.st_uid != oldsfstat.st_uid) ||
                  (sfstat.st_gid != oldsfstat.st_gid) ||
                  (sfstat.st_mtime != oldsfstat.st_mtime))

            ret = E_ALTERSAVE;
      }
      unlink( sfname);
   }
   signal( SIGINT, SIG_DFL);
   return( ret);
}
#else
savegame() {return 0}
restoregame() {return 0}
#endif
