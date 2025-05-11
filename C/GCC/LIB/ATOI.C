
int atoi (str)
char * str;
{
  int value = 0;		/* accumulated value */
  int sgn = 0;			/* if seen sign */
  char c;

/* first skip whitespace */
  for ( ; (c = *str++) ; )
	if (!((c == ' ') || (c == '\t')))
		break;
  if (c == '+')
	sgn = 1;
    else
  if (c == '-')
	sgn = -1;
    else
	{
	str--;		/* back up so loop will catch it again */
	sgn = 1;
	}
/* process digits */
  for ( ; ((c = *str++) && (c >= '0') && (c <= '9')) ; )
	value = (value * 10) + (c - '0');

  return(value * sgn);
}
