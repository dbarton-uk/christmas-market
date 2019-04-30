// Show Links between chalets in zones
// Could use where clause alternatively
MATCH p = (c1:Chalet) -[:LINKS_TO]-> (c2:Chalet)
MATCH q = (c2) <-[:HOSTS]- (z:Zone) -[:HOSTS]-> (c1)
RETURN p,q