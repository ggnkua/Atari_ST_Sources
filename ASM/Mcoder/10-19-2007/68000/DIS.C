/*
	- ce qu'il faut rajouter :
		trier les labels … la fin
		d‚finir zones .L .W .B
		mettre des tabs entre mn‚mo et op‚rande

	68000 disassembler (2 passes)

	Ce qui reste … faire :

	- l'option /P bugge
	- g‚n‚rer des DC.B au lieu des DC.W dans les zones Datas

	/2=2 passes
	/Daaaa-bbbb=data entre aaaa et bbbb (hexa)

	originally written by Bill Rogers (New Zealand)
	slightly modified and improved by Mcoder 06/28/92

	find UNLITE & UNCLIPPER

	bugs found in GENPC :
	- compteur de ligne=signed int (si >32768 devient n‚gatif !!!)
	- d(An,Xi) ou d(PC,Xi) n'indique pas d'overflow
	- add.b # n'optimise pas en addq.b
	- btst dn,addr non impl‚ment‚
	- lea -1-1 -> lea 0 !!!

	tester les instructions suivantes (non impl‚ment‚es dans GENPC)

		BTST	#n,d(PC)
		BTST	#n,d(PC,Xi)

		BTST	Dn,d(PC)
		BTST	Dn,d(PC,Xi)
		BTST	Dn,#n

	ADDA,SUBA -> valeurs sign‚es derriŠre
	am‚liorer signage des valeurs de branchement
*/
typedef unsigned char UCHAR;

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#define MAXSEG 100				/* nombre maximum de segments DATAS */
#define MAXLAB 4000				/* nombre maximum de labels */
#define MARGE1 (7+2*10+1)
#define MARGE2 (MARGE1+8)
#define opchar(c) *p++=(c)

int pause=0;
int countline=0;
UCHAR opline[120], *p, *q;
int srckind;
unsigned int word;
FILE *in;
FILE *in2;
long codeaddress,pc;
int passe,firstpasse;
int dcb;

long debutcode,fincode;

int nbseg;
unsigned long segment_debut[MAXSEG],segment_fin[MAXSEG];
int nblabels;
unsigned long label[MAXLAB];
unsigned char used_label[MAXLAB];	/* pour g‚n‚ration des labels unused */

/* liste des prototypes */
/* void operand(int mode,int reg); */
void decode(void);
void display(void);

int read_segments(UCHAR *file)
{
	int l,k;
	/* fichier contenant les adresses des segments */
	if (*file==0)
	{
		printf("Fichier null\n");
		return 1;
	}
	printf("fichier de segments : %s\n",file);
	in2=fopen(file,"rb");
	if (in2==NULL)
	{
		printf("No config file found\n");
		return 14;
	}

	if (firstpasse==0)
	{
		printf("error -> option valid only when 2 passes\n");
		return 2;
	}
	for (;;)
	{
		if (nbseg>MAXSEG)
		{
			printf("Maximum segment overflow\n");
			return 1;
		}
		segment_debut[nbseg]=0L;
		segment_fin[nbseg]=0L;
		l=0;
		for (;;)
		{
			if (feof(in2))
			{
				goto finished1;
			}
			k=fgetc(in2);
			if (k==0 || k==26 || feof(in2)!=0)
			{
				goto finished1;
			}
			if (k>='a' && k<='z')
			{
				k=k-'a'+'A';
			}
			switch(k)
			{
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				if (l==0)
				{
					segment_debut[nbseg]=(segment_debut[nbseg]<<4)+(k-'0');
				}
				else
				{
					segment_fin[nbseg]=(segment_fin[nbseg]<<4)+(k-'0');
				}
				break;
			case 'A':
			case 'B':
			case 'C':
			case 'D':
			case 'E':
			case 'F':
				if (l==0)
				{
					segment_debut[nbseg]=(segment_debut[nbseg]<<4)+(k-'A'+10);
				}
				else
				{
					segment_fin[nbseg]=(segment_fin[nbseg]<<4)+(k-'A'+10);
				}
				break;
			case '-':
				l++;
				if (l>=2)
				{
					printf("Error : only 2 adresses after /D\n");
					return 5;
				}
				break;
			case ',':
			case 10:
				goto finished2;
			case 13:
			case ' ':
				break;
			default:
				printf("%d=%c\n",k,k);
				printf("Error in hexa number\n");
				return 4;
			}
		}
	finished2:
		if (l==0)
		{
			segment_fin[nbseg]=0xFFFFFFL;
		}
		nbseg++;
	}
finished1:
	fclose(in2);
	return 0;
}

