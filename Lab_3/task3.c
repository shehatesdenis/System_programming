#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc != 4) {
        return 1;
    }

    long long a = strtoll(argv[1], NULL, 10);
    long long b = strtoll(argv[2], NULL, 10);
    long long c = strtoll(argv[3], NULL, 10);

    if (c == 0) {
        return 1;
    }

    long long result = (((a - c) * b) / c) * a;
    printf("%lld\n", result);
    return 0;
}