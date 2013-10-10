/* EZ-Score Plus 1.1 printer configuration file creator
 *
 * by Craig Dickson / Tom Bajoras
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   18 March 1988
 * Last modified (by Craig): 30 March 1988
 * Last modified (by Tom): 22 August 1988
 */

#include <tos.h>
#include <ctype.h>
#include <misc.h>

#define PROMPTLINE   23
#define PROMPTCOL    5
#define CR 0x0d
#define NIL -1
#define ERRLINE   24

#define CNFSIZE   128


char  config[CNFSIZE], name[40], pathbuf[60];
int   *configw;

int   pinits[20], flinef[20], ilinef[20], nlinef[20], rdlinef[20],
      ddgraph[20], dsgraph[20];

typedef struct {
   int   row;
   int   col;
} COORDINATE;

int   titlines = 2;

char  *titles[] = {
   "EZ-Score Plus v1.1 Printer Configuration Creator, v1.1",
   "Copyright 1988 Hybrid Arts, Inc."
};

COORDINATE  titcoords[] = {
   { 0,15 },
   { 1,23 }
};

int   mainlines = 13;

char  *mainmenu[] = {
   "Menu",
   "1. Change printer name:",
   "2. Change printer type:",
   "3. Change lines per page:",
   "4. Change dot columns per line:",
   "5. Change initialization string:",
   "6. Change set-linefeed string:",
   "7. Change restore-linefeed string:",
   "8. Change standard graphics string:",
   "9. Change rough mode graphics string:",
   "10. Load configuration",
   "11. Save configuration",
   "12. Quit program"
};

COORDINATE  maincoords[] = {
   {  4,37 },
   {  7, 6 },
   {  8, 6 },
   {  9, 6 },
   { 10, 6 },
   { 12, 6 },
   { 13, 6 },
   { 14, 6 },
   { 15, 6 },
   { 16, 6 },
   { 18, 5 },
   { 19, 5 },
   { 20, 5 }
};

int   mc_lines = 9;

char  *mc_text[] = {
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "xxxxxx",
   "xxxxxx",
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
};

COORDINATE  mc_coords[] = {
   {  7,45 },
   {  8,45 },
   {  9,45 },
   { 10,45 },
   { 12,45 },
   { 13,45 },
   { 14,45 },
   { 15,45 },
   { 16,45 }
};

char  *prname, *prtype;
int   typelines = 7;

char  *types[] = {
   "What type of printer are we configuring for?",
   "1. 9-pin 216 lpi standard carriage",
   "2. 9-pin 216 lpi wide carriage    ",
   "3. 9-pin 144 lpi standard carriage",
   "4. 9-pin 144 lpi wide carriage    ",
   "5. 24-pin 180 lpi standard carriage",
   "6. 24-pin 180 lpi wide carriage    "
};

COORDINATE  typecoords[] = {
   {  4,17 },
   {  7,10 },
   {  8,10 },
   { 10,10 },
   { 11,10 },
   { 13,10 },
   { 14,10 }
};

int   n9_216normal[] = {      /* msp-10 */
         9, 216, 120,
         24, 1, 22,
         192, 2196, 64, 896,
         2340,
         96, 2292, 64, 896,
         0
      };

int   n9_216wide[] = {        /* msp-15 */
         9, 216, 204,
         24, 1, 22,
         192, 2196, 64, 1568,
         2340,
         96, 2292, 64, 1568,
         0
      };

char  *s9216sname = "Citizen MSP-10",
      *s9216wname = "Citizen MSP-15",
      *s9216pinits = "\002\030\030",
      *s9216flinef = "\002\033\063",
      *s9216ilinef = "\002\033\063",
      *s9216nlinef = "\002\033\063",
      *s9216rdlinef = "\002\033\062",
      *s9216ddgraph = "\002\033\114",
      *s9216dsgraph = "\002\033\131";

int   n9_144normal[] = {      /* smm804 */
         9, 144, 120,
         24, 2, 22,
         192, 2196, 64, 896,
         2340,
         96, 2292, 64, 896,
         0
      };

