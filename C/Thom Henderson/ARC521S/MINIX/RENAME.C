/*
 * substitute for BSD/SVR3 rename() system call, from
 * Janet Walz, walz@mimsy.umd.edu & Rich Salz, rsalz@pineapple.bbn.com
 */

int rename(oldname,newname)
char *oldname,*newname;
{
	(void)unlink(newname);
	if(link(oldname,newname))
		return(-1);
	return(unlink(oldname));
}
