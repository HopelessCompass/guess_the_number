section .data
    message db "Enter your number 1-10: ", 0  ; Строка для вывода
    msg_len equ $ - message             ; Длина строки

    random_number dd 0              ; Переменная для случайного числа
    user_number dd 128                ; Переменная для числа от пользователя

    bytes_written dd 0              ; Переменная для записи числа записанных байтов

    msg_yes db "You're a lucky guy!", 0   ; Сообщение если угадал
    msg_no db "Unlucky, try again!", 0     ; Сообщение если не угадал

    hConsole dd 0                   ; Дескриптор консоли

section .bss
    bytes_read resd 1                ; Количество прочитанных байтов

section .text
    global _start
    extern GetStdHandle, WriteConsoleA, ReadConsoleA, ExitProcess, GetTickCount

_start:

    ;;; Вывод из консоли переменной с msg

    ; Получаем дескриптор стандартного вывода (консоль)
    push dword -11         ; STD_OUTPUT_HANDLE (-11)
    call GetStdHandle
    mov [hConsole], eax    ; Сохраняем дескриптор консоли

    ; Выводим текст в консоль
    push dword 0           ; lpReserved (NULL)
    push dword bytes_written ; Число записанных символов
    push dword msg_len     ; Длина строки
    push dword message     ; Адрес строки
    push dword [hConsole]  ; Дескриптор консоли
    call WriteConsoleA     ; Вызов API

    ;;; Ввод из консоли в random_number

    ; Получаем дескриптор стандартного ввода (консоль)
    push dword -10         ; STD_INPUT_HANDLE (-10)
    call GetStdHandle
    mov [hConsole], eax    ; Сохраняем дескриптор консоли

    ; Читаем строку из консоли и пишем в random_number
    push dword 0           ; lpReserved (NULL)
    push dword bytes_read  ; Количество прочитанных байтов
    push dword 128         ; Максимальная длина ввода
    push dword user_number      ; Буфер для ввода
    push dword [hConsole]  ; Дескриптор консоли
    call ReadConsoleA      ; Вызов API

    ;;; Генерация случайных чисел из текущего времени в милисекундах
    call GetTickCount
    mov ecx, 10            ; Делим на 10
    xor edx, edx           ; Обнуляем edx для div
    div ecx                ; EAX = EAX / 10, остаток в EDX
    inc edx                ; Делаем диапазон 1–10
    mov [random_number], edx ; Сохраняем результат

    ;;; Сравниваем число от пользователя и от раднома

    mov eax, [user_number]      ; Загружаем x в eax
    cmp eax, [random_number]      ; Сравниваем x с 5
    je print_yes    ; Если числа совпали переходим к print_yes
    jnz print_no    ; Если числа не совпал переходим к print_no

    print_no:
        push dword msg_no
        jmp exit

    print_yes:
        push dword msg_yes
        jmp exit

    ; Выход из программы
    exit:
        push dword 0
        call ExitProcess