int   n9_144wide[] = {        /* fictitious wide-carriage smm804 */
         9, 144, 204,
         24, 2, 22,
         192, 2196, 64, 1568,
         2340,
         96, 2292, 64, 1568,
         0
      };

char  *s9144sname = "Atari SMM804",
      *s9144wname = " ",
      *s9144pinits = "\002\030\030",
      *s9144flinef = "\002\033\063",
      *s9144ilinef = "\002\033\063",
      *s9144nlinef = "\002\033\063",
      *s9144rdlinef = "\002\033\062",
      *s9144ddgraph = "\002\033\114",
      *s9144dsgraph = "\002\033\114";

int   n24_180normal[] = {     /* nec p6 */
         24, 180, 120,
         29, 29, 29,
         192, 2196, 64, 896,
         2340,
         96, 2292, 64, 896,
         0
      };

int   n24_180wide[] = {       /* nec p7 */
         24, 180, 204,
         29, 29, 29,
         192, 2196, 64, 1568,
         2340,
         96, 2292, 64, 1568,
         0
      };

char  *s24180sname = "NEC P6",
      *s24180wname = "NEC P7",
      *s24180pinits = "\002\030\030",
      *s24180flinef = "\002\033\063",
      *s24180ilinef = "\002\033\063",
      *s24180nlinef = "\002\033\063",
      *s24180rdlinef = "\002\033\062",
      *s24180ddgraph = "\003\033\052\041",
      *s24180dsgraph = "\003\033\052\041";

int   *printers[] = { n9_216normal, n9_216wide, n9_144normal, n9_144wide,
         n24_180normal, n24_180wide };

char  *the_names[] = { s9216sname, s9216wname, s9144sname, s9144wname,
         s24180sname, s24180wname };

char  *the_pinits[] = { s9216pinits, s9216pinits, s9144pinits, s9144pinits,
         s24180pinits, s24180pinits };

char  *the_flinef[] = { s9216flinef, s9216flinef, s9144flinef, s9144flinef,
         s24180flinef, s24180flinef };

char  *the_ilinef[] = { s9216ilinef, s9216ilinef, s9144ilinef, s9144ilinef,
         s24180ilinef, s24180ilinef };

char  *the_nlinef[] = { s9216nlinef, s9216nlinef, s9144nlinef, s9144nlinef,
         s24180nlinef, s24180nlinef };

char  *the_rdlinef[] = { s9216rdlinef, s9216rdlinef, s9144rdlinef,
         s9144rdlinef, s24180rdlinef, s24180rdlinef };

char  *the_ddgraph[] = { s9216ddgraph, s9216ddgraph, s9144ddgraph,
         s9144ddgraph, s24180ddgraph, s24180ddgraph };

char  *the_dsgraph[] = { s9216dsgraph, s9216dsgraph, s9144dsgraph,
         s9144dsgraph, s24180dsgraph, s24180dsgraph };

char  *sp60 = "                                                            ";

extern   counter(), ft_cblink(), init_assembly(), interrupt(), save_a4(),
         the_rte();


