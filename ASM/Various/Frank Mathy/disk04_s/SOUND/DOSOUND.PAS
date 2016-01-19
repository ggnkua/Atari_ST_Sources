PROGRAM sound;

TYPE sound = PACKED ARRAY[0..67] OF CHAR;

VAR snd:sound;

PROCEDURE dosound(VAR snd:sound);
XBIOS(32);

PROCEDURE pause(zeit:INTEGER);
C;

BEGIN
snd[0]:=CHR(0);    snd[1]:=CHR(222);  snd[2]:=CHR(1);     snd[3]:=CHR(1);
snd[4]:=CHR(8);    snd[5]:=CHR(16);   snd[6]:=CHR(11);    snd[7]:=CHR(0);
snd[8]:=CHR(12);   snd[9]:=CHR(64);   snd[10]:=CHR(13);   snd[11]:=CHR(9);
snd[12]:=CHR(7);   snd[13]:=CHR(254); snd[14]:=CHR($ff);  snd[15]:=CHR(30);
snd[16]:=CHR(0);   snd[17]:=CHR(170); snd[18]:=CHR(13);   snd[19]:=CHR(9);
snd[20]:=CHR($ff); snd[21]:=CHR(10);  snd[22]:=CHR(0);    snd[23]:=CHR(123);
snd[24]:=CHR(13);  snd[25]:=CHR(9);   snd[26]:=CHR($ff);  snd[27]:=CHR(20);
snd[28]:=CHR(0);   snd[29]:=CHR(170); snd[30]:=CHR(13);   snd[31]:=CHR(9);
snd[32]:=CHR($ff); snd[33]:=CHR(20);  snd[34]:=CHR(0);    snd[35]:=CHR(102);
snd[36]:=CHR(13);  snd[37]:=CHR(9);   snd[38]:=CHR($ff);  snd[39]:=CHR(20);
snd[40]:=CHR(0);   snd[41]:=CHR(123); snd[42]:=CHR(13);   snd[43]:=CHR(9);
snd[44]:=CHR($ff); snd[45]:=CHR(20);  snd[46]:=CHR(0);    snd[47]:=CHR(170);
snd[48]:=CHR(13);  snd[49]:=CHR(9);   snd[50]:=CHR($ff);  snd[51]:=CHR(10);
snd[52]:=CHR(0);   snd[53]:=CHR(250); snd[54]:=CHR(13);   snd[55]:=CHR(9);
snd[56]:=CHR($ff); snd[57]:=CHR(10);  snd[58]:=CHR(0);    snd[59]:=CHR(222);
snd[60]:=CHR(13);  snd[61]:=CHR(9);   snd[62]:=CHR($ff);  snd[63]:=CHR(30);
snd[64]:=CHR(7);   snd[65]:=CHR(255); snd[66]:=CHR($ff);  snd[67]:=CHR(0);

dosound(snd);
pause(800);

END.

