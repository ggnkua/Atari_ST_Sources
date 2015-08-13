/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*              ply_io.c
                        By Jeff koftinoff
**              v1.0                                                            
                        started: May 22/88
**
**              play program's I/O functions:
**
**              put_text( int x,y,col,mode, char *text )
**                      put text on screen.
**                      mode=true for inverse on bw.
**
**              put_stat( char *lng, char *shrt )
**                      lng=long status, shrt=short status.
**                      put string on to current display device via midi
**
**              midi_thru()
**                      examine next msg and return the proper command code
**                      if appropriate.
**
**              get_kybd()
**                      examine scan code and return a proper command code
**                      if appropriate.
**
**
**              light( unsigned int new_stat )
**                      set the entire printer port lighting status.
**
*/

#include "ply_defs.h"

#include <ctype.h>

#define DEBUG_IO 1

extern  Command cur_command;
extern  CFG cfg;
extern  SET set;

extern  int     rez;
extern  int cur_thru;
extern  int has_text_on;
extern 	int cur_song;

extern 	int playing;

unsigned short
                l_stat;
                
static
        char
                l_keys[8] = {
            36, 38, 40, 41, 43, 45, 47, 48
        };
        
static  Boolean d50(char*);
static	Boolean mt32(char*);
static	Boolean jx8p(char*);
static	Boolean dx7(char*);
static	Boolean juno1(char*);
static	Boolean u20(char*);
static	Boolean ctrl_pg1(unsigned char*);
static	Boolean ctrl_pg125(unsigned char*);
static	Boolean ctrl_port(unsigned char*);
static  Boolean ctrl_hold(unsigned char*);
static  Boolean ctrl_pg(unsigned char*);



void select_left_song( void )
{
	ushort sng = cur_song-22;
	
	if( sng<set.num_songs )
	{
		cur_command.type=ComSelect;
		cur_command.value=sng;
	}
	else
	{
		cur_command.type=ComSelect;
		cur_command.value=set.num_songs-1;
	}
}

void select_right_song( void )
{
	ushort sng = cur_song+22;
	
	if( sng<set.num_songs )
	{
		cur_command.type=ComSelect;
		cur_command.value=sng;
	}
	else
	{
		cur_command.type=ComSelect;
		cur_command.value=0;
	}
}


Boolean put_text( int x, int y, int col, int mode, char *text )
{

        if( rez!=2 ) {
                t_char_col( col );
                t_back_col( 0 );
                t_goto_xy( 0, y );
                clr_line();
        }
        if( rez==2 ) {
                if( x==-1 ) {
                        t_rev_off();
                        t_goto_xy( 0, y );
                        clr_line();
                }

                if( mode )
                        t_rev_on();
                else
                        t_rev_off();            
        }

        if( x==-1 ) {
                t_goto_xy( 40-(strlen(text)/2), y );
        }
        else
                t_goto_xy( x,y);
        cputs( text );
        return( OK );
}


void put_stat( char *lng, char *shrt )
{
    int line;
    
    t_save_curs();

    if( rez==1 )
       t_char_col( STAT_COLOR );
    if( rez==2 ) 
    {
                t_rev_off();
    }
                
/* erase the current status line */
    
    if( has_text_on )
    	line=0;
    else
    	line=1;
	
    t_goto_xy( 0, line );
    clr_line();

    t_goto_xy( (40-strlen(lng)/2), line );   

    cputs( lng );                           /* Center the text */
    
        if( shrt!=NULL )
                ext_display( lng, shrt );

    t_rest_curs();
}

void ext_display( char *lng, char *shrt )
{
char s[100];

	if( lng==NULL || shrt==NULL )
		return;
			
        strcpy( s, lng );
        if( strlen( s )<20 )
                strcat( s, "                    " );

        switch( cfg.disp_type ) {
                case 0:         /* no display   */
                        return;
                case 1:         /* D-50                 */
                        d50( s );
                        break;
                case 2:         /* MT-32                */
                        mt32( shrt );
                        break;
                case 3:         /* D-10                 */
                        mt32( s );
                        break;
                case 4:         /* JX-8P                */
                        jx8p( shrt );
                        break;
                case 5:         /* DX-7                 */
                        dx7( shrt );
                        break;
                case 6:         /* alpha juno 1 */
                        juno1( shrt );
                        break;
                case 7:			/* u-20, U-220	*/
               		u20( shrt );
               		break;
        };
        
}