int cdecl main(int argc,char *argv[])
{
	int i,j,k,l;
	debutcode=0x8000L;
	in=NULL;
	firstpasse=0;
	passe=0;

	/*
		firstpasse	passe
			0		  0			d‚sassemblage normal (monopasse)
			1		  0 ou 1	premiŠre passe d‚sassemblage bipasse
			0		  1			seconde passe
	*/
	for (i=1;i<argc;i++)
	{
		switch(*argv[i])
		{
		case '@':
			j=read_segments(argv[i]+1);
			if (j!=0)
			{
				return j;
			}
			break;


		case '/':
			switch(*(argv[i]+1))
			{
			case '2':
				if (*(argv[i]+2)==0)
				{
					firstpasse=1;
					break;
				}
				break;
			case 'o':
			case 'O':
				/* nombre hexa */
				debutcode=0L;
				for (j=2;;j++)
				{
					k=*(argv[i]+j);
					if (k==0)
					{
						break;
					}
					if (k>='a' && k<='z')
					{
						k=k-'a'+'A';
					}
					switch(k)
					{
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9':
						debutcode=(debutcode<<4)+(k-'0');
						break;
					case 'A':
					case 'B':
					case 'C':
					case 'D':
					case 'E':
					case 'F':
						debutcode=(debutcode<<4)+(k-'A'+10);
						break;
					default:
						printf("Error in hexa number\n");
						return 4;
					}
				}
				break;
			case 'p':
			case 'P':
				if (*(argv[i]+2)==0)
				{
					pause=1;
					break;
				}
				break;
			case 'd':
			case 'D':
				if (firstpasse==0)
				{
					printf("error -> option valid only when 2 passes\n");
					return(2);
				}
				if (nbseg>MAXSEG)
				{
					printf("Maximum segment overflow\n");
					return 1;
				}
				segment_debut[nbseg]=0L;
				segment_fin[nbseg]=0L;
				l=0;
				for (j=2;;j++)
				{
					k=*(argv[i]+j);
					if (k==0)
					{
						break;
					}
					if (k>='a' && k<='z')
					{
						k=k-'a'+'A';
					}
					switch(k)
					{
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9':
						if (l==0)
						{
							segment_debut[nbseg]=(segment_debut[nbseg]<<4)+(k-'0');
						}
						else
						{
							segment_fin[nbseg]=(segment_fin[nbseg]<<4)+(k-'0');
						}
						break;
					case 'A':
					case 'B':
					case 'C':
					case 'D':
					case 'E':
					case 'F':
						if (l==0)
						{
							segment_debut[nbseg]=(segment_debut[nbseg]<<4)+(k-'A'+10);
						}
						else
						{
							segment_fin[nbseg]=(segment_fin[nbseg]<<4)+(k-'A'+10);
						}
						break;
					case '-':
						l++;
						if (l>=2)
						{
							printf("Error : only 2 adresses after /D\n");
							return 5;
						}
						break;
					default:
						printf("Error in hexa number\n");
						return 4;
					}
				}
				if (l==0)
				{
					segment_fin[nbseg]=0xFFFFFFL;
				}
				nbseg++;
				break;
			default:
				printf("Unknown option\n");
				return 6;
			}
			break;
		default:
			if (in!=NULL)
			{
				printf("One file at a time\n");
				return 3;
			}
			in=fopen(argv[i],"rb");
			if (in==NULL)
			{
				printf("Couldn't open file %s\n",argv[1]);
				return 2;
			}

		}
	}
	if (in==NULL)
	{
		printf("Syntax : DIS filename.prg [/oorg] [/p] [/2] [/Daaaa-bbbb] [@segment file]\n");
		return 1;
	}

	if (firstpasse!=0)
	{
		printf("D‚sassemblage 2 passes d‚sir‚\n");
		printf("%d segments d‚finis\n",nbseg);
		for (i=0;i<nbseg;i++)
		{
			printf("%lx-%lx\n",segment_debut[i],segment_fin[i]);
		}
	}

	fseek(in,0L,SEEK_END);
	fincode=debutcode+ftell(in);

	for(;;)
	{
		fseek(in,0L,SEEK_SET);
		codeaddress=debutcode;
		dcb=0;
		while (codeaddress<fincode)
		{

			if (dcb==0)
			{
				pc=codeaddress;
			}
			decode();
			if (dcb==0)
			{
				display();
			}

		}
		if (dcb!=0)
		{
			display();
		}

		if (firstpasse==0)
		{
			break;
		}
		firstpasse=0;
		passe=1;
	}
	if (passe!=0 || firstpasse!=0)
	{
		printf("Adresses : %lx-%lx\n",debutcode,fincode);
		printf("%d labels collect‚s\n",nblabels);
		printf("Liste des labels non assign‚s :\n");
		for (i=0;i<nblabels;i++)
		{
			if (used_label[i]==0)
			{
				printf("L%lx:\n",label[i]);
			}
		}
	}
	return 0;
}

void internal(int err)
{
	printf("Internal bug %d at $%lx on $%x\n",err,codeaddress,word);
	*p=0;
	printf("%s\n",opline);
	exit(err);
}
void display(void)
{
	void oplab(unsigned long);
	int n;
	while (q<(opline+MARGE1))
	{
		*q++=' ';
	}
	*p='\0';

	if (firstpasse!=0)
	{
		return;
	}

	if (passe==0)
	{
		printf("%s\n",opline);
	}
	else
	{
		for (n=0;n<nblabels;n++)
		{
			if (pc==label[n])
			{
				break;
			}
		}
		if (n<nblabels)
		{
			used_label[n]=1;
			p=opline;
			oplab(pc);
			*p=0;
			printf("%s",opline);
		}
		printf("\t%s\n",opline+MARGE1);
	}

	if (pause!=0)
	{
		countline++;
		if (countline==20)
		{
			switch(getch())
			{
			case 3:
			case 27:
				printf("Aborted");
				exit(0);
			}
			countline=0;
		}
	}
}

void padd(void)
{
	while (p<(opline+MARGE2))
	{
		opchar(' ');
	}
}

void opstring(UCHAR *s)
{
	while (*s!='\0')
	{
		*p++=*s++;
	}
}

void opcode(UCHAR *s)
{
	int n=5;
	while ((*s!='\0')&&(n-->0))
	{
		*p++=*s++;
	}
}

void ophex(unsigned long v)
{
	int n;
	UCHAR c;

	if (v<10)
	{
		*p++=v+'0';
	}
	else
	{
		n=8;
		while(n--)
		{
			if ((v>>(n<<2))&0xF)
			{
				break;
			}
		}
		*p++='$';
		do
		{
			*p++=(c=(v>>(n<<2))&0xF)<=9 ? c+'0' : c-10+'A';
		}
		while (--n>=0);
	}
}

void oplab(unsigned long v)
{
	int n;
	UCHAR c;

	*p++='L';		/* label */
	if (v<10)
	{
		*p++=v+'0';
	}
	else
	{
		n=8;
		while(n--)
		{
			if ((v>>(n<<2))&0xF)
			{
				break;
			}
		}
		do
		{
			*p++=(c=(v>>(n<<2))&0xF)<=9 ? c+'0' : c-10+'A';
		}
		while (--n>=0);
	}
}

void opaddr(unsigned long v)
{
	int n;
	if (firstpasse!=0)
	{
		if (v>=debutcode && v<fincode)
		{
			/* si l'adresse courante est une adresse du programme, on cr‚e un label */
			/* d'abord on le recherche, ensuite on le stocke s'il n'y est pas */
			for (n=0;n<nblabels;n++)
			{
				if (v==label[n])
				{
					break;
				}
			}
			if (n>=nblabels)
			{
				if (nblabels>=MAXLAB)
				{
					printf("Symbol table full");
					exit(10);
				}
				used_label[nblabels]=0;
				label[nblabels++]=v;
			}
		}
	}
	else
	{
		if (passe!=0)
		{
			if (v>=debutcode && v<fincode)
			{
				for (n=0;n<nblabels;n++)
				{
					if (v==label[n])
					{
						break;
					}
				}
				if (n>=nblabels)
				{
					printf("Label %lx not found\n",v);
					printf("Internal bug type 1\n");
					exit(11);
				}
				/* used_label[n]=1; */
				oplab(v);
				return;
			}
		}
	}
	ophex(v);
}

