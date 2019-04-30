// Shortest Route (Step 3)
// Using orderedChaletNumbers and shortestHopChaletNumber
// Retrieve chalet route
WITH [8, 14, 59, 60, 43, 42, 29, 33] AS orderedSelectedChaletNumbers,
     [[8, 13, 14], [14, 24, 23, 22, 21, 20, 54, 55, 56, 57, 58, 59], [59, 60], [43, 44, 53, 50, 60], [42, 41, 40, 39, 43], [29, 39, 40, 41, 42], [29, 32, 33]] AS shortestRouteChaletNumbers
UNWIND range(0, 7) as index
WITH CASE WHEN orderedSelectedChaletNumbers[index] = shortestRouteChaletNumbers[index][0]
THEN shortestRouteChaletNumbers[index]
       ELSE reverse(shortestRouteChaletNumbers[index])
       END as orderedChaletNumbers
UNWIND orderedChaletNumbers as chaletNumber
MATCH (c:Chalet {number: chaletNumber})
RETURN c.name, c.number