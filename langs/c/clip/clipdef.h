#ifndef CLIPDEF_H
#define CLIPDEF_H

// data structures
#define MAX_BUFLEN 0x800
#define NAME "clipdata"

// server info
#define PORT 45341

// response/request codes should all be
// 2 bytes long with no null bytes
#define SET_GREETING (unsigned short)0x1337
#define GET_GREETING (unsigned short)0xdead

#define ERROR_NOT_FOUND (unsigned short)0x404
#define SUCCESS (unsigned short)0x201

// proto
#define GREETING_LEN 2
#define MSG_LEN_BYTES 2
#define RESPONSE_LEN_BYTES 2
#define HEADING_LEN (GREETING_LEN+MSG_LEN_BYTES)

#endif // CLIPDEF_H
