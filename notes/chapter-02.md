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

Next the book turns to string literals.