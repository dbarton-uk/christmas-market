WITH  [16, 41, 33, 48, 22, 12, 43, 29] AS selection
UNWIND selection  as start
WITH start,
     filter(s in selection where s > start) as ends,
     selection
UNWIND ends as end
MATCH (c1:Chalet { id: start})
MATCH (c2:Chalet { id: end})
CALL algo.shortestPath.stream(c1, c2, 'cost', {relationshipQuery: 'LINKS_TO'}) YIELD nodeId, cost
WITH c1,
     c2,
     max(cost) as totalCost,
     selection,
     collect(nodeId) as shortestHopNodeIds
MERGE (c1) -[r:SHORTEST_ROUTE_TO]- (c2)
SET r.cost = totalCost
SET r.shortestHopNodeIds = shortestHopNodeIds
WITH c1,
     c2,
     (size(selection) - 1) as level
CALL apoc.path.expandConfig(c1, {relationshipFilter: 'SHORTEST_ROUTE_TO', minLevel: level, maxLevel: level, terminatorNodes: [c2], uniqueness: 'NODE_PATH'}) YIELD path
WITH extract(n in nodes(path) | n.id) as ids,
     extract(n in nodes(path) | id(n)) as systemIds,
     extract(n in nodes(path) | n.name) as names,
     reduce(cost = 0, x in relationships(path) | cost + x.cost) as totalCost,
     extract(r in relationships(path) | r.shortestHopNodeIds) as shortestRouteNodeIds
ORDER BY totalCost LIMIT 1
UNWIND range(0, size(ids) - 1) as index
UNWIND shortestRouteNodeIds[index] as shortestHopNodeId
WITH ids, names, totalCost, index,
     CASE WHEN shortestRouteNodeIds[index][0] = systemIds[index]
     THEN tail(collect(shortestHopNodeId))
       ELSE tail(reverse(collect(shortestHopNodeId)))
       END as orderedHopNodeIds
     ORDER BY index
UNWIND orderedHopNodeIds as orderedHopNodeId
MATCH (c: Chalet) where id(c) = orderedHopNodeId
RETURN names, ids, [ids[0]] + collect(c.id) as route, totalCost