#include <stdio.h>

int main(void) {
    long long n;
    if (scanf("%lld", &n) != 1) return 1;
    long long count = 0;
    for (long long k = 1; k <= n; ++k)
        if (k % 11 != 0 && k % 5 != 0) ++count;
    printf("Count: %lld\n", count);
    return 0;
}
