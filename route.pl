% -------- Weighted edges (undirected distances in km) --------
edge(colombo, kandy, 120).
edge(colombo, galle, 116).
edge(kandy, anuradhapura, 138).
edge(galle, matara, 45).
edge(matara, hambantota, 80).
edge(kandy, hambantota, 250).
edge(colombo, negombo, 37).
edge(colombo, kurunegala, 94).
edge(kurunegala, kandy, 42).
edge(kurunegala, anuradhapura, 117).
edge(kandy, nuwara_eliya, 75).
edge(kandy, badulla, 120).
edge(badulla, ella, 20).
edge(ella, hambantota, 100).
edge(galle, ratnapura, 129).
edge(ratnapura, kandy, 95).
edge(ratnapura, badulla, 140).
edge(anuradhapura, jaffna, 200).
edge(anuradhapura, trincomalee, 105).
edge(trincomalee, batticaloa, 137).
edge(batticaloa, ampara, 63).
edge(ampara, hambantota, 140).
edge(nuwara_eliya, ella, 60).

:- dynamic blocked/2.

% -------------connected/3: undirected and not blocked -----------------
connected(A,B,W) :- edge(A,B,W), \+blocked(A,B).
connected(A,B,W) :- edge(B,A,W), \+blocked(B,A).
                
%-------- Block and unblock roads---------------
block_road(A,B) :-
    assertz(blocked(A,B)),
    assertz(blocked(B,A)).
unblock_road(A,B) :-
    retractall(blocked(A,B)),
    retractall(blocked(B,A)).
clear_all_blocks :- retractall(blocked(_,_)).



% -------- BFS (shortest by number of edges) --------
/* double brackets are used in [[Start]] because it is a list of lists. 
 * There is only one path currently which is the starting node */
bfs(Start, Goal, Path) :-
    bfs_queue([[Start]], Goal, Path). 

 /* =============================================================
 The outer list [....|.....] is a queue containing multiple paths.
 [Goal|Rest] is the first element of the queue which is a path.
 Anonnymous variable is used to indicate rest of the paths.
  */
/*
Following is the base case for BFS.
When the first path in the queue starts with the "Goal" node we stop the 
recursion and return the answer(path)
*/

/*
Path is written backwards. for example path to Colombo from Matara is stored as
[Matara, Galle, Colombo] which is backwards so we need to reverse it to make it readable
========================================================================*/
bfs_queue([[Goal|Rest]|_], Goal, Path) :-
    reverse([Goal|Rest], Path).

/*=====================================================================

[[Current|Rest]|Other]

In here,
Current == The current node we are expanding
Rest == The rest of the path
Other == Other paths in the queue


=========findall/3============================
findall/3 is a predicate that collects all the soulutions of a goal and 
combines them into a single list.

The syntax: findall(Template, goal, List)
Templete == The pattern that specifies what part of the solution you want to collect
Goal == Condition that generate the solution
List == Name of the list containing all instances of "Template" for which "Goal succeeds"

=========================================================================

**Mapping of findall(Template, Goal, List) with the implementation of bfs_queue**

Template === [Next, Current | Rest]

Goal === (connected(Current, Next, _),
 \+ member(Next, [Current|Rest]))

List === NewPath

=========================================================================
Lets dive deep into [Next, Current | Rest]

[Head|Tail] means first element is Head and the rest is Tail

[Next, Current | Rest] means first element is "Next" and the second element
will be "Current". Then the remaining elements will be "Rest"

First element("Next") is the neighbor of "Current"

=========================================================================

Now lets look into (connected(Current, Next, _),\+ member(Next, [Current|Rest]))

(connected(Current, Next, _), 
 \+ member(Next, [Current|Rest]))

 Above maps to the Goal of the findall/3

 connected(Current, Next, _) === Checks if there a road between "Current" node and 
 some neigbor "Next". We do not care about the distance so anonymous variable is used

 example -> connected(kandy, hambantota, 250) 
 This succeeds with Current = kandy and Next = hambantota.

 \+ member(Next, [Current|Rest]) === This checks whether "Next" is not already on the path
Here [Current|Rest] is the path (nodes we have already visited)

=============== append(Other, NewPaths, Updated) ======================
We append "Other" (old paths before "NewPaths") so BFS finishes explore 
shallow paths before exploring newly discoverd "NewPaths"

*/
bfs_queue([[Current|Rest]|Other], Goal, Path) :-
    findall([Next,Current|Rest],
            (connected(Current, Next, _),
             \+ member(Next, [Current|Rest])),
            NewPaths),
    append(Other, NewPaths, Updated),
    bfs_queue(Updated, Goal, Path).


    

