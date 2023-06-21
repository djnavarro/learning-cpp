---
title: "1: A crash course in C++ and the standard library"
---

[Back to top](index.html)

## The hello world program

As is tradition in every computer science text, the book starts with a "hello world" program designed to highlight core behaviour of the language. Here's the source, modified -- per my own tradition -- to print a slightly modified message:

``` cpp
// helloworld.cpp
#include <iostream>

int main() {
    std::cout << "Hello cruel world" << std::endl;
    return 0; 
}
```

## Compiling helloworld.cpp

That's all well and good, but I can't do anything useful with this until I compile it, and for that to happen I need a C++ compiler. As it happens I already have g++ on my system, but -- for no particular reason -- I've decided to use clang. Installing clang on ubuntu is pretty straightforward:

``` bash
sudo apt install clang
```

Now that I have a compiler, I need to actually compile it. Here's the command:

``` bash
clang++ --std=c++20 helloworld.cpp -o helloworld
```

The `--std=c++20` flag tells clang what version of C++ I'm using, and the `-o` flag is used to specify the output file. 

In practice, this isn't the commmand I actually use. I don't want my binaries to build into in the same folder as my source code, so I keep all the source code in `src` and the binaries in `bin`. Additionally, I've done a bit of tinkering and installed clang 15, and I want to use that as my compiler rather than clang 14 (which is what ubuntu ends up installing with the command above). I could tinker with links to set my default clang to version 15, but at some level I think I prefer the command to explicitly specify the compiler version, so my command would actually look like this:

```bash
clang++-15 --std=c++20 ./src/helloworld.cpp -o ./bin/helloworld
```

As a side benefit, structuring the project this way makes it much easier to avoid accidentally commiting binary files to the git repository. All I have to do is add the `bin` folder to my `.gitignore` file. Fantastic. 

That being said, I don't actually want to type this command for every source file. Instead, because I'm a fundamentally lazy person, I've written a `Makefile` that takes care of that for me, and also renders the markdown files to html. So really the only command I ever use is simply:

```bash
make
```

Anyway, once the source has been compiled, I can invoke the executable like so:

``` bash
./bin/helloworld
```

And out pops the message at the terminal:

```
Hello cruel world
```

Excellent. The basics are working. 

## Notes on helloworld.cpp

Thankfully, I've written enough C++ code in the past that nothing about this surprises me. A few very basic syntactic notes in case I ever happen to share this with someone else coming from R.

- Comments in C++ are specified using `//`
- Lines must end with the semicolon `;`
- The `main()` function is special: that's the entry point to your program. This is the function that gets called whenever you invoke the executable at the command line.
- Unlike R, C++ is strongly typed, so when you define a function you must specify the output type: so in this case I write `int main() { // blah }` to specify that the output is an integer
- C++ uses namespaces. In R you often see namespaces as package names (e.g., `dplyr::filter`), and `::` functions similarly here. When I write `std::cout`, I'm roughly saying "cout, which lives in the std namespace". 
- The `#include` line is a "preprocessor directive", used to specify meta-information about the program. In this case, it's telling the preprocessor to take everything in the `<iostream>` header file and make it available to the program. Without it, I can't do any input/output 
- In theory, since I'm notionally using C++20 in these notes, I could have written `import <iostream>;` instead of using the `#include` preprocessor directive. This is because C++20 introduced support for modules. I'm being a bit old-fashioned here, but for a good reason. When I installed clang with the command shown earlier, what I actually got on my system is clang version 14, and the support for modules in clang 14 is limited. I kind of don't want to get bogged down with those details here, so I'm going to use `#include` directives instead of trying to get modules working.

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

