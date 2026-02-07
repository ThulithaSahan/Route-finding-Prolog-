# Route-finding-Prolog-
Implements a route-finding system for Sri Lankan cities using BFS, DFS and A* algorithms

This system supports realistic constraints such as
• Blocking and unblocking roads
• Optimizing routes based on distance cost
• Compare algorithms
Project structure
1. Graph representation
The road networks in Sri Lankan cities are represented as weighted edges. Weight
being distance between cities
edge(colombo, kandy, 120).
edge(colombo, galle, 116).
edge(kandy, anuradhapura, 138).2. Blocking and unblocking roads
block_road(A,B).
unblock_road(A,B).
clear_all_blocks.
3. Algorithms used
BFS (Breadth-First Search): Uses a queue-based expansion.
DFS (Depth-First Search): Uses a stack-like structure.
A* Search: Expands nodes with the smallest f(n) = g(n) + h(n). (actual cost (g) and
heuristic (h).)
4. Path cost calculations
path_cost(Path, Cost).
Calculates any given distance of a path
5. Finding the shortest path
shortest_bfs_path(Start, Goal, Path, Cost).
shortest_dfs_path(Start, Goal, Path, Cost).
astar_path(Start, Goal, Path, Cost).
Collects all possible paths and selects path with minimum cost6. Comparison of algorithms Runs BFS, DFS, and A*.
Prints Path taken total distance cost.
compare_algorithms(Start, Goal).
Example Output:
?- compare_algorithms(colombo, hambantota).
BFS Path: colombo->galle->matara->hambantota, Cost: 241
DFS Path: colombo->galle->matara->hambantota, Cost: 241
A* Path: colombo->galle->matara->hambantota, Cost: 241
Also you can simulate blocked roads
block_road(colombo,galle),
compare_algorithms(colombo, hambantota).
%output
BFS Path: colombo->kandy->nuwara_eliya->ella-
>hambantota, Cost: 355
DFS Path: colombo->kandy->nuwara_eliya->ella-
>hambantota, Cost: 355
A* Path: colombo->kandy->hambantota, Cost: 370
Future enhancements
• Add real GPS values
• Visualize paths with a plotting tool
• Extend constraints such as fuel, traffic and time
