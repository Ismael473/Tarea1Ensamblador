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
    ACCOUNTS       db ACC_SIZE * MAX_ACC dup(?) ; Define el espacio de memoria para diez cuentas.
    ACC_COUNT      db 0 ; Contador de cuentas    
    ACTIVE_ACC     db 0
    INACTIVE_ACC   db 0 
                   
    CURRENT_ACC  dw ? ; Direccion de memoria de la cuenta seleccionada              
    MAX_BAL_ACC  dw ?
    MIN_BAL_ACC  dw ?
    
    BANK_BAL     dw 0000h, 0000h

    
    HOLDER_INPUT        db 21, ?, 21 dup(?)
    ACC_NUM_INPUT       db 6, ?, 6 dup('0')
    NUMBER32_INPUT      db 12, ?, 12 dup(?)
; --------------------------------------- Gillermo


;Flag verification
FindAccountByAccountNumberError db 0    ; 1 = Error. Error flag for the FindAccountByAccountNumber procedure.
numberVerification16Flag db 0           ; 
numberVerification32Flag db 0           ;

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
input_error_message db "En este menu solo se pueden ingresar numeros del 1 al 7.", 0Dh, 0Ah, "$";


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
create_account_menu_already_exists db       "El numero de cuenta ya existe, intentalo con otro...", 0Dh,0Ah, "$"
create_account_menu_succesfully_created db  "La cuenta ha sido creada correctamente.", 0Dh,0Ah, "$" 
create_account_menu_limit_exceeded db       "No hay espacio suficiente para crear otra cuenta, intentalo de nuevo mas tarde...", 0Dh, 0Ah, "$"
create_account_menu_wrong_format db         "El numero que ingreso no esta en el formato correcto" , 0Dh, 0Ah, "$"

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

;Overdraft while withdrawing
overdraft_error_message db "No se puede extraer ese monto debido a sobregiro de la cuenta.", 0Dh, 0Ah, "$"



; Reporte Prints.   Add a newline and tab to each message?
total_de_cuentas_activas_print db "Cuentas activas: $"
total_de_cuentas_inactivas_print db "Cuentas inactivas: $"
saldo_total_del_banco_print db "Saldo total del banco: $"
cuenta_con_mayor_saldo_print db "Cuenta con mayor saldo: $"
cuenta_con_menor_saldo_print db "Cuenta con menor saldo: $"

ZERO_ACCOUNTS    db "No hay ninguna cuenta creada por el momento...", 0Dh,0Ah, "$"

; Decimal Number Print
decimal_to_print db "000000.0000$"



; Debugging prints
debug_0 db "CHECKPOINT 0", 0Dh,0Ah, "$"
debug_1 db "CHECKPOINT 1", 0Dh,0Ah, "$"
debug_2 db "CHECKPOINT 2", 0Dh,0Ah, "$"
debug_5 db "CHECKPOINT 3", 0Dh,0Ah, "$"
debug_small db ".-", "$"



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
    
    mov ah, 09h
    mov dx, offset input_error_message
    int 21h
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
    mov ah, 09h
    mov dx, offset show_report_menu_opening_message
    int 21h
    
    call show_report
    
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

; El numero N de 32 bits se recibe en DX:AX
; N/10 vuelve en DX:AX
   
Divide32By10 proc       ; Source: https://stackoverflow.com/questions/69083041/trying-to-display-a-32bit-number-in-assembly-8086-32bit
    mov     cx,ax         
    mov     ax,dx          ;First divide the HighDividend
    xor     dx,dx          ;Setup for division DX:AX / BX
    div     bx             ; -> AX is HighQuotient, Remainder is re-used
    xchg    ax,cx          ;Temporarily move it to CX restoring LowDividend
    div     bx             ; -> AX is LowQuotient, Remainder DX=[0,9]
    mov     si, dx
    mov     dx,cx          ;Build true 32-bit quotient in DX:AX
    
    ret   
Divide32By10 endp    

; El numero N de 32 bits se recibe en DX:AX
   
