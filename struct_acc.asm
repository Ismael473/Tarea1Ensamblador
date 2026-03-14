.model small
.stack 100h


.data

;; Fixed-point arithmetic
;new_score_digits   dd 7 dup(00000000h)      ; 7 doublewords for score digits
;scores_sum         dd 00000000h             ; accumulator for all scores
;scores_average     dd 00000000h             ; result of average


; Program globals
current_menu              db 00h            ; 1 byte for menu state
next_menu                 db 00h            ; This is a byte that depends on the user's input.
; next_menu is 0 most of the time which means the current menu shouldn't change.



; --------------------------------------- Gillermo
;.DATA
    ; Definiciones simbolicas para la estructura de datos
    ; Indican el tamano en bytes de cada dato (para navegar la estructura)
    ; ACC_NUM 2 bytes
    ; ACC_HOLDER 20 bytes
    ; ACC_BAL 4 bytes
    ; ACC_STATE 1 byte
    MAX_ACC     equ 10
    ACC_SIZE    equ 28
    
    ACC_NUM     equ 0
    ACC_HOLDER  equ 2
    ACC_BAL     equ 23
    ACC_STATE   equ 27
    
    ; Variables para el manejo de cuentas
    ACCOUNTS    db ACC_SIZE * MAX_ACC dup(?) ; Define el espacio de memoria para diez cuentas.
    ACC_COUNT   db 0 ; Contador de cuentas 
                   
    CURRENT_ACC dw ? ; Cuenta seleccionada
    
    HOLDER_INPUT        db 21, ?, 21 dup(?)
    ACC_NUM_INPUT       db 6, ?, 6 dup('0')
    NUMBER32_INPUT      db 11, ?, 11 dup(?)
; --------------------------------------- Gillermo



FindAccountByAccountNumberError db 0    ; 1 = Error. Error flag for the FindAccountByAccountNumber procedure.

; Menu names (jumps)
; 1 CreateAccountMenu
; 2 DepositMenu
; 3 WithdrawMenu
; 4 CheckBalanceMenu
; 5 ShowReportMenu
; 6 DeactivateAccountMenu
; 7 Exit
create_account_menu_opening_message db "A continuacion, ingrese los datos de la nueva cuenta.", 0Dh,0Ah, "$"
deposit_menu_opening_message db "Ingrese el numero de cuenta destino.", 0Dh,0Ah, "$"
withdraw_menu_opening_message db "Ingrese el numero de cuenta de origen.", 0Dh,0Ah, "$"
check_balance_menu_opening_message db "Ingrese el numero de cuenta por solicitar.", 0Dh,0Ah, "$"
show_report_menu_opening_message db "Reporte general:", 0Dh,0Ah, "$"
deactivate_account_menu_opening_message db "Ingrese el numero de cuenta por desactivar.", 0Dh,0Ah, "$"
exit_opening_message db "Saliendo...", 0Dh,0Ah, "$"



current_max_balance                dw 0000h, 0000h      ; Used by FindMaxBalanceAccount
current_min_balance                dw 0000h, 0000h      ; Used by FindMinBalanceAccount



print_newline db 0Dh,0Ah, "$"

; Menu prints
welcome_print db "Bienvenido a BankTec.$"
; the sequence '0Dh, 0Ah' works as a newline. 
; Use backslash to continue in a new line.
main_menu_message_part_0 db "Digite un numero:", 0Dh,0Ah, "$"
main_menu_message_part_1 db "1.   Crear cuenta", 0Dh,0Ah, "$"
main_menu_message_part_2 db "2.   Depositar dinero", 0Dh,0Ah, "$"
main_menu_message_part_3 db "3.   Retirar dinero", 0Dh,0Ah, "$"
main_menu_message_part_4 db "4.   Consultar saldo", 0Dh,0Ah, "$"
main_menu_message_part_5 db "5.   Mostrar reporte general", 0Dh,0Ah, "$"
main_menu_message_part_6 db "6.   Desactivar una cuenta", 0Dh,0Ah, "$"
main_menu_message_part_7 db "7.   Salir", 0Dh,0Ah, "$"

