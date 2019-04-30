// Show Links between chalets
MATCH p = (c1:Chalet) -[:LINKS_TO]-> (c2:Chalet)
RETURN p