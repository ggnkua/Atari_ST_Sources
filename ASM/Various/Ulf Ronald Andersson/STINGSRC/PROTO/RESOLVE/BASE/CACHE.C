

#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "transprt.h"
#include "resolve.h"


void   build_base (void);
int16  save_cache (void);


CACHE  *cache_root = NULL, cache[64];
DNAME  dn[16];
char   *c_file = "CACHE.DNS";



void  main()

{
   build_base();

   save_cache();
 }


void  build_base()

{
   cache[0].IP_address  = 0x96cb3002ul;
   cache[0].real.name   = "aerodec.anu.edu.au";
   cache[0].real.length = strlen (cache[0].real.name);
   cache[0].real.type   = DNS_A;
   cache[0].real.expiry = time (NULL) + 2500000L;
   cache[0].real.next   = NULL;
   cache[0].alias = NULL;
   cache[0].used = time (NULL);   cache[0].next = NULL;

   cache[1].IP_address  = 0x96cbcd03ul;
   cache[1].real.name   = "hanhuba.anu.edu.au";
   cache[1].real.length = strlen (cache[1].real.name);
   cache[1].real.type   = DNS_A;
   cache[1].real.expiry = time (NULL) + 2500000L;
   cache[1].real.next   = NULL;
   cache[1].alias = NULL;
   cache[1].used = time (NULL);   cache[1].next = & cache[0];

   cache[2].IP_address  = 0xcb16d412ul;
   cache[2].real.name   = "anu.carno.net.au";
   cache[2].real.length = strlen (cache[2].real.name);
   cache[2].real.type   = DNS_A;
   cache[2].real.expiry = time (NULL) + 2500000L;
   cache[2].real.next   = NULL;
   cache[2].alias = NULL;
   cache[2].used = time (NULL);   cache[2].next = & cache[1];

   cache[3].IP_address  = 0x8b820666ul;
   cache[3].real.name   = "actrno2.gw.au";
   cache[3].real.length = strlen (cache[3].real.name);
   cache[3].real.type   = DNS_A;
   cache[3].real.expiry = time (NULL) + 2500000L;
   cache[3].real.next   = NULL;
   cache[3].alias = NULL;
   cache[3].used = time (NULL);   cache[3].next = & cache[2];

   cache[4].IP_address  = 0x8b82ebe3ul;
   cache[4].real.name   = "Fddi0-0.civ2.Canberra.telstra.net";
   cache[4].real.length = strlen (cache[4].real.name);
   cache[4].real.type   = DNS_A;
   cache[4].real.expiry = time (NULL) + 2500000L;
   cache[4].real.next   = NULL;
   cache[4].alias = NULL;
   cache[4].used = time (NULL);   cache[4].next = & cache[3];

   cache[5].IP_address  = 0x8b82ef0aul;
   cache[5].real.name   = "Serial5-1.civ-core1.Canberra.telstra.net";
   cache[5].real.length = strlen (cache[5].real.name);
   cache[5].real.type   = DNS_A;
   cache[5].real.expiry = time (NULL) + 2500000L;
   cache[5].real.next   = NULL;
   cache[5].alias = NULL;
   cache[5].used = time (NULL);   cache[5].next = & cache[4];

   cache[6].IP_address  = 0x8b82efe2ul;
   cache[6].real.name   = "Fddi0-0.lon-core1.Melbourne.telstra.net";
   cache[6].real.length = strlen (cache[6].real.name);
   cache[6].real.type   = DNS_A;
   cache[6].real.expiry = time (NULL) + 2500000L;
   cache[6].real.next   = NULL;
   cache[6].alias = NULL;
   cache[6].used = time (NULL);   cache[6].next = & cache[5];

   cache[7].IP_address  = 0xcc46d07aul;
   cache[7].real.name   = "telstra-internet.Bloomington.mci.net";
   cache[7].real.length = strlen (cache[7].real.name);
   cache[7].real.type   = DNS_A;
   cache[7].real.expiry = time (NULL) + 2500000L;
   cache[7].real.next   = NULL;
   cache[7].alias = NULL;
   cache[7].used = time (NULL);   cache[7].next = & cache[6];

   cache[8].IP_address  = 0xcc46d044ul;
   cache[8].real.name   = "borderx2-fddi-1.Bloomington.mci.net";
   cache[8].real.length = strlen (cache[8].real.name);
   cache[8].real.type   = DNS_A;
   cache[8].real.expiry = time (NULL) + 2500000L;
   cache[8].real.next   = NULL;
   cache[8].alias = NULL;
   cache[8].used = time (NULL);   cache[8].next = & cache[7];

   cache[9].IP_address  = 0xbc01904eul;
   cache[9].real.name   = "ir-perryman1.WiN-IP.DFN.DE";
   cache[9].real.length = strlen (cache[9].real.name);
   cache[9].real.type   = DNS_A;
   cache[9].real.expiry = time (NULL) + 2500000L;
   cache[9].real.next   = NULL;
   cache[9].alias = NULL;
   cache[9].used = time (NULL);   cache[9].next = & cache[8];

   cache[10].IP_address  = 0xbc019061ul;
   cache[10].real.name   = "ir-frankfurt1.WiN-IP.DFN.DE";
   cache[10].real.length = strlen (cache[10].real.name);
   cache[10].real.type   = DNS_A;
   cache[10].real.expiry = time (NULL) + 2500000L;
   cache[10].real.next   = NULL;
   cache[10].alias = NULL;
   cache[10].used = time (NULL);   cache[10].next = & cache[9];

   cache[11].IP_address  = 0xbc019022ul;
   cache[11].real.name   = "ZR-Frankfurt1.WiN-IP.DFN.DE";
   cache[11].real.length = strlen (cache[11].real.name);
   cache[11].real.type   = DNS_A;
   cache[11].real.expiry = time (NULL) + 2500000L;
   cache[11].real.next   = NULL;
   cache[11].alias = NULL;
   cache[11].used = time (NULL);   cache[11].next = & cache[10];

   cache[12].IP_address  = 0xbc01901aul;
   cache[12].real.name   = "ZR-Koeln1.WiN-IP.DFN.DE";
   cache[12].real.length = strlen (cache[12].real.name);
   cache[12].real.type   = DNS_A;
   cache[12].real.expiry = time (NULL) + 2500000L;
   cache[12].real.next   = NULL;
   cache[12].alias = NULL;
   cache[12].used = time (NULL);   cache[12].next = & cache[11];

   cache[13].IP_address  = 0xbc010401ul;
   cache[13].real.name   = "ZR-Hannover1.WiN-IP.DFN.DE";
   cache[13].real.length = strlen (cache[13].real.name);
   cache[13].real.type   = DNS_A;
   cache[13].real.expiry = time (NULL) + 2500000L;
   cache[13].real.next   = NULL;
   cache[13].alias = NULL;
   cache[13].used = time (NULL);   cache[13].next = & cache[12];

   cache[14].IP_address  = 0xbc010405ul;
   cache[14].real.name   = "Uni-Hannover1.WiN-IP.DFN.DE";
   cache[14].real.length = strlen (cache[14].real.name);
   cache[14].real.type   = DNS_A;
   cache[14].real.expiry = time (NULL) + 2500000L;
   cache[14].real.next   = NULL;
   cache[14].alias = NULL;
   cache[14].used = time (NULL);   cache[14].next = & cache[13];

   cache[15].IP_address  = 0x824b01fdul;
   cache[15].real.name   = "BWINgate.rrzn.uni-hannover.de";
   cache[15].real.length = strlen (cache[15].real.name);
   cache[15].real.type   = DNS_A;
   cache[15].real.expiry = time (NULL) + 2500000L;
   cache[15].real.next   = NULL;
   cache[15].alias = NULL;
   cache[15].used = time (NULL);   cache[15].next = & cache[14];

   cache[16].IP_address  = 0x824bb001ul;
   cache[16].real.name   = "gate-s5-1.stud.uni-hannover.de";
   cache[16].real.length = strlen (cache[16].real.name);
   cache[16].real.type   = DNS_A;
   cache[16].real.expiry = time (NULL) + 2500000L;
   cache[16].real.next   = NULL;
   cache[16].alias = NULL;
   cache[16].used = time (NULL);   cache[16].next = & cache[15];

   cache[17].IP_address  = 0x824bb07dul;
   cache[17].real.name   = "modserv2.stud.uni-hannover.de";
   cache[17].real.length = strlen (cache[17].real.name);
   cache[17].real.type   = DNS_A;
   cache[17].real.expiry = time (NULL) + 2500000L;
   cache[17].real.next   = NULL;
   cache[17].alias = NULL;
   cache[17].used = time (NULL);   cache[17].next = & cache[16];

/* route data */

   cache[18].IP_address  = 0xc29fff08ul;
   cache[18].real.name   = "ircnet.demon.co.uk";
   cache[18].real.length = strlen (cache[18].real.name);
   cache[18].real.type   = DNS_A;
   cache[18].real.expiry = time (NULL) + 2500000L;
   cache[18].real.next   = NULL;
   cache[18].alias = & dn[0];
   cache[18].used = time (NULL);   cache[18].next = & cache[17];
   dn[0].name   = "irc.demon.co.uk";
   dn[0].length = strlen (dn[0].name);
   dn[0].type   = DNS_CNAME;
   dn[0].expiry = time (NULL) + 2500000L;
   dn[0].next   = NULL;

   cache[19].IP_address  = 0xce649119ul;
   cache[19].real.name   = "wyatt.hpi.net";
   cache[19].real.length = strlen (cache[19].real.name);
   cache[19].real.type   = DNS_A;
   cache[19].real.expiry = time (NULL) + 2500000L;
   cache[19].real.next   = NULL;
   cache[19].alias = & dn[1];
   cache[19].used = time (NULL);   cache[19].next = & cache[18];
   dn[1].name   = "irc.hpi.net";
   dn[1].length = strlen (dn[1].name);
   dn[1].type   = DNS_CNAME;
   dn[1].expiry = time (NULL) + 2500000L;
   dn[1].next   = NULL;

   cache[20].IP_address  = 0x89e2e007ul;
   cache[20].real.name   = "shirkan.informatik.rwth-aachen.de";
   cache[20].real.length = strlen (cache[20].real.name);
   cache[20].real.type   = DNS_A;
   cache[20].real.expiry = time (NULL) + 2500000L;
   cache[20].real.next   = NULL;
   cache[20].alias = & dn[2];
   cache[20].used = time (NULL);   cache[20].next = & cache[19];
   dn[2].name   = "irc.informatik.rwth-aachen.de";
   dn[2].length = strlen (dn[2].name);
   dn[2].type   = DNS_CNAME;
   dn[2].expiry = time (NULL) + 2500000L;
   dn[2].next   = NULL;

   cache[21].IP_address  = 0xc24952f3ul;
   cache[21].real.name   = "teapot.bt.net";
   cache[21].real.length = strlen (cache[21].real.name);
   cache[21].real.type   = DNS_A;
   cache[21].real.expiry = time (NULL) + 2500000L;
   cache[21].real.next   = NULL;
   cache[21].alias = & dn[3];
   cache[21].used = time (NULL);   cache[21].next = & cache[20];
   dn[3].name   = "irc.bt.net";
   dn[3].length = strlen (dn[3].name);
   dn[3].type   = DNS_CNAME;
   dn[3].expiry = time (NULL) + 2500000L;
   dn[3].next   = NULL;

   cache[22].IP_address  = 0x8c4eb601ul;
   cache[22].real.name   = "alijku04.edvz.uni-linz.ac.at";
   cache[22].real.length = strlen (cache[22].real.name);
   cache[22].real.type   = DNS_A;
   cache[22].real.expiry = time (NULL) + 2500000L;
   cache[22].real.next   = NULL;
   cache[22].alias = & dn[4];
   cache[22].used = time (NULL);   cache[22].next = & cache[21];
   dn[4].name   = "irc.uni-linz.ac.at";
   dn[4].length = strlen (dn[4].name);
   dn[4].type   = DNS_CNAME;
   dn[4].expiry = time (NULL) + 2500000L;
   dn[4].next   = NULL;

   cache[23].IP_address  = 0xcefcc014ul;
   cache[23].real.name   = "irc.stealth.net";
   cache[23].real.length = strlen (cache[23].real.name);
   cache[23].real.type   = DNS_A;
   cache[23].real.expiry = time (NULL) + 2500000L;
   cache[23].real.next   = NULL;
   cache[23].alias = NULL;
   cache[23].used = time (NULL);   cache[23].next = & cache[22];

/* irc data */

   cache[24].IP_address  = 0xc12df002ul;
   cache[24].real.name   = "ftp.oden.se";
   cache[24].real.length = strlen (cache[24].real.name);
   cache[24].real.type   = DNS_A;
   cache[24].real.expiry = time (NULL) + 2500000L;
   cache[24].real.next   = NULL;
   cache[24].alias = NULL;
   cache[24].used = time (NULL);   cache[24].next = & cache[23];

   cache[25].IP_address  = 0x8baefd0dul;
   cache[25].real.name   = "ftp.tu-clausthal.de";
   cache[25].real.length = strlen (cache[25].real.name);
   cache[25].real.type   = DNS_A;
   cache[25].real.expiry = time (NULL) + 2500000L;
   cache[25].real.next   = NULL;
   cache[25].alias = NULL;
   cache[25].used = time (NULL);   cache[25].next = & cache[24];

   cache[26].IP_address  = 0x83f65e5eul;
   cache[26].real.name   = "ftp.uni-kl.de";
   cache[26].real.length = strlen (cache[26].real.name);
   cache[26].real.type   = DNS_A;
   cache[26].real.expiry = time (NULL) + 2500000L;
   cache[26].real.next   = NULL;
   cache[26].alias = NULL;
   cache[26].used = time (NULL);   cache[26].next = & cache[25];

   cache[27].IP_address  = 0x83ea1622ul;
   cache[27].real.name   = "gigaserv.uni-paderborn.de";
   cache[27].real.length = strlen (cache[27].real.name);
   cache[27].real.type   = DNS_A;
   cache[27].real.expiry = time (NULL) + 2500000L;
   cache[27].real.next   = NULL;
   cache[27].alias = & dn[5];
   cache[27].used = time (NULL);   cache[27].next = & cache[26];
   dn[5].name   = "ftp.uni-paderborn.de";
   dn[5].length = strlen (dn[5].name);
   dn[5].type   = DNS_CNAME;
   dn[5].expiry = time (NULL) + 2500000L;
   dn[5].next   = NULL;

   cache[28].IP_address  = 0xc13fff01ul;
   cache[28].real.name   = "phoenix.doc.ic.ac.uk";
   cache[28].real.length = strlen (cache[28].real.name);
   cache[28].real.type   = DNS_A;
   cache[28].real.expiry = time (NULL) + 2500000L;
   cache[28].real.next   = NULL;
   cache[28].alias = NULL;
   cache[28].used = time (NULL);   cache[28].next = & cache[27];

   cache[29].IP_address  = 0x8dd3780bul;
   cache[29].real.name   = "carpediem.ccs.itd.umich.edu";
   cache[29].real.length = strlen (cache[29].real.name);
   cache[29].real.type   = DNS_A;
   cache[29].real.expiry = time (NULL) + 2500000L;
   cache[29].real.next   = NULL;
   cache[29].alias = & dn[6];
   cache[29].used = time (NULL);   cache[29].next = & cache[28];
   dn[6].name   = "atari.archive.umich.edu";
   dn[6].length = strlen (dn[6].name);
   dn[6].type   = DNS_CNAME;
   dn[6].expiry = time (NULL) + 2500000L;
   dn[6].next   = NULL;

/* ftp data */

   cache[30].IP_address  = 0x824bb002ul;
   cache[30].real.name   = "studserv.stud.uni-hannover.de";
   cache[30].real.length = strlen (cache[30].real.name);
   cache[30].real.type   = DNS_A;
   cache[30].real.expiry = time (NULL) + 2500000L;
   cache[30].real.next   = NULL;
   cache[30].alias = & dn[7];
   cache[30].used = time (NULL);   cache[30].next = & cache[29];
   dn[7].name   = "www.stud.uni-hannover.de";
   dn[7].length = strlen (dn[7].name);
   dn[7].type   = DNS_CNAME;
   dn[7].expiry = time (NULL) + 2500000L;
   dn[7].next   = NULL;

/* stud data */

   cache[31].IP_address  = 0x824b4b15ul;
   cache[31].real.name   = "flora.amp.uni-hannover.de";
   cache[31].real.length = strlen (cache[31].real.name);
   cache[31].real.type   = DNS_A;
   cache[31].real.expiry = time (NULL) + 2500000L;
   cache[31].real.next   = NULL;
   cache[31].alias = NULL;
   cache[31].used = time (NULL);   cache[31].next = & cache[30];

   cache[32].IP_address  = 0x824b4b14ul;
   cache[32].real.name   = "iris.amp.uni-hannover.de";
   cache[32].real.length = strlen (cache[32].real.name);
   cache[32].real.type   = DNS_A;
   cache[32].real.expiry = time (NULL) + 2500000L;
   cache[32].real.next   = NULL;
   cache[32].alias = NULL;
   cache[32].used = time (NULL);   cache[32].next = & cache[31];

   cache[33].IP_address  = 0x824b4b13ul;
   cache[33].real.name   = "hebe.amp.uni-hannover.de";
   cache[33].real.length = strlen (cache[33].real.name);
   cache[33].real.type   = DNS_A;
   cache[33].real.expiry = time (NULL) + 2500000L;
   cache[33].real.next   = NULL;
   cache[33].alias = NULL;
   cache[33].used = time (NULL);   cache[33].next = & cache[32];

   cache[34].IP_address  = 0x824b4b12ul;
   cache[34].real.name   = "vesta.amp.uni-hannover.de";
   cache[34].real.length = strlen (cache[34].real.name);
   cache[34].real.type   = DNS_A;
   cache[34].real.expiry = time (NULL) + 2500000L;
   cache[34].real.next   = NULL;
   cache[34].alias = NULL;
   cache[34].used = time (NULL);   cache[34].next = & cache[33];

   cache[35].IP_address  = 0x824b4b11ul;
   cache[35].real.name   = "juno.amp.uni-hannover.de";
   cache[35].real.length = strlen (cache[35].real.name);
   cache[35].real.type   = DNS_A;
   cache[35].real.expiry = time (NULL) + 2500000L;
   cache[35].real.next   = NULL;
   cache[35].alias = NULL;
   cache[35].used = time (NULL);   cache[35].next = & cache[34];

   cache[36].IP_address  = 0x824b4b10ul;
   cache[36].real.name   = "pallas.amp.uni-hannover.de";
   cache[36].real.length = strlen (cache[36].real.name);
   cache[36].real.type   = DNS_A;
   cache[36].real.expiry = time (NULL) + 2500000L;
   cache[36].real.next   = NULL;
   cache[36].alias = NULL;
   cache[36].used = time (NULL);   cache[36].next = & cache[35];

/* cad data */

   cache[37].IP_address  = 0xc0a80101ul;
   cache[37].real.name   = "suse.modem.uni-hannover.de";
   cache[37].real.length = strlen (cache[37].real.name);
   cache[37].real.type   = DNS_A;
   cache[37].real.expiry = time (NULL) + 2500000L;
   cache[37].real.next   = NULL;
   cache[37].alias = NULL;
   cache[37].used = time (NULL);   cache[37].next = & cache[36];

   cache_root = & cache[37];
 }


int16  save_cache()

{
   CACHE  *walk;
   DNAME  *alias;
   long   error;
   int    handle;

   if ((error = Fcreate (c_file, 0)) < 0)
        return (-1);

   handle = (int) error;

   for (walk = cache_root; walk; walk = walk->next) {
        if (Fwrite (handle, sizeof (CACHE), walk) != sizeof (CACHE))
             break;
        if (Fwrite (handle, walk->real.length, walk->real.name) != walk->real.length)
             break;
        for (alias = walk->alias; alias; alias = alias->next) {
             if (Fwrite (handle, sizeof (DNAME), alias) != sizeof (DNAME))
                  break;
             if (Fwrite (handle, alias->length, alias->name) != alias->length)
                  break;
           }
        if (alias)   break;
      }

   Fclose (handle);

   return ((walk != NULL) ? -1 : 0);
 }
