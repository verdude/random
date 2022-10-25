#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#include "clipdef.h"
#include "cp.h"

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

int is_hostname(char *s) {
    if (!s) {
        return -1;
    }
    else if (isdigit(s[0])) {
        return 0;
    }
    else {
        return 1;
    }
}

void setup_sockaddr(char *str) {
    struct sockaddr_in serveraddr;
    char ip[20] = {0};
    int ishostname;
    memset(&serveraddr, 0, sizeof(struct sockaddr_in));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_port = htons(PORT);

    if ((ishostname = is_hostname(str)) == 0) {
        strncpy(ip, str, 15);
    }
    else if (ishostname == 0) {
        if (get_ip(str, ip) != 0) {
            fprintf(stderr, "Could not find host: %s\n", str);
        }
    }
    if (inet_pton(AF_INET, ip, &serveraddr.sin_addr) <= 0) {
        fprintf(stderr, "Hi, There was a problem with the piton\n");
    }

}

int send_msg(int sock, char *pd, char *msg, char *response) {
    int reslen, bytes_sent;
    unsigned short* greeting = (unsigned short*)msg;
    *greeting = SET_GREETING;
    greeting = (unsigned short*)(msg+sizeof(unsigned short));
    *greeting = (unsigned short)strlen(pd);
    strncpy(msg+HEADING_LEN, pd, MAX_BUFLEN-HEADING_LEN-1);

    if ((bytes_sent = send(sock, msg, HEADING_LEN+*greeting, 0)) == -1) {
        fprintf(stderr, "Failed to send message.\n");
        return -1;
    }
    else {
        if ((reslen = recv(sock, response, 200, 0)) == 0) {
            fprintf(stderr, "Recieved no bytes for some reason\n");
            return -1;
        }
        else if (reslen == -1) {
            perror("recv");
            return -1;
        }
        else  {
            printf("%s\n", response);
        }
    }
    return 0;
}

int main(int argc, char** argv) {
    server_ipa ipas[MAX_IPAS];
    char *pd;
    char msg[MAX_BUFLEN+1] = {0};
    char response[20] = {0};
    int addresses, i;


    if (argc > 1) {
        pd = strndup(argv[1], MAX_BUFLEN-HEADING_LEN-1);
    }
    else {
        fprintf(stderr, "Brother please...\n");
        return 1;
    }
    signal(SIGINT, sigint_proc);
    addresses = load_ipas(NULL, ipas, MAX_BUFLEN);

    for (i = 0; i < addresses; ++i) {
        sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (connect(sock, (struct sockaddr*)&ipas[i].addr, sizeof(struct sockaddr_in)) == -1) {
            if (ipas[i].alert) {
                perror("connect");
                fprintf(stderr, "Failed to connect to %s\n", ipas[i].addrstr);
                close(sock);
                break;
            }
        }
        else {
            send_msg(sock, pd, msg, response);
        }
        close(sock);
    }

    free(pd);
    return 0;
}

