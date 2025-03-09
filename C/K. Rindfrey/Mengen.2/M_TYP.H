/*  M_TYP.H --- Typefinitionen fuer Bitsets                   */

/*
 * BitSetDefType --- Enthaelt Informationen des Mengentyps.
 *   !!! Interne Struktur - Nicht darauf zugreifen !!!
 */
typedef struct {
                  unsigned arrlen;   /* Laenge von bitset[].      */
                  unsigned maxcard;  /* Max. Kardinalitaet.       */
                  int      minelem;  /* Kleinstes moegliche
                                      * Element.                  */
                  int      maxelem;  /* Groesstes moegliche
                                      * Element.                  */
                  unsigned mask;     /* Zum Maskieren des letzten
                                      * Feldes in bitset[].       */
               } BitSetDefType;

/*
 * BitSetType --- Datentyp fuer Mengen.
 * !!! Interne Struktur - Nicht darauf zugreifen !!!
 */
typedef struct {
                  BitSetDefType *bsdef; /* Zeigt auf Definition des
                                         * Mengentyps.              */
                  unsigned  bitset[];   /* Menge als Bitmuster.     */
               } BitSetType;
 
/*
 * BS_OpId --- Code fuer die moeglichen Mengenoperationen.
 */
typedef enum {
                BS_UNION, BS_INTERSECT, BS_DIFFERENCE, BS_INCLUDE,
                BS_EXCLUDE, BS_ISELEMENT, BS_ISEQUAL, BS_ISSUBSET,
                BS_CARDINAL, BS_COMPLEMENT
             } BS_OpId;

#define TRUE  1
#define FALSE 0

