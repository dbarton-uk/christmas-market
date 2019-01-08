// Calculate Route - 1
WITH  [109, 24, 169, 89, 32, 184, 181, 19] AS selection
MATCH p = (c1) -[:SHORTEST_ROUTE_TO]- (c2)
  WHERE c1.number in selection and c2.number in selection
RETURN p