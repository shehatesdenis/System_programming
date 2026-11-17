format ELF64
public _start

section '.data' writable
    N = 45
    M = 5
    K = 9

    buf rb N
    nl db 10

section '.text' executable
_start:
    lea rdi,[buf]
    mov al,'!'
    mov rcx,N

.fill:
    mov [rdi],al
    inc rdi
    loop .fill

    lea r12,[buf]           ; указатель на текущий символ
    mov r13,K               ; счётчик строк

.row:
    mov r14,M               ; счётчик колонок

.col:
    mov eax,1               ; write(1, r12, 1) - один символ
    mov edi,1
    mov rsi,r12
    mov edx,1
    syscall

    inc r12                 ; следующий символ в памяти
    dec r14
    jnz .col                ; пока не вывели M символов

    mov eax,1               ; перевод строки
    mov edi,1
    lea rsi,[nl]
    mov edx,1
    syscall

    dec r13
    jnz .row                ; пока не вывели K строк

    mov eax,60
    xor edi,edi
    syscall
