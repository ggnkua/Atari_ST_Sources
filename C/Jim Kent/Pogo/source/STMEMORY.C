
#define NULL 0L

extern void *malloc();

void *
askmem(amount)
int amount;
{
return(malloc(amount));
}

freemem(pt)
void *pt;
{
if (pt != NULL)
	free(pt);
}
