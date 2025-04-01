/*******************************/
/* get_lang                    */
/* Ermitteln der Systemsprache */
/* (c)1993 by MAXON-Computer   */
/* Autor: Uwe Seimet           */
/*******************************/

#include <stdio.h>
#include <tos.h>
#include <aes.h>

#define AKP 0x5f414d50l

char *code_to_lang[] =
  { "USA", "FRG", "FRA", "UK",
    "SPA", "ITA", "SWE", "SWF",
    "SWG", "TUR", "FIN", "NOR",
    "DEN", "SAU", "HOL" };

int get_lang(void);
int appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2,
  int *ap_gout3, int *ap_gout4);
extern int aes(void *aespb[]);

main()
{
  int language;
  char msg[40];

  if (appl_init() < 0) return(-1);

  language = get_lang();
  sprintf(msg, "[0][Systemsprache: %s  ][  OK  ]",
    code_to_lang[language]);
  form_alert(1, msg);

  appl_exit();
  return(0);
}

int get_lang()
{
  long old_stack = 0;
  long *cookie_jar;
  int lang;
  int dummy;
  SYSHDR *syshdr;

  if (!Super((void *)1l)) old_stack = Super(0l);

/* Zun„chst Systemheader auswerten */

  syshdr = *(SYSHDR **)0x4f2;
  syshdr = syshdr->os_base;
  lang = syshdr->os_palmode>>1;

/* Als n„chstes _AKP-cookie berprfen */

  cookie_jar = *(long **)0x5a0;
  while (cookie_jar[0]) {
    if (cookie_jar[0] == AKP) {
      lang = (int)(cookie_jar[1]>>8);
      break;
    }
    else cookie_jar = &(cookie_jar[2]);
  }

  if (old_stack) Super((void *)old_stack);

/* Zum Schluž noch der Test auf AES 4.0 */

  if (_GemParBlk.global[0] >= 0x0400)
    appl_getinfo(3, &lang, &dummy, &dummy, &dummy);

  return(lang);
}

/* Vorl„ufige Implementation von appl_getinfo */

int appl_getinfo(ap_gtype, ap_gout1, ap_gout2, ap_gout3, ap_gout4)
int ap_gtype;
int *ap_gout1;
int *ap_gout2;
int *ap_gout3;
int *ap_gout4;
{
  void *aespb[6];

  aespb[0] = _GemParBlk.contrl;
  aespb[1] = _GemParBlk.global;
  aespb[2] = _GemParBlk.intin;
  aespb[3] = _GemParBlk.intout;
  aespb[4] = _GemParBlk.addrin;
  aespb[5] = _GemParBlk.addrout;

  _GemParBlk.contrl[0] = 130;
  _GemParBlk.contrl[1] = 1;
  _GemParBlk.contrl[2] = 5;
  _GemParBlk.contrl[3] = 0;
  _GemParBlk.contrl[4] = 0;

  _GemParBlk.intin[0] = ap_gtype;

  aes(aespb);

  *ap_gout1 = _GemParBlk.intout[1];
  *ap_gout2 = _GemParBlk.intout[2];
  *ap_gout3 = _GemParBlk.intout[3];
  *ap_gout4 = _GemParBlk.intout[4];

  return(_GemParBlk.intout[0]);
}

