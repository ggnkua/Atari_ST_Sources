/********************************************************************/
/* Babel News transfer Agent For STiK/STiNG/GlueSTiK                */
/* First Created by Mark Baker                                      */
/* Recent Developements by Christian Andersson                      */
/* Future Implementation should be Multi-user friendly (somehow)    */
/********************************************************************/
/* include files                                                    */
#include <stdio.h> 
#include <string.h>
#include <time.h>
#include <ctype.h>

#include "..\fire.h"
#include "babel.h"

/********************************************************************/
/* String lengths                                                   */
#define MAXSTRING 255
#define MAXTIMELENGTH 18
#define STATUSLENGTH 80

/********************************************************************/
/* File handles imported from files.c                               */
extern FILE *descriptions ;
extern FILE *groups ;
extern FILE *newgroups ;
extern ACTIVE active ;
extern char *line_to_read;
extern int program_exit;
/********************************************************************/
/* Time zone                                                        */
/********************************************************************/
#define TZ_UNKNOWN 100
#define SECONDS_IN_AN_HOUR 3600

int tz = TZ_UNKNOWN ;

/********************************************************************/
/* Options */
/********************************************************************/
Options opt;

void maintain( void );
/********************************************************************/
/*                                                                  */
/* main() initialises everything, then runs process_file() to do all*/
/*    the work.                                                     */
/*                                                                  */
/********************************************************************/
int main( int argc, char **argv )
{
  parse_command_line( argc, argv ) ;

  initialise_gem() ;
  initialise_stik() ;

  status_line( strings.filesopen ,TRUE ,"","") ;
  open_files() ;
  process_file() ;
  status_line( strings.filesclose ,TRUE ,"","") ;
  close_files() ;

  shutdown_gem() ;

  return 0 ;
}

/********************************************************************/
/*                                                                  */
/* parse_command_line()'s use is obvious                            */
/*                                                                  */
/********************************************************************/
void parse_command_line( int argc, char **argv )
{
  int counter;
  char *arg ;

  /* Defaults */
  opt.mode = 'g' ;                                       /* TOS/GEM modes                                          */
  opt.logging = FALSE;                                   /* NO Logging                                             */
  opt.dupcheck = FALSE;                                  /* Do NOT check for dupes when retrieving                 */
  opt.offline=FALSE;                                     /* GO Online                                              */
  opt.datecheck = FALSE;                                 /* Do NOT check for old messages                          */
  opt.delete = FALSE;                                    /* Do NOT hard-delete messages                            */
  opt.comment = FALSE;                                   /* Do NOT create comment tree                             */
  memset((void*)&active,0,sizeof(ACTIVE));
  
  opt.directory[0] = '\0' ;

  /* Skip program name */
  counter=1;                                             /* One, not zero, as we're skipping program name                                      */
  while( counter<argc )
  {
    if( argv[counter][0] != '-' )
    {
      byebye(0);
      break;
    }
    switch( argv[counter][1] )
    {
      case 'g' :                                            /* -g or --gem  Runs Babel in GEM                                 */
        opt.mode = 'g' ;
        break ;
      case 't' :                                            /* -t or --text Runs babel in Text-Mode                           */
        opt.mode = 't' ;
        break ;
      case 'q' :                                            /* -q or --quiet Do not Print anything to screen in text-mode     */
		if(opt.mode=='t')
          opt.mode = 'q' ;
        break ;
      case 's' :                                            /* -s or --silent do not show the Alert when an error accour      */
        if( opt.mode == 'g' )
          opt.mode = 's';
        break;
      case 'c':                                             /* -c create comment tree                                         */
        opt.comment = 1;
        break;
      case 'l' :                                            /* -l create a log file                                           */
        opt.logging = 1 ;
        break ;
      case 'm' :                                            /* -m Force babel into doing a full maintenance                   */
        opt.datecheck = TRUE ;
	    opt.dupcheck = TRUE ;
        opt.delete = TRUE ;
        opt.comment = TRUE ;
        break;
      case 'r' :                                            /* Delete "Deleted" messages */
        opt.delete = TRUE ;
        break;
      case 'e' :                                            /* Check for Dupes */
        opt.dupcheck = TRUE ;
        break;
      case 'a' :
        opt.datecheck = TRUE ;
        break;
      case 'o' :                                            /* Do not go On-line (perheps only maint?)                        */
        opt.offline = TRUE ;
        break;
      case 'd' :                                            /* -d or --directory change news-directory                        */
        arg = argv[counter] ;

        while ( *arg != '\0' && *arg != '=' )               /* search for an '='                                              */
          arg++ ;

        if( *arg == '=' )                                   /* did we found an =                                              */
          strcpy( opt.directory, ++arg ) ;
        else if( argc-- != 1 )                              /* the path is the next option                                    */
          strcpy( opt.directory, argv[++counter] ) ;
    }
    counter++;
  }
}

