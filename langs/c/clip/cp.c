#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <limits.h>
#include <errno.h>
#include <arpa/inet.h>

#include "cp.h"

static char *skip_space(char *argp)
{
    char *endp;
    int i = 0, len;
    if (argp == NULL)
    {
        return NULL;
    }
    len = strnlen(argp, MAXBUFLEN);
    if (len == MAXBUFLEN) {
        return NULL;
    }
    endp = argp + len-1;

    while (isspace(argp[i]) && argp[i] != '\0' && i < MAXBUFLEN) ++i;

    if (i == MAXBUFLEN)
    {
        return NULL;
    }

    return argp+i;
}

static int new_ipa(char *configline, server_ipa *addr) {
    int l = 0;
    BOOL alert;
    int temp;
    char *alertp, *invalid_char;

    if (configline == NULL) {
        return -1;
    }
    else {
        configline = skip_space(configline);
        if (configline == NULL) {
            return -1;
        }
        while (!isspace(configline[l]) && configline[l] != 0 && l < MAXBUFLEN) {
            l++;
        }
        if (l == 0) {
            return -1;
        }
        configline[l] = '\0';
        alertp = configline + l + 1;
        if (*alertp == 0) {
            alertp = NULL;
            addr->alert = alert = 0;
        }
        else {
            temp = strtol(alertp, &invalid_char, 10);
			if ((errno == ERANGE && (temp == LONG_MAX || temp == LONG_MIN)) || (errno != 0 && temp == 0)) {
				perror("strtol");
				return -1;
			}
			if (invalid_char == alertp) {
				return -1;
			}
			alert = temp;
        }
    }

    return 0;
}

int load_ipas(const char* fn, server_ipa *ipas, unsigned int n) {
    char line[MAXBUFLEN];
    server_ipa addr;
    int num_ipas = 0;
    FILE *f;

    if (fn == NULL) {
        f = fopen(CONFIG, "r");
    }
    else {
        f = fopen(fn, "r");
    }

    if (f == NULL) {
        perror("fopen");
        return -1;
    }

    while (num_ipas < MAX_IPAS && fgets(line, MAXBUFLEN, f)) {
       if (new_ipa(line, &ipas[num_ipas])) {
           fprintf(stderr, "Error parsing line [%i] in config\n", num_ipas+1);
            return -1;
       }
       puts(line);
       num_ipas++;
    }

    if (num_ipas == 0) {
        fprintf(stderr, "Could not load any IPAS\n");
        return -1;
    }

    if (fclose(f) != 0) {
        perror("fclose");
        return -1;
    }

    return num_ipas+1;
}

