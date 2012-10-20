taiwanPersonalTax = (salary) ->
  baseTaxFree = 82000 + 76000 + 104000 # 免稅額, 標準扣除額, 薪資所得特別扣除額
  salary = if (salary > baseTaxFree) then salary - baseTaxFree else 0
  rawTax = | (salary > 4230000) => salary * 0.4 - 774400
           | (salary > 2260000) => salary * 0.3 - 351400
           | (salary > 1130000) => salary * 0.2 - 125400
           | (salary > 500000) => salary * 0.12 - 35000
           | otherwise => salary * 0.05