The nomenclature used in C++ when talking about changing variable types is a little more precise than it usually is in R. A **cast** is when you explicitly convert from one type to another. In contrast, the term **coercion** is used to describe an implicit cast. 

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
- We then use `static_cast()` to explicitly cast it to a signed 16 bit integer and store this as `someShort`. 
- In the next line we're multiplying by 10000, which gives us an answer of 2570000. That's too large a number to store as a 16 bit integer, but because the output variable `someLong` is typed as a long integer (also 32 bit), coercion takes place. The output is cast implicitly to long there's an implicit cast happening here (called coercion), and the result is stored as a long integer with value 2570000.
- The next line also involves coercion rather than an explicit cast. We're adding a float (`0.785f`) to a long integer and storing the result as a float. So the output `someFloat` has value 2570000.785.
- Finally, we explicitly cast `someFloat` to a double precision floating point number, divide it by 100000, and assign the result to `someDouble`. That gives us a value of 25.70000785

We've lost a little precision in the printed output, however, because the program prints 25.7 to stdout.

## Enumerated types

Next up: "strongly typed enumerated types". **Enumerated types** are essentially the C++ version of R factors, or Python dictionaries I guess. The key idea is to have a discrete set of labelled values. Internally the objects are encoded as integer values, but those numbers are masked so you can't do silly things with them. So, for example I could encode gender (somewhat crudely) with an enumerated type as follows:

``` cpp
enum class Gender { male, female, nonbinary, other, unspecified };
```

To declare and initialise some gender variables I would do this:

``` cpp
enum class Gender { male, female, nonbinary, other, unspecified };
Gender danielle_gender { Gender::female };
Gender benjamin_gender { Gender::male };
```

The internal coding is revealed by this program:

``` cpp
// enumerated-types.cpp
#include <iostream>

int main() {
    enum class Gender { male, female, nonbinary, other, unspecified };
    Gender danielle_gender { Gender::female };
    Gender benjamin_gender { Gender::male };

    std::cout << "Danielle gender: " << static_cast<int>(danielle_gender) << std::endl;
    std::cout << "Benjamin gender: " << static_cast<int>(benjamin_gender) << std::endl;
    return 0; 
}
```

When we run this one, the output looks like this:

```
Danielle gender: 1
Benjamin gender: 0
```

## Structs

Moving along. The next kind of objects the book considers are **structs**, which allow you to group one or more existing objects (which may themselves be of different types) into a new type. They are, more or less, the C++ analog of lists in R. 

It's not uncommon for C++ code to define a class within a header file which can be made available to the program by an `#include` directive (or, in C++20, imported as a module). Sticking reasonably closely to what is in the book here, I'll write a header file that defines an `Employee` class:

``` cpp
// employee.h
struct Employee {
    char firstInitial;
    char lastInitial;
    int employeeNumber;
    int salary;
};
```

In the book, the code is a little more elaborate because it explicitly defines a module, but since my compiler has incomplete support for C++20 features, I'm keeping it simple. 

A thing to note here is that C++ doesn't supply a string type out of the box, which is -- I would imagine -- the reason why this class sidesteps that awkwardness and encodes only the `firstInitial` and `lastInitial` as fields in an `Employee` struct. By doing that we can get away with using a char here. There are of course ways to specify strings, but it's a bit tangential to the discussion. 

Anyway, the key thing is that we access the fields of a struct using `.` as the code below illustrates:

``` cpp
Employee danielle;
danielle.firstInitial = 'D';
danielle.lastInitial = 'N';
danielle.employeeNumber = 69;
danielle.salary = 123456;
```

To see it in action we can write a short program. Again we have a bit of an issue because the book uses C++20 features that my compiler doesn't support. Specifically, it uses the new C++20 `<format>` module to handle printing, which I don't have access to. Rather than mess about with compilers to get the new hotness working or introduce an external dependency, I decided to use stringstream objects provided by the `<sstream>` header file. 

So my program looks like this:

``` cpp
// employee.cpp
#include <iostream>
#include <sstream>
#include "employee.h"

int main() {
    // define the employee record
    Employee danielle;
    danielle.firstInitial = 'D';
    danielle.lastInitial = 'N';
    danielle.employeeNumber = 69;
    danielle.salary = 123456;

    // write to stdout
    std::stringstream ss;
    ss.str("");
    ss << "Employee: " << danielle.firstInitial << danielle.lastInitial;
    std::cout << ss.str() << std::endl;

    ss.str("");
    ss << "Employee number: #" << danielle.employeeNumber;
    std::cout << ss.str() << std::endl;

    ss.str("");
    ss << "Employee salary: $" << danielle.salary;
    std::cout << ss.str() << std::endl;

    return 0;
}
```

