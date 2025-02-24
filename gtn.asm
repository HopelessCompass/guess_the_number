section .data
    message db "Enter your number 1-10: ", 0
    msg_len equ $ - message

    random_number dq 0
    user_number dq 0

    bytes_written dq 0

    msg_yes db "You're a lucky guy!", 0
    msg_no db "Unlucky, try again!", 0

    hConsole dq 0

section .bss
    bytes_read resq 1
    user_input resb 128

section .text
    extern GetStdHandle, WriteConsoleA, ReadConsoleA, ExitProcess, GetTickCount
    global main

main:
    ; Получаем дескриптор стандартного вывода (консоль)
    sub rsp, 32
    mov ecx, -11
    call GetStdHandle
    mov [hConsole], rax

    ; Выводим сообщение
    mov rcx, [hConsole]
    lea rdx, [message]
    mov r8, msg_len
    lea r9, [bytes_written]
    mov qword [rsp + 32], 0
    call WriteConsoleA

    ; Получаем дескриптор стандартного ввода (консоль)
    mov ecx, -10
    call GetStdHandle
    mov [hConsole], rax

    ; Читаем ввод
    mov rcx, [hConsole]
    lea rdx, [user_input]
    mov r8, 128
    lea r9, [bytes_read]
    mov qword [rsp + 32], 0
    call ReadConsoleA

    ; Преобразуем строку в число
    lea rcx, [user_input]
    call string_to_int
    mov [user_number], rax

    ; Генерация случайного числа
    call GetTickCount
    mov ecx, 10
    xor rdx, rdx
    div rcx
    inc rdx
    mov [random_number], rdx

    ; Сравниваем числа
    mov rax, [user_number]
    cmp rax, [random_number]
    je print_yes
    jmp print_no

    ; Вывод если не угадали
    print_no:
        lea rcx, [msg_no]
        call print_message
        jmp exit

    ; Вывод если угадали
    print_yes:
        lea rcx, [msg_yes]
        call print_message
        jmp exit

    ; Условный вывод сообщений
    print_message:
        mov rcx, [hConsole]
        mov rdx, rcx
        mov r8, msg_len
        lea r9, [bytes_written]
        mov qword [rsp + 32], 0
        call WriteConsoleA
        ret

    ; Чистка регистра и вызов функции по конвертации строки в число
    string_to_int:
        xor rax, rax
        call convert_loop

    ; Строка в число
    convert_loop:
        movzx rdx, byte [rcx]
        test rdx, rdx
        jz done
        sub rdx, '0'
        imul rax, rax, 10
        add rax, rdx
        inc rcx
        jmp convert_loop

    ; Выход из цикла строки в число
    done:
        ret

    ; Завершение программы
    exit:
        xor ecx, ecx
        call ExitProcess
