format ELF64
public _start

section '.data' writable
    string db 'ywSzWnIvoXjsEqgFRwuyZYQwUGXWv'
    s_len = $ - string

    buf rb s_len
    nl db 10

section '.text' executable
_start:
    mov r15,3               ; номер строки, которую переворачиваем (меняешь тут: 4, 5...)

    lea rsi,[string]
    lea rdi,[buf+s_len-1]
    mov rcx,s_len

.reverse:
    mov al,[rsi]
    mov [rdi],al
    inc rsi
    dec rdi
    loop .reverse

    lea r12,[buf]
    mov rbx,1
    mov r13,s_len

.triangle:
    mov r14,rbx
    cmp r14,r13
    jbe .check
    mov r14,r13

.check:
    cmp rbx,r15             ; сравниваем с номером из регистра
    jne .write

    mov rsi,r12
    lea rdi,[r12+r14-1]
.swap:
    cmp rsi,rdi
    jae .write
    mov al,[rsi]
    mov dl,[rdi]
    mov [rsi],dl
    mov [rdi],al
    inc rsi
    dec rdi
    jmp .swap

.write:
    mov eax,1
    mov edi,1
    mov rsi,r12
    mov rdx,r14
    syscall

    mov eax,1
    mov edi,1
    lea rsi,[nl]
    mov edx,1
    syscall

    add r12,r14
    sub r13,r14
    inc rbx
    test r13,r13
    jnz .triangle

    mov eax,60
    xor edi,edi
    syscall