; Crear cuenta prints.
create_account_menu_enter_holder db         "Digite el nombre del propietario:", 0Dh,0Ah, "$"
create_account_menu_enter_account_number db "Digite el numero de cuenta:", 0Dh,0Ah, "$"
create_account_menu_enter_balance db        "Digite el saldo:", 0Dh,0Ah, "$"

; FindAccountByAccountNumber error print
find_account_by_account_number_error_message db "No se encontro una cuenta con ese numero de cuenta.", 0Dh,0Ah, "$"

; deposit_to_an_account prints
deposit_to_an_account_indicate_amount db "Indique el monto por depositar.", 0Dh,0Ah, "$"
; withdraw_from_an_account prints
withdraw_from_an_account_indicate_amount db "Indique el monto por retirar.", 0Dh,0Ah, "$"
; check_balance_of_an_account prints
check_balance_of_an_account_show_amount db "El saldo de la cuenta es: $"

; deactivate_an_account prints
deactivate_an_account_success_message db "Cuenta desactivada.", 0Dh,0Ah, "$"





; Reporte Prints.   Add a newline and tab to each message?
total_de_cuentas_activas_print db "Cuentas activas:", 0Dh,0Ah, "$"
total_de_cuentas_inactivas_print db "Cuentas inactivas:", 0Dh,0Ah, "$"
saldo_total_del_banco_print db "Saldo total del banco:", 0Dh,0Ah, "$"
cuenta_con_mayor_saldo_print db "Cuenta con mayor saldo:", 0Dh,0Ah, "$"
cuenta_con_menor_saldo_print db "Cuenta con menor saldo:", 0Dh,0Ah, "$"



; Decimal Number Print
decimal_to_print db "000000.0000$"



; Debugging prints
debug_0 db "CHECKPOINT 0", 0Dh,0Ah, "$"
debug_1 db "CHECKPOINT 1", 0Dh,0Ah, "$"
debug_2 db "CHECKPOINT 2", 0Dh,0Ah, "$"
debug_5 db "CHECKPOINT 3", 0Dh,0Ah, "$"
debug_small db ".-", "$"




; --------------------------------------- Ismael
;.DATA
;    ; Definiciones simbolicas para la estructura de datos
;    ; Indican el tamano en bytes de cada dato (para navegar la estructura)
;    ; ACC_NUM 2 bytes
;    ; ACC_HOLDER 20 bytes
;    ; ACC_BAL 4 bytes
;    ; ACC_STATE 1 byte
;    
;    ;---Opciones del menu ---
;    
;<<<<<<< Updated upstream
;<<<<<<< Updated upstream
;    op_Crear db "1. Crear cuenta"
;    op_Depos db "2. Depositar Dinero"
;    op_Retir db "3. Retirar Dinero"
;    op_Consul db "4. Consultar Saldo"
;    op_MostRepo db "5. Mostrar Reporte General"
;    op_Desac db "6. Desactivar cuenta"
;    op_Salir db "7. Salir"
;=======
;=======
;>>>>>>> Stashed changes
;    op_Crear db "1. Crear cuenta\n$"
;    op_Depos db "2. Depositar Dinero\n$"
;    op_Retir db "3. Retirar Dinero\n$"
;    op_Consul db "4. Consultar Saldo\n$"
;    op_MostRepo db "5. Mostrar Reporte General\n$"
;    op_Desac db "6. Desactivar cuenta\n$"
;    op_Salir db "7. Salir\n$"
;<<<<<<< Updated upstream
;>>>>>>> Stashed changes
;=======
;>>>>>>> Stashed changes
;                             
;    ;------------------------                             
;    
;    
;    MAX_ACC     equ 10
;    ACC_SIZE    equ 27
;    
;    ACC_NUM     equ 0
;    ACC_HOLDER  equ 2
;    ACC_BAL     equ 22
;    ACC_STATE   equ 26
;    
;    ; Variables para el manejo de cuentas
;    ACCOUNTS    db ACC_SIZE * MAX_ACC dup(?) ; Define el espacio de memoria para diez cuentas.
;    ACC_COUNT   db 0 ; Contador de cuentas
;    
;    HOLDER_TEST_INPUT  db 21, ?, 21 dup(?)
;    ACC_NUM_TEST_INPUT db 6, ?, 6 dup(?)
;    
;





.code
main proc
; It's necessary to move @data to ds for 'offset' to work. Don't touch DS.
    mov ax, @data     ; Load data segment address
    mov ds, ax        ; into DS register


