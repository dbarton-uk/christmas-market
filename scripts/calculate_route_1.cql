// Calculate Route - 1
WITH  [109, 24, 169, 89, 32, 184, 181, 19] AS selection
MATCH (c:Chalet) where c.number IN selection
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