.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi sp,sp,-16
    sd ra,8(sp)
    sd s0,0(sp)
    mv s0,a0              # save val in s0
    li a0,12              # allocate 12 bytes for node
    call malloc
    sw s0,0(a0)           # node->val=val
    sd x0,8(a0)           # node->left=NULL
    sd x0,16(a0)           # node->right=NULL
    ld ra,8(sp)
    ld s0,0(sp)
    addi sp,sp,16
    ret

insert:
    addi sp,sp,-32
    sd ra,24(sp)
    sd s0,16(sp)
    sd s1,8(sp)
    mv s0,a0                            # s0=root
    mv s1,a1                            # s1=val
    bne s0,x0,insert_notnull            # if root==NULL make new node and return
    mv a0,s1
    call make_node
    j insert_done
    insert_notnull:
        lw t0,0(s0)                     # t0=root->val
        beq s1,t0,insert_return_root    # if val==root->val do nothing
        blt s1,t0,insert_left           # val < root->val go left
        ld a0,16(s0)                     # a0=root->right
        mv a1,s1       
        call insert
        sd a0,16(s0)                     # root->right=result
        j insert_return_root
        insert_left:
            ld a0,8(s0)                 # a0=root->left
            mv a1,s1
            call insert
            sd a0,8(s0)                 # root->left=result
    insert_return_root:
        mv a0,s0                        # a0=root
    insert_done:
        ld ra,24(sp)
        ld s0,16(sp)
        ld s1,8(sp)
        addi sp,sp,32
        ret

get:
    beq a0,x0,get_done                 # if root==NULL return NULL
    lw t0,0(a0)
    beq a1,t0,get_done                 # return root if root->val==val
    blt a1,t0,get_go_left              # go left val < root->val
    ld a0,16(a0)
    j get
    get_go_left:
        ld a0,8(a0)
        j get
    get_done:
        ret

getAtMost:
    addi sp,sp,-32
    sd ra,24(sp)
    sd s0,16(sp)
    sd s1,8(sp)
    sd s2,0(sp)
    mv s0,a0                            # s0=val
    mv s1,a1                            # s1=root
    li s2,-1                            # s2=best result so far
    getAtMost_loop:
        beq s1,x0,getAtMost_done        # if root==NULL return best result so far
        lw t0,0(s1)                     # t0=root->val
        blt s0,t0,getAtMost_go_left     # if val < root->val go left
            mv s2,t0                    # update best
            beq s0,t0,getAtMost_done    # exact match, can't do better
            ld s1,16(s1)                 # root=root->right
            j getAtMost_loop            # trying to find if a better answer exists
        getAtMost_go_left:
            ld s1,8(s1)                 # root=root->left
            j getAtMost_loop   
    getAtMost_done:
        mv a0,s2                        # return best result
        ld ra,24(sp)
        ld s0,16(sp)
        ld s1,8(sp)
        ld s2,0(sp)
        addi sp,sp,32
        ret
