#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    char c;
    long hours = 0;
    long mins = 0;

    opterr=0;

    while ((c = getopt(argc, argv, "h:m:")) != -1) {
        switch(c) {
            case 'h':
                hours = strtol(optarg, NULL, 10);
                break;
            case 'm':
                mins = strtol(optarg, NULL, 10);
                break;
            case '?':
                if (optopt != 'h' || optopt != 'm')
                    printf("[%c] is not an option", optopt);
                break;
            default:
                printf("unstandard failure.");
        }
    }
    printf("The given Values are: \"%lu\" and \"%lu\"\n", hours, mins);
}

