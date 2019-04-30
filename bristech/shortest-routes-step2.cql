// Shortest Route (Step 2)
// Use apoc.expandConfig to find all routes of 7 levels
// Sort by total cost
MATCH (c1:Chalet:Selected)
WITH c1, 7 as level
CALL apoc.path.expandConfig(c1, {
  relationshipFilter: 'SHORTEST_ROUTE_TO',
  minLevel: 7,
  maxLevel: 7,
  uniqueness: 'NODE_PATH' }
) YIELD path
RETURN
  extract(n in nodes(path) | n.number) as orderedChaletNumbers,
  reduce(cost = 0, x in relationships(path) | cost + x.cost) as totalCost,
  extract(r in relationships(path) | r.shortestHopChaletNumbers) as shortestRouteChaletNumbers
  ORDER BY totalCost LIMIT 1