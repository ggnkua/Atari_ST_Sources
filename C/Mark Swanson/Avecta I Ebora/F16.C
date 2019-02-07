extern int i16(pc)
int pc;
{
extern int vbl(),off();
xbios(37);
xbios(38,off);
raton();
form_alert(1,"[1][ZZZ... not implemented][OK]");
rausmaus();
xbios(37);
xbios(38,vbl);
return(0);
}

extern int o16(pc)
int pc;
{
return(1);
}