When I run this program I get this as output:

```
Employee: DN
Employee number: #69
Employee salary: $123456
```

That all seems to make sense. What's next?

## Digression: Poisson variates

Looking ahead, it seems like the book is about to start discussing conditional branching, functions, loops, and all that good stuff. Fair enough. But conditional branching based on testing some boolean expression is never much fun unless you have a something meaningful to test. Ideally you'd have something where the conditional might evaluate differently. So, since we're all statisticians here (I mean, it's just me here and I'm a statistician), this feels like a good moment to divert from the text and write some code that generates Poisson random numbers. To do this I'll use `<random>`:

``` cpp
// poisson-sample.cpp
#include <iostream>
#include <random>

int main() {
    // set seed using time, define PRNG with Mersenne Twister
    long unsigned int seed = static_cast<long unsigned int>(time(0));
    std::mt19937_64 mersenne {seed};

    // sample_poisson() draws from Poisson(4.1) and returns an integer.
    std::poisson_distribution<int> sample_poisson(4.1);

    // draw poisson sample (passing the PRNG as argument) and write to stdout
    std::cout << "poisson sample: " << sample_poisson(mersenne) << std::endl;
    return 0;
}
```

Here's what happens when I repeatedly invoke the `sample-poisson` program at the terminal:

```
poisson sample: 2
poisson sample: 6
poisson sample: 2
poisson sample: 5
poisson sample: 2
poisson sample: 4
poisson sample: 4
```

You get the idea.

## Conditionals

Okay, back to the development of ideas in the book. Next up is conditional branching, which comes in a few different forms. 

### `if/else` statements

the basic syntax is deeply familiar to anyone who has programmed in... pretty much any language I guess. The first example in the book shows a cascading if statement like this:

``` cpp
if (value > 4) {
    // do something
} else if (value > 2) {
    // do something else
} else {
    // do something else
}
```

However, the nice thing about having some code to sample random numbers is that I can write something a little less boring here. Here's a small program that samples a Poisson random variate, and prints a message to the terminal that adds a little comment about where the sample falls relative to the distribution mode:

``` cpp
// poisson-conditional.cpp
#include <iostream>
#include <random>

int main() {
    // define a poisson distribution
    long unsigned int seed = static_cast<long unsigned int>(time(0));
    std::mt19937_64 mersenne {seed};
    std::poisson_distribution<int> sample_poisson(4.1);

    // sample a value and write first part of message
    int value = sample_poisson(mersenne);
    std::cout << "The sampled value of " << value;

    // remainder of message depends on the value
    if (value == 4) {
        std::cout << " is the modal value." << std::endl;
    } else if (value < 4) {
        std::cout << " is below the mode." << std::endl;
    } else {
        std::cout << " is above the mode." << std::endl;
    }
    return 0;
}
```

Again, here's some output I get when I repeatedly invoke the `poisson-conditional` function:

```
The sampled value of 11 is above the mode.
The sampled value of 4 is the modal value.
The sampled value of 6 is above the mode.
The sampled value of 5 is above the mode.
The sampled value of 4 is the modal value.
The sampled value of 3 is below the mode.
```

Exciting times in the life of Danielle. 

### `if-else` statements with initialisers 

At this point the book introduces a concept I wasn't familiar with. You can include an initialiser within an if/else block, where you can define variables that exist only within the scope of that block. The basic syntax looks like this:

``` cpp
if (<initialiser>; <conditional_expression>) {
    <if_body>
} else if (<else_if_expression>) {
    <else_if_body>
} else {
    <else_body>
}
```

The book doesn't give an example of this at this early stage because, rather sensibly, the author hasn't gone down the weird little digression into Poisson variates that I did. But, having done so, it's easy to write a variant of the previous program that creates the random value within the initialiser:

