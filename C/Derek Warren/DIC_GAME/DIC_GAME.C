#include <osbind.h>
#include <stdio.h>
#include <aes.h>   
#include <vdi.h>
 
#define dsbl_cur printf("%s","\033f")  /* disable cursor (ie 'ESC' f)  */
#define enbl_cur printf("%s","\033e")  /* enable cursor   (ie 'ESC' e) */
#define cur_posn(row,col) putchar(27); putchar('Y'); putchar(row+32); putchar(col+32);
#define BELL printf("%s","\007")       /* ring bell  				           */
#define cls  v_clrwk(handle)
#define	mouse_off() graf_mouse(M_OFF,NULL);
#define	mouse_on()  graf_mouse(M_ON,NULL);
#define LINE 0   		                   /* line and column              */
#define COL 0                          /*          of cursor at input  */
#define TIME 10000L                    /* for delay routine       	   */
/* for Lattice C:- */
#define int    short   
   
int contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];
int handle,ch,cw,bh,bw,rez_no;
int work_in[11],work_out[57];
int charw,charh,cellw,cellh;

char y_n,*dic1[][2] ={ 

"¶­³´¬¼", "k³·fº­·¸°Àv}d§¸¨±­¯¯l°²¶©§®­ir~lÁ²d~fª·»®¾um°¥©«g±·j±¸®·pe¸¶½·®k»¿c·¶»¨º®j±»¿°",
"§­¦©¹±½³®", "¶­¬´o©¬­°ºÁod¨««±µ¶¬xm¨¸¨tp¼¸j´º±¬§¦º¬h­³±²²µ©³ºg»¸¿¹°Àc³·f½©µ¿°¿m²ªe§g´®¾¿±¿",
"³³®±°´¸¾³±¿°", "²¶¬§µ±¼·kÀµ¤¸e¸¬¯¾¶¬À²¶d§µ«Ái¾°¹½¨¶¦º¼º®j­Åm¬¸¸f©­±«Áµ¼¸¶en©©¼µ´º´od§»¹º¸Á´º´l",
"¯¥µ¶¬¼", "¶±¦²³h¯¶¬¼m²¶e¬¶´­jº²mª¥·³¬¶½j°À°~d­§µ¯²¸²l¼µd±µ¶»®j»µ²¦©eµ­h¯¶°¿µk°´¨¬tÀ«¿À¹¨m",
"¯­²³¬º", "j¥e°¨¬®vk­m«¹¿ÀÀti«k¿Áµ¹²¶¬¼uj¬l¿²«º«shªj¾¯¼¸²©¸¬´wq",
"»©§«ª", "¶±¦²³h½²½±²p±¦¹»­­jÁ±À¶©±f¾±½²k¸®·©ª´g©·®k¿¾¸¥·«g»ª³·¿yc¹¸««h²¸k™²§­¹«¹ºª¸°­»q",
"§­³­³­", "j¥eª¬­¹jÂ»¼§©©f½©µ¶°Åm²¶eª¬´µxr",
"¤§ª¸©±½Ã", "j·´»¹h«³¿À²µ²ª¹ºƒi½°Â²µ­¹¿sh¼²¬¾½±©¸¹uo",
"«½µ«¹¸±«¾µ®", "j°¦©²h¸°k¯¼±¸·µ³h¸À°¾m·¬ªf¶º°«¹¿m²ªe¹·­®­³zt",
"¥©±²¬»v¶°ÀÁµ©¸", "j¥·º°»½³®l®±¨e²°¼®¼¬¾Æc»·¯»±·±¾xm¯­¬®»hµ³¿±¿¤¸º¸¬vp",
"µ¬¦³·°¸³¯", "j¦ª§²u¼²¬¼²§rl",
"¥¶¦¹º©»®", "j¥e¨¨¬°¯kÃ¼µ²eµµh½²°l®µ±sm",
"±©´²¶¯²½¸", "j¥e´¬¿v­ºµ»¨¨e½¶º­jº¾m³¬·§º­wq",
"·¬´²¬", "jl»t»vr¬°­¿o¹³ª¬º°¹†lu±rn¶°¶i¹±l¿²»±µª³wq",
"¦¥¸¹¨¼²¹¹", "j¥§¸¶¯ª¾´»»~d·«½­»½¬¸m²ªe§g²¾®´¯¶¤°e¹¬¶½¯¹¯²qk",
"¨·´º¬º²­", "jª´¸g¼±¯kµ»¬¸®§»­­jºº¹¼e¹¬«»¯¿zt",
"½©¹§", "j°®º»´®j®¸¼¶©¹f¶ºi­³­º¥©·g©i½°ÄÁ²²l¹gº¸¹¸l¼¹©·fª°¾¼®´m³³·©¯vp",
"©°´¸°´®±´Áº", "j¥³f¨¶½²º¸¼ª½sm",
"ª¶¦¼¬·µ¯¹À", "j·²«³´²¸²lÀ·¶´´®´Âj¬º±c³«¬¬¶¼³Á±¹¼rl",
"«¥®´", "jl»t»vr¾ºl½µ³¹«ª¼uj¿»m¶¥»«sh½¹k¼¿¨·ª¸½­iwkt»qm¦´g­·­·»À¸¶ªtn",
"¬²¨®¶©½¯", "j®º¹»h«¯²Á»~dº´«­¿¯·»½¨¨sm",
"­³·»´", "j°¦¸®­i¬ºÃ¹c³·f«º²¸¶µ»ªd»«º»®¶†l¶··e©¶¶½¯¹ÀÀqk",
"®­³§¬»½²°¿¶¶", "j¸­«gµ¾½®Á¹¤¶e¹¬¶¼¯†lÁ«©e¶¬º¬¯»À¶²²eµ­h¶¿¾¯Â¯¥·f´·¿¯¸±»·rl",
"©¶´½¨º­", "j²´ºg¿²¶·µ»ªd¹µg«¸·»¸Æod·«­ºª­¿»¿¼pe¶¬º¿¯½¿²od²»»±·¹À¿{j",
"§­¬¸¨¸±", "j¥e©¶µ«³¹­Á¬³³f¶®i¾Â»m¯©¹º¬º¼j¿»mµ©µ¸¬»®¸¿l¼±©e¹¶½·®kt²ªdµ®g·»j°Åvqk",
"°©·«»º²­´»Â¶", "j·­µ¾±µÃk­Á·¶¦©»±¿¯wl³¯¥¸®Àti¾¬Ã±µ½qf¶®i¹½l¹¬¯ªf¨h±«½¸¼·rl",
"«³²µ·°¸¸°", "j»´¸«h±«Áµ»ªd¹®¬h¼«¸±m¶³º´«hª½k­»²¸­«¹h«¿¿l±¬ª««¹­·¾k¹²¤²®´®h¸¼k»¿¬«®´uo",
"²¦²»»­¼­°º°¨", "j°´¹ºh¸°k¿½¨©¨®sh¸¬¾À¶±¥¹«g»²¶°º°¨d´¸g¼ª­´ÀÂµ²®ºÀvp",
"¦³³©¼¸²½®±»¦©", "j°º¹»vp",
"³½·¯­·»·", "j´ª§¹u¼²¬¼²§rl",
"¨¼´º¬º²­", "j¹³ª¬º¼¾¬º±¤¦±«gªÂj¿´²c±¦´Àƒi¹½°¶±¥·¿sh¹¹»Á¹¤¶sm",
"¶¸ª¸¬", "j§º¨°«i·°À¿¨rl",
"°¥¨¸¶¶", "j»·¯»¼®¸k»¿c´·¯µ¼®®k¹®µ¯enFqi¹Á±¿c¥e²¶¶°jº¾m¶¸·«º»®®kÂ¼º©±tn",
"¤«·«º¼²­", "j¶º¸¨´uj½ÁÀ·­¨rg«µ¹Âº¶¶¬qf¼¶¬¹ÀÀµqk",
"¸¶¦´¶¯»«»´Æ", "j¨ª¹ªº²º¿µÃ¨d¦¹»º¸¸º¹Æqk",
"¯©º", "j¸­«gªª½´¯m°³³«»©»ÃkÁ»¬¸eµ­h›¹¸­»¬¥sm",
"¹©¸¯ª©½¯", "j¶¦¯º­i¬·µÀ·©·¹g··jyz{crl",
"¦³³©¨¼®¸¬À¶²²", "j°®´²±·±kÀ¼ª©¹®¬ºir¬l°«¥®´g·¯j°Â²±¸¸rg¼±³¹³Àodªºªvrxr",
"º­·¸À«¸Á", "j¥e®¶ª°¹­¸¶±pe§gª¸±Ä†m·¬ªf«­¿³·zt",
"ª¶ª¹º·»³¬¸", "j»¦²²±·±†l®§¥µº¬¬i°º¾mº¥±±°¶°xr",
"¶©¨©¶", "j¸­«g¼®­³º¶´¹ªf¶®iº¬µ»·­³­g··j¯¾Æc´±§º¼®¼kÃ¶·¬e¶°¯¶¯¹ÀÀc±®¾¬¬i³¹lÄ¤¸ª¸uo",
"©°¦­¬´µ«¹À", "j³³«g¿±¹k¿°²¹·­¬»i²´¹|«©·¹¬´¯jº¾m²¸­«¹»wq",
"¼¥µ¶", "jª´¸´h¸°k®¼²¯§¯µ¬²¸²lÄ¬¸­f³±¶ºk¸²¤¸­«¹h¬¹Á±¿cª´²«±·±k»Ã¨¶e««¯®½k»³c°ª§½­¼xr",
"¯¥³»®·", "jª®´¬h¼¹±Àm«¥®¸sh®½»zm·¬¦ºg«¸À°¾¶±«e¨¶¬Âj¬º±c°®³©»i¹±lÁ«©e®¼µª¸k²¼¨¸º¹uo",
"©¥±©°®¸¼¸", "j§º¸½­­j·µ¸¨d¦fº±¬µ·±{j",
"¶©²³°¼", "j¥³f¼¶­¯½¿µ¬¶¹tn",
"³³±¿´©½²", "j¥e¶¬º¼¹¹l¼©d²»ª°i¹½lÃ¤¶®««hµ¯¬¾»¬²¬g©i±½±®·d¸©¯·µ«½zt",
"¨¼º¼°©½¯", "jl»t»ºwsk¿µ¨¨en¨h¼µ´ºm¨¸¨ouo",
"¯©¨¿»°¾½", "j¥eº¯±·j¹­¿µ³¼sµ­¬µ°°m¹¥¸«g·»j±¸®¶¯sm",
"¶©²§µ¼®·°", "j¥e¬¼¶­«¸±»·¥±f¬´®·°ºÁc©½¶¹­¼½´º´c¥³f°µª±°l¼µd®ª¬©wq",
"³³±«µ¼ª", "j´´¸¹±­±°lº¤¨ªf¶®i·¬µÇ¨d²«¨´i¯¿¯{j",
"¤§·µ·­½«·", "j¨ª¼¬´¸º´º´cª·µ´h«¯·»Äc¹µ½¨º­½ys",
"¶¥±º¼»", "j¥e¹¼¬­¯¹lÁµ¥³¹°¼²¹¹‡m¤d§¸¬©¬²k»³c§´´»±·¿´ÀÆqk",
"³°¦´»±°¼¬°²", "jl´¬g©·j¬º¶°¥±og¿ª¶¶µ»ªd´´g¼±¯k¿¼¯©¸f¶®i³¿¿m©©ªºsh²¯k´Â°¥³¹g·»j­±®µ·l",
"¶©®¬", "j¥e¹¨¶­j¯Á»¨d®´g¼±¯k¿µ¤´ªf¶®i«k¸¼±«e´¨º»¹Âl¿¬¨¬«uo",
"©¶¦¾°¶®¶·­", "j¥·µ´©½³®l½¯¥³ºg°ªÀ´º´cª´²°©°¯kÀµ¤¸e«´±½½k­»c©¹®¬º®«·l¶±ª±§´µª¬·±m²­±m",
"·¶®§®­", "¶³·ºg®¸¼k½Â¤°®ºÀti¹½l±¨«·«¬h¸°kÁ¿ª©³©Àhq¹±lÄ²¹³ªºh®¾®um©³·f¶º­¯½l¼©d¹¸¬©½·°ºÁ",
"¶§ºº¼µ", "¨¥¨®g·¯j¿´²c·­¯¬´­w·µ¸¨d¸©¨´®½k»³c¸­«gª¸¸°Åm¦³»«¹±·±k»³c§·µª·­³·±y·¹·º³­uj°À°",
"¬°®»´", "¥³³«g®¸¼¸µ»ªdº¶·­»j»­¿·d´¬g­ª­³lµ¤°«f¶®i²À¹®±dµ«³¾²½†l°²¶·«ºvi¬ºº²c­³f¨¶²·¬¸À",
"©°ª»¹··", "j¥e¬³·À¯½yÀ«¥µ««h¸¼¹­º¨²¹f¶¶i«k®Â¬°©¯µ¯uj®»¶±pe¨¶·´j°À°qk",
"¶³¹«¹±¸¶º³Æ", "j¸­«g¬¸­¿¾¶±©eµ­h¼«·Â®·­´´uo",
"·¶ª³¨¼¸®°", "¤dµ§¹©¼³¿µ°cª±§»¿¸¼¸xmk©¸¶phªj±¸Â®©e½°¼±j³»¼®·eµ¹h¼¿®·²µ·qf¬¯i«k¸¶¹©·f­´¾µ°z",
"¬±§¸¼­", "j·¹§°¶uj¾»¶¯peª¹­·­³lu¬²en¶ºiÁ´Àµld§²¶·­vk±Á¦mqf´·²½¿±»qk",
"ª¥¿«©·", "¶±¦²³h«¿´¸±¬²¬rg»½¼À¯Á¸¶ªfo»¾·¸±¿p¬´»º­u¾À¾¿¨¸nf«­¼³²º²§d¹µg¯²À°l®c»®ª¬h¿³°Ã",
"¶³ºº¨¶®", "jd¦fª©¼½º¯¸c»´¸µh«Ãk­m³¶®«º¼wq",
"¬±µ¸¬»½", "°³³«Àhª®Á­»¦©©f»·i«k¼²µ·´´g®¸¼kÁÀ¨d®´g›½«¿±m¥¹¸¯µ­¼½wl®c°´§µti«¯Â®±§ªªg¸ªÃy",
"·©·¸¬¼", "¨¥¨®g·¯j¿´²c°´µ·»i¹½l¿¬²¬¹g··j³­¿±©¸¹g¸ª®k²¼µd©¸°¾²¸²l¿¨­³¹g¼¸j»­À¶d¹®¹·¾±³z",
"±³¸µ³·°Ã", "¥¶¦´ª°i¹±lº¨¨®©¨´i½®µ²±§ªf«­ª¶´º´c»®º¯h½²°l°¯¥¸¹°®²­¬À¶²²eµ­h¶¯¯µ°¤°eª°»®«¾±À",
"¶³ºº¬º", "jd¦fº°¸¯¸­¸¨¶qf¨h¬¹­®¹¨¶sm",
"³°¦¹»º¸¸", "j¦·«¨»½º·­Á¨pe¬¹··¾k»³c·­¯¹¼uj­»±¬§ªrg¾®¸¿¾®¯dµ§¹¼i¹±lÁ²¶¹µ°»®j¾´²¯°e«»«wq",
"¶³ºº¨«±¯", "jd¦fµ©»¼ºÃm©°¦ºg·»¸¬¹²±¸¦²gª»«´°m¸·ªªg¼¸j¿¾¶°d¬§¹µ®¸¿¿{j",
"±¹²«µ", "j¥e¶¹­¼³¯µ»ªd©«°¼Âjº¾m¶´®¸°¼p",
"·¥³º¨´¾½", "¤d¸º¨¶­j´ºmº¬®©¯h¼º´¾¶·d©«ª©·¾°¾Àc±¦¿gª®j·»°®©©f¼¸i¬ÀÀm¹­¸¯©´®x",
"·³µµµÁ¶Ã", "·¬ªfº¼¾®Äl¼©d¹®¬h¹¶¬¯²p²¦³¬»i¹±l®c¶ª­°··xr",
"¬°ª»´", "j¸­«g¼±³½°m¤²©f³©¼¾k¼¼µ¸®µµh¸°kÀµ¨d¸³¨´µj´ºÁ¨·¹¯µ­wq",
"¶©©«¹½·¾", "j¥e¹°¼½³¹³m²ªe§µh®­®±À¬¥¸º°«ª¶k­À¶©²¨³Ái¹½l¼·¬ª¸gª¸®Äzt",
"³¬´¸¬»Â", "¤·¸µª±ª¾´»»c­³f¾°²­³l¼±©eµ¹¯ª¸´¿ºc§¦¸¹±®½k­»²¸­«¹tiÁ´Àµ²¹¹f°¼i¬°µ»ªdµ§¹©¼³¿µ°",
"¦¥¸¹¨¼ª", "j¥eºÀ¸®jº²m¬§ªsªº®«¸l°²²¹§µ±·±k¯®±¨®««h¸¼k°¿¬©©f­º¾³¿l®±¨e´¼¼¼xr",
"±³©»º", "j¥e±µ·½¾Äl½²­³ºshªj¯µ³©­¨»³¼Âvk­m¦³²¶³±¬«¿µ¼±d®´g¼±¯k¼¹²¸eµ­hªj¾À¼µ½e«»«wq",
"µ©©§ª¼", "j´ººg±·¾ºl¹¬¸ª¸¨ºÂj±»¿°e««±½j±»¿c´º¨³±¬«¿µ¼±rl",
"©¹³§´ª¾¶´¿Á", "jd¦f¹·¹¯xÃ®¯¯ª¸uo",
"¶¥±¯ª±¸¸¬¸", "¤²eµ¹¯ª¸k¿Á²´e½°¼±j¬lÀ²ª¹f¹­®®ÄlÁ²²ªf³±´¯kÀµ¤¸eµ­hªjÂµ¹¯³¼s·±¹¯ys",
"¦¥¹§ª´ª½´¿", "j¸­«g¶ª¾À¾®¯dµ¸¶«®½¾l¼©d«¸¨«½¿½±yc·­«¬º²¸²l¼µd§¸¬©´³¹³m¸´eµ­h»¹®·Àqk",
"²¶±µ·", "j¸­«g´¸Á°¿Ác¨ª©²h¸°k­m¶¬®¶g¿²¾³lÁ«¶ª«g·»j¸»¿¨d©«ª³¼xr",
"µ­±²", "j¥e¹´©µ¶k¿Áµ©¦³‚hªj¾¹®¯°e©¯©·¸°¸m¦¹¹f°¶i½ºµ¹c³·f¹·¬µk®Æc¶º´µ±·±kÃ®·©·tn",
"ª¥±²¶··", "¤d³§¹º¸Ák¯¹²·ªs¾·¿¯¹l¯µ¥®ªg·¯j²»¹§p¸¯³¾®¼w¿¶¯¯q©¶¼½¹¹l²·§e¬¶ºi¬´º±¬²¬f«º®½¾±À",
"±³·±", "k¹¸»¨´µÃkµ»c´±»¹©µsks®c»´³¨¶p½k®¿¨¥¸ºnhq‹À¿Áµ¥±¯¨¶i½·­»ªm",
"¦³µ¯»©", "j¥eº¼´²ºx¿µ¤´ªªg»±¯½¾Æc«±§º»„j¬l´¯¥¸¹g·¯j¾´²µ¶¾tn",
"ª³¼§µ", "j¥eª¨±¼Ã†l®±½e½¯±½¯k»¿c½ª²³·Àj±µ²¯¨r¬³·À¯½zt",
"¦³·¨°­", "j¥e¸¨¾®¸wl®c§¦¸¹±¸¸k¯¿²»sm",
"³¬®²°¸¹³®", "j¥e¨°¼½¯½lÃ¨¶§§³hª¾¿­°®d´¸g¬®¸Àº°¬¥¹¯¶¶wq",
"¦³·ª¶¾ª¸", "j¥e±°¶­jº²m¶³«ºg´®«¿´²µrl",
"©¹±¼¶½¼", "jd·««¬²½³yÆ¨°±µ¾ti¾¬Ã»¼rl",
"±½²¶¯·µ¯»¿Æ", "j©¨¹»©¼Ãk»¿cª·«µÂÂj®­Â¶©©f©Ái®°¿¶µ©eµ­h½²°lÂ±¥¹º¨±·«­¸²qk",
"©¹²§¹·µ¯", "j¥³f¶¸®¸´º´c­³f¶ºi¸°­¿c¥e¼¶´¬«¹»yc¸­¸¶½°²kÃµ¬§­f¯·½jÁ­½²¹·¹g­¶¯½³²qk",
"²¶¬«¨¼", "j¥e©¶·µ³¹³m§¶®´²h¶«¯±m©¶´³gªª¼·±Æc³·f¨´¶¹¹°Àc¥³ªg·»«¹³²pª±µ¾­»jÂ­Á¨¶sm",
"¦¥·º¶µª¸®Å", "jª´¸»½·¯kÀ²¯°®´®h«Ãkµ»·©·¶¹­½³¹³m¤d·§µ¬¸·k¿²¯©¨¯¶¶i¹±l½¯¥¾¯µ¯i­¬¾±¶rl",
"µ¬ªµ³·°Ã", "j¸­«g»¬³°º°¨d©«¨´²¸²lÄ¬¸­f»°®j±¸¼ºd¦´«h­¯±»¿°¥¹¯¶¶i¹±lº¤¸¹«¹vp",
"°³·º¨¬®¶·­", "j¥e²¨º°¯k¿½¬§ªªg¸¸¼¶lÀ¤¹¸§®­wq",
"¬·´º¯­»¯", "¯­³«g··j¬lº¤´e©¶¶·¯®À¶±«e¶³©¬¯¾lµ¤º®´®h¼«¸±m¤ºª¸¨¯®j¿±º³©·§»½»¯kµ»c·º³´­»x",
"", ""   };

