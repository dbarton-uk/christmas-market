WITH [83, 78, 74, 89, 176, 181, 176, 35, 39, 35, 34, 32, 59, 57, 50, 47, 119, 123, 126, 112, 111, 112, 114, 116, 143] as route
UNWIND range(0, size(route) - 2) as index
MATCH p=(c1:Chalet {number: route[index]}) -[:LINKS_TO]-  (c2:Chalet {number: route[index + 1]})
MATCH q= (z1:Zone) -[:HOSTS]-> (c1)
MATCH r =(z2:Zone) -[:HOSTS]-> (c2)
RETURN p,q,r