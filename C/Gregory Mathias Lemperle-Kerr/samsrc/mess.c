/**************************************
	Message to user in (c)
***************************************/
void mess(char *c)
	{
	char 	a[40];
	
	graf_mouse(ARROW,0);
	strcpy(a,"[3][");
	strcat(a,c);
	strcat(a,"][OK]");
	form_alert(1,a);
	graf_mouse(POINT_HAND,0);
	}

int	mess2(
	char	*c1,	/*	Line one of message	*/
	char	*c2,	/*  Line two			*/
	char	*b1,	/*  Button one text		*/
	char	*b2,	/*	Button two text		*/
	int		db	)	/*	Default Button #	*/
	{
	char 	a[80];
	
	graf_mouse(ARROW,0);
	strcpy(a,"[2][");
	strcat(a,c1);
	strcat(a,"|");
	strcat(a,c2);
	strcat(a,"][");
	strcat(a,b1);
	strcat(a,"|");
	strcat(a,b2);
	strcat(a,"]");
	db = form_alert(db+1,a) - 1;
	graf_mouse(POINT_HAND,0);
	return(db);
	}


void messi(int	i)
	{
	char	m[16];
	sprintf(m,"%d",i);
	mess(m);
	}

void messl(long	l)
	{
	char	m[16];
	sprintf(m,"%ld",l);
	mess(m);
	}
