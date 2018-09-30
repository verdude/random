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

void accept_error_cb(struct evconnlistener *listener, evutil_socket_t fd,
        struct sockaddr *address, int socklen, void *ctx) {

    

}

int main(int argc, char **argv) {
    struct event_base* ev_base = event_base_new();
    struct sockaddr_in sin = {
        .sin_family = AF_INET,
        .sin_port = htonl(2001),
        .sin_addr = {
            .s_addr = htons(0)
        }
    };
    rctx *ctx = NULL;
    struct evconnlistener* listener = evconnlistener_new_bind(ev_base, accept_cb, ctx,
            LEV_OPT_CLOSE_ON_FREE | LEV_OPT_THREADSAFE | LEV_OPT_REUSEABLE, -1, (struct sockaddr*)&sin, sizeof(sin));

    if (!listener) {
        fprintf(stderr, "Could not create listener.\n");
        return 1;
    }

    evconnlistener_set_error_cb(listener, accept_error_cb);

    event_base_dispatch(ev_base);

    evconnlistener_free(listener);
    event_base_free(ev_base);
    libevent_global_shutdown();
    return 0;
}

