/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*	protect.c
**
**	Dongle Protection for the performance midi sequencer
**
*/



typedef double prottype;

#ifdef PROTECT

void pwrite( int reg, int data )
{
register long ptr;
prottype p;
prottype y;

	p=0xfb0000;
		
	if( reg&1 )
		p+=0x800;
	if( reg&2 )
		p+=0x20;

	if( data&1 )
		p+=0x40;
	if( data&2 )
		p+=0x80;
	y=p;
	ptr=(long)y;

	ptr=*(short *)ptr;
/*
	asm ( "
		movel	%1,a0
		movew	a0@,%0
	" : "=r"(ptr) : "r"(ptr) : "a0" );
*/	
}


int pread( int reg )
{
register long ptr;
register int data;
prottype p;
prottype y;

	p=0xfa0000;

	if( reg&1 )
		p+=0x20;
	if( reg&2 )
		p+=0x800;
	y=p;
	ptr=(long)y;
	
	ptr=*(short *)ptr;
/*	asm ( "
		movel	%1,a0
		movew	a0@,%0
	" : "=g"(ptr) : "r"(ptr) : "a0" );
*/

	data=0;
	if( ptr&0x100 ) data=1;
	if( ptr&0x400 ) data|=2;
 
	return( data );
}

#else

int regs[4];

void pwrite( int reg, int data )
{
	regs[reg]=data;
}


int pread( int reg )
{
	return( regs[reg] );
}


#endif