void opbyte(unsigned long v)
{
	if (v>=0x80)
	{
		opchar('-');
		ophex(0x100-v);
	}
	else
	{
		ophex(v);
	}
}

void opword(unsigned long v)
{
	if (v>=0x8000L)
	{
		opchar('-');
		ophex(0x10000L-v);
	}
	else
	{
		ophex(v);
	}
}
/*
void oplong(unsigned long v)
{
	if (v>=0x80000000L)
	{
		opchar('-');
		ophex(0x100000000L-v);
	}
	else
	{
		ophex(v);
	}
}
*/
void dcw(void)
{
	int n=4;
	UCHAR c;
	if (p!=opline+MARGE1)
	{
		internal(90);
	}

	opstring("DC.W");
	padd();
	opchar('$');

	while (n-->0)
	{
		c=(word>>(n<<2)) & 0xF;
		*p++= (c<=9) ? c+'0' : c-10+'A';
	}
}

int grabchar(void)
{
	int c;
	if (feof(in))
	{
		return 0;
	}
	c=fgetc(in);
	if (c==EOF)
	{
		return 0;
	}
	return c;
}
unsigned int nextword(void)
{
	unsigned int v;
	int n=4;
	UCHAR c;

	v=((grabchar()<<8)|grabchar());
	codeaddress+=2;
	while (n-->0)
	{
		c=(v>>(n<<2)) & 0xF;
		*q++= (c<=9) ? c+'0' : c-10+'A';
	}
	return v;
}


void dcbyte(void)
{
	int n=2;
	UCHAR c;
	unsigned int v;

	if (dcb==0)
	{
		opstring("DC.B");
		padd();
	}
	else
	{
		opchar(',');
	}
	opchar('$');

	v=grabchar();
	codeaddress++;
	while (n-->0)
	{
		c=(v>>(n<<2)) & 0xF;
		c= (c<=9) ? c+'0' : c-10+'A';
		*p++=c;
		*q++=c;
	}
}

void sourcekind(int k)
{
	opchar('.');
	switch(k)
	{
	case 0:
		opchar('B');
		srckind=0;
		break;
	case 1:
		opchar('W');
		srckind=1;
		break;
	case 2:
		opchar('L');
		srckind=2;
		break;
	default:
		internal(1);
	}
}

void operand(int mode,int reg)
{
	unsigned int word2;
	unsigned long garbage;

	switch(mode)
	{
	case 0:
		opchar('D');
		opchar(reg+'0');
		break;
	case 1:
		opchar('A');
		opchar(reg+'0');
		break;
	case 2:
		opstring("(A");
		opchar(reg+'0');
		opchar(')');
		break;
	case 3:
		opstring("(A");
		opchar(reg+'0');
		opstring(")+");
		break;
	case 4:
		opstring("-(A");
		opchar(reg+'0');
		opchar(')');
		break;
	case 5:
		opword(nextword());
		opstring("(A");
		opchar(reg+'0');
		opchar(')');
		break;
	case 6:
		word2=nextword();
		opbyte(word2&0xFF);
		opstring("(A");
		opchar(reg+'0');
		opchar(',');
		opchar((word2&0x8000)==0 ? 'D' : 'A');
		opchar(((word2>>12)&7)+'0');
		opchar('.');
		opchar((word2&0x800)==0 ? 'W' : 'L');
		opchar(')');
		break;
	case 7:
		switch(reg)
		{
		case 0:
			garbage=nextword();
			if (garbage>=0x8000)
			{
				garbage|=0xFFFF0000L;
			}
			opaddr(garbage);
			opchar('.');
			opchar('W');
			break;
		case 1:
			opaddr(((unsigned long)nextword()<<16)+nextword());
			break;
		case 2:
			garbage=nextword();
			if (garbage>=0x8000)
			{
				garbage|=0xFFFF0000L;
			}
			opaddr(garbage+codeaddress-2);

			opstring("(PC)");
			break;
		case 3:
			word2=nextword();

			garbage=word2&255;
			if (garbage>=0x80)
			{
				garbage|=0xFFFFFF00L;
			}
			opaddr(garbage+codeaddress-2);	/* … v‚rifier */

			opstring("(PC,");
			opchar((word2&0x8000)==0 ? 'D' : 'A');
			opchar(((word2>>12)&7)+'0');
			opchar('.');
			opchar((word2&0x800)==0 ? 'W' : 'L');
			opchar(')');
			break;
		case 4:
			opchar('#');
			switch(srckind)
			{
				case 0:
					opaddr(nextword()); 	/* d‚sassembler tel quel */
					break;
				case 1:
					opaddr(nextword());
					break;
				case 2:
					opaddr(((unsigned long)nextword()<<16)+nextword());
					break;
				default:
					internal(2);
			}
			break;
		case 5:
		case 6:
		case 7:
			internal(19);
		default:
			internal(3);
		}
		break;
	default:
		internal(4);
	}
}

void conditioncode(int cc)
{
	UCHAR *codes = "RASRHILSCCCSNEEQVCVSPLMIGELTGTLE";
	if (cc>1 || ((word>>12)&15)==6)
	{
		opchar(codes[cc<<1]);
		opchar(codes[(cc<<1)+1]);
	}
	else
	{
		if (cc==0)
		{
			opchar('T');
		}
		else
		{
			opchar('F');
		}
	}
}

void startrange(int bit)
{
	operand(bit<=7 ? 0 : 1, bit&7);
}

void endrange(int first,int bit)
{
	if (first<=7 && bit>7)
	{
		endrange(first,7);
		opchar('/');
		startrange(8);
		first=8;
	}
	if (bit>first)
	{
		opchar('-');
		startrange(bit);
	}
}

void registerlist(int kkkk,int mask)
{
	int bit=0;
	int inrange=-1;
	int some=0;
	while (bit<=15)
	{
		if ((kkkk ? (mask>>(15-bit)) : (mask>>bit) ) & 1 )
		{
			if (inrange<0)
			{
				if (some)
				{
					opchar('/');
				}
				startrange(bit);
				some=1;
				inrange=bit;
			}
		}
		else
		{
			if (inrange>=0)
			{
				endrange(inrange,bit-1);
				inrange=-1;
			}
		}
		bit++;
	}
	if (inrange>=0)
	{
		endrange(inrange,15);
	}
}