static Boolean d50( char *text )
{
	int c, i, d;
	int sum;
	short len=strlen(text);

        if( cfg.disp_chan<0 || cfg.disp_chan>15 ) return( FAILED );

        midi_out( 0xf0 );   midi_out( 0x41 );
        midi_out( cfg.disp_chan );
        midi_out( 0x14 );   midi_out( 0x12 );
        midi_out( 0x00 );   midi_out( 0x03 );   midi_out( 0x00 ); sum=3;
            
	//cputs( "D-50=" );
	//cputs( text );

        for( i=0; i<18; i++ ) {
		c=text[i]&0x7f;
		d=0;

                if( i>=len ) 
		{
                        d=0;
                }
		
		if( (c>='A') && (c<='Z') )
		{
			d=c-'A'+1;
		}
		
		if( c>='a' && c<='z' )
		{
			d=c-'a'+1+26;
		}
		
		if( c=='0' )
		{
			d=62;
		}

		if( c>='1' && c<='9' )
		{
			d=c-'0' + 52;
		}
 		
		if( c=='-' || c=='?' ) 
		{	
			d=63;
		}

		midi_out( d );
		sum+=d;
        }
            
        midi_out( (128-sum)&0x7f );
        midi_out( 0xf7 );
        return( OK );
           
}

static Boolean mt32( char *text )
{
char i, sum, l;

	
        if( cfg.disp_chan<0 || cfg.disp_chan>32 ) return( FAILED );
        
        midi_out( 0xf0 );       midi_out( 0x41 );       
        midi_out( cfg.disp_chan );
        midi_out( 0x16 );               /* MT-32, D10           */
        midi_out( 0x12 );               /* data set                     */
        midi_out( 0x20 );               /* display address      */
        midi_out( 0x00 );
        midi_out( 0x00 );
        sum=0x20;

        l=strlen( text );
        
        for( i=0; i<32; i++ ) {
                if( i<l ) {
                        midi_out( text[i] );
                        sum+=text[i];
                }
                else {
                        midi_out( ' ' );
                        sum+=' ';
                }
        }

        midi_out( (128-sum)&0x7f );
        midi_out( 0xf7 );

        return( OK );
}

static Boolean jx8p( char *text )
{
unsigned int i;

        if( cfg.disp_chan<0 || cfg.disp_chan>15 ) return( FAILED);
        midi_out( 0xf0 );       midi_out( 0x41 );
        midi_out( 0x36 );
        midi_out( cfg.disp_chan );
        midi_out( 0x21 );       midi_out( 0x20 );
        midi_out( 0x01 );
        for( i=0; i<10; i++ ) {
                midi_out( i );
                if( i>=strlen( text ) ) midi_out( ' ' );
                        else midi_out( text[i] );
        }
        midi_out( 0xf7 );
        return( OK );

}

static Boolean dx7( char *text )
{
register unsigned int i;
register unsigned int len;
register unsigned int c;

        if( cfg.disp_chan<0 || cfg.disp_chan>15 ) return FALSE;
        
        len=strlen( text );

        for( i=0; i<10; i++ ) {
                if( i<len )
                        c=text[i];
                else
                        c=' ';
                
                midi_out( 0xf0 );
                midi_out( 0x43 );
                midi_out( 0x10+cfg.disp_chan );
                midi_out( 0x01 );
                midi_out( 0x11+i );
                midi_out( c );
                midi_out( 0xf7 );
        }
	return TRUE;        
}

static Boolean juno1( char *text )
{

	return FALSE;
}

static Boolean u20( char * text )
{
char i, sum, l;

	if( cfg.disp_chan<0 || cfg.disp_chan>32 ) return( FAILED );
        
        midi_out( 0xf0 );       midi_out( 0x41 );       
        midi_out( cfg.disp_chan );
        midi_out( 0x2b );               /* u-20, u-220         	 */
        midi_out( 0x12 );               /* data set              */
        
        midi_out( 0x00 );               /* Keyboard Patch temp   */
        midi_out( 0x01 );
        midi_out( 0x00 );
        sum=0x01;

        l=strlen( text );

#define MIDI_OUTSUM( x ) 	midi_out( x ); sum+=x
		        
        for( i=0; i<12; i++ ) {
        unsigned int ch;
        	ch=text[i];
        	
        	if( i>=l ) ch=' ';
        	else ch=text[i];
        	
        	MIDI_OUTSUM( text[i]&0x0f );
        	MIDI_OUTSUM( (text[i]>>4)&0x0f );
        }

        midi_out( (128-sum)&0x7f );
        midi_out( 0xf7 );
        
        
        
        midi_out( 0xf0 );       midi_out( 0x41 );       
        midi_out( cfg.disp_chan );
        midi_out( 0x2b );               /* u-20, u-220         	 */
        midi_out( 0x12 );               /* data set              */
        
        midi_out( 0x00 );               /* Sound Patch temp   */
        midi_out( 0x06 );
        midi_out( 0x00 );
        sum=0x06;

        l=strlen( text );
        
        for( i=0; i<12; i++ ) {
        unsigned int ch;
        	ch=text[i];
        	
        	if( i>=l ) ch=' ';
        	else ch=text[i];
        	
        	MIDI_OUTSUM( text[i]&0x0f );
        	MIDI_OUTSUM( (text[i]>>4)&0x0f );
        }

        midi_out( (128-sum)&0x7f );
        midi_out( 0xf7 );

        return( OK );
#undef MIDI_OUTSUM
}