PUSH_REGISTERS MACRO
    push ax
    push bx
    push cx
    push dx
ENDM

POP_REGISTERS MACRO
    pop dx
    pop cx
    pop bx
    pop ax
ENDM


; --------------------------------------- Esteban
MainMenu:
    ; Print welcome and possible actions message between newlines.
    call PrintNewline

    mov ah, 09h
    mov dx, offset main_menu_message_part_0
    int 21h
    mov dx, offset main_menu_message_part_1
    int 21h
    mov dx, offset main_menu_message_part_2
    int 21h
    mov dx, offset main_menu_message_part_3
    int 21h
    mov dx, offset main_menu_message_part_4
    int 21h
    mov dx, offset main_menu_message_part_5
    int 21h
    mov dx, offset main_menu_message_part_6
    int 21h
    mov dx, offset main_menu_message_part_7
    int 21h
    
    mov dx, offset print_newline
    int 21h    

    
    ; Use 'ah, 01h' to freeze the program until the user writes a single character (doesn't need to press enter).
    mov ah, 01h            ; wait for keypress ah code
    int 21h
    sub al, '0'            ; substracting the value of char '0' gets the value of that number char as the actual number.
    mov [current_menu], al ; changes current_menu in .data. This is used to act based on new menu (jump to the corresponding menu's code). 

    ; Print a newline after receiving the input.
    call PrintNewline

    ; Act based on new menu.
    ; jumps if al is equal to the corresponding value of the menu. 

    ; Menu names (jumps)
    ; 1 CreateAccountMenu
    ; 2 DepositMenu
    ; 3 WithdrawMenu
    ; 4 CheckBalanceMenu
    ; 5 ShowReportMenu
    ; 6 DeactivateAccountMenu
    ; 7 Exit

    cmp al, 1
    jne CreateAccountMenuSkipJump
    jmp CreateAccountMenu
    CreateAccountMenuSkipJump:


    cmp al, 2
    jne DepositMenuSkipJump
    jmp DepositMenu
    DepositMenuSkipJump:

    cmp al, 3
    jne WithdrawMenuSkipJump
    jmp WithdrawMenu
    WithdrawMenuSkipJump:

    cmp al, 4
    jne CheckBalanceMenuSkipJump
    jmp CheckBalanceMenu
    CheckBalanceMenuSkipJump:

    cmp al, 5
    jne ShowReportMenuSkipJump
    jmp ShowReportMenu
    ShowReportMenuSkipJump:

    cmp al, 6
    jne DeactivateAccountMenuSkipJump
    jmp DeactivateAccountMenu
    DeactivateAccountMenuSkipJump:

    cmp al, 7
    jne ExitSkipJump
    jmp Exit
    ExitSkipJump:
    
    jmp MainMenu          ; invalid input, repeat

; Define behaviour of each 'menu'

; al == 1
CreateAccountMenu: ;------------------------------------------------------------------------------------
    ; print "A continuacion, ingrese los datos de la nueva cuenta."
    mov ah, 09h
    mov dx, offset create_account_menu_opening_message
    int 21h

    ; Code for adding a new account.
    call create_account

    jmp MainMenu


; al == 2
DepositMenu:
    ; Code for depositing to an account.
    call deposit_to_an_account

    jmp MainMenu

; al == 3
WithdrawMenu:
    ; Code for withdrawing from an account.
    call withdraw_from_an_account
    
    jmp MainMenu

; al == 4
CheckBalanceMenu:
    ; Code for checking the balance of an account.
    call check_balance_of_an_account
    
    jmp MainMenu

; al == 5
ShowReportMenu:
    ; mov ah, 09h
    ; mov dx, offset show_report_menu_opening_message
    ; int 21h
    jmp MainMenu
    
; al == 6
DeactivateAccountMenu:
    ; Code for deactivating an account.
    call deactivate_an_account

    jmp MainMenu
    
; al == 7
Exit:
    mov ah, 09h
    mov dx, offset exit_opening_message
    int 21h
    jmp ExitProgram


ExitProgram:
    mov ah, 4Ch
    int 21h

main endp


; This function needs a double word in dx:ax and cl to hold a shift amount -> [0,31]
; returns 1 if the bit at cl's position is 1; 0, if 0
; returns in ch
; push and pops bx (bx unaltered)
; does not modify dx:ax, cl, nor bx. Modifies ch
GetBitFrom32 proc

    ret
GetBitFrom32 endp
;-------------------------------------
Divide32By16 proc
    
    ret
Divide32By16 endp

PrintDecimalFrom32BitFixedPoint proc    ; This name may be so long is truncated by assembler

    ret
PrintDecimalFrom32BitFixedPoint endp

; Test function
; Prints Hex of dx:ax
PrintHexFrom32Bit proc

    ret
PrintHexFrom32Bit endp






























; --------------------------------------- Gillermo
    
; En number32_input debe de estar el numero
; Recibe AX, BX, CX y DX en 0   alta:baja 
; Devuelve en AX, DX un numero    dx:ax
; de 32 bits.                     bx:cx

convert_32 PROC
    mov ax, 0 ; Limpiar cuatro registros para convertir un numero de 32 bits
    mov bx, 0 
    mov cx, 0
    mov dx, 0
    
    xor di, di
    mov dl, [NUMBER32_INPUT+1]
    mov di, dx
    xor dx, dx
    lea si, NUMBER32_INPUT+2

convert_loop:
    cmp di, 0
    je ExitConvertLoop
                    
    mov bl, [si]
    sub bl, '0'
    
    push bx
    
    shl ax, 1   
    rcl dx, 1
    
    mov bx, ax
    mov cx, dx
    
    shl ax, 1
    rcl dx, 1
    
    shl ax, 1
    rcl dx, 1
    
    add ax, bx
    adc dx, cx
    
    pop bx
    
    xor bh, bh
    add ax, bx
    adc dx, 0
    
    dec di
    inc si
    jmp convert_loop  
    
ExitConvertLoop:
    ret
    
convert_32 ENDP

create_account PROC
    mov al, MAX_ACC
    cmp ACC_COUNT, al    
    jl acc_limitSkipJump
    jmp acc_limit
    acc_limitSkipJump:
    ;jae acc_limit ; Se fija si hay espacio para una nueva cuenta
    
    ; Get account holder.
    mov ah, 09h
    mov dx, offset create_account_menu_enter_holder
    int 21h    
    mov ah, 0Ah
    lea dx, HOLDER_INPUT ; Account holder Buffer.
    int 21h
    call PrintNewline
    
    ; Get account number.
    mov ah, 09h
    mov dx, offset create_account_menu_enter_account_number
    int 21h    
    mov ah, 0Ah
    lea dx, ACC_NUM_INPUT ; Account number Buffer.
    int 21h    
    call PrintNewline

    ; Get account balance.
    mov ah, 09h
    mov dx, offset create_account_menu_enter_balance
    int 21h 
    mov ah, 0Ah
    lea dx, NUMBER32_INPUT
    int 21h 
    call PrintNewline

    xor ax, ax ; Limpiar registros
    xor cx, cx
    xor dx, dx
    xor bh, bh
    mov cl, [ACC_NUM_INPUT+1] ; Numero de caracteres que el usuario ingreso
    lea si, ACC_NUM_INPUT+2   ; La direccion de memoria donde empieza el string

;convert_acc_number:
;    mov bl, [si]  ; Asignamos el caracter
;    sub bl, '0'   ; Conversion a entero
;    mov dx, 10    ; Asignar diez para multiplicar el numero anterior ax * 10 + bl
;    mul dx
;    add ax, bx 
;   
;    inc si        ; Pasar al siguiente caracter
;
;    loop convert_acc_number
    call ConvertAccountNumberTo16
    
    mov cl, ACC_COUNT
    lea si, ACCOUNTS  ; Inicio del bloque de memoria de las cuentas
    xor bx, bx   
    
check_existance:
    cmp cl, 0
    je create_new_acc    ; Ninguna cuenta tiene el mismo numero, creamos una nueva
    
    mov bx, [si]
    cmp ax, bx           ; El numero ingresado tiene es el mismo para otra cuenta, evitamos crear otra.
    je duplicated_acc
    
    dec cl
    add si, ACC_SIZE     ; Saltamos a la siguiente cuenta
    jmp check_existance    

create_new_acc:
    mov dx, ax
    xor ax, ax               ; Estas lineas se utilizan para calcular
    mov al, ACC_COUNT        ; la direccion de memoria de la cuenta que vamos a crear
    mov bl, ACC_SIZE         ; de la siguiente forma: ACCOUNTS + ACC_SIZE * ACC_COUNT
    mul bl
    lea si, ACCOUNTS
    add si, ax
    mov CURRENT_ACC, si
    
    mov [si+ACC_NUM], dx     ; Guarda el numero de cuenta
    mov [si+ACC_STATE], 1    ; Colocamos el estado de la cuenta en activa (0 = inactiva, 1 = activa)
    lea di, HOLDER_INPUT     ; Primer byte del de input
    mov cl, [di+1]           ; Contador de caracteres, para un el loop de copy_acc_holder
    lea di, HOLDER_INPUT+2   ; Primer caracter del input
    lea si, si+ACC_HOLDER    ; Primer caracter del arreglo de la cuenta
    mov bx, ax
    
copy_acc_holder:
    mov dx, 0   
    
    mov al, [di]          ; Copiar del input a la cuenta que estamos creando
    mov [si], al
    
    inc di                ; Cambiamos de byte (caracter) para el input y el arreglo de la cuenta      
    inc si                       
    
    loop copy_acc_holder         
    
    mov al, '$'                  ; Al final de la cadena del nombre se le coloca $ para poder imprimir
    mov [si], al                 ; sin usar un loop

    call convert_32              ; Converts the current received balance from a string to a 32 bit number saved into dx:ax
    
    mov si, CURRENT_ACC
    
    mov [si+ACC_BAL], ax
    mov [si+ACC_BAL+2], dx
    
    inc ACC_COUNT
    ret    
     
acc_limit:
    ret
    
duplicated_acc:
    ret
        
create_account ENDP

end_program PROC
    mov ax, 4C00h
    int 21h
end_program ENDP

PrintNewline proc
    push ax
    push dx
    mov ah, 09h
    mov dx, offset print_newline
    int 21h
    pop dx
    pop ax
    ret
PrintNewline endp

; Requires ACC_NUM_INPUT+2 to have the account number string.
; returns the offset of the matching Account offset in si
FindAccountByAccountNumber proc
    push cx
    push bx
    push ax

    lea si, ACCOUNTS                ; get the position of the first account into si.
                                    ; The first value in an account is the account number,
                                    ; so the bare offset of an account is the offset of its account number.
    call ConvertAccountNumberTo16   ; Gets the numeric value of ACC_NUM_INPUT+2 into ax.
    
    mov cx, MAX_ACC                 ; cx = 10 to iterate 10 times.
    FindAccountLoop:
        mov bx, [si]                ; [si] is the account number of the current account.
        cmp bx, ax                  ; ax has the account number to compare.
        je FoundAccount             ; equal numbers mean a matching account was found.
        add si, ACC_SIZE            ; ACC_SIZE    equ 28. Jumps to the next account to compare.
        loop FindAccountLoop
    
    mov [FindAccountByAccountNumberError], 1;   This code is reached if no accounts matched the given account number.
    
    FoundAccount:
    pop ax
    pop bx
    pop cx
    ret
FindAccountByAccountNumber endp


; Calculates a 16 bit number from a 6 byte numeric string stored at ACC_NUM_INPUT+2.
; Returns to ax.
ConvertAccountNumberTo16 proc
    push si
    push bx
    push dx
    push cx

    mov ax, 0
    lea si, ACC_NUM_INPUT+2     ; La direccion de memoria donde empieza el string
    mov ch, 0
    mov cl, byte ptr [ACC_NUM_INPUT+1]   ; Tamano del string.

    convert_acc_number:
    mov bl, [si]  ; Asignamos el caracter
    sub bl, '0'   ; Conversion a entero
    mov dx, 10    ; Asignar diez para multiplicar el numero anterior ax * 10 + bl
    mul dx        ; dx:ax = ax * dx
    add ax, bx
   
    inc si        ; Pasar al siguiente caracter

    loop convert_acc_number

    pop cx
    pop dx
    pop bx
    pop si
    ret
ConvertAccountNumberTo16 endp


; PSEUDO
;    deposit_to_an_account
;        print("Ingrese el numero de cuenta destino.")
;        data.account_number = int21()
;        target_account_address = FindAccountByAccountNumber()
;        if (data.FindAccountByAccountNumberError)
;            print("No se encontro una cuenta con ese numero de cuenta.")
;            jump menu
;            data.FindAccountByAccountNumberError = 0
;
;        data.balance = Convert32(int21())
;
;        account[target_account_address].balance += data.balance
;        return
deposit_to_an_account proc
    PUSH_REGISTERS
    ; print("Ingrese el numero de la cuenta destino.")
    mov ah, 09h
    mov dx, offset deposit_menu_opening_message
    int 21h

    ; get the account number into the account_number buffer as a string.
    mov ah, 0Ah
    lea dx, ACC_NUM_INPUT ; Account number Buffer.
    int 21h
    call PrintNewline

    ; get the offset of the account with the given account number
    call FindAccountByAccountNumber ; returns the offset of the matching Account offset in si
    ; continue if FindAccountByAccountNumber didn't run into an error.
    cmp byte ptr [FINDACCOUNTBYACCOUNTNUMBERERROR], 0    ; 0 = no error ; byte ptr/word ptr is necessary for data in memory.
        je successfully_found_account1
        ; If it ran into an error:
        ; print("No se encontro una cuenta con ese numero de cuenta.")
        mov ah, 09h
        mov dx, offset find_account_by_account_number_error_message
        int 21h
        mov FINDACCOUNTBYACCOUNTNUMBERERROR, 0
        POP_REGISTERS
        ret ; generally jumps to MainMenu (using ret mantains the stack valid)
        successfully_found_account1:
    push si ; save si for later.

    ; get the sum to deposit as a string from the user. 
    mov ah, 09h
    mov dx, offset deposit_to_an_account_indicate_amount
    int 21h 
    mov ah, 0Ah
    lea dx, NUMBER32_INPUT
    int 21h 
    call PrintNewline

    call convert_32 ; get the 32 bit balance to add into dx:ax
    pop si
    add si, ACC_BAL ; add the offset of the balance within an account.
    ; add to the balance at si.
    add word ptr [si], ax ; si now holds the address of the balance to add to
    adc word ptr [si+2], dx
    POP_REGISTERS
    ret
deposit_to_an_account endp

; Same code as deposit_to_an_account but substracts instead and TODO: VALIDATE THAT THERE IS ENOUGH MONEY TO WITHDRAW.
withdraw_from_an_account proc
    PUSH_REGISTERS
    ; print("Ingrese el numero de la cuenta de origen.")
    mov ah, 09h
    mov dx, offset withdraw_menu_opening_message
    int 21h

    ; get the account number into the account_number buffer as a string.
    mov ah, 0Ah
    lea dx, ACC_NUM_INPUT ; Account number Buffer.
    int 21h
    call PrintNewline

    ; get the offset of the account with the given account number
    call FindAccountByAccountNumber ; returns the offset of the matching Account offset in si
    ; continue if FindAccountByAccountNumber didn't run into an error.
    cmp byte ptr [FINDACCOUNTBYACCOUNTNUMBERERROR], 0    ; 0 = no error ; byte ptr/word ptr is necessary for data in memory.
        je successfully_found_account2
        ; If it ran into an error:
        ; print("No se encontro una cuenta con ese numero de cuenta.")
        mov ah, 09h
        mov dx, offset find_account_by_account_number_error_message
        int 21h
        mov FINDACCOUNTBYACCOUNTNUMBERERROR, 0
        POP_REGISTERS
        ret ; generally jumps to MainMenu (using ret mantains the stack valid)
        successfully_found_account2:
    push si ; save si for later.

    ; get the sum to withdraw as a string from the user. 
    mov ah, 09h
    mov dx, offset withdraw_from_an_account_indicate_amount
    int 21h 
    mov ah, 0Ah
    lea dx, NUMBER32_INPUT
    int 21h 
    call PrintNewline

    call convert_32 ; get the 32 bit balance to add into dx:ax
    pop si
    add si, ACC_BAL ; add the offset of the balance within an account.
    ; add to the balance at si.
    sub word ptr [si], ax ; si now holds the address of the balance to subtract from.
    sbb word ptr [si+2], dx
    POP_REGISTERS
    ret
withdraw_from_an_account endp


; Check balance
; similarly to deposit and withdraw, this procedure finds the account by account number and performs an action.
check_balance_of_an_account proc
    PUSH_REGISTERS
    ; print("Ingrese el numero de la cuenta por solicitar.")
    mov ah, 09h
    mov dx, offset check_balance_menu_opening_message
    int 21h

    ; get the account number into the account_number buffer as a string.
    mov ah, 0Ah
    lea dx, ACC_NUM_INPUT ; Account number Buffer.
    int 21h
    call PrintNewline

    ; get the offset of the account with the given account number
    call FindAccountByAccountNumber ; returns the offset of the matching Account offset in si
    ; continue if FindAccountByAccountNumber didn't run into an error.
    cmp byte ptr [FINDACCOUNTBYACCOUNTNUMBERERROR], 0    ; 0 = no error ; byte ptr/word ptr is necessary for data in memory.
        je successfully_found_account3
        ; If it ran into an error:
        ; print("No se encontro una cuenta con ese numero de cuenta.")
        mov ah, 09h
        mov dx, offset find_account_by_account_number_error_message
        int 21h
        mov FINDACCOUNTBYACCOUNTNUMBERERROR, 0
        POP_REGISTERS
        ret ; generally jumps to MainMenu (using ret mantains the stack valid)
        successfully_found_account3:
    
    ; print "El saldo de la cuenta es: $"
    mov ah, 09h
    mov dx, offset check_balance_of_an_account_show_amount
    int 21h 
    
    add si, ACC_BAL ; add the offset of the balance within an account.
    ; si now holds the address of the balance to print.
    ; PLACEHOLDER BEHAVIOR OF PRINTING debug_0!!! TODO: PRINT THE 32 bit BALANCE AS A DECIMAL NUMBER. -------
    mov ah, 09h
    mov dx, offset debug_0
    int 21h 
    
    

    ; TODO: Insert code to print the 32 bit number at si here



    POP_REGISTERS
    ret
check_balance_of_an_account endp






; Similar code to deposit_to_an_account but overwrites the account's state instead of the balance.
deactivate_an_account proc
    PUSH_REGISTERS
    ; print("Ingrese el numero de cuenta a desactivar.")
    mov ah, 09h
    mov dx, offset deactivate_account_menu_opening_message
    int 21h

    ; get the account number into the account_number buffer as a string.
    mov ah, 0Ah
    lea dx, ACC_NUM_INPUT ; Account number Buffer.
    int 21h
    call PrintNewline

    ; get the offset of the account with the given account number
    call FindAccountByAccountNumber ; returns the offset of the matching Account offset in si
    ; continue if FindAccountByAccountNumber didn't run into an error.
    cmp byte ptr [FINDACCOUNTBYACCOUNTNUMBERERROR], 0    ; 0 = no error ; byte ptr/word ptr is necessary for data in memory.
        je successfully_found_account4
        ; If it ran into an error:
        ; print("No se encontro una cuenta con ese numero de cuenta.")
        mov ah, 09h
        mov dx, offset find_account_by_account_number_error_message
        int 21h
        mov FINDACCOUNTBYACCOUNTNUMBERERROR, 0
        POP_REGISTERS
        ret ; generally jumps to MainMenu (using ret mantains the stack valid)
        successfully_found_account4:

    ; print "Cuenta desactivada."
    mov ah, 09h
    mov dx, offset deactivate_an_account_success_message
    int 21h 

    add si, ACC_STATE ; add the offset of the state within an account.
    ; Sobresecribir el estado de la cuenta en la direccion dada por si con inactiva (0 = inactiva, 1 = activa)
    mov byte ptr [si], 0 ; si now holds the address of the balance to subtract from.
    POP_REGISTERS
    ret
deactivate_an_account endp





;push_registers proc    ; This code interferes with the logic of return because values are added to the stack.
;    push 
;    push ax
;    push bx
;    push cx
;    push dx
;    ret
;push_registers endp
;
;pop_registers proc
;    push dx
;    push cx
;    push bx
;    push ax
;    ret
;pop_registers endp






;main:
;    mov ax, @data
;    mov ds, ax
;    
;    call create_account
;    call create_account 
;    
;    call end_program
;END main