main( argc, argv )
int argc;
char *argv[];
{
   register int   choice, i;
   char  buf[80];

   init();
   i = FALSE;
   if (argc > 1) {
      strcpy( pathbuf, argv[1] );
      i = load_config();
   }
   if (i != TRUE)
      setup_type( TRUE );
   do {
      update_dstrings();
      display( mainlines, mainmenu, maincoords );
      display( mc_lines, mc_text, mc_coords );
      choice = get_choice( 12 );
      switch (choice) {
         case 1:
            get_string( buf, mc_coords[0].row, mc_coords[0].col, 39, 'X' );
            if (buf[0]) {
               strcpy( name, buf );
               prname = name;
            }
            break;
         case 2:
            clearlines( mainlines, maincoords );
            setup_type( FALSE );
            break;
         case 3:
            i = get_input( buf, mc_coords[2].row, mc_coords[2].col, 5, 32767 );
            if (i >= 2000) {
               configw[7] = i - 144;
               configw[10] = i;
               configw[12] = i - 48;
            }
            break;
         case 4:
            i = get_input( buf, mc_coords[3].row, mc_coords[3].col, 4, 3264 );
            if (i >= 640) {
               choice = (configw[2] <= 120);
               configw[2] = (i & 0x07)? (i >> 3) + 1: i >> 3;
               configw[9] = configw[14] = (configw[2] << 3) - 64;
               if ((configw[2] <= 120) ^ choice)
                  decide_type();
            }
            break;
         case 5:
            edit_string( pinits, mc_coords[4].row, mc_coords[4].col, 25 );
            break;
         case 6:
            edit_string( flinef, mc_coords[5].row, mc_coords[5].col, 25 );
            break;
         case 7:
            edit_string( rdlinef, mc_coords[6].row, mc_coords[6].col, 25 );
            break;
         case 8:
            edit_string( ddgraph, mc_coords[7].row, mc_coords[7].col, 25 );
            break;
         case 9:
            edit_string( dsgraph, mc_coords[8].row, mc_coords[8].col, 25 );
            break;
         case 10:
            i = load_a_config();
            if (i)
               clearlines( mainlines, maincoords );
            break;
         case 11:
            i = save_a_config();
            if (i)
               clearlines( mainlines, maincoords );
      }
   } while (choice - 12);
   Xbtimer( 0, 0, 0, 0L );
   Bconout( 2, 27 );
   Bconout( 2, 'E' );
   Bconout( 2, 27 );
   Bconout( 2, 'e' );
}


init()
{
   long  addr;

   configw = (int*)config;
   if (ft_init( &addr )) {
      Bconout( 2, 27 );
      Bconout( 2, 'f' );
      ft_clear();
      display( titlines, titles, titcoords );
      Supexec( init_assembly );
      Xbtimer( 0, 7, 0, interrupt );
      pathbuf[0] = '\0';
   } else
      exit( -1 );
}


asm {
init_assembly:
   lea      save_a4(PC),A0
   move.l   A4,(A0)
   lea      the_rte(PC),A0
   move.l   A0,0x60
   lea      counter(PC),A0
   move     #24,(A0)
   rts

save_a4:
   dc.l  0

counter:
   dc.w  0

interrupt:
   movem.l  D0-D3/A0/A4,-(A7)
   lea      counter(PC),A0
   subi.w   #1,(A0)
   tst.w    (A0)
   bne.s    forgetit
   move.w   #24,(A0)
   movea.l  save_a4(PC),A4
   jsr      ft_cblink(PC)
forgetit:
   movem.l  (A7)+,D0-D3/A0/A4
   bclr     #5,0xFFFA0F
the_rte:
   rte
}


update_dstrings()
{
   char  *itoa();

   strcpy( mc_text[0], prname );
   strcpy( mc_text[1], prtype );
   itoa( configw[10], mc_text[2], 0 );
   itoa( configw[2] << 3, mc_text[3], 0 );
   btos( pinits, mc_text[4] );
   btos( flinef, mc_text[5] );
   btos( rdlinef, mc_text[6] );
   btos( ddgraph, mc_text[7] );
   btos( dsgraph, mc_text[8] );
}


char *itoa( number, string, digits )
register int number;
register char *string;
int digits;
{
   register int   i, j, k;
   char  buf[20];

   i = 20;
   do {
      buf[--i] = number % 10 + 48;
      number /= 10;
   } while (number);
   if (j = digits - 20 + i)
      for (k = 0; k < j; k++)
         *string++ = '\040';
   j = 20 - i;
   for (k = 0; k < j; k++)
      *string++ = buf[i++];
   *string = '\0';
   return string;
}


btos( iarray, string )
register int *iarray;
register char *string;
{
   register int   length;
   char  *itoa();

   for (length = *iarray++; length; length--) {
      string = itoa( *iarray++, string, 0 );
      *string++ = '\040';
   }
   *string = '\0';
}


display( numl, text, coord )
register int numl;
register char **text;
register COORDINATE *coord;
{
   register int   i;

   for (i = 0; i < numl; i++)
      ft_text( text[i], coord[i].row, coord[i].col );
}


