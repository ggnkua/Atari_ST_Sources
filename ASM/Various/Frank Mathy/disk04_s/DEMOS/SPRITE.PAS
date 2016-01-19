PROGRAM Sprite;

TYPE clip = ARRAY[0..3] OF INTEGER;

VAR sprite:ARRAY[0..319] OF INTEGER;
    clp:clip;
    s1,s2:ARRAY[0..261] OF INTEGER;
    i,x,res:INTEGER;
    name:STRING;
    car:ARRAY[0..1919] OF INTEGER;
    phys:LONG_INTEGER;

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

PROCEDURE fsetsprite(x,y:INTEGER; VAR spr,save:INTEGER;
                     log:LONG_INTEGER; VAR clp:clip; h:INTEGER);
C;

PROCEDURE fclrsprite(VAR s:INTEGER; log:LONG_INTEGER; h:INTEGER);
C;

PROCEDURE Vsync;
XBIOS(37);

PROCEDURE binload(n:LONG_INTEGER; VAR s:INTEGER; b:LONG_INTEGER);
C;

FUNCTION sbeg(VAR n:STRING):LONG_INTEGER;
C;

FUNCTION Getrez:INTEGER;
XBIOS(4);

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; res:INTEGER);
XBIOS(5);

BEGIN
offmouse;
phys:=Physbase;
res:=Getrez;
Setscreen(-1,-1,0);
clp[0]:=0; clp[1]:=0; clp[2]:=319; clp[3]:=199;
sprite[0]:=$0000; sprite[1]:=$0000; sprite[2]:=$0000; sprite[3]:=$0000;
sprite[4]:=$0000; sprite[5]:=$0000; sprite[6]:=$0000; sprite[7]:=$0000;
sprite[8]:=$0000; sprite[9]:=$0000; sprite[10]:=$0000; sprite[11]:=$0000;
sprite[12]:=$0000; sprite[13]:=$0000; sprite[14]:=$0000; sprite[15]:=$0000;
sprite[16]:=$0000; sprite[17]:=$0000; sprite[18]:=$0000; sprite[19]:=$001F;
sprite[20]:=$001F; sprite[21]:=$001F; sprite[22]:=$001F; sprite[23]:=$001F;
sprite[24]:=$00FF; sprite[25]:=$00FF; sprite[26]:=$00FF; sprite[27]:=$00FF;
sprite[28]:=$00FF; sprite[29]:=$03FF; sprite[30]:=$03FF; sprite[31]:=$03FF;
sprite[32]:=$03FF; sprite[33]:=$03FF; sprite[34]:=$07FF; sprite[35]:=$03FF;
sprite[36]:=$03FF; sprite[37]:=$03FF; sprite[38]:=$03FF; sprite[39]:=$07FF;
sprite[40]:=$07FF; sprite[41]:=$07FF; sprite[42]:=$07FF; sprite[43]:=$07FF;
sprite[44]:=$0FFF; sprite[45]:=$0FC0; sprite[46]:=$0FC0; sprite[47]:=$0FC0;
sprite[48]:=$0FFF; sprite[49]:=$1FFF; sprite[50]:=$0FC0; sprite[51]:=$0FC0;
sprite[52]:=$0FC0; sprite[53]:=$0FFF; sprite[54]:=$1FFF; sprite[55]:=$1F80;
sprite[56]:=$1F80; sprite[57]:=$1F80; sprite[58]:=$1FFF; sprite[59]:=$3FFF;
sprite[60]:=$3F03; sprite[61]:=$3F03; sprite[62]:=$3F03; sprite[63]:=$3FFC;
sprite[64]:=$7FFF; sprite[65]:=$3E03; sprite[66]:=$3E03; sprite[67]:=$3E03;
sprite[68]:=$3FFC; sprite[69]:=$7FFF; sprite[70]:=$7E07; sprite[71]:=$7E07;
sprite[72]:=$7E07; sprite[73]:=$7FF8; sprite[74]:=$FFFF; sprite[75]:=$7C07;
sprite[76]:=$7C07; sprite[77]:=$7C07; sprite[78]:=$7FF8; sprite[79]:=$FFFF;
sprite[80]:=$3C07; sprite[81]:=$3C07; sprite[82]:=$3C07; sprite[83]:=$3FF8;
sprite[84]:=$7FFF; sprite[85]:=$7F07; sprite[86]:=$7F07; sprite[87]:=$7F07;
sprite[88]:=$7FF8; sprite[89]:=$FFFF; sprite[90]:=$7F00; sprite[91]:=$7F00;
sprite[92]:=$7F00; sprite[93]:=$7FFF; sprite[94]:=$FFFF; sprite[95]:=$7FC0;
sprite[96]:=$7FC0; sprite[97]:=$7FC0; sprite[98]:=$7FFF; sprite[99]:=$FFFF;
sprite[100]:=$7FC0; sprite[101]:=$7FC0; sprite[102]:=$7FC0; sprite[103]:=$7FFF;
sprite[104]:=$FFFF; sprite[105]:=$3FE0; sprite[106]:=$3FE0; sprite[107]:=$3FE0;
sprite[108]:=$3FFF; sprite[109]:=$FFFF; sprite[110]:=$1FF0; sprite[111]:=$1FF0;
sprite[112]:=$1FF0; sprite[113]:=$1FFF; sprite[114]:=$7FFF; sprite[115]:=$01FC;
sprite[116]:=$01FC; sprite[117]:=$01FC; sprite[118]:=$01FF; sprite[119]:=$0FFF;
sprite[120]:=$007F; sprite[121]:=$007F; sprite[122]:=$007F; sprite[123]:=$007F;
sprite[124]:=$01FF; sprite[125]:=$000F; sprite[126]:=$000F; sprite[127]:=$000F;
sprite[128]:=$000F; sprite[129]:=$00FF; sprite[130]:=$000F; sprite[131]:=$000F;
sprite[132]:=$000F; sprite[133]:=$000F; sprite[134]:=$001F; sprite[135]:=$0007;
sprite[136]:=$0007; sprite[137]:=$0007; sprite[138]:=$0007; sprite[139]:=$000F;
sprite[140]:=$0000; sprite[141]:=$0000; sprite[142]:=$0000; sprite[143]:=$0000;
sprite[144]:=$0007; sprite[145]:=$0000; sprite[146]:=$0000; sprite[147]:=$0000;
sprite[148]:=$0000; sprite[149]:=$0000; sprite[150]:=$0000; sprite[151]:=$0000;
sprite[152]:=$0000; sprite[153]:=$0000; sprite[154]:=$0000; sprite[155]:=$0000;
sprite[156]:=$0000; sprite[157]:=$0000; sprite[158]:=$0000; sprite[159]:=$0000;
sprite[160]:=$0000; sprite[161]:=$0000; sprite[162]:=$0000; sprite[163]:=$0000;
sprite[164]:=$0000; sprite[165]:=$0000; sprite[166]:=$0000; sprite[167]:=$0000;
sprite[168]:=$0000; sprite[169]:=$0000; sprite[170]:=$0000; sprite[171]:=$0000;
sprite[172]:=$0000; sprite[173]:=$0000; sprite[174]:=$0000; sprite[175]:=$0000;
sprite[176]:=$0000; sprite[177]:=$0000; sprite[178]:=$0000; sprite[179]:=$FFC0;
sprite[180]:=$FFC0; sprite[181]:=$FFC0; sprite[182]:=$FFC0; sprite[183]:=$FFC0;
sprite[184]:=$FFE0; sprite[185]:=$FFE0; sprite[186]:=$FFE0; sprite[187]:=$FFE0;
sprite[188]:=$FFE0; sprite[189]:=$FFF0; sprite[190]:=$FFE0; sprite[191]:=$FFE0;
sprite[192]:=$FFE0; sprite[193]:=$FFE0; sprite[194]:=$FFF0; sprite[195]:=$FFF0;
sprite[196]:=$FFF0; sprite[197]:=$FFF0; sprite[198]:=$FFF0; sprite[199]:=$FFF8;
sprite[200]:=$87F8; sprite[201]:=$87F8; sprite[202]:=$87F8; sprite[203]:=$FFF8;
sprite[204]:=$FFFC; sprite[205]:=$01FC; sprite[206]:=$01FC; sprite[207]:=$01FC;
sprite[208]:=$FFFC; sprite[209]:=$FFFE; sprite[210]:=$00FE; sprite[211]:=$00FE;
sprite[212]:=$00FE; sprite[213]:=$FFFE; sprite[214]:=$FFFF; sprite[215]:=$00FE;
sprite[216]:=$00FE; sprite[217]:=$00FE; sprite[218]:=$FFFE; sprite[219]:=$FFFF;
sprite[220]:=$C0FE; sprite[221]:=$C0FE; sprite[222]:=$C0FE; sprite[223]:=$3FFE;
sprite[224]:=$FFFF; sprite[225]:=$E0FE; sprite[226]:=$E0FE; sprite[227]:=$E0FE;
sprite[228]:=$1FFE; sprite[229]:=$FFFF; sprite[230]:=$C0FE; sprite[231]:=$C0FE;
sprite[232]:=$C0FE; sprite[233]:=$3FFE; sprite[234]:=$FFFF; sprite[235]:=$83FC;
sprite[236]:=$83FC; sprite[237]:=$83FC; sprite[238]:=$7FFC; sprite[239]:=$FFFE;
sprite[240]:=$87FC; sprite[241]:=$87FC; sprite[242]:=$87FC; sprite[243]:=$7FFC;
sprite[244]:=$FFFE; sprite[245]:=$8FF8; sprite[246]:=$8FF8; sprite[247]:=$8FF8;
sprite[248]:=$7FF8; sprite[249]:=$FFFC; sprite[250]:=$1FF8; sprite[251]:=$1FF8;
sprite[252]:=$1FF8; sprite[253]:=$FFF8; sprite[254]:=$FFFC; sprite[255]:=$1FE0;
sprite[256]:=$1FE0; sprite[257]:=$1FE0; sprite[258]:=$FFE0; sprite[259]:=$FFF8;
sprite[260]:=$0FC0; sprite[261]:=$0FC0; sprite[262]:=$0FC0; sprite[263]:=$FFC0;
sprite[264]:=$FFE0; sprite[265]:=$0F80; sprite[266]:=$0F80; sprite[267]:=$0F80;
sprite[268]:=$FF80; sprite[269]:=$FFC0; sprite[270]:=$0F00; sprite[271]:=$0F00;
sprite[272]:=$0F00; sprite[273]:=$FF00; sprite[274]:=$FF80; sprite[275]:=$0F00;
sprite[276]:=$0F00; sprite[277]:=$0F00; sprite[278]:=$FF00; sprite[279]:=$FF80;
sprite[280]:=$FF00; sprite[281]:=$FF00; sprite[282]:=$FF00; sprite[283]:=$FF00;
sprite[284]:=$FF80; sprite[285]:=$FE00; sprite[286]:=$FE00; sprite[287]:=$FE00;
sprite[288]:=$FE00; sprite[289]:=$FF00; sprite[290]:=$FE00; sprite[291]:=$FE00;
sprite[292]:=$FE00; sprite[293]:=$FE00; sprite[294]:=$FF00; sprite[295]:=$FE00;
sprite[296]:=$FE00; sprite[297]:=$FE00; sprite[298]:=$FE00; sprite[299]:=$FF00;
sprite[300]:=$FE00; sprite[301]:=$FE00; sprite[302]:=$FE00; sprite[303]:=$FE00;
sprite[304]:=$FF00; sprite[305]:=$1C00; sprite[306]:=$1C00; sprite[307]:=$1C00;
sprite[308]:=$1C00; sprite[309]:=$FE00; sprite[310]:=$0000; sprite[311]:=$0000;
sprite[312]:=$0000; sprite[313]:=$0000; sprite[314]:=$1C00; sprite[315]:=$0000;
sprite[316]:=$0000; sprite[317]:=$0000; sprite[318]:=$0000; sprite[319]:=$0000;

FOR x:=-32 TO 360 DO
        BEGIN
        fsetsprite(x-16,100,sprite[0],s1[0],$f8000,clp,31);
        fsetsprite(x,100,sprite[160],s2[0],$f8000,clp,31);
        Vsync;
        fclrsprite(s2[0],$f8000,31);
        fclrsprite(s1[0],$f8000,31);
        END;

name:='sprite.img';
binload(sbeg(name),car[0],3840);
FOR x:=0 TO 9 DO
    FOR i:=0 TO 23 DO
        BEGIN
        fsetsprite(160,100,car[i*80],s1[0],$f8000,clp,15);
        Vsync;
        Vsync;
        fclrsprite(s1[0],$f8000,15);
        END;
Setscreen(-1,-1,res);
onmouse;
END.
