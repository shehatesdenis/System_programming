format ELF64
public _start

BUFFER_SIZE = 4096
MAX_ARGS = 64

section '.data' writable
    path2 db 'Lab_5/task2', 0
    path5 db 'Lab_5/task5', 0
    path6 db 'Lab_6/task', 0
    parent_path2 db '../Lab_5/task2', 0
    parent_path5 db '../Lab_5/task5', 0
    parent_path6 db '../Lab_6/task', 0

    prompt db '> '
    prompt_len = $ - prompt
    usage db 'Commands: task2 input output k | task5 input output k m | task | exit', 10
    usage_len = $ - usage
    invalid_command db 'Invalid command or arguments', 10
    invalid_len = $ - invalid_command
    process_error db 'Could not start the program', 10
    process_error_len = $ - process_error

    sigchld_action dq reap_children, 0x14000000, signal_return, 0

section '.bss' writable
    command rb BUFFER_SIZE
    arguments rq MAX_ARGS + 1
    input_byte rb 1
    foreground rb 1

section '.text' executable
_start:
    ; envp is after argv and its terminating NULL.
    mov rax, [rsp]
    lea r15, [rsp + rax*8 + 16]

    mov eax, 13                 ; rt_sigaction(SIGCHLD, &sigchld_action, NULL, 8)
    mov edi, 17
    mov rsi, sigchld_action
    xor edx, edx
    mov r10d, 8
    syscall
    test rax, rax
    js .failure

    mov edi, 1
    mov rsi, usage
    mov edx, usage_len
    call write_message

.next_command:
    mov edi, 1
    mov rsi, prompt
    mov edx, prompt_len
    call write_message
    xor ebx, ebx
    xor r14d, r14d

.read_line:
    xor eax, eax                ; read one byte, leaving later lines for Lab 6
    xor edi, edi
    mov rsi, input_byte
    mov edx, 1
    syscall
    cmp rax, -4
    je .read_line
    test rax, rax
    js .failure
    jz .end_of_input

    mov al, [input_byte]
    cmp al, 10
    je .parse
    cmp ebx, BUFFER_SIZE - 1
    jae .read_line
    mov [command + rbx], al
    inc ebx
    jmp .read_line

.end_of_input:
    mov r14d, 1
    test ebx, ebx
    jz .finish

.parse:
    cmp ebx, BUFFER_SIZE - 1
    jae .invalid
    mov byte [command + rbx], 0
    mov rsi, command
    xor ecx, ecx

.skip_spaces:
    mov al, [rsi]
    test al, al
    jz .parsed
    cmp al, ' '
    ja .argument
    inc rsi
    jmp .skip_spaces

.argument:
    cmp ecx, MAX_ARGS
    jae .invalid
    mov [arguments + rcx*8], rsi
    inc ecx

.scan_argument:
    inc rsi
    mov al, [rsi]
    test al, al
    jz .parsed
    cmp al, ' '
    ja .scan_argument
    mov byte [rsi], 0
    inc rsi
    jmp .skip_spaces

.parsed:
    mov qword [arguments + rcx*8], 0
    test ecx, ecx
    jz .continue
    mov rsi, [arguments]
    cmp dword [rsi], 'task'
    je .task
    cmp dword [rsi], 'exit'
    jne .invalid
    cmp byte [rsi + 4], 0
    jne .invalid
    cmp ecx, 1
    je .finish
    jmp .invalid

.task:
    cmp byte [rsi + 4], 0
    je .lab6
    cmp byte [rsi + 5], 0
    jne .invalid
    cmp byte [rsi + 4], '2'
    je .lab5_task2
    cmp byte [rsi + 4], '5'
    jne .invalid
    cmp ecx, 5
    jne .invalid
    mov r12, path5
    mov r13, parent_path5
    jmp .launch

.lab5_task2:
    cmp ecx, 4
    jne .invalid
    mov r12, path2
    mov r13, parent_path2
    jmp .launch

.lab6:
    cmp ecx, 1
    jne .invalid
    mov r12, path6
    mov r13, parent_path6
    mov byte [foreground], 1

.launch:
    mov eax, 57                 ; fork
    syscall
    test rax, rax
    js .launch_error
    jz .child
    cmp byte [foreground], 0
    je .continue

    ; Lab 6 uses the terminal, so wait for it before reading another command.
    mov rdi, rax
.wait_foreground:
    mov eax, 61                 ; wait4(pid, NULL, 0, NULL)
    xor esi, esi
    xor edx, edx
    xor r10d, r10d
    syscall
    cmp rax, -4
    je .wait_foreground
    mov byte [foreground], 0
    call reap_children
    jmp .continue

.child:
    mov rdi, r12
    call exec_program
    cmp rax, -2                 ; try the path relative to Lab_7 on ENOENT
    jne .child_error
    mov rdi, r13
    call exec_program
.child_error:
    mov edi, 2
    mov rsi, process_error
    mov edx, process_error_len
    call write_message
    mov edi, 127
    jmp exit

.launch_error:
    mov byte [foreground], 0
    call reap_children
    mov edi, 2
    mov rsi, process_error
    mov edx, process_error_len
    call write_message
    jmp .continue

.invalid:
    mov edi, 2
    mov rsi, invalid_command
    mov edx, invalid_len
    call write_message

.continue:
    test r14d, r14d
    jz .next_command

.finish:
    mov eax, 61                 ; wait for any remaining Lab 5 jobs
    mov rdi, -1
    xor esi, esi
    xor edx, edx
    xor r10d, r10d
    syscall
    test rax, rax
    jg .finish
    cmp rax, -4
    je .finish
    xor edi, edi
    jmp exit

.failure:
    mov edi, 1
exit:
    mov eax, 60
    syscall

exec_program:
    mov eax, 59                 ; execve(path, argv, envp)
    mov rsi, arguments
    mov rdx, r15
    syscall
    ret

write_message:
    mov eax, 1
    syscall
    ret

reap_children:
    cmp byte [foreground], 0
    jne .done
.wait:
    mov eax, 61                 ; wait4(-1, NULL, WNOHANG, NULL)
    mov rdi, -1
    xor esi, esi
    mov edx, 1
    xor r10d, r10d
    syscall
    test rax, rax
    jg .wait
.done:
    ret

signal_return:
    mov eax, 15                 ; rt_sigreturn
    syscall
