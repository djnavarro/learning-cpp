---
title: "4: Designing professional C++ programs"
---

[Back to top](index.html)

## Chapter summary

The chapter focuses on the software design process. The first part of the of the chapter is focused on principles to consider when designing software:

- **Abstraction**: Write code that works in a more general scenarios that the immediate use case. Writing templates is a useful pattern for this (though I haven't gotten to those yet). It's a bit tricky working out how much to abstract though, since premature abstraction can be a mistake too. (I refuse to use the term "code smells" - it has always rubbed me the wrong way - but I guess that's one of those)
- **Code reuse**: Don't reinvent the wheel every time. Consider using code libraries written by others (assuming the licence allows it), or reuse code you've written. External libraries (e.g. [fmt](https://fmt.dev/)) are a little tricky for me right now because I haven't gotten to [CMake](https://cmake.org/) or [vcpkg](https://vcpkg.io/) yet, but the principles are familiar. The discussion around reuse is generally pretty nuanced, I think. For instance, it talks a lot about the pros and cons of taking a dependency on an external library, which is a refreshing change from a lot of the blanket "dependencies = bad" framing I see online sometimes.
- **Design from the beginning**: Fundamentally, the point is that if you're building software rather than writing a script, it's a good idea to spend time sketching out what you think the structure of that software is, *before* you start writing any code. 

The book then moves into talking about the practicalities of the design process. The goal is to produce a design document that specifies in advance how the software should work. This plan might start out as a basic sketch. As you put together the sketch you'll start fleshing out specific classes, their methods and fields, and the ways they interact. It's an iterative process: you might realise some parts of your plan are wrong, redesign, etc.

Keeping to the spirit of these notes I'll try to do one of these things myself, for a small program I might end up writing one day if I ever feel confident enough at C++ to do so.

## Iteration 1: An informal sketch

Something I've always wanted to do is write a simple game engine for simple text-based games, kind of like the "choose your own adventure" novels and "fighting fantasy" novels I used to read as a kid, or the kind of "twine" games I used to see on the web. Not that the world needs another one of those things, of course, but I kind of want to do it just for fun. So let's imagine something like that. How would I design a game engine like this? It's not a very complicated piece of software, but it would still have quite a few moving parts. 

The first step is to start writing an informal list of what some of the parts would be. At this point I'm not thinking about specific classes, and I'm not being at all precise about what the parts do and how they interact. This first stage is purely an exercise in me trying think about what kinds of things I'll need to include in the program.

Let's start by considering the "people, places, and things" that might be involved in a specific game:

- We would need a **Protagonist** object to represent the player character (there would be only one of these). The protagonist would need to have fields to store relevant information about the current state of the character (current health, maximum health, current hunger, current strength, etc). The protagonist object would be responsible for various actions associated with the state of the character. For instance, it should signal the end of the game if health reaches zero, it should decrease health if hunger gets too high, and so on. The **Protagonist** object would also be responsible for those game state variables that represent "where the protagonist is" and "what the protagonist is doing". So it would probably have a field storing "current location", for example. It would also need a field specifying which entity (or entities?) that the protagonist is curretly using.

- We would need an **Inventory** object that represents a collection of storable **Entity** objects that the protagonist carries with them from one location to another. The inventory object would be responsible for actions associated with its contents: if if the character is carrying too many objects it should signal that the inventory is full and require the player to drop objects before taking any other action.

- We would need a data structure to represent a **Location**. A location could be a room in a house, or a district in a town, or something like that. Locations are permitted to contain other locations: for instance, a game could include a "neighbourhood" location that contains many "house" locations, and each house could have several "room" locations. Locations would need to have a description to be presented to the user, and they could have field listing a set of **Entity** objects that exist at the location, and with which the protagonist could interact. Each location would also need to specify which other locations the protagonist could move to upon leaving this location. In order to handle these contingencies, the location itself would need to contain one or more **Action** objects.

- The **Entity** class would be a high level class. A basic entity is would be something akin to an object that exist within a location. This can include "storeable" entities like books, which can exist inside a location but can also be stored in the inventory, as well as "non-storeable" entities like fountains that can exist in a location but cannot be placed in the inventory. As such every entity would need to have a "location" field that could refer either to an actual **Location** but it could refer to the **Inventory**. This field allows each entity to know where it is. Entities would also need to have a boolean "is_visible" field or something like that. Upon entering a location, only the visible entities would be made available for the user to interact with. Invisible entities stay invisible until some **Action** triggers them to change state. More generally, each entity would be associated with some set of **Action** objects that specify the way in which the protagonist can interact wit the entity. 

- An **AgentEntity** (presumably a subclass of **Entity**) is an entity that has all the characteristics of any other **Entity** but additionally has methods and fields that provide it with "agent-like" attributes. It may be possible to talk to an agent or engage in combat with them. So a "Goblin"
might have health statistics much like the protagonist, and could engage in combat with the protagonist. If the entity is something the protagonist can talk to, the entity would need a store a dialogue tree.

On top of this we need objects and systems to govern the flow between game states and handle interactions between the protagonist, entities, and locations. Let's start thinking about what this looks like:

- An **Action** object is a thing that attaches either to an **Entity** or a **Location** and specifies a way in which the protagonist can interact with the entity/location. There would likely be many subclasses here. 

I'm not certain precisely what action types would be needed here, but 

- **StoreAction**: this would allow an entity to be removed from the current location and added to the inventory. When the **StoreAction** is called it would automatically create a new **DropAction** associated with the relevant entity, and then destroys itself. This would prevent the game from letting the user try to store an object that is already in the inventory.

- **DropAction**: this would allow an entity currently in the inventory to be removed from the inventory and added to the location where the protagonist currently is. When called, it would add a **StoreAction** to the relevant entity, and then destroy itself. If the entity is currently in use, it would trigger the relevant "unuse" action before doing so. 

- **TravelAction**: this would in the typical case, be associated with a specific location. When invoked, a **TravelAction** would move the protagonist to a different location. In doing so it would have to update the "current location" field for the protagonist, and invoke the **LocationInteraction** system for that new location. Though typically associated with locations, we wouldn't forbid entities from possessing a **TravelAction**. For instance, a fountain entity might double as a teleporter that moves the protagonist to a new location.

- **EntryAction**: this would be automatically invoked when the protagonist first enters a location (e.g., this could be used to trigger a trap when the protagonist enters a room)

- **ExitAction**: analogous to **EntryAction**, it is automatically invoked when the protagonist leaves the location. 

- **InspectAction**: at a minimum, this trigger a new description to be presented to the user. But it might also lead to one or more entity objects being revealed (e.g., the **InspectAction** for a bookcase might invoke the **RevealAction** for a book). If the **InspectAction** has consequences like that, it's likely that it would need to destroy itself after the inspection has taken place.

- **RevealAction**: this would set the is_visible field of an entity true

- **HideAction**: this would set the is_visible field of an entity to false

- **CombatAction**: this would induce a **CombatInteraction** between the protagonist and the entity
  
- **TalkAction**: this would induce a **TalkInteraction** between the protagonist and the entity

- **UseAction**: this would invoke some entity-specific change in the protagonist state (e.g., increasing health). It would then have other side effects. For example, if it's a single-use object (e.g., a health potion), then calling the **UseAction** would call the **DestroyAction** for the entity. If it's a persistent object (e.g., a book), the **UseAction** would (a) update the protagonists "currently using" field to refer to the entity; (b) create an **UnuseAction** for the entity and; (c) destroy itself. Optionally: if there's already an in-use entity, it would need to trigger the **UnuseAction** for the currently-in-use entity before taking steps (a-c). 

- **UnuseAction**: object would reverse the entity-specific changes in state associated with a persistent in-use object. It would (a) reset the "currently using" field for the protagonist to an empty value, (b) create a **UseAction** for the entity, and (c) destroy itself.

- **DestroyAction**: is invoked whenever the relevant entity is destroyed. In the simplest case, it destroys the entity object. It may have some other side effects though: it could reveal new objects, for instance. Killing the "Goblin" entity in combat would call its **DestroyAction**. This **DestroyAction** might invoke the **RevealAction** for the "Goblin Sword" that the goblin had been using. By revealing the sword, the user can pick it up (i.e., invoke the **StoreAction** for the "Goblin Sword").

Thinking about actions in this sense makes clear that we probably need several qualitative different **Interaction** systems:

- **LocationInteraction**: this system would be responsible for interactions with location. It presents the user with a description of the place and offers a set of actions based on whatever is contained in that place. It would also accept responses from the user, and trigger the appropriate actions. Depending on what the user does, this might then hand over to the entity interaction system, for instance. Additionally, it would offer the user the ability to move between locations.

- **InventoryInteraction**: this system would be responsible for interactions with the inventory. It would show the user a list of entities currently stored, allow the user to select entities, drop them, destroy them, use them, etc. 

- **EntityInteraction**: this system would take an entity, present the user with a description, and offer actions associated with that entity. Again, it would accept responses from the user and trigger appropriate actions. This might in turn trigger the combat or dialog interaction systems.

- **CombatInteraction**: this would be a turn-based system that governs how the protagonist can fight an **AgentEntity**. You can only enter combat if the agent possesses a **CombatAction**. This system would need a random-number generation system, some notion of attack strength, and perhaps include its own set of combat-specific actions like: **Attack**, **Defend**, **Flee**, etc. It would also allow the protagonist to call the **UseAction** for an item stored in the **Inventory** (e.g., using a "health potion" would increase health and then destroy the potion). Each combat action would modify the state of both the protagonist and the entity. Combat would end only when either the protagonist or the entity is destroyed/dead. A dead protagonist ends the game. A dead/destroyed entity triggers the relevant **DestroyAction**. 

- **TalkInteraction**: this would also be a turn-based system that manages the dialogue options that associated with an **AgentEntity**. I'm not quite sure what that looks like yet, but presumably it would invoke a dialog tree associated with the agent. 

Things are starting to take shape, but we still have some more to consider. The **Interaction** systems are part of the game mechanic. They describe how the protagonist interacts with other things in the game world. However, when I wrote about these systems above I talked about it as if the protagonist and the user are the same thing. They aren't, so we'll also need this:

- **UserInterface**: this system would take care of the actual "displaying stuff to the user" and the "reading responses from the user" part. It would also handle things like "giving the user the option to exit the game", and also "displaying the game state" (e.g., "You are talking to a Goblin, in the Library") 

In the initial conception, this "engine" would just be a headers-only library (assuming I understand that term correctly). For any specific "game", I'd import the library and then write the code needed to make that particular game. In that situation (assuming the games are short, simple things), this would be enough. But you could imagine taking it further. For instance, you might want the ability to read and write save files so that a player can pick up where they left off. That would require a **SavedGame** system that allows read/write for save game files. Taking it further, you might even imagine a whole system that makes it possible to store the entire game itself as a JSON file or the like, such that the game engine could accept a game file and a saved-game file as input. I'm not planning on anything like that right now, but if I want that to be an option it's important to think about how to serialise/deserialise games and game states. 


### Post-mortem on iteration 1

In software engineering land, the idea behind a "post-mortem" is to look back at a project (or a stage in the development process for the project) and do a blame-free evaluation of how it went. What worked? What didn't work? What are the lessons for the next step? Fundamental to the process is that it's not meant to be used to pass judgment on persons, and it's not meant to be used as part of someone's career evaluation. I confess I'm skeptical that this works as advertised in practice, because humans are what we are: people blame each other for things all the time even in situations where we're not supposed to, and I've never yet met a manager (in tech or any other industry) who didn't misuse private information when evaluating workers. Maybe one day I'll see a counterexample to this but it hasn't happened yet. Fortunately this isn't a problem in this instance, because it's my own personal project and I am accountable only to myself here :)

- There are places in the sketch where the vagueness about objects suggests I haven't fully decided on the scope of the project. For example, entities that are stored in the inventory can either be "in-use" or "not-in-use", but I'm quite unsure about what constraints exist on the "in-use" entities. At some points I talk as if the protagonist can only use a single entity at a given time, but at other points I seem to be acknowledging that this is too limited (why can't my protagonist wield the "Goblin Sword" while also wearing the "Goblin Hat"?) There may be a need for a "slots" system here. For instance, if the game is a sword-and-sorcery style game, you might want an "in-use-weapon" slot, and "in-use-armour" slot, and maybe more. If the game has more of a romance simulation flavour, there might be slots for the "in-use-outfit" that the protagonist wears on a date, one or more "in-use-tickets" that the protagonist uses to plan a date (e.g., a movie ticket, a go-to-a-picnic ticket, etc). It's not clear to me right now how many game structures I want the engine to be able to support (I'm not sure why a dating simulator needs a combat system, but on the other hand I have dated men in the past so yeah maybe it does), but it does seem clear that a single "in-use" slot is quite limiting. To resolve that, I'll probably need to do some work on clarifying the scope of the project.

- The sketch is quite vague about how the parts of the software should be organised into subsystems. For instance, there's a sense in which **Entity** objects and the **EntityInteraction** system go together as an entity system of some sort. But I'm not sure about where **Action** objects fit. Is there an **ActionHandler** system needed, for example? Should I be making a clearer distinction between actions attached to locations versus actions attached to entities? I'm really not sure, and I think that makes clear to me that this list is lacking some structure. It seems to me that what I have here is a list that summarises the objects I might need, but is missing details about assigning responsibilities. This lack of structure feels like the big missing piece right now. 

- The sketch is also lacking detail about what kinds of methods and fields should belong to these objects. What should be private to the objects, and what should be public? There's no detail on this at all so far. That bothers me less right now: it feels like something I want clarity on before writing any code, but it's probably something that can wait until I have a little more clarity on the structure.

Okay that's good, I think? It gives me a sense of what I need to work on next as I iterate on the design. 

In terms of progress through the book, what I think I'll do now is move onto chapter 5 (which talks about OOP approaches in C++) because that will probably be valuable to me in order to progress to "iteration 2", and then return to this section of the notes later.

## Moar iterations...

...to be added. Maybe.

[Back to top](index.html)

