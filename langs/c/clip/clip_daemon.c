#include <event2/event.h>
#include <event2/listener.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdio.h>

typedef struct {
    char* r;
} rctx;

void accept_cb(struct evconnlistener *listener, evutil_socket_t fd,
        struct sockaddr *address, int socklen, void *ctx) {

    

}

void accept_error_cb(struct evconnlistener *listener, void *ptr) {
    
}

int main(int argc, char **argv) {
    struct event_base* ev_base = event_base_new();
    struct sockaddr_in sin;
    rctx *ctx = NULL;
    int port = 2001;

    if (argc > 1) {
        port = atoi(argv[1]);
    }
    if (port <= 0 || port > 65535) {
       fprintf(stderr, "Invalid Port.\n");
       return 1;
    }
    fprintf(stdout, "Going to Use Port %i\n", port);

    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = htonl(0);
    sin.sin_port = htons(port);

    struct evconnlistener* listener = evconnlistener_new_bind(ev_base, accept_cb, ctx,
            LEV_OPT_CLOSE_ON_FREE | LEV_OPT_THREADSAFE | LEV_OPT_REUSEABLE, -1, (struct sockaddr*)&sin, sizeof(sin));

    if (!listener) {
        perror("Could not create listener.\n");
        return 1;
    }

    evconnlistener_set_error_cb(listener, accept_error_cb);

    event_base_dispatch(ev_base);

    evconnlistener_free(listener);
    event_base_free(ev_base);
    libevent_global_shutdown();
    return 0;
}

