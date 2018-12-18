WITH  [16, 41, 33, 48, 22, 12, 43, 29] AS selection
UNWIND selection  as start
WITH start, filter(s in selection where s < start) as endList, selection
UNWIND endList as end
MATCH (c1:Chalet { id: start})
MATCH (c2:Chalet { id: end})
CALL algo.shortestPath.stream(c1, c2, 'cost', {relationshipQuery: 'LINKS_TO'}) YIELD nodeId, cost
WITH c1, c2, max(cost) as totalCost, selection, collect(nodeId) as nodes
MERGE (c1) -[r:SHORTEST_ROUTE_TO]- (c2)
SET r.cost = totalCost
SET r.nodes = nodes
WITH c1, c2,(size(selection) - 1) as level
CALL apoc.path.expandConfig(c1, {relationshipFilter: 'SHORTEST_ROUTE_TO', minLevel: level, maxLevel: level, terminatorNodes: [c2], uniqueness: 'NODE_PATH'}) YIELD path
WITH extract(n in nodes(path) | n.id) as nodeIds, reduce(s = 0, x in relationships(path) | s + x.cost) as cost
RETURN nodeIds, cost ORDER by cost LIMIT 1