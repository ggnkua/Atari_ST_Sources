/*

   UEDIT - program to edit linked chains of RAM-resident
           utilities conforming to the suggested protocol.

   By Moshe Braner  <braner@amvax.tn.cornell.edu>          870102

*/

#include <osbind.h>

int hex[] =
   {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

int
nibble(c)
	register int c;
{
	register int i;
	if (c>='a' && c<='f')
		c += ('A'-'a');
	for (i=0; i<16; i++)
		if (c == hex[i])  break;
	return (i);
}

long
gethex()
{
	register long	v;
	register int	d;
	register char	*cp;
	char	str[80];
	str[0] = 76;
	Cconrs(str);
	str[str[1]+2] = '\0';
	cp = &str[2];
	v = 0;
	while ((d=nibble(*cp++)) < 16)
		v = (v<<4) + d;
	return (v);
}

puthex(v)
	register long	v;
{
	register char	*cp;
	char str[7];
	str[6] = '\0';
	cp = &str[6];
	while (--cp >= str) {
		*cp = hex[v&0xF];
		v >>= 4;
	}
	Cconws(str);
}

main()
{
	register int	c, level, valid;
	register long	address;
	long	vector, temp, stack;
	long	over[9];
	char	str[80];
	str[0] = 76;

new:
	Cconws("\033E\r\n\n\tUEDIT\tby Moshe Braner");
	Cconws("\r\n\n\tEnter vector address, in HEX: ");
	vector = gethex();
	if (vector <= 0) goto new;
	level = 0;
	stack = Super(0L);		/* get into supervisor mode	*/
	address = *((long *) vector);
	Super(stack);			/* back to user mode		*/
repeat:
	Cconws("\033E\r\n\n\tVector address:   ");
		puthex(vector);
	Cconws("\r\n\tLink level:            ");
		Bconout(2,level+'1');
	Cconws("\r\n\tUtility address:  ");
		puthex(address);
	valid = 0;
	if (address<0x001000 || address>0xFEFFFF || (address&1==1))
		Cconws("\r\n\t(Not a valid utility address)");
	else {
		temp = *((long *)(address-4));
		if (temp<0x001000 || temp>0xFEFFFF || (temp&1==1))
			Cconws("\r\n\t(No valid next address)");
		else {
			Cconws("\r\n\tMagic here:       \"");
			Bconout(5,*((char *)(address-8)));
			Bconout(5,*((char *)(address-7)));
			Bconout(5,*((char *)(address-6)));
			Bconout(5,*((char *)(address-5)));
			Bconout(2,'\"');
			Cconws("\r\n\tNext address:     ");
			puthex(*((long *)(address-4)));
			valid = 1;
		}
	}
	if (level) {
		Cconws("\r\n\tPrevious address: ");
		puthex(over[level]);
	}
	Cconws("\r\n");
	if (level)
		Cconws("\r\n\t\tPrevious utility");
	if (valid) {
		Cconws("\r\n\t\tNext utility");
		Cconws("\r\n\t\tUnlink this utility");
	}
	Cconws("\r\n\t\tLink in a utility (over this one)");
	Cconws("\r\n\t\tQuit");
	Cconws("\r\n\t\t(default: restart)");
	Cconws("\r\n\n\t\tEnter first letter of choice: ");
	Cconrs(str);
	if (str[1] == 0)
		goto new;
	c = str[2];

	if ((c=='p' || c=='P') && level)
		address = over[level--];
	else if ((c=='n' || c=='N') && valid && level<8) {
		over[++level] = address;
		address = *((long *)(address-4));
	} else if ((c=='u' || c=='U') && valid) {
		Cconws("\r\n\n\t\tUnlink? (y/n) ");
		Cconrs(str);
		c = str[2];
		if (c!='y' && c!='Y')
			goto repeat;
		address =  *((long *)(address-4));
		if (level == 0) {		  /* over==vector */
			stack = Super(0L);
			*((long *) vector) = address;
			Super(stack);
		} else
			*((long *)(over[level]-4)) = address;
	} else if (c=='l' || c=='L') {
		Cconws("\r\n\n\t\tLink in? (y/n) ");
		Cconrs(str);
		c = str[2];
		if (c!='y' && c!='Y')
			goto repeat;
		Cconws("\r\n\n\t\tEnter utility address, in HEX: ");
		temp = gethex();
		if (temp == 0) goto repeat;
		*((long *)(temp-4)) = address;
		if (level == 0) {
			stack = Super(0L);
			*((long *) vector) = temp;
			Super(stack);
		} else
			*((long *)(over[level]-4)) = temp;
		address = temp;
	} else if (c=='q' || c=='Q')
		exit (0);
	goto repeat;
}
