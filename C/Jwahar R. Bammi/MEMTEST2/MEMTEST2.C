#include <osbind.h>

/*
 * A simple memory tester
 *  J.R. Bammi
 *	decvax!cwruecmp!bammi or bammi%case@csnet-relay
 */

#define Supexec(X)	xbios(38,X)  /* Not defined in osbind.h		   */
#define Vsync()		xbios(37)
#define ClearScreen() 	Cconws("\033E")
#define prinl(X)	_prl((long)X)
#define prinh(X)	_prh((long)X)

#define S_STHEAP	0x04000      /* size of stack + heap above _break   */
extern char *_base;		     /* Base page of our TPA		    */
extern long _break;		     /* Break location -- first unused byte */
				     /* Defined in gemstart.s		    */

long *phystop	= (long *)0x000042e; /* [Physical top of memory] 	   */
long v_phystop;			     /* Contents of phystop		   */
char **_va_bas_ad = (char **)0x0000044e; /* Contains base address of screen */
long total = 0L;		     /* Total errors 			   */
char *screen;			     /* Base address of screen memory 	   */
char Sswitched;			     /* True when screen is switched	   */
char Pause;			     /* Pause on errors			   */

main()
{
	register char
	  *start,	        /* First byte above the program  	 */
	  *high,		/* High location for tests (_HiTpa)	 */
	  *MyScreen,		/* Pointer to Screen base when testing   */
				/* The systems screen			 */
	  TestScreen;		/* Should we test screen memory too      */

	int ReadBiosVars();
	int YesNo();
	
	/* Go find out v_phystop and screen_mem */
	Supexec(ReadBiosVars);

	/* Find out our high location */
	high = (char *)(*(long *)(_base + 4L));
	
	/* Find our start location */
	start = (char *)(_break + (long)S_STHEAP + 2L);
	
	/* If its odd, inc 1 */
	if(((long)start & 1L) == 1)
	    start++;

	/* find out if he wants to test screen locations too */
	if((TestScreen = YesNo("Include Screen Memory in Tests?")))
	    /* My Screen Will be a 32K chunk on an 256 byte boundary */
	    MyScreen = (char *) ((( (long)start + 256L) & 0xffffff00)
				 + 0x00000100);

	/* find out if he wants to pause on errors */
	Pause = YesNo("Pause on Errors?");
	
	/* Tell the user */
	Cconws("The System Thinks You Have ");
	prinl(v_phystop);
	Cconws(" [");
	prinl((v_phystop/1024L));
	Cconws("K] Bytes of Memory.\r\n\n");

	Cconws("Memory from Location ");
	prinh(start);
	Cconws(" To ");
	prinh((high - 1L));
	Cconws(" [");
	prinl(((long)high - (long)start));
	Cconws("  Bytes] Will be Tested.\r\n\n");
	
	if(TestScreen)
	{
		Cconws("Then the Screen Base will be switched to ");
		prinh(MyScreen);
		Cconws("\r\nand the locations from ");
		prinh(screen);
		Cconws(" To ");
		prinh(((long)screen + 32L*1024L));
		Cconws(" [32K Bytes] Will be Tested.\r\n");
		Cconws("Finally the Screen Base will be switched back to ");
		prinh(screen);
		Cconws(".\r\n\n");
	}

	/* Begin Tests */
	Sswitched = 0;
	ByteTest(start, high);
	IntTest(start, high);
	LongTest(start, high);
	RandTest(start,high);

#ifdef MARCH
	March1s(start, high);
	March0s(start, high);
#endif

	if(TestScreen)
	{
		register long end;
		
		Cconws("Starting Screen Memory Tests\r\n");
		Cconws("Hit any key to Continue .....");
		Crawcin();

		/* Switch to MyScreen */
		Setscreen(MyScreen, MyScreen, -1);
		ClearScreen();
		Sswitched = 1;
		
		end = (long)screen + 32L*1024L;
		ByteTest(screen, end);
		IntTest(screen, end);
		LongTest(screen,end);
		RandTest(screen, end);

#ifdef MARCH
		March1s(screen,end);
		March0s(screen,end);
#endif
		
		Cconws("Hit any key to Continue .....");
		Crawcin();

		/* Switch back to Screen */
		Setscreen(screen, screen, -1);
		ClearScreen();
		
	}
	
	Cconws("All Tests Complete.\r\n");
	prinl(total);
	Cconws(" Error(s) Detected.\r\n");
	
	Pterm0();
	
}


