format ELF64

public _start

number dq 3363522457

buffer rb 32

_start:
    mov rax,[number]
    xor r8d,r8d
    mov ebx,10

.sum_loop:
    xor edx,edx
    div rbx
    add r8,rdx
    test rax,rax
    jnz .sum_loop

    mov rax,r8
    lea rdi,[buffer+31]
    mov byte [rdi],10
    dec rdi

.to_ascii:
    xor edx,edx
    div rbx
    add dl,'0'
    mov [rdi],dl
    dec rdi
    test rax,rax
    jnz .to_ascii

    inc rdi
    lea rsi,[rdi]
    lea rdx,[buffer+32]
    sub rdx,rsi

    mov eax,1
    mov edi,1
    syscall

    mov eax,60
    xor edi,edi
    syscall
