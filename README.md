# Gaming the Christmas Market

The code is a contrived example that aims to provide a "travelling salesman" type algorithm implemented in neo4j and 
cypher. Given an array of points as an input, the algorithm provides the optimum order for visiting these points.

The implementation is based on the a Christmas Market containing multiple chalets. The chalets and a 'cost' of moving
between chalets is modelled in a neo4j graph. Given a subset of chalets, the optimum route is calculated using 
cypher (and apoc) to determine the 'quickest' route through the chalets to purchase all presents.




	