void main()
{
	int rect1[]={0,0,639,199},rect2[]={0,0,639,399};  
	char ch, cha,dic2a[16],dic2b[80],temp[16];
	int slctd_wd,i,j,k,count,q;
	cls;
	k=0;
 	dsbl_cur;
 	mouse_off();       
	rez_no = Getrez();
	if (k==0 && rez_no==0)
	{
		not_low();
 		goto end;  
	}
	gem_on();   
 	vsf_color(handle,3);   
 	slctd_wd = (rand_func()%99)+1;  /*  selects word  at a random point
 	                                             in 100 word 'dictionary' */
	keybd_repeat(100,-1);    /* '100' reduces possibility of inadvertent
		         		multiple responses to initial key press, '-1' maintains
		         		existing (ie OS) response time for second and	
		         			                          and subsequent key presses. */ 
	if (k==0 && rez_no==1) 
	{
	 	v_bar(handle,rect1);   /* draw filled rectangle 	                  */ 
		at(24,14,"(Note: this program will also run in high resolution.)"); 
	}
	if (k==0 && rez_no==2)
	{
	 	v_bar(handle,rect2);  
    at(24,10,"(Note: this program will also run in medium resolution colour.)");  
	}
	title(rez_no);
 	do
	{
  	for (i = 0; i < 16; i++)
   		dic2a[i] = '\0';       /* ensures dic2a contains nothing           */
  	for (i = 0; i < 80; i++)
    	dic2b[i] = '\0';       /* ensures dic2b contains nothing           */
   /*    decode sequence   */
  	j = 67;
  	for (i = 0; i < strlen(dic1[slctd_wd][0]); i++)
  	{
  		dic2a[i] = dic1[slctd_wd][0][i]-j;
    	j++;
    	if (j > 77)j = 67;
  	}
  	j = 67;
  	for (i=0; i < strlen(dic1[slctd_wd][1]); i++)
  	{
  		dic2b[i] = dic1[slctd_wd][1][i]-j;
  		j++;
  		if (j > 77)j = 67; 
  	}      
		k=1;
  	count = 0;          /* count number of guesses                       */
  	for (i = 0; i < strlen(dic2a); i++)
  	 	temp[i] = '-';    /* puts hyphens at beginning of temp[16] equiv  
                        to number of characters in word dic[slctd_wd][0] */
  	for (i = strlen(dic2a); i < 15; i++)
  	 	temp[i] = '\0';   /* puts \0 in remainder of temp[16] ie 16    
  	                               minus number of characters in dic2a   */
		cls;   
/*    letter guess and display sequence     */
		cur_posn(LINE+1,COL);	
/*    give advance showing of randomly selected word (if wanted)         
	  printf("\t\t    (Randomly selected word is:  '%s'  )\n", dic2a);   */
  	printf("\n\t\tFind a word and, maybe, extend your vocabulary.");
  	printf("\n\t\t----------------------------------------------");
		printf("\n\n\t  Find this word  %s  by guessing its individual letters.\n\n", temp);
  	do 
  	{
    	printf("\tEnter your guess: ");
 			cha = getch();
/* does guess match any letter/s in word; if so substitute for hyphen/s  */
    	for (i = 0; i < strlen(dic2a); i++)
      	if (cha == dic2a[i])
      		temp[i] = cha;
    	count++;
    	printf("%s\n", temp);
  	}
  	while (strcmp(temp, dic2a)); /*  until 'temp' matches selected word  */
  	printf("\n\t\t\t  %s is correct.\n\n", dic2a);
  	printf("\tYou managed it in %d guesses.", count);
  	for (i = 0; i < strlen(temp); i++)
  	{
  		ch = temp[i];              /* convert word to upper case           */
  		ch = toupper(ch);
  		temp[i] = ch;
  	}
  	printf("\n\n\n\t\t\t  %s means (or is):\n\n",temp);
  	for (q = 0; q < (80-strlen(dic2b))/2; q++) /*  centralises 'dic2b'   */
  		printf(" ");
  	printf("%s", dic2b);
  	for (i = 0; i < strlen(dic2a); i++)
  		temp[i] = '-';   /*  replace all characters of last word with '-'  */     
  	slctd_wd++;
  	if (slctd_wd > 99) slctd_wd = 0;/* back to beginning of 'dictionary' */
  	printf("\n\n\t\t\t  ----------------------  ");
  	printf("\n\t\t\t  Try another word? Y/N:  ");
  	printf("\n\t\t\t  ----------------------  ");
  	y_n = getch();
		cls;
  	y_n = toupper(y_n);
 		if (y_n!='Y' && y_n!='N')
		not_Y_or_N();
  }
  while (y_n == 'Y');    /* do it again?                                 */
  end: 
 	enbl_cur;
 	mouse_on();
  keybd_repeat(15,-1);  /*  '15' puts speed of first keypress  response
                                                  approx. back to normal */
	cls;
	gem_off(); 
	exit(0);
}