PrintDecimalFrom32BitFixedPoint proc    ; This name may be so long is truncated by assembler
    PUSH_REGISTERS
    mov di, 0          ; Contador de digitos del numero N
    mov bx, 10         ; Divisor
    
stack_loop:
    call Divide32By10  ; Divide por diez N y guarda el residuo en SI
    push si            ; Guardamos en el stack el numero para leerlo de nuevo luego.
    
    inc di             ; Incrementa el numero de digitos de N
    
    mov cx,dx          ; Temporalmente guardamos la parte alta de N (esto si es un numero que cabe en 16 bits, pues al usar el OR se escriben valores en DX)
    or cx, ax          ; Revisar si la parte alta y baja de N son iguales a cero.
    jnz stack_loop     ; Brincar de nuevo al loop si no son cero las dos partes.

itneed_zeros?:
    cmp di, 5          ; Para numeros con un numero de digitos < 5 debemos agregar ceros adelante para representar el punto decimal.
    jb add_zeros       ; Si hacen falta ceros, los agregamos
    
    mov cx, 0          
    
    mov bx, di         ; Cuantos numeros debo de contar antes de agregar el punto decimal?
    sub bx, 4          ; ((Si el numero tiene 6 digitos, el punto decimal debe de ir en el
                       ; segundo numero que ha imprimido)) <--- Asi es como se comportan estas dos lineas.
    mov ah, 02h        ; Imprimir el simbolo de dolar.
    mov dl, '$'
    int 21h
    
    jmp print32_number

add_zeros:
    mov cx, 5          ; Calcula cuantos ceros debe de agregar al stack
    sub cx, di
    
add_zeros_loop:
    push 0             
    inc di             ; Incrementamos el numero de digitos
    loop add_zeros_loop
    
    jmp itneed_zeros?      

print32_number:
    cmp cx, bx         ; Ya se debe de imprimir el punto?
    je add_fixed_point
    
    cmp cx, di         ; Ya terminamos de imprimir el numero?
    je return_print32
    
    pop dx             ; Sacamos el digito correspondiente del stack

    add dx, '0'        ; Se imprime el numero
    int 21h
    
    inc cx
    
    jmp print32_number
    

add_fixed_point:
    mov ah, 02h     ; Imprimir el punto
    mov dl, '.'
    int 21h
    
    mov bx, 0FFFFh  ; Valor dummy para que no vuelva a imprimir otro punto.
    
    jmp print32_number
    
return_print32:
    POP_REGISTERS    
    ret
    
PrintDecimalFrom32BitFixedPoint endp


; Recibe el numero de 16 bits en AX

PrintDecimalFrom16Bit proc
    PUSH_REGISTERS 
    
    mov cx, 10
    mov di, 0
    
div16b_loop:
    xor dx, dx
    div cx
    
    push dx
    
    inc di
    
    cmp ax, 0
    jne div16b_loop

print16_loop:
    cmp di, 0
    je return_print16
    
    pop dx
    
    add dl, '0'
    
    push ax
    
    mov ah, 02h
    int 21h
    
    pop ax
    
    dec di
    jmp print16_loop
    
return_print16:
    POP_REGISTERS
    ret

PrintDecimalFrom16Bit endp


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

number_verification32 PROC
    push ax
    push cx
    push dx
    push si
    
      
    lea si, NUMBER32_INPUT
    mov cx, 0 
    mov numberVerification32Flag, cl                     
    mov cl, [si+1]
    lea si, NUMBER32_INPUT + 2
                               
number_verification32_loop:  
    mov dl, [si]
    cmp dl, '.'
    je  skip_point
    sub dl, '0'
    cmp dl, 0
    jl  number_verification32_flag 
    cmp dl, 9
    jg  number_verification32_flag
    inc si
    loop number_verification32_loop
    jmp number_verification32_return
    
    
number_verification32_flag:
    mov al, 1
    mov numberVerification32Flag, al
   
number_verification32_return:
    pop si
    pop dx
    pop cx
    pop ax
    
    ret 
skip_point:
    inc si
    loop number_verification32_loop
number_verification32 ENDP


