MATCH p = (z:Zone) -[:HOSTS]-> (c1:Chalet)
MATCH q = (c1) -[:LINKS_TO]-> (c2:Chalet)
MATCH r = (z) -[:HOSTS]-> (c2)
RETURN p, q, r