% -------- DFS (depth-first search) --------
/*
Same as BFS excepts append "NewPaths" before old "Other" paths
it it push NewPaths to FRONT to behave like a stack (LIFO)

*/


dfs(Start, Goal, Path) :-
    dfs_stack([[Start]], Goal, Path).

dfs_stack([[Goal|Rest]|_], Goal, Path) :-
    reverse([Goal|Rest], Path).
dfs_stack([[Current|Rest]|Other], Goal, Path) :-
    findall([Next,Current|Rest],
            (connected(Current, Next, _),
             \+ member(Next, [Current|Rest])),
            NewPaths),
    % push to FRONT to behave like a stack (LIFO)
    append(NewPaths, Other, Updated),
    dfs_stack(Updated, Goal, Path).

% -------- Path cost (sum distances along a path) --------
/*
==========
Base case
==========

path_cost([_], 0).

If the path has only one node (represented by anonymous variable) the path cost is 0.

example - [colombo]

This stops the recursion

==============
Recursive case
==============

path_cost([A,B|T], Cost) :-
    connected(A,B,W),
    path_cost([B|T], Rest),
    Cost is W + Rest.

Here,
A == first node
B == second node
T == rest of the nodes

First prolog finds the weight of the path cost between first and second nodes

Then it computes the cost of the tail recursively

Exaple run:

1. path_cost([colombo,kandy,anuradhapura], Cost)
    A=colombo, B=kandy, W=120
    recursive action on [kandy, anuradhapura]

2. path_cost([kandy,anuradhapura], Rest)]
    A=kandy, B=anuradhapura, W=138
    recurse on [anuradhapura]

3. path_cost([anuradhapura], 0)
   The base case

*/

path_cost([_], 0).
path_cost([A,B|T], Cost) :-
    connected(A,B,W),
    path_cost([B|T], Rest),
    Cost is W + Rest.

% -------- Collect all paths --------

/*
What does findall/3 do

findall(Tempalte, Goal, List) -> This collects all possiblities of Template
that satisfy Goal and combines them in a List 
*/


all_bfs_paths(Start, Goal, Paths) :-
    findall(Path, bfs(Start, Goal, Path), Paths).

all_dfs_paths(Start, Goal, Paths) :-
    findall(Path, dfs(Start, Goal, Path), Paths).


% -------- Convenience predicates --------
/*
This generates all possible paths between start and Goal
And picks the shortest path by cost

all_bfs_paths(Start, Goal, Paths)-> Uses findall/3 with BFS search and puts 
all bfs paths into list called Paths. 

Same goes for all_dfs_paths/3

shortest_path(Paths, Path, Cost) -> Takes the list of paths
Returns the cheapest Path and the Cost

*/

shortest_bfs_path(Start, Goal, Path, Cost) :-
    all_bfs_paths(Start, Goal, Paths),
    shortest_path(Paths, Path, Cost).

shortest_dfs_path(Start, Goal, Path, Cost) :-
    all_dfs_paths(Start, Goal, Paths),
    shortest_path(Paths, Path, Cost).

% -------- Find shortest path by distance --------

/*
This implements shortest_path(Paths, Path, Cost).

Here
Paths - List of paths from bfs and dfs
ShortestPath - The best path with minimum cost
MinCost - Best paths total cost

Step 1: map_list_to_pairs(path_cost, Paths, Pairs)

This applies path_cost/2 predicate to each element in "Paths"
And it creates Key-Value pairs like "Cost-Paths"

example
Pairs = [370-[colombo,kandy,hambantota],
         241-[colombo,galle,matara,hambantota]]

Step 2: keysort/2

keysort/2 sorts the list of "Key-Value" pairs by its "Key"
Smallest key ends up as the Head of the list

[MinCost-ShortestPath|_] unifies with the sorted list taking the smallest pair,
Rest of the "Key-Value" pairs are ignored with a anonymous variable


*/

shortest_path([], _, _) :-
    write('No path exists.'), fail.
shortest_path(Paths, ShortestPath, MinCost) :-
    map_list_to_pairs(path_cost, Paths, Pairs),
    keysort(Pairs, [MinCost-ShortestPath|_]).

% -------- A* Search --------

