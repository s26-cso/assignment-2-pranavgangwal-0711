#include <stdio.h>
#include <string.h>
#include <dlfcn.h>

#define OP_MAX 6       
#define LIBNAME_MAX 12      

int main(void) {
    char op[OP_MAX];
    int  num1, num2;

    // Read one line at a time
    while (scanf("%5s %d %d", op, &num1, &num2) == 3) {

        // Build library name
        // Use "./" prefix so dlopen looks in the current working directory
        char libname[3 + OP_MAX + 3 + 1]; // "./" + "lib" + op + ".so" + null
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        // Load the shared library
        void *handle = dlopen(libname, RTLD_NOW);
        if (!handle) {
            fprintf(stderr, "Error loading %s: %s\n", libname, dlerror());
            continue;
        }

        // Look up the function symbol named <op>
        typedef int (*op_func_t)(int, int);
        void    *sym  = dlsym(handle, op);
        char    *err  = dlerror();
        if (err != NULL) {
            fprintf(stderr, "Error finding symbol '%s': %s\n", op, err);
            dlclose(handle);
            continue;
        }

        // Convert void* to function pointer
        op_func_t func;
        memcpy(&func, &sym, sizeof(func));

        // Call the operation and print the result
        int result = func(num1, num2);
        printf("%d\n", result);

        // Unload before loading the next lib
        dlclose(handle);
    }

    return 0;
}