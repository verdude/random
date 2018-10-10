#ifndef cp_h
#define cp_h

#define MAX_IPAS 5
#define MAXBUFLEN 21
#define CONFIG "domain.txt"
typedef unsigned char BOOL;

typedef struct {
    struct sockaddr_in addr;
    BOOL alert;
} server_ipa;

/**
 *  Loads the ipas from the file titled fn
 *  if fn is NULL, ipas will be attempted to be loaded from a file named CONFIG
 *  stores the ipas in the array ipas
 *  n denotes the length of the ips array
 *  however, load_ipas whill not load more than MAXBUFLEN ipas
 *  returns the number of ipas loaded on success, -1 on failure
 */
int load_ipas(const char *fn, server_ipa *ipas, unsigned int n);

#endif // cp_h

