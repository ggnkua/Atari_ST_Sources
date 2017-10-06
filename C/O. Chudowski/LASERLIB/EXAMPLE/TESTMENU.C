/**************************************************************************/
/*                                                                        */
/*                        T E S T U M G E B U N G                         */
/*                                                                        */
/**************************************************************************/

#include <stdio.h>
#include <libterm.inc>
#include <libstr.inc>
#include <boolop.h>
#include <popmenu.inc>

BYTE *functel();
BYTE *selectall();

extern PM testmenu;

PME vorn_ent[] =
   {
      { "Alois",  (PMVALUE | PMSELECT), "Alois", NULP },
      { "Sandro", (PMVALUE | PMSELECT), "Sandro", NULP },
      { "Menu", (PMMENU | PMSELECT), (BYTE *) &testmenu, NULP },
      { "Olli", (PMVALUE | PMSELECT), "Olli", NULP }
   };
PM vornmenu =
{
   "Vornamen", 10, 6, PMTABSIZE (vorn_ent), vorn_ent
};

PME test_ent[] =
   {
      { "Name", PMVALUE | PMSELECT, "Name select", NULP },
      { "Gebname", PMVALUE | PMSELECT, "Gebname", NULP },
      { "Vorname", PMMENU | PMSELECT, (BYTE *) &vornmenu, "san" },
      { "Alter", PMMENU | PMSELECT, (BYTE *) &vornmenu, NULP },
      { "Strasse", PMVALUE | PMSELECT, "Strasse", NULP },
      { "Bezirk", PMVALUE | PMSELECT, "Bezirk", NULP },
      { "Beruf", PMVALUE | PMSELECT, "Beruf", NULP },
      { "Telefon", PMFUNC | PMSELECT, functel, "Das ist die Telefonnummer" },
      { "Select", PMPROC | PMSELECT, selectall, "" }
   };
   
PM testmenu = 
{
   "Testmenu", 12, 7, PMTABSIZE (test_ent), test_ent
};

BYTE *selectall (dummy, menup)
BYTE *dummy;
PM *menup;
{
   pmselect (menup, "", TRUE);
   return ("Alle Eintraege selektiert!");
}

BYTE *functel (param)
BYTE *param;
{
   static BYTE buf[100];
   extern BYTE *strcpyn();
   
   return (strcpyn (buf, param, " ", "666 777 888", NULP));
}

main ()
{
   BYTE *ret;
   WORD retkey;
   
   t_init();
   pmselect (&testmenu, "B", FALSE);
   pmselect (&testmenu, "alt", FALSE);
   ret = pmexec (&testmenu, 7, 5, "Beruf", &retkey, !ISSUBMENU);
   t_goxy (20, 20);
   printf ("'%s'\n", (retkey == 27 ? "Abbruch" : ret));
   t_getc();
   t_exit();
}

