/*
 *	BloufGate
 *	Type-2 FTS-0001 Packet Handler
 *
 *	Public Domain: may be copied and sold freely
 */

#include	"blouf.h"

/*
 * 	Message ID generation
 */

unsigned long mytimer=0;

unsigned long msgid_serial(void )
{
	if(!mytimer)
		mytimer=(unsigned long) time(NULL)*16;
	else
		mytimer++;
	return mytimer;	
}


/*
 *	Write packet header
 *
 *	outpkt:    path to place pkt created
 *	c:	   config struct
 *	return:    packet file desc
 */

FILE *openpacket()
{
		int i;
		char tmp[80];
		struct tm *heure;
		FILE *packet;
		time_t starth;

		time(&starth);
		
		sprintf (tmp, "%s%c%8.8lx.PKT", cf->outpkt,BLF_DSEPAR, (unsigned long) starth);
		
		if(access(tmp,0)==0)
		{
/* fixme: db */ printf("pkt exists\n");
			sprintf (tmp, "%s%c%8.8lx.PKT", cf->outpkt,BLF_DSEPAR,(unsigned long)(starth-111));
			if(access(tmp,0)==0)
			{
				logline("!Can't find a unique packet name");
				return NULL;
			}
		}
		
		packet = fopen(tmp, "wb");
		
		if(packet==NULL)
		{
			logline("!Can't open packet");
			return NULL;
		}
		
		fputiw ((WORD) cf->td_node, packet); /* orignode */
		fputiw ((WORD) cf->b_node, packet); /* destnode */
		heure = localtime (&starth);
		fputiw ((WORD) heure->tm_year, packet);
		fputiw ((WORD) heure->tm_mon, packet);
		fputiw ((WORD) heure->tm_mday, packet);
		fputiw ((WORD) heure->tm_hour, packet);
		fputiw ((WORD) heure->tm_min, packet);
		fputiw ((WORD) heure->tm_sec, packet);
		fputiw (0, packet);					/* Type 2 packet */
		fputiw (2, packet);
		fputiw ((WORD)cf->td_net, packet);	/* orig net */
		fputiw ((WORD)cf->b_net, packet);	/* dest net */
		fputc (ProdCode, packet);			/* product code */
		fputc (0, packet);					/* serial number */
		
		if(cf->pktpass[0]=='\0')
			for (i=1; i<=8; i++) fputc (0, packet);    	/* password */
		else
			for(i=0; i<8; i++) fputc(cf->pktpass[i], packet);
				
		fputiw ((WORD)cf->o_zone, packet);				/* orig zone */
		fputiw ((WORD)cf->b_zone, packet);				/* dest zone */
		for (i=1; i<=20; i++) fputc (0, packet); 		/* fill */
		
		return packet;
}

/*
 *	Close Packet
 */
 
void closepacket(FILE *p)
{
	fputiw(0,p);
	/* fputc(0,p); i was wrong */
	if(ferror(p))
		logline("!Write error while trying to close packet");
	fclose(p);
}

/*
 * Open message
 */

void openpktmessage(FILE *p, char *area,
		       BFIDOUSER *from, BFIDOUSER *to,
		       char *subject, unsigned long serial, struct tm *ptime)
{
	char timestring[BLFSTR];
	time_t timer;
		
	time(&timer);
	
	fputiw (2, p);
	if(area)
	{
		fputiw (cf->td_node, p);
		fputiw (cf->b_node, p);
		fputiw (cf->td_net, p);
		fputiw (cf->b_net, p);
	}
	else
	{
		fputiw (from->node, p);
		fputiw (to->node, p);
		fputiw (from->net, p);
		fputiw (to->net, p);
	}

	if(area) /* attributes word */
		fputiw (0, p);
	else
		fputiw (1, p); /* Pvt flag */
		
	fputiw (0, p); /* cost */

	/** DATE  **/
	/* Date: 20 Dec 1990 14:48:02 */
	if(!ptime) /* set to now */
		strftime(timestring,40,"%d %b %y  %H:%M:%S",localtime(&timer));
	else
		strftime(timestring,40,"%d %b %y  %H:%M:%S",ptime);
		
	fputs (timestring, p);
	fputc (0, p);
	/** TO **/
	if(to)
		fputs (to->name, p);
	else
		fputs ("All",p);
	fputc (0, p);
	/** FROM **/
	fputs (from->name, p);
	fputc (0, p);
        
	/** SUBJECT **/
	fputs (subject, p);
	fputc (0, p);
        
	/** KLUDGE **/
	if(area) /* Echomail, area not nil */
		fprintf (p, "AREA: %s\r", area);
	else
	{ /* netmail */
		if(from->zone!=cf->o_zone || to->zone!=cf->o_zone)
			fprintf(p, "\01INTL %d:%d/%d %d:%d/%d\r",
				to->zone,to->net,to->node,
				from->zone,from->net,from->node);
		if(from->point)
			fprintf(p, "\01FMPT %d\r", from->point);
		if(to->point)
			fprintf(p, "\01TOPT %d\r", to->point);
	}
	fprintf (p, "\01MSGID: %d:%d/%d.%d %8.8lx\r",
			cf->o_zone, cf->o_net, cf->o_node, cf->o_point, serial ? serial : msgid_serial());
	/* fprintf (packet, "\01PTH %d:%d/%d.%d@fidonet", zone, net, node, point); */
}

/*
 *	Close message packet
 */
 
void closepktmessage(FILE *p)
{
	fputc(0,p);
}

/* end of pkt.c */