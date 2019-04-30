// Show Chalets in each zone
MATCH p = (:Zone) -[:HOSTS]-> (:Chalet) RETURN p