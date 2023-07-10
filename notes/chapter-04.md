---
title: "4: Designing professional C++ programs"
---

[Back to top](index.html)

## Chapter summary

...Blah blah blah. I'll fill this bit in later...

Okay, so most of this makes sense to me. Fundamentally, the point is that if you're building software rather than writing a script, it's a good idea to spend time sketching out what you think the structure of that software is, *before* you start writing any code. 

A design document that specifies this plan might start out as a basic sketch. As you put together the sketch you'll start fleshing out specific classes, their methods and fields, and the ways they interact. It's an iterative process: you might realise some parts of your plan are wrong, redesign, etc. 

## An informal sketch

Something I've always wanted to do is write a simple game engine for simple text-based games, kind of like the "choose your own adventure" novels and "fighting fantasy" novels I used to read as a kid, or the kind of "twine" games I used to see on the web. Not that the world needs another one of those things, of course, but I kind of want to do it just for fun. So let's imagine something like that. How would I design a game engine like this? It's not a very complicated piece of software, but it would still have quite a few moving parts. 

The first step is to start writing an informal list of what some of the parts would be. At this point I'm not thinking about specific classes, and I'm not being at all precise about what the parts do and how they interact. This first stage is purely an exercise in me trying think about what kinds of things I'll need to include in the program.

Let's start by considering the "people, places, and things" that might be involved in a specific game:

- We would need a **Protagonist** object to represent the player character (there would be only one of these). The protagonist would need to have fields to store relevant information about the current state of the character (current health, maximum health, current hunger, current strength, etc). The protagonist object would be responsible for various actions associated with the state of the character. For instance, it should signal the end of the game if health reaches zero, it should decrease health if hunger gets too high, and so on. The **Protagonist** object would also be responsible for those game state variables that represent "where the protagonist is" and "what the protagonist is doing". So it would probably have a field storing "current location", for example.

- We might need an **Inventory** object that represents a collection of storable **Entity** objects that the protagonist carries with them from one location to another. The inventory object would be responsible for actions associated with its contents: if if the character is carrying too many objects it should signal that the inventory is full and require the player to drop objects before taking any other action.

- We would need a **Map** object used to represent the collection of **Locations** within the game. In the simplest case the game would have only a single map, but for more complicated games you might need maps that store other maps: for instance, a game could include neighbourhoods that have many houses, and each house could have several rooms. In that case each room is a location, each house is a map of room locations, and the neighbourhood would be a map of house maps. 

- We would need a data structure to represent a **Location**. A location could be a room in a house, or a district in a town, or something like that. Locations would need to have a description to be presented to the user, and they could contain a set of **Entity** objects with which the protagonist could interact. Each location would also need to specify which other locations the protagonist could move to upon leaving this location. In order to handle these contingencies, the location would need to contain one or more **Action** objects.

- It's possible we need a higher level abstraction to describe **Place** objects. For instance: **Maps** are a kind of place that can contain locations and other maps. **Locations** are a kind of place that can contain entities (with no constraint on what kinds of entity can exist within a location). The **Inventory** would also be a place, but it would only be permitted to contain "storable" entities.

- An **Entity** would be a flexible class "something the protagonist can interact with". The entity system would need some way to represent "storeable" entities like books, which can exist inside a location but can also be stored in the inventory, as well as "non-storeable" entities like fountains that can exist in a location but cannot be placed in the inventory. It would also have to accomodate "agent-like" entities: a goblin might have health statistics much like the protagonist, and could engage in combat with the protagonist. If the entity is something the protagonist can talk to, the entity would need a store a dialogue tree. In order to make the entity system flexible and workable, each entity might need to be associated with one or more **Action** objects. 

On top of this we need objects and systems to govern the flow between game states and handle interactions between the protagonist, entities, and locations. Let's start thinking about what this looks like:

- An **Action** object is a thing that attaches either to an **Entity** or a **Location** and specifies a way in which the protagonist can interact with the entity/location. There would likely be many subclasses here. A few of these:

