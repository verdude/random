#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#include "clipdef.h"

int sock;

void sigint_proc(int signum) {
    if (signum == SIGINT) {
        fprintf(stdout, "peace out brother...\n");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        exit(1);
    }
}

int get_ip(char *hostname, char* ip) {
    struct addrinfo hints, *servinfo, *p;
    struct sockaddr_in *h;
    int rv;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC; // use AF_INET6 to force IPv6
    hints.ai_socktype = SOCK_STREAM;

    if ( (rv = getaddrinfo( hostname , "http" , &hints , &servinfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and connect to the first we can
    for(p = servinfo; p != NULL; p = p->ai_next)
    {
        h = (struct sockaddr_in *) p->ai_addr;
        strcpy(ip , inet_ntoa( h->sin_addr ) );
    }

    freeaddrinfo(servinfo); // all done with this structure
    return 0;
}

int main(int argc, char** argv) {
    struct sockaddr_in serveraddr;
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    char *pd;
    char msg[MAX_BUFLEN+1] = {0};
    char response[20] = {0};
    char ip[20] = {0};
    int reslen, bytes_sent;

    if (argc > 2) {
        pd = strndup(argv[1], MAX_BUFLEN-HEADING_LEN-1);
    }
    else {
        fprintf(stderr, "Brother please...\n");
        return 1;
    }
    signal(SIGINT, sigint_proc);

    memset(&serveraddr, 0, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_port = htons(PORT);

    if (get_ip(argv[1], ip) != 0) {
        fprintf(stderr, "Could not find host: %s\n", argv[1]);
        return 1;
    }
    if (inet_pton(AF_INET, ip, &serveraddr.sin_addr) <= 0) {
        fprintf(stderr, "Hi, There was a problem with the piton\n");
        return 1;
    }

    if (connect(sock, (struct sockaddr*)&serveraddr, sizeof(serveraddr)) == -1) {
        perror("connect");
        fprintf(stderr, "Error connecting\n");
        return 1;
    }

    unsigned short* greeting = (unsigned short*)msg;
    *greeting = SET_GREETING;
    greeting = (unsigned short*)(msg+sizeof(unsigned short));
    *greeting = (unsigned short)strlen(pd);
    strncpy(msg+HEADING_LEN, pd, MAX_BUFLEN-HEADING_LEN-1);

    if ((bytes_sent = send(sock, msg, HEADING_LEN+*greeting, 0)) == -1) {
        fprintf(stderr, "Failed to send message.\n");
    }
    else {
        if ((reslen = recv(sock, response, 20, 0)) == 0) {
            fprintf(stderr, "Recieved no bytes for some reason\n");
        }
        else if (reslen == -1) {
            perror("recv");
        }
        else printf("%s\n", response);
    }
    free(pd);
    close(sock);
    return 0;
}

