/*   
 *  cdplayer
 *
 *  Michel R. Prevenier.
 */

#include <sys/types.h>
#include <errno.h>
#include <curses.h>
#include <signal.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <minix/cdrom.h>

#define MAX_TRACKS	110
#define CURS_CTRL	'\033'
#define UP   		'A'
#define DOWN		'B'
#define LEFT		'C'
#define RIGHT		'D'
#define BACKSPACE	(char) 8

_PROTOTYPE ( void duration, (u8_t t1[3], u8_t t2[3], u8_t length[]));
_PROTOTYPE ( int main, (int arg, char **argv));
_PROTOTYPE ( void usage, (void));
_PROTOTYPE ( void non_interactive, (void));
_PROTOTYPE ( void setup_screen, (void));
_PROTOTYPE ( void user_interface, (void));
_PROTOTYPE ( void list_toc, (void));
_PROTOTYPE ( void terminate, (int s));
_PROTOTYPE ( void play, (int *track_list, int next));

int track_list[MAX_TRACKS];
struct cd_toc_entry toc[MAX_TRACKS];
struct cd_disk_info info = 0;
struct cd_toc_entry toc_entry;
struct cd_play_track tracks;
WINDOW *main_win;
WINDOW *toc_win;
WINDOW *play_win;
WINDOW *list_win;
WINDOW *status_win;
int old_stdin;
int fd;
int rflag, all;


void usage()
{
  fprintf(stderr, "Usage: cdplay [-r]|[-a] \n");
  exit(-1);
}


void terminate(s)
int s;
{
  /* Restore terminal parameters and exit */

  (void) fcntl(0,F_SETFL,old_stdin);
  move(23, 0);			
  refresh();			
  resetty();
  endwin();			
  exit(1);		
}


void duration(t1, t2, length)
u8_t t1[3];
u8_t t2[3];
u8_t length[];
{
  /* Compute time difference in min:sec */

  int time1, time2;

  time1 = (int) t1[MINUTES] * 60 + t1[SECONDS];
  time2 = (int) t2[MINUTES] * 60 + t2[SECONDS];
  time2 -= time1;

  length[MINUTES] = (u8_t) (time2 / 60);
  length[SECONDS] = (u8_t) (time2 % 60);
  length[SECTOR] = 0;
}


int main(argc, argv)
int argc;
char **argv;

{
  int i;

  /* Open cdrom */
  if ((fd = open("/dev/cd0",O_RDONLY)) < 0)
  {
    fprintf(stderr, "Cannot open /dev/cd0\n");
    exit(-1);
  }

  /* Read disk info */
  if (ioctl(fd, CDIOREADTOCHDR, &info) != 0)
  {
    fprintf(stderr, "Cannot read disk info\n");
    exit(-1);
  }

  /* Read table of contents */      
  if (ioctl(fd, CDIOREADTOC, &toc) != 0)
  {
    fprintf(stderr, "Cannot read table of contents\n");
    exit(-1);
  }

  /* Initialize randomizer */
  srand(getpid());

  /* Fill last entry of toc table with the disk length */
  toc[info.last_track+1].position_mss[MINUTES] = info.disk_length_mss[MINUTES];
  toc[info.last_track+1].position_mss[SECONDS] = info.disk_length_mss[SECONDS];

  /* Get arguments */
  if (argc > 1) 
  {
    if (strncmp(&argv[1][0], "-r", 2) == 0) rflag = 1;
    else if (strncmp(&argv[1][0], "-a", 2) == 0) all = 1;
    else usage();

    /* If there were any arguments, start cdplay non-interactively */
    non_interactive();
  }
    
  /* Initialize windows */
  (void) initscr();
  signal(SIGINT, terminate);
  old_stdin = fcntl(0,F_GETFL);
  cbreak();
  noecho();
  main_win = newwin(23,80,0,0);
  scrollok(main_win, FALSE);
  list_win = subwin(main_win,5,25,12,40);
  play_win = subwin(main_win,4,25,7,40);
  status_win = subwin(main_win,1,30,19,40);
  toc_win = subwin(main_win,18,28,3,2);
  scrollok(toc_win,TRUE);
  wsetscrreg(toc_win,0,17); 

  /* Setup the user screen */
  setup_screen();

  /* Handle input from user */
  user_interface(); 
}


