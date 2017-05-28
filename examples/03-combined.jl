using DataValues

A = [?(9), ?(8), ?(15)]

map(i->isnull(i) ? false : get(i) % 3 == 0, A)

f(i) = isnull(i) ? false : get(i) % 3 == 0

f.(A)
