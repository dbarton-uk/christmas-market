// Choose gifts
// Add Selected Label
WITH [{ number: 14, for: "Bro"},
       {number: 60, for: "Nan"},
       {number: 8, for: "Grandpa"},
       {number: 29, for: "Toby"},
       {number: 42, for: "The Girl"},
       {number: 43, for: "The Boy"},
       {number: 33, for: "The Missus"},
       {number: 59, for: "The Missus"}
     ] as gifts
UNWIND gifts as gift
MATCH (c:Chalet { number: gift.number})
CALL apoc.create.addLabels(id(c), ['Selected']) YIELD node
RETURN
  gift.number as Number,
  gift.for as For,
  c.name as Name,
  c.description as Description,
  c.zone as Zone,
  c.category as Category
  ORDER by c.zone, c.number