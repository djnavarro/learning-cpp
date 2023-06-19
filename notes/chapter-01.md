---
title: "1: A crash course in C++ and the standard library"
---

[Back to top](index.html)

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

## Compiling the hello world program

That's all well and good, but I can't do anything useful with this until I compile it, and for that to happen I need a C++ compiler. As it happens I already have g++ on my system, but -- for no particular reason -- I've decided to use clang. Installing clang on Ubuntu is pretty straightforward:

``` bash
sudo apt install clang
```

Now that I have a compiler, I need to actually compile it. Here's the command:

``` bash
clang++ -std=c++20 helloworld.cpp -o helloworld
```

The `-std=c++20` flag tells clang what version of C++ I'm using, and the `-o` flag is used to specify the output file. 

In practice, this isn't the commmand I actually use. I don't want my binaries to build into in the same folder as my source code, so I keep all the source code in `src` and the binaries in `bin`. So the command would actually look like this:

```bash
clang++ --std=c++20 ./src/helloworld.cpp -o ./bin/helloworld
```

As a side benefit, structuring the project this way makes it much easier to avoid accidentally commiting binary files to the git repository. All I have to do is add the `bin` folder to my `.gitignore` file. Fantastic. 

That being said, I don't actually want to type this command for every source file. Instead, because I'm a fundamentally lazy person, I've written a `Makefile` that takes care of that for me, and also renders the markdown files to html. So really the only command I ever use is simply:

```bash
make
```

Anyway, once the source has been compiled, I can invoke the executable at the terminal like so:

``` bash
./bin/helloworld
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

- `std::cout` refers to "standard out" (stdout), basically the place where we write output to the console. The metaphor used in the book is to think of it as a "chute" where you toss text.
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

## Variables, types, and operators

The next part of the chapter walks you through variables, operators, types, and so on. Most of this feels very familiar and standard. Yes, C++ is strongly typed and requires variable declaration. This I know. I've gotten quite used to writing C++ code like this:

``` cpp
// declares variables but does not initalise
int a;
double b;
bool c;

// declares and initialises variables
// (this uses "uniform initialisation" syntax)
int x = 2;
double y = 2.54; 
bool z = true;
```

Operators generally feel familiar from other languages. One thing I've missed while working in R is the increment and decrement operators, `++` and `--`. I have to admit I love these:

``` cpp
// increment and decrement with + and -
x = x + 1;
y = y - 1;

// this is the same
x++
y--
```

## Casting and coercion

The book gives this as example code. The idea being that you should be able to reason through the steps that the program is following, what cast operations are taking place, and thereby predict what it will print out at the end.

``` cpp
// typecasting.cpp
#include <iostream>

int main() {
    // variable declarations
    int someInteger;
    short someShort;
    long someLong;
    float someFloat;
    double someDouble;

    // some operations that involve casts
    someInteger = 256;
    someInteger++;
    someShort = static_cast<short>(someInteger);
    someLong = someShort * 10000;
    someFloat = someLong + 0.785f;
    someDouble = static_cast<double>(someFloat) / 100000;

    // print output and return
    std::cout << someDouble << std::endl;
    return 0;
}
```

Okay, I'll give it a go. Stepping through it line by line...

- We start out with a signed 32 bit integer `someInteger` which has value 256. 
- The `++` operator increments this to 257. 
- We then use `static_cast()` to cast it to a signed 16 bit integer and store this as `someShort`. 
- In the next line we're multiplying by 10000, which gives us an answer of 2570000. That's too large a number to store as a 16 bit integer, but there's an implicit cast happening here (called coercion). The `someLong` variable is typed as a long integer (also 32 bits) so no explicit cast is needed, and the result is stored as a long integer with value 2570000.
- The next line also involves an implicit cast. We're adding a float (`0.785f`) to a long integer and storing the result as a float. So `someFloat` has value 2570000.785.
- Finally, we explicitly cast `someFloat` to a double precision floating point number, divide it by 100000, and assign the result to `someDouble`. That gives us a value of 25.70000785

We've lost a little precision in the printed output, however, because the program prints 25.7 to stdout.