/*
	instruction type 0x0nnn

	liste des instructions :

	tt=taille 00=B,01=W,10=L,11=bug
	ccc=registre

		mmm	rrr
		000 n		Dn
		001			bug
		010	n		(An)
		011	n		(An)+
		100	n		-(An)
		101	n		d(An)
		110	n		d(An,Xi)
		111	000		abs.w
		111	001		abs.l

		111	010		d(pc)	;pour BTST
		111 011		d(pc,Xi);pour BTST
		111	100		#		;pour BTST
		111	autres	bug

				0000                ext		dreg	sreg	smod

	ORI			00000000ttmmmrrr	0tt		000		rrr		mmm		*
	ANDI		00000010ttmmmrrr	0tt		001		rrr     mmm		*
	SUBI		00000100ttmmmrrr	0tt		010		rrr     mmm     *
	ADDI		00000110ttmmmrrr	0tt		011     rrr     mmm     *
	EORI		00001010ttmmmrrr	0tt		101     rrr     mmm     *
	CMPI 		00001100ttmmmrrr	0tt		110     rrr     mmm     *

	ORI to CCR	0000000000111100	000		000		100     111     *
	ORI to SR	0000000001111100	001		000		100     111     *
	ANDI to CCR 0000001000111100	000		001		100     111     *
	ANDI to SR	0000001001111100	001		001		100     111     *
	EORI to CCR	0000101000111100	000		101		100     111     *
	EORI to SR	0000101001111100	001		101		100     111     *

	BTST #		0000100000mmmrrr	000		100						*
	BCHG #		0000100001mmmrrr	001		100						*
	BCLR #		0000100010mmmrrr	010		100                     *
	BSET #		0000100011mmmrrr	011		100                     *

	BTST Dn		0000ccc100mmmrrr	100		ccc
	BCHG Dn,	0000ccc101mmmrrr	101		ccc
	BCLR Dn,	0000ccc110mmmrrr	110		ccc
	BSET Dn		0000ccc111mmmrrr	111		ccc

	MOVEP		0000ccc1pp001aaa	1pp		ccc

	ppp
	00	MOVEP.W d(An),Dn
	01	MOVEP.L d(An),Dn
	10	MOVEP.W	Dn,d(An)
	11	MOVEP.L Dn,d(An)

*/
void handle0(void)
{
	int ext=(word>>6)&7;
	int dreg=(word>>9)&7;
	int smod=(word>>3)&7;
	int sreg=word&7;
	static UCHAR *opzero[8]={"ORI","ANDI","SUBI","ADDI","","EORI","CMPI",""};
	static UCHAR *opone[4]={"BTST","BCHG","BCLR","BSET"};

	if (ext<=2 && dreg!=4)
	{
		/* ORI,ANDI,SUBI,ADDI,EORI,CMPI */

		if ( (dreg==7) ||
			 (smod==1) ||
			 (smod==7 && (sreg>=2 && sreg!=4)) ||
			 (smod==7 && sreg==4 && ext>=2) ||
			 (smod==7 && sreg==4 && dreg!=0 && dreg!=1 && dreg!=5) )
		{
			dcw();
			return;
		}

		opstring(opzero[dreg]);
		sourcekind(ext);
		padd();
		operand(7,4);
		opchar(',');

		if (smod==7 && sreg==4)
		{
			opstring(srckind==0 ? "CCR" : "SR");
		}
		else
		{
			operand(smod,sreg);
		}
		return;
	}

	if (ext<=3)
	{
		/* BTST #,BCHG #,BCLR #,BSET # */

		if ( (dreg!=4) ||
			 (smod==1) ||
			 (smod==7 && sreg>=2 && ext!=0) ||
			 (smod==7 && sreg>=4 && ext==0) )
		{
			dcw();
			return;
		}
		opstring(opone[ext]);
		padd();
		srckind=0;
		operand(7,4);
		opchar(',');
		srckind=1;
		operand(smod,sreg);
		return;
	}

	if (ext<=3)
	{
		internal(71);
	}

	if (smod!=1)
	{
		/* BTST Dn,BCHG Dn,BCLR Dn,BSET Dn */

		if ( (smod==7 && sreg>=2 && ext!=4) ||
			 (smod==7 && sreg>=5 && ext==4) )
		{
			dcw();
			return;
		}
		opstring(opone[ext-4]);
		padd();
		srckind=0;
		operand(0,dreg);
		opchar(',');
		srckind=1;
		operand(smod,sreg);
		return;
	}

	/* dernier cas : MOVEP */

	opstring("MOVEP");
	sourcekind((ext&1)+1);
	padd();
	if (ext<=5)
	{
		operand(5,sreg);
		opchar(',');
		operand(0,dreg);
	}
	else
	{
		operand(0,dreg);
		opchar(',');
		operand(5,sreg);
	}
}
/*
	MOVE
	instructions type :

	%00ttrrrmmmmmmrrr
*/
void moveinstruction(void)
{
	int kind=(word>>12)&15;
	int m1=(word>>6)&7;
	int m2=(word>>3)&7;
	int r1=(word>>9)&7;
	int r2=word&7;

	if ( (m2==7 && r2>=5) ||
		 (m1==7 && r1>=2) ||
		 (m2==1 && kind==1) ||
		 (m1==1 && kind==1))
	{
		dcw();
		return;
	}

	opstring("MOVE");
	if (m1==1)
	{
		opchar('A');
	}
	sourcekind(kind==1 ? 0 : (kind==2 ? 2 : 1));
	padd();
	operand(m2,r2);
	opchar(',');
	operand(m1,r1);
}