``` cpp
// poisson-initialised-conditional.cpp
#include <iostream>
#include <random>

int main() {
    // define a poisson distribution
    long unsigned int seed = static_cast<long unsigned int>(time(0));
    std::mt19937_64 mersenne {seed};
    std::poisson_distribution<int> sample_poisson(4.1);

    // conditional statement with an initialiser
    if (int x = sample_poisson(mersenne); x == 4) {
        std::cout << x << " is the modal value." << std::endl;
    } else if (x < 4) {
        std::cout << x << " is below the mode." << std::endl;
    } else {
        std::cout << x << " is above the mode." << std::endl;
    }
    return 0;
}
```

In this code, the variable `x` exists only within the scope of the if/else statement. Here's a few results from running this program several times:

```
7 is above the mode.
4 is the modal value.
3 is below the mode.
8 is above the mode.
```

### `switch/case` statements

``` cpp
// gender-switch.cpp
#include <iostream>

int main() {
    enum class Gender { male, female, nonbinary, other, unspecified };
    Gender danielle_gender { Gender::female };

    std::cout << "Danielle's gender is ";
    switch (danielle_gender) {
        case Gender::female:
        case Gender::male:
            std::cout << "within the gender binary" << std::endl;
            break;
        case Gender::nonbinary:
        case Gender::other:
            std::cout << "outside the gender binary" << std::endl;
            break;
        default:
            std::cout << "unspecified" << std::endl;
    }
}
```

When this code is executed, we get this:

```
Danielle's gender is within the gender binary
```

The reason this happens is due to **fallthrough** behaviour. When a `case` expression that matches the `switch` expression is reached, all subsequent statements are executed until a `break` statement is reached. So even though there's nothing to execute immediately following the `Gender::female` case expression, there's no `break` there either, so the flow "falls through" to the next case. In other words, inthis code male and female genders will both produce "within the gender binary" as the printed message, whereas nonbinary and other genders will produce "outside the gender binary" as the message. If the gender is unspecified, none of the case expressions will match against the switch expression, so the default message at the end is printed. 

Just like with `if/else` blocks, `switch` blocks can use initialisers:

``` cpp
// gender-switch-2.cpp
#include <iostream>

int main() {
    enum class Gender { male, female, nonbinary, other, unspecified };

    switch (Gender x { Gender::unspecified }; x) {
        case Gender::female:
        case Gender::male:
            std::cout << "Within the gender binary" << std::endl;
            break;
        case Gender::nonbinary:
        case Gender::other:
            std::cout << "Outside the gender binary" << std::endl;
            break;
        case Gender::unspecified:
            std::cout << "Gender unspecified" << std::endl;
    }
}
```

The output here is:

```
Gender unspecified
```

### Conditional operator

You can also use `?` and `:` to create a conditional expression. The general syntax is

``` cpp
<condition> ? <value_if_condition_true> : <value_if_condition_false>;
```

Here's a simple example:

``` cpp
std::cout << ((p_value < .05) ? "reject null" : "retain null");
```

Cool Continuing on.

## Logical expressions

There's not much to say here. C++ operators are mostly the same as anywhere else:

- Inequality operators: `>`, `>=`, `<`, `<=`
- Equality operator: `==`
- Not-equal operator: `!=`
- Not operator: `!`
- And operator: `&&`
- Or operator: `||`

Absolutely riveting content, honestly. I'm on the edge of my seat. About the only thing worth mentioning is that C++ uses **short circuit** rules to evaluate logical expressions. A logical expression is evaluated only until the result is guaranteed. Later steps are not evaluated. For instance:

``` cpp
bool result { boolean_eval_to_false || true || boolean_is_irrelevant }
```

In this case `boolean_eval_to_false` is evaluated (returning `false`). That doesn't guarantee the final result though, because the expressions are joined by `||`. However, the next expression is `true`, which means that `result` must equal `true`. Consequently the expression as a whole short-circuits, and `boolean_is_irrelevant` is never evaluated. This trick is used a lot for efficiency: if you put the computationally cheap tests first and the computationally expensive tests last, you may be able to avoid ever having to perform the expensive tests.

## Functions

So far all the programs I've looked at have included a `main()` function and nothing else. Every time I've declared my `main()` function the code has looked like this:

