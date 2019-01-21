# Gaming the Christmas Market 

## Introduction

The [Bath Christmas Market](https://bathchristmasmarket.co.uk) is a yearly extravaganza, when the city of Bath is 
transformed into a veritable Winter Wonderland offering a selection of gift chalets for all your Christmas purchasing 
requirements. Or at least that's one perspective. For me, long in the tooth and a little bit grumpy, it's not quite so
evocative. A log jam of people shuffling between chalets with their Christmas spirit disappearing faster than the mince 
pies and hot toddy. When it comes to Christmas shopping, a high focus on efficiency is what is required! 

This mini project uses the Neo4j graph database to determine the optimum route through the Christmas Market, given 
a set of mandatory chalets to purchase from. (a.k.a. [The Travelling Salesman Problem](https://en.wikipedia.org/wiki/Travelling_salesman_problem)). 
It gives a user friendly visual of the route using Neo4j Desktop, making use of APOC's virtual nodes and relationships.

The project is written using Neo4j 3.4.10 and licensed under Apache License 2.0. Full source code is 
[available](https://github.com/dbarton-uk/christmas-market).
 
### Use Cases

The project looks to address the following two use cases:

1. Find Optimum Route: Given a set of chalets to visit, define an optimum travel route between the chalets such that each 
of the set is visited at least once.
 
2. Visualize Route: Given the optimum route, provide a user friendly visual of the route.

## Setting up the Data

### Overview

The Christmas Market is split into zones, each defined by a unique name. A zone hosts a number of chalets, each with a 
unique name and number. A chalet has a description and is categorized by the type of gift that it sells. Links between 
chalets have been manually defined, with a cost assigned to each link. These links and their associated costs are used 
to determine the optimal route to take when visiting a given set of chalets.
 
60 chalets across 8 zones are defined, with the data sourced originally sourced from [The Bath Christmas Market website](https://bathchristmasmarket.co.uk) 
The raw data is available in the [spreadsheet](https://github.com/dbarton-uk/christmas-market/blob/master/ChristmasMarket.numbers).

For reference, the original map of the market is here:

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/Bath-Christmas-Market-Map-2018.png?raw=true "Map")

### Create constraints and indexes

Run [create_constraints.cql](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/create_constraints.cql)
to setup constraints and indexes. 

```cypher
CREATE CONSTRAINT ON (z:Zone) ASSERT (z.name) IS NODE KEY;
CREATE CONSTRAINT ON (c:Chalet) ASSERT (c.number) IS NODE KEY;
CREATE CONSTRAINT ON (c:Chalet) ASSERT c.name IS UNIQUE;
CREATE CONSTRAINT ON (c:Chalet) ASSERT c.sequence IS UNIQUE;
```

### Loading the data

The schema is shown below.

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/schema.png?raw=true "Database Schema")

First run [load_chalets.cql](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/load_chalets.cql).

```cypher
LOAD CSV WITH HEADERS
  FROM 'https://raw.githubusercontent.com/dbarton-uk/christmas-market/master/data/Chalets-Chalets.csv' 
  AS csv
CREATE (c :Chalet {
  sequence: toInteger(csv.Id),
  number: toInteger(csv.Number),
  name: csv.Name,
  description: csv.Description,
  zone: csv.Zone,
  category: csv.Category
})
MERGE (z:Zone { name: csv.Zone})
WITH c, z
CALL apoc.create.addLabels( 
  id(c), 
  [apoc.text.capitalize(apoc.text.camelCase(z.name))]
) YIELD node
MERGE (z) -[:HOSTS]-> (c)
```
`Added 68 labels, created 68 nodes, set 308 properties, created 60 relationships, completed after 540 ms.`

The load chalet script does the following:

- Creates chalet nodes based on the [extracted chalet csv data](https://github.com/dbarton-uk/christmas-market/blob/master/data/Chalets-Chalets.csv).

- Create zone nodes based on zone data.

- Adds zone labels to chalet nodes

- Links zones to chalets with a `:HOSTS` relationship.

The chalets are split into 5 categories: Clothing and Accessories, Food and Drink, Gifts and Homeware, Health and Beauty 
and Home and Garden. Zone names are added as redundant labels to improve Neo4j Desktop visualization options. 

Next run [load_links.cql](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/load_links.cql).

```cypher
LOAD CSV WITH HEADERS 
  FROM 'https://raw.githubusercontent.com/dbarton-uk/christmas-market/master/data/Links-Links.csv' 
  AS csv
MATCH (c1:Chalet {sequence: toInteger(csv.from)})
MATCH (c2:Chalet {sequence: toInteger(csv.to)})
MERGE (c1) -[:LINKS_TO {cost: toInteger(csv.cost)}]-> (c2)
```

`Set 87 properties, created 87 relationships, completed after 347 ms.`

The script creates the links between chalets based on the [extracted link csv data](https://github.com/dbarton-uk/christmas-market/blob/master/data/Links-Links.csv).
A cost is defined for each link, which is used by the algorithm when calculating an optimal route.


### Checking the data

Ok, so, let's see what we have. First the [chalets](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/chalets.cql).

```cypher
MATCH (c :Chalet)
RETURN c.number as Number, c.name as Name, c.description, c.category as Category, c.zone as Zone
  ORDER BY c.zone, c.category, c.number
```

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/chalets_table.png?raw=true "Table of Chalets")

Next, the [intra-zone links](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/intra-zone_links.cql).
```cypher
MATCH p = (c1:Chalet) -[:LINKS_TO]-> (c2:Chalet)
  WHERE c1.zone = c2.zone
RETURN p
```

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/intra-zone_links.png?raw=true "Intra-Zone Links")


And finally, the [inter-zone links](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/inter-zone_links.cql).
```cypher
MATCH p = (c1:Chalet) -[:LINKS_TO]-> (c2:Chalet)
  WHERE c1.zone <> c2.zone
RETURN p
```

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/inter-zone_links.png?raw=true "Inter-Zone Links")

Using zone as a label, means that in Neo4j Desktop, we can colour each chalet by zone. Lovely Jubbly. :thumbsup:

## Optimizing the route

### Choosing the gifts

So now that we are set up and ready to go, let's choose the chalets that we are going to purchase gifts from.

- For Bro, something to share (no. 109)
- For Nan, something for the garden. (no. 24)
- For Grandpa, something tasty (no. 169)
- For Toby the dog, some doggy treats (no. 89)
- For the Kids, something that won't get me in trouble (no. 32, no. 184) 
- For the Trouble, something to keep her warm and sweet (no. 181, no. 19)

```cypher
WITH [{ number: 109, for: "Bro"},
       {number: 24, for: "Nan"},
       {number: 169, for: "Grandpa"},
       {number: 89, for: "Toby"},
       {number: 32, for: "The Girl"},
       {number: 184, for: "The Boy"},
       {number: 181, for: "The Missus"},
       {number: 19, for: "The Missus"}
     ] as gifts
UNWIND gifts as gift
MATCH (c:Chalet { number: gift.number})
RETURN
  gift.number as Number,
  gift.for as For,
  c.name as Name,
  c.description as Description,
  c.zone as Zone,
  c.category as Category
  ORDER by c.zone, c.number
```

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/selected_gifts.png?raw=true "Table of Selected Gifts")

### The Algorithm

So to the main event. Let's find the optimal route around the market.

Here is the bad boy cypher statement, augmented with steps. An explanation is given below.

```cypher
// Step 1
WITH [109, 24, 169, 89, 32, 184, 181, 19] as selection
MATCH (c:Chalet) where c.number in selection
WITH collect(c) as chalets
UNWIND chalets as c1
WITH c1,
     filter(c in chalets where c.number > c1.number) as c2s,
     chalets
UNWIND c2s as c2
CALL algo.shortestPath.stream(c1, c2, 'cost', {relationshipQuery: 'LINKS_TO'}) YIELD nodeId, cost
WITH c1,
     c2,
     max(cost) as totalCost,
     collect(nodeId) as shortestHopNodeIds,
     chalets
MERGE (c1) -[r:SHORTEST_ROUTE_TO]- (c2)
SET r.cost = totalCost
SET r.shortestHopNodeIds = shortestHopNodeIds
// Step 2
WITH c1,
     c2,
     (size(chalets) - 1) as level,
     chalets
CALL apoc.path.expandConfig(c1, {
        relationshipFilter: 'SHORTEST_ROUTE_TO', 
        minLevel: level, 
        maxLevel: level, 
        whitelistNodes: chalets, 
        terminatorNodes: [c2], 
        uniqueness: 'NODE_PATH' }
      ) YIELD path
WITH nodes(path) as orderedChalets,
     extract(n in nodes(path) | id(n)) as ids,
     reduce(cost = 0, x in relationships(path) | cost + x.cost) as totalCost,
     extract(r in relationships(path) | r.shortestHopNodeIds) as shortestRouteNodeIds
  ORDER BY totalCost LIMIT 1
// Step 3
UNWIND range(0, size(orderedChalets) - 1) as index
UNWIND shortestRouteNodeIds[index] as shortestHopNodeId
WITH orderedChalets, totalCost, index,
     CASE WHEN shortestRouteNodeIds[index][0] = ids[index]
     THEN tail(collect(shortestHopNodeId))
       ELSE tail(reverse(collect(shortestHopNodeId)))
       END as orderedHopNodeIds
  ORDER BY index
UNWIND orderedHopNodeIds as orderedHopNodeId
MATCH (c: Chalet) where id(c) = orderedHopNodeId
RETURN extract(c in orderedChalets | c.name) as names, 
       extract(c in orderedChalets | c.number) as chaletNumbers, 
       [orderedChalets[0].number] + collect(c.number) as chaletRoute, 
      totalCost
```

The algorithm should be considered in three steps. Each step is explained below.

#### Step 1

In Step 1, the shortest path between each of the chalets, is calculated using the graph algorithm `algo.shortestPath.stream` 
procedure. "SHORTEST_ROUTE_TO" relationships are merged between each distinct pair of selected chalets, with the 
total cost of the shortest path and the hops of the shortest path stored on the relationship. Some optimization is 
achieved by ensuring the shortest path between a pair of nodes is only calculated in one direction. 

To get a picture of the result of Step 1, running the following query give us the output of step 1.

```cypher
WITH  [109, 24, 169, 89, 32, 184, 181, 19] AS selection
MATCH p = (c1) -[r:SHORTEST_ROUTE_TO]- (c2)
  WHERE c1.number in selection 
  AND c2.number in selection
RETURN 
  c1.number as Chalet1, 
  c2.number as Chalet2, 
  r.cost as Cost, 
  r.shortestHopNodeIds as Hops
ORDER BY Chalet1, Chalet2
```

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/shortest_routes.png?raw=true "Mesh of Shortest Routes")

#### Step 2

Step 2 of the algorithm uses these newly calculated costs to return the shortest path that includes all of the selected 
chalets. The step makes use of APOC's `apoc.path.expandConfig` procedure, using SHORTEST_ROUTE_TO relationships to 
determine paths. Resultant paths are ordered by total cost. 

The path expander config constrains the path expanding algorithm to ensure that all of the selected chalets nodes are 
visited only once within the SHORTEST_ROUTE_TO mesh. It does this by ensuring that the number of levels traversed 
(`minLevel` and `maxLevel`) is equal to the number of chalets - 1 (7 in this case), and that all nodes traversed are unique.
 `whitelistNodes` limits the paths to the chalet selection, which provides some optimisation.

The path returned with lowest cost is the route that we want to take.

#### Step 3

Step 3 of the algorithm prepares the data for return, and provides a list of the full route through the chalets. 
It uses the `shortestHopNodeIds` calculated in Step 1, it tidies up the route removing duplicates and it ensures a 
consistent direction.

For our selected chalets the resulting of running the algorithm is:

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/optimal_route.png?raw=true "Optimal Route")