not_low()               /*  if in low res.                               */  
{
	at(6,0,"Program does not run in low resolution;");
	at(8,3,"please switch to high or medium."); 
	at(11,15,"Press a key to exit.");
 	evnt_keybd();
}

gem_on()
{
	int I;
	appl_init();
	handle=graf_handle(&ch,&cw,&bh,&bw);
	for (I=0;I<10;I++)
		work_in[I]=1;
	work_in[10]=2;
	v_opnvwk(work_in,&handle,work_out);
}

at(x,y,string)
int x,y;
char string[];
{
	cur_posn(LINE+x,COL+y);
	printf(string);
}

title(int d)
{
	int rect3[]={60,25,580,150},rect4[]={80,35,560,140};/* for 1 (med rez) */  
	int rect5[]={60,50,580,300},rect6[]={80,70,560,280};/* for 2 (high rez)*/  
	int i,charw,charh,cellw,cellh;
	vsf_interior(handle,2); /* these two lines give style of               */
	vsf_style(handle,12);   /*              fill for first rectangle       */
  vsf_color(handle,2);    /* colour for first rectangle                  */    
	vst_point(handle,18,&charw,&charh,&cellw,&cellh);	/* changes height
                                                  and thus width of text */
	if (d==1)               /* ie if med. rez.                             */
	{	
	  v_bar(handle,rect3);	/* draws rectangle 	                           */ 
		vsf_color(handle,0);  /* colour for 2nd rectangle                    */
		v_rfbox(handle,rect4);/* draws 2nd rectangle (white filled) over
		                                                    centre of first  */
		v_justified(handle,100,80,"FIND A WORD AND, MAYBE,",400,0,1);/* prints
                                                          justified text */
		v_justified(handle,130,110,"EXTEND YOUR VOCABULARY!",400,0,1);	
	}
	if (d==2)               /* ie if high rez.                             */
  {
    v_bar(handle,rect5); 	
		vsf_color(handle,0);
		v_rfbox(handle,rect6);
		v_justified(handle,100,160,"FIND A WORD AND, MAYBE,",400,0,1);	
  	v_justified(handle,130,220,"EXTEND YOUR VOCABULARY!",400,0,1);
	}
	for (i=0;i<4;i++)
	{
		at(20,55,"           ");
		delay(TIME*5);
		at(20,55,"Press a key");
		delay(TIME*5);
	}
evnt_keybd();
}
   
