// Load Chalets
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/dbarton-uk/christmas-market/master/data/Chalets-Chalets.csv' AS csv
CREATE (c :Chalet {
  sequence: toInteger(csv.Id),
  number: toInteger(csv.Number),
  name: csv.Name,
  description: csv.Description,
  zone: csv.Zone,
  category: csv.category

})
MERGE (z:Zone { name: csv.Zone})
WITH c, csv.Category as category, z
CALL apoc.create.addLabels( id(c), [apoc.text.capitalize(apoc.text.camelCase(category))]) YIELD node
MERGE (z) -[:HOSTS]-> (c)