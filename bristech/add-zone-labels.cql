// Add Zone Labels
MATCH (c1:Chalet)
WITH c1, c1.zone as zone
CALL apoc.create.addLabels(id(c1), [zone]) YIELD node
RETURN node