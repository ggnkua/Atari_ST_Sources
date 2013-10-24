/*--------------------------------------------------------------------------
  ACCSEL - a simple accessory selector

  Copy the program into a folder called AUTO on the boot disk. It must be 
  called ACCSEL.PRG. When the computer is switched on the names of the 
  accessories on the disk will be listed on the screen. Choose the ones 
  you want and then hit return.

  The source code is Laser C, by Les Kneeling, 1990

--------------------------------------------------------------------------*/
#include <stdio.h>
#include <osbind.h>
#include <strings.h>

/*--------------------------------------------------------------------------
  Structure definitions
--------------------------------------------------------------------------*/
typedef struct dta  {
                    char    reserved[21];
                    char    fattr;
                    int     ftime;
                    int     fdate;
                    long    fsize;
                    char    fname[14];
                    };

typedef struct fentry {
                    char    fname[20];      /* extra wide to give four
                                               names per line           */
                    struct fentry *next;    /* pointer to next struct in
                                               the linked list - used when
                                               going forwards           */
                    struct fentry *last;    /* pointer to the last struct
                                               in the list - used when
                                               going forwards           */
                    };

/*--------------------------------------------------------------------------
  Globals
--------------------------------------------------------------------------*/
struct fentry start;
char file_count;
char from[21], to[21];
char resolution;                /* Scaling factor for display           */
/*-------------------------------------------------------------------------
  Start
--------------------------------------------------------------------------*/

main()
{
start.last = 0l;            /* Initialise struct at beginning of list   */
start.next = 0l;
if( Getrez() == 2 ) resolution = 4;     /* Set up scaling factor for    */
else resolution = 2;                    /* colour or mono display       */
clrscr();
gotoxy( 0, 0 );                         /* Go to top left corner        */
inverted_text();                        /* White text on black          */
if( resolution == 4 ) Cconws("                                        ");
Cconws("               ACCSEL - by Les Kneeling " );
                                        /* That's me                    */
gotoxy( 23, 0 );                        /* Bottom two lines             */
inverted_text();                        /* White on black               */
if( resolution == 4 )
Cconws("             <+> switch accessory on,     <-> switch accessory off              ");
else Cconws("  <+> accessory on, <-> accessory off   ");
auto_overflow_off();                    /* Stop the screen scrolling when
                                           the bottom left corner has a
                                           character printed in it      */
gotoxy( 24, 0 );
if( resolution == 4 )
    {
    Cconws("      " );
    Bconout( 5, 4 );
    Cconws( " and " );
    Bconout( 5, 3 ); 
    Cconws( " select file,   ESC clears all accessories    <return> finish      ");
    }
else 
    {
    Cconws( "  " );
    Bconout( 5, 4 );
    Bconout( 2, 32 );
    Bconout( 5, 3 );
    Cconws( " select, + on, - off, Return end   " );
    }
auto_overflow_on();                     /* Back to normal               */
normal_text();                          /* and black on white           */

get_filenames();
show_filenames();
interact();
free_memory();
}

/*--------------------------------------------------------------------------
  Read the disk directory
--------------------------------------------------------------------------*/
get_filenames()
{
int error; 
struct dta newdta;
struct fentry *ptr, *holder;

ptr = &start;

Fsetdta( &newdta );                     /* User defined disk transfer
                                           address  */

file_count = 0;
error = Fsfirst( "\\*.ACC", 0x3f );     /* First search for the ACCs    */
while((!error)&&(file_count < 20 * resolution ))
    {
    file_count++;                       /* Make sure files don't over-
                                           write the stuff on the screen*/
    strcpy( ptr->fname, newdta.fname ); /* Copy filename into struct    */
    expand( ptr->fname );               /* Make the string 20 characters
                                           wide                         */
    holder = ptr;                       /* Keep address for the ->last
                                           field in the next struct in
                                           the list                     */
    ptr->next = (struct fentry *)malloc( sizeof( struct fentry ) );
                                        /* Add a new struct to the list 
                                           and link list forwards       */
    ptr = ptr->next;                    /* Move to new struct           */
    ptr->last = holder;                 /* Link the list backwards      */
    ptr->next = 0l;                     /* Put stop value at end of list*/
    *ptr->fname = 0;                    /* Zap the filename just in case*/
    error = Fsnext();                   /* Any more entries in directory*/
    }

error = Fsfirst( "\\*.ACX", 0x3f );     /* Now for the ACXs             */
while((!error)&&(file_count < 20 * resolution ))        
    {                                   /* Exactly the same again       */
    file_count++;
    strcpy( ptr->fname, newdta.fname );
    expand( ptr->fname );
    holder = ptr;
    ptr->next = (struct fentry *)malloc( sizeof( struct fentry ) );
    ptr = ptr->next;
    ptr->last = holder;
    ptr->next = 0l;
    *ptr->fname = 0;
    error = Fsnext();
    }
}

