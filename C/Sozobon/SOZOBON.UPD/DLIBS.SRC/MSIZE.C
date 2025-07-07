long msize(addr)
	register long *addr;
	{
	return((addr[-1] & 0x00FFFFFF) - 4L);
	}
