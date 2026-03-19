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
    ; Symbolic definitions for the data structure
    ; This specifies the byte size of each data element (for the movement in the data structure)
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
    
    ; Account management variables.
    ACCOUNTS       db ACC_SIZE * MAX_ACC dup(?) ; Saves the space in memory for 10 accounts.
    ACC_COUNT      db 0 ; Account counter.
    ACTIVE_ACC     db 0
    INACTIVE_ACC   db 0 
                   
    CURRENT_ACC  dw ? ; Memory address of the selected account.
    MAX_BAL_ACC  dw ?
    MIN_BAL_ACC  dw ?
    
    BANK_BAL     dw 0000h, 0000h

    
    HOLDER_INPUT        db 21, ?, 21 dup(?)
    ACC_NUM_INPUT       db 6, ?, 6 dup('0')
    NUMBER32_INPUT      db 12, ?, 12 dup(?)
    NUMBER32_INPUT_FIXED_POINT_ZEROS    db 4 dup('0') ; This Mantains 4 consecutive zeros in memory
                                                    ; that are added to numbers depending on the number of digits after decimal point.
; --------------------------------------- Gillermo


;Flag verification
FindAccountByAccountNumberError db 0    ; 1 = Error. Error flag for the FindAccountByAccountNumber procedure.
numberVerification16Flag db 0           ; 
numberVerification32Flag db 0           ;

; Counts the number of digits present after the decimal point.
; It's updated by number_verification32 for fixed point arithmetic and used on NUMBER32_INPUT.
digits_after_decimal_point_count db 0
has_reached_decimal_point   db 0    ; This is used to check no more than one decimal point is present in NUMBER32_INPUT.

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

; Create account prints.
create_account_menu_enter_holder db         "Digite el nombre del propietario:", 0Dh,0Ah, "$"
create_account_menu_enter_account_number db "Digite el numero de cuenta:", 0Dh,0Ah, "$"
create_account_menu_enter_balance db        "Digite el saldo:", 0Dh,0Ah, "$"
create_account_menu_already_exists db       "El numero de cuenta ya existe, intentelo con otro...", 0Dh,0Ah, "$"
create_account_menu_succesfully_created db  "La cuenta ha sido creada correctamente.", 0Dh,0Ah, "$" 
create_account_menu_limit_exceeded db       "No hay espacio suficiente para crear otra cuenta, intentelo de nuevo mas tarde...", 0Dh, 0Ah, "$"
create_account_menu_wrong_format db         "El numero que ingreso no esta en el formato correcto" , 0Dh, 0Ah, "$"

; FindAccountByAccountNumber error print
find_account_by_account_number_error_message db "No se encontro una cuenta con ese numero de cuenta.", 0Dh,0Ah, "$"

; deposit_to_an_account prints.
deposit_to_an_account_indicate_amount db "Indique el monto por depositar.", 0Dh,0Ah, "$"
; withdraw_from_an_account prints.
withdraw_from_an_account_indicate_amount db "Indique el monto por retirar.", 0Dh,0Ah, "$"
; check_balance_of_an_account prints.
check_balance_of_an_account_show_amount db "El saldo de la cuenta es: $"

; deactivate_an_account prints.
deactivate_an_account_success_message db "Cuenta desactivada.", 0Dh,0Ah, "$"
deactivate_an_account_repeated_account_message db "La cuenta indicada ya fue desactivada.", 0Dh,0Ah, "$"

; Overdraft while withdrawing.
overdraft_error_message db "No se puede extraer ese monto debido a sobregiro de la cuenta.", 0Dh, 0Ah, "$"

; Inactive account when depositing or withdrawing.
transaction_on_inactive_account_error_message db "La cuenta indicada esta desactivada.", 0Dh, 0Ah, "$"



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

; The 32 bits number N it's received in DX:AX
; N/10 comes back in DX:AX
   
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

; The 32 bits number N it's received in DX:AX
   
