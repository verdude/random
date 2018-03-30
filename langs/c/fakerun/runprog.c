#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

char* people() {
    return "(-(-_(-_-)_-)-)";
}

char* bender() {
	return "¦̵̱ ̵̱ ̵̱ ̵̱ ̵̱(̢ ̡͇̅└͇̅┘͇̅ (▤8כ−◦";
}

void print_dots(unsigned short num_dots, unsigned delay) {
    for (unsigned short i = 0; i < num_dots; i++) {
        printf(". ");
        usleep(delay);
    }

    // reset the output to the beginning of the line
    printf("\b\b\b\b");
    // x out the dots
    for (unsigned short i = 0; i < num_dots; i++) {
        printf("X ");
        usleep(delay*2);
    }
}

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
    // Automatically write to stdout rather than waiting for the buffer to be
    // flushed.
    // Will slow down writing to a file.
    setvbuf(stdout, NULL, _IONBF, BUFSIZ);
    // 500 milliseconds
    print_dots(10, 500000);
    printf("\n");
}

