format ELF64
public _start

section '.data' writable
    symbol db 'a'
    K = 10
    nl db 10

section '.text' executable
_start:
    mov r13,K               ; счётчик символов

.next:
    inc byte [symbol]       ; 'a' -> 'b' -> 'c' ...

    mov eax,1               ; write(1, symbol, 1)
    mov edi,1
    lea rsi,[symbol]
    mov edx,1
    syscall

    dec r13
    jnz .next

    mov eax,1               ; перевод строки
    mov edi,1
    lea rsi,[nl]
    mov edx,1
    syscall

    mov eax,60
    xor edi,edi
    syscall