PrintDecimalFrom32BitFixedPoint proc    ; This name may be so long is truncated by assembler
    PUSH_REGISTERS
    mov di, 0          ; Digit counter of number N
    mov bx, 10         ; Divisor
    
stack_loop:
    call Divide32By10  ; Divide N by ten and store the remainder in SI.
    push si            ; Pushes the number onto the stack to retreive it later.
    
    inc di             ; Increases the digit number of N. 
    
    mov cx,dx          ; We temporarily store the high side of N (which is required for 16 bit values, as the or operation modifies the DX register).
    or cx, ax          ; This checks if the high side and the low side of N are equal to cero.
    jnz stack_loop     ; This jumps back again to the loop if neither of both sides are equal to cero.

itneed_zeros?:
    cmp di, 5          ; In the case of numbers with 5 digits, we need to add more zeros in front of it so we can represent the decimaal point.
    jb add_zeros       ; If we are missing zeros we just add them
    
    mov cx, 0          
    
    mov bx, di         ; How many number we need to count before adding the decimal point?
    sub bx, 4          ; ((If the number has 6 digits, the decimal point must go in the 
                       ; second number that has been printed)) <--- And that is how this two lines behave.
    mov ah, 02h        ; This just prints the dolar symbol.
    mov dl, '$'
    int 21h
    
    jmp print32_number

add_zeros:
    mov cx, 5          ; This calculate how many ceros must be added to the stack.
    sub cx, di
    
add_zeros_loop:
    push 0             
    inc di             ; This increases the digit numbers
    loop add_zeros_loop
    
    jmp itneed_zeros?      

print32_number:
    cmp cx, bx         ; Should the decimal point be printed yet? 
    je add_fixed_point
    
    cmp cx, di         ; This check if the number printing is completed
    je return_print32
    
    pop dx             ; We pop out the corresponding digit from the stack

    add dx, '0'        ; The number is printed.
    int 21h
    
    inc cx
    
    jmp print32_number
    

add_fixed_point:
    mov ah, 02h     ; The point is printed
    mov dl, '.'
    int 21h
    
    mov bx, 0FFFFh  ; This is like a dummy value so it doesn't prints another point.
    
    jmp print32_number
    
return_print32:
    POP_REGISTERS    
    ret
    
PrintDecimalFrom32BitFixedPoint endp


;   This receives 16 bits number from AX

PrintDecimalFrom16Bit proc
    PUSH_REGISTERS 
    
    mov cx, 10  ;Set divisor to 10 for decimal conversion
    mov di, 0   ;Initialize digit counter
    
div16b_loop:
    xor dx, dx  ;Cleans dx for the division
    div cx      ;Division
    
    push dx     ;Pushes the remaining (decimal digit) on to the stack
    
    inc di      ;Increases digit counter
    
    cmp ax, 0   ;Checks if quotient is cero
    jne div16b_loop ;If its different than zero, continues extracting digits

print16_loop:
    cmp di, 0   ;Check if all digits have been read
    je return_print16   ;If the counter is zero, then exits the loop
    
    pop dx  
    
    add dl, '0' ;Converts the number to ascii character
    
    push ax     
    
    mov ah, 02h
    int 21h
    
    pop ax
    
    dec di      ;Reduce digit counter
    jmp print16_loop   
    
return_print16:
    POP_REGISTERS
    ret

PrintDecimalFrom16Bit endp

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Test function
; Prints Hex of dx:ax
PrintHexFrom32Bit proc

    ret
PrintHexFrom32Bit endp
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++







; --------------------------------------- Gillermo
    
; The number must be in number32_input 
; Receive AX, BX, CX y DX in 0   high:baja 
; Returns in AX, DX a 32 bit number      dx:ax
;                                        bx:cx

