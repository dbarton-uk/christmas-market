// Load Links
// Match from and to chalets and create LINKS_TO relationship
LOAD CSV WITH HEADERS
FROM 'file:///Users/davidbarton/Projects/dbarton-uk/christmas-market/data/Links-Links.csv'
AS csv
MATCH (c1:Chalet {number: toInteger(csv.from)})
MATCH (c2:Chalet {number: toInteger(csv.to)})
MERGE (c1) -[:LINKS_TO {cost: toInteger(csv.cost)}]-> (c2)