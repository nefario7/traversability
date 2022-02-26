This is our tool optNESS for deriving optimal 3D neighborhoods via
eigenentropy-based scale selection.


DESCRIPTION

  For each individual 3D point, this function calculates the optimal
  neighborhood size formed by the respective k nearest neighbors. More
  details can be found in the following paper:

    M. Weinmann, B. Jutzi, and C. Mallet (2014): Semantic 3D scene
    interpretation: a framework combining optimal neighborhood size
    selection with relevant features. In: K. Schindler and N. Paparoditis
    (Eds.), ISPRS Technical Commission III Symposium. ISPRS Annals of the
    Photogrammetry, Remote Sensing and Spatial Information Sciences,
    Vol. II-3, pp. 181-188. 


INPUT VARIABLES (we omit checking input variables for useful values)

  XYZ               -   [n x 3]-matrix containing XYZ coordinates
                        (n: number of considered 3D points)
  k_min             -   minimum number of neighbors to be considered
  k_max             -   maximum number of neighbors to be considered
  delta_k           -   stepsize within the interval [k_min,k_max]


OUTPUT VARIABLES

  opt_nn_size       -   vector describing the optimal neighborhood size
                        for each individual 3D point


USAGE
  [opt_nn_size] = optNESS(XYZ,k_min,k_max,delta_k)


LICENSE

  Copyright (C) 2014  Martin Weinmann

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


CONTACT

  Martin Weinmann
  Institute of Photogrammetry and Remote Sensing, Karlsruhe Institute of Technology (KIT)
  email:   martin.weinmann@kit.edu



