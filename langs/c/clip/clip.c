#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

#define BUFLEN 2048
#define HEADING_LEN 4
#define GREETING (unsigned short)0x1337
#define PORT 2001

int sock;

void sigint_proc(int signum) {
    if (signum == SIGINT) {
        fprintf(stdout, "peace out brother...\n");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        exit(1);
    }
}

int main(int argc, char** argv) {
    struct sockaddr_in serveraddr;
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    char *pd;
    char msg[BUFLEN+1] = {0};
    char response[20] = {0};
    int reslen, bytes_sent;

    if (argc > 1) {
        pd = strndup(argv[1], BUFLEN-HEADING_LEN-1);
    }
    else {
        fprintf(stderr, "Brother please...\n");
        return 1;
    }
    signal(SIGINT, sigint_proc);

    memset(&serveraddr, 0, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, "127.0.0.1", &serveraddr.sin_addr) <= 0) {
        fprintf(stderr, "Hi, There was a problem with the piton\n");
        return 1;
    }

    if (connect(sock, (struct sockaddr*)&serveraddr, sizeof(serveraddr)) == -1) {
        perror("connect");
        fprintf(stderr, "Error connecting\n");
        return 1;
    }

    unsigned short* greeting = (unsigned short*)msg;
    *greeting = GREETING;
    greeting = (unsigned short*)(msg+sizeof(unsigned short));
    *greeting = (unsigned short)strlen(pd);
    strncpy(msg+HEADING_LEN, pd, BUFLEN-HEADING_LEN-1);

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
        else printf("%s", response);
    }
    free(pd);
    close(sock);
    return 0;
}

