function n = linking_number(gamma0, gamma1);

n = intval(0);

length_0 = size(gamma0, 2);
length_1 = size(gamma1, 2);

gamma0 = intval(gamma0);
gamma1 = intval(gamma1);

for i = 1:length_0
    for j = 1:length_1
        a = gamma1(:, j)                    + 0     - gamma0(:, i);
        b = gamma1(:, j)                    - gamma0(:, mod(i, length_0) + 1);
        c = gamma1(:, mod(j, length_1) + 1) - gamma0(:, mod(i, length_0) + 1);
        d = gamma1(:, mod(j, length_1) + 1) + 0     - gamma0(:, i);
        n = n + solid_angle_quadrilateral(a, b, c, d);
    end
end

n = n / (4 * midrad(pi, 1e-14))
