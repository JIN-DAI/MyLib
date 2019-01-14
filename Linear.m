function Value_k = Linear(k, Value_1, Value_2, Step)
%LINEAR SUMMARY
% Description: Linearly changing from Value_1 to Value_2 during Step return the value at k-th step.
% Author: Jin Dai
% Date: 2013.08.07

Value_k = (Value_2 - Value_1)*k/Step + Value_1;

end