% -------- Heuristic values (straight-line estimates to hambantota) ------
/* Astar searchfinds theoptimal path between Path and Goal by minimum value of f(n) = g(n)+h(n)  

g(n) - cost from start to current node
h(n) - hearustic value from current node to goal
f(n) - Toatal of g+h

astar(Start, Goal, Path, Cost) :-
    h(Start, H0),
    astar_search([node(Start, [Start], 0, H0)], Goal, RevPath, Cost),
    reverse(RevPath, Path).

Steps:
1. Get heuristic of Start (h(Start, H0))
2. Initialize OpenList with one node: Start
3. Call astar_search/4 to expand until Goal is found
4. Reverse the path because we store it backwards

node has four components
node(State, Path, G, F)
   - State = current node
   - Path  = path taken so far (in reverse order for efficiency)
   - G     = actual cost so far
   - F     = estimated total cost (g + h)

==============
Entry point
==============
astar(Start, Goal, Path, Cost) :-
    h(Start, H0),
    astar_search([node(Start, [Start], 0, H0)], Goal, RevPath, Cost),
    reverse(RevPath, Path).

1. Here "h(Start, H0)" looks for heuristic value from start node to the goal
Example: if start = colombo and h(colombo, 250) then H0 = 250
Heuristic value is the initial guess of cost

2. astar_search([node(Start, [Start], 0, H0)], Goal, RevPath, Cost)

Here it initialize the open list with one node (Open list are nodes which are 
discovered but not expanded)

node(Start, [Start], 0, H0)

Start - Starting city
[Start] - Path so far (stored in reverse order)
0 - Actual cost so far
H0 - Estimated cost to the goal

astar_search/4 will succeed with->

RevPath - path in reverse order
Cost - Total cost of the path

3. reverse(RevPath, Path)
This will Reverse the RevPath to form of Start -> Goal

==============
Base case
==============
astar_search([node(State, Path, G, _)|_], State, Path, G) :- !.

1. first element is node(State, Path, G, _).

State = current node
Path = Path so far
G = actual cost from start
_ = F value (h+g), we do not care about this value
[..........|_] = rest of the open list, also we do not care these values

The clause checkes State is the Goal
If yes,
Path is returned
G the total cost is returened
! - the cut operator ensure prolog searching further

================
Recursive case
================
astar_search([node(State, Path, G, _)|Rest], Goal, FinalPath, Cost) :-
    findall(node(Next, [Next|Path], G1, F1),
            ( connected(State, Next, StepCost),   % 1. expand neighbors
              \+ member(Next, Path),              % 2. avoid cycles
              G1 is G + StepCost,                 % 3. actual cost so far
              h(Next, H),                         % 4. heuristic
              F1 is G1 + H ),                     % 5. estimated total cost
            Children),
    append(Rest, Children, OpenList),             % 6. merge with remaining nodes
    sort(4, @=<, OpenList, Sorted),               % 7. sort by F (ascending)
    astar_search(Sorted, Goal, FinalPath, Cost).  % 8. recurse

1. [node(State, Path, G, _)|Rest]

Here open list is divided into two
HEAD - node(State, Path, G, _)
TAIL - Rest (The remaining open list)

2.  findall(node(Next, [Next|Path], G1, F1)

Findall(Template, Goal, List)

Template = what you want to collect
Goal = the condition that must hold for Template
List = the list of all Template instances that satisfy Goal

Here Template is = node(Next, [Next|Path], G1, F1)

Next - The neigbor city
[Next|Path] - The new path, append "Next" to current Path
G1 = updated actual cost
F1 = Estimated total(G1 + Heuristic)


Here Goal is = 
    ( connected(State, Next, StepCost),
     \+ member(Next, Path),
    G1 is G + StepCost,
    h(Next, H),
    F1 is G1 + H )

connected(State, Next, StepCost) -> there’s a road from current city to neighbor
\+ member(Next, Path) -> don't revisit nodes already in the path
G1 is G + StepCost -> Updated actual cost
h(Next, H) -> Heuristic for neighbor
F1 is G1 + H -> Compute the total estimated cost(G1 + Heuristic)

Here Result is = Children

* findall(node(...), Goal, Children) says
Expand the current city into all neighbours and bundle them into a List called Children

3.  append(Rest, Children, OpenList),     

append(List1, List2, Result).

Here List1 is Rest = nodes waiting in the open list
List2 is Childern = New nodes generated from findall/3
OpenList = Combination of Rest and Children

4. sort(4, @=<, OpenList, Sorted)
This sorts OpenList by 4th argument of node/4 ,(F=G+H)
@=< means acending order

5.astar_search(Sorted, Goal, FinalPath, Cost).

This is te recursive call

Take the first element in Sorted (best node by F).
If it's not the goal -> expand it with findall.
Append its children to the rest.
Re-sort.
Repeat.

================
step-by-step trace of astar(colombo, hambantota, Path, Cost)

1.astar(colombo, hambantota, Path, Cost).

2.[node(colombo, [colombo], 0, 150)]

3.
node(kandy, [kandy,colombo], 120, 320)        % G=120, H=200
node(galle, [galle,colombo], 116, 266)        % G=116, H=150
node(negombo, [negombo,colombo], 37, 307)     % G=37,  H=270
node(kurunegala, [kurunegala,colombo], 94, 314) % G=94, H=220

4.
Rest = []
Children = [above four nodes]

5.
OpenList = [kandy, galle, negombo, kurunegala]

6.
Sorted = [
  node(galle, [galle,colombo], 116, 266),
  node(negombo, [negombo,colombo], 37, 307),
  node(kurunegala, [kurunegala,colombo], 94, 314),
  node(kandy, [kandy,colombo], 120, 320)
]

7. Expand galle node

node(matara, [matara,galle,colombo], 161, 261)  % G=116+45=161, H=100, F=261

Rest = [negombo, kurunegala, kandy]
Children = [matara]

8.
OpenList = [negombo, kurunegala, kandy, matara]

9.
Sorted = [
  node(matara, [matara,galle,colombo], 161, 261),
  node(negombo, [negombo,colombo], 37, 307),
  node(kurunegala, [kurunegala,colombo], 94, 314),
  node(kandy, [kandy,colombo], 120, 320)
]


10. Expand matara
node(hambantota, [hambantota,matara,galle,colombo], 241, 241)

11.
Rest = [negombo, kurunegala, kandy]
Children = [hambantota]

12.
OpenList = [negombo, kurunegala, kandy, hambantota]

13.
Sorted = [
  node(hambantota, [hambantota,matara,galle,colombo], 241, 241),
  node(negombo, [negombo,colombo], 37, 307),
  node(kurunegala, [kurunegala,colombo], 94, 314),
  node(kandy, [kandy,colombo], 120, 320)
]

Goal found. So reverse

node(hambantota, [hambantota,matara,galle,colombo], 241, 241) ->
[colombo,galle,matara,hambantota]


*/