ReadBiosVal()	/* Must be in Super mode else SHROOMS!! */
{
	v_phystop = *phystop;
	screen    = *_va_bas_ad;
}

int YesNo(prompt)
char *prompt;
{
	register int c;
	
	Cconws(prompt);
	Cconws(" [Y/N]");
	if(((c = Crawcin() & 0x7f) == 'Y') || (c == 'y'))
	{
		Cconws("Yes\r\n");
		return(1);
	}

	Cconws("No\r\n");
	return(0);
}

/* 0x0E is the end marker */
char b_data[] = { 0xFF, 0x00, 0x55, 0xAA, 0x5A, 0x0E };

		     
	
ByteTest(begin,end)
register char *begin;
register char *end;
{
	register char *addr;
	register char data,got;
	register int i;
	register long errors;
	
	errors = 0;
	Cconws("Begin Byte Write/Read Tests\r\n");
	
	for(i = 0; (data = b_data[i]) != 0x0E; i++)
	{
		Cconws("\tTesting with ");
		prinh(((long)data & 0x000000FF));
		Cconws("\r\n");
		
		for(addr = begin; addr < end; addr++)
		{
			*addr = data;
			/* Dont want to do two reads */
			if((got = *addr) != data)
			{
				err((long)((long)got & 0x000000FF),
				    (long)((long)data & 0x000000FF),addr);
				errors++;
			}
			    
		}
	}
	
	Cconws("End Byte Write/Read Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;
	
}

/* 0x000E is the end marker */
int w_data[] = { 0x0000, 0xFFFF, 0xAAAA, 0x5555,  0x2345,
				 0x000E };

		     
	
IntTest(begin,end)
register int *begin;
register int *end;
{
	register int *addr;
	register int data,got;
	register int i;
	register long errors;
	
	errors = 0;
	Cconws("Begin Integer Write/Read Tests\r\n");
	
	for(i = 0; (data = w_data[i]) != 0x000E; i++)
	{
		Cconws("\tTesting with ");
		_prh((long)((unsigned int)data & 0x0000FFFFL));
		Cconws("\r\n");
		
		for(addr = begin; addr < end; addr++)
		{
			*addr = data;
			/* Dont want to do two reads */
			if((got = *addr) != data)
			{
				err((long)((long)got & 0x0000FFFF),
				    (long)((long)data & 0x0000FFFF),addr);
				errors++;
			}
			    
		}
	}
	
	Cconws("End Integer Write/Read Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;
	
}

/* 0x0000000E is the end marker */
long l_data[] = { 0x00000000, 0xFFFFFFFF, 0xAAAAAAAA, 0x55555555,
		  0xAAAA5555, 0x5555AAAA, 0x11223344, 0x0000000E };

		     
	
LongTest(begin,end)
register long *begin;
register long *end;
{
	register long *addr;
	register long data,got;
	register int i;
	register long errors;
	
	errors = 0;
	Cconws("Begin Long Write/Read Tests\r\n");
	
	for(i = 0; (data = l_data[i]) != 0x000E; i++)
	{
		Cconws("\tTesting with ");
		prinh(data);
		Cconws("\r\n");

		for(addr = begin; addr < end; addr++)
		{
			*addr = data;
			/* Dont want to do two reads */
			if((got = *addr) != data)
			{
				err(got,data,addr);
				errors++;
			}
			    
		}
	}
	
	Cconws("End Long Write/Read Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;

	errors = 0;
	Cconws("Begin Refresh Tests\r\n");

	for(addr = begin; addr < end; addr++)
	    *addr = addr;

	for(addr = begin; addr < end; addr++)
	{
		if((got = *addr) != addr)
		{
			err(got,addr,addr);
			errors++;
		}
	}
	
	Cconws("End Refresh Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;
}

RandTest(begin,end)
register long *begin;
register long *end;
{
	register long *addr;
	register long data,got;
	register long errors;
	
	errors = 0;
	Cconws("Begin Random Write/Read Tests\r\n");
	

	for(addr = begin; addr < end; addr++)
	{
		data = Random();
		*addr = data;
		/* Dont want to do two reads */
		if((got = *addr) != data)
		{
			err(got,data,addr);
			errors++;
		}
		    
	}
	
	Cconws("End Random Write/Read Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;
}

#ifdef MARCH

March1s(begin,end)
register long *begin;
register long *end;
{
	register long *addr, *addr1;
	register long got;
	register int count;
	register long errors;
	
	count = errors = 0;
	Cconws("Begin Marching 1's Test (be patient -- Dots show progress)\r\n");
	
	for(addr = begin; addr < end; addr++)
		*addr = 0L;
	for(addr = begin; addr < end; addr++)
	{
		*addr = -1L;
		
		for(addr1 = begin; addr1 <= addr; addr1++)
		{
			/* Dont want to do two reads */
			if((got = *addr1) != -1L)
			{
				err(got,-1L,addr1);
				errors++;
			}
		}

		Cconout('.');
		if(++count == 80)
		{
			count = 0;
			Cconws("\r\n");
		}
	}
	
	Cconws("End Marching 1's Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;
	
}

March0s(begin,end)
register long *begin;
register long *end;
{
	register long *addr,*addr1;
	register long got;
	register int count;
	register long errors;
	
	count = errors = 0;
	Cconws("Begin Marching 0's Test (be patient -- Dots show progress)\r\n");
	
	for(addr = begin; addr < end; addr++)
		*addr = -1L;
	for(addr = begin; addr < end; addr++)
	{
		*addr = 0L;
		
		for(addr1 = begin; addr1 <= addr; addr1++)
		{
			/* Dont want to do two reads */
			if((got = *addr1) != 0L)
			{
				err(got,0L,addr);
				errors++;
			}
		}
		    
		Cconout('.');
		if(++count == 80)
		{
			count = 0;
			Cconws("\r\n");
		}
	}
	
	Cconws("End Marching 0's Tests ");
	prinl(errors);
	Cconws(" Error(s)\r\n\n");
	total += errors;
	
}

#endif

err(got, expecting, addr)
long got;
long expecting;
long addr;
{
	int YesNo();
	
	Cconws("Error at Location ");
	prinh(addr);
	Cconws(": Expecting ");
	prinh(expecting);
	Cconws(" Got ");
	prinh(got);
	Cconws("\r\n");
	
	if(Pause)
	{
		if(YesNo("Continue Tests?"))
		    return;
		
		/* if screen has been switched, switch back and terminate */
		if(Sswitched)
		{
			Setscreen(screen,screen,-1);
			ClearScreen();
		}

		Cconws("Tests Terminated\r\n");
		prinl(total+1L);
		Cconws(" Error(s) Detected\r\n");
		Pterm(1);
	}
}

_prl(val)
register long val;
{
        register int j;
        register int div_idx;
        register int first;
        static long divisors[] = { 1000000000,100000000,10000000,1000000,
				   100000,10000, 1000, 100, 10, 1 };
#define MAX_IDX 10
	
        if (val == 0)
	{
                Cconout('0');
                return;
	}
        else if (val == -2147483648)
	{
                Cconws("-2147483648");
		return;
	}
	
        first = 0;

        if (val < 0)
	{
                Cconout('-');
                val = -val;
	}
	
        for(div_idx = 0; div_idx < MAX_IDX; div_idx++)
	{
                if(((j = val / divisors[div_idx]) != 0) || first != 0)
		{
                        Cconout(j + '0');
                        first = 1;
		}
                val %= divisors[div_idx];
	}
	
}

_prh(val)
register long val;
{
	register int i,j;
	register int first;
	static char hex[] = {'0','1','2','3','4','5','6','7','8','9','A',
			     'B','C','D','E','F' };

	if(val == 0L)
	{
		Cconws("0H");
		return;
	}

	first = 0;
	for(i = 28; i >= 0; i-= 4)
	{
		if(((j = (val >> i) & 0x0000000F) != 0) || (first != 0))
		{
			Cconout((int)hex[j]);
			first = 1;
		}
	}
	Cconout('H');
}

