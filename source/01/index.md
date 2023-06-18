---
title: "1: A crash course in C++ and the standard library"
---

[Back to top](../index.html)

## The hello world program

As always, we start with a "hello world" program. Here's the source:

``` cpp
// helloworld.cpp
#include <iostream>

int main() {
    std::cout << "Hello cruel world" << std::endl;
    return 0; 
}
```

That's all well and good, but I can't do anything useful with this until I compile it, and for that to happen I need a C++ compiler. As it happens I already have g++ on my system, but -- for no particular reason -- I've decided to use clang. Installing clang on Ubuntu is pretty straightforward:

``` bash
sudo apt install clang
```

Now that I have a compiler, I need to actually compile it. Here's the command:

``` bash
clang++ -std=c++20 helloworld.cpp -o helloworld
```

The `-std=c++20` flag tells clang what version of C++ I'm using, and the `-o` flag is used to specify the output file. Since I don't want to commit any binaries to my git repo, I'll add `helloworld` to the `.gitignore` file. Fantastic. 

From this point, I can invoke the executable at the terminal quite simply:

``` bash
./helloworld
```

And out pops the "Hello cruel message" at the console. Excellent. The basics are working. 

## Notes on the hello world program

Thankfully, I've written enough C++ code in the past that nothing about this surprises me. A few very basic syntactic notes in case I ever happen to share this with someone else coming from R.

- Comments in C++ are specified using `//`
- Lines must end with the semicolon `;`
- The `main()` function is special: that's the entry point to your program. This is the function that gets called whenever you invoke the executable at the command line.
- Unlike R, C++ is strongly typed, so when you define a function you must specify the output type: so in this case I write `int main() { // blah }` to specify that the output is an integer
- C++ uses namespaces. In R you often see namespaces as package names (e.g., `dplyr::filter`), and `::` functions similarly here. When I write `std::cout`, I'm roughly saying "cout, which lives in the std namespace". 
- The `#include` line is a "preprocessor directive", used to specify meta-information about the program. In this case, it's telling the preprocessor to take everything in the `<iostream>` header file and make it available to the program. Without it, I can't do any input/output 
- In theory, since this is C++20, I could have written `import <iostream>;` instead of using the `#include` preprocessor directive. This is because C++20 supports for modules. I'm being a bit old-fashioned here.

Going a little deeper: 

- `std::cout` refers to "standard out", basically the place where we write output to the console. The metaphor used in the book is to think of it as a "chute" where you toss text.
- The `<<` operator is used to "toss data into the chute", so `std::cout << "hello"` passes the text string `"hello"` to the standard output. As the helloworld program illustrates, you can concatenate multiple `<<` operations
- `std::endl` represents the end-of-line. 

If you don't particularly want to namespace every command, as per `std::cout`, you can tell the compiler to make the names in a particular namespace available  with a `using` directive (not dissimilar to calling `library()` in R). So I could have written my helloworld program like this:

``` cpp
// helloworld-using.cpp
#include <iostream>

using namespace std;

int main() {
    cout << "Hello cruel world" << endl;
    return 0; 
}
```

In general though it's not a good idea because that leads to namespace conflicts pretty quickly.