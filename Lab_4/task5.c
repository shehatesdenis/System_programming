#include "read_n.h"

int main(void) {
    long long n;
    if (!read_n(&n)) {
        return 1;
    }

    long long count = n > 0 ? n - n / 55 : 0;
    printf("Count: %lld\n", count);
    return 0;
}