/********************************************************************/
/********************************************************************/
void process_file( void )
{
  char server_time[MAXTIMELENGTH+1] ;
  time_t currtime ;
  char statusstr[MAXSTRING+1] ;
  int temp_messages;
  
    /* Default time */
  currtime = time( NULL ) ;
  /* Adjust for timezone, and use the GMT time */
  currtime -= active.time * SECONDS_IN_AN_HOUR ;
  strftime( server_time, MAXTIMELENGTH, "%y%m%d %H%M%S GMT", localtime( &currtime ) ) ;


  if(!opt.offline)
  {
    active.serv_num=0;
    while(active.serv_num < active.num_of_servers)
    {
      sprintf( statusstr, strings.serveropen, active.servers[active.serv_num].name ) ;
      status_line( statusstr ,TRUE ,"","") ;
      if( open_server( active.servers[active.serv_num].name ) != FAIL )
      {
        if ( program_exit ) { close_server(); break; }

        if( active.servers[active.serv_num].new_server )
          new_server( active.servers[active.serv_num].name , active.servers[active.serv_num].file ) ;
        else
          new_groups( active.servers[active.serv_num].file, server_time ) ;
        if ( program_exit ) { close_server(); break; }

        strftime( active.servers[active.serv_num].date,SIZE_DATE,"%y%m%d",localtime( &currtime ) );
        strftime( active.servers[active.serv_num].time,SIZE_DATE,"%H%M%S",localtime( &currtime ) );
        status_line(NULL,TRUE,active.servers[active.serv_num].name,"");
        active.group_num=0;
        while( active.group_num < active.num_of_groups )
        {
          active.tempgroup=get_entity(active.glist,active.group_num);
          if ( ! active.tempgroup )
            continue;
          if ( active.tempgroup->serv_num != active.serv_num )
            continue;
          temp_messages=do_group(&active.servers[active.serv_num],active.tempgroup);
          save_active();
          if ( program_exit ) { break; }
          active.group_num++;
        }
        close_server();
      }
      active.serv_num++;
    }
  }
  active.group_num=0;
  while( active.group_num < active.num_of_groups )
  {
    active.tempgroup=get_entity(active.glist,active.group_num);
    if( !active.tempgroup )
      break;
    status_line( "" ,TRUE , active.servers[ active.tempgroup->serv_num ].name , active.tempgroup->groupname ) ;
    if(program_exit) break;
    if(opt.datecheck)
      check_old_date( active.tempgroup );
    if(program_exit) break;
    if(opt.dupcheck)
      delete_dupes( active.tempgroup );
    if(program_exit) break;
    if(opt.delete)
      hard_delete( active.tempgroup );
    if(program_exit) break;
    if(opt.comment)
      make_comment( active.tempgroup );
    if(program_exit) break;
    active.group_num++;
  }
}

/********************************************************************/
/*
 * new_server() connects to a server, and reads a full group list,
 *    and a complete descriptions list.
 *
 * server_name is, obviously, the hostname of the server, groupfile
 * is the base filename associated with the server 
 */
