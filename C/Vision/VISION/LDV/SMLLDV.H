#ifndef __SMLLDV
#define __SMLLDV

#pragma warn -par
LDV_MODULE *SmlLDVGetModuleList(char *path_ldv)
{
  long size ;
  LDV_MODULE *mods ;
  LDV_MODULE tab_module[] = {
                              /* Module 1 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_STDFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_STDFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_STDFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT | LDVF_SUPPORTPROG | LDVF_SUPPORTPREVIEW },
                                  { 16, 16, LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW },
                                  { 32, 32, LDVF_ATARIFORMAT | LDVF_SUPPORTPROG },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 2 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT | LDVF_SPECFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT | LDVF_SPECFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT | LDVF_SPECFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 3 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_SPECFORMAT | LDVF_AFFECTPALETTE },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 4 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 5 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 6 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 7 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 8 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 9 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 1 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 2 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 3 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 4 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 5 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 6 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  1, 1, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },

                              /* Module 7 */
                              { (LDG *) 0x00000001UL, "Mod.LDV",
                                sizeof(LDV_INFOS), TLDV_MODIFYIMG,
                                "Jean Lusetti",
                                {
                                  {  4, 4, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  {  8, 8, LDVF_ATARIFORMAT | LDVF_AFFECTPALETTE },
                                  { 15, 15, LDVF_ATARIFORMAT },
                                  { 16, 16, LDVF_ATARIFORMAT },
                                  { 32, 32, LDVF_ATARIFORMAT },
                                  {  0, 0, 0 },
                                }
                              },


                              /* Dernier module (marqueur de fin) */
                              { NULL, "",
                                0, 0,
                                "", "",
                                {
                                  {  0, 0 },
                                }
                              }
                            } ;

  size = (long) sizeof(tab_module) ;
  mods = (LDV_MODULE *) malloc( size ) ;
  if ( mods ) memcpy( mods, tab_module, size ) ;

  return( mods ) ;
}
#pragma warn +par
#endif
