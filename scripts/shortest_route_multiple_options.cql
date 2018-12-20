WITH  [[111, 112], [83], [181], [39], [126], [143], [32], [89]] AS chaletNumbers
UNWIND chaletNumbers as froms
WITH froms,
     filter(s in chaletNumbers where s[0] > froms[0]) as toChaletNumbers,
     chaletNumbers
UNWIND toChaletNumbers as tos
UNWIND froms as from
UNWIND tos as to
WITH from, to, chaletNumbers
MATCH (c1:Chalet { number: from})
MATCH (c2:Chalet { number: to})
CALL algo.shortestPath.stream(c1, c2, 'cost', {relationshipQuery: 'LINKS_TO'}) YIELD nodeId, cost
WITH c1,
     c2,
     max(cost) as totalCost,
     chaletNumbers,
     collect(nodeId) as shortestHopNodeIds
MERGE (c1) -[r:SHORTEST_ROUTE_TO]- (c2)
SET r.cost = totalCost
SET r.shortestHopNodeIds = shortestHopNodeIds
WITH c1,
     c2,
     (size(chaletNumbers) - 1) as level
CALL apoc.path.expandConfig(c1, {relationshipFilter: 'SHORTEST_ROUTE_TO', minLevel: level, maxLevel: level, terminatorNodes: [c2], uniqueness: 'NODE_PATH'}) YIELD path
WITH extract(n in nodes(path) | n.number) as chaletNumbers,
     extract(n in nodes(path) | id(n)) as ids,
     extract(n in nodes(path) | n.name) as names,
     reduce(cost = 0, x in relationships(path) | cost + x.cost) as totalCost,
     extract(r in relationships(path) | r.shortestHopNodeIds) as shortestRouteNodeIds
  ORDER BY totalCost LIMIT 1
UNWIND range(0, size(chaletNumbers) - 1) as index
UNWIND shortestRouteNodeIds[index] as shortestHopNodeId
WITH chaletNumbers, names, totalCost, index,
     CASE WHEN shortestRouteNodeIds[index][0] = ids[index]
     THEN tail(collect(shortestHopNodeId))
       ELSE tail(reverse(collect(shortestHopNodeId)))
       END as orderedHopNodeIds
  ORDER BY index
UNWIND orderedHopNodeIds as orderedHopNodeId
MATCH (c: Chalet) where id(c) = orderedHopNodeId
RETURN names, chaletNumbers, [chaletNumbers[0]] + collect(c.number) as chaletRoute, totalCost