void non_interactive()
{
  /* Play non-interactively. This means play the selected tracks
   * in the background
   */

  int next = 0;
  int i,j;
  int sleep_time;
  u8_t time[3];
 
  /* Close the old file descriptor. After starting the child process
   * we exit the parent which will close all of its open files.
   * So we have to create a new file descriptor in the child's
   * process. */
  close(fd);

  /* If random play was selected, fill the tracklist randomly */
  if (rflag)
  {
    while (next < info.last_track)
    {
      track_list[next] = 0;
      i = (rand() % (info.last_track - info.first_track + 1)) + 1;
      for (j = 0; j<next; j++)
        if (track_list[j] == i) break;
      if (track_list[j] != i) track_list[next++] = i;
    }
  }
  
  /* Fork the background process */
  switch(fork())
  {
    case -1:
    {
      fprintf(stderr, "Cdplay: could not fork \n");
      exit(-1);
    }
    case 0: break;      /* child continues */
    default: exit(0);   /* parent exits */
  }

  /* This is the child process, which is now an orphan because the
   * parent process has exited
   */

  /* Open cdrom device again */
  if ((fd = open("/dev/cd0",O_RDONLY)) < 0) exit(-1);

  /* If all tracks were selected, program cd to play all tracks
   * end them exit 
   */
  if (all)
  {
    tracks.begin_track = info.first_track;
    tracks.end_track = info.last_track;
    (void) (ioctl(fd, CDIOPLAYTI, &tracks));  
    exit(0);
  }
  
  /* Random play is chosen, play all tracks in the track list */
  for(i=0;i<next;i++)
  {
    /* Get next track */
    tracks.begin_track = track_list[i];
    tracks.end_track = track_list[i];

    /* Start cd */
    if ((ioctl(fd, CDIOPLAYTI, &tracks) == 0)) 
    {
      /* Compute track time */
      duration(toc[tracks.begin_track].position_mss,       
               toc[tracks.begin_track+1].position_mss,
               time);
      /* Convert track time to seconds */
      sleep_time = (int)time[MINUTES]*60 + (int)time[SECONDS];

      /* Sleep while we are playing, and wakeup 1 second before
       * the track has finished
       */
      sleep_time -= 1; /* wakeup one second before ending of track */ 
      sleep(sleep_time);

      /* The track will soon be finished, try to read the subchannel.
       * As long as the track is playing the ioctl will succeed. 
       * When the cd has stopped playing the iocontrol will give an
       * error indicating that we can start the next track
       */   
      while(ioctl(fd,CDIOREADSUBCH, &toc_entry) == 0);
    } 
  }
  exit(0);
}
  

void setup_screen()
{
  /* Draw the user screen */

  wclear(main_win);
  mvwprintw(main_win,1,40,"------- Disk Info -------");
  mvwprintw(main_win,2,40,"  #tracks    disk length", NULL);
  mvwprintw(main_win,3,40,"     %02d         %02d:%02d\n",
                      (int) info.last_track - info.first_track + 1,
                      (int) info.disk_length_mss[MINUTES],
                      (int) info.disk_length_mss[SECONDS]);
  mvwprintw(main_win,5,40,"------- Play Info -------", NULL);
  mvwprintw(main_win,6,40,"   total      remaining ", NULL);
  mvwprintw(main_win,1,2,"------- Track List -------", NULL);
  mvwprintw(main_win,2,2,"track  begin   end  length", NULL);
  mvwprintw(main_win,11,40,"------- Play List -------", NULL);
  mvwprintw(main_win,18,40,"-------- Status ---------", NULL);
  wrefresh(main_win);
  wclear(list_win);
  (void) mvwprintw(list_win,0,1,"All",NULL);
  wrefresh(list_win);
  wclear(play_win);
  wclear(status_win);
  (void) mvwprintw(status_win,0,0,"Stopped",NULL);
  wrefresh(status_win);
  wclear(toc_win);
  list_toc();        /* list table of contents */
}
 

