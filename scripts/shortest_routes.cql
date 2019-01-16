// Shortest Routes
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