

#ifndef _CREEK_HH
#define _CREEK_HH


#ifdef atarist	// for Atari ST



typedef long KeyCode;


class creek	// just like a stream, but smaller :-)
{		// always tied to low level Bios routines.
		// does not support floating point stuff.

	short device;
public:

			creek( short device );

 	inline	void	set_device( short dev )
				{ device=dev; }

		void	put( register const char * s );
		void	put( int i );
		int    	get( 	register char *s, 
				short max_len, Boolean echo=TRUE );
			
	inline	void	put( char c ) 
				{ Bconout( device, c ); }

	inline	Boolean ostat() 
				{ return (Boolean)Bcostat(device); }
	inline	Boolean istat() 
				{ return (Boolean)Bconstat(device); }
	
	inline	creek&	operator << (char   c)
				{ Bconout(device,c); return *this; }

	inline	creek& 	operator << (KeyCode   n)
				{ Bconout( device, n&0xff ); return *this; }

	inline	creek& 	operator << (const char* s)
				{ put(s); return *this;}


	inline	long   get()
				{ return Bconin( device ); }

	inline	creek& operator >> (char&   c)
				{ c=Bconin(device); return *this; }
	inline 	creek& operator >> (KeyCode& k)
				{ k=Bconin( device ); return *this; }

	inline 	creek& operator >> (char*   s)
				{ get( s, 80, TRUE );  	return *this; }
};




class creekvt52 : public creek
{
public:

	creekvt52( short device );

	void goto_xy(char x,char y );
	void cursor_up();
	void cursor_down();
	void cursor_left();
	void cursor_right();

	void cursor_home();
	void cursor_up_scroll();
	void cursor_save();
	void cursor_restore();

	void clear_screen();
	void clear_eop();
	void clear_eol();
	void clear_top();
	void clear_line();
	void clear_beginning();

	void insert_line();
	void delete_line();

	void reverse_on();
	void reverse_off();

	void cursor_on();
	void cursor_off();

	void overflow_on();
	void overflow_off();

	void char_col( char c );

	void back_col( char c );

};




extern creekvt52 con;		// console.

#else			// for IBM PC

#ifndef _WINDOWS 	// doesn't work under MS-WINDOWS

typedef short KeyCode;


class creek	// just like a stream, but smaller :-)
{		// always tied to low level conio routines.
		// does not support floating point stuff.

public:

			creek();

		void	put( register const char * s );
		void	put( int i );
		int    	get( 	register char *s,
				short max_len, Boolean echo=TRUE );

	inline	void	put( char c )
				{ putch( c ); }

	inline	Boolean ostat()
				{ return TRUE; }
	inline	Boolean istat()
				{ return kbhit(); }

	inline	creek&	operator << (char   c)
				{ putch(c); return *this; }

	inline	creek& 	operator << (KeyCode   n)
				{ putch( n&0xff ); return *this; }

	inline	creek& 	operator << (const char* s)
				{ put(s); return *this;}


	inline	long   get()
				{ return getch(); }

	inline	creek& operator >> (char&   c)
				{ c=getch(); return *this; }
	inline 	creek& operator >> (KeyCode& k)
				{ k=getch(); return *this; }

	inline 	creek& operator >> (char*   s)
				{ get( s, 80, TRUE );  	return *this; }
};




class creekpc : public creek
{
public:

	inline	void goto_xy(short x,short y ) { gotoxy( x, y ); }
	inline	void cursor_up() 	{ gotoxy( wherex(), wherey()-1); }
	inline	void cursor_down()	{ gotoxy( wherex(), wherey()+1); }
	inline	void cursor_left()	{ gotoxy( wherex()-1, wherey()); }
	inline	void cursor_right()	{ gotoxy( wherex()+1, wherey()); }

	inline	void cursor_home()	{ gotoxy( 1,1 ); }

	inline	void cursor_up_scroll()	{}
	inline	void cursor_save()	{}
	inline	void cursor_restore()	{}

	inline	void clear_screen()	{ clrscr(); }
	inline	void clear_eop()	{}
	inline	void clear_eol()	{ clreol(); }
	inline	void clear_top()	{}
	inline	void clear_line()	{}
	inline	void clear_beginning()	{}

	inline	void insert_line()	{ insline(); }
	inline	void delete_line()	{ delline(); }

	inline	void reverse_on()	{}
	inline	void reverse_off()	{}

	inline	void cursor_on()	{}
	inline	void cursor_off()	{}

	inline	void overflow_on()	{}
	inline	void overflow_off()	{}

	inline	void char_col( char c ) {}

	inline	void back_col( char c ) {}

};




extern creekpc con;		// console.

#endif

#endif

#endif



