%option case-insensitive yylineno
%{
    struct symbol {
        char *name;
        struct ref *reflist;
    };
    /* a word */
    struct ref {
        struct ref *next;
        int flags;
        int lineno;
    };
    /* simple symtab of fixed size */
    #define NHASH 9997
    struct symbol symtab[NHASH];
    struct symbol *lookup(char*);
    void addref(int, char*, int);
%}

%%
a |
an |
and |
are |
as |
at |
be |
but |
for |
in |
is |
it |
of |
on |
or |
that |
the |
this |
to /* ignore */

[a-z]+(\'(s|t))?    { addref(yylineno, yytext, 0); }
.|\n /* ignore everything else */
%%

main() {
    yylineno = 1;
    yylex();
    printrefs();
}

/* hash a symbol */
static unsigned symhash(char *sym) {
    unsigned int hash = 0;
    unsigned c;
    while (c = *sym++)
        hash = hash * 9 ^ c;
    return hash;
}

struct symbol* lookup(char* sym) {
    struct symbol *sp = &symtab[symhash(sym) % NHASH];
    int scount = NHASH;
    /* how many have we looked at */
    while (--scount >= 0) {
        if (sp->name && !strcmp(sp->name, sym))
            return sp;
        if (!sp->name)
        {
            sp->name = strdup(sym);
            sp->reflist = 0;
            return sp;
        }
        /* new entry */
        if (++sp >= symtab + NHASH)
            sp = symtab; /* try the next entry */
    }
    fputs("symbol table overflow\n", stderr);
    abort(); /* tried them all, table is full */
}


void
addref(int lineno, char *word, int flags)
{
    struct ref *r;
    struct symbol *sp = lookup(word);
    /* don't do dups of same line and file */
    if(sp->reflist && sp->reflist->lineno == lineno)
        return;
    r = malloc(sizeof(struct ref));
    if(!r) {fputs("out of space\n", stderr); abort(); }
    r->next = sp->reflist;
    r->lineno = lineno;
    r->flags = flags;
    sp->reflist = r;
}


/* print the references
* sort the table alphabetically
* then flip each entry's reflist to get it into forward order
* and print it out
*/
/* aux function for sorting */
static int
symcompare(const void *xa, const void *xb) {
    const struct symbol *a = xa;
    const struct symbol *b = xb;
    if(!a->name) {
        if(!b->name) return 0;
        return 1;
    }
    /* both empty */
    /* put empties at the end */
    if(!b->name)
        return -1;
    return strcmp(a->name, b->name);
}


void
printrefs() {
    struct symbol *sp;
    qsort(symtab, NHASH, sizeof(struct symbol), symcompare); /* sort the symbol table */
    for(sp = symtab; sp->name && sp < symtab+NHASH; sp++) {
        char *prevfn = NULL;
        /* reverse the list of references */
        struct ref* rp = sp->reflist;
        struct ref* rpp = 0;  /* previous ref */
        struct ref* rpn;      /* next ref */
        do {
            rpn = rp->next;
            rp->next = rpp;
            rpp = rp;
            rp = rpn;
        } while(rp);
        /* now print the word and its references */
        printf("%10s", sp->name);
        for(rp = rpp; rp; rp = rp->next) {
            printf(" %d", rp->lineno);
        }
        printf("\n");
    }
}