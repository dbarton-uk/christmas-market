// Show Chalets
MATCH (c :Chalet)
RETURN c.zone, c1.category, c.number, c.name
  ORDER BY c.zone, c.category, c.number