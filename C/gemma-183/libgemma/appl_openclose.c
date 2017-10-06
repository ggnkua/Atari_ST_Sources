# include <mint/mintbind.h>
# include <gemma/gemma.h>

GEM_ARRAY *gem;

# ifndef GEMMA_MULTIPROC

SLB gemma;

GEM_ARRAY *
gem_control(void)
{
	return (GEM_ARRAY *)(gemma.exec)(gemma.handle, (long)GEM_CTRL, (short)0);
}

long
appl_open(char *file, short thread, char *pname)
{
	long r;

	r = Slbopen("gemma.slb", 0L, GEMMA_VERSION, &gemma.handle, &gemma.exec);
	if (r < 0)
		return r;

	r = (gemma.exec)(gemma.handle, (long)AP_OPEN, (short)3, (char *)file, (short)thread, (char *)pname);
	if (r > 0)
		gem = gem_control();
	else
	{
		Slbclose((long)gemma.handle);
		gemma.handle = 0;
	}

	return r;
}

long
appl_close()
{
	long r = 0;

	if (gemma.handle)
	{
		r = (gemma.exec)(gemma.handle, (long)AP_CLOSE, (short)0);
		Slbclose((long)gemma.handle);
		gemma.handle = 0;
	}

	gem = 0;

	return r;
}

# else /* MULTIPROC */

short _pid;
SLB gemma[1000];

GEM_ARRAY *
gem_control(void)
{
	return (GEM_ARRAY *)(gemma[_pid].exec)(gemma[_pid].handle, (long)GEM_CTRL, (short)0);
}

long
appl_open(char *file, short thread, char *pname)
{
	long r;

	_pid = Pgetpid();
	r = Slbopen("gemma.slb", 0L, GEMMA_VERSION, &gemma[_pid].handle, &gemma[_pid].exec);
	if (r < 0)
		return r;

	r = (gemma[_pid].exec)(gemma[_pid].handle, (long)AP_OPEN, (short)3, (char *)file, (short)thread, (char *)pname);
	if (r > 0)
		gem = gem_control();
	else
		Slbclose((long)gemma[_pid].handle);

	return r;
}

long
appl_close()
{
	long r;

	r = (gemma[_pid].exec)(gemma[_pid].handle, (long)AP_CLOSE, (short)0);
	Slbclose((long)gemma[_pid].handle);

	gem = 0;

	return r;
}

# endif

/* EOF */
