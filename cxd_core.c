#include "cxd_core.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <openssl/sha.h>

void secure_wipe(void* v, size_t n) {
    volatile unsigned char* p = (volatile unsigned char*)v;
    while (n--) *p++ = 0;
}

int validate_and_wipe(const char* voter_id, const char* vote, const char* current_location) {
    int success = 0;
    if (voter_id != NULL && vote != NULL) {
        
        if (strcmp(current_location, "Ireland") == 0 || strcmp(current_location, "Texas") == 0) {
        
            unsigned char hash[SHA256_DIGEST_LENGTH];
            SHA256((unsigned char*)vote, strlen(vote), hash);
            
            success = 1; 
        }
    }

    if (voter_id) secure_wipe((void*)voter_id, strlen(voter_id));
    
    return success;
}