convert_32 PROC
    mov ax, 0 ; This cleans the four registers in order to parse a 32 bits number 
    mov bx, 0 
    mov cx, 0
    mov dx, 0
    
    xor di, di
    mov dl, [NUMBER32_INPUT+1]
    mov di, dx                  ; di holds the amount of digits.
    ; This makes the function keep adding zeros (i. e. multiplying by 10) as much as the digit count after the decimal point is less than 4.
    ; i. e. added zeros = 4 - (digits after '.'). This value is saved to dx here.
    mov dx, 4
    sub dl, [digits_after_decimal_point_count]
    add di, dx
    ; digits_after_decimal_point_count now will hold the number of zeros to add.
    mov [digits_after_decimal_point_count], dl

    xor dx, dx
    lea si, NUMBER32_INPUT+2    ; si holds the address of the current char.

convert_loop:
    cmp di, 0 ;Checks if the counter is 0 
    je ExitConvertLoop  ; if there are no more characters, then exit the loop
    mov bl, [digits_after_decimal_point_count]
    cmp di, bx
    jle convert_loop_add_zeros  ; Uses a fixed value of 0 for the number to add in case the sequence has ended but more zeros are necessary.
                    
    mov bl, [si] ; Loads the current character from the string 
    cmp bl, '.'  ; Check if the character is "." 
    je convert_loop_skip_decimal_point ;Skips the "." if there is one
    sub bl, '0'  ; Converts the ascii to its numeric value
    jmp convert_loop_add_zeros_skip 
    convert_loop_add_zeros:
    mov bx, 0    ; Uses zeros as padding
    convert_loop_add_zeros_skip:   
    
    push bx     ; Stores the current digit to the stack
    
    shl ax, 1   ; Shifts Ax left by 1 (Value x 2)
    rcl dx, 1   ; Rotates the carry digit into dx to keep the 32-bit
    
    mov bx, ax  
    mov cx, dx
    
    shl ax, 1   ;Shift again (Value x 4)
    rcl dx, 1
    
    shl ax, 1   ;Shift again (Value x 8)
    rcl dx, 1
    
    add ax, bx  ;Adds from (Value x 2) to (Value x 8)
    adc dx, cx  ;Add with carry for the higher value to dx
    
    pop bx      ;Restore the digit 
                
    xor bh, bh  ;Cleans bh
    add ax, bx  ;Adds the new digit to the low side of (ax)
    adc dx, 0   ;Propagate carry to the high side (dx)

    convert_loop_skip_decimal_point:
    dec di      ;Reduces the character counter
    inc si      ;Increases the pointer for the character string
    jmp convert_loop    ;Repeats the loop  
    
ExitConvertLoop:
    ret
    
convert_32 ENDP


; Checks for character errors in a user given number (NUMBER32_INPUT) that can include a decimal point.
; Also counts the number of digits present after the decimal point.
; this is used for fixed point arithmetic.
; digits_after_decimal_point_count stores this count.
number_verification32 PROC
    push ax
    push cx
    push dx
    push si
    
    ;Initialize state variables    
    mov [digits_after_decimal_point_count], 0
    mov [has_reached_decimal_point], 0
    

    lea si, NUMBER32_INPUT  ;Load input address
    mov cx, 0 
    mov numberVerification32Flag, cl    ;Resets error flag                  
    mov cl, [si+1]          ;gets the number of characters
    lea si, NUMBER32_INPUT + 2  ;points si to the start of the string
                               
number_verification32_loop:  
    mov dl, [si]    ;load current character
    cmp dl, '.'     ;Checks if it's a "."
    je  skip_point
;----Checks if the character is in a range of values different than numbers using ascii values----
    sub dl, '0'
    cmp dl, 0
    jl  number_verification32_flag ;Error if the character is < 0
    cmp dl, 9
    jg  number_verification32_flag ;Error if the character is > 0
    inc si                         ;Move to next character
    loop number_verification32_loop ;Repeat until the last character
    jmp number_verification32_return
    
    
number_verification32_flag:
    mov al, 1       ;Sets error flag to 1
    mov numberVerification32Flag, al
   
number_verification32_return:
    pop si
    pop dx
    pop cx
    pop ax
    
    ret 