unsigned int rand_func()
	{
		int utime;
		long ltime;
		ltime =time(NULL);/* using system time to 'seed'
		                                        random number generator      */
		utime=(unsigned int) ltime/2;      
		return (utime);
	}

delay(t)			            /*  delay routine                              */
long t;
	{
		long i; 
		for(i=1;i<t;i++);
	}	

not_Y_or_N()           /*  if 'Y', 'y', 'N' or 'n' not pressed           */
{		
	int i,x,y;
	int rect7[]={88,100,552,300};  /*  rez 2                               */
	int rect8[]={88,50,552,150};   /*  rez 1                               */
	vsf_color(handle,2);    
	vst_point(handle,12,&charw,&charh,&cellw,&cellh);	
	do
	{
		cls;
		if (rez_no == 2)
		{
			x=84;
			y=116;
  		v_bar(handle,rect7); 
  	}	 
		if (rez_no == 1)
  	{
  		x=0;
  		y=0;
  		v_bar(handle,rect8);	  
 		}
    BELL;
    for (i=0;i<5;i++)
    {
  		v_justified(handle,180,x+84,"                                   ",280,1,1);
      delay(TIME*5);
  		v_justified(handle,180,x+84," YOU  DID  NOT  PRESS  'Y' OR 'N'! ",280,1,1);
			delay(TIME*8);
		}
 		v_justified(handle,232,y+116," PLEASE  DO  SO  NOW. ",176,0,1);
  	y_n = getch();
  	y_n = toupper(y_n);
  }
 	while (y_n!='Y' && y_n!='N');
	cls;
  return(y_n); 
}	

int keybd_repeat(int a, int b)
{
	Kbrate(a,b);                  
	return(keybd_repeat);
}

gem_off()
{
	v_clsvwk(handle);
	appl_exit();
}