number_verification16 PROC
    push ax
    push cx
    push dx
    push si
    
      
    lea si, ACC_NUM_INPUT
    mov cx, 0 
    mov numberVerification16Flag, cl                     
    mov cl, [si+1]
    lea si, ACC_NUM_INPUT + 2
                               
number_verification16_loop:  
    mov dl, [si]
    sub dl, '0'
    cmp dl, 0
    jl  number_verification16_flag 
    cmp dl, 9
    jg  number_verification16_flag
    inc si
    loop number_verification16_loop
    jmp number_verification16_return
    
    
number_verification16_flag:
    mov al, 1
    mov numberVerification16Flag, al
   
number_verification16_return:
    pop si
    pop dx
    pop cx
    pop ax
    
    ret 

number_verification16 ENDP
 
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
    call number_verification16
    mov al, numberVerification16Flag
    cmp al, 1
    je  number_verification_wrong_format
    call PrintNewline

    ; Get account balance.
    mov ah, 09h
    mov dx, offset create_account_menu_enter_balance
    int 21h 
    mov ah, 0Ah
    lea dx, NUMBER32_INPUT
    int 21h 
    call number_verification32
    mov al, numberVerification32Flag
    cmp al, 1
    je number_verification_wrong_format
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
    
    call PrintNewline
    
    mov ah, 09h
    mov dx, offset create_account_menu_succesfully_created
    int 21h 
    
    ret    
     
acc_limit:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_limit_exceeded
    int 21h 
    ret
    
duplicated_acc:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_already_exists
    int 21h 
    ret    
    
number_verification_wrong_format:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    ret
    
            
create_account ENDP
; <---------------------------  Guillermo --------------------------------->
; Salida: en MAX_BAL_ACC quedara la direccion de memoria de la cuenta
; con el balance mas grande
; Esta funcion realiza una busqueda lineal comparando los balances de cada cuenta.
find_max_bal PROC
    push ax
    push bx
    push cx
    push dx
    push di
    
    ; Inicializar registros temporales
    mov ax, 0              ; Parte baja del maximo actual
    mov bx, 0
    mov cx, 0
    mov dx, 0              ; Parte alta del maximo actual
    
    lea si, ACCOUNTS       ; SI apunta al primer registro de cuenta
    mov dl, ACC_COUNT      ; Cargar cantidad de cuentas
    mov di, dx             ; DI será contador del loop
    
    mov dl, 0              ; Limpiar DL
    
find_max_loop:
    cmp di, 0              ; Ya recorrimos todas las cuentas?
    je exit_fmax
    
    ; Cargar saldo actual de la cuenta
    mov cx, [si+ACC_BAL]       ; Parte baja
    mov bx, [si+ACC_BAL+2]     ; Parte alta
    
    ; Comparar primero parte alta
    
    cmp bx, dx 
    jg set_temp_max        ; Si parte alta es mayor, nuevo máximo
    jl next_acc            ; Si es menor, pasar siguiente cuenta
    
    ; Si parte alta es igual, comparar parte baja
    
    cmp cx, ax
    jg set_temp_max        ; Si parte baja es mayor, nuevo máximo
    
    dec di 
    add si, ACC_SIZE       ; Avanzar siguiente cuenta
    jmp find_max_loop

set_temp_max:
    mov MAX_BAL_ACC, si    ; Guardar direccion de la cuenta máxima
    
    mov dx, bx             ; Actualizar parte alta máxima
    mov ax, cx             ; Actualizar parte baja máxima
    
    dec di
    add si, ACC_SIZE
    jmp find_max_loop

next_acc:
    dec di
    add si, ACC_SIZE
    jmp find_max_loop     

exit_fmax:
    pop di   
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
    
find_max_bal ENDP 

find_min_bal PROC
    push ax
    push bx
    push cx
    push dx
    push di
    
    ; Inicializar registros temporales
    mov bx, 0
    mov cx, 0
    
    lea si, ACCOUNTS       ; SI apunta al primer registro
    mov dl, ACC_COUNT
    xor dh, dh
    mov di, dx             ; DI contador
    
    mov dl, 0
    
    ; Inicializar minimo con valor maximo posible (FFFF:FFFF)
    mov ax, 0FFFFh         ; Parte baja minimo actual
    mov dx, 0FFFFh         ; Parte alta manimo actual
    