skip_point:
    inc si
    mov [digits_after_decimal_point_count], cl  ; cl has the amount of digits left input by the user, including the current '.'.
    sub [digits_after_decimal_point_count], 1   ; count only the remaining digits after the '.'.
    ; If there are more than 4 digits after the decimal point, the format is considered incorrect.
    cmp [digits_after_decimal_point_count], 4
    jg number_verification32_flag
    ; Check that the decimal point was not reached several times.
    cmp has_reached_decimal_point, 1
    je number_verification32_flag
    mov [has_reached_decimal_point], 1
    ; Loop again if no error have ocurred.
    loop number_verification32_loop
    ; This jump is reached if the number ended in a decimal point e. g.: "2." This is considered incorrect.
    jmp number_verification32_flag
number_verification32 ENDP


number_verification16 PROC
    push ax
    push cx
    push dx
    push si
    
      
    lea si, ACC_NUM_INPUT   ;Loads the 16 bit input
    mov cx, 0 
    mov numberVerification16Flag, cl ;Resets error flag                     
    mov cl, [si+1]          ;Gets the character count
    lea si, ACC_NUM_INPUT + 2   ;Sets the start of the string
                               
number_verification16_loop:  
    mov dl, [si]
    sub dl, '0'             ;Convers from ascii to numeric
    cmp dl, 0
    jl  number_verification16_flag  ;Error if the character is < 0
    cmp dl, 9
    jg  number_verification16_flag  ;Error if the character is > 0
    inc si
    loop number_verification16_loop ;Checks next character
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

    xor ax, ax ; Cleans the registers
    xor cx, cx
    xor dx, dx
    xor bh, bh
    mov cl, [ACC_NUM_INPUT+1] ; Number of characters entered by the users
    lea si, ACC_NUM_INPUT+2   ; This is for the memory address where the string starts

;convert_acc_number:
;    mov bl, [si]  ; We assign the character
;    sub bl, '0'   ; Conversion to integer
;    mov dx, 10    ; Assign ten as the multiplier for the previous number ax * 10 + bl
;    mul dx
;    add ax, bx 
;   
;    inc si        ; Changes to the next character
;
;    loop convert_acc_number
    call ConvertAccountNumberTo16
    
    mov cl, ACC_COUNT
    lea si, ACCOUNTS  ; Is the start of the accounts memory block
    xor bx, bx   
    
check_existance:
    cmp cl, 0
    je create_new_acc    ; No account has the same number as another one, so we create a new one.
    
    mov bx, [si]
    cmp ax, bx           ; If the entered number is he same for another account, we avoid creating a new one.
    je duplicated_acc
    
    dec cl
    add si, ACC_SIZE     ; We jump to the next account.
    jmp check_existance    

create_new_acc:
    mov dx, ax
    xor ax, ax               ; This lines are used to calculate
    mov al, ACC_COUNT        ; the memory address for the account that we are gonna create
    mov bl, ACC_SIZE         ; in this way : ACCOUNTS + ACC_SIZE * ACC_COUNT 
    mul bl
    lea si, ACCOUNTS
    add si, ax
    mov CURRENT_ACC, si
    
    mov [si+ACC_NUM], dx     ; Stores the account number
    mov [si+ACC_STATE], 1    ; We setup the account state as active (0 = inactive, 1 = active)
    lea di, HOLDER_INPUT     ; First byte from the input
    mov cl, [di+1]           ; Character counter, for the copy_acc_holder loop
    lea di, HOLDER_INPUT+2   ; First character from the input
    lea si, si+ACC_HOLDER    ; First character from the account array
    mov bx, ax
    
