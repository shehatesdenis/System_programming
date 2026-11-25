format ELF64
public _start

section '.bss' writable
    input_byte rb 1
    output_byte rb 1

section '.text' executable
_start:
    cmp qword [rsp], 4
    jne .failure

    mov rsi, [rsp + 32]
    call parse_nonnegative
    test rax, rax
    jle .failure
    mov r14, rax                ; k

    mov eax, 2                  ; open(input, O_RDONLY)
    mov rdi, [rsp + 16]
    xor esi, esi
    syscall
    test rax, rax
    js .failure
    mov r12, rax

    mov eax, 2                  ; open(output, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov rdi, [rsp + 24]
    mov esi, 577
    mov edx, 420
    syscall
    test rax, rax
    js .close_input_failure
    mov r13, rax

    xor ebx, ebx                ; position since last selected character

.read_loop:
    xor eax, eax                ; read(input, &input_byte, 1)
    mov rdi, r12
    lea rsi, [input_byte]
    mov edx, 1
    syscall
    test rax, rax
    js .close_both_failure
    jz .success

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
    cmp rax, 1
    jne .close_both_failure
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

; Convert the decimal string at RSI to an integer. Returns -1 if invalid.
parse_nonnegative:
    xor eax, eax
    cmp byte [rsi], 0
    je .invalid

.digits:
    movzx edx, byte [rsi]
    sub edx, '0'
    cmp edx, 9
    ja .invalid
    imul rax, 10
    jo .invalid
    add rax, rdx
    jo .invalid
    inc rsi
    cmp byte [rsi], 0
    jne .digits
    ret

.invalid:
    mov rax, -1
    ret