find_min_loop:
    cmp di, 0
    je exit_fmin
    
    ; Cargar saldo actual
    mov cx, [si+ACC_BAL]       ; Parte baja
    mov bx, [si+ACC_BAL+2]     ; Parte alta
    
    ; Comparar parte alta
    
    cmp bx, dx 
    jb set_temp_min        ; Si es menor, nuevo minimo
    ja next_acc_fmin       ; Si es mayor, ignorar
    
    ; Si parte alta igual, comparar parte baja
    
    cmp cx, ax
    jb set_temp_min
    
    dec di 
    add si, ACC_SIZE
    jmp find_min_loop

set_temp_min:
    mov MIN_BAL_ACC, si    ; Guardar direccion de minimo
    
    mov dx, bx             ; Actualizar parte alta minima
    mov ax, cx             ; Actualizar parte baja minima
    
    dec di
    add si, ACC_SIZE
    jmp find_min_loop

next_acc_fmin:
    dec di
    add si, ACC_SIZE
    jmp find_min_loop     

exit_fmin:
    pop di   
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
    
find_min_bal ENDP

sum_all_balances PROC
    ; Inicializar acumulador de suma
    mov ax, 0              ; Parte baja suma total
    mov bx, 0
    mov cx, 0
    mov dx, 0              ; Parte alta suma total
    
    mov dl, ACC_COUNT
    
    mov di, dx             ; DI contador
    xor dl, dl
    lea si, ACCOUNTS       ; SI apunta al primer registro
    
sum_loop:
    cmp di, 0
    je sum_return
    
    ; Cargar saldo de cuenta actual
    mov bx, [si+ACC_BAL]      ; Parte baja
    mov cx, [si+ACC_BAL+2]    ; Parte alta
    
    ; Sumar 32 bits: low con ADD, high con ADC
    add ax, bx
    adc dx, cx
    
    add si, ACC_SIZE          ; Siguiente cuenta
    
    dec di
    
    jmp sum_loop

sum_return:
    ; Guardar suma total en BANK_BAL
    mov [BANK_BAL], ax 
    mov [BANK_BAL+2], dx
    ret
    
sum_all_balances ENDP

active_inactive_count PROC
    PUSH_REGISTERS
    
    xor ax, ax
    
    ; Reiniciar contadores
    mov ACTIVE_ACC, al
    mov INACTIVE_ACC, al
    
    xor cx, cx
    
    mov cl, ACC_COUNT
    lea si, ACCOUNTS
    
count_loop:
    cmp cx, 0
    je return_count
    
    mov al, [si+ACC_STATE]    ; Leer estado de cuenta
    
    cmp al, 1
    je inc_active_count
    
    ; Cuenta inactiva
    inc INACTIVE_ACC
    dec cx
    
    add si, ACC_SIZE
    jmp count_loop
    
inc_active_count:
    ; Cuenta activa
    inc ACTIVE_ACC
    dec cx
    
    add si, ACC_SIZE
    jmp count_loop
    
return_count:
    POP_REGISTERS
    ret
active_inactive_count ENDP

