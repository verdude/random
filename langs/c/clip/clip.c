#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFLEN 2048

int main(int argc, char** argv) {
    struct sockaddr_in serveraddr;
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    char *pd;
    char msg[BUFLEN] = {0};

    if (argc > 1) {
        pd = strndup(argv[1], BUFLEN-5);
    }
    else {
        fprintf(stderr, "Brother please...\n");
        return 1;
    }

    memset(&serveraddr, 0, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_port = htons(2001);

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
    *greeting = 0x1337;
    greeting = (unsigned short*)(msg+2);
    *greeting = (unsigned short)strlen(pd);
    strncpy(msg+4, pd, BUFLEN-4);
    printf("Sending data:\n%s\n", pd);
    send(sock, msg, 4+*greeting, 0);
    free(pd);
    return 0;
}