/*
	instructions type : 0x4nnn

	aaa=registre
	mmm	rrr
	000	n		Dn
	001	n		An
	010	n		(An)
	011	n		(An)+
	100	n		-(An)
	101	n		d(An)
	110	n		d(An,Xi)
	111	000		addr.W
	111	001		addr.L
	111	010		d(PC)
	111	011		d(PC,Xi)
	111	100		#imm

	tt
	00	.B
	01	.W
	10	.L

* ext<=2 et (dreg<=3 ou dreg==5)
*	CLR			01000010ttmmmrrr	mmm<>1 et rrr<2 si mmm=7
*	NEG     	01000100ttmmmrrr	mmm<>1 et rrr<2 si mmm=7
*	NEGX        01000000ttmmmrrr	mmm<>1 et rrr<2 si mmm=7
*	NOT			01000110ttmmmrrr	mmm<>1 et rrr<2 si mmm=7
*	TST			01001010ttmmmrrr	mmm<>1 et rrr<2 si mmm=7

* ext<=3 et dreg==4
*	NBCD		0100100000mmmrrr	mmm<>1 et rrr<2 si mmm=7
*	PEA			0100100001mmmrrr	mmm=2,5,6,7 et rrr<4 si mmm=7
*	SWAP		0100100001000aaa
*	EXT			010010001u000aaa	u=0 ->.W u=1->.L
*	MOVEM		01001w001xmmmrrr	w=0 -> reg,mem w=1 -> mem,reg
									x=0 -> .W x=1 -> .L
									si w=0
									mmm=2,4,5,6,7 et rrr<2 si mmm=7
									si w=1
									mmm=2,3,5,6,7 et rrr<4 si mmm=7

* ext=001 et dreg=7
*	TRAP		010011100100bbbb	bbbb=vecteur
*	LINK		0100111001010aaa
*	UNLK		0100111001011aaa
*	MOVE USP   	010011100110vaaa	v=0 An,USP v=1 USP,An
*	RESET		0100111001110000
*	NOP			0100111001110001
*	STOP		0100111001110010
*	RTE			0100111001110011
*	RTS			0100111001110101
*	TRAPV		0100111001110110
*	RTR			0100111001110111

* ext=010
*	JSR			0100111010mmmrrr	mmm=2,5,6 ou 7 et rrr<4 si mmm=7
* ext=011
*	MOVE SR		0100000011mmmrrr	mmm<>1 et rrr<2 si mmm=7
*	MOVE to CCR	0100010011mmmrrr	mmm<>1 et rrr<5 si mmm=7
*	MOVE to SR	0100011011mmmrrr	mmm<>1 et rrr<5 si mmm=7
*	TAS			0100101011mmmrrr	mmm<>1 et rrr<2 si mmm=7
*	ILLEGAL		0100101011111100
*	JMP			0100111011mmmrrr	mmm=2,5,6 ou 7 et rrr<4 si mmm=7
* ext=110
*	CHK         0100aaa110mmmrrr	mmm<>1 et rrr<5 si mmm=7
* ext=111
*	LEA         0100aaa111mmmrrr	mmm=2,5,6 ou 7 et rrr<4 si mmm=7

*/
void handle4(void)
{
	int ext=(word>>6)&7;
	int dreg=(word>>9)&7;
	int smod=(word>>3)&7;
	int sreg=word&7;
	int reglist;

	static UCHAR *unaryA[]={"NEGX","CLR","NEG","NOT","","TST"};
	static UCHAR *cross4[]={"NBCD","PEA","MOVEM.W","MOVEM.L",
						   "NBCD","SWAP","EXT.W","EXT.L"};
	static UCHAR *jumps[] = {"JSR","JMP"};

	if (ext<=2 && (dreg<=3 || dreg==5))
	{
		/* NEGX,CLR,NEG,NOT,TST OK !!!*/
		if ( (smod==1) ||
			 (smod==7 && sreg>=2) )
		{
			dcw();
			return;
		}
		opstring(unaryA[dreg]);
		sourcekind(ext);
		padd();
		operand(smod,sreg);
		return;
	}

	if (ext<=3 && dreg==4)
	{
		/* NBCD PEA SWAP EXT MOVEM  OK !!!*/
		if ( (ext==0 && smod==7 && sreg>=2) ||
			 (ext==0 && smod==1) ||
			 (ext==1 && (smod==1 || smod==3 || smod==4)) ||
			 (ext==1 && smod==7 && sreg>=4) ||
			 (ext>=2 && (smod==1 || smod==3)) ||
			 (ext>=2 && smod==7 && sreg>=2) )
		{
			dcw();
			return;
		}

		opstring(cross4[smod==0 ? ext+4 : ext]);
		padd();
		if (ext>=2 && smod!=0)
		{
			registerlist(smod==4,nextword());
			opchar(',');
		}
		operand(smod,sreg);
		return;
	}

	if (ext<=1)
	{
		/* TRAP,UNLK,MOVE USP,RESET,NOP,STOP,RTE,RTS,TRAPV,RTR */

		if ( (ext==0) ||
			 (ext==1 && dreg!=7) ||
			 (smod==7) ||
			 (smod==6 && sreg==4) )
		{
			dcw();
			return;
		}

		switch (smod)
		{
		case 0:
		case 1:
			opstring("TRAP");
			padd();
			opchar('#');
			if ((word&15)>10)
			{
				opchar('1');
				opchar((word&15)-10+'0');
			}
			else
			{
				opchar((word&15)+'0');
			}
			return;
		case 2:
			opstring("LINK");
			padd();
			operand(1,sreg);
			opchar(',');
			srckind=1;
			operand(7,4);
			return;
		case 3:
			opstring("UNLK");
			padd();
			operand(1,sreg);
			return;
		case 4:
			opstring("MOVE.L");
			padd();
			operand(1,sreg);
			opstring(",USP");
			return;
		case 5:
			opstring("MOVE.L");
			padd();
			opstring("USP,");
			operand(1,sreg);
			return;
		case 6:
			switch (sreg)
			{
			case 0:
				opstring("RESET");
				return;
			case 1:
				opstring("NOP");
				return;
			case 2:
				opstring("STOP");
				padd();
				srckind=1;
				operand(7,4);
				return;
			case 3:
				opstring("RTE");
				return;
			case 5:
				opstring("RTS");
				return;
			case 6:
				opstring("TRAPV");
				return;
			case 7:
				opstring("RTR");
				return;
			default:
				internal(8);
			}
		default:
			internal(7);
		}
		internal(14);
	}

	if (ext==4 || ext==5)
	{
		dcw();
		return;
	}

	if (ext==2 || ext==3)
	{
		if (dreg==6)
		{
			/* MOVEM OK !!!*/

			if ( (smod==7 && sreg>=4) ||
				 (smod==0 || smod==1 || smod==4) )
			{
				dcw();
				return;
			}

			opstring(cross4[ext]);
			padd();
			reglist=nextword();
			operand(smod,sreg);
			opchar(',');
			registerlist(0,reglist);
			return;
		}
		if (dreg==7)
		{
			/* JSR ou JMP OK !!! */

			if ( (smod==7 && sreg>=4) ||
				 (smod==0 || smod==1 || smod==3 || smod==4) )
			{
				dcw();
				return;
			}
			opstring(jumps[ext-2]);
			padd();
			operand(smod,sreg);
			return;
		}

		if (ext!=3)
		{
			internal(22);
		}

		/* MOVE SR,MOVE to CCR,MOVE to SR,TAS,ILLEGAL  OK !!!*/

		switch (dreg)
		{
		case 0:
			if ( (smod==1) ||
				 (smod==7 && sreg>=2) )
			{
				dcw();
				return;
			}
			opstring("MOVE");
			padd();
			opstring("SR,");
			operand(smod,sreg);
			return;
		case 1:
			dcw();
			return;
		case 2:
			if ( (smod==1) ||
				 (smod==7 && sreg>=5) )
			{
				dcw();
				return;
			}
			opstring("MOVE");
			padd();
			srckind=0;
			operand(smod,sreg);
			opstring(",CCR");
			return;
		case 3:
			if ( (smod==1) ||
				 (smod==7 && sreg>=5) )
			{
				dcw();
				return;
			}
			opstring("MOVE");
			padd();
			srckind=1;
			operand(smod,sreg);
			opstring(",SR");
			return;
		case 5:
			if ( (smod==1) ||
				 (smod==7 && (sreg>=5 || sreg==3 || sreg==2)) )
			{
				dcw();
				return;
			}
			if (word==0x4AFC) 			/* smod==7 && sreg=4 */
			{
				opstring("ILLEGAL");
				return;
			}
			opstring("TAS");
			padd();
			operand(smod,sreg);
			return;
		default:
			internal(9);
		}
		internal(13);
	}

	if (ext==7)
	{
		/* LEA OK !!! */
		if ( (smod==0 || smod==1 || smod==3 || smod==4) ||
			 (smod==7 && sreg>=4) )
		{
			dcw();
			return;
		}
		opstring("LEA");
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(1,dreg);
		return;
	}

	if (ext==6)
	{
		/* CHK OK !!! */
		if ( (smod==1) ||
			 (smod==7 && sreg>=5) )
		{
			dcw();
			return;
		}
		opstring("CHK");
		padd();
		srckind=1;
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}
	internal(21);
}