Boolean get_action()
{
        cur_command.type=ComNone;
        if( get_kybd() ) return( TRUE );
        if( midi_thru() ) return( TRUE );
	if( cfg.use_joy )
	        if( joystick_cmd() ) return( TRUE ); 
        return( FALSE );

}

Boolean joystick_cmd()
{
        JoyStickState j1;
        static CommandType last_cmd=ComNone;
        CommandType cur_cmd;
        Boolean flag=FALSE;
	static Boolean first_time=TRUE;
	static int lr_mode=0;

        j1=JoyGet(1);   /* read joystick 1 */
	
	
        cur_cmd=ComNone;

	if( cfg.use_joy==2 )	// if 2, then look at inverted FIRE button only
				// if all other inputs are 0
	{
		if( !j1.fire )
	        {
	                cur_cmd=ComPlay;
			if( first_time==TRUE )
			{
				// ignore the fire button unless it changes,
				// so it doesn't start playing immediately
				// when there is no footswitch plugged in.
				
				last_cmd=ComPlay;
				first_time=FALSE;
				return FALSE;
			}
	        }
	}
	else
	{
	        if( j1.down )
       		{
			if( playing )
	       	        	cur_cmd=ComPause;
			else
			{
				if( lr_mode!=1 )
				{
					select_left_song();
					lr_mode=1;
					return OK;
				}
			}			
       	 	}

        	if( j1.up )
        	{
			if( playing )
	                	cur_cmd=ComUnhang;
			else
			{
				if( lr_mode!=2 )
				{
					select_right_song();
					lr_mode=2;
					return OK;
				}
			}
        	}
        	if( j1.left )
        	{
			lr_mode=0;
                	cur_cmd=ComBackup;
	        }
        	if( j1.right )
	        {
			lr_mode=0;
	                cur_cmd=ComSkip;
	        }
	        if( j1.fire )
	        {
			lr_mode=0;
	                cur_cmd=ComPlay;
	        }
	}
	
	if( cur_cmd==ComNone )
	{
		lr_mode=0;
	}

        if( cur_cmd!=ComNone && cur_cmd!=last_cmd )
        {
             cur_command.type=cur_cmd;
             flag=TRUE;
        }
        last_cmd=cur_cmd;
        
	if( first_time==TRUE )
		first_time=FALSE;

        return flag;
}


Boolean midi_thru()
{
unsigned char buf[300];
unsigned int len;
Boolean stat;

        len= jk_msg_in( buf, 300 );
        if( len<2 ) return( FALSE );
        
        if( (*buf>(unsigned char)0xaf) && (*buf<(unsigned char)0xc0) )
                if( buf[1]>0x7a )
                        return( FALSE );    /* don't midi thru all notes off */

        stat=FALSE;

        if( len<4 && (*buf&0x0f)==cfg.ctrl_chan ) 
	{

                switch( cfg.ctrl_type ) {
                        case 1:
                                stat=ctrl_pg1( buf );
                                break;
                        case 2:
                                stat=ctrl_pg125( buf );
                                break;
                        case 3:
                                stat=ctrl_port( buf );
                                break;
                        case 4:
                                stat=ctrl_hold( buf );
                                break;
                        case 5:
                                stat=ctrl_pg( buf );
                                break;
                };
        }
        if( cfg.light_ch<16 && cfg.light_ch>=0 )
                if( *buf==(0x90+cfg.light_ch) )
                        light_midi( buf[1], buf[2] );

        if( cur_thru>=0 && cur_thru<16 &&
          len<4 )
                *buf=(*buf & 0xf0) | cur_thru;

        if( cur_thru!=-1 )
                Midiws( len-1, buf );

        return( stat ); 
}


