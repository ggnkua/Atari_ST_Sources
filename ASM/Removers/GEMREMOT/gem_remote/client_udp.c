#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>

int creer_socket(int type,int *ptr_port,struct sockaddr_in *ptr_adresse);
void client_service(int sock,struct sockaddr_in *adresse,int argc,char *argv[]);

struct sockaddr_in adresse_serveur,adresse_client;

int main(int argc,char *argv[]) {
  int port;
  int socket_client;
  struct hostent *hp;
  if(argc < 3) {
    fprintf(stderr,"erreur sur le nombre de paramètres\n");
    exit(2);
  }
  if((hp=gethostbyname(argv[1])) == NULL) {
    fprintf(stderr,"machine %s inconnue\n",argv[1]);
    exit(2);
  }
  port=0;
  if((socket_client=creer_socket(SOCK_DGRAM,&port,&adresse_client)) == -1) {
    fprintf(stderr,"création de la socket impossible\n");
    exit(2);
  }
  printf("client sur le port %d\n",ntohs(adresse_client.sin_port));
  adresse_serveur.sin_family=AF_INET;
  adresse_serveur.sin_port=htons(atoi(argv[2]));
  memcpy(&adresse_serveur.sin_addr.s_addr,hp->h_addr,hp->h_length);
  client_service(socket_client,&adresse_serveur,argc-3,argv+3);

  exit(0);
}
