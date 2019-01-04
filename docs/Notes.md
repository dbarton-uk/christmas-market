##Introduction

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

##Setting up the Data

### Overview

The christmas market is split into zones, each defined by a unique name. A zone hosts a number of chalets, each with a 
unique name and number. A chalet has a description and is categorized by the type of gift that it sells. Links between 
chalets have been manually defined, with a cost assigned to each link. The link with its cost is used to determine the 
optimal route for a set of chalets.
 
60 chalets across 8 zones are defined, with the data sourced originally sourced from [The Bath Christmas Market website](https://bathchristmasmarket.co.uk) 
The raw data is available in the linked [spreadsheet file](https://github.com/dbarton-uk/christmas-market/blob/master/ChristmasMarket.numbers), 
extracted to [csv](https://github.com/dbarton-uk/christmas-market/tree/master/data).

The diagram below provides an overview of the `db.schema()`.

![alt text](https://github.com/dbarton-uk/christmas-market/blob/master/docs/db_schema.png?raw=true "the schema")


### Create constraints and indexes






-- Loading it up
-- Using categories

3) Visualising the data. Select presents.

4) High level explanation of algorithm

5) Description of algorithm implementation

6) Route map visualization, based on algorithm results

