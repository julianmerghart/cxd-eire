#ifndef CXD_CORE_H
#define CXD_CORE_H

#include <stddef.h>

// The primary security handshake
// Returns 1 if valid and processed, 0 if failed
int validate_and_wipe(const char* voter_id, const char* vote, const char* expected_geofence);

// Internal utility to zero-out sensitive RAM
void secure_wipe(void* v, size_t n);

#endif
