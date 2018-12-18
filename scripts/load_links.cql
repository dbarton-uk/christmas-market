LOAD CSV WITH HEADERS FROM 'file:///Links-Links.csv' AS csv
MATCH (c1:Chalet {id: toInteger(csv.from)})
MATCH (c2:Chalet {id: toInteger(csv.to)})
MERGE (c1) -[:LINKS_TO {cost: toInteger(csv.cost)}]-> (c2)