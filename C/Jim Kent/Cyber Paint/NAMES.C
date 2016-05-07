
upc(s)
register char *s;
{
register char c;

while (c = *s)
	{
	*s++ = toupper(c);
	}
}

tr_string(string, in, out)
register char *string;
register char in, out;
{
register char c;

while (c = *string)
	{
	if ( c == in )
		*string = out;
	string++;
	}
}

cut_suffix(title)
char *title;
{
tr_string(title, '.', 0 );	/* cut off suffix */
}

suffix_in(string, suff)
char *string, *suff;
{
string += strlen(string) - strlen(suff);
return( strcmp(string, suff) == 0);
}

#ifdef SLUFFED
lines_size(lines)
char *lines[];
{
int count = 0;

while (*lines++ != 0L)
	count++;
return(count);
}
#endif SLUFFED


