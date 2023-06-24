---
title: "2: Working with strings and string views"
---

[Back to top](index.html)


## C-style strings

The chapter begins with a discussion of strings in C. I understand why the book does this, but C-style strings are terrible and I want to make it a life goal never to use them again. In C, a string is literally an array of characters with a special `NUL` character (written `'\0'`) occupying the final slot. The string `"danielle"` is nothing more than a character array with values `{'d', 'a', 'n', 'i', 'e', 'l', 'l', 'e', '\0'}`. It's "fine", but only in the  everything-is-on-fire-dog-holding-a-cup-of-coffee-saying-this-is-fine sense of the term. It's especially horrible because the nul-terminator character is not included in the length of the string, and so you have to keep remembering that the length of every string is always +1 character longer than what it looks like. This leads to annoying code like this:

``` cpp
// append-c-strings.cpp
#include <iostream>
#include <cstring>

char* paste_strings(const char* str1, const char* str2, const char* str3) {
    const unsigned long len1 { std::strlen(str1) };
    const unsigned long len2 { std::strlen(str2) };
    const unsigned long len3 { std::strlen(str3) };
    char* out { new char[len1 + len2 + len3 + 1] }; 
    std::strcpy(out, str1);
    std::strcat(out, str2);
    std::strcat(out, str3);
    return out;
}

int main() {
    std::cout << paste_strings("I", "hate", "this") << std::endl;
    return 0;
}
```

```
Ihatethis
```

I really, really do. 

## String literals

Next the book turns to string literals. It starts by defining terms: the terms "string literal" just refers to the actual string value itself, rather than the variable. So `"cat"` is a string literal. 

### Literal pooling

String literals pose different issues for languages than other kinds of literals because there's an incredibly large number of possible string literals, and a single string literal can be quite large. C++ (much like R, actually) does the smart thing from a memory perspective by having **literal pooling**. String literals are stored in read-only memory, which allows the compiler to optimise memory usage: every use of the `"cat"` string literal (or a string literal containing the entire Treaty of Westphalia) is treated as a reference to the same location in memory. That way you can use the same string over and over without wasting memory.

That all makes sense but this is where things become tricky. You can technically assign a string literal to a variable but string literal pooling produces weirdness. Formally a string literal of length $n$ is an array of $n$ `const char` types, but (for backward compatibility, apparently) the compiler doesn't enforce the implicit `const` in this context:

``` cpp
char* ptr { "cat" }; // string literal is assigned to a variable
ptr[1] = "o";        // the behaviour here is undefined
```

A slightly safer thing to do here is to explicitly use the `const` keyword. In this case, the compiler will explicitly recognise that we're trying to modify a `const` and throws an error:

``` cpp
const char* ptr { "cat" }; // string literal is assigned to a variable
ptr[1] = "o";              // compiler throws error because you can't change a const
```

The book has a few other details here, but I'm skipping them for now. 

### Escaping in string literals

As with most languages, string literals in C++ include escape sequences as use `\` as the way to escaping special characters. The book treats this as assumed knowledge, which probably makes sense becaus this isn't an introductory book and you're expected to have some prior coding experience before attempting to read it. But for what it's worth:

``` cpp
// string-escapes.cpp
#include <iostream>

int main() {
    const char* str { "Dear world,\nI should like to say \"hello\"." };
    std::cout << str << std::endl;
    return 0;
}
```

```
Dear world,
I should like to say "hello".
```

### Raw string literals

To make life a little easier, C++ also supports **raw string literals**, which do not support escape sequences and do not require escaping of quote marks. To open a raw string literal use `R"(`, and to close it use `)"`. Naturally, you cannot construct a raw string literal that actually contains `)"` as part of the string using this syntax. You can, however, include line breaks by literally typing "enter" when specifying the string. So, ugly as it is, this works:

``` cpp
// raw-string-literal.cpp
#include <iostream>

int main() {
    const char* str { R"(Dear world,
I too would like to say "hello".)" };
    std::cout << str << std::endl;
    return 0;
}
```

```
Dear world,
I too would like to say "hello".
```

Finally, yes, C++ does support an extended raw string literal syntax in pretty much exactly the way you'd hope, where you can adopt a user defined sequence to signal the opening and closing of the string. For instance, to use `**` as the delimiter for an extended raw string literal corresponding to `"cat"`, I'd write `R"**(cat)**"`. It looks clunky in this case, but it's super handy for regular expressions and various other situations. A simple example:

``` cpp
// extended-raw-string-literal.cpp
#include <iostream>

int main() {
    const char* str1 { R"**(Raw string literal containing "))**"};
    const char* str2 { R"%%(Raw string literal containing **)%%"};
    std::cout << str1 << std::endl;
    std::cout << str2 << std::endl;
    return 0;
}
```

```
Raw string literal containing ")
Raw string literal containing **
```

