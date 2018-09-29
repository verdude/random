#include <event2/event.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char **argv) {
    puts("hi");
    libevent_global_shutdown();
}