/* jusqu'ici tout est OK */

/*
	ddd=donn‚e (0=8)
	aaa=registre
	cond=condition

	tt
	00	.B
	01	.W
	10	.L

	0x5nnn

	ADDQ	0101ddd0ttmmmrrr	mmm=7 et rrr<2
	SUBQ	0101ddd1ttmmmrrr	mmm=7 et rrr<2
	DBcc	0101cond11001aaa
	Scc		0101cond11mmmrrr	mmm<>1 et si mmm=7 rrr<2

	0x6nnn

	Bcc		0110condnnnnnnnn
	BRA		01100000nnnnnnnn
	BSR		01100001nnnnnnnn

	0x7nnn

	MOVEQ	0111aaa0nnnnnnnn
*/

void handle5(void)
{
	int ext=(word>>6)&3;
	int dreg=(word>>9)&7;
	int smod=(word>>3)&7;
	int sreg=(word&7);
	unsigned long garbage;

	if (ext<=2)
	{
		/* ADDQ,SUBQ */

		if ( (smod==7 && sreg>=2) ||
			 (ext==0 && smod==1) )
		{
			dcw();
			return;
		}
		opstring((word&0x100)==0 ? "ADDQ" : "SUBQ");
		sourcekind(ext);
		padd();
		opchar('#');
		opchar(dreg==0 ? '8' : dreg+'0');
		opchar(',');
		operand(smod,sreg);
		return;
	}
	if (ext!=3)
	{
		internal(22);
	}

	if (smod==1)
	{
		/* DBcc */
		opstring("DB");
		conditioncode((word>>8)&15);
		padd();
		operand(0,sreg);
		opchar(',');
		garbage=nextword();
		if (garbage>=0x8000)
		{
			garbage|=0xFFFF0000L;
		}
		opaddr(garbage+codeaddress-2);
		return;
	}

	/* Scc */
	if (smod==7 && sreg>=2)
	{
		dcw();
		return;
	}
	opchar('S');
	conditioncode((word>>8)&15);
	padd();
	operand(smod,sreg);
}

void handle6(void)
{
	unsigned long garbage;
	/* Bcc */
	opchar('B');
	conditioncode((word>>8)&15);
	if ( (word&0xFF)!=0 )
	{
		opchar('.');
		opchar('S');
	}
	padd();
	if ( (word&0xFF)==0 )
	{
		garbage=nextword();
		if (garbage>=0x8000)
		{
			garbage|=0xFFFF0000L;
		}
		opaddr(garbage+codeaddress-2);
	}
	else
	{
		garbage=word&0xFF;
		if (garbage>=0x80)
		{
			garbage|=0xFFFFFF00L;
		}
		opaddr(garbage+codeaddress);	/* … v‚rifier */
	}
	if ((word&1)!=0)
	{
		opstring(" ;Warning odd address");
	}
}

void handle7(void)
{
	if ( (word&0x100)!=0 )
	{
		dcw();
		return;
	}
	opstring("MOVEQ");
	padd();
	opchar('#');
	opbyte(word&0xFF);
	opchar(',');
	operand(0,(word>>9)&7);
}