%approximate distance from hambantota
h(colombo, 250).
h(kandy, 200).
h(galle, 150).
h(matara, 100).
h(hambantota, 0).
h(negombo, 270).
h(kurunegala, 220).
h(anuradhapura, 300).
h(nuwara_eliya, 180).
h(badulla, 150).
h(ella, 120).
h(ratnapura, 170).
h(jaffna, 400).
h(trincomalee, 280).
h(batticaloa, 200).
h(ampara, 120).

% Uses connected/3 so blocked roads are respected

astar(Start, Goal, Path, Cost) :-
    h(Start, H0),
    astar_search([node(Start, [Start], 0, H0)], Goal, RevPath, Cost),
    reverse(RevPath, Path).

% If we reach the goal, succeed and cut
astar_search([node(State, Path, G, _)|_], State, Path, G) :- !.

astar_search([node(State, Path, G, _)|Rest], Goal, FinalPath, Cost) :-
    findall(node(Next, [Next|Path], G1, F1),
            ( connected(State, Next, StepCost),   % uses connected/3
              \+ member(Next, Path),              % avoid cycles
              G1 is G + StepCost,
              h(Next, H),
              F1 is G1 + H ),
            Children),
    append(Rest, Children, OpenList),
    sort(4, @=<, OpenList, Sorted),               % sort by F value
    astar_search(Sorted, Goal, FinalPath, Cost).





/*
This predicate compares BFS, DFS, and Astar search algorithms.
For each algorithm:
1. It tries to find the shortest path between Start and Goal.
2. If a path exists, it converts the path list into a readable
    "city1->city2->.....->Goal" format using atomic_list_concat/3.
3. It then prints both the formatted path and its total cost.
4. If no path exists, it prints a message instead.

*/

compare_algorithms(Start, Goal) :-
    ( shortest_bfs_path(Start, Goal, BfsPath, BfsCost) ->
        atomic_list_concat(BfsPath, '->', BfsRoute),
        format("BFS  Path: ~w, Cost: ~w~n", [BfsRoute, BfsCost])
    ; writeln("BFS: No path found")
    ),
    ( shortest_dfs_path(Start, Goal, DfsPath, DfsCost) ->
        atomic_list_concat(DfsPath, '->', DfsRoute),
        format("DFS  Path: ~w, Cost: ~w~n", [DfsRoute, DfsCost])
    ; writeln("DFS: No path found")
    ),
    ( astar(Start, Goal, AstarPath, AstarCost) ->
        atomic_list_concat(AstarPath, '->', AstarRoute),
        format("A*   Path: ~w, Cost: ~w~n", [AstarRoute, AstarCost])
    ; writeln("A*: No path found")
    ).

