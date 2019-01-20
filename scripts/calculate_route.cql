// Calculate Route
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