/*
	type :
	0x8nnn

*	DIVU	1000aaa011mmmrrr	mmm<>1 et (si mmm=7 rrr<5)
*	DIVS	1000aaa111mmmrrr	mmm<>1 et (si mmm=7 rrr<5)
*	OR		1000aaapppmmmrrr	si ,Dn mmm<>1 et si mmm=7 rrr<5
								si Dn, mmm<>0 et mmm<>1 et si mmm=7 rrr<2
								ppp
								000	.B ,Dn
								001	.W ,Dn
								010 .L ,Dn
								100 .B Dn,
								101 .W Dn,
								110 .L Dn,
*	SBCD	1000aaa10000qbbb	q=0 SBCD Dbbb,Daaa
								q=1 SBCD -(Abbb),-(Aaaa)
*/
void handle8(void)
{
	int ext=(word>>6)&7;
	int dreg=(word>>9)&7;
	int smod=(word>>3)&7;
	int sreg=word&7;

	if (ext==3 || ext==7)
	{
		/* DIVS,DIVU */
		if ( (smod==1) ||
			 (smod==7 && sreg>=5))
		{
			dcw();
			return;
		}
		opstring(ext==3 ? "DIVU" : "DIVS");
		padd();
		srckind=1;
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}

	if (ext==4 && smod<=1)
	{
		/* SBCD */
		opstring("SBCD");
		padd();
		if (smod==0)
		{
			operand(0,sreg);
			opchar(',');
			operand(0,dreg);
			return;
		}
		else
		{
			operand(4,sreg);
			opchar(',');
			operand(4,dreg);
			return;
		}
	}

	/* OR */
	if (ext<4)
	{
		/* OR ,Dn */
		if ( (smod==1) ||
			 (smod==7 && sreg>=5) )
		{
			dcw();
			return;
		}
		opstring("OR");
		sourcekind(ext);
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}
	/* OR Dn, */
	if ( (smod==0 || smod==1) ||
		 (smod==7 && sreg>=2) )
	{
		dcw();
		return;
	}
	opstring("OR");
	sourcekind(ext&3);
	padd();
	operand(0,dreg);
	opchar(',');
	operand(smod,sreg);
}
/*
	type :
	0x9nnn et 0xDnnn

*	SUB		1001aaapppmmmrrr
*	SUBA	1001aaapppmmmrrr
*	SUBX	1001aaa1tt00xbbb

*	ADD		1101aaapppmmmrrr
								ppp
								000	.B ,Dn
								001	.W ,Dn
								010	.L ,Dn
								100	.B Dn,
								101	.W Dn,
								110 .L Dn,
							si ppp<4
								si mmm=1 ppp<>0
								si mmm=7 rrr<5
							si ppp>4
								mmm<>0,mmm<>1
								si mmm=7 rrr<2
*	ADDA	1101aaapppmmmrrr
								ppp
								011	.W ,An
								111	.L ,An
								si mmm=7 rrr<5
*	ADDX	1101aaa1tt00xbbb
								tt
								00	.B
								01	.W
								10	.L

								x
								0	ADDX Dbbb,Daaa
								1	ADDX -(Abbb),-(Aaaa)

*/
void handle9_13(void)
{
	int dreg=(word>>9)&7;
	int ext=(word>>6)&7;
	int smod=(word>>3)&7;
	int sreg=word&7;

	if (ext==3 || ext==7)
	{
		/* ADDA ou SUBA */
		if (smod==7 && sreg>=5)
		{
			dcw();
			return;
		}
		opstring(((word>>12)&0xF)==9 ? "SUBA" : "ADDA");
		sourcekind((ext>>2)+1);
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(1,dreg);
		return;
	}
	/* ADD ou ADDX ou SUB ou SUBX */

	if (ext>=4 && smod<=1)
	{
		/* ADDX ou SUBX */
		opstring(((word>>12)&0xF)==9 ? "SUBX" : "ADDX");
		sourcekind(ext&3);
		padd();
		if (smod==0)
		{
			operand(0,sreg);
			opchar(',');
			operand(0,dreg);
		}
		else
		{
			operand(4,sreg);
			opchar(',');
			operand(4,dreg);
		}
		return;
	}

	/* ADD ou SUB */
	if (ext<4)
	{
		/* ADD ou SUB ,Dn */
		if ( (smod==1 && ext==0) ||
			 (smod==7 && sreg>=5) )
		{
			dcw();
			return;
		}
		opstring(((word>>12)&0xF)==9 ? "SUB" : "ADD");
		sourcekind(ext);
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}
	/* ADD ou SUB Dn, */
	if (smod==7 && sreg>=2)
	{
		dcw();
		return;
	}
	opstring(((word>>12)&0xF)==9 ? "SUB" : "ADD");
	sourcekind(ext&3);
	padd();
	operand(0,dreg);
	opchar(',');
	operand(smod,sreg);
	return;
}
/*
	type :
	0xBnnn

*	CMP		1011aaapppmmmrrr
								ppp
								000	.B ,Dn
								001	.W ,Dn
								010	.L ,Dn
								si mmm=1 ppp<>0
								si mmm=7 rrr<5
*	CMPA	1011aaapppmmmrrr
								ppp
								011	.W ,An
								111 .L ,An
								si mmm=7 rrr<5
*	CMPM    1011aaa1tt001bbb
								tt
								00	CMPM.B (Abbb)+,(Aaaa)+
								01	CMPM.W (Abbb)+,(Aaaa)+
								10	CMPM.L (Abbb)+,(Aaaa)+
	EOR		1011aaapppmmmrrr
								ppp
								100	.B Dn,
								101	.W Dn,
								110	.L Dn,
								mmm<>1
								si mmm=7 rrr<2
*/
void handle11(void)
{
	int dreg=(word>>9)&7;
	int ext=(word>>6)&7;
	int smod=(word>>3)&7;
	int sreg=word&7;

	if (ext==3 || ext==7)
	{
		/* CMPA */
		if (smod==7 && sreg>=5)
		{
			dcw();
			return;
		}
		opstring("CMPA");
		sourcekind((ext>>2)+1);
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(1,dreg);
		return;
	}

	if (ext<4)
	{
		/* CMP */
		if ( (smod==1 && ext==0) ||
			 (smod==7 && sreg>=5) )
		{
			dcw();
			return;
		}
		opstring("CMP");
		sourcekind(ext);
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}

	/* CMPM ou EOR */
	if (smod==1)
	{
		/* CMPM */
		opstring("CMPM");
		sourcekind(ext&3);
		padd();
		operand(3,sreg);
		opchar(',');
		operand(3,dreg);
		return;
	}

	/* EOR */
	if (smod==7 && sreg>=2)
	{
		dcw();
		return;
	}
	opstring("EOR");
	sourcekind(ext&3);
	padd();
	operand(0,dreg);
	opchar(',');
	operand(smod,sreg);
}
/*
	type :
	0xCnnn

*	ABCD	1100aaa10000xbbb
								x
								0	ABCD Dbbb,Daaa
								1	ABCD -(Abbb),-(Aaaa)
*	AND		1100aaapppmmmrrr
								ppp
								000	AND.B ,Dn
								001	AND.W ,Dn
								010	AND.L ,Dn
								100	AND.B Dn,
								101	AND.W Dn,
								110 AND.L Dn,
							si ppp<4
								mmm<>1
								si mmm=7 rrr<5
							si ppp>=4
								mmm<>0
								mmm<>1
								si mmm=7 rrr<2
*	EXG		1100aaa1qqqqqbbb
								qqqq
								01000	EXG Dbbb,Daaa
								01001	EXG Abbb,Aaaa
								10001	EXG Dbbb,Aaaa
*	MULS	1100aaa111mmmrrr
								mmm<>1
								si mmm=7 rrr<5
*	MULU	1100aaa011mmmrrr
								mmm<>1
								si mmm=7 rrr<5
*/
void handle12(void)
{
	int dreg=(word>>9)&7;
	int ext=(word>>6)&7;
	int smod=(word>>3)&7;
	int sreg=word&7;

	if (ext==3 || ext==7)
	{
		/* MULS ou MULU */
		if ( (smod==1) ||
			 (smod==7 && sreg>=5) )
		{
			dcw();
			return;
		}
		opstring(ext==3 ? "MULU" : "MULS");
		padd();
		srckind=1;
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}

	if (ext==4 && smod<=1)
	{
		/* ABCD */
		opstring("ABCD");
		padd();
		if (smod==0)
		{
			operand(0,sreg);
			opchar(',');
			operand(0,dreg);
		}
		else
		{
			operand(4,sreg);
			opchar(',');
			operand(4,dreg);
		}
		return;
	}

	if (ext<4)
	{
		/* AND ,Dn */
		if ( (smod==1) ||
			 (smod==7 && sreg>=5) )
		{
			dcw();
			return;
		}
		opstring("AND");
		sourcekind(ext);
		padd();
		operand(smod,sreg);
		opchar(',');
		operand(0,dreg);
		return;
	}

	if (smod<=1)
	{
		/* EXG */
		if ( (smod==0 && ext!=5) ||
			 (smod==1 && ext!=5 && ext!=6) )
		{
			dcw();
			return;
		}
		opstring("EXG");
		padd();
		if (smod==0 && ext==5)
		{
			operand(0,dreg);
			opchar(',');
			operand(0,sreg);
			return;
		}
		if (smod==1 && ext==5)
		{
			operand(1,sreg);
			opchar(',');
			operand(1,dreg);
			return;
		}
		if (smod==1 && ext==6)
		{
			operand(0,dreg);
			opchar(',');
			operand(1,sreg);
			return;
		}
		internal(23);
	}

	/* AND */

	if (smod==7 && sreg>=2)
	{
		dcw();
		return;
	}
	opstring("AND");
	sourcekind(ext&3);
	padd();
	operand(0,dreg);
	opchar(',');
	operand(smod,sreg);
	return;
}
/*
	type :
	0xEnnn

	i
	0	#aaa,Dbbb
	1	Daaa,Dbbb

	mmm<>0 && mmm<>1
	si mmm=7 -> rrr<2

	ASL		1110aaa1tti00bbb
			1110000111mmmrrr
	ASR		1110aaa0tti00bbb
			1110000011mmmrrr
	LSL		1110aaa1tti01rrr
			1110001111mmmrrr
	LSR		1110aaa0tti01bbb
			1110001011mmmrrr
	ROL		1110aaa1tti11bbb
			1110011111mmmrrr
	ROR		1110aaa0tti11bbb
			1110011011mmmrrr
	ROXL    1110aaa1tti10bbb
			1110010111mmmrrr
	ROXR	1110aaa0tti10bbb
			1110010011mmmrrr

*/
void shiftinstruction(void)
{
	static UCHAR *mnemonics[8]={"ASR","ASL","LSR","LSL","ROXR","ROXL","ROR","ROL"};

	int dreg=(word>>9)&7;
	int ext=(word>>6)&3;
	int smod=(word>>3)&7;
	int sreg=word&7;

	if (ext==3)
	{
		/* d‚calage m‚moire */
		if ( (smod==0 || smod==1) ||
			 (smod==7 && sreg>=2) ||
			 (dreg>=4) )
		{
			dcw();
			return;
		}
		opstring(mnemonics[(dreg<<1)+((word>>8)&1)]);
		padd();
		operand(smod,sreg);
		return;
	}
	/* d‚calage registre */

	opstring(mnemonics[((smod&3)<<1)+((word>>8)&1)]);
	sourcekind(ext);
	padd();
	if ((word&0x20)==0)
	{
		opchar('#');
		opchar(dreg==0 ? '8' : '0'+dreg);
	}
	else
	{
		operand(0,dreg);
	}
	opchar(',');
	operand(0,sreg);
}

