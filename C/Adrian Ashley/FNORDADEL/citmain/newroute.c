
   91May11 10:39:09 pm from ranger @ moonsweep
   From: ranger@moonsweep
 
 subj - code to implement the tricky part of route-map automatic updating
  (that is, the actual updating)
 
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 
 typedef enum {HEREIS, REQUEST} rectypes;
 
 typedef struct {
    char domainid[40];
    char path[60];
    long cost;
    int netcredits;
    int isbad;
 } path_record;
 
  typedef struct {
    rectypes type;
    char domainid[40];
    char path[60];
    long cost;
 } hold_record;
 
 static path_record *paths;
 static int npaths;
 
 #define OURPATHS "d:\\sysdir\\ctdlrout.sys"
 #define SNDPATHS "d:\\netdir\\sndpaths.sys"
 #define RCVPATHS "d:\\netdir\\rcvpaths.sys"
 
  /*
   * The file OURPATHS is where our paths go - a binary file of path_records.
   * The file SNDPATHS holds the records for sending info to other systems. 
   *  (Binary file of hold_records)
   * The file RCVPATHS is where info coming in from other systems is left.
   *  (Binary file of hold_records)
   */
 
 static int add_to_ourpaths(path_record *p) {
   path_record *tmp;
   tmp = realloc(paths, npaths+1);
   if (!tmp) return -1;
   paths = tmp;
   paths[npaths] = *p;
   npaths++;
   return 0;
 }
 
 static int load_ourpaths(void) {
   path_record p;
   FILE *f;
   f = fopen(OURPATHS, "rb");
   if (!f) return -1;
   while (fread(&p, 1, sizeof(path_record), f)==1)
     if (add_to_ourpaths(&p)) {fclose(f); return -1;}
   fclose(f);
   return 0;
 }
 
 static int save_ourpaths(void) {
   FILE *f;
   f = fopen(OURPATHS, "wb"); /* FIXME: should really write and rename */
   if (!f) return -1;
   fwrite(paths, npaths, sizeof(path_record), f);
   fclose(f);
   return 0;
 }
 
 static int send_to_all(rectypes t, char *domainid, long cost, char *except) 
{
   char sysname[40];
   hold_record s;
   FILE *f;
   s.type = t;
   strcpy(s.domainid, domainid);
   s.cost = cost;
   f = fopen(SNDPATHS, "ab");
   if (!f) return -1;
   /*
    * Do this for EACH neighbor system "sysname"...
    *  -- except the one given in *except!
    */ {
     strcpy(s.path, sysname);
     fwrite(&s, 1, sizeof(hold_record), f);
   }
   fclose(f);
   return 0;
 }
 
 static int send_to_one(rectypes t, char *domainid, long cost, char *sysname)
{
   hold_record s;
   FILE *f;
   s.type = t;
   strcpy(s.domainid, domainid);
   strcpy(s.path, sysname);
   s.cost = cost;
   f = fopen(SNDPATHS, "ab");
   if (!f) return -1;
   fwrite(&s, 1, sizeof(hold_record), f);
   fclose(f);
   return 0;
 }
 
 static int find_path(char *domainid) {
   int i;
   for (i=0; i<npaths && strcmpi(domainid, paths[i].domainid); i++);
   if (i==npaths) {
     path_record p;
     strcpy(p.domainid, domainid);
     *p.path = 0;
     p.cost = 0x7FFFFFFFL;  /* large number */
     p.netcredits = 0;
     p.isbad = 1;
     add_to_ourpaths(&p); 
     /* after this i will contain the old npaths, which is now the */
     /* correct number. Watch out if rewriting add_to_ourpaths(). */
   }
   return i;
 }
 
 static void process_path(hold_record *h) {
   int i;
   i = find_path(h->domainid);
   switch (h->type) {
     case HEREIS: 
       if (h->cost < paths[i].cost || paths[i].isbad) {
         /* better path */
         strcpy(paths[i].path, h->path);
         paths[i].cost = h->cost;
         /* domainid is already the same, why copy it? */
         paths[i].netcredits = 0;  /* FIXME */
         paths[i].isbad = 0;
         send_to_all(HEREIS, h->domainid, h->cost, h->path);
       }
       break;
     case REQUEST: 
       if (!strcmpi(paths[i].path, h->path)) {
         /* our path was through the system that asked; ask our neighbors */
         send_to_all(REQUEST, h->domainid, 0, h->path); /*cost fld 
irrelevant*/
         paths[i].isbad = 1; /* our path is no longer valid */
       }
       else {
         /* send them our path */
         send_to_one(HEREIS, h->domainid, paths[i].cost, h->path);
       }
   }
 }
 
 int process_new_paths(void) {
   hold_record h;
   FILE *f;
   f = fopen(RCVPATHS, "rb");
   if (!f) return -1;
   while (fread(&h, 1, sizeof(hold_record), f)==1) process_path(&h);
   fclose(f);
   return 0;
 }
 
 
   /*
    * Here it is: code to deal with incoming path data as per my proposal.
    * The code to route something according to this information is easy:
    * the system or bang-path to route to is given in the "path" field of
    * the path_record. The "domainid" field is what you're routing to; if
    * it is an individual system it should probably include the domain 
    * (i.e., C-86 Test System -> C-86 Test System.MN) but, you know, info 
    * for just the .MN domain can be sent around also. Some care needs to 
    * be taken checking if a system somebody's asking about is a neighbor (in

    * process_path()) - I couldn't write it in because I have no idea how 
this 
    * information is stored.
    * Some thought needs to be applied on the best method of restricting the
    * distribution of information about some systems to their own domain; 
this
    * code as it exists sends everybody's data everywhere, which isn't the 
    * ideal. 
    * 
    * Code to actually SEND the stuff that is dumped out in the temp file
    * should be highly straightforward. Remember, the "path" field is 
included
    * so the networker knows which system to send each record to; the 
contents
    * of the path field should not be sent.
    */



   91May11 10:51 pm from ranger @ Blade
While that code isn't quite sufficient to compile and go, it should make
things easier and/or clearer. There is one place (in send_to_all()) that 
needs
to have a loop "looped", since I don't know how neighbor systems are kept
track of.
 
   btw - a neighbor system is a system you call (relatively) frequently and
exchange mail with. [definition]

