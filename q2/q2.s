.section .rodata
int_fmt: .string "%d"
space_str: .string " "
newline_str: .string "\n"

.text
.globl main

main:
    addi sp,sp,-80
    sd ra,72(sp)
    sd s0,64(sp)        # s0=argc-1 (n,number of elements)
    sd s1,56(sp)        # s1=pointer to int array (heap)
    sd s2,48(sp)        # s2=pointer to result array (heap)
    sd s3,40(sp)        # s3=pointer to stack base (heap)
    sd s4,32(sp)        # s4=stack top index (number of elements currently on stack)
    sd s5,24(sp)        # s5=loop counter i
    sd s6,16(sp)        # s6=argv base pointer

    # a0=argc, a1=argv
    addi s0,a0,-1       # n=argc-1
    mv s6,a1            # save argv

    ine:
        beq s0,x0,empty_exit

    # allocate int array (n*4 bytes)
    slli a0,s0,2
    call malloc
    mv s1,a0            # s1=arr[]

    # allocate result array (n*4 bytes)
    slli a0,s0,2
    call malloc
    mv s2,a0            # s2=result[]

    # allocate stack (n*4 bytes)
    slli a0,s0,2
    call malloc
    mv s3,a0            # s3=stack base
    li s4,0             # stack top index=0 (empty)

    # parse argv[1..n] into arr[]
    li s5,0             # i=0
    
    parse_loop:
        bge s5,s0,parse_done
        addi t0,s5,1    # argv index=i+1
        slli t1,t0,3
        add t1,s6,t1
        ld a0,0(t1)     # a0=argv[i+1]
        call atoi
        slli t1,s5,2
        add t1,s1,t1
        sw a0,0(t1)     # arr[i]=atoi(argv[i+1])
        addi s5,s5,1
        j parse_loop
    
    parse_done:
        # initialise result[] to -1
        li s5,0

    init_loop:
        bge s5,s0,init_done
        slli t0,s5,2
        add t0,s2,t0
        li t1,-1
        sw t1,0(t0)
        addi s5,s5,1
        j init_loop

    init_done:
        # main algorithm: iterate i from n-1 down 0
        addi s5,s0,-1    # i=n-1
    algo_loop:
        blt s5,x0,algo_done

        # while (!stack_empty && arr[stack_top()]<=arr[i]) pop
        while_loop:
            beq s4,x0,while_done   # stack empty -> exit while

            # t0=arr[stack_top()]
            addi t1,s4,-1          # top index in stack array
            slli t1,t1,2
            add t1,s3,t1
            lw t2,0(t1)            # t2=stack_top() (an index int arr)
            slli t3,t2,2 
            add t3,s1,t3
            lw t0,0(t3)            # t0=arr[stack_top()]

            # t4=arr[i]
            slli t4,s5,2
            add t4,s1,t4
            lw t4,0(t4)            # t4=arr[i]

            bgt t0,t4,while_done   # arr[stack_top()]>arr[i] -> stop popping            
            addi s4,s4,-1          # pop
            j while_loop
        
        while_done:
            # if (!stack_empty) result[i]=stack_top()
            beq s4,x0,skip_result
            addi t1,s4,-1
            slli t1,t1,2
            add t1,s3,t1
            lw t2,0(t1)             # t2=stack_top()
            slli t3,s5,2
            add t3,s2,t3
            sw t2,0(t3)             # result[i]=stack_top()

        skip_result:
            # push(i)
            slli t1,s4,2
            add t1,s3,t1
            sw s5,0(t1)             # stack[s4]=i
            addi s4,s4,1            # s4++

            addi s5,s5,-1           # i--
            j algo_loop
    
    algo_done:
        # print result
        li s5,0
    print_loop:
        bge s5,s0,print_done
        # print space seperator before every element except the first
        beq s5,x0,no_space
        la a0,space_str
        call printf

    no_space:
        slli t0,s5,2
        add t0,s2,t0
        lw a1,0(t0)       # a1=result[i]
        la a0,int_fmt
        call printf

        addi s5,s5,1
        j print_loop

    print_done:
        la a0,newline_str
        call printf

        li a0,0           # return 0
        ld ra,72(sp)
        ld s0,64(sp)
        ld s1,56(sp)
        ld s2,48(sp)
        ld s3,40(sp)
        ld s4,32(sp)
        ld s5,24(sp)
        ld s6,16(sp)
        addi sp,sp,80
        ret

    empty_exit:
        li a0,0           # return 0
        ld ra,72(sp)
        ld s0,64(sp)
        ld s1,56(sp)
        ld s2,48(sp)
        ld s3,40(sp)
        ld s4,32(sp)
        ld s5,24(sp)
        ld s6,16(sp)
        addi sp,sp,80
        ret     