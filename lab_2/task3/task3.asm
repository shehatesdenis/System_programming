format ELF64
public _start

section '.data' writable
    N = 45

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

    xor r13,r13             ; сколько символов уже выведено (смещение в buf)
    xor r12,r12             ; длина текущей строки

.tri:
    inc r12                 ; 1, 2, 3, ...

    mov eax,1               ; write(1, buf+r13, r12)
    mov edi,1
    lea rsi,[buf+r13]       ; продолжаем с того места, где остановились
    mov rdx,r12
    syscall

    add r13,r12

    mov eax,1               ; перевод строки
    mov edi,1
    lea rsi,[nl]
    mov edx,1
    syscall

    cmp r13,N
    jb .tri

    mov eax,60
    xor edi,edi
    syscall