/*--------------------------------------------------------------------------
  Display the filenames on the screen
--------------------------------------------------------------------------*/
show_filenames()
{
struct fentry *ptr;                     /* Local pointer to list        */
int count = 0;

ptr = &start;                           /* Initialise pointer to start  */
gotoxy( 1, 0 );                         /* Next line                    */
normal_text();                          /* Black text on white          */
Cconws( ptr->fname );                   /* Print the filename           */
while( ptr->next != 0l )                /* while not at end of list     */
    {
    ptr = ptr->next;                    /* advance                      */
    count++;                            /* keep count                   */
    gotoxy( count/resolution + 1, (count % resolution) * 20 );
                                        /* position cursor              */
    Cconws( ptr->fname );               /* print filename               */
    }
}

/*--------------------------------------------------------------------------
  Pad the filename with spaces
--------------------------------------------------------------------------*/
expand( filename )
char *filename;
{
char count;

count = strlen( filename );             /* Add spaces to the end of the */
while( count < 20 )                     /* filename until it is 20      */
    *(filename + count++) = 32;         /* characters long to keep the  */
*(filename + count) = 0;                /* display pretty when it is    */
}                                       /* printed white on black       */

/*--------------------------------------------------------------------------
  Take care of the keystrokes
--------------------------------------------------------------------------*/
interact()
{
struct fentry *ptr;                     /* Local pointer for the list   */
char temp[20];
char count = 0;
union   {                               /* Union used to split up the   */
        long whole;                     /* high and low words of the    */
        struct  {                       /* long returned by Bconin()    */
                int highword;
                int lowword;
                }split;
        } key;

ptr = &start;                           /* Initialise pointer to start  */

gotoxy( 1, 0 );                         /* Beginning of display         */
inverted_text();
Cconws( ptr->fname );                   /* Put cursor over first file   */
normal_text();

/*--------------------------------------------------------------------------
   The Bconin() call returns a long, but the switch statement can only 
   handle an int so it is necessary to go through a few gyrations to
   make it work
--------------------------------------------------------------------------*/
while( key.split.lowword != 13 )        /* Return finishes it           */
    {
    key.whole = Bconin( 2 );            /* Get the keytroke             */
    if( key.split.lowword != 0 )
        switch( key.split.lowword )
            {
            case '+':                   /* Switch accessory on          */
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                inverted_text();
                strcpy( from, "\\" );
                strcat( from, ptr->fname );
                strcpy( to, "\\" );
                strcat( to, ptr->fname );   /* Build a new filename */
                *index( to, '.' ) = 0;      /* with ACC extension   */
                strcat( to, ".ACC" );
                if( !Frename( 0, from, to ))
                    strcpy( ptr->fname, to + 1 );
                /* If the rename doesn't work don't
                change the name on the screen*/
                expand( ptr->fname );
                Cconws( ptr->fname );
                normal_text();
                break;
            case '-':               /* Switch accessory off         */
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                inverted_text();
                strcpy( from, "\\" );
                strcat( from, ptr->fname );
                strcpy( to, "\\" );
                strcat( to, ptr->fname );
                *index( to, '.' ) = 0;
                strcat( to, ".ACX" );
                if( !Frename( 0, from, to ))
                    strcpy( ptr->fname, to + 1 );
                expand( ptr->fname );
                Cconws( ptr->fname );
                normal_text();
                break;
            case 27:    
                ptr = &start;       /* Clear all accessories        */
                count = 0;
                while( ptr->next != 0l )    /* For each filename    */
                    {                       /* in turn              */
                    gotoxy( count/resolution + 1, (count % resolution) * 20 );
                    inverted_text();
                    strcpy( from, "\\" );
                    strcat( from, ptr->fname );
                    strcpy( to, "\\" );
                    strcat( to, ptr->fname );
                    *index( to, '.' ) = 0;
                    strcat( to, ".ACX" );   /* Try to rename it ACX */
                    if( !Frename( 0, from, to ))
                        strcpy( ptr->fname, to + 1);
                    expand( ptr->fname );
                    Cconws( ptr->fname );
                    normal_text();
                    gotoxy( count/resolution + 1, (count % resolution) * 20 );
                    Cconws( ptr->fname );
                    ptr = ptr->next;
                    count++;
                    }
                count = 0;          /* Put cursor at beginning again*/
                ptr = &start;
                inverted_text();
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                Cconws( ptr->fname );
                normal_text();
                break;
            }
    else
        switch( key.split.highword )
            {
            case 0x4d:      /* Right arrow */
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                                    /* Position cursor              */
                normal_text();
                Cconws( ptr->fname );
                                    /* Erase old cursor             */
                inverted_text();
                if( count < file_count - 1 )    /* Keep the cursor  */
                    {                           /* inside the list  */
                    count++;
                    ptr = ptr->next;        /* Advance through list */
                    }
                else
                    {
                    count = 0;              /* End of list - go back*/
                    ptr = &start;           /* to the beginning     */
                    }
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                                    /* Position cursor              */
                Cconws( ptr->fname );
                                    /* Highlight new filename       */
                normal_text();
                break;
            case 0x4b:              /* Last filename                */
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                normal_text();
                Cconws( ptr->fname );
                inverted_text();
                if( count > 0 )
                    {
                    count--;
                    ptr = ptr->last;    /* Going backwards this time*/
                    }
                gotoxy( count/resolution + 1, (count % resolution) * 20 );
                Cconws( ptr->fname );
                normal_text();
                break;
            }
    }
}
/*--------------------------------------------------------------------------
  Release memory reserved in program
--------------------------------------------------------------------------*/
free_memory()
{
struct fentry *ptr;

ptr = &start;

while( ptr->next != 0l )            /* Proceed to the end of the list   */
    ptr = ptr->next;

while( ptr->last != 0l )            /* Then go back to the beginning    */
    {                               /* releasing the blocks as we go    */
    ptr = ptr->last;
    free( ptr->next );
    }
}

/*--------------------------------------------------------------------------
                Screen handling 
--------------------------------------------------------------------------*/
gotoxy( xpos, ypos )                /* Position VT52 cursor         */
char xpos, ypos;
{
Bconout( 2, 27 );
Bconout( 2, 'Y' );
Bconout( 2, 32 + xpos );
Bconout( 2, 32 + ypos );
}

clrscr()                            /* Clear the screen             */
{
Bconout( 2, 27 );
Bconout( 2, 'E' );
}

clreol()                            /* Clear to end of line         */
{
Bconout( 2, 27 );
Bconout( 2, 'l' );
}

inverted_text()                     /* White print on black         */
{
Bconout( 2, 27 );
Bconout( 2, 'p' );
}

normal_text()                       /* Black text on white          */
{
Bconout( 2, 27 );
Bconout( 2, 'q' );
}

auto_overflow_off()                 /* Switch off automatic overflow*/
{                                   /* which normally occurs when   */
Bconout( 2, 27 );                   /* the end of the screen is     */
Bconout( 2, 'w' );                  /* reached - this stops the     */
}                                   /* screen scrolling             */

auto_overflow_on()                  /* Restore setting to normal    */
{
Bconout( 2, 27 );
Bconout( 2, 'v' );
}