- A **Store** action would allow an **Entity** to be removed from the current **Location** and added to the **Inventory**. When the **Store** is called it would create a new **Drop** associated with the relevant **Entity**, and then destroys itself (you can't store an object that is already in the inventory)

- A **Drop** is the opposite. It would allow an **Entity** to be removed from the **Inventory** and added to the **Location** where the protagonist currently is. When called, it would add a **Store** to the relevant entity, and then destroy itself. 

- A **Travel** action would, in the typical case, be associated with a specific **Location**. When invoked, it would move the **Protagonist** to a different **Location**. However, we wouldn't forbid **Entities** from possessing this class of action: for instance, a fountain entity might double as a teleporter that moves the protagonist to a new location. 

- An **Inspect** action would, at a minimum, trigger a new description to be presented to the user. But it might also lead to one or more **Entity** objects being created (e.g., searching a room reveals something new), trigger other actions and so on. If the **Inspect** action has consequences like that it might also need to modify itself (e.g., to say "you have already searched this room" or something).

- A **Fight** action would invoke the **CombatInteraction** system, triggering a fight between the **Protagonist** and an **Entity**.
  
- A **Talk** action would invoke the **DialogueInteraction** system, triggering a conversation between the **Protagonist** and an **Entity**

- A **Use** action would invoke some entity-specific change in state.

- A **Unuse** action would reverse the entity-specific change in state.

- A **Destroy** action is invoked whenever the relevant entity is destroyed (e.g., killed in combat)

Thinking about actions in this sense makes clear that we probably need four qualitative different **Interaction** systems:

- The **PlaceInteraction** system would be responsible for interactions with places. It takes a **Place** object (**Map**, **Location**, **Inventory**), presents the user with a description of the place and offers a set of actions based on whatever is contained in that place. It would also accept responses from the user, and trigger the appropriate actions. Depending on what the user does, this might then hand over to the entity interaction system, for instance.

- The **EntityInteraction** system would take an **Entity**, present the user with a description, and offer actions associated with that entity. Again, it would accept responses from the user and trigger appropriate actions. This might in turn trigger the combat or dialog interaction systems.

- We would also need a turn-based **CombatInteraction** system that governs how the **Protagonist** can fight an **Entity**. You can only enter combat if the **Entity** possesses a **Fight** action. It would need a random-number generation system, some notion of attack strength, and perhaps include its own set of combat-specific actions like: **Attack**, **Defend**, **Flee**, etc. It would also allow the protagonist to **Use** an item stored in the **Inventory** (e.g., using a "health potion" would increase health and then destroy the potion). Each combat action would modify the state of both the protagonist and the entity. Combat would end only when either the protagonist or the entity is destroyed/dead. A dead **Protagonist** ends the game. A dead/destroyed **Entity** triggers the relevant **Destroy** action. 

- There would need to be a turn-based **DialogueInteraction** system. That manages the dialogue options that associated with an entity. I'm not quite sure what that looks like yet.

Things are starting to take shape, but we still have some more to consider. The **Interaction** systems are part of the game mechanic. They describe how the protagonist interacts with other things in the game world. However, when I wrote about these systems above I talked about it as if the protagonist and the user are the same thing. They aren't, so we'll also need this:

- The **UserInterface** system would take care of the actual "displaying stuff to the user" and the "reading responses from the user" part. It would also handle things like "giving the user the option to exit the game", and also "displaying the game state" (e.g., "You are talking to a Goblin, in the Library") 

Pushing further, if we're thinking of this as a simple game engine, then we'll need some additional mechanisms:

- The **GameLoad** system would have the ability to read a game state from a JSON file or something. 
- The **GameSave** system would have the ability to write a game state to file. 

In a fancy world you'd separate the "game file" from a specific "save game file", but this setup is so simple that you might as well write everything to the save file. In this sense, a "game file" is exactly identical to the "save game file" corresponding to the initial game state. 



