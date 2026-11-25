#include <limits.h>
#include "read_n.h"

int main(void) {
    long long n;
    if (!read_n(&n)) {
        return 1;
    }

    long long sum = 0;
    if (n > 0) {
        int odd = n % 2;
        long long left = n / 2 + odd;
        long long right = n + !odd;
        if (left > LLONG_MAX / right) {
            return 1;
        }
        sum = left * right;
        if (!odd) {
            sum = -sum;
        }
    }
    printf("Sum: %lld\n", sum);
    return 0;
}
