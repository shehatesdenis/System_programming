#ifndef LAB_4_READ_N_H
#define LAB_4_READ_N_H

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int read_n(long long *n) {
    char input[128];
    if (fgets(input, sizeof input, stdin) == NULL) {
        return 0;
    }

    size_t length = strlen(input);
    if (length == sizeof input - 1 && input[length - 1] != '\n') {
        return 0;
    }

    char *end;
    errno = 0;
    long long value = strtoll(input, &end, 10);
    if (end == input || errno == ERANGE) {
        return 0;
    }
    while (isspace((unsigned char)*end)) {
        ++end;
    }
    if (*end != '\0') {
        return 0;
    }
    *n = value;
    return 1;
}

#endif