copy_acc_holder:
    mov dx, 0   
    
    mov al, [di]          ; Copies the input to the account that we are creating.
    mov [si], al
    
    inc di                ; We change the byte (character) for the input and the account array 
    inc si                       
    
    loop copy_acc_holder         
    
    mov al, '$'                  ; At the end of the name string we add the $ symbol in order to print it
    mov [si], al                 ; without using the loop

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
; Output: MAX_BAL_ACC will store the memory address of the account
; with the highest balance
; This function performs a linear search by comparing the balances of each account.
find_max_bal PROC
    push ax
    push bx
    push cx
    push dx
    push di
    
    ; Initialize temporary registers
    mov ax, 0              ; Low side of the current maximum
    mov bx, 0
    mov cx, 0
    mov dx, 0              ; High side of the current maximum
    
    lea si, ACCOUNTS       ; SI points to the first account register
    mov dl, ACC_COUNT      ; Loads the amount of accounts
    mov di, dx             ; DI would be the loop counter
    
    mov dl, 0              ; Cleans DL
    
find_max_loop:
    cmp di, 0              ; Have we look at all the accounts ?
    je exit_fmax
    
    ; Loads the current balance on the account
    mov cx, [si+ACC_BAL]       ; Low side
    mov bx, [si+ACC_BAL+2]     ; High side
    
    ; First compares the high side
    
    cmp bx, dx 
    ja set_temp_max        ; If the high side is bigger then we have a new maximum 
    jb next_acc            ; If its smaller we move to the next account
    
    ; If both high sides are the same, then we compare the low side
    
    cmp cx, ax
    ja set_temp_max        ; If the low side is bigger, then we have a new maximum
    
    dec di 
    add si, ACC_SIZE       ; Move to the next account
    jmp find_max_loop

set_temp_max:
    mov MAX_BAL_ACC, si    ; Stores the account address for the maximum account
    
    mov dx, bx             ; It updates the maximum High side
    mov ax, cx             ; It updates the maximum low side
    
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
    
    ; Initialize temporary registers
    mov bx, 0
    mov cx, 0
    
    lea si, ACCOUNTS       ; SI points to the first register
    mov dl, ACC_COUNT
    xor dh, dh
    mov di, dx             ; DI counter
    
    mov dl, 0
    
    ; Initialize minimum with the biggest posible value (FFFF:FFFF)
    mov ax, 0FFFFh         ; Current minimum low side
    mov dx, 0FFFFh         ; Current minimum high side
    
find_min_loop:
    cmp di, 0
    je exit_fmin
    
    ; Loads current balance
    mov cx, [si+ACC_BAL]       ; Low side
    mov bx, [si+ACC_BAL+2]     ; High side
    
    ; Compares the high side
    
    cmp bx, dx 
    jb set_temp_min        ; If it's smaller, new minimum
    ja next_acc_fmin       ; If it's bigger, ignore it
    
    ; If the high side is the same, compare the low side
    
    cmp cx, ax
    jb set_temp_min
    
    dec di 
    add si, ACC_SIZE
    jmp find_min_loop

set_temp_min:
    mov MIN_BAL_ACC, si    ; Store the minimum's address
    
    mov dx, bx             ; Update the minimum's high side
    mov ax, cx             ; Updates the minimum's low side
    
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
    ; Initialize sum accumulator
    mov ax, 0              ; Low side sum total
    mov bx, 0
    mov cx, 0
    mov dx, 0              ; High side sum total
    
    mov dl, ACC_COUNT
    
    mov di, dx             ; DI counter
    xor dl, dl
    lea si, ACCOUNTS       ; SI points to the first register
    
sum_loop:
    cmp di, 0
    je sum_return
    
    ; Loads current account balance 
    mov bx, [si+ACC_BAL]      ; Low side
    mov cx, [si+ACC_BAL+2]    ; High side
    
    ; Sums 32 bits: low with ADD, high with ADC
    add ax, bx
    adc dx, cx
    
    add si, ACC_SIZE          ; Next account
    
    dec di
    
    jmp sum_loop

sum_return:
    ; Stores total sum in BANK_BAL
    mov [BANK_BAL], ax 
    mov [BANK_BAL+2], dx
    ret
    
sum_all_balances ENDP

active_inactive_count PROC
    PUSH_REGISTERS
    
    xor ax, ax
    
    ; Restart the counters
    mov ACTIVE_ACC, al
    mov INACTIVE_ACC, al
    
    xor cx, cx
    
    mov cl, ACC_COUNT
    lea si, ACCOUNTS
    
