// Load Links
LOAD CSV WITH HEADERS
  FROM 'https://raw.githubusercontent.com/dbarton-uk/christmas-market/master/data/Links-Links.csv'
  AS csv
MATCH (c1:Chalet {sequence: toInteger(csv.from)})
MATCH (c2:Chalet {sequence: toInteger(csv.to)})
MERGE (c1) -[:LINKS_TO {cost: toInteger(csv.cost)}]-> (c2)

