format ELF64
public _start

section '.data' writable
    string db 'ywSzWnIvoXjsEqgFRwuyZYQwUGXWv'
    s_len = $ - string

    buf rb s_len
    nl db 10

section '.text' executable
_start:
    lea rsi,[string]
    lea rdi,[buf+s_len-1]
    mov rcx,s_len

.reverse:
    mov al,[rsi]
    mov [rdi],al
    inc rsi
    dec rdi
    loop .reverse

    lea r12,[buf]           ; текущая позиция в буфере
    mov rbx,1               ; сколько символов в текущей строке
    mov r13,s_len           ; сколько символов осталось

.triangle:
    mov r14,rbx             ; r14 = сколько выводим сейчас
    cmp r14,r13
    jbe .print
    mov r14,r13             ; если осталось меньше, чем нужно - выводим остаток

.print:
    mov eax,1               ; write(1, r12, r14)
    mov edi,1
    mov rsi,r12
    mov rdx,r14
    syscall

    mov eax,1               ; write(1, nl, 1)
    mov edi,1
    lea rsi,[nl]
    mov edx,1
    syscall

    add r12,r14             ; сдвигаем позицию вперед
    sub r13,r14             ; уменьшаем остаток
    inc rbx                 ; следующая строка на 1 символ длиннее
    test r13,r13
    jnz .triangle           ; пока остались символы

    mov eax,60
    xor edi,edi
    syscall
