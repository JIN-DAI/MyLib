function omega = solid_angle_quadrilateral(a, b, c, d)

omega = solid_angle_triangle(a, b, c) + solid_angle_triangle(c, d, a);