``` cpp
int main() {
    // meaningful content here
    // return to user
    return 0;
}
```

By writing the declaration in this way we are asserting the `main()` function always returns an `int` value, and indeed when we look at the `return` statement at the end, it always does. Admittedly, I've never used this return value for anything, but it's a requirement in C++ that the `main()` function return an integer. 

Other functions aren't constrained in the same way, and in fact C++ functions don't have to return anything if the only reason to call the function is for its side effects. To do that we set the output type to `void`. Here's an example: 


``` cpp
// char-code.cpp
#include <iostream>

void print_ascii_code(char c) {
    std::cout << c << " has integer code " << static_cast<int>(c) << std::endl;
}

int main() {
    print_ascii_code('d');
    print_ascii_code('a');
    print_ascii_code('n');
    print_ascii_code('i');
}
```

When I run this program I get this:

```
d has integer code 100
a has integer code 97
n has integer code 110
i has integer code 105
```

(The integers correspond to the ASCII codes for each character).

### Useful tidbits about functions

1. It's possible to use the `auto` keyword to ask the compiler to figure out the output type for you. So, for instance, this works and returns an integer:

``` cpp
auto add_numbers(int x, int y) {
    return x + y;
}
```

2. Every function has a local variable `__func__` that contains the function name. As noted in the book, this can be helpful for logging purposes. Here's a slightly expanded version of the example used in the book:

``` cpp
// add-with-logging.cpp
#include <iostream>

int add_numbers(int x, int y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + y;
}

int main() {
    int a = 1;
    int b = 2;
    int c = 3;
    int sum1 = add_numbers(a, b);
    int sum2 = add_numbers(sum1, c);
    std::cout << "result: " << sum2 << std::endl;
    return 0;
}
```

When this executes, we see the following written to stdout:

```
add_numbers(1, 2)
add_numbers(3, 3)
result: 6
```

3. Function overloading is permitted: you can write multiple functions that have the same name but have different signatures. Note that in this case that means the function arguments must be different. It's not sufficient merely to declare a different output type. As an example, we could use this to define addition functions that accept both integers and doubles, returning integers only if both arguments are integers:

``` cpp
// add-with-overloading.cpp
#include <iostream>

int add_numbers(int x, int y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + y;
}

double add_numbers(double x, double y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + y;
}

double add_numbers(int x, double y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return static_cast<double>(x) + y;
}

double add_numbers(double x, int y) {
    std::cout << __func__ << "(" << x << ", " << y << ")" << std::endl;
    return x + static_cast<double>(y);
}


int main() {
    int int_a = 1;
    int int_b = 2;
    double dbl_c = 3.45;
    double dbl_d = 6.78;

    int int_ab = add_numbers(int_a, int_b);
    double dbl_cd = add_numbers(dbl_c, dbl_d);
    double dbl_abcd = add_numbers(int_ab, dbl_cd);
    std::cout << "result: " << dbl_abcd << std::endl;
    return 0;
}
```

Running this code produces the following output:

```
add_numbers(1, 2)
add_numbers(3.45, 6.78)
add_numbers(3, 10.23)
result: 13.23
```

It works, but it can be a bit risky to abandon type stability. In this case it's quite easy to reason about the output type of a call to `add_numbers()` simply by inspecting the input types, but in my experience things go bad quite quickly when you don't take type stability seriously.

4. You can specify attributes like `[[maybe_unused]]` to indicate that, for instance, a function argument might not be used. There are other attributes like `[[deprecated]]` for functions, and -- though I skipped that bit earlier, attributes like `[[fallthrough]]` for switch statements. To be honest, at this point I'm only lightly reading the sections on attributes.

## Arrays

At this point, the book moves to a discussion of arrays. Specifically, it first talks about old-school C-style arrays before moving onto the C++ `std::array` type. Given that I try my very best never to use C-style arrays in my C++ code, I think I'll skip straight to `std::array` in these notes. C++ style array objects are provided by the `<array>` library. The size of the array must be specified in advance, and all elements of the array must have the same type. Indexing starts at 0. 

Here's a simple example:

