LOAD CSV WITH HEADERS FROM 'file:///Chalets-Chalets.csv' AS csv
CREATE (c :Chalet {
  sequence: toInteger(csv.Id),
  number: toInteger(csv.Number),
  name: csv.Name,
  zone: csv.Zone,
  description: csv.Description
})
MERGE (z:Zone { name: csv.Zone})
WITH c, csv.Category as category, z
CALL apoc.create.addLabels( id(c), [apoc.text.capitalize(apoc.text.camelCase(category))]) YIELD node
MERGE (z) -[:HOSTS]-> (c)