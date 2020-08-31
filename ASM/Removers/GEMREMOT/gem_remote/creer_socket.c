#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

static struct sockaddr_in adresse;

int creer_socket(int type,int *ptr_port,struct sockaddr_in *ptr_adresse) {
  int desc;
  int longueur=sizeof(struct sockaddr_in);
  if((desc = socket(AF_INET,type,0)) == -1) {
    fprintf(stderr,"création de socket impossible\n");
    return -1;
  }
  adresse.sin_family = AF_INET;
  adresse.sin_addr.s_addr = htonl(INADDR_ANY);
  adresse.sin_port = htons(*ptr_port);
  if(bind(desc,(struct sockaddr *)&adresse,longueur) == -1) {
    fprintf(stderr,"attachement de la socket impossible\n");
    close(desc);
    return -1;
  }
  if(ptr_adresse != NULL) {
    getsockname(desc,(struct sockaddr *)ptr_adresse,&longueur);
  }
  return desc;
}
