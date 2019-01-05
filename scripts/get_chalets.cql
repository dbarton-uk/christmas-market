// Show Chalets
MATCH (c :Chalet)
RETURN c.number as Number, c.name as Name, c.category as Category, c.zone as Zone
  ORDER BY c.zone, c.category, c.number