count_loop:
    cmp cx, 0
    je return_count
    
    mov al, [si+ACC_STATE]    ; Reads the account status 
    
    cmp al, 1
    je inc_active_count
    
    ; Inactive account
    inc INACTIVE_ACC
    dec cx
    
    add si, ACC_SIZE
    jmp count_loop
    
inc_active_count:
    ; Active account
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
    
    ; If there is no account, shows up the message
    cmp al, 0
    je zero_accounts_found
    
    ; Counts the actives and inactives
    call active_inactive_count 
    
    ; Shows up the actives
    mov ah, 09h
    mov dx, offset total_de_cuentas_activas_print
    int 21h
    
    xor ax, ax
    mov al, ACTIVE_ACC
    
    call PrintDecimalFrom16Bit
    call PrintNewline 
     
    ; Shows up the inactives
    mov ah, 09h
    mov dx, offset total_de_cuentas_inactivas_print
    int 21h
    
    xor ax, ax
    mov al, INACTIVE_ACC
    
    call PrintDecimalFrom16Bit
    call PrintNewline
    
    ; Search for the accounts with the maximum and minimum balance in them
    call find_max_bal
    call find_min_bal
    
    ; Shows the account with the maximum balance
    mov si, MAX_BAL_ACC

    mov ah, 09h
    mov dx, offset cuenta_con_mayor_saldo_print
    int 21h
    
    lea dx, si+ACC_HOLDER
    int 21h
    
    call PrintNewline
    
    ; Shows the account with the minimum balance
    mov si, MIN_BAL_ACC
    
    mov ah, 09h
    mov dx, offset cuenta_con_menor_saldo_print
    int 21h
    
    lea dx, si+ACC_HOLDER
    int 21h
    
    call PrintNewline
    
    ; Show the bank's total balance
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
    
    mov bx, 0

    mov ax, 0
    lea si, ACC_NUM_INPUT+2     ; Memory address where the string starts
    mov ch, 0
    mov cl, byte ptr [ACC_NUM_INPUT+1]   ;  String size.

    convert_acc_number:
    mov bl, [si]  ; We assign the character
    sub bl, '0'   ; Integer conversion
    mov dx, 10    ; Sets the multiplier to 10 for the AX * 10 + BL operation   
    mul dx        ; dx:ax = ax * dx
    add ax, bx
   
    inc si        ; Moves to the next character

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
    ; If the account is inactive, print an error and return.
    cmp byte ptr [si+ACC_STATE], 0   ; 0 means inactive.
    je transaction_on_inactive_account_error
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
    jmp deposit_return

transaction_on_inactive_account_error:
    mov ah, 09h
    mov dx, offset transaction_on_inactive_account_error_message
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
    ; If the account is inactive, print an error and return.
    cmp byte ptr [si+ACC_STATE], 0   ; 0 means inactive.
    je transaction_on_inactive_account_error
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
    ; print("Ingrese el numero de cuenta por desactivar.")
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

    add si, ACC_STATE ; add the offset of the state within an account.
    ; Sobresecribir el estado de la cuenta en la direccion dada por si con inactiva (0 = inactiva, 1 = activa)
    cmp byte ptr [si], 0
    je account_already_deactivated_error
    mov byte ptr [si], 0 ; si now holds the address of the balance to subtract from.
    ; print "Cuenta desactivada."
    mov ah, 09h
    mov dx, offset deactivate_an_account_success_message
    int 21h 
    jmp deactivate_return

deactivate_verification_wrong_format_without_pop:
    call PrintNewline
    mov ah, 09h
    mov dx, offset create_account_menu_wrong_format 
    int 21h
    jmp deactivate_return

account_already_deactivated_error:
    mov ah, 09h
    mov dx, offset deactivate_an_account_repeated_account_message
    int 21h 

deactivate_return:
    POP_REGISTERS
    ret
deactivate_an_account endp





