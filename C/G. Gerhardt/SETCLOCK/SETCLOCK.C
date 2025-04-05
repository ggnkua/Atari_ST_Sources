/**************************************/
/*                                    */
/* SETCLOCK.C ist PD-SOURCE-SOFTWARE  */
/*                                    */
/*         by G. Gerhardt             */
/*            Siekhammer 34           */
/*            4930  Detmold           */
/*                                    */
/**************************************/

#include <osbind.h>

char line[11];

int linepos;

writechr(c)
char c;
{
    if (c=='\n') Bconout(2,'\r');
    Bconout(2,c);
}

writestr(line)
char *line;
{
    while (*line) writechr(*line++);
}

readline(maxlen)
int maxlen;
{
    int ptr;
    char c;

    ptr=0;
    writestr("\033e");
    do
    {
        do c=Crawcin(); while ((c&0xff)<' ' && c!='\b' && c!='\r');
        if (c=='\b' && ptr)
        {
            writestr("\b \b");ptr--;
        }
        if ((c&0xff)>=' ' && ptr<maxlen)
        {
            writechr(c);line[ptr++]=c;
        }
    }
    while (c!='\r');
    writestr("\n\033f");
    line[ptr]=0;
    linepos=0;
}

int scannum()
{
    int val,found;
    char c;

    val=found=0;
    do
    {
        c=line[linepos++];
        if (c>='0' && c<='9')
        {
            val=val*10+c-'0';
            found=1;
        }
        else
        {
            if (found) found++;
        }
    }
    while (c && found<2);
    if (!c) linepos--;
    return(found ? val : -1);
}

int getdate()
{
    int t,m,j;

    readline(10);
    t=scannum();
    m=scannum();
    j=scannum();
    if (j==-1) j=87;
    if (j>99) j%=100;
    if (j<87) j+=100;
    if (t>0 && t<32 && m>0 && m<13)
        return(t&31)|((m&15)<<5)|(((j-80)&127)<<9);
    else
        if ((Gettime()>>16)&31L)
            return(Gettime()>>16);
        else
            return(0x0c46);
}

int gettime()
{
    int h,m,s;

    readline(10);
    h=scannum();
    m=scannum();
    s=scannum();
    if (s==-1) s=0;
    if (h>=0 && h<24 && m>=0 && m<60 && s>=0 && s<60)
        return(((s>>1)&31)|((m&63)<<5)|((h&31)<<11));
    else
        return(Gettime());
}

main()
{
    int d,t;

    writestr("\033E\nBitte Datum eingeben : ");
    d=getdate();
    Tsetdate(d);
    writestr("\nBitte Uhrzeit eingeben : ");
    t=gettime();
    Tsettime(t);
    Settime((long)d<<16|(long)t&0xffffL);
}

