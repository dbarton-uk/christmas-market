// Shortest Route (Step 1)
// Find shortest path between all selected chalets
// Create a new relationship
// Add hop node ids to relationship
MATCH (c:Chalet:Selected)
WITH collect(c) as chalets
UNWIND chalets as c1
WITH c1,
     filter(c in chalets where c.number > c1.number) as c2s
UNWIND c2s as c2
CALL algo.shortestPath.stream(c1, c2, 'cost', {relationshipQuery: 'LINKS_TO'}) YIELD nodeId, cost
WITH c1,
     c2,
     max(cost) as totalCost,
     collect(nodeId) as shortestHopNodeIds
UNWIND shortestHopNodeIds as shortestHopNodeId
MATCH (chalet:Chalet) where id(chalet) = shortestHopNodeId
WITH
  c1,
  c2,
  totalCost,
  collect(chalet.number) as shortestHopChaletNumbers
MERGE (c1) -[r:SHORTEST_ROUTE_TO]- (c2)
SET r.cost = totalCost
SET r.shortestHopChaletNumbers = shortestHopChaletNumbers