static Boolean ctrl_pg1( register unsigned char *buf )
{
        if( (*buf&0xf0) == 0xc0 ) {
                if( buf[1]==0 ) {
                        cur_command.type=ComSkip;
                        return( OK );
                }
                if( buf[1]==1 ) {
                        cur_command.type=ComBackup;
                        return( OK );
                }
                if( buf[1]==2 ) {
                        cur_command.type=ComPlay;
                        return( OK );
                }
                if( buf[1]==3 ) {
                        cur_command.type=ComStop;
                        return( OK );
                }
        }

        return( FAILED );
}

static Boolean ctrl_pg125( register unsigned char *buf )
{

        if(  ((*buf++)&0xf0) == 0xc0 ) {
                if( *buf==124 ) 
		{
                        cur_command.type=ComSkip;
                        return( OK );
                }
                if( *buf==125 ) 
		{
                        cur_command.type=ComBackup;
                        return( OK );
                }
                if( *buf==126 ) 
		{
                        cur_command.type=ComPlay;
                        return( OK );
                }
                if( *buf==127 ) 
		{
                        cur_command.type=ComStop;
                        return( OK );
                }
        }
        return( FAILED );
}

static Boolean ctrl_port( register unsigned char *buf )
{
        if(  *buf&0xf0 ==0xb0 )
                if( buf[1]==65 )
                        if( buf[2]&0x40 ) 
			{
                                cur_command.type=ComPlay;
                                return( OK );
                        }
        return( FAILED );
}

static Boolean ctrl_hold( register unsigned char *buf )
{
        if( (*buf&0xf0) ==0xb0 )
                if( buf[1]==64 )
                        if( buf[2]&0x40 ) 
			{
                                cur_command.type=ComPlay;
                                return( OK );
                        }
        return( FAILED );
}

static Boolean ctrl_pg( register unsigned char *buf )
{
        if(  (*buf&0xf0) == 0xb0 )
                if( buf[1]==65 )
                        if( buf[2]&0x40 ) 
			{
                                cur_command.type=ComPlay;
                                return( OK );
                        }
        if(  ((*buf)&0xf0) == 0xc0 ) 
	{
		cur_command.type  = ComSelect;
		cur_command.value = buf[1];
		if( cur_command.value >= set.num_songs )
		{
			cur_command.type=ComNone;
			return FALSE;
		}
		return OK;
        }	

	return FALSE;
}

Boolean get_kybd()
{
register long key;
register unsigned char c,i;
extern char song_chars[];
static unsigned char digit1=0, digit2=0, digit3=0;

        if( !key_stat() ) return( FAILED );

        key=(long)getch();
        c=key&0x7f;

        
        if( man_light( key ) ) return( FAILED );

	if( c=='T' || c=='t' || c=='T'-'A' )
	{
		cur_command.type=ComTextSet;
		return OK;
	}

	if( c==',' )
	{
		cur_command.type=ComTempoDown;
		return OK;
	}

	if( c=='.' )
	{
		cur_command.type=ComTempoUp;
		return OK;
	}
        
        if( c=='A'-64 || c=='A' || c=='a' ) {
                cur_command.type=ComStop;
                return( OK );
        }

        if( c=='U'-64 || c=='U' || c=='u' ) {
                cur_command.type=ComUnhang;
                return( OK );
        }

        if( c=='P'-64 || c=='P' || c=='p' ) {
                cur_command.type=ComPause;
                return( OK );
        }

        if( c=='G'-64 ) {
                cur_command.type=ComExit;
                return( OK );
        }

        if( c=='L'-64 || c=='L' || c=='l') {
                cur_command.type=ComReload;
                return( OK );
        }

	if( c=='Z' || c=='z' || c=='Z'-64 )
	{
		extern void toggle_background();

		toggle_background();
		return FAILED;
	}
        
        if( c==' ' ) {
                cur_command.type=ComPlay;
                return( OK );
        }

        if( key==K_UP ) {
                cur_command.type=ComBackup;
                return( OK );
        }

        if( key==K_DOWN ) {
                cur_command.type=ComSkip;
                return( OK );
        }
	if( key==K_LEFT ) {
		select_left_song();
		return OK;

	}
	if( key==K_RIGHT ) {
		select_right_song();
		return( OK );	
	}
		
	
        if( key==K_HELP ) {
                cur_command.type=ComHelp;
                return( OK );
        }


	if( c=='\\' ) 
	{
                cur_command.type=ComAutoPlay;
                return( OK );
        }

	if( c>='0' && c<='9')
	{
		digit1=digit2;
		digit2=digit3;
		digit3=c-'0';
	}
	
	if( c=='\r' )
	{
		cur_command.type=ComSelect;
		cur_command.value=(digit1*100)+(digit2*10)+(digit3)-1;
		digit1=0;
		digit2=0;
		digit3=0;		
		if( cur_command.value >= set.num_songs 
			|| cur_command.value<0 )
		{
			cur_command.type=ComNone;
			return FAILED;
		}

		return OK;
	}
	
        c=toupper( c );

/*        for( i=0; i<set.num_songs; i++ ) {
                if( c==song_chars[i] ) {
                        cur_command.type=ComSelect;
                        cur_command.value=i;
                        return( OK );
                }
        }
*/

        key>>=16;
        c=key-0x3a;
        
        if( c>=1 && c<=10 ) {
                cur_command.type=ComNewSet;
                cur_command.value=c;
                if( c==10 ) cur_command.value=0;
                
                return( OK );
        }
        
        return( FAILED );

}

