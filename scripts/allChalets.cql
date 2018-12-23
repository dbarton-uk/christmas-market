MATCH (z:Zone) -[]-> (c:Chalet) WITH z, min(c.sequence) as chaletId
MATCH p = (z) -[]-> (c:Chalet { sequence: chaletId})
MATCH q = (:Chalet) -[:LINKS_TO]-> (:Chalet) RETURN p, q