/********************************************************************/
void new_server( char *server_name, char *groupfile )
{
  char statusstr[STATUSLENGTH+1] ;
  int has_xgtitle = 1 ;
  char *gptr ;

  /* Create file with unique name */
  sprintf( statusstr, strings.groupfile, server_name ) ;
  status_line( statusstr , TRUE , server_name , "" ) ;
  group_list_file( server_name, groupfile ) ;

  /* Send command to get group list */
  status_line( strings.fullgroups , TRUE , NULL , NULL ) ;
  write_string( "list\r\n" ) ;

  /* Get 215 reply */
  read_line( line_to_read, MAXLINELENGTH ) ;
  line_to_read[3] = '\0' ;
  if( strcmp( line_to_read, "215" ) )
  {
    line_to_read[3]=' ';
    alert( strings.unexpected ) ;
    byebye(1) ;
  }

  /* Read group list */
  while( 1 )
  {
    /* Read a line */
    read_line( line_to_read, MAXLINELENGTH ) ;

    /* Check for last line */
    if( line_to_read[ 0 ] == '.' )
      break ;

    /* Find end of group name and null-terminate it */
    for( gptr = line_to_read; !isspace( *gptr ); gptr++ ) ;
    *gptr = '\0' ;

    /* Print group name to group file */
    fprintf( groups, "%s\n", line_to_read ) ;
  }

  /* Send command to get descriptions */
  status_line( strings.descriptions , TRUE , NULL , NULL) ;
  write_string( "xgtitle *\r\n" ) ;

  /* Get 282 reply */
  read_line( line_to_read, MAXLINELENGTH ) ;
  line_to_read[3] = '\0' ;
  if( !strcmp( line_to_read, "500" ) )
  {
    has_xgtitle = 0 ;
  }
  else if( strcmp( line_to_read, "282" ) )
  {
    line_to_read[3]=' ';
    alert( strings.unexpected ) ;
    byebye(1) ;
  }

  if( has_xgtitle )
  {
    while( 1 )
    {
      /* Read a line */
      read_line( line_to_read, MAXLINELENGTH ) ;

      /* Have we got to the end? */
      if( line_to_read[0] == '.' )
        break ;

      /* Find end of group line and null terminate it */
      for( gptr = line_to_read; !isspace( *gptr ); gptr++ ) ;
      *gptr = '\0' ;

      /* Only store description if it isn't a ? */
      if( strcmp( gptr, "?" ) )
      {
        /* Print group name */
        fprintf( descriptions, "%s ", line_to_read ) ;
          
        /* Skip whitespace */
        while( isspace( *++gptr ) ) ;
          
        /* Print description */
        fprintf( descriptions, "%s\n", gptr ) ;
      }
    }
  }

  /* Close files */
  fclose( groups ) ;
  fclose( descriptions ) ;
}

/********************************************************************/
/*
 * new_groups() checks a server for any new groups since last
 *    time we logged on. Then for each one in turn, it
 *    looks for a description and appends it to the .dsc file
 * 
 * basename is the filename associated with the server (without 
 * extension), date is a string containing the date the server
 * was last contacted.
 */
