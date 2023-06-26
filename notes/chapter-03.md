---
title: "3: Coding with style"
---

[Back to top](index.html)

Chapter 3 focuses on the elements of good coding style. The short version is very familiar. At the beginning of the chapter the following themes are listed:

- Documentation
- Decomposition
- Naming
- Use of the language
- Formatting

## Documentation

I found the section on documentation interesting, because it focuses very heavily on code comments (which generally target developers maintaining or extending the code), whereas most of my experience with writing documentation targets users who need to call the code. In that sense it seems like there's a meaningful difference between **documentation for developers** and **documentation for users**. The chapter seems to focus more on the former than the latter: regular users don't look at the source code to work out how to interact with the public facing API, they look for tutorials, API reference pages, and so on. It's only the devs (which, could of course include anyone submitting a pull request) who read the code comments!

### Comments explain the things that are hard to extract from the code

With that in mind, one thing I found especially interesting is that the book advocates for a much more verbose commenting style than I typically see in the wild (either in C++ or R). Here's what I mean. The book uses the example of a `saveRecord()` function with this signature:

``` cpp
int saveRecord(Record& record);
```

There's no actual source code provided, but *maaaaaaaybe* someone reading the source code would work out that this function will throw an exception if `openDatabase()` has not yet been called. However, the most likely scenario is that it's a pain in the arse for the reader of the code -- per the fundamental law of programming that code is harder to read than to write -- so it's best to preface the source code with a comment like this:

``` cpp
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
int saveRecord(Record& record);
```

There are other things about this function that might not be obvious. Someone reading the code might notice that the `record` argument has type `Record&`: it's a reference to a non-const. A reader might wonder if that ought to be `const Record&`, so this should be explained:

``` cpp
// Parameters:
//    record: If the given record does not yet have a database 
//    ID, then the method modifies the record object to store
//    the ID assigned by the database     
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
int saveRecord(Record& record);
```

That makes a lot more sense. The `record` argument cannot be declared `const` because it's possible that the `saveRecord()` function will modify the original `Record` object to which it refers. 

As an aside, I'm genuinely delighted to see the author advocating that code comments preserve this level of detail. Over and over again I find myself reading through a code base where it is 100% clear to me that the developer thinks "oh this is obvious, you should just be able to read my code, it is totally self-documenting". This is almost *never* true. I've seen very little code that is truly self-documenting for a reader who is not the same person as the author. Of course, that doesn't mean every code base should be meticulously documented, it's more... if you document at the level where only future-you can easily read the code, then other people will be less inclined to interact with your code. That's a legitimate choice... the *vast* majority of my code on GitHub is like that because I'm not looking for other users. I wrote the code for myself, and I've documented it to exactly the level required to ensure that future-Danielle (who has similar skills and thought patterns to me, I presume!) will be able to make sense of it. 

### Sometimes a well-named class removes the need for a comment

Anyway, getting back on track, the book then asks the question of whether we should consider extending the documentation even further by explaining the `int` return type? We could, for example, do this:

``` cpp
// Parameters:
//    record: If the given record does not yet have a database 
//    ID, then the method modifies the record object to store
//    the ID assigned by the database  
// Returns: int
//    An integer representing the ID of the saved record
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
int saveRecord(Record& record);
```

It's pretty tempting to do this, because honestly that `int` isn't very comprehensible, and the reader would have to dig into the code a fair ways in order to make sense of it. However, a better approach would be to define a very simple `RecordID` class. Most likely, a `RecordID` object would simply store an integer, but the mere fact that we've defined the class and given it a comprehensible name ensures that the function signature of `saveRecord()` is quite a bit more comprehensible:

``` cpp
// Parameters:
//    record: If the given record does not yet have a database 
//    ID, then the method modifies the record object to store
//    the ID assigned by the database     
// Throws:
//    DatabaseNotOpenedException if the openDatabase() method 
//    has not been called yet
RecordID saveRecord(Record& record);
```

Plus, it's a little more future proof: the `RecordID` class could be extended later if need be.

### Your code is a lot more complex than you think it is

The next point the book makes about commenting is that comments within a function serve an important purpose too. My experience has been that programmers grossly underestimate the complexity of their own code, and grossly overestimate the degree to which a reader of their code shares "common ground knowledge" with them. The book -- perhaps pointedly, I can't tell? -- gives the example of insertion sort. A loooooooooooooot of programmers would write this and think the code is "self-documenting":

``` cpp
void sort(int data[], size_t size) {
    for (int i { 1 }; i < size; i++) {
        int element { data[i] };
        int j { i };
        while (j > 0 && data[j - 1] > element) {
            data[j] = data[j - 1];
            j--;
        }
        data[j] = element;
    }
}
```

The book has words of wisdom here:

> You might recognize the algorithm if you have seen it before, but a newcomer probably wouldn't understand the way the code works.

The implication here is that if you believe this code "doesn't need comments", what you're really saying is "newcomers can fuck off". There's, um, quite a bit of that attitude in the programming world. The implicit assumption here that "everybody knows insertion sort (because undergrad compsci classes almost always use sorting algorithms for pedagogical purposes)" functions as a kind of cultural shibboleth. It ensures that the world remains closed to everyone who arrived to programming from a non-traditional background and didn't take those classes. 

The book then goes on to offer the following as an example of better documentation:

``` cpp
// Implements the "insertion sort" algorithm. The algorithm separates the 
// array into two parts -- the sorted part and the unsorted part. Each 
// element, starting at position 1, is examined. Everything earlier in the
// array is in the sorted part, so the algorithm shifts each element over
// until the correct position is found to insert the current element. When
// the algorithm finishes with the last element, the entire array is sorted.
void sort(int data[], size_t size) {

    // Start at position 1 and examine each element
    for (int i { 1 }; i < size; i++) {
        // Loop invariant:
        //    All elements in the range 0 to i-1 (inclusive) are sorted

        int element { data[i] };
        int j { i }; // j is the position in the sorted part where element will be inserted

        // As long as the value in the slot before the current slot in the 
        // sorted array is higher than the element, shift values to the right
        // to make room for inserting element (hence the name, "insertion 
        // sort") in the correct position
        while (j > 0 && data[j - 1] > element) {
            data[j] = data[j - 1]; // invariant: elements in the range j+1 to i are > element
            j--; // invariant: elements in the range i to i are > element
        }

        // At this point the current position in the sorted array is *not* greater
        // than the element, so this is its new position
        data[j] = element;
    }
}
```

It's actually rather surprising to me that the book goes this far in arguing for detailed internal documentation. Not going to lie, it does make me happy, because I can look at the second version and immediately understand what the code does. The first version? Not so much. 

