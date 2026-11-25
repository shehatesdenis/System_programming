format ELF64
public _start

COUNT = 669
ARRAY_SIZE = COUNT * 4
THREADS = 4
STACK_SIZE = 8192
CLONE_FLAGS = 0x310900          ; VM | SIGHAND | THREAD | PARENT_SETTID | CHILD_CLEARTID

section '.data' writable
    workers dq most_common_digit, fifth_after_min, third_quartile, count_primes
    digit_msg db 'Most common digit: ', 0
    fifth_msg db 'Fifth after minimum: ', 0
    quartile_msg db '0.75 quantile: ', 0
    primes_msg db 'Prime count: ', 0
    error_msg db 'Could not complete the computation', 10
    error_len = $ - error_msg

section '.bss' writable align 16
    numbers rq 1
    tids rd THREADS
    align 16
    stacks rb THREADS * STACK_SIZE

section '.text' executable
_start:
    mov eax, 12                 ; brk(0): current end of the heap
    xor edi, edi
    syscall
    mov [numbers], rax
    lea rdi, [rax + ARRAY_SIZE]
    mov eax, 12                 ; brk(numbers + ARRAY_SIZE)
    syscall
    cmp rax, rdi
    jne .error

    mov rsi, [numbers]
    mov edx, ARRAY_SIZE

.random:
    mov eax, 318                ; getrandom
    mov rdi, rsi
    mov esi, edx
    xor edx, edx
    syscall
    mov edx, esi
    mov rsi, rdi
    cmp rax, -4
    je .random
    test rax, rax
    jle .error
    add rsi, rax
    sub edx, eax
    jnz .random

    mov rsi, [numbers]
    mov ecx, COUNT
    mov r8d, 10000

.limit_number:
    mov eax, [rsi]
    xor edx, edx
    div r8d
    inc edx                     ; range 1..10000
    mov [rsi], edx
    add rsi, 4
    loop .limit_number

    xor ebx, ebx
    xor r14d, r14d
    mov r12, tids
    mov r13, stacks + STACK_SIZE

.create_thread:
    mov rax, [workers + rbx*8]
    mov [r13 - 8], rax
    mov eax, 56                 ; clone(flags, stack, parent_tid, child_tid, tls)
    mov edi, CLONE_FLAGS
    lea rsi, [r13 - 8]
    lea rdx, [r12 + rbx*4]
    mov r10, rdx
    xor r8d, r8d
    syscall
    test rax, rax
    jz .worker
    js .clone_error
    add r13, STACK_SIZE
    inc ebx
    cmp ebx, THREADS
    jb .create_thread
    jmp .wait_threads

.clone_error:
    mov r14d, 1

.wait_threads:
    mov rdi, r12

.next_thread:
    dec ebx
    js .finished

.wait_thread:
    mov edx, [rdi]              ; kernel clears the TID on thread exit
    test edx, edx
    jz .thread_done
    mov eax, 202                ; futex(tid, FUTEX_WAIT, expected_tid, NULL)
    xor esi, esi
    xor r10d, r10d
    syscall
    jmp .wait_thread

.thread_done:
    add rdi, 4
    jmp .next_thread

.finished:
    test r14d, r14d
    jnz .error
    xor edi, edi
    jmp exit

.worker:
    pop rax
    call rax
    xor edi, edi
    jmp exit

.error:
    mov eax, 1
    mov edi, 2
    mov rsi, error_msg
    mov edx, error_len
    syscall
    mov edi, 1

exit:
    mov eax, 60                 ; sys_exit ends just the calling thread
    syscall

most_common_digit:
    sub rsp, 40
    mov rdi, rsp
    xor eax, eax
    mov ecx, 10
    rep stosd
    mov rsi, [numbers]
    mov ecx, COUNT
    mov r8d, 10

.next_number:
    mov eax, [rsi]

.next_digit:
    xor edx, edx
    div r8d
    inc dword [rsp + rdx*4]
    test eax, eax
    jnz .next_digit
    add rsi, 4
    loop .next_number

    xor eax, eax
    mov edx, [rsp]
    mov ecx, 1

.find_maximum:
    cmp [rsp + rcx*4], edx
    jbe .next_count
    mov edx, [rsp + rcx*4]
    mov eax, ecx

.next_count:
    inc ecx
    cmp ecx, 10
    jb .find_maximum

    add rsp, 40
    mov rsi, digit_msg
    jmp print_number

fifth_after_min:
    mov edi, 5                  ; index 5 in the sorted array (0-based)
    mov rsi, fifth_msg
    jmp sorted_value

third_quartile:
    mov edi, (3 * COUNT + 3) / 4 - 1
    mov rsi, quartile_msg

; Sort a private copy on the thread's stack and print the given element.
sorted_value:
    mov r8d, edi
    mov r9, rsi
    sub rsp, ARRAY_SIZE
    mov rsi, [numbers]
    mov rdi, rsp
    mov ecx, COUNT
    rep movsd
    mov ecx, 1

.next_element:
    mov eax, [rsp + rcx*4]
    mov edx, ecx

.shift:
    test edx, edx
    jz .insert
    mov esi, [rsp + rdx*4 - 4]
    cmp esi, eax
    jbe .insert
    mov [rsp + rdx*4], esi
    dec edx
    jmp .shift

.insert:
    mov [rsp + rdx*4], eax
    inc ecx
    cmp ecx, COUNT
    jb .next_element

    mov eax, [rsp + r8*4]
    add rsp, ARRAY_SIZE
    mov rsi, r9
    jmp print_number

count_primes:
    mov rsi, [numbers]
    mov ecx, COUNT
    xor r9d, r9d

.next_number:
    mov r8d, [rsi]
    cmp r8d, 2
    jb .skip
    mov edi, 2

.try_divisor:
    mov eax, edi
    imul eax, edi
    cmp eax, r8d
    ja .prime
    mov eax, r8d
    xor edx, edx
    div edi
    test edx, edx
    jz .skip
    inc edi
    jmp .try_divisor

.prime:
    inc r9d

.skip:
    add rsi, 4
    loop .next_number
    mov eax, r9d
    mov rsi, primes_msg
    jmp print_number

; Print the label at RSI and unsigned number in EAX in a single write.
print_number:
    sub rsp, 64
    lea r8, [rsp + 64]
    dec r8
    mov byte [r8], 10
    mov ecx, 10

.convert:
    xor edx, edx
    div ecx
    dec r8
    add dl, '0'
    mov [r8], dl
    test eax, eax
    jnz .convert

    mov r9, rsi

.label_length:
    cmp byte [r9], 0
    je .copy_label
    inc r9
    jmp .label_length

.copy_label:
    dec r9
    dec r8
    mov al, [r9]
    mov [r8], al
    cmp r9, rsi
    jne .copy_label

    mov eax, 1
    mov edi, 1
    mov rsi, r8
    lea rdx, [rsp + 64]
    sub rdx, r8
    syscall
    add rsp, 64
    ret