``` cpp
// array-danielle.cpp
#include <iostream>
#include <array>

int main() {
    std::array<char, 8> danielle = { 'D', 'a', 'n', 'i', 'e', 'l', 'l', 'e' };
    std::cout << "Danielle has " << danielle.size() << " letters." << std::endl;
}
```

The nice thing here is that C++ arrays have a `.size()` method which makes it easy to do all sort of operations with them. The current example is a bit minimal: I'm just using it to count the letters in my name. Speaking of which, here's the output:

```
Danielle has 8 letters.
```

## Vectors

In many situations you don't know in advance how many elements you need to store. To help with that, C++ provides the `std::vector` type via the `<vector>` library. Vectors are flexible containers that can grow and shrink at run time, so you don't need to specify how long they will be and you don't have to faff about with memory managemtn. Because vectors are more useful than arrays (in my experience) I'll give an example that roughly mirrors a situation I've had to deal with in real life: when you're collecting observations and you don't know in advance how many observations might arise. In real applications the source of this variation usually comes from the outside source, but for this example I'll rely on my new best friend, the [`<random>`](https://cplusplus.com/reference/random/) library.

I'll switch to statistical notation here. In the code below I assume the number of observations $n$ follows a Poisson distribution with rate parameter $\lambda$:

$$
n \sim \mbox{Poisson}(\lambda)
$$

and I'll assume each value $v$ is a Beta variate between 0 and 1:

$$ 
v \sim \mbox{Beta}(a, b)
$$

Annoyingly, the `<random>` library does not supply functions for beta distributions out of the box but happily I have not forgotten my basic variate relations. To sample $v$ from a Beta distribution I can draw two Gamma variates $x$ and $y$ as follows:

$$
\begin{array}{rcl}
x & \sim & \mbox{Gamma}(a, 1) \\
y & \sim & \mbox{Gamma}(b, 1)
\end{array}
$$

and set $v = x/(x + y)$. Problem solved. 

Anyway, here's the code:


``` cpp
// beta-sample.cpp
#include <iostream>
#include <vector>
#include <random>

void print_message(double value, double a, double b) {
    std::cout << "beta(" << a << "," << b << ") sample: " << value << std::endl;
}

std::vector<double> draw_betas(double rate, double a, double b) {
    // distributions
    std::gamma_distribution<double> gamma_a(a, 1.0);
    std::gamma_distribution<double> gamma_b(b, 1.0);
    std::poisson_distribution<int> poisson(rate);

    // mersenne twister numbers
    std::random_device rd;
    std::mt19937 mt(rd());

    // draw poisson sample to determine number of betas
    int n = poisson(mt);

    // draw beta samples and return
    std::vector<double> beta_variates {};
    double x, y;
    for (int i = 0; i < n; i++) {
        x = gamma_a(mt);
        y = gamma_b(mt);
        beta_variates.push_back(x / (x + y));
    }
    return beta_variates;
}

int main() {
    const double a = 2.0; // shape parameter 1
    const double b = 1.0; // shape parameter 2
    const double rate = 2.4; // rate for poisson dist

    // draw samples
    std::vector<double> betas = draw_betas(rate, a, b);

    // print messages and return
    std::cout << "collected " << betas.size() << " samples" << std::endl;
    for (int i = 0; i < betas.size(); i++) {
        print_message(betas[i], a, b);
    }
    return 0;
}
```

Technically I'm getting slightly ahead of the book here because it hasn't talked about loops yet, but whatever. A `for` loop is more or less the same thing everywhere. 

Anyway, let's take a quick look at some output. Sometimes this code creates a `betas` vector containing four values:

```
collected 4 samples
beta(2,1) sample: 0.293596
beta(2,1) sample: 0.920161
beta(2,1) sample: 0.971502
beta(2,1) sample: 0.502786
```

Sometimes the `betas` vector has no values:

```
collected 4 samples
```

Sometimes we sample two values, so the output looks like this:

```
collected 2 samples
beta(2,1) sample: 0.729145
beta(2,1) sample: 0.414129
```

And so on.

## Pairs and optionals

At this point the book discusses a couple of topics that I'm not going to bother writing my own code for:

- C++ provides a `std::pair` class via the `<utility>` library. It's used to group two values that can be of different types. It has methods `.first()` and `.second()` to extract individual elements. I can imagine this is useful as a tool for representing name-value pairs, for instance. 

- There is an `std::optional` class provided by `<optional>` and can either hold a value of a specific type, or nothing. There's a method `.has_value()` that returns a boolean specifying whether a value has een stored, and a `.value()` method that returns the stored value. Apparently you can also use the dereferencing operator to do the same thing, so if we have an optional object called `maybe` then `maybe.value()` and `*maybe` do the same thing. There's also a `.value_or()` method that returns the stored value if one exists, or else returns whatever is passed to `.value_or()`. The obvious application that comes to mind for me is that optional objects could be used to handle missing values in statistical contexts.

## Structured bindings

Structured bindings were introduced in C++17 and allow you to declare and assign multiple variables at once, using values taken from an appropriate object: arrays, structs, pairs, and tuples all work for this. The main use case I can see for this that it provides a clean way to allow function to return multiple values. On the function side, you wrap the outputs into an appropriate structure (the example below uses a tuple). Then when the function is called elsewhere, use the structured bindings syntax to assign the elements of the wrapping structure (e.g., the tuple) directly into their own variables. for example, let's suppose I've written `some_function()` that returns a 3-tuple. I can assign the elements of that tuple to variables `x`, `y` and `z` like so:

``` cpp
auto [x, y, z] = some_function();
```

Back in my MATLAB days I used to do this all the time. In R it's slightly trickier to do that unless you're using specialised packages that provide multiple assignment functionality. Anyway, here's a contrived example:

``` cpp
// structured-binding-asl.cpp
#include <iostream>
#include <tuple>
#include <string>

// somewhat absurd function used to illustrate the point
std::tuple<int, char, std::string> asl() {
    return {45, 'F', "Sydney"};
}

int main() {
    // use structured bindings to declare and assign multiple 
    // variables from the output returned by the function call
    auto [age, sex, location] = asl();

    // messages
    std::cout << "age: " << age << std::endl;
    std::cout << "sex: " << sex << std::endl;
    std::cout << "location: " << location << std::endl;
    return 0;
}
```

For the sake of keeping these notes family-friendly I have restricted myself to "a/s/l", even though the term "structured bindings" itself suggests the possibility of a rather more... expansive... query that might be adopted here. 

Aaaaaaanyway... the results:

```
age: 45
sex: F
location: Sydney
```

## Loops

The book now turns to loops. I'm trying very hard not to start skimming in case there's something secific to C++ that I need to know, but honestly this all feels very, very familiar. To keep my boredom to a minimum I'll try to find examples that I find entertaining. 

### The `while` loop

First up, a **while** loop calculating the sequence of integers $x_1, x_2, \ldots$

$$
x_{n+1} = \left\{ 
\begin{array}{rl} 
x_n/2 & \mbox{if $x_n$ is even} \\    
3x_n +1 & \mbox{if $x_n$ is odd} \\  
\end{array}  
\right.
$$

terminating at the first $n$ such that $x_n = 1$. This is of course an implementation of the [collatz conjecture](https://en.wikipedia.org/wiki/Collatz_conjecture) which proposes that this collatz sequence, for every integer-valued choice of initial value $x_0$, eventually terminates in 1. Code:

``` cpp
// collatz.cpp
#include <iostream>

int main() {
    int value = 39;
    std::cout << value;
    while (value != 1) {
        value = (value % 2 == 0) ? (value / 2) : (3 * value + 1);
        std::cout << " -> " << value;
    }
    std::cout << std::endl;
    return 0;
}
```

The results for $x_0 = 39$, where I've manually added linebreaks:

```
39 -> 118 -> 59 -> 178 -> 89 -> 268 -> 134 -> 67 -> 
202 -> 101 -> 304 -> 152 -> 76 -> 38 -> 19 -> 58 -> 
29 -> 88 -> 44 -> 22 -> 11 -> 34 -> 17 -> 52 -> 26 -> 
13 -> 40 -> 20 -> 10 -> 5 -> 16 -> 8 -> 4 -> 2 -> 1
```

### The `do/while` loop

The `do/while` loop is inherently boring, but is very occasionally handy if it is important to ensure that the code block is executed at least once. This pattern makes sense when, for example, you might need to repeatedly check something until it produces valid output. In that situation a while loop does make sense, but you really have to run *at least* once test in order to validate... whatever it is you're trying to validate.

As a truly absurd example:

``` cpp
// validation-check.cpp
#include <iostream>
#include <ctime>

bool valid_time() {
    std::time_t elapsed = std::time(nullptr);
    bool is_valid = elapsed % 2 == 0;
    if (is_valid) {
        std::cout << elapsed << " seconds since the epoch" << std::endl;
    }
    return is_valid;
}

int main() {
    bool valid;
    int i = 0;
    do {
        i++;
    } while (!valid_time());
    std::cout << "attempts = " << i << std::endl;
    return 0;
}
```

This code checks the current time, measured in number of seconds since the unix epoch. If that number is even, it deems the time to be "valid" and prints the elapsed seconds to stdout. If that number is odd, it deems the time to be "invalid" and refuses to terminate the `do/while` loop. That leads to some entertaining behaviour. About half the time you'll get output like this where it succeeds the first time:

```
1687250594 seconds since the epoch
attempts = 1
```

But the other half of time the program fails about 200 million times before finally succeeding: 

```
1687250596 seconds since the epoch
attempts = 200744719
```

Suffice it to say, although the idea of using `do/while` loops to implement validation checks makes sense, this is... um... an unhinged example. But I found it funny so I ran with it.


### The `for` loop

One of the earlier examples gave an example of a `for` loop that was semi-serious, so I feel justified in being absurd again:

``` cpp
// na-na-hey-hey.cpp
#include <iostream>

int main() {
    for(int i = 0; i < 8; i++) { std::cout << "na "; }
    for(int i = 0; i < 3; i++) { std::cout << "hey "; }
    std::cout << "goodbye" << std::endl;
    return 0;
}
```

```
na na na na na na na na hey hey hey goodbye
```

### The range-based `for` loop

The range-based `for` loop iterates directly over the elements of a container. It works for a fairly wide range of possible containers: anything that has `.begin()` and `.end()` methods that return iterators will work. Example:

``` cpp
// array-iterator.cpp
#include <iostream>
#include <array>

int main() {
    std::array<int, 6> fib = { 1, 1, 2, 3, 5, 8 };
    for(int f : fib) { std::cout << f << std::endl; }
    return 0;
}
```

```
1
1
2
3
5
8
```

Note that in this code, at each step of the iteration the variable `f` stores a copy of the relevant element of `fib`. However, it's possible to do range-based `for` loops without making copies by using a reference variable. The book promises to discuss this later in the chapter.

## Initialiser lists

Initialiser lists are designed to make it easy to write functions that accept a variable number of arguments, and are provided by the `<initializer_list>` library. All values in an initialiser list must be the same type. Here's an example that computes the mean of an arbitrary number of double values:

``` cpp
// mean-value.cpp
#include <iostream>
#include <initializer_list>

double mean(std::initializer_list<double> values) {
    double tot = 0;
    for (double v : values) {
        tot += v;
    }
    return tot / values.size();
} 

int main() {
    double x_bar = mean({ 2.3, 1.5, 7.8, 11.0 });
    double y_bar = mean({ 102.5, 59.1, 98.2 });
    std::cout << "mean x: " << x_bar << std::endl;
    std::cout << "mean y: " << y_bar << std::endl;
    return 0;
}
```

```
mean x: 5.65
mean y: 86.6
```

## Strings

The book talks about strings next, but it's mostly a promissory note here. It mentions that the `std::string` type from `<string>` works more or less the way you'd expect for a string type. Here's a quick example:

```cpp
// simple-string.cpp
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::vector<std::string> name = { "Daniela", "Jasmine", "Navarro", "Bullock" };
    for(std::string n : name) { std::cout << n << std::endl; }
    return 0;
}
```

```
Daniela
Jasmine
Navarro
Bullock
```