void list_toc()
{
  /* Show the track list ( = toc) */
  int position = 0;
  int track = info.first_track;
  u8_t length_mss[3];

  /* Keep displaying track unitl the window is full */
  while (track <= info.last_track && position < 18)
  {
    duration(toc[track].position_mss, 
             toc[track+1].position_mss, length_mss);
    (void) mvwprintw(toc_win,position,2,"%02d   %02d:%02d  %02d:%02d  %02d:%02d",
          track, 
          (int) toc[track].position_mss[MINUTES],
          (int) toc[track].position_mss[SECONDS],
          (int) toc[track+1].position_mss[MINUTES],
          (int) toc[track+1].position_mss[SECONDS],
          (int) length_mss[MINUTES],
          (int) length_mss[SECONDS]);
     position++;
     track++;
  }
  wrefresh(toc_win);
}


void user_interface()
{
  /* This routine handles the user interface. */ 

  int position = 0;
  int next = 0;
  int x,y,i,j;
  int track = info.first_track;
  char c;
  u8_t length_mss[3];
  
  while (1)
  {
    duration(toc[track].position_mss, 
             toc[track+1].position_mss, length_mss);
    (void) mvwprintw(toc_win,position,1," %02d   %02d:%02d  %02d:%02d  %02d:%02d",
            track, 
            (int) toc[track].position_mss[MINUTES],
            (int) toc[track].position_mss[SECONDS],
            (int) toc[track+1].position_mss[MINUTES],
            (int) toc[track+1].position_mss[SECONDS],
            (int) length_mss[MINUTES],
            (int) length_mss[SECONDS]);
    wrefresh(toc_win);
    switch (c = wgetch(toc_win))
    {
      case CURS_CTRL:
      {
        (void) wgetch(toc_win);
        switch (wgetch(toc_win))
        {
          case DOWN:
          {
            if (track < info.last_track)
              if (position > 16) 
              {
                scroll(toc_win);
                track++;
              }
              else
              {
                position++;
                track++;
              }
          };break;
          case UP:
          {
            if (track > info.first_track) 
              if (position < 1)
              {
                winsertln(toc_win);
                track--;
              }
              else
              {
                position--;
                track--;
              }
          };break;
        }
      };break;
      case ' ':
      case BACKSPACE:
      {
        wclear(list_win);
        if (c == ' ')
        {
          if (next < MAX_TRACKS)
            track_list[next++] = track;
        }
        else
        {
          next--;
          if (next <= 0) 
          {
            next = 0;
            (void) mvwprintw(list_win,0,1,"All", NULL);
          }
        }
        x=0;y=0;i=0;
        while (i < next)
        {
          (void) mvwprintw(list_win,y,x+1,"%02d",track_list[i]);
          if (i < next-1) waddch(list_win,',');
          i++;
          x+=3;
          y+= x/24;
          x %= 24;
        }
        wrefresh(list_win);
      };break;
      case 's':
      {
        if (!next)
        {
          next = info.last_track - track + 1; 
          for (i = 0; i < next; i++)
            track_list[i] = track + i;
        }
        play(&track_list[0],next);
        next = 0;
        wclear(list_win);
        (void) mvwprintw(list_win,0,1,"All",NULL);
        wrefresh(list_win);
        wclear(status_win);
        (void) mvwprintw(status_win,0,0,"Stopped",NULL);
        wrefresh(status_win);
      };break;
      case 'r':
      {
        next = 0;
        while (next < info.last_track)
        {
          track_list[next] = 0;
          i = (rand() % (info.last_track - info.first_track + 1)) + 1;
          for (j = 0; j<next; j++)
            if (track_list[j] == i) break;
          if (track_list[j] != i) track_list[next++] = i;
        }
        wclear(list_win);
        (void) mvwprintw(list_win,0,1,"Random",NULL);
        wrefresh(list_win);
        play(&track_list[0],next);
        next = 0;
      }
      case 'p': play(&track,1);break;
      case 'e': terminate(1);
      default: break;
    }
  }
}