*Note: You may need to run the algorithm twice before getting consistent results! I have raised an issue [here](https://github.com/neo4j/neo4j/issues/12111) 
which describes the problem in more detail.* If anyone has any further insight here, please let me know!

So there we have it. An optimal route through the Christmas Market, stopping at all selected chalets. Now let's see if
we can get a good visual of the route, using the functionality of Neo4j Desktop.

## Visualizing the route

In this second section, we will look at how we can display the route calculated by the algorithm in the first section.
The idea is to produce a useable route planner, that guides the user from chalet to chalet.

Here is the wishlist of useful things to display in the the route planner.

1) The chalets in the route.
2) The order in which to traverse the chalets.
3) Entry and exit points for the route.
4) Chalets in the same zone coloured the same.
5) Zone nodes attached to chalets to indicate whenever there is a zone change.
6) Chalet names and numbers displayed.
7) Selected gift chalets should be indicated.

Here is the visual of the route, satisfying the wishlist above. 

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/images/show_route.png?raw=true "Route Guide through chalets")

APOC's virtual nodes and relationships help achieve this custom visual. The cypher code is shown and explained below.


```cypher
WITH [169, 109, 19, 24, 32, 184, 89, 181] AS selection,
     [169, 108, 109, 134, 127, 126, 123, 119, 13, 15, 16, 17, 18, 19, 24, 45, 88, 34, 32, 74, 78, 83, 
      184, 83, 78, 74, 89, 176, 181] AS route
MATCH (chalet :Chalet) WHERE chalet.number IN route 
WITH route, chalet,
     CASE WHEN chalet.number in selection 
     	  THEN 'Selected' 
     	  ELSE 'NotSelected' 
     	  END AS selected,
     CASE WHEN chalet.number in selection 
     	  THEN '* '+chalet.number+': '+chalet.name 
          ELSE chalet.number+': '+chalet.name 
          END AS title
CALL apoc.create.vNode([selected] + labels(chalet), {title: title}) YIELD node 
WITH route, collect(chalet) AS chalets, collect(node) as vChalets
CALL apoc.create.vNode(['EntryExit'], { ee: 'Enter'}) YIELD node as enter 
CALL apoc.create.vNode(['EntryExit'], { ee: 'Exit'}) YIELD node as exit 
MATCH (firstChalet :Chalet { number: head(route)})
MATCH (lastChalet :Chalet { number: last(route)})
CALL apoc.create.vRelationship(enter, 'VIA', {}, vChalets[apoc.coll.indexOf(chalets, firstChalet)] ) 
  YIELD rel as enteringVia
CALL apoc.create.vRelationship(vChalets[apoc.coll.indexOf(chalets, lastChalet)], 'VIA', {}, exit ) 
  YIELD rel as exitingVia
WITH apoc.coll.pairs(route) as hops, chalets, vChalets, enter, exit, enteringVia, exitingVia
UNWIND hops as hop
MATCH (from :Chalet {number: hop[0]}) -[l:LINKS_TO]- (to :Chalet {number: hop[1]}) 
CALL apoc.create.vRelationship(
	vChalets[apoc.coll.indexOf(chalets, from)], 
	'NEXT', 
	properties(l), 
	vChalets[apoc.coll.indexOf(chalets, to)] 
	)  YIELD rel as next
CALL apoc.create.vNode([null], { name: to.zone }) YIELD node as zone
CALL apoc.create.vRelationship(zone, 'HOSTS', {}, vChalets[apoc.coll.indexOf(chalets, to)] ) 
  YIELD rel as hosts
WITH chalets, vChalets, enter, exit, enteringVia, exitingVia, collect(next) as nexts, hops
MATCH (startZone :Zone) -[:HOSTS]-> (startChalet:Chalet { number: hops[0][0]})
CALL apoc.create.vNode(['Zone'], properties(startZone)) 
  YIELD node as vStartZone
CALL apoc.create.vRelationship(vStartZone, 'HOSTS', {}, vChalets[apoc.coll.indexOf(chalets, startChalet)]) 
  YIELD rel as startHost
UNWIND hops as hop
MATCH (zone1 :Zone) -[:HOSTS]-> (from:Chalet { number: hop[0]})
MATCH (zone2 :Zone) -[:HOSTS]-> (to:Chalet { number: hop[1]})
  WHERE apoc.coll.different([zone1, zone2])
CALL apoc.create.vNode(['Zone'], properties(zone2)) 
  YIELD node as zone
CALL apoc.create.vRelationship(zone, 'HOSTS', {}, vChalets[apoc.coll.indexOf(chalets, to)]) 
  YIELD rel as host
RETURN 
	vChalets, 
	enter, 
	exit, 
	enteringVia, 
	exitingVia, 
	nexts, 
	vStartZone, 
	startHost, 
	collect(zone) as zones, 
	collect(host) as hosts
```

First chalets are matched based on the route calculated by the algorithm in Section 1. Chalets are then marked as 
"Selected" or "NotSelected" based on whether or not they also exist in the original selection list. The text to display 
on each chaletnode is defined by `title` and virtual nodes are created for each chalet with labels and properties 
reflecting the matches. 

Virtual nodes for entry and exit points are created, and linked with a virtual `VIA` relationship to the first and last
chalets in the route. 

Virtual `NEXT` relationships are created to show the hops between each chalet. The `NEXT` relationship provides directionality
from chalet to chalet through the route. The original 

Virtual nodes are created for the zone, and attached to a virtual chalet nodes whenever there is a zone change.

## Conclusion

And that's it, typically it took a little longer than I expected and it's a bit late now for the 2018 Christmas Market. Maybe next year!

I hope you enjoyed it, and any questions or comments please feel free to drop me a line. 