setup_type( flag )
register int flag;
{
   register int   i, *printer;
   register char  num, *string;
   char  *copy_string();

   display( typelines, types, typecoords );
   do {
      num = get_choice( 6 );
   } while (!num && flag);
   if (num) {
      prtype = &types[num][3];
      num--;
      prname = the_names[num];
      printer = printers[num];
      for (i = 0; i < 16; i++)
         configw[i] = printer[i];
      copy_string( the_pinits[num], pinits );
      copy_string( the_flinef[num], flinef );
      copy_string( the_ilinef[num], ilinef );
      copy_string( the_nlinef[num], nlinef );
      copy_string( the_rdlinef[num], rdlinef );
      copy_string( the_ddgraph[num], ddgraph );
      copy_string( the_dsgraph[num], dsgraph );
   }
   clearlines( typelines, typecoords );
}


get_choice( limit )
register int limit;
{
   register int   choice;
   char  buf[4];

   ft_text( "Enter choice:", PROMPTLINE, PROMPTCOL );
   choice = get_input( buf, PROMPTLINE, 19, 2, limit );
   ft_char( 32, PROMPTLINE, 19 );
   ft_char( 32, PROMPTLINE, 20 );
   clearline( ERRLINE );
   return choice;
}


get_input( buf, row, col, len, limit )
register char *buf;
int row, col;
register int len;
register int limit;
{
   register long   choice;
   long  atol();

   do {
      get_string( buf, row, col, len, '9' );
      choice = atol( buf );
   } while (choice > limit);
   return ((int)choice);
}


get_string( buf, row, col, len, type )
register char *buf;
int row, col;
register int len;
register char type;
{
   register int   count;
   register char  ch;

   ft_text( &sp60[60-len], row, col );
   ft_cbena();
   ft_cbloc( row, col );
   count = 0;
   do {
      ch = (char)Bconin( CON );
      if (is_valid( ch, type ) && count < len) {
         buf[count++] = ch;
         ft_cchar( ch );
      } else if (ch == '\010' && count) {
         count--;
         ft_cbloc( ft_qcypos(), ft_qcxpos() - 1 );
         ft_cchar( 32 );
         ft_cbloc( ft_qcypos(), ft_qcxpos() - 1 );
      } else if (ch == CR)
         buf[count] = '\0';
   } while (ch != CR);
   ft_cbdis();
   ft_text( &sp60[60-len], row, col );
}


is_valid( ch, type )
register char ch;
register char type;
{
   switch (type) {
      case '0': return (isdigit( ch ) || ch == ' ');
      case '9': return isdigit( ch );
      case 'A': return isupper( ch );
      case 'P': return (isprint( ch ) && ch != ' ' && ch != '*' && ch != '?');
      case 'X': return isprint( ch );
      case 'a': return isalpha( ch );
      case 'n': return isalnum( ch );
   }
}


long atol( str )
register char *str;
{
   register long  val;
   register char  ch;

   val = 0L;
   while (*str) {
      ch = *str++;
      if (isdigit( ch )) {
         val *= 10;
         val += ch & 0xF;
      } else
         break;
   }
   return val;
}


char *copy_string( source, dest )
register char *source;
register int *dest;
{
   register int   length;

   for (length = *source + 1; length; length--)
      *dest++ = *source++;
   return source;
}


clearlines( nlines, coord )
register int nlines;
register COORDINATE *coord;
{
   register int   i;

   for (i = 0; i < nlines; i++)
      clearline( coord[i].row );
}


edit_string( bbuf, row, col, len )
register int *bbuf;
register int row, col;
int len;
{
   register int   count, i;
   long  atol();
   char  tbuf[80];

   get_string( tbuf, row, col, len, '0' );
   count = i = 0;
   do {
      while (tbuf[i] && !isdigit( tbuf[i] ))
         i++;
      if (tbuf[i]) {
         bbuf[++count] = (int)(atol( &tbuf[i] ) & 0xFF);
         while (tbuf[i] && isdigit( tbuf[i] ))
            i++;
      }
   } while (tbuf[i]);
   if (count)
      bbuf[0] = count;
}


