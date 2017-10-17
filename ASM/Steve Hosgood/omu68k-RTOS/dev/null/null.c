/*
 * Null character device.
 */

r_null(dev, buff, count)
char *buff;
{

	/* on read, return EOF */
	return 0;
}

w_null(dev, buff, count)
char *buff;
{

	/* on write, look like sucess */
	return count;
}