Boolean light( unsigned short new_stat )
{
register unsigned int i;

        l_stat=new_stat;
        if( cfg.light_ch<0 || cfg.light_ch>15 ) return FAILED;

        
    t_goto_xy(32,23);
    if( rez==1 ) t_char_col( STAT_COLOR );
        if( rez==2 ) t_rev_off();

    cputs( "LIGHTS :");

    if( rez==1 ) t_char_col( HIGH_COLOR );

    for( i=0; i<8; i++ ) {
        if( (l_stat>>i)&1==1 ) putch( '1'+i );
        else putch( ' ' );
    }

    if( (int)Bcostat(0)==(int)0 ) {
        cputs( "N/C!" );
        return( FAILED );
    }
    else 
                cputs( "    " );

    Bconout( 0, l_stat^0xff );

    return( OK );
}
 

void light_midi( int key, int vel )
{
int j;
        for( j=0; j<8; j++ )
                if( l_keys[j]==key ) {
                        if( vel==0 )
                                l_stat &= ~(1<<j);
                        else
                                l_stat |= (1<<j);
                        light(l_stat);
                }       

}

Boolean man_light( long key )
{
register int l;

        if( cfg.light_ch<0 || cfg.light_ch>15 ) return( FAILED );

    l=-1;
    if( key==K_F11 ) l=0;
    if( key==K_F12 ) l=1;
    if( key==K_F13 ) l=2;
    if( key==K_F14 ) l=3;
    if( key==K_F15 ) l=4;
    if( key==K_F16 ) l=5;
    if( key==K_F17 ) l=6;
    if( key==K_F18 ) l=7;
    if( key==K_F19 ) l=8;
    if( key==K_F20 ) l=9;
    if( l==-1 ) return( FAILED );

    switch( l ) {

        case 8: l_stat=255;
                break;
        case 9: l_stat=0;
                break;
        default: l_stat ^= (1<<l);
                break;
    }
    light( l_stat );
    return( OK );
}

void unhang()       /* unhang any bad midi messages */
{
unsigned int    channel;
unsigned long time;

    for( channel=0; channel<16; channel++ ) {
       
       midi_out( 0xe0+channel );       /* reset all benders    */
       midi_out( 0x00 );
       midi_out( 0x40 );       /* wild guess at middle position*/
       
       
       midi_out( 0xb0+channel ); /* send All notes off */
       
       midi_out( 0x7c );
               
       midi_out( 0x00 );
       
       midi_out( 0xb0+channel );
       
       midi_out( 0x01 );       /* reset all modulations        */
       midi_out( 0x00 );
       
       midi_out( 0x02 );       /* reset breath controllers     */
       midi_out( 0x00 );
       
       midi_out( 0x40 );       /* reset sustain switch         */
       midi_out( 0x00 );
       
       midi_out( 0x41 );       /* reset portamento switch      */
       midi_out( 0x00 );
       
       midi_out( 0xd0+channel );       /* reset aftertouch     */
       midi_out( 0x00 );

       while( !Bcostat(3) );
       time=jk_get_200()+3;
       while( time>jk_get_200() );       
    }
}




void clr_line()
{

        cputs( 
"                    "
"                    "
"                    "
"                   "
	);
}