load_a_config()
{
   register int   ret;

   clearline( PROMPTLINE );
   ft_text( "Load file:", PROMPTLINE, PROMPTCOL );
   get_string( pathbuf, PROMPTLINE, 16, 58, 'P' );
   if (pathbuf[0])
      ret = load_config();
   clearline( PROMPTLINE );
   if (ret == NIL)
      ft_text( "Checksum error in file!", ERRLINE, 5 );
   else if (!ret)
      ft_text( "Error reading file!", ERRLINE, 5 );
   return (ret == TRUE);
}


load_config()
{
   register int   handle, i, *ibuf;
   register long  read;
   register char  cksum, *string;
   char  buf[128], *copy_string();

   handle = Fopen( pathbuf, 0 );
   if (handle >= 0) {
      read = Fread( handle, 128L, buf );
      Fclose( handle );
      if (read == 128L) {
         for (i = cksum = 0; i < 127; i++)
            cksum ^= buf[i];
         if (cksum == buf[127]) {
            ibuf = (int*)buf;
            for (i = 0; i < 16; i++)
               configw[i] = ibuf[i];
            string = copy_string( &buf[32], pinits );
            (*string)--;
            string = copy_string( string, flinef );
            (*(++string))--;
            string = copy_string( string, ilinef );
            (*(++string))--;
            string = copy_string( string, nlinef );
            string = copy_string( ++string, rdlinef );
            string = copy_string( string, ddgraph );
            string = copy_string( string, dsgraph );
            strcpy( name, string );
            prname = name;
            decide_type();
            return TRUE;
         } else
            return NIL;
      }
   }
   return FALSE;
}


decide_type()
{
   if (configw[1] == 216)
      prtype = (configw[2] <= 120)? &types[1][3]: &types[2][3];
   else if (configw[1] == 144)
      prtype = (configw[2] <= 120)? &types[3][3]: &types[4][3];
   else if (configw[1] == 180)
      prtype = (configw[2] <= 120)? &types[5][3]: &types[6][3];
   else
      prtype = &sp60[59];
}


save_a_config()
{
   register int   ret;

   clearline( PROMPTLINE );
   ft_text( "Save file:", PROMPTLINE, PROMPTCOL );
   get_string( pathbuf, PROMPTLINE, 16, 58, 'P' );
   if (pathbuf[0])
      ret = save_config();
   clearline( PROMPTLINE );
   if (!ret)
      ft_text( "Error writing file!", ERRLINE, 5 );
   return ret;
}


save_config()
{
   register int   handle, i;
   register long  written;
   register char  cksum, *string, *string2;
   char  *make_string();

   handle = Fcreate( pathbuf, 0 );
   if (handle >= 0) {
      string = make_string( pinits, &config[32] );
      string2 = make_string( flinef, string );
      (*string)++;
      *string2 = (configw[0] == 24 || configw[1] == 216)? 24: 16;
      string = make_string( ilinef, ++string2 );
      (*string2)++;
      *string = (configw[0] == 24)? 24: 1;
      string2 = make_string( nlinef, ++string );
      (*string)++;
      *string2 = (configw[0] == 24)? 24: ((configw[1] == 216)? 22: 14);
      string = make_string( rdlinef, ++string2 );
      string2 = make_string( ddgraph, string );
      string = make_string( dsgraph, string2 );
      strcpy( string, prname );
      for (i = cksum = 0; i < 127; i++)
         cksum ^= config[i];
      config[127] = cksum;
      written = Fwrite( handle, 128L, config );
      Fclose( handle );
      if (written == 128L)
         return TRUE;
   }
   return FALSE;
}


char *make_string( source, dest )
register int *source;
register char *dest;
{
   register int   length;

   for (length = *source + 1; length; length--)
      *dest++ = (char)(*source++);
   return dest;
}

clearline(y)
int y;
{
	static char blankline[80]= "\
                                                                              ";
	ft_text( blankline, y, 0 );
}

/* EOF */