show_report PROC
    push ax
    push dx
    push si
    
    mov ax, 0
    mov al, ACC_COUNT
    
    ; Si no hay cuentas, mostrar mensaje
    cmp al, 0
    je zero_accounts_found
    
    ; Contar activas/inactivas
    call active_inactive_count 
    
    ; Mostrar activas
    mov ah, 09h
    mov dx, offset total_de_cuentas_activas_print
    int 21h
    
    xor ax, ax
    mov al, ACTIVE_ACC
    
    call PrintDecimalFrom16Bit
    call PrintNewline 
     
    ; Mostrar inactivas
    mov ah, 09h
    mov dx, offset total_de_cuentas_inactivas_print
    int 21h
    
    xor ax, ax
    mov al, INACTIVE_ACC
    
    call PrintDecimalFrom16Bit
    call PrintNewline
    
    ; Buscar cuenta maxima y minima
    call find_max_bal
    call find_min_bal
    
    ; Mostrar cuenta maxima
    mov si, MAX_BAL_ACC

    mov ah, 09h
    mov dx, offset cuenta_con_mayor_saldo_print
    int 21h
    
    lea dx, si+ACC_HOLDER
    int 21h
    
    call PrintNewline
    
    ; Mostrar cuenta minima
    mov si, MIN_BAL_ACC
    
    mov ah, 09h
    mov dx, offset cuenta_con_menor_saldo_print
    int 21h
    
    lea dx, si+ACC_HOLDER
    int 21h
    
    call PrintNewline
    
    ; Mostrar saldo total banco
    mov ah, 09h
    mov dx, offset saldo_total_del_banco_print
    int 21h
    
    call sum_all_balances
    
    mov ax, [BANK_BAL]
    mov bx, [BANK_BAL+2]
    
    call PrintDecimalFrom32BitFixedPoint
       
    call PrintNewline
     
    jmp exit_report 

zero_accounts_found:
    mov ah, 09h
    mov dx, offset ZERO_ACCOUNTS
    int 21h
    
exit_report:
    pop si
    pop dx
    pop ax
    
    ret     
     
show_report ENDP

; <---------------------------  Guillermo --------------------------------->

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
    call number_verification16
    mov al, numberVerification16Flag
    cmp al, 1
    je  deposit_verification_wrong_format_without_pop
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
    call PrintNewline
    call number_verification32
    mov al, numberVerification32Flag
    cmp al, 1
    je  deposit_verification_wrong_format
    call PrintNewline

    call convert_32 ; get the 32 bit balance to add into dx:ax
    pop si
    add si, ACC_BAL ; add the offset of the balance within an account.
    ; add to the balance at si.
    add word ptr [si], ax ; si now holds the address of the balance to add to
    adc word ptr [si+2], dx
    jmp deposit_return
    

deposit_verification_wrong_format:
    pop si
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    jmp deposit_return
    
deposit_verification_wrong_format_without_pop:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    

deposit_return:
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
    call number_verification16
    mov al, numberVerification16Flag
    cmp al, 1
    je  withdraw_verification_wrong_format_without_pop
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
    call number_verification32
    mov al, numberVerification32Flag
    cmp al, 1
    je  withdraw_verification_wrong_format
    call PrintNewline

    call convert_32 ; get the 32 bit balance to add into dx:ax
    pop si
    add si, ACC_BAL ; add the offset of the balance within an account.
    ; add to the balance at si.
    
    mov cx, [si+2] 
    mov bx, [si]
    
    ;cmp cx, dx
    ;jl  overdraft
    ;cmp bx, ax
    
    sub bx, ax
    sbb cx, dx
    js  overdraft
    
    sub word ptr [si], ax ; si now holds the address of the balance to subtract from.
    sbb word ptr [si+2], dx
    
    jmp withdraw_return
    
overdraft:
    mov ah, 09h
    mov dx, offset overdraft_error_message
    int 21h
    jmp withdraw_return
    
    
withdraw_verification_wrong_format:
    pop si
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    jmp withdraw_return
    
withdraw_verification_wrong_format_without_pop:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    

withdraw_return:
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
    call number_verification16
    mov al, numberVerification16Flag
    cmp al, 1
    je  check_verification_wrong_format_without_pop
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
    
    mov ax, [si]
    mov dx, [si+2]
    
    call PrintDecimalFrom32BitFixedPoint
    jmp check_return
    
check_verification_wrong_format_without_pop:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    

check_return:
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
    call number_verification16
    mov al, numberVerification16Flag
    cmp al, 1
    je  deactivate_verification_wrong_format_without_pop
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
    jmp deactivate_return

deactivate_verification_wrong_format_without_pop:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    

deactivate_return:
    POP_REGISTERS
    ret
deactivate_an_account endp






