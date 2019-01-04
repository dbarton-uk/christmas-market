## Introduction

The [Bath Christmas Market](https://bathchristmasmarket.co.uk) is a yearly extravaganza, where the city of Bath is 
transformed into a veritable Winter Wonterland with a selection of gift chalets for all your Christmas purchasing 
requirements. Or so they would have you believe. For me, long in the tooth and a little bit grumpy, it's a bit of a log  
jam. People shuffling between chalets with their Christmas spirit disappearing faster than the mince pies 
and hot toddy. When it comes to Christmas shopping, high focus efficiency is what is required! 

This project uses the Neo4j Graph Database to determine the optimum route through the christmas market, given 
a set of chalets to purchase from. It gives a user friendly visual of the route, using Neo4j Desktop, making use of 
virtual nodes and relationships.

Full source code, licensed under Apache License 2.0 is [available](https://github.com/dbarton-uk/christmas-market).

 
**Use Cases**

1. Optimum Route: Given a set of chalets to visit, define an optimum travel route between the chalets such that each of 
the set is visited at least once.
 
2. Visualize Route: Given the optimum route, provide a user friendly visual of the route.

## Setting up the Data

### Overview

The christmas market is split into zones, each defined by a unique name. A zone hosts a number of chalets, each with a 
unique name and number. A chalet has a description and is categorized by the type of gift that it sells. Links between 
chalets have been manually defined, with a cost assigned to each link. The link with its cost is used to determine the 
optimal route for a set of chalets.
 
60 chalets across 8 zones are defined, with the data sourced originally sourced from [The Bath Christmas Market website](https://bathchristmasmarket.co.uk) 
The raw data is available in the linked [spreadsheet file](https://github.com/dbarton-uk/christmas-market/blob/master/ChristmasMarket.numbers), 
extracted to [csv](https://github.com/dbarton-uk/christmas-market/tree/master/data).

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/docs/db_schema.png?raw=true "the schema")


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

1. First run [load_chalets.cql](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/load_chalets.cql)

```cypher
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/dbarton-uk/christmas-market/master/data/Chalets-Chalets.csv' AS csv
CREATE (c :Chalet {
  sequence: toInteger(csv.Id),
  number: toInteger(csv.Number),
  name: csv.Name,
  zone: csv.Zone,
  description: csv.Description
})
MERGE (z:Zone { name: csv.Zone})
WITH c, csv.Category as category, z
CALL apoc.create.addLabels( id(c), [apoc.text.capitalize(apoc.text.camelCase(category))]) YIELD node
MERGE (z) -[:HOSTS]-> (c)
```
`Added 68 labels, created 68 nodes, set 308 properties, created 60 relationships, completed after 540 ms.`

The load chalet script does the following:

- Creates chalet nodes based on [chalet csv data]([csv](https://github.com/dbarton-uk/christmas-market/blob/master/data/Chalets-Chalets.csv)
in the github repository.

- Create zone nodes based on zone data, which embedded in the [chalet csv](https://github.com/dbarton-uk/christmas-market/blob/master/data/Chalets-Chalets.csv).

- Adds category labels to chalet nodes. 

- Links zones to chalets with a `:HOSTS` relationship.

The chalets are split into 5 categories: Clothing and Accessories, Food and Drink, Gifts and Homeware, Health and Beauty 
and Home and Garden. These categories were added as labels rather than attributes to improve the visualization options 
available in Neo4j Desktop. The zone is also redundant on the chalet, for convenience.

2. Next run [load_links.cql](https://github.com/dbarton-uk/christmas-market/blob/master/scripts/load_links.cql)

```cypher
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/dbarton-uk/christmas-market/master/data/Links-Links.csv' AS csv
MATCH (c1:Chalet {sequence: toInteger(csv.from)})
MATCH (c2:Chalet {sequence: toInteger(csv.to)})
MERGE (c1) -[:LINKS_TO {cost: toInteger(csv.cost)}]-> (c2)
```

`Set 87 properties, created 87 relationships, completed after 347 ms.`

The script creates the links between chalets based on the link csv data in the [repository](https://github.com/dbarton-uk/christmas-market/blob/master/data/Links-Links.csv)
A cost is defined for each link. This cost is used in the algorithm that calculated the optimum route.

3. Check the data

#### Visuals

### Optimizing the route

#### Select presents
#### Explanation of algorithm
#### Visual of route

### Route visualisation
### Explanation of visual


