# Barycenter for the Two Body Problem

<img src="https://github.com/davewalker5/RC2014/blob/main/Applications/Barycenter/Barycenter.png" alt="Barycenter Calculator" width="600">

A barycenter is defined as the common centre of mass of two or more bodies orbiting one another.

For the two body problem, it's expressed as a distance from the center of the primary body (the one with the higher mass).

It's calculated as follows:

$$ r_1 = {a \times m_2 \over m_1 + m_2} $$

Where:

- r<sub>1</sub> = the distance from the primary body to the barycenter (km)
- a = the distance between the two bodies (km)
- m<sub>1</sub> = mass of the primary body (kg)
- m<sub>2</sub> = mass of the secondary body (kg)

For example, for the Earth-Moon system:

- a = 388400
- m<sub>1</sub> = 5.97 x 10<sup>24</sup> kg
- m<sub>2</sub> = 0.079 x 10<sup>24</sup> kg

This gives a value of 4643.59 km for r<sub>1</sub>.

If the ratio of the masses is known rather than the absolute masses:

$$ m_2 \over m_1 $$

Then enter 1 as the mass of the primary body and the above ratio as the mess of the secondary body.

For the Earth-Moon system:

- a = 388400
- m<sub>1</sub> = 1
- m<sub>2</sub> = 0.0122278

This, again, gives a value of 4643.59 km for r<sub>1</sub>.

# References

- [Barycenter](<https://en.wikipedia.org/wiki/Barycenter_(astronomy)>), Wikipedia
- [What is a Barycenter?](https://spaceplace.nasa.gov/barycenter/en/), NASA
