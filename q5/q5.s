.section .rodata
filename: .string "input.txt"
mode_r: .string "r"
str_yes: .string "Yes\n"
str_no: .string "No\n"
err_msg: .string "Error: Could not open input.txt. Check if file exists.\n"

.section .text
.globl main

main:
    addi sp,sp,-64
    sd ra,56(sp)
    sd s0,48(sp)         # s0 -> forward file pointer (fp1)
    sd s1,40(sp)         # s1 -> backward file pointer (fp2)
    sd s2,32(sp)         # s2=file length
    sd s3,24(sp)         # s3=left index (0-based,moves right)
    sd s4,16(sp)         # s4=right index (n-1,moves left)
    sd s5,8(sp)          # s5=left_char (saved across fseek/fgetc calls)

    # open file for forward reading (fp1)
    la a0,filename
    la a1,mode_r
    call fopen
    mv s0,a0             # s0=fp1
    beq s0,x0,fail_with_message     # fopen failed

    # open file for backward reading (fp2)
    la a0,filename
    la a1,mode_r
    call fopen
    mv s1,a0             # s0=fp1
    beq s1,x0,fail_with_message   # fopen failed

    # find file length: fseek(fp2,0,SEEK_END)
    mv a0,s1
    li a1,0
    li a2,2              # SEEK_END=2
    call fseek

    # s2=ftell(fp2)=file length
    mv a0,s1
    call ftell
    mv s2,a0             # s2=n (file length in bytes)

    # handle edge cases: empty file or single char
    li t0,1
    ble s2,t0,print_yes  # 0 or 1 chars -> pallindrome

    # initialise left and right indices
    li s3,0              # left=0
    addi s4,s2,-1        # right=n-1

    # Check for and ignore trailing newline
    mv a0,s1
    mv a1,s4
    li a2,0              # SEEK_SET
    call fseek
    mv a0,s1
    call fgetc
    li t2,10             # ASCII value for "\n"
    bne a0,t2,rewind_fp1 # If last char is not "\n", proceed normally
    addi s4,s4,-1        # If it is "\n", decrement the right pointer by 1

    # rewind fp1 to start
    rewind_fp1:
        mv a0,s0
        li a1,0
        li a2,0              # SEEK_SET=0
        call fseek

    compare_loop:
        # if left>=right we're done -> it's a pallindrome
        bge s3,s4,print_yes

        # read char from left: fseek fp1 to s3, then fgetc
        mv a0,s0
        mv a1,s3
        li a2,0          # SEEK_SET
        call fseek
        mv a0,s0
        call fgetc
        mv s5,a0         # s5=left_char

        # read char from right: fseek fp2 to s4, then fgetc
        mv a0,s1
        mv a1,s4
        li a2,0          # SEEK_SET
        call fseek
        mv a0,s1
        call fgetc
        mv t1,a0         # t1=right_char

        # compare
        bne s5,t1,print_no

        # advance pointers
        addi s3,s3,1     # left++ 
        addi s4,s4,-1    # right--
        j compare_loop

    fail_with_message:
        beq s0,x0,skip_close_err    # fp1 might be NULL if first fopen failed
        mv a0,s0
        call fclose
    skip_close_err:
        la a0,err_msg
        call printf
        j exit_main 

    print_yes:
        # close both files
        mv a0,s0
        call fclose
        mv a0,s1
        call fclose
        la a0,str_yes
        call printf
        j exit_main

    print_no:
        # close both files
        mv a0,s0
        call fclose
        mv a0,s1
        call fclose
        la a0,str_no
        call printf
        j exit_main

    exit_main:
        li a0,0
        ld ra,56(sp)
        ld s0,48(sp)         
        ld s1,40(sp)         
        ld s2,32(sp)         
        ld s3,24(sp)         
        ld s4,16(sp)
        ld s5,8(sp)
        addi sp,sp,64
        ret