/********************************************************************/
void new_groups( char *basename, char *date )
{
  char command[MAXSTRING+1] ;
  char *gptr ;

  if(active.servers[active.serv_num].get_new_groups)
  {
    /* Open file */
    new_groups_file( basename ) ;

    /* Send command to get group list */
    status_line( strings.newgroups , TRUE , NULL , basename ) ;
    sprintf( line_to_read, "newgroups %s\r\n", date ) ;
    write_string( line_to_read ) ;

    /* Get 231 reply */
    read_line( line_to_read, MAXLINELENGTH ) ;
Log("New_groups: %s\n",line_to_read);
    line_to_read[3] = '\0' ;
Log("New_groups: %s\n",line_to_read);
    if(strcmp( line_to_read, "231" ) )
    {
      line_to_read[3]=' ';
      alert( strings.unexpected ) ;
      byebye(1) ;
    }
Log("New_groups: Better\n");

    /* Read back new groups */
    while( 1 )
    {
      /* Read a line */
      read_line( line_to_read, MAXLINELENGTH ) ;
Log("New_groups: %s\n",line_to_read);

      /* Check for last line */
      if( line_to_read[0] == '.' )
        break ;

      /* Find end of group name and null-terminate it */
      for( gptr = line_to_read; !isspace( *gptr ); gptr++ ) ;
      *gptr = '\0' ;

      /* Print group name to new groups file and group list */
      fprintf( newgroups, "%s\n", line_to_read ) ;
      fprintf( groups, "%s\n", line_to_read ) ;
    }

    /* Rewind file so we can read back from it to get descriptions */
    rewind( newgroups ) ;

      
    if(active.servers[active.serv_num].get_descriptions)
    {
      /* Get descriptions */
      status_line( strings.descriptions , TRUE , NULL , NULL ) ;
      while( fgets( line_to_read, MAXLINELENGTH, newgroups ) )
      {
        /* Send xgtitle command */
        ((char *)strrchr(line_to_read,'\n'))[0]='\0';
        ((char *)strrchr(line_to_read,'\r'))[0]='\0';
        sprintf( command, "xgtitle %s\r\n", line_to_read ) ;
        write_string( command ) ;
  
        /* Get 215 reply */
        read_line( line_to_read, MAXLINELENGTH ) ;
        line_to_read[3] = '\0' ;
        if( !strcmp( line_to_read, "500" ) )
        {
          /* No xgtitle command - oh well, never mind */
          break ;
        }
        else if( strcmp( line_to_read, "282" ) )
        {
          line_to_read[3]=' ';
          alert( strings.unexpected ) ;
          byebye(1) ;
        }

        /* Read what ought to be the description */
        read_line( line_to_read, MAXLINELENGTH ) ;

        /* Is there a description */
        if( line_to_read[0] != '.' )
        {
          /* Find beginning of end of group name and null-terminate it */
          for( gptr = line_to_read; !isspace( *gptr ); gptr++ ) ;
          *gptr = '\0' ;
          
          /* Print group name */
          fprintf( descriptions, "%s ", line_to_read ) ;

          /* Skip whitespace */
          while( isspace( *++gptr ) ) ;
      
          /* Print description */
          fprintf( descriptions, "%s\n", gptr ) ;
      
          /* Ignore the dot and any lines up to it */
          do
          {
            read_line( line_to_read, MAXLINELENGTH ) ;
          }
          while( line_to_read[0] != '.' ) ;
        }
      }
    }

    /* Close files */
    fclose( groups ) ;
    fclose( newgroups ) ; 
    fclose( descriptions ) ;
  }
}

/********************************************************************/
/*
 * byebye() tidies up and quits, and is called when we get an error
 *
 * retstat is the program status to return to the caller
 */
/********************************************************************/
void byebye( retstat )
{
  close_server() ;
  close_files();

  shutdown_gem() ;

  exit( retstat ) ;
}

/********************************************************************/
/* This Log-function should work almost like printf                 */
/* %d - int                                                         */
/* %l - long                                                        */
/* %s - char *                                                      */
/* %x - int (Hex)                                                   */
/* %X - long (Hex)                                                  */
/********************************************************************/
#include <stdarg.h>
void Log(char *logstring,...)
{
  char *point=logstring;
  int num_parm=0L;
  va_list ap;
  FILE *logfile;

    logfile=fopen("babel.lge","a");
    if(logfile!=NULL)
    {
      while(*point!=0)
      {
        if(*point=='%')
        {
          point++;
          if((*point=='c')||(*point=='d')||(*point=='s')||(*point=='l'))
            num_parm++;
          if(*point==0)
            point--;
        }
        point++;
      }
      if(num_parm>0)
        va_start(ap,logstring);
      point=logstring;
      
      while(*point!=0)
      {
        if(*point=='%')
        {
          point++;
           if(*point=='%')
           fputc('%',logfile);
          else if(*point=='d')
            fprintf(logfile,"%d",va_arg(ap,int));
          else if(*point=='l')
            fprintf(logfile,"%ld",va_arg(ap,long));
          else if(*point=='x')
            fprintf(logfile,"%x",va_arg(ap,long));
          else if(*point=='X')
            fprintf(logfile,"%X",va_arg(ap,long));
          else if(*point=='s')
            fprintf(logfile,"%s",va_arg(ap,char *));
          else if(*point!=0)
          {
            fputc('%',logfile);
            fputc(*point,logfile);
          }
          else
            point--;
        }
        else
          fputc(*point,logfile);
        point++;
      }
      fclose(logfile);
      va_end(ap);
    }
}

