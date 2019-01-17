WITH [169, 109, 19, 24, 32, 184, 89, 181] AS selection,
     [169, 108, 109, 134, 127, 126, 123, 119, 13, 15, 16, 17, 18, 19, 24, 45, 88, 34, 32, 74, 78, 83, 184, 83, 78, 74, 89, 176, 181] AS route
MATCH (chalet :Chalet) WHERE chalet.number IN route
WITH route, chalet, CASE WHEN chalet.number in selection THEN 'isSelected' ELSE null END AS isSelected
CALL apoc.create.vNode(labels(chalet) + isSelected, {title: chalet.number+': ' + chalet.name}) YIELD node
WITH route, collect(chalet) AS chalets, collect(node) as vChalets
CALL apoc.create.vNode(['EntryExit'], { ee: 'Enter'}) yield node as enter
CALL apoc.create.vNode(['EntryExit'], { ee: 'Exit'}) yield node as exit
MATCH (firstChalet :Chalet { number: head(route)})
MATCH (lastChalet :Chalet { number: last(route)})
CALL apoc.create.vRelationship(enter, 'VIA', {}, vChalets[apoc.coll.indexOf(chalets, firstChalet)] ) YIELD rel as enteringVia
CALL apoc.create.vRelationship(vChalets[apoc.coll.indexOf(chalets, lastChalet)], 'VIA', {}, exit ) YIELD rel as exitingVia
WITH apoc.coll.pairs(route) as hops, chalets, vChalets, enter, exit, enteringVia, exitingVia
UNWIND hops as hop
MATCH (from :Chalet {number: hop[0]}) -[l:LINKS_TO]- (to :Chalet {number: hop[1]})
CALL apoc.create.vRelationship(vChalets[apoc.coll.indexOf(chalets, from)], 'NEXT', properties(l), vChalets[apoc.coll.indexOf(chalets, to)] ) YIELD rel as next
CALL apoc.create.vNode([null], { name: to.zone }) YIELD node as zone
CALL apoc.create.vRelationship(zone, 'HOSTS', {}, vChalets[apoc.coll.indexOf(chalets, to)] ) YIELD rel as hosts
RETURN vChalets, enter, exit, enteringVia, exitingVia, collect(next) as nexts, hops