void play(track_list, nr_of_tracks)
int *track_list;
int nr_of_tracks;
{
  /* Start playing the tracks in the track list. */

  int next = 0;
  int done, finished;
  int paused = 0;
  u8_t rem_time[3];
  char c;

  /* Set terminal to non-blocking mode */
  (void) fcntl(0,F_SETFL,old_stdin | O_NONBLOCK);

  done = 0;
  while (!done)
  {
    if (read(0, &c, 1) == 1)
    {
      switch (c)
      {
        case 's': done = 1;break;
        case ' ': 
           {
             wclear(status_win);
             if (!paused) 
             { 
               (void) ioctl(fd, CDIOPAUSE, (char *)0);
               mvwprintw(status_win,0,0,"Paused  ", NULL);
             }
             else 
             {
               (void) ioctl(fd, CDIORESUME, (char *)0);
               mvwprintw(status_win,0,0,"Playing", NULL);
             }
             wrefresh(status_win);
             paused++;
             paused%=2;
           };break;    
        case CURS_CTRL: 
           {
             (void) read(0, &c, 1);
             (void) read(0, &c, 1);
             switch (c)
             {
               case UP:
                  {
                    if (next >= nr_of_tracks) next--; 
                    finished = 1;
                  };break;
               case DOWN: 
                  {
                    next-=2;
                    if (next < 0) next = 0;
                    finished = 1;
                  };break;
               case LEFT:
               case RIGHT:
               default: break; 
             }
           }
       default: break;
      }
    } 
    else
    {
      if (finished)
      {
        tracks.begin_track = track_list[next];
        tracks.end_track = track_list[next++];
        wclear(status_win);
        if (ioctl(fd, CDIOPLAYTI, &tracks) < 0) 
        {
          (void) mvwprintw(status_win,0,0,
                          "ERROR: cannot play track %d",tracks.begin_track);
          wrefresh(status_win);
          sleep(1);
        }
        else  
        {
          finished = 0;
          (void) mvwprintw(status_win,0,0,"Playing", NULL);
          wrefresh(status_win);
        }
      }
      else
      {
        if (!paused)
          if (ioctl(fd, CDIOREADSUBCH, &toc_entry) != 0)
          {
            finished = 1;
            if (next >= nr_of_tracks) done = 1;
          }
        duration(toc_entry.position_mss,  
                 toc[toc_entry.track_nr+1].position_mss, 
                 rem_time);
        mvwprintw(play_win,0,0,"   %02d:%02d        %02d:%02d",
                   toc_entry.track_time_mss[MINUTES],
                   toc_entry.track_time_mss[SECONDS],
                   rem_time[MINUTES], rem_time[SECONDS]); 
        duration(toc_entry.position_mss, info.disk_length_mss, rem_time);
        mvwprintw(play_win,1,0,"   %02d:%02d        %02d:%02d",
                   toc_entry.position_mss[MINUTES],
                   toc_entry.position_mss[SECONDS],
                   rem_time[MINUTES], rem_time[SECONDS]); 
        mvwprintw(play_win,2,9,"- %02d -", toc_entry.track_nr);
        mvwprintw(play_win,3,24," ", NULL);
        wrefresh(play_win);
      }
    }
  }

  /* restore terminal parameters */
  (void) fcntl(0,F_SETFL,old_stdin);
  (void) ioctl(fd, CDIOSTOP, (char *)0);

  wclear(play_win);
  wrefresh(play_win);
}
