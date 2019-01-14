function omega = solid_angle_triangle(a, b, c)

%determ = a(1) * b(2) * c(3) + a(3) * b(1) * c(2) + a(2) * b(3) * c(1) - a(1) * b(3) * c(2) - a(2) * b(1) * c(3) - a(3) * b(2) * c(1);
determ = sum([b(2)*c(3) - b(3)*c(2); b(3)*c(1) - b(1)*c(3); b(1)*c(2) - b(2)*c(1)] .* a);

al = norm(a);
bl = norm(b);
cl = norm(c);
 
div = al * bl * cl + a' * b * cl + c' * a * bl + b' * c *al;

if in(0, div)
    error('atan2 can not computed.')
end

if div > 0
    at = atan(determ / div);
elseif determ > 0
    at = atan(-determ/-div) + pi;
elseif determ < 0
    at = atan(-determ/-div) - pi; 
else 
    error('atan2 can not computed.')
end

omega = 2 * at;
