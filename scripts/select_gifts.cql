// Select gifts 
WITH [{ number: 109, for: "Bro"},
       {number: 24, for: "Nan"},
       {number: 169, for: "Grandpa"},
       {number: 89, for: "Toby"},
       {number: 32, for: "The Girl"},
       {number: 184, for: "The Boy"},
       {number: 181, for: "The Missus"},
       {number: 19, for: "The Missus"}
     ] as gifts
UNWIND gifts as gift
MATCH (c:Chalet { number: gift.number})
RETURN
  gift.number as Number,
  gift.for as For,
  c.name as Name,
  c.description as Description,
  c.zone as Zone,
  c.category as Category
  ORDER by c.zone, c.number