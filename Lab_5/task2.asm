format ELF64 executable 3
entry _start

segment readable writeable
input_byte rb 1
output_byte rb 1

segment readable executable
_start:
    cmp qword [rsp], 4
    jne .failure

    mov eax, 2                  ; open(input, O_RDONLY)
    mov rdi, [rsp+16]
    xor esi, esi
    syscall
    test rax, rax
    js .failure
    mov r12, rax

    mov eax, 2                  ; open(output, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov rdi, [rsp+24]
    mov esi, 577
    mov edx, 420
    syscall
    test rax, rax
    js .close_input_failure
    mov r13, rax

    mov rsi, [rsp+32]
    call parse_positive
    test rax, rax
    jle .close_both_failure
    mov r14, rax                ; k
    xor ebx, ebx                ; position since last selected character

.read_loop:
    xor eax, eax                ; read(input, &input_byte, 1)
    mov rdi, r12
    lea rsi, [input_byte]
    mov edx, 1
    syscall
    test rax, rax
    jle .success

    inc rbx
    cmp rbx, r14
    jne .read_loop

    mov al, [input_byte]
    mov [output_byte], al
    mov eax, 1                  ; write(output, &output_byte, 1)
    mov rdi, r13
    lea rsi, [output_byte]
    mov edx, 1
    syscall
    test rax, rax
    js .close_both_failure
    xor ebx, ebx
    jmp .read_loop

.success:
    mov eax, 3
    mov rdi, r12
    syscall
    mov eax, 3
    mov rdi, r13
    syscall
    xor edi, edi
    jmp .exit

.close_both_failure:
    mov eax, 3
    mov rdi, r13
    syscall
.close_input_failure:
    mov eax, 3
    mov rdi, r12
    syscall
.failure:
    mov edi, 1
.exit:
    mov eax, 60
    syscall

; Parse a positive decimal integer at RSI. Returns it in RAX, or 0 if invalid.
parse_positive:
    xor eax, eax
    xor r8d, r8d
.parse_loop:
    movzx ecx, byte [rsi]
    test ecx, ecx
    jz .parse_done
    cmp ecx, '0'
    jb .invalid
    cmp ecx, '9'
    ja .invalid
    imul rax, 10
    sub ecx, '0'
    add rax, rcx
    inc r8
    inc rsi
    jmp .parse_loop
.parse_done:
    test r8, r8
    jz .invalid
    ret
.invalid:
    xor eax, eax
    ret
