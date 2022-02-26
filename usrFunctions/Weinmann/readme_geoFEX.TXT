This is our tool geoFEX for calculating low-level geometric 3D and
2D features.


DESCRIPTION
  For each point in the point cloud, this function derives basic
  geometric properties of the respective local neighborhood by using
  the respective number of nearest neighbors. More
  details can be found in the following paper:

    M. Weinmann, S. Urban, S. Hinz, B. Jutzi, and C. Mallet (2015):
    Distinctive 2D and 3D features for automated large-scale scene
    analysis in urban areas. Computers & Graphics, Vol. 49, pp. 47-57.


INPUT VARIABLES

  XYZI          -   matrix containing XYZI [n x 4]
  nn_size       -   vector containing the number of neighbors for each 3D point 
  raster_size   -   raster size in [m], e.g. 0.25m


OUTPUT VARIABLES

  attributes    -   matrix containing attributes for each point in a point cloud 

                       column 01: linearity
                       column 02: planarity
                       column 03: scattering
                       column 04: omnivariance
                       column 05: anisotropy
                       column 06: eigenentropy
                       column 07: sum_EVs
                       column 08: change_of_curvature
                       column 09: Z_vals
                       column 10: radius_kNN
                       column 11: density
                       column 12: verticality
                       column 13: delta_Z_kNN
                       column 14: std_Z_kNN
                       column 15: radius_kNN_2D
                       column 16: density_2D
                       column 17: sum_EVs_2D
                       column 18: EV_ratio
                       column 19: frequency_acc_map
                       column 20: delta_z
                       column 21: std_z
                       columns 22-24: Evs in 3D
                       columns 25-26: EVs in 2D


USAGE
  [attributes] = geoFEX(XYZI,nn_size,raster_size)


LICENSE

  Copyright (C) 2015  Martin Weinmann

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
