OBJECT *ResourceObject(RSHDR *hdr, short num)
{
	unsigned long *index, offset;

	if (!hdr || num < 0 || num >= hdr->rsh_nobs)
		return NULL;
	index = (unsigned long *)((unsigned long)hdr + (unsigned long)hdr->rsh_object);
	offset = index[num];			/* HR!!!  This assumed a pointer array!!!!!! */
	return (OBJECT *)((unsigned long)hdr + offset);
}

TEDINFO *ResourceTedinfo(void *base, short num)
{
	unsigned long *index, offset;
	RSHDR *hdr = (RSHDR *)base;

	if ((!hdr) || (num < 0) || (num >= hdr->rsh_nted))
		return NULL;
	index = (unsigned long *)((unsigned long)base + (unsigned long)hdr->rsh_tedinfo);
	offset = index[num];
	return (TEDINFO *)((unsigned long)base + offset);
}

ICONBLK *ResourceIconblk(void *base, short num)
{
	unsigned long *index, offset;
	RSHDR *hdr = (RSHDR *)base;

	if ((!hdr) || (num < 0) || (num >= hdr->rsh_nib))
		return NULL;
	index = (unsigned long *)((unsigned long)base + (unsigned long)hdr->rsh_iconblk);
	offset = index[num];
	return (ICONBLK *)((unsigned long)base + offset);
}

BITBLK *ResourceBitblk(void *base, short num)
{
	unsigned long *index, offset;
	RSHDR *hdr = (RSHDR *)base;

	if ((!hdr) || (num < 0) || (num >= hdr->rsh_nbb))
		return NULL;
	index = (unsigned long *)((unsigned long)base + (unsigned long)hdr->rsh_bitblk);
	offset = index[num];
	return (BITBLK *)((unsigned long)base + offset);
}

/* Find the ref to the free strings */
char **ResourceFrstr(void *base, short num)
{
	unsigned long *index;
	RSHDR *hdr = base;

	if (!(hdr) || (num < 0) || (num >= hdr->rsh_nstring))
		return NULL;
	index = (unsigned long *)((unsigned long)base + (unsigned long)hdr->rsh_frstr);

DIAG((D.p,-1,"Gaddr 15\n"));
	return (char **)&index[num];
}

/* Find the ref to free images */
void *ResourceFrimg(void *base,short num)
{
	unsigned long *index, offset;
	RSHDR *hdr = base;

	if ((!hdr) || (num < 0) || (num >= hdr->rsh_nimages))
		return NULL;
	index = (unsigned long *)((unsigned long)base + (unsigned long)hdr->rsh_frimg);
	offset = index[num];
DIAG((D.p,-1,"Gaddr 16\n"));
	return (void*)((unsigned long)base + offset);
}
