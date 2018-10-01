#include <event2/event.h>
#include <event2/listener.h>
#include <event2/bufferevent.h>
#include <event2/buffer.h>
#include <sys/socket.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include "clipdef.h"


typedef struct {
    char* pd;
    size_t xlen;
    size_t rlen;
} pdctx_t;

pdctx_t *create_pdctx() {
    pdctx_t *p = malloc(sizeof(pdctx_t));
    memset(p, 0, sizeof(pdctx_t));
    return p;
}

void free_pdctx(pdctx_t *ctx) {
    if (!ctx) {
        return;
    }
    if (ctx->pd) {
        free(ctx->pd);
    }
    free(ctx);
}

void reader_event_cb(struct bufferevent *bev, short events, void *ctx) {
    if (events & BEV_EVENT_ERROR) {
        perror("error from bufferevent");
    }
    if (events & (BEV_EVENT_EOF | BEV_EVENT_ERROR)) {
        // free context
        pdctx_t* t = (pdctx_t*)ctx;
        free_pdctx(t);
        bufferevent_free(bev);
    }
}

void set_data_cb(struct bufferevent *bev, void *ctx) {
    pdctx_t *pdc = ctx;
    struct evbuffer *input = bufferevent_get_input(bev);
    size_t len = evbuffer_get_length(input);
    char *mlen[MSG_LEN_BYTES] = {0};
    int xlen;

    // get length of the message
    if (len > 1 && pdc->xlen == 0) {
        bufferevent_read(bev, mlen, MSG_LEN_BYTES);
        len -= MSG_LEN_BYTES;
        xlen = *(short*)mlen;
        if (xlen <= 0 || xlen > MAX_BUFLEN) {
            fprintf(stderr, "Invalid content length: [%i].\n", xlen);
            free_pdctx(pdc);
            bufferevent_free(bev);
            return;
        }
        else {
            pdc->xlen = xlen;
            pdc->pd = calloc(xlen+1, sizeof(char));
            bufferevent_setcb(bev, set_data_cb, NULL, reader_event_cb, pdc);
            if (len > 0) {
                set_data_cb(bev, pdc);
            }
        }
    }

    // ready to read message
    if (len > 0 && pdc->xlen > 0 && pdc->rlen < pdc->xlen) {
        int ret = bufferevent_read(bev, pdc->pd + pdc->rlen, len);
        if (ret != -1) {
            pdc->rlen += len;
            len = 0;
            if (pdc->rlen == pdc->xlen) {
                char successret[] = "Thanks for playing.";
                char failureret[] = "FAILURE.";
                char* ret = setenv(NAME, pdc->pd, 1) == 0 ? successret : failureret;

                bufferevent_write(bev, ret, strlen(ret));
                free_pdctx(pdc);
                // Free'ing the bufferevnet here closes the socket and kills
                // the connection before the return message can be sent
                //bufferevent_free(bev);
            }
        }
    }
}

void reader_cb(struct bufferevent *bev, void* ctx) {
    pdctx_t *pdc = ctx;
    struct evbuffer *input = bufferevent_get_input(bev);
    size_t len = evbuffer_get_length(input);
    char greeting[GREETING_LEN] = {0};
    unsigned short g;

    if (len > 1 && pdc->xlen == 0) {
        bufferevent_read(bev, greeting, GREETING_LEN);
        g = *(short*)greeting;
        len -= GREETING_LEN;
        if (g == SET_GREETING) {
            bufferevent_setcb(bev, set_data_cb, NULL, reader_event_cb, pdc);
            if (len > 0) {
                set_data_cb(bev, pdc);
            }
        }
        else if (g == GET_GREETING){
            char* data = getenv(NAME);
            if (data == NULL) {
                char error[RESPONSE_LEN_BYTES] = {0};
                unsigned short *errn = (unsigned short*)error;
                *errn = ERROR_NOT_FOUND;
                bufferevent_write(bev, errn, RESPONSE_LEN_BYTES);
            }
            else {
                bufferevent_write(bev, data, strnlen(data, MAX_BUFLEN));
            }
            free_pdctx(pdc);
        }
        else {
            free_pdctx(pdc);
            bufferevent_free(bev);
        }
    }

}

void accept_cb(struct evconnlistener *listener, evutil_socket_t fd,
        struct sockaddr *address, int socklen, void *ctx) {

    struct event_base *base = evconnlistener_get_base(listener);
    struct bufferevent *bev = bufferevent_socket_new(base, fd, BEV_OPT_CLOSE_ON_FREE);
    if (!bev) {
        fprintf(stderr, "...Could not create bufferevent...\n");
        perror("Same error as above\n");
    }

    pdctx_t *pdctx = create_pdctx();
    bufferevent_setcb(bev, reader_cb, NULL, reader_event_cb, pdctx);
    bufferevent_enable(bev, EV_READ | EV_WRITE);
}

void accept_error_cb(struct evconnlistener *listener, void *ptr) {
    struct event_base *base = evconnlistener_get_base(listener);
    int err = EVUTIL_SOCKET_ERROR();
    fprintf(stderr, "Got an error %d (%s) on the listener."
            "Shutting down.\n", err, evutil_socket_error_to_string(err));
    event_base_loopexit(base, NULL);
}

void sigint_cb(evutil_socket_t fd, short event, void *arg) {
    int signum = fd;
    if (signum == SIGINT) {
        fprintf(stdout, "Caught SIGINT..Shutting down..\n");
        event_base_loopbreak(arg);
    }
    else {
        fprintf(stderr, "Caught signal with code: [%i]\n", signum);
    }
}

int main(int argc, char **argv) {
    struct event_base* ev_base = event_base_new();
    struct sockaddr_in sin;
    pdctx_t *ctx = NULL;
    int port = PORT;
    struct event *sev_int;

    if (argc > 1) {
        port = atoi(argv[1]);
    }
    if (port <= 0 || port > 65535) {
       fprintf(stderr, "Invalid Port.\n");
       return 1;
    }
    fprintf(stdout, "p:%i\n", port);

    sev_int = evsignal_new(ev_base, SIGINT, sigint_cb, ev_base);
    if (sev_int == NULL) {
        fprintf(stderr, "Couldn't create sigint handler.\nShutting down.\n");
        libevent_global_shutdown();
        return 1;
    }
    evsignal_add(sev_int, NULL);

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

    event_free(sev_int);
    evconnlistener_free(listener);
    event_base_free(ev_base);
    libevent_global_shutdown();
    return 0;
}

