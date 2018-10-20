
typedef struct
{
	int		w,h;			/* Framesize */
	long	siz;			/* =w*h, spart Rechnereien */
	
	uchar	*buf; 		/* Interleaved Source planes, size=7*siz
										 Planes 1-3=Source CMY oder Source Grey,
											damm 2,3 leer 
										 Plane 4=Maske
										 Plane 5=Buffer fÅr Maske
										 Plane 6-8 = buf2 fÅr Smear
									*/ 

	uchar	*mask, *maskbuf, *buf2; /* Da steht gleich alles drin */

	int		sdef, mdef, stype;	/* sdef=Source defined 0/1
															 mdef=Mask defined 0/1
															 stype=Sourcetype, 0=CMY, 1=Grey */

	int		act_buf;	/* Aktueller Schreib-Buffer im Smear-mode 
										 0=Noch nix gebuffert
										 1=Aktuelles Ziel In buf gebuffert
										 2=Aktuelles Ziel in buf2 gebuffert
									*/
	
	int		save_type;/* Nur bei Layerdaten, Bits:
										 0=Transparent
										 1=Deckend ohne weiû
										 2=Deckend mit weiû */

	int		save_mode;	/* Bit 0: smear aus(0) oder an(1) 
											 Bit 1: Maske aus(0) oder an(1)	*/
}STEMPEL;

void stempel(int wid);
void get_stempel(int wid);
void get_clip_stempel(int type);
void stempel_io(void);

void stampopt_window(void);
void dial_stampopt(int ob);

void stamp_turn_on(int ob);
void stamp_turn_off(int ob);

extern OBJECT *ostampopt;
extern WINDOW wstampopt;
extern DINFO dstampopt;