void decode()
{
	int n=6;
	UCHAR c;

	if (dcb==0)
	{
		q=opline;
		p=opline+MARGE1;
		while (n-->0)
		{
			c=(codeaddress>>(n<<2)) & 0xF;
			*q++= (c<=9) ? c+'0' : c-10+'A';
		}
		*q++=' ';
	}

	if (passe!=0 && dcb!=0)
	{
		for (n=0;n<nblabels;n++)
		{
			if (codeaddress==label[n])
			{
				break;
			}
		}
		if (n<nblabels)
		{
			dcb=0;
			return;
		}
	}

	if (firstpasse!=0 || passe!=0)
	{
		/* on recherche si PC est inclus dans les datas */
		for (n=0;n<nbseg;n++)
		{
			if (codeaddress>=segment_debut[n] && codeaddress<segment_fin[n])
			{
				break;
			}
		}
		if (n<nbseg)
		{
			dcbyte();
			dcb++;
			if (dcb==8)
			{
				dcb=0;
			}
			return;
		}
	}
	if (dcb!=0)
	{
		dcb=0;
		return;
	}

	word=nextword();
	srckind=-1;
	switch ((word>>12)&15)
	{
	case 0:
		handle0();					/* OK */
		break;
	case 1:
	case 2:
	case 3:
		moveinstruction();			/* OK */
		break;
	case 4:
		handle4();					/* OK */
		break;
	case 5:
		handle5();					/* OK */
		break;
	case 6:
		handle6();					/* OK */
		break;
	case 7:
		handle7();					/* OK */
		break;
	case 8:
		handle8();					/* OK */
		break;
	case 9:
	case 13:
		handle9_13();				/* OK */
		break;
	case 11:
		handle11();					/* OK */
		break;
	case 12:
		handle12();					/* OK */
		break;
	case 14:
		shiftinstruction();
		break;
	case 10:
	case 15:
		dcw();
		break;
	default:
		internal(10);
	}
}
