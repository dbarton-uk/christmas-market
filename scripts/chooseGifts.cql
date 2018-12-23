MATCH (c:Chalet)
RETURN c.number as No,
       c.name as Name,
       c.description as Description,